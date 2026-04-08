using Microsoft.EntityFrameworkCore;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Infrastructure.Persistence.Repositories;

public sealed class UserRepository(AppDbContext dbContext) : IUserRepository
{
    public Task<User?> GetByIdAsync(Guid userId, CancellationToken cancellationToken)
    {
        return dbContext.Users
            .AsSplitQuery()
            .Include(x => x.ExternalIdentities)
            .Include(x => x.LocalCredential)
            .Include(x => x.Accounts)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);
    }

    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken)
    {
        return dbContext.Users
            .AsSplitQuery()
            .Include(x => x.ExternalIdentities)
            .Include(x => x.LocalCredential)
            .Include(x => x.Accounts)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.Email == email, cancellationToken);
    }

    public Task<User?> GetByExternalIdentityAsync(AuthProvider provider, string subject, CancellationToken cancellationToken)
    {
        return dbContext.Users
            .AsSplitQuery()
            .Include(x => x.ExternalIdentities)
            .Include(x => x.LocalCredential)
            .Include(x => x.Accounts)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(
                x => x.ExternalIdentities.Any(identity => identity.Provider == provider && identity.Subject == subject),
                cancellationToken);
    }

    public Task AddAsync(User user, CancellationToken cancellationToken)
    {
        return dbContext.Users.AddAsync(user, cancellationToken).AsTask();
    }
}
