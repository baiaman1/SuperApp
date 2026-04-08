using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SuperAppBackend.Application.DTOs.Auth;
using SuperAppBackend.Application.Interfaces.Services;
using SuperAppBackend.WebApi.Extensions;

namespace SuperAppBackend.WebApi.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController(IAuthService authService, IHostEnvironment environment) : ControllerBase
{
    [HttpPost("google")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> SignInWithGoogle([FromBody] GoogleSignInRequest request, CancellationToken cancellationToken)
    {
        var response = await authService.SignInWithGoogleAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Refresh([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        var response = await authService.RefreshAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] PasswordSignInRequest request, CancellationToken cancellationToken)
    {
        var response = await authService.SignInWithPasswordAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpPost("development")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> DevelopmentSignIn([FromBody] DevelopmentSignInRequest request, CancellationToken cancellationToken)
    {
        if (!environment.IsDevelopment())
        {
            return NotFound();
        }

        var response = await authService.SignInDevelopmentAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<UserProfileDto>> Me(CancellationToken cancellationToken)
    {
        var response = await authService.GetProfileAsync(User.GetRequiredUserId(), cancellationToken);
        return Ok(response);
    }
}
