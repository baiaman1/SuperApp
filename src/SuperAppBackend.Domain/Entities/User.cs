using SuperAppBackend.Domain.Common;

namespace SuperAppBackend.Domain.Entities;

public sealed class User : AuditableEntity
{
    public string Email { get; set; } = string.Empty;

    public string FullName { get; set; } = string.Empty;

    public string PreferredCurrency { get; set; } = "KZT";

    public string? AvatarUrl { get; set; }

    public bool IsActive { get; set; } = true;

    public ICollection<ExternalIdentity> ExternalIdentities { get; set; } = new List<ExternalIdentity>();

    public ICollection<MoneyAccount> Accounts { get; set; } = new List<MoneyAccount>();

    public ICollection<Category> Categories { get; set; } = new List<Category>();

    public ICollection<MoneyTransaction> Transactions { get; set; } = new List<MoneyTransaction>();

    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
}
