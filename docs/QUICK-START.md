# 🚀 快速开始指南

## 立即配置（5分钟）

### 步骤 1: 选择你的脚本

根据你的使用方式，选择一个脚本：

| 如果你... | 使用脚本 | 特点 |
|----------|---------|------|
| **在 Terminal 运行 Claude** | `cc-hook-smart.ps1` | ⭐推荐：智能记忆 |
| 使用 Claude 独立应用 | `cc-hook-improved.ps1` | 7个策略 |
| 需要手动控制 | `cc-hook-terminal.ps1` | 简单直接 |

### 步骤 2: 在 Claude Code 中配置

在 Claude Code 中运行：
```
/hooks
```

选择 **Stop Hook**，输入：

**推荐配置（智能记忆版本）：**
```bash
powershell -ExecutionPolicy Bypass -File "C:\Users\Barry\Repos\Claude-hooks\cc-hook-smart.ps1"
```

### 步骤 3: 设置窗口标题（可选但强烈推荐）

在你运行 Claude Code 的 CMD/PowerShell 窗口中：

**CMD:**
```cmd
title ✳ 窗口识别和切换机制 - Claude-hooks
```

**PowerShell:**
```powershell
$host.ui.RawUI.WindowTitle = "✳ 窗口识别和切换机制 - Claude-hooks"
```

### 步骤 4: 测试

1. 让我执行一个简单任务（比如 `replay test`）
2. 等待通知弹出
3. **点击通知**
4. 观察窗口是否正确激活

---

## 🔧 配置详解

### 智能记忆脚本的工作原理

```
第一次使用:
  → 尝试匹配项目路径/名称
  → 如果失败，使用当前活动窗口
  → 保存窗口信息到 .last-window-memory.json

第二次及以后:
  → 直接读取记忆文件
  → 检查窗口是否还存在（通过 HWND）
  → 如果存在，直接激活 ✅
  → 如果不存在，重新查找并更新记忆
```

### 记忆文件位置

```
C:\Users\Barry\Repos\Claude-hooks\.last-window-memory.json
```

**内容示例：**
```json
{
  "ProjectPath": "C:\\Users\\Barry\\Repos\\Claude-hooks",
  "ProcessName": "cmd",
  "WindowTitle": "✳ 窗口识别和切换机制",
  "WindowHandle": 1707308,
  "Timestamp": "2025-11-05T00:45:00"
}
```

---

## 🧪 测试工具

### 1. 查看所有窗口

```powershell
.\find-my-window.ps1
```

**输出：**
- 所有 Claude 窗口
- 所有 Terminal 窗口
- 包含项目名的窗口

### 2. 测试智能记忆脚本

```powershell
.\test-stdin.ps1 -HookType stop
```

或直接测试：
```powershell
.\test-improved.ps1
```

### 3. 检查记忆文件

```powershell
Get-Content .last-window-memory.json | ConvertFrom-Json | Format-List
```

---

## 🎯 常见使用场景

### 场景 1: 你在 CMD 中运行 Claude Code

**配置：**
```bash
# 1. 设置 CMD 标题
title ✳ Claude-hooks

# 2. 启动 Claude Code
claude

# 3. 配置 Hook (在 Claude Code 中)
/hooks
powershell -ExecutionPolicy Bypass -File "cc-hook-smart.ps1"
```

**工作流程：**
1. Claude 执行任务
2. 完成后通知弹出
3. 点击通知
4. CMD 窗口被激活

---

### 场景 2: 你在 PowerShell 中运行

**配置：**
```powershell
# 1. 设置标题
$host.ui.RawUI.WindowTitle = "Claude - $PWD"

# 2. 启动 Claude Code
claude

# 3. 配置 Hook
/hooks
powershell -ExecutionPolicy Bypass -File "cc-hook-smart.ps1"
```

---

### 场景 3: 你使用 Windows Terminal

**配置：**

在 Windows Terminal 的 `settings.json` 中：
```json
{
  "profiles": {
    "defaults": {
      "tabTitle": "${PWD}"
    }
  }
}
```

然后配置 Hook：
```bash
powershell -ExecutionPolicy Bypass -File "cc-hook-smart.ps1"
```

---

## 🔍 调试

### 如果通知不显示

1. 检查 Windows 通知设置
2. 确保 PowerShell 有通知权限
3. 运行测试脚本确认：
   ```powershell
   .\test-stdin.ps1 -HookType stop
   ```

### 如果激活了错误的窗口

1. 查看控制台输出，了解匹配过程
2. 删除记忆文件重新开始：
   ```powershell
   Remove-Item .last-window-memory.json
   ```
3. 设置窗口标题包含项目名：
   ```cmd
   title ✳ Your-Title - Claude-hooks
   ```

