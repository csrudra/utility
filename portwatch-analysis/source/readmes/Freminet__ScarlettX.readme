# ScarlettX

**ScarlettX** is an experimental, open-source high-level emulator (HLE) for **Xbox Series X|S (Scarlett / Gen9 Game Core)** x86-64 software, designed to execute legally obtained GDK titles end-to-end by emulating the Scarlett OS, Game Core runtime, unified memory model, `d3d12_xs`, and ray-tracing (`XboxBvhBuilder` / DXR) stack.

> **Legal notice:** ScarlettX does not include, decrypt, or distribute any proprietary Microsoft/Xbox binaries, keys, firmware, or commercial game assets. All automated tests run against synthetic x86-64 PE titles built from source in this repository.

<!-- SCARLETTX_STATUS_START -->
## Status

![ScarlettX Status](docs/status.svg)

![Status of the game Concept Destruction](docs/status_concept_destruction.svg)

| Main menu | In game |
| :---: | :---: |
| ![Concept Destruction main menu running in ScarlettX](docs/image_00_01.png) | ![Concept Destruction gameplay running in ScarlettX](docs/image_00_02.png) |
| Max FPS: 1189<br>Average FPS: 1082<br>Minimum FPS: 264 | Max FPS: 247<br>Average FPS: 188<br>Minimum FPS: 91 |

**Emulator Status:** `66.6%` (281 of 422 tracked functions, including unimplemented `0%` subsystems) · **Concept Destruction:** `91.3%` (42 of 46 bring-up milestones) · **Exports:** `269` · **Tests:** `26/26` passing · **Target:** `Xbox Series X|S (Gen9)`

