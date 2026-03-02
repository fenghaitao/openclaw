# Start OpenClaw Gateway
# This script starts the OpenClaw gateway with your Feishu + Kimi K2.5 configuration

Write-Host "🦞 Starting OpenClaw Gateway..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration: $env:USERPROFILE\.openclaw\openclaw.json" -ForegroundColor Gray
Write-Host "Model: Kimi K2.5 (Moonshot)" -ForegroundColor Gray
Write-Host "Channel: Feishu" -ForegroundColor Gray
Write-Host ""
Write-Host "Gateway will listen on:" -ForegroundColor White
Write-Host "  - Main: http://0.0.0.0:18789" -ForegroundColor Gray
Write-Host "  - Webhook: http://0.0.0.0:18790/feishu/events" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Start the gateway
openclaw gateway run --port 18789 --verbose
