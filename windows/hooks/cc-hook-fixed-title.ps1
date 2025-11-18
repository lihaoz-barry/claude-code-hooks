# Claude Code Hook - 固定标题版本
# 通过固定的窗口标题格式找到对应的 Terminal 窗口

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class WinAPI {
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
}
"@

# 从 stdin 读取
$stdinData = ""
if ([Console]::IsInputRedirected) {
    $stdinData = [Console]::In.ReadToEnd().Trim()
}

# 解析 JSON
$taskInfo = @{
    WorkingDir = $PWD.Path
    SessionId = $null
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

if ($stdinData) {
    try {
        $parsed = $stdinData | ConvertFrom-Json
        if ($parsed.cwd) { $taskInfo.WorkingDir = $parsed.cwd }
        if ($parsed.session_id) { $taskInfo.SessionId = $parsed.session_id }
    } catch {}
}

$projectName = Split-Path -Leaf $taskInfo.WorkingDir

Write-Host "=== Claude Code Hook (Fixed Title) ===" -ForegroundColor Cyan
Write-Host "Project: $projectName" -ForegroundColor White
Write-Host "Path: $($taskInfo.WorkingDir)" -ForegroundColor Gray

# 查找窗口 - 使用固定标题格式
function Find-ClaudeWindow {
    param([string]$ProjectName)

    $processes = Get-Process | Where-Object { $_.MainWindowHandle -ne 0 }

    Write-Host "`nSearching for window..." -ForegroundColor Cyan

    # 策略 1: 固定标题格式 [Claude-ProjectName]
    Write-Host "[Strategy 1] Fixed title format [Claude-$ProjectName]..." -ForegroundColor Yellow
    $titlePattern = "\[Claude-$ProjectName\]"

    foreach ($proc in $processes) {
        if ($proc.MainWindowTitle -match $titlePattern) {
            Write-Host "  [MATCH] $($proc.ProcessName): $($proc.MainWindowTitle)" -ForegroundColor Green
            return $proc
        }
    }
    Write-Host "  [NO MATCH]" -ForegroundColor DarkGray

    # 策略 2: 任何包含 [Claude-...] 的标题
    Write-Host "[Strategy 2] Any [Claude-*] title..." -ForegroundColor Yellow
    foreach ($proc in $processes) {
        if ($proc.MainWindowTitle -match "\[Claude-.*\]") {
            Write-Host "  [MATCH] $($proc.ProcessName): $($proc.MainWindowTitle)" -ForegroundColor Green
            return $proc
        }
    }
    Write-Host "  [NO MATCH]" -ForegroundColor DarkGray

    # 策略 3: 包含项目名的窗口
    Write-Host "[Strategy 3] Window containing project name..." -ForegroundColor Yellow
    foreach ($proc in $processes) {
        if ($proc.MainWindowTitle -match [regex]::Escape($ProjectName)) {
            Write-Host "  [MATCH] $($proc.ProcessName): $($proc.MainWindowTitle)" -ForegroundColor Green
            return $proc
        }
    }
    Write-Host "  [NO MATCH]" -ForegroundColor DarkGray

    # 策略 4: Claude 应用
    Write-Host "[Strategy 4] Claude application..." -ForegroundColor Yellow
    $proc = Get-Process -Name "claude" -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($proc) {
        Write-Host "  [MATCH] $($proc.MainWindowTitle)" -ForegroundColor Green
        return $proc
    }
    Write-Host "  [NO MATCH]" -ForegroundColor DarkGray

    # 策略 5: 任何 Terminal
    Write-Host "[Strategy 5] Any terminal (fallback)..." -ForegroundColor Yellow
    $terminals = @("WindowsTerminal", "pwsh", "powershell", "cmd")
    foreach ($name in $terminals) {
        $proc = Get-Process -Name $name -ErrorAction SilentlyContinue |
                Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
        if ($proc) {
            Write-Host "  [FALLBACK] $($proc.MainWindowTitle)" -ForegroundColor Yellow
            return $proc
        }
    }

    Write-Host "[FAILED] No suitable window found" -ForegroundColor Red
    return $null
}

# 激活窗口
function Activate-Window {
    param($Process)
    if (-not $Process) {
        Write-Host "No window to activate" -ForegroundColor Red
        return
    }

    Write-Host "`nActivating: $($Process.MainWindowTitle)" -ForegroundColor Green

    $hwnd = $Process.MainWindowHandle
    if ([WinAPI]::IsIconic($hwnd)) {
        [void][WinAPI]::ShowWindowAsync($hwnd, 9)
        Start-Sleep -Milliseconds 100
    }
    [void][WinAPI]::ShowWindowAsync($hwnd, 5)
    Start-Sleep -Milliseconds 50
    [void][WinAPI]::SetForegroundWindow($hwnd)
    Write-Host "[+] Window activated" -ForegroundColor Green
}

# 构建通知
$message = "[Project] $projectName`n[Path] $($taskInfo.WorkingDir)`n[Time] $($taskInfo.Timestamp)`n`nClick to return to terminal"
$title = "Claude Code - Task Complete"

# 显示通知
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.Visible = $true
$clicked = $false

$null = $notify.add_BalloonTipClicked({ $script:clicked = $true })

Start-Sleep -Milliseconds 500
$notify.ShowBalloonTip(10000, $title, $message, [System.Windows.Forms.ToolTipIcon]::Info)
Write-Host "[+] Notification displayed" -ForegroundColor Green

# 等待用户点击
$deadline = (Get-Date).AddSeconds(12)
while ((Get-Date) -lt $deadline -and -not $clicked) {
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}

if ($clicked) {
    Write-Host "`n[Event] User clicked notification" -ForegroundColor Magenta
    $window = Find-ClaudeWindow -ProjectName $projectName
    Activate-Window -Process $window
} else {
    Write-Host "`nNotification timeout" -ForegroundColor Gray
}

$notify.Visible = $false
$notify.Dispose()

Write-Host "`nDone`n" -ForegroundColor Green
exit 0
