<div align="center">

# ScarlettPort

**A native Windows port layer for a next-gen Xbox Series X|S open-world title, running from your own files.**
No emulator. No streaming. The game's own x64 code runs on your CPU, and its RDNA2 GPU code is recompiled for your graphics card on the fly.

### Progress to playable

![progress](https://img.shields.io/badge/progress-45%25-ff2d95?style=for-the-badge)

```
█████████░░░░░░░░░░░  45%
```

`boots` ✅ → `intro & menus` ✅ → `world loads` ✅ → `world geometry` ✅ → `gameplay starts` ✅ → `lit final image` ✅ → `shadows, speed` 🔨 → `30 fps 1:1` ⏳

<a href="https://www.paypal.me/SalwanStudios"><img src="https://img.shields.io/badge/DONATE-PayPal-blue?style=for-the-badge&logo=paypal&logoColor=white" alt="Donate via PayPal" height="45"/></a>
<a href="https://ko-fi.com/ziggymar"><img src="https://img.shields.io/badge/BUY%20A%20COFFEE-Ko--fi-ff5f5f?style=for-the-badge&logo=kofi&logoColor=white" alt="Support on Ko-fi" height="45"/></a>

<sub>PayPal: please send as <b>Friends & Family</b> to avoid holds and fees.</sub>

</div>

---

## 📸 Running right now

### 🆕 The game's own lit picture on an RTX 3060

![Lit gameplay view](assets/world-lit.png)

<sub>The game's real final image in gameplay on an RTX 3060 (Windows 10): sunlight, textures, fences, buildings, with the movement tutorial on screen. About 2.5 fps. Shadowed areas are still too dark and some HUD text is cut off. Built on the public VIctory fork by fxceless (GPL-3.0) with our Windows 10, input, capture and fast-boot work on top.</sub>

### 🆕 The world with our own stand-in lighting

![World with fallback lighting](assets/world-fallback-light.png)

<sub>The game's real picture on an RTX 3060, with a stand-in lighting pass (`VICTORY_FALLBACK_LIGHT=1`): sky, a sun, fog, and the world's own geometry buffers. Fences, a bin and props are there; terrain and most surface colours are still missing because their shaders don't translate yet. About 1 fps.</sub>

### 🆕 Gameplay has started: the movement tutorial

![Movement tutorial prompt](assets/tutorial-prompt.png)

<sub>The game's own "Move around / Move the camera" tutorial on an RTX 3060. The game is past its opening and waiting for the player; the 3D picture behind the prompt is still black because the lighting shaders don't all translate yet (see below).</sub>

### 🆕 The open world, drawn live on an RTX 3060

![Open world in debug colours](assets/world-street-debug.png)

<sub>A street in the open world, shown in the game window in real time on an RTX 3060: a picnic table, a building, the road and its markings. This is one of the game's own geometry buffers put on screen with a debug colour view (VIctory + community PRs, `VICTORY_DEBUG_PS=1`, `VICTORY_SHOW_TARGET=2560x1440-f28`), at about 1 fps. Lighting and textures are not there yet.</sub>

### The opening scene's 3D world on an RTX 3060

![Opening scene geometry in debug colours](assets/world-sofa-debug.png)

<sub>A sofa from the game's opening scene, drawn in real time on an RTX 3060 with a debug colour view (VIctory + community PRs, `VICTORY_DEBUG_PS=1`, one of the game's internal buffers). The geometry is there; the lighting pass that turns these buffers into the final picture still outputs black. That is the next thing to fix.</sub>

### First open-world geometry on an NVIDIA GPU

![First world geometry](assets/first-world-geometry.png)

<sub>Captured from inside the open world on an RTX 3060 (Series S profile): one of the game's own render passes drawing the ground in true 3D perspective. It's an internal pass, not the final lit image yet, but it's the world rendering. Next step: the geometry passes that feed the final image.</sub>

The title's own artwork, menus and loading screens, drawn natively on an **RTX 3060** at a locked **30 fps**:

| Title artwork | Loading screen | Loading screen |
|:---:|:---:|:---:|
| ![Title artwork](assets/title-art.png) | ![Loading screen](assets/loading-1.png) | ![Loading screen](assets/loading-2.png) |

| Lucia loading screen | | |
|:---:|:---:|:---:|
| ![Lucia loading screen](assets/loading-lucia.png) | | |

| First-boot setup | Legal notices | Terms & policies |
|:---:|:---:|:---:|
| ![Subtitles setup screen](assets/menu-subtitles.png) | ![Legal notices screen](assets/menu-legal.png) | ![Terms screen](assets/menu-terms.png) |

<sub>Gameplay screenshots go here the moment the world renders. Watch the repo ⭐ so you see it first.</sub>

---

## 🧱 What blocks the final picture

The world's geometry buffers (normals, albedo, depth, shadow maps) fill in correctly. The final image is black because some of the game's GPU programs still fail to translate on NVIDIA, and their work is dropped. The biggest groups, from one world run on an RTX 3060:

