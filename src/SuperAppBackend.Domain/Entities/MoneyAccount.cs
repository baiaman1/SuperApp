using SuperAppBackend.Domain.Common;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Domain.Entities;

public sealed class MoneyAccount : AuditableEntity
{
    public Guid UserId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string CurrencyCode { get; set; } = "KZT";

    public AccountKind Kind { get; set; } = AccountKind.Cash;

    public decimal Balance { get; set; }

    public bool IsArchived { get; set; }

    public int DisplayOrder { get; set; }

    public User User { get; set; } = null!;

    public ICollection<MoneyTransaction> Transactions { get; set; } = new List<MoneyTransaction>();
}
