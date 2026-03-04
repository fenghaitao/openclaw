# Complete MS Teams Setup - Remaining Steps

## Current Status
- ✅ Azure Bot created with credentials
- ✅ Messaging endpoint set in Azure
- ✅ MS Teams plugin installed
- ✅ Credentials configured in OpenClaw
- ⚠️ Gateway auto-restarting (needs Teams app installation)

## What You Need to Do

### Step 1: Get Your Azure Bot App ID

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to your Azure Bot resource
3. Go to **Configuration**
4. Copy the **Microsoft App ID** (format: `12345678-1234-1234-1234-123456789abc`)

### Step 2: Update Teams Manifest

Run this PowerShell command (replace `YOUR_APP_ID` with the actual App ID from Step 1):

```powershell
cd win

# Set your App ID here
$APP_ID = "YOUR_APP_ID_HERE"

# Update the manifest
$manifest = Get-Content teams-manifest.json | ConvertFrom-Json
$manifest.id = $APP_ID
$manifest.bots[0].botId = $APP_ID

# Add webApplicationInfo (required for RSC permissions)
$manifest | Add-Member -NotePropertyName "webApplicationInfo" -NotePropertyValue @{
    id = $APP_ID
} -Force

# Add RSC permissions for channel/group access
$manifest | Add-Member -NotePropertyName "authorization" -NotePropertyValue @{
    permissions = @{
        resourceSpecific = @(
            @{ name = "ChannelMessage.Read.Group"; type = "Application" },
            @{ name = "ChannelMessage.Send.Group"; type = "Application" },
            @{ name = "Member.Read.Group"; type = "Application" },
            @{ name = "Owner.Read.Group"; type = "Application" },
            @{ name = "ChannelSettings.Read.Group"; type = "Application" },
            @{ name = "TeamMember.Read.Group"; type = "Application" },
            @{ name = "TeamSettings.Read.Group"; type = "Application" },
            @{ name = "ChatMessage.Read.Chat"; type = "Application" }
        )
    }
} -Force

# Save updated manifest
$manifest | ConvertTo-Json -Depth 10 | Set-Content teams-manifest-updated.json

Write-Host "✅ Manifest updated: teams-manifest-updated.json"
```

### Step 3: Create App Icons

You need two PNG icons:
- `outline.png` - 32x32 pixels (transparent background)
- `color.png` - 192x192 pixels

**Quick option**: Download placeholder icons:
```powershell
# Create simple placeholder icons (you can replace these later)
# For now, you can use any PNG images of the right size
```

Or use online tools:
- [Canva](https://www.canva.com) - create custom icons
- [Favicon.io](https://favicon.io) - generate simple icons

### Step 4: Create Teams App Package (ZIP)

```powershell
cd win

# Create the app package
Compress-Archive -Path teams-manifest-updated.json,outline.png,color.png -DestinationPath openclaw-teams-app.zip -Force

Write-Host "✅ Teams app package created: openclaw-teams-app.zip"
```

### Step 5: Set Up Public URL (Tunnel)

Your bot needs to be accessible from the internet. Choose one option:

**Option A: ngrok (Recommended for testing)**
```powershell
# Install ngrok if you don't have it: https://ngrok.com/download
ngrok http 3978
```
Copy the `https://` URL (e.g., `https://abc123.ngrok.io`)

**Option B: Tailscale Funnel**
```powershell
tailscale funnel 3978
```

**Option C: Production** - Use your actual domain/server

### Step 6: Update Azure Bot Messaging Endpoint

1. Go to [Azure Portal](https://portal.azure.com) → Your Azure Bot
2. Go to **Configuration**
3. Set **Messaging endpoint** to: `https://YOUR_TUNNEL_URL/api/messages`
   - Example: `https://abc123.ngrok.io/api/messages`
4. Click **Apply**

### Step 7: Install Teams App

**Method 1: Teams Developer Portal (Easiest)**
1. Go to [Teams Developer Portal](https://dev.teams.microsoft.com/apps)
2. Click **+ New app**
3. Fill in basic info
4. Go to **App features** → **Bot**
5. Select **Enter a bot ID manually** and paste your App ID
6. Check scopes: **Personal**, **Team**, **Group Chat**
7. Go to **Distribute** → **Download app package**
8. In Teams: **Apps** → **Manage your apps** → **Upload a custom app** → select the ZIP

**Method 2: Direct Upload**
1. Open Microsoft Teams
2. Click **Apps** (left sidebar)
3. Click **Manage your apps** (bottom left)
4. Click **Upload a custom app** (or **Upload an app to your org's app catalog**)
5. Select `openclaw-teams-app.zip`
6. Click **Add** to install for yourself

### Step 8: Test the Bot

1. In Teams, find your bot in the Apps section
2. Click **Add** or **Open**
3. Send a test message: "Hello"
4. Check the gateway logs for activity

### Step 9: Verify Gateway

```powershell
# Check if the gateway is receiving messages
Get-Content C:\Users\haita\AppData\Local\Temp\openclaw\openclaw-2026-03-04.log -Tail 50
```

Look for:
- `[msteams] starting provider (port 3978)` - should stop auto-restarting
- `[msteams] received activity` - incoming messages
- No more "auto-restart attempt" messages

## Troubleshooting

### Gateway Still Auto-Restarting
- The bot needs at least one successful interaction before it stabilizes
- Make sure the tunnel URL is correct in Azure
- Check that the App ID in the manifest matches Azure

### "401 Unauthorized" in Logs
- This is normal when testing manually
- Use Azure Bot's **Test in Web Chat** to verify webhook first

### Bot Not Responding in Teams
- Verify the messaging endpoint in Azure is correct
- Check that the tunnel is running
- Ensure the App ID in manifest matches Azure
- Try sending a message in Azure Web Chat first

### Icons Missing Error
- Make sure `outline.png` and `color.png` exist
- Verify they're the correct sizes (32x32 and 192x192)
- Ensure they're included in the ZIP

## Optional: Add Graph API Permissions (For Channel Images/Files)

If you want to support images and files in channels (not just DMs):

1. Go to Azure Portal → App Registration (click **Manage** next to App ID)
2. Go to **API permissions** → **Add a permission**
3. Select **Microsoft Graph** → **Application permissions**
4. Add:
   - `ChannelMessage.Read.All`
   - `Chat.Read.All`
   - `Sites.ReadWrite.All` (for file uploads)
5. Click **Grant admin consent**
6. Update the manifest version (e.g., `1.0.0` → `1.1.0`)
7. Re-upload the app package to Teams

## Next Steps After Working

Once the bot is responding:

1. Configure access control in `openclaw.json`:
   ```json
   {
     "channels": {
       "msteams": {
         "dmPolicy": "allowlist",
         "allowFrom": ["user@yourdomain.com"],
         "groupPolicy": "allowlist",
         "groupAllowFrom": ["user@yourdomain.com"]
       }
     }
   }
   ```

2. Test in different contexts:
   - Direct messages
   - Group chats (with @mention)
   - Team channels (with @mention)

3. Monitor the gateway logs for any issues

## Quick Reference

- **Azure Portal**: https://portal.azure.com
- **Teams Developer Portal**: https://dev.teams.microsoft.com
- **OpenClaw Docs**: https://docs.openclaw.ai/channels/msteams
- **Gateway Logs**: `C:\Users\haita\AppData\Local\Temp\openclaw\openclaw-2026-03-04.log`
