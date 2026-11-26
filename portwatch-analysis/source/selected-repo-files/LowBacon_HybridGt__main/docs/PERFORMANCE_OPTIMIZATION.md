# Performance optimisation log

Each change is measured against the run before it. Game-run numbers come from the frame line,
averaged over the steady world frames of a run.

## 2026-11-25: descriptor sync change check (patch 0012)

Run next1 spent 49.5 ms a frame in `sync_heaps`, which looks at 234,346 slots a frame and mirrors
50,399 of them.

The change check was a BLAKE3 hash of each 32-byte record, under one lock per slot. It is now the
exact 12-byte key that `HostHeap::mirror` reads (tag, view index, generation), with one lock per
64 KiB page. Same answers, by construction and checked by the benchmark's assert.

Ignored test `change_check_cost` on the test machine: **15.1 ms → 0.83 ms** for 234,000 slots. The
remaining cost is the mirroring itself. Not yet measured in a game run.

## Switches ready for the next run (next2)

| Switch | Expected effect | Evidence |
|---|---|---|
| `VICTORY_WIDE_REFRESH=1`, `VICTORY_WIDE_MERGE=1` | buffer copies (88 ms in next1) spread over threads | on in HybridGt's fastest earlier runs (3.5–3.8 fps); off in next1 |
| `VICTORY_LEVELS_ON_DEMAND=1` | textures get card memory only for the levels the title holds; the card was full in next1 (6,258 slots waiting) | upstream `a26859f`: 3.1 GB not allocated on an RTX 4070, no device loss |
| `VICTORY_FIRSTLANE_OWN=1` + `VICTORY_BVH_BUILDER=1` | ray-tracing structure builder: its last "first-lane read" programs translate, so the builder can run | ZTRX #55: world "lit" at 4–5 fps on an RTX 5060 with the builder on. The builder turns itself off if any of its pipelines is missing |

`VICTORY_FIRSTLANE_OWN` is part of the shader cache key, so next2 needs its own warm-up
(`cache-next2`).

## Run next2 (2026-11-25): builder + levels on demand + wide refresh. Result: crash

Shader cache warmed with `VICTORY_FIRSTLANE_OWN=1`: 25,741 translated, 244 refused (3 more than
next1 translate). The run used `VICTORY_BVH_BUILDER=1`, `VICTORY_LEVELS_ON_DEMAND=1`,
`VICTORY_WIDE_REFRESH=1` and `VICTORY_WIDE_MERGE=1`. Log: `logs/next2.log`.

- The ray-tracing structure builder ran: "all of its programs have host pipelines pipelines=53".
- Levels on demand worked: 3,014 MB of the card not allocated for levels the title does not
  hold. Still 13,932 texture slots waiting while the world loaded.
- About 2 min in, still loading, the title crashed: access violations on many title threads at
  once, with registers holding float bounds (`0xff8000007f800000`, `0xff800000ff800000`). This
  is the failure `docs/fork-ray-tracing.md` describes for a partly wrong builder (upstream run 98):
  box bounds stored over the title's own pointers.
- Likely cause: `VICTORY_FIRSTLANE_OWN=1` is a shortcut, exact only when the value is the same in
  every lane of the console wave. At least one builder program reads a value that differs per
  lane. The fix is an exact cross-wave first-lane read (the console wave's first active lane can
  be in the other host wave). Until then the builder stays off.

## Run next3 (2026-11-25): levels on demand + wide refresh + patch 0012, builder off

Same as next2 without the builder; cache `cache-next`. The user reports textures and assets now
load, at about 3 fps. Steady world frames 08:18:57–08:19:27 against next1:

| | next1 | next3 |
|---|---|---|
| fps | 1.9–3.2 (3.0 steady) | 3.0–3.4 |
| ms/frame | 309–337 | 296–332 |
| CPU preparing | 118–140 ms | 124–144 ms |
| buffer copies | 73–88 ms, 190–194 MB | 73–80 ms, 171–177 MB |
| GPU | 110–130 ms | 99–124 ms |
| copy-back thread | 154–182 ms | 148–174 ms |
| descriptor sync | 49.5 ms (234k slots, 50k mirrored) | 37.4 ms (195k slots, 41k mirrored) |
| textures waiting for memory | 6,258 (card full) | 9,537 waiting, 2,875 MB not allocated for absent levels |

FidelityFX: the title made no FidelityFX call in the Series X profile (no "FidelityFX" log line in
next1 or next3). It asked for the upscaler only in Series S mode (`--console series-s`, run fork13).

## Benchmark procedure (from run next8 on)

The same save (`HybridGt-work/data`), Series X profile, 1080p, cache `cache-next3` (pipelines
saved). `VICTORY_KEYS` presses Enter every 4 s from 20 s to 120 s. `autoclose.sh` closes the game
3 minutes after the first 3 consecutive frame lines under 500 ms with 3,000+ draws. No user
input. "Steady" means frame lines after the world settled with the camera still.

## Runs on victory-gta6 `9376fd6` (fork's CPU-side frame commit) + ZTRX shader PRs #10, #51, #56

