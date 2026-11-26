# sludgemu

A compatibility layer that runs Xbox Series X|S titles on Windows desktop.

Scarlett titles are x64 Windows PE images built against the console flavour of the Microsoft
GDK. sludgemu loads them directly and provides the console-only parts of the platform: title
memory management, the console D3D12 runtime (translated to desktop D3D12, with RDNA2 shader
binaries recompiled to DXIL at runtime), console audio hardware, DirectStorage, input and system
services.

> **Status:** early bring-up. The loader maps a title, binds its imports and starts the title's
> CRT; most console APIs are still logging stubs.

sludgemu contains no Microsoft GDK code or headers and no title code or data. You need your own
legally obtained, decrypted title package.

## Building

Requirements: Windows 10/11 x64, Visual Studio 2022 (MSVC, "Desktop development with C++"),
CMake 3.24+, and network access on the first configure (dependencies are fetched then).

```
cmake --preset vs2022
cmake --build --preset vs2022-debug      # or vs2022-release
```

Output goes to `build/vs2022/bin/<Config>/`.

## Running

```
sludgemu.exe [options] <package directory | title exe> [-- title arguments]
```

| Option | Meaning |
|---|---|
| `--console` | open a console window with the live log |
| `--log-level=LEVEL` | `trace`, `debug`, `info` (default), `warn`, `error` |
| `--break-on-stub` | break into an attached debugger when an unimplemented import is called |
| `--gpu-debug` | enable the D3D12 debug layer |
| `--gpu-warp` | render with the software rasterizer (WARP) instead of the GPU |
| `--model=MODEL` | console to present as: `series-x` or `series-s`. Titles adapt to the detected console (memory budget, resolution, quality). By default sludgemu picks Series X only on machines with at least 24 GB of RAM and a 10 GB GPU, and Series S otherwise |
| `--dump-threads-after=N` | log a backtrace of every thread every N seconds (for diagnosing hangs) |
| `--watch-write=SPEC` | hardware watchpoint: log every write (value + backtrace) to an 8-byte location, `module.dll+0xRVA` or `0xADDRESS` |

The title runs in its own window, the way a native game does. **F11** or **Alt+Enter** toggles
borderless fullscreen. The log is written to `sludgemu.log` next to `sludgemu.exe`, and a
minidump to `sludgemu_crash.dmp` on a crash.

## Layout

| Path | Contents |
|---|---|
| `src/loader` | PE mapping, import binding, TLS, logging stubs, crash reporting and diagnostics |
| `src/hle` | implementations of console system DLLs, plus host-function overrides |
| `src/platform` | desktop integration (window management, ...) |
| `src/core` | title metadata, console memory model |
| `docs/` | design notes |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how it fits together.
