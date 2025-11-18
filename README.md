# Claude Code Hooks

Cross-platform automation hooks for Claude Code - get notifications and auto-focus when tasks complete.

## Overview

This project provides hook scripts that integrate with Claude Code to:
- Send desktop notifications when tasks complete
- Send push notifications to your phone via ntfy.sh
- Automatically activate your terminal window
- Support multiple Claude Code sessions simultaneously

## Platform Support

### Currently Supported
- **Windows** ✅ - Full support with two hook implementations

### Coming Soon
- **Linux** 🚧 - Planned
- **macOS** 🚧 - Planned

## Features

### Windows Implementation

**Two hook modes available:**

1. **Desktop Notification Hook** (`cc-hook-fixed-title.ps1`)
   - Local Windows notifications
   - One-click window activation
   - Multi-project support via terminal title matching
   - Recommended for most users

2. **Mobile Push Hook** (`claude-stop-hook-with-ntfy.ps1`)
   - Everything from Desktop Notification Hook
   - Push notifications to your phone via ntfy.sh
   - Remote monitoring of task completion
   - Perfect for long-running tasks

**Quick launcher:**
- `claude-start.cmd` - Fast startup with proper configuration

## Quick Start (Windows)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/claude-code-hooks.git
cd claude-code-hooks/windows
```

2. Choose your hook mode:

**Option A: Desktop Notifications Only**
```powershell
# Configure in Claude Code
/hooks
# Stop Hook: powershell -ExecutionPolicy Bypass -File "C:\path\to\claude-code-hooks\windows\hooks\cc-hook-fixed-title.ps1"
```

**Option B: Desktop + Mobile Push Notifications**
```powershell
# Configure ntfy.sh topic (edit the hook file)
# Then configure in Claude Code
/hooks
# Stop Hook: powershell -ExecutionPolicy Bypass -File "C:\path\to\claude-code-hooks\windows\hooks\claude-stop-hook-with-ntfy.ps1"
```

3. Set your terminal title:
```powershell
$host.ui.RawUI.WindowTitle = "[Claude-YourProjectName]"
```

4. Test it:
```
replay test hook
```

### Daily Usage

Use the launcher script for automatic setup:
```cmd
C:\path\to\claude-code-hooks\windows\launchers\claude-start.cmd
```

Or manually:
```powershell
# Set terminal title
$host.ui.RawUI.WindowTitle = "[Claude-ProjectName]"

# Start Claude Code
claude
```

## Project Structure

```
claude-code-hooks/
├── windows/
│   ├── hooks/
│   │   ├── cc-hook-fixed-title.ps1           # Desktop notification hook
│   │   └── claude-stop-hook-with-ntfy.ps1    # Desktop + mobile push hook
│   ├── launchers/
│   │   ├── claude-start.cmd                  # Quick start script
│   │   ├── start-claude.ps1                  # PowerShell launcher
│   │   └── claude-start-with-window-recording.ps1
│   └── docs/
│       ├── QUICK-START.md
│       ├── COMPLETE-SETUP-INSTRUCTIONS.md
│       └── ntfy通知配置说明.md
├── linux/                                     # Coming soon
├── macos/                                     # Coming soon
└── README.md
```

## Configuration

### ntfy.sh Mobile Notifications (Optional)

To enable mobile push notifications:

1. Install ntfy app on your phone ([iOS](https://apps.apple.com/app/ntfy/id1625396347) / [Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy))

2. Edit `windows/hooks/claude-stop-hook-with-ntfy.ps1`:
```powershell
# Line 88: Change to your topic
$ntfyUrl = "https://ntfy.sh/YOUR_UNIQUE_TOPIC_NAME"
```

3. Subscribe to the same topic in your ntfy app

See `docs/ntfy通知配置说明.md` for detailed instructions (Chinese).

## How It Works

1. You set a standardized terminal title: `[Claude-ProjectName]`
2. Claude Code executes your tasks
3. When task completes, hook script triggers
4. Script shows notification and/or sends to phone
5. Click notification → terminal activates automatically

**Multi-project support:** Each project uses a unique terminal title, allowing the hook to activate the correct window.

## Documentation

- `docs/QUICK-START.md` - Quick reference guide
- `docs/COMPLETE-SETUP-INSTRUCTIONS.md` - Detailed setup instructions
- `docs/ntfy通知配置说明.md` - ntfy.sh configuration (Chinese)

## Roadmap

- [x] Windows implementation
  - [x] Desktop notifications
  - [x] Mobile push notifications
  - [x] Auto window activation
  - [x] Multi-project support
- [ ] Linux implementation
  - [ ] Desktop notifications (libnotify)
  - [ ] Mobile push notifications
  - [ ] Window activation
- [ ] macOS implementation
  - [ ] Desktop notifications
  - [ ] Mobile push notifications
  - [ ] Window activation

## Requirements

### Windows
- Windows 10/11
- PowerShell 5.1+
- Claude Code
- Optional: ntfy mobile app for push notifications

## Contributing

Contributions are welcome! Especially for Linux and macOS implementations.

## License

MIT License - Feel free to use and modify for personal and commercial purposes.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Ready to start? Check out the Windows quick start guide above!**
