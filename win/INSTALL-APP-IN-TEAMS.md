# 📱 Installing OpenClaw App in Microsoft Teams

## Current Status

✅ Azure Bot working (Test Web Chat works)  
✅ Gateway running  
✅ ngrok tunnel active  
⚠️ Teams app not installed yet  

## Why You Can't Find It in Teams

The bot works in Azure's Test Web Chat, but to use it in Teams, you need to **upload the app package** to Teams.

## 📦 Install the App in Teams

### Method 1: Upload Custom App (Easiest)

1. **Open Microsoft Teams** (desktop or web)

2. **Click "Apps"** in the left sidebar (or bottom on mobile)

3. **Click "Manage your apps"** (bottom left corner)

4. **Click "Upload an app"** or "Upload a custom app"
   - If you see "Upload an app to your org's app catalog", use that instead

5. **Select the file:**
   ```
   C:\Users\haita\openclaw\win\openclaw-teams-app.zip
   ```

6. **Click "Add"** or "Add for me"

7. **The app should appear in your Apps list**

### Method 2: Teams Admin Center (If Method 1 Blocked)

If your organization blocks custom app uploads:

1. Go to: https://admin.teams.microsoft.com
2. Click **Teams apps** → **Manage apps**
3. Click **Upload new app**
4. Select `C:\Users\haita\openclaw\win\openclaw-teams-app.zip`
5. Click **Upload**
6. Go back to Teams → Apps → Search for "OpenClaw"
7. Click **Add**

### Method 3: Teams Developer Portal

1. Go to: https://dev.teams.microsoft.com/apps
2. Click **+ New app**
3. Click **Import app package**
4. Select `C:\Users\haita\openclaw\win\openclaw-teams-app.zip`
5. Click **Import**
6. Go to **Distribute** → **Download app package**
7. In Teams: Apps → Manage your apps → Upload the downloaded ZIP

## 🔍 Finding the App After Installation

### In Teams Desktop/Web:

1. **Click "Apps"** (left sidebar)
2. **Search for "OpenClaw"** in the search bar
3. **Click the app** to open it
4. **Click "Add"** if not already added
5. **Start chatting!**

### Alternative:

1. **Click "Chat"** (left sidebar)
2. **Click "New chat"** (top)
3. **Search for "OpenClaw"**
4. **Select it and start messaging**

## 🐛 Troubleshooting

### "Upload a custom app" Option Missing?

Your organization may have disabled custom apps:

**Option A: Ask IT Admin**
- Request permission to upload custom apps
- Or ask them to upload it to the org catalog

**Option B: Use Teams Admin Center**
- If you have admin access, use Method 2 above

**Option C: Developer Mode**
1. Teams Settings → About → Version
2. Click version 7 times to enable developer mode
3. Try uploading again

### "This app can't be added" Error?

**Check:**
1. App ID in manifest matches Azure Bot App ID
2. Bot is enabled in Azure Bot → Channels → Microsoft Teams
3. You're using the correct ZIP file

**Fix:**
```powershell
# Verify the ZIP contains the right files
Expand-Archive -Path win\openclaw-teams-app.zip -DestinationPath win\temp-check -Force
Get-ChildItem win\temp-check
# Should show: manifest.json, outline.png, color.png
Remove-Item win\temp-check -Recurse -Force
```

### App Uploaded But Can't Find It?

1. **Refresh Teams** (Ctrl+R or Cmd+R)
2. **Check "Built for your org"** section in Apps
3. **Search by exact name**: "OpenClaw"
4. **Check "Manage your apps"** → "Built for [your org]"

### App Shows But Won't Open?

1. **Click the app** in Apps list
2. **Click "Add"** button
3. **Wait a few seconds**
4. **Check Chat list** for new conversation

## ✅ Verification Steps

After installing:

1. **Find the app** in Teams Apps
2. **Open a chat** with the bot
3. **Send "Hello"**
4. **Check gateway logs** for activity:
   ```powershell
   # In PowerShell
   Get-Content C:\Users\haita\AppData\Local\Temp\openclaw\openclaw-2026-03-04.log -Tail 20
   ```

Should see:
```
[msteams] received message
[msteams] processing message
```

## 📋 Quick Checklist

Before installing:
- [ ] Gateway running (Terminal 6)
- [ ] ngrok running (Terminal 7)
- [ ] Azure Bot messaging endpoint updated with ngrok URL
- [ ] File exists: `C:\Users\haita\openclaw\win\openclaw-teams-app.zip`

After installing:
- [ ] App appears in Teams Apps
- [ ] Can open chat with bot
- [ ] Bot responds to messages
- [ ] No errors in gateway logs

## 🎯 Next Steps After Installation

1. **Test the bot**: Send "Hello" or "What can you do?"
2. **Approve pairing** (if needed): `openclaw pairing approve msteams <code>`
3. **Add to groups/channels** (optional)
4. **Configure access control** (optional)

## 📱 Mobile Installation

The app will automatically sync to Teams mobile apps once installed on desktop.

To install directly on mobile:
1. Open Teams mobile app
2. Tap "Apps" (bottom)
3. Tap "Manage your apps"
4. You should see "OpenClaw" if already installed on desktop
5. Or use the same upload process if available

---

**Need Help?**

If you're still stuck, check:
- Your organization's Teams app policies
- Whether you have permission to upload custom apps
- Contact your Teams admin for assistance

**File Location:**
```
C:\Users\haita\openclaw\win\openclaw-teams-app.zip
```
