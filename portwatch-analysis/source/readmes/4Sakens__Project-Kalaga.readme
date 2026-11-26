# Project Kalaga

**One repository for running Xbox Series X|S game files on Windows — natively,
without CPU emulation.** The title's own x86-64 code runs in our process; the
console APIs it expects (`kernelx`, XGameRuntime, D3D12.X, XAudio2, …) are
answered by a compatibility runtime, and its RDNA2 shaders are recompiled to
DXIL on the PC GPU.

The project consolidates four efforts:

| Effort | Where | What it is |
|---|---|---|
| **XCL** | `D:\xcl` (upstream `ivall/xcl`) | General console runtime in Rust: kernelx, XGameRuntime, D3D12.X, XAudio2, VFS, memory, TLS, PE loader, RDNA2 → HLSL → DXIL. Retail titles playable. |
| **VIctory** | `D:\VIctory` (GTA VI fork `fxceless/victory-gta6` @ `1684989`; base upstream `Marvisak/VIctory`) | GTA VI–specific layer in Rust: formats, hooks, build identities, shader pipeline, CLI. |
| **FiveStar Recomp** | `fivestar/` (submodule) | GTA VI port in C#/.NET: formats, shader translation, loader, graphics, asset extraction. |
| **Xbox2Windows** | `xbox2windows/` (submodule) | Static-recompilation research in C++/CMake and Python; source-built CPU/GPU fixtures. |
| **Project Kalaga tooling** | `kalaga/` (this repo) | Discovery, validation, readiness, build, dependency staging, launch and diagnostics — the glue that turns the four layers into a repeatable pipeline. |

## Status (2026-11-24, measured on this machine)

Verified today on Windows 11 26300, Ryzen 5 5600X, 32 GiB, RX 7600:

| Stage | State |
|---|---|
| Game dump validation | ✅ 108/108 manifest files, 22 RPF9 archives, 208.6 GiB, title `7952987A` v1.0.2.1 |
| Build without Visual Studio | ✅ `victory.exe` (45 MB) via Rust 1.98.1 GNU + mingw-w64, 1m00s |
| Runtime boot | ✅ title mapped, virtual drive `G:` → dump, offline user, Series X mode |
| Rendering | ✅ menus at **29 fps**; prologue at **4.0–4.1 fps** native with the quality profile, **4.0–4.2 fps** best at 640×360 |
| Texture quality | ✅ **AF 16**, near-material LOD restored, native 1920×1080; sharper at the same ~4 fps |
| UI | ✅ boot screens, setup wizard, terms, start-screen art and prologue HUD captured |
| Audio | ✅ APU + DSP connected (256 streams), `audio.rpf` opened via DirectStorage |
| Input | ✅ GameInput devices enumerated; prologue prompts “Move around / Move the camera” |
| Menus | ✅ account picker → legal → setup → terms → start screen, at 29 fps |
| Opening pacing | ✅ loading phase at **60 fps for its first 60 s**, then the title's own 30 fps; no present warnings |
| Opening cutscene | ✅ plays in order, lit, with its illustrated credit cards |
| World | ✅ prologue renders characters, yard, watchtower and sky at 2.2–4.2 fps; shadowed areas are black |
| Gameplay | ✅ prologue scene and HUD; movement not actuated |
| Device stability | ✅ 0 removals in the stable 15-minute run; world entry is settings-sensitive (see the review) |

The opening's real-time loading phase is paced at 60 fps for its first 60
seconds by a small fork patch; the title's authored 30 fps resumes for the
static key art. See [docs/opening.md](docs/opening.md).

The isolated BVH test is in [docs/bvh-test.md](docs/bvh-test.md): the builder
runs all 53 pipelines but crashes the title; the quarantined variant avoids a
device removal but does not restore usable indirect light and runs at ~0 fps.

See
[docs/graphics.md](docs/graphics.md) for the black-uniform/shadow investigation: the meshes and textures are present, but
the fork's ray-traced indirect light does not run, so shadowed fabric and faces
are black. Global gamma cannot fix it without clipping the sunlit yard.

The fork and upstream review is in
[docs/upstream-review.md](docs/upstream-review.md). The focused PRs it tried
(AMD view-heap clamp, writelane, relay staging) passed their tests but made the
world a sub-1 fps texture-upload crawl, so they are not in `main`; the fork is
back at `1684989` plus the opening patch. Restoring `vSync=2` and FSR off
brought the visible prologue back at 3.4–4.0 fps. A later quality profile
(AF 16, near-material LOD 1.0, `lodScale=0.8`, `VICTORY_INPLACE_MB=4096`) held
**4.0–4.1 fps at native 1920×1080** with 0 device removals, and the materials
are visibly sharper.

The prologue is the deepest verified point. Its shadows are still black and
its frame rate is 2.2 fps at the title defaults, 4.0–4.1 fps native with the
quality profile, or 4.0–4.2 fps in the low-resolution performance
configuration. **15–30 fps was not reached**; the
remaining wall is 71–74 MB/frame of title-buffer readback plus per-record
indirect mesh draws. The rest of the world and story is untested. What *is*
working end to end is the pipeline: validate the dump → detect the machine →
build the runtime → stage DXC → launch the original executable → capture
evidence and a diagnostic report.

## Quick start

