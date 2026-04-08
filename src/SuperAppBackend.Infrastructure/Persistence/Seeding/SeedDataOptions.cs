namespace SuperAppBackend.Infrastructure.Persistence.Seeding;

public sealed class SeedDataOptions
{
    public const string SectionName = "SeedData";

    public string SuperAdminEmail { get; set; } = "admin@superapp.local";

    public string SuperAdminPassword { get; set; } = "Admin123!";

    public string DemoUserEmail { get; set; } = "demo@superapp.local";

    public string DemoUserPassword { get; set; } = "Demo123!";
}
