using SuperAppBackend.Application.DTOs.Dashboard;
using SuperAppBackend.Application.DTOs.Transactions;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.Services;

public sealed class DashboardService(
    IAccountRepository accountRepository,
    ITransactionRepository transactionRepository) : IDashboardService
{
    public async Task<DashboardSummaryDto> GetSummaryAsync(Guid userId, DashboardSummaryRequest request, CancellationToken cancellationToken)
    {
        var transactions = await transactionRepository.ListByUserAsync(
            userId,
            new TransactionListFilter(
                request.AccountId,
                null,
                null,
                request.DateFromUtc,
                request.DateToUtc,
                1,
                1000),
            cancellationToken);

        var accounts = await accountRepository.ListByUserAsync(userId, cancellationToken);

        var totalIncome = transactions
            .Where(x => x.EntryType == TransactionEntryType.Income)
            .Sum(x => x.Amount);

        var totalExpense = transactions
            .Where(x => x.EntryType == TransactionEntryType.Expense)
            .Sum(x => x.Amount);

        return new DashboardSummaryDto(
            totalIncome,
            totalExpense,
            totalIncome - totalExpense,
            accounts.Sum(x => x.Balance));
    }
}
