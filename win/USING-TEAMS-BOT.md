# 🎉 Using OpenClaw in Microsoft Teams

## ✅ Setup Complete!

Your MS Teams bot is now fully operational. Here's how to use it effectively.

## 💬 Direct Messages (DMs)

You can chat with the bot directly in 1-on-1 conversations:

1. Open the OpenClaw app in Teams
2. Send any message: "Hello", "What can you do?", "Help me with..."
3. The bot will respond!

**Examples:**
- "What's the weather like today?"
- "Help me write a Python script to parse JSON"
- "Explain how async/await works in JavaScript"
- "Create a meeting agenda for tomorrow"

## 👥 Group Chats

To use the bot in group chats, you need to:

1. **Add the bot to the group chat**
2. **@mention the bot** in your message

**Example:**
```
@OpenClaw can you summarize this conversation?
```

**Note:** Group chats are currently blocked by default. To enable:
- Add your user ID to `channels.msteams.groupAllowFrom` in the config
- Or set `groupPolicy: "open"` (allows any group member)

## 📢 Team Channels

To use the bot in team channels:

1. **Install the app in the team** (if not already done)
2. **@mention the bot** in your message

**Example:**
```
@OpenClaw what are the action items from this thread?
```

**Note:** Channels are also blocked by default. Same configuration as group chats applies.

## 🔧 Configuration Tips

### Allow Group/Channel Access

Edit `C:\Users\haita\.openclaw\openclaw.json`:

```json
{
  "channels": {
    "msteams": {
      "groupPolicy": "allowlist",
      "groupAllowFrom": ["c4873ac9-d65d-4a75-8ab9-08dc084321b7"],
      "requireMention": true
    }
  }
}
```

Or for open access (any team member):
```json
{
  "channels": {
    "msteams": {
      "groupPolicy": "open",
      "requireMention": true
    }
  }
}
```

After changing config, restart the gateway:
```powershell
# Stop current gateway (Ctrl+C in Terminal 6)
# Then restart:
openclaw gateway run --bind loopback --port 18789
```

### Disable @mention Requirement

If you want the bot to respond without @mentions:

```json
{
  "channels": {
    "msteams": {
      "requireMention": false
    }
  }
}
```

**Warning:** This means the bot will see ALL messages in channels/groups!

## 🎨 Advanced Features

### Send Files
You can ask the bot to create files:
- "Create a Python script that does X"
- "Generate a CSV file with this data"

The bot will send files directly in the chat.

### Multi-turn Conversations
The bot maintains conversation history:
- "What did I ask you earlier?"
- "Continue from where we left off"

### Code Assistance
- "Review this code: [paste code]"
- "Debug this error: [paste error]"
- "Optimize this function"

### Task Automation
- "Remind me to check the logs in 1 hour"
- "Create a checklist for deploying to production"

## 🔒 Security & Privacy

### Who Can Use the Bot?

**Direct Messages:**
- Only approved users (via pairing)
- Your user ID is already approved

**Group Chats/Channels:**
- Controlled by `groupAllowFrom` list
- Or `groupPolicy: "open"` for any member

### Pairing New Users

When someone else tries to message the bot:

1. They send a message
2. Bot creates a pairing request
3. You approve it:
   ```powershell
   openclaw pairing list msteams
   openclaw pairing approve msteams <code>
   ```

## 🚀 Pro Tips

### 1. Use Specific Commands
Instead of: "Help me"
Try: "Write a Python function to parse JSON files"

### 2. Provide Context
"I'm working on a React app. How do I handle form validation?"

### 3. Ask for Formats
"Give me the answer as a bullet list"
"Format this as a table"

### 4. Iterate
"Make it shorter"
"Add error handling"
"Explain that in simpler terms"

## 🐛 Troubleshooting

### Bot Not Responding?

1. **Check gateway is running:**
   ```powershell
   # Should see output in Terminal 6
   ```

2. **Check ngrok is running:**
   ```powershell
   # Should see output in Terminal 7
   # Or check: http://127.0.0.1:4040
   ```

3. **Check logs:**
   ```powershell
   Get-Content C:\Users\haita\AppData\Local\Temp\openclaw\openclaw-2026-03-04.log -Tail 50
   ```

### "Not Allowlisted" Error?

You need to approve the pairing request:
```powershell
openclaw pairing list msteams
openclaw pairing approve msteams <code>
```

### Bot Responds Slowly?

- Normal for complex requests (30-60 seconds)
- Check your model provider (GitHub Copilot) status
- Try a simpler request first

### ngrok Tunnel Expired?

Free ngrok tunnels expire after 2 hours:

1. Stop ngrok (Terminal 7)
2. Restart: `ngrok http 3978`
3. Update Azure Bot messaging endpoint with new URL
4. No need to restart gateway

## 📱 Mobile Usage

The bot works on Teams mobile apps too:
- iOS Teams app
- Android Teams app
- Same functionality as desktop

## 🔄 Keeping It Running

### For Development (Current Setup)

**Pros:**
- Easy to test and debug
- Can see logs in real-time

**Cons:**
- ngrok tunnel expires every 2 hours
- Gateway stops when you close terminal

### For Production (Future)

Consider:
1. **Permanent domain** instead of ngrok
2. **Run gateway as a service** (Windows Service or Docker)
3. **Add monitoring** and auto-restart
4. **Set up proper logging**

## 📚 Learn More

- **OpenClaw Docs**: https://docs.openclaw.ai/channels/msteams
- **Config Reference**: https://docs.openclaw.ai/gateway/configuration
- **Pairing Guide**: https://docs.openclaw.ai/gateway/pairing

## 🎯 Quick Reference

**Start Gateway:**
```powershell
openclaw gateway run --bind loopback --port 18789
```

**Start ngrok:**
```powershell
ngrok http 3978
```

**List Pairing Requests:**
```powershell
openclaw pairing list msteams
```

**Approve Pairing:**
```powershell
openclaw pairing approve msteams <code>
```

**Check Logs:**
```powershell
Get-Content C:\Users\haita\AppData\Local\Temp\openclaw\openclaw-2026-03-04.log -Tail 50
```

---

**Enjoy using OpenClaw in Teams!** 🦞

If you have questions, check the docs or ask the bot itself: "How do I use you in Teams?"
