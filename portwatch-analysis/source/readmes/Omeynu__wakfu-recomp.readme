# wakfu-recomp

[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-support%20the%20project-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/omeynu)
[![Verified developer on RecompStore](https://recompstore.com/assets/press/verified-dark.svg)](https://recompstore.com/dev/omeynu)

A static recompilation of **Islands of Wakfu** (Xbox Live Arcade, Xbox 360, title `584109AA`) to native PC code.
The game's PowerPC code is translated to C++ with a patched [XenonRecomp](https://github.com/hedge-dev/XenonRecomp);
its Direct3D calls are intercepted and rendered with Vulkan; the Xbox 360 kernel, audio (XMA) and input are
reimplemented in a runtime (SDL3).

**Why this project:** I have been a fan of the Wakfu series since I was young, and I wanted to play Islands of
Wakfu natively on my PC instead of going through an emulator.

**[Download the latest release](https://github.com/Omeynu/wakfu-recomp/releases/latest)** ·
**[Support the project on Ko-fi](https://ko-fi.com/omeynu)**

> [!IMPORTANT]
> This project does not include any game assets. You must provide the files from your own legally acquired copy
> of the game (XBLA package) and its title update 2. The recompiled code is generated on your PC from those files
> and is never distributed.

This project is not affiliated with, endorsed or sponsored by Ankama or Microsoft. *Islands of Wakfu* and *Wakfu*
are trademarks of their respective owners. Donations support development time only: they never buy access to the
game, its files or any build.

**AI disclosure:** most of the code and documentation was written with the help of an AI coding assistant (Claude).
Each step is covered by the tests and checks described in [`docs/`](docs/) (French) and [`BUILDING.md`](BUILDING.md).

## Table of contents

- [System requirements](#system-requirements)
- [How to install](#how-to-install)
- [Features](#features)
- [The project book](#the-project-book)
- [FAQ](#faq)
- [Building](#building)
- [Credits](#credits)

## System requirements

| | |
|---|---|
| OS | Windows 10/11 x64, or Linux x86_64 (missing packages installed automatically on Arch-based distributions) |
| GPU | Vulkan 1.3 (tested on AMD Radeon RX 6700 XT, RX 7900 XT, Vega 8 integrated) |
| Memory | at least 4 GB of free virtual memory (RAM + page file): the emulated console memory is committed at start |
| Disk | ~3 GB free (build tools, prepared game, build) |
| Game | Islands of Wakfu XBLA package + title update 2 (STFS packages, ISO/XISO image or extracted folder) |

## How to install

### With RecompLauncher

Needs an up-to-date RecompLauncher. Add **Islands of Wakfu** in [RecompLauncher](https://recomplauncher.com) and
give it the game package (or its ISO/XISO image or extracted folder) and the title update 2 package. Setting it up
recompiles the game (a few minutes to an hour, depending on the CPU); after that, your copy is no longer needed and
starts are immediate. Display, sound and controller settings are on the game's page and in Big Picture mode, where
the game opens borderless (unless you chose fullscreen) without changing your settings.

### Manually

Pick the file for your system on the [releases page](https://github.com/Omeynu/wakfu-recomp/releases/latest):

| System | File | How to start it |
|---|---|---|
| Windows 10/11 x64 | `WakfuRecomp-<version>-windows-x64.exe` | double-click |
| Linux x86_64 | `WakfuRecomp-<version>-linux-x86_64` | `chmod +x` it, then run it |

1. Drop your game package and title update 2 package on the window (or use *Browse*). Each file is checked by
   content; an unknown version is refused with the reason.
2. Click *Recompile*, wait, then *Play*.

Windows SmartScreen or an antivirus may warn because the executable is not signed.
Settings, saves and logs are in `%APPDATA%\WakfuRecomp` (Windows) or `~/.local/share/wakfu-recomp` (Linux) and survive updates.

## Features

- Plays from boot to in-game: intro videos, menus, new game, first zone; save games and profile settings.
- Native rendering: Direct3D calls are translated to Vulkan (no GPU emulation); internal resolution up to 2160p,
  MSAA 2x/4x/8x, anisotropic filtering, graphics presets, optional AMD FSR 1 upscaling.
- Game language: French, English, German, Spanish, Italian, Japanese (or the system language).
- Local co-op for two players (up to 4 controllers or keyboard); controllers through SDL3 (hot-plug, rumble) and a
  remappable keyboard.
- Windowed, borderless and fullscreen modes; GPU selection; frame rate counter; skippable intro logos.
  All settings in `config.toml` or the launcher window ([`docs/options.md`](docs/options.md), French).
- One-file Windows installer and launcher that ships its own compiler toolchain: nothing else to install.

## The project book

How the game was recompiled, what works, what went wrong and how it was solved, with dated logs of every
measurement (French): **[docs/livre](docs/livre/README.md)**

- [Project status and measured performance](docs/livre/01-etat.md)
- [Problems and solutions](docs/livre/problemes/README.md), one page per problem, open or solved
- [Roadmap](docs/livre/03-feuille-de-route.md)

## FAQ

**Is this legal?** The repository contains only original code, documentation and third-party code under open source
licenses. No game file, extracted asset or code generated from the game is distributed: you need your own copy,
and everything game-specific is produced on your PC. This is the same model as other recompilation projects.

**Why do I need the title update?** The recompiled code targets the game patched with title update 2; the files are
checked by SHA-1 before recompiling.

**Why does the first start take so long?** The game's code is recompiled and compiled on your PC, because the
generated C++ is derived from the game and cannot be distributed.

**Where are the logs?** `%APPDATA%\WakfuRecomp\journal.log` on Windows,
`~/.local/share/wakfu-recomp/userdata/journal.log` on Linux.

## Building

See [`BUILDING.md`](BUILDING.md).

## Credits

- [XenonRecomp](https://github.com/hedge-dev/XenonRecomp) and [XenosRecomp](https://github.com/hedge-dev/XenosRecomp) —
  PowerPC and Xenos shader recompilers.
- [Xenia](https://github.com/xenia-project/xenia) — texture layout code adapted in `runtime/third_party/xenia`.
- [UnleashedRecomp](https://github.com/hedge-dev/UnleashedRecomp) — architecture reference.
- AMD FidelityFX FSR 1, SDL3, FFmpeg (XMA2 decoder only), glslang, DirectXShaderCompiler, Dear ImGui, toml++, zstd,
  llvm-mingw — see [`packaging/windows/LICENCES-TIERS.txt`](packaging/windows/LICENCES-TIERS.txt).

## License

[GPL-3.0](COPYING), except `runtime/third_party/`, which keeps its own licenses (BSD, MIT).
Islands of Wakfu and its assets belong to their respective owners.
