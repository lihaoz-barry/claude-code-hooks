# ntfy.sh 通知配置说明

## ✅ 新功能

现在 Stop Hook 会自动发送通知到你的手机！

---

## 📱 新脚本特性

### `claude-stop-hook-with-ntfy.ps1`

**功能：**
1. ✅ 提取 Hook JSON 细节（项目名称、路径、时间等）
2. ✅ 发送 HTTP POST 到 `https://ntfy.sh/barry_claude_done`
3. ✅ 包含完整项目信息
4. ✅ 设置通知标题和标签
5. ✅ 保持原有窗口激活功能

---

## 📋 发送的通知内容

### HTTP 请求

```http
POST https://ntfy.sh/barry_claude_done
Title: Claude Code - {项目名称}
Priority: default
Tags: white_check_mark

Task completed!

Project: {项目名称}
Path: {完整路径}
Time: {完成时间}
```

### 手机收到的通知

```
标题: Claude Code - my-app
内容:
  Task completed!

  Project: my-app
  Path: C:\Projects\my-app
  Time: 2025-01-06 14:30:15
```

---

## 🚀 如何使用

### 步骤 1: 更新 Hook 配置

在 Claude Code 中：

```
/hooks
```

将 **Stop Hook** 改为：

```
powershell -ExecutionPolicy Bypass -File "C:\Users\Barry\Repos\Claude-hooks\claude-stop-hook-with-ntfy.ps1"
```

### 步骤 2: 测试

```powershell
# 启动 Claude Code
claude-start

# 执行一个简单任务
# 完成后检查：
# 1. 终端输出应该显示 "Notification sent successfully!"
# 2. 手机应该收到通知
```

---

## 🔍 脚本输出示例

```
=== Claude Code Hook (ntfy.sh) ===
Project: my-app
Path: C:\Projects\my-app
Path Hash: a1b2c3d4

[Notification] Sending to ntfy.sh...
  [+] Notification sent successfully!

[INFO] Using project-specific window info
  [+] Window is valid

Attempting to set window title to: [Claude-my-app]
  [+] Title set successfully!

[Desktop Notification] Showing balloon...
  [+] Desktop notification shown

=== Hook Complete ===
```

---

## 📊 通知流程

```
Claude Code 任务完成
    ↓
Hook 触发
    ↓
1. 发送 HTTP POST 到 ntfy.sh
    ↓
2. 你的手机收到通知 📱
    ↓
3. 显示桌面通知
    ↓
4. 激活终端窗口
    ↓
完成 ✅
```

---

## 🎨 自定义通知

### 修改通知 URL

在脚本第 85 行修改：

```powershell
# 当前
$ntfyUrl = "https://ntfy.sh/barry_claude_done"

# 改为自定义频道
$ntfyUrl = "https://ntfy.sh/your_custom_channel"
```

### 修改优先级

在脚本第 93 行修改：

```powershell
$headers = @{
    "Title" = $notifyTitle
    "Priority" = "urgent"      # default, low, high, urgent
    "Tags" = "white_check_mark,rocket"  # 多个 emoji 标签
}
```

### 修改通知内容

在脚本第 87-93 行修改：

```powershell
$notifyMessage = @"
✅ 任务完成！

项目：$projectName
路径：$($taskInfo.WorkingDir)
时间：$($taskInfo.Timestamp)
会话：$($taskInfo.SessionId)
"@
```

---

## 🔧 ntfy.sh 支持的功能

### Priority（优先级）

```
"Priority" = "min"       # 最低优先级
"Priority" = "low"       # 低优先级
"Priority" = "default"   # 默认（当前使用）
"Priority" = "high"      # 高优先级
"Priority" = "urgent"    # 紧急（会发出声音）
```

### Tags（标签）

```
"Tags" = "warning"                    # ⚠️
"Tags" = "white_check_mark"          # ✅
"Tags" = "rocket"                     # 🚀
"Tags" = "tada"                       # 🎉
"Tags" = "rotating_light"             # 🚨
"Tags" = "white_check_mark,rocket"   # 多个标签
```

### Actions（操作按钮）

```powershell
$headers = @{
    "Title" = $notifyTitle
    "Priority" = "default"
    "Tags" = "white_check_mark"
    "Actions" = "view, Open Terminal, https://..."
}
```

---

## ⚠️ 故障排查

### 1. 通知没有发送

检查终端输出：

```
[WARN] Failed to send notification: ...
```

**可能原因：**
- 网络连接问题
- ntfy.sh 服务不可用
- 防火墙阻止

**解决方法：**
```powershell
# 手动测试 ntfy.sh 连接
Invoke-RestMethod -Uri "https://ntfy.sh/barry_claude_done" -Method Post -Body "Test message"

# 检查是否收到手机通知
```

### 2. 手机没有收到通知

**检查：**
1. ntfy.sh App 是否订阅了 `barry_claude_done` 频道
2. App 通知权限是否开启
3. 手机网络连接是否正常

**测试：**
```bash
# 在手机浏览器或另一台电脑上执行
curl -d "Test notification" https://ntfy.sh/barry_claude_done
```

### 3. 脚本执行失败

**检查 Hook 配置：**

```powershell
# 完整路径必须正确
powershell -ExecutionPolicy Bypass -File "C:\Users\Barry\Repos\Claude-hooks\claude-stop-hook-with-ntfy.ps1"
```

**手动测试：**

```powershell
# 直接运行脚本
cd C:\Users\Barry\Repos\Claude-hooks
.\claude-stop-hook-with-ntfy.ps1
```

---

## 🆚 新旧对比

### 旧版本（`claude-stop-hook-window-activator.ps1`）

- ✅ 激活窗口
- ✅ 桌面通知
- ❌ 没有手机通知

### 新版本（`claude-stop-hook-with-ntfy.ps1`）

- ✅ 激活窗口
- ✅ 桌面通知
- ✅ 手机通知（ntfy.sh）
- ✅ 详细项目信息
- ✅ 可自定义通知内容

---

## 📝 JSON 数据示例

Hook 接收的 JSON 数据：

```json
{
  "cwd": "C:\\Projects\\my-app",
  "session_id": "abc-123-def",
  "hook_event_name": "Stop"
}
```

提取后的数据：

```powershell
$taskInfo = @{
    WorkingDir = "C:\Projects\my-app"
    SessionId = "abc-123-def"
    Timestamp = "2025-01-06 14:30:15"
    HookEvent = "Stop"
}

$projectName = "my-app"  # 从路径提取
$pathHash = "a1b2c3d4"   # MD5 哈希前8位
```

---

## 🎯 使用场景

### 场景 1: 长时间任务

启动一个需要5-10分钟的任务，然后：
- 离开电脑去泡咖啡 ☕
- 手机收到通知
- 回到电脑继续工作

### 场景 2: 多项目并行

同时运行多个项目的任务：
- 每个项目完成时都会发送独立通知
- 通知内容包含项目名称，容易区分

### 场景 3: 远程监控

在家办公时：
- 启动任务后可以离开书房
- 手机通知让你知道何时回来

---

## ✅ 总结

**配置步骤：**

1. 确保手机已安装 ntfy.sh App 并订阅 `barry_claude_done`
2. 更新 Claude Code Hook 配置指向新脚本
3. 运行 `claude-start` 测试

**效果：**

- ✅ 任务完成立即收到手机通知
- ✅ 包含完整项目信息
- ✅ 保留所有原有功能
- ✅ 支持多项目

**立即开始使用！** 🚀
