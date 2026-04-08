using System.Security.Cryptography;
using System.Text;
using SuperAppBackend.Application.Common.Defaults;
using SuperAppBackend.Application.Common.Exceptions;
using SuperAppBackend.Application.DTOs.Auth;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.Services;

public sealed class AuthService(
    IUserRepository userRepository,
    IRefreshTokenRepository refreshTokenRepository,
    IGoogleTokenVerifier googleTokenVerifier,
    IJwtTokenService jwtTokenService,
    IAppPasswordHasher passwordHasher,
    IUnitOfWork unitOfWork) : IAuthService
{
    private static readonly TimeSpan RefreshTokenLifetime = TimeSpan.FromDays(30);

    public async Task<AuthResponse> SignInWithGoogleAsync(GoogleSignInRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.IdToken))
        {
            throw new ValidationException("Google idToken обязателен.");
        }

        var externalUser = await googleTokenVerifier.VerifyAsync(request.IdToken, cancellationToken);
        return await SignInAsync(externalUser, request.DeviceName, request.PreferredCurrency, cancellationToken);
    }

    public Task<AuthResponse> SignInDevelopmentAsync(DevelopmentSignInRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
        {
            throw new ValidationException("Email обязателен.");
        }

        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            throw new ValidationException("Имя пользователя обязательно.");
        }

        var email = request.Email.Trim().ToLowerInvariant();

        var externalUser = new ExternalUserInfo(
            AuthProvider.Development,
            email,
            email,
            request.FullName.Trim(),
            null);

        return SignInAsync(externalUser, request.DeviceName, request.PreferredCurrency, cancellationToken);
    }

    public async Task<AuthResponse> SignInWithPasswordAsync(PasswordSignInRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
        {
            throw new ValidationException("Email is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            throw new ValidationException("Password is required.");
        }

        var user = await userRepository.GetByEmailAsync(request.Email.Trim().ToLowerInvariant(), cancellationToken);
        if (user?.LocalCredential is null || !passwordHasher.VerifyPassword(user, user.LocalCredential.PasswordHash, request.Password))
        {
            throw new ForbiddenException("Invalid email or password.");
        }

        if (!user.IsActive)
        {
            throw new ForbiddenException("User account is inactive.");
        }

        var refreshToken = CreateRefreshToken(user.Id, request.DeviceName);
        await refreshTokenRepository.AddAsync(refreshToken.Entity, cancellationToken);

        var accessToken = jwtTokenService.CreateAccessToken(user.Id, user.Email, user.FullName, user.Role);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new AuthResponse(
            accessToken.Token,
            accessToken.ExpiresAtUtc,
            refreshToken.RawToken,
            MapUser(user));
    }

    public async Task<AuthResponse> RefreshAsync(RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            throw new ValidationException("Refresh token обязателен.");
        }

        var tokenHash = HashToken(request.RefreshToken);
        var refreshToken = await refreshTokenRepository.GetByTokenHashAsync(tokenHash, cancellationToken);

        if (refreshToken is null || refreshToken.RevokedAtUtc.HasValue || refreshToken.ExpiresAtUtc <= DateTimeOffset.UtcNow)
        {
            throw new ForbiddenException("Refresh token недействителен или истек.");
        }

        refreshToken.RevokedAtUtc = DateTimeOffset.UtcNow;
        refreshToken.DeviceName = request.DeviceName.TrimOrDefault("Unknown device");

        var replacementToken = CreateRefreshToken(refreshToken.UserId, request.DeviceName);
        await refreshTokenRepository.AddAsync(replacementToken.Entity, cancellationToken);

        var accessToken = jwtTokenService.CreateAccessToken(
            refreshToken.User.Id,
            refreshToken.User.Email,
            refreshToken.User.FullName,
            refreshToken.User.Role);

        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new AuthResponse(accessToken.Token, accessToken.ExpiresAtUtc, replacementToken.RawToken, MapUser(refreshToken.User));
    }

    public async Task<UserProfileDto> GetProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetByIdAsync(userId, cancellationToken)
            ?? throw new NotFoundException("Пользователь не найден.");

        return MapUser(user);
    }

    private async Task<AuthResponse> SignInAsync(
        ExternalUserInfo externalUser,
        string? deviceName,
        string? preferredCurrency,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(externalUser.Email))
        {
            throw new ValidationException("В ответе провайдера отсутствует email.");
        }

        var normalizedEmail = externalUser.Email.Trim().ToLowerInvariant();
        var user = await userRepository.GetByExternalIdentityAsync(externalUser.Provider, externalUser.Subject, cancellationToken)
            ?? await userRepository.GetByEmailAsync(normalizedEmail, cancellationToken);

        if (user is null)
        {
            user = new User
            {
                Email = normalizedEmail,
                FullName = externalUser.FullName.Trim(),
                PreferredCurrency = string.IsNullOrWhiteSpace(preferredCurrency) ? "KZT" : preferredCurrency.Trim().ToUpperInvariant(),
                AvatarUrl = externalUser.PictureUrl
            };

            user.ExternalIdentities.Add(new ExternalIdentity
            {
                Provider = externalUser.Provider,
                Subject = externalUser.Subject,
                Email = normalizedEmail,
                ProviderDisplayName = externalUser.FullName.Trim()
            });

            user.Accounts.Add(DefaultDataFactory.CreateDefaultAccount(user.Id, user.PreferredCurrency));
            foreach (var category in DefaultDataFactory.CreateDefaultCategories(user.Id))
            {
                user.Categories.Add(category);
            }

            await userRepository.AddAsync(user, cancellationToken);
        }
        else
        {
            user.FullName = externalUser.FullName.Trim();
            user.Email = normalizedEmail;
            user.AvatarUrl = externalUser.PictureUrl;
            user.UpdatedAtUtc = DateTimeOffset.UtcNow;

            var hasIdentity = user.ExternalIdentities.Any(x => x.Provider == externalUser.Provider && x.Subject == externalUser.Subject);
            if (!hasIdentity)
            {
                user.ExternalIdentities.Add(new ExternalIdentity
                {
                    UserId = user.Id,
                    Provider = externalUser.Provider,
                    Subject = externalUser.Subject,
                    Email = normalizedEmail,
                    ProviderDisplayName = externalUser.FullName.Trim()
                });
            }

            if (!user.Accounts.Any())
            {
                user.Accounts.Add(DefaultDataFactory.CreateDefaultAccount(user.Id, user.PreferredCurrency));
            }

            if (!user.Categories.Any())
            {
                foreach (var category in DefaultDataFactory.CreateDefaultCategories(user.Id))
                {
                    user.Categories.Add(category);
                }
            }
        }

        var refreshToken = CreateRefreshToken(user.Id, deviceName);
        await refreshTokenRepository.AddAsync(refreshToken.Entity, cancellationToken);

        var accessToken = jwtTokenService.CreateAccessToken(user.Id, user.Email, user.FullName, user.Role);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new AuthResponse(accessToken.Token, accessToken.ExpiresAtUtc, refreshToken.RawToken, MapUser(user));
    }

    private static (RefreshToken Entity, string RawToken) CreateRefreshToken(Guid userId, string? deviceName)
    {
        var rawToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

        return (new RefreshToken
        {
            UserId = userId,
            DeviceName = deviceName.TrimOrDefault("Unknown device"),
            TokenHash = HashToken(rawToken),
            ExpiresAtUtc = DateTimeOffset.UtcNow.Add(RefreshTokenLifetime)
        }, rawToken);
    }

    private static string HashToken(string token)
    {
        return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));
    }

    private static UserProfileDto MapUser(User user)
    {
        return new UserProfileDto(user.Id, user.Email, user.FullName, user.PreferredCurrency, user.AvatarUrl, user.Role);
    }
}

internal static class StringExtensions
{
    public static string TrimOrDefault(this string? value, string fallback)
    {
        return string.IsNullOrWhiteSpace(value) ? fallback : value.Trim();
    }
}
