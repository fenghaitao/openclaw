# Test Feishu message handling
# This simulates a message from Feishu to test if the AI model responds correctly

$webhookUrl = "http://localhost:18790/feishu/events"

# Simulate a Feishu message event
$testMessage = @{
    schema = "2.0"
    header = @{
        event_id = "test-$(Get-Date -Format 'yyyyMMddHHmmss')"
        event_type = "im.message.receive_v1"
        create_time = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds().ToString()
        token = "axmGMeoZKziW7paZFwU2cgSARRl6BcgA"
        app_id = "cli_a92e8d2ca6219bd7"
    }
    event = @{
        sender = @{
            sender_id = @{
                open_id = "ou_test_user_123"
                user_id = "test_user"
            }
            sender_type = "user"
        }
        message = @{
            message_id = "om_test_$(Get-Date -Format 'yyyyMMddHHmmss')"
            root_id = ""
            parent_id = ""
            create_time = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds().ToString()
            chat_id = "oc_test_chat_123"
            chat_type = "p2p"
            message_type = "text"
            content = '{"text":"你好"}'
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "Sending test message to OpenClaw..." -ForegroundColor Cyan
Write-Host "Webhook URL: $webhookUrl" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $testMessage -ContentType "application/json"
    Write-Host "✅ Message sent successfully!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ Error sending message:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message
    }
}

Write-Host ""
Write-Host "Check the gateway logs for AI response:" -ForegroundColor Yellow
Write-Host "  Terminal ID: 21" -ForegroundColor Gray
