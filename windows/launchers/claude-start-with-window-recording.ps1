# 启动 Claude Code V2 - 带窗口信息记录
# 在启动前自动记录窗口信息，供 Hook 使用

param(
    [string]$ProjectPath = $PWD.Path,
    [string]$CustomTitle = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== Claude Code Launcher V2 ===" -ForegroundColor Cyan
Write-Host ""

# 切换到项目目录
if ($ProjectPath -ne $PWD.Path) {
    Write-Host "Changing directory to: $ProjectPath" -ForegroundColor Cyan
    Set-Location $ProjectPath
}

$projectName = Split-Path -Leaf $PWD.Path

# 确定标题
if ([string]::IsNullOrWhiteSpace($CustomTitle)) {
    $windowTitle = "[Claude-$projectName]"
} else {
    $windowTitle = "[Claude-$CustomTitle]"
}

# 设置窗口标题
$host.ui.RawUI.WindowTitle = $windowTitle

Write-Host "Project: $projectName" -ForegroundColor White
Write-Host "Path: $($PWD.Path)" -ForegroundColor Gray
Write-Host "Terminal Title: $windowTitle" -ForegroundColor Green
Write-Host ""

# 记录窗口信息
Write-Host "Recording window information..." -ForegroundColor Yellow

try {
    # 获取当前进程
    $currentPID = $PID

    # 获取父进程（Terminal）
    $parentPID = (Get-CimInstance Win32_Process -Filter "ProcessId = $currentPID").ParentProcessId
    $parentProcess = Get-Process -Id $parentPID

    # 如果父进程没有窗口句柄，尝试向上查找
    if ($parentProcess.MainWindowHandle -eq 0) {
        Write-Host "  [INFO] Parent process has no window, searching for terminal..." -ForegroundColor Yellow

        # 查找所有可能的终端进程
        $terminalCandidates = Get-Process | Where-Object {
            $_.MainWindowHandle -ne 0 -and
            ($_.ProcessName -eq "WindowsTerminal" -or
             $_.ProcessName -eq "powershell" -or
             $_.ProcessName -eq "pwsh" -or
             $_.ProcessName -eq "conhost")
        }

        # 尝试找到当前窗口（最近活动的）
        foreach ($candidate in $terminalCandidates) {
            # 简单启发式：使用最近创建的窗口
            if ($candidate.MainWindowHandle -ne 0) {
                $parentProcess = $candidate
                $parentPID = $candidate.Id
                Write-Host "  [+] Found terminal window: $($candidate.ProcessName) (PID: $parentPID)" -ForegroundColor Green
                break
            }
        }
    }

    # 生成项目路径的哈希（用于多项目支持）
    $pathHash = [System.BitConverter]::ToString(
        [System.Security.Cryptography.MD5]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($PWD.Path.ToLower())
        )
    ).Replace("-", "").Substring(0, 8)

    # 窗口信息
    $windowInfo = @{
        ProjectName = $projectName
        ProjectPath = $PWD.Path
        PathHash = $pathHash
        ProcessId = $parentPID
        ProcessName = $parentProcess.Name
        WindowHandle = $parentProcess.MainWindowHandle.ToInt64()
        WindowTitle = $parentProcess.MainWindowTitle
        RecordedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # 保存到项目专属文件（支持多项目）
    $infoFile = Join-Path $PSScriptRoot ".last-window-info-$pathHash.json"
    $windowInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $infoFile -Encoding UTF8

    # 同时保存到通用文件（向后兼容）
    $legacyFile = Join-Path $PSScriptRoot ".last-window-info.json"
    $windowInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $legacyFile -Encoding UTF8

    Write-Host "  [+] Window info saved" -ForegroundColor Green
    Write-Host "  Process: $($parentProcess.Name) (PID: $parentPID)" -ForegroundColor Gray
    Write-Host "  Window Handle: $($windowInfo.WindowHandle)" -ForegroundColor Gray

} catch {
    Write-Host "  [WARN] Failed to record window info: $_" -ForegroundColor Yellow
    Write-Host "  Hook may not be able to activate window" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Starting Claude Code..." -ForegroundColor Yellow
Write-Host ""

# 设置环境变量
$env:CLAUDE_TERMINAL_TITLE = $windowTitle
$env:CLAUDE_PROJECT_NAME = $projectName
$env:CLAUDE_PROJECT_PATH = $PWD.Path

# 启动 Claude Code (with dangerous mode skip)
claude --dangerously-skip-permissions
