# GTA VI on PC — coordination hub

One place to coordinate the open-source effort to run **Grand Theft Auto VI** (Xbox Series / `Scarlett` build `1.0.2.1`, RAGE 9) natively on Windows.

The work is real and fast-moving — nine independent runtime and recompilation projects, a dozen asset tools — but it is **uncoordinated**: every project re-derives the same facts, re-implements the same console shims, and measures the same GPU behaviour in a private harness. This repo owns the shared layer so the projects can spend their time on code that only they can write.

> [!IMPORTANT]
> Clean-room only. No game executables, assets, keys, or DRM tooling live here — only metadata, counts, specs, and test definitions. Bring your own copy of the files.

**Status today: nothing boots.** No open-source project runs GTA VI, and the reason is not a missing feature — it is a missing file. See below.

---

## The one fact that blocks everything

The circulating `1.0.2.1` package does **not contain the game executable**, although the package manifest names it explicitly.

| Fact | Value | Source |
| :--- | :--- | :--- |
| Declared executable | `game_scarlett_master.exe` (Id `GTAO`, `TargetDeviceFamily="Scarlett"`) | `MicrosoftGame.Config` → `ExecutableList` |
| Declared in package manifest | `<Application Id="GTAO" Executable="game_scarlett_master.exe">` | `appxmanifest.xml` |
| Executables actually present | **0** | [docs/package-inventory.md](docs/package-inventory.md) |
| Package identity | `RockstarGamesInc.28872443D20A7`, Publisher `CN=3164F9C2-…0054`, TitleId `7952987A` | `MicrosoftGame.Config` |
| Files / size | 108 files, 223,880,932,870 bytes (208.5 GiB) | [docs/package-inventory.md](docs/package-inventory.md) |

