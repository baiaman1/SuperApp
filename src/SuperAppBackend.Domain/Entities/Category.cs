using SuperAppBackend.Domain.Common;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Domain.Entities;

public sealed class Category : AuditableEntity
{
    public Guid UserId { get; set; }

    public string Name { get; set; } = string.Empty;

    public CategoryKind Kind { get; set; }

    public string? Icon { get; set; }

    public string? Color { get; set; }

    public bool IsSystem { get; set; }

    public bool IsArchived { get; set; }

    public int DisplayOrder { get; set; }

    public User User { get; set; } = null!;

    public ICollection<MoneyTransaction> Transactions { get; set; } = new List<MoneyTransaction>();
}
