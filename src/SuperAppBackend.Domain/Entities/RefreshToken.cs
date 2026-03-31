using SuperAppBackend.Domain.Common;

namespace SuperAppBackend.Domain.Entities;

public sealed class RefreshToken : AuditableEntity
{
    public Guid UserId { get; set; }

    public string TokenHash { get; set; } = string.Empty;

    public string DeviceName { get; set; } = string.Empty;

    public DateTimeOffset ExpiresAtUtc { get; set; }

    public DateTimeOffset? RevokedAtUtc { get; set; }

    public User User { get; set; } = null!;
}
