<p align="center">
  <img src="xHoly-logo.svg" width="160" alt="xHoly logo"/>
</p>

<p align="center"><b>Redeem Your Games</b></p>

# xHoly — Xbox One & Xbox Series X|S Emulator

xHoly is an independent, open-source emulator for **Xbox One** and **Xbox
Series X|S** software, written primarily in **Rust** and designed for
**Windows x86-64** and **Linux x86-64** hosts. It is built on a
**High-Level Emulation (HLE)** architecture: instead of simulating the
console's hardware, xHoly implements the console's software interfaces —
imported DLL functions, memory services and system services — directly on
the host.

> **Status: early development.** xHoly can load, validate and execute
> bounded PE32+ guest programs in its own x86-64 pipeline and presents
> host-rendered frames. **No retail Xbox title has been confirmed to boot
> or run.** See [Compatibility and current limitations](#7-compatibility-and-current-limitations).

---

## Table of contents

1. [What is xHoly?](#1-what-is-xholy)
2. [Project vision and goals](#2-project-vision-and-goals)
3. [Supported platforms](#3-supported-platforms)
4. [Architecture](#4-architecture)
5. [Implemented features](#5-implemented-features)
6. [Screenshots and interface overview](#6-screenshots-and-interface-overview)
7. [Compatibility and current limitations](#7-compatibility-and-current-limitations)
8. [Installation and usage](#8-installation-and-usage)
9. [Building from source](#9-building-from-source)
10. [CLI reference](#10-cli-reference)
11. [Development roadmap](#11-development-roadmap)
12. [Contributing](#12-contributing)
13. [Third-party components and acknowledgements](#13-third-party-components-and-acknowledgements)
14. [License](#14-license)
15. [Legal information and independence](#15-legal-information-and-independence)

---

## 1. What is xHoly?

xHoly is an emulator project targeting the Xbox One and Xbox Series X|S
consoles. The long-term goal is to run compatible retail and homebrew
software on Windows and Linux PCs, covering the console's system
services, memory model and graphics stack through high-level emulation.

The project is organized around a single Rust crate (`xholy`) that
contains the emulator core, the loader, the guest CPU pipeline, the HLE
runtime, the GUI frontends and a set of independently testable
infrastructure modules. An optional Scala runtime exists for JVM-based
game modules and a Scala.js web bundle.

xHoly is under active development by an independent community
contributor. It is not a finished product, and its current capabilities
are deliberately described below in concrete terms.

## 2. Project vision and goals

The project's direction is defined in [ROADMAP.md](ROADMAP.md) and the
binding architecture decision record
[docs/adr/0001-target-architecture.md](docs/adr/0001-target-architecture.md):

- Emulate **Xbox One and Xbox Series X|S** software on **Windows and
  Linux x86-64** hosts.
- Use **HLE**: reimplement console system interfaces (XAM-style services,
  memory services such as `xmem`, graphics APIs such as `d3d12_xs`) as
  host-side modules instead of simulating console hardware cycle by
  cycle.
- Keep the graphics path **host-vendor-independent** (wgpu; Vulkan is a
  candidate cross-platform backend).
- Keep the codebase **modular and maintainable**: every subsystem is an
  independent, unit-tested module; diagnostics and progress are derived
  from code, not asserted in prose.
- Stay an **independent open-source project** with no Microsoft SDK
  dependency as an architectural goal.

## 3. Supported platforms

| Platform | State |
|---|---|
| Windows x86-64 | **Primary development target.** Unit tests, integration tests, windowed GUI and CLI verified on the development host. |
| Linux x86-64 | **Supported build target.** CI runs `cargo test` and `cargo clippy` on Ubuntu; not verified locally on this machine. |
| ARM64 hosts, macOS | **Not supported.** Outside the target scope. |

Guest targets are Xbox One / Xbox Series X|S (x86-64 guests). Legacy
Xbox 360 code exists behind feature flags and is outside the current
target scope.

## 4. Architecture

xHoly's core pipeline for guest execution is:

```
PE32+ image ──► loader/pe64.rs ──► guest memory ──► X64Cpu (bounded x86-64)
   (validate,              (section mapping,      (subset decoder /
    sections, IAT)          relocations, IAT)       interpreter)
                                      │
                                      ▼
                            pipeline/mod.rs GuestSession
                            (imports → HleRuntime dispatch,
                             diagnostics, execution report)
                                      │
                    ┌─────────────────┼──────────────────┐
                    ▼                 ▼                  ▼
              hle/runtime.rs     hle/xmem.rs        hle/graphics.rs
              (dispatch,         (guest heap:       (guest/host
               structured         alloc/free,        seam; no fake
               results)           tracking)          D3D12)
```

| Component | Path | State |
|---|---|---|
| PE32+ parser: validation, section mapping, relocations, IAT | `src/core/loader/pe64.rs`, `src/core/pipeline/imports.rs` | Implemented for synthetic PE32+ fixtures; no delay-load, TLS callbacks or encrypted retail packages |
| Read-only import analyzer | `src/core/loader/import_analyzer.rs` | Implemented (`--analyze`, `--json`) |
| Guest memory | `src/core/memory.rs`, `src/core/kernel/pte.rs` | Flat guest address space implemented; PTE model only, no MMU |
| Bounded x86-64 CPU | `src/core/cpu/x64.rs` | Partial: bounded instruction subset, not a complete x86-64 emulator |
| Microsoft x64 calling convention | `src/core/pipeline/abi.rs` | Partial: RCX/RDX/R8/R9 + stack args, shadow space, stack bounds; no XMM/float args |
| HLE API registry | `src/core/hle/mod.rs` | Implemented: metadata registry with verified-evidence discipline |
| HLE dispatch runtime | `src/core/hle/runtime.rs` | Implemented: structured Completed/Unsupported/Unknown/Failed results |
| xmem guest memory services | `src/core/hle/xmem.rs` | Partial: `XMemAlloc`/`XMemFree` shims; attribute bitfields not decoded |
| Guest execution pipeline | `src/core/pipeline/mod.rs` | Implemented for synthetic PE32+ guests |
| Execution diagnostics + trace | `src/core/pipeline/diagnostics.rs`, `src/core/pipeline/trace.rs` | Implemented (`--trace`, `--trace-out`, trace viewer in GUI) |
| Execution reports | `src/core/pipeline/mod.rs` (`ExecutionReport`) | Implemented |
| XEX2 fixture loader | `src/core/loader/xex_parser.rs`, `games/minimal/` | Partial: contiguous fixture layout only; no retail XEX |
| AArch64 test interpreter | `src/core/cpu/interpreter.rs` | Experimental test harness (not the Xbox ISA) |
| WASM JIT research subset | `src/jit/` | Experimental: x86-64 → WASM subset compiler + interpreter |
| Host GPU presentation | `src/gui/windowed/renderer.rs` | Partial: wgpu presentation + guest framebuffer blit; **no guest draw-call translation** |
| Guest→host graphics seam | `src/core/hle/graphics.rs` | Architecture only; no fake device or shader translation |
| Shader work | `src/core/shader/dxil_parser.rs` | Partial: DXIL parsing research; no Xbox shader compatibility |
| Swapchain state | `src/gpu/swapchain.rs` | Model only |
| Scala runtime bridge | `scala/`, `src/runtime/scala_bridge.rs` | Implemented bridge; JVM/Scala.js modules |
| Windowed GUI (winit + wgpu) | `src/gui/windowed/` | Implemented; synthetic-guest launch path, HLE trace viewer, console log |
| Terminal UI (ratatui) | `src/gui/ratatui_backend.rs` | Implemented |
| Infrastructure modules | `src/config`, `src/save`, `src/input`, `src/logging`, `src/mod_system`, `src/cheat_engine`, `src/benchmark`, `src/cloud`, `src/network`, `src/telemetry`, `src/multiplayer`, `src/storage`, `src/utils`, `src/presence` | Implemented as headless, unit-tested modules; several are models without real backends (see limitations) |

## 5. Implemented features

Verified against the repository (unit/integration tests green on the
development host):

- **PE32+ loading pipeline** — parse, validate, map sections, apply
  relocations, resolve imports for synthetic PE32+ guest images.
- **Bounded x86-64 guest execution** — a documented instruction subset
  executes real guest code end-to-end (load → run → HLE dispatch →
  exit), with configurable Microsoft x64 ABI calling convention
  (integer args in RCX/RDX/R8/R9 plus stack arguments, 32-byte shadow
  space, stack bounds checking).
- **HLE runtime** — a single registry-driven dispatcher that separates
  implemented functions from unsupported/unknown ones and returns
  structured results; `XMemAlloc`/`XMemFree` are the first implemented
  guest services backed by a tracked guest heap.
- **Diagnostics and tracing** — per-dispatch diagnostic events, an
  execution report, `--trace`/`--trace-out`/`--json` CLI export, and a
  trace viewer inside the windowed GUI.
- **Import analysis** — `--analyze` produces a read-only compatibility
  report classifying every import as implemented / partially
  implemented / unsupported / unknown, with evidence strings.
- **Minimal guest fixture** — `games/minimal/` is a real on-disk guest
  image (XEX2 header + payload) that runs through the loader, kernel
  and interpreter path and writes a guest framebuffer the GUI blits.
- **Windowed GUI** — launcher-style UI (winit + wgpu, auto GPU API:
  Vulkan/OpenGL/software), game browser for mounted media, guest launch
  path, console log, HLE trace viewer, Discord Rich Presence, themes,
  post-processing (bloom, tone mapping, FXAA/MSAA).
- **Terminal UI** — ratatui frontend with the same launch path.
- **Infrastructure** — config layering/hot-reload, save system,
  input state model, logging, mod loader, cheat engine, benchmarks,
  cloud/network/telemetry abstractions, multiplayer model, storage
  layer, progress tracking derived from `progress.json`.

## 6. Screenshots and interface overview

No screenshots are bundled in this repository yet. The windowed GUI is a
launcher-style interface with a game grid, a detail panel (metadata,
console output, HLE trace), a toolbar with launch/settings controls and
an emulation overlay (Ctrl+Alt+T). The terminal UI provides the same
launch path in a console.

## 7. Compatibility and current limitations

This section is normative: it describes what xHoly **cannot** do today.

- **No retail Xbox game is confirmed to boot or run.** All verified
  execution uses synthetic or bundled test guest images.
- **The guest CPU supports only a bounded x86-64 instruction subset.**
  It is sufficient for test programs, not a complete x86-64 emulator;
  retail binaries use far more of the ISA.
- **HLE API coverage is incomplete.** Only `xmem`'s
  `XMemAlloc`/`XMemFree` are implemented; most documented Gen9 imports
  are classified `Unknown` (no reliable public documentation) or
  `Unsupported`.
- **Microsoft x64 ABI support is limited** — integer arguments and
  stack passing only; XMM/float arguments are not implemented.
- **The GPU path is not an Xbox GPU emulator.** There is no guest
  draw-call translation, no D3D12 device emulation and no Xbox shader
  compatibility; the GUI presents host-rendered frames and blits the
  test guest's framebuffer.
- **GUI integration for PE32+ guest execution is partial** — the
  pipeline runs headless; the GUI's guest launch path targets the
  bundled fixture images.
- **Retail package containers are not supported** — encrypted retail
  packages are not read, and no DRM/encryption bypass is planned.
- **XAM service layer is blocked** — no verified Xbox Series X|S XAM ABI
  exists in the codebase.
- **Infrastructure modules are mostly headless models** — e.g. no real
  network transport, no Lua cheat compiler, no multiplayer netcode.

## 8. Installation and usage

### Prerequisites

- Rust toolchain (stable; `rustup` recommended). The crate builds with
  the default toolchain — no pinned version is required by the
  manifest.
- Windows x86-64 or Linux x86-64.
- For the Scala runtime: a JDK and `sbt` (optional; see below).
- For the native window-manager demo: a C++17 compiler and CMake
  (optional; `cpp/window_manager/`).

### Prebuilt binary

No prebuilt releases are published by this repository. Build from
source (below).

### Running

```sh
cargo build --release
./target/release/xholy --help
```

Scan mounted media and launch the GUI:

```sh
xholy --drives                              # detect optical drives
xholy --mount "D:\\" --list                  # scan a physical disc
xholy --mount game.iso --list                # scan an ISO image
xholy --mount games --list                   # scan a directory
xholy --gui                                 # windowed GUI
xholy --gui-tui                             # terminal UI
xholy --game games/minimal                  # run the bundled guest fixture
```

## 9. Building from source

### Rust core (required)

```sh
cargo build --release     # optimized binary → target/release/xholy
cargo build               # debug build
cargo test                # full test suite
cargo test --features cpu-stub   # additionally enables the CPU stub feature
cargo bench               # Criterion benchmarks
```

Verified on Windows x86-64. Linux x86-64 builds are covered by CI
(`.github/workflows/ci.yml`) but were not verified locally.

### Scala runtime (optional)

```sh
cd scala
sbt assembly        # JVM fat jar → target/scala-*/xholy-runtime.jar
sbt fullOptJS       # Scala.js bundle → target/scala-*/xholy-web-opt.js
```

The Rust host locates these artifacts automatically (see
`src/runtime/scala_bridge.rs`).

### Native window manager demo (optional, Windows)

```sh
cd cpp/window_manager
cmake -B build && cmake --build build
```

See `cpp/window_manager/README.md` and `INSTALL.md` for details.

## 10. CLI reference

| Flag | Description |
|---|---|
| `xholy [IMAGE]` | Run a game image or disc (e.g. `.iso`, `.xvc`, directory) |
| `--mount PATH` | Mount an optical source (drive letter, directory or ISO); repeatable for multi-disc |
| `--list` | List detected games on mounted media and exit |
| `--drives` | Detect and print physical optical drives, then exit |
| `--gui` | Launch the windowed GUI (winit + wgpu) |
| `--gui-tui` | Launch the terminal UI (ratatui) |
| `--gui-headless [--max-frames N]` | Render the GUI pipeline offscreen (default 300 frames) |
| `--game PATH` | Run a guest image headless through the emulation path |
| `--enable-jit` | Enable the experimental x86-64→WASM JIT branch |
| `--jit-no-fallback` | Disable JIT→interpreter fallback |
| `--analyze PATH` | Read-only PE32+ import analysis (never executes the file) |
| `--analyze PATH --json` | Machine-readable analysis report |
| `--trace PATH [--trace-out FILE] [--json]` | Execute a PE32+ file in the bounded HLE pipeline and export its diagnostic trace |
| `--progress` | Print the roadmap progress report derived from `progress.json` |
| `--gpu-api auto\|vulkan\|opengl\|software` | Force the host GPU API (alias: `--renderer`) |
| `--resolution WxH` | Window size |
| `--fullscreen` | Start fullscreen |
| `--theme dark\|gold\|light` | GUI theme |
| `--fps-limit N` | Cap GUI framerate (`0` = uncapped) |
| `--frame-pacing auto\|fixed\|uncapped` | Frame pacing policy |
| `--no-vsync` | Disable VSync (manual frame pacing takes over) |
| `--bloom` / `--no-bloom` | Bloom post-processing (default on) |
| `--tone-mapping linear\|reinhard\|filmic\|aces` | Tone mapping operator |
| `--aa off\|fxaa\|msaa4` | Anti-aliasing |
| `--native-wm` | Native C++ window-manager demo (Windows) |
| `--config PATH` | Layered TOML configuration file |

## 11. Development roadmap

The binding roadmap is [ROADMAP.md](ROADMAP.md); the binding
architecture decision is
[docs/adr/0001-target-architecture.md](docs/adr/0001-target-architecture.md).
An honest inventory of unimplemented components is kept in
[MISSING.md](MISSING.md), and the feature/status checklist in
[STATUS.md](STATUS.md).

### Project development progress

The figures below are generated from and validated against
[`progress.json`](progress.json) by `src/progress.rs` (a unit test fails
if this README section goes stale). Run `xholy --progress` for the same
report on the command line.

**Overall roadmap completion: 60.2%**

`[▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░] 60.2%`

| Category | Weight | Completion |
|---|---:|---:|
| CPU & Execution | 20% | 40.0% |
| HLE & System Runtime | 20% | 75.0% |
| GPU & Shader Translation | 20% | 50.0% |
| Memory & Storage | 10% | 82.5% |
| Audio & Input | 10% | 50.0% |
| Game Compatibility & Boot | 15% | 60.0% |
| GUI & Infrastructure | 5% | 100.0% |

Last verification: 2026-11-25.

Calculation: each task adds `weight x credit` to its category, where credit is 0 for Planned and Blocked, 0.5 for Partially Implemented, and 1 for Implemented and Verified. Task weights total 100 within each category, so the category sum is its completion percentage. Overall completion is the category completion weighted by the category weights. Everything is derived from `progress.json` by `src/progress.rs`. This measures roadmap progress only, not game compatibility, production readiness or retail boot success.

### Performance targets

| Metric | Target |
|---|---|
| Frame rate | 60 FPS @ 1440p/4K |
| Input latency | < 15 ms |
| Compatibility | Xbox Series X\|S (Gen9): goal; no retail title runs yet |

These are goals for the completed emulator, not current measurements —
see `benchmarks/REPORT.md` for the scaffold baseline.

## 12. Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Credit only contributors who
made a substantive change. AI agents should use their verified bot
identity (see [Agents.md](Agents.md)).

When contributing:

- Keep claims evidence-based: the HLE registry requires a reliable
  public source before a symbol may leave the `Unknown` state.
- Add tests for new behavior; the suite is the verification bar.
- Do not bundle firmware, game dumps or proprietary SDK code.

## 13. Third-party components and acknowledgements

xHoly's own code is licensed under the Apache License 2.0. Direct Rust
dependencies (wgpu, winit, ratatui, serde, clap, and others) and the
bundled Inter font are listed with their licenses in
[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md). Crate metadata is
the source of the license column; it has not been separately
legal-reviewed.

ScarlettX is used as a **compatibility reference only**; no code is
copied from it. No Microsoft Xbox GDK/GDKX code is included.

## 14. License

xHoly's own code is distributed under the
[Apache License 2.0](LICENSE).

The Apache License applies to xHoly's own covered code only. It does
not grant any rights to Microsoft's trademarks, proprietary software,
firmware, commercial games or third-party components, which remain
subject to their respective licenses and terms.

## 15. Legal information and independence

### Independence

xHoly is an independent community project. It is not affiliated with,
endorsed by, sponsored by, or officially connected to Microsoft, Xbox,
Rockstar Games or Take-Two Interactive. Microsoft, Xbox, Xbox One, Xbox
Series X|S and associated trademarks belong to their respective
owners. The project does not claim ownership of Microsoft's intellectual
property.

### Independent implementation

xHoly aims to implement its own emulator functionality independently.
No proprietary Microsoft SDK source code is included in the project's
own implementation. This is an architectural goal; the dependency set
has not been fully audited for SDK independence (see
[THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)).

No Xbox firmware, commercial game files or protected proprietary
content is bundled with the project.

### User responsibility

Users are responsible for ensuring that their use of the software and
any external files they supply complies with applicable law.
Reverse-engineering and interoperability rules vary by jurisdiction,
and no interoperability provision grants blanket permission for every
activity. Users cannot assume they may freely dump, decrypt,
distribute or execute every commercial game. This README is not legal
advice.

### License scope

The Apache License 2.0 applies to xHoly's own covered code. It does not
grant rights to Microsoft's trademarks, proprietary software, firmware
or commercial games. Third-party components remain subject to their
respective licenses.

## GTA VI statement

xHoly is not specifically developed, marketed, promoted or positioned
for Grand Theft Auto VI. The project makes no GTA VI compatibility
claims or promises and does not include GTA VI-specific features or
assets.

**Redeem Your Games.**
