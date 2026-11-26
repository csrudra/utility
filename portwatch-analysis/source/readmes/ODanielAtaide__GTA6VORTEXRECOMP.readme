# Vortex

**Open-source Xbox Series compatibility research for Windows x64, written primarily in Rust.**

[![Windows CI](https://github.com/ODanielAtaide/GTA6VORTEXRECOMP/actions/workflows/ci.yml/badge.svg)](https://github.com/ODanielAtaide/GTA6VORTEXRECOMP/actions/workflows/ci.yml) [![License: GPL-3.0-or-later](https://img.shields.io/badge/license-GPL--3.0--or--later-blue)](LICENSE)

Vortex is an experimental compatibility layer investigating native x86-64 execution, high-level runtime services, Direct3D 12 graphics translation, shader recompilation and hardware compatibility. Our initial performance research target is **30 FPS with correct rendering**, not simply a higher frame counter. This is not a complete recompilation or an official PC port of any commercial game.

Based on [VIctory](https://github.com/Marvisak/VIctory) by Marvisak and contributors and [victory-gta6](https://github.com/fxceless/victory-gta6). Their public source history, authorship and GPL-3.0-or-later licensing are preserved. See [upstream credits](docs/UPSTREAM_CREDITS.md) and [BCPack table provenance](docs/BCPACK_PROVENANCE.md).

[Português (Brasil)](docs/README.pt-BR.md) · [Development report](docs/DEVELOPMENT_STATUS.md) · [Roadmap](docs/ROADMAP.md) · [Contributing](CONTRIBUTING.md) · [Benchmarks](docs/BENCHMARKS.md)

## Current status — November 24, 2026

| Milestone | Status |
|---|---|
| Editable source workspace and preserved upstream ancestry | Complete |
| Windows release compilation | Passed on maintainer's machine |
| Initial local regression suite | 354 successful test invocations, including one synthetic benchmark |
| Experimental local runtime observation | Maintainer reported menu and entry into a 3D scene |
| Menu performance | 30.0 FPS in captured telemetry |
| Complex 3D scene | Approximately 0.8–1.0 FPS in captured telemetry |
| Correct rendering and stable gameplay | Not established |
| 30 FPS in complex 3D scenes | Research target, not achieved |

These are preliminary observations on a single machine (Intel Core i5-9400, Radeon RX 6600 XT 8 GB, 16 GB RAM). They are not an independently reproduced compatibility claim, and the source/provenance of the workload has not been independently verified. Only original or otherwise authorized workloads should be used for reproducible testing. No proprietary executable, assets, private logs or title-specific binary data are provided in this report.

## What we are working on

- Reducing CPU/GPU synchronization stalls and unnecessary memory transfers.
- Improving shader translation, graphics pipeline readiness and rendering correctness.
- Efficient texture scheduling, cache publication and resource lifetime management.
- Reproducible profiling and regression tests for different GPUs and CPU architectures.

The [development report](docs/DEVELOPMENT_STATUS.md) records actual changes, measured observations and remaining uncertainties. A faster frame with missing rendering work is not a valid optimization.

## Build and test

Windows x64, the pinned Rust toolchain, MSVC build tools and Windows SDK are required.

```powershell
cargo test --workspace --locked
cargo build --release -p vortex --locked
.\target\release\vortex.exe --help
```

Optional experimental performance profile:

```powershell
cargo build --profile performance -p vortex --locked
```

Internal crates, log targets, root marker, configuration and environment variables use the Vortex namespace. Set VORTEX_* variables and use vortex.toml. The default local cache and data directory is now named vortex; existing user data is not automatically moved. Use the [benchmark instructions](docs/BENCHMARKS.md) for authorized or original workloads. No FPS improvement from the performance profile is claimed without a controlled measurement.

## Join the project

Contributors are welcome: Rust developers, graphics engineers, D3D12 and GPU specialists, shader compiler experts, Windows runtime engineers, test authors and technical writers. You do not need a commercial game to contribute. Small, independently reproducible fixes are valuable.

Start with [CONTRIBUTING.md](CONTRIBUTING.md), the [roadmap](docs/ROADMAP.md), or [open an issue](https://github.com/ODanielAtaide/GTA6VORTEXRECOMP/issues/new) to propose a focused improvement. Please preserve rendering correctness, include tests and disclose known limitations.

## Technology and project credits

The runtime, loader, graphics backend and shader compiler are written in **Rust**. Python is used only for auxiliary inspection, telemetry and regression tools. At the November 24, 2026 source snapshot, the repository held 139 Rust files (4,175,366 bytes) and six Python files (9,299 bytes): approximately 99.78% Rust by combined Rust/Python source bytes.

**Vortex maintainer and project lead:** [@ODanielAtaide](https://github.com/ODanielAtaide). The project-specific work and inherited upstream contributions are documented separately in [AUTHORS.md](AUTHORS.md). GitHub's automatic contributor graph also includes authors of the imported Git history; their appearance does not establish direct participation in Vortex.

This independent research project is not affiliated with or endorsed by Microsoft, Xbox, Rockstar Games or Take-Two Interactive. Do not upload unauthorized proprietary material or distribute commercial game files. See [LICENSE](LICENSE) and the separate [BCPack provenance](docs/BCPACK_PROVENANCE.md).
