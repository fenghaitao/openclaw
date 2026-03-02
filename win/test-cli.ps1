# Test OpenClaw CLI locally
# This script makes it easy to chat with the AI via command line

param(
    [Parameter(Mandatory=$false)]
    [string]$Message = "Hello, how are you?"
)

Write-Host "🦞 OpenClaw CLI Test" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sending message: $Message" -ForegroundColor White
Write-Host ""

# Send message to the main agent
openclaw agent --message $Message --agent main

Write-Host ""
Write-Host "✅ Done!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Yellow
Write-Host "  .\win\test-cli.ps1" -ForegroundColor Gray
Write-Host "  .\win\test-cli.ps1 -Message 'What is 2+2?'" -ForegroundColor Gray
Write-Host "  openclaw agent --message 'Your question' --agent main" -ForegroundColor Gray
