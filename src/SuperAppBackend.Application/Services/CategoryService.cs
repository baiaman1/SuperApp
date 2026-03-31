using SuperAppBackend.Application.Common.Exceptions;
using SuperAppBackend.Application.DTOs.Categories;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Entities;
using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.Services;

public sealed class CategoryService(
    ICategoryRepository categoryRepository,
    IUnitOfWork unitOfWork) : ICategoryService
{
    public async Task<IReadOnlyCollection<CategoryDto>> GetCategoriesAsync(Guid userId, CategoryKind? kind, CancellationToken cancellationToken)
    {
        var categories = await categoryRepository.ListByUserAsync(userId, kind, cancellationToken);
        return categories.Select(Map).ToArray();
    }

    public async Task<CategoryDto> CreateCategoryAsync(Guid userId, CreateCategoryRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
            throw new ValidationException("Название категории обязательно.");
        }

        var category = new Category
        {
            UserId = userId,
            Name = request.Name.Trim(),
            Kind = request.Kind,
            Icon = request.Icon?.Trim(),
            Color = request.Color?.Trim(),
            DisplayOrder = request.DisplayOrder ?? 0
        };

        await categoryRepository.AddAsync(category, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Map(category);
    }

    public async Task<CategoryDto> UpdateCategoryAsync(Guid userId, Guid categoryId, UpdateCategoryRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
            throw new ValidationException("Название категории обязательно.");
        }

        var category = await categoryRepository.GetByIdAsync(userId, categoryId, cancellationToken)
            ?? throw new NotFoundException("Категория не найдена.");

        category.Name = request.Name.Trim();
        category.Icon = request.Icon?.Trim();
        category.Color = request.Color?.Trim();
        category.IsArchived = request.IsArchived;
        category.DisplayOrder = request.DisplayOrder ?? category.DisplayOrder;
        category.UpdatedAtUtc = DateTimeOffset.UtcNow;

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return Map(category);
    }

    private static CategoryDto Map(Category category)
    {
        return new CategoryDto(
            category.Id,
            category.Name,
            category.Kind,
            category.Icon,
            category.Color,
            category.IsSystem,
            category.IsArchived,
            category.DisplayOrder);
    }
}
