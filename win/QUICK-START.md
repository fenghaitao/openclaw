# 🚀 Quick Start - Microsoft Teams Integration

## Your Setup is Ready!

All configuration is complete. Follow these 4 simple steps to get your bot running:

---

## Step 1: Start ngrok (2 minutes)

```bash
ngrok http 3978
```

**Copy the HTTPS URL** from the output (looks like: `https://abc123.ngrok.io`)

---

## Step 2: Set Azure Messaging Endpoint (1 minute)

1. Go to: https://portal.azure.com
2. Search for your bot
3. Click **Configuration** (left sidebar)
4. Set **Messaging endpoint** to: `https://YOUR-NGROK-URL.ngrok.io/api/messages`
5. Click **Save**

---

## Step 3: Start OpenClaw Gateway (30 seconds)

```bash
openclaw gateway
```

Leave this running!

---

## Step 4: Test in Azure Web Chat (30 seconds)

1. In Azure Portal, click **Test in Web Chat** (left sidebar)
2. Send: "Hello"
3. Bot should respond!

---

## ✅ If Test Works

Your bot is working! Now install it in Teams:

### Create Teams App Package

1. **Get icon files:**
   - `color.png` (192x192 pixels)
   - `outline.png` (32x32 pixels, transparent)

2. **Create ZIP:**
   ```powershell
   # Put icons in win\teams-app-icons\
   Compress-Archive -Path win\teams-manifest.json, win\teams-app-icons\*.png -DestinationPath win\openclaw-teams.zip
   ```

3. **Install in Teams:**
   - Teams → Apps → Manage your apps
   - Upload an app → Upload a custom app
   - Select `openclaw-teams.zip`
   - Click Add

4. **Chat with your bot!**

---

## 🔧 If Test Doesn't Work

### Check 1: Gateway Running?
```bash
openclaw gateway
```
Should show: "Gateway listening on port 3978"

### Check 2: ngrok Running?
```bash
ngrok http 3978
```
Should show HTTPS URL

### Check 3: Messaging Endpoint Correct?
- Must be HTTPS (not HTTP)
- Must end with `/api/messages`
- Example: `https://abc123.ngrok.io/api/messages`

### Check 4: Credentials Correct?
```bash
cat %USERPROFILE%\.openclaw\openclaw.json
```
Verify App ID, Password, Tenant ID match Azure

---

## 📋 Your Credentials

**App ID:** `f9f803b3-d1e4-489d-a6ac-42b796c2846e`  
**Tenant ID:** `f6995bd1-4340-4351-81e7-0b18e45853a2`  
**Webhook Port:** `3978`  
**Webhook Path:** `/api/messages`

---

## 🎯 One-Command Start

Use the helper script:

```powershell
cd win
.\start-teams-gateway.ps1
```

This will guide you through everything!

---

## 📚 More Help

- **Complete Guide:** `win/SETUP-COMPLETE-SUMMARY.md`
- **Detailed Steps:** `win/STEP3-COMPLETE.md`
- **Troubleshooting:** `win/MSTEAMS-SETUP.md`

---

**Ready? Let's go!**

```bash
# Terminal 1: Start ngrok
ngrok http 3978

# Terminal 2: Start gateway
openclaw gateway
```

Then set the messaging endpoint in Azure and test!
