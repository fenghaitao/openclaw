# OpenClaw Setup Guide: Feishu + Kimi K2.5 (Windows)

This guide will help you set up OpenClaw with Feishu (飞书/Lark) as your messaging channel and Kimi K2.5 as your AI model on Windows.

## Prerequisites

- Node.js 22 or higher
- npm package manager
- A Feishu/Lark account with admin access to create a bot
- A Moonshot AI API key (for Kimi K2.5)
- PowerShell (included with Windows)

## Step 1: Install OpenClaw

Open PowerShell as Administrator and run:

```powershell
# Install OpenClaw globally
npm install -g openclaw@latest
```

## Step 2: Install Feishu Plugin

```powershell
# The Feishu plugin needs to be installed separately
npm install -g @openclaw/feishu@latest
```

## Step 3: Get Your Moonshot API Key

1. Go to https://platform.moonshot.cn/
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key and save it securely

## Step 4: Create Feishu Bot

### For Feishu (飞书) - China:
1. Go to https://open.feishu.cn/app
2. Click "Create Custom App" (创建企业自建应用)
3. Fill in app name and description
4. After creation, note down:
   - **App ID** (应用凭证 - App ID)
   - **App Secret** (应用凭证 - App Secret)

### For Lark - International:
1. Go to https://open.larksuite.com/app
2. Click "Create Custom App"
3. Follow the same steps as above

### Configure Bot Permissions:
In your Feishu app settings, go to "Permissions & Scopes" and enable:
- `im:message` - Send and receive messages
- `im:message.group_at_msg` - Receive group @ mentions
- `im:message.p2p_msg` - Receive private messages
- `im:chat` - Access chat information
- `contact:user.base` - Read basic user info

### Enable Event Subscriptions:
1. Go to "Event Subscriptions" in your app settings
2. You'll configure the webhook URL after starting OpenClaw (Step 6)

## Step 5: Create Configuration File

Create `%USERPROFILE%\.openclaw\openclaw.json` with the following content:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "moonshot/kimi-k2.5"
      },
      "workspace": "%USERPROFILE%\\.openclaw\\workspace"
    }
  },
  "models": {
    "providers": {
      "moonshot": {
        "apiKey": "YOUR_MOONSHOT_API_KEY_HERE"
      }
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "appId": "YOUR_FEISHU_APP_ID",
      "appSecret": "YOUR_FEISHU_APP_SECRET",
      "verificationToken": "YOUR_FEISHU_VERIFICATION_TOKEN",
      "domain": "feishu",
      "connectionMode": "webhook",
      "webhookPath": "/feishu/events",
      "webhookPort": 18790,
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist",
      "requireMention": true,
      "allowFrom": [],
      "groups": {
        "*": {
          "requireMention": true,
          "enabled": true
        }
      }
    }
  },
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789
  }
}
```

### Configuration Explanation:

**Model Settings:**
- `agents.defaults.model.primary`: Set to `moonshot/kimi-k2.5` for Kimi K2.5
- `models.providers.moonshot.apiKey`: Your Moonshot API key

**Feishu Settings:**
- `appId`: Your Feishu app ID
- `appSecret`: Your Feishu app secret
- `verificationToken`: Get this from Feishu app "Event Subscriptions" page
- `domain`: Use `"feishu"` for China, `"lark"` for international
- `connectionMode`: `"webhook"` (recommended) or `"websocket"`
- `webhookPath`: The path where Feishu will send events
- `webhookPort`: Port for webhook server (default: 18790)
- `dmPolicy`: `"pairing"` means users need approval before chatting
- `groupPolicy`: `"allowlist"` means only specified groups can use the bot
- `requireMention`: Bot only responds when @mentioned in groups

**Gateway Settings:**
- `mode`: `"local"` for local development
- `bind`: `"loopback"` (127.0.0.1) for security, or `"0.0.0.0"` to allow external access
- `port`: Main gateway port (default: 18789)

## Step 6: Start OpenClaw Gateway

```powershell
# Start the gateway
openclaw gateway run --bind 0.0.0.0 --port 18789 --verbose
```

The gateway will start and show you the webhook URL.

## Step 7: Configure Feishu Webhook

### Option A: Using Public URL (Production)

If you have a public domain:

1. Set up reverse proxy (IIS/nginx) to forward to `http://localhost:18790/feishu/events`
2. In Feishu app settings → Event Subscriptions:
   - Request URL: `https://your-domain.com/feishu/events`
   - Click "Verify" - OpenClaw will handle the verification
3. Subscribe to these events:
   - `im.message.receive_v1` - Receive messages
   - `im.message.reaction.created_v1` - Receive reactions (optional)

### Option B: Using Tailscale (Recommended for Testing)

```powershell
# Install Tailscale if not already installed
# Then expose the gateway:
tailscale funnel 18790
```

Update your config to use Tailscale:
```json
{
  "gateway": {
    "tailscale": {
      "mode": "funnel",
      "resetOnExit": true
    }
  }
}
```

### Option C: Using ngrok (Quick Testing)

```powershell
# In a separate PowerShell window
ngrok http 18790
```

Use the ngrok URL (e.g., `https://abc123.ngrok.io/feishu/events`) in Feishu webhook settings.

## Step 8: Approve Users (Pairing Mode)

Since `dmPolicy` is set to `"pairing"`, users need approval:

1. User sends a message to the bot
2. Bot responds with a pairing code
3. You approve with:
   ```powershell
   openclaw pairing approve feishu <pairing-code>
   ```

To list pending pairing requests:
```powershell
openclaw pairing list
```

## Step 9: Test Your Setup

