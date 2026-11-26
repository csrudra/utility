# Vader

Runs the Xbox Series build of GTA VI natively on Windows, on NVIDIA
graphics cards, from game files the user supplies.

Vader fuses three lines of work into one tree:

- [ztrx](https://github.com/Zettrox/ztrx) by ZETTROX: the NVIDIA-tuned
  runtime, the most stable public build at the time of writing.
- [victory-fork](https://github.com/fxceless/victory-fork) by hyphennn and
  contributors: the rendering and frame-rate fixes merged here from
  upstream.
- Our own changes: GPU-view mirrors for the Bink video planes, shader
  lowering fixes, and the work tracked in [docs/PLAN.md](docs/PLAN.md).

**This repository contains no game files or assets.** You need your own
copy of the game. Not affiliated with or endorsed by its developer or
publisher.

## Status

Nothing below is a claim of ours unless it says **verified here**. The rest
comes from upstream's own reports on their test machine, not from this
repo's runs.

| Stage | State | Where it was seen |
|---|---|---|
| Boot, first-boot screens, intro, opening credits | works | upstream report (RTX 3050) |
| Intro video | GPU-view mirrors landed; the log shows the pairing (`gpu_view`/`cpu_view`), the picture is not confirmed visually yet | this tree, unverified |
| Prologue | playable from the cell to the boat chase | upstream report (RTX 3050) |
| Stability | 1 h 30 min+ in one session without a crash | upstream report |
| Frame rate | 1-3 fps in the world | upstream report (RTX 3050); see docs/PLAN.md for our targets |
| Known problems | anything in shadow is black; bright scenes overexpose | upstream report |

**Verified here:** the tree builds, clippy passes with zero warnings, and
the workspace tests pass on an RTX 2080 Ti. The GPU-view pairing fires at
runtime (one `gpu_view`/`cpu_view` pair logged). Nothing else has been
confirmed on this machine yet.

Tested on Windows 11 with an NVIDIA GeForce RTX 3050 (8 GB) by upstream.
See [docs/upstream-fork-changelog.md](docs/upstream-fork-changelog.md) for
the measured history of every frame-rate change.

## Requirements

- Windows 10/11 x64, a CPU with AVX2
- A Direct3D 12 GPU with shader model 6.6 and mesh shaders (NVIDIA RTX 20
  series or newer)
- Rust (the version in `rust-toolchain.toml`)
- Several GB of free Windows commit memory. Raise the paging file if
  `crashes.log` reports error 1455.

## Build

```powershell
cargo build --release -p victory
```

## Play

```powershell
powershell -ExecutionPolicy Bypass -File scripts\play.ps1 -Game "<your game folder>\<the game's exe>"
```

`scripts\play.ps1` keeps the shader cache and saves in folders you choose
(`-Cache`, `-Data`). Controller: XInput pads. With no pad connected the
keyboard acts as one while the game window has focus.

## Tuning switches

The main switches, all off by default unless noted:

| Switch | Effect |
|---|---|
| `VICTORY_RELAY=2` | land copy-back results as the card finishes (upstream: card idle behind the submit thread fell from 136 to 30 ms a frame) |
| `VICTORY_LATE_WAIT=3` | submit ahead of the card's fence |
| `VICTORY_WIDE_BACK=1` | wider copy-back of shader-written ranges |
| `VICTORY_INDIRECT_GATHER=1` | one clamp pass per list for scattered indirect records (needs `VICTORY_INDIRECT_WINDOW=1`) |
| `VICTORY_LEVELS_ON_DEMAND=1` | allocate card memory only for held texture levels (saves about 3 GB; off until tested on NVIDIA) |
| `VICTORY_FPS_COUNTER=0` | hide the frame-rate box drawn on the picture |

The full list, with measurements, lives in
[docs/upstream-fork-changelog.md](docs/upstream-fork-changelog.md). Do not
enable `VICTORY_WAVE_WIDE` on NVIDIA: it lost the device in upstream's runs.

## Diagnostics build

```powershell
cargo build --profile diag -p victory --features diagnostics
```

## Docs

- [docs/PLAN.md](docs/PLAN.md) — strategy, baseline protocol, exit criteria
- [docs/architecture.md](docs/architecture.md) — how the layer works
- [docs/upstream-fork-changelog.md](docs/upstream-fork-changelog.md) — the
  full measured history of upstream's frame-rate work

## Credits and license

Based on [VIctory](https://github.com/Marvisak/VIctory) by Marvisak and its
contributors, [victory-fork](https://github.com/fxceless/victory-fork) by
hyphennn and contributors, and [ztrx](https://github.com/Zettrox/ztrx) by
ZETTROX. Licensed GPL-3.0-or-later, as upstream.
