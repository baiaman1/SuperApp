using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SuperAppBackend.Application.DTOs.Categories;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Enums;
using SuperAppBackend.WebApi.Extensions;

namespace SuperAppBackend.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("api/categories")]
public sealed class CategoriesController(ICategoryService categoryService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyCollection<CategoryDto>>> Get([FromQuery] CategoryKind? kind, CancellationToken cancellationToken)
    {
        var response = await categoryService.GetCategoriesAsync(User.GetRequiredUserId(), kind, cancellationToken);
        return Ok(response);
    }

    [HttpPost]
    public async Task<ActionResult<CategoryDto>> Create([FromBody] CreateCategoryRequest request, CancellationToken cancellationToken)
    {
        var response = await categoryService.CreateCategoryAsync(User.GetRequiredUserId(), request, cancellationToken);
        return CreatedAtAction(nameof(Get), new { id = response.Id }, response);
    }

    [HttpPut("{categoryId:guid}")]
    public async Task<ActionResult<CategoryDto>> Update(Guid categoryId, [FromBody] UpdateCategoryRequest request, CancellationToken cancellationToken)
    {
        var response = await categoryService.UpdateCategoryAsync(User.GetRequiredUserId(), categoryId, request, cancellationToken);
        return Ok(response);
    }

    [HttpDelete("{categoryId:guid}")]
    public async Task<IActionResult> Delete(Guid categoryId, CancellationToken cancellationToken)
    {
        await categoryService.DeleteCategoryAsync(User.GetRequiredUserId(), categoryId, cancellationToken);
        return NoContent();
    }
}
