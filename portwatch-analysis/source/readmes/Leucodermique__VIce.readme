<p align="center">
  <img src="launcher/studio/studio-emblem.png" alt="VIce Studio" width="190" />
</p>

<h1 align="center">VIce · VIce Studio</h1>

<p align="center">
  <strong>Xbox Series X|S → Windows 11 Native Compatibility Layer (Rust / Direct3D 12) &amp; VIce Studio Launcher</strong>
</p>

<p align="center">
  <em>AI-managed consolidated build fed continuously from community commits across the VIctory ecosystem.</em>
</p>

---

## Overview

**VIce** is a consolidated distribution and dedicated desktop launcher (**VIce Studio v4**) built on top of the open-source **[VIctory](https://github.com/Marvisak/VIctory)** compatibility layer, focused on running Xbox Series X|S titles natively on Windows 11 — with extensive real-hardware tuning and validation on **NVIDIA GeForce RTX 4070 Laptop (8 GB VRAM, 32-lane warps) / 16 GB RAM**.

> **Legal Notice:** This repository contains **no game files, binaries, code, or proprietary assets**. You must supply your own legitimately obtained files at runtime. Licensed under **GPL-3.0-or-later** in full compliance with upstream [VIctory](https://github.com/Marvisak/VIctory). It is not affiliated with or endorsed by any game developer or publisher.

---

## AI Governance & Model Attribution

This repository is actively maintained, integrated, tested, and published through an **AI-driven engineering workflow**, combining our own work with community-contributed AI-assisted fixes from upstream forks:

| Area | AI Model / Agent | Scope of Work |
|---|---|---|
| **VIce Project Maintenance & Integration** | **Antigravity (Google DeepMind / Gemini)** | Continuous multi-fork curation and cherry-picking across `Marvisak/VIctory`, `fxceless/victory-fork`, and `LooperSalty/victory`; merge-conflict resolution; automated unit-test & `--release` validation; repository & GitHub release management. |
| **NVIDIA RTX 8 GB Debugging & Shader Fixes** | **Antigravity (Google DeepMind / Gemini)** | Live `play.log` telemetry analysis, anti-TDR loop bounds (`LOOP_LIMIT = 16384`), DXIL disassembly & `descriptor_data()` fixes unlocking `PS_PuddleDetect` and `ShallowWaterSim`, and `XboxBvhBuilder.dll` wave-32 validation testing. |
| **VIce Studio v4 Launcher & Branding** | **Antigravity (Google DeepMind / Gemini)** | End-to-end backend (`studio_server.py`) & frontend (`studio.html`) architecture, Win32 game-window state detection, zero-blocking in-memory telemetry, automatic token refresh, password-protected developer mode, cinematic startup intro, and the generated **VIce Studio** neon emblem (`studio-emblem.png`). |
| **Upstream GPU / Shader Architecture** | **Claude (Anthropic — Claude Code / Opus / Fable)** | Co-author of core upstream & `fxceless/victory-fork` breakthroughs integrated here: async `VICTORY_RELAY` / `VICTORY_LATE_WAIT`, GPU-side card-buffer comparison, Depth Bounds Test (`#82`), pre-bake bindless texture uploads, helper-lane `v_readfirstlane` fix (`#1733`), and shader cleanup passes. |
| **Upstream D3D12 Fixes** | **Gemini (Google)** | Co-author of upstream D3D12 device fixes integrated here (including real `GetDeviceRemovedReason` `#928`). |

### Automatically Fed Community Sources

VIce tracks and integrates verified advancements from:
1. **[Marvisak/VIctory](https://github.com/Marvisak/VIctory)** — upstream foundation (PE/XEX loader, HLE runtime services, D3D12 backend, RDNA2→DXIL shader recompiler; **106+ recent PRs** integrated).
2. **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)** — NVIDIA RTX rendering fixes, VRAM deduplication, Depth Bounds Test (`#82`), pre-bake texture uploads, Geometry Shaders (`#381`), AVX2 relay merge (`#384`), and skin/wall race fixes (`#191`, `#206`).
3. **[LooperSalty/victory](https://github.com/LooperSalty/victory)** — dedicated D3D12 `COPY` queue, DirectStorage physical-page GPU notifications (`VICTORY_DSTORAGE_NOTIFY=1`), BCPack BC7 fix, MIMG fixes, `late waits` in-place placement guards, and `xg_xs.dll` local oracle support.
4. **[XCL](https://github.com/ivall/xcl)** (GPL-2.0-only) — referenced by upstream authors for console behavior verification.

---

## Detailed Progress & Milestones

### Current Status (2026-11-25 — Tested on Windows 11, RTX 4070 Laptop 8 GB, 16 GB RAM, Series X Profile)

| Stage | Current State |
|---|---|
| **Boot, first-boot setup & menus** | Working cleanly at **30 fps** (zero intro video flicker). |
| **Opening cutscene** | Plays start-to-finish, lit and in order (title cards, credits, night/dusk exterior shots). |
| **Saves & checkpoints** | Autosave checkpoint creation and reload working. |
| **First playable scene (prison cell & yard)** | Renders correctly with walls, ceiling, character skin/hair, sunlit exterior, HUD, pause menu, and pad/keyboard input. |
| **Shader coverage (NVIDIA 32-lane)** | **25,948 / 25,953 shaders translated (99.98%)** via `fxceless` PRs `#854` + `#993` + `#1006` + `#501` (**100% Pixel Shaders, 100% Vertex Shaders, 195 Geometry Shaders**, paired wave64 on 32-lane NVIDIA, mesh >32 KiB linking, and `f5e50eb2108c425b` integer-RT fix). |
| **Ray Tracing (BVH Builder)** | **Live ray-tracing structure builder (`VICTORY_BVH_BUILDER=1`, PR `#994`)** runs all 52 `XboxBvhBuilder.dll` shaders cleanly without crashing, lighting indirect/shaded interiors and faces (toggleable in VIce Studio settings). |
| **VRAM & In-world frame rate** | **Levels on demand (`VICTORY_LEVELS_ON_DEMAND=1`)** saves **~3.1 GB VRAM** on RTX 4070 8 GB; full `fxceless/main` (`3973179`) speed stack (`ASYNC_SUBMIT`, `QUEUE2`, `INDIRECT_WINDOW` + anti-TDR `DRIVER_WATCH`, `COPY_PLAIN`, `JOIN_PARTS`, `BACK_OWN_VIEW`) reaches **7–9.6 fps** in the first rooms (**10–12 fps** in lighter views). |

### 1. Rendering, Shaders & Ray Tracing (`fxceless 3973179` + PRs `#854`, `#993`, `#994`, `#1006`, `#501`, `#632`, `#684`, `#238`)
- **99.98% Shader Translation on NVIDIA 32-lane GPUs (`#854` + `#993`)**: paired wave64 execution on 32-lane hosts, mesh-to-pixel linking for >32 KiB mesh outputs (71 pedestrian/vehicle/prop mesh shaders), native **Geometry Shaders (195 programs)**, console-accurate loops, dispatches past 65,535 groups in X, and **100% of Pixel & Vertex shaders** passing (`12,067/12,067` PS, `2,192/2,192` VS).
- **Live Ray Tracing Structure Builder (`#994`)**: dispatches `XboxBvhBuilder.dll` by thread counts (fixing multi-GB wild writes), makes raw-address title memory ready for BVH passes, and keeps node tests safe when toggled off (`VICTORY_BVH_BUILDER=0/1`).
- **First Room Renders Right (`a26859f`, `8dd30ab`)**: mirrors byte-copied descriptor records (`VICTORY_HEAP_SYNC`, ~40,000/frame), gives unaligned buffer views their own copy (`VICTORY_VIEW_OWN_COPY`), guards every view of physical pages (`VICTORY_VIEW_GUARD`), opens guards on DirectStorage physical-page writes (`VICTORY_PAGE_WRITES`), and reserves VRAM for first-frame buffers and render targets.
- **Levels on Demand (`VICTORY_LEVELS_ON_DEMAND=1`)**: allocates VRAM only for mip levels actually streamed in by the title — saving **~3.1 GB of VRAM** on RTX 4070 8 GB — paired with `#632` (stale unmapped checks no longer wipe freshly-written skin/face texture views) and `#1006` (`code_dword` table start fix saving GBs of NVIDIA VRAM).
- **Pipeline & Descriptor Correctness**: `#501` disables blending on integer render targets (`R8_UINT`, fixing the refused mesh pipeline `f5e50eb2108c425b`), `#684` fixes 32-bit integer typed buffer views, `#238` zeroes blend/depth-stencil/stream padding for reliable D3D12 pipeline-library hits, and Depth Bounds Test (`#82`) illuminates room lamps cleanly.

### 2. Frame Rate Breakthrough (1–2 fps → 7–9.6 fps on RTX 4070)
- **Dedicated Async Submit & Copy Queue (`f85101b`, `a253706`, `0b0074e`, `3973179`)**: `VICTORY_ASYNC_SUBMIT=1`, `VICTORY_QUEUE2=1`, `VICTORY_RELAY=1`, `VICTORY_JOIN_PARTS=1` (29 → 9 submissions/frame), `VICTORY_BACK_OWN_VIEW=1`, `VICTORY_COPY_PLAIN=1`, `VICTORY_TEXTURE_NO_WAIT=1`, and P-core pinning (`VICTORY_FAST_CORES`).
- **Safe Indirect Draw Windows (`VICTORY_INDIRECT_WINDOW=1`) + Anti-TDR `VICTORY_DRIVER_WATCH`**: accelerates indirect draw bursts while watching the Windows display driver event log and automatically disabling draw windows ahead of any potential TDR/device loss.
- **Fast Descriptor Heap Sync & Write-Watch (`9376fd6`, `#670`)**: cuts descriptor sync from `70–220 ms` to **~3 ms/frame** via per-slot fingerprinting and skips ~3,600 failing kernel write-watch calls/frame.
- **Pipeline Worker Unblocking**: tuned `VICTORY_PIPELINE_COMMIT_MB=768` and `VICTORY_PIPELINE_WAIT_MS=1000` for 16 GB RAM hosts so background pipeline workers never stall during cutscene transitions, backed by full `shaders.rpf` pre-warming.

### 4. VIce Studio v4 Launcher (`launcher/studio/`)
- **Sleek GTA 6 sunset glassmorphism UI** with generated neon **VIce Studio** emblem (`launcher/studio/studio-emblem.png`) and skippable 2-second cinematic startup intro.
- **Unified Play / Stop toggle** synced live to the actual Windows game window via Win32 `EnumWindows` / `IsWindowVisible` (sends graceful `WM_CLOSE` first so the D3D12 pipeline cache saves cleanly on exit).
- **Zero "Unable to fetch" errors**: `ThreadingHTTPServer` with `allow_reuse_address` + `daemon_threads`, supports both `127.0.0.1` and `localhost`, automatic token renewal on `401` via `/api/token`, JSON error reporting, and `< 1 ms` in-memory live telemetry (FPS, ms/frame, draws/frame) without re-reading multi-MB log files from disk.
- **Password-protected Developer Mode** (PBKDF2-SHA256 via `%LOCALAPPDATA%\VIce\studio-auth.json`): unlocks **Diagnostics** (live GPU counters & D3D12 ID histograms), server-filtered **Logs**, build selection, and engine toggles (`VICTORY_RELAY=2`, `VICTORY_CARD_BUFFERS_MIN_MB=1`, `VICTORY_CARD_BUFFERS_MB=768`, `VICTORY_DSTORAGE_NOTIFY=1`, D3D12 debug, WARP).

---

## Launching VIce Studio

```powershell
# Build the optimized engine binary
cargo build --locked --release -p victory

# Launch VIce Studio (opens the local app window on http://127.0.0.1:17642/)
pythonw.exe launcher\studio\studio_server.py
```

---

## Getting started

Requirements: Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with
shader model 6.6 (and mesh shaders for the world), Rust (pinned in
`rust-toolchain.toml`).

To install Rust, use rustup (`winget install --id Rustlang.Rustup -e`, or
the installer from https://rustup.rs). The first `cargo` command in this
repository then fetches the pinned toolchain. Building needs the MSVC C++
build tools: Visual Studio or its Build Tools with the "Desktop development
with C++" workload.

The title also needs several GiB of available Windows commit at startup.
Check **Committed** under **Task Manager → Performance → Memory**. If
`crashes.log` reports Windows error 1455, close other applications or increase
the Windows paging file size, then retry.

```powershell
cargo xtask install-hooks                # asset-policy check on every commit
copy victory.example.toml victory.toml   # then set your paths (outside the repo)
cargo test --workspace                   # needs no game data
cargo run -p victory -- config           # check your paths
```

Run the title:

```powershell
cargo build --release -p victory
target\release\victory.exe run <game dir>\<the title's exe> --execute
```

The window caption shows the framerate. Saves, settings and `crashes.log`
are kept under the data folder (default `%LOCALAPPDATA%\victory\data`), derived
data under the cache folder.

Set `VICTORY_WINDOW_MAX=1920x1080` before launching to limit the title's
top-level window to that bounding box. Smaller windows keep their size,
larger windows keep their proportions, and the monitor's work area still
limits them. This scales the displayed image; it does not change the
console render resolution or the swap-chain buffers. With the variable
unset, window sizing is unchanged.

Input: XInput pads. With none connected the keyboard is a pad while the
title's window has focus:

| Keys | Pad |
|------|-----|
| W A S D / I J K L | left / right stick |
| arrows | D-pad |
| Enter, Backspace, X, Y | A, B, X, Y |
| Q / E, Z / C | shoulders, triggers |
| F / H | stick clicks |
| Esc, Tab | Menu, View |

## Commands

```
victory inspect <exe|dll> [--imports] [--exports]
victory census [paths...] [--missing] [--strict]
victory lib-exports <import.lib> [--list]
victory shader-info [paths...] [--verbose] [--disasm]
victory translate [paths...] [--validate] [--pipelines] [--list] [--jobs N]
victory run <exe> [--execute] [--unimplemented trap|zero] [--strict]
            [--console series-x|series-s] [-- <title arguments>]
victory config
```

Logging: `VICTORY_LOG=victory_loader=trace,info` (a release build logs
info and above).

### Windows shader-test validator

The shader tests use `dxil.dll` to validate Shader Model 6.6 containers.
An older Windows SDK validator can load successfully but reject them with
`Unknown shader model 'ps_6_6'`. If this happens, use a current x64 validator
from [Microsoft's DirectX Shader Compiler releases](https://github.com/microsoft/DirectXShaderCompiler/releases)
or a current Windows SDK. Set its path for the test session:

```powershell
$env:VICTORY_DXIL = 'C:\tools\dxc\bin\x64\dxil.dll'
cargo test -p victory-shader --lib --locked -- --test-threads=1
```

Without this override, the validator loader selects the newest installed
Windows SDK's `bin/<version>/x64/dxil.dll`, then falls back to the DLL search
path when no SDK copy is found. This is a test/offline-validation dependency;
the translated shaders do not require it at runtime.

## Debugging

A release build has no debugging aids. Build them in with

```powershell
cargo build --profile diag -p victory --features diagnostics   # target\diag\victory.exe
```

The on/off switches below (`...=1`) are off when unset or set to `0`.

| Variable | Effect |
|----------|--------|
| `VICTORY_LOG=<target>=debug,...` | debug and trace output |
| `VICTORY_STACKS=20,60` | every thread's stack at those seconds |
| `VICTORY_WATCH=<rva>,...` | logs a title u32 when it changes |
| `VICTORY_POKE=<rva>:<byte>,...` | writes a title byte twice a second (a hang watchdog's tick, say) |
| `VICTORY_KEYS=30:Enter,35:X` | presses keys at those seconds, focus or not |
| `VICTORY_CRASH_BREAKPOINTS=1` | appends first-chance breakpoints to `crashes.log`, including ones a handler may recover from |
| `VICTORY_CRASH_SAVE=<rva>:<len>,...` | saves title memory to the cache folder on a crash |
| `VICTORY_CAPTURE=<dir>` | saves presented frames (powers of two, or `VICTORY_CAPTURE_FRAMES=<list>`) |
| `VICTORY_DUMP_TARGETS=1` | with the two above, saves every render target of those frames |
| `VICTORY_D3D12_DEBUG=1` | host debug layer |
| `VICTORY_D3D12_GBV=1` | with the above, GPU-based validation (bad descriptor use reported, not faulted; slow) |
| `VICTORY_D3D12_DRED=1` | on a GPU failure, the allocation hit and the commands in flight |
| `VICTORY_PIPELINE_WAIT_MS=24` | reduce the per-frame wait for background pipeline creation from the default of 500 ms. A draw can be omitted until its pipeline is ready |
| `VICTORY_SKIP_PIPELINES=<hash>,...` | omit draws and dispatches, including indirect ones, whose pipeline contains a listed 16-digit shader hash |
| `VICTORY_GPU_TIMING=1` | with the above, each list of a submission run and timed on its own; slow lists logged with their slowest commands |
| `VICTORY_D3D12_WARP=1` | host device on the software adapter (slow; cannot reset the driver) |
| `VICTORY_SHADER_LOOP_LIMIT=<n>` | translated shader loops stop after `n` iterations per lane instead of 2^20 (own shader cache entries); if a lower `n` makes world frames much faster, loops hitting the limit are what makes them slow |
| `VICTORY_AUDIO_CAPTURE=<file.wav>` | records what the title plays (our process only) |
| `VICTORY_XMA_DUMP=<dir>` | saves the first 32 XMA voices' context and input |

Every build appends unhandled exceptions, panics, and host GPU failures to
`crashes.log` in the title's data folder.

For a startup breakpoint (`0x80000003`), run the diagnostics build with
`VICTORY_CRASH_BREAKPOINTS=1`. Keep the console output along with the new
`crashes.log` entries. A host DLL refusal includes the caller stack in the
console output. The refusal is expected for DLLs outside the host policy,
including `rpcrt4.dll`.

On Series 1.0.2.1, a missing `appdata0.rpf` reproduced the breakpoint at
`+0x2237178` before the first window. Restore the archive from the same
package beside the title executable. `run --execute` checks that it can
read the RPF9 header before starting this build.

To compare hardware and software rendering, repeat with
`VICTORY_D3D12_WARP=1` and check the console for
`host device on the software adapter (WARP)` to confirm the WARP device was
created. Compare the exception's module and offset, stack frames, and
preceding messages across the two runs.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
