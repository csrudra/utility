# leowenya

[![Built with DeepSeek Harness](https://img.shields.io/badge/built%20with-DeepSeek%20Harness-6366F1?logo=deepseek)](https://github.com/deepseek-ai)
![Agent](https://img.shields.io/badge/maintained%20by-DeepFeiyu%20%F0%9F%90%8B-0EA5E9)
![Model](https://img.shields.io/badge/model-hy4flash-8B5CF6)
![Mode](https://img.shields.io/badge/dsh-unrestricted-22C55E)

`leowenya` is an experimental compatibility layer that runs the Xbox Series
build of a certain game natively on Windows with NVIDIA graphics cards, from
game files you supply yourself. It is a tuned tree of
[ztrx](https://github.com/Zettrox/ztrx) and
[VIctory](https://github.com/Marvisak/VIctory)/victory-fork, with a launcher
and a set of switches A/B-tested on one machine: an RTX 5070 Laptop 8 GB
(Blackwell).

This repository holds no game files, code or assets. Running it needs your own
copy of the game. It is not affiliated with, or endorsed by, the game's
developer or publisher.

## Where it stands on our machine (2026-11-26)

The upstream tree was first validated on an RTX 3050 8 GB; every tune and
A/B comparison in this fork was done on an RTX 5070 Laptop 8 GB.

| Stage | What we see |
|---|---|
| Boot, first-run screens, intro, credits | work |
| Prologue | walkable from the cell through the boat chase: cell, cafeteria, robbery, police chase (wanted level, minimap), boat, binoculars |
| Stability | over 1.5 hours in one session without a crash |
| Frame rate | menus 30 fps; 1-3 fps in the world (the first run is slower while shaders translate, then they are cached) |
| Picture | the ambient floor lifts rooms out of pitch black, but lighting is approximate and bright scenes still overexpose (ray tracing does not run yet); some blocky artifacts; boats sit low in the water |

Put plainly: **the picture has caught up, the frame rate has not.** Our work
runs on two tracks at once — getting the image right, and getting frames.

## Recent work

### Reflections are held to the ambient light (belobug `c3bd561`)

The last write of the title's reflections in a frame (`CS_UpdateHistory`)
is now held to a part of the surrounding ambient light, so a mirror surface
with no rays (still water) gets the sky's light instead of going black.
The `ambient::hold` pass and its `REFLECTED`/`REFLECTIONS` hooks came in with
the sky-following port but were not wired; this connects them: a
`ends_reflections` flag on shaders (`pipeline.rs`) and a branch in
`State::ambient` (`draw.rs`) that holds the reflection UAV. Part of the light
around, default 0.5 (`VICTORY_AMBIENT_REFLECT`, `0` off). Full suite and
release build pass. A live run confirmed the picture: the 3D world (a prison
yard at sunset) renders with correct sky-following light, rim-lit hair,
glass reflections, readable shadows and no blowout. The `CS_UpdateHistory`
reflection program did not fire in the scenes captured, so the reflection
branch itself was not observed live (it is exercised in unit builds).

### Dynamic descriptor slots: find a free run across the search's start (victory-fork `4d0c634`)

The search for `n` free dynamic slots went from its starting place to the end
and then from the start up to that place, so a free run lying *across* the
starting place was seen as two halves and never whole. A table was refused
with room for it, and the "too long" shortcut then refused every table that
size until the next release — the same symptom as the missing-pipeline draws
in the world. The second part now continues past the starting place by `n-1`
slots. New regression test `a_free_run_across_the_place_the_search_starts_from_is_found`
holds the old search; full suite and release build pass. Upstream c1c32819.

### Batch the heap pass's buffer refreshes, share a read lock (ccs03 `cd6e283`)

The view-heap buffer pass was the largest CPU bucket in the world
(357-1231 ms a frame): it refreshes some 4,600 host-copy spans, and each
`defer_refresh` took the list's lock on its own. Now the spans are collected
and inserted under one lock (`Shadow::refresh_many` /
`HostList::defer_refreshes`). The `BUFFERS` table, asked by every recording
thread for every descriptor, is an `RwLock` with a read fast path: an ask for
a buffer that already has its copy takes only the read lock, and the write
lock is used just to register, release or make a copy first use. Ported from
ccs03. The shadow test suite (28 tests) and the full suite pass; release
build clean. Its effect on the heap-pass bucket still needs an A/B.

### Slow pipelines stop hogging the compile workers (from avatarmanz `a30829c`)

On a fresh pipeline cache, a few title pipelines take tens of seconds each to
make. All workers were once busy inside those, while the world's first
minutes dropped thousands of draws a frame for want of pipelines. Now the
time each pipeline took is recorded beside the early-pipeline list
(`slow-pipelines.txt`), and a pipeline known to take over a second is queued
separately: at most a quarter of the workers make such slow, unrequested
pipelines, leaving the rest free for the ones a draw actually waits for.
`VICTORY_PIPELINE_SLOW=0` restores creation order. Ported into
`pipeline/library.rs` (record/read slow times) and `pipeline/make.rs`
(separate queue, `slow_limit`, worker accounting). New test
`pipelines_known_to_take_long_leave_workers_for_the_others` passes; full
suite and release build clean. Its effect on our cold-cache frames is not
yet A/B'd.

### The title's idle threads no longer wait for free processors (from avatarmanz `0d065d3`)

Six of the title's threads run at "idle", the streaming pager among them. On
a PC those threads contend with other programs and our own workers, and a
thread at "idle" ran about once in four seconds, stalling what waited for it
(loading was seen 1.1 s late on average, 4.8 s worst). Our HLE `kernel32`
now implements `SetThreadPriority` and lifts the title's two lowest priority
classes ("idle" and "lowest") to "below normal"; higher priorities pass
through unchanged. `VICTORY_TITLE_PRIORITIES=0` leaves them as the title set
them. Ported from avatarmanz, the current fastest public fork (13-22 fps on
an RX 7900 XTX by merging several VIctory forks). New HLE test
`no_title_thread_waits_for_idle_processors` passes; full suite and release
build clean. Its effect on our frame rate is not yet A/B'd.

### Card-copy compare hashes a piece with 64 threads (ported from victory-fork `5557224`)

The compare of card-resident copies gave each 64 KiB piece one thread that
walked it 16 bytes at a time — 4,096 sequential loads — so a pass cost the
time of one piece however few pieces it had, and there are 300-450 hash
passes and ~100 compare passes a frame. Now thread `t` hashes the steps
`t, t + 64, ...` and lane 0 folds the 64 lane hashes in lane order. On by
default (`VICTORY_CARD_HASH_WIDE=0` restores the old form); stored and
compared hashes use the same form within a process. victory-fork measured
its own card passes falling from 22-29 ms to 5-9 ms a frame on an RTX 3060.
Ported into `host.rs` (`CARD_COMPARE_WIDE`, `card_hash_wide`,
`card_compare_source`, `card_compare_groups` and three call sites). New WARP
test `warp_card_compare_finds_every_byte_with_skew` checks every one-byte
change at skewed offsets in both forms; full suite and release build pass.

### Where the world frame actually goes (measured, not yet fixed)

With a correctly built diag binary and no scripted keys, the 3D world is
reached and its steady frames were measured from the log's fps/ms line:
**0.2-0.7 fps (1.5-4.5 s/frame)** — far worse than the earlier cutscene-only
estimate of 2-4 fps. The frame is now **GPU bound**: `on the GPU` is
1009-2787 ms with the card ~79% busy, while `preparing` is ~120-520 ms and
`copying back` ~30-705 ms. Between 400 and 4,800 draws a frame are dropped
for want of a host pipeline. This means the window/gather work (which cuts
the per-record clamp) helps only at full draw counts, and `INPLACE` (which
cuts a host-side read) is not the bottleneck here. The next target is the
GPU time itself; a per-pipeline GPU timing pass is the next diagnostic.

A later A/B with `VICTORY_TEXTURE_NO_WAIT=1` and in-flight fetch off raised
the world's steady frames to **1.0-3.7 fps (0.27-1.0 s/frame)** — about
3-5x — and cut `textures` from 28-206 ms to 27-73 ms and `copying back` from
317-393 ms to 12-177 ms. `on the GPU` fell to 1-169 ms, exposing `heap
buffers` (the view-heap buffer pass, including texture uploads) at 357-1231 ms
as the new largest bucket. `VICTORY_TEXTURE_NO_WAIT=1` is now on by default
(`-NoTextureNoWait` for comparison); in-flight fetch stays as before. A
per-pipeline GPU timing run showed our own pass timings (~10 ms/frame) do not
name the title's draws, so the `heap buffers` bucket still needs another
instrument. The leading public fork (avatarmanz, 16 fps) is on AMD RDNA3
with native wave64; our NVIDIA 32-lane card emulates the refused programs,
which is a structural gap no switch closes.

### Indirect light now follows the sky (ported from belobug `4f62c2a`)

The fixed ambient level was the cause of the overexposed picture: the same
0.6 at noon and at night. It now follows the sky. The title draws a small
128x128 R16G16B16A16_FLOAT sky-paraboloid image (`ps_sky_paraboloid_reflection`)
twice a frame; we keep that host copy (`ambient::sky_drawn`, called from the
draw path when a bound shader draws the sky) and the ambient pass reads its
mean. The level is `gain * mean^power + least`, with a bluish least so night
does not go fully black — belobug's measured hand-set levels were 0.07 at
night, 0.3 at dusk and 1.4 at noon against sky means of 0.001 to 0.65. On by
default; `VICTORY_AMBIENT_SKY=off` restores the constant, and
`gain,least,power` tunes it (also live from the ambient file). Ported from
belobug's `705a2d0`/`e48eb83`/`c3bd561`/`4f62c2a`: `ambient.rs` plus a
`draws_sky` flag in `pipeline.rs`, the `sky_drawn` call in `draw.rs`, and
`HostList::transition_copy` in `host.rs`. `ambient_pass_builds` and the full
suite pass; release build clean. Verified in a live run on this machine: the
log shows `the sky image the ambient light would follow` and `ambient light
follows the sky`, and a 3D-world frame of the prologue now has proper dark
interiors and correctly lit skin/clothes instead of the washed-out picture
the fixed 0.6 gave.

### Scattered indirect records gathered once per list (ported from victory-fork `465b94f`)

`VICTORY_INDIRECT_GATHER=1` (with windows on) gives a draw whose record misses
its window a slot in the list's scratch buffer, which the list's prelude fills
with all such records in one clamp pass — instead of a compute pass of ours in
front of each such draw. A dispatch, a direct draw, or shaders that may write
arguments close gathering for that list. The title keeps its mesh records
scattered up to 33,056 bytes apart in one ~100 MB argument buffer, so a
window's fixed step cannot serve them; victory-fork measured 10.3 fps in the
first rooms on an RTX 3090 Ti. Ported into `indirect.rs` (`GatherSet`,
`gather`, `record_gathers`), `host.rs` (the list's `gather` state, `gather_slot`,
`gather_close`, prelude and reset/close paths) and `draw.rs` (the switch and
the gather-on-window-miss path). `run.ps1 -Window -Gather` enables it.

New tests: `gathered_records_must_fit_the_clamp`, and a WARP test proving
gathered records come out exactly as if clamped one by one (both pass). A live
A/B on this machine (diag build, warm cache, cutscene scene, ~1,000-4,000
draws a frame) showed **no measurable difference**: frames 256 to 1024 took
about 18.2 s both with and without gather (~28 fps by frame-number
advance). The scene's draw count is far below the 9,000 of victory-fork's
measurement, so the clamp is not the bottleneck here; gather stays off by
default and may matter once the world renders at full draw counts.

### Series S profile: the upscaler and interface plane (ported from ccs03)

A large port of ccs03's Series S work, so `--console series-s` can in
principle render at 1280x720 internally (about 30% cheaper per frame than
Series X) and fill the display with the title's own upscaler:

- **Title-code patches** (`victory-game`, `victory-loader`, `run.rs`; ccs03 `82270e9`): a known build's code can be patched before mapping, with every expected byte run checked first and a patched copy given its own cache name. One build is registered — `Xbox Series master` (the hash our exe has) — with two patches that make the upscaler choice return 6 (the title's own upscaler) instead of FSR 4, whose output never reached the screen. `VICTORY_TITLE_PATCHES=0` disables them; `VICTORY_TITLE_PATCH=<rva>:<old>:<new>` adds more. Verified: both patches apply on our exe and the build is now identified.
- **`over.rs`** (new, ccs03 `de1634d`/`fa7e312`/`184ce09`/`c831d8d`): a present's second plane — the title's interface at 3840x2160 in Series S mode — is drawn over the game image as one alpha-blended triangle, so menus and loading screens are not black. `host::present` takes the second plane and `queue::present` finds it (0x48-byte plane descriptions). `over.rs` also holds the FidelityFX upscale stretch.
- **`ffx.rs`** (new HLE module, ccs03 `f41553f`): the title's `ffxDispatch` import is bound to ours, which turns an upscale dispatch into a plain stretch of the colour input via `list::upscale_stretch`; other dispatches pass to the title's own DLL. `run.rs` wires the binding.

All new unit tests pass: 5 in `over` (stretch stays inside its target, format mapping, overlay pixels) and 2 in `ffx` (description layout, unanswered dispatch errors). **Not yet a working picture:** on our machine a `--console series-s` run still shows black frames and never reaches the world in a short run; the upscale dispatch was not observed to fire. The port compiles, is test-covered and does not affect the default `series-x` path; getting a lit Series S world needs more debugging.

### Guarded views: walk only the dirty gaps (ported from ccs03 `538749f`)

`victory-gpu/src/watch.rs` now keeps the set of clean 64 KiB guard blocks as
disjoint half-open runs (`CleanBlocks`) instead of one entry per block. A
refresh used to collect and scan about 150,000 clean entries a frame just to
find the few dirty ones; a fully clean range is now one lookup, and a mixed
range visits only the gaps between clean runs. From ccs03 `538749f` (itself
victory-fork PR 824). Verified here: the new
`clean_runs_match_per_block_tracking` compares the runs against per-block
tracking exhaustively over every insert, remove and query, and all 16
guard/mapping tests pass.

### Driver watch (ported unchanged from victory-fork)

`crates/victory-gpu/src/drvwatch.rs` subscribes to display-driver errors in
the system event log (from victory-fork `a253706`). In victory-fork's runs,
every device loss with draw windows on was announced by such an entry 2.7 to
6.3 seconds ahead; now each is logged as it happens and counted, and the
**first one turns draw windows off for the rest of the run**, so a driver
fault costs a slower frame rather than the card. On by default;
`VICTORY_DRIVER_WATCH=0` opts out. `draw.rs`'s `windows()` checks
`!drvwatch::tripped()`. Verified on this machine: the EventLog subscription
is accepted and the trip/count unit test passes.

### Pixel quad reads reach helper lanes at triangle edges

In a pixel program, a quad-local read of another lane now goes through DXIL
quad operations, including the helper lanes left by a triangle edge or a
discard. Host wave reads return 0 from helpers, so a hand-made derivative
took the smallest mip and drew lines along every triangle edge on car paint,
glass and skin. Ported from upstream `4015a18` and Belobug `03629f3`:
`helpers_read_for` in `lower.rs`, applied at both quad-local lane-read sites.
The companion `v_readfirstlane` fix (`0601955` / `f520772`) is in too — a
helper lane reads its own value, so a waterfall loop no longer spins to its
limit with a wrong descriptor. New test `pixel_quad_reads_reach_helpers`.
This is a picture fix, not a frame-rate one.

### Indirect-draw windows, made safe

The clamp shader drops garbage draw records asking for 2^23 vertices or
instances an instance or more; no mesh of this title is that large. CCS03
traced the device losses of `VICTORY_INDIRECT_WINDOW` to exactly such
records: a window charges a clamped record once however often it is drawn,
so a list of 90 records of 2^24 vertices all ran (1.5 billion vertices in one
list). The `MOST_DRAW` guard empties them in every path. `run.ps1 -Window`
exposes the switch and forces in-flight fetch off (the two together also
lost the device). Still off by default; see the test notes below.

### Texture mip-skip for small cards (commit `ae865f5`)

On cards under 10 GB, host copies of large 2D textures leave out the two
finest mips (on by default, `VICTORY_TEXTURE_MIP_SKIP=2`): each level dropped
quarters that texture's card memory, so on 8 GB more textures stay resident
instead of showing black albedo. The staging reader follows a kept prefix and
views shift their level indices; copies in and out of such textures are
refused. From Comet `e82716d`. A/B on our 8 GB card: texture prep fell from
90-1700 ms to 6-20 ms. `-NoMipSkip` disables it; the trade is a little fine
detail for residency.

### Indirect light and the tuned launcher

Ray-traced indirect light does not run, so the title's probe resolve writes
garbage or nothing. `victory-gpu/src/ambient.rs` (commit `a2ee402`, ported
from Belobug via CCS03 PR24) follows that pass with a small compute shader
that writes a fixed value (level `0.6`, tint `1.0/0.98/0.94`), which the
title's own lighting then applies to surfaces. `VICTORY_AMBIENT=<level>` sets
it (`0` for none); `off` keeps the title's output. It lifts rooms out of
black, but the light is uniform from every direction and follows neither
exposure nor geometry; it goes away once ray tracing runs. `run.ps1` loads
these settings plus the switches A/B-tested on our card (commit `bfd1e92`).

## How the picture caught up

The first room now renders correctly on our machine — walls, textures,
people, lamps — at 190-450 ms a frame (2-5 fps): the image work caught up,
the frame rate did not. What got it there, on top of the list below:

- Descriptor records the title copies into its heap as plain bytes are mirrored before every submission (Flyander PR #305, after upstream `86a5ed6`). About 40,000 such records a frame that no call had announced; their host slots were empty or stale.
- A buffer view that does not start on an element of its host copy gets its own bytes instead of being refused (after `86a5ed6`): 3-6 a frame.
- Room is kept on the card for the render targets and buffer copies a world makes in its first frame: 98 buffer copies (945 MB) where earlier runs made one, and the processor no longer compares 550-710 MB a frame looking for shader writes (25 MB now).
- Levels on demand ran on the card for the first time (`VICTORY_LEVELS_ON_DEMAND=1`, still off by default; with AscilCH PR #747's fixes): 3.1 GB not allocated for levels the title does not hold, no device loss.
- Guarded blocks under storage writes are open by default; 14 more shader programs translate; a program uses first-half interpolation pairs only if it was refused for one (on for every program, 8,551 working pixel programs changed).
- First processor-side frame cuts: the descriptor sync uses a cheap fingerprint and leaves draw-table slots to their draws (the heap pass fell from 70-220 ms a frame to about 3), and memory the guards already hold is not asked of the write watch (Jonirulah PR #670).

## Bottlenecks and what we tried

- A frame is still 250-380 ms; the card is the limit, mostly the per-record clamp before each of some 6,700 indirect draws a frame.
- `VICTORY_INDIRECT_WINDOW=1` (PR #220) cut the card's time here from about 100-150 to 35-80 ms a frame, but lost the device twice (once with a card page fault after 160 s). With the `MOST_DRAW` guard and driver watch now in, `run.ps1 -Window` is an A/B switch, still off by default.
- `VICTORY_CARD_FETCH_INFLIGHT=1` (Jonirulah PR #648, on by default): the copy-back thread's wait fell from 181 ms a frame to 0, but the card got busier, so no gain is claimed; `run.ps1 -NoFetchInflight` turns it off. It must not run together with windows.
- `VICTORY_LATE_WAIT` / `VICTORY_RELAY`: submissions go ahead of the wait for the card, results land as the card finishes; in a first five-minute run the card's idle time behind the submitting thread fell from about 136 to 30 ms a frame.
- `VICTORY_INPLACE` (first stage only): opening title memory as a graphics heap so buffers are used in place; a probe confirmed the approach on our GPU.
- Translated shaders get clean-up passes over the finished module (dead code, constant folding, reuse of values, branch facts); the pack's host instruction count falls by about 43%, worth about 20 ms of GPU time a frame here (`VICTORY_SHADER_OPT=0`).
- Tried, not kept: PR #220's windows together with in-flight fetch lost the device; an indirect compute pass asks for about 77,500 thread groups in x where one dispatch runs 65,535 (the rest is cut off).

## Memory sync and card memory

- **A write through one view of a physical page is seen by the copies taken through its other views** (`VICTORY_VIEW_GUARD=0` turns it off). The title shows one page at several addresses and a copy was guarded at one of them only. Measured here: 0.8-1.0 million such writes in five minutes, each of which used to leave a copy stale. Since it went in, the first room had its walls in the later frames of four runs out of four (two of five before); its very first shot still comes up without walls in some runs.
- Kernel reads into title memory are read beside and copied in, so a block guarded again in between no longer fails the read.
- Storage-layer writes into physical pages are counted where the title maps those pages (10,000-50,000 guarded blocks of copies lay under them in every run) and can open the guards there: `VICTORY_PAGE_WRITES=guards` (off by default; `1`, `slots`, `all` do more).
- Failed page-destination reads are retried (`VICTORY_DSTORAGE_RETRIES=0` restores the old behaviour).
- The test card is full from the world's first frame (85-99% of its budget for a whole run; about 26,000 texture copies let go and 3,400 remade in five minutes; 2.8 GB of render targets all in use).
- Levels on demand (`VICTORY_LEVELS_ON_DEMAND=1`, off by default): a texture takes card memory only for the levels the title holds (2.2-3.0 GB of copies were levels it does not hold). Run on the software adapter so far, not yet on a real card.
- Refused texture slots are held back a few seconds so a pass reaches the slots behind them (`VICTORY_FULL_CARD_PASS=0`); room can be kept for card copies of title buffers (`VICTORY_CARD_ROOM_FOR_BUFFERS=1`, off).

## Tools and diagnostics

- `victory translate <shader file> --warm all --jobs N` translates every shader ahead of a run, on the CPU only (about 4.5-6.5 minutes here); the cache is keyed on translator source, so a build that does not touch the translator starts warm.
- `run.ps1 -Profile diag` enables frame capture and scripted keys; `-Window` is the window A/B (and turns in-flight fetch off); `-Window -Gather` adds gathered records; `-NoAmbient`, `-NoTune`, `-NoMipSkip`, `-NoFetchInflight`, `-Guide` each isolate one comparison.
- Counters, off or diagnostics-only: `VICTORY_MERGE_RACE=1` (title bytes a copy-back was about to overwrite with older values: none in 138,000 copy-backs), `VICTORY_WALLS_TRACE`, `VICTORY_CARD_ACCOUNTING`, and a census of copies the texture sweep never lets go.
- `VICTORY_DRIVER_WATCH=0` disables the driver watch; `VICTORY_AMBIENT_FILE` (diagnostics builds) hot-tunes ambient's level, colour and shading from a file twice a second.

## Verification notes

- Full `cargo test --workspace`: only four **pre-existing** ray-intersection tests fail (ray tracing is still in development, unrelated to these changes); everything else passes. The window guard, quad/helper fix, driver watch and guard-runs change each have dedicated unit tests, all passing.
- `cargo build --release -p victory` is clean; the asset-policy check `policy::tests::repository_passes_policy` passes.
- Live run (2026-11-25, diag build, empty shader cache on first run): with `VICTORY_INDIRECT_WINDOW=1` and in-flight fetch off, the title booted, played its cutscenes and reached the 3D world; 2,000+ frames captured, no device loss, no `crashes.log` entry. The picture is lit and textured (the captures were removed from the repo per the asset policy). The world is still overexposed at the fixed ambient level — a later picture task. A warm-cache frame-rate A/B of windows on/off is still owed.

## Known problems

- Indirect light is a constant, not real bounce light: rooms are no longer pitch black, but shading stays flat and exposure is not followed.
- The interior of the first gameplay room is sometimes not drawn after the cutscene hands over.
- With the in-game phone out the world is unlit (black) and the phone is an empty outline; other forks see this too.
- About 24 GB of memory is in use during play.
- A few style lints are disabled for this fork in the workspace `Cargo.toml` until newer code is tidied.
- Many changes are specific to this title and GPU; some are marked `shortcut:` where they approximate console behaviour.

## Running it

Build once, then use `run.ps1`. It keeps the shader cache and saves under
`%LOCALAPPDATA%\ztrx\cache` and `%LOCALAPPDATA%\ztrx\data` — the folder keeps
its old `ztrx` name so existing saves and caches still load. **Do not delete
the data folder to fix a shader problem.** If the game exe is not at the path
in the script, point `-Game` at your own copy.

```powershell
cargo build --release -p victory
powershell -ExecutionPolicy Bypass -File run.ps1
powershell -ExecutionPolicy Bypass -File run.ps1 -Guide -Profile diag  # scripted first-run wizard
powershell -ExecutionPolicy Bypass -File run.ps1 -Window             # A/B: window clamps
```

The default is `--console series-x`. `--console series-s` selects the smaller
internal render profile; its upscaler/interface-plane support is ported but
not yet producing a lit world here, so treat it as experimental. The known
build's upscaler patches apply automatically (`VICTORY_TITLE_PATCHES=0` turns
them off), and `VICTORY_TITLE_PATCH=<rva>:<old hex>:<new hex>,...` adds custom
ones for other builds.

Requirements: Windows 10/11 x64, an AVX2 CPU, a D3D12 GPU with SM 6.6 and
mesh shaders (NVIDIA RTX 20 series or newer), the Rust version pinned in
`rust-toolchain.toml`, and several GiB of Windows commit at startup (if
`crashes.log` reports error 1455, close other applications or grow the paging
file).

## Sources and licence

The platform underneath comes from [VIctory](https://github.com/Marvisak/VIctory)
(Marvisak and contributors), and this tree absorbs fixes from
[victory-fork](https://github.com/fxceless/victory-fork), ztrx, ccs03,
Belobug and Comet; their commits and authors remain in the history.

Tuning, porting and verification in this fork are carried out by **DeepFeiyu 🐋**,
an agent running on the **hy4flash** model in DeepSeek Harness (dsh,
unrestricted mode). GPL-3.0-or-later (see `LICENSE`).
