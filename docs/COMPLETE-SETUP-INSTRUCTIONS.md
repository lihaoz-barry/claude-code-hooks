# 🎯 完整配置指令 - 固定标题窗口匹配

## 📋 你现在需要做的（按顺序）

---

## 第一步：设置当前 Terminal 标题（30秒）

**在你的 PowerShell/CMD 窗口中运行：**

### PowerShell:
```powershell
$host.ui.RawUI.WindowTitle = "[Claude-Claude-hooks]"
```

### CMD:
```cmd
title [Claude-Claude-hooks]
```

**验证标题是否设置成功：**
- 查看窗口标题栏，应该显示 `[Claude-Claude-hooks]`

---

## 第二步：配置 Hook（2分钟）

**在 Claude Code 中运行：**

```
/hooks
```

**选择 Stop Hook，输入以下命令：**

```bash
powershell -ExecutionPolicy Bypass -File "C:\Users\Barry\Repos\Claude-hooks\cc-hook-fixed-title.ps1"
```

**确认路径正确：**
- 确保文件 `cc-hook-fixed-title.ps1` 存在于 `Claude-hooks` 文件夹
- 路径必须是完整的绝对路径

---

## 第三步：测试（1分钟）

**配置完成后，在 Claude Code 中说：**

```
replay 测试固定标题 hook
```

**或者说：**

```
测试 hook
```

**观察结果：**
1. ✅ 通知应该弹出
2. ✅ 点击通知
3. ✅ 当前 Terminal 窗口应该被激活（回到前台）

---

## 🔄 每次使用 Claude Code 时

### 方式 1: 使用启动脚本（推荐）⭐

```powershell
# 在项目目录中运行
.\start-claude.ps1
```

这会：
- 自动设置标题为 `[Claude-项目名]`
- 启动 Claude Code

### 方式 2: 手动设置标题

```powershell
# 1. 设置标题
$host.ui.RawUI.WindowTitle = "[Claude-Claude-hooks]"

# 2. 启动 Claude
claude
```

---

## 📊 完整命令清单

### 当前会话（立即执行）

```powershell
# 1. 设置标题
$host.ui.RawUI.WindowTitle = "[Claude-Claude-hooks]"

# 2. 验证标题
Write-Host "Current title: $($host.ui.RawUI.WindowTitle)" -ForegroundColor Green
```

### 在 Claude Code 中配置

```
/hooks
```

选择 **Stop Hook**，输入：
```
powershell -ExecutionPolicy Bypass -File "C:\Users\Barry\Repos\Claude-hooks\cc-hook-fixed-title.ps1"
```

### 测试

在 Claude Code 中说：
```
replay 测试 hook 功能
```

---

## 🎨 标题格式说明

### 当前项目
```
标题: [Claude-Claude-hooks]
匹配: 精确匹配当前项目
```

### 其他项目
```
项目 A: [Claude-church-bot]
项目 B: [Claude-my-app]
项目 C: [Claude-test-project]
```

### 自定义会话名
```powershell
$host.ui.RawUI.WindowTitle = "[Claude-我的自定义会话]"
```

---

## 🔍 验证配置

### 检查标题是否正确
```powershell
$host.ui.RawUI.WindowTitle
# 应该输出: [Claude-Claude-hooks]
```

### 检查 Hook 脚本是否存在
```powershell
Test-Path "C:\Users\Barry\Repos\Claude-hooks\cc-hook-fixed-title.ps1"
# 应该输出: True
```

### 查看所有 Claude 会话
```powershell
Get-Process | Where-Object {
    $_.MainWindowHandle -ne 0 -and
    $_.MainWindowTitle -match "\[Claude-"
} | Select-Object ProcessName, MainWindowTitle
```

---

## ⚡ 快捷方式（可选）

### 创建桌面快捷方式

**右键桌面 → 新建 → 快捷方式**

**目标：**
```
powershell.exe -NoExit -Command "cd 'C:\Users\Barry\Repos\Claude-hooks'; $host.ui.RawUI.WindowTitle = '[Claude-Claude-hooks]'; claude"
```

**名称：**
```
Claude Code - Claude-hooks
```

双击快捷方式即可自动：
1. 切换到项目目录
2. 设置标题
3. 启动 Claude Code

---

## 📝 配置文件（可选）

### PowerShell Profile

编辑：
```powershell
notepad $PROFILE
```

添加：
```powershell
function Start-ClaudeHooks {
    cd C:\Users\Barry\Repos\Claude-hooks
    $host.ui.RawUI.WindowTitle = "[Claude-Claude-hooks]"
    claude
}

Set-Alias -Name cch -Value Start-ClaudeHooks
```

使用：
```powershell
cch  # 启动 Claude-hooks 项目
```

---

## 🆘 故障排除

### 问题 1: 标题设置后看不到

**解决：**
- 查看窗口标题栏（最上方）
- 在 PowerShell 中运行：`$host.ui.RawUI.WindowTitle`
- 确认输出是否正确

### 问题 2: Hook 没有触发

**检查：**
```powershell
# 1. 检查脚本存在
Test-Path "C:\Users\Barry\Repos\Claude-hooks\cc-hook-fixed-title.ps1"

# 2. 手动运行测试
.\test-stdin.ps1 -HookType stop
```

### 问题 3: 通知显示但窗口不激活

**可能原因：**
- 标题格式不匹配
- 窗口标题不包含 `[Claude-Claude-hooks]`

**验证：**
```powershell
# 检查当前标题
$host.ui.RawUI.WindowTitle

# 应该是: [Claude-Claude-hooks]
# 不是: Claude-hooks 或其他格式
```

---

## ✅ 完成检查清单

配置完成后，确认：

- [ ] Terminal 标题已设置为 `[Claude-Claude-hooks]`
- [ ] 在 Claude Code 中配置了 Stop Hook
- [ ] Hook 命令路径正确
- [ ] 测试运行成功
- [ ] 通知可以弹出
- [ ] 点击通知能激活 Terminal 窗口

---

## 🎉 完整流程总结

### 一次性配置
```powershell
# 1. 设置标题（在 Terminal）
$host.ui.RawUI.WindowTitle = "[Claude-Claude-hooks]"

# 2. 配置 Hook（在 Claude Code）
/hooks
# Stop Hook: powershell -ExecutionPolicy Bypass -File "cc-hook-fixed-title.ps1"

# 3. 测试
replay 测试 hook
```

### 日常使用
```powershell
# 每次启动 Claude Code 前设置标题
$host.ui.RawUI.WindowTitle = "[Claude-Claude-hooks]"
claude

# 或使用启动脚本
.\start-claude.ps1
```

---

## 📚 相关文件

- `cc-hook-fixed-title.ps1` - Hook 主脚本
- `start-claude.ps1` - 启动脚本
- `set-terminal-title.ps1` - 标题设置工具
- `FIXED-TITLE-SETUP.md` - 详细配置指南

---

## 🚀 现在就开始

### 立即执行（复制粘贴）：

**在你的 PowerShell 窗口：**
```powershell
$host.ui.RawUI.WindowTitle = "[Claude-Claude-hooks]"
Write-Host "✅ 标题已设置！" -ForegroundColor Green
```

**在 Claude Code：**
```
/hooks
```

然后输入：
```
powershell -ExecutionPolicy Bypass -File "C:\Users\Barry\Repos\Claude-hooks\cc-hook-fixed-title.ps1"
```

**测试：**
```
replay 测试 hook
```

---

准备好了吗？告诉我配置完成，我会立即执行一个测试任务！🎯
