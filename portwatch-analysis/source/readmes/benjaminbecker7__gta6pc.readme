# xse

An early-stage compatibility layer for Xbox Series X|S-style executables.

Series X|S titles are 64-bit x86 programs in the Windows PE format, so the approach is
the one Wine takes rather than CPU emulation: load the program, run its code natively,
and supply host implementations of the system libraries it calls.

## Status

**This does not run any commercial Xbox game, and is nowhere near doing so.**
What works today:

- Loading PE32+ x86-64 images, with base relocation and per-section page protection.
- Binding imports to host implementations (about 20 basic Win32 calls: console output,
  heap, virtual memory, timing).
- A trap for every unimplemented import that names the call and exits with status 70,
  so each missing piece is identified the moment a program reaches it.
- A minimal thread environment block reachable through the GS register (Linux only).

It runs small freestanding test programs built from `tests/`.

## Build and test

Requires a C compiler; the tests also need `clang`, `lld-link`, `llvm-dlltool` and
`llvm-readobj`.

    make
    make test
    build/xse [-v] program.exe

Developed and tested on x86-64 Linux. The Makefile builds an x86-64 binary on macOS
(running under Rosetta 2 on Apple Silicon), but **the macOS build has never been
compiled or run**. One known problem there: macOS reserves the GS register for its own
thread-local storage, so programs that read the thread environment block directly will
not work until that is solved.

## What is missing

Roughly in dependency order:

1. Threads, synchronisation, file I/O, and the C runtime start-up path.
2. Structured exception handling and thread-local storage directories.
3. The Xbox game runtime (`xgameruntime.dll`: user, input, storage, networking).
4. Graphics: translating the Xbox flavour of Direct3D 12 to Metal or Vulkan. This is
   the largest single piece of work.
5. Audio.
6. The guest thread environment block on macOS.

## Scope and legal boundaries

- No Microsoft code, firmware or keys are used or accepted into this repository.
- Retail games are distributed encrypted. This project does not decrypt them, does not
  extract keys from a console, and will not add code that does. In practice that means
  it can only ever run programs you built yourself or that are distributed unencrypted.
