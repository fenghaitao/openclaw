#!/bin/bash

# OpenClaw + Feishu + Kimi K2.5 Setup Script
# This script will set up OpenClaw with your configuration

set -e

echo "🦞 OpenClaw Setup for Feishu + Kimi K2.5"
echo "=========================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 22+ first."
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    echo "❌ Node.js version 22 or higher is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js $(node -v) detected"
echo ""

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed."
    exit 1
fi

echo "📦 Step 1: Checking OpenClaw installation..."

# Check if openclaw is installed
if command -v openclaw &> /dev/null; then
    OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    echo "✅ OpenClaw is already installed: $OPENCLAW_VERSION"
else
    echo "⚠️  OpenClaw not found. Installing..."
    npm install -g openclaw@latest
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Installation failed. Please run: npm install -g openclaw@latest"
        exit 1
    fi
    echo "✅ OpenClaw installed successfully"
fi

echo ""
echo "📦 Step 2: Installing Feishu plugin..."

# Check if feishu plugin is installed
if npm list -g @openclaw/feishu &> /dev/null 2>&1; then
    echo "✅ Feishu plugin is already installed"
else
    echo "⚠️  Feishu plugin not found. Installing..."
    npm install -g @openclaw/feishu@latest
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Installation failed. Please run: npm install -g @openclaw/feishu@latest"
        exit 1
    fi
    echo "✅ Feishu plugin installed successfully"
fi

echo ""
echo "📁 Step 3: Setting up configuration..."

# Create OpenClaw directory if it doesn't exist
mkdir -p ~/.openclaw

# Check if config file exists in current directory
if [ ! -f "openclaw-config.json" ]; then
    echo "❌ openclaw-config.json not found in current directory!"
    echo ""
    echo "Please create it from the example:"
    echo "  cp openclaw-config.example.json openclaw-config.json"
    echo "  # Then edit with your credentials"
    exit 1
fi

# Copy the config file
cp openclaw-config.json ~/.openclaw/openclaw.json

echo "✅ Configuration file created at ~/.openclaw/openclaw.json"
echo ""

echo "🔧 Step 4: Creating workspace..."
mkdir -p ~/.openclaw/workspace

echo ""
echo "✅ Setup complete!"
echo ""
echo "=========================================="
echo "📋 Next Steps:"
echo "=========================================="
echo ""
echo "1. Configure Feishu Bot Permissions:"
echo "   - Go to: https://open.feishu.cn/app"
echo "   - Open your app and enable required permissions"
echo "   - See START_HERE.md for details"
echo ""
echo "2. Expose webhook (choose one):"
echo ""
echo "   Option A - Using ngrok (quick testing):"
echo "     ngrok http 18790"
echo ""
echo "   Option B - Using Tailscale (recommended):"
echo "     tailscale funnel 18790"
echo ""
echo "3. Start OpenClaw Gateway:"
echo "   ./start-gateway.sh"
echo ""
echo "4. Configure Feishu Webhook:"
echo "   - Go to: https://open.feishu.cn/app"
echo "   - Event Subscriptions → Request URL"
echo "   - Enter: https://YOUR_URL/feishu/events"
echo "   - Subscribe to: im.message.receive_v1"
echo ""
echo "5. Test your bot:"
echo "   - Send a message to your bot in Feishu"
echo "   - Approve pairing: openclaw pairing approve feishu <code>"
echo "   - Chat with Kimi K2.5!"
echo ""
echo "=========================================="
echo ""
echo "📚 Useful Commands:"
echo "   openclaw status              - Check gateway status"
echo "   openclaw channels status     - Check Feishu connection"
echo "   openclaw pairing list        - List pending approvals"
echo "   openclaw logs --follow       - View live logs"
echo "   openclaw doctor              - Diagnose issues"
echo ""
echo "🔗 Documentation: https://docs.openclaw.ai"
echo "💬 Discord: https://discord.gg/clawd"
echo ""
