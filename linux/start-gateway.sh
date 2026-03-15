#!/bin/bash

# Start OpenClaw Gateway with Feishu + MS Teams + DingTalk
# Config lives in ~/.openclaw/openclaw.json — this script just starts tunnels and the gateway.

echo "🦞 OpenClaw Gateway"
echo "================================"
echo ""
echo "Configuration: ~/.openclaw/openclaw.json"
echo "Model: GitHub Copilot GPT-4o"
echo "Channels: Feishu + MS Teams + DingTalk"
echo ""

# ── MS Teams Tunnel ───────────────────────────────────────────────────────────
echo "🌐 Starting Tailscale Funnel for MS Teams (port 3978)..."
tailscale funnel --bg 3978 2>/dev/null || echo "⚠️  Tailscale Funnel already running or failed"
sleep 2

# ── Tunnel Status ─────────────────────────────────────────────────────────────
echo ""
echo "📡 Tunnel Status:"
echo "----------------"
echo "✅ Feishu: Stream Mode (outbound WebSocket — no tunnel needed)"
echo "✅ MS Teams webhook: https://ununtu24.tail9c6f1c.ts.net/api/messages"
echo "✅ DingTalk: Stream Mode (outbound WebSocket — no tunnel needed)"
echo ""

# ── Auth Info ─────────────────────────────────────────────────────────────────
echo "🔐 Authentication:"
echo "Gateway token: $(openclaw config get gateway.auth.token 2>/dev/null || echo 'Token not found')"
echo ""
echo "🌐 Access via SSH Tunnel (Recommended):"
echo "  ssh -L 19999:localhost:19999 $USER@<server>"
echo "  Then open: http://localhost:19999"
echo ""

# ── Start Gateway ─────────────────────────────────────────────────────────────
echo "================================"
echo "🚀 Starting OpenClaw gateway..."
echo ""
echo "Gateway will listen on:"
echo "  - Main:             ws://127.0.0.1:19999"
echo "  - Feishu:           Stream Mode (outbound WebSocket)"
echo "  - MS Teams webhook: http://0.0.0.0:3978/api/messages"
echo "  - DingTalk:         connected automatically on gateway start"
echo ""
echo "Press Ctrl+C to stop"
echo "================================"
echo ""

# Start the gateway with increased heap size
NODE_OPTIONS="--max-old-space-size=3072" openclaw gateway run --bind loopback --port 19999 --verbose
