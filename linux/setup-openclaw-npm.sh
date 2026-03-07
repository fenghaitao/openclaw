#!/usr/bin/env bash
set -euo pipefail

# OpenClaw Setup Script (npm installation)
# Sets up OpenClaw with Feishu and MS Teams channels
# For 1GB RAM systems with 4GB swap

echo "🦞 OpenClaw Setup Script"
echo "========================"
echo ""
echo "This script will:"
echo "  1. Create 4GB swap file (if needed)"
echo "  2. Install OpenClaw via npm"
echo "  3. Install Feishu and MS Teams plugins"
echo "  4. Install required dependencies"
echo "  5. Create configuration file"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# ============================================================================
# 1. Setup Swap File (4GB)
# ============================================================================
echo "📝 Step 1: Setting up swap file..."
SWAP_FILE="/swapfile"
SWAP_SIZE="4G"

if swapon --show | grep -q "$SWAP_FILE"; then
  echo "✅ Swap file already exists"
  swapon --show
else
  echo "Creating ${SWAP_SIZE} swap file..."
  sudo fallocate -l "$SWAP_SIZE" "$SWAP_FILE"
  sudo chmod 600 "$SWAP_FILE"
  sudo mkswap "$SWAP_FILE"
  sudo swapon "$SWAP_FILE"
  echo "✅ Swap file created and enabled"
  
  # Make permanent
  if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "✅ Added to /etc/fstab (permanent)"
  fi
fi

echo ""
free -h
echo ""

# ============================================================================
# 2. Install OpenClaw via npm
# ============================================================================
echo "📦 Step 2: Installing OpenClaw..."

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
  echo "❌ Error: Node.js 22+ required (found: $(node -v))"
  exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Install OpenClaw globally with increased heap
echo "Installing openclaw@latest..."
NODE_OPTIONS="--max-old-space-size=3072" npm install -g openclaw@latest

echo "✅ OpenClaw installed: $(openclaw --version)"
echo ""

# ============================================================================
# 3. Install Plugins
# ============================================================================
echo "🔌 Step 3: Installing plugins..."

# Create plugins directory
mkdir -p ~/.openclaw/plugins
cd ~/.openclaw/plugins

# Install Feishu plugin
echo "Installing @openclaw/feishu..."
NODE_OPTIONS="--max-old-space-size=3072" npm install @openclaw/feishu --omit=dev

# Install MS Teams plugin
echo "Installing @openclaw/msteams..."
NODE_OPTIONS="--max-old-space-size=3072" npm install @openclaw/msteams --omit=dev

# Install MS Teams dependency (if needed)
MSTEAMS_DIR=$(npm list -g | grep openclaw | head -1 | awk '{print $NF}')/extensions/msteams
if [ -d "$MSTEAMS_DIR" ]; then
  echo "Installing @microsoft/agents-hosting dependency..."
  cd "$MSTEAMS_DIR"
  NODE_OPTIONS="--max-old-space-size=3072" npm install @microsoft/agents-hosting --omit=dev
  cd ~/.openclaw/plugins
fi

echo "✅ Plugins installed"
ls -la node_modules/@openclaw/
echo ""

# ============================================================================
# 4. Create Configuration File
# ============================================================================
echo "⚙️  Step 4: Creating configuration..."

cat > ~/.openclaw/openclaw.json << 'CONFIGEOF'
{
  "meta": {
    "lastTouchedVersion": "2026.3.2",
    "lastTouchedAt": "2026-03-07T06:30:00.000Z"
  },
  "models": {
    "mode": "merge",
    "providers": {
      "moonshot": {
        "baseUrl": "https://api.moonshot.cn/v1",
        "apiKey": "YOUR_MOONSHOT_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "kimi-k2.5",
            "name": "Kimi K2.5"
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "moonshot/kimi-k2.5"
      },
      "workspace": "~/.openclaw/workspace"
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "appId": "YOUR_FEISHU_APP_ID",
      "appSecret": "YOUR_FEISHU_APP_SECRET",
      "verificationToken": "YOUR_FEISHU_VERIFICATION_TOKEN",
      "domain": "feishu",
      "connectionMode": "webhook",
      "webhookPath": "/feishu/events",
      "webhookPort": 20000,
      "dmPolicy": "pairing",
      "groupPolicy": "open",
      "allowFrom": ["*"]
    },
    "msteams": {
      "enabled": true,
      "appId": "YOUR_MSTEAMS_APP_ID",
      "appPassword": "YOUR_MSTEAMS_APP_PASSWORD",
      "tenantId": "YOUR_MSTEAMS_TENANT_ID",
      "webhook": {
        "port": 3978,
        "path": "/api/messages"
      },
      "dmPolicy": "open",
      "groupPolicy": "open",
      "allowFrom": ["*"]
    }
  },
  "gateway": {
    "port": 19999,
    "mode": "local",
    "bind": "loopback"
  },
  "plugins": {
    "entries": {
      "feishu": {
        "enabled": true
      },
      "msteams": {
        "enabled": true
      }
    }
  }
}
CONFIGEOF

echo "✅ Configuration created at ~/.openclaw/openclaw.json"
echo ""
echo "⚠️  IMPORTANT: Edit ~/.openclaw/openclaw.json and replace:"
echo "   - YOUR_MOONSHOT_API_KEY"
echo "   - YOUR_FEISHU_APP_ID, YOUR_FEISHU_APP_SECRET, YOUR_FEISHU_VERIFICATION_TOKEN"
echo "   - YOUR_MSTEAMS_APP_ID, YOUR_MSTEAMS_APP_PASSWORD, YOUR_MSTEAMS_TENANT_ID"
echo ""

# ============================================================================
# 5. Install Tunnel Tools (optional)
# ============================================================================
echo "🌐 Step 5: Tunnel tools check..."

if command -v ngrok &> /dev/null; then
  echo "✅ ngrok installed: $(ngrok version)"
else
  echo "⚠️  ngrok not found - install from https://ngrok.com/download"
fi

if command -v tailscale &> /dev/null; then
  echo "✅ Tailscale installed"
else
  echo "⚠️  Tailscale not found - install from https://tailscale.com/download"
fi

echo ""

# ============================================================================
# Summary
# ============================================================================
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Next Steps:"
echo "1. Edit config: nano ~/.openclaw/openclaw.json"
echo "2. Add your API keys and credentials"
echo "3. Start gateway: openclaw gateway run --bind loopback --port 19999"
echo "4. Or use: ./linux/start-gateway.sh (if available)"
echo ""
echo "Useful Commands:"
echo "  - Check status: openclaw channels status"
echo "  - Fix config: openclaw doctor --fix"
echo "  - View logs: tail -f /tmp/openclaw/openclaw-*.log"
echo ""
echo "Tunnels:"
echo "  - Feishu (port 20000): ngrok http 20000"
echo "  - MS Teams (port 3978): tailscale funnel --bg 3978"
echo ""
echo "Memory Usage:"
free -h
echo ""
echo "✅ All done!"
