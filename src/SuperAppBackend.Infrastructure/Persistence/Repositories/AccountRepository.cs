using Microsoft.EntityFrameworkCore;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Domain.Entities;

namespace SuperAppBackend.Infrastructure.Persistence.Repositories;

public sealed class AccountRepository(AppDbContext dbContext) : IAccountRepository
{
    public async Task<IReadOnlyCollection<MoneyAccount>> ListByUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        return await dbContext.Accounts
            .AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderBy(x => x.DisplayOrder)
            .ThenBy(x => x.Name)
            .ToArrayAsync(cancellationToken);
    }

    public Task<MoneyAccount?> GetByIdAsync(Guid userId, Guid accountId, CancellationToken cancellationToken)
    {
        return dbContext.Accounts
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Id == accountId, cancellationToken);
    }

    public async Task<IReadOnlyCollection<MoneyAccount>> GetByIdsAsync(Guid userId, IReadOnlyCollection<Guid> accountIds, CancellationToken cancellationToken)
    {
        return await dbContext.Accounts
            .Where(x => x.UserId == userId && accountIds.Contains(x.Id))
            .ToArrayAsync(cancellationToken);
    }

    public Task AddAsync(MoneyAccount account, CancellationToken cancellationToken)
    {
        return dbContext.Accounts.AddAsync(account, cancellationToken).AsTask();
    }
}
