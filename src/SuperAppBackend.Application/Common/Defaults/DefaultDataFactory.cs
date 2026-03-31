using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.Common.Defaults;

public static class DefaultDataFactory
{
    public static IReadOnlyCollection<Category> CreateDefaultCategories(Guid userId)
    {
        return
        [
            new Category { UserId = userId, Name = "Еда", Kind = CategoryKind.Expense, Icon = "restaurant", Color = "#E76F51", IsSystem = true, DisplayOrder = 1 },
            new Category { UserId = userId, Name = "Транспорт", Kind = CategoryKind.Expense, Icon = "directions_car", Color = "#457B9D", IsSystem = true, DisplayOrder = 2 },
            new Category { UserId = userId, Name = "Дом", Kind = CategoryKind.Expense, Icon = "home", Color = "#2A9D8F", IsSystem = true, DisplayOrder = 3 },
            new Category { UserId = userId, Name = "Здоровье", Kind = CategoryKind.Expense, Icon = "favorite", Color = "#E63946", IsSystem = true, DisplayOrder = 4 },
            new Category { UserId = userId, Name = "Развлечения", Kind = CategoryKind.Expense, Icon = "movie", Color = "#6D597A", IsSystem = true, DisplayOrder = 5 },
            new Category { UserId = userId, Name = "Зарплата", Kind = CategoryKind.Income, Icon = "payments", Color = "#2A9D8F", IsSystem = true, DisplayOrder = 6 },
            new Category { UserId = userId, Name = "Фриланс", Kind = CategoryKind.Income, Icon = "work", Color = "#264653", IsSystem = true, DisplayOrder = 7 },
            new Category { UserId = userId, Name = "Подарок", Kind = CategoryKind.Income, Icon = "redeem", Color = "#F4A261", IsSystem = true, DisplayOrder = 8 },
            new Category { UserId = userId, Name = "Кэшбэк", Kind = CategoryKind.Income, Icon = "savings", Color = "#8AB17D", IsSystem = true, DisplayOrder = 9 }
        ];
    }

    public static MoneyAccount CreateDefaultAccount(Guid userId, string currencyCode)
    {
        return new MoneyAccount
        {
            UserId = userId,
            Name = "Основной счет",
            CurrencyCode = currencyCode,
            Kind = AccountKind.Cash,
            Balance = 0m,
            DisplayOrder = 1
        };
    }
}