| Run | Change against the run before | Steady world fps | ms/frame | Notes |
|---|---|---|---|---|
| next7 | new base and new cache, no saved pipelines | (first run) | 335–700 | 1,000 pipelines made in the run; cutscene draws dropped, slow load. Not a regression |
| next8 | remaps: scatter pages joined into ranges | crash | — | joined pages were several placeholders: `MapViewOfFile3` error 487. Fixed in next9 |
| next9 | remaps: both locks once per scatter call; no-op remaps skipped | **3.5–3.6** | **276–284** | 15 min, no crash. Steady frames: preparing 96–104, GPU 150–155, copy-back 165–181 ms |
| next10 | `VICTORY_CARD_FETCH_INFLIGHT=1` (fork switch) | 1.5–1.7 | 578–700 | GPU 420–480 ms (×3): 87 MB a frame copied to PC memory inside the GPU's timeline. Copy-back thread 70–90 ms. **Rejected** |

next9 against next3 (the best run on the old base): 276–284 ms vs 296–332 ms per steady world
frame. Several changes came in together (upstream `9376fd6`, the ZTRX shader PRs, the remap
locking), so the gain is not attributed to one of them.

### Remap lock (from the next9 counters)
- While loading: 127–900 lock takings a frame, 1,700–3,500 pages, **held 700–1,300 ms a frame**,
  waited for up to 12 ms. So after the change the cost is the holding: about 0.5 ms a page.
- Steady world: 4–40 pages a frame, about 1 ms held.

Next: split the held time between system calls and GPU-side notifications (timers added, next11).

### Copy-back (next9, steady)
- The submitting thread waits 154 ms a frame in "title memory read" settles (2 a frame: one for
  a title buffer copy, one for an upload fill).
- The relay thread waits 134 ms for 7 fetches.
- The GPU is 64% busy.

Next: title buffer copies on the card instead of waiting (`VICTORY_GPU_BUFFER_COPIES=1`, next11).

## Runs next11–next12: copy-back waits removed from the submitting thread

| Run | Change | Steady world fps | ms/frame | Submitting thread's settles |
|---|---|---|---|---|
| next9 | (reference) | 3.5–3.6 | 276–284 | 2 a frame, 154 ms ("title memory read": a buffer copy, an upload fill) |
| next11 | `VICTORY_GPU_BUFFER_COPIES=1` (patch 0020) | 3.7–3.8 | 261–273 | 1 a frame, 97 ms (the upload fill) |
| next12 | + `VICTORY_GPU_FILLS=1` (patch 0021) | **3.7–4.0** | **252–270** | 1–1.5 a frame, 83 ms, now "title memory changed under shader writes" |

next12 moved 15 buffer copies and 5,600–6,100 scratch fills a frame onto the GPU. CPU copies fell
from about 185 MB to about 160 MB a frame.

### What is left in a steady frame (next12, about 260 ms)

| Part | Time | Cause |
|---|---|---|
| Copy-back thread | 160–188 ms | 100 ms waiting for 7–8 fetches; 66 ms with nothing to land |
| CPU preparation | 101–117 ms | copies 53–62 ms for about 160 MB; textures 2–4 ms |
| GPU | 78–115 ms | the card is 66% busy |
| Settle "title memory changed under shader writes" | 77 ms | the title's CPU writes 85,000–102,000 runs a frame (0.21–0.26 MB, 2–3 bytes each) into pages that flights' shaders write. The merge path (`merge_under_writes`) allows 512 runs a submission, then the submission waits for every flight |

### Measured and rejected or deferred

- `VICTORY_CARD_FETCH_INFLIGHT=1`: GPU time ×3 (next10).
- Kernel reads are not the copy cost. `read_cost` benchmark: 155 MB in 64 KiB reads takes 20 ms
  through the kernel, 14 ms as a plain copy. Refreshes already read whole runs of 64 KiB pages.
  The rest of the 53–62 ms needs the diagnostics build's copy counters.
- **Masked merge on the GPU, designed but not built.** For the 85,000–102,000 tiny runs: one
  compute dispatch would write only the title's bytes into the card copy. It needs two things:
  - an indexed log of the merged runs with their send number (the copy-back skips bytes sent
    after its fetch);
  - hashing of the merged pages after the merge.

  This is the next target. It would remove the remaining 77 ms settle.

## Runs next13–next14: masked merge on the card (patches 0023–0025)

| Run | Change | Steady world fps | ms/frame | Settle left |
|---|---|---|---|---|
| next12 | (reference) | 3.7–4.0 | 252–270 | 77 ms "title memory changed under shader writes" |
| next13 | `VICTORY_GPU_MERGE=1`, log in a tree | 3.4–4.0 | 252–298 | that settle gone (35 ms "lists in the air"). CPU preparation rose to 125–183 ms: 242,000 runs a frame, a tree insert each |
| next14 | log as one vector per send, binary search | **3.7–4.2** | **239–272** | 69 ms "256 lists in the air" (`VICTORY_LATE_WAIT_LISTS`) |

In next14 the merge step takes 10–23 ms of the submitting thread for 114,000–486,000 dwords a
frame. Those are merged on the card in 1.5–6.4 dispatches. No device loss, no crash.

Correctness checks:
- `merge_log_tests`: masks, joined dwords, unseen runs, pruning, runs merged again. This test
  found a bug: a run merged again at the same offset replaced the older one, and that run would
  have been skipped forever.
- `card_merge_tests::the_merge_writes_the_masked_bytes_and_nothing_else`: on the RTX 4070 Ti,
  every byte of a 64 KiB buffer is checked.

## 2026-11-25, afternoon: merges, runs next16-next17

