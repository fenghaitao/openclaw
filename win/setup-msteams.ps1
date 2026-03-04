# Microsoft Teams Setup Helper for OpenClaw
# This script helps you configure MS Teams integration

param(
    [string]$AppId = "",
    [string]$AppPassword = "",
    [string]$TenantId = "",
    [switch]$UseEnvFile = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Microsoft Teams Setup for OpenClaw                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if plugin is installed
Write-Host "[1/6] Checking MS Teams plugin..." -ForegroundColor Yellow
$pluginCheck = & openclaw plugins list 2>&1 | Select-String "msteams"
if ($pluginCheck) {
    Write-Host "✓ MS Teams plugin is installed" -ForegroundColor Green
} else {
    Write-Host "✗ MS Teams plugin not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installing MS Teams plugin..." -ForegroundColor Yellow
    & openclaw plugins install "@openclaw/msteams"
    Write-Host "✓ Plugin installed" -ForegroundColor Green
}
Write-Host ""

# Get credentials if not provided
Write-Host "[2/6] Collecting Azure Bot credentials..." -ForegroundColor Yellow
if ([string]::IsNullOrWhiteSpace($AppId)) {
    Write-Host ""
    Write-Host "You need to create an Azure Bot first:" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://portal.azure.com/#create/Microsoft.AzureBot" -ForegroundColor Gray
    Write-Host "  2. Create a bot (use Single Tenant type)" -ForegroundColor Gray
    Write-Host "  3. Get the App ID, App Password, and Tenant ID" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Enter your Azure Bot App ID:" -ForegroundColor Cyan
    $AppId = Read-Host
}

if ([string]::IsNullOrWhiteSpace($AppPassword)) {
    Write-Host "Enter your Azure Bot App Password (client secret):" -ForegroundColor Cyan
    $AppPassword = Read-Host -AsSecureString
    $AppPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AppPassword)
    )
}

if ([string]::IsNullOrWhiteSpace($TenantId)) {
    Write-Host "Enter your Azure Tenant ID:" -ForegroundColor Cyan
    $TenantId = Read-Host
}

Write-Host "✓ Credentials collected" -ForegroundColor Green
Write-Host ""

# Determine configuration method
Write-Host "[3/6] Choosing configuration method..." -ForegroundColor Yellow
if ($UseEnvFile) {
    Write-Host "  Using .env file" -ForegroundColor Gray
} else {
    Write-Host "  Would you like to use:" -ForegroundColor Cyan
    Write-Host "    1. Config file (openclaw.json)" -ForegroundColor White
    Write-Host "    2. Environment file (.env)" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "  Enter choice (1 or 2)"
    $UseEnvFile = ($choice -eq "2")
}
Write-Host ""

# Configure based on choice
$openclawDir = Join-Path $env:USERPROFILE ".openclaw"
$configFile = Join-Path $openclawDir "openclaw.json"
$envFile = Join-Path $openclawDir ".env"

if ($UseEnvFile) {
    Write-Host "[4/6] Configuring via .env file..." -ForegroundColor Yellow
    
    # Read existing .env if it exists
    $envContent = @()
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile
    }
    
    # Remove existing MS Teams entries
    $envContent = $envContent | Where-Object { 
        $_ -notmatch "^MSTEAMS_APP_ID=" -and 
        $_ -notmatch "^MSTEAMS_APP_PASSWORD=" -and 
        $_ -notmatch "^MSTEAMS_TENANT_ID="
    }
    
    # Add new entries
    $envContent += "MSTEAMS_APP_ID=$AppId"
    $envContent += "MSTEAMS_APP_PASSWORD=$AppPassword"
    $envContent += "MSTEAMS_TENANT_ID=$TenantId"
    
    # Write back
    $envContent | Out-File -FilePath $envFile -Encoding UTF8
    Write-Host "✓ Credentials saved to: $envFile" -ForegroundColor Green
    
} else {
    Write-Host "[4/6] Configuring via openclaw.json..." -ForegroundColor Yellow
    
    if (-not (Test-Path $configFile)) {
        Write-Host "✗ Config file not found: $configFile" -ForegroundColor Red
        Write-Host "  Please run the main configuration installer first" -ForegroundColor Yellow
        exit 1
    }
    
    # Read existing config
    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    
    # Add or update msteams section
    if (-not $config.channels) {
        $config | Add-Member -NotePropertyName "channels" -NotePropertyValue @{} -Force
    }
    
    $msteamsConfig = @{
        enabled = $true
        appId = $AppId
        appPassword = $AppPassword
        tenantId = $TenantId
        webhook = @{
            port = 3978
            path = "/api/messages"
        }
        dmPolicy = "pairing"
        groupPolicy = "allowlist"
        requireMention = $true
        allowFrom = @()
        groupAllowFrom = @()
    }
    
    $config.channels | Add-Member -NotePropertyName "msteams" -NotePropertyValue $msteamsConfig -Force
    
    # Backup existing config
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$configFile.backup.$timestamp"
    Copy-Item $configFile $backupFile -Force
    Write-Host "  Backed up config to: $backupFile" -ForegroundColor Gray
    
    # Write updated config
    $config | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8
    Write-Host "✓ Configuration updated: $configFile" -ForegroundColor Green
}
Write-Host ""

