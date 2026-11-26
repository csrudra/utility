# OpenScarlett

#### Xbox Series X|S games running natively on Windows and Linux, from your own copy.

[Status](#project-status) | [Tested games](#tested-games) | [Getting games running](#getting-games-running) |
[How to build](#how-to-build) | [How it works](#how-it-works) | [Want to help?](#want-to-help) |
[Credits](#credits) | [Licence](#licence) | [Discord](https://discord.gg/XygrXFn6us)

[![Discord](https://img.shields.io/badge/Discord-join-5865F2?logo=discord&logoColor=white)](https://discord.gg/XygrXFn6us)
[![Licence: AGPL-3.0-or-later](https://img.shields.io/badge/licence-AGPL--3.0--or--later-blue)](LICENSE)

**OpenScarlett** is an open-source compatibility layer for Xbox Series X|S software. It is not an
emulator: a game's own x86-64 code runs natively on the PC, and the console system libraries the
game expects (`d3d12_xs.dll`, `xgameruntime.dll`, `GameInput.dll`, DirectStorage, …) are replaced
by same-named DLLs built on Win32 and PC Direct3D 12. Games whose shaders ship only as console GPU
machine code get them translated to PC shaders. On Linux the same DLLs run under Wine with
vkd3d-proton. "Scarlett" is the codename of the hardware platform the project targets.

> [!IMPORTANT]
> This repository **does not contain any game, Microsoft software, keys or executables**, and it
> does not explain how to obtain them. Nothing here decrypts or works around any protection. You
> must provide your own copy of a game. Never share game files, SDK files or generated shaders,
> and never attach them to issues or pull requests.

## Project status

| What | Status |
|---|---|
| Launcher (`tools/xsl-run`, Windows and Linux) | ✅ Works |
| Gaming Runtime (task queues, users, saves, local storage, package/system APIs) | ⚠ Core APIs work; online services stay offline |
| Direct3D 12.X → PC Direct3D 12 (devices, queues, resources, pipelines, `PresentX`, console descriptor model, page mapping) | ✅ Works for the tested games |
| Console GPU machine code → HLSL (compute, pixel, vertex, mesh, geometry shaders) | ✅ Works; every shader of Minecraft Preview and The Matrix Awakens translates, about nine in ten of the newer retail game's |
| Ray tracing (acceleration structures, ray queries, `DispatchRays`) | ⚠ In progress: structures build, pipelines translate and light most of the scenes tested; programs are slow to prepare and some results are still wrong |
| GameInput (gamepads incl. DualSense, keyboard, mouse) | ✅ Works |
| DirectStorage (`XCRDAPI.dll`) | ✅ Works (zlib; BCPack through the SDK's own DLL) |
| Audio | ⚠ Games that mix their sound themselves and play it through Windows are heard (a movie's sound track, for one); the console's audio processors are silent stand-ins, so sound decoded by them is missing |
| Older GDK editions (per-edition ABI layouts) | ✅ Works with the edition files collected from your own GDK installs |

## Tested games

| Game | Version / GDK edition | Tested on | Status |
|---|---|---|---|
| Minecraft Preview | 1.18.3064.0, GXDK 220300 | Windows 10 (RTX 5090), Linux (Wine) | ✅ **Playable**: worlds are created, saved and played at ~60 FPS; no audio |
| The Matrix Awakens: An Unreal Engine 5 Experience | GXDK 200800 | Windows 10 (RTX 5090) | ⚠ **In progress**: menus, videos and the opening chase run at ~20 FPS; real-time scenes are lit once their ray-tracing programs are prepared, with some objects still black (Lumen hardware ray tracing is incomplete); the first run spends minutes compiling shaders and has lag spikes |
| **A newer retail game** | – | Windows 10 (RTX 5090) | 🚧 **In progress**: runs its first-boot settings and legal screens and its start screen at a steady 30 FPS; its 4K intro movie plays with sound; it then stops while it streams in the scene behind its menus (the menus themselves are not reached yet). The first frame comes after about 3 s and the start screen after about 15 s (a pipeline is built when it is first used; those an earlier run used are built ahead) |
| Microsoft's Xbox GDK samples (25, built as Series X\|S executables) | GDKX April 2026 | Linux (Intel Iris Xe) | ✅ 22 of 25 present frames with their intended image; the other 3 need a mesh-shader GPU |

Per-title details, known issues and what was fixed on the way are in
[docs/compat.md](docs/compat.md). Report results for other games on
[Discord](https://discord.gg/XygrXFn6us) or in an issue (without game files).

## Getting games running

Every game needs the layer built (see [How to build](#how-to-build)) and your own copy of the game
as an unpacked folder (the one that holds the game's `.exe` and `MicrosoftGame.config`).
Then run the launcher on that folder:

```
python tools\xsl-run "D:\path\to\GameFolder"        # Windows
tools/xsl-run /path/to/GameFolder                   # Linux (Wine)
```

On Windows you can also double-click `tools\xsl-run.cmd` (it asks for the folder) or drag the
game folder onto it. The launcher builds a run directory next to the layer; it never changes
System32 or the registry. Logs go to the console, or to a file with `XSL_LOG_FILE=path`.

### Minecraft Preview

https://github.com/user-attachments/assets/c82c22e9-eafd-4a22-b8ca-fed18cf52263

1. **Edition files.** This version was built with the March 2022 GDK (GXDK 220300). Collect that
   edition's two files from your own GDK installs and point the build at them (see
   [docs/sdk-editions.md](docs/sdk-editions.md)):
   ```sh
   tools/sdk/collect_editions.py /path/to/editions "/path/to/Microsoft GDK"
   cmake -S . -B build -DXSL_SDK_EDITIONS_DIR=/path/to/editions && ninja -C build
   ```
2. **Run** `tools/xsl-run` on the game folder.
3. **Controls:** a DualSense or XInput gamepad, or keyboard and mouse (the mouse is captured while
   the window has focus; `XSL_MOUSE_CAPTURE=0` turns that off).
4. **Saves** go to `C:\Users\Public\OpenScarlett\<title>\Drives\C` on Windows (the game's console
   `C:` drive), or under the Wine prefix on Linux.

Known gaps: no audio, no speech synthesis, no game streaming.

### The Matrix Awakens: An Unreal Engine 5 Experience

https://github.com/user-attachments/assets/7e01f974-c23e-4f67-9e05-39103014cb84

1. **Windows 10/11 with a recent NVIDIA GPU** (tested on an RTX 5090). Linux is untested for this
   title.
2. **HEVC Video Extensions** from the Microsoft Store. The opening video is H.265; without a decoder
   the video surface stays black and the game later stops.
3. **Edition files:** built with the August 2020 GDK (GXDK 200800). Collecting that edition gives
   exact tables; without it the layer uses the nearest newer layout (see
   [docs/sdk-editions.md](docs/sdk-editions.md)).
4. **Run** `tools/xsl-run` on the game folder. `-nomovie` after the folder skips the intro movie.
5. **First run is slow.** Every shader is console machine code and is translated, compiled and then
   compiled again by the GPU driver. The results are cached (`%LOCALAPPDATA%\OpenScarlett\shadercache`,
   or `XSL_SHADER_CACHE=dir`), so later runs start much faster. Expect stalls the first time each
   scene appears. `xsl-shaderwarm` ([docs/gpucode.md](docs/gpucode.md)) can fill the cache from a
   folder of shader containers before the first run.

Known issues: Lumen's hardware ray tracing runs on translated programs, each of which the GPU
driver needs 15 s to minutes to prepare the first time. Until a scene's programs are ready its
people and objects are black; `xsl-rtwarm` ([docs/gpucode.md](docs/gpucode.md)) prepares cached
programs outside the game on all cores. With the programs ready, most of the white-room scenes are
lit, but some figures and furniture still render black and the rooftop shot can show wrongly
coloured lighting. Occasional lag spikes and repeated audio while pipelines compile.
`XSL_RT_PIPELINES=0` turns ray-tracing pipelines off.

### Microsoft's Xbox GDK samples

Build them as Series X|S executables from a checkout of Microsoft's public
[Xbox-GDK-Samples](https://github.com/microsoft/Xbox-GDK-Samples) together with the layer:

```sh
cmake -S . -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-clang-cl-xwin.cmake \
      -DCMAKE_BUILD_TYPE=Release -DXSL_SAMPLES_ROOT=/path/to/Xbox-GDK-Samples
ninja -C build
tools/xsl-run build/samples/SimpleTriangle         # Esc (or View) exits
tools/run-samples <outdir> [seconds]               # run every sample
```

SimpleMeshlet, DynamicCubeMap and PointSprites need a GPU with mesh shaders (DirectX 12 Ultimate).

## How to build

The layer is cross-compiled on Linux and runs on Windows 10/11 or on Linux under Wine.

**Prerequisites:**
- clang-cl, lld-link, llvm-lib (LLVM), CMake 3.24 or newer, Ninja, Python 3
- [xwin](https://github.com/Jake-Shadle/xwin) with the Windows SDK in `~/.xwin`
- Wine 11 or newer (Linux runs only)
- Your own licensed **Microsoft GDK with the Xbox extensions (GDKX)**, April 2026 Update 5. It is
  reached through a gitignored `sdk` link and is never committed.

```sh
ln -s "/path/to/Microsoft GDK/260405" sdk          # gitignored; never committed
cmake -S . -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-clang-cl-xwin.cmake \
      -DCMAKE_BUILD_TYPE=Release
ninja -C build
tools/get-dxc.sh                                   # Microsoft's public PC shader compiler (needed for translated shaders)
```

**On Windows:** copy `build/` (the layer DLLs, plus `build/deps/dxc-pc`), `tools/xsl-run` and
`tools/xsl-run.cmd` to the PC, install Python 3, then run games as described above. The layer uses
the system's Direct3D 12; no Wine or vkd3d is involved.

**On Linux:** `tools/build-vkd3d-proton.sh` builds vkd3d-proton with the project's patches;
`XSL_BACKEND=vkd3d-proton-xsl|vkd3d-proton|wine|null` picks the back end.

**Useful switches** (environment variables): `XSL_LOG=info|trace|gfx=trace,…`, `XSL_LOG_FILE=…`,
`XSL_D3D12_DEBUG=1` (debug layer), `XSL_CAPTURE='path\frame.bmp@120[+count]'` (save displayed
frames), `XSL_DISPLAY_SIZE=1920x1080`, `XSL_SAVE_DIR=…`, `XSL_GAMERTAG=…`. Shader translation and
ray-tracing switches are listed in [docs/gpucode.md](docs/gpucode.md); console drives, display size
and memory behaviour in [docs/compat.md](docs/compat.md).

**User patches:** a `patches.txt` next to a game executable is applied at start-up, checked against
the original bytes ([docs/patches.md](docs/patches.md)). The project ships no patches; they are
user data.

## How it works

| Piece | What it does | Where |
|---|---|---|
| Launcher | Builds a run directory, selects the back end and console mode, maps console drives | `tools/xsl-run` |
| Platform | Interposes the game's imports from `d3d12_xs.dll`'s `DllMain`; lifetime notifications; user patches | `src/platform` |
| Memory | `XMemVirtualAlloc` (64 KB pages), physical pages, GPU-visible memory registry | `src/xmem` |
| Gaming Runtime | Loader protocol, API dispatch across GDK editions, task queues, users, saves, storage | `src/runtime` |
| Direct3D 12.X | Console object model on PC Direct3D 12: descriptors, page mapping, `PresentX`, ray tracing | `src/gfx` |
| Shader translator | Console GPU machine code (AMD GFX10) → HLSL → DXIL, with global-memory access and ray-tracing programs | `src/gpucode`, [docs/gpucode.md](docs/gpucode.md) |
| Input | GameInput over XInput and SDL (DualSense), keyboard and mouse | `src/input` |
| DirectStorage | `XCRDAPI.dll` queues, files, zlib, BCPack (SDK DLL at run time) | `src/storage` |
| Audio | APU memory and a silent software audio processor | `src/audio` |

More: [docs/status.md](docs/status.md) (test ladder), [docs/backends.md](docs/backends.md),
[docs/provenance.md](docs/provenance.md) (where every layout and constant comes from).

## Want to help?

Open areas:
- **Ray tracing:** making translated ray-tracing programs fast to prepare and verifying their results
  (`src/gfx/xs_device.cpp`, `src/gpucode/rtso.cpp`).
- **Audio:** an ACP/XMA implementation behind the silent audio processor (`src/audio`).
- **More games:** run them and report what breaks.

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) first. In short: no SDK files or
text copied from them, no keys or decryption, no game files or patches, no title-specific code, and
a provenance note for every layout taken from a binary or header. Security issues:
[SECURITY.md](SECURITY.md). Come talk on [Discord](https://discord.gg/XygrXFn6us).

Piracy is not supported. Issues and discussions about obtaining games will be closed.

## Credits

- [zlib](https://zlib.net/) (zlib licence), vendored in `third_party/zlib`.
- Microsoft's open-source [libHttpClient](https://github.com/microsoft/libHttpClient) (MIT): the
  XTaskQueue/XAsync implementation in `third_party/libHttpClient-task`.
- [vkd3d-proton](https://github.com/HansKristian-Work/vkd3d-proton) and dxil-spirv (patched for
  Xbox shaders on Linux; patches keep their upstream licences).
- [LLVM](https://llvm.org/): the AMDGPU instruction tables (`src/gpucode/*.inc`) are generated from
  its assembler and disassembler.
- [Mesa](https://mesa3d.org/) (MIT): public facts about the GFX10 hardware used by the translator.
- Microsoft's public [DirectX Shader Compiler](https://github.com/microsoft/DirectXShaderCompiler)
  (downloaded at build time).
- Facts gathered by the Leonida project were reviewed for the translator; no code was taken.

## Licence

OpenScarlett is free software under the **GNU Affero General Public License v3.0 or later**
(`AGPL-3.0-or-later`, see [LICENSE](LICENSE)): the layer DLLs, the launcher and the build files.
Tools, tests and generated ABI data are MIT. Every file carries an SPDX tag; full texts are in
`LICENSES/`, and third-party code and patches keep their own licences
([third_party/README.md](third_party/README.md)). It comes with no warranty.

## Disclaimer

OpenScarlett is an independent open-source project. It is not affiliated with, endorsed by or
sponsored by Microsoft Corporation, Mojang, Epic Games or Warner Bros. Xbox and Xbox Series X|S are
trademarks of Microsoft Corporation; Minecraft is a trademark of Mojang Synergies AB; The Matrix is
a trademark of Warner Bros. Entertainment Inc.; Unreal Engine is a trademark of Epic Games, Inc.
"Scarlett" is used only to describe the hardware platform this project targets. Not affiliated
with Focusrite. No game data or Microsoft software is included; you must provide your own copy.
