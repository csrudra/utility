# HitBoy's Emulations

See the [emulation handoff](docs/EMULATION-HANDOFF.md) for console test entry points and [SOURCES.txt](SOURCES.txt) for research references.

**HitBoy's Emulations** is a from-scratch multi-system console emulator, mobile OS runner, and virtual machine suite written in **Rust** and **C++** by **HitBoyXx23**.

Performance-critical CPU cores are written in **C++** behind a clean C ABI, while buses, PPU/GPU pipelines, OS runtimes, input, save states, rewind, and the cross-platform `egui` frontend + WebAssembly browser player are written in **Rust**.

## Highlights

- **Classic & Retro Consoles (Playable)**: NES, SNES, Game Boy / GBC, Game Boy Advance, Virtual Boy, Nintendo 64, GameCube, PlayStation 1, Sega Master System, Genesis / Mega Drive, Game Gear, Atari 2600, Atari 7800, TurboGrafx-16, WonderSwan / Color, Intellivision.
- **Xbox One / Series X|S (`crates/xboxone`)**:
  - **Native Mode**: PE32+ x86-64 loader with DIR64 relocations, section protections, TLS callbacks, `.pdata` SEH unwind registration (`RtlAddFunctionTable`), Windows DLL redirection (`kernelx.dll` → `kernel32.dll`, `d3d12_x.dll`/`d3d12_xs.dll` → `d3d12.dll`, `d3d11_x.dll` → `d3d11.dll`, `xinput`/`gameinput`/`xaudio2` → real Windows audio & gamepads), and per-symbol GDK/XDK/D3D12.X shims (`XGameRuntime*`, `XSystem*`, `XTaskQueue*`, `XUser*`, `XGameSave*`, `XMemAlloc*`, `TitleMemoryStatus`, `XDisplay*`, `XThread*`, `XDeviceCreate`, `XGComputeOptimalTileMode`, `D3D12XBOX_CreateDevice`, `D3D11XCreateDeviceX`).
  - **Emulator Mode**: Clean-room sandboxed x86-64 (Zen 2 / Jaguar) user-mode CPU interpreter (including BMI1/BMI2 VEX instructions, bit-ops, shifts/rotates, multiply/divide), Era virtual memory manager (`TitleAddressSpace` with 4 KiB/64 KiB pages, page protections, GPU alias windows, and `TitleMemoryStatus`), DXBC console-chunk sanitizer, root-signature flag sanitizer, XG texture tiling layout calculator (including BC1/BC3/BC7 mips), and offscreen framebuffer bridge.
  - Supports decrypted `appxmanifest.xml` (XDK), `MicrosoftGame.config` (GDK), and Developer Mode `.msix` / `.msixbundle` / `.appx` packages.
- **Xbox & Xbox 360 (`crates/xbox`, `crates/x360`)**: Original Xbox Pentium III + NV2A boot support and Xbox 360 Xenon PowerPC `.xex` loader & kernel HLE.
- **Nintendo Switch (`crates/switch`)**: `.nsp` / `.xci` package decryption with user-supplied `prod.keys`, NCA/ExeFS/RomFS parsing, ARM64 + NEON + Crypto + LSE CPU core, Horizon OS kernel SVCs, cooperative threads, and IPC services (`sm:`, `set`, `set:sys`, `lm`, `time:u`, `apm`, `appletOE`, `hid`, etc.).
- **iOS (`crates/ios`)**: `.ipa` and `.ipsw` parsing, IM4P / `complzss` kernelcache decompression, Apple DeviceTree sanitization, ARM32/ARM64e XNU bring-up with 16 KiB 3-level MMU translation, EL1 exception vectors, and Apple S5L UART / AICv2 peripherals.
- **PlayStation 4 / 5 (`crates/ps5`)**: Decrypted ELF / SELF / `eboot.bin` loader on our x86-64 + AVX/SSE core with cooperative threads, FIOS/VFS, VideoOut framebuffer scanout, controller input, and PS4/PS5 Remote Play discovery.
- **Built-in x86 PC & Virtual Machines (`crates/pc`, `crates/cpui686`, `crates/pchw`)**: Custom Pentium-class x86 PC with HLE BIOS, VGA/VESA display, IDE/ATAPI drives, and QEMU/WHPX VM management.
- **Desktop & Browser Player**: Shared Rust UI with Console Mode, save slots, rewind, customizable keyboard/gamepad controls, and a WebAssembly player (`crates/web`).

## Workspace Layout

```text
crates/
  apps/hitboy/   HitBoy's Emulations desktop binary (Royal Purple & Royal Blue theme)
  frontend/      Shared GUI, console shell, library manager, controls, save states & rewind
  web/           WebAssembly browser player
  gamedump/      CLI tool for verifying user-owned disc/console dumps & running bring-up probes
  xboxone/       Xbox One / Series X|S Native & Emulator runtime, Era memory & GPU bridge
  xbox/ x360/    Original Xbox and Xbox 360 cores
  psx/ ps2/ ps5/ PlayStation 1, 2, 4 and 5 cores
  switch/ ios/   Nintendo Switch (ARM64/Horizon) and iOS (ARM64e/XNU) runtimes
  nes/ snes/ gb/ gba/ vb/ n64/ gc/   Nintendo classic cores
  sms/ md/ pce/ ws/ atari2600/ atari7800/ intv/   Sega, NEC, Bandai, Atari & Mattel cores
  pc/ pchw/      Built-in x86 PC and virtual machine hardware
  cpu*/          Dedicated C++ & Rust CPU cores (6502, 65816, SM83, Z80, 68k, ARM7, R3000, R5900, VR4300, Gekko, Xenon, 8086, i686)
```

## Build & Run

Requires [Rust](https://rustup.rs) and a C++17 compiler (MSVC Build Tools on Windows, Xcode Command Line Tools on macOS, or GCC/Clang on Linux).

```bash
# Run unit tests
cargo test -p xboxone -p switch -p ios -p frontend

# Run the desktop app
cargo run --release --bin hitboy

# Open a game directly
cargo run --release --bin hitboy -- path/to/game.zip

# Package desktop release + WebAssembly browser player (Windows)
.\build.ps1
```

## Legal Notice

Only use ROMs, discs, BIOS, keys, firmware, and decrypted packages dumped from hardware you legally own. No copyrighted game files, BIOS images, or encryption keys are included in this repository.

## License

MIT License — Copyright (c) 2026 HitBoyXx23. See [LICENSE](LICENSE).