| Subsystem | Category | Progress | Coverage | Details |
| :--- | :--- | :---: | :---: | :--- |
| **PE64 Loader & Auto-Stubs** | `Core` | `6 of 6` | `100%` | PE32+ mapping, DIR64/HIGHLOW relocs, named/ordinal IAT, API-set redirection, x64 auto-stub thunks |
| **d3d12_xs → PC D3D12 & PSOs** | `Graphics` | `45 of 46` | `98%` | 44 exports + DXIL/DXBC container parser & Xbox-chunk stripper; root signatures, descriptor heaps, graphics/compute/software-DXR PSOs, pipeline cache, WARP or hardware adapter |
| **DirectStorage & XVD** | `Storage` | `23 of 24` | `96%` | 22 DStorage exports + unencrypted XVD parser/PackageVfs mounting; async worker queues, fence/status arrays, cancellation, synthetic LZ-RLE test codec |
| **XTaskQueue & XAsync** | `xgameruntime` | `23 of 24` | `96%` | 15 XTaskQueue + 8 XAsync exports (manual/threadpool/delayed/monitors/cancel) |
| **Networking (HTTP / XCurl)** | `Networking` | `38 of 40` | `95%` | 19 libHttpClient.GDK + 19 XCurl exports; deterministic offline mock registry, async callbacks, headers, fallback responses |
| **XSystem & Runtime** | `xgameruntime` | `17 of 18` | `94%` | 17 exports; Scarlett Anaconda device info, runtime/analytics, handle validation |
| **Input (GameInput)** | `Input` | `15 of 16` | `94%` | 15 exports; virtual Xbox Series controller & keyboard, reading history (Current/Next/Previous), state injection, rumble forwarded to the host controller's two main motors |
| **DXR / XboxBvhBuilder** | `Graphics` | `12 of 14` | `86%` | 8 BVH exports + DXR AS prebuild/build/destroy, BLAS update, single-ray trace, deterministic software BVH fallback (hardware DXR requires capable GPU) |
| **Audio (XAudio2 / AcpHal)** | `Media` | `33 of 42` | `79%` | 33 exports (XAudio2_9 ordinal #1 + AcpHal.dll APU/SHAPE shims); headless PCM mixer, WAV writer, fail-closed real-title COM guard, synthetic XMA2 test decoder |
| **XGameSave (persistent)** | `xgameruntime` | `23 of 30` | `77%` | 23 exports; disk-backed containers, sync/async blob R/W, quota, delete |
| **XMem & Threading** | `xgameruntime` | `11 of 16` | `69%` | 11 exports; default/custom alloc hooks, VirtualAlloc/Free, time-sensitive thread state |
| **Middleware (Bink2 / FSR)** | `Middleware` | `22 of 34` | `65%` | 12 Bink2Scarlett + 10 amd_fidelityfx_loader/upscaler_xbox exports; deterministic offline HLE shims (synthetic RGBA/BGRA frames, bilinear upscale & hash) |
| **XUser & Identity** | `xgameruntime` | `13 of 24` | `54%` | 13 exports; synthetic Xbox Live profile, XUID, gamertag components, privileges |
| **Hardware DXR & Vulkan Backend** | `Graphics` | `0 of 14` | `0%` | Hardware GPU ray tracing (DXR Tier 1.1) and cross-platform Vulkan / vkd3d-proton backend |
| **Live Xbox Services (XSAPI/WinRT)** | `Platform` | `0 of 16` | `0%` | Full Xbl* Xbox Live services, WinRT runtime activation, achievements, multiplayer |
| **Production Codecs (XMA2/GDeflate/Bink)** | `Media` | `0 of 16` | `0%` | Native SHAPE XMA2 transform audio, hardware GDeflate/BCPack, production Bink2 & GPU FSR |
| **RDNA2 XS2 Shader Lifting** | `Graphics` | `0 of 16` | `0%` | Precompiled RDNA2/Scarlett GPU microcode lifting to PC DXIL or SPIR-V |
| **Retail XVC/XVD Crypto** | `Storage` | `0 of 12` | `0%` | Encrypted & digitally signed retail .xvc/.xvd package decryption and verification |
| **Xbox Unified Memory & KernelX** | `Platform` | `0 of 14` | `0%` | MEM_GRAPHICS, 64 KB / 4 MB physical-virtual aliasing, full Game OS kernel services |

> **Not started (0%):** Xbox unified memory (`MEM_GRAPHICS`) & full KernelX, precompiled RDNA2 `XS2` ISA lifting, encrypted retail XVC/XVD decryption, production GDeflate/XMA2/Bink decoding, hardware DXR & Vulkan backend, and live XSAPI/WinRT services. Passing synthetic tests do not imply commercial retail title execution.

_Regenerate with `python tools/generate_status.py --build-dir <build tree>` after adding new HLE APIs or subsystems; the test numbers are read from that tree's last `ctest` run._
<!-- SCARLETTX_STATUS_END -->

## Architecture Overview

Because Xbox Series X|S executables are native **x86-64 PE32+** binaries targeting Microsoft's Game Development Kit (GDK), ScarlettX focuses on **high-level OS, runtime, memory, and GPU/RT emulation** rather than CPU static recompilation:

| Subsystem | Components | Status |
| :--- | :--- | :--- |
| **Package & PE64 Loader** | `MicrosoftGame.Config` parser (`XboxGen9`/`Scarlett`), in-process PE64 mapper (`DIR64`/`HIGHLOW` relocations, page protections), named/ordinal IAT & API-set resolution (`api-ms-win-core-synch-l1-2-*`, `rtlsupport`, `psm-appnotify`), dynamic `LoadLibrary` shim redirection, x64 auto-stub thunk generator | Phase 1 updated + tests |
| **GDK Runtime (`xgameruntime.dll`)** | C ABI for `XGameRuntime*`, `XTaskQueue*`, `XAsync*`, `XUser*`, persistent disk-backed `XGameSave*`, `XSystem*`, `XMem*` hooks & virtual memory, `XThread*`, `XStorage`, `InitializeApiImpl`/`InitializeApiImplEx`, `UninitializeApiImpl`, `XErrorReport`, plus ScarlettX-owned guest COM vtables for `QueryApiImpl` GUIDs `{073B7DCB-1FCF-4030-94BE-E3C9EB623428}` and `{37E56907-2F10-41E8-B72F-36EDB185331A}` | Phase 3 updated + tests |
| **Graphics (`d3d12_xs` / `xg_xs`)** | `d3d12_xs.dll` (`D3D12XboxCreateDevice`, `D3D12XboxSetProcessDebugFlags`, `D3D12SerializeRootSignature`, `D3D12XboxCreateSyntheticDevice`, ScarlettX-owned Xbox COM proxy wrappers for device, queues `0x2`/`0x10`, fences, descriptor heaps, allocators, root signatures, graphics PSOs, resources, command lists, and frame events) + `xg_xs.dll` (`XGCreateTexture2DComputer`, `XGComputeOptimalSwizzleMode`) | Phase 3 in progress + tests |
| **Ray Tracing (DXR / BVH)** | Synthetic `d3d12_xs` DXR acceleration-structure prebuild/build/destroy + `XboxBvhBuilder.dll` (synthetic signatures + deterministic software BVH fallback; hardware DXR requires a DXR-capable GPU) | Synthetic scaffold + tests |
| **DirectStorage & XVD (`dstorage_xs.dll`)** | Renamed to Xbox `dstorage_xs.dll`; async worker-thread I/O queues, file/memory/XVD reads, fence callbacks, status arrays, cancellation by tag, synthetic LZ-RLE test codec, unencrypted XVD container parser + `PackageVfs::MountXvd` | Phase 1 cleanup + tests |
| **Audio (`xaudio2_9.dll` / `AcpHal.dll`)** | `XAudio2_9.dll` with verified ordinal `#1` (`XAudio2Create`; real titles get guest-facing `IXAudio2`/voice objects over the host XAudio2 2.9, or silent output without an audio device; effect chains are not passed through) + `AcpHal.dll` (`ApuAlloc`/`ApuFree`/`ApuMapVirtualAddress`/`ApuIsVirtualAddressValid`/`AcpHalCreate`/`AcpHalAllocateShapeContexts`/`AcpHalReleaseShapeContexts`) + headless PCM mixer & synthetic XMA2 test decoder | Phase 3 updated + tests |
| **Input (`GameInput.dll`)** | `GameInput.dll` with verified ordinal `#1` (`GameInputCreate`), virtual Xbox Series controller & keyboard enumeration, reading history (`Current`/`Next`/`Previous`), deterministic input injection, rumble forwarded to the host controller's two main motors | Phase 1 updated + tests |
| **Shader & PSO Pipeline** | DXIL/DXBC container parser (stage, shader model, I/O params, RT exports, embedded root sig, content hash), Xbox-private chunk stripping (`XBOX`/`XS2M`), explicit unsupported-format error on precompiled RDNA2 `XS2`, D3D12 root signatures, descriptor heaps, graphics/compute/software-DXR PSOs, pipeline cache stats, draw/dispatch/RT command execution | Synthetic scaffold + tests |
| **Middleware (`Bink2` / `FidelityFX`)** | `Bink2Scarlett.dll` (open/decode/advance/pause/seek/RGBA/BGRA/summary), `amd_fidelityfx_loader_xbox.dll` & `amd_fidelityfx_upscaler_xbox.dll` (context lifecycle, quality ratios, render resolution, jitter, deterministic bilinear upscale & frame hash) | Synthetic scaffold + tests |
| **Networking (`libHttpClient` / `XCurl`)** | `libHttpClient.GDK.dll` (init, mock registry, request setup, async callbacks, offline fallback), `XCurl.dll` (easy handle lifecycle, `curl_easy_setopt`, write callbacks, `curl_easy_getinfo`, slist headers, mock/offline responses) | Synthetic scaffold + tests |
| **End-to-End Integration** | `scarlett_arena` synthetic Gen9 game booting via in-process PE64 mapper (with isolated guest `atexit` cleanup) and child process across `xgameruntime`, `dstorage_xs`/XVD, `GameInput`, `d3d12_xs` + software BVH RT, `XAudio2`, and `XGameSave` | Synthetic E2E + tests |

### Real-Title Bring-Up (Verified Observations — Concept Destruction)

Testing against an unencrypted commercial Xbox Series X|S (`Scarlett`) Unity IL2CPP title (**Concept Destruction**, kept strictly outside the repository) established:

- **Phase 1 — Static inspection & image mapping:** PE64 image maps with 405 imported symbols and no auto-stubs left; ScarlettX's `d3d12_xs.dll`, `xg_xs.dll`, and `AcpHal.dll` resolve all static Xbox imports.
- **Phase 2 — `QueryApiImpl` COM interface (`{073B7DCB-1FCF-4030-94BE-E3C9EB623428}`):** Reverse-engineered the target's Windows x64 register ABI (`RCX=api_id`, `RDX=riid`, `R8=out_impl`) and vtable offsets (`+0x00`/`+0x08`/`+0x10`, `+0x30`, `+0x60`, `+0x80`, `+0x88`, `+0xE8`). Implemented a ScarlettX-owned 32-slot guest COM object in `xgameruntime.dll` with dedicated ABI tests (`test_query_api_impl`).
- **Phase 3 — Runtime tables, `AcpHal` and `d3d12_xs` proxies:** every `QueryApiImpl` table the title requests now resolves through ScarlettX-owned guest COM objects (task queues, XNetworking, XGame, XSystem, XUser, XGameSave). Table slots were identified from the console `xgameruntime.dll`; slots without a verified name stay unnamed and traced. `XUserGetTokenAndSignatureAsync` still returns `E_NOTIMPL`; the title carries on.
- **Phase 4 — Frames:** with guest implicit TLS in the loader the title runs until stopped. It writes cooked texel data (console `4KB_S` layout) to the address returned by `ID3D12Resource::GetGPUVirtualAddress`; `d3d12_xs` backs that address with guest memory and converts it into the host texture, `xg_xs` reports the console texture layout, and scene textures are created through `CreateHeap`/`CreatePlacedResource`. Frame dumps show, in order: the publisher logo, the developer logo, the intro cutscene, a 3D scene, the main menu and the "Select car" menu.
- **Phase 5 — Input, gameplay, audio:**
  - With keyboard input bridged to a virtual gamepad, a Championship event starts and the car drives. Verified in frame dumps: A, B, D-pad, left stick, right trigger. A real Xbox controller works as well, and progress is saved: a championship in progress continued after the emulator was restarted.
  - `XAudio2Create` returns guest-facing objects; the title creates its engine, mastering voice and a 48 kHz source voice and polls the play position, against a silent output (the first test machine has no audio device). On a machine with an audio device the title's sound is audible.
  - No `CmdList::Close` failure or device removal in gameplay runs.
  - On a hardware GPU (`--gpu`) the title plays at full speed: about 110 fps at 2,300 draw calls per frame and about 140 fps at 850, measured with `--stats`. An event ran from the countdown to the results screen. The software rasterizer of the first test machine managed about 2 to 3 fps.
- **Known problems:** The fps figures in this README were measured before frame pacing existed; `--fcap 0` gives the same behaviour.
- **Current classification:** **In-game** — **Concept Destruction** and **Unicorn Overlord** are playable on a hardware GPU; Alt+Enter toggles borderless fullscreen and controller rumble works.

### Current Limitations

- **Xbox COM vtable wrappers:** `d3d12_xs` guest-facing proxies cover what **Concept Destruction** and **Unicorn Overlord** use; other titles will hit unimplemented or unnamed slots. `XAudio2Create` returns guest-facing `IXAudio2`, source, submix and mastering voice objects (never a host COM pointer); they forward to the host XAudio2 2.9, or to a silent output when the host has no audio device. With the real title the sound is audible through the host output; effect chains are not passed to the host, and the silent output times every buffer as PCM.
- **Presentation:** Alt+Enter switches the PresentX window to borderless fullscreen on its monitor and back, stretching the title's frame; there is no exclusive fullscreen. `WaitFrameEventX` waits for the next frame origin at the interval set with `SetFrameIntervalX`, on a timer rather than the display's vertical sync; `ScheduleFrameEventX` succeeds without scheduling anything.
- **Guest texture uploads:** texel data a title writes to a texture's address is uploaded once per presented frame, before the frame's first submit, so a later write reaches the host texture one frame late. Until the first frame is presented, every submit uploads.
- **Child-process boot:** without `--in-process` the guest starts as a separate process. The emulator sets the shim directory as the DLL directory for that process, so the shims are found ahead of a host `C:\Windows\System32\xgameruntime.dll` (a Windows component on some Windows 11 builds). A DLL of the same name next to the guest executable still takes precedence over the shim.
- **Unimplemented 0% subsystems:** Xbox unified memory (`MEM_GRAPHICS`, 64 KB / 4 MB physical-virtual aliasing) & full KernelX, precompiled RDNA2 `XS2` ISA lifting, encrypted retail `.xvc`/`.xvd` decryption, production GDeflate/BCPack/XMA2/Bink2/GPU FSR codecs, hardware DXR Tier 1.1 & Vulkan backend, and live XSAPI/WinRT services.
- **Codecs, Middleware & Networking:** `Bink2Scarlett`, `amd_fidelityfx_*_xbox`, `dstorage_xs` decompression, `XMA2`, `libHttpClient.GDK`, and `XCurl` use deterministic offline/synthetic HLE shims for automated tests. Passing synthetic tests do not imply commercial retail title execution.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/ROADMAP.md](docs/ROADMAP.md) for detailed design notes.

