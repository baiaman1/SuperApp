using SuperAppBackend.Application.Common.Models;
using SuperAppBackend.Application.DTOs.Accounts;
using SuperAppBackend.Application.DTOs.Auth;
using SuperAppBackend.Application.DTOs.Categories;
using SuperAppBackend.Application.DTOs.Dashboard;
using SuperAppBackend.Application.DTOs.Transactions;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.Interfaces.Services;

public interface IGoogleTokenVerifier
{
    Task<ExternalUserInfo> VerifyAsync(string idToken, CancellationToken cancellationToken);
}

public interface IJwtTokenService
{
    AccessTokenResult CreateAccessToken(Guid userId, string email, string fullName, UserRole role);
}

public interface IAppPasswordHasher
{
    string HashPassword(Domain.Entities.User user, string password);

    bool VerifyPassword(Domain.Entities.User user, string passwordHash, string password);
}

public interface IAuthService
{
    Task<AuthResponse> SignInWithGoogleAsync(GoogleSignInRequest request, CancellationToken cancellationToken);

    Task<AuthResponse> SignInDevelopmentAsync(DevelopmentSignInRequest request, CancellationToken cancellationToken);

    Task<AuthResponse> SignInWithPasswordAsync(PasswordSignInRequest request, CancellationToken cancellationToken);

    Task<AuthResponse> RefreshAsync(RefreshTokenRequest request, CancellationToken cancellationToken);

    Task<UserProfileDto> GetProfileAsync(Guid userId, CancellationToken cancellationToken);
}

public interface IAccountService
{
    Task<IReadOnlyCollection<MoneyAccountDto>> GetAccountsAsync(Guid userId, CancellationToken cancellationToken);

    Task<MoneyAccountDto> CreateAccountAsync(Guid userId, CreateMoneyAccountRequest request, CancellationToken cancellationToken);

    Task<MoneyAccountDto> UpdateAccountAsync(Guid userId, Guid accountId, UpdateMoneyAccountRequest request, CancellationToken cancellationToken);
}

public interface ICategoryService
{
    Task<IReadOnlyCollection<CategoryDto>> GetCategoriesAsync(Guid userId, CategoryKind? kind, CancellationToken cancellationToken);

    Task<CategoryDto> CreateCategoryAsync(Guid userId, CreateCategoryRequest request, CancellationToken cancellationToken);

    Task<CategoryDto> UpdateCategoryAsync(Guid userId, Guid categoryId, UpdateCategoryRequest request, CancellationToken cancellationToken);

    Task DeleteCategoryAsync(Guid userId, Guid categoryId, CancellationToken cancellationToken);
}

public interface ITransactionService
{
    Task<PagedResult<TransactionDto>> GetTransactionsAsync(Guid userId, TransactionListFilter filter, CancellationToken cancellationToken);

    Task<TransactionDto> CreateTransactionAsync(Guid userId, CreateTransactionRequest request, CancellationToken cancellationToken);

    Task<TransactionDto> UpdateTransactionAsync(Guid userId, Guid transactionId, UpdateTransactionRequest request, CancellationToken cancellationToken);

    Task<IReadOnlyCollection<TransactionDto>> CreateTransferAsync(Guid userId, CreateTransferRequest request, CancellationToken cancellationToken);

    Task DeleteTransactionAsync(Guid userId, Guid transactionId, CancellationToken cancellationToken);
}

public interface IDashboardService
{
    Task<DashboardSummaryDto> GetSummaryAsync(Guid userId, DashboardSummaryRequest request, CancellationToken cancellationToken);
}
