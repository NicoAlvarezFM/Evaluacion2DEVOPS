Write-Host "🚀 Building Docker image..." -ForegroundColor Cyan
docker build -t bdget-microservicio:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful" -ForegroundColor Green
    Write-Host ""
    docker images bdget-microservicio:latest
    Write-Host ""
    Write-Host "Run: docker run -p 8080:8080 --env-file .env bdget-microservicio:latest" -ForegroundColor White
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}
