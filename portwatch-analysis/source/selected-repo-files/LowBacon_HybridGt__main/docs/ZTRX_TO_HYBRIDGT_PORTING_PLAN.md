# ZTRX → HybridGt porting plan and gap analysis

2026-11-25.

## Decision

ZTRX is not a separate runtime: it is victory-gta6 with one shader fix (#11) and a launcher
(see `ZTRX_IMPLEMENTATION_AUDIT.md`). Its value is the **open pull requests** of its testers.
HybridGt therefore does not port ZTRX as a code base. Instead, HybridGt:

1. moves its runtime base from victory-gta6 `1684989` to the fork's newest `main`, `a26859f`.
   That commit already contains all of ZTRX's code, plus depth bounds, texture re-checks,
   descriptor mirroring and faster defaults;
2. replays its own commits that the fork lacks on top of that;
3. takes ZTRX PRs that are tested and merge cleanly.

All of it is GPL-3.0-or-later, as is HybridGt, so no licence boundary is crossed. Cherry-picks
keep each author, and `-x` records the source commit.

## Done (branch `hybridgt/next` in `E:\GTA\HybridGt-work\victory-gta6`)

| Order | Commit(s) | Source |
|---|---|---|
| base | `a26859f` | fxceless/victory-gta6 `main` (contains ZTRX `2119b0e`) |
| 1 | wave-wide branch fallback | HybridGt (old patch 0004) |
| 2 | FidelityFX module stage 1 | HybridGt (old 0007; uses upstream's `view_heap_limit`) |
| 3 | FidelityFX stage 2 (AMD PC upscaler on the host list) | HybridGt |
| 4 | constant samplers in reserved heap slots | HybridGt (merged with upstream's null-slot heap) |
| 5, 6 | integer-target blend; LDS-flag regions | ZTRX PR #36 |
| 7, 8 | guarded-texture stale frames; loading screen | ZTRX PR #32 |
| 9, 10 | `ds_bpermute_b32`, `ds_permute_b32` across host waves | ZTRX PR #43 |

Dropped HybridGt commits, now upstream in better or equal form:
- cache warming (upstream `translate --warm all`);
- `v_cvt_f32_f64` and `v_permlane16` (upstream has both);
- first-half interpolation (upstream, only for programs refused without it);
- image descriptors read for size (upstream `unused_descriptor_kind`).

Not taken: ZTRX PR #30. It conflicts in four files, its own testers measured 0 of 4 refused
pipelines fixed, and it weakens group synchronisation.

## Remaining gaps, ranked

| # | Gap | Evidence | Next step |
|---|---|---|---|
| 1 | Black shadowed areas: ray-traced lighting has no acceleration structure | both projects; `docs/fork-ray-tracing.md` | BVH builder pipelines (3 first-lane reads) |
| 2 | Frame time ≈ 230–300 ms: CPU memory sync and copy-back serial | HybridGt timing logs; ZTRX #55 | profile `hybridgt/next` defaults against the old switches |
| 3 | Shadow-ray tracing programs (`CS_TraceShadowRays_*`): dynamically indexed view address | HybridGt offline list | `view_address` with a dynamic index |
| 4 | Series S black screen | HybridGt fork13 | needs a game run with FSR stage 2 |
| 5 | Startup flicker | #24, #5 | #32 now included; needs a game run |
| 6 | 195 voxelization geometry shaders | offline list | geometry stage or a compute rewrite |

Game runs and offline translation over the game's files need the user's permission. The latest
brief forbids the game folder. Until that permission is given, changes are checked with the
crates' own tests: synthetic shaders on the GPU and on WARP.
