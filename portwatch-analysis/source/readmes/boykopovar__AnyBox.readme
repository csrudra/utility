# About

AnyBox is a compatibility layer for running Xbox Series X|S executables natively on Windows. Part of [AnyPS5](https://github.com/boykopovar/AnyPS5) ecosystem. AnyBox uses the [RDNA shader recompiler from AnyPS5 core](https://github.com/boykopovar/AnyPS5/tree/main/core/shader/recompiler), built from a pinned submodule with AnyBox platform and storage adapters.

## Status

Xbox shader pipeline integration is in development. Even the test app does not render a frame yet. It currently reaches graphics initialization and compute pipeline creation.
Work on full shader support now.

Seven system libraries have been created. Implementations exist for 37 exported functions; three exports remain stubs. Some implemented functions still have unsupported modes. Launch has been tested with the test app's executable.

Unimplemented functions throw a C++ exception. Cross-library stack unwinding and destructor execution are verified by tests. The test app reaches an unimplemented function and terminates with an unhandled MSVC-compatible C++ exception; its call stack is visible in the debugger. Destructor execution during unwinding through the test app's code has not been verified.

## Building

AnyBox uses standard C++20 and can be built with any conforming compiler targeting 64-bit Windows. MSVC or `clang-cl` with the MSVC runtime is recommended for ABI compatibility and correct stack unwinding of diagnostic C++ exceptions through test app code.

Initialize dependencies with `git submodule update --init --recursive` before configuring CMake. Third-party libraries require a C compiler from the same toolchain as the C++ compiler.

The D3D12 backend uses Microsoft Agility SDK 1.614.1. CMake downloads the runtime package into `build/deps/agility`, verifies its checksums and copies the runtime beside the built libraries.

Unmodified executables require Windows Developer Mode for process-local SDK activation. Executables exporting SDK version 614 and a relative SDK path use that configuration directly.

`ANYBOX_REQUIRE_D3D12_VALIDATION=ON` enables the graphics validation test. It requires the Windows graphics debug tools, including `DXGIDebug.dll`. `ANYBOX_DXGI_DEBUG_LIBRARY` optionally supplies an application-local copy of that library.

## Disclaimer

The project is intended for interoperability, research and preservation. Application executables and data, firmware, cryptographic keys and proprietary console SDK libraries are not distributed with the project.

Users must supply their own application executables and data.

AnyBox is an independent project and is not affiliated with, authorized or endorsed by Microsoft. Xbox is a trademark of Microsoft Corporation.

## License

This project is licensed under the [GNU General Public License version 2 only](LICENSE).
