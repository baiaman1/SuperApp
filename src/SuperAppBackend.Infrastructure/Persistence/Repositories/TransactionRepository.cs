using Microsoft.EntityFrameworkCore;
using SuperAppBackend.Application.DTOs.Transactions;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Domain.Entities;

namespace SuperAppBackend.Infrastructure.Persistence.Repositories;

public sealed class TransactionRepository(AppDbContext dbContext) : ITransactionRepository
{
    public async Task<IReadOnlyCollection<MoneyTransaction>> ListByUserAsync(Guid userId, TransactionListFilter filter, CancellationToken cancellationToken)
    {
        return await BuildQuery(userId, filter, applyPaging: true)
            .AsNoTracking()
            .Include(x => x.Account)
            .Include(x => x.Category)
            .ToArrayAsync(cancellationToken);
    }

    public Task<int> CountByUserAsync(Guid userId, TransactionListFilter filter, CancellationToken cancellationToken)
    {
        return BuildQuery(userId, filter, applyPaging: false).CountAsync(cancellationToken);
    }

    public Task<MoneyTransaction?> GetByIdAsync(Guid userId, Guid transactionId, CancellationToken cancellationToken)
    {
        return dbContext.Transactions
            .Include(x => x.Account)
            .Include(x => x.Category)
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Id == transactionId, cancellationToken);
    }

    public async Task<IReadOnlyCollection<MoneyTransaction>> GetByTransferGroupAsync(Guid userId, Guid transferGroupId, CancellationToken cancellationToken)
    {
        return await dbContext.Transactions
            .Where(x => x.UserId == userId && x.TransferGroupId == transferGroupId)
            .ToArrayAsync(cancellationToken);
    }

    public Task AddAsync(MoneyTransaction transaction, CancellationToken cancellationToken)
    {
        return dbContext.Transactions.AddAsync(transaction, cancellationToken).AsTask();
    }

    public Task AddRangeAsync(IEnumerable<MoneyTransaction> transactions, CancellationToken cancellationToken)
    {
        return dbContext.Transactions.AddRangeAsync(transactions, cancellationToken);
    }

    public void RemoveRange(IEnumerable<MoneyTransaction> transactions)
    {
        dbContext.Transactions.RemoveRange(transactions);
    }

    private IQueryable<MoneyTransaction> BuildQuery(Guid userId, TransactionListFilter filter, bool applyPaging)
    {
        var query = dbContext.Transactions
            .Where(x => x.UserId == userId);

        if (filter.AccountId.HasValue)
        {
            query = query.Where(x => x.AccountId == filter.AccountId.Value);
        }

        if (filter.CategoryId.HasValue)
        {
            query = query.Where(x => x.CategoryId == filter.CategoryId.Value);
        }

        if (filter.EntryType.HasValue)
        {
            query = query.Where(x => x.EntryType == filter.EntryType.Value);
        }

        if (filter.DateFromUtc.HasValue)
        {
            query = query.Where(x => x.OccurredAtUtc >= filter.DateFromUtc.Value);
        }

        if (filter.DateToUtc.HasValue)
        {
            query = query.Where(x => x.OccurredAtUtc <= filter.DateToUtc.Value);
        }

        query = query
            .OrderByDescending(x => x.OccurredAtUtc)
            .ThenByDescending(x => x.CreatedAtUtc);

        if (applyPaging)
        {
            var pageNumber = filter.PageNumber < 1 ? 1 : filter.PageNumber;
            var pageSize = filter.PageSize is < 1 or > 200 ? 50 : filter.PageSize;
            query = query.Skip((pageNumber - 1) * pageSize).Take(pageSize);
        }

        return query;
    }
}
