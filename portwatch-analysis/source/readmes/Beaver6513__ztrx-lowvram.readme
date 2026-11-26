# ztrx-lowvram

A fork of [**ztrx**](https://github.com/Zettrox/ztrx), which runs the Xbox
Series build of the game natively on Windows PCs with NVIDIA graphics cards,
from game files you supply yourself. This fork makes it run on **older and
smaller cards on Windows 10**: it was brought up on a **GeForce GTX 1650
(4 GB)**, which upstream ztrx cannot start on.

**This repository contains no game files or assets.** You need your own copy
of the game. Not affiliated with or endorsed by its developer or publisher.

## What this fork changes

| Change | Why | Where |
|---|---|---|
| **DirectX 12 Agility SDK at run time** | Windows 10's own D3D12 stops at shader model 6.5, even on cards that do 6.6 (GTX 16 series). ztrx needs 6.6 and mesh shaders, so it refused to start. Now an Agility SDK folder you point it at is loaded through `ID3D12SDKConfiguration1`, and every device, debug interface and `d3d12.dll` export goes through it. | `crates/victory-shader/src/agility.rs` |
| **Memory limits for small cards** | On a card with less than 6 GB, texture copies are kept to about a sixth of the card's memory budget (instead of a fixed 2 GB), and copies of the title's buffers stay in the PC's memory. A GTX 1650 had been at **6.0 GB used against a 3.3 GB budget**, Windows moving memory to and from the card every frame. | `crates/victory-gpu/src/{host,resource,shadow}.rs` |
| **`-Fast` launcher switch** | Turns on upstream's `VICTORY_RELAY=2`, which overlaps the CPU's copy-back with the card's work. | `scripts/play.ps1` |
| **Movie skipping** (`-SkipMovies`) | Ends the title's start-up logo movies on their first frame, and logs every movie the title opens (size, length). | `crates/victory-hle/src/modules/bink.rs` |
| **Cut-scene skip helper** (`-SkipCutscene`) | The title skips a cut-scene while **A is held** until its prompt's ring fills. At a few frames a second that takes far longer than on a console, and a release resets it. **F8** starts holding A for you; F8 again lets go. | `crates/victory-hle/src/modules/autopress.rs` |

### Measured results

GTX 1650 (4 GB), Intel i7-10700, 32 GB RAM, Windows 10 22H2, Agility SDK 1.620.
Median frame time over 3.5-minute runs in the same 3D scene, 20 or so
5-second samples each:

| Setup | Median ms/frame | Middle half of samples | Card memory in use / budget |
|---|---|---|---|
| Upstream defaults (with the Agility SDK) | 1388 | 1151–1547 | 6.0 GB / 3.3 GB |
| `-Fast` | 642 | 535–824 | – |
| **`-Fast` + this fork's memory limits** | **548** | **529–576** | **4.1 GB / 3.3 GB** |

What the frame time was made of before (from ztrx's own counters and a
timing run): about two thirds waiting for the card, of which about a quarter
were copies of a few kilobytes stalled for up to 579 ms while Windows moved
memory back onto the card; the rest the CPU preparing submissions and
comparing shader-written buffers, with the card idle meanwhile.

Known limits:

- The card is still about 0.8 GB over its budget; most of what is left is the
  title's own render targets (about 2.4 GB at its Series X resolution).
- With textures capped, some textures wait for room before they are uploaded
  and may appear late.
- `--console series-s` (which would lower resolution and texture sizes) does
  not work yet: the title waits forever on an internal "ready" signal from one
  of its own threads before loading the world.

## Status of upstream ztrx (2026-11-25)

Tested by upstream on Windows 11 with an **NVIDIA GeForce RTX 3050** (8 GB):

| | |
|---|---|
| Boot, first-boot screens, intro, opening credits | works |
| Prologue | playable from the cell to the boat chase: cell, cafeteria, robbery, police chase (wanted level, minimap), boat, binoculars |
| Stability | 1 h 30 min+ in one session without a crash |
| Frame rate | 1-3 fps in the world (the first run is slower while shaders translate; they are cached after that) |
| Known problems | anything in shadow is black and bright scenes overexpose (the game's ray-traced lighting does not run yet); some blocky artifacts; boats sit low in the water |

## Requirements

- Windows 10/11 x64, a CPU with AVX2
- A Direct3D 12 GPU with shader model 6.6 and mesh shaders (NVIDIA RTX 20 or
  GTX 16 series or newer)
- On **Windows 10**: the [DirectX 12 Agility SDK](https://www.nuget.org/packages/Microsoft.Direct3D.D3D12)
  (Windows 10 22H2 with KB5029331 or later). Unpack the `.nupkg` (it is a zip)
  and pass the folder with `-D3D12 <folder>` to `scripts\play.ps1`, or set
  `VICTORY_D3D12_DIR`; a `D3D12\` folder next to `victory.exe` or
  `%LOCALAPPDATA%\victory\D3D12\` is found without either.
- Rust (the version in `rust-toolchain.toml`)
- Several GB of free Windows commit memory (raise the paging file if `crashes.log` reports error 1455)

## Build

```powershell
cargo build --release -p victory
```

## Play

```powershell
powershell -ExecutionPolicy Bypass -File scripts\play.ps1 -Game "<your game folder>\<the game's exe>" -D3D12 "<Agility SDK folder>" -Fast -SkipMovies -SkipCutscene
```

| Launcher option | Effect |
|---|---|
| `-D3D12 <folder>` | load the D3D12 Agility SDK from that folder (needed on Windows 10) |
| `-Fast` | overlap the CPU's copy-back with the card's work (`VICTORY_RELAY=2`) |
| `-SkipMovies` | end movies that do not loop on their first frame (`all` via `VICTORY_SKIP_MOVIES=all` skips looping ones too) |
| `-SkipCutscene` | F8 holds A (the title's cut-scene skip) until F8 is pressed again |
| `-AutoPress "A,X"` | F8 holds these buttons in turn instead |
| `-Cache`, `-Data` | where the shader cache and saves are kept |

The log goes to `%TEMP%\ztrx.log`. Controller: XInput pads (a
DualShock/DualSense through DS4Windows works). With no pad connected the
keyboard acts as one while the game window has focus.

## Settings

| Variable | Effect |
|---|---|
| `VICTORY_D3D12_DIR` | the Agility SDK folder (`-D3D12`) |
| `VICTORY_TEXTURE_BUDGET_MB` | cap on texture copies, in MB (default: a sixth of the card's budget, at most 2 GB) |
| `VICTORY_CARD_BUFFERS=0` / `=1` | copies of the title's buffers in the card's memory off / on (default: on for cards with 6 GB or more) |
| `VICTORY_RELAY=2` | relay submissions (`-Fast`) |
| `VICTORY_SKIP_MOVIES` | `1`: movies that do not loop; `all`; or `;`-separated parts of movie names |
| `VICTORY_AUTO_PRESS` | buttons F8 holds (`1` = A) |
| `VICTORY_AUTO_PRESS_MS` | `<hold>,<release>` in ms (default `60000,1000`; release `0` never lets go) |
| `VICTORY_AUTO_PRESS_KEY` | toggle key, `F1` to `F12` (default `F8`) |
| `VICTORY_AUTO_PRESS_START=1` | auto-press on from the start |

## Debugging switches

| Switch | Effect |
|---|---|
| `VICTORY_CAPTURE=<dir>` + `VICTORY_CAPTURE_FRAMES=<list>` | save those frames as PNG (diagnostics build) |
| `VICTORY_KEYS=30:Enter,35:X` | press keys at those seconds (diagnostics build) |
| `VICTORY_D3D12_DRED=1` | on a GPU failure, report the commands in flight |
| `VICTORY_GPU_TIMING=1` + `VICTORY_D3D12_DRED=1` | each command's time on the card, heaviest first (diagnostics build) |
| `VICTORY_PIPELINE_WAIT_MS=24` | shorter per-frame wait for pipelines still being built |

Diagnostics build: `cargo build --profile diag -p victory --features diagnostics`

## License and credits

GPL-3.0-or-later (see `LICENSE`). This fork is based on
[ztrx](https://github.com/Zettrox/ztrx) (Zettrox), itself based on VIctory
(Marvisak) and victory-fork (fxceless). The git history of upstream is kept.
The Agility SDK loading follows the approach of
[XCL](https://github.com/xcl-dev/xcl) (GPL-2.0-only); no XCL code is copied.
