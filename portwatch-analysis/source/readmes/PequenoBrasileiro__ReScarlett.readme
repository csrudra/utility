# ReScarlett.

### Bridging Xbox Scarlett and Windows.

ReScarlett is an experimental research project exploring the technical feasibility of bringing Xbox Series X|S software environments to Windows through reverse engineering, API analysis, and custom compatibility layers.

Our goal is to investigate the architectural differences between Xbox and Windows, understand platform-specific dependencies, and develop experimental solutions for compatibility.

---

## Project Overview

Xbox Series X|S software relies on platform-specific technologies, system interfaces, and development frameworks.

ReScarlett aims to investigate these technologies and explore whether a compatibility environment can be developed for Windows.

**This is an experimental engineering research project. No successful game port has been achieved.**

## Architecture

The proposed compatibility architecture is divided into independent subsystems:

| Module | Responsibility |
|---|---|
| ScarlettMemory | Memory management compatibility |
| ScarlettGraphics | Graphics API compatibility |
| ScarlettStorage | Storage and DirectStorage research |
| ScarlettAudio | Audio subsystem compatibility |
| ScarlettNetwork | Networking compatibility |
| ScarlettServices | Xbox platform service research |

## Development Roadmap

### Phase 1 — Reverse Engineering

- [x] Identify executable architecture (PE32+ x64)
- [x] Initial executable structure analysis
- [x] Identify Xbox GDK dependencies
- [ ] Complete IAT import inventory
- [ ] Classify Xbox-specific APIs
- [ ] Investigate Rockstar dependencies
- [ ] Analyze executable initialization sequence
- [ ] Document runtime dependencies

### Phase 2 — Compatibility Layer

- [ ] Map Xbox APIs to Windows equivalents
- [ ] Investigate Direct3D 12 compatibility
- [ ] Analyze Xbox memory management
- [ ] Investigate DirectStorage compatibility
- [ ] Analyze audio interfaces
- [ ] Analyze networking and platform services
- [ ] Design compatibility interfaces

### Phase 3 — Experimental Implementation

- [ ] ScarlettMemory prototype
- [ ] ScarlettGraphics prototype
- [ ] ScarlettStorage prototype
- [ ] ScarlettAudio prototype
- [ ] ScarlettNetwork prototype
- [ ] ScarlettServices prototype
- [ ] Windows compatibility testing

## Current Research

Preliminary static analysis has reported:

- PE32+ x64 executable.
- 10 PE sections.
- GUI subsystem.
- Image base: `0x140000000`.
- 655 IAT entries reported.
- Xbox GDK-related dependencies.
- DirectX 12 Xbox graphics interfaces.
- Xbox-specific storage and audio dependencies.
- Rockstar backend references.

These findings remain subject to further verification and documentation.

## Project Structure

```text
ReScarlett/
├── analysis/
│   ├── imports/
│   ├── dependencies/
│   └── executable/
├── docs/
│   ├── architecture/
│   ├── research/
│   └── compatibility/
├── src/
├── modules/
│   ├── memory/
│   ├── graphics/
│   ├── storage/
│   ├── audio/
│   ├── network/
│   └── services/
├── tests/
├── README.md
├── CONTRIBUTING.md
└── CHANGELOG.md
```

## Development Philosophy

- Preserve original binaries.
- Prefer verified technical findings over assumptions.
- Avoid fake implementations and empty API stubs.
- Develop independent and modular compatibility components.
- Document every experiment and its results.
- Keep proprietary files and assets out of the repository.

## Disclaimer

ReScarlett is an independent research project and is not affiliated with, endorsed by, or associated with Microsoft, Xbox, or Rockstar Games.

All trademarks belong to their respective owners.

This repository does not distribute proprietary executables, game assets, confidential SDKs, or copyrighted game files.

---

**ReScarlett — Exploring the boundaries between Xbox and Windows.**
