using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using SuperAppBackend.Application;
using SuperAppBackend.Infrastructure;
using SuperAppBackend.Infrastructure.Persistence;
using SuperAppBackend.Infrastructure.Persistence.Seeding;
using SuperAppBackend.WebApi.Middleware;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddCors(options =>
{
    options.AddPolicy("ProdCors", policy =>
    {
        policy
            .WithOrigins(
                "http://13.220.53.240",
                "http://localhost:3000"
            )
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddSwaggerGen();
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

var app = builder.Build();

// 🔥 DB init (оставляем)
var databaseOptions = app.Configuration
    .GetSection(DatabaseStartupOptions.SectionName)
    .Get<DatabaseStartupOptions>() ?? new DatabaseStartupOptions();

if (databaseOptions.AutoApplyOnStartup)
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await dbContext.Database.EnsureCreatedAsync();
}

// 🔥 MIDDLEWARE (ПРАВИЛЬНЫЙ ПОРЯДОК)
app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseCors("ProdCors");

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.RoutePrefix = "swagger";
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "API");
});

// ❌ УБРАТЬ пока нет HTTPS
// app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// ✅ ТОЛЬКО ОДИН RUN
var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
app.Run($"http://0.0.0.0:{port}");