Branch `hybridgt/next3` (exported as `patches/victory-gta6-next3/`, one diff on
fxceless/victory-fork `a253706`):

- Merged fxceless/victory-gta6 `f85101b` (submit thread `VICTORY_ASYNC_SUBMIT`, copy queue
  `VICTORY_QUEUE2`, indirect draw windows, profiler) and fxceless/victory-fork `a253706` (frame
  log, driver watch, heap lock; their figure: 6.0 -> 8.9 fps with `VICTORY_INDIRECT_WINDOW=1` on
  an RTX 4070, first room). Our relay copy-queue fetch defers to `VICTORY_QUEUE2`.
- 13 ZTRX PR commits (shader lowering: f64, packed dot, quad masks, interpolation, LOD; uniform
  LDS reads, which make the last 3 BVH builder programs translate; batched texture probes).
- POPS pixel shaders translate (10 ped cut-out programs), after upstream `522d2bc`.
- xmem: no split call where our own unmap left an exact placeholder; no commit call for
  section pages committed already.
- FSR 1 (AMD, MIT, vendored) on present: `VICTORY_FSR=1`, `VICTORY_FSR_OUTPUT=WxH`; GPU test.
- `victory.exe` has an icon of its own (original design).

| Run | Build / switches | Scene | Frames |
|---|---|---|---|
| next16 | next2 + `VICTORY_FETCH_COPY_QUEUE=1` | world, user playing and driving | median 300 ms (next14: 255 ms); not the same scene, no gain claimed |
| next17 | next3 + async submit, queue2, windows, texture no-wait | **new game** (saves moved to `save-backup/`): prologue cutscene and streaming | 0.6-4.2 fps; remapping held 372 ms/frame (6,200 pages, 260 ms in system calls), card ~11 % busy, up to 866 draws dropped while pipelines were first built (new cache) |

The new-game scene is not comparable with next14's save. Next: a run on the warm cache with the
xmem change, then 1080p against 720p+FSR.

Shader translation (offline, after the POPS fix): 25,751 of 25,985 programs. Left: 196 geometry
shaders (no geometry stage in the translator; they also read a driver table through user data
0-1), 29 DXBC programs inside the console's FidelityFX DLL (never run: the host's upscaler is used),
5 shadow-ray programs (read the BVH's address from a descriptor; useless until the BVH builder
works), 1 nested waterfall (opaque lane mask), 1 lane mask exchanged under a partial EXEC.

### Run next18b (next3 + xmem change + POPS shaders, warm cache, same switches as next17)

New game, prison cell after the opening: **4.3-5.3 fps** (190-230 ms a frame, 4,700-6,600
draws), dropped 250-390 draws a frame without a host pipeline. Of a frame: copies of title
memory about 80 ms (130-160 MB), copy-back about 100 ms (50-58 MB); remapping 0.6-2 ms (the
scene was not streaming, so the xmem change is not measured by this).

Seen by the user: sunlight edges in tile-sized blocks on faces and clothes, and characters' eyes
glowing. The blocks fit a shadow mask whose edge-refining pass does not run (candidates:
`CS_ShadowRenderTiledCascadesAlpha*` and `CS_TraceShadowRays_*`, both still untranslated; three
compute pipelines the host refused, `6b82bc7d22016cb5`, `2da4beb386509b77`, `02384a60fda6f2d0`).
The eyes may come from the POPS ped shaders first drawn in this run: that path is now off unless
`VICTORY_POPS=1` until a run with it off says.

### Runs next19-next21 (in place, geometry stages)

