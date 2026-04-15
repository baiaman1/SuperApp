using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SuperAppBackend.Application.Common.Defaults;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Infrastructure.Persistence.Seeding;

public sealed class AppDataSeeder(
    AppDbContext dbContext,
    IAppPasswordHasher passwordHasher,
    IOptions<SeedDataOptions> options,
    ILogger<AppDataSeeder> logger)
{
    private readonly SeedDataOptions _options = options.Value;

    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        await SeedSuperAdminAsync(cancellationToken);
        await SeedDemoUserAsync(cancellationToken);
    }

    private async Task SeedSuperAdminAsync(CancellationToken cancellationToken)
    {
        var email = _options.SuperAdminEmail.Trim().ToLowerInvariant();
        var user = await dbContext.Users
            .Include(x => x.LocalCredential)
            .Include(x => x.Accounts)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.Email == email, cancellationToken);

        if (user is null)
        {
            user = CreateUser("Super Admin", email, UserRole.SuperAdmin, "KZT");
            user.LocalCredential = CreateCredential(user, _options.SuperAdminPassword);
            user.Accounts.Add(DefaultDataFactory.CreateDefaultAccount(user.Id, user.PreferredCurrency));
            AddDefaultCategories(user);
            SeedAdminTransactions(user);
            await dbContext.Users.AddAsync(user, cancellationToken);
            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Seeded super admin user {Email}.", email);
            return;
        }

        var changed = false;

        if (user.Role != UserRole.SuperAdmin)
        {
            user.Role = UserRole.SuperAdmin;
            changed = true;
        }

        if (user.LocalCredential is null)
        {
            user.LocalCredential = CreateCredential(user, _options.SuperAdminPassword);
            changed = true;
        }
        else if (!passwordHasher.VerifyPassword(user, user.LocalCredential.PasswordHash, _options.SuperAdminPassword))
        {
            user.LocalCredential.PasswordHash = passwordHasher.HashPassword(user, _options.SuperAdminPassword);
            user.LocalCredential.PasswordChangedAtUtc = DateTimeOffset.UtcNow;
            user.LocalCredential.UpdatedAtUtc = DateTimeOffset.UtcNow;
            changed = true;
        }

        if (!user.Accounts.Any())
        {
            user.Accounts.Add(DefaultDataFactory.CreateDefaultAccount(user.Id, user.PreferredCurrency));
            changed = true;
        }

        if (!user.Categories.Any())
        {
            AddDefaultCategories(user);
            changed = true;
        }

        if (changed)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    private async Task SeedDemoUserAsync(CancellationToken cancellationToken)
    {
        var email = _options.DemoUserEmail.Trim().ToLowerInvariant();
        var user = await dbContext.Users
            .Include(x => x.LocalCredential)
            .Include(x => x.Accounts)
            .Include(x => x.Categories)
            .FirstOrDefaultAsync(x => x.Email == email, cancellationToken);

        if (user is not null)
        {
            var changed = false;

            if (user.LocalCredential is null)
            {
                user.LocalCredential = CreateCredential(user, _options.DemoUserPassword);
                changed = true;
            }
            else if (!passwordHasher.VerifyPassword(user, user.LocalCredential.PasswordHash, _options.DemoUserPassword))
            {
                user.LocalCredential.PasswordHash = passwordHasher.HashPassword(user, _options.DemoUserPassword);
                user.LocalCredential.PasswordChangedAtUtc = DateTimeOffset.UtcNow;
                user.LocalCredential.UpdatedAtUtc = DateTimeOffset.UtcNow;
                changed = true;
            }

            if (!user.Accounts.Any())
            {
                user.Accounts.Add(DefaultDataFactory.CreateDefaultAccount(user.Id, user.PreferredCurrency));
                changed = true;
            }

            if (!user.Categories.Any())
            {
                AddDefaultCategories(user);
                changed = true;
            }

            if (changed)
            {
                await dbContext.SaveChangesAsync(cancellationToken);
                logger.LogInformation("Ensured demo user {Email} local credentials and defaults.", email);
            }

            return;
        }

        user = CreateUser("Demo User", email, UserRole.User, "KZT");
        user.LocalCredential = CreateCredential(user, _options.DemoUserPassword);

        var categories = DefaultDataFactory.CreateDefaultCategories(user.Id).ToList();
        foreach (var category in categories)
        {
            user.Categories.Add(category);
        }

        var cash = new MoneyAccount
        {
            UserId = user.Id,
            Name = "Наличные",
            CurrencyCode = "KZT",
            Kind = AccountKind.Cash,
            Balance = 0m,
            DisplayOrder = 1
        };

        var card = new MoneyAccount
        {
            UserId = user.Id,
            Name = "Kaspi Gold",
            CurrencyCode = "KZT",
            Kind = AccountKind.BankCard,
            Balance = 0m,
            DisplayOrder = 2
        };

        var savings = new MoneyAccount
        {
            UserId = user.Id,
            Name = "Накопления",
            CurrencyCode = "KZT",
            Kind = AccountKind.Savings,
            Balance = 0m,
            DisplayOrder = 3
        };

        user.Accounts.Add(cash);
        user.Accounts.Add(card);
        user.Accounts.Add(savings);

        var salary = categories.Single(x => x.Name == "Зарплата");
        var freelance = categories.Single(x => x.Name == "Фриланс");
        var cashback = categories.Single(x => x.Name == "Кэшбэк");
        var food = categories.Single(x => x.Name == "Еда");
        var transport = categories.Single(x => x.Name == "Транспорт");
        var home = categories.Single(x => x.Name == "Дом");
        var entertainment = categories.Single(x => x.Name == "Развлечения");

        var now = DateTimeOffset.UtcNow;

        AddTransaction(user, card, salary, TransactionEntryType.Income, 450000m, now.AddDays(-27), "Мартовская зарплата");
        AddTransfer(user, card, cash, 50000m, now.AddDays(-26), "Снятие наличных");
        AddTransaction(user, cash, food, TransactionEntryType.Expense, 18200m, now.AddDays(-25), "Продукты на неделю");
        AddTransaction(user, card, transport, TransactionEntryType.Expense, 4200m, now.AddDays(-24), "Такси");
        AddTransaction(user, cash, entertainment, TransactionEntryType.Expense, 12500m, now.AddDays(-22), "Кино и кофе");
        AddTransaction(user, card, home, TransactionEntryType.Expense, 68000m, now.AddDays(-19), "Аренда и коммуналка");
        AddTransaction(user, card, cashback, TransactionEntryType.Income, 3700m, now.AddDays(-18), "Кэшбэк по карте");
        AddTransfer(user, card, savings, 100000m, now.AddDays(-16), "Отложить на подушку");
        AddTransaction(user, card, freelance, TransactionEntryType.Income, 120000m, now.AddDays(-11), "Сайт для клиента");
        AddTransaction(user, cash, food, TransactionEntryType.Expense, 9600m, now.AddDays(-9), "Обед и groceries");
        AddTransaction(user, cash, entertainment, TransactionEntryType.Expense, 8000m, now.AddDays(-5), "Подарок другу");

        await dbContext.Users.AddAsync(user, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Seeded demo user {Email} with mock finance data.", email);
    }

    private static User CreateUser(string fullName, string email, UserRole role, string currencyCode)
    {
        return new User
        {
            Email = email,
            FullName = fullName,
            PreferredCurrency = currencyCode,
            Role = role,
            IsActive = true
        };
    }

    private LocalCredential CreateCredential(User user, string password)
    {
        return new LocalCredential
        {
            UserId = user.Id,
            PasswordHash = passwordHasher.HashPassword(user, password),
            PasswordChangedAtUtc = DateTimeOffset.UtcNow
        };
    }

    private static void AddDefaultCategories(User user)
    {
        foreach (var category in DefaultDataFactory.CreateDefaultCategories(user.Id))
        {
            user.Categories.Add(category);
        }
    }

    private static void SeedAdminTransactions(User user)
    {
        var account = user.Accounts.First();
        var categories = user.Categories.ToList();
        var salary = categories.Single(x => x.Name == "Зарплата");
        var food = categories.Single(x => x.Name == "Еда");
        var now = DateTimeOffset.UtcNow;

        AddTransaction(user, account, salary, TransactionEntryType.Income, 999999m, now.AddDays(-3), "Системный тестовый доход");
        AddTransaction(user, account, food, TransactionEntryType.Expense, 12000m, now.AddDays(-2), "Проверка расходов администратора");
    }

    private static void AddTransaction(
        User user,
        MoneyAccount account,
        Category category,
        TransactionEntryType entryType,
        decimal amount,
        DateTimeOffset occurredAtUtc,
        string note)
    {
        var transaction = new MoneyTransaction
        {
            UserId = user.Id,
            AccountId = account.Id,
            CategoryId = category.Id,
            EntryType = entryType,
            Amount = amount,
            Note = note,
            OccurredAtUtc = occurredAtUtc,
            Account = account,
            Category = category,
            User = user
        };

        account.Balance += entryType == TransactionEntryType.Income ? amount : -amount;
        user.Transactions.Add(transaction);
    }

    private static void AddTransfer(
        User user,
        MoneyAccount fromAccount,
        MoneyAccount toAccount,
        decimal amount,
        DateTimeOffset occurredAtUtc,
        string note)
    {
        var transferGroupId = Guid.NewGuid();

        var outgoing = new MoneyTransaction
        {
            UserId = user.Id,
            AccountId = fromAccount.Id,
            EntryType = TransactionEntryType.TransferOut,
            Amount = amount,
            Note = note,
            OccurredAtUtc = occurredAtUtc,
            TransferGroupId = transferGroupId,
            CounterpartyAccountId = toAccount.Id,
            Account = fromAccount,
            User = user
        };

        var incoming = new MoneyTransaction
        {
            UserId = user.Id,
            AccountId = toAccount.Id,
            EntryType = TransactionEntryType.TransferIn,
            Amount = amount,
            Note = note,
            OccurredAtUtc = occurredAtUtc,
            TransferGroupId = transferGroupId,
            CounterpartyAccountId = fromAccount.Id,
            Account = toAccount,
            User = user
        };

        fromAccount.Balance -= amount;
        toAccount.Balance += amount;
        user.Transactions.Add(outgoing);
        user.Transactions.Add(incoming);
    }
}
