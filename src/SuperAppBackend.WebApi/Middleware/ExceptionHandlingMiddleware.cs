using System.Net;
using SuperAppBackend.Application.Common.Exceptions;

namespace SuperAppBackend.WebApi.Middleware;

public sealed class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception exception)
        {
            logger.LogError(exception, "Unhandled exception while processing request.");
            await WriteProblemDetailsAsync(context, exception);
        }
    }

    private static Task WriteProblemDetailsAsync(HttpContext context, Exception exception)
    {
        var (statusCode, title) = exception switch
        {
            ValidationException => ((int)HttpStatusCode.BadRequest, "Validation error"),
            ForbiddenException => ((int)HttpStatusCode.Forbidden, "Forbidden"),
            NotFoundException => ((int)HttpStatusCode.NotFound, "Not found"),
            _ => ((int)HttpStatusCode.InternalServerError, "Server error")
        };

        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        return context.Response.WriteAsJsonAsync(new
        {
            title,
            status = statusCode,
            detail = exception.Message
        });
    }
}
