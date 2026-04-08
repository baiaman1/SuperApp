using Microsoft.AspNetCore.Identity;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Entities;

namespace SuperAppBackend.Infrastructure.Authentication.Local;

public sealed class AspNetPasswordHasher : IAppPasswordHasher
{
    private readonly PasswordHasher<User> _passwordHasher = new();

    public string HashPassword(User user, string password)
    {
        return _passwordHasher.HashPassword(user, password);
    }

    public bool VerifyPassword(User user, string passwordHash, string password)
    {
        var result = _passwordHasher.VerifyHashedPassword(user, passwordHash, password);
        return result is PasswordVerificationResult.Success or PasswordVerificationResult.SuccessRehashNeeded;
    }
}