## Building & Running Tests

Requirements on Windows (x86-64):
- CMake 3.20+
- Ninja
- C++20 compiler (MinGW-w64 GCC 13+ or MSVC 2022)
- Windows D3D12 runtime + WARP (included in Windows 10/11 & Server 2022)

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

## Running the Synthetic Scarlett Test Games

```bash
# Inspect a Game Core package manifest and PE imports
./build/scarlettx inspect build/packages/hello_scarlett

# Boot the synthetic hello_scarlett title headlessly
./build/scarlettx boot build/packages/hello_scarlett --headless --frames 3

# Boot the synthetic ray-tracing showcase and dump a rendered RT frame
./build/scarlettx boot build/packages/rt_showcase --headless --frames 2 --rt-dump rt_frame.ppm

# Run the full-stack end-to-end synthetic game demo (PE64 + XVD/DirectStorage + GameInput + D3D12/BVH RT + XAudio2/XMA2 + XGameSave)
./build/test_scarlett_arena_e2e
```

## Running a Real Title

```bash
# From the directory that holds scarlettx.exe and the shim DLLs
scarlettx boot "<extracted package>\Mount" --in-process --gpu --stats
```

- `--in-process` maps the title into the emulator process (the path used for real titles). `--gpu` renders on the hardware adapter, which is the default; `--warp` selects the software rasterizer. `--stats` prints fps and D3D12 call counts once per second, `--fcap N` holds N frames per second instead of the title's own rate (for example `--fcap 144`; `--fcap 0` removes the cap), and `--trace` logs the shim calls.
- Input: the keyboard while the window has focus (arrows = D-pad, WASD = left stick, IJKL = right stick, Enter/Space = A, Escape/Backspace = B, X = X, Y = Y, Q/E = shoulders, 1/3 = triggers, Tab = View, P = Menu), and the first XInput controller when one is connected (checked with an Xbox controller; rumble is forwarded to it).
- The window does not close from its title bar; stop the emulator with Ctrl+C in its console.
- Save data goes to `%TEMP%\scarlettx_saves`; set `SCARLETTX_SAVE_ROOT` to use another directory.
