using System.Security.Claims;
using SuperAppBackend.Application.Common.Exceptions;

namespace SuperAppBackend.WebApi.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetRequiredUserId(this ClaimsPrincipal principal)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? principal.FindFirstValue("sub");

        if (!Guid.TryParse(userId, out var parsedUserId))
        {
            throw new ForbiddenException("Не удалось определить пользователя по токену.");
        }

        return parsedUserId;
    }
}
