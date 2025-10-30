# Kiro2API Source Code Packaging Script
# Auto-excludes sensitive files

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Kiro2API Source Code Packager" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path "go.mod")) {
    Write-Host "[ERROR] Please run from project root!" -ForegroundColor Red
    exit 1
}

$deploymentDir = "deployment"
$tempDir = "$deploymentDir\temp_source"
$zipFile = "$deploymentDir\kiro2api-source.zip"

Write-Host "[1/4] Creating temp directory..." -ForegroundColor Yellow
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "[2/4] Copying source files..." -ForegroundColor Yellow
Write-Host "      Excluding sensitive files..." -ForegroundColor Gray

$exclude = @(".env", ".env.*", "auth_config.json", "*.log", ".git", ".vscode", ".idea", 
             "deployment\temp_*", "deployment\*.zip", "deployment\*.tar*", "node_modules", 
             "vendor", "bin", "dist", "build", "*.exe")

Get-ChildItem -Recurse | Where-Object {
    $item = $_
    $shouldInclude = $true
    foreach ($pattern in $exclude) {
        if ($item.FullName -like "*$pattern*") {
            $shouldInclude = $false
            break
        }
    }
    $shouldInclude
} | ForEach-Object {
    $dest = $_.FullName.Replace((Get-Location).Path, $tempDir)
    if ($_.PSIsContainer) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    } else {
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $_.FullName -Destination $dest -Force
    }
}

Write-Host "      Source files copied" -ForegroundColor Green

Write-Host "[3/4] Creating example config files..." -ForegroundColor Yellow

$envExample = @"
# kiro2api Configuration Example
KIRO_AUTH_TOKEN=./auth_config.json
KIRO_CLIENT_TOKEN=your-secret-token-here
STEALTH_MODE=true
HEADER_STRATEGY=real_simulation
STEALTH_HTTP2_MODE=auto
PORT=8080
GIN_MODE=release
LOG_LEVEL=info
LOG_FORMAT=json
LOG_CONSOLE=true
MAX_TOOL_DESCRIPTION_LENGTH=10000
"@

[System.IO.File]::WriteAllText("$tempDir\.env.example", $envExample)
Write-Host "      Created .env.example" -ForegroundColor Green

Write-Host "[4/4] Compressing archive..." -ForegroundColor Yellow
if (Test-Path $zipFile) { Remove-Item $zipFile -Force }

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFile)

$zipSize = (Get-Item $zipFile).Length / 1MB
Write-Host "      Archive size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Green

Remove-Item $tempDir -Recurse -Force

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "  Package Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output: $zipFile" -ForegroundColor Cyan
Write-Host "Size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Security Check:" -ForegroundColor Yellow
Write-Host "  [OK] .env excluded" -ForegroundColor Green
Write-Host "  [OK] auth_config.json excluded" -ForegroundColor Green
Write-Host "  [OK] .env.example included" -ForegroundColor Green
Write-Host ""
