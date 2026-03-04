#!/usr/bin/env pwsh
# Add MS Teams configuration to OpenClaw config

param(
    [Parameter(Mandatory=$true)]
    [string]$AppId,
    
    [Parameter(Mandatory=$true)]
    [string]$AppPassword,
    
    [Parameter(Mandatory=$true)]
    [string]$TenantId
)

Write-Host "🔧 Adding MS Teams configuration to OpenClaw config..." -ForegroundColor Cyan

$configPath = "openclaw-config.json"
if (-not (Test-Path $configPath)) {
    Write-Host "❌ openclaw-config.json not found" -ForegroundColor Red
    exit 1
}

# Read current config
$config = Get-Content $configPath -Raw | ConvertFrom-Json

# Add MS Teams configuration
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

# Add msteams to channels
$config.channels | Add-Member -NotePropertyName "msteams" -NotePropertyValue $msteamsConfig -Force

# Add plugins configuration if not exists
if (-not $config.PSObject.Properties['plugins']) {
    $pluginsConfig = @{
        allow = @("msteams")
    }
    $config | Add-Member -NotePropertyName "plugins" -NotePropertyValue $pluginsConfig -Force
} elseif (-not $config.plugins.PSObject.Properties['allow']) {
    $config.plugins | Add-Member -NotePropertyName "allow" -NotePropertyValue @("msteams") -Force
} elseif ($config.plugins.allow -notcontains "msteams") {
    $config.plugins.allow += "msteams"
}

# Save updated config
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath

Write-Host "✅ MS Teams configuration added successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Configuration:" -ForegroundColor Yellow
Write-Host "  - App ID: $AppId"
Write-Host "  - Tenant ID: $TenantId"
Write-Host "  - Webhook: http://localhost:3978/api/messages"
Write-Host "  - DM Policy: pairing (requires approval)"
Write-Host "  - Group Policy: allowlist (requires allowFrom)"
Write-Host ""
Write-Host "⚠️  Note: You need to copy this config to the actual OpenClaw config location:" -ForegroundColor Yellow
Write-Host "   C:\Users\haita\.openclaw\openclaw.json" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Or merge the 'channels.msteams' section manually" -ForegroundColor Gray
Write-Host ""
Write-Host "🔄 Next: Restart the gateway to apply changes" -ForegroundColor Cyan
