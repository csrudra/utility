# NVIDIA wave64 compatibility

## Measured (2026-11-24, `hgt-gfxdiag` check `wave64`)

| Adapter | Host lanes | Native ballot = console wave64 ballot | Two-half emulated ballot = console |
|---|---|---|---|
| RTX 4070 Ti, compute | 32 | **no** | yes |
| RTX 4070 Ti, mesh | 32 | **no** | yes |
| WARP, compute | 4 | no | yes |
| WARP, mesh | 4 | no | yes |

Test: one 64-thread group, predicate `t % 3 == 0`. The console (RDNA2, wave64)
answers one 64-bit mask for all 64 threads. On the 4070 Ti each thread sees only
its own 32-lane half, so any shader that reads a ballot, lane index, mbcnt,
readlane or a DPP/permute across lanes 32–63 gets wrong data. Emulating the wave
as two halves joined through group-shared memory gives the console answer.
Reproduce: `HYBRIDGT_ADAPTER=hw cargo test -p hgt-gfxdiag wave64 -- --nocapture`.

## Why this matters for the black world

All 9,282 mesh shaders of the title are wave64. VIctory's wave64 emulation
(patch 0001) covers compute shaders only. Two outcomes seen:

- Run 19: an unfinished mesh-emulation experiment refused 469 mesh shaders
  ("emulated wave operation outside uniform control flow"); their draws were
  dropped, so the G-buffer stayed empty. The experiment is now set aside.
- Run 20 (without it): mesh-shader failures fell to 11, but the GPU was removed
  ~frame 1,651 once the world began drawing. Leading cause (unproven): mesh
  shaders running with 32-lane semantics on wave64 code.

## Still needed

1. Done: mesh-stage check (`check_wave64_stage(.., Mesh)`). Two-half emulation
   through group-shared memory and group barriers is correct in mesh shaders on
   the 4070 Ti, when the cross-lane op is reached by all 64 threads.
2. Open, the actual blocker: Mesh-stage emulation in the translator that also handles cross-lane ops
   inside divergent control flow (the 469 refusals).
3. Vertex and pixel stages: cannot use group-shared memory; need a separate
   strategy (e.g. per-wave-half analysis or WaveSize-aware rewrite).

## Why the 469 refusals are hard

The emulation joins halves with a group barrier. A barrier must be reached by
every thread of the group, so a cross-lane op inside a branch only some threads
take cannot use it. Fix, proven in this harness (`check_wave64_divergent`): predicate instead of
branch. Every thread reaches the exchange, so the barrier is legal, and a thread
outside the branch contributes 0. For `if (t < 40) ballot(t % 3 == 0)` it gives
the console mask `0x00000092_49249249` in compute and mesh, on the RTX 4070 Ti and
WARP. Still to do: apply this in VIctory's translator (`emit/lower.rs`), where
the op sits in arbitrarily nested control flow and loops; loops whose trip count
differs per lane need the exchange repeated until every lane has left.

## Translator change (patches 0012–0013, 2026-11-24)

- 0012: an emulated cross-lane op under a lane (EXEC) guard, in a block every
  thread runs, is now translated: the exchange runs in all threads and the guard
  masks each lane's contribution (reductions/prefix: neutral value; first-lane
  read: first guarded lane; lane read: unaffected). Real divergent branches and
  loops (non-uniform blocks) are still refused.
- 0013: wave64 emulation enabled for mesh shaders, within D3D12's 28 KiB mesh
  group-shared limit (was compute only).
- `victory-shader` tests: 122 passed. Not yet measured: how many of the 469
  previously refused mesh shaders now translate (needs a `translate` pass over
  the title's shaders) and whether the GPU removal at world start is gone.

## Offline translate of the title's shaders (2026-11-24, read-only, no launch)

| Build | Mesh programs emitted (of 8,713) | Emulated wave64 | Host-wave fallback |
|---|---|---|---|
| 0013 (mesh emulation, no fallback) | 1,629 | 1,629 | 0 |
| 0014 (fallback) | 8,214 | 1,486 | 6,728 |

6,852 programs (6,729 mesh, 124 compute) put a cross-lane op inside real divergent
control flow (non-uniform blocks), which predication of guards (0012) does not
cover. The 6,728 fallback mesh programs run with 32-lane semantics on NVIDIA:
their draws execute but cross-lane results can be wrong; they are the leading
suspect for the run-20 GPU removal. Next: exchanges in non-uniform blocks
(repeat-until-all-arrive loops), then one game run with DRED.
