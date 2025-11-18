# 启动 Claude Code 并设置固定标题

param(
    [string]$ProjectPath = $PWD.Path,
    [string]$CustomTitle = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 如果指定了项目路径，切换到该目录
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

Write-Host "=== Claude Code Launcher ===" -ForegroundColor Cyan
Write-Host "Project: $projectName" -ForegroundColor White
Write-Host "Path: $($PWD.Path)" -ForegroundColor Gray
Write-Host "Terminal Title: $windowTitle" -ForegroundColor Green
Write-Host ""
Write-Host "Starting Claude Code..." -ForegroundColor Yellow
Write-Host ""

# 设置环境变量
$env:CLAUDE_TERMINAL_TITLE = $windowTitle
$env:CLAUDE_PROJECT_NAME = $projectName
$env:CLAUDE_PROJECT_PATH = $PWD.Path

# 启动 Claude Code
claude
