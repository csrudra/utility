# ZJOU-VICTORY 性能框架与项目总览（详细版）

> 更新：2026-11-25 · 仓库：`github.com/FQY55kai/ZJOU-VICTORY`（HEAD 67076c7）
>
> **演示视频（本项目实况）**：[victory-amd 的英伟达移植，大部分着色器正常运行，目前已实现稳定的 3-4 帧](https://www.bilibili.com/video/BV14WyBzjEBW)（哔哩哔哩，短链 https://b23.tv/MJZBC3R）

---

## 一、项目定位与目标

**ZJOU-VICTORY** 是 Xbox Series 版 GTA6 在 Windows PC 上原生运行的翻译层（基于 VIctory 系开源工程），本项目聚焦**性能优化**：在其他分支负责渲染正确性的前提下，专攻帧率、资源占用与稳定性。

### 目标

| 层级 | 目标 | 现状 |
|---|---|---|
| 已达成 | 突破 30fps 节奏锁 | ✅ 开场 188-240fps（4-5ms/帧） |
| 已达成 | 世界加载 2fps → 稳定 4fps | ✅ 3.9-4.5fps（223-254ms/帧），零崩溃 |
| 已达成 | 静默退出修复（dstorage 竞态） | ✅ joshuu 修复已合入 |
| 近期 | 低分辨率降载功能修复（现默认关） | 用 D3D 调试层定位非法调用 |
| 近期 | 统一内存路径（VICTORY_UNIFIED）改造后默认开 | 对比/取回 pass 不再对共享内存 compute 哈希 |
| 中期 | 世界内 8-10fps、heap pass 406ms 尖峰消除 | 增量化描述符堆更新 |
| 远期 | 60fps 稳定、序章可玩、光影正确（当前阴影全黑：光线追踪光照未实现） | 依赖社区正确性进展 |

---

## 二、所用机器

### 主力测试机（本文全部实测数据来源）

| 部件 | 型号 |
|---|---|
| 整机 | 机械师（MACHENIKE）曙光16 Pro **L16P** |
| CPU | Intel Core **i9-13900HX**（24 核 32 线程） |
| GPU | NVIDIA **GeForce RTX 4080 Laptop**（12GB GDDR6） |
| 驱动 | NVIDIA **32.0.15.9733**（2026-11-25 更新） |
| 内存 | **31.7GB** DDR5 |
| 系统 | Windows 11 x64 |
| 游戏 | GTA6 Xbox Series 版（`game_scarlett_master.exe`，Series X profile，TitleID 7952987A），本地 dump（`C:\boottest`） |

### 引用项目的测试机（他人实测，用于对照）

| 项目 | 测试机 | 实测 |
|---|---|---|
| JoshuuDev/victory-amd | AMD RX 7800 XT 16GB + Ryzen 7 7700X + 32GB；另有 i7-14700KF + RTX 4070 12GB | 序章过场+第一房间 2-3fps，8 分钟基本不崩 |
| Zettrox/ztrx | NVIDIA RTX 3050 8GB | 序章从囚室到快艇追逐可玩，1-3fps，单次 1.5 小时不崩 |
| fxceless/victory-fork | NVIDIA RTX 4070 | 过场+3D 可渲染（社区排行 78%） |

---

## 三、引用项目（全部上游与参考工程）

### 直接血缘

| 仓库 | 角色 | 我们取用的内容 |
|---|---|---|
| **Marvisak/VIctory** | 一切的基座（loader/HLE/D3D12 后端/着色器重编译） | 全部架构；GPL-3.0 |
| **fxceless/victory-fork**（=Hyphen，社区排行 78%，开源第 2） | 主要上游 | `rect_list_gs`（矩形列表进几何阶段，治黑屏）；`e9765a7` wave64 挂死修复；纹理上传队列 310c6eb；depth bounds test + 快速默认 c96b4f2（#82 by Kaivyyy）；索引纹理复查 a803c87；AMD view heap clamp 31714de（trippywhale）；fx PR 移植 3bff182（asdaasdsaddf） |
| **JoshuuDev/victory-amd**（fork 自 myokex/victory-amd，再 fork 自 fxceless） | 2026-11-25 合并（e6a5ed7） | **dstorage 守卫竞态修复**（治静默退出）；页面全视图守卫（VICTORY_VIEW_GUARD，源自 victory-fork #115 by Spexivus + 修正 Spexivus/victory-fork#1 by joroyt + VIctory #1122 by tightfall）；纹理真内存 spans（placed_bytes_from）；dispatch >65535 组分部；dstorage page array 运行时读取；VICTORY_HEAP_RECHECK；**`victory warm` 着色器预热**；early pipeline list 跨运行保留；AMD view index 钳制 |
| **Zettrox/ztrx** | 参考 + 启动器 | `play.ps1` 启动器模式、README 状态基准；（其树=fxceless 落后 5 提交+启动器，无独特技术） |

### 对照与参考（未合并，仅学习/对比）

| 仓库 | 用途 |
|---|---|
| **JMAN730/victory** | 高频提交；shader 修复（v_permlanex16_b32 等）定点移植；全量合并 49k 行两次放弃 |
| **xcl-dev/xcl** | 行为对照（XCL：动画流畅但 3D 场景 35119 pipelines 堆积不消减） |
| **myokex/victory-amd** | joshuu 的直接上游 |
| **gta6recomp.com / PortWatch VI 排行榜** | 进度基准：omonkey 79%（私有）、Hyphen=fxceless 78%、VIctory 70%、AnyXboxX 65%、XCL 63%、Xbox2Windows 48%、Palmetto 25% |

### 四树复现对照结论（2026-11-25 上午）

| 树 | 状态 |
|---|---|
| fxceless/victory-fork | 唯一能渲染过场+3D（后成为我们基底） |
| JMAN730/victory | 黑屏（present 合成断），shader 修复可取 |
| Marvisak/VIctory | 菜单 20fps 后 GPU 设备丢失（缺 wave64 修复） |
| xcl-dev/xcl | 动画流畅但 3D 场景加载不出 |

---

## 四、达成的情况（实测数据）

### 4.1 30fps 突破（帧调度）

- **根因**：标题用 Xbox 帧间隔机制 `set_interval(33.333ms)` 在帧时钟上阻塞定步；渲染本身仅 4-5ms。
- **实现**：`VICTORY_FRAME_INTERVAL=<µs>` 覆盖（`0`=uncapped 500µs tick）+ `VICTORY_VSYNC=0`。
- **实测**：开场动画 **30fps → 188-240fps（4-5ms/帧）**。
- 注意：uncapped 后出现"走一步退一步"现象（游戏帧步进被破坏），正式游玩建议 `VICTORY_FRAME_INTERVAL=16667`（60Hz）。

### 4.2 世界加载段性能（433ms → 172ms，2.3fps → 5.8fps）

| 指标 | 今晨基线 | 现在（67076c7） | 手段 |
|---|---|---|---|
| 帧时间 | 433ms | **223-254ms** | 以下全部叠加 |
| 帧率 | 2.3fps | **3.9-4.5fps** | |
| fetch 等卡 | 262ms | **8.6ms** | 卡上拷贝优先（e2852a6） |
| copy back | 328ms | **12.7ms** | 同上 + WIDE_MERGE 默认开 |
| 卡上缓冲拷贝 | 1 个 174MB | **97 个 941MB** | `VICTORY_CARD_ROOM_PERCENT=95`（拷贝 95% vs 纹理 90%） |
| 纹理刷新 | 1029ms（等重映射 963ms） | **3.8ms** | 上游 310c6eb/a803c87 + WIDE_REFRESH |
| CPU 快照 | 689MB/帧 | 随拷贝上卡大幅下降 | 同 e2852a6 |
| hash 对比遍数 | 121-146 遍 | 合并运行（compare 15→4） | `VICTORY_CARD_REHASH_RUNS` 默认开 |
| 着色器翻译失败 | 13 条 | **2 条** | 我们的 descriptor/f64/interp 修复 + 上游 |

> 2026-11-25 夜 `477c395a` 进一步到 **151–239 ms / 4.2–6.6 fps**（视场景 4400–6600 draws；空闲段最好 172 ms / 5.8 fps）。合并 LooperSalty `80d58f8` 27 提交：DirectStorage 物理页通知、COPY 队列卡上拷贝、depth bounds 直通。逐环节开销、优化方法与目标见 **4.5 账本**。

### 4.3 稳定性

- **静默退出修复**：dstorage 守卫竞态（标题世界第一帧后数秒自停 2/2 复现）——joshuu `10ea38e` 修复已合入。
- **`victory warm`**：着色器预热命令（约 4 分钟），进游戏不再缺物体/首分钟卡翻译。
- 世界加载段连续运行零设备错误（LOWRES=0 路径）。

### 4.4 实验性功能（默认关，有明确方向）

| 开关 | 状态 | 发现 |
|---|---|---|
| `VICTORY_UNIFIED=1` | 默认关 | 统一内存映射（CUSTOM heap/L0/WriteCombined ≈ Resizable BAR 共享内存）：UPLOAD heap 不许 UAV；L0 可用但现有 compute 哈希压共享内存 1 分钟内挂设备 → **改造方向明确**：对比/取回 pass 用 CPU 侧或写标记替代 compute 哈希后可默认开，届时 271ms/帧的"标题等内存读"串行点消失 |
| `VICTORY_LOWRES_MIPS=1~8` | 默认 0 | 显存满时纹理丢最大 mip（降分辨率不等待）：drop>0 时设备挂死（无效调用，两次复现）→ 待 D3D 调试层（`VICTORY_D3D12_DEBUG=1`）定位 |
| `VICTORY_FRAME_INTERVAL=0` | 可用 | 突破 30fps；游戏有第二层限速与步进依赖，60Hz 更稳 |

### 4.5 逐环节开销账本（每部分：开销 / 优化方法 / 目标）

一帧从 title 提交到 present 拆成 10 段，**每段都是独立实测**（各段有自己的日志行），阶段之间**并行重叠，不能直接相加**。基线 `477c395a`，囚室场景，4100–6300 draws，218 ms 典型帧。

| # | 环节 | 当前开销（典型 / 峰值） | 优化方法（已做） | 目标（下一步） |
|---|---|---|---|---|
| 1 | **帧调度**（限速） | 33.3 ms 硬定步，渲染本身仅 4–5 ms | `VICTORY_FRAME_INTERVAL=<µs>` 覆盖 + `VICTORY_VSYNC=0` → 开场 **30 → 188–240 fps** | 60 Hz 定步下不再"走一步退一步" |
| 2 | **title 内存拷贝** | **48.7 ms / 132 MB**（峰 58.5 / 192），27 次拷贝 0 次续接 | `VICTORY_JOIN_COPIES` 默认开（相邻拷贝合并）；COPY 队列**卡上拷贝优先于纹理**（95% vs 90%） | 增量拷贝：只送脏页，不重送整缓冲 |
| 3 | **纹理刷新**（读+哈希+解瓦） | **7.2 ms / 21 MB**（峰 18.6 / 43）；其中问 write watch 0.6，等重映射 0–11.9 | `VICTORY_TEXTURE_NO_WAIT=1` 重映射期间走内核直读；WIDE_REFRESH；未写过的纹理 8 帧一查；最近变过的纹理 30 帧内每查必哈希（防解码器环形缓冲） | 把"等重映射 11.9 ms"彻底移出提交线程 |
| 4 | **卡上哈希/比较** | 234 次 hash 遍 / 1201 片、96 次比较遍；上行 79.8 MB / 239 段，比 17034 片，取回 808 片 **52.2 MB**，19 次等卡 10 ms | `VICTORY_CARD_REHASH_RUNS=1` 把散片合成连续遍（比较遍 **121–146 → 4–96**）；`VICTORY_CARD_BUFFERS_MIN_MB` 大拷贝交卡看 | **声明精度**：为何每帧声明 1 GB 写范围（疑整缓冲声明） |
| 5 | **描述符堆 pass** | **5.2 ms / 1.0 遍**（尖峰 12–406） | 部分增量更新；`recheck_looks` 取代双 recheck | 堆增量更新做完，消掉 406 ms 尖峰 |
| 6 | **着色器翻译** | 冷启动 **2913 条 ≈ 26 s**；热启动 `hits=1846 misses=0` | `victory warm` 预热；缓存 key = 镜像哈希 + 翻译指纹 + 源码哈希；descriptor / f64 / 插值修复使翻译失败 **13 → 2 条** | key 分模块：改一处别让全表失效（现在一改 lower.rs 全废） |
| 7 | **绘制提交** | 4100–6300 draws/帧；丢 **346**（无宿主管线）+ **637** indirect | 管线库落盘 463 MB；bind sets skip 34/帧 | 用 `VICTORY_DESC_WHY` 解剖这 346 个丢画的着色器 |
| 8 | **GPU 执行** | **34.5–92 ms**，卡 68–86% 忙（合并前 219.6 ms） | 合并 LooperSalty `80d58f8` 27 提交：DirectStorage 物理页通知、depth bounds 直通宿主管线、MIMG 偏移、BCPack 词典 | GPU 侧压到 60 ms 以内 |
| 9 | **内存回读**（copy back） | **42.7 ms / 43 MB**（峰 58.5 / 86），合并前 287.4 ms | 卡上拷贝优先 + WIDE_MERGE 默认开 | 只回读 title 真读过的页 |
| 10 | **等待/同步** | 提交线程等卡 **85–241 ms**；卡在我们干活时空转 26.5 ms | 四路并行默认开；`VICTORY_LATE_WAIT=2` 让落在 flight 底部；relay 线程独立回读 | 缩短"卡空转等 CPU"的 26.5 ms |

**本版最大的一次跳跃**（合并 LooperSalty 27 提交后，同一囚室场景）：

| 指标 | 合并前 | 合并后 | 变化 |
|---|---|---|---|
| 帧率 | 3.0 fps | **5.8 fps** | +93% |
| 帧时间 | 346 ms | **172 ms** | −50% |
| GPU | 219.6 ms | **75.6 ms** | −66% |
| copy back | 287.4 ms | **42.7 ms** | −85% |
| draws | 379 | **4753** | 12.5× |

**三条真杠杆（按收益排序）**

1. **显存打满后的重传策略**——5 小时跑出 106 000 次 `HEAP_TEXTURES_REUPLOADED_FULL`，932 MB 常驻拷贝、7971 个槽等内存。目标：显存满时按"丢最大 mip → 降分辨率"而不是每帧重传。验收：该计数 10 分钟增长 < 1000。
2. **346 个丢画**——`VICTORY_DESC_WHY` 逐个解剖，全是翻译失败或管线缺失。验收：丢画 < 50/帧。
3. **写范围声明精度**——现在每帧声明约 1 GB 写范围，逼着卡做 234 遍哈希。验收：上行 < 30 MB/帧。

> 数据来源：`run4.log`（合并后冷启动）、`run6.log`（同 exe 热启动，验证缓存命中 100%）。取最后 60 条状态行的中位数，剔除加载段尖峰。
>
> **缓存命中的实测结论**：命中率高不等于帧率高——同一 exe 二次启动 `hits=1846 misses=0`，但稳态帧率与冷启动持平（4.2–6.2 fps vs 4.8–5.0 fps）。缓存省的是**启动与首次进场景的 26 秒翻译窗口**，稳态早已不含翻译成本。**纹理两套变化检测同理**：都在哈希之前求值，只是几个整数比较，不重复哈希，关掉省不到时间，故保留（安全优先）。

---

## 五、自研改动清单（相对全部上游）

| 提交 | 内容 |
|---|---|
| `11cdbec` | shader：bindless image 尺寸重建（descriptor_words/getDimensions）、v_cvt_f32_f64、插值修复；vsync 默认开、纹理预算 |
| `fcd3584` | 合并 fxceless 5 新提交 |
| `4386f55` | 项目更名 ZJOU-VICTORY；**VICTORY_FRAME_INTERVAL** 帧间隔覆盖 |
| `d741399` | REHASH_RUNS/JOIN_COPIES/WIDE_REFRESH/WIDE_MERGE **默认开**（纯并行无正确性风险） |
| `e2852a6` | **卡上拷贝优先于纹理**（95% vs 90%，VICTORY_CARD_ROOM_PERCENT） |
| `6c79025` | 低分辨率纹理（VICTORY_LOWRES_MIPS，现默认 0） |
| `e6a5ed7` | 合并 JoshuuDev/victory-amd（10 处冲突，Spans 取真内存方案） |
| `bfdb186` | 合并后续：rechecks 记账、双 recheck 共存、depth-bounds 命名 |
| `31904df`/`67076c7` | 低分辨率默认关（稳定优先） |
| `f2b8c85` | **pixel shader 的 quad 读取走 quad read（含 helper lane）**：修三角形边线（车漆/玻璃/皮肤），移植自 Belobug `03629f3` |
| `1fc58f3` | **常量间接漫反射光**（`VICTORY_AMBIENT`，默认 0.6）：光追不跑时替代 resolve 输出，修室内色块/洋红植被/黑人脸，移植自 Belobug `4f45ab8` |
| `c7be77e` | **鼠标映射**：移动转镜头（右摇杆，自动衰减）、左键开火、右键瞄准、中键 A |
| `6ad4317f` | **合并 LooperSalty `80d58f8` 27 提交**（AnyXboxX 钉住的同一批）：DirectStorage 物理页写通知（`VICTORY_DSTORAGE_NOTIFY`，修囚室墙透明）、xmem 按 section 索引、sampler 比较槽、MIMG 偏移、BCPack 词典、COPY 队列卡上取回、depth bounds 直通宿主管线、离线预编译（只留 `victory warm`）。19 处冲突全清，330+ 测试通过；**帧 346 → 172 ms、GPU 220 → 76 ms** |
| `edf97609` | **多树合并后的去重**：删掉与 `descriptor_words` 重复的 `descriptor_data` 整份（276 行）及 `FIRST_HALF`、`pages_written`、`shown_at`、被 `recheck_looks` 取代的 `recheck` |
| `477c395a` | `placed_filler_twins` 按 `feature="diagnostics"` 恢复（诊断内存行要读它） |

---

## 六、关键开关速查

| 开关 | 作用 | 建议 |
|---|---|---|
| `VICTORY_FRAME_INTERVAL` | 覆盖帧间隔（µs） | 游玩 `16667`；测峰值 `0` |
| `VICTORY_VSYNC` | 垂直同步 | 测峰值 `0` |
| `VICTORY_CARD_ROOM_PERCENT` | 卡上拷贝显存份额 | 默认 `95` |
| `VICTORY_CARD_REHASH_RUNS` | hash 遍合并 | 默认开 |
| `VICTORY_JOIN_COPIES` / `VICTORY_WIDE_REFRESH` / `VICTORY_WIDE_MERGE` | 并行/合并 | 默认开，`=0` 退回 |
| `VICTORY_LOWRES_MIPS` | 显存满丢 mip | **默认 0（勿开，待修）** |
| `VICTORY_UNIFIED` | 统一内存缓冲 | **默认 0（勿开，待改造）** |
| `VICTORY_HEAP_RECHECK` / `VICTORY_VIEW_GUARD` / `VICTORY_TEXTURE_SWEEP` | joshuu 修复开关 | 默认开 |
| `VICTORY_AMBIENT` | 间接漫反射光常量（0=全黑，`off`=保留原输出） | 默认 `0.6`；觉得偏亮可下调 |
| `VICTORY_BVH_BUILDER` | **开光追构建器**（标题 52 个 BVH 构建程序 + 约 1,000 个 resolve 程序） | 默认 `0`；开闸首跑要多编译 1.4–2.5 小时，见第十章 |
| `VICTORY_BVH_QUARANTINE` | 构建器产出只留宿主副本、不回写 title 内存 | 首次开闸配 `VICTORY_BVH_BUILDER=1` 用，防写坏 title 对象 |
| `VICTORY_BVH_RESOLVE=0` | 构建器开着时**先不造**那约 1,000 个 resolve 程序 | 首次验证构建器专用，把 1.4–2.5 小时压到 3 分钟 |
| `VICTORY_WAVE_WIDE` | 打开 `widen()`（发散分支整波一起走） | **默认 `0`；`=1` 实测会挂卡，别开**（见第十章） |
| `VICTORY_RT_RESOLVE` | 单独造 resolve 管线（不开构建器时它们没有命中可着色，纯浪费） | 默认 `0` |
| `VICTORY_WAVE_WHY` | 打印 wave64 重试每一步（`own_bits` / `WAVE64-WIDE`） | 诊断光追翻译时开 |
| `victory warm` | 着色器预热 | 更新构建后跑一次 |

### 操作方式（不接手柄时）

| 输入 | 手柄 | 说明 |
|---|---|---|
| **W A S D** | 左摇杆 | 移动 |
| **鼠标移动** | 右摇杆 | 转镜头（停下即停，不漂移） |
| **I J K L** | 右摇杆 | 键盘转镜头（备用） |
| **鼠标左键** | 右扳机 | 开火/攻击 |
| **鼠标右键** | 左扳机 | 瞄准 |
| **鼠标中键** | A | 交互/确认 |
| **Enter / 空格** | A | 交互/跳跃/确认 |
| **Backspace** | B | 返回 |
| **X / Y** | X / Y | X、Y 键 |
| **方向键** | 十字键 | 菜单导航 |
| **Q / E** | 左右肩键 | 切换 |
| **Z / C** | 左右扳机 | 油门/刹车 |
| **Esc / Tab** | Menu / View | 暂停/切换视图 |

---

## 七、已知问题

1. **阴影全黑**：光线追踪光照/阴影未实现（全社区一致，非本项目范围）。
2. **走一步退一步**（uncapped 帧率下）：游戏帧步进被破坏；60Hz 下验证中。
3. **低分辨率功能挂设备**：任何 mip 丢弃触发"无效调用"设备移除，已默认关闭。
4. **统一内存路径挂设备**：compute 哈希压共享内存所致，改造后启用。
5. **帧抖动（一顿一顿）**：heap pass 406ms 尖峰 + 流送波动。

---

## 八、招募：真 RT GI（光线追踪反弹光照）—— 需求与步骤

**问题**：人脸与室内是黑的。截图证据：贴图、直射阳光全部正常（Lucia 头发/衣服材质完好），但阳光照不到的地方（脸的背光面、室内）几乎纯黑——缺少光追反弹光照（RTGI）。这是全社区（VIctory / victory-fork / victory-amd 各 README 一致承认）都缺失的最后一块大拼图：**`ray-traced bounce light does not run`**。

**为什么它值得做**：这是从"能跑"到"好看"的分水岭。做完之后阴影不再是死黑，画面观感接近主机。

> **2026-11-25 夜更新：这条路已经有人走通了。** PortWatch 榜首 `DexNom/VIctory`（78%，RX 7900 XTX）已跑通光追光照，做法与我们下面的判断一致——**不映射到 DXR**，而是翻译标题自己的 52 个 BVH 构建程序与 64 个遍历程序，只把 `image_bvh*_intersect_ray` 一条指令用 DXIL 模拟（详见其 `docs/fork-ray-tracing.md`）。
>
> **2026-11-26 凌晨更正**：查证后发现这套着色器代码**早就在我们树里**（`6a2d9f99` 已是祖先，`intersect.rs` / `own_bits.rs` / `wave64_tests.rs` / `docs/fork-ray-tracing.md` 全在且已接线）。缺的不是代码，是 `pipeline.rs` 里 `VICTORY_BVH_BUILDER` 那道硬门，而它注释里写的解锁条件（"遍历结构的程序能翻译"）现在已经满足。证据与下一步见**第十章**。

### 我们已经有的（地基是实的）

| 组件 | 状态 |
|---|---|
| `XboxBvhBuilder.dll` 原生运行 | ✅ BLAS/TLAS 构建在跑（标题的 BVH 数据包 `core_bvh4*.rpf` 经 DirectStorage 正常加载） |
| BVH 内存布局 | ✅ 标题把 BVH 放在自己内存里（xmem 的地址范围约束正是为它：`the title's BVH builder refuses one above`） |
| 描述符"只取地址"路径 | ✅ 翻译器已有：`a buffer view the code only takes the address of, to walk the memory behind it (a ray-tracing structure)`——识别出了 BVH 遍历着色器 |
| 双精度/波求和 | ✅ phase2 已支持（水/大气的透射率、体积计算） |
| 部分光照累积着色器 | ✅ 已能翻译（deferred 面、水洼、浅水） |

### 缺什么（按证据推断，从易到难）

**A. 先搞清楚"RT"在主机上的实现形态（1-2 天，最关键的第一步）**

Xbox 的 XDXR 有两种可能的实现，决定了完全不同的工程路线：
1. **着色器软件遍历**：着色器自己用 buffer 读走 BVH 树（我们已看到这类着色器的迹象——"拿 buffer 地址走内存"的模式）。若是这样，工程量在着色器翻译修复。
2. **硬件 TraceRay**：`TraceRay/ReportHit/AcceptHit` 等 DXIL 光线内建。若是这样，需要 RTPSO 全套（见 B）。

判别方法：
- 开诊断构建跑世界场景，收集**未翻译/被丢弃的着色器**清单（现有日志直接给）；
- 对每个失败着色器跑 `VICTORY_DESC_WHY=1`，看是否大量出现"描述符只取地址"（软件遍历）；
- 顺带把仅存的 4 个翻译失败（`whole-wave section step` ×2、`lane mask exchanged`、`descriptor @0x38`）解剖——它们疑似就是遍历循环。

**B. 若是硬件 TraceRay（1-2 周）**

1. `D3D12_STATE_OBJECT`（RTPSO）创建翻译：DXIL library / hit group（closest-hit、any-hit、miss）/ shader config / pipeline config / global root signature 子对象；
2. `DispatchRays` → `DispatchRays` + SBT（Shader Binding Table）布局还原（标题自建 SBT 的结构要逆向它的 record 布局）;
3. DXIL 光线内建的翻译：`TraceRay`（参数包：加速结构句柄、ray mask、contribution、miss index、payload…）、`ReportHit`、`IgnoreHit`、`AcceptHitAndEndSearch`、`RayQuery_*`（inline 遍历）；
4. **加速结构视图**：`D3D12_RAYTRACING_ACCELERATION_STRUCTURE` SRV（描述符 words[3] 是 AS 的 GPU VA）；
5. **最大的坑——AS 格式转换**：XboxBvhBuilder 产出的是 **XDXR 格式 BVH**，PC DXR 只吃标准 AS。要么写 XDXR→DXR AS 转换器，要么从几何重建 AS（标题的 BVH 叶子里有几何）。

**C. 若是软件遍历（3 天-1 周）**

1. 修复 4 个现存翻译失败（遍历循环的 whole-wave 模拟、lane mask）；
2. 描述符地址读取（`0x38` 偏移）的数值化；
3. 遍历循环的性能（BVH 走树是长循环——现有的 loop-limit/波模拟要能扛住）。

**D. 光照累积（共通，1-3 天）**

反弹光的累积 pass（间接光求和、环境光探针）——phase2 的双精度波求和正是它的底座。

### 验收标准

- 序章囚室截图：Lucia 脸的背光面、背景人物、室内墙壁**不再是纯黑**（有可辨的环境/反弹光）；
- 帧率不低于当前基线（3fps 起步，预期 RT 开销可控在 2 倍内）；
- 连续运行 10 分钟无设备丢失。

**如果你要做这个，从 A 开始，把 A 的结论（软件遍历 or 硬件 TraceRay）发 issue，再动手。** 欢迎认领。

---

## 九、代码结构（分门别类）

12 万行、142 个源文件。按职责分五个 crate，每帧热路径只在 `victory-gpu` 与 `victory-shader`：

| crate | 行数 | 职责 | 热路径 |
|---|---|---|---|
| `victory-shader` | 43,381 | xbox 着色器字节码 → DXIL 翻译器（IR、结构化、发射、验证） | 首次遇到时（缓存后为 0） |
| `victory-gpu` | 44,365 | D3D12 后端：清单提交、title 内存镜像、描述符堆、纹理流送、卡上哈希 | **每帧** |
| `victory-hle` | 19,451 | 内核/系统模块替身（文件、内存、DirectStorage、输入、音频） | 每帧（浅） |
| `victory-formats` | 4,536 | 容器格式（BCPack 词典等） | 载入时 |
| `victory-loader` / `victory-pe` / `victory-game` / `victory-core` / `victory-pipeline` | 7,141 | PE 加载、重定位、游戏特定补丁、管线库 | 启动时 |

**`victory-gpu` 内部按职责分文件**（括号内为行数）：

| 文件 | 职责 | 对应账本环节 |
|---|---|---|
| `host.rs` (6,954) | 提交调度、飞行队列、卡上工作、回读中继、统计行 | 2/9/10 |
| `resource.rs` (4,058) | 堆与资源放置、孪生拷贝 | 4 |
| `shadow.rs` (3,752) | title 内存镜像、着色器写检测、变更段合并 | 4 |
| `descriptor/host.rs` (3,570) | 描述符堆增量、槽位与视图 | 5 |
| `draw.rs` (3,531) | 清单录制、绘制/间接分派、满显存重传 | 7 |
| `list.rs` (2,222) | 清单结构与值等待 | 7/10 |
| `indirect.rs` (1,931) | 间接参数解析与拆分 | 7 |
| `texture.rs` (1,681) | 纹理变化检测与解瓦 | 3 |
| `queue.rs` (1,086) | 命令队列、present、帧率行 | 1/6 |
| `ambient.rs` (242) | 常量间接光（`VICTORY_AMBIENT`），RT GI 的占位 | 8 |

**`victory-shader` 的翻译器**（本次拆分，原先全在 `emit/lower.rs` 一个文件里）：

| 文件 | 行数 | 职责 |
|---|---|---|
| `emit/lower.rs` | 10,570 | 降级本体：一条指令一条指令地发射 DXIL |
| `emit/lower/waves.rs` | 757 | lane/wave 分析：值需要哪些 lane、mask 被当数据读、哪些程序能按 wave 跑 |
| `emit/lower/pack.rs` | 172 | 签名打包：半精度通道落在宿主参数的第几个 dword |
| `emit/lower/tests.rs` | 659 | 上述三者的测试 |

拆分前 `lower.rs` 是 **12,133 行 / 526,401 字节**，超过仓库自定的 512 KiB 上限（`xtask/src/policy.rs`），策略测试一直是红的。拆完 **10,570 行 / 461,934 字节**，策略测试首次通过。拆出的三个文件已加入缓存 key 的源列表（`lib.rs::sources()`），因此**这一改动会让着色器缓存失效一次**。

### 本次顺带修掉的一处开销

`shadow.rs` 的变更段原先只切“精确相异的字节”：中间哪怕只有 1 个相同字节也另起一段。实测 run 6 每帧 **56,440 段 / 0.15 MB（平均 2.8 字节一段）**，每段都要一次拷贝、一条发给卡的范围、一条 dirty 记录。现在 `changed_runs_within` 把 **≤16 个相同字节的间隔并入同一段**（拷贝相同字节等于写入它原本的值，无害）：

| 指标 | 改动前（run 6） | 改动后（run 7） |
|---|---|---|
| 单次合并的段数（中位） | **23,797**（峰值 114,553） | **9**（峰值 43） |
| 每段承载的字节 | 2.8 B | 约 16 KB |
| 触发合并的采样占比 | 148 / 345 | 6 / 288 |
| 稳态帧 | 4.6–6.6 fps / 151–239 ms | 5.0–5.3 fps / 190–200 ms |

**帧率没有可测变化**——这一项本来只占帧时 1–3%，如实记录，不吹。真正省掉的是每帧数万次的小拷贝与 dirty 记录，以及由此引发的反复 settle。

---

## 十、上游同步（2026-11-25 夜）

### 榜单已经变了

| 项目 | 进度 | 变化 |
|---|---|---|
| **DexNom/VIctory** | **78%** | 新登顶；**首个 AMD 跑通光追光照**，说明为"接近零售版"，3–4 fps，很少崩 |
| Belobug/VIctory-Belobug-AMD | 77.4% | 我们已移植过它的 quad read 与 AMBIENT |
| Zettrox/ztrx | 64.2% | 打通序章到 Jason 首任务"Gone Fishing" |
| fxceless/victory-fork | 59.8% | 我们另一个参考源 |
| Marvisak/VIctory（上游） | 40% | 我们全部代码的祖宗 |

### 上游领先我们多少

分叉点 `ffe310eb`（11-24 10:53）之后，**上游主线 319 个提交、其中 182 个非合并提交**，我们 106 个、117 个文件、+53k 行。**直接 `git merge` 产生 411 处冲突 / 55 个文件**：

| 文件 | 冲突块 | 文件 | 冲突块 |
|---|---|---|---|
| `emit/lower.rs` | 65 | `emit/shader.rs` | 17 |
| `draw.rs` | 38 | `shadow.rs` | 15 |
| `host.rs` | 35 | `emit/mod.rs` | 13 |
| `descriptor/host.rs` | 19 | `texture.rs` | 13 |

冲突这么密，是因为上游在 **11-24 22:36 有一整块大型功能落地**（title 内存按裸地址走页表 `27c3dc9d`、FidelityFX 与 64 位图像原子 `0b35b7fe`、BVH 求交、shader pack `286e33f0`、根视图走页表 `0f637570`）——它重写了我们改动最深的 `shadow.rs` / `host.rs` / `memory.rs`。**盲合会把双方都毁掉**，所以按“逐个提交审查后挑取”来做。

### 本轮合入（逐条人工核对冲突）

| 上游提交 | 内容 | 我们的处理 |
|---|---|---|
| `4e60ea3a` | 无宿主管线时**先丢间接调用，再做参数刷新与钳位 dispatch**；上游实测每帧 1294–1750 个这类空转 | 我们 `execute_indirect` 早已把 `host_pipeline` 查表提到最前并绑定 `p`（矩形与类型判断都要用），比它更彻底 → **保留我们的结构，只采纳它的诊断原因 `why("no host pipeline")`** |
| `06019553` | **helper lane 的 `v_readfirstlane` 读自己的值**：否则 waterfall 循环里只剩 helper lane 时会空转到 `LOOP_LIMIT`，单次绘制 0.3–1.3 秒，约 200 秒后 `DEVICE_HUNG` | 我们的 `v_readfirstlane_b32` 走双 host-wave 交换（`first_lane` + `exchange_halves`），该结构保留；在其后追加它的 `helper_reads_own` 选择，helper lane 取自己的值 |

验证：全量 **563 个测试通过、0 失败**，`cargo xtask policy` 通过，诊断构建上机运行**零 `DEVICE_HUNG` / 零设备丢失**。

### 有意没合入的（附阻塞原因）

| 上游提交 | 价值 | 为什么这轮不合 |
|---|---|---|
| `cd94d353` + `940d32f6` | shader 标记它们经视图写过的页，回读只比那些页——正打我们 42.7 ms 的 copy back 与 234 遍卡上哈希 | 牵动 **20 个文件**，依赖上面那一大块上游落地；单挑必然造出一棵半新半旧的树 |
| `ed0dbfd1` | shader 声明范围内若有 title 写入，副本会保持陈旧（某 RTX 4050 上 dispatch 读到 0 尺寸死循环直到设备移除） | 依赖上游 shadow 重构（`tracked` 字段、`before` 结构都不同）。**我们树里确实有同一缺陷**（`Shadow::update` 整段跳过 `pending` 范围），但修法要同时改快照，否则回写会覆盖 title 的后续写入——写回路径最怕内存损坏，不硬凑 |
| DexNom `bc3cd4b0` 等 6 个 RT 提交 | **光追光照本身** | 依赖 `cd94d353` 与那一大块落地；它的 `memory.rs +396`、新增 `writeback.rs 321` 正是建立在我们没有的地基上 |

另外两条原计划要搬的改动，查证后**已被上游自己的机制取代**，不再移植：

| 我们的改动 | 上游的替代 |
|---|---|
| `shadow.rs` 的 `changed_runs_within`（变更段合并） | 上游 `cd94d353` 改成**页标记**：shader 声明它经视图写过哪些页，回读只比那些页。逐字节差分这整条路径在上游已不存在（`git grep "fn changed_runs" 940d32f6` 为空） |
| `descriptor_data` 去重 | 上游的页标记落地后重复已不存在（`fn descriptor_data` 与 `fn descriptor_words` 在 `940d32f6` 中各只出现 1 处） |

### 更正：光追的着色器层早就在我们树里（2026-11-26 凌晨）

上一版写的"最后叠 DexNom 的 RT 提交"这个计划，查证后发现前提是错的：

| 查证项 | 结果 |
|---|---|
| DexNom/fxceless 的光追着色器提交 `6a2d9f99`（"Shadow and trace programs translate"） | **`git merge-base --is-ancestor 6a2d9f99 0b969193` = 是。它已经是我们的祖先**，再 cherry-pick 是空操作 |
| 该提交新增的文件 | `own_bits.rs`（914 行）、`wave64_tests.rs`（452 行）、`docs/fork-ray-tracing.md`——**三者在主树里都在**，`emit/mod.rs` 也已 `mod own_bits; mod wave64_tests;` 接线 |
| `image_bvh*_intersect_ray` 的模拟 | `crates/victory-shader/src/emit/intersect.rs`（557 行）+ `src/bvh.rs`，来自同一支线 `578d459c`，`lower.rs` 已 `#[path = "intersect.rs"] mod intersect;` |
| `lower.rs` 的接入点 | 已接：`own_bits: super::own_bits::OwnBits`（273 行）、`own_bits::find(...)`（634 行）、循环里 `self.own_bits.alike` / `totals`（6773、880 行） |

也就是说：**我们缺的从来不是光追的着色器代码，那部分早在树里了。**

### 上游走的是另一条路（同一条指令，两种实现）

上游 `940d32f6` 里也有一条 `image_bvh_intersect_ray` 的实现，但和我们这支完全独立：

| | 我们（fxceless / ZSlayer / DexNom 支线） | 上游 `940d32f6` |
|---|---|---|
| 求交模拟 | `emit/intersect.rs` 557 行 + `src/bvh.rs` 696 行 | `emit/lower/bvh.rs` 535 行（`0b35b7fe`） |
| 波前 64 的处理 | **车道模拟**：`own_bits`、`structure_wide`、`without_early_outs`、`without_skips`、`widen`、`with_local_waves`——把 console wave64 拆成两个 host wave 再用 LDS 交换 | **直接声明**：`lower.rs:541 s.wave_size = Some(wave)`，在 DXIL 里要 `WaveSize=64`，让设备自己支持 |
| 代价 | 约 2,300 行模拟代码，翻译慢、逻辑绕 | 设备不支持 wave64 就翻译不出来（NVIDIA 的 D3D12 `WaveLaneCountMax` = 32） |

上游那 6 个测试在这台机器上本来就失败（`permutes_read_the_lane_named_and_zero_from_lanes_left_out` 等），正是这条分歧的副作用。

### DexNom 的 `570a941e` 是一个假补丁

`570a941e`（"Publish DexNom Runtime Radeon sources"，170 文件 / +49,715 −36,762）的父提交**正是** `940d32f6`，但它的树**不是**"上游 + 光追"，而是**整棵 fork 树的快照**。证据是它相对上游删掉了上游独有的模块：

| 被删掉的上游模块 | 用途 |
|---|---|
| `bindless.rs` | bindless 纹理队列 |
| `external.rs` / `switch.rs` / `tdr.rs` / `twin.rs` | 外部资源、开关、TDR、孪生拷贝 |
| `emit/lower/bvh.rs` | 上游自己的 BVH 求交 |

**结论：把 `570a941e` 合进来等于用 fork 树覆盖上游 319 个提交的成果**，冲突只有 5 文件 / 9 块（正好是我们刚移植过的那 5 个文件），但合完就退回上游之前。这条路不走。

### 真正的缺口：一道硬门

光追在本树里的最后一步不是写代码，是 `crates/victory-gpu/src/pipeline.rs` 里这道门：

```rust
// shortcut: and only with `VICTORY_BVH_BUILDER=1`, until a run has shown
// the whole builder and the host side of title memory by address
// (`memory.rs`) working on a card; nothing reads the structures before
// the programs that walk them translate.
fn builder_runs() -> bool {
    if !ALLOWED.get_or_init(|| env::var_os("VICTORY_BVH_BUILDER") == Some("1".into())) { return false; }
    ...
}
```

门上的注释写着解锁条件："**直到遍历结构的程序能翻译**"。而按上面查证，遍历程序（`intersect.rs` + `own_bits.rs` + `wave64_tests.rs`）**确实能翻译**——所以门的前提看上去满足了，才值得实际开一次。**实测结果是：遍历程序能翻，构建器还差 3 个**（见下一节）。

配套的诊断开关也在，正是为首次开闸准备的：

| 开关 | 作用 |
|---|---|
| `VICTORY_BVH_QUARANTINE=1` | 构建器写的东西只留在宿主副本、不回写 title 内存——首次跑全构建器的保险（"a stage that stores where it should not can then not reach the title's own objects"） |
| `VICTORY_RT_RESOLVE=1` | 让 resolve 管线被造出来 |
| `VICTORY_WAVE_WHY=1` | 打印 wave64 重试的每一步（`own_bits` 走到哪条路） |

**开闸的代价（必须预备好）**：`pipeline/make.rs::without_structures` 在构建器关着时会把 `CS_RaytracingResolve` 整批丢掉——注释写明那是**约 1,000 个计算程序，全部绑定在世界第一帧，每个要 AMD 编译器 5–9 秒**。所以：

- `VICTORY_BVH_BUILDER=1` 一开，这 1,000 个程序全部要造出来，**首次进世界的光编译时间约 1.4–2.5 小时**（5–9 s × 1000）。
- 这不是 bug，是"构建器关着就没有命中可着色"的必然结果，也正是它默认关着的原因。
- 缓解：着色器缓存（`hits=1846 misses=0` 的那套）会把这 1,000 个的翻译结果留下来，**第二次启动起为 0**。所以开闸前务必确认缓存目录可写、且 `lib.rs::sources()` 不再变动（任何源文件增删都会让缓存整体失效一次）。

### 本轮实际做完的事

在独立 worktree `D:/victory-up`（分支 `up-base`，基 `940d32f6`）里，按 crate 逐块搬我们的改动，每块跑测试：

| 提交 | 内容 | 验证 |
|---|---|---|
| `75afad29` | 鼠标映射（`gameinput.rs`：`scripted_keys()` 与 `mouse()` 并存，`merge_scripted` 走 `fallback(scripted, MouseState::default())`） | 编译通过 |
| `1691f839` | quad-local read 到达 helper lane，收在 `VICTORY_QUAD_HELPERS=1` 后面（上游的规则是它自己硬件测试写的那条，而这台机器上那 6 个测试本来就是红的，无法判定对错，所以默认保持上游行为） | 编译通过 |
| `fc472c36` | 常量间接光 `AMBIENT`（`ambient.rs` + `pipeline.rs` 的 `resolves_light` + `draw.rs` 的 `self.ambient(list, p)`） | `victory-gpu` **144 passed / 0 failed** |

`relay/flight`（`VICTORY_RELAY=1` 独立回读线程）在这棵树上**没有对应物**——上游有自己的多 flight 实现，要做得端到端重做，不在本轮范围。

### 开闸实测（2026-11-26 00:15–00:25）：53 个程序里 3 个翻译不出，而这道墙在这张卡上过不去

先加了一个开关把两件事拆开：`VICTORY_BVH_RESOLVE=0` 只跑构建器、不造那 1,000 个 resolve 程序。**验证时间从预估的 1.4–2.5 小时压到 3 分钟**（`pipeline/make.rs::without_structures`）。

`VICTORY_BVH_BUILDER=1 VICTORY_BVH_QUARANTINE=1 VICTORY_BVH_RESOLVE=0 VICTORY_WAVE_WHY=1` 跑两次（`rt1`、`rt2`）：

```
host wave lanes min=32 max=32
the ray-tracing structure builder stays off: not all of its programs have a host pipeline,
and its stages run all or none    missing=3 of=53
```

**构建器实为 53 个程序**（文档写 52），其中 3 个翻译不出，all-or-none 规则让整批关闭：

| 着色器 | 规模 | 报错 |
|---|---|---|
| `b22a16a1` | 28–56 次/帧 | `0x22c: a wave sum of 16-bit floats where not every lane runs` |
| `f133e35e` | 69,384 字节，0.2–2 次/帧 | `0x1eb4: a lane mask exchanged where not every lane runs` |
| `ceb5eb68` | 早期一次 | `0x38: a descriptor's address or format read as data` |

重试机制确实在跑（944 条 `WAVE64-*` 记录）：`without early-outs`、`without skips`、`without skips, scalars followed`、`local waves (idiom)`、`local waves (APPROXIMATE)` 全部试过，都停在同一处。

**`VICTORY_WAVE_WIDE=1` 打开 `widen()` 后**：救回 **33 个**程序（返回 `wave Some(32)`，即不再要求 64 车道），但构建器那 3 个仍然不行——`widen` 被拒 14 次，理由统一是：

```
WAVE64-WIDE not tried: thread groups of [256, 1, 1]
WAVE64-RETRY wave-wide branches: wave-wide branches in a thread group of several console waves
```

而且这次运行在进世界约 2.5 分钟后**整机静默**（进程活着、占用 15.8 GB），同样时长下不开 `VICTORY_WAVE_WIDE` 的 `rt1` 没有这个现象——与 `mod.rs:404` 那段注释（"runs 121–124 lost the card … `ptfx_CS_lightAtlas_Sprite` 和 `_Trail`"）完全一致。**默认关是对的，不要再默认打开。**

#### 为什么这是结构性的，不是缺一行代码

console 的一个波是 64 车道。卡上只有 32 车道时，跨 64 车道的运算（f16 平衡树求和、lane mask 交换）必须让两个 32 车道 host wave 通过 LDS 交换，而交换需要**组屏障**。组屏障一旦落在发散分支里，没到齐的线程就永远等下去——所以 `widen()` 只在"线程组正好是一个 console 波（64 线程）"时才敢用，这是它 `cs.threads.product() == 64` 那道判断的全部理由。

构建器的线程组是 **256 / 128 / 1024**，天生跨多个波。三个失败程序要的恰恰是"每个车道都到场"，而这在多波组里做不到安全。

| | AMD（`WaveLaneCountMax=64`，RX 7900 XTX） | NVIDIA（`min=32 max=32`，本机 RTX 4080） |
|---|---|---|
| 上游路线：声明 `WaveSize=64` | ✅ 可用，根本不需要模拟车道 | ❌ D3D12 不支持，`min=max=32` |
| 我们的路线：模拟车道 | ✅ 也不必模拟 | ❌ 跨波交换需要组屏障，多波组里死锁 |
| 构建器 53 个程序 | 应可全翻译 | **3 个永远翻译不出** |

**这才是榜单上 DexNom 78% / Belobug 77.4% 的物理前提**——他们都在 AMD 上，`WaveSize=64` 直接可用。换到 wave32 上限的卡，光追这条路在当前设计下是关着的，跟努力程度无关。

#### 剩下两条路

1. **换一张 AMD 卡验一次**（最省事，1 小时见分晓）：同一份代码在 `min=32 max=64` 的卡上，`widen` 与 `local waves` 都会走别的分支，构建器很可能直接起来。这是把"3 个失败"变成"0 个"最快的验证方式。
2. **留在 NVIDIA 就要改发散模型**：把 `structure_wide` 从"按波"扩到"按组"——让组里所有波对每个分支做同一个决定（谓词化，谁都不提前退出），屏障才合法。这等于重写结构化器的一部分，工作量大，且拿不到正确 BVH 时的后果已知（早期尝试是"第一次构建器提交后一秒内死在框位模式指针上"）。不建议在没拿到 AMD 数据前动。

#### 本轮附带产出

| 改动 | 作用 |
|---|---|
| `VICTORY_BVH_RESOLVE=0` | 只跑构建器、不造 1,000 个 resolve 程序；把首次开闸的验证从小时级压到 3 分钟 |
| 实测数据 | 构建器 53 个、失败 3 个及其 hash 与偏移；`widen` 救回 33 个、被拒 14 次的原因 |

### 2026-11-26 00:30 再看上游

| 远程 | 头部 | 内容 |
|---|---|---|
| `origin/main`（Marvisak） | `67e8ae14` | `940d32f6` 之后又 **85 个提交**，绝大多数是 GPU 性能重构：页标记回读、纹理暂存池、单视图共享大拷贝缓冲、堆同步只处理变动槽位、D3D12 对象专用释放线程、快照池上限 512 MiB |
| `dexnom/main` | `921d8d3b` | `Repair pixel quad sampling, grow ray buffer views, and recover sparse textures` —— 光追方向继续前进，仍在他们那棵树上 |
| `looper/perf/nt-write-copy-back` | `6950319c` | copy back 1.5 s → 0.13 s（`NtWriteVirtualMemory`，不先 `VirtualQuery`）。**我们树里已有**，见第十一章 |
| `looper/perf/copy-pool-stacked` | `8cce7801` | 拷贝线程池做快照与比对。依赖上游的页快照，拿不到 |
| `looper/shaders/*` | `b00573d8` / `8996aeb8` | `v_readfirstlane` 地址下的 code-table 与 loop counter，属 waterfall 方向 |

**两条直接关系到我们待办的上游提交**：

- `4015a182 Shaders: quad reads in pixel programs reach the helpers at triangle edges` —— **上游自己实现了我们的 `VICTORY_QUAD_HELPERS`**。本树可以改用它，不必再挂环境变量。
- `e8e9f0c2 Shaders: a lane mask joined with data at a uniform join is its number` 与 `4a3166e6 Shaders: lanes skipping a compare's region read 0 of its lane mask` —— lane mask 的两处修复，**有可能是 `f133e35e` 的解**（`a lane mask exchanged where not every lane runs`）。试挑过：4 处冲突，且依赖上游新建的 `read_phis` / `lane_edge` / `uniform_join` 结构，不是能顺手移植的，需要单独一轮。

---

## 十一、为什么移植版比原生贵这么多

原生 Series X 的目标是 30 fps（标题自己按 33.3 ms 节流）。本机 4080 是世界场景 **5.0 fps / 200.7 ms**。不是"优化没做完"，而是**每一层都得替硬件做一遍它本来免费做的事**。下面全部取自 `run8.log` 稳态。

### 200.7 ms 花在哪

| 环节 | 每帧 | 原生对应 |
|---|---|---|
| 帧总长 | **200.7 ms** | 33.3 ms |
| 命令录制（6 线程合计） | **149.1 ms**，35,766 次 list 调用 | ≈0：console 的 command processor 是硬件，绘制包直接进队列 |
| GPU 执行 | **103.3 ms** | ≈33 ms |
| title 内存 → 宿主副本 | **45.9 ms / 122.9 MB** | 0：统一内存 |
| 宿主副本 → title 内存（回写） | **40.9 ms / 42.5 MB** | 0 |
| 视图堆整堆扫描 | 15.6 ms | 0 |
| 绘制 | 4,544 次，另有 343 次丢弃 + 637 次间接 | 硬件批量，且不校验 |

各项重叠（多线程录制与 GPU 并行），不能相加。

### 多出来的部分，按代价排序

1. **每一条绘制都要在 CPU 上重放。** console 的绘制包由硬件直接消费；我们要把 4,544 条解成 D3D12 调用，每条校验根签名、绑描述符表（每帧 **11,224 张**）、设状态、记 list。这就是那 149 ms。**原生这条是 0。**
2. **描述符要重建。** console 的 shader 直接拿 GPU 虚拟地址读描述符（bindless by address）；host 堆布局不同，必须把 title 内存里的描述符翻译进 host 堆：每帧 1,082 次视图写入 + 那 11,224 张表。
3. **内存要镜像两遍。** console 统一内存，shader 写哪 CPU 立刻看得见。我们要维持 title 内存的宿主副本：检测 shader 写了哪些页（每帧比对 23.9 MB），把变的拷回去（42.5 MB）；反方向 title 写纹理，还要读出来解瓦上传（122.9 MB）。**往返 165 MB/帧、87 ms/帧，纯属翻译成本。**
4. **GPU 本身也慢 3 倍。** console 的波是 64 车道，4080 在 D3D12 下只有 32（`min=32 max=32`）：每个 wave64 计算程序要拆成两个 host wave 再用 LDS 交换，指令数最多翻倍；而且我们发射的 DXIL 远不如 AMD 编译器优化的产物。
5. **显存不够，数据一直在搬家。** 16 GB 的卡上预算只有 **10.2 GB**，`in use 97%`（9,974/10,282 MB）；**35,261 张 title 纹理没有宿主副本（14.6 GB 的 title 内存）**，一个 run 里 **1,669 次**因为没地方而没做出来。原生只有一份数据；我们同时持有 title 内存映像 + 宿主副本 3.5 GB + 卡上宿主纹理 8.1 GB + 卡上副本 928 MB，**进程私有 23.8 GB**（常驻 10.9 GB）。

一句话：**native 是"零拷贝 + 硬件描述符 + 原生 64 波 + 一份内存"；我们是"三份内存 + 每帧 165 MB 往返 + CPU 重放 4,544 条绘制 + 32 波模拟"。** 差距不是系数，是这五项各自乘上去的结果。

### 已试过但无效的（省得再试一遍）

| 想法 | 实测 |
|---|---|
| 用 `NtReadVirtualMemory` 替掉 `ReadProcessMemory`，抄 Looper 在写侧的成功 | **无意义**：Vista 之后 `ReadProcessMemory` 本身就是 `NtReadVirtualMemory` 的薄壳；写侧之所以有用是因为 `WriteProcessMemory` 会先 `NtQueryVirtualMemory`。我们树的 `VICTORY_DIRECT_WRITES`（写侧）与 `VICTORY_COPY_ASK`（不预先 `VirtualQuery`）**都已默认开着**，Looper 那两个 perf 分支的内容我们早就有 |
| 用 `IDXGIAdapter3::SetVideoMemoryReservation` 把预算从 10.2 GB 抬到 15.7 GB（日志写着"5741 MB could still be reserved"） | **无效**：预留给的是**下限**（保证不被别人挤掉），不会把预算抬到系统已经给的额度之上。实测 `reserved_mb=2870 ok=true` 之后 `budget` 仍 9,631 MB，帧率与"no room"计数无变化。代码已撤 |
| `VICTORY_TEXTURE_ROOM_PERCENT=94`（代码注释自己推荐的值：90 时"1,020 MB 空着，同时上千张纹理在等"） | **更慢**。同绘制数（约 4,960）对照：90 时 **188.8–207.8 ms**，94 时 **233–239 ms**，贵约 25 ms/帧（−12%）。原因就在账本里：显存用得多→每帧搬得更多，`copies` 122.9→**153.2 MB**、`copying back` 42.5→**66.6 MB**。默认仍是 90 |

### 真要往下压，只有三条

1. **拿上游的 GPU 侧重构**（那 85 个提交）：页标记回读（`cd94d353`，正是 42.5 MB 回写与 23.9 MB 比对的替代）、单视图共享大拷贝缓冲（`6cc6aa35`）、堆同步只处理变动槽位（`f8095210`、`29221419`）、纹理暂存池（`fdf34ab7`）。这是唯一能动第 1、3 项成本的东西，代价是那次 411 冲突的合并。
2. **`VICTORY_INPLACE` 全量**（把 title 内存直接当显卡堆用，少一份副本）：本树只有第一阶段。
3. **换 AMD 卡**：第 4 项成本（wave64 模拟翻倍的指令数）直接消失。

---

## 构建与运行

```powershell
# 构建（需 Rust 工具链、MSVC C++ 工作负载、Windows SDK）
cargo build --release -p victory

# 着色器预热（推荐，约 4 分钟；更新仓库后重跑）
target\release\victory.exe warm

# 运行（游戏为自备的 Xbox Series 版 dump）
target\release\victory.exe run "<游戏目录>\game_scarlett_master.exe" --execute --console series-x
```

节奏与开关：`VICTORY_FRAME_INTERVAL=16667` 为 60Hz 节奏（省略则 30fps），`VICTORY_VSYNC=0` 关垂直同步；完整开关见上文速查表。缓存与存档默认在系统的本地应用数据目录下 `victory` 文件夹，`scripts\play.ps1` 为一键启动器。

**本仓库不含任何游戏文件、代码或资源**，需要自备游戏副本；与游戏开发/发行方无关。
