#!/usr/bin/env pwsh
# Complete Teams App Setup - Interactive Script

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         OpenClaw MS Teams App Setup Wizard                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get App ID
Write-Host "📋 Step 1: Azure Bot App ID" -ForegroundColor Yellow
Write-Host "   Go to: https://portal.azure.com" -ForegroundColor Gray
Write-Host "   Navigate to: Your Azure Bot → Configuration" -ForegroundColor Gray
Write-Host "   Copy: Microsoft App ID" -ForegroundColor Gray
Write-Host ""

$appId = Read-Host "Enter your Azure Bot App ID"

if ($appId -notmatch '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
    Write-Host "❌ Invalid App ID format. Expected GUID format." -ForegroundColor Red
    exit 1
}

Write-Host "✅ App ID validated: $appId" -ForegroundColor Green
Write-Host ""

# Step 2: Update manifest
Write-Host "📝 Step 2: Updating Teams manifest..." -ForegroundColor Yellow
& .\update-teams-manifest.ps1 -AppId $appId
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to update manifest" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Create icons
Write-Host "🎨 Step 3: Creating placeholder icons..." -ForegroundColor Yellow
if (-not (Test-Path "outline.png") -or -not (Test-Path "color.png")) {
    Write-Host "   Creating simple placeholder icons..." -ForegroundColor Gray
    & .\create-placeholder-icons.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create icons" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Icons already exist, skipping creation" -ForegroundColor Green
}
Write-Host ""

# Step 4: Create package
Write-Host "📦 Step 4: Creating Teams app package..." -ForegroundColor Yellow
& .\create-teams-package.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create package" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 5: Tunnel setup
Write-Host "🌐 Step 5: Set up public URL (tunnel)" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Your bot needs to be accessible from the internet." -ForegroundColor Gray
Write-Host "   Choose one option:" -ForegroundColor Gray
Write-Host ""
Write-Host "   Option A: ngrok (recommended for testing)" -ForegroundColor Cyan
Write-Host "     1. Install: https://ngrok.com/download" -ForegroundColor Gray
Write-Host "     2. Run: ngrok http 3978" -ForegroundColor Gray
Write-Host "     3. Copy the https:// URL" -ForegroundColor Gray
Write-Host ""
Write-Host "   Option B: Tailscale Funnel" -ForegroundColor Cyan
Write-Host "     1. Run: tailscale funnel 3978" -ForegroundColor Gray
Write-Host "     2. Copy the URL" -ForegroundColor Gray
Write-Host ""
Write-Host "   Option C: Production domain" -ForegroundColor Cyan
Write-Host "     Use your actual server URL" -ForegroundColor Gray
Write-Host ""

$tunnelUrl = Read-Host "Enter your public URL (e.g., https://abc123.ngrok.io)"

if ($tunnelUrl -notmatch '^https://') {
    Write-Host "⚠️  Warning: URL should start with https://" -ForegroundColor Yellow
}

$messagingEndpoint = "$tunnelUrl/api/messages"
Write-Host "✅ Messaging endpoint: $messagingEndpoint" -ForegroundColor Green
Write-Host ""

# Step 6: Azure configuration
Write-Host "⚙️  Step 6: Update Azure Bot configuration" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Go to: https://portal.azure.com" -ForegroundColor Gray
Write-Host "   2. Navigate to: Your Azure Bot → Configuration" -ForegroundColor Gray
Write-Host "   3. Set Messaging endpoint to:" -ForegroundColor Gray
Write-Host "      $messagingEndpoint" -ForegroundColor Cyan
Write-Host "   4. Click Apply" -ForegroundColor Gray
Write-Host ""

$ready = Read-Host "Press Enter when you've updated the messaging endpoint"

# Step 7: Install in Teams
Write-Host ""
Write-Host "📱 Step 7: Install app in Microsoft Teams" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Method 1: Teams Developer Portal (Easiest)" -ForegroundColor Cyan
Write-Host "     1. Go to: https://dev.teams.microsoft.com/apps" -ForegroundColor Gray
Write-Host "     2. Click: + New app" -ForegroundColor Gray
Write-Host "     3. Fill in basic info" -ForegroundColor Gray
Write-Host "     4. App features → Bot → Enter bot ID: $appId" -ForegroundColor Gray
Write-Host "     5. Check scopes: Personal, Team, Group Chat" -ForegroundColor Gray
Write-Host "     6. Distribute → Download app package" -ForegroundColor Gray
Write-Host "     7. In Teams: Apps → Manage your apps → Upload" -ForegroundColor Gray
Write-Host ""
Write-Host "   Method 2: Direct Upload" -ForegroundColor Cyan
Write-Host "     1. Open Microsoft Teams" -ForegroundColor Gray
Write-Host "     2. Click: Apps (left sidebar)" -ForegroundColor Gray
Write-Host "     3. Click: Manage your apps (bottom left)" -ForegroundColor Gray
Write-Host "     4. Click: Upload a custom app" -ForegroundColor Gray
Write-Host "     5. Select: openclaw-teams-app.zip" -ForegroundColor Gray
Write-Host "     6. Click: Add" -ForegroundColor Gray
Write-Host ""

$installed = Read-Host "Press Enter when you've installed the app in Teams"

# Step 8: Test
Write-Host ""
Write-Host "🧪 Step 8: Test the bot" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. In Teams, find your bot in the Apps section" -ForegroundColor Gray
Write-Host "   2. Click Add or Open" -ForegroundColor Gray
Write-Host "   3. Send a test message: 'Hello'" -ForegroundColor Gray
Write-Host "   4. Check the gateway logs for activity" -ForegroundColor Gray
Write-Host ""
Write-Host "   Gateway log location:" -ForegroundColor Gray
Write-Host "   C:\Users\haita\AppData\Local\Temp\openclaw\openclaw-2026-03-04.log" -ForegroundColor Cyan
Write-Host ""

# Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    Setup Complete! ✅                      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Yellow
Write-Host "   ✅ App ID: $appId" -ForegroundColor Green
Write-Host "   ✅ Manifest updated: teams-manifest-updated.json" -ForegroundColor Green
Write-Host "   ✅ Package created: openclaw-teams-app.zip" -ForegroundColor Green
Write-Host "   ✅ Messaging endpoint: $messagingEndpoint" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Troubleshooting:" -ForegroundColor Yellow
Write-Host "   - If bot doesn't respond, check gateway logs" -ForegroundColor Gray
Write-Host "   - Verify tunnel is still running" -ForegroundColor Gray
Write-Host "   - Test in Azure Bot Web Chat first" -ForegroundColor Gray
Write-Host "   - See: win/complete-teams-setup.md for details" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Documentation: https://docs.openclaw.ai/channels/msteams" -ForegroundColor Cyan
Write-Host ""
