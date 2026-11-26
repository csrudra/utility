# RyGT

<h1 align="center">
  <sub>Gran Turismo Sport and Gran Turismo 7 on PC</sub>
</h1>


**Gran Turismo Sport and Gran Turismo 7 running as native Windows programs.**

RyGT ports Gran Turismo Sport (CUSA03220, update 1.69) and Gran Turismo 7 (CUSA24769, update 1.71) from
PlayStation 4 to Windows. The games are not emulated: the converter turns each game's executable
into `GTSport.exe` or `GT7.exe`, the game code runs directly on your CPU, and RyGT's libraries
stand in for the PS4 system. Graphics go through
[shadGT](https://github.com/rygt-team/shadGT/tree/ryty-gpu)'s Vulkan renderer, built as the
games' video output library.

**One runtime, one renderer, one launcher for both games.** The runtime libraries, the renderer and
`RyGTLauncher.exe` are single builds that serve GT Sport and GT7 alike; each tells the games apart
at run time (by the launcher's choice, else by the executable's name). Both games can sit in **one
folder**: everything a game writes is named after its serial (see
[One folder for both games](#one-folder-for-both-games)). ryGT7, the former GT7 port, is merged
into this repository.

RyGT is a fork of [Ryty](https://github.com/aarvsn/Ryty), the general PS4/PS5 porting tool, with
everything GT Sport and GT7 need added on top.

## Status

GT Sport:

| Area | State |
| --- | --- |
| Boot, menus, car and track selection | Working |
| Races | Working, about 42-60 fps depending on how many cars are on screen |
| Race summary and results | Working |
| Audio | Working |
| Controllers | Working through SDL |
| Steering Wheels | Working |
| Online features | In Development |
| VR features | In Development |

Known issues:
- The first 30 seconds of a race can stutter while graphics pipelines compile.
- ~~A few draws in the race summary can occasionally read garbage vertex descriptors; those draws
  are skipped.~~

Tested on Windows 11 with an Intel i7-13700KF and an RTX 4070Ti.

Tested on Windows 11 with an AMD Ryzen 5 9600X and an RTX 3060 12GB

Tested on Windows 10 LTSC with an AMD Ryzen 7 7745HX and an RTX 4070 8GB

GT7 (CUSA24769) is set up and started by the same launcher, with its Offline mode patch
(`patches\CUSA24769.xml`) and its online pages (Account, Online: RyGTServer and shadNet, see
[server](server)).

## Download

Get the latest build from [Releases](https://github.com/rygt-team/RyGTS/releases). One release
serves both games: the runtime libraries, the renderer, the converter, the launcher, GT Sport's
settings, and GT7's files (its stub library `libs\libSceTextToSpeech.prx`, its Offline mode patch
`patches\CUSA24769.xml`, and the online server in `server`). It contains **no game files**: you
need your own decrypted dump of GT Sport CUSA03220 with update 1.69 and/or GT7 CUSA24769 with update 1.71, and the
system modules and fonts from your own PS4 firmware.

Unzip it anywhere and run `RyGTLauncher.exe`. Pick the game at the top left of the launcher, then
on its Game page pick your game, update, firmware module and font folders, press **Set up**, then
**Play**. Do the same for the other game in the same folder. Updates (Settings > About > Updates)
update the folder for both games. The loader's source is in
[loader](loader). Manual setup steps are in [docs/gt-sport/README.md](docs/gt-sport/README.md).

## FAQ

### Why do shaders need compiling? The PS4 never did that!

It did. Polyphony just did it once, for the PS4's one and only GPU. Your PC has a different
graphics card, so RyGT translates each shader and lets your driver compile it for your card. That
happens the first time a shader shows up. After that it's saved, and the next time it's instant. A
driver update clears the driver's cache, so you'll see some of it again after one.

### The Bloodborne and inFAMOUS PC ports precompile everything up front. Why can't GT?

Those games keep their shaders in plain files, so the ports can read them all before you play. GT
keeps them inside Polyphony's encrypted archives. Opening those would mean shipping decryption keys,
and that's the kind of thing that landed Yuzu in court. So we only see a shader once the game loads
it itself. GT7 also has far more shaders, and much bigger ones: even with all the code, compiling
everything would take anywhere from tens of minutes to a few hours, depending on your CPU.

What we do instead: we'd rather let something pop in a little late than freeze your game, and we
keep everything, so your second visit to a track is smooth. We're also looking at ways to get
shaders ready before you need them.

## How it fits together

```
your dumps: GT Sport (CUSA03220, 1.69)        GT7 (CUSA24769, 1.71)
            eboot.bin + sce_module            eboot.bin + sce_module
        |                                     |
        |  RyGTLauncher.exe: unwrap the SELF, convert with ryty.exe --windows --ps4 --app0 app0/<serial>
        v                                     v
GTSport.exe                                   GT7.exe
app0\CUSA03220\sce_module\*.guest.prx        app0\CUSA24769\sce_module\*.guest.prx
        |                                     |
        +------------------+------------------+
                           |  both load at run time
                           v
libs\  one runtime (kernel, libc, save data, audio, input, network, ...)
       + one shadGT renderer (libSceVideoOut.prx: Gnm driver, PM4 processing, Vulkan;
         plus shadGT's audio, NP and other libraries)
       + GT7's stub library (libSceTextToSpeech.prx)
```

The rest of each game is read from your dump where it is (the folders on the Game page).

## One folder for both games

Everything a game writes is named after its serial, so GT Sport and GT7 never touch each other's
files:

| What | GT Sport | GT7 |
| --- | --- | --- |
| Executable | `GTSport.exe` | `GT7.exe` |
| Launcher and runtime settings | `CUSA03220.RyGT.ini` | `CUSA24769.RyGT.ini` |
| Game settings | `user\custom_configs\CUSA03220.json` | `user\custom_configs\CUSA24769.json` |
| Saves | `user\savedata\CUSA03220` | `user\savedata\CUSA24769` |
| Converted modules | `app0\CUSA03220` | `app0\CUSA24769` |
| Shaders and caches | `shaders\CUSA03220*` | `shaders\CUSA24769*` |
| Logs | `logs\CUSA03220` | `logs\CUSA24769` |
| Set up's work, temp0, data | `convert\CUSA03220`, `temp0\CUSA03220`, `data\CUSA03220` | `convert\CUSA24769`, `temp0\CUSA24769`, `data\CUSA24769` |
| Launcher pictures (optional) | `launcher\CUSA03220` | `launcher\CUSA24769` |

Shared on purpose: `libs`, `converter`, the renderer, `dlss`, the controller bindings
(`user\input_config\default.ini`, `ryty-input.ini`, `ryty-wheel.ini`) and `RyGT-Launcher.ini` (the
game picked last). Older folders are moved to these names by the launcher and the runtime, never
overwriting anything; details in [loader/UNIFIED-LAUNCHER.md](loader/UNIFIED-LAUNCHER.md).

## What this repository contains

- **Converter** ([core/relinker](core/relinker)): turns the PS4 executable and its modules into
  Windows binaries. RyGTS adds fixes for GT Sport's executable and modules.
- **Runtime libraries** ([core/libs/prx](core/libs/prx)): the PS4 system libraries both games link
  against, one build for both ([core/libs/GameSerial.hpp](core/libs/GameSerial.hpp) tells them
  apart). The changes for GT Sport include:
  - kernel: an event queue bridge for the renderer, mapping and protection change notices so the
    renderer's memory tracking stays correct, `MAP_FIXED` replacing mappings, direct memory and
    semaphore fixes;
  - libc: C++ exceptions through the SEH runtime, guest allocation fixes, crash reports with
    debugging aids;
  - save data, AppContent, audio output and network control fixes, including holding the first
    save data mount until the boot screen is drawn (GT Sport's boot script otherwise crashes).
- **GT7 stubs** ([runtime/gt7](runtime/gt7)): `libSceTextToSpeech.prx`, the libraries GT7 needs that
  the runtime doesn't have yet.
- **Launcher** ([loader](loader)): `RyGTLauncher.exe`, one launcher for both games. It converts each
  game from your own dump and starts it, with each game's display, graphics, shader and controls
  pages, GT7's Account and Online pages, the Advanced page's renderer switches (saved per game),
  and one updater for the folder. See [loader/UNIFIED-LAUNCHER.md](loader/UNIFIED-LAUNCHER.md).
- **Online server** ([server](server)): RyGTServer and shadNet, which stand in for PSN and the
  games' servers (GT7's online play).
- **DLSS plugin** ([plugins/dlss](plugins/dlss)): optional NVIDIA DLSS upscaling. The package
  ships it as `dlss\ryGT_dlss.dll`; NVIDIA's runtime comes from the launcher's download button.
  It is licensed differently from the rest: see [License](#license).
- **GT Sport guide** ([docs/gt-sport](docs/gt-sport)): setup from your own dump.

The renderer lives in [shadGT, branch `ryty-gpu`](https://github.com/rygt-team/shadGT/tree/ryty-gpu)
(`ryty_gpu/`). It builds shadGT's video output, Gnm driver and Vulkan renderer as
`libSceVideoOut.prx`, plus shadGT's audio, NP and other libraries. It is one renderer for both
games (ryGT7's renderer, shadgt7, is merged into it): it carries GT Sport's and GT7's rendering
fixes and game patches, picked by the running game, and the performance work (Vulkan calls on
their own thread, cheaper buffer and image tracking).

## Building

Most people should use a [release](https://github.com/RyGT-Team/RyGTS/releases). To build it
yourself on Windows you need:

| What | Why | Where |
| --- | --- | --- |
| Git | cloning, with submodules | [git-scm.com](https://git-scm.com/download/win) |
| MSYS2 (UCRT64 shell) with GCC, CMake and Ninja | the runtime libraries (`libs\*.prx`) and the converter | [msys2.org](https://www.msys2.org) |
| Internet access while configuring | CMake downloads FFmpeg's prebuilt libraries once | |
| .NET Framework 4.x (part of Windows 10/11) | the launcher, `RyGTLauncher.exe` | built in |
| Visual Studio's C++ tools with LLVM (clang) | only for GT7's stub library (`runtime/gt7/build.cmd`) | [visualstudio.microsoft.com](https://visualstudio.microsoft.com) |
| Visual Studio 2022 with "C++ Clang tools", the Vulkan SDK | only to rebuild the renderer (`libSceVideoOut.prx`) | [visualstudio.microsoft.com](https://visualstudio.microsoft.com), [vulkan.lunarg.com](https://vulkan.lunarg.com) |

You also need everything a release needs to run: your own decrypted GT Sport dump (CUSA03220,
update 1.69) and/or GT7 dump (CUSA24769, update 1.71), and your PS4 firmware's system modules and fonts.

### 1. Get the code with its submodules

```sh
git clone --recursive -b development https://github.com/mlgprorektm8/RyGT.git
cd RyGT
```

Already cloned without `--recursive`? Run `git submodule update --init --recursive`. Without the
submodules (SDL2, FFmpeg, FreeType, stb, glslang and the others in `3rdparty`), CMake builds only
the converter and **skips every runtime library**, so `GTSport.exe` then fails to load
`libScePad.prx` and the rest. The configure step warns about this.

### 2. Install the compiler (MSYS2)

Open the **MSYS2 UCRT64** shell (not "MSYS2 MSYS") and run:

```sh
pacman -S --needed git mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja
```

### 3. Build the runtime libraries and the converter

In the UCRT64 shell, from the RyGT folder:

```sh
cmake -S . -B build/windows-mingw -G Ninja -DCMAKE_BUILD_TYPE=Release -DRTY_ENABLE_LTO=OFF -DRTY_BUILD_GUI=OFF
cmake --build build/windows-mingw --target libs ryty
```

Check that the configure output has no "3rdparty submodules are missing" warning. The results:

- `build/windows-mingw/core/libs/libs/*.prx`: the runtime libraries. They go in the game folder's
  `libs` folder.
- `build/windows-mingw/core/relinker/ryty.exe`: the converter. It goes in `converter`.

The libraries also need `libgcc_s_seh-1.dll`, `libstdc++-6.dll` and `libwinpthread-1.dll` from
`C:\msys64\ucrt64\bin` next to `GTSport.exe` and `GT7.exe` (a release already has them). The same
libraries serve both games.

Building from PowerShell or cmd instead of the UCRT64 shell? Put `C:\msys64\ucrt64\bin` first on
`PATH`, or the build fails without a clear error.

### 4. Build the launcher

From cmd or PowerShell:

```bat
loader\build.cmd C:\path\to\your\game\folder
```

This writes `RyGTLauncher.exe` with the C# compiler that ships with Windows.

### 5. Put it together

The easiest way is to start from a release: unzip it, then copy your own `libs\*.prx`,
`converter\ryty.exe` and `RyGTLauncher.exe` over the release's files. The release also has the renderer,
the FSR library, the launcher pictures and the tools, which this repository doesn't build. Then
run `RyGTLauncher.exe` and press Set up, as in the release's README.

### Renderer (optional)

The renderer is in [shadGT, branch `ryty-gpu`](https://github.com/mlgprorektm8/shadGT/tree/ryty-gpu).
In a "x64 Native Tools Command Prompt for VS 2022":

```bat
cmake --preset x64-Clang-Release -DSHADGT_RYTY_GPU=ON
cmake --build Build/x64-Clang-Release --target ryty_gpu
```

This makes `libSceVideoOut.prx` and the other `libSce*.prx` files in `Build/x64-Clang-Release`
(`libSceAjm`, `libSceAudio3d`, `libSceNgs2`, `libSceZlib`, `libSceDiscMap`, `libSceScreenShot`,
`libSceNpAuth`). They replace the ones in `libs`, for both games: copy all of them, because the
runtime build makes placeholder libraries of some of the same names that GT7 can't run on.

More details: [docs/user/BUILDING.md](docs/user/BUILDING.md).

## Branches

- `main`: stable builds; releases come from here.
- `development`: ongoing work. Changes reach `main` once they are tested.
- 'shader_fixes': Fixing shader bugs.'

# Discord Server
Join our server for more updates: https://discord.gg/wXs3YQujSt

## Documentation

- [GT Sport setup](docs/gt-sport/README.md)
- [One launcher for both games](loader/UNIFIED-LAUNCHER.md)
- [GT7's stub libraries](runtime/gt7/README.md), [online server](server/README.md)
- [Linux (Steam Proton)](docs/user/LINUX.md)
- Ryty's general documentation: [index](docs/README.md), [building](docs/user/BUILDING.md),
  [usage](docs/user/USAGE.md), [input mapping](docs/user/INPUT_MAPPING.md),
  [porting pipeline](docs/dev/PORTING_PIPELINE.md)

## Credits

- [Ryty](https://github.com/aarvsn/Ryty) by aarvsn, itself a fork of
  [AnyPS5](https://github.com/boykopovar/AnyPS5) by Andrii Semkiv (boykopovar) and its
  contributors: the converter, the system library implementations and the test infrastructure.
- [shadPS4](https://github.com/shadps4-emu/shadPS4) and its contributors, through shadGT: the
  renderer, shader recompiler and HLE libraries.
- [Nenkai](https://github.com/Nenkai): [GTAdhocToolchain](https://github.com/Nenkai/GTAdhocToolchain)
  (the AdHoc script compiler and disassembler, MIT licensed), which adcpatch uses to patch the
  offline livery and decal scripts, and Nenkai's research into Gran Turismo's formats and scripts.
- NVIDIA: the DLSS SDK's NGX loader, inside the DLSS plugin. This software uses NVIDIA DLSS. NVIDIA, the NVIDIA logo and DLSS are trademarks and/or registered trademarks of NVIDIA Corporation in the U.S. and other countries.
- @dessierror For the artwork used in README.md
- See [AUTHORS.md](AUTHORS.md).

## Disclaimer

This project is for interoperability, research and preservation. It does not include or
distribute copyrighted games, firmware, keys or proprietary libraries, with one exception: the DLSS
plugin contains NVIDIA's NGX loader, under NVIDIA's licence (see [License](#license)). Use your own legally
obtained copy of the game and your own console's firmware files, in line with the laws where
you live.

Please do NOT ask shadps4 or Ryty servers for help from this project.

## License

GNU General Public License version 2 only, as Ryty. The renderer (shadGT) is also GPL-2.0.

### The DLSS plugin (`dlss\ryGT_dlss.dll`)

The DLSS plugin is licensed differently from the rest of RyGTS. It has two parts:

| Part | Whose | Licence |
|---|---|---|
| The plugin's source ([plugins/dlss](plugins/dlss)) | RyGT-Team | MIT ([plugins/dlss/LICENSE](plugins/dlss/LICENSE), shipped as `ryGT_dlss-LICENSE.txt`) |
| NVIDIA's NGX loader (`nvsdk_ngx_d.lib`, DLSS SDK v310.9.16), linked into `ryGT_dlss.dll` as object code | NVIDIA | [NVIDIA RTX SDKs License](https://github.com/NVIDIA/DLSS/blob/v310.9.16/LICENSE.txt), shipped as `NVIDIA-RTX-SDKs-LICENSE.txt` |

- **NVIDIA's part is not under the MIT licence or the GPL.** NVIDIA's licence lets it be distributed
  only as object code inside an application (section 1c). You may not reverse engineer it, take it
  out of the plugin, or distribute it on its own (section 3).
- **Why it is a separate plugin:** NVIDIA's licence forbids putting the SDK under an open-source licence
  that would require its source, derivative works or free redistribution (section 3e). So it is
  linked only into the MIT plugin, never into the GPL renderer or runtime. The renderer loads the
  plugin at run time through the small interface in `rygt_dlss_api.h`.
- **NVIDIA's runtime is not shipped:** `nvngx_dlss.dll`, `nvngx_dlssg.dll` and Streamline's `sl.*.dll`
  come from the launcher's download button, under NVIDIA's terms.
- **Attribution** (the licence's supplement): This software uses NVIDIA DLSS. NVIDIA, the NVIDIA logo and DLSS are trademarks and/or registered trademarks of NVIDIA Corporation in the U.S. and other countries. The launcher shows this
  on its About page.

Gran Turismo is a trademark of Sony Interactive Entertainment. This project is independent of Sony
and Polyphony Digital.

<p align="center">
  <img src="assets/GranTurismoSportBanner2.webp" width="800" alt="Gran Turismo Sport banner">
</p>
