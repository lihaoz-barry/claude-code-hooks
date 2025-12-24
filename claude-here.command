#!/bin/bash
# Claude Code Portable Launcher for macOS
# Place this file in any project folder and double-click it
# It will automatically detect the current directory and launch claude with dangerous mode

# Get the directory where this script is located
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Extract project name from directory
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Change to the project directory
cd "$PROJECT_DIR"

# Set terminal title using AppleScript (more reliable than escape codes)
# This properly sets both window and tab title in Terminal.app
osascript -e "tell application \"Terminal\" to set custom title of front window to \"Claude: ${PROJECT_NAME}\"" 2>/dev/null &

# Also try escape codes for iTerm2 compatibility
echo -ne "\033]0;Claude: ${PROJECT_NAME}\007"
echo -ne "\033]1;Claude: ${PROJECT_NAME}\007"

# For iTerm2 specifically, use proprietary escape sequence
echo -ne "\033]1337;SetUserVar=currentProject=$(echo -n "$PROJECT_NAME" | base64)\007"

# Clear screen and show banner
clear
echo ""
echo "========================================"
echo "   Claude Code - Quick Launch (macOS)"
echo "========================================"
echo ""
echo "Project: $PROJECT_NAME"
echo "Directory: $PROJECT_DIR"
echo "Terminal Title: Claude: ${PROJECT_NAME}"
echo ""

# Check if claude is installed
if ! command -v claude &> /dev/null; then
    echo "[!] Error: claude command not found"
    echo "    Please install Claude Code first:"
    echo "    npm install -g @anthropic-ai/claude-code"
    echo ""
    echo "Press any key to exit..."
    read -n 1 -s
    exit 1
fi

echo "[+] Launching Claude Code with dangerously-skip-permissions..."
echo ""

# Launch claude with dangerous mode
exec claude --dangerously-skip-permissions
