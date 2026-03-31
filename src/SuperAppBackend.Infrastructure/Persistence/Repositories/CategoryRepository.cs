using Microsoft.EntityFrameworkCore;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Infrastructure.Persistence.Repositories;

public sealed class CategoryRepository(AppDbContext dbContext) : ICategoryRepository
{
    public async Task<IReadOnlyCollection<Category>> ListByUserAsync(Guid userId, CategoryKind? kind, CancellationToken cancellationToken)
    {
        var query = dbContext.Categories
            .AsNoTracking()
            .Where(x => x.UserId == userId);

        if (kind.HasValue)
        {
            query = query.Where(x => x.Kind == kind.Value);
        }

        return await query
            .OrderBy(x => x.DisplayOrder)
            .ThenBy(x => x.Name)
            .ToArrayAsync(cancellationToken);
    }

    public Task<Category?> GetByIdAsync(Guid userId, Guid categoryId, CancellationToken cancellationToken)
    {
        return dbContext.Categories
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Id == categoryId, cancellationToken);
    }

    public Task AddAsync(Category category, CancellationToken cancellationToken)
    {
        return dbContext.Categories.AddAsync(category, cancellationToken).AsTask();
    }
}
