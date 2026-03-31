using SuperAppBackend.Domain.Common;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Domain.Entities;

public sealed class ExternalIdentity : AuditableEntity
{
    public Guid UserId { get; set; }

    public AuthProvider Provider { get; set; }

    public string Subject { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string? ProviderDisplayName { get; set; }

    public User User { get; set; } = null!;
}
