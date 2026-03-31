using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SuperAppBackend.Domain.Entities;

namespace SuperAppBackend.Infrastructure.Persistence.Configurations;

internal sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Email).HasMaxLength(256).IsRequired();
        builder.Property(x => x.FullName).HasMaxLength(256).IsRequired();
        builder.Property(x => x.PreferredCurrency).HasMaxLength(3).IsRequired();
        builder.Property(x => x.AvatarUrl).HasMaxLength(1024);

        builder.HasIndex(x => x.Email).IsUnique();
    }
}

internal sealed class ExternalIdentityConfiguration : IEntityTypeConfiguration<ExternalIdentity>
{
    public void Configure(EntityTypeBuilder<ExternalIdentity> builder)
    {
        builder.ToTable("external_identities");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Subject).HasMaxLength(256).IsRequired();
        builder.Property(x => x.Email).HasMaxLength(256).IsRequired();
        builder.Property(x => x.ProviderDisplayName).HasMaxLength(256);

        builder.HasIndex(x => new { x.Provider, x.Subject }).IsUnique();

        builder.HasOne(x => x.User)
            .WithMany(x => x.ExternalIdentities)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

internal sealed class MoneyAccountConfiguration : IEntityTypeConfiguration<MoneyAccount>
{
    public void Configure(EntityTypeBuilder<MoneyAccount> builder)
    {
        builder.ToTable("accounts");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name).HasMaxLength(128).IsRequired();
        builder.Property(x => x.CurrencyCode).HasMaxLength(3).IsRequired();
        builder.Property(x => x.Balance).HasPrecision(18, 2);

        builder.HasIndex(x => new { x.UserId, x.DisplayOrder });

        builder.HasOne(x => x.User)
            .WithMany(x => x.Accounts)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

internal sealed class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> builder)
    {
        builder.ToTable("categories");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name).HasMaxLength(128).IsRequired();
        builder.Property(x => x.Icon).HasMaxLength(128);
        builder.Property(x => x.Color).HasMaxLength(32);

        builder.HasIndex(x => new { x.UserId, x.Kind, x.DisplayOrder });

        builder.HasOne(x => x.User)
            .WithMany(x => x.Categories)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

internal sealed class MoneyTransactionConfiguration : IEntityTypeConfiguration<MoneyTransaction>
{
    public void Configure(EntityTypeBuilder<MoneyTransaction> builder)
    {
        builder.ToTable("transactions");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Amount).HasPrecision(18, 2);
        builder.Property(x => x.Note).HasMaxLength(1000);

        builder.HasIndex(x => new { x.UserId, x.OccurredAtUtc });
        builder.HasIndex(x => x.TransferGroupId);

        builder.HasOne(x => x.User)
            .WithMany(x => x.Transactions)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Account)
            .WithMany(x => x.Transactions)
            .HasForeignKey(x => x.AccountId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Category)
            .WithMany(x => x.Transactions)
            .HasForeignKey(x => x.CategoryId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}

internal sealed class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("refresh_tokens");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.TokenHash).HasMaxLength(256).IsRequired();
        builder.Property(x => x.DeviceName).HasMaxLength(256).IsRequired();

        builder.HasIndex(x => x.TokenHash).IsUnique();

        builder.HasOne(x => x.User)
            .WithMany(x => x.RefreshTokens)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
