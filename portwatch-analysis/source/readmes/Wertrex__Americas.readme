# Americas

Grand Theft Auto VI (Xbox Series) on Windows, built on your own PC from your own copy of the game.

**Status: early, not playable.** The title starts and reaches its first-run screens. It does not reach the open world.
Measured numbers and known failures are in [PORT-STATUS.md](PORT-STATUS.md).

> [!IMPORTANT]
> This repository contains **no game data, keys, executables or shaders**, and it does not explain how to obtain them.
> You need your own copy of the Xbox Series package, version 1.0.2.1, as plain files on disk. Everything the build
> generates comes from your copy and stays on your PC. Never share those files.

## What this is

A runtime that loads the game's own x86-64 executable on Windows, reimplements the console's system layer, and runs
its graphics through a D3D12 layer on Vulkan. The console's RDNA2 shader programs are translated to SPIR-V. It is a
personal branch with a short list of changes on top of the open-source project it was forked from.

## Changes in this branch

- Upstream pull request #1878 (batch page-copy sources resolved through their CPU aliases), taken unchanged.
- The whole-heap rescan of the console descriptor heap runs in budgeted slices. Setting `LEONIDA_CONSOLE_RESCAN_US`
  to 0 restores the old behaviour. It cut that phase from 150 to 1,250 ms per submission to about 6 ms during the
  story load.

## Requirements

- Windows 10 or 11 x64, a Vulkan 1.3 GPU, and about 30 GB free for the shader stage and the runtime. A full asset
  export needs about 400 GB and is not needed to run.
- Your own Xbox Series 1.0.2.1 package.
- Python 3.12+, .NET 8 SDK, CMake, Ninja, the Vulkan SDK, Visual Studio 2022 C++ tools with Windows SDK 10.0.26100
  or newer, and an `llvm-mc` with the AMDGPU target (`scripts\build_llvm_mc.ps1` builds one).

## Build and run

From an x64 Developer PowerShell, in the checkout:

```powershell
git submodule update --init
$game = 'C:\path\to\your\package'
$scratch = 'D:\americas-build'
cmake -S runtime -B "$scratch\build" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLEONIDA_REQUIRE_VULKAN=ON -DLEONIDA_SDL3_FETCH=ON
cmake --build "$scratch\build" --target gta6rt
python -I make_game.py --game $game --work "$scratch\work" --out "$scratch\port" --runtime-build "$scratch\build" --stages check,shaders,runtime
$env:LEONIDA_D3D12 = 'vulkan'
$env:LEONIDA_TITLE_WINDOWS_MB = '512'
& "$scratch\port\gta6rt.exe" --first-run-ui "$game\game_scarlett_master.exe"
```

The game runs offline. More detail is in [docs/first_run_ui.md](docs/first_run_ui.md) and [docs/boot.md](docs/boot.md).

## Known problems

- World start fails with `VK_ERROR_DEVICE_LOST` between 130 and 190 s, or with a null read in the title's code.
- Story load runs at 4 to 15 frames/s; the shadow-buffer copy and the texture refresh are the next costs.

## Credits and licence

Licensed under the GNU GPL v3, see [LICENSE](LICENSE). This is a derivative work: the original authors and
contributors are credited in [docs/UPSTREAM_README.md](docs/UPSTREAM_README.md), in the source headers and in the
fork link at the top of this page. The contributions listed in that file keep their own attribution.
