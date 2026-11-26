# VIctory in the world on an RTX 4070 Ti: frame cost and GPU hangs

Status: **measured** (game data owned by the user, opened read-only). The game folder's file list, sizes and
modification times were identical before and after the runs.

Setup:
- Hardware: RTX 4070 Ti, driver 32.0.16.2124, Windows 11 Pro 10.0.26300.
- Software: VIctory `ffe310e`, `--profile diag --features diagnostics`, in an isolated clone
  (`E:\GTA\HybridGt-work\victory`).
- Paths: cache and data folders in `E:\GTA\HybridGt-work`.
- No input: the title advances to the world by itself, reaching it at frame 1,200–1,700.

What the user sees: audio, subtitles and the first mission's title card. The scene after it is dark, with no
models, at about 1 fps.

## Frame cost (median of the per-second lines in world frames; `tools/victory_logstats.py`)

| | run1 (cold cache) | run2 | run3 | run4 (+ write-watch reuse) |
|---|---|---|---|---|
| fps | 1.2 | 0.7 | 0.8 | 0.9 |
| ms/frame | 837 | 1500 | 1266 | 1140 |
| CPU preparing | 405 | 1091 | 671 | 634 |
| of it, copies of title memory | 275 | 837 | 540 | 452 |
| write-watch time | 56 | 287 | 294 | 142 |
| page faults per frame | 69k | 214k | 259k | 65k |
| GPU | 172 | 287 | 338 | 231 |
| copy-back | 46 | 162 | 152 | 135 |
| submissions per frame | 28 | 31 | 33 | 36 |
| draws per frame | 860 | 1391 | 1932 | 2481 |
| draws dropped per second (no host pipeline) | 2043 | 1735 | 962 | 1567 |

Menus run at 30.0 fps in every run.

The bytes actually moved are only 13–52 ms per frame. The copy cost is in dirty tracking:
- each world frame makes ~1,300 `GetWriteWatch` askings over 7–10 GB of address space, and more than 96 % of
  it turns out unchanged;
- 600–850 copies per frame fall back to page-by-page reads of unmapped memory, 120–180 MB per frame.

Patch `patches/victory/0001-…` answers repeated askings within one submission from the journal. Write-watch
time fell from 294 to 142 ms (run3 → run4), even though run4 drew more per frame. Runs vary with the scene,
so this is one comparison each way, not a controlled benchmark.

## Shaders that do not translate (run4)

There are 437 unique shaders in total. By stage: compute 367, pixel 37, mesh 28, vertex 5.

Top reasons, as VIctory gives them:

| Reason | Shaders |
|---|---|
| a select on an untracked mask | 91 |
| a lane mask holding lanes elsewhere read as data | 79 |
| a descriptor read only as data | 61 |
| a structured buffer of unknown stride | 46 |
| an address in an SGPR that is no root parameter | 35 |
| a scalar memory read as data | 35 |

Draws and dispatches of these shaders are dropped.

## GPU hangs: device removed in runs 3, 4 and 5

Each hang came 0–300 frames after the world appeared. DRED shows the stopped command list inside a run of
direct `DispatchMesh` commands (op 42), each with a different translated mesh pipeline:

| Run | Mesh pipeline | Pixel pipeline |
|---|---|---|
| run3 | `4adfa13bea1c556a` | none |
| run4 | `f0c7efd2aceb2aaa` | `7d85c9cab3c80721` |
| run5 | `51ff151f75cd5759` | `7fe75645c406cac6` |

No page fault was reported, so this looks like a timeout, not a bad address. Translated loops may run 2^20
iterations per lane (`victory-shader/src/emit/lower.rs` `LOOP_LIMIT`). Run6 tests `VICTORY_SHADER_LOOP_LIMIT=4096`.

These are the world's geometry passes, the same path as the missing models.

## Reproduce

```powershell
$env:VICTORY_GAME_DIR = '<your dump>'; $env:VICTORY_CACHE_DIR = '<outside any repo>'; $env:VICTORY_DATA_DIR = '<outside any repo>'
$env:VICTORY_D3D12_DRED = '1'; $env:VICTORY_LOG = 'info'
target\diag\victory.exe run '<your dump>\game_scarlett_master.exe' --execute *> run.log
python -I tools\victory_logstats.py run.log
```

**Warning:** on this GPU, entering the world resets the display driver within seconds to minutes.
