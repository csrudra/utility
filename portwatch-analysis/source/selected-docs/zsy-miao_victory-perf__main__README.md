# victory-perf

A performance- and lighting-focused Windows compatibility layer for running Xbox Series X|S (Scarlett) GDK titles natively on PC, derived from [fxceless/victory-fork](https://github.com/fxceless/victory-fork) and [Marvisak/VIctory](https://github.com/Marvisak/VIctory).

The project combines a native x86-64 PE32+ loader, console HLE modules (`xgameruntime`, `kernelx`, `d3d12_xs`, GameInput), a `d3d12_xs` → host D3D12 graphics backend, and an RDNA2 (GFX10) → DXIL shader recompiler, with targeted CPU/GPU synchronization optimizations, ahead-of-time shader precompilation, lighting stand-ins for shadowed interiors, Series S overlay compositing, and keyboard/mouse support.

> **Asset policy:** This repository contains **no game files, executables, keys, or proprietary assets**. Users must supply their own files outside the repository. Not affiliated with or endorsed by any game developer, publisher, or console vendor.

---

## Status & Measured Results

Tested on one machine:
- **CPU:** AMD Ryzen 7 9800X3D (8C / 16T)
- **GPU:** NVIDIA GeForce RTX 4070 SUPER 12 GB (Resizable BAR enabled)
- **RAM:** 64 GB
- **OS:** Windows 11 Pro x64

| Stage | Status | Notes |
| --- | --- | --- |
| PE32+ loader & GDK HLE (`kernelx`, `xgameruntime`) | ✅ Working | Runs x86-64 title code natively; offline profile, saves, and Series S/X profiles |
| Boot, intro, and menus | ✅ Working | Runs at 30 fps target with audio and input |
| Prologue & interior gameplay | ✅ Playable | Character movement, HUD, pause menu, gamepad and keyboard/mouse input |
| Frame rate (Series S, 50% render scale) | 🟡 4.5–14+ fps | **14 fps (71 ms)** prison corridor, **11 fps (95 ms)** heist interior, **9 fps (115 ms)** cell; **4.5–6.5 fps** in heavy scenes (~10,000 draws/frame) — up from 2.5–4 fps baseline |
| Shadowed interior lighting | 🟡 Lit via stand-ins | Ambient and shadowmask stand-ins (`VICTORY_AMBIENT_STUB=1`, `VICTORY_SHADOWMASK_STUB=1`) illuminate pitch-black shadow zones; full ray-traced lighting is still WIP |
| Stability (`--console series-s`) | ✅ Stable in testing | Avoids AMD FFX FSR4 `DXGI_ERROR_INVALID_CALL` crash via `VICTORY_OWN_UPSCALER=1`; no screen flicker observed |

*Caveats:* All benchmark numbers above are self-reported on a single Ryzen 7 9800X3D + RTX 4070 SUPER setup using `--console series-s` with `VICTORY_OWN_UPSCALER=1` and `VICTORY_RENDER_SCALE=0.5`. Lighting stand-ins approximate missing bounce/shadow light rather than reproducing console ray tracing.

---

## Changes on Top of `fxceless/victory-fork`

### Original GPU & CPU Performance Work
- **Coalesced `CARD_COMPARE` + 128 MiB inline L0 readback ring (`crates/victory-gpu`):** Rewrote GPU-side buffer diffing to 64 coalesced threads per 64 KiB chunk with LDS hash reduction and inline readback slots, dropping relay fetch stalls from ~200 ms/frame to ~0 ms.
- **Scoped indirect clamp barriers (`VICTORY_CLAMP_SCOPED`, default on):** Replaces global full-GPU UAV drains around `ExecuteIndirect` argument clamps with resource-scoped UAV barriers on dedicated argument/count buffers and removes the redundant post-clamp global barrier.
- **Per-list UAV barrier deduplication (`VICTORY_BARRIER_MERGE`, default on):** Tracks `uav_pending` (including image stores) per `HostList` and skips redundant global UAV barriers across `barrier_groups` and clamp passes.
- **Expanded indirect clamp windows & light PSO restore:** Enables `VICTORY_INDIRECT_WINDOW` by default, increases `VICTORY_INDIRECT_WINDOW_MOST` from `64` to `4096`, and enables `VICTORY_CLAMP_LIGHT_RESTORE` by default so graphics root bindings survive clamp dispatches.
- **CPU stall & spike elimination (`crates/victory-gpu/src/host.rs`, `resource.rs`, `texture.rs`):** Removed O(N²) loops in `host.rs`, moved `heap_buffers` pruning/refresh to 1/16th incremental work per frame (removing ~142 ms periodic spikes), relaxed VRAM texture eviction (`EVICT_IDLE_FRAMES=120`), enabled parallel refresh flushes, and enabled overlapped texture refreshes / fast hashing (`VICTORY_TEXTURE_OVERLAP`, `VICTORY_FAST_HASH`, `VICTORY_KNOWN_WRITES`, all default on).
- **Ahead-of-time shader precompilation (`apps/victory/src/precompile.rs`, `crates/victory-gpu/src/precompile.rs`, `shader_cache.rs`):** Precompiles cached RDNA2 → DXIL shader pipelines ahead of runtime to cut first-use hitches.

### Modules Ported & Adapted (GPL-3.0-or-later)
Integrated and adapted from [ZigZagBoi1/ScarlettPort](https://github.com/ZigZagBoi1/ScarlettPort) (`runtime/victory`, GPL-3.0-or-later):
- **Lighting stand-ins & merged shader lowering:** `crates/victory-shader/src/emit/stand_in.rs`, `exposure.rs`, and `merged.rs` (`VICTORY_AMBIENT_STUB=1`, `VICTORY_SHADOWMASK_STUB=1`, `VICTORY_EXPOSURE_STUB=1`).
- **Series S overlay compositing:** `crates/victory-gpu/src/over.rs`.
- **Loader resolution, upscaler, and watchdog hooks:** `crates/victory-loader/src/hooks.rs` (`VICTORY_OWN_UPSCALER=1`, `VICTORY_RENDER_SCALE=<0.2..=1.0>`, `VICTORY_NO_WATCHDOG=1`).
- **Keyboard & mouse input:** `crates/victory-core/src/kbm.rs` and `crates/victory-hle/src/modules/controls.rs` / `gameinput.rs` (`Alt` toggles mouse capture).
- **Memory copy, ReBAR, and readback helpers:** `crates/victory-gpu/src/memcopy.rs`, `rebar.rs`, and `readback.rs`.

---

## Building & Testing

**Requirements:** Windows 10/11 x64, AVX2-capable CPU, Direct3D 12 GPU with Shader Model 6.6 + Mesh Shaders, and the Rust toolchain pinned in `rust-toolchain.toml`.

```powershell
# Run workspace unit tests (requires no game files)
cargo test --workspace

# Verify repository asset policy
cargo xtask policy

# Build release binary
cargo build --release -p victory
```

Configure local paths outside the repository by copying `victory.example.toml` to `victory.toml` and pointing `game_dir` to your own dump.

### Recommended Launch Profile (Series S, 10+ fps target)

```powershell
$env:VICTORY_CARD_BUFFERS_MIN_MB = "1"
$env:VICTORY_CARD_BUFFERS_MB = "2048"
$env:VICTORY_RELAY = "2"
$env:VICTORY_LATE_WAIT = "3"
$env:VICTORY_WIDE_BACK = "1"
$env:VICTORY_LIBRARY_TRIM = "0"
$env:VICTORY_REBAR = "0"
$env:VICTORY_COPY_BACK_ONLY_READBACK = "0"
$env:VICTORY_AMBIENT_STUB = "1"
$env:VICTORY_SHADOWMASK_STUB = "1"
$env:VICTORY_OWN_UPSCALER = "1"
$env:VICTORY_RENDER_SCALE = "0.5"
.\target\release\victory.exe run --console series-s --execute "<path-to-title-exe>"
```

See `docs/architecture.md` and `docs/asset-policy.md` for architecture notes and contribution rules.

---

## Credits & License

Full upstream git history is preserved in this repository.

- **[Marvisak/VIctory](https://github.com/Marvisak/VIctory)** (GPL-3.0-or-later) — foundational PE32+ loader, runtime HLE, `d3d12_xs` graphics layer, BCPack/swizzle texture decoders, and RDNA2 → DXIL shader recompiler.
- **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)** (GPL-3.0-or-later) — direct upstream base adding world rendering, shader optimizations, card buffers, relay threading, and in-place memory work.
- **[ZigZagBoi1/ScarlettPort](https://github.com/ZigZagBoi1/ScarlettPort)** (GPL-3.0-or-later) — source of ported GPL-3.0-or-later modules and design ideas listed above.
- **[ivall/xcl](https://github.com/ivall/xcl)** (GPL-2.0-only) — referenced solely for behavioral comparison; no GPL-2.0-only code is included.

Licensed under **GPL-3.0-or-later**. See [LICENSE](LICENSE).
