# OpenClaw Windows Configuration

This directory contains the OpenClaw configuration for Windows systems.

## Quick Start

### Step 1: Copy Configuration to System

Choose one method:

#### Method A: Using PowerShell (Recommended)
```powershell
cd win
.\copy-config.ps1
```

#### Method B: Using Batch File
```cmd
cd win
copy-config.bat
```

#### Method C: Manual Copy
```powershell
# Create directory
New-Item -ItemType Directory -Path "$env:USERPROFILE\.openclaw" -Force

# Copy config
Copy-Item "win\openclaw-config.json" "$env:USERPROFILE\.openclaw\openclaw.json"
```

### Step 2: Set GitHub Token

The configuration uses `github-copilot/gpt-4o` as the primary model. You need to provide a GitHub token.

#### Option A: Create .env file (Recommended)
```powershell
# Create .env file
$envContent = "COPILOT_GITHUB_TOKEN=your_github_token_here"
$envPath = Join-Path $env:USERPROFILE ".openclaw\.env"
$envContent | Out-File -FilePath $envPath -Encoding UTF8
```

#### Option B: Set Environment Variable
```powershell
# Temporary (current session only)
$env:COPILOT_GITHUB_TOKEN = "your_github_token_here"

# Permanent (system-wide)
[System.Environment]::SetEnvironmentVariable("COPILOT_GITHUB_TOKEN", "your_github_token_here", "User")
```

#### Option C: Use Interactive Login
```bash
openclaw models auth login-github-copilot
```

### Step 3: Start OpenClaw

```bash
openclaw gateway
```

Or use the provided startup script:
```powershell
.\setup-and-run.ps1
```

## Configuration Details

### Current Configuration

- **Primary Model**: `github-copilot/gpt-4o`
- **Workspace**: `%USERPROFILE%\.openclaw\workspace`
- **Gateway Port**: 18789
- **Gateway Bind**: loopback (127.0.0.1)

### Channels Configured

#### Feishu (Lark)
- **Enabled**: Yes
- **Connection Mode**: Webhook
- **Webhook Port**: 18790
- **DM Policy**: Pairing (requires approval for new contacts)
- **Group Policy**: Allowlist with mention required

### Additional Providers

The configuration also includes Moonshot (Kimi) provider as a fallback:
- Kimi K2.5
- Moonshot V1 (8K, 32K, 128K variants)

## File Locations

After installation:

- **Main Config**: `%USERPROFILE%\.openclaw\openclaw.json`
- **Environment Variables**: `%USERPROFILE%\.openclaw\.env`
- **Workspace**: `%USERPROFILE%\.openclaw\workspace`
- **Credentials**: `%USERPROFILE%\.openclaw\credentials`
- **Sessions**: `%USERPROFILE%\.openclaw\sessions`

## Troubleshooting

### Check Configuration
```bash
openclaw config get
```

### Check Model Status
```bash
openclaw models status
```

### Check Gateway Status
```bash
openclaw status
```

### View Logs
```bash
openclaw logs
```

### Test GitHub Copilot Connection
```bash
# This will show if your token is working
openclaw models status
```

## Getting a GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name (e.g., "OpenClaw Copilot")
4. Select scope: `read:user` (minimum required)
5. Click "Generate token"
6. Copy the token (starts with `ghp_` or `github_pat_`)

## Security Notes

- The configuration file contains API keys and tokens
- Keep `openclaw-config.json` secure and don't commit it to public repositories
- The `.env` file is automatically ignored by git
- Tokens are stored in `%USERPROFILE%\.openclaw\credentials` with restricted permissions

## Support

- Documentation: https://docs.openclaw.ai
- GitHub: https://github.com/openclaw/openclaw
- Discord: https://discord.gg/clawd

## Next Steps

After setup:

1. Test the connection: `openclaw status`
2. Send a test message through Feishu
3. Check the logs if something doesn't work: `openclaw logs`
4. Read the docs for advanced configuration: https://docs.openclaw.ai
