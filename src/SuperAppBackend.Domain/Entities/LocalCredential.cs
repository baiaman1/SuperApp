using SuperAppBackend.Domain.Common;

namespace SuperAppBackend.Domain.Entities;

public sealed class LocalCredential : AuditableEntity
{
    public Guid UserId { get; set; }

    public string PasswordHash { get; set; } = string.Empty;

    public DateTimeOffset? PasswordChangedAtUtc { get; set; }

    public User User { get; set; } = null!;
}
