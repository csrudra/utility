# NativeX Runtime

**Native x64 interoperability, platform runtime and graphics research for Windows and Linux.**

NativeX Runtime (formerly Scarlett Windows Compat) develops original, independently buildable C++ and Python tools for PE32+ metadata inspection, native host ABI validation, memory, graphics, I/O, audio, input and performance research. The project explores direct execution of compatible x64 instructions on an x64 host, with native platform APIs where appropriate. Xbox Series / Game Core interoperability is a research area, not a promise of retail title compatibility.

## Current capabilities

| Area | Evidence in this repository |
| --- | --- |
| PE32+ | Bounded imports, exports (including ordinal-only entries), forwarders, TLS, relocations and AMD64 unwind inventory; compact analysis of large exception tables |
| Dependency planning | Offline explicit import-binding plans, host export inventory validation, and immediate/delayed multi-image dependency preflight |
| Native ABI | Source-built Windows DLL, TLS lifecycle, struct return and unwind/SEH fixtures |
| Graphics | Original D3D12/WARP compute, raster, tiled resource and DXGI present tests; Linux Vulkan compute/raster fixtures; CPU/GPU BC texture checks |
| Memory and I/O | Page alias models, Windows shared backing and IOCP fixtures, portable bounded asset streaming |
| Input, audio and persistence | Remappable controls, gamepad analog processing, PCM mixing/resampling and two-slot save integrity |
| Performance | Frame timing, safe x64 dispatch and explicit feature capability policies |

These are separate experiments and reusable components, not a complete application runtime or commercial-game port. A matching export name is not ABI proof. WARP or CPU Vulkan success is not evidence of physical GPU performance.

## Build and test (manual)

Requirements: CMake 3.20+, Python 3.11+, and a C++17 compiler. Windows graphics fixtures additionally depend on the Windows SDK and appropriate runtime capabilities. LLVM Clang and lld-link are optional for the source-built Win64 PE export fixture.

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
python -m unittest discover -s tests -v
```

Run offline PE checks without executing the inspected image:

```sh
# Linux/macOS-style executable path for the portable inspector
./build/pe_intake /path/to/authorized-sample.exe --compact
```

On Windows, use the generated pe_intake.exe (typically build/Release/pe_intake.exe for a multi-configuration generator). See the [PE tools guide](docs/NATIVE_PE_TOOLS.md) for explicit input manifests and failure semantics.

The new PE tools were manually verified on 2026-11-24 with strict GNU C++17 compilation, four independent integration checks and 23 Python unit tests. Previously merged Windows/Linux fixture evidence is retained in dated technical reports. The current revision has not been certified by a new Windows CI run. Automatic GitHub Actions are disabled by the repository owner; use local, on-demand tests.

## Documentation

- [Public scope and provenance](docs/PUBLIC_SCOPE.md)
- [Architecture](docs/ARCHITECTURE.md), [target](docs/NATIVE_TARGET.md) and [roadmap](docs/ROADMAP.md)
- [Current verified development state](docs/STATE.md)
- [Native PE tools](docs/NATIVE_PE_TOOLS.md)
- [Source and license review](docs/SOURCES.md)
- [Contribution policy](CONTRIBUTING.md) and [security](SECURITY.md)

## License and boundaries

Original project code is MIT-licensed. Vendored dependencies retain their own licenses; check each third-party notice before reuse. No proprietary games, executable images, SDK binaries, game assets, cryptographic keys, or access-control bypasses belong in the repository.

This is an independent research project, not affiliated with Microsoft or any game publisher. Earlier development records included title-specific feasibility and planning discussions. They remain preserved in [the historical repository revision](https://github.com/ProhorovIlja/NativeX-Runtime/tree/14a8806993bcd73887c63c5261ae4d62598f759b); the current public scope is the independently testable infrastructure. This restructuring does not alter historical evidence or establish legal authorization for private experiments.

Only use external materials you are authorized to access and analyze. Do not submit proprietary inputs or private information in issues, pull requests or commits.
