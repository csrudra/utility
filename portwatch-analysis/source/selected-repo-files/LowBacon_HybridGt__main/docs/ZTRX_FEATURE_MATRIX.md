# ZTRX ↔ HybridGt feature matrix

2026-11-25. "HybridGt" means the runtime HybridGt runs: victory-gta6 with HybridGt's patches.
Since this date that is branch `hybridgt/next`, built on fxceless/victory-gta6 `a26859f`.
"Seen" means on the RTX 4070 Ti in HybridGt runs before 2026-11-25. Those were made with the
user's approval, before the game folder was declared off-limits.

| Subsystem | ZTRX (reported) | HybridGt (measured) | Class |
|---|---|---|---|
| Boot, first-boot screens, intro, credits | works | works (runs fork3–fork13) | both work |
| Intro / startup video flicker | open (#24, #5); PR #32 | open; PR #32 now in `hybridgt/next`, untested in game | both incomplete |
| Menus | works | 30 fps, 0 dropped draws | both work |
| World loads, prologue renders | works | works; Lucia, hair, sky, sunlit exteriors seen | both work |
| Character and camera control | works (keyboard as pad, XInput) | works (same code) | both work |
| Long session stability | 90+ min (RTX 3050) | longest HybridGt run ~15 min, no device loss | cannot be verified here |
| World frame rate | 1–3 fps | 3.5–3.8 fps at 1080p with speed switches | both incomplete |
| Shadows / indirect light | black | black | both incomplete |
| `IrradianceCache_Shade*` (indirect light probes) | translate (#11) | translated by HybridGt's wave-wide fallback; now #11 too | both work (translation only) |
| Depth bounds | not in ZTRX main (PR #35) | in `hybridgt/next` (upstream `c96b4f2`) | HybridGt ahead |
| Textures picked by index after upload | not in ZTRX main (PR #48) | in `hybridgt/next` (upstream `a803c87`) | HybridGt ahead |
| Byte-copied descriptor mirroring | no | in `hybridgt/next` (upstream `a26859f`) | HybridGt ahead |
| Integer-target blend fix (#36) | open PR | in `hybridgt/next` | HybridGt ahead |
| Cross-wave `ds_bpermute` / `ds_permute` (#43) | open PR | in `hybridgt/next` | HybridGt ahead |
| FidelityFX (FSR) calls | refused (no module) | HybridGt module: loads AMD's PC upscaler, dispatches on the host list | HybridGt ahead (game test pending) |
| Series S mode | not reported | black screen at 11 draws/frame | HybridGt incomplete |
| Constant samplers at a join | refused | HybridGt reserved sampler slots | HybridGt ahead |
| Ray-tracing structures (BVH builder) | off | off (`VICTORY_BVH_BUILDER` exists, builder pipelines incomplete) | neither |
| Geometry shaders (voxelization) | none | none (195 programs) | neither |
| Diagnostics (capture, keys, DRED, pipeline wait) | yes | same code | both work |
| Launcher | `scripts/play.ps1` | README commands | ZTRX ahead (convenience only) |
