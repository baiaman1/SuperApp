using Microsoft.EntityFrameworkCore;

namespace SuperAppBackend.Infrastructure.Persistence.Seeding;

public sealed class DatabaseSchemaBootstrapper(AppDbContext dbContext)
{
    public async Task EnsureCompatibilityAsync(CancellationToken cancellationToken = default)
    {
        if (!await dbContext.Database.CanConnectAsync(cancellationToken))
        {
            return;
        }

        await dbContext.Database.ExecuteSqlRawAsync(
            """
            ALTER TABLE users
            ADD COLUMN IF NOT EXISTS "Role" integer NOT NULL DEFAULT 1;
            """,
            cancellationToken);

        await dbContext.Database.ExecuteSqlRawAsync(
            """
            CREATE TABLE IF NOT EXISTS local_credentials (
                "Id" uuid NOT NULL,
                "UserId" uuid NOT NULL,
                "PasswordHash" character varying(1024) NOT NULL,
                "PasswordChangedAtUtc" timestamp with time zone NULL,
                "CreatedAtUtc" timestamp with time zone NOT NULL,
                "UpdatedAtUtc" timestamp with time zone NOT NULL,
                CONSTRAINT "PK_local_credentials" PRIMARY KEY ("Id"),
                CONSTRAINT "FK_local_credentials_users_UserId" FOREIGN KEY ("UserId") REFERENCES users ("Id") ON DELETE CASCADE
            );
            """,
            cancellationToken);

        await dbContext.Database.ExecuteSqlRawAsync(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "IX_local_credentials_UserId"
            ON local_credentials ("UserId");
            """,
            cancellationToken);
    }
}
