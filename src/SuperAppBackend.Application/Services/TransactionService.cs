using SuperAppBackend.Application.Common.Exceptions;
using SuperAppBackend.Application.Common.Models;
using SuperAppBackend.Application.DTOs.Transactions;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.Services;

public sealed class TransactionService(
    IAccountRepository accountRepository,
    ICategoryRepository categoryRepository,
    ITransactionRepository transactionRepository,
    IUnitOfWork unitOfWork) : ITransactionService
{
    public async Task<PagedResult<TransactionDto>> GetTransactionsAsync(Guid userId, TransactionListFilter filter, CancellationToken cancellationToken)
    {
        var sanitizedFilter = filter with
        {
            PageNumber = filter.PageNumber < 1 ? 1 : filter.PageNumber,
            PageSize = filter.PageSize is < 1 or > 200 ? 50 : filter.PageSize
        };

        var items = await transactionRepository.ListByUserAsync(userId, sanitizedFilter, cancellationToken);
        var totalCount = await transactionRepository.CountByUserAsync(userId, sanitizedFilter, cancellationToken);

        return new PagedResult<TransactionDto>
        {
            Items = items.Select(Map).ToArray(),
            PageNumber = sanitizedFilter.PageNumber,
            PageSize = sanitizedFilter.PageSize,
            TotalCount = totalCount
        };
    }

    public async Task<TransactionDto> CreateTransactionAsync(Guid userId, CreateTransactionRequest request, CancellationToken cancellationToken)
    {
        ValidateTransactionRequest(request);

        if (request.EntryType is TransactionEntryType.TransferIn or TransactionEntryType.TransferOut)
        {
            throw new ValidationException("Для переводов между счетами используйте отдельный endpoint transfer.");
        }

        var account = await accountRepository.GetByIdAsync(userId, request.AccountId, cancellationToken)
            ?? throw new NotFoundException("Счет не найден.");

        var category = await categoryRepository.GetByIdAsync(userId, request.CategoryId, cancellationToken)
            ?? throw new NotFoundException("Категория не найдена.");

        EnsureCategoryMatches(request.EntryType, category.Kind);

        var transaction = new MoneyTransaction
        {
            UserId = userId,
            AccountId = request.AccountId,
            CategoryId = request.CategoryId,
            EntryType = request.EntryType,
            Amount = request.Amount,
            Note = request.Note?.Trim(),
            OccurredAtUtc = request.OccurredAtUtc == default ? DateTimeOffset.UtcNow : request.OccurredAtUtc
        };

        ApplyAccountBalance(account, transaction.EntryType, transaction.Amount);

        await transactionRepository.AddAsync(transaction, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        transaction.Account = account;
        transaction.Category = category;

        return Map(transaction);
    }

    public async Task<TransactionDto> UpdateTransactionAsync(Guid userId, Guid transactionId, UpdateTransactionRequest request, CancellationToken cancellationToken)
    {
        ValidateTransactionRequest(request.AccountId, request.CategoryId, request.Amount);

        if (request.EntryType is TransactionEntryType.TransferIn or TransactionEntryType.TransferOut)
        {
            throw new ValidationException("Редактирование переводов пока не поддерживается. Удалите перевод и создайте его заново.");
        }

        var transaction = await transactionRepository.GetByIdAsync(userId, transactionId, cancellationToken)
            ?? throw new NotFoundException("Операция не найдена.");

        if (transaction.TransferGroupId.HasValue)
        {
            throw new ValidationException("Редактирование переводов пока не поддерживается. Удалите перевод и создайте его заново.");
        }

        var affectedAccountIds = new[] { transaction.AccountId, request.AccountId }.Distinct().ToArray();
        var accounts = await accountRepository.GetByIdsAsync(userId, affectedAccountIds, cancellationToken);
        var currentAccount = accounts.SingleOrDefault(x => x.Id == transaction.AccountId)
            ?? throw new NotFoundException("Счет операции не найден.");
        var nextAccount = accounts.SingleOrDefault(x => x.Id == request.AccountId)
            ?? throw new NotFoundException("Новый счет не найден.");

        var category = await categoryRepository.GetByIdAsync(userId, request.CategoryId, cancellationToken)
            ?? throw new NotFoundException("Категория не найдена.");

        EnsureCategoryMatches(request.EntryType, category.Kind);

        ApplyAccountBalance(currentAccount, GetReverseEntryType(transaction.EntryType), transaction.Amount);
        ApplyAccountBalance(nextAccount, request.EntryType, request.Amount);

        transaction.AccountId = nextAccount.Id;
        transaction.Account = nextAccount;
        transaction.CategoryId = category.Id;
        transaction.Category = category;
        transaction.EntryType = request.EntryType;
        transaction.Amount = request.Amount;
        transaction.Note = request.Note?.Trim();
        transaction.OccurredAtUtc = request.OccurredAtUtc == default ? DateTimeOffset.UtcNow : request.OccurredAtUtc;
        transaction.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return Map(transaction);
    }

    public async Task<IReadOnlyCollection<TransactionDto>> CreateTransferAsync(Guid userId, CreateTransferRequest request, CancellationToken cancellationToken)
    {
        if (request.FromAccountId == request.ToAccountId)
        {
            throw new ValidationException("Счета для перевода должны отличаться.");
        }

        if (request.Amount <= 0)
        {
            throw new ValidationException("Сумма перевода должна быть больше нуля.");
        }

        var accounts = await accountRepository.GetByIdsAsync(userId, [request.FromAccountId, request.ToAccountId], cancellationToken);
        var fromAccount = accounts.SingleOrDefault(x => x.Id == request.FromAccountId)
            ?? throw new NotFoundException("Счет списания не найден.");
        var toAccount = accounts.SingleOrDefault(x => x.Id == request.ToAccountId)
            ?? throw new NotFoundException("Счет зачисления не найден.");

        var transferGroupId = Guid.NewGuid();
        var occurredAtUtc = request.OccurredAtUtc == default ? DateTimeOffset.UtcNow : request.OccurredAtUtc;

        var outgoing = new MoneyTransaction
        {
            UserId = userId,
            AccountId = fromAccount.Id,
            EntryType = TransactionEntryType.TransferOut,
            Amount = request.Amount,
            Note = request.Note?.Trim(),
            OccurredAtUtc = occurredAtUtc,
            TransferGroupId = transferGroupId,
            CounterpartyAccountId = toAccount.Id
        };

        var incoming = new MoneyTransaction
        {
            UserId = userId,
            AccountId = toAccount.Id,
            EntryType = TransactionEntryType.TransferIn,
            Amount = request.Amount,
            Note = request.Note?.Trim(),
            OccurredAtUtc = occurredAtUtc,
            TransferGroupId = transferGroupId,
            CounterpartyAccountId = fromAccount.Id
        };

        ApplyAccountBalance(fromAccount, outgoing.EntryType, outgoing.Amount);
        ApplyAccountBalance(toAccount, incoming.EntryType, incoming.Amount);

        await transactionRepository.AddRangeAsync([outgoing, incoming], cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        outgoing.Account = fromAccount;
        incoming.Account = toAccount;

        return [Map(outgoing), Map(incoming)];
    }

    public async Task DeleteTransactionAsync(Guid userId, Guid transactionId, CancellationToken cancellationToken)
    {
        var transaction = await transactionRepository.GetByIdAsync(userId, transactionId, cancellationToken)
            ?? throw new NotFoundException("Операция не найдена.");

        IReadOnlyCollection<MoneyTransaction> transactionsToDelete = transaction.TransferGroupId.HasValue
            ? await transactionRepository.GetByTransferGroupAsync(userId, transaction.TransferGroupId.Value, cancellationToken)
            : [transaction];

        var affectedAccountIds = transactionsToDelete.Select(x => x.AccountId).Distinct().ToArray();
        var accounts = await accountRepository.GetByIdsAsync(userId, affectedAccountIds, cancellationToken);

        foreach (var item in transactionsToDelete)
        {
            var account = accounts.Single(x => x.Id == item.AccountId);
            ApplyAccountBalance(account, GetReverseEntryType(item.EntryType), item.Amount);
        }

        transactionRepository.RemoveRange(transactionsToDelete);
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private static void ValidateTransactionRequest(CreateTransactionRequest request)
    {
        if (request.Amount <= 0)
        {
            throw new ValidationException("Сумма операции должна быть больше нуля.");
        }

        if (request.AccountId == Guid.Empty)
        {
            throw new ValidationException("AccountId обязателен.");
        }

        if (request.CategoryId == Guid.Empty)
        {
            throw new ValidationException("CategoryId обязателен.");
        }
    }

    private static void ValidateTransactionRequest(Guid accountId, Guid categoryId, decimal amount)
    {
        if (amount <= 0)
        {
            throw new ValidationException("Сумма операции должна быть больше нуля.");
        }

        if (accountId == Guid.Empty)
        {
            throw new ValidationException("AccountId обязателен.");
        }

        if (categoryId == Guid.Empty)
        {
            throw new ValidationException("CategoryId обязателен.");
        }
    }

    private static void EnsureCategoryMatches(TransactionEntryType entryType, CategoryKind categoryKind)
    {
        if (entryType == TransactionEntryType.Income && categoryKind != CategoryKind.Income)
        {
            throw new ValidationException("Для дохода можно использовать только категорию типа Income.");
        }

        if (entryType == TransactionEntryType.Expense && categoryKind != CategoryKind.Expense)
        {
            throw new ValidationException("Для расхода можно использовать только категорию типа Expense.");
        }
    }

    private static void ApplyAccountBalance(MoneyAccount account, TransactionEntryType entryType, decimal amount)
    {
        account.Balance += entryType switch
        {
            TransactionEntryType.Income => amount,
            TransactionEntryType.TransferIn => amount,
            TransactionEntryType.Expense => -amount,
            TransactionEntryType.TransferOut => -amount,
            _ => throw new ValidationException("Неподдерживаемый тип операции.")
        };

        account.UpdatedAtUtc = DateTimeOffset.UtcNow;
    }

    private static TransactionEntryType GetReverseEntryType(TransactionEntryType entryType)
    {
        return entryType switch
        {
            TransactionEntryType.Income => TransactionEntryType.Expense,
            TransactionEntryType.Expense => TransactionEntryType.Income,
            TransactionEntryType.TransferIn => TransactionEntryType.TransferOut,
            TransactionEntryType.TransferOut => TransactionEntryType.TransferIn,
            _ => throw new ValidationException("Неподдерживаемый тип операции.")
        };
    }

    private static TransactionDto Map(MoneyTransaction transaction)
    {
        return new TransactionDto(
            transaction.Id,
            transaction.AccountId,
            transaction.Account.Name,
            transaction.CategoryId,
            transaction.Category?.Name,
            transaction.EntryType,
            transaction.Amount,
            transaction.Note,
            transaction.OccurredAtUtc,
            transaction.TransferGroupId,
            transaction.CounterpartyAccountId);
    }
}