Five projects independently reached the same conclusion: `R0Y00/Xbox2Windows` ("the main executable was absent from the inspected package"), `drycheetah84/TomBox`, `omonkeyz/xbox-emulator`, `Freminet/ScarlettX` (#44), and `ItsNotRexed/Leonida` (task RT-5, #2891). This is a **provenance** problem, not a code problem, and it deserves one shared inventory rather than five private ones.

---

## Projects

<!-- STATUS:START -->
_Snapshot: 2026-11-22._

### Runtime & translation layers

| Project | Stack | Target | Licence | Status | Biggest blocker |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [ItsNotRexed/Leonida](https://github.com/ItsNotRexed/Leonida) | Python, C# | Xbox Series → Windows (Vulkan) | GPL-3.0 | All 26,503 RDNA2 shaders translated to SPIR-V; PE loader runs a stand-in executable; Xbox D3D12 → Vulkan device in progress. Does not boot. | No executable to run; Vulkan backend still lacks buffer views, root signatures, pipelines, draws, placed resources, 1D textures and swapchain. |
| [ivall/xcl](https://github.com/ivall/xcl) | Rust | Xbox Series → Windows (D3D12) | GPL-2.0-only | Console x64 code runs natively with kernelx / XGameRuntime / d3d12_xs / DirectStorage / XAudio2 shims; 24,064 shader programs translate; XDefiant, Fortnite and Minecraft reach title screens. | HANDOFF.md: little left to do without the executable. Open items: MSAA in the tiled layout, hull/domain/amplification shaders, draw-time root-arg → SGPR binding. |
| [californiaAlmonds/OpenScarlett](https://github.com/californiaAlmonds/OpenScarlett) | C++20 | Xbox Series → Windows | MIT | v0.5.0-alpha: 51/51 automated tests, official GDK samples run unmodified; 66/66 CTest; 774/779 GFX10.3 opcodes lifted. | Commercial retail Xbox Series games are not playable yet. |
| [omonkeyz/xbox-emulator](https://github.com/omonkeyz/xbox-emulator) | Rust | Xbox Series → Windows | GPL-3.0-or-later | Continuation of TomBox + rage9; reimplements d3d12_xs, RDNA2 translation, unified memory and console DLLs; Fortnite reaches its lobby. | GTA VI not run — dump has no executable. 8,749 of 8,765 mesh programs stall at first resource load (no RTS0 chunk). |
| [R0Y00/Xbox2Windows](https://github.com/R0Y00/Xbox2Windows) | C++, Python | Xbox Series → Windows | MIT | Source-built programs run entry to exit; two translated pixel shaders match hardware and WARP reference outputs; Windows CI with coverage dashboard. | Main executable absent. Coverage wall: 851/12,101 PS and 12/2,689 CS shaders actually executed. |
| [drycheetah84/TomBox](https://github.com/drycheetah84/TomBox) | Rust | Xbox Series → Windows | MIT OR Apache-2.0 (per crate, no root LICENSE) | Upstream runtime for omonkeyz/xbox-emulator; one title reaches its main menu. | No executable; ~1/3 of vertex shaders translate — mesh shaders and root-signature-less shaders are the blockers. |
| [sammwyy/xvalkyrie](https://github.com/sammwyy/xvalkyrie) | C++20 | Xbox One + Series → Windows | GPL-3.0 | Wine-style import shimming for both console generations; on Series 37/40 GDK samples draw and retail titles present frames. | Shaders carrying only the console's GPU code (no DXBC) are untranslated — exactly GTA VI's case. 1,786/2,055 retail shaders translate. |
| [Freminet/ScarlettX](https://github.com/Freminet/ScarlettX) | C++ | Xbox Series → Windows | none | Clean-room HLE: PE64 loader, DirectStorage/XVD (unencrypted), d3d12_xs → D3D12, GameInput, XGameSave, XAudio2; Concept Destruction and Unicorn Overlord playable. | RDNA2 XS2 shader lifting is 0 of 16 — and all GTA VI shaders ship as precompiled RDNA2 XS2. |
| [brcly/TuxBox](https://github.com/brcly/TuxBox) | Rust, Python | Xbox Series → Linux (Proton); Windows in progress | none | The Matrix Awakens runs from menu through the highway chase into the open city under stock Proton; publishes per-library export and shader coverage. | Windows column is pending for all 14 gates; PresentX gate fails on 3 of 4 Linux hosts; no CI and no issue tracker. |

Status and blocker columns cite each project's own docs and issues; see `data/projects.json` for the exact references.

### Asset & format tools

| Project | Stack | Licence | Focus |
| :--- | :--- | :--- | :--- |
| [TrinitronClient/GTA6-Asset-Info](https://github.com/TrinitronClient/GTA6-Asset-Info) | 17-part spec | GPL-3.0 | Byte-level RPF9, resources, textures, tiling, BCPack, models, map, interiors, vehicles, collision, navmesh, PSO, BVH4 and AWC/ADAT specs. |
| [holdmysocks/SixNG](https://github.com/holdmysocks/SixNG) | Rust | GPL-3.0 | RPF9 asset extraction to glTF, textures and map data with streaming 3D map view, LOD and shader/parameter name resolution. |
| [Ahmet-Dedeler/bcpack-rs](https://github.com/Ahmet-Dedeler/bcpack-rs) | Rust, Python | MIT OR Apache-2.0 | Standalone BCPack decoder: BC1 verified on held-out pools at 34.7/34.0 dB median; entropy layer exact for BC3/4/5/6H/7; BC7 block decode in progress. |
| [Ahmet-Dedeler/rage9-re](https://github.com/Ahmet-Dedeler/rage9-re) | Rust, Python | NOASSERTION (see repo) | script.rpf PSO script data and anim.rpf crAnimation channels decoded with glTF 2.0 export. |
<!-- STATUS:END -->

Generated from [`data/projects.json`](data/projects.json) by [`scripts/render_status.py`](scripts/render_status.py). Edit the JSON, then run the script.

---

## Coordination workstreams

These are the six things no single project can own alone. Each has a document and a tracking issue.

| # | Workstream | Problem it solves | Doc |
| :-- | :--- | :--- | :--- |
| C-1 | **Package inventory** | Five projects re-derive "which files exist"; nobody publishes a canonical manifest. | [docs/package-inventory.md](docs/package-inventory.md) |
| C-2 | **Shader census convention** | 26,503 records (Leonida, xcl, Xbox2Windows #594) vs 25,727 (TomBox #5) vs 21,522 console-cache entries. Denominators disagree, so "99% translated" is unmeasurable. | [docs/shader-census.md](docs/shader-census.md) |
| C-3 | **Root-signature-less shaders** | The same unfixed bug in four codebases: 8,749 GTA VI mesh programs carry no RTS0 chunk and stall at the first resource load. No shared memory-based root ABI fallback exists. | [docs/root-signature-fallback.md](docs/root-signature-fallback.md) |
| C-4 | **Conformance corpus** | `d3d12_xs` is reimplemented in ≥6 repos, `kernelx` in ≥5, RDNA2 lifting in 6 — each with its own GPU suite and no shared fixtures. | [docs/conformance.md](docs/conformance.md) |
| C-5 | **Licence compatibility** | `xcl` is GPL-2.0-**only**, which is one-way incompatible with GPL-3.0 `Leonida`/`xbox-emulator`; `ScarlettX`, `TuxBox`, `6stars`, `rpf9-explorer` have no licence file at all, blocking reuse. | [docs/license-matrix.md](docs/license-matrix.md) |
| C-6 | **Wave64-on-wave32 results** | Measured four times in four harnesses (Leonida #166 across 30+ GPUs; OpenScarlett 448/448 dwords; Xbox2Windows 408 BVH queries × 60 adapters; xcl 749 programs at risk). One fixture and one table would replace all four. | [docs/conformance.md](docs/conformance.md) |

---

## How to use this repo

- **Claim a workstream** or a subsystem slot by opening an issue using the templates. Skills matrix lives in [docs/owners.md](docs/owners.md); a claim is advisory, not exclusive — say what you are working on and link your commit.
- **Publish hardware results** with the hardware-report template. Those reports are what make C-6 and the GPU-vendor gaps visible.
- **Disagree with a number here?** That is the point: open an issue with your method and evidence, and the docs get corrected.

## Related

- [Awesome GTA VI Reverse Engineering](https://github.com/Ahmet-Dedeler/awesome-gta6-reverse-engineering) — the canonical index of projects and format research.
- [PortWatch VI](https://github.com/4lwayz/portwatch-vi) — daily status tracker for the PC port efforts.

## Licence

[CC0 1.0](LICENSE) for this repo's text and data. Linked projects keep their own licences.
