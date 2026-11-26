# HUMAN

An experimental Xbox Series X|S to Windows x86-64 / Direct3D 12 compatibility layer written in Rust.

**HUMAN** loads a user-supplied Xbox Series title executable directly in a Windows x86-64 process, provides user-mode runtime services, translates console GPU command lists to host Direct3D 12, detiles console textures, and recompiles console GPU shaders to DirectX Shader Model 6.6 DXIL ahead of time or on demand.

> **Important Notice (No Game Files Included):**
> This repository contains **only original compatibility-layer source code and documentation**. No game executables, archives, shaders, textures, audio, keys, or proprietary assets are included or distributed here. You must supply your own legally obtained files stored **outside** the repository (enforced by `.gitignore` and `cargo xtask policy`). This project is not affiliated with or endorsed by Microsoft or any game developer or publisher.

> **Optimization Pull Requests Wanted:**
> We are actively looking for **Pull Requests focused on CPU, GPU, memory, and shader optimizations**! See [Contributing & Optimization Targets](#contributing--optimization-targets) below for the highest-impact bottlenecks.

---

## Key Features & Enhancements

- **User-Mode Loader & Runtime HLE** (`victory-pe`, `victory-loader`, `victory-hle`): Loads x86-64 PE binaries, provides offline user/licensing/storage stubs, XInput & keyboard input mapping, and parallel DirectStorage / zlib / BCPack decompression.
- **Console Shader Recompiler to SM 6.6 DXIL** (`victory-shader`): Translates console GPU bytecode to validated DXIL with dead-code, constant-folding, value-reuse, and branch-fact optimization passes (`VICTORY_SHADER_OPT`), plus configurable per-stage loop caps (`VICTORY_SHADER_LOOP_LIMIT`, `VICTORY_SHADER_LOOP_LIMIT_CS`).
- **Direct3D 12 Backend** (`victory-gpu`):
  - Bindless descriptor heap mirroring, mesh shader support, and rectangle list geometry expansion.
  - Indirect draw/dispatch argument clamping with dense-stride batch windows (`VICTORY_INDIRECT_WINDOW`) and exact placed buffer views to avoid unused whole-buffer shadow allocations.
  - Ambient indirect diffuse fallback (`VICTORY_AMBIENT`) for Wave32 GPUs when ray-tracing acceleration structures are not built.
- **8 GB VRAM & Streaming Optimizations**:
  - Host mip-level dropping (`VICTORY_TEXTURE_DROP_MIPS=1` or `2`) for large 2D textures.
  - On-demand tiled mip residency (`VICTORY_LEVELS_ON_DEMAND=1`) and 64 MiB placed texture heaps (`VICTORY_PLACED_TEX=1`).
  - GPU-resident shadow buffers (`VICTORY_CARD_BUFFERS_MIN_MB=1`, `VICTORY_CARD_BUFFERS_MB=512`) and zero-copy in-place private heaps (`VICTORY_INPLACE=1`).
- **Multi-Threaded Submission & Relay**:
  - Async submission thread (`VICTORY_ASYNC_SUBMIT=1`), dual-queue copy-back relay (`VICTORY_RELAY=2`, `VICTORY_QUEUE2=1`), SIMD relay merge, and hybrid CPU fast-core thread scheduling.
- **Console Profiles**: Supports both Series X (`--console series-x`, default) and Series S (`--console series-s`, recommended for 8 GB GPUs).

---

## Workspace Architecture

| Crate | Purpose |
|-------|---------|
| `apps/victory` | CLI entry point (`run`, `translate`, `inspect`, `census`, `shader-info`, `config`) |
| `crates/victory-core` | Configuration (`victory.toml`), paths, and repo-safety checks |
| `crates/victory-pe` | PE parsing and import/export inspection |
| `crates/victory-loader` | Binary mapping, relocations, and runtime patching |
| `crates/victory-hle` | Console OS, filesystem, threading, audio, and input HLE |
| `crates/victory-gpu` | Direct3D 12 translation, memory shadows, textures, and indirect execution |
| `crates/victory-shader` | Console GPU ISA decoder, IR lowering, optimization, and DXIL emitter |
| `crates/victory-formats` | Console texture swizzle/detile layouts, BCPack, and audio formats |
| `crates/victory-pipeline` | Pipeline state tracking and caching |
| `crates/victory-game` | Title-agnostic build identity matching and container helpers |
| `xtask` | Asset-policy enforcement (`cargo xtask policy`) and git hook installer |

---

## Requirements & Building

- **OS:** Windows 10 / 11 x64
- **CPU:** x86-64 with AVX2
- **GPU:** Direct3D 12 with Shader Model 6.6 & Mesh Shaders
- **SDK:** Windows 10/11 SDK (`dxcompiler.dll` / `dxil.dll`, e.g. `C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64` via `XCL_DXC_DIR`)
- **Toolchain:** Rust (pinned in [rust-toolchain.toml](rust-toolchain.toml))

```powershell
# 1. Install the asset-policy pre-commit hook
cargo xtask install-hooks

# 2. Create your local git-ignored config and point game_dir outside the repo
copy victory.example.toml victory.toml

# 3. Run unit tests & asset-policy verification (no external files required)
cargo test --workspace
cargo run -p xtask -- policy

# 4. Build the release binary
cargo build --release -p victory
```

---

## Usage

### Pre-Warm Shaders

Pre-translating shaders avoids cold-compile stalls in-game. Ensure `VICTORY_SHADER_LOOP_LIMIT_CS` matches the value you use when running, because the shader cache keys on it:

```powershell
$env:XCL_DXC_DIR = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64"
$env:XCL_ADAPTER = "nvidia"
$env:VICTORY_SHADER_LOOP_LIMIT_CS = "192"
.\target\release\victory.exe translate "<path-to-shader-archive>" --warm all
```

### Run a Title

Use the tuned NVIDIA launcher script (Series S profile recommended for 8 GB VRAM GPUs):

```powershell
.\scripts\play-nvidia.ps1 -Title "<path-to-title.exe>" -Console series-s
```

Or invoke `victory.exe` directly:

```powershell
.\target\release\victory.exe run "<path-to-title.exe>" --execute --console series-s
```

### Keyboard Stand-In Controls

When no XInput controller is connected, the keyboard maps to a standard pad while the window has focus:

| Keys | Pad Input |
|------|-----------|
| `W A S D` / `I J K L` | Left / Right Stick |
| Arrow keys | D-Pad |
| `Enter`, `Backspace`, `X`, `Y` | A, B, X, Y |
| `Q` / `E`, `Z` / `C` | Shoulders (LB/RB), Triggers (LT/RT) |
| `F` / `H` | Stick clicks (L3 / R3) |
| `Esc`, `Tab` | Menu, View |
| `F11` or `Alt+Enter` | Toggle windowed / borderless |

---

## Key Environment Switches

| Variable | Recommended | Effect |
|----------|-------------|--------|
| `XCL_ADAPTER` | `nvidia` | Selects the discrete GPU on hybrid systems |
| `VICTORY_AMBIENT` | `0.6` | Injects indirect diffuse fallback on Wave32 GPUs |
| `VICTORY_TEXTURE_DROP_MIPS` | `1` (Series S) / `2` (4K) | Drops `N` largest mip levels on host copies to fit 8 GB VRAM |
| `VICTORY_LEVELS_ON_DEMAND` | `1` | Allocates tiled texture mips on demand |
| `VICTORY_PLACED_TEX` | `1` | Sub-allocates placed textures from 64 MiB heaps |
| `VICTORY_CARD_BUFFERS_MIN_MB` | `1` | Promotes buffers `>= 1 MiB` to GPU-resident shadow copies |
| `VICTORY_CARD_BUFFERS_MB` | `512` | GPU-resident buffer shadow budget (MiB) |
| `VICTORY_INPLACE` | `1` | Zero-copy private heap placement for eligible buffers |
| `VICTORY_RELAY` | `2` | Enables async copy-back relay thread |
| `VICTORY_ASYNC_SUBMIT` | `1` | Offloads command-list preparation/submission from render thread |
| `VICTORY_QUEUE2` | `1` | Uses copy queue for shader write-back fetches |
| `VICTORY_INDIRECT_WINDOW` | `1` | Clamps consecutive indirect draws in batch windows |
| `VICTORY_SHADER_LOOP_LIMIT_CS` | `192` | Caps compute shader loop iterations per lane (part of cache key) |
| `VICTORY_FPS_LIMIT` | `0` / `30` / `60` | Caps host presentation rate |

---

## Contributing & Optimization Targets

**Pull requests for performance and memory optimizations are very welcome.** Whether it's shaving microseconds off per-draw CPU overhead, reducing GPU command-list barriers, improving VRAM residency on 8 GB cards, or tightening DXIL shader codegen, every measurable improvement helps.

High-impact areas to target:

1. **Indirect Execution & Draw Submission (`crates/victory-gpu/src/indirect.rs`, `draw.rs`):**
   - Reducing per-record argument clamping overhead and coalescing barriers/dispatches across indirect draw windows.
   - Cutting per-draw descriptor table, root-parameter, and command-signature overhead.
2. **CPU <-> GPU Shadow Memory & Relay (`crates/victory-gpu/src/shadow.rs`, `plaincopy.rs`, `inplace.rs`):**
   - Optimizing dirty-page scanning, SIMD diff/merge throughput, and copy-back latency.
   - Expanding safe zero-copy `VICTORY_INPLACE` heap coverage.
3. **8 GB VRAM Residency & Texture Streaming (`crates/victory-gpu/src/texture.rs`, `tiles.rs`, `placed.rs`):**
   - Faster tiled/BC detiling, lower staging allocation churn, and smarter eviction under tight DXGI memory budgets.
4. **Shader Recompiler & DXIL Passes (`crates/victory-shader`):**
   - Tighter Wave64-on-Wave32 lowering, eliminating redundant lane/waterfall operations, and faster pipeline compilation.

Before opening a PR, please verify:
- `cargo test --workspace` passes.
- `cargo run -p xtask -- policy` passes with zero violations (strict zero-game-asset rule).

---

## Credits & License

- Built on upstream open-source work:
  - **[VIctory](https://github.com/Marvisak/VIctory)** by Marvisak and contributors (`GPL-3.0-or-later`)
  - **[XCL](https://github.com/ivall/xcl)** by ivall and contributors (`GPL-2.0-only` references rewritten in Rust)
  - Community contributions from `victory-amd` and fork contributors
- Licensed under **GPL-3.0-or-later**. See [LICENSE](LICENSE).
