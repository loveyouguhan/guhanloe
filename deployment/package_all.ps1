# Kiro2API Complete Deployment Package Script

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Kiro2API Deployment Packager" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path "go.mod")) {
    Write-Host "[ERROR] Please run from project root!" -ForegroundColor Red
    exit 1
}

$deploymentDir = "deployment"
$imageTar = "$deploymentDir\kiro2api.tar"
$sourceZip = "$deploymentDir\kiro2api-source.zip"

# Step 1: Export Docker image
Write-Host "[1/3] Checking Docker image..." -ForegroundColor Yellow
if (-not (Test-Path $imageTar)) {
    Write-Host "      Exporting Docker image..." -ForegroundColor Gray
    docker save -o $imageTar kiro2api:latest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to export image! Run: docker compose build" -ForegroundColor Red
        exit 1
    }
    $imageSize = (Get-Item $imageTar).Length / 1MB
    Write-Host "      Image exported ($([math]::Round($imageSize, 2)) MB)" -ForegroundColor Green
} else {
    $imageSize = (Get-Item $imageTar).Length / 1MB
    Write-Host "      Image exists ($([math]::Round($imageSize, 2)) MB)" -ForegroundColor Green
}

# Step 2: Package source code
Write-Host "[2/3] Packaging source code..." -ForegroundColor Yellow
if (Test-Path $sourceZip) { Remove-Item $sourceZip -Force }
& "$deploymentDir\package_source.ps1"
if (-not (Test-Path $sourceZip)) {
    Write-Host "[ERROR] Source packaging failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Create final package
Write-Host "[3/3] Creating deployment package..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$finalZip = "kiro2api-deploy-$timestamp.zip"
$tempFinal = "$deploymentDir\temp_final"

if (Test-Path $tempFinal) { Remove-Item $tempFinal -Recurse -Force }
New-Item -ItemType Directory -Path $tempFinal -Force | Out-Null

# Copy deployment files
Copy-Item "$deploymentDir\docker-compose.yml" -Destination $tempFinal
Copy-Item "$deploymentDir\.env.example" -Destination $tempFinal
Copy-Item "$deploymentDir\README.md" -Destination $tempFinal
Copy-Item "$deploymentDir\deploy.ps1" -Destination $tempFinal
Copy-Item "$deploymentDir\deploy.sh" -Destination $tempFinal
Copy-Item $imageTar -Destination $tempFinal
Copy-Item $sourceZip -Destination $tempFinal

# Compress
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempFinal, $finalZip)

$finalSize = (Get-Item $finalZip).Length / 1MB
Remove-Item $tempFinal -Recurse -Force

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "  Deployment Package Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output: $finalZip" -ForegroundColor Cyan
Write-Host "Size: $([math]::Round($finalSize, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package Contents:" -ForegroundColor Yellow
Write-Host "  [OK] Docker image (kiro2api.tar)" -ForegroundColor Green
Write-Host "  [OK] Source code (kiro2api-source.zip)" -ForegroundColor Green
Write-Host "  [OK] Deployment scripts (deploy.ps1/sh)" -ForegroundColor Green
Write-Host "  [OK] Docker Compose config" -ForegroundColor Green
Write-Host "  [OK] Environment example (.env.example)" -ForegroundColor Green
Write-Host "  [OK] Documentation (README.md)" -ForegroundColor Green
Write-Host ""
Write-Host "Security: All sensitive data excluded" -ForegroundColor Green
Write-Host ""
