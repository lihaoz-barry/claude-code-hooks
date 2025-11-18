# Claude Code Hook - Window Activator (Fixed Version)
# Activates the Claude Code window when task completes

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Windows API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsWindow(IntPtr hWnd);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SetWindowText(IntPtr hWnd, string text);
}
"@

# Read JSON from stdin
$stdinData = ""
if ([Console]::IsInputRedirected) {
    $stdinData = [Console]::In.ReadToEnd().Trim()
}

# Parse JSON
$taskInfo = @{
    WorkingDir = $PWD.Path
    SessionId = $null
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    HookEvent = "Stop"
}

if ($stdinData) {
    try {
        $parsed = $stdinData | ConvertFrom-Json
        if ($parsed.cwd) { $taskInfo.WorkingDir = $parsed.cwd }
        if ($parsed.session_id) { $taskInfo.SessionId = $parsed.session_id }
        if ($parsed.hook_event_name) { $taskInfo.HookEvent = $parsed.hook_event_name }
    } catch {}
}

$projectName = Split-Path -Leaf $taskInfo.WorkingDir

Write-Host "=== Claude Code Hook (Window Activator) ===" -ForegroundColor Cyan
Write-Host "Project: $projectName" -ForegroundColor White
Write-Host "Path: $($taskInfo.WorkingDir)" -ForegroundColor Gray

# Generate project path hash (for multi-project support)
$pathHash = [System.BitConverter]::ToString(
    [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($taskInfo.WorkingDir.ToLower())
    )
).Replace("-", "").Substring(0, 8)

Write-Host "Path Hash: $pathHash" -ForegroundColor Gray

# Activate Window Function
function Activate-Window {
    param([IntPtr]$Handle)

    if ($Handle -eq [IntPtr]::Zero) {
        return $false
    }

    Write-Host "`nActivating window..." -ForegroundColor Cyan

    if ([WinAPI]::IsIconic($Handle)) {
        [void][WinAPI]::ShowWindowAsync($Handle, 9)  # SW_RESTORE
        Start-Sleep -Milliseconds 100
    }
    [void][WinAPI]::ShowWindowAsync($Handle, 5)  # SW_SHOW
    Start-Sleep -Milliseconds 50
    [void][WinAPI]::SetForegroundWindow($Handle)
    Write-Host "  [+] Window activated" -ForegroundColor Green
    return $true
}

# Read saved window info (project-specific file preferred)
$infoFile = Join-Path $PSScriptRoot ".last-window-info-$pathHash.json"
if (-not (Test-Path $infoFile)) {
    # Fallback to generic file (backward compatibility)
    Write-Host "[INFO] Project-specific file not found, using legacy file" -ForegroundColor Yellow
    $infoFile = Join-Path $PSScriptRoot ".last-window-info.json"
} else {
    Write-Host "[INFO] Using project-specific window info" -ForegroundColor Green
}

$windowInfo = $null
$hwnd = [IntPtr]::Zero

if (Test-Path $infoFile) {
    try {
        $windowInfo = Get-Content $infoFile -Raw | ConvertFrom-Json
        $hwnd = [IntPtr]$windowInfo.WindowHandle

        Write-Host "`n[Method 1] Using recorded window info:" -ForegroundColor Cyan
        Write-Host "  Project: $($windowInfo.ProjectName)" -ForegroundColor Gray
        Write-Host "  Window Handle: $($windowInfo.WindowHandle)" -ForegroundColor Gray
        Write-Host "  Recorded at: $($windowInfo.RecordedAt)" -ForegroundColor Gray

        # Verify window still exists
        if ([WinAPI]::IsWindow($hwnd)) {
            Write-Host "  [+] Window is valid" -ForegroundColor Green

            # Try to auto-set window title
            $newTitle = "[Claude-$projectName]"
            Write-Host "`nAttempting to set window title to: $newTitle" -ForegroundColor Yellow

            $result = [WinAPI]::SetWindowText($hwnd, $newTitle)
            if ($result -ne 0) {
                Write-Host "  [+] Title set successfully!" -ForegroundColor Green
            } else {
                Write-Host "  [WARN] Could not set title (not critical)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [WARN] Recorded window is no longer valid" -ForegroundColor Yellow
            $hwnd = [IntPtr]::Zero
        }
    } catch {
        Write-Host "`n[WARN] Failed to use recorded window info: $_" -ForegroundColor Yellow
    }
}

# If no recorded window, try to auto-find
if ($hwnd -eq [IntPtr]::Zero) {
    Write-Host "`n[Method 2] Auto-searching for window..." -ForegroundColor Cyan

    # Find windows containing project name or Claude
    $processes = Get-Process | Where-Object { $_.MainWindowHandle -ne 0 }

    # Strategy 1: Contains [Claude-ProjectName]
    $titlePattern = "\[Claude-$projectName\]"
    $found = $processes | Where-Object { $_.MainWindowTitle -match $titlePattern } | Select-Object -First 1

    if (-not $found) {
        # Strategy 2: Contains Claude
        $found = $processes | Where-Object { $_.MainWindowTitle -match "Claude" } | Select-Object -First 1
    }

    if (-not $found) {
        # Strategy 3: Any Terminal
        $found = $processes | Where-Object { $_.Name -match "pwsh|powershell|WindowsTerminal|cmd" } | Select-Object -First 1
    }

    if ($found) {
        $hwnd = $found.MainWindowHandle
        Write-Host "  [+] Found window: $($found.ProcessName) - $($found.MainWindowTitle)" -ForegroundColor Green

        # Try to set title
        $newTitle = "[Claude-$projectName]"
        $result = [WinAPI]::SetWindowText($hwnd, $newTitle)
        if ($result -ne 0) {
            Write-Host "  [+] Title set to: $newTitle" -ForegroundColor Green
        }
    } else {
        Write-Host "  [WARN] Could not find suitable window" -ForegroundColor Yellow
    }
}

# Build notification
$statusEmoji = switch ($taskInfo.HookEvent) {
    "Stop" { "Task Complete" }
    "Start" { "Task Started" }
    "Error" { "Task Error" }
    default { "Task Event" }
}

$message = @"
Project: $projectName

Path: $($taskInfo.WorkingDir)

Time: $($taskInfo.Timestamp)

Click to return to terminal
"@

$title = "Claude Code - $statusEmoji"

# Show notification
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.Visible = $true
$clicked = $false

$null = $notify.add_BalloonTipClicked({
    $script:clicked = $true
})

Start-Sleep -Milliseconds 500
$notify.ShowBalloonTip(10000, $title, $message, [System.Windows.Forms.ToolTipIcon]::Info)
Write-Host "`n[+] Notification displayed" -ForegroundColor Green

# Wait for user click (max 12 seconds)
$deadline = (Get-Date).AddSeconds(12)
while ((Get-Date) -lt $deadline -and -not $clicked) {
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}

if ($clicked) {
    Write-Host "`n[Event] User clicked notification" -ForegroundColor Magenta

    if ($hwnd -ne [IntPtr]::Zero) {
        Activate-Window -Handle $hwnd
    } else {
        Write-Host "  [WARN] No valid window to activate" -ForegroundColor Yellow
    }
} else {
    Write-Host "`nNotification timeout (no click)" -ForegroundColor Gray
}

$notify.Visible = $false
$notify.Dispose()

Write-Host "`nDone`n" -ForegroundColor Green
exit 0
