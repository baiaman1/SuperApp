namespace SuperAppBackend.Application.DTOs.Dashboard;

public sealed record DashboardSummaryRequest(
    Guid? AccountId,
    DateTimeOffset? DateFromUtc,
    DateTimeOffset? DateToUtc);

public sealed record DashboardSummaryDto(
    decimal TotalIncome,
    decimal TotalExpense,
    decimal Net,
    decimal TotalBalance);
