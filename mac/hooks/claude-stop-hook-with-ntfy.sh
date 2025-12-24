#!/bin/bash
# Claude Code Hook - Stop Hook with ntfy.sh notification for macOS
# Sends notification to phone + activates terminal window

# ====================================
# Configuration
# ====================================

# ntfy.sh topic - CHANGE THIS to your own topic!
NTFY_TOPIC="barry_claude_done"
NTFY_URL="https://ntfy.sh/${NTFY_TOPIC}"

# ====================================
# Read stdin JSON
# ====================================

STDIN_DATA=""
if [ ! -t 0 ]; then
    STDIN_DATA=$(cat)
fi

# Get working directory from JSON or use current directory
WORKING_DIR="$PWD"
SESSION_ID=""
HOOK_EVENT="Stop"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Parse JSON if we have jq, otherwise use basic extraction
if command -v jq &> /dev/null && [ -n "$STDIN_DATA" ]; then
    WORKING_DIR=$(echo "$STDIN_DATA" | jq -r '.cwd // empty' 2>/dev/null)
    [ -z "$WORKING_DIR" ] && WORKING_DIR="$PWD"
    SESSION_ID=$(echo "$STDIN_DATA" | jq -r '.session_id // empty' 2>/dev/null)
    HOOK_EVENT=$(echo "$STDIN_DATA" | jq -r '.hook_event_name // "Stop"' 2>/dev/null)
elif [ -n "$STDIN_DATA" ]; then
    # Basic extraction without jq
    if [[ "$STDIN_DATA" =~ \"cwd\":\"([^\"]+)\" ]]; then
        WORKING_DIR="${BASH_REMATCH[1]}"
    fi
fi

# Extract project name from working directory
PROJECT_NAME=$(basename "$WORKING_DIR")

echo "=== Claude Code Hook (ntfy.sh) - macOS ==="
echo "Project: $PROJECT_NAME"
echo "Path: $WORKING_DIR"
echo ""

# ====================================
# Send ntfy.sh notification
# ====================================

echo "[Notification] Sending to ntfy.sh..."

NOTIFY_TITLE="Claude Code - $PROJECT_NAME"
NOTIFY_MESSAGE="Task completed!

Project: $PROJECT_NAME
Path: $WORKING_DIR
Time: $TIMESTAMP"

# Send POST request to ntfy.sh
NTFY_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$NTFY_URL" \
    -H "Title: $NOTIFY_TITLE" \
    -H "Priority: default" \
    -H "Tags: white_check_mark" \
    -d "$NOTIFY_MESSAGE" 2>/dev/null)

if [ "$NTFY_RESPONSE" = "200" ]; then
    echo "  [+] Notification sent successfully!"
else
    echo "  [WARN] Failed to send notification (HTTP $NTFY_RESPONSE)"
    echo "  Continuing with hook execution..."
fi

# ====================================
# Show macOS Desktop Notification
# ====================================

echo ""
echo "[Desktop Notification] Showing notification..."

# Use osascript to display native macOS notification
# Note: The notification will appear in Notification Center
osascript -e "display notification \"Task completed in $PROJECT_NAME\" with title \"Claude Code\" subtitle \"$PROJECT_NAME\" sound name \"Glass\""

if [ $? -eq 0 ]; then
    echo "  [+] Desktop notification shown"
else
    echo "  [WARN] Failed to show desktop notification"
fi

echo ""
echo "=== Hook Complete ==="
