# Dekubi-Ally-X

Xbox Series X|S compatibility layer for Windows.

The goal: run Xbox Series X|S (GDK) titles natively on a Windows PC from game
files the user owns and supplies. No CPU emulation: the title's x86-64 code
runs in our process, Dekubi-Ally-X provides the console platform underneath it
(system libraries, runtime services, file and package access, input, audio)
and translates the console GPU work (D3D12.X, RDNA2 shaders) to host
Direct3D 12 / DXIL.

## Status (2026-11-25)

Skeleton. A Cargo workspace with one library (`crates/ally-core`) and one
binary (`apps/dekubi-ally`) that prints its version. No compatibility code
yet.

## Requirements

- Windows 10/11 x64, CPU with AVX2
- Direct3D 12 GPU with shader model 6.6 (mesh shaders for 3D worlds)
- Rust, `x86_64-pc-windows-msvc`, MSVC C++ build tools
- Your own, legally obtained, unpacked game files

## Build

```powershell
cargo build --release -p dekubi-ally
cargo test --workspace
```

The first `cargo` command fetches the toolchain pinned in
`rust-toolchain.toml`. Install Rust with `winget install --id Rustlang.Rustup -e`.

## Layout

| Path | What |
|------|------|
| `crates/` | Libraries (`ally-core`, later loader, runtime, GPU, shaders) |
| `apps/dekubi-ally/` | Command-line front end |
| `docs/` | Topic docs (`docs/INDEX.md`) |
| `.github/` | CI, templates |

## Game files

This repository contains no game files, no console SDK code, headers or
binaries, and no keys. It does not download, decrypt or unpack game packages
and contains nothing for circumventing DRM. Keep game folders, caches, dumps
and saves outside the repository. Never commit them.

## Credits

Dekubi-Ally-X builds on prior open-source work in this space. Their authors
gave permission to reuse their code; each project's license still applies.

| Project | Author | License | Notes |
|---------|--------|---------|-------|
| [VIctory](https://github.com/Marvisak/VIctory) | Marvisak and contributors | GPL-3.0-or-later | Base loader, runtime services, D3D12 back end, shader recompiler |
| [victory-fork](https://github.com/fxceless/victory-fork) | fxceless | GPL-3.0-or-later | World rendering, lighting, relay/VRAM fixes |
| [VItoriaBr](https://github.com/uiliannn/VItoriaBr) | uiliannn | GPL-3.0-or-later | Continuation of VIctory + victory-fork |
| [ztrx](https://github.com/Zettrox/ztrx) | Zettrox | GPL-3.0-or-later | VIctory-based, NVIDIA-focused |
| [XCL](https://github.com/xcl-dev/xcl) | xcl-dev / ivall and contributors | GPL-2.0-only | Reference only, see below |

XCL is GPL-2.0-only, which cannot be combined with GPL-3.0 code. Use it as a
behavioural reference; reimplement ideas in this codebase rather than copying
its code, unless its authors relicense the specific code.

Agent doc layout (`CLAUDE.md`, `.claude/`, `docs/INDEX.md`, `.claudeignore`)
adapted from [claude-token-optimizer](https://github.com/nadimtuhin/claude-token-optimizer)
by Nadim Tuhin (MIT).

Not affiliated with or endorsed by Microsoft or any game developer or
publisher.

## License

GPL-3.0 (see [LICENSE](LICENSE)).
