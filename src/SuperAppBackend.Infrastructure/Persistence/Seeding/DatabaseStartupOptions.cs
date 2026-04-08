namespace SuperAppBackend.Infrastructure.Persistence.Seeding;

public sealed class DatabaseStartupOptions
{
    public const string SectionName = "Database";

    public bool AutoApplyOnStartup { get; set; } = true;

    public bool ResetOnStartup { get; set; }

    public bool SeedMockDataOnStartup { get; set; }
}
