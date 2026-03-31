param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug"
)

$ErrorActionPreference = "Stop"

$projects = @(
    "src/SuperAppBackend.Domain/SuperAppBackend.Domain.csproj",
    "src/SuperAppBackend.Application/SuperAppBackend.Application.csproj",
    "src/SuperAppBackend.Infrastructure/SuperAppBackend.Infrastructure.csproj",
    "src/SuperAppBackend.WebApi/SuperAppBackend.WebApi.csproj"
)

foreach ($project in $projects) {
    dotnet build $project -c $Configuration
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed for $project"
    }
}

Write-Host "Build succeeded for all projects." -ForegroundColor Green
