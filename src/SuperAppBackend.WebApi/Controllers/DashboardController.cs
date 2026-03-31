using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SuperAppBackend.Application.DTOs.Dashboard;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.WebApi.Extensions;

namespace SuperAppBackend.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("api/dashboard")]
public sealed class DashboardController(IDashboardService dashboardService) : ControllerBase
{
    [HttpGet("summary")]
    public async Task<ActionResult<DashboardSummaryDto>> Summary(
        [FromQuery] Guid? accountId,
        [FromQuery] DateTimeOffset? dateFromUtc,
        [FromQuery] DateTimeOffset? dateToUtc,
        CancellationToken cancellationToken)
    {
        var request = new DashboardSummaryRequest(accountId, dateFromUtc, dateToUtc);
        var response = await dashboardService.GetSummaryAsync(User.GetRequiredUserId(), request, cancellationToken);
        return Ok(response);
    }
}
