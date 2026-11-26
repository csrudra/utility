# ScarlettMac

[![macOS: Apple Silicon](https://img.shields.io/badge/macOS-Apple%20Silicon-0091FF)](#tested-on-mac)
[![Tested on M3 Max](https://img.shields.io/badge/Tested-M3%20Max-5832A8)](#tested-on-mac)
[![Graphics: D3DMetal](https://img.shields.io/badge/Graphics-D3DMetal-04a519)](#how-it-works)
[![XCL: World loading](https://img.shields.io/badge/XCL-World%20loading-FFD700)](#gta-vi-status)
[![ScarlettMac 3D opening](https://img.shields.io/badge/ScarlettMac-3D%20opening-04a519)](#captured-on-mac)

ScarlettMac is an experimental Xbox Series X|S compatibility layer for Apple Silicon Macs, built on XCL and CrossOver. [XCL](https://github.com/xcl-dev/xcl)

[Build and run XCL](#build-and-run) · [Runtime preview](runtime-preview/BUILD.md) · [Compatibility results](docs/compatibility.md)

## Contribute

> [!IMPORTANT]
> Help test ScarlettMac on more Apple Silicon Macs. You can run the synthetic Xbox test title, report a compatibility result, or improve the setup instructions. [Contributor guide](CONTRIBUTING.md) · [Open a report](https://github.com/paveledits/ScarlettMac/issues/new/choose)

## GTA VI status

> [!WARNING]
> **In development.** GTA VI gameplay is currently unavailable.

**GTA VI reaches world loading through XCL on the M3 Max. Tests with a separate experimental runtime rendered the live 3D opening and verified pause and resume input.**

The 3D opening ran below 1 FPS and showed severe rendering artifacts. Player movement and camera control remain unverified. These development tests used a local runtime configuration with additional patches. [Development test results](docs/compatibility.md#recent-development-tests)

### Captured on Mac

**XCL** reached first-run setup and world loading on an M3 Max.

| Navigation settings | World loading |
| --- | --- |
| [<img src="assets/captures/navigation-menu.png" width="360" alt="GTA VI Navigation Experience menu with Minimap set to Dynamic">](assets/captures/navigation-menu.png) | [<img src="assets/captures/xcl-loading-artwork.png" width="360" alt="Illustrated GTA VI loading screen captured through XCL">](assets/captures/xcl-loading-artwork.png) |

| Subtitle settings | Finish Setup |
| --- | --- |
| [<img src="assets/captures/subtitles-menu.png" width="360" alt="GTA VI Subtitles menu with Medium selected">](assets/captures/subtitles-menu.png) | [<img src="assets/captures/setup-menu.png" width="360" alt="GTA VI Finish Setup menu with Settings, Continue, and Back controls">](assets/captures/setup-menu.png) |

The experimental **ScarlettMac** runtime captured the title card and the rendered opening scene.

| Opening title card | Rendered 3D opening |
| --- | --- |
| [<img src="assets/captures/opening-title-card.png" width="360" alt="GTA VI title card reading Vice City, Two Years Ago">](assets/captures/opening-title-card.png) | [<img src="assets/captures/opening-cinematic.png" width="360" alt="A car and driver silhouetted against the sky in the rendered opening cinematic">](assets/captures/opening-cinematic.png) |

Later native-window tests captured the pause menu during the opening and a partially rendered skyline. The skyline still shows severe lighting and geometry artifacts.

| Pause menu during the opening | Skyline after shader fixes |
| --- | --- |
| [<img src="assets/captures/development-pause-menu.png" width="360" alt="The GTA VI pause menu open over the opening cinematic">](assets/captures/development-pause-menu.png) | [<img src="assets/captures/development-skyline.png" width="360" alt="Partially rendered skyline with broken lighting and geometry">](assets/captures/development-skyline.png) |

[Replay details](docs/compatibility.md#scarlettmac-opening-cinematic) · [Development test results](docs/compatibility.md#recent-development-tests)

### XCL launch milestones

<picture>
  <source media="(max-width: 480px) and (prefers-color-scheme: dark)" srcset="assets/gta-launch-milestones-mobile-dark.svg">
  <source media="(max-width: 480px) and (prefers-color-scheme: light)" srcset="assets/gta-launch-milestones-mobile-light.svg">
  <source media="(prefers-color-scheme: dark)" srcset="assets/gta-launch-milestones-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/gta-launch-milestones-light.svg">
  <img alt="GTA VI launch milestones on M3 Max. Offline boot, intro graphics, and menus with controller input at about 30 FPS are verified. Loading artwork and asset reads were observed. The next milestone is a visible 3D scene. In-world controls and the first mission are open." src="assets/gta-launch-milestones-dark.svg">
</picture>

[Compatibility measurements and reproduction steps](docs/compatibility.md)

## How it works

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/compatibility-flow-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/compatibility-flow-light.svg">
  <img alt="An Xbox Series game runs through ScarlettMac and XCL. Rosetta 2 runs the x64 code, and D3DMetal runs the graphics on the Mac GPU." src="assets/compatibility-flow-dark.svg">
</picture>

XCL supplies Xbox system services. Rosetta 2 runs the game’s x64 code, and D3DMetal runs the translated graphics on the Mac GPU.

## Tested on Mac

Apple M3 Max with CrossOver Preview 27.0.0.41073 and D3DMetal 4.0b3.

| Test | Result |
| --- | --- |
| GTA VI on XCL | Menus and world loading reached |
| Xbox system checks | 43, 44, and 43 of 50 passed |
| TuxBox Lanes | Scripted replay passed with input and rendered-board checks |

[Measurements, known issues, and reproduction steps](docs/compatibility.md)

## Build and run

Use an Apple Silicon Mac with CrossOver Preview and create a dedicated Windows 11 64-bit bottle named `ScarlettLab` with D3DMetal enabled. Keep the executable and accompanying unpacked game files together in their original directory structure. [CrossOver](https://www.codeweavers.com/crossover)

Install Rust through rustup, extract LLVM-MinGW 20261117 for macOS, and extract the x64 DLLs from a DirectX Shader Compiler release. The reported build used Rust 1.92.0. [Rust](https://rustup.rs/) · [LLVM-MinGW](https://github.com/mstorsjo/llvm-mingw/releases/tag/20261117) · [DXC](https://github.com/microsoft/DirectXShaderCompiler/releases)

```sh
rustup target add --toolchain stable x86_64-pc-windows-gnullvm
export SCARLETT_LLVM_MINGW=/path/to/llvm-mingw
export SCARLETT_DXC_DIR=/path/to/dxc/bin/x64
scripts/build.sh
scripts/run.sh --inspect /path/to/unpacked/game.exe
scripts/run.sh /path/to/unpacked/game.exe
```

Set `SCARLETT_BOTTLE_DIR` to use a dedicated bottle in another location. Set `SCARLETT_OPUS_DLL` to an x64 `libopus-0.dll` to enable the Opus decoder. The launcher stores local data in the bottle under `C:\scarlett-lab-data` and runs with outbound IP traffic disabled.

The repository distributes project source, patches, and launcher scripts. Supply your own unpacked game files. [Source provenance](SOURCE-NOTICES.md)

## Runtime preview

Build the independent VIctory-macOS runtime for CrossOver on Apple Silicon. The preview includes a configurable cap for recycled CPU snapshot buffers and an opt-in pixel shader interpolation fix. [Build and verify the runtime](runtime-preview/BUILD.md)

## Credits and license

This project builds on XCL by ivall and the macOS work by utkarshxdev. [ivall/xcl](https://github.com/ivall/xcl), [utkarshxdev/xcl-mac](https://github.com/utkarshxdev/xcl-mac)

The XCL-derived patches are distributed under GPL-2.0-only. See [LICENSE](LICENSE).