- **next19** (POPS off, `VICTORY_TITLE_GS=1` before the switch existed, `VICTORY_INPLACE=1` with
  the probe): the title crashed 1 min 57 s in (prologue cutscene prestream; access violation in
  the title's code reading unmapped memory). Probe on the RTX 4070 Ti: private memory and a
  **committed page pool section** open in place, read and write; a reserved section is refused.
- **next20** (only `VICTORY_TITLE_GS=1`): no crash; 3.4-4.5 fps in the cell. The title made no
  pipeline with a geometry stage there.
- **next21** (`VICTORY_TITLE_GS=1 VICTORY_POOL_COMMIT=1 VICTORY_INPLACE=2`): **slower, 2.4-3.1 fps**
  (320-420 ms). In place: 81 windows 384 MB, 3,606 title buffers 40 MB (78 in page pool
  sections); 1,041 turned down (view memory scattered over the pool, or not committed whole).
  Copies fell from ~80 to 42-60 ms, copy-back stayed at ~80-100 ms, and GPU time rose to
  60-130 ms with the card ~100 % busy: placed buffers are in system memory, read over PCIe.
  Conclusion: in place only for small buffers the CPU rewrites each frame; data the card mostly
  reads stays in its own memory. Window closed by the user at the end (no crash).
- Three compute pipelines the host refused (`2da4beb386509b77` alphaResolve prefilter,
  `6b82bc7d22016cb5` / `02384a60fda6f2d0` VFX triangle clip): **the shaders require 64-lane waves;
  the RTX 4070 Ti has 32** (debug layer). The cascade shadow program
  `CS_ShadowRenderTiledCascadesAlpha*` fails for the same reason: wave64 programs whose thread
  group holds several console waves need branches made group-wide (not yet in the translator).
- Screenshots of runs: `HybridGt-work/captures/<run>/` (`tools/capture-loop.ps1`, every 30 s).

### Runs next22-next23: where the remaining frame goes

- **next22** (`VICTORY_READ_PROBE=8`): of 153,816 copied-back pieces probed (7.2 GB), the
  title's CPU touched **10,046 (6.5 %)** before the card wrote them again. About 93 % of the
  copy-back (80-100 ms a frame) is never read. 4.5 fps; heap pass 87 ms, copies 66 ms,
  copy-back 99 ms.
- **next23** (heap pass timed in parts, `VICTORY_UNWATCHED_FRAMES=2`): 4.4-4.9 fps. The heap
  pass is **45-53 ms over buffer slots** (14,000-50,000 slots re-made a frame) and **0.5-0.8 ms
  refreshing**; refreshing unwatched memory every second frame changed nothing.
- Research (web, summarised): shadPS4 (PS4 on PC, same AMD unified memory) has a "precise"
  readback mode: GPU-written pages lose CPU access and are downloaded on first touch (a 512 KiB
  window), 2.7-7.2 ms a frame measured on an RTX 5090. Xenia mirrors guest memory in one VRAM
  buffer (tiled, default heaps) and never copies back. Ryujinx moves buffers between memory kinds
  by how they are used. `D3D12_HEAP_TYPE_GPU_UPLOAD` (Resizable BAR) lets the CPU write VRAM
  directly. No project runs wave64 shaders on 32-wide NVIDIA hardware other than by groupshared
  emulation.
- Built from that (fork `70cf037`): copy-back on first touch (`VICTORY_LAZY_BACK=1`) and the
  heap pass keeping slots whose records are unchanged (on by default; `VICTORY_SLOT_PRINTS=0`).
  Measured in next24.

### Runs next24-next28: two large savings that crashed, one kept

| Run | Switches | Result |
|---|---|---|
| next24 | lazy copy-back + slot prints (first form) | crash (title writes through null) ~6 min in; copy-back 80-100 -> ~7 ms before it; texture pass 2-7 -> 105-181 ms (`ensure` took a lock per read) |
| next25 | + all-or-nothing closing, guard re-closing | crash, same kind |
| next26 | + every kernel read hooked, block filter | crash while loading **with 0 pieces deferred**: slot prints |
| next27 | lazy copy-back alone | crash (same title offset as next25): lazy copy-back on its own too |
| next28 | slot prints that also require the same copy (`VICTORY_SLOT_PRINTS=1`) | no crash; median 196 ms (5.1 fps), p90 918 ms; only 4,000-5,500 slots kept a frame (most slots show a different copy each frame) |

Both are off by default. Lazy copy-back needs every path by which the title or this runtime sees
title memory found first; the likely kind is a reader that neither faults nor goes through
`crate::host`'s reads. Frame-time spread: next23 median 235 ms, p90 663 ms, worst 3.9 s; the
spikes (one frame in ten over 0.6 s) are what play feels like.

Copies move 185 MB in 81 ms (2.3 GB/s): overhead, not bandwidth. Next: the sampling profiler and
frame log (diagnostics build, next29) to see where those milliseconds and the spikes go.

### Runs next29-next31: the crashes are not the speed changes

- Every crash of runs next19-next30 (seven reports) came at **the same moment**: the prologue's
  intro cutscene ("cine@leadout@int_prolo@int@leadout") in its *Prestream* state, 1 min 23 s to
  1 min 57 s into a new game (5 min 26 s once), the title writing through null. next26 and next30
  crashed there with **nothing deferred** by the lazy copy-back. Runs before the saves were moved
  (next1-next18) loaded a save past this cutscene.
- At that moment the title makes thousands of pipelines through the two device methods the runtime
  does not implement: **16,384 calls of 0x1c8 (graphics) and 2,048 of 0x218 (compute)** in next30.
- next31: answering them with a placeholder pipeline (no shaders) instead of a failure made the
  title draw its frame through them: ~9 draws a frame, black screen with sound. Off again
  (`VICTORY_PLACEHOLDER_PIPELINES=1` to try).
- Consequence: **methods 0x1c8 and 0x218 are part of how the Series X build renders** (not only
  Series S). Their pipelines are where draws are missing (the user sees windows and other assets
  wrong). Implementing them is now the first task for stability and picture both. The descriptions
  carry native GFX10 code with the same hash header as the shader containers' code, the register
  state and metadata records (`docs/SERIES_S_AND_FSR.md`).
- The lazy copy-back fix (other host copies told of a deferred piece) is in the tree (fork
  `5c..`), not yet measured past the cutscene.

### Device methods 0x1c8/0x218: the code is the containers'; DexNom/VIctory

- next32 (200 s, diagnostic): the descriptions name standalone code in GPU memory (no container
  around it). 0x1c8: w1/w2 registers (0x184), w3/w4 a 0xbc block starting with a hash, w5/w6 vertex
  code, w7/w8 its metadata, w9/w10 pixel code, w11/w12 its metadata. 0x218: entries of 12 words,
  w1/w2 registers (0x1c, thread group), w3/w4 hash and 3, w5/w6 code, w7/w8 metadata (0x403).
- **All 16 code headers seen (the two hash-carrying `v_nop`s) match exactly one container's native
  code in `shaders.rpf`.** Plan: an index from code header to archive record (built offline by our
  tool), then real pipelines from the containers the translator already handles: compute (0x218)
  first, then graphics (0x1c8), whose blend/depth/target state must be read from the register block.
- DexNom/VIctory (upstream VIctory + 10 commits): same stub for 0x1c8/0x218; experimental ray
  tracing on an RX 7900 XTX ("frame times can still reach several seconds"); five shadow-ray
  compute shaders and the voxel-visibility shader recovered. Ported: `76749ce` (voxel visibility
  now translates and validates here). Its shadow, ray-structure and shader-variant commits
  (`5f4c3df`, `bc3cd4b`, `921d8d3`, `ddb7332`) conflict with this tree's translator and need a
  merge by hand.

### Runs next33-next34: method 0x218 implemented

- `victory shader-index <archive> <file>` indexes 26,698 native programs by their first 12 bytes
  (984 headers shared by more than one container). With `VICTORY_NATIVE_INDEX=<file>` and
  `VICTORY_NATIVE_PIPELINES=1`, method 0x218 makes compute pipelines from those containers.
- **next33**: 1,024+ compute pipelines made, 0 missed; reached the world, 5.1-5.3 fps (188-197 ms:
  copies 50-64 ms, copy-back 82-91 ms, heap pass 53-80 ms); no crash.
- **next34** (same + lazy copy-back): crashed at the prologue cutscene, same title offset
  (`+0x23cf683`), nothing deferred. next33 passed it by timing. The remaining suspect is method
  0x1c8 (graphics), still failing there. Next: 0x1c8 from containers, with its graphics state read
  from the register block (w1/w2, 0x184 bytes, starting `4005d808`).
- **next35** (old save from a separate `data-bench` folder, 0x218 native, lazy copy-back): crashed
  in the world (`+0x2215c35`, as next27). Lazy copy-back cut copy-back to 15 ms but fetching on
  touch cost ~60 ms a frame and copies rose to 150 ms: as built it loses most of its gain and still
  lets a stale read through. Keep it off; the dependable route to more frames is method 0x1c8 (so
  runs survive the prologue) and then cheaper copies.

### Run next36: fxceless d510ee4 merged + 0x218 native pipelines — 5.2-7.0 fps

Switches: `VICTORY_ASYNC_SUBMIT=1 VICTORY_QUEUE2=1 VICTORY_INDIRECT_WINDOW=1 VICTORY_TEXTURE_NO_WAIT=1
VICTORY_JOIN_PARTS=1 VICTORY_BACK_OWN_VIEW=1 VICTORY_INDIRECT_GATHER=1 VICTORY_CARD_REHASH_RUNS=1
VICTORY_NATIVE_INDEX=... VICTORY_NATIVE_PIPELINES=1`, old save from `data-bench`.
Frames 143-191 ms (best 7.0 fps, user saw ~7): copy-back 39-56 ms (was ~85), copies 34-67 ms,
heap pass 33-132 ms (now the largest and most variable part), dropped draws 87-121 a frame (was
~350: the 0x218 pipelines draw). No crash in the world. User: water looks rough compared with the
console build. Next: the heap pass, method 0x1c8 (graphics pipelines, likely materials such as water
and glass), then copies.

### The streaming stalls (from fxceless d510ee4) and the plan for them

fxceless measured the dips while moving: in streaming frames the title waits on its own page
mapping (`CopyPageMappingsBatchX` -> `xmem::map_alias`), about 850 one-page remaps a frame, each a
view taken away and one mapped in the kernel: 246 ms of a streaming frame, nearly all waiting on the
process's address-space lock. Here `map_alias_locked` already goes through `map()` with the
placeholder and commit calls skipped (2 kernel calls a page instead of 4). Joining pages into longer
views was tried by fxceless and broke faces (black/red), so not that.

Plan (not built yet): keep the remaps as a table (address page -> section, offset) without kernel
calls; GPU-side reads of those pages go through the runtime's own section views; the title's own
view is made only when its CPU touches the address (exception handler), and every runtime path
that reads title memory there asks the table first. Same shape as the copy-back on first touch,
whose missed paths crashed: build with a probe first (how often the title's CPU touches tiled-heap
pages at all), then the table.

### Run next37: 1280x720 + FSR 1 to 1920x1080 — no gain

Same switches as next36, the user's own save: FSR 1 ran on present; world frames median 224 ms
(4.5 fps), best 147 ms (6.8), against 143-191 ms at full 1080p in next36. Rendering fewer pixels
does not shorten the frame: it is bound by the CPU side (copies, copy-back, heap pass, page
remaps). FSR stays available (`VICTORY_FSR=1`) for when the card becomes the limit.

### Run next38: in-place copies (`VICTORY_COPY_PLAIN=1`) — kept

next36's switches plus `VICTORY_COPY_PLAIN=1`, the user's own save, no crash: copies 48.0 -> 40.6 ms a
frame on average (-15 %), best frame 132 -> 125 ms, median unchanged at 202 ms (~5 fps). Kept in the
standard set. The median moves only when the other CPU parts move too (heap pass, copy-back, page
remaps); next: the per-page remap stalls (plan above), then method 0x1c8.

### Runs next39-next40: lock-free descriptor mirror — kept

`HostHeap::mirror` took one lock over the whole heap's made-table for every call: 58,000-90,000
calls a frame in the world, 80-130 ms a frame of lock and lookup summed over the threads (next38,
next39). A per-slot atomic copy of the key, published only after the host descriptor is written and
kept, answers calls whose slot is already made from the same record without the lock (28,000 a
frame in next40); `VICTORY_MIRROR_LOCKED=1` restores the old path. Same scene, same switches:

| Run | Median | p10 | p90 frame | Worst frame |
|---|---|---|---|---|
| next38 | 5.0 fps | 2.0 fps | 509 ms | 547 ms |
| next39 (timer only) | 4.8 fps | 2.4 fps | 415 ms | 647 ms |
| next40 (lock-free) | **5.8 fps** | **3.4 fps** | **291 ms** | **345 ms** |

One run each: a trend until it repeats.

### Device method 0x1c8 is not water or glass

The 43 saved 0x1c8 descriptions all have the same vertex layout (POSITION, COLOR, TEXCOORD),
alpha blending (CB_BLEND_CONTROL `e5040504`: src alpha / inverse src alpha) and no depth test
(DB_DEPTH_CONTROL `007007f0`): immediate-mode 2D/overlay pipelines. Decoded so far in the 0x184
register block: +0xd0..+0xec CB_BLEND0-7_CONTROL, +0xc0/+0xc4 DB_STENCILREFMASK(_BF), +0xb8
DB_DEPTH_CONTROL, +0x38/+0x4c SPI_SHADER_PGM_RSRC1 of VS/PS. The earlier note that 0x1c8 is
"likely water and glass" was wrong.

### Compute pipelines NVIDIA refuses (64-lane waves)

Three compute programs translate and validate but D3D12 refuses their pipelines on the RTX 4070 Ti
("Shader wants wave lane count of 64 but maximum wave lane count for device is 32", debug layer):

| Shader | Why it kept 64 lanes | Now |
|---|---|---|
| `CS_AlphTransmissionPrefilterMip` (refraction mip chain sampled by water and glass) | barrier inside the program's early-out region; with the early-out left out, a sampler built inside a skip could not be tracked | **translates to 32-lane waves** (exact form, validated, pipeline created): a join where one edge holds a built/loaded descriptor and the others none takes that edge's |
| `CS_DefragHeap_ComputeRelocations` | 64-lane prefix scan carried across loop iterations (`v_readlane ..., 63`) | still refused: an approximate form would compute wrong relocations |
| `vfx_triangleClip:CS_CollectTriangles_Meshlets` | allocation idiom over 64 lanes | still refused |

### The boat mission ("Cal fell off the boat") — not fixed yet

Mission start on the boat: the boat sinks or ends on the bank, the engine dies, the mission fails
("CAL FELL OFF THE BOAT", "THE BOAT COULDN'T BE DRIVEN"). After a retry the boat sometimes floats
and drives. A/B runs, same save:

| Run | Switches | Result |
|---|---|---|
| next39 | standard set | water line above the boat's floor |
| next41b | without `BACK_OWN_VIEW` and `NATIVE_PIPELINES` | fails the same way |
| next42 | without `TEXTURE_NO_WAIT` and `LEVELS_ON_DEMAND` | fails the same way |

So none of those four switches is the cause. The boat's buoyancy reads water heights the GPU
resolves (`ShallowWaterSim:CS_ResolveHeightLookUps`, 92b4790eb4c29f6d: per query, three height
textures read with 16-bit packed coordinates, which the translator unpacks correctly; 1 KiB of
results per dispatch, run next43). Whether those results reach title memory correctly is the open
question; `VICTORY_TRACE_SHADER=92b4790eb4c29f6d` logs what title memory holds there. The game's
water tessellation compute chain (`water_tessellation:*`) and the shallow-water integration
(`CS_IntegrateHeight`, `CS_IntegrateVelocity`, `CS_AdvectionStep`) never ran in any run (never
bound by the title).

The face shaders (`ped_standard_head_cs`, the `compute_graph_ops` network ops) are created and bound
in the world without errors; why the mouths do not move is not found yet.

### Session 2026-11-25 (night): audit against the repair brief (no game runs: not authorized)

**Shader inventory, reconciled** (`translate-list-21`, `shaders.rpf`): 26,084 programs, 15 do not
emit: 5 `shadowmask:CS_TraceShadowRays_*` ("a descriptor read only as data") and 10
`PS_PedTexturedCutOutTint_Zero_*` ("a hardware SGPR input": the POPS collision input; they translate
with `VICTORY_POPS=1`, which made eyes glow). The cascade-shadow program counted before now emits.
The 29 FidelityFX shaders are DXBC in other files. 213 programs emit but fail Microsoft's validator
(71 mesh output > 32 KiB, 72 signature-part mismatches, 70 interpolation modes mixed in one row).

**Where a world frame goes** (run next40, 39 busiest world frames, means): copies to the card 48 ms
(103 MB), textures 32 ms (60 MB), copy-back 65 ms, GPU 4.3 ms; descriptor slot loop 60 ms, 41 ms of
it making host views. The card is nearly idle: every large cost is CPU-side runtime work.

**Page remaps** (runs next39-42, busy frames): 1,386-1,488 pages a frame, the remap lock held
151-226 ms a frame, 94 % in system calls, 102-163 us a page; the render side waits < 0.3 ms for the
lock, so the cost lands on the title's streaming threads (late assets), not directly on the frame.
Component benchmark on this PC (`remap_bench`, 512 pages): 6.7-7.9 us a page idle, 10-15 us with
2-6 threads toggling guards; one view per run of consecutive pages: 4.5-6.3 / 7.6-11.4 us. Neither
reproduces the in-game 100-160 us, so the next run's remap census (by system call, slowest
operations) decides what to change; joined runs are ready behind `VICTORY_REMAP_RUNS=1` (off).

