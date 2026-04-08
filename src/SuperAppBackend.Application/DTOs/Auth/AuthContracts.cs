using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.DTOs.Auth;

public sealed record GoogleSignInRequest(string IdToken, string DeviceName, string? PreferredCurrency);

public sealed record DevelopmentSignInRequest(string Email, string FullName, string DeviceName, string? PreferredCurrency);

public sealed record PasswordSignInRequest(string Email, string Password, string DeviceName);

public sealed record RefreshTokenRequest(string RefreshToken, string DeviceName);

public sealed record ExternalUserInfo(
    AuthProvider Provider,
    string Subject,
    string Email,
    string FullName,
    string? PictureUrl);

public sealed record UserProfileDto(
    Guid Id,
    string Email,
    string FullName,
    string PreferredCurrency,
    string? AvatarUrl,
    UserRole Role);

public sealed record AuthResponse(
    string AccessToken,
    DateTimeOffset AccessTokenExpiresAtUtc,
    string RefreshToken,
    UserProfileDto User);

public sealed record AccessTokenResult(string Token, DateTimeOffset ExpiresAtUtc);
