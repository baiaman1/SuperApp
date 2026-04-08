using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.DTOs.Transactions;

public sealed record CreateTransactionRequest(
    Guid AccountId,
    Guid CategoryId,
    TransactionEntryType EntryType,
    decimal Amount,
    string? Note,
    DateTimeOffset OccurredAtUtc);

public sealed record UpdateTransactionRequest(
    Guid AccountId,
    Guid CategoryId,
    TransactionEntryType EntryType,
    decimal Amount,
    string? Note,
    DateTimeOffset OccurredAtUtc);

public sealed record CreateTransferRequest(
    Guid FromAccountId,
    Guid ToAccountId,
    decimal Amount,
    string? Note,
    DateTimeOffset OccurredAtUtc);

public sealed record TransactionDto(
    Guid Id,
    Guid AccountId,
    string AccountName,
    Guid? CategoryId,
    string? CategoryName,
    TransactionEntryType EntryType,
    decimal Amount,
    string? Note,
    DateTimeOffset OccurredAtUtc,
    Guid? TransferGroupId,
    Guid? CounterpartyAccountId);

public sealed record TransactionListFilter(
    Guid? AccountId,
    Guid? CategoryId,
    TransactionEntryType? EntryType,
    DateTimeOffset? DateFromUtc,
    DateTimeOffset? DateToUtc,
    int PageNumber = 1,
    int PageSize = 50);