# Provide next steps
Write-Host "[5/6] Next steps..." -ForegroundColor Yellow
Write-Host ""
Write-Host "You still need to:" -ForegroundColor Cyan
Write-Host "  1. Set up messaging endpoint in Azure Bot:" -ForegroundColor White
Write-Host "     - Go to Azure Portal → Your Bot → Configuration" -ForegroundColor Gray
Write-Host "     - Set Messaging endpoint to your public URL + /api/messages" -ForegroundColor Gray
Write-Host "     - Example: https://your-ngrok-url.ngrok.io/api/messages" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Create Teams app manifest (see MSTEAMS-SETUP.md)" -ForegroundColor White
Write-Host ""
Write-Host "  3. Install the Teams app in Microsoft Teams" -ForegroundColor White
Write-Host ""
Write-Host "  4. Start OpenClaw gateway:" -ForegroundColor White
Write-Host "     openclaw gateway" -ForegroundColor Gray
Write-Host ""

# Offer to start ngrok
Write-Host "[6/6] Webhook endpoint setup..." -ForegroundColor Yellow
Write-Host ""
Write-Host "For local testing, you need a public URL. Options:" -ForegroundColor Cyan
Write-Host "  1. ngrok (recommended for testing)" -ForegroundColor White
Write-Host "  2. Tailscale Funnel" -ForegroundColor White
Write-Host "  3. Your own domain (production)" -ForegroundColor White
Write-Host ""
Write-Host "Would you like help setting up ngrok? (Y/N)" -ForegroundColor Cyan
$ngrokChoice = Read-Host

if ($ngrokChoice -eq "Y" -or $ngrokChoice -eq "y") {
    Write-Host ""
    Write-Host "Checking for ngrok..." -ForegroundColor Yellow
    $ngrokPath = Get-Command ngrok -ErrorAction SilentlyContinue
    
    if ($ngrokPath) {
        Write-Host "✓ ngrok found" -ForegroundColor Green
        Write-Host ""
        Write-Host "Starting ngrok tunnel on port 3978..." -ForegroundColor Yellow
        Write-Host "Copy the HTTPS URL and set it as your messaging endpoint in Azure" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Press Ctrl+C to stop ngrok when done" -ForegroundColor Gray
        Write-Host ""
        Start-Sleep -Seconds 2
        & ngrok http 3978
    } else {
        Write-Host "✗ ngrok not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "Download ngrok from: https://ngrok.com/download" -ForegroundColor Cyan
        Write-Host "After installing, run: ngrok http 3978" -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "Manual setup:" -ForegroundColor Cyan
    Write-Host "  ngrok: ngrok http 3978" -ForegroundColor Gray
    Write-Host "  Tailscale: tailscale funnel 3978" -ForegroundColor Gray
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         MS Teams Configuration Complete! ✓            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "For detailed setup instructions, see:" -ForegroundColor Cyan
Write-Host "  win\MSTEAMS-SETUP.md" -ForegroundColor White
Write-Host ""
Write-Host "To test:" -ForegroundColor Cyan
Write-Host "  1. Start gateway: openclaw gateway" -ForegroundColor White
Write-Host "  2. Test in Azure Web Chat first" -ForegroundColor White
Write-Host "  3. Then test in Microsoft Teams" -ForegroundColor White
Write-Host ""
