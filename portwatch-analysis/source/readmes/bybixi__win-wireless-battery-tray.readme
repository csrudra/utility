# Win Wireless Battery Tray（Windows 无线外设电量托盘）

一款**零第三方依赖**的 Windows 10/11 任务栏无线外设电量提示工具，仅使用 Python 标准库 + `ctypes`（Win32 API）+ `tkinter` 实现。

图标与弹出面板深度对齐 Windows 11 原生系统风格（复刻系统「鼠标设置」空心鼠标、耳机、手柄轮廓与 Win11 24H2/25H2 任务栏电池配色），默认使用 **「智能」单图标模式**，仅占 1 格任务栏：有设备充电且电量 `≤ 80%` 时优先显示充电设备，超过 `80%` 或无充电时自动显示电量最低的在线设备，悬停一次看全全部设备。

## 特性

- **零第三方依赖**：无需 `hidapi`、`Pillow`、`pystray`、`pywin32`，安装官方 Python 3 即可直接运行。
- **原生 Win11 视觉风格**：
  - 纯矢量超采样光栅化 + 预乘 Alpha `HICON`，Per-Monitor V2 DPI 自适应，自动跟随任务栏深浅色主题。
  - **三种托盘显示模式**：
    - **`智能`（默认，单图标）**：最优先展示正在充电且电量 `≤ 80%` 的设备；充电电量超过 `80%` 后自动切回电量最低的在线设备；悬停 tooltip 一次列出全部三台设备电量（当前展示的设备标 `▶`，充电设备带 `⚡`）。
    - **`仅最低`（单图标）**：始终显示当前电量最低的在线设备。
    - **`全部`（多图标）**：三台设备各占 1 格任务栏。
  - **4 种图标样式**：`图标+%`（上方设备轮廓 + 下方百分比）、`蓝牙条`（蓝牙耳机风格：左设备轮廓 + 右竖向电池条）、`电池+%`、`纯数字`。
  - **Win11 蓝牙设备风格三卡片面板**：右键托盘图标即刻弹出，展示各设备连接状态、大号百分比、分段变色进度条（≥60 绿 / 30–59 黄 / <30 红）与全部设置。
- **极低资源占用**：基于 Win32 `SetTimer` 事件驱动（默认 60 秒，可调 30 秒 ~ 30 分钟），空闲时 CPU 占用接近 0，后台线程并行读取，界面不卡顿，不写任何日志文件。
- **规范开机自启**：纯 `ctypes` COM 在「启动」文件夹创建 `.lnk` 快捷方式（`pythonw.exe` 无黑窗），直接在 **任务管理器 → 启动应用** 可见与管理，面板开关只读真实状态。
- **内置完整 HID 调试器**：支持枚举所有 HID 接口、转储/探测 Feature Report ID、试发雷蛇协议命令并将标定参数保存至 `config.json`。

## 支持设备与协议

| 设备 | 接入方式 | VID:PID / 通道 | 说明 |
|---|---|---|---|
| **雷蛇毒蝰 V2 Pro** (`Razer Viper V2 Pro`) | 2.4G / USB 有线 | `1532:00A6` / `1532:00A5` (`MI_00`) | 90 字节 Feature Report（Report ID `0x00`，`tid=0x1F`，电量 `07/80`，充电 `07/84`），支持调试页标定其他同协议雷蛇鼠标 |
| **漫步者 G3 无线耳机** (`HECATE G3 无线版`) | 2.4G / USB 有线 | `35BB:A220` (`mi_03&col03`, `0xD0`) / `35BB:A21F` (`col02`, `0xE0`) | 64 字节 HID 报文（`D0/E0 35 BB 01 00`），返回连接状态、精确电量、充电状态与固件版本 |
| **Xbox Elite 2 手柄** | 蓝牙 LE / Xbox 无线适配器 / USB | `DEVPKEY_Bluetooth_Battery` / `xinput1_4.dll` | 蓝牙模式读取精确 `0–100%`；无线适配器模式通过 XInput 读取 4 档硬件电量（极低/偏低/中等/满电），支持 USB 有线充电检测 |

## 快速开始

### 方式一：直接下载 EXE（免装 Python）

前往 [Releases](https://github.com/bybixi/win-wireless-battery-tray/releases) 下载 `WirelessBatteryTray.exe`：
- 直接双击即可无黑窗运行在任务栏托盘；
- 右键托盘图标打开面板即可一键开启「开机自启」（配置文件 `config.json` 保存在同级目录）。

### 方式二：Python 源码运行

#### 环境要求

- Windows 10 / 11（64 位）
- Python 3.10+（仅标准库，无需 `pip install`）

#### 安装开机自启并启动

```powershell
# 1. 创建开机自启快捷方式与桌面入口
python razer_battery.py --install

# 2. 无黑窗启动托盘（或直接双击 启动电量托盘.pyw）
pythonw razer_battery.py
```

> **Windows 11 任务栏固定提示**：首次启动后，新图标可能位于任务栏右下角的 `^`（显示隐藏的图标）中，将其拖到系统电池图标旁边即可常驻显示。

### 托盘交互

- **左键点击**：立即刷新全部设备电量
- **右键点击**：打开 / 前置三卡片设置面板
- **鼠标悬停**：查看全部三台设备实时电量与更新时间

### 命令行选项

```powershell
python  razer_battery.py --once       # 命令行打印一次三台设备电量并退出
pythonw razer_battery.py --panel      # 直接打开三卡片弹出面板
python  razer_battery.py --debug-ui   # 打开完整 HID 调试与标定工具
python  razer_battery.py --scan       # 扫描已知外设 HID 接口并试读电量
python  razer_battery.py --install    # 配置开机自启（启动文件夹 .lnk）与桌面链接
python  razer_battery.py --uninstall  # 移除开机自启与桌面链接
python  razer_battery.py --debug      # 配合任意模式在控制台输出调试日志（不写文件）
```

## 工程实现细节

- **HID 并发安全**：漫步者 G3 无线通道严格使用独立的 `FILE_FLAG_OVERLAPPED` 读/写句柄 + 事件超时 + `CancelIoEx`，避免在同一 HID 句柄上并发阻塞读写导致进程异常终止；跨进程读写使用命名互斥锁隔离。
- **系统独占 HID 集合**：雷蛇接收器鼠标顶层集合采用 `dwDesiredAccess=0` 打开，仍可稳定收发 90 字节 Feature Report。
- **无僵尸进程退出**：托盘窗口在 `WM_DESTROY` 中销毁全部 `HICON`、移除所有托盘图标、停止定时器并调用 `PostQuitMessage(0)`，彻底释放单实例锁。
- **Tkinter 线程安全**：后台读取线程只通过 `queue.Queue` 向主线程投递结果，由主线程 `after(100, pump)` 消费刷新 UI。

## 开源协议

本项目基于 [MIT License](LICENSE) 开源。
