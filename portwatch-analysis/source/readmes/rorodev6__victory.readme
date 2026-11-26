# victory — rorodev6's build

A Windows runtime for **an Xbox Series X|S title**, run from game files you own yourself. This branch is maintained by
**[rorodev6](https://github.com/rorodev6)**. Since 2026-11-25 it is based on **shadowdog00's** build, which runs the
title as the smaller console (Xbox Series S) and is about three times faster than the previous `main`. It is tested on an
**AMD Radeon RX 6700 XT (12 GB)**.

The title's original x86-64 code runs unchanged inside the process; the runtime provides the Xbox/GDK platform beneath it
and translates the console's GPU data and shaders (D3D12.X / GFX10 → D3D12 / DXIL).

> No game data is included or distributed here. You need your own copy of the game.

## What this build is

| Part | Source |
|------|--------|
| Base runtime | [Marvisak/VIctory](https://github.com/Marvisak/VIctory) |
| Fork line | [fxceless/victory-gta6](https://github.com/fxceless/victory-gta6) |
| Series S mode, upscaler stand-in, pooled GPU memory, faster card-copy hashing | [shadowdog00/vi-pc-combo](https://github.com/shadowdog00/vi-pc-combo), branch `victory/main` (`692519e`) |
| Shader fixes carried over | [uiliannn/VItoriaBr](https://github.com/uiliannn/VItoriaBr) (see below) |
| FPS counter, shader fixes ported, AMD preset, `play.ps1`, `AGENTS.md` | **rorodev6** (this branch) |

The previous `main` (VItoriaBr + fxceless + low textures, ~3 fps) is kept on the branch `full-build-2026-11-25`.

### rorodev6's changes on top of shadowdog's build

- **FPS counter** in the top-left corner of the game window (`crates/victory-gpu/src/fps_overlay.rs`). It is a separate
  transparent window, so it costs no frame time. `VICTORY_FPS_OVERLAY=0` turns it off.
- **Shader translator fixes ported from VItoriaBr**, for programs the game uses that did not translate before:
  - `v_cvt_f32_f64` (water volumetrics compute shaders), VItoriaBr `3052431`;
  - `v_permlane16_b32` / `v_permlanex16_b32` (water transmittance), from VItoriaBr `31714de`;
  - buffer-view addresses chosen by a computed heap index (`SLOT_VIEWS`), VItoriaBr `b62bbc0`.
- `play.ps1` with shadowdog's preset, Series S by default.

## Status (2026-11-25, RX 6700 XT 12 GB, Ryzen, 32 GB RAM)

| Stage | State |
|-------|-------|
| Boot, menus, intro video | ✅ Works |
| Opening cutscene, prologue | 🟡 **7-9 fps** (113-141 ms a frame), up from ~3 fps |
| Characters | ✅ Bodies, faces and hair drawn |
| Textures | 🟡 Some walls, posters and wire mesh differ from launch to launch |
| Ray tracing | ⚪ Off (its structure builder is not emulated) |

Where a frame goes on the RX 6700 XT: about 70-80 ms preparing it (copying the title's memory to the card), 60-75 ms
copying results back (partly overlapping), and only 22-40 ms of GPU work. The single submitting thread is the limit,
not the GPU.

## Easiest way: ask an AI assistant

Open this folder in an AI coding assistant (Claude Code, Cursor, Copilot, …) and say *"set this up and launch the
game"*, or *"look at my err.txt"* after a crash. `AGENTS.md` tells it how to build, run and read the logs.

## Launching and logs

```powershell
cargo build --locked --profile diag -p victory --features diagnostics
powershell -NoProfile -ExecutionPolicy Bypass -File .\play.ps1 -Game "D:\Games\GTA VI\game_scarlett_master.exe"
```

The path is remembered after the first run. `-SeriesX` runs as the larger console (about half the frame rate). Each run
writes `logs\<date_time>\err.txt` (the runtime's log), `out.txt` and `run.txt`.

**First launch after a build or an update:** `play.ps1` first translates the game's shaders into the cache
(`victory.exe warm`, several minutes, shown in the console), then starts the game. Without it the loading screen stays
black while every shader is translated and compiled in game. Pipelines that need the game's draw state are still
compiled the first time they are drawn, so the very first load stays slower than later ones. `-NoWarm` skips the step,
`-Warm` redoes it.

## Windows 10

Windows 10's own Direct3D 12 stops at Shader Model 6.5, so every translated pipeline is refused and nothing draws.
Microsoft's D3D12 Agility SDK runtime fixes that (Windows 10 20H2 or later, a current GPU driver). One extra command
before building:

```powershell
cargo xtask agility                                                  # downloads it, checks its SHA-512
cargo build --locked --profile diag -p victory --features diagnostics   # build after it, not before
```

`cargo xtask agility` fetches the pinned NuGet package `Microsoft.Direct3D.D3D12` 1.620.2 from nuget.org, checks the
SHA-512 nuget.org publishes, and puts `D3D12Core.dll` and `d3d12SDKLayers.dll` in `target\<profile>\D3D12\`. The next
build of `victory.exe` then asks D3D12 to load them. Without that folder the exe asks for nothing, so Windows 11 needs
no step. The DLLs never enter the repository.

From [fxceless/victory-fork#402](https://github.com/fxceless/victory-fork/pull/402) by domints. Checked on Windows 11
(the game runs with the Agility runtime beside it, 2026-11-25); please report how it goes on Windows 10.

## NVIDIA cards with 8 GB

This build is measured on cards with 12 GB or more (RX 6700 XT, and RTX 5060 Ti / 4070 Ti in shadowdog00's tests). On
an 8 GB NVIDIA card the textures do not fit: use
[soldsawn/victory-nvidia-8gb](https://github.com/soldsawn/victory-nvidia-8gb), tuned and measured on an RTX 4060 Laptop
8 GB (`VICTORY_TEXTURE_DROP_MIPS=2`, `VICTORY_RESOLUTION=1920x1080`).

## License

GPL-3.0, like the projects it is built from. The original project's README is in `README.upstream.md`.
