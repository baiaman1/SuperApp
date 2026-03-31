using SuperAppBackend.Application.Common.Exceptions;
using SuperAppBackend.Application.DTOs.Accounts;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Entities;

namespace SuperAppBackend.Application.Services;

public sealed class AccountService(
    IAccountRepository accountRepository,
    IUnitOfWork unitOfWork) : IAccountService
{
    public async Task<IReadOnlyCollection<MoneyAccountDto>> GetAccountsAsync(Guid userId, CancellationToken cancellationToken)
    {
        var accounts = await accountRepository.ListByUserAsync(userId, cancellationToken);
        return accounts.Select(Map).ToArray();
    }

    public async Task<MoneyAccountDto> CreateAccountAsync(Guid userId, CreateMoneyAccountRequest request, CancellationToken cancellationToken)
    {
        ValidateRequest(request.Name, request.CurrencyCode);

        var account = new MoneyAccount
        {
            UserId = userId,
            Name = request.Name.Trim(),
            CurrencyCode = request.CurrencyCode.Trim().ToUpperInvariant(),
            Kind = request.Kind,
            Balance = request.OpeningBalance,
            DisplayOrder = request.DisplayOrder ?? 0
        };

        await accountRepository.AddAsync(account, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Map(account);
    }

    public async Task<MoneyAccountDto> UpdateAccountAsync(Guid userId, Guid accountId, UpdateMoneyAccountRequest request, CancellationToken cancellationToken)
    {
        ValidateRequest(request.Name, request.CurrencyCode);

        var account = await accountRepository.GetByIdAsync(userId, accountId, cancellationToken)
            ?? throw new NotFoundException("Счет не найден.");

        account.Name = request.Name.Trim();
        account.CurrencyCode = request.CurrencyCode.Trim().ToUpperInvariant();
        account.Kind = request.Kind;
        account.IsArchived = request.IsArchived;
        account.DisplayOrder = request.DisplayOrder ?? account.DisplayOrder;
        account.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return Map(account);
    }

    private static void ValidateRequest(string name, string currencyCode)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            throw new ValidationException("Название счета обязательно.");
        }

        if (string.IsNullOrWhiteSpace(currencyCode) || currencyCode.Trim().Length != 3)
        {
            throw new ValidationException("Код валюты должен состоять из 3 символов.");
        }
    }

    private static MoneyAccountDto Map(MoneyAccount account)
    {
        return new MoneyAccountDto(
            account.Id,
            account.Name,
            account.CurrencyCode,
            account.Kind,
            account.Balance,
            account.IsArchived,
            account.DisplayOrder);
    }
}
