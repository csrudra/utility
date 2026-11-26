# HybridGt

Engineering work toward running the Xbox Series X|S build of Grand Theft Auto VI, from files the
user owns, natively on Windows x64. Tested on one PC: Windows 11, NVIDIA RTX 4070 Ti.

HybridGt is **not a standalone runtime**. The game runs inside
[victory-gta6](https://github.com/fxceless/victory-gta6) (a fork of
[VIctory](https://github.com/Marvisak/VIctory), both GPL-3.0-or-later). HybridGt holds:

- **patches** on top of that fork (`patches/victory-gta6/`), plus an older series on upstream
  VIctory (`patches/victory/`, superseded);
- **independent tools and tests** (`crates/`): a D3D12 diagnostic harness and texture code;
- **documentation** of measurements, failures and root causes (`docs/`).

No game files, extracted assets or shaders are in this repository.

## Progress

Updated with each run. Measured numbers only.

| Area | Progress | Detail |
|---|---|---|
| Shader programs translated | `███████████████████░` 99.9 % | `shaders.rpf`: 26,069 of 26,084 programs emit; 15 do not: 5 ray-traced shadow (`CS_TraceShadowRays_*`, descriptor read as data), 10 POPS ped pixel shaders (`PS_PedTexturedCutOutTint_Zero`, off: glowing eyes). The 29 FidelityFX DXBC shaders live in other files and are not counted here (inventory reconciled 2026-11-25: earlier "45/43" mixed sources) |
| Shader containers the runtime translates (whole game folder) | `███████████████████░` 99.8 % | 25,938 of 25,985; 242 -> 47 failing after the runtime learned geometry-only containers (195 voxel-lighting GS). Left: 29 Xbox FidelityFX (replaced by PC FidelityFX), 10 POPS, 5 ray-traced shadow, 3 stubs with no GPU code |
| Shaders passing Microsoft's DXIL validator | `███████████████████░` 99.1 % | the rest: signature rows mixing flat and interpolated values, 71 mesh shaders over 32 KiB of outputs (NVIDIA takes them) |
| Geometry shaders (voxel lighting) | `████████████████████` 100.0 % | translate and validate; host pipelines behind `VICTORY_TITLE_GS=1` |
| Console pipeline methods 0x218 / 0x1c8 | `██████████████████░░` 90.0 % | 0x218 compute: 2,048 made, 0 missed. 0x1c8 graphics (the title's main renderer path): 1,746 of 1,746 captured prologue descriptions make D3D12 pipelines offline (vertex, vertex-only, mesh); on in play-fast.cmd; not yet seen in game; stencil ops not decoded |
| Frame rate vs 30 fps goal | `████░░░░░░░░░░░░░░░░` 19.3 % | median 5.8 fps, best 6.9, slowest frame 345 ms in the world (run next40, lock-free descriptor mirror; was 4.8 fps median, 647 ms worst) |
| Compute pipelines the RTX 4070 Ti accepts | `███████████████████░` 99.9 % | 1 of 3 wave64-only programs fixed (`CS_AlphTransmissionPrefilterMip`, the refraction mips water and glass sample); GPU heap defrag and a VFX triangle pass still refused |
| Boat mission ("Cal fell off the boat") | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | not fixed. Traced: the water heights the physics reads are flat (only 0.0 m or 0.3 m); the shallow-water integration programs are never created by the game. Next: trace the GPU time step the game reads back |
| Mouth animation | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | not fixed: the face compute shaders and network ops run without errors; cause not found |
| Ray tracing | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | BVH builder off; DexNom's builder work needs a merge by hand |
| FSR 1 upscale on present | `████████████████████` 100.0 % | runs in game (`VICTORY_FSR=1`, 720p -> 1080p); no frame-rate gain measured: the frame is CPU-bound |
| FSR 3.1 (temporal) | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | needs the game's motion vectors and depth: the game calls FSR only on its Series S path (blocked by 0x1c8/0x218) |
| Series S boot | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | blocked on device method 0x1c8 |

Details of every run: `docs/PERFORMANCE_OPTIMIZATION.md`.

## Status (2026-11-25, evening)

**Not playable.** From the user's save the world renders and the boat mission starts at
**5–7 fps** (median 5.8 fps in run next40) on an RTX 4070 Ti, but the mission fails at its start
("Cal fell off the boat": the boat sinks), and mouths do not move when characters talk.

### Works (seen on screen or measured)

| What | Evidence |
|---|---|
| Boot, intro, menus at 30 fps | run logs `fork3`–`fork8` |
| Prologue renders: characters (Lucia, hair), textures, sky, sunlit exteriors, HUD prompts | user screenshots, `docs/MASTER_STATUS.md` |
| Player movement and camera through the game's own input | user report |
| 5,000–6,500 draws per frame in the world | run log `fork8` |
| Shader translation: 14,160 of 14,259 vertex/pixel, 2,718 of 2,734 compute, 8,762 of 8,765 mesh programs | offline `translate` over the title's shaders |
| No GPU hang or device removal in the last runs | run logs `fork6`, `fork8` |

### Runtime base and patches (`patches/victory-gta6/`, on fork commit `9376fd6`)

The patches apply to fxceless/victory-gta6 `9376fd6`. That commit contains all of
[ZTRX](https://github.com/Zettrox/ztrx) `main`, plus the fork's own work since then: depth bounds,
texture re-checks, descriptor mirroring, and the CPU-side frame work. See
[docs/ZTRX_IMPLEMENTATION_AUDIT.md](docs/ZTRX_IMPLEMENTATION_AUDIT.md).

| Patches | What | Source |
|---|---|---|
| 0001 | Wave-wide branch form as last resort on 32-lane GPUs | HybridGt |
| 0002–0003 | FidelityFX: the title's FSR calls run AMD's PC upscaler (`VICTORY_FFX_DIR`) | HybridGt |
| 0004 | Constant samplers in reserved host sampler slots | HybridGt |
| 0005–0006 | No blending on integer targets; LDS-flag regions as two waves | ZTRX PR #36 |
| 0007–0008 | Guarded textures re-checked after a change (intro flicker) | ZTRX PR #32 |
| 0009–0010 | `ds_bpermute_b32` / `ds_permute_b32` across two host waves | ZTRX PR #43 |
| 0013–0015 | `fma_mix`, `mul_hi` without INT64, 23 more VALU instructions | ZTRX PRs #56, #51, #10 |
| 0012, 0016, 0022 | Diagnostics: pipeline-method samples, descriptor timers, read benchmark | HybridGt |
| 0017–0019 | Memory remapping: locks once per call; no-op remaps skipped; remap counters; `VICTORY_KEYS` in release builds | HybridGt |
| 0020–0021 | Buffer copies and scratch fills that would wait for in-flight GPU work run on the GPU (`VICTORY_GPU_BUFFER_COPIES=1`, `VICTORY_GPU_FILLS=1`) | HybridGt |
| 0011 | Test fix-up | HybridGt |

Performance (RTX 4070 Ti, Series X profile, 1080p, steady world frames, no input):

| Run | Steady world | Frame |
|---|---|---|
| next1 | about 3.0 fps | 309–337 ms |
| next9 (remap locking) | 3.5–3.6 fps | 276–284 ms |
| next12 (with both GPU-copy switches) | **3.7–4.0 fps** | **252–270 ms** |

Every run is in [docs/PERFORMANCE_OPTIMIZATION.md](docs/PERFORMANCE_OPTIMIZATION.md).

Also in `crates/hgt-gfxdiag`: GPU checks proving the RTX 4070 Ti runs 32-lane waves and that
two-half wave64 emulation gives the console's answer in compute and mesh shaders, including
ballots inside branches.

### In progress

- **Frame rate.** Measured per world frame: about 105 ms CPU preparation (about 130 MB of title
  memory copied to the GPU), about 94 ms GPU work, about 38 ms copying results back, all on one
  CPU thread. Next: a GPU timing run naming the slowest shaders, and the fork's copy-free
  `VICTORY_INPLACE` mode.
- **FSR (stage 2).** The title's upscaler uses the same five-function API as AMD's PC FidelityFX
  SDK (MIT). The plan is to run the PC upscaler on the host's command list when the title calls
  `ffxDispatch`. Not started beyond stage 1.
- **Series S mode** (`--console series-s`, lower resolution): it stopped at a black screen
  because the FSR DLL was refused; retest with patch 0007 pending.

### Not working

| Problem | Cause (as far as known) |
|---|---|
| Shadowed areas and interiors black | The title's indirect light and lamp/sun shadows are ray traced in its own compute shaders; the fork's ray-tracing path is off by default and not yet run end to end |
| Some sun shadows and mirror reflections missing (40 programs) | A sampler chosen between a loaded one and a constant one; needs reserved slots in the host sampler heap |
| Menu / startup animation flickers back and forth | Unknown; not the relay or texture switches (tested). Next: a RenderDoc capture |
| 2 compute programs still need 64-lane waves; 1 mesh pipeline refused at run time | — |
| 2 device methods (`0x1c8`, `0x218`) not implemented: 29 pipelines skipped | Unknown layout; likely ray-tracing state |
| 195 voxelization geometry shaders do not translate | No geometry-shader stage; not requested in the scenes tested |

Details: [docs/MASTER_STATUS.md](docs/MASTER_STATUS.md),
[docs/KNOWN_FAILURES.md](docs/KNOWN_FAILURES.md),
[docs/ROOT_CAUSE_ANALYSIS.md](docs/ROOT_CAUSE_ANALYSIS.md),
[docs/NVIDIA_WAVE64_COMPATIBILITY.md](docs/NVIDIA_WAVE64_COMPATIBILITY.md).

## Build and run the game

Requirements: Windows 11 x64, a D3D12 GPU with mesh shaders (tested: RTX 4070 Ti), Rust (stable,
MSVC toolchain), Git, the Windows SDK (for `dxil.dll`), and **your own** copy of the game's
Xbox Series files in a folder outside every repository.

```powershell
git clone https://github.com/fxceless/victory-gta6
cd victory-gta6
git checkout 9376fd6
git switch -c hybridgt
git am <path to HybridGt>\patches\victory-gta6\*.patch
cargo build --release -p victory
```

Set the paths (any folders outside the repository):

```powershell
$env:VICTORY_GAME_DIR  = '<your game folder>'
$env:VICTORY_CACHE_DIR = '<a cache folder>'
$env:VICTORY_DATA_DIR  = '<a save-data folder>'
```

Translate every shader into the cache once per build (about 20 minutes; it reads the game files
and writes only to the cache). On an NVIDIA GPU this setting matches what the game run picks:

```powershell
$env:VICTORY_HOST_MAX_WAVE = '32'
.\target\release\victory.exe translate --warm all $env:VICTORY_GAME_DIR
Remove-Item Env:VICTORY_HOST_MAX_WAVE
```

Run. On `a26859f` the fork's own defaults already include the speed settings HybridGt used
to set by hand: relay stage 2, wide copy-back, and card copies from 1 to 1,024 MB. Upstream
measured about 230 ms per frame with them, where it was about 400 ms, on an RTX 4070. HybridGt
has not measured them on its RTX 4070 Ti yet.

```powershell
$env:VICTORY_DISPLAY_MODE = '1920x1080'
$env:VICTORY_LEVELS_ON_DEMAND = '1'; $env:VICTORY_WIDE_REFRESH = '1'; $env:VICTORY_WIDE_MERGE = '1'
$env:VICTORY_GPU_BUFFER_COPIES = '1'; $env:VICTORY_GPU_FILLS = '1'
$env:VICTORY_FFX_DIR = '<folder with amd_fidelityfx_loader_dx12.dll and amd_fidelityfx_upscaler_dx12.dll>'
.\target\release\victory.exe run "$env:VICTORY_GAME_DIR\<the game's exe>" --execute
```

Keyboard without a pad: Enter = A, Esc = Menu, WASD = left stick. The first run after a build
still flickers until the GPU pipelines it saves are made.

## Build and test HybridGt's own tools

Requirements: Rust (stable MSVC) and DXC on `PATH` or in `HYBRIDGT_DXC`. Without DXC the GPU
checks print `SKIPPED` and pass; skips are not coverage.

```powershell
cargo test --workspace                 # GPU checks on WARP (software); safe on any machine
$env:HYBRIDGT_ADAPTER = "hw"           # the same checks on the first hardware GPU
cargo run -p hgt-gfxdiag               # the harness, one line per check
$env:HYBRIDGT_D3D12_DEBUG = "1"        # D3D12 debug layer: errors fail a check
```

Hardware runs refuse the checks that hung a GPU before, unless `HYBRIDGT_ALLOW_HANG_REPRO=1` is set.

## Licence

GPL-3.0-or-later, as VIctory and victory-gta6. XCL (GPL-2.0-only) was studied as a reference
only; no XCL code is used. Third-party use is listed in [THIRD_PARTY.md](THIRD_PARTY.md).
