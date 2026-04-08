using Microsoft.EntityFrameworkCore;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Domain.Common;
using SuperAppBackend.Domain.Entities;

namespace SuperAppBackend.Infrastructure.Persistence;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options), IUnitOfWork
{
    public DbSet<User> Users => Set<User>();

    public DbSet<ExternalIdentity> ExternalIdentities => Set<ExternalIdentity>();

    public DbSet<LocalCredential> LocalCredentials => Set<LocalCredential>();

    public DbSet<MoneyAccount> Accounts => Set<MoneyAccount>();

    public DbSet<Category> Categories => Set<Category>();

    public DbSet<MoneyTransaction> Transactions => Set<MoneyTransaction>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTimeOffset.UtcNow;

        foreach (var entry in ChangeTracker.Entries<AuditableEntity>())
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.CreatedAtUtc = now;
            }

            if (entry.State is EntityState.Added or EntityState.Modified)
            {
                entry.Entity.UpdatedAtUtc = now;
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
