# 🦞 OpenClaw + Feishu + Kimi K2.5 Setup (Windows)

**Location**: `win/` folder in this repository

This folder contains all the setup scripts and documentation for running OpenClaw with Feishu and Kimi K2.5 on Windows.

## 📁 Files in This Directory

- ✅ `openclaw-config.example.json` - Example configuration (copy and customize)
- ✅ `openclaw-config.json` - Your actual configuration (gitignored)
- ✅ `setup-and-run.ps1` - Setup script (installs Feishu plugin & copies config)
- ✅ `start-gateway.ps1` - Start the OpenClaw gateway
- ✅ `README.md` - This file (quick reference)
- ✅ `START_HERE.md` - Beginner-friendly navigation guide
- ✅ `FEISHU_KIMI_SETUP.md` - Detailed Feishu setup documentation
- ✅ `QUICK_START.md` - Quick reference guide
- ✅ `WINDOWS_NOTES.md` - Windows-specific tips and troubleshooting
- ✅ `SETUP_SUMMARY.md` - Complete checklist and summary

## 🔐 Before You Start

1. Copy the example config:
   ```powershell
   Copy-Item openclaw-config.example.json openclaw-config.json
   ```

2. Edit `openclaw-config.json` with your credentials:
   - Moonshot API key
   - Feishu App ID
   - Feishu App Secret
   - Feishu Verification Token

**Note**: `openclaw-config.json` is gitignored to protect your credentials.

## 🚀 Quick Start (3 Steps)

### 0. Setup Configuration
```powershell
# Make sure you're in the win/ directory
cd win/

# Copy example config and edit with your credentials
Copy-Item openclaw-config.example.json openclaw-config.json
notepad openclaw-config.json  # or use code/vim
```

### 1. Run Setup (installs Feishu plugin & copies config)
```powershell
.\setup-and-run.ps1
```

### 2. Start Gateway
```powershell
.\start-gateway.ps1
```

That's it! The script will check if OpenClaw is installed and only install what's missing.

## 📖 Full Instructions

Read `FEISHU_KIMI_SETUP.md` for complete step-by-step instructions including:
- Feishu bot configuration
- Webhook setup with ngrok/Tailscale
- Testing and troubleshooting
- Security best practices

## ⚡ Your Configuration

- **Model**: Kimi K2.5 (Moonshot)
- **Channel**: Feishu (飞书)
- **DM Policy**: Pairing (users need approval)
- **Platform**: Windows (PowerShell)

## 🔧 Common Commands

```powershell
# Check status
openclaw status

# View logs
openclaw logs --follow

# List pairing requests
openclaw pairing list

# Approve user
openclaw pairing approve feishu <code>

# Test Kimi K2.5
openclaw agent --message "你好"
```

## 🆘 Need Help?

1. **Setup questions**: Read `START_HERE.md`
2. **Detailed docs**: Read `FEISHU_KIMI_SETUP.md`
3. **PowerShell execution policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 🔐 Security Note

Your credentials are in `openclaw-config.json`, which is gitignored. Never commit this file to version control!

To share this setup:
1. Commit everything except `openclaw-config.json`
2. Others can copy `openclaw-config.example.json` and add their own credentials

---

**Ready?** Start with: `.\setup-and-run.ps1`
