using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SuperAppBackend.Application.DTOs.Accounts;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.WebApi.Extensions;

namespace SuperAppBackend.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("api/accounts")]
public sealed class AccountsController(IAccountService accountService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyCollection<MoneyAccountDto>>> Get(CancellationToken cancellationToken)
    {
        var response = await accountService.GetAccountsAsync(User.GetRequiredUserId(), cancellationToken);
        return Ok(response);
    }

    [HttpPost]
    public async Task<ActionResult<MoneyAccountDto>> Create([FromBody] CreateMoneyAccountRequest request, CancellationToken cancellationToken)
    {
        var response = await accountService.CreateAccountAsync(User.GetRequiredUserId(), request, cancellationToken);
        return CreatedAtAction(nameof(Get), new { id = response.Id }, response);
    }

    [HttpPut("{accountId:guid}")]
    public async Task<ActionResult<MoneyAccountDto>> Update(Guid accountId, [FromBody] UpdateMoneyAccountRequest request, CancellationToken cancellationToken)
    {
        var response = await accountService.UpdateAccountAsync(User.GetRequiredUserId(), accountId, request, cancellationToken);
        return Ok(response);
    }
}