**Trace ready, not run**: `play-trace.cmd` = `play-fast.cmd` + `VICTORY_TRACE_SHADER` for the water
height lookups (92b4790eb4c29f6d), the face blendshape mapping (61e54e90adccaf6a) and the HSS graph
output extract (970c4fbb3b017c0e) + `VICTORY_SYNC_TIMING=1`; log `logs\play-trace.log`.

### Trace run (play-trace.cmd, authorized "RUN THE TRACE"), 2026-11-25 22:49

Same configuration as `play-fast.cmd` plus `VICTORY_TRACE_SHADER` (water height lookups, face
blendshape mapping, HSS graph extract) and `VICTORY_SYNC_TIMING=1`; the user's save; frames
2073-4745 traced. Findings:

- **Water heights the boat physics reads** (`CS_ResolveHeightLookUps` results in title memory, 1,926
  readings): only 0.300 m (941x) or 0.000 m (713x), millimetre noise in the third value; unused
  slots hold -10000.0 (the title's "no water" sentinel), replaced after the GPU runs. Copy-back
  reaches title memory, before the title's fences in all three copy-back paths (checked in
  source). The heights are flat: no waves, no current.
- **Why flat (not proven yet)**: the shallow-water simulation's integration programs
  (`CS_IntegrateHeight`, `CS_IntegrateVelocity`, `CS_AdvectionStep`, `CS_SweepX/Y`) are never even
  created by the title, while the time-step chain (`CS_ComputeTimestep` -> `CS_MinTimestepReduce`
  -> `CS_CopyTimestepResult`) runs from frame 2073. Next: trace the time step the GPU hands back.
