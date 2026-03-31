using SuperAppBackend.Domain.Enums;

namespace SuperAppBackend.Application.DTOs.Categories;

public sealed record CategoryDto(
    Guid Id,
    string Name,
    CategoryKind Kind,
    string? Icon,
    string? Color,
    bool IsSystem,
    bool IsArchived,
    int DisplayOrder);

public sealed record CreateCategoryRequest(
    string Name,
    CategoryKind Kind,
    string? Icon,
    string? Color,
    int? DisplayOrder);

public sealed record UpdateCategoryRequest(
    string Name,
    string? Icon,
    string? Color,
    bool IsArchived,
    int? DisplayOrder);
