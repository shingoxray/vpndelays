# VPNDelays

macOS 菜单栏工具 — 实时监控多个 VPN 端点不同隧道的网络延迟。

![macOS](https://img.shields.io/badge/macOS-12.0+-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.7+-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

## 功能

- **菜单栏实时状态** — 彩色方块图标（绿/橙/红/灰）一目了然整体网络状况
- **多端点 + 多隧道** — 支持添加多个 VPN 端点，每个端点下可配置多条隧道
- **自动 Ping 检测** — 定期 Ping 每条隧道，显示通断、延迟（ms）和丢包率（%）
- **可调延迟阈值** — 每个端点可独立设置绿/红延迟阈值，橙色自动取中间值
- **倒计时显示** — 距离下次检测的秒数实时倒计时
- **端点级颜色指示** — 每个端点前有彩色圆点，基于内部隧道状态自动着色
- **隧道名称预设** — 预设常用隧道名称（Tailscale、ZeroTier、NetBird 等），方便快速输入
- **快捷退出** — 右键菜单栏图标 → 退出程序

## 截图

```
菜单栏: [■]  ← 彩色方块
         ↓ 点击
┌──────────────────────────────┐
│  ● VPNDelays           3s ⚙️ │
├──────────────────────────────┤
│  ▼ ● AWS Tokyo     2/3 在线  │
│    ● Tailscale  23ms  0%    │
│    ● ZeroTier   N/A  100%   │
│    ● NetBird    12ms  0%    │
│  ▶ ● DigitalOcean 3/3 在线  │
│                              │
│  + 添加端点               ↻  │
└──────────────────────────────┘
```

## 颜色含义

| 层级 | 灰色 | 红色 | 橙色 | 绿色 |
|------|------|------|------|------|
| **隧道** | 未检测 | 超时 / ≥红色阈值 / 有丢包 | 绿色~红色阈值之间 | <绿色阈值 且 0% 丢包 |
| **端点** | 未检测 | 全部隧道红色 | 有橙色隧道，无绿色 | 有绿色隧道 |
| **菜单栏/全局** | 从未检测 | 有端点红色 | 有端点橙色，无红色 | 全部绿色 |

> 默认阈值：绿色 < 50ms，红色 ≥ 150ms。每个端点可在编辑时独立调整。

## 安装

### 前提条件

- macOS 12.0+
- Xcode 14+

### 编译运行

```bash
# 克隆仓库
git clone https://github.com/your-username/vpndelays.git
cd vpndelays

# 生成 Xcode 项目（如果还没有）
python3 generate_xcode_project.py

# 编译
xcodebuild -project VPNDelays.xcodeproj -scheme VPNDelays -configuration Debug build

# 运行
open VPNDelays.xcodeproj  # 在 Xcode 中打开后按 ⌘R
```

> 也可以直接用 Xcode 打开 `VPNDelays.xcodeproj` → Build & Run。

## 使用

1. 启动后程序仅出现在**菜单栏**（Dock 中不可见）
2. 点击菜单栏图标 → 弹出面板
3. 点击 **+ 添加端点** → 填写端点名称、隧道和延迟阈值
4. 隧道名称可从预设下拉列表中选择，也可手动输入
5. 每个端点可独立设置绿/红延迟阈值：绿色 < X ms，红色 ≥ Y ms
6. 点击 **⚙️** → 设置全局 Ping 参数和隧道名称预设
7. 右键菜单栏图标 → **退出 VPNDelays**

## 技术架构

```
┌─────────────────────────────────────┐
│  VPNDelaysApp.swift  (@main)        │
│  ┌───────────────────────────────┐  │
│  │  AppDelegate                  │  │
│  │  ├─ NSStatusItem (菜单栏图标)  │  │
│  │  └─ NSPopover (弹出面板)       │  │
│  ├───────────────────────────────┤  │
│  │  DataStore (UserDefaults 持久化)│  │
│  │  PingManager (Ping调度+解析)    │  │
│  ├───────────────────────────────┤  │
│  │  Views                        │  │
│  │  ├─ PopoverContentView        │  │
│  │  ├─ EndpointRowView           │  │
│  │  ├─ TunnelRowView             │  │
│  │  ├─ AddEndpointView           │  │
│  │  └─ SettingsView              │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

- **语言**: Swift + SwiftUI + AppKit
- **数据持久化**: UserDefaults (JSON encoding)
- **网络检测**: `/sbin/ping` 进程调用
- **项目**: 14 个 Swift 源文件，约 1,150 行代码

## 配置

通过设置窗口（⚙️）可调整：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| 每次发包数 | 2 | 每次 Ping 发送的 ICMP 包数 |
| 检测间隔 | 5 秒 | 每轮检测的间隔时间 |
| 隧道名称预设 | Tailscale, ZeroTier, ... | 快速输入用预设列表 |

每个端点独立配置（添加/编辑端点时设置）：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| 绿色阈值 | < 50ms | 延迟低于此值 → 绿色 |
| 红色阈值 | ≥ 150ms | 延迟达到或超过此值 → 红色 |
| 橙色区间 | 50 ~ 149ms | 自动取绿色和红色之间 |

## License

MIT
