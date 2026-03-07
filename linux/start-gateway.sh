#!/bin/bash

# Start OpenClaw Gateway with Feishu + MS Teams
# This script starts the OpenClaw gateway with tunnels for both channels

echo "🦞 Starting OpenClaw Gateway..."
echo "================================"
echo ""
echo "Configuration: ~/.openclaw/openclaw.json"
echo "Model: Kimi K2.5 (Moonshot)"
echo "Channels: Feishu + MS Teams"
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

# Start the gateway with increased heap size
NODE_OPTIONS="--max-old-space-size=3072" openclaw gateway run --bind loopback --port 19999 --verbose
