# Azure VM Setup Summary

Complete documentation of all configurations and changes made to the Azure Ubuntu 24.04 VM for OpenClaw deployment.

**Date**: 2026-03-07  
**VM IP**: `<YOUR_VM_IP>`  
**User**: `<your_username>`

---

## Table of Contents

- [Overview](#overview)
- [OpenClaw Configuration](#openclaw-configuration)
- [VNC Desktop Setup](#vnc-desktop-setup)
- [Network Configuration](#network-configuration)
- [Access Methods](#access-methods)
- [File Changes](#file-changes)
- [Quick Reference](#quick-reference)

---

## Overview

This VM has been configured with:

1. **OpenClaw Gateway** using GitHub Copilot GPT-4o
2. **VNC Server** with XFCE4 desktop environment
3. **Network ports** opened for remote access
4. **Messaging channels** configured (Feishu, MS Teams)

---

## OpenClaw Configuration

### Primary Changes

#### 1. Model Configuration

**Changed from**: `moonshot/kimi-k2.5`  
**Changed to**: `github-copilot/gpt-4o`

**Command used**:

```bash
openclaw config set agents.defaults.model.primary github-copilot/gpt-4o
```

#### 2. GitHub Copilot Authentication

**Token stored in**: `~/.openclaw/.env`

**Configuration**:

```bash
echo "COPILOT_GITHUB_TOKEN=your_github_token_here" >> ~/.openclaw/.env
```

**Verification**:

```bash
openclaw models status
# Shows: github-copilot effective=env:your_token...
```

#### 3. Gateway Network Binding

**Changed from**: `loopback` (127.0.0.1 only)  
**Changed to**: `lan` (0.0.0.0 - all interfaces)

**Command used**:

```bash
openclaw config set gateway.bind lan
```

**Why**: This allows the gateway to be accessible from outside the VM (required for remote access).

#### 4. Allowed Origins Configuration

**Added**: Public IP to CORS allowed origins

**Command used**:

```bash
openclaw config set gateway.controlUi.allowedOrigins '["http://localhost:19999","http://127.0.0.1:19999","http://<YOUR_VM_IP>:19999"]'
```

**Why**: Required for browser access to the Control UI from different origins.

### Configuration Files Modified

#### `~/.openclaw/openclaw.json`

**Key changes**:

```json
{
  "meta": {
    "lastTouchedVersion": "2026.3.2",
    "lastTouchedAt": "2026-03-07T08:32:30.443Z"
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "github-copilot/gpt-4o"
      }
    }
  },
  "gateway": {
    "port": 19999,
    "mode": "local",
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "YOUR_GATEWAY_TOKEN_HERE"
    },
    "controlUi": {
      "allowedOrigins": [
        "http://localhost:19999",
        "http://127.0.0.1:19999",
        "http://<YOUR_VM_IP>:19999"
      ]
    }
  },
  "channels": {
    "msteams": {
      "enabled": true,
      "appId": "YOUR_AZURE_APP_ID_HERE",
      "tenantId": "YOUR_AZURE_TENANT_ID_HERE",
      "webhook": {
        "port": 3978,
        "path": "/api/messages"
      },
      "dmPolicy": "open",
      "groupPolicy": "open"
    },
    "feishu": {
      "enabled": true,
      "appId": "YOUR_FEISHU_APP_ID",
      "domain": "feishu",
      "connectionMode": "webhook",
      "webhookPath": "/feishu/events",
      "webhookPort": 20000,
      "dmPolicy": "pairing",
      "groupPolicy": "open"
    }
  }
}
```

#### `~/.openclaw/.env`

**Created**: Environment file for GitHub Copilot token

```bash
COPILOT_GITHUB_TOKEN=your_github_token_here
```

#### `linux/openclaw-config.json`

**Updated**: Template configuration synced from `~/.openclaw/openclaw.json`

- Primary model: `github-copilot/gpt-4o`
- Moonshot provider retained for reference (with placeholder API key)
- MS Teams configuration added
- Channel order: msteams → feishu
- All secrets replaced with placeholders

**Committed**:

```
commit 8fc0bcb5b82de1ee8cfb1fdd2440a71d10b058e2
Author: Haitao Feng <haitao.feng@gmail.com>
Date:   Sat Mar 7 08:48:30 2026 +0000

    Linux: switch default model to github-copilot/gpt-4o
```

---

## VNC Desktop Setup

### Installed Components

**Desktop Environment**: XFCE4 (lightweight)  
**VNC Server**: TightVNC  
**Applications**:

- Firefox web browser
- gedit text editor
- Thunar file manager
- GNOME Terminal
- Font packages (base, 75dpi, 100dpi)

### Installation Commands

```bash
# Update packages
sudo apt-get update

# Install XFCE desktop
sudo apt-get install -y xfce4 xfce4-goodies

# Install VNC server
sudo apt-get install -y tightvncserver

# Install utilities
sudo apt-get install -y firefox gedit thunar gnome-terminal dbus-x11 \
  xfonts-base xfonts-75dpi xfonts-100dpi
```

### VNC Configuration

**Display**: :1  
**Port**: 5901  
**Resolution**: 1920x1080  
**Color Depth**: 24-bit  
**Password**: `your_vnc_password` (truncated to 8 chars: `your_vnc_password`)

**Password setup**:

```bash
printf "your_vnc_password\nyour_vnc_password\nn\n" | vncserver :1
```

**Startup script** (`~/.vnc/xstartup`):

```bash
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
```

### VNC Server Management

**Start VNC**:

```bash
vncserver :1 -geometry 1920x1080 -depth 24
```

**Stop VNC**:

```bash
vncserver -kill :1
```

**Check status**:

```bash
ps aux | grep Xtightvnc
ss -tlnp | grep 5901
```

**Change password**:

```bash
vncpasswd
```

---

## Network Configuration

### Azure Network Security Group (NSG) Rules

Two ports need to be opened in Azure NSG for external access:

#### Port 5901 (VNC)

```bash
az network nsg rule create \
  --resource-group "YOUR_RESOURCE_GROUP" \
  --nsg-name "YOUR_NSG_NAME" \
  --name AllowVNC5901 \
  --protocol tcp \
  --priority 1010 \
  --destination-port-range 5901 \
  --access Allow \
  --direction Inbound \
  --description "VNC Server port"
```

#### Port 19999 (OpenClaw Gateway)

```bash
az network nsg rule create \
  --resource-group "YOUR_RESOURCE_GROUP" \
  --nsg-name "YOUR_NSG_NAME" \
  --name AllowPort19999 \
  --protocol tcp \
  --priority 1020 \
  --destination-port-range 19999 \
  --access Allow \
  --direction Inbound \
  --description "OpenClaw Gateway port"
```

**Note**: These rules must be created via Azure Portal or Azure CLI from a machine with Azure CLI installed, as the VM does not have Azure CLI installed.

### Open Ports on VM

| Port  | Service          | Binding   | Status                      |
| ----- | ---------------- | --------- | --------------------------- |
| 19999 | OpenClaw Gateway | 0.0.0.0   | ✅ Running                  |
| 5901  | VNC Server       | 0.0.0.0   | ✅ Running                  |
| 20000 | Feishu Webhook   | 127.0.0.1 | ✅ Running (localhost only) |
| 3978  | MS Teams Webhook | 127.0.0.1 | ✅ Running (localhost only) |
| 20001 | Browser Control  | 127.0.0.1 | ✅ Running (localhost only) |

**Verification commands**:

```bash
ss -tlnp | grep -E '19999|5901|20000|3978|20001'
```

---

## Access Methods

### 1. OpenClaw Gateway (HTTP)

**⚠️ Issue**: Direct HTTP access blocked due to security requirements.

The gateway requires HTTPS or localhost for the Control UI because it needs a "secure context" for device identity.

**Error message**:

```
control ui requires device identity (use HTTPS or localhost secure context)
```

**Solution**: Use SSH tunnel (see below).

### 2. OpenClaw Gateway (SSH Tunnel) ✅ RECOMMENDED

**From your local machine**:

```bash
# Create SSH tunnel
ssh -L 19999:localhost:19999 <your_username>@<YOUR_VM_IP>

# Keep terminal open, then access in browser:
http://localhost:19999
```

**Authentication token**:

```
YOUR_GATEWAY_TOKEN_HERE
```

**Access flow**:

1. SSH tunnel forwards local port 19999 to VM's localhost:19999
2. Browser connects to localhost:19999 (secure context)
3. Gateway sees connection from localhost (allowed)
4. Paste token when prompted for authentication

### 3. VNC Desktop Access

**Direct connection** (after opening port 5901 in Azure NSG):

```
Address: <YOUR_VM_IP>:5901
Password: your_vnc_password
```

**VNC Clients**:

- Windows: TightVNC Viewer, RealVNC Viewer
- macOS: RealVNC Viewer, Screen Sharing (vnc://<YOUR_VM_IP>:5901)
- Linux: xtightvncviewer, Remmina

**SSH Tunnel (more secure)**:

```bash
# From local machine
ssh -L 5901:localhost:5901 <your_username>@<YOUR_VM_IP>

# Then connect VNC to:
localhost:5901
```

---

## File Changes

### Repository Files Modified

1. **`linux/openclaw-config.json`**
   - Updated primary model to `github-copilot/gpt-4o`
   - Synced configuration from active `~/.openclaw/openclaw.json`
   - All secrets sanitized with placeholders
   - Committed to git

2. **`linux/start-gateway.sh`**
   - Added automatic gateway.bind configuration to `lan`
   - Added public IP to allowed origins
   - Added informational output with SSH tunnel instructions
   - Added gateway token display

3. **`win/openclaw-config.example.json`**
   - Changed primary model from `moonshot/kimi-k2.5` to `github-copilot/gpt-4o`
   - Updated provider from moonshot to github-copilot
   - Changed API key placeholder

4. **`win/README.md`**
   - Updated model provider documentation
   - Changed from Moonshot/Kimi to GitHub Copilot

### New Files Created

1. **`VNC-SETUP-GUIDE.md`**
   - Complete VNC installation and configuration guide
   - Connection instructions for all platforms
   - Troubleshooting section
   - Security recommendations

2. **`AZURE-VM-SETUP-SUMMARY.md`** (this file)
   - Complete documentation of all changes
   - Configuration references
   - Access methods
   - Quick reference guide

### User Home Directory Changes

1. **`~/.openclaw/openclaw.json`**
   - Primary model: `github-copilot/gpt-4o`
   - Gateway bind: `lan`
   - Allowed origins: includes public IP
   - Channel order: msteams first, then feishu

2. **`~/.openclaw/.env`**
   - Created with GitHub Copilot token

3. **`~/.vnc/xstartup`**
   - Created VNC startup script for XFCE4

4. **`~/.vnc/passwd`**
   - VNC password file (encrypted)

---

## Quick Reference

### OpenClaw Gateway

**Start gateway**:

```bash
cd ~/openclaw
./linux/start-gateway.sh
# or
openclaw gateway
```

**Stop gateway**:

```bash
pkill -f openclaw-gateway
```

**Check status**:

```bash
openclaw status
ps aux | grep openclaw-gateway
ss -tlnp | grep 19999
```

**View logs**:

```bash
tail -f /tmp/openclaw/openclaw-2026-03-07.log
```

**Configuration commands**:

```bash
# View all config
openclaw config get

# Get specific value
openclaw config get gateway.auth.token
openclaw config get agents.defaults.model.primary

# Set value
openclaw config set gateway.bind lan
```

### VNC Server

**Start**:

```bash
vncserver :1 -geometry 1920x1080 -depth 24
```

**Stop**:

```bash
vncserver -kill :1
```

**Status**:

```bash
ps aux | grep Xtightvnc
ss -tlnp | grep 5901
```

**Logs**:

```bash
cat ~/.vnc/<hostname>:1.log
```

### SSH Tunnels

**OpenClaw Gateway**:

```bash
ssh -L 19999:localhost:19999 <your_username>@<YOUR_VM_IP>
```

**VNC Server**:

```bash
ssh -L 5901:localhost:5901 <your_username>@<YOUR_VM_IP>
```

**Multiple tunnels**:

```bash
ssh -L 19999:localhost:19999 -L 5901:localhost:5901 <your_username>@<YOUR_VM_IP>
```

### Important Credentials

**OpenClaw Gateway Token**:

```
YOUR_GATEWAY_TOKEN_HERE
```

**VNC Password**:

```
your_vnc_password
```

**GitHub Copilot Token**:

```
your_github_token_here
```

### URLs

**VM Public IP**: <YOUR_VM_IP>

**OpenClaw Gateway** (via SSH tunnel):

```
http://localhost:19999
```

**VNC Desktop** (direct):

```
<YOUR_VM_IP>:5901
```

**VNC Desktop** (via SSH tunnel):

```
localhost:5901
```

---

## Security Recommendations

### 1. Change Default Passwords

```bash
# Change VNC password
vncpasswd

# Regenerate OpenClaw gateway token
openclaw config set gateway.auth.token "$(openssl rand -hex 32)"
```

### 2. Restrict Azure NSG Rules

Instead of allowing from `Any`, restrict to your specific IP:

```bash
az network nsg rule update \
  --resource-group "YOUR_RESOURCE_GROUP" \
  --nsg-name "YOUR_NSG_NAME" \
  --name AllowVNC5901 \
  --source-address-prefixes "YOUR.IP.ADDRESS"
```

### 3. Use SSH Tunnels

Always prefer SSH tunnels over direct port access for better encryption and security.

### 4. Regular Updates

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 5. Monitor Access

```bash
# Check active connections
ss -tnp
w

# Review VNC logs
tail -f ~/.vnc/<hostname>:1.log

# Review OpenClaw logs
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

---

## Troubleshooting

### OpenClaw Gateway Won't Start

```bash
# Check if port is in use
ss -tlnp | grep 19999

# Kill existing process
pkill -9 -f openclaw-gateway

# Start fresh
openclaw gateway
```

### Can't Access via Browser

1. **Check gateway is running**: `ps aux | grep openclaw-gateway`
2. **Verify SSH tunnel is active**: `netstat -an | grep 19999`
3. **Check allowed origins**: `openclaw config get gateway.controlUi.allowedOrigins`
4. **Use correct token**: `openclaw config get gateway.auth.token`

### VNC Not Connecting

1. **Check VNC is running**: `ps aux | grep Xtightvnc`
2. **Verify port is listening**: `ss -tlnp | grep 5901`
3. **Check Azure NSG rule exists**: Via Azure Portal
4. **Test locally**: `telnet localhost 5901`

### GitHub Copilot Not Working

```bash
# Check token is set
grep COPILOT ~/.openclaw/.env

# Verify model status
openclaw models status

# Check auth
openclaw models auth
```

---

## Related Documentation

- **VNC Setup Guide**: `VNC-SETUP-GUIDE.md`
- **OpenClaw Docs**: https://docs.openclaw.ai
- **Linux Config Example**: `linux/openclaw-config.example.json`
- **Startup Script**: `linux/start-gateway.sh`

---

**Last Updated**: 2026-03-07  
**VM**: <YOUR_VM_IP> (Ubuntu 24.04)  
**OpenClaw Version**: 2026.3.2  
**Primary Model**: github-copilot/gpt-4o
