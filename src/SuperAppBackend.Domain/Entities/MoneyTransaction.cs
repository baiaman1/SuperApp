using SuperAppBackend.Domain.Common;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Domain.Entities;

public sealed class MoneyTransaction : AuditableEntity
{
    public Guid UserId { get; set; }

    public Guid AccountId { get; set; }

    public Guid? CategoryId { get; set; }

    public TransactionEntryType EntryType { get; set; }

    public decimal Amount { get; set; }

    public string? Note { get; set; }

    public DateTimeOffset OccurredAtUtc { get; set; }

    public Guid? TransferGroupId { get; set; }

    public Guid? CounterpartyAccountId { get; set; }

    public User User { get; set; } = null!;

    public MoneyAccount Account { get; set; } = null!;

    public Category? Category { get; set; }
}
