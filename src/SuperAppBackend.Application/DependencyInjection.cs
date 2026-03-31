using Microsoft.Extensions.DependencyInjection;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Application.Services;

namespace SuperAppBackend.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IAccountService, AccountService>();
        services.AddScoped<ICategoryService, CategoryService>();
        services.AddScoped<ITransactionService, TransactionService>();
        services.AddScoped<IDashboardService, DashboardService>();

        return services;
    }
}
