# GTA6-BootTest

Stand-in DLLs and a debugger harness that boot the Xbox Series X|S build of GTA VI (`game_scarlett_master.exe`, GDK) on Windows, plus an RDNA2 shader translator and a real-GPU path that runs the game's draws on a PC graphics card.

**This repository contains no game code or data.** You need your own copy of the build. It is not playable yet. The game boots, streams its archives, runs its frame loop and renders its first UI screen (the start-screen prompt bar) through translated shaders on the PC GPU. Compute, tiled textures, blending and later loading stages are not finished.

The technical findings are in [REPORT.md](REPORT.md).

## What it does

| Part | Role |
|---|---|
| `src/xmem.c` | Xbox memory API: placeholders, physical pages, commit-on-touch VEH, title allocation hooks. With `GTA6_GPUMEM=1` it backs GPU memory with a pool of pagefile sections so the PC GPU sees the same pages as the title (zero copy). Also installs IAT hooks: `G:` package-root redirect, borderless fullscreen window, `QueryApiImpl` proxies, Bink hooks. |
| `src/gpumem.h` | Shared layout of the GPU memory pool and its two-level page table (read by translated shaders). |
| `src/d3d12_xs.c` | D3D12.X device: COM objects, creator-method table, resources, root signatures, command-list recording and replay, pipeline metadata, fences, `PresentX`. |
| `src/realgpu.c` | Real D3D12 device: pool mapping, render-target cache, translated pipelines, submission at the title's `ExecuteCommandLists` with GPU-backed fences, present blit, debug readbacks and screenshots. |
| `src/XCRDAPI.c` + `src/inflate.h` | DirectStorage queue with synchronous reads and zlib. |
| `src/xg_xs.c` | Texture-computer probe. |
| `src/audio_stubs.c` | APU heap and shape contexts; no-op XApu/XDsp (silent). |
| `src/xgrproxy.h` | `xgameruntime` interface proxies and a local offline user (no Xbox Live). |
| `src/harness.c` | Debugger: loads, exceptions, debug output, breakpoints, assert skipping, `-cores=N`, hardware write-watchpoints (`GTA6_WATCH`). |
| `tools/rdna2hlsl.py` | RDNA2 machine code -> HLSL (SM 6.6) translator: scalar/vector ALU, DPP/SDWA, wave ops, buffer/typed/image memory through the pool page table, hardware-style attribute interpolation. |
| `tools/xlat_*.py` | Batch translation: survey, translate everything, or only the shader pairs a run logged as needed (`logs/xlat_needed.txt`). |
| `tools/*.hlsl` | Present blit, pool self-test and debug shaders. |
| `tools/heaptest*.c` | Small tests of D3D12 heaps opened over mapped sections. |
| `tools/*.py` (other) | capstone/ISA helpers: function disassembly via `.pdata`, xrefs, import thunks, shader ELF and pipeline metadata dumps, log summaries. |

## Build and run

Needs Visual Studio 2022 (C toolset), Gaming Services installed (for `xgameruntime.dll`), Python 3 and DXC (`third_party/dxc`). The translator reads the AMD RDNA2 ISA XML (`third_party/amd_isa/amdgpu_isa_rdna2.xml`, not included).

```
src\build.bat
powershell -ExecutionPolicy Bypass -File go.ps1 -Game "X:\path\to\game_scarlett_master.exe" -Timeout 120 -Flags "-skip"
run.bat "X:\path\to\game_scarlett_master.exe"
```

Or set `GTA6_GAME_EXE` once instead of passing the path. Logs go to `logs\harness.log` and `logs\stubs.log`.

Real-GPU run: compile the helper shaders into `bin`, translate the logged shaders, then run with the pool enabled.

```
dxc -T vs_6_6 -E vs tools/blit.hlsl -Fo bin/blit_vs.cso
dxc -T ps_6_6 -E ps tools/blit.hlsl -Fo bin/blit_ps.cso
dxc -T gs_6_6 -E main tools/rect_gs.hlsl -Fo bin/rect_gs.cso
python -I tools/xlat_needed.py third_party/amd_isa/amdgpu_isa_rdna2.xml logs logs/xlat third_party/dxc/bin/x64/dxc.exe
set GTA6_GPUMEM=1
set GTA6_XLAT_DIR=<repo>\logs\xlat
set GTA6_BLIT_DIR=<repo>\bin
```

## Environment switches

| Switch | Effect |
|---|---|
| `GTA6_WINDOWED=1` | Windowed instead of borderless fullscreen |
| `GTA6_NO_XGR_PROXY=1`, `GTA6_NO_FAKE_USER=1` | Disable the runtime proxies / offline user |
| `GTA6_NO_RACE_GUARD=1` | Disable the guard for the submit race at `exe+0x24821FE` (on by default) |
| `GTA6_WATCH=<sizeHex>:<offsetHex>` | Hardware write-watchpoint |
| `GTA6_ROOT=<dir>` | Package root |
| `GTA6_GPUMEM=1` | GPU memory pool + real-GPU path |
| `GTA6_GPUMEM_MASK`, `GTA6_GPUMEM_NORES=1` | Which physical reservations go in the pool (default excludes #0) |
| `GTA6_NO_LOW32=1` | Don't place the title's GPU heap at 2-4 GB |
| `GTA6_XLAT_DIR`, `GTA6_BLIT_DIR` | Translated shader / blit shader directories |
| `GTA6_XLAT_SOLID=1` | Flat-colour pixel shader for every draw |
| `GTA6_XLAT_MAXDRAWS=<n>` | Cap translated draws per frame |
| `GTA6_D3D_DEBUG=1` | D3D12 debug layer, messages logged |
| `GTA6_DRAWLOG=1`, `GTA6_PSO57DUMP=1`, `GTA6_VSDEBUG=1` | Per-draw logs, pipeline dumps, vertex-shader output readback |
| `GTA6_SHOT=1` | Screenshots and render-target dumps at fixed frames |
| `GTA6_NO_SRV_FROM_CB=1` | Don't fill empty buffer-SRV table slots from the table's CBV descriptor |
| `GTA6_GPUMEM_NOVA=1` | Keep `PAGE_GRAPHICS_*` allocations as private memory instead of pool pages |

## Notes

- Open D3D12 heaps over the pool with `OpenExistingHeapFromAddress` on a mapped view. `OpenExistingHeapFromFileMapping` leaked commit permanently on the tested driver (over 100 GB in one run).

## Not done

- Blend state from the pipeline's render-state block; screens after the start screen go black again
- Compute dispatch on the real GPU, tiled/swizzled textures
- DirectStorage formats `0x02` / `0x0E` (Series texture codecs)
- Saves, input mapping, audio output