- **Face buffers in title memory**: the blendshape-mapping output reads NaN and the HSS extract
  output 0.0 in title memory; both are GPU-to-GPU buffers, so title memory may simply never be
  refreshed: not evidence of wrong GPU values by itself.
- **Remap census** (per second, busy samples): map view 140-230 us a call and unmap 90-115 us in
  the game, against 5-8 us in isolation; of 1,012 pages in one sample 932 were separate runs of
  consecutive section pages, so joined runs (`VICTORY_REMAP_RUNS`) would save < 10 %: left off.

### hgt-gfxdiag on the RTX 4070 Ti (driver 621.24)

`HYBRIDGT_ADAPTER=hw`: a 256 MiB buffer read by the card from system memory (where
`VICTORY_INPLACE` places title memory) 31.2 ms, **8.6 GB/s**; from video memory 0.97 ms, 277.6 GB/s;
from a **GPU_UPLOAD heap** (video memory the CPU writes directly, Resizable BAR) 0.98 ms,
**275.0 GB/s** - supported on this PC. That is why in place was slower (next21: GPU time 60-130 ms).
The runtime never creates a GPU_UPLOAD heap; the CPU-side copies (48 ms a frame, two steps through
staging) are the candidate for it. Hang reproductions stay skipped on hardware.

