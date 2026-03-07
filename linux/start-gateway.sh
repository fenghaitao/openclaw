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
echo "  - Main: http://0.0.0.0:19999"
echo "  - Webhook: http://0.0.0.0:20000/feishu/events"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "================================"
echo ""

# Start the gateway
openclaw gateway run --bind loopback --port 19999 --verbose
