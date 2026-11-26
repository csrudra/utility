<p align="center"><img src="docs/img/pisco.png" alt="PISCO logo: a glass of pisco on ice" width="160"></p>

<h1 align="center">PISCO</h1>

<p align="center"><b>PISCO Imitates Systems, Compiles Originals.</b><br>Recompile. Package. Run.</p>

Pisco is distilled from wine, and this project owes a lot to [Wine](https://www.winehq.org): Windows PC titles are
checked against it screen by screen and call by call.

PISCO runs x86 titles in WebAssembly — in a browser tab or in Node — by recompiling their code ahead of time and
supplying the system they were written for. It is one recompiler (`crates/lifter`), one package format (`pisco`
builds a recipe and your own copy of a title into a title image), and several **compatibility runtimes**, peers
that each imitate one system; a title image names the one it is built FROM ([the plan](docs/plan.md)):

| Runtime (base) | Imitates | Runs today | Its goal |
|---|---|---|---|
| **Xbox Series** (`base/xbox-series`) | the GDK's console build: kernelx, XMem, XGameRuntime, D3D12.X, DirectStorage, XAudio2 | Doom as a console title; XCL's console test title, 50/50 | Minecraft (Bedrock), the Xbox Series build |
| **Windows x64** (`base/windows-x64`) | 64-bit Windows desktop: DXGI, D3D12, the PC GDK, the MSVC runtimes | Stockfish 19 (official build), Microsoft's SimpleTriangleDesktop and SimplePBR | desktop D3D12 titles |
| **Windows x86** (`base/windows-x86`) | 32-bit Windows desktop of the 2000s: Win32, GDI, Direct3D 9, DirectInput, FMOD | Narbacular Drop (2005), playable in a desktop browser; Tag: The Power of Paint (2008, shader model 2) to its second level, checked in headless Chrome | 32-bit Direct3D 9 games of the 2000s |

Running Minecraft through the Xbox Series runtime is where the project started; it is now that runtime's goal, one
among several. Nothing of a title is in this repository: you bring your own copy.

Narbacular Drop, built from your own installer into a title image, runs at 100 to 350 frames a second in Chrome on
an M1 MacBook Pro, with its sound, mouse-look under Pointer Lock, both portals and its saved options. Scripted
sessions check it against Wine screen by screen and call by call, in Node and in headless Chrome
([status](docs/status.md), [the game's page](docs/narbacular-drop.md)).

Tag: The Power of Paint, DigiPen's paint-gun game, is built the same way, with Microsoft's own D3DX from its
installer lifted beside it: its 16 effects compile at run time to the same 46 shaders as under Wine, translated to
WGSL, and in headless Chrome its first level is within 1.4 of 255 of Wine's screenshots on average; it plays into
its second level, paints and erases, with FMOD Ex's calls as Wine's ([the game's page](docs/tag.md)).

Licence: GPL-2.0-or-later for our own code; code from other projects keeps its own licence (the shader tools
from [XCL](https://github.com/ivall/xcl) are GPL-2.0-only). See [LICENSING.md](LICENSING.md).

Docs: [the plan](docs/plan.md) (the structure, the runtimes, the rules a change follows) ·
[the journey so far](docs/journey.md) (what was built, measured and learned, roadblocks) ·
[status and next steps, by runtime](docs/status.md) · [first run of a console title](docs/first-run.md) · [wasm32 or wasm64](docs/memory.md) ·
[Narbacular Drop, the first Windows PC title](docs/narbacular-drop.md) · [title images and `pisco`](docs/images.md)

## How it works

```
title.exe ── lifter (native, once per build) ──► C, one function per guest function ──► clang ──► title.wasm
                                                                                                   │ imports
runtime (rt/, C on wasi-libc, linked into the same module) ◄───────────────────────────────────────┘
 the core, every title (rt/*.c):
  process.c   image loading, import binding, guest calls, handles and waits, threads, TEB / TLS
  kernel32.c  threads, sync objects (events, semaphores, mutexes, critical sections, SRW, condition variables),
              memory, time, modules, code pages, standard handles
  msvcrt.c    C runtime: startup / exit, stdio, printf (each guest width's arguments), strings, maths, locale "C"
  ucrt.c      the UCRT (api-ms-win-crt-*), falling back to msvcrt.c where the semantics match
  seh.c       x64 exception handling over the images' .pdata / .xdata: RaiseException, RtlUnwindEx, vectored handlers
  vfs.c       the title's file system: console drives, the title's folder read-only, an in-memory overlay;
              an image's file layers make C:, and what a desktop title writes in its folder is kept by the host
  files.c     kernel32 / ntdll file functions over vfs.c
  mixer.c     the one sound output, shared by XAudio2 and FMOD (mixed to the virtual clock when there is one)
  gpu_ring.c  the ring of records a GPU back end reads (web/gpu/): what D3D12 and Direct3D 9 both write to
 one folder per runtime (each base lists its own; `pisco sources <base>` prints them):
  gdk/        what the Xbox Series and Windows x64 runtimes share: D3D12 (d3d12.c), DXGI and MFPlat, D3DCompile
              from precompiled shaders, XAudio2 + audio_codec.c (XMA2 / Opus via FFmpeg), XGameRuntime (task
              queues, XAsync, XUser, saves, PLS, package), GameInput
  xbox-series/ the console's own: kernelx, XMem (with the GPU-visible region), its screen (user32 / DWM),
              D3D12.X's frame clock and list methods, XG, DirectStorage
  windows-x64/ DXGI's factory and swap chains, the PC GDK's QueryApiImpl objects
  windows-x86/ user32, gdi32 (text drawn: font.c, stb_truetype, Liberation Sans), the registry, DirectInput 8,
              FMOD 3 (fmod3.c, audio_decode.c), and Direct3D 9 (d3d9*.c: the device; d3d9_ffp.c: its
              fixed-function pipeline as WGSL; d3d9_gpu.c: its draws)
Imports nothing implements become stubs that log their first call and return 0 (E_NOTIMPL for the console's
HRESULT APIs), as in XCL; SW_STRICT=1 stops at them instead.
host (web/)   WASI calls, one worker per guest thread over one shared memory; image.mjs reads a title image
pisco (crates/pisco) builds a recipe and the user's installer into a title image (OCI layout), and runs it
```

- **Images**: the exe and every DLL it imports that sits beside it are lifted together, each rebased below
  4 GiB; imports between them are bound at lift time. The runtime reads their bytes from the title's folder.
- **Lifter** (`crates/lifter`): functions from the exception table, call targets, code pointers in data,
  jump tables, and landing pads from the language-specific exception data (GCC/LLVM LSDA, C scope tables).
  It reports what it could not lift. AVX-and-later functions are left out: the virtual CPU's CPUID reports
  SSE4.2 and POPCNT only, so titles pick their SSE paths.
- **Registers** live in a `Cpu` struct passed as `restrict`, so clang keeps them in wasm locals between calls.
- **32-bit titles**: the same lifter in a 32-bit mode. Without an exception table, functions come from the
  entry point and call targets, then from code addresses in data and immediates; `jmp [reg*4+table]`
  switches are recovered; x87 keeps its control word (rounding, 24-bit precision). The runtime is built for
  the guest's width (stdcall arguments on the stack, the TEB on `fs`). MMX and 3DNow are not lifted; the
  recipe gives a title its virtual CPU's features, so a 32-bit title takes its x87 paths.
- **Guest memory** is linear memory: a guest address is a wasm address. Images are rebased below 4 GiB.
  wasm32 by default; see [docs/memory.md](docs/memory.md) for wasm64.
- **Threads**: a guest thread is a pthread of the runtime, i.e. a worker. In the browser they come from a
  pool the page starts ahead of time (a worker cannot start one while it blocks).
- **Exceptions**: a lifted function with landing pads registers a `setjmp` landing; restoring a context
  longjmps to the frame's landing and jumps to the pad's label.

## Try it

Needs Rust, Node 24, [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) 34 in `~/tools`, and for the C++
tests [llvm-mingw](https://github.com/mstorsjo/llvm-mingw). `tools/setup-toolchain.sh` fetches them (and the
shader tools the Doom test needs); `tests/run.sh` builds and runs every test title.

```sh
cargo build --release -p pisco-lifter
(cd fixtures/hello && cargo build --release)                       # our own Windows-format test titles
cargo build --release -p pisco                                      # build-title.sh asks it for the base's files
tools/build-title.sh fixtures/hello/target/x86_64-pc-windows-msvc/release/hello.exe out/hello   # BASE=windows-x64 (64-bit default)
node web/run-node.mjs out/hello/title.wasm fixtures/hello/target/x86_64-pc-windows-msvc/release/hello.exe
node tools/run-chrome.mjs out/hello/title.wasm <the .exe>          # the same in headless Chrome
```

A Windows PC title is built from its recipe and your own installer into a title image (an OCI image layout:
[docs/images.md](docs/images.md)); the installer is checked by its sha256, extracted with innoextract
(`tools/setup-toolchain.sh innoextract`), and never copied into the repository:

```sh
cargo build --release -p pisco -p pisco-lifter
target/release/pisco build recipes/narbacular-drop --source ~/Downloads/narbacular_drop_setup.exe   # -> out/images/narbacular-drop
target/release/pisco run out/images/narbacular-drop --session recipes/narbacular-drop/sessions/menu-to-level.json
target/release/pisco run out/images/narbacular-drop --chrome          # headless Chrome; in a browser of your own:
node tools/serve.mjs 8000 web out/images/narbacular-drop           # then http://127.0.0.1:8000/browser/index.html?image=/files/0/
target/release/pisco build recipes/tag --source ~/Downloads/Tag_setup.exe                          # -> out/images/tag, the same way
target/release/pisco inspect out/images/narbacular-drop               # its layers, config and registry
target/release/pisco census <a title's .exe>                          # what the base and its libraries answer for
```

`SW_TRACE=1` logs missing imports and exception dispatch; `SW_TRACE=2` every import call. For Windows
desktop titles: `SW_CLOCK=16667` makes time virtual (it moves by that many microseconds when a frame is
presented), `SW_SESSION=<session.json>` plays a scripted session of mouse and keyboard input (both hosts; in
Chrome the frame presented at each of its `shot` steps is saved as a PNG beside the wasm, in `shots/`),
`SW_D3D9_STATS=1` and `SW_D3D9_FRAMES=1` print what the title asked Direct3D 9 for and the shaders made for it.

## State (2026-11-25)

[![graphics ladder](https://yhozen.github.io/pisco/badge-ladder.svg)](https://yhozen.github.io/pisco/progress.html) [![D3D12 methods](https://yhozen.github.io/pisco/badge-d3d12.svg)](https://yhozen.github.io/pisco/progress.html) [![imports](https://yhozen.github.io/pisco/badge-imports.svg)](https://yhozen.github.io/pisco/progress.html) [![XCL checks](https://yhozen.github.io/pisco/badge-xcl.svg)](https://yhozen.github.io/pisco/progress.html)

[![progress map](https://yhozen.github.io/pisco/progress.svg)](https://yhozen.github.io/pisco/progress.html)

Video: [Doom as an Xbox console title in the browser](https://yhozen.github.io/pisco/) (D3D12.X on WebGPU, XAudio2, GameInput, saves in OPFS).
The map is drawn by `tools/progress.mjs` (`--refresh` re-reads the build outputs into `docs/progress-data.json`)
and published by `.github/workflows/progress.yml`.

| Title | What it checks | Node | Chrome |
|---|---|---|---|
| `fixtures/hello` (Rust, no_std) | recursion, switch, pointers, SSE loop, f64 | 7/7 | 7/7 |
| `fixtures/threads` (Rust, no_std) | 4 threads, `lock xadd`, critical sections, events, semaphores, TLS, ExitThread, timeouts | 9/9 | 9/9 |
| `fixtures/cxx` (C++, llvm-mingw, libc++ + libunwind) | throw through frames with destructors, `catch (...)`, `std::exception`, rethrow, throw in catch, in a thread | 7/7 | 7/7 |
| `fixtures/dll` (C++, llvm-mingw: an exe and the DLL it ships) | static and dynamic imports, DllMain on process and thread attach, `thread_local` in the DLL, an exception crossing from the DLL | 7/7 | – |
| `hello` again as a 32-bit program (i686), and `fixtures/x87` (C, llvm-mingw, no SSE) | the lifter's 32-bit mode and the runtime for a 32-bit guest: stdcall, the x87 with its control word (rounding, 24-bit precision), the direction flag, EFLAGS.ID, a jump table as Visual C++ writes them. Expected output: what the same programs print under Wine | 7/7; 27 of 27 lines | 7/7; 27 of 27 |
| **Narbacular Drop** (2005; the user's own copy, built with `recipes/narbacular-drop/title.toml`) | a real 32-bit Windows game from its entry point into its first level: its C runtime, files, window, Direct3D 9 (fixed-function, drawn through shaders the runtime writes), D3DX, DirectInput, FMOD 3 (sound from its MP3, Ogg and WAV files), scripted sessions on a virtual clock, the keyboard and Pointer Lock mouse from the page, files it writes kept between runs | the same calls as under Wine up to `Direct3DCreate9` (81 steps, repeats folded); the session's 13 checkpoints over 6,256 frames, the same log on every run, each frame making the Direct3D calls it makes under Wine, text draws included (strict mode); its 539,750 draws reach the null GPU back end as consistent records; a second session places both portals and walks out of the cage, its sound the same on every run, its FMOD calls Wine's up to the game's first random choice of a sound; `system.opt`, written on Quit, read by the next run | the session drawn with WebGPU, a PNG at each checkpoint: the 8 still screens within one level in 255 of Wine's (with D3DX's plain code, as here), the menu and the level within what two runs of Wine differ by, the level's title and hint drawn by GDI where Wine draws them; 12 to 20 frames a second on SwiftShader (`tests/run.sh ndgfx`); the portal session's level views within 1 to 2 levels of Wine's on average, `system.opt` kept across a reload in OPFS (`tests/run.sh ndplay`); a recording with sound (`recipes/narbacular-drop/video.sh`); built from the installer as an image, the same results (`tests/run.sh images`). **Played by hand in Chrome on an M1 MacBook Pro**: 294 to 355 frames a second in lighter views, 103 to 174 in the heaviest, no WebGPU error over 4.4 M draws |
| **XCL's console test title** (`tests/testtitle` + its game DLL, Rust std, built for `x86_64-pc-windows-gnullvm`) | XCL's own checks of a console title: TLS, panics, kernelx, XMem, the console screen, GameInput, modules, game DLL, the VFS, XGameRuntime, XUser, saves, PLS; D3D12.X (UMA memory, the console device and list methods, DMA queue, derived pipelines, depth bias, queries, textures in title memory), DirectStorage, MFPlat, XAudio2 with XMA2 and Opus | 46/50 (the 4 checks that read pixels need WebGPU) | **50/50** (`tests/gfx/xcl.sh`) |
| **Stockfish 19, official Windows x64 build** (MinGW, 103 MB) | `bench`: 2.9 M instructions lifted, worker threads, NNUE (109 MB) in shared memory | **2,497,913 nodes = the published signature**, 105,700 nodes/s | **2,497,913 nodes**, 110,821 nodes/s, 22.5 s |
| **SimpleTriangleDesktop** (Microsoft's GDK sample, clang-cl and real MSVC builds, with the MSVC C++ runtime DLLs lifted beside it) | the PC GDK's XGameRuntime, DXGI swap chains, vertex buffers, sRGB targets, MSVC C++ exceptions (`fixtures/msvc`: 6/6 with the real vcruntime140) | runs, null back end | frame read back from WebGPU = the colours and area computed from the sample's vertices, both builds (`tests/gfx/st.sh`) |
| **SimplePBR** (Microsoft's GDK sample, clang-cl, all of DirectXTK12) | PBR with image-based lighting, HDR target and tone map, BC textures and cube maps, sprite fonts, the thread pool | runs, null back end | the sample's scene, stable frame to frame, no WebGPU error, ~2 fps on SwiftShader (`tests/gfx/pbr.sh`) |
| **Doom as a console title** (`fixtures/doom`: doomgeneric + Freedoom on D3D12.X, GameInput, XAudio2, XGameSave; llvm-mingw) | D3D12.X → WebGPU, `PresentX` and the frame clock, sound, keyboard / gamepad, saves that survive a reload | `-timedemo` frames equal native on every deterministic frame (null GPU back end) | frames **read back from WebGPU** equal native's; ~35 fps on SwiftShader; video: `fixtures/doom/video.sh` |

Stockfish's `bench` is deterministic and its node count is recorded in the release commit (`Bench: 2497913`), so
matching it checks every lifted instruction it ran.

No game files, lifted output or dumps belong in this repository (`out/` is ignored).
