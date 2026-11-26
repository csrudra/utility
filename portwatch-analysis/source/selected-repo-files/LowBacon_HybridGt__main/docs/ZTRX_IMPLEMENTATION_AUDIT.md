# ZTRX implementation audit

Audited 2026-11-25 from the public repository only (`git fetch` of
https://github.com/Zettrox/ztrx and its pull-request refs). No game files were read for this audit.

## Exact version

| Item | Value |
|---|---|
| Default branch | `main` |
| Head | `90b529f87` (2026-11-25 01:11 UTC), "ztrx: own README and a launcher for normal play" |
| Licence | GPL-3.0-or-later (`LICENSE`, `Cargo.toml` `workspace.package.license`) |
| Toolchain | Rust `1.98.1`, `x86_64-pc-windows-msvc`, edition 2024 (`rust-toolchain.toml`) |
| Tags / releases | none |
| Workspace | `crates/*`, `apps/*`, `xtask`; `tests/fixtures` excluded |
| Crates | `victory-core`, `-pe`, `-loader`, `-hle`, `-gpu`, `-shader`, `-formats`, `-pipeline`, `-game`; app `apps/victory` |
| Docs | `docs/architecture.md`, `docs/asset-policy.md`, `docs/fork-ray-tracing.md` |

## What ZTRX is

ZTRX is the same code line HybridGt already runs. Its history contains `16849898f`, the
fxceless/victory-gta6 commit HybridGt's patches were built on. On top of that, ZTRX has six commits:

| Commit | Content | Code? |
|---|---|---|
| `3930989` | Mesh pipeline test skips on GPUs without mesh shaders (#14) | test only |
| `90228a7` | Parked wave64 lane-mask pairs restored when the two `v_readlane_b32` are a few instructions apart; `v_movrels_b32` reads no longer stop unspilling (#11). `IrradianceCache_Shade*` and one `RaytracingResolve` translate. `VICTORY_TRANSLATE_ONLY`, `VICTORY_HOST_MAX_WAVE` | **yes** |
| `4e17478` | Game name removed from the tree (≈50 files, comments and strings) | rename |
| `9e49b8a`, `2119b0e` | #11 taken out, then put back | none net |
| `90b529f` | Own README, `scripts/play.ps1` launcher (sets cache/data dirs, clears capture/key switches, logs to `%TEMP%\ztrx.log`) | script |

The ZTRX runtime is therefore not a separate implementation. It is victory-gta6 at `2119b0e`
plus a launcher. The fxceless fork (`origin/main` = `a26859f`) has since gone **further** than ZTRX:

| Upstream commit | Content |
|---|---|
| `3bff182` | f64 instructions (`v_cvt_f32_f64`, f64 sums), first-half interpolation pairs, eviction under memory pressure, DirectStorage write retry, zlib-rs |
| `31714de` | Every host view heap ends at a null slot (cache keyed by it); `v_permlane16/x16` |
| `a803c87` | Textures picked by index re-checked after upload (black skin / pale hair) |
| `c96b4f2` | Depth bounds test (first room lit by its lamp); faster defaults (relay stage 2, wide copy-back, card buffers 1–1,024 MB, 256 lists): about 230 ms/frame where it was about 400 ms on an RTX 4070 |
| `310c6eb` | Packed textures stay in the upload queue; refresh when the card is full |
| `8dd30ab` | Writes through one view of a page seen at its other views; levels on demand (off); `translate --warm all` |
| `a26859f` | Byte-copied descriptor records mirrored before each submission; own bytes for views off their copy's elements; card room for first-frame bursts |

## Reported results (not verified by HybridGt)

The ZTRX README reports the following, on an RTX 3050 8 GB:
- boot, intro and credits work;
- the prologue is playable from the cell to the boat chase;
- 90+ minutes in one session;
- 1–3 fps in the world;
- shadowed areas black, bright scenes overexposed, blocky artifacts, boats too low.

Issues filed by other testers (data points, not verified here):

| Issue | GPU | Reported |
|---|---|---|
| #44 | RTX 5070 | 496/0/7 tests at `90b529f`; ~0.8 fps in world |
| #55 | RTX 5060 | 4–5 fps lit, with #36 + #49; 12 programs refused; copy-back dominates the frame |
| #37 | RTX 5070 Ti | speed settings: none 2.9 fps, `RELAY=1` 3.4, `LATE_WAIT+WIDE_BACK+CARD_BUFFERS` 4.1–4.2, plus fork PRs 4.6; `INPLACE=1` slower |
| #28, #39 | RTX 5060 / 4060 Ti | int3 after ~6 min with an unsignalled cross-queue barrier |
| #42 | — | 30 min run into Chapter I: 2–3 fps, flat black lighting, corrupted textures |
| #24, #5 | — | intro movie jumps back and forth (= HybridGt's "startup flicker") |

## Open pull requests and what was taken

| PR | Change | Taken into `hybridgt/next` | Why |
|---|---|---|---|
| #36 | No blending on integer render targets (driver refused a world mesh pipeline: missing walls); LDS-flag lane-branch regions run as two waves (`sr_tracing:CS_Tiling_Generate_Opaque`) | **yes** (2 commits) | Tested by four people on RTX 5080 / 5070 Ti / 3060 Ti; fixes pipelines NVIDIA refuses |
| #32 | Guarded textures re-hashed every frame for 16 frames after a change; loading-screen fix | **yes** (2 commits) | Targets the intro back-and-forth (#24/#5); two testers report it fixed |
| #43 | `ds_bpermute_b32` / `ds_permute_b32` across two host waves via a 64-dword table | **yes** (2 commits) | Shadow-mask trace programs; card tests pass on RTX 5070 Ti after fix |
| #48 | Textures by index re-checked | already upstream (`a803c87`) | — |
| #35 | Depth bounds | already upstream (`c96b4f2`) | — |
| #49, #52 | `v_permlane16`, `v_cvt_f32_f64` | already upstream; HybridGt had its own | — |
| #30 | Drop group sync on divergent single-wave barriers | **no** | Conflicts in 4 files; its testers measured 0 of 4 refused pipelines fixed; weakens synchronisation |
| #50 | Null-slot clamp of every view heap | already upstream (`31714de`) | — |
| #54, #58, #59, #60, #61 | f64 ops, buffer record counts, XBCH inflate, signature order, AMD reuse pass | not yet | to evaluate next |

## Diagnostics (from source, `apps/victory` and `victory-gpu`)

| Switch | Effect | HybridGt equivalent |
|---|---|---|
| `VICTORY_CAPTURE` + `VICTORY_CAPTURE_FRAMES` | PNG of listed frames (diagnostics build) | none of its own; uses the same switch |
| `VICTORY_KEYS` | scheduled key presses (diagnostics build) | same switch |
| `VICTORY_D3D12_DRED` | DRED breadcrumbs on device removal | same switch |
| `VICTORY_PIPELINE_WAIT_MS` | per-frame wait for pipelines still building | same switch |
| `VICTORY_TRANSLATE_ONLY`, `VICTORY_HOST_MAX_WAVE` | offline translate limited to hashes / as a 32-lane host | HybridGt `VICTORY_SAVE_HASHES` (patch), now superseded |

The diagnostics build is `cargo build --profile diag -p victory --features diagnostics`.
