using Google.Apis.Auth;
using Microsoft.Extensions.Options;
using SuperAppBackend.Application.Common.Exceptions;
using SuperAppBackend.Application.DTOs.Auth;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Infrastructure.Authentication.Google;

public sealed class GoogleTokenVerifier(IOptions<GoogleAuthOptions> options) : IGoogleTokenVerifier
{
    private readonly GoogleAuthOptions _options = options.Value;

    public async Task<ExternalUserInfo> VerifyAsync(string idToken, CancellationToken cancellationToken)
    {
        if (_options.ClientIds.Length == 0)
        {
            throw new ValidationException("Google ClientIds не настроены.");
        }

        var settings = new GoogleJsonWebSignature.ValidationSettings
        {
            Audience = _options.ClientIds
        };

        var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

        return new ExternalUserInfo(
            AuthProvider.Google,
            payload.Subject,
            payload.Email,
            payload.Name ?? payload.Email,
            payload.Picture);
    }
}
