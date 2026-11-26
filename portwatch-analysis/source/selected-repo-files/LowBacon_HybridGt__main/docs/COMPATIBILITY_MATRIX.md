# Compatibility matrix: XCL vs VIctory vs HybridGt

As of 2026-11-24. Sources inspected:
- **VIctory**: local clone `E:\GTA\VIctory`, commit `ffe310e` (clean, `origin` = github.com/Marvisak/VIctory).
- **XCL**: the copy vendored in GTA6-PC-Native (`E:\GTA\GTA6-PC-Native\runtime\xcl`, GTA6-PC-Native commit
  `05b9566`). It is upstream `main` plus `patches/xcl-gta-stack.patch`, which includes upstream PRs #684, #850,
  #851, #891, #900, #906, #944 and #905 (BCPack), per `docs/RUNTIMES.md`. **It is not upstream `main`.**
- **Public issues and PRs**: ivall/xcl#878 and the PRs it links (#273, #340, #438, #856, #541, #630, #905),
  read 2026-11-24.

Legend:
- **Source**: read in the code, with the file named.
- **README**: the project's own claim, not checked.
- **Not inspected**: nobody here has looked yet.
- **Measured**: produced by a HybridGt run.

No game data was used: the console title's files were not opened.

| Component | XCL | VIctory | HybridGt |
|---|---|---|---|
| Executable loading | Source: own PE loader, `crates/xcl/src/loader.rs`, `pe.rs` (relocations, imports, delay-load, TLS via a generated carrier DLL `tls.rs`, C++ EH hook `eh.rs`); launched as a child process (`launcher.rs`) | Source: `victory-loader` (`prepare.rs`, `resolve.rs`, `tls.rs`, `thunks.rs`, `crash.rs`), `victory-pe`; runs the title in-process | None. Not planned until a graphics blocker needs it |
| Runtime initialization | README / HANDOFF: kernelx, XGameRuntime offline (`hle/kernelx*`, `hle/xgameruntime/`). Boot to menus at 30 fps: README claim | README: boot, first-boot screens, intro, start screen, saves work; modules in `victory-hle/src/modules/` (xgameruntime, xuser, xpackage, xgamesave, lifecycle …) | None |
| Memory management | Not inspected (`hle/kernelx`, `gpu/uma.rs` exist) | Not inspected (`modules/xmem.rs` exists) | None |
| System interfaces | Source (resolver order HLE → game DLL → Windows → logged auto-stub, `resolver.rs`, `stubs.rs`). #878: console slots `ID3D12CommandAllocator::#9`, `ID3D12GraphicsCommandList10::#75/#126/#142`, `ID3D12CommandQueue::#31` are stubbed on a retail run | Not inspected in depth; `victory census --missing` lists missing imports (README) | None |
| Graphics device | Source: D3D12.X proxied over the PC's D3D12 (`hle/d3d12x/real.rs`, `bind.rs`), Agility SDK (`gpu/agility.rs`) | Source: `victory-gpu` (`device.rs`, `list.rs`, `queue.rs`, `host.rs`), D3D12; console list slots mapped by shape (`list.rs:1357`, "ExecuteIndirect moved from 0x1d8 to 0x1e8") | Measured: test harness only (`hgt-gfxdiag`). It creates its own D3D12 device on WARP or hardware. It does not stand in for the console's device |
| Shader translation | README/HANDOFF: RDNA2 → HLSL → DXIL; 26,698 programs translate (README claim); decoder generated from AMD's ISA XML (`gpu/rdna2_spec.rs`). GTA6-PC-Native adds a 4096-iteration loop cap | Source: `victory-shader` (`gfx10/`, `dxil.rs`, `structure.rs`); README: `victory translate --validate` | None |
| Mesh rendering | #541 / #630 (open, not merged): ~2,750 `MS_VS_*_Wrapped` pipelines refused, plus minimap mesh pipelines with the console MS in the AS slot. Mixed test results | Source: indirect mesh dispatches go through `prepare_for(.., mesh)` (`draw.rs`) and are clamped to one-dimensional groups (`indirect.rs`) | None |
| Texture handling | Source: BCPack BC1/3/4/5/6H/7 via a port of VIctory's decoder (`hle/bcpack/victory.rs`, "Ported from VIctory … on 2026-11-23"). BC2 refused. A decode failure returns `E_DECOMPRESSION` (`dstorage.rs:252-275`) and is counted. Before #905 every BCPack request was refused, 183,128,064 bytes unfilled (#878). Optional magenta fill `XCL_DSTORAGE_BCPACK_FILL=1` | Source: `victory-formats/src/bcpack.rs` (decode BC1, 3–7; BC2 → "unsupported BC format"); errors → `INVALID_DATA` (`dstorage.rs:831-835`). A zlib stream that ends short of the destination **passes** (`dstorage.rs:846-848`) | Measured: `hgt-texture`. Strict wrapper over VIctory's decoder: the destination is untouched on error, a panic counts as a failed request, and a ledger records requested vs filled bytes. Finding: **60–90 % of random garbage streams "decode"** (no checksum), so `Ok` is not proof. BC1 GPU path checked against CPU references on WARP and RTX 4070 Ti, including NVIDIA's interpolation |
| Resource synchronization | Not inspected | Not inspected (`fence.rs`, `queue.rs`) | None |
| Indirect execution | Source: count and argument buffers passed through unchanged (`hle/d3d12x/bind.rs:235-286`). Skipped when the pipeline is pending, or when the signature changes root arguments under a translated pipeline. Skipped producer dispatches do not zero their outputs | Source: every argument record is clamped on the GPU before execution, and a per-list budget applies (`indirect.rs`, `draw.rs:1015`). **The count buffer itself is passed through unclamped** (`draw.rs:993-1052`). Drawn records are bounded, but the number of records relies on the driver's `min(count, max)` | Measured: an unclamped count 0xFFFFFFFF with max 5 **hung an RTX 4070 Ti once** (WARP clamps correctly). `CountGuard::Clamp` (a shadow count buffer) gives 5 draws, no hang, on both adapters. See [findings/2026-11-24-indirect-count-hang.md](findings/2026-11-24-indirect-count-hang.md) |
| World rendering | #878 (XCL `a1672ef` and `main` `beaa245`, NVIDIA): black after loading, then a fault at `game_scarlett_master.exe+0x23cf683`, on the title's fatal path ("GPU Loc Sig" string). Not fixed by #905 | README (2026-11-23): first mission title card renders, the scene after it is dark, 0.5–1.8 s per frame. "Entering the world on a real GPU can currently hang it." Tested on AMD RX 6700 XT only. #878 reports VIctory faults at the same offset | None. HybridGt has not rendered any title frame |
| Input | README: XInput, keyboard and mouse (`hle/gameinput.rs`, `kbm.rs`) | README: XInput, keyboard as pad (`modules/gameinput.rs`) | None |
| Audio | Source/README: XAudio2, XMA2, Opus (`hle/xaudio2.rs`, `xma2/`, `opus.rs`) | README: menu, video and loading audio; XMA and Opus decode; reverb silent | None |