### Clean reset and the "242 shaders that do not translate"

At the user's request: the save moved to `save-backup/data-moved-out-2026-11-25-reset` (not deleted;
identical to `save-backup/data-2026-11-25-brief`), every shader cache deleted, the runtime rebuilt
from a clean target, all shaders translated again. The warm-up now names each failing container:

| Before | After | Containers | Why |
|---|---|---|---|
| 198 | 3 | geometry-only containers (195 `GS_VoxelizeGeneric`) | the runtime converter looked only for VS/PS/CS/MS programs; now falls back to the geometry program (as the offline translator did). The 3 left are stubs in the executable with no GPU program in them |
| 29 | 29 | `amd_fidelityfx_upscaler_xbox.dll` | AMD's precompiled code in an `ACCC` part; the runtime runs the PC FidelityFX instead, so never needed |
| 10 | 10 | POPS ped pixel shaders | need ordered pixel shading (ROV); the shortcut made eyes glow |
| 5 | 5 | ray-traced shadows | need the BVH builder |

242 -> 47 containers that do not translate; 15 of them matter.

### Correction: method 0x1c8 is the title's renderer path, not only overlays

The 43 descriptions decoded above (immediate-mode vertices, alpha blending, no depth) are the
first calls only. Run next31 showed that when 0x1c8 hands out pipelines (placeholders then), the
title moves its rendering onto them: the screen went black with ~9 draws a frame. So 0x1c8 is how
the title makes its graphics pipelines when it can (16,384 calls by the prologue), and the stream
path is its fallback. A placeholder for 0x1c8 alone would swap the prologue crash for a black
screen; the fix is real pipelines:

1. VS and PS containers from the code the description names (words 5 and 9, first 12 bytes ->
   `native-index.txt`, as 0x218 does);
2. blend (CB_BLEND0-7_CONTROL at +0xd0, CB_TARGET_MASK at +0xcc), depth/stencil (DB_DEPTH_CONTROL
   +0xb8, DB_STENCILREFMASK +0xc0/+0xc4) and cull (PA_SU_SC_MODE_CNTL +0xa0) from the 0x184 block;
3. the vertex layout from the 0xbc block;
4. render-target and depth formats from what is bound at the pipeline's first draw.

