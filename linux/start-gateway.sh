#!/bin/bash

# Start OpenClaw Gateway
# This script starts the OpenClaw gateway with your Feishu + Kimi K2.5 configuration

echo "🦞 Starting OpenClaw Gateway..."
echo "================================"
echo ""
echo "Configuration: ~/.openclaw/openclaw.json"
echo "Model: Kimi K2.5 (Moonshot)"
echo "Channel: Feishu"
echo ""
echo "Gateway will listen on:"
echo "  - Main: http://0.0.0.0:18789"
echo "  - Webhook: http://0.0.0.0:18790/feishu/events"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "================================"
echo ""

# Start the gateway
openclaw gateway run --bind 0.0.0.0 --port 18789 --verbose
