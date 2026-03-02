# OpenClaw + Feishu + Kimi K2.5 Setup Script for Windows
# This script will set up and run OpenClaw with your configuration

$ErrorActionPreference = "Stop"

Write-Host "🦞 OpenClaw Setup for Feishu + Kimi K2.5 (Windows)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Warning: Not running as Administrator. Some operations may fail." -ForegroundColor Yellow
    Write-Host "   Consider running PowerShell as Administrator for best results." -ForegroundColor Yellow
    Write-Host ""
}

# Check if Node.js is installed
try {
    $nodeVersion = node -v
    $nodeMajorVersion = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    
    if ($nodeMajorVersion -lt 22) {
        Write-Host "❌ Node.js version 22 or higher is required. Current version: $nodeVersion" -ForegroundColor Red
        Write-Host "   Download from: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✅ Node.js $nodeVersion detected" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js 22+ first." -ForegroundColor Red
    Write-Host "   Visit: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if npm is installed
try {
    $npmVersion = npm -v
    Write-Host "✅ npm $npmVersion detected" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ npm is not installed." -ForegroundColor Red
    exit 1
}

Write-Host "📦 Step 1: Checking OpenClaw installation..." -ForegroundColor Cyan

# Check if openclaw is installed
try {
    $openclawCmd = Get-Command openclaw -ErrorAction SilentlyContinue
    if ($openclawCmd) {
        $openclawVersion = openclaw --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ OpenClaw is already installed: $openclawVersion" -ForegroundColor Green
        } else {
            Write-Host "✅ OpenClaw is already installed" -ForegroundColor Green
        }
    } else {
        throw "Not installed"
    }
} catch {
    Write-Host "⚠️  OpenClaw not found. Installing..." -ForegroundColor Yellow
    npm install -g openclaw@latest
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Installation failed. Please run: npm install -g openclaw@latest" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ OpenClaw installed successfully" -ForegroundColor Green
}

Write-Host ""
Write-Host "📦 Step 2: Installing Feishu plugin..." -ForegroundColor Cyan

# Check if feishu plugin is already installed
try {
    $feishuCheck = npm list -g @openclaw/feishu 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Feishu plugin is already installed" -ForegroundColor Green
    } else {
        throw "Not installed"
    }
} catch {
    Write-Host "⚠️  Feishu plugin not found. Installing..." -ForegroundColor Yellow
    npm install -g @openclaw/feishu@latest
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Installation failed. Please run: npm install -g @openclaw/feishu@latest" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Feishu plugin installed successfully" -ForegroundColor Green
}

Write-Host ""
Write-Host "📁 Step 3: Setting up configuration..." -ForegroundColor Cyan

# Create OpenClaw directory if it doesn't exist
$openclawDir = "$env:USERPROFILE\.openclaw"
if (-not (Test-Path $openclawDir)) {
    New-Item -ItemType Directory -Path $openclawDir -Force | Out-Null
}

# Check if config file exists in current directory
if (-not (Test-Path "openclaw-config.json")) {
    Write-Host "❌ openclaw-config.json not found in current directory!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create it from the example:" -ForegroundColor Yellow
    Write-Host "  Copy-Item openclaw-config.example.json openclaw-config.json" -ForegroundColor Yellow
    Write-Host "  # Then edit with your credentials" -ForegroundColor Yellow
    exit 1
}

# Copy the config file
Copy-Item openclaw-config.json "$openclawDir\openclaw.json" -Force

Write-Host "✅ Configuration file created at $openclawDir\openclaw.json" -ForegroundColor Green
Write-Host ""

Write-Host "🔧 Step 4: Creating workspace..." -ForegroundColor Cyan
$workspaceDir = "$openclawDir\workspace"
if (-not (Test-Path $workspaceDir)) {
    New-Item -ItemType Directory -Path $workspaceDir -Force | Out-Null
}

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Configure Feishu Bot Permissions:" -ForegroundColor White
Write-Host "   - Go to: https://open.feishu.cn/app" -ForegroundColor Gray
Write-Host "   - Open your app and enable required permissions" -ForegroundColor Gray
Write-Host "   - See START_HERE.md for details" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Expose webhook (choose one):" -ForegroundColor White
Write-Host ""
Write-Host "   Option A - Using ngrok (quick testing):" -ForegroundColor Gray
Write-Host "     ngrok http 18790" -ForegroundColor Gray
Write-Host ""
Write-Host "   Option B - Using Tailscale (recommended):" -ForegroundColor Gray
Write-Host "     tailscale funnel 18790" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Start OpenClaw Gateway:" -ForegroundColor White
Write-Host "   Run: .\start-gateway.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Configure Feishu Webhook:" -ForegroundColor White
Write-Host "   - Go to: https://open.feishu.cn/app" -ForegroundColor Gray
Write-Host "   - Event Subscriptions → Request URL" -ForegroundColor Gray
Write-Host "   - Enter: https://YOUR_URL/feishu/events" -ForegroundColor Gray
Write-Host "   - Subscribe to: im.message.receive_v1" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Test your bot:" -ForegroundColor White
Write-Host "   - Send a message to your bot in Feishu" -ForegroundColor Gray
Write-Host "   - Approve pairing: openclaw pairing approve feishu <code>" -ForegroundColor Gray
Write-Host "   - Chat with Kimi K2.5!" -ForegroundColor Gray
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Useful Commands:" -ForegroundColor Cyan
Write-Host "   openclaw status              - Check gateway status" -ForegroundColor Gray
Write-Host "   openclaw channels status     - Check Feishu connection" -ForegroundColor Gray
Write-Host "   openclaw pairing list        - List pending approvals" -ForegroundColor Gray
Write-Host "   openclaw logs --follow       - View live logs" -ForegroundColor Gray
Write-Host "   openclaw doctor              - Diagnose issues" -ForegroundColor Gray
Write-Host ""
Write-Host "🔗 Documentation: https://docs.openclaw.ai" -ForegroundColor Cyan
Write-Host "💬 Discord: https://discord.gg/clawd" -ForegroundColor Cyan
Write-Host ""
