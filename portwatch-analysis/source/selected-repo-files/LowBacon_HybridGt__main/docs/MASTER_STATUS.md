# HybridGt master status

Updated 2026-11-24. Hardware: RTX 4070 Ti, Windows 11, D3D12. Everything below was
measured; nothing is claimed beyond what a run or test showed.

## Workspace rule (from 2026-11-24 brief)

From this brief on, `E:\GTA\GTA6.Xbox.v1.0.2.1` is not accessed by the agent in any way,
and new work lives only in `E:\GTA\HybridGt`. Game runs listed below (runs 1–19) were
made earlier under the user's read-only permission; they are not repeated by the agent.
The user can still launch the game themselves (see README).

## What HybridGt is

| Part | What it does | Status | Evidence |
|---|---|---|---|
| `crates/hgt-texture` | Strict BCPack unpacking over VIctory's decoder; BC1 reference decoders (exact + NVIDIA) | Works on synthetic fixtures | 14 unit tests pass |
| `crates/hgt-gfxdiag` | D3D12 harness: clear, BC1 upload/sample, indirect draw counts with clamp guard, view-heap limit probe, buffer read benchmark | Works on RTX 4070 Ti | 10 tests pass; probe: 1,000,000-slot heap cap |
| `patches/victory/0001–0011` | Patch series on VIctory `ffe310e` (wave64 emulation, queue waits, heap caps, watchdog switch, diagnostics) | Experimental, opt-in env switches | Runs 16–19 below |
| `tools/victory_logstats.py` | Summarises VIctory logs (drops, refused pipelines) | Works | used on runs 6–19 |

HybridGt has no runtime of its own: the game runs inside VIctory with these patches.

## Best measured result (run 17, patches 0001–0010)

- Boots, menus, intro video and audio, loads the world, reaches the Prologue.
- 8+ minutes without a GPU reset (user report); run 18 reset once at frame 2,113.
- Screen black except the "PROLOGUE" title card. About 1 fps.

## Not working

See `KNOWN_FAILURES.md` and `ROOT_CAUSE_ANALYSIS.md`. In short: world geometry,
lighting, characters, gameplay, performance.

## Tests

`cargo test --workspace`: 27 passed, 0 failed (2026-11-24).

## 2026-11-24 evening: first visible 3D world

Running the public fork `fxceless/victory-gta6` @ `1684989` (GPL-3.0-or-later,
same base `ffe310e`), built unmodified at `E:\GTA\HybridGt-work\victory-gta6`:
the user saw **3D models and lighting on screen** and **moved the player** (about 1 fps; some models and textures missing) on the RTX 4070 Ti (first time
in this project). Measured in `logs/fork1.log`: up to 9,375 draws/frame (our
build: ~1,460); 0.4 fps, ~2,000 ms/frame of GPU time in one 14-list compute
submission; ~1,100 pipelines still being made on first start (flicker, stale
subtitles). Leading cause of our black world per the fork's notes: meshlet
culling read its scene buffers through the wrong view type.

Next: timed run (`VICTORY_GPU_TIMING=1`, diag build) to name the 2 s compute
work; then port HybridGt's wave64 mesh work onto the fork if it helps.

## Shader cache warmed offline (fork + HybridGt patch, 2026-11-24)

`patches/victory-gta6/0001`: `VICTORY_WARM_CACHE=<cache dir>` makes `victory translate`
put each container's runtime translation into that cache (run with
`VICTORY_HOST_WAVE=32 VICTORY_VIEW_LIMIT=999999` to match the RTX 4070 Ti).
Result over the title's shaders (read-only):

| Stage | Translated by the fork |
|---|---|
| vertex + pixel | 14,152 of 14,259 |
| compute | 2,713 of 2,734 |
| mesh | 8,762 of 8,765 |

24,435 entries added to the runtime cache, 358 containers do not translate
(top: 195 voxelization geometry shaders, "an address in an SGPR that is no root
parameter"; 40 "descriptor chosen by control flow"; 40 "descriptor read only as
data"). GPU pipelines still need one run each (they need the game's state).
