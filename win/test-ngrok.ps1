# ngrok Validation Script for Windows
# This script helps you test ngrok with a simple server

Write-Host "🔍 ngrok Validation Test" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node -v
    Write-Host "✅ Node.js $nodeVersion detected" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js first." -ForegroundColor Red
    Write-Host "   Visit: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if ngrok is installed
try {
    $ngrokVersion = ngrok version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ngrok is installed: $ngrokVersion" -ForegroundColor Green
    } else {
        throw "ngrok not found"
    }
} catch {
    Write-Host "❌ ngrok is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "To install ngrok:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://ngrok.com/download" -ForegroundColor Gray
    Write-Host "2. Extract ngrok.exe to a folder" -ForegroundColor Gray
    Write-Host "3. Add that folder to your PATH" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or use Chocolatey: choco install ngrok" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "📋 Test Plan:" -ForegroundColor Cyan
Write-Host "1. Start a test server on port 18790" -ForegroundColor White
Write-Host "2. Expose it with ngrok" -ForegroundColor White
Write-Host "3. Validate the connection" -ForegroundColor White
Write-Host ""

# Check if port 18790 is already in use
$portCheck = netstat -ano | Select-String ":18790"
if ($portCheck) {
    Write-Host "⚠️  Port 18790 is already in use:" -ForegroundColor Yellow
    Write-Host $portCheck -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Do you want to kill the process and continue? (y/n)"
    if ($continue -eq 'y') {
        $pid = ($portCheck -split '\s+')[-1]
        Write-Host "Killing process $pid..." -ForegroundColor Yellow
        taskkill /PID $pid /F 2>$null
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "🚀 Starting test server..." -ForegroundColor Cyan
Write-Host ""

# Start the test server in a new window
$serverScript = Join-Path $PSScriptRoot "test-server.js"
if (-not (Test-Path $serverScript)) {
    Write-Host "❌ test-server.js not found!" -ForegroundColor Red
    Write-Host "   Make sure test-server.js is in the same directory." -ForegroundColor Yellow
    exit 1
}

# Start server in a new PowerShell window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "node '$serverScript'"

Write-Host "✅ Test server started in a new window" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 2

Write-Host "🌐 Starting ngrok..." -ForegroundColor Cyan
Write-Host ""
Write-Host "ngrok will open in a new window." -ForegroundColor Gray
Write-Host "Look for the 'Forwarding' line with the HTTPS URL." -ForegroundColor Gray
Write-Host ""

# Start ngrok in a new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "ngrok http 18790"

Start-Sleep -Seconds 3

Write-Host "================================" -ForegroundColor Cyan
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check the ngrok window for the HTTPS URL" -ForegroundColor White
Write-Host "   It looks like: https://abc123.ngrok.io" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open that URL in your browser" -ForegroundColor White
Write-Host "   You should see: '✅ ngrok is working!'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Test the Feishu webhook endpoint:" -ForegroundColor White
Write-Host "   https://YOUR_NGROK_URL/feishu/events" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Check the ngrok web interface:" -ForegroundColor White
Write-Host "   http://localhost:4040" -ForegroundColor Gray
Write-Host "   (Shows all requests in real-time)" -ForegroundColor Gray
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Test setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To stop:" -ForegroundColor Yellow
Write-Host "- Close the server window (Ctrl+C)" -ForegroundColor Gray
Write-Host "- Close the ngrok window (Ctrl+C)" -ForegroundColor Gray
Write-Host ""