## Licences (source, `LICENSE` and `Cargo.toml`)

| Project | Licence | Consequence for HybridGt (GPL-3.0-or-later) |
|---|---|---|
| VIctory | GPL-3.0-or-later | Usable. Used as a pinned git dependency (`victory-formats`) |
| XCL | GPL-2.0-only | **Not combinable** with GPL-3.0 code. Reference only |
| OpenScarlett | MIT | Usable. Not used yet |
| Leonida | GPL-3.0 text in `LICENSE` | Usable. Not used yet |

Picking GPL-3.0-or-later rules out XCL code, and picking GPL-2.0-only would rule out VIctory. VIctory was
chosen because it is ahead on the world path (reaches the first mission) and has per-record clamping that XCL
lacks.

## The earliest known divergence, per runtime (evidence-backed)

- **XCL**: the world loads, then the screen goes black, then the title takes its own fatal path at `+0x23cf683`
  (#878). Unknown: which condition sets the fatal flag. The stubbed command-list slots and the empty textures
  are both candidates. The textures part is fixed by #905; the fault remains.
- **VIctory**: the title card renders, the next scene is dark, frames take 0.5–1.8 s, and the GPU can hang
  (README). The source shows argument records clamped but counts not. HybridGt measured a count-only hang on
  NVIDIA. Whether a count above `max` reaches the GPU in VIctory's world frames is **not established**: that
  needs a run with game data.

## Not inspected (next)

Memory management, resource synchronization (fences, barriers, aliasing), the render-target paths used by the
title card versus the scene, and pipeline state. These need either a deeper source read or a diagnostic run on
game data that the user is authorized to use.