### Test in DM:
1. Open Feishu/Lark
2. Search for your bot by name
3. Send a message: "Hello!"
4. If pairing is required, approve the user first
5. Bot should respond using Kimi K2.5

### Test in Group:
1. Add the bot to a group chat
2. @mention the bot: "@YourBot what's the weather?"
3. Bot should respond

## Advanced Configuration

### Allow Specific Users Only

```json
{
  "channels": {
    "feishu": {
      "dmPolicy": "allowlist",
      "allowFrom": [
        "ou_1234567890abcdef",
        "ou_0987654321fedcba"
      ]
    }
  }
}
```

### Open DM Access (Not Recommended)

```json
{
  "channels": {
    "feishu": {
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  }
}
```

### Enable Specific Groups

```json
{
  "channels": {
    "feishu": {
      "groupPolicy": "allowlist",
      "groups": {
        "oc_1234567890abcdef": {
          "enabled": true,
          "requireMention": true
        },
        "oc_0987654321fedcba": {
          "enabled": true,
          "requireMention": false
        }
      }
    }
  }
}
```

### Use Kimi for Coding (Extended Thinking)

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "kimi-coding/k2p5"
      }
    }
  },
  "providers": {
    "kimi-coding": {
      "apiKey": "YOUR_KIMI_CODING_API_KEY"
    }
  }
}
```

### Enable Feishu Document Tools

```json
{
  "channels": {
    "feishu": {
      "tools": {
        "doc": true,
        "chat": true,
        "wiki": true,
        "drive": true,
        "perm": false
      }
    }
  }
}
```

## Troubleshooting

### Check Gateway Status
```powershell
openclaw status
```

### Check Feishu Connection
```powershell
openclaw channels status
```

### View Logs
```powershell
openclaw logs --follow
```

### Test Moonshot API
```powershell
openclaw agent --message "Hello" --thinking low
```

### Common Issues

**1. PowerShell Execution Policy:**
If you get an error about script execution, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**2. Webhook verification fails:**
- Ensure `verificationToken` matches Feishu app settings
- Check that webhook URL is accessible from internet
- Verify gateway is running on correct port
- Check Windows Firewall settings for port 18790

**3. Bot doesn't respond:**
- Check if user is approved (pairing mode)
- Verify bot has correct permissions in Feishu
- Check logs for errors: `openclaw logs`

**4. "Model not found" error:**
- Verify Moonshot API key is correct
- Check API key has access to Kimi K2.5
- Test with: `openclaw models list`

**5. Group messages not working:**
- Ensure bot is added to the group
- Check `requireMention` setting
- Verify group is in allowlist if using `groupPolicy: "allowlist"`

**6. Port already in use:**
```powershell
# Find process using port 18789 or 18790
netstat -ano | findstr :18789
# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

## Windows Firewall Configuration

If you're exposing the webhook publicly, you may need to allow the ports through Windows Firewall:

```powershell
# Allow port 18789 (gateway)
New-NetFirewallRule -DisplayName "OpenClaw Gateway" -Direction Inbound -LocalPort 18789 -Protocol TCP -Action Allow

# Allow port 18790 (webhook)
New-NetFirewallRule -DisplayName "OpenClaw Webhook" -Direction Inbound -LocalPort 18790 -Protocol TCP -Action Allow
```

## Security Best Practices

1. **Use pairing mode for DMs**: Prevents unauthorized access
2. **Use allowlist for groups**: Only enable bot in specific groups
3. **Keep API keys secure**: Never commit them to version control
4. **Use environment variables**: Store secrets in env vars instead of config
5. **Enable HTTPS**: Always use HTTPS for webhook endpoints
6. **Rotate keys regularly**: Change API keys and tokens periodically
7. **Configure Windows Firewall**: Only allow necessary ports

## Environment Variables (Alternative to Config File)

In PowerShell:
```powershell
$env:MOONSHOT_API_KEY="your_moonshot_key"
$env:FEISHU_APP_ID="your_app_id"
$env:FEISHU_APP_SECRET="your_app_secret"
$env:FEISHU_VERIFICATION_TOKEN="your_token"
```

To make them permanent, add to your PowerShell profile or use System Environment Variables:
```powershell
[System.Environment]::SetEnvironmentVariable('MOONSHOT_API_KEY', 'your_moonshot_key', 'User')
```

Then use a minimal config:
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "moonshot/kimi-k2.5"
      }
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "domain": "feishu",
      "connectionMode": "webhook"
    }
  },
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789
  }
}
```

## Running as a Windows Service

To run OpenClaw as a Windows service, you can use tools like:
- **NSSM** (Non-Sucking Service Manager): https://nssm.cc/
- **WinSW** (Windows Service Wrapper): https://github.com/winsw/winsw

Example with NSSM:
```powershell
# Install NSSM
choco install nssm

# Create service
nssm install OpenClaw "C:\Program Files\nodejs\openclaw.cmd" "gateway run --bind 0.0.0.0 --port 18789"

# Start service
nssm start OpenClaw
```

## Next Steps

- Read the full docs: https://docs.openclaw.ai
- Explore Feishu tools: https://docs.openclaw.ai/channels/feishu
- Configure skills: `openclaw skills list`
- Set up cron jobs: `openclaw cron list`
- Enable browser control: https://docs.openclaw.ai/tools/browser

## Support

- GitHub Issues: https://github.com/openclaw/openclaw/issues
- Discord: https://discord.gg/clawd
- Documentation: https://docs.openclaw.ai

---

**Note**: This setup creates a standalone OpenClaw instance with only Feishu and Kimi K2.5. You can add more channels or models later by updating the configuration.
