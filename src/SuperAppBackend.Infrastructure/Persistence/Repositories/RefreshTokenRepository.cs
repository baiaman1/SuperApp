using Microsoft.EntityFrameworkCore;
using SuperAppBackend.Application.Interfaces.Persistence;
using SuperAppBackend.Domain.Entities;

namespace SuperAppBackend.Infrastructure.Persistence.Repositories;

public sealed class RefreshTokenRepository(AppDbContext dbContext) : IRefreshTokenRepository
{
    public Task AddAsync(RefreshToken refreshToken, CancellationToken cancellationToken)
    {
        return dbContext.RefreshTokens.AddAsync(refreshToken, cancellationToken).AsTask();
    }

    public Task<RefreshToken?> GetByTokenHashAsync(string tokenHash, CancellationToken cancellationToken)
    {
        return dbContext.RefreshTokens
            .Include(x => x.User)
            .FirstOrDefaultAsync(x => x.TokenHash == tokenHash, cancellationToken);
    }
}