| Failure | Shaders | Status |
|---|:---:|---|
| Descriptor read only as data | 149 | open |
| `v_readfirstlane` in divergent control flow | 101 | uniform case fixed, rest open |
| Lane mask read as data (mesh + compute) | 94 | fixed in our branch (plus upstream VIctory #1407) |
| Structured buffer of unknown stride | 63 | in progress – the top per-frame drop |
| Cross-lane wave op in divergent flow | 57 | open |
| Title heap larger than NVIDIA's 1,000,000-descriptor cap | – | in progress (upstream VIctory #1133) |

Each of these is a self-contained task for one person + one AI agent. Speed is the other wall: about 1 fps in the world today.

---

## 🚦 Where we are

| Stage | Status | Notes |
|---|:---:|---|
| Executable loads, imports bind | ✅ | 0 missing imports; the game's 16 console DLLs load |
| Intro, setup and menus | ✅ | 30 fps, audio plays |
| Shaders translate | ✅ | all 26,084 programs in the pack translate (XCL) |
| Exposure / tonemapping chain | ✅ | all 36 luminance & tonemap shaders translate |
| Open world loads | ✅ | world packs stream in through DirectStorage |
| Open world renders | 🔨 | **the current wall**: black screen after loading (see below) |
| Gameplay | ⏳ | |
| 1:1 at 30 fps on a mid-range PC | ⏳ | the goal |

### The current wall: the first seconds in the world

The game boots, runs its menus, loads the open world (peds and cars spawn, and the in-world audio plays), and then dies within seconds. We've narrowed down why:

- When the world starts, the game asks for **~10,000 GPU programs at once**. Compiling them on NVIDIA takes far longer than the game will wait.
- If those draws **wait** for their programs, the game's own 30-second watchdog decides it has hung and quits.
- If those draws are **skipped**, their outputs are never written. Later GPU work reads that garbage (e.g. indirect draw counts), runs far past Windows' 2-second GPU timeout, and the device resets.

**The fix is to have every program compiled before the game starts.** `setup.ps1 -Game <dump>` now precompiles the whole shader pack and the GPU pipelines once (about 45 minutes; it's resumable). Making that faster and complete is task #1 below.

**New:** `play.ps1` now turns off the game's stall watchdog (`XCL_NO_WATCHDOG`), so the game waits out slow first-time shader builds in the world instead of quitting. The first world load is slow while the cache fills, but it no longer dies.

**Latest (Nov 24):**
- **World asset streaming fixed.** Map, prop and VFX files failed to load once the world started, because requests went out before the game had filled in where the data goes, and the game then waited forever. Requests now wait briefly for the game to finish, and the runs since have had zero failed loads.
- **Unlit mode (`XCL_FLAT=1`).** Big lighting shaders get a tiny flat grey stand-in, so the world can show without waiting on NVIDIA's slow compiles. Menus and loading screens keep their real shaders.
- **Pipeline journal.** Every GPU pipeline the game creates is recorded, even in runs that crash, and `xcl pipelines <game>` builds them all ahead of time. This is the path to a one-time "build shaders" step instead of compiling at world start.
- **Native launcher.** One exe with the runtime built in: [download it from Releases](https://github.com/ZigZagBoi1/ScarlettPort/releases).
- **World-start GPU crash fixed.** A two-pass mesh draw used to fall back to a draw that read from address 0 and reset the GPU. That draw is now skipped safely (upstream #1124 plus our indirect-draw guard), and the game survives 7+ minutes in the world on an RTX 3060.
- **New in the runtime:** a boot splash from your own game files, click-to-capture mouse with a remappable keyboard layout, local profiles, achievement recording with pop-ups, windowed/borderless/fullscreen with an FPS cap, mute on Alt+Tab, and automatic crash reports.
- **Launcher:** a Display settings page, automatic save backups before each Play, and a crash notice.
- **Current wall:** the world's draws now run, but **the final image stays black**, and memory reaches ~29 GB committed at world start. Drawing the two-pass mesh calls (`XCL_TWO_PASS_INDIRECT=1`, off by default) still resets the GPU on some runs.

Already fixed in this repo's runtime: the 64-bit wait ordering (black screen), the BCPack texture decoder (empty world textures), the `CopyFromSubresource` crash at the end of loading, and runaway shader loops.

---

## 🚀 Run it

> **You need your own unpacked Xbox Series copy of the game.** This repo contains **no game files** of any kind, and never will.

**Requirements:** Windows 10/11 x64 · a D3D12 GPU with Shader Model 6.6 and mesh shaders (RTX 20-series / RX 6000 or newer) · 32 GB RAM recommended · [Rust](https://rustup.rs) (stable MSVC) · Windows SDK (for DXC)

Two ways to run it:

**A. VIctory stack: furthest today** (world geometry on screen, movement tutorial, about 1 fps, final image still black)

```powershell
git clone https://github.com/ZigZagBoi1/ScarlettPort.git
cd ScarlettPort
.\scripts\setup-victory.ps1                                         # build + Agility SDK
.\scripts\play-victory.ps1 -Game "D:\path\to\your\dump" -AutoInput -DebugView
```

**B. XCL + launcher: menus and loading screens at 30 fps**

```powershell
.\scripts\setup.ps1 -Game "D:\path\to\your\dump"     # build + Agility SDK + precompile all shaders (~45 min, once)
.\scripts\play.ps1  -Game "D:\path\to\your\dump" -AutoMenu
```

Or download the one-exe launcher from [Releases](https://github.com/ZigZagBoi1/ScarlettPort/releases).

- `-AutoInput` / `-AutoMenu` press A for you so the menus advance without a controller. `-DebugView` shows one of the game's internal geometry buffers in the window.
- While the game runs, write button names into `press.txt` (e.g. `DOWN DOWN A`) to press them. Handy for scripting and for AI agents testing a build.
- Logs go to `logs\`. Attach one when you open an issue.
- Controls: an Xbox controller works best. On keyboard and mouse, Enter = A, Esc = B, WASD = left stick, and the mouse moves the right stick.

Environment variables and differences between the two: [`docs/RUNTIMES.md`](docs/RUNTIMES.md). Build instructions: [`docs/BUILDING.md`](docs/BUILDING.md). Plan to 30 fps: [`docs/ROADMAP.md`](docs/ROADMAP.md).

---

## 🤖 Task board: grab one, send a PR

Every task is sized for **one person + one AI coding agent**. Pick one, comment on its issue to claim it, and send a PR. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) first (it takes two minutes).

### 🔥 Critical path to gameplay

- [ ] **#1 Zero shader compiles at world load.** `setup.ps1 -Game` precompiles the pack; make sure the world's programs are then *all* cache hits at runtime (`compiling shaders: N done` should stay at 0). Find what still misses (graphics pipelines, mesh passes, split-wave64 variants) and precompile those too.
- [ ] **#2 Keep the watchdog fed.** While a program is still building, keep the game's main-thread heartbeat alive without skipping work. See `pso_async.rs` and issue #505 in the XCL repo for the watchdog's address and logic.
- [ ] **#3 Never read garbage from a skipped dispatch.** When a dispatch is skipped, zero or clamp the indirect-argument buffers it would have written, so an `ExecuteIndirect` can't run for minutes.
- [ ] **#4 Mesh pipelines with the MS in the AS slot.** The game uses these and upstream XCL refuses them; an experimental translation exists in the git history. Make them draw correctly.

### 🎨 Rendering

- [ ] **#5 Why do VIctory's newer wave64 builds render black menus?** VIctory PR #439 and #414 builds draw black, while the older `wave64-emulation` build shows the menus. Bisect it.
- [ ] **#6 Clear VIctory's remaining shader failures.** The biggest groups are SGPR addresses that aren't root parameters (195), wave64 groups larger than 64 threads (155), and descriptors read from computed VGPRs (138).
- [ ] **#7 Faster wave64 on NVIDIA.** Console 64-lane programs run as two 32-lane halves. Profile them and cut the overhead.

### ⚡ Performance

- [ ] **#8 Memory copy bottleneck.** Up to ~600 ms per frame goes to copying title memory in world scenes. Batch it, use async copy queues, or skip clean pages.
- [ ] **#9 Shader cache warm-up script.** Ship a script that fills the cache offline so first launch isn't a slideshow.

### 🧰 Tooling & docs

- [ ] **#10 One-click launcher.** A `.bat` or small GUI that finds the dump, runs setup if needed, and starts the game.
- [ ] **#11 Hardware reports.** Run it on your GPU and post results (GPU, driver, fps, how far it got) to the pinned issue.
- [ ] **#12 CI.** Build both runtimes on Windows on every PR.

---

## 🗂️ What's in here

```
ScarlettPort/
├── scripts/          setup.ps1 / play.ps1 (XCL), setup-victory.ps1 / play-victory.ps1 (VIctory stack)
├── runtime/
│   ├── xcl/          XCL: console OS, D3D12.X, RDNA2 → HLSL → DXIL recompiler; menus and loading at 30 fps
│   └── victory/      VIctory stack: RDNA2 → DXIL directly; world geometry and the tutorial (see SCARLETTPORT.md)
├── launcher/         native one-exe launcher (Rust, egui)
├── patches/          our changes to each runtime, as plain diffs (easy to review and upstream)
├── docs/             STATUS, RUNTIMES, BUILDING, ROADMAP
└── assets/           screenshots
```

---

## ⚖️ Legal

- This project contains **no code, assets or files from the game or its publisher**, and no console SDK code. You must own the game and provide your own dump.
- Nothing here decrypts, unpacks or bypasses DRM.
- `runtime/xcl` is GPL-2.0-only, © the XCL authors. `runtime/victory` is GPL-3.0-or-later, © the VIctory authors. Each keeps its own `LICENSE`. See [`LICENSE.md`](LICENSE.md).

<div align="center">

**If this got you hyped, star it ⭐ and share it. Every PR gets us closer to playable.**

</div>
