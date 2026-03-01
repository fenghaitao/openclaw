#!/bin/bash

# OpenClaw + Feishu + Kimi K2.5 Setup Script
# This script will set up and run OpenClaw with your configuration

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

echo "📦 Step 1: Installing OpenClaw..."

# Check if openclaw is already installed
if npm list -g openclaw &> /dev/null; then
    echo "⚠️  OpenClaw is already installed. Removing old version..."
    npm uninstall -g openclaw
    echo "✅ Old version removed"
fi

# Clean npm cache to avoid ENOTEMPTY errors
echo "🧹 Cleaning npm cache..."
npm cache clean --force

# Install OpenClaw
npm install -g openclaw@latest

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Installation failed. Running fix script..."
    ./fix-install.sh
    exit 1
fi

echo ""
echo "📦 Step 2: Installing Feishu plugin..."

# Check if feishu plugin is already installed
if npm list -g @openclaw/feishu &> /dev/null; then
    echo "⚠️  Feishu plugin is already installed. Removing old version..."
    npm uninstall -g @openclaw/feishu
fi

npm install -g @openclaw/feishu@latest

echo ""
echo "📁 Step 3: Setting up configuration..."

# Create OpenClaw directory if it doesn't exist
mkdir -p ~/.openclaw

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
echo "   - Open your app: cli_a92e8d2ca6219bd7"
echo "   - Enable these permissions:"
echo "     • im:message"
echo "     • im:message.group_at_msg"
echo "     • im:message.p2p_msg"
echo "     • im:chat"
echo "     • contact:user.base"
echo ""
echo "2. Get Verification Token:"
echo "   - In Feishu app → Event Subscriptions"
echo "   - Copy the 'Verification Token'"
echo "   - Add it to ~/.openclaw/openclaw.json:"
echo "     \"verificationToken\": \"YOUR_TOKEN_HERE\""
echo ""
echo "3. Start OpenClaw Gateway:"
echo "   Run: ./start-gateway.sh"
echo ""
echo "4. Expose webhook (choose one):"
echo ""
echo "   Option A - Using ngrok (quick testing):"
echo "     ngrok http 18790"
echo "     Then use the ngrok URL in Feishu webhook settings"
echo ""
echo "   Option B - Using Tailscale (recommended):"
echo "     tailscale funnel 18790"
echo ""
echo "   Option C - Public server:"
echo "     Set up reverse proxy to localhost:18790"
echo ""
echo "5. Configure Feishu Webhook:"
echo "   - Go to: https://open.feishu.cn/app"
echo "   - Event Subscriptions → Request URL"
echo "   - Enter: https://YOUR_URL/feishu/events"
echo "   - Subscribe to: im.message.receive_v1"
echo ""
echo "6. Test your bot:"
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