```powershell
copy kalaga.example.toml kalaga.toml     # set your paths
python -m kalaga doctor                    # hardware + toolchain
python -m kalaga validate                  # dump identity, archives, manifest
python -m kalaga plan                      # what can run, and what blocks it
python -m kalaga build                     # builds the selected runtime
python -m kalaga launch --dry-run          # exact command + env
python -m kalaga launch                    # run the title
python -m kalaga report --out report.json  # one JSON with everything
```

No Visual Studio? Set a GNU toolchain and a mingw-w64 `bin` folder:

```toml
[runtime]
target = 'x86_64-pc-windows-gnu'
toolchain = '1.98.1-x86_64-pc-windows-gnu'
toolchain_bin = 'D:\projectz-deps\mingw64\bin'
dxc_dir = 'D:\projectz-deps\dxc'
```

The current GTA VI runtime is the `fxceless/victory-gta6` fork. On AMD cards
pass the fork's pipeline skips:

```powershell
$env:VICTORY_SKIP_PIPELINES = (Get-Content docs/amd-skips.txt) -join ','
$env:VICTORY_SHADER_LOOP_LIMIT = '256'
```

See [docs/launcher.md](docs/launcher.md) for every command, config key and exit
code, [docs/architecture.md](docs/architecture.md) for how the layers fit, and
[docs/status.md](docs/status.md) for the full measurement log and next steps,
[docs/performance.md](docs/performance.md) for the frame-rate investigation,
[docs/opening.md](docs/opening.md) for the 60 fps opening window,
[docs/graphics.md](docs/graphics.md) for the black-uniform investigation,
[docs/bvh-test.md](docs/bvh-test.md) for the BVH builder/trace test,
[docs/shadow-mask-test.md](docs/shadow-mask-test.md) for the five-program
light-path test, [docs/light-passes.md](docs/light-passes.md) for the pass map
and repository updates, [docs/upstream-review.md](docs/upstream-review.md)
for the upstream/PR review, [docs/pc-test.md](docs/pc-test.md) for PC controls
(mouse-look, Esc), the loading-video fix and the frame-rate switches, and
[docs/graphics-plan.md](docs/graphics-plan.md) for the plan to fix the
lighting and graphics, and [docs/related-work.md](docs/related-work.md) for
what the other projects and forks have working.

## Repository layout

```text
ZZ-box/                       (github.com/4Sakens/Project-Kalaga)
├── kalaga/                   integration toolkit (Python, stdlib only)
├── tests/                    33 unit tests; KALAGA_REAL_GAME adds the real-dump check
├── docs/
│   ├── launcher.md           commands, configuration, troubleshooting
│   ├── architecture.md       how the pipeline composes the runtimes
│   ├── status.md             measured status, evidence, remaining work
│   ├── performance.md        FPS measurements, bottlenecks, rejected switches
│   ├── opening.md            opening pacing, 60 fps window, caveats
│   ├── graphics.md           black uniforms/shadows, deep-skips and gamma tests
│   ├── bvh-test.md           isolated BVH builder/trace test, stable untouched
│   ├── shadow-mask-test.md   five light-path programs; exact-mask + cell result
│   ├── light-passes.md       light-pass map and 2026-11-24 repository check
│   ├── upstream-review.md    forks, PRs/issues, trial integration, licences
│   ├── pc-test.md            mouse-look, Esc, loading-video fix, fps switches
│   ├── graphics-plan.md      ordered plan for the black shadows and graphics
│   ├── related-work.md       survey of the other projects and forks
│   └── integration.md        the four-effort merge plan
├── fivestar/                 FiveStar Recomp (submodule)
├── xbox2windows/             Xbox2Windows (submodule)
├── patches/                  fork patches applied to D:\VIctory
├── pyproject.toml            kalaga packaging
├── kalaga.example.toml     configuration template
└── Cargo.toml                Rust workspace stub for the grafted crates
```

The Rust sources of XCL and VIctory stay in their own checkouts for now; the
root `Cargo.toml` declares them as path dependencies so a combined build can be
added without moving code. `kalaga.toml` (machine paths) and `logs/` are
git-ignored.

## Requirements

- Windows 10/11 x64, a D3D12 GPU with shader model 6.6 (mesh shaders for the
  world), AVX2 CPU, ≥ 32 GiB RAM for GTA VI.
- Rust (the runtime pins its toolchain), and either Visual Studio Build Tools
  or a mingw-w64 toolchain for the GNU target.
- `dxcompiler.dll` + `dxil.dll` (Windows SDK, or Microsoft's standalone
  [DirectX Shader Compiler](https://github.com/microsoft/DirectXShaderCompiler)
  release) — `kalaga launch` stages them next to the executable.
- Your own copy of the game files. Nothing proprietary is stored here.

## Licensing

XCL is GPL-2.0-only; FiveStar and VIctory are GPL-3.0; Xbox2Windows is MIT; the
Project Kalaga tooling is GPL-2.0-or-later. Combining them into one distributed build
needs a licence decision — see "Open decisions" in
[docs/integration.md](docs/integration.md).

## Legal

The tools work only with game files the user already has, keep them outside the
repository, and never bypass DRM, licence checks or access controls. No game
archive, executable or copyrighted asset is stored or distributed by this
repository.
