# Claude Code Hooks

Cross-platform automation hooks and launchers for Claude Code - get notifications, auto-focus when tasks complete, and quickly launch Claude from any project folder.

## Overview

This project provides hook scripts and launcher utilities that integrate with Claude Code to:
- Send desktop notifications when tasks complete
- Send push notifications to your phone via ntfy.sh
- Automatically activate your terminal window
- Support multiple Claude Code sessions simultaneously
- **Quick-launch Claude from any project folder** with portable launcher scripts

## Platform Support

| Platform | Hooks | Launchers | Status |
|----------|-------|-----------|--------|
| **Windows** | ✅ Full support | ✅ Full support | Production ready |
| **macOS** | 🚧 Planned | ✅ Full support | Launchers ready |
| **Linux** | 🚧 Planned | 🚧 Planned | Coming soon |

## Features

### Windows

**Hooks (Task Completion Notifications):**

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

**Launchers (Quick Start):**
- `claude-start.cmd` - Fast startup with proper configuration
- `claude-here.bat` - **Portable launcher** - drop into any project folder, double-click to launch Claude

### macOS

**Launchers (Quick Start):**
- `claude-here.command` - **Portable launcher** - drop into any project folder, double-click to launch Claude with `--dangerously-skip-permissions` mode

## Quick Start (Windows)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/lihaoz-barry/claude-code-hooks.git
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

Or use the portable launcher - copy `claude-here.bat` to any project folder and double-click it.

Or manually:
```powershell
# Set terminal title
$host.ui.RawUI.WindowTitle = "[Claude-ProjectName]"

# Start Claude Code
claude
```

## Quick Start (macOS)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/lihaoz-barry/claude-code-hooks.git
```

2. Copy `mac/launchers/claude-here.command` to any project folder

3. Make it executable (if needed):
```bash
chmod +x claude-here.command
```

4. Double-click the file to launch Claude Code in that directory

### How it works
- The `.command` file is double-clickable in Finder
- Automatically detects the project directory
- **Sets terminal title to `[Claude-ProjectName]`** for easy identification
- Launches Claude Code with `--dangerously-skip-permissions` flag
- Shows a banner with project name and directory
- Works with both Terminal.app and iTerm2

## Project Structure

```
claude-code-hooks/
├── docs/                                      # Documentation
│   ├── QUICK-START.md                         # Quick reference guide
│   ├── COMPLETE-SETUP-INSTRUCTIONS.md         # Detailed setup guide
│   └── ntfy通知配置说明.md                     # ntfy.sh config (Chinese)
│
├── windows/                                   # Windows platform
│   ├── hooks/                                 # Task completion hooks
│   │   ├── cc-hook-fixed-title.ps1            # Desktop notification hook
│   │   ├── claude-stop-hook-with-ntfy.ps1     # Desktop + mobile push hook
│   │   └── claude-stop-hook-window-activator.ps1
│   └── launchers/                             # Quick start scripts
│       ├── claude-here.bat                    # Portable launcher (drop & run)
│       ├── claude-start.cmd                   # Quick start script
│       ├── start-claude.ps1                   # PowerShell launcher
│       └── claude-start-with-window-recording.ps1
│
├── mac/                                       # macOS platform
│   └── launchers/                             # Quick start scripts
│       └── claude-here.command                # Portable launcher (drop & run)
│
├── linux/                                     # Linux platform (coming soon)
│
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

- [docs/QUICK-START.md](docs/QUICK-START.md) - Quick reference guide
- [docs/COMPLETE-SETUP-INSTRUCTIONS.md](docs/COMPLETE-SETUP-INSTRUCTIONS.md) - Detailed setup instructions
- [docs/ntfy通知配置说明.md](docs/ntfy通知配置说明.md) - ntfy.sh configuration (Chinese)

## Roadmap

- [x] **Windows implementation**
  - [x] Desktop notifications
  - [x] Mobile push notifications (ntfy.sh)
  - [x] Auto window activation
  - [x] Multi-project support
  - [x] Portable launcher (`claude-here.bat`)
- [ ] **macOS implementation**
  - [x] Portable launcher (`claude-here.command`)
  - [ ] Desktop notifications
  - [ ] Mobile push notifications
  - [ ] Window activation hooks
- [ ] **Linux implementation**
  - [ ] Desktop notifications (libnotify)
  - [ ] Mobile push notifications
  - [ ] Window activation
  - [ ] Portable launcher

## Requirements

### Windows
- Windows 10/11
- PowerShell 5.1+
- Claude Code CLI installed
- Optional: ntfy mobile app for push notifications

### macOS
- macOS 10.15+ (Catalina or later)
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)

## Contributing

Contributions are welcome! Especially for Linux and macOS implementations.

## License

MIT License - Feel free to use and modify for personal and commercial purposes.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Ready to start?**
- **Windows users:** Check out the [Windows Quick Start](#quick-start-windows) guide above
- **macOS users:** Check out the [macOS Quick Start](#quick-start-macos) guide above
