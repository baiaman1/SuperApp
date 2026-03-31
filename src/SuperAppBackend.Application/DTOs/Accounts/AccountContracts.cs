using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.DTOs.Accounts;

public sealed record MoneyAccountDto(
    Guid Id,
    string Name,
    string CurrencyCode,
    AccountKind Kind,
    decimal Balance,
    bool IsArchived,
    int DisplayOrder);

public sealed record CreateMoneyAccountRequest(
    string Name,
    string CurrencyCode,
    AccountKind Kind,
    decimal OpeningBalance,
    int? DisplayOrder);

public sealed record UpdateMoneyAccountRequest(
    string Name,
    string CurrencyCode,
    AccountKind Kind,
    bool IsArchived,
    int? DisplayOrder);
