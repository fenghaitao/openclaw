# 🦞 OpenClaw + Feishu + Kimi K2.5 Setup

**Location**: `linux/` folder in this repository

This folder contains all the setup scripts and documentation for running OpenClaw with Feishu and Kimi K2.5.

## 📁 Files in This Directory

- ✅ `openclaw-config.example.json` - Example configuration (copy and customize)
- ✅ `openclaw-config.json` - Your actual configuration (gitignored)
- ✅ `setup-and-run.sh` - Setup script (installs Feishu plugin & copies config)
- ✅ `start-gateway.sh` - Start the OpenClaw gateway
- ✅ `fix-install.sh` - Fix npm installation issues (if needed)
- ✅ `README.md` - This file (quick reference)
- ✅ `START_HERE.md` - **Main setup guide** (read this first!)
- ✅ `QUICK_START.md` - Quick reference guide
- ✅ `FEISHU_KIMI_SETUP.md` - Detailed Feishu setup documentation
- ✅ `INSTALLATION_FIX.md` - Troubleshooting installation issues
- ✅ `FOLDER_STRUCTURE.md` - Explains this folder organization

## 🔐 Before You Start

1. Copy the example config:
   ```bash
   cp openclaw-config.example.json openclaw-config.json
   ```

2. Edit `openclaw-config.json` with your credentials:
   - Moonshot API key
   - Feishu App ID
   - Feishu App Secret
   - Feishu Verification Token

**Note**: `openclaw-config.json` is gitignored to protect your credentials.

## 🚀 Quick Start

### 0. Setup Configuration
```bash
# Make sure you're in the linux/ directory
cd linux/

# Copy example config and edit with your credentials
cp openclaw-config.example.json openclaw-config.json
nano openclaw-config.json  # or use vim/code
```

### 1. Run Setup (installs Feishu plugin & copies config)
```bash
./setup-and-run.sh
```

### 2. Start Gateway
```bash
./start-gateway.sh
```

That's it! The script will check if OpenClaw is installed and only install what's missing.

## 📖 Full Instructions

Read `START_HERE.md` for complete step-by-step instructions including:
- Feishu bot configuration
- Webhook setup with ngrok/Tailscale
- Testing and troubleshooting
- Security best practices

## ⚡ Your Configuration

- **Model**: Kimi K2.5 (Moonshot)
- **Channel**: Feishu (飞书)
- **App ID**: cli_a92e8d2ca6219bd7
- **DM Policy**: Pairing (users need approval)
- **Location**: Linux filesystem (better performance on WSL)

## 🔧 Common Commands

```bash
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

1. **Installation issues**: Read `INSTALLATION_FIX.md`
2. **Setup questions**: Read `START_HERE.md`
3. **Detailed docs**: Read `FEISHU_KIMI_SETUP.md`

## 🔐 Security Note

Your credentials are in `openclaw-config.json`, which is gitignored. Never commit this file to version control!

To share this setup:
1. Commit everything except `openclaw-config.json`
2. Others can copy `openclaw-config.example.json` and add their own credentials

---

**Ready?** Start with: `./fix-install.sh` then `./setup-and-run.sh`
