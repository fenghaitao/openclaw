# Azure Bot Creation - Quick Reference Card

## 🚀 Quick Start (5 Minutes)

### 1. Create Bot
**URL**: https://portal.azure.com/#create/Microsoft.AzureBot

**Settings**:
- Bot handle: `openclaw-bot-[yourname]` (must be unique)
- Pricing: **F0 (Free)**
- Type: **Single Tenant** ⚠️ Important!
- Creation: **Create new Microsoft App ID**

Click: **Review + create** → **Create** → Wait 1-2 min

### 2. Get App ID
1. Go to resource → **Configuration**
2. Copy **Microsoft App ID**
3. Save as: `APP_ID`

### 3. Get App Password
1. Click **Manage** (next to App ID)
2. **Certificates & secrets** → **+ New client secret**
3. Description: `OpenClaw`
4. Click **Add**
5. **COPY VALUE IMMEDIATELY** ⚠️ (you can't see it again!)
6. Save as: `APP_PASSWORD`

### 4. Get Tenant ID
1. Still in App Registration → **Overview**
2. Copy **Directory (tenant) ID**
3. Save as: `TENANT_ID`

## ✅ Checklist

Before proceeding, verify you have:

```
[ ] APP_ID (format: 12345678-1234-1234-1234-123456789abc)
[ ] APP_PASSWORD (format: abc123~DEF456.ghi789-JKL012)
[ ] TENANT_ID (format: 87654321-4321-4321-4321-210987654321)
```

## 📋 Credential Template

Copy this and fill in your values:

```text
APP_ID: ________________________________
APP_PASSWORD: __________________________
TENANT_ID: _____________________________
```

## ⚡ Next Step

Run the setup script with your credentials:

```powershell
cd win
.\setup-msteams.ps1
```

Or paste into the script when prompted.

## 🔗 Quick Links

- **Azure Portal**: https://portal.azure.com
- **Create Bot**: https://portal.azure.com/#create/Microsoft.AzureBot
- **All Resources**: https://portal.azure.com/#blade/HubsExtension/BrowseAll

## ⚠️ Common Mistakes

❌ Selecting Multi-Tenant (use Single Tenant)
❌ Not copying App Password immediately
❌ Copying Secret ID instead of Secret Value
❌ Sharing credentials publicly

## 💡 Pro Tips

- Use a descriptive bot handle (e.g., `openclaw-acme-bot`)
- Save credentials in a password manager
- Delete temporary credential files after setup
- F0 (Free) tier gives you 10,000 messages/month

## 🆘 Troubleshooting

**Bot handle taken?**
→ Try: `openclaw-bot-2`, `openclaw-[company]-bot`

**Lost App Password?**
→ Create new secret in Certificates & secrets

**Can't find App Registration?**
→ Click "Manage" next to App ID in Bot Configuration

## 📱 Mobile Friendly

Scan this QR code to access Azure Portal on mobile:
(Or just go to: portal.azure.com)

---

**Time to complete**: ~5 minutes
**Cost**: Free (F0 tier)
**Difficulty**: Easy

Ready? Go to: https://portal.azure.com/#create/Microsoft.AzureBot
