namespace SuperAppBackend.Infrastructure.Authentication.Google;

public sealed class GoogleAuthOptions
{
    public const string SectionName = "GoogleAuth";

    public string[] ClientIds { get; set; } = [];
}
