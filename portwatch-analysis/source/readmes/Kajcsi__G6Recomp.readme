# G6Recomp

Runs the Xbox Series X|S release of Grand Theft Auto VI as a native Windows application. The
game's own x86-64 code runs directly on your CPU, on top of a runtime that reimplements the
console's system services, much as Wine and Proton run Windows programs.

> Unofficial fan project. Not affiliated with or endorsed by Rockstar Games, Take-Two
> Interactive, or Microsoft.

**This repository contains no game code, data, or assets.** It holds a loader and a runtime
that reimplements the console's system services, a D3D12.X-to-D3D12 translation layer,
analysis tools, and per-build configuration. All of it is original code or open-source code
under a compatible licence (listed in [NOTICES.md](NOTICES.md)). To use it you need your own
legally purchased copy of the game. Everything derived from your files is generated and compiled on your own
machine and never leaves it. This project doesn't explain how to obtain or decrypt game files,
and requests for them are closed.

## Status

Early development. **Nothing is playable yet.**

| Milestone | State |
|---|---|
| M0: PE readers, `.pdata`-seeded function discovery, import table | In progress: readers, discovery, and jump-table resolution are done and tested against the side DLLs of build 1.0.2.1 |
| M1: the native loader runs the game's code; imports, exceptions, TLS, and heaps work | In progress: the loader, hook engine, import policy, and pre-flight scan are done and tested on original fixtures, and the game's side DLLs initialize under it |
| M2: threads, memory, and I/O stable through boot | Started: the install is mounted read-only and the path functions run on it; the Game Runtime's task queues and async calls are implemented and tested |
| M3: first frame, then the title screen | Not started |
| M4: in-game and controllable | Not started |
| M5: enhancements, settings UI, Linux under Proton verified | Not started |

## How it works

The console executable is already x86-64 code for a Windows-derived OS, so it doesn't need
translating: your CPU runs it as it is. What has to be replaced is everything around it.

* **Loader** (`runtime/loader`). Maps the game's modules into memory, binds every import the
  game makes to the PC API or to our own implementation, and registers the game's own unwind
  data with Windows, so exceptions, thread-local storage, and fibers work as they do on PC.
  Hooks and enhancements are patched into the mapped code at run time. The game sees the
  console's CPU features, so it takes the code paths it took on the console.
* **Runtime** (`runtime/`). Replaces the console OS. Where console and PC APIs match, imports
  are forwarded to the PC API. Where they differ, they get a high-level reimplementation.
  Networking is never forwarded: Game Runtime (GDK) services report one local, offline user,
  and saves go to a per-user data directory.
* **GPU** (`runtime/gpu`). Wraps the game's D3D12.X objects, forwards everything PC D3D12
  supports, and translates console-only features. Console shaders are converted to PC DXIL on
  first run and cached locally.
* **I/O** (`runtime/io`). Mounts your install read-only and reads archives in place.
* **Analysis tools** (`tools/x64recomp`). Inspect executables and find every function and jump
  table, which the loader uses to place hooks safely. The project started as a static
  recompilation in the style of [N64Recomp](https://github.com/N64Recomp/N64Recomp) and
  [UnleashedRecomp](https://github.com/hedge-dev/UnleashedRecomp), hence the name. The
  recompiler still works and is kept as a fallback, but the game doesn't run through it.

The design notes live in [`docs/`](docs/), starting with
[`docs/execution-model.md`](docs/execution-model.md), and in [`CLAUDE.md`](CLAUDE.md).

## Supported builds

Only builds listed in [`game/config/known_builds.toml`](game/config/known_builds.toml) are
supported. A build is identified by its package version and the SHA-256 of its files. The
configure step checks your files against that list and stops with a clear message on a
mismatch. Supported today: package version **1.0.2.1**.

## Requirements

* Windows 10 or 11, x64, with a CPU that supports AVX2. Linux is meant to run the Windows build
  under Proton (not verified yet).
* To build:
  * Visual Studio 2022 with the C++ desktop workload and a Windows SDK (it also provides Ninja)
  * LLVM with `clang-cl` (developed with 22.1)
  * CMake 3.28 or newer
  * Git

## Building

Clone with submodules:

```powershell
git clone --recursive https://github.com/Kajcsi/G6Recomp.git
```

Then build from a Visual Studio Developer PowerShell.

Without game files, you get the tools and the tests that need none. This is what CI runs:

```powershell
cmake --preset windows-debug -DG6_NOGAME=ON
cmake --build --preset windows-debug
ctest --preset windows-debug -L nogame
```

With game files, put the contents of your decrypted package in `private/game`, or pass
`-DG6_GAME_DIR=<path>`. `private/` is gitignored.

```powershell
cmake --preset windows-release
cmake --build --preset windows-release
ctest --preset windows-debug -L "^game$"   # local checks against your files
```

`x64recomp` can be used on its own to inspect any x64 PE:

```powershell
out\windows-debug\x64recomp.exe info      <file>
out\windows-debug\x64recomp.exe imports   <file>
out\windows-debug\x64recomp.exe exports   <file>
out\windows-debug\x64recomp.exe functions <file> [--list] [--tables]
out\windows-debug\x64recomp.exe scan      <file> [--sites] [--no-sweep]
```

`scan` is the pre-flight check for native execution ([`docs/scan.md`](docs/scan.md)). It reports
instructions the host might lack, TEB and TLS use, system instructions, and code that treats
code as data.

## Repository layout

```
common/     logging and PE32+ / x64 unwind readers shared by tools and runtime
tools/      x64recomp (analysis and the frozen recompiler) and shaderrecomp (shader converter)
runtime/    loader, console OS services, imports, Game Runtime, GPU, I/O, audio, input
game/       per-build config, hooks, and enhancements
app/        launcher and settings
tests/      unit tests, loader tests on original fixture DLLs, recompiler differential tests
docs/       design notes and findings, written as prose
scripts/    clean-tree check, hook installer, dev helpers
private/    your game files (gitignored, never committed)
```

## Contributing

Read [`CLAUDE.md`](CLAUDE.md) first. Its hard rules are not negotiable:

* Never commit game files, or anything generated from them: recompiled code, translated
  shaders, dumped tables, strings, or assets.
* No disassembly, decompiled output, or hex dumps of game code anywhere in the repo, including
  issues and PRs. Describe findings in prose; addresses, signatures, and struct layouts are fine.
* Reimplement from understood behavior, not line by line from decompiled code.
* Offline only: no online services, multiplayer, anti-cheat interaction, or cloud saves.
* No piracy support, and no unlocking of paid content.

Run `scripts/install-hooks.sh` once. The pre-commit hook runs `scripts/check-clean.sh`, which
rejects executables, game package formats, large files, and files whose hashes match known game
files. Code is formatted with the repo's `.clang-format` and must pass `clang-tidy`. Changes to
the loader or hooks need a test on an original fixture DLL in `tests/fixtures/`, and changes to
the recompiler need a differential test in `tests/diff/`.

## License

Copyright (C) 2026 the G6Recomp contributors.

G6Recomp is free software: you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version (`GPL-3.0-or-later`). It is distributed in
the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [LICENSE](LICENSE) file for
details.

The licence covers this project's code only. It grants no rights to the game, its files, or
anything generated from them. Third-party libraries under `thirdparty/` keep their own
licenses. Code taken from other open-source projects keeps its original notices and is listed
in [NOTICES.md](NOTICES.md).
