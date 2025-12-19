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

# Set terminal title to include project name (format: [Claude-ProjectName])
# This works for Terminal.app and iTerm2
echo -ne "\033]0;[Claude-${PROJECT_NAME}]\007"

# For iTerm2, also set tab title
echo -ne "\033]1;[Claude-${PROJECT_NAME}]\007"

# Clear screen and show banner
clear
echo ""
echo "========================================"
echo "   Claude Code - Quick Launch (macOS)"
echo "========================================"
echo ""
echo "Project: $PROJECT_NAME"
echo "Directory: $PROJECT_DIR"
echo "Terminal Title: [Claude-${PROJECT_NAME}]"
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
