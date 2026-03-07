#!/bin/bash

# Start OpenClaw Gateway with Feishu + MS Teams
# This script starts the OpenClaw gateway with tunnels for both channels

echo "🦞 Starting OpenClaw Gateway..."
echo "================================"
echo ""
echo "Configuration: ~/.openclaw/openclaw.json"
echo "Model: GitHub Copilot GPT-4o"
echo "Channels: Feishu + MS Teams"
echo ""

# Configure gateway for LAN access
echo "⚙️  Configuring gateway for LAN access..."
openclaw config set gateway.bind lan 2>/dev/null || true

# Add public IP to allowed origins
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "")
if [ -n "$PUBLIC_IP" ]; then
    echo "⚙️  Adding http://$PUBLIC_IP:19999 to allowed origins..."
    openclaw config set gateway.controlUi.allowedOrigins "[\"http://localhost:19999\",\"http://127.0.0.1:19999\",\"http://$PUBLIC_IP:19999\"]" 2>/dev/null || true
fi
echo ""

# Start Tailscale Funnel for MS Teams (port 3978)
echo "🌐 Starting Tailscale Funnel for MS Teams (port 3978)..."
tailscale funnel --bg 3978 2>/dev/null || echo "⚠️  Tailscale Funnel already running or failed"
sleep 2

# Start ngrok for Feishu (port 20000)
echo "🌐 Starting ngrok for Feishu (port 20000)..."
pkill -f "ngrok.*20000" 2>/dev/null
ngrok http 20000 > ~/ngrok-feishu.log 2>&1 &
sleep 5

# Get tunnel URLs
echo ""
echo "📡 Tunnel Status:"
echo "----------------"
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | jq -r '.tunnels[0].public_url' 2>/dev/null)
if [ -n "$NGROK_URL" ] && [ "$NGROK_URL" != "null" ]; then
  echo "✅ Feishu webhook: $NGROK_URL/feishu/events"
else
  echo "⚠️  ngrok tunnel not ready yet (check ~/ngrok-feishu.log)"
fi

echo "✅ MS Teams webhook: https://ununtu24.tail9c6f1c.ts.net/api/messages"
echo ""

# Start the gateway
echo "🚀 Starting OpenClaw gateway..."
echo ""
echo "Gateway will listen on:"
echo "  - Main: ws://127.0.0.1:19999"
echo "  - Feishu webhook: http://127.0.0.1:20000/feishu/events"
echo "  - MS Teams webhook: http://0.0.0.0:3978/api/messages"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "================================"
echo ""

# Display access information
echo ""
echo "🔐 Authentication:"
echo "Gateway token: $(openclaw config get gateway.auth.token 2>/dev/null || echo 'Token not found')"
echo ""
echo "🌐 Access via SSH Tunnel (Recommended):"
echo "  ssh -L 19999:localhost:19999 $USER@$PUBLIC_IP"
echo "  Then open: http://localhost:19999"
echo ""

# Start the gateway with increased heap size
NODE_OPTIONS="--max-old-space-size=3072" openclaw gateway run --bind lan --port 19999 --verbose
