#!/usr/bin/env pwsh
# Update Teams Manifest with Azure Bot App ID

param(
    [Parameter(Mandatory=$true)]
    [string]$AppId
)

Write-Host "🔧 Updating Teams manifest with App ID: $AppId" -ForegroundColor Cyan

# Validate App ID format (GUID)
if ($AppId -notmatch '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
    Write-Host "❌ Invalid App ID format. Expected GUID format: 12345678-1234-1234-1234-123456789abc" -ForegroundColor Red
    exit 1
}

# Read the manifest
$manifestPath = "teams-manifest.json"
if (-not (Test-Path $manifestPath)) {
    Write-Host "❌ teams-manifest.json not found in current directory" -ForegroundColor Red
    exit 1
}

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

# Update IDs
$manifest.id = $AppId
$manifest.bots[0].botId = $AppId

# Add webApplicationInfo (required for RSC permissions)
$webAppInfo = @{
    id = $AppId
}
$manifest | Add-Member -NotePropertyName "webApplicationInfo" -NotePropertyValue $webAppInfo -Force

# Add RSC permissions for channel/group access
$authorization = @{
    permissions = @{
        resourceSpecific = @(
            @{ name = "ChannelMessage.Read.Group"; type = "Application" },
            @{ name = "ChannelMessage.Send.Group"; type = "Application" },
            @{ name = "Member.Read.Group"; type = "Application" },
            @{ name = "Owner.Read.Group"; type = "Application" },
            @{ name = "ChannelSettings.Read.Group"; type = "Application" },
            @{ name = "TeamMember.Read.Group"; type = "Application" },
            @{ name = "TeamSettings.Read.Group"; type = "Application" },
            @{ name = "ChatMessage.Read.Chat"; type = "Application" }
        )
    }
}
$manifest | Add-Member -NotePropertyName "authorization" -NotePropertyValue $authorization -Force

# Save updated manifest
$outputPath = "teams-manifest-updated.json"
$manifest | ConvertTo-Json -Depth 10 | Set-Content $outputPath

Write-Host "✅ Manifest updated successfully: $outputPath" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Yellow
Write-Host "  - App ID: $AppId"
Write-Host "  - Bot ID: $AppId"
Write-Host "  - RSC Permissions: Added (8 permissions)"
Write-Host "  - Output: $outputPath"
Write-Host ""
Write-Host "📦 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Create icons: outline.png (32x32) and color.png (192x192)"
Write-Host "  2. Run: .\create-teams-package.ps1"
Write-Host "  3. Upload openclaw-teams-app.zip to Teams"
