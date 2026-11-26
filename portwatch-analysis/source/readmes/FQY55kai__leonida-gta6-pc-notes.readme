# leonida-gta6-pc-notes

把 Xbox Series X|S 版《Grand Theft Auto VI》通过**静态重编译 / PE 手动映射**的方式在 Windows PC 上跑起来 —— 本仓库记录 Leonida 工程的进展、调试证据与可复用参考资料。

> 工作方式：无人值守、反复验证、逐个修根因（**Fix, don't disable**）。
> **仓库内不含任何游戏文件、着色器资产（DXBC / FSSM / SPIR-V）、运行日志原文或用户数据**，只包含工程代码、结论与可复现的调试脚本。

---

## 背景

Xbox Series 版的 `game_scarlett_master.exe` 是 **x86-64 原生代码**。方案不是改写 CPU 指令，而是：

1. 由宿主进程**手动映射**游戏的 PE 映像（基址 `0x140000000`）；
2. 把 GDK、XMem、`d3d12_xs`、DirectStorage 等系统软件导入**替换为 shim**；
3. 把游戏内存布局在 PC 与 Xbox 之间**逐段对齐 ABI 差异**（结构返回约定、vtable slot 语义、IID 变体、对象状态机）。

因此启动过程本质是**逐段补 shim、逐段对齐 ABI**，而不是"配置一下就能跑"。

## 目录

| 路径 | 内容 |
|---|---|
| `docs/Leonida_进度报告_2026-11-24.md` | **主文档**：总流程与当前状态、按时间线的工作记录、每一处根因与修法 |
| `docs/game_scarlett_master_反编译分析.md` | 游戏 EXE 的静态分析：PE 结构、导入表、TLS、`.pdata` 函数边界、关键字符串 / IID / desc 常量定位、启动路径伪代码 |
| `reference/` | PE 静态解析原始产物（节区、导入、TLS、function ranges） |
| `reference/xbox_d3d12_device_vtable.md` | **Xbox ↔ PC D3D12 device vtable slot 对照表**（160 槽），来自对游戏 EXE 的实测 + 公开同类项目交叉验证 |
| `scripts/` | PE 静态解析脚本（Python）与本轮调试用的 cdb 命令脚本 |

## 当前进展

启动链路逐段状态（细节见进度报告）：

```
PE 映射 → 导入绑定 → 静态 TLS → CRT/GDK 运行时 → DirectStorage/XMem
      → GAME: 卷路径 → D3D12 设备创建 → 命令队列/围栏/命令分配器/命令列表
      → 设备能力与帧调度 → 资源与描述符 → 着色器管线 → 渲染
```

* ✅ PE 手动映射、导入绑定、静态 TLS / magic-static 根治、CRT 初始化、GDK 运行时、DirectStorage、XMem 物理页、`G:` 盘符映射、D3D12 设备与子对象代理
* ✅ 26,503 / 26,503 着色器翻译通过、1,680 语义测试全过、shader library corpus 0 failures
* ⚠️ 真实启动仍在设备初始化阶段以 `__debugbreak()` 断言结束（`exit 3`，非段错误），根因逐个定位中

## 与 `Marvisak/VIctory` 的交叉验证

[VIctory](https://github.com/Marvisak/VIctory)（Rust，GPL-3.0-or-later）是同目标的另一实现，进度更远（能进世界、跑第一个任务）。
本工程用它的**公开事实数据**交叉验证了自己的动态调试结论：

* 三个 Xbox 变体 IID 完全一致 —— command allocator `6102DEE4-AF59-4B09-B999-B44D73F09B24`、graphics command list `C3827890-4024-474C-98CF-645B51DC4874`、command signature `C36A797C-EC80-4F0A-8985-A7B2475082D1`
* device vtable 的 slot 语义一致（9 / 15 / 26 / 36 / 41 / 48 / 73 …）
* 关键差异：VIctory **自建完整 160 槽 Xbox device vtable** 自己实现每个方法；本工程是"包装 PC 设备 + 按序号转发 + 逐个特例"，这正是 slot 错位问题的来源

> 常量 / IID / slot 语义属于**接口事实**（同类项目之间可相互印证），非逐字复制源码。
> 两边均为 **GPL-3.0**，本仓库沿用 GPL-3.0。

## 许可

GPL-3.0-or-later（与 Leonida、VIctory 一致）。
