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
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "SuperApp API",
        Version = "v1"
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Вставь JWT токен. Пример: Bearer eyJhbGciOiJIUzI1NiIs..."
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

var app = builder.Build();

var databaseOptions = app.Configuration
    .GetSection(DatabaseStartupOptions.SectionName)
    .Get<DatabaseStartupOptions>() ?? new DatabaseStartupOptions();

if (databaseOptions.AutoApplyOnStartup)
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await dbContext.Database.EnsureCreatedAsync();

    var schemaBootstrapper = scope.ServiceProvider.GetRequiredService<DatabaseSchemaBootstrapper>();
    await schemaBootstrapper.EnsureCompatibilityAsync();

    var appDataSeeder = scope.ServiceProvider.GetRequiredService<AppDataSeeder>();
    await appDataSeeder.SeedAsync();
}

app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseCors("ProdCors");

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.RoutePrefix = "swagger";
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "API");
});

// app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
app.Run($"http://0.0.0.0:{port}");
