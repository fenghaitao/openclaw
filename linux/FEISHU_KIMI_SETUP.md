# OpenClaw Setup Guide: Feishu + Kimi K2.5

This guide will help you set up OpenClaw with Feishu (飞书/Lark) as your messaging channel and Kimi K2.5 as your AI model.

## Prerequisites

- Node.js 22 or higher
- npm, pnpm, or bun package manager
- A Feishu/Lark account with admin access to create a bot
- A Moonshot AI API key (for Kimi K2.5)

## Step 1: Install OpenClaw

```bash
# Install OpenClaw globally
npm install -g openclaw@latest

# Or with pnpm
pnpm add -g openclaw@latest
```

## Step 2: Install Feishu Plugin

```bash
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

Create `~/.openclaw/openclaw.json` with the following content:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "moonshot/kimi-k2.5"
      },
      "workspace": "~/.openclaw/workspace"
    }
  },
  "providers": {
    "moonshot": {
      "apiKey": "YOUR_MOONSHOT_API_KEY_HERE"
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "appId": "YOUR_FEISHU_APP_ID",
      "appSecret": "YOUR_FEISHU_APP_SECRET",
      "verificationToken": "YOUR_VERIFICATION_TOKEN",
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
    "bind": "0.0.0.0",
    "port": 18789
  }
}
```

### Configuration Explanation:

**Model Settings:**
- `agents.defaults.model.primary`: Set to `moonshot/kimi-k2.5` for Kimi K2.5
- `providers.moonshot.apiKey`: Your Moonshot API key

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

## Step 6: Start OpenClaw Gateway

```bash
# Start the gateway
openclaw gateway run --bind 0.0.0.0 --port 18789 --verbose
```

The gateway will start and show you the webhook URL.

## Step 7: Configure Feishu Webhook

### Option A: Using Public URL (Production)

If you have a public domain:

1. Set up reverse proxy (nginx/caddy) to forward to `http://localhost:18790/feishu/events`
2. In Feishu app settings → Event Subscriptions:
   - Request URL: `https://your-domain.com/feishu/events`
   - Click "Verify" - OpenClaw will handle the verification
3. Subscribe to these events:
   - `im.message.receive_v1` - Receive messages
   - `im.message.reaction.created_v1` - Receive reactions (optional)

### Option B: Using Tailscale (Recommended for Testing)

```bash
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

```bash
# In a separate terminal
ngrok http 18790
```

Use the ngrok URL (e.g., `https://abc123.ngrok.io/feishu/events`) in Feishu webhook settings.

## Step 8: Approve Users (Pairing Mode)

Since `dmPolicy` is set to `"pairing"`, users need approval:

1. User sends a message to the bot
2. Bot responds with a pairing code
3. You approve with:
   ```bash
   openclaw pairing approve feishu <pairing-code>
   ```

To list pending pairing requests:
```bash
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
```bash
openclaw status
```

### Check Feishu Connection
```bash
openclaw channels status
```

### View Logs
```bash
openclaw logs --follow
```

### Test Moonshot API
```bash
openclaw agent --message "Hello" --thinking low
```

### Common Issues

**1. Webhook verification fails:**
- Ensure `verificationToken` matches Feishu app settings
- Check that webhook URL is accessible from internet
- Verify gateway is running on correct port

**2. Bot doesn't respond:**
- Check if user is approved (pairing mode)
- Verify bot has correct permissions in Feishu
- Check logs for errors: `openclaw logs`

**3. "Model not found" error:**
- Verify Moonshot API key is correct
- Check API key has access to Kimi K2.5
- Test with: `openclaw models list`

**4. Group messages not working:**
- Ensure bot is added to the group
- Check `requireMention` setting
- Verify group is in allowlist if using `groupPolicy: "allowlist"`

## Security Best Practices

1. **Use pairing mode for DMs**: Prevents unauthorized access
2. **Use allowlist for groups**: Only enable bot in specific groups
3. **Keep API keys secure**: Never commit them to version control
4. **Use environment variables**: Store secrets in env vars instead of config
5. **Enable HTTPS**: Always use HTTPS for webhook endpoints
6. **Rotate keys regularly**: Change API keys and tokens periodically

## Environment Variables (Alternative to Config File)

```bash
export MOONSHOT_API_KEY="your_moonshot_key"
export FEISHU_APP_ID="your_app_id"
export FEISHU_APP_SECRET="your_app_secret"
export FEISHU_VERIFICATION_TOKEN="your_token"
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
  }
}
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
