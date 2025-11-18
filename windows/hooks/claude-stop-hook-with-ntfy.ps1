# Claude Code Hook - Stop Hook with ntfy.sh notification
# 发送通知到手机 + 激活窗口

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

# 从 stdin 读取 JSON
$stdinData = ""
if ([Console]::IsInputRedirected) {
    $stdinData = [Console]::In.ReadToEnd().Trim()
}

# 解析 JSON
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

Write-Host "=== Claude Code Hook (ntfy.sh) ===" -ForegroundColor Cyan
Write-Host "Project: $projectName" -ForegroundColor White
Write-Host "Path: $($taskInfo.WorkingDir)" -ForegroundColor Gray

# 生成项目路径的哈希（用于多项目支持）
$pathHash = [System.BitConverter]::ToString(
    [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($taskInfo.WorkingDir.ToLower())
    )
).Replace("-", "").Substring(0, 8)

Write-Host "Path Hash: $pathHash" -ForegroundColor Gray

# ====================================
# 发送 ntfy.sh 通知
# ====================================

Write-Host "`n[Notification] Sending to ntfy.sh..." -ForegroundColor Yellow

try {
    # 准备通知内容
    $notifyTitle = "Claude Code - $projectName"
    $notifyMessage = @"
Task completed!

Project: $projectName
Path: $($taskInfo.WorkingDir)
Time: $($taskInfo.Timestamp)
"@

    # ntfy.sh API endpoint
    $ntfyUrl = "https://ntfy.sh/barry_claude_done"

    # 发送 POST 请求
    $headers = @{
        "Title" = $notifyTitle
        "Priority" = "default"
        "Tags" = "white_check_mark"
    }

    $response = Invoke-RestMethod -Uri $ntfyUrl -Method Post -Body $notifyMessage -Headers $headers -ContentType "text/plain; charset=utf-8"

    Write-Host "  [+] Notification sent successfully!" -ForegroundColor Green

} catch {
    Write-Host "  [WARN] Failed to send notification: $_" -ForegroundColor Yellow
    Write-Host "  Continuing with hook execution..." -ForegroundColor Gray
}

# ====================================
# 读取保存的窗口信息（优先使用项目专属文件）
# ====================================

$infoFile = Join-Path $PSScriptRoot ".last-window-info-$pathHash.json"
if (-not (Test-Path $infoFile)) {
    # 降级到通用文件（向后兼容）
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

        # 验证窗口是否仍然存在
        if ([WinAPI]::IsWindow($hwnd)) {
            Write-Host "  [+] Window is valid" -ForegroundColor Green

            # 尝试自动设置窗口标题
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

# 如果没有记录的窗口，尝试自动查找
if ($hwnd -eq [IntPtr]::Zero) {
    Write-Host "`n[Method 2] Auto-searching for window..." -ForegroundColor Cyan

    $processes = Get-Process | Where-Object {
        $_.MainWindowHandle -ne 0 -and
        $_.Id -ne $PID
    }

    $titlePattern = "\[Claude-$projectName\]"
    $found = $processes | Where-Object { $_.MainWindowTitle -match $titlePattern } | Select-Object -First 1

    if ($found) {
        Write-Host "  [+] Found window: $($found.MainWindowTitle)" -ForegroundColor Green
        $hwnd = $found.MainWindowHandle
    } else {
        Write-Host "  [-] No matching window found" -ForegroundColor Yellow
        Write-Host "  Expected title pattern: $titlePattern" -ForegroundColor Gray
    }
}

# ====================================
# 显示桌面通知 + 激活窗口
# ====================================

Write-Host "`n[Desktop Notification] Showing balloon..." -ForegroundColor Yellow

$statusEmoji = "Done"
$message = @"
Project: $projectName

Path: $($taskInfo.WorkingDir)

Time: $($taskInfo.Timestamp)
"@

$title = "Claude Code - $statusEmoji"

$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.Visible = $true
$clicked = $false

# Simple event handler using add_ method
$null = $notify.add_BalloonTipClicked({
    $script:clicked = $true
})

Start-Sleep -Milliseconds 500
$notify.ShowBalloonTip(10000, $title, $message, [System.Windows.Forms.ToolTipIcon]::Info)

Write-Host "  [+] Desktop notification shown" -ForegroundColor Green

# Wait for user click (max 12 seconds)
$deadline = (Get-Date).AddSeconds(12)
while ((Get-Date) -lt $deadline -and -not $clicked) {
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}

if ($clicked) {
    Write-Host "`n[Click] User clicked notification" -ForegroundColor Cyan

    if ($hwnd -ne [IntPtr]::Zero) {
        Write-Host "  Activating window..." -ForegroundColor Yellow

        # If window is minimized, restore it
        if ([WinAPI]::IsIconic($hwnd)) {
            [void][WinAPI]::ShowWindowAsync($hwnd, 9)  # SW_RESTORE
            Start-Sleep -Milliseconds 100
        }

        # Activate window
        $activateResult = [WinAPI]::SetForegroundWindow($hwnd)
        if ($activateResult) {
            Write-Host "  [+] Window activated" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Failed to activate window" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [WARN] No valid window to activate" -ForegroundColor Yellow
    }
} else {
    Write-Host "`nNotification timeout (no click)" -ForegroundColor Gray
}

$notify.Visible = $false
$notify.Dispose()

Write-Host "`n=== Hook Complete ===" -ForegroundColor Green
