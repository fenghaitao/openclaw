# Start OpenClaw Gateway for Microsoft Teams
# This script helps you start the gateway and set up ngrok

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   OpenClaw Gateway - Microsoft Teams Setup            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if configuration exists
$configFile = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"
if (-not (Test-Path $configFile)) {
    Write-Host "✗ Configuration file not found" -ForegroundColor Red
    Write-Host "  Expected: $configFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Please run setup-msteams.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Verify MS Teams configuration
$config = Get-Content $configFile -Raw | ConvertFrom-Json
if (-not $config.channels.msteams) {
    Write-Host "✗ MS Teams not configured" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run setup-msteams.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ MS Teams configuration found" -ForegroundColor Green
Write-Host "  App ID: $($config.channels.msteams.appId)" -ForegroundColor Gray
Write-Host "  Webhook Port: $($config.channels.msteams.webhook.port)" -ForegroundColor Gray
Write-Host ""

# Check if ngrok is available
Write-Host "Checking for ngrok..." -ForegroundColor Yellow
$ngrokPath = Get-Command ngrok -ErrorAction SilentlyContinue

if ($ngrokPath) {
    Write-Host "✓ ngrok found" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Would you like to start ngrok tunnel? Enter Y or N:" -ForegroundColor Cyan
    $startNgrok = Read-Host
    
    if ($startNgrok -eq "Y" -or $startNgrok -eq "y") {
        Write-Host ""
        Write-Host "Starting ngrok on port 3978..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Gray
        Write-Host "IMPORTANT: Copy the HTTPS URL from ngrok output below" -ForegroundColor Yellow
        Write-Host "Example: https://abc123.ngrok.io" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Then set it in Azure Portal:" -ForegroundColor Yellow
        Write-Host "  1. Go to: https://portal.azure.com" -ForegroundColor White
        Write-Host "  2. Navigate to: Your Bot → Configuration" -ForegroundColor White
        Write-Host "  3. Set Messaging endpoint to: https://YOUR-URL.ngrok.io/api/messages" -ForegroundColor White
        Write-Host "  4. Click Save" -ForegroundColor White
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Press Ctrl+C to stop ngrok when done" -ForegroundColor Gray
        Write-Host ""
        Start-Sleep -Seconds 3
        
        # Start ngrok in a new window
        Start-Process -FilePath "ngrok" -ArgumentList "http", "3978" -NoNewWindow
        
        Write-Host ""
        Write-Host "ngrok started!" -ForegroundColor Green
        Write-Host ""
    }
} else {
    Write-Host "⚠ ngrok not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install ngrok:" -ForegroundColor Cyan
    Write-Host "  1. Download from: https://ngrok.com/download" -ForegroundColor White
    Write-Host "  2. Or use Chocolatey: choco install ngrok" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternative: Use Tailscale Funnel" -ForegroundColor Cyan
    Write-Host "  tailscale funnel 3978" -ForegroundColor White
    Write-Host ""
}

# Ask if ready to start gateway
Write-Host "Ready to start OpenClaw gateway? Enter Y or N:" -ForegroundColor Cyan
$startGateway = Read-Host

if ($startGateway -eq "Y" -or $startGateway -eq "y") {
    Write-Host ""
    Write-Host "Starting OpenClaw gateway..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "Gateway will listen on port 3978" -ForegroundColor White
    Write-Host "Webhook endpoint: http://localhost:3978/api/messages" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the gateway" -ForegroundColor Gray
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    Start-Sleep -Seconds 2
    
    # Start the gateway
    & openclaw gateway
} else {
    Write-Host ""
    Write-Host "Gateway not started." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To start manually:" -ForegroundColor Cyan
    Write-Host "  openclaw gateway" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host ""
