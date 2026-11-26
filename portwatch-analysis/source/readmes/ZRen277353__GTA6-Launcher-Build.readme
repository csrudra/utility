# GTA6启动器编译 / GTA6 Launcher Builds

[Run a build / 运行编译](../../actions/workflows/build.yml) · [Releases / 下载](../../releases) · [PortWatch VI](https://portwatch-vi.xyz/)

A workflow-only repository for building the latest public upstream Windows x64 launchers. It contains **only this README and two GitHub Actions workflows**: no launcher implementation, game files, console SDKs or keys. Upstream runtime sources are not patched.

本项目只有 **README 和两个工作流文件**，用于从上游最新公开源码编译 Windows x64 启动器。不存放启动器实现、游戏文件、主机 SDK 或密钥，也不修改上游运行时代码。

## Projects / 编译列表

| Upstream / 原仓库 | Notes / 说明 |
| --- | --- |
| [avatarmanz/VIctory-7900XTX](https://github.com/avatarmanz/VIctory-7900XTX) | Added from PortWatch's public race; uses the exact source's official fast launch preset. AMD tuning; 64 GB RAM recommended upstream. / 新增榜单项目，提取官方性能启动预设，主要针对AMD。 |
| [DexNom/VIctory](https://github.com/DexNom/VIctory) | Added from PortWatch's public race; verifies format tables, builds all three executables. Default BAT uses the README no-RT path. / 新增榜单项目，含三个程序及格式表校验，默认关闭光追。 |
| [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD) | AMD-oriented fork / 面向AMD的分支 |
| [uiliannn/VItoriaBr](https://github.com/uiliannn/VItoriaBr) | VIctory variant / VIctory分支 |
| [fxceless/victory-fork](https://github.com/fxceless/victory-fork) | Documented run-279 runtime settings plus the measured run-293 lookup cache / 已测性能预设及查找缓存 |
| [Marvisak/VIctory](https://github.com/Marvisak/VIctory) | Original VIctory / 原项目 |
| [xcl-dev/xcl](https://github.com/xcl-dev/xcl) | XCL, with checksum-verified DXC and Agility runtime files / 附校验过的微软运行库 |
| [Zettrox/ztrx](https://github.com/Zettrox/ztrx) | Kept in the selector; HTTP 404 is reported explicitly, without preventing other builds / 保留选项，404会明确记录并跳过 |

The public, active main-race repositories in the PortWatch data checked on **2026-11-26** are covered. Private builds and projects without downloadable public code cannot be compiled here. The list is deliberately reviewed rather than executing arbitrary repositories added by a website; future additions require updating both workflow allowlists.

已覆盖 **2026年11月26日** 检查时 PortWatch 主榜中可用的公开代码项目。私有版本和未开放源码的版本无法编译。名单经过审核，网站未来出现新项目时需更新两个工作流中的允许列表。

## Fork and build / Fork后自行编译

1. **Fork this repository** into your own GitHub account. / 点击本仓库右上角 **Fork**，复制到自己的账号。
2. Open **Actions** in your Fork and enable workflows if prompted. / 在Fork中进入 **Actions**，如有提示则启用工作流。
3. Choose **Build launchers / 编译启动器**, then **Run workflow**. / 选择编译工作流，点击 **Run workflow**。
4. Select **all** for one combined batch, or a single upstream. Choose the CPU target, then start. / 选择全部或单个项目，选择CPU指令集后开始。
5. Wait for the selected builds and the final **Publish one combined Release / 统一发布** job. Open **Releases** in your own Fork and download the desired ZIP. / 等待编译和统一发布完成，到自己Fork的 **Releases** 下载所需ZIP。

The upstream default-branch HEAD is resolved at build time and checked out by its exact full SHA. The upstream Rust toolchain and Cargo.lock are respected. Upstream changes do not trigger automatic builds: manually run again whenever you want an update.

每个项目在构建时解析上游默认分支HEAD，并按完整SHA精确检出，使用上游指定的Rust工具链及Cargo.lock。想更新时再次手动触发即可，上游更新不会自动消耗编译额度。

Build jobs have `contents: read`; only the final publisher has `contents: write`. Account or organization Actions policies must permit these workflows. No personal token or additional secret is required in a normal Fork.

编译任务只有读取仓库权限，统一发布任务才有写入Release权限。普通Fork无需添加个人令牌或额外Secret；账号或组织需允许Actions及工作流写权限。

## Compiler optimization / 编译优化

Every successful package uses **Release, opt-level=3, fat LTO, codegen-units=1, static MSVC CRT**, with incremental compilation and the diagnostics feature disabled. Line-table debug information is retained for crash analysis. The actual Rust version, flags and profile are saved in `BUILD-INFO.json`, project metadata and the unified manifest.

所有项目使用 **Release、最高常规优化等级3、fat LTO、单代码生成单元和静态CRT**，关闭增量编译和diagnostics特性，保留便于定位崩溃的行号调试信息。实际参数和Rust版本记录在构建信息及清单中。

- **x86-64-v3 (default):** optimized for modern CPUs with AVX2, FMA, BMI/BMI2 and related v3 instructions. / 默认适合支持这些指令的现代Intel/AMD处理器。
- **x86-64:** the CPU compatibility option for older machines. / 旧CPU使用兼容选项。

The build never uses `target-cpu=native` on a GitHub runner: that would target the runner's CPU rather than yours. Compiler optimization cannot guarantee better FPS in every scene or fix unimplemented rendering, GPU synchronization bugs or upstream crashes. These packages are not gameplay-benchmarked and do **not** promise stable 30 FPS.

不会把GitHub编译机的CPU当作你的CPU使用。编译优化不保证每个场景都更快，也无法自动修复未实现的渲染、GPU同步问题或全部崩溃；本项目不承诺稳定30帧。

## One Release, 404 fallback and version comparison / 统一发布、404兜底和版本对比

**One workflow run produces one Release after all selected projects have a verified result.** Successful projects provide ZIPs; an upstream repository/commit HTTP 404 provides an explicit **“project 404, cannot download source, cannot compile”** record. A 404 project does not block other projects and never reuses an older binary. Other failures, including compiler errors, rate limits, permissions and broken dependency downloads, still fail the batch and prevent publication.

**每次运行只统一发布一个Release。** 所有选择项目都有确定结果后才发布：成功项目提供ZIP，上游仓库或提交404则写明 **“项目404，无法下载源码，无法编译”**，不会阻塞其他项目，也不会混入旧程序。真实编译错误、权限、限流和依赖下载错误仍使整批失败，不会被当成404隐藏。

Even if every selected project is 404, one status-only Release is published, with no executable and no invented compile time. Interrupted builds or missing/corrupt artifacts never count as 404.

全部项目均404时发布一个仅含状态的Release，不附EXE，不伪造编译完成时间。中断任务或缺失、损坏的产物不会冒充404。

The Release title shows the compile completion time in **Beijing time (UTC+08:00)**. The source-version table shows each original repository, **this run's 12-character Git SHA**, the **last published all-project batch's 12-character SHA**, changed/unchanged/new/404 status, and compile time. Commit links and comparisons open the exact full SHAs. A more recent single-project release is not mistaken for the previous all-project batch. Legacy multi-project manifests are recognized.

Release标题显示 **北京时间UTC+08:00的编译完成时间**。表格对比原仓库、本次Git短版本、上次全项目统一构建的Git短版本、变化状态及编译时间。页面仅显示 **12位** 提交号，点击可查看完整提交或差异；较新的单项目构建不会覆盖上次全项目构建基准，旧版多项目清单也能识别。

Full SHAs remain in `BUILD-MANIFEST.json` and uniquely named per-project metadata, including unavailable status and previous version. Packages, checksums and metadata are uploaded to one draft Release, verified against remote asset sizes and SHA-256 digests, and then published together. Workflow runs are serialized to keep the previous-batch comparison unambiguous.

完整SHA及404状态保存在统一清单和各项目metadata中。附件全部上传到同一个草稿Release，核对远端大小和SHA-256后一次性公开。工作流串行发布，便于确定上次构建基准。

## Extract and run / 解压使用

Extract the entire ZIP into a writable folder. Its layout is **original-owner/original-repository/**. Run **Launch.bat** inside that folder or drag the game's EXE onto it. VIctory asks for the game executable; XCL opens its own game picker. Saves and caches use `data/` and `cache/` beside the launcher.

完整解压到可写目录，在 **原作者/仓库名/** 内运行 **Launch.bat**，或将游戏主程序拖到BAT。存档和缓存位于启动器旁的 `data/`、`cache/` 中。

Packages include the executable, BAT, upstream README/license notices, exact `source.zip`, `BUILD-INFO.json` and file checksums. Projects with runtime presets also include `PERFORMANCE.md` and `RUNTIME-PRESET.json`; `Launch.bat --print-runtime-preset` prints the applied settings without starting the game. Runtime variables take effect when launching, not merely while compiling.

包内含EXE、BAT、原项目说明和许可证、对应源码及校验文件。有预设的包另附参数说明和JSON；`Launch.bat --print-runtime-preset` 可检查参数而不启动游戏。运行参数需在启动游戏前设置，仅在编译时设置不会自动生效。

- **fxceless:** retains the documented run-279 settings, shader opt 63 and upstream wave defaults; adds **`VICTORY_LOOKUP_CACHE=1`**, which upstream run 293 measured at about 14 ms/frame saved at equal draws. Unmeasured experiments are not enabled indiscriminately.
- **AvatarManz:** extracts the official `scripts/play.ps1` default fast settings from the exact compiled SHA, including threaded recording, joined submissions and upload-ahead. AMD-focused, upstream recommends 64 GB RAM; NVIDIA performance is not established. Optional ray tracing stays off. The original script is included as a reference and is not the portable entry point.
- **DexNom:** bundles **victory.exe, victory-play.exe and victory-warm.exe** and initializes checksum-pinned format tables before building. The BAT uses the README no-RT path, which is also upstream's suggested NVIDIA starting point. Select optional ray tracing/FSR explicitly with victory-play.exe.
- **XCL:** bundles checksum-pinned official DXC/Agility files and their licenses; **Windows Gaming Services / XGameRuntime must still be installed**.

No Rust or full Windows SDK is required to use the packages. You still need the upstream-supported Windows/GPU/driver features and your own unpacked game files. Releases persist independently of the seven-day intermediate Actions artifacts. GitHub's automatic “Source code” downloads are this workflow repository; **the actual launcher source is the `source.zip` inside each successful package**.

运行包无需Rust或完整Windows SDK，但仍需满足上游系统和显卡要求，并自行提供已解包游戏文件。Release附件独立于7天保留期的中转产物。GitHub自动附加的Source code是本工作流仓库；**实际启动器源码在各包的source.zip里**。

## Attribution / 致谢

All launcher code belongs to its original authors and retains its upstream license. VIctory variants use GPL-3.0-or-later; XCL uses GPL-2.0-only. Microsoft runtime files retain their notices. PortWatch rankings and author reports help choose projects; they are not a performance guarantee by this builder.

所有启动器代码属于原作者并遵循上游许可证，微软运行库保留独立声明。榜单与作者实测用于选项目，不代表本编译仓库保证相同帧率或稳定性。