Needed first: descriptions from the prologue (calls past the first 43), saved with
`VICTORY_SAVE_PIPELINES=<dir>` in a short new-game run up to the crash.

### Device method 0x1c8 built (component-verified, not yet game-verified)

New-game capture (`play-capture.cmd`, authorized): the opening credits drew on black (the title's
0x1c8 pipelines missing), no crash this time, 1,746 0x1c8 descriptions saved. Layout found with
the D3D12 debug layer (`victory console-pipelines`, diagnostics build): word 1 register block, 3
vertex layout, **5 pixel code, 9 vertex code** (the earlier note had them the other way round),
13 mesh code; 101 pipelines have no pixel stage, 97 a mesh stage instead of a vertex one. States
(`tools/decode_1c8.py`): mostly no depth test, no culling, alpha blending variants, stencil masks.

Pipelines are made per render-target and depth formats bound at the draw (the description holds
none). Offline on the RTX 4070 Ti: **1,746 of 1,746** descriptions give a host pipeline, no
debug-layer error (first attempt: 0 of 1,746 - stages swapped; then 2 refused for dual-source
blending on targets above 0, fixed). On in `play-fast.cmd` (`VICTORY_NATIVE_GRAPHICS=1`).
Open: stencil operations are not decoded (KEEP); whether the intro and prologue now render, and
whether the title's own state (vertex buffers, root data) matches, needs a game run.

### First game run with 0x1c8 pipelines (new game, play-fast.cmd)

16,384 0x1c8 pipelines made, 0 missed, no crash (after a fix: the first launch aborted on a
too-short read of the description). The user: the intro renders partly, "full of triangles", the
2D layer late, 3-4 fps where 1-2 before. Frame lines: up to 9.6 fps in steady stretches; 100-690
draws a frame dropped while their host pipelines were made at first draw. Now remembered across
runs (`console-formats.txt`): from the second launch on they are made during loading. The
triangles are not explained yet: next, one frame captured with fxceless's built-in shot
(`VICTORY_SHOT`, diagnostics build) to see which pass draws them.

### Other repositories, 2026-11-25 evening

fxceless/victory-gta6 085ee7c merged (3 commits: windows in a GPU upload heap,
`VICTORY_WINDOW_UPLOAD=1`; frame shot `VICTORY_SHOT`). Its test
`indirect::tests::warp_budget_saturates_without_wraparound_and_preserves_draw_fields` fails on its
own tree too. Marvisak/VIctory +402, DexNom/VIctory +334, Belobug +550 commits since our last
merges: diverged; to be ported piece by piece. Zettrox/ztrx: repository no longer found.

### The intro's "triangles": console rectangle lists (2026-11-25, 23:13-23:25)

Launch 1 (play-fast.cmd, new game, 7 min, no crash, 1,046 pipeline format sets recorded, frames up
to 9.9 fps): the intro's 3D scenes show through regular grids in which every square has one of its
two triangles filled. The title draws those as console rectangle lists (3 corners, the hardware
adds the 4th); stream pipelines naming that topology get a geometry stage that completes them,
the new 0x1c8 pipelines declared triangles, so each rectangle drew its first triangle.
A 0x1c8 pipeline drawn with rectangles now gets a host pipeline with that stage (offline: the
rectangle version of all 1,649 captured vertex pipelines made, stage present, no debug error).
Launch 2 with it: **the GPU was lost 84 s in** (device removed, "invalid command"), as the intro
began, where launch 1 ran on. The stage is behind `VICTORY_NATIVE_RECTS=1`, off; next a diagnostics
launch with the D3D12 debug layer to name the command.

### Session while the user was away (2026-11-25/26 night)

- **Rectangle stage, again**: with the D3D12 debug layer and DRED (diagnostics build) the intro ran 9
  minutes with it, no device loss, no error naming it; then the normal build with it ran to its stop
  too. 2 clean runs against 1 loss: intermittent. **The intro's triangle grids are gone**: ocean,
  beach, pier, rooms and the credits art render. On in `play-fast.cmd` (`VICTORY_NATIVE_RECTS=1`).
- **Frame rate, same new-game stretch** (frame lines with 300+ draws): launch 1 (no rectangle stage,
  nothing made ahead) median 2.1 fps, mean 2.9, 436 draws dropped a frame; with the rectangle
  stage and the format memory (1,483 format sets) median **5.6 fps**, mean 4.4, 371 dropped.
- **Dropped draws** (diagnostics run): almost all are the console ray-tracing structure builder's
  stages (230-998 a frame), held off as before; `victory spilled` shows all 52 builder programs come
  from `XboxBvhBuilder.dll`, none from the game's shader pack.
- **Characters without bodies (hair floating)**: frame shots (`VICTORY_SHOT`, frame 2514, 4,726
  draws, 50 pass pictures): the G-buffer and depth hold the hair, never the head or body. Not
  dropped: the body draws are issued (`MS_VS_PedTransformPreSkinD` + `PS_DeferredPedTexturedNC`, 103;
  its depth pass `..._PositionOnly`, 169; shadow passes), and the skinning programs run
  (`CS_PedStandardSkinning_*`, 154+). The body draws are indirect mesh dispatches whose counts the
  pre-skinned meshlet culling writes (`meshlet_culling:CS_BatchCullPreSkinnedMeshlets`, indirect
  dispatches themselves); it translates exactly. Next: trace the indirect path (the shader trace
  hooks direct dispatches only, so the culling run found nothing).