### 如果找不到窗口

1. 运行 `find-my-window.ps1` 查看所有窗口
2. 确认你的窗口在列表中
3. 检查窗口标题是否包含可识别信息

---

## 📊 脚本选择流程图

```
你在哪里运行 Claude Code?
    │
    ├─ Terminal (CMD/PowerShell)
    │   │
    │   └─→ cc-hook-smart.ps1 (推荐)
    │       或 cc-hook-terminal.ps1
    │
    ├─ Claude 独立应用
    │   │
    │   └─→ cc-hook-improved.ps1
    │
    └─ VS Code 扩展
        │
        └─→ cc-hook-improved.ps1
```

---

## 💡 专业技巧

### 1. 自动设置标题（PowerShell）

在 PowerShell Profile 中添加：
```powershell
# 编辑 Profile
notepad $PROFILE

# 添加这些代码
function prompt {
    $projectName = Split-Path -Leaf $PWD
    $host.ui.RawUI.WindowTitle = "PS - $projectName"
    "PS $($PWD)> "
}
```

### 2. 创建快捷启动脚本

创建 `start-claude-hooks.cmd`：
```cmd
@echo off
cd /d C:\Users\Barry\Repos\Claude-hooks
title ✳ Claude Code - Claude-hooks
powershell -NoExit -Command "& {claude}"
```

### 3. 批量管理多个项目

创建 `project-launcher.ps1`：
```powershell
param([string]$Project)

$projects = @{
    "hooks" = "C:\Users\Barry\Repos\Claude-hooks"
    "bot" = "C:\Users\Barry\Repos\church-bot"
}

if ($projects.ContainsKey($Project)) {
    $path = $projects[$Project]
    Set-Location $path
    $projectName = Split-Path -Leaf $path
    $host.ui.RawUI.WindowTitle = "Claude - $projectName"
    claude
}
```

使用：
```powershell
.\project-launcher.ps1 -Project hooks
```

---

## ✅ 检查清单

配置完成后，确认以下几点：

- [ ] Hook 已在 Claude Code 中配置
- [ ] 窗口标题包含项目名（推荐）
- [ ] 测试脚本运行成功
- [ ] 通知可以正常显示
- [ ] 点击通知能激活正确的窗口
- [ ] 记忆文件已创建（智能版本）

---

## 🎓 高级配置

### 配置多个项目

为每个项目使用不同的窗口标题：

**项目 1:**
```cmd
cd C:\Users\Barry\Repos\Claude-hooks
title ✳ Claude - Hooks Project
claude
```

**项目 2:**
```cmd
cd C:\Users\Barry\Repos\church-bot
title ✳ Claude - Church Bot
claude
```

智能记忆脚本会自动记住每个项目的窗口。

### 使用环境变量

设置环境变量来配置脚本：
```powershell
$env:CLAUDE_WINDOW_TITLE = "✳ Claude - Custom Project"
```

### 日志记录

修改脚本添加日志：
```powershell
# 在脚本开头添加
$logFile = Join-Path $PSScriptRoot "hook.log"
function Write-Log {
    param([string]$Message)
    Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}
```

---

## 🆘 故障排除

### 问题 1: "找不到 PowerShell 脚本"

**解决：**
```powershell
# 检查文件是否存在
Test-Path "C:\Users\Barry\Repos\Claude-hooks\cc-hook-smart.ps1"

# 使用完整路径
powershell -ExecutionPolicy Bypass -File "C:\Users\Barry\Repos\Claude-hooks\cc-hook-smart.ps1"
```

### 问题 2: "脚本无法运行（执行策略）"

**解决：**
```powershell
# 检查当前策略
Get-ExecutionPolicy

# 设置为 RemoteSigned
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 问题 3: "总是激活错误的窗口"

**解决：**
```powershell
# 删除记忆文件
Remove-Item .last-window-memory.json -Force

# 设置正确的窗口标题
title ✳ Your-Window - Claude-hooks

# 重新运行测试
.\test-stdin.ps1 -HookType stop
```

---

## 📚 相关文档

- `SOLUTION-COMPARISON.md` - 方案详细对比
- `WINDOW-MATCHING-EXPLAINED.md` - 窗口匹配机制
- `LOGIC-EXPLAINED.md` - 整体逻辑说明
- `FINAL-SETUP-GUIDE.md` - 完整配置指南

---

## 🎉 完成！

现在你应该已经成功配置了 Claude Code Hook！

**下一步：**
1. 在 Claude Code 中运行一个测试任务
2. 观察通知弹出
3. 点击通知看窗口是否正确激活
4. 检查 `.last-window-memory.json` 文件

有任何问题，运行调试脚本：
```powershell
.\find-my-window.ps1
.\test-stdin.ps1 -HookType stop
```
