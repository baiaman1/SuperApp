using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SuperAppBackend.Application.Common.Models;
using SuperAppBackend.Application.DTOs.Transactions;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.Domain.Enums;
using SuperAppBackend.WebApi.Extensions;

namespace SuperAppBackend.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("api/transactions")]
public sealed class TransactionsController(ITransactionService transactionService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PagedResult<TransactionDto>>> Get(
        [FromQuery] Guid? accountId,
        [FromQuery] Guid? categoryId,
        [FromQuery] TransactionEntryType? entryType,
        [FromQuery] DateTimeOffset? dateFromUtc,
        [FromQuery] DateTimeOffset? dateToUtc,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken cancellationToken = default)
    {
        var filter = new TransactionListFilter(accountId, categoryId, entryType, dateFromUtc, dateToUtc, pageNumber, pageSize);
        var response = await transactionService.GetTransactionsAsync(User.GetRequiredUserId(), filter, cancellationToken);
        return Ok(response);
    }

    [HttpPost]
    public async Task<ActionResult<TransactionDto>> Create([FromBody] CreateTransactionRequest request, CancellationToken cancellationToken)
    {
        var response = await transactionService.CreateTransactionAsync(User.GetRequiredUserId(), request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("transfer")]
    public async Task<ActionResult<IReadOnlyCollection<TransactionDto>>> Transfer([FromBody] CreateTransferRequest request, CancellationToken cancellationToken)
    {
        var response = await transactionService.CreateTransferAsync(User.GetRequiredUserId(), request, cancellationToken);
        return Ok(response);
    }

    [HttpDelete("{transactionId:guid}")]
    public async Task<IActionResult> Delete(Guid transactionId, CancellationToken cancellationToken)
    {
        await transactionService.DeleteTransactionAsync(User.GetRequiredUserId(), transactionId, cancellationToken);
        return NoContent();
    }
}
