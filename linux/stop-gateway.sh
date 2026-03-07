#!/usr/bin/env bash
set -euo pipefail

# Stop OpenClaw Gateway, ngrok tunnels, and Tailscale Funnel
# This script stops all running OpenClaw gateway, ngrok, and Tailscale processes

echo "🛑 Stopping OpenClaw gateway, ngrok, and Tailscale Funnel..."

# Stop gateway processes
if pkill -9 -f "openclaw-gateway" 2>/dev/null; then
  echo "✅ Stopped OpenClaw gateway"
else
  echo "ℹ️  No OpenClaw gateway process found"
fi

if pkill -9 -f "openclaw gateway" 2>/dev/null; then
  echo "✅ Stopped OpenClaw gateway (alternative)"
else
  echo "ℹ️  No alternative gateway process found"
fi

# Stop ngrok tunnels
if pkill -9 -f "ngrok" 2>/dev/null; then
  echo "✅ Stopped ngrok tunnels"
else
  echo "ℹ️  No ngrok processes found"
fi

# Stop Tailscale Funnel
if tailscale funnel --https=443 off 2>/dev/null; then
  echo "✅ Stopped Tailscale Funnel"
else
  echo "ℹ️  Tailscale Funnel already off or not configured"
fi

# Reset Tailscale serve config (just to be safe)
tailscale serve reset 2>/dev/null || true

sleep 2

# Verify all stopped
REMAINING=$(ps aux | grep -E "openclaw|ngrok" | grep -v grep | wc -l)
if [ "$REMAINING" -eq 0 ]; then
  echo "✅ All processes stopped successfully"
  free -h
else
  echo "⚠️  Warning: $REMAINING process(es) still running:"
  ps aux | grep -E "openclaw|ngrok" | grep -v grep
fi
