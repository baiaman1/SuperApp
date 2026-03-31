namespace SuperAppBackend.Infrastructure.Authentication.Jwt;

public sealed class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Issuer { get; set; } = "SuperAppBackend";

    public string Audience { get; set; } = "SuperAppMobile";

    public string SecretKey { get; set; } = "ChangeThisSuperSecretKeyForProduction_123456789";

    public int AccessTokenMinutes { get; set; } = 60;
}
