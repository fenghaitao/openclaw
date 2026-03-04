#!/usr/bin/env pwsh
# Create Teams App Package (ZIP)

Write-Host "📦 Creating Teams app package..." -ForegroundColor Cyan

# Check for required files
$manifestPath = "teams-manifest-updated.json"
$outlinePath = "outline.png"
$colorPath = "color.png"

$missing = @()
if (-not (Test-Path $manifestPath)) { $missing += $manifestPath }
if (-not (Test-Path $outlinePath)) { $missing += $outlinePath }
if (-not (Test-Path $colorPath)) { $missing += $colorPath }

if ($missing.Count -gt 0) {
    Write-Host "❌ Missing required files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "📋 Required files:" -ForegroundColor Yellow
    Write-Host "  - teams-manifest-updated.json (run .\update-teams-manifest.ps1 first)"
    Write-Host "  - outline.png (32x32 pixels, transparent background)"
    Write-Host "  - color.png (192x192 pixels)"
    Write-Host ""
    Write-Host "💡 Tip: You can use any PNG images for testing, just rename them" -ForegroundColor Cyan
    exit 1
}

# Rename manifest for packaging
Copy-Item $manifestPath "manifest.json" -Force

# Create the ZIP package
$zipPath = "openclaw-teams-app.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path "manifest.json",$outlinePath,$colorPath -DestinationPath $zipPath -Force

# Clean up temporary manifest
Remove-Item "manifest.json" -Force

Write-Host "✅ Teams app package created: $zipPath" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Package contents:" -ForegroundColor Yellow
Write-Host "  - manifest.json (from $manifestPath)"
Write-Host "  - outline.png"
Write-Host "  - color.png"
Write-Host ""
Write-Host "📱 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Set up tunnel: ngrok http 3978"
Write-Host "  2. Update Azure Bot messaging endpoint with tunnel URL"
Write-Host "  3. Upload $zipPath to Teams:"
Write-Host "     - Open Teams → Apps → Manage your apps"
Write-Host "     - Click 'Upload a custom app'"
Write-Host "     - Select $zipPath"
Write-Host "  4. Test by sending a message to the bot"
