# PowerShell script to copy OpenClaw configuration to system directory
# Run this script to install the configuration

$ErrorActionPreference = "Stop"

# Define paths
$sourceConfig = Join-Path $PSScriptRoot "openclaw-config.json"
$openclawDir = Join-Path $env:USERPROFILE ".openclaw"
$targetConfig = Join-Path $openclawDir "openclaw.json"

Write-Host "OpenClaw Configuration Installer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if source file exists
if (-not (Test-Path $sourceConfig)) {
    Write-Host "ERROR: Source configuration file not found: $sourceConfig" -ForegroundColor Red
    exit 1
}

Write-Host "Source: $sourceConfig" -ForegroundColor Yellow
Write-Host "Target: $targetConfig" -ForegroundColor Yellow
Write-Host ""

# Create .openclaw directory if it doesn't exist
if (-not (Test-Path $openclawDir)) {
    Write-Host "Creating OpenClaw directory: $openclawDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $openclawDir -Force | Out-Null
}

# Backup existing config if it exists
if (Test-Path $targetConfig) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupConfig = Join-Path $openclawDir "openclaw.json.backup.$timestamp"
    Write-Host "Backing up existing config to: $backupConfig" -ForegroundColor Yellow
    Copy-Item $targetConfig $backupConfig -Force
}

# Copy the configuration file
Write-Host "Copying configuration file..." -ForegroundColor Green
Copy-Item $sourceConfig $targetConfig -Force

# Verify the copy
if (Test-Path $targetConfig) {
    Write-Host ""
    Write-Host "SUCCESS! Configuration installed successfully." -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuration location: $targetConfig" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Set your GitHub token (choose one method):" -ForegroundColor White
    Write-Host "   Option A - Create .env file:" -ForegroundColor Gray
    Write-Host "   `$envFile = Join-Path `$env:USERPROFILE '.openclaw\.env'" -ForegroundColor Gray
    Write-Host "   'COPILOT_GITHUB_TOKEN=your_token_here' | Out-File -FilePath `$envFile -Encoding UTF8" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Option B - Set environment variable:" -ForegroundColor Gray
    Write-Host "   `$env:COPILOT_GITHUB_TOKEN = 'your_token_here'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Start OpenClaw gateway:" -ForegroundColor White
    Write-Host "   openclaw gateway" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "ERROR: Failed to copy configuration file." -ForegroundColor Red
    exit 1
}
