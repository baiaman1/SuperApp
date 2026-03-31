using SuperAppBackend.Application.DTOs.Transactions;
using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.Interfaces.Persistence;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid userId, CancellationToken cancellationToken);

    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken);

    Task<User?> GetByExternalIdentityAsync(AuthProvider provider, string subject, CancellationToken cancellationToken);

    Task AddAsync(User user, CancellationToken cancellationToken);
}

public interface IAccountRepository
{
    Task<IReadOnlyCollection<MoneyAccount>> ListByUserAsync(Guid userId, CancellationToken cancellationToken);

    Task<MoneyAccount?> GetByIdAsync(Guid userId, Guid accountId, CancellationToken cancellationToken);

    Task<IReadOnlyCollection<MoneyAccount>> GetByIdsAsync(Guid userId, IReadOnlyCollection<Guid> accountIds, CancellationToken cancellationToken);

    Task AddAsync(MoneyAccount account, CancellationToken cancellationToken);
}

public interface ICategoryRepository
{
    Task<IReadOnlyCollection<Category>> ListByUserAsync(Guid userId, CategoryKind? kind, CancellationToken cancellationToken);

    Task<Category?> GetByIdAsync(Guid userId, Guid categoryId, CancellationToken cancellationToken);

    Task AddAsync(Category category, CancellationToken cancellationToken);
}

public interface ITransactionRepository
{
    Task<IReadOnlyCollection<MoneyTransaction>> ListByUserAsync(Guid userId, TransactionListFilter filter, CancellationToken cancellationToken);

    Task<int> CountByUserAsync(Guid userId, TransactionListFilter filter, CancellationToken cancellationToken);

    Task<MoneyTransaction?> GetByIdAsync(Guid userId, Guid transactionId, CancellationToken cancellationToken);

    Task<IReadOnlyCollection<MoneyTransaction>> GetByTransferGroupAsync(Guid userId, Guid transferGroupId, CancellationToken cancellationToken);

    Task AddAsync(MoneyTransaction transaction, CancellationToken cancellationToken);

    Task AddRangeAsync(IEnumerable<MoneyTransaction> transactions, CancellationToken cancellationToken);

    void RemoveRange(IEnumerable<MoneyTransaction> transactions);
}

public interface IRefreshTokenRepository
{
    Task AddAsync(RefreshToken refreshToken, CancellationToken cancellationToken);

    Task<RefreshToken?> GetByTokenHashAsync(string tokenHash, CancellationToken cancellationToken);
}

public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}
