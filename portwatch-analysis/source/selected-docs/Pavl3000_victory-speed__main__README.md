# Victory - speed

**Frames per second, and nothing else.** This is a fork of
[ztrx](https://github.com/Zettrox/ztrx) (which is [VIctory](https://github.com/Marvisak/VIctory)
plus [fxceless](https://github.com/fxceless/victory-fork)'s frame-rate work)
for running the Xbox Series build of *that* game natively on Windows through a
high-level-emulation layer: the game's x86-64 code runs natively, its console
APIs are replaced, its GFX10 shaders are translated to DXIL, and D3D12 is the
back end.

The goal of this branch is the highest frame rate that can be reached.
Correctness bugs are out of scope **unless they cost frames** - there are
several known ones and they are left alone on purpose. Every change that
touches behaviour has an environment switch, so it can be turned off without a
rebuild.

**This repository contains no game files or assets.** You need your own copy of
the game. Not affiliated with or endorsed by its developer or publisher.

## Status: measured, not guessed

Machine: Ryzen 9 9950X3D, GeForce RTX 3080 Ti (12 GB), 32 GB RAM, Windows 11.

| | before this branch | after |
|---|---|---|
| Opening cutscene (about 1 300 draws a frame) | 5.1 fps, 196 ms | **8-10 fps, 101-129 ms** |
| The same, on the card | 99 ms | **29 ms** |
| A heavier spot (4 900 draws a frame) | - | 5.7 fps, 176 ms, of which 110 ms is the card |
| Textures picked by index, a frame | 250 MB, pass 246-420 ms | 29.5 MB, pass 32 ms |
| Writes back into title memory, a frame | 250 236 kernel calls | **167** |
| Our clamps of indirect arguments, a frame | 501 | **46** |
| The relay's wait for fetched pieces | 73-272 ms a frame | **0.0** |

The number that decides everything else: the card's own time. In the cutscene it
went from 99 ms to 29 ms; in a heavy spot it is 110 ms, and 110 ms of card is a
ceiling of 9 fps whatever the CPU does.

## What the frame was spent on (measured, in this order)

1. **A per-command profile** (`VICTORY_GPU_TIMING=1` + `VICTORY_D3D12_DRED=1`)
   says a plain draw costs **1.36 us** on this card - native-level - while each
   element of the title's **indirect stream cost 19.8 us**, 2 691 of them a
   frame: 54% of the GPU. One compute pass of the title costs 10.9-16.9 ms and
   is real work that no batching touches.
2. **The copy-back wrote four bytes a call**: 250 236 kernel writes of 1.0 MB a
   frame, on the one thread whose lateness the submitting thread waits for.
3. **Textures picked by index were re-uploaded** for the same spans over and
   over (54% of the uploads, 62% of the bytes), and the pass that does it was
   allowed 288 MB and 750 ms of a frame by its own budget.
4. **The objects a host list keeps alive were kept without a set**, so one list
   held thousands of `AddRef`s of the same heap and the same staging buffer, and
   released them all when it was reset - 17.3 ms of a frame in resets alone.
5. **Our own clamps of the title's indirect arguments**: one compute dispatch
   each, 501 a frame, clamping 8 500 records where the title asked for 1 234.

## What this branch changed

| commit | what | against |
|---|---|---|
| `abddf43` | a stretch the kernel will not take is opened (`VirtualProtect`) and copied | per-page kernel drilling, 8.6 us a page |
| `e6ab460` | the heap-texture walk skips 663 884 slots when nothing was placed and nothing waits | 54.5 ms a frame |
| `13356c2` | page-marked guest writes: shaders report `writes_guest_memory`, the copy-back compares only the marked pages | 124 ms of comparison |
| `5962ed4` | the frame line counts the texture uploads paid for twice (`reuploaded=`) and divides them by cause | "broken invalidation" against "the title really streams this much" |
| `2373257` | the pass over textures is bounded to 100 ms a frame | 246-420 ms |
| `f95fc6c` | what the card wrote goes back by an opened copy first; the counters stopped reading as milliseconds when they were counts | a 90.4 ms kernel write of 37.9 MB |
| `07b614c` | the records of an indirect window are drawn as **one** `ExecuteIndirect` when the run ends (`VICTORY_INDIRECT_MERGE=1`, off by default) | 8.4-10 us a command |
| `0b07e0d` | a run still waiting to be drawn is flushed before a clamp overwrites its scratch buffer | a crash |
| `590f135` | "lists reset" is split into its parts | 129.8 ms read as one number |
| `9051ace` | the runs written back are joined over 16-byte gaps | 250 236 writes a frame -> 167 |
| `cbc25f6` | our clamps are counted; the window's first size is a switch | 501 clamps a frame |
| `ee0338a` | an object a list keeps is kept once | 17.3 ms of resets |

## Hypotheses measured and refuted (so nobody repeats them)

- **Page faults**: 49 745 -> 4 167 a frame changed the copy-back by 6%.
- **State changes** (0.25 rebinds, 0.5 barriers a command): not the cost.
- **Pixels**: 0.56 Mpx a draw, a normal deferred renderer; VRS helped nothing.
- **The relay at the present**: the end-of-frame wait measures 0.0 ms a frame;
  page versions to let the frame run ahead would buy nothing. What costs is
  `WHY_STALE` - the next frame reads memory the previous frame's shaders wrote,
  and that is the console's shared memory this layer has to pay for.
- **Opening memory ranges instead of the kernel's write**: 13 ms a MB against
  0.6 for `NtWriteVirtualMemory`; the kernel's write is the fast way into this
  title's memory.
- **Writing the frame's changed bytes once**: they already are - 23 GB over
  1 024 frames is 22.8 MB a frame, exactly what the frame line says.
- **The shader emitter**: of 2 596 542 descriptor loads, 1 269 812 are already
  `scalar` (one a wave, not a pixel), 174 561 are constants that fold, and the
  rest are per-lane where the `umin` clamp is what keeps the index inside the
  heap. Very little is left there - the command stream is where the time is,
  not the shader bodies.

## Build

```powershell
cargo build --release -p victory                                              # normal play
cargo build --release -p victory --features diagnostics --target-dir <dir>    # the per-command profile
```

## Play

```powershell
powershell -ExecutionPolicy Bypass -File scripts\play.ps1 -Game "<your game folder>\<the game's exe>"
```

## Switches this branch adds or relies on

| switch | effect |
|---|---|
| `VICTORY_INDIRECT_WINDOW=1` | a run of the title's indirect records is clamped once into a scratch buffer (19.8 -> 8.4-10 us a command) |
| `VICTORY_INDIRECT_WINDOW_RECORDS=64` | how many records one clamp covers: 501 clamps a frame at 16, 46 at 64 |
| `VICTORY_INDIRECT_MERGE=1` | the records of a run are drawn as one `ExecuteIndirect` (off by default: one run still has to look at the picture) |
| `VICTORY_CARD_FETCH_INFLIGHT=1`, `..._MB=128` | the pieces a flight's compare flags are fetched inside the flight: the relay's 73-272 ms of waits go to 0 |
| `VICTORY_OPEN_COPIES=0/1/2` | how what the card wrote goes back: kernel only, kernel first, or opened copy first (`1` is the fast one here) |
| `VICTORY_BACK_GAP=16` | how far apart the written runs may be joined into one kernel call (`=0` keeps every run apart) |
| `VICTORY_MERGE_RUNS=512` | how many changed runs a submission may send up before it settles the flights instead |
| `VICTORY_TEXTURE_CATCHUP=0`, `VICTORY_TEXTURE_STAGE_MS=100`, `VICTORY_TEXTURE_STAGE_MB=96` | the budget of the pass that uploads textures picked by index |
| `VICTORY_TEXTURE_SPANS=0` | turn off the `reuploaded=` census |
| `VICTORY_HEAP_TEXTURE_SKIP=0` | walk every heap slot every frame, as before |
| `VICTORY_RELAY=2`, `VICTORY_LATE_WAIT_LISTS=256` | the copy-back on a thread of its own; how many host lists may be in the air |
| `VICTORY_GPU_TIMING=1`, `VICTORY_D3D12_DRED=1`, `VICTORY_SLOW_LIST_MS=200` | the per-command profile (diagnostics build only) |

## How the numbers were made (so they can be repeated)

No GPU profiler was used. Three instruments in the layer gave everything above,
and they are all plain log lines:

| instrument | switch | what it gives |
|---|---|---|
| the frame line, every 5 s | `VICTORY_FRAME_LOG=1` | fps, ms a frame, and its split: `preparing` (copies, textures), `on the GPU`, `copying back`; draws, dropped draws, the texture queue |
| the per-command profile | diagnostics build, `VICTORY_GPU_TIMING=1 VICTORY_D3D12_DRED=1 VICTORY_SLOW_LIST_MS=200` | "the card's time by command (timing run)": each command kind - indirect, dispatch, draw, texture upload, barrier - with its commands a frame and its milliseconds, and the heaviest forty named by pipeline |
| the counters this branch added | none (always on) | `write_calls/write_syscalls/write_mb` and the writes by path; `our clamps ... per frame`; `reuploaded=` with its three causes; `lists reset` split into its parts with what each let go |

The rule that made the difference: **read one number, change one thing, read the
same number again.** Twice in this work a change that "should" have helped was
reverted by exactly that - opening memory ranges instead of the kernel write cost
13 ms a MB against 0.6, and raising the merge cap made a wait *worse*; both were
in the log an hour after they went in.

The full chronology - each run, what the log said, what was concluded, what was
changed, and the conclusions that turned out wrong - is in
**[docs/performance-log.md](docs/performance-log.md)**.

## What is left, measured

```
128.8 ms a frame = preparing 53.0 (copies 27.5 / 117.9 MB, textures 12.2 / 47.6 MB)
                 + the card 29.1
                 + copying back 18.0 / 27.6 MB
                 + ~28 ms of waiting (WHY_STALE: the next frame reads what the
                   previous frame's shaders wrote, and the layer must land those
                   flights first)
```

The copies run at **4.3 GB/s** - memcpy speed - and their 80-120 MB a frame are
the title's own changed memory, so there is nothing to shave there; the two
things that would move the frame now are structural: uploads on a second (copy)
queue overlapped with the render, and the read-after-shader-write round trip
that a console does not pay. The one prepared and unmeasured lever is
`VICTORY_INDIRECT_MERGE=1` (one `ExecuteIndirect` per run of records): it is
written, its ordering bug is fixed, and it has not been in a run since.

## The preset this fork plays with

```bat
set VICTORY_RELAY=2
set VICTORY_LATE_WAIT_LISTS=256
set VICTORY_CARD_FETCH_INFLIGHT=1
set VICTORY_CARD_FETCH_INFLIGHT_MB=128
set VICTORY_INDIRECT_WINDOW=1
set VICTORY_INDIRECT_WINDOW_RECORDS=64
set VICTORY_TEXTURE_CATCHUP=0
set VICTORY_TEXTURE_STAGE_MS=100
set VICTORY_TEXTURE_STAGE_MB=96
set VICTORY_TEXTURE_BUDGET_MB=10240
set VICTORY_CARD_BUFFERS_MB=2048
set VICTORY_OPEN_COPIES=1
set VICTORY_BACK_GAP=16
set VICTORY_MERGE_RUNS=512
```

## Credits and references

- **[VIctory](https://github.com/Marvisak/VIctory)** by Marvisak and its
  contributors: the loader, the runtime services, the D3D12 back end and the
  shader recompiler - the base of everything here. GPL-3.0-or-later, as is this
  fork.
- **[ztrx](https://github.com/Zettrox/ztrx)** by Zettrox: the fork this one is
  made from.
- **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)**: the
  submit thread, the copy queue for fetches, the indirect windows, the card
  fetches inside their flights - all merged here and measured again.
- **[DexNom/VIctory](https://github.com/DexNom/VIctory)**: the page-marked guest
  writes (`bc3cd4b`, `921d8d3`) the copy-back now compares with.
- **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**
  and **[uiliannn/VItoriaBr](https://github.com/uiliannn/VItoriaBr)**: the AMD
  path, and the "recommended preset" this fork starts from (`RELAY=2`,
  `JOIN_COPIES=1`, `WIDE_MERGE=1`, `WIDE_REFRESH=1`, `TEXTURE_NO_WAIT=1`,
  `CARD_BUFFERS_MB=2048`, `TEXTURE_BUDGET_MB=10240`).
- **myokex/victory-amd** (the guard over every view of a page) and
  **ivall/xcl** (a reference for how the same title behaves under another layer),
  as the upstream README says.

## License

GPL-3.0-or-later (see `LICENSE`). Based on VIctory (Marvisak), ztrx (Zettrox)
and victory-fork (fxceless).


