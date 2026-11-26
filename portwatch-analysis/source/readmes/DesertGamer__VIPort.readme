<div align="center">

# VIPort

**Grand Theft Auto VI (Xbox Series X|S), running natively on Windows, from files you supply.**<br>
An independent, community-built project on the VIctory codebase: hundreds of pull requests in one tree that builds and is tested.

![Status](https://img.shields.io/badge/status-not%20playable%20yet-orange?style=for-the-badge)
![Reaches](https://img.shields.io/badge/reaches-the%20first%20cutscene-2ea44f?style=for-the-badge)

[![Stars](https://img.shields.io/github/stars/DesertGamer/VIPort?style=flat-square&logo=github)](https://github.com/DesertGamer/VIPort/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/DesertGamer/VIPort?style=flat-square)](https://github.com/DesertGamer/VIPort/commits/main)
[![Issues](https://img.shields.io/github/issues/DesertGamer/VIPort?style=flat-square)](https://github.com/DesertGamer/VIPort/issues)
![Rust](https://img.shields.io/badge/Rust-2024-b7410e?style=flat-square&logo=rust&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078d4?style=flat-square&logo=windows&logoColor=white)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square)](LICENSE)

[![Telegram](https://img.shields.io/badge/Telegram-@desertdev-26A5E4?style=flat-square&logo=telegram&logoColor=white)](https://t.me/desertdev)
![Discord](https://img.shields.io/badge/Discord-desert__gamer-5865F2?style=flat-square&logo=discord&logoColor=white)
[![E-mail](https://img.shields.io/badge/E--mail-desert__gamer@icloud.com-3693F3?style=flat-square&logo=icloud&logoColor=white)](mailto:desert_gamer@icloud.com)

[**Progress**](#where-viport-is-today) · [**Help wanted**](#help-wanted) · [**Getting started**](#getting-started) · [**Talk to us**](#where-to-talk)

</div>

> **VIPort is built on the VIctory codebase by
> [Marvisak](https://github.com/Marvisak/VIctory) and its contributors.** It
> started as an integration fork of it and is now developed independently.
>
> VIPort is developed in the open and receives a lot of community pull
> requests (shader lowering, GPU fixes, HLE, formats, tooling). A big queue of
> them builds up faster than one maintainer can review. VIPort put those
> contributions together in one tree that builds, passes the tests, and can be
> tried today, without waiting for each one to land upstream.
>
> **VIPort is not the official VIPort project and is not endorsed by its
> author.** Its history, with every author, is kept here intact. VIPort merged
> from the original until 2026-11-25 and no longer does; the original stays a
> reference. The code is GPL-3.0, as the original.

<details>
<summary><b>На русском</b></summary>

**VIPort** — независимый проект на кодовой базе VIPort (неофициальный, GPL-3.0): запуск GTA VI (Xbox Series X|S) на Windows из ваших файлов. Игра пока не играбельна: меню и вступительное видео работают, дальше игра загружает мир и рисует его по 1–2 секунды на кадр, с дефектами. В репозитории нет игровых данных, их вы приносите сами.

Нужна помощь: отчёты по железу ([#4](https://github.com/DesertGamer/VIPort/issues/4)), небольшие задачи (список и распределение в [#29](https://github.com/DesertGamer/VIPort/issues/29)) и подсчёт сбоев DirectStorage на вашей видеокарте ([#15](https://github.com/DesertGamer/VIPort/issues/15)). Связь: Telegram [@desertdev](https://t.me/desertdev).

</details>

## What it is

Runs Grand Theft Auto VI (Xbox Series X|S) natively on Windows, from files
the user supplies.

The title's x86-64 code runs unchanged inside our process; VIPort supplies
the platform underneath it and converts the title's data, ahead of time where
it can (shaders and pipelines too, see Getting started) and on first use
otherwise. See [docs/architecture.md](docs/architecture.md).

## Where VIPort is today

**Not playable yet.** The title boots, shows its menus and intro, loads the
world and draws it: slowly, and with rendering defects. On 2026-11-26 (NVIDIA RTX 5070, warm caches) three runs of the world scene took between 0.55 and 1.4 seconds per frame; the target is 33 milliseconds. The road from here:

```mermaid
flowchart LR
    A["Boot and<br/>first-boot screens"] --> B["Intro video<br/>with sound"] --> C["Start screen,<br/>profile, saves"] --> D["Loading into<br/>the world<br/>(about 50 s)"] --> E["The world<br/>1-2 s per frame,<br/>unlit surfaces"] --> F["Playable"]
    classDef done fill:#1f883d,stroke:#1a7f37,color:#ffffff
    classDef partial fill:#bf8700,stroke:#9a6700,color:#ffffff
    classDef todo fill:#6e7781,stroke:#57606a,color:#ffffff
    class A,B,C,D done
    class E partial
    class F todo
```

Green works, amber works with visible defects, grey is not there yet. The stages
follow upstream's table of 2026-11-23 (AMD RX 6700 XT); VIPort's own runs of
2026-11-25 (NVIDIA RTX 5070) reach the first cutscene. Details, and where it
still fails, are under [Status details](#status-details-2026-11-25).

### The shaders, world scene

The title's console GPU code is recompiled to DXIL. Coverage of the world's
shaders, from the Status details tables:

```text
Mesh       ████████████████  100%     0 left of  8,765
Vertex/px  ███████████████░  99.7%   42 left of 12,592
Compute    ███████████████░  97.8%   58 left of  2,637
```

### By the numbers (tests and lines recounted 2026-11-26; the first two figures are from 2026-11-25)

| 292 | 232 | 127,700 | 978 |
|:---:|:---:|:---:|:---:|
| community pull requests merged | authors in the history | lines of Rust in 9 crates | tests pass, none fail |

### What works, what is missing

| | Subsystem | What is still missing |
|:-:|-----------|-----------------------|
| ✅ | Loader | nothing known |
| ✅ | Network | offline by design |
| 🟡 | Files and streaming | loading is limited by writes into title memory |
| 🟡 | Input | rumble is unverified in game |
| 🟡 | Audio | reverb is silent |
| 🟡 | Runtime services | the text entry dialog and relaunch are untested live |
| 🟡 | GPU: menus | frame pacing drifts on one screen in release builds |
| 🟡 | GPU: world | lighting, some geometry; frames take 1-2 s |
| 🟡 | Shaders | merged geometry stages (195 programs) and about 100 others |
| 🟡 | Textures | render-target metadata planes |
| 🟡 | Series S mode | the world |

✅ nothing known missing, 🟡 works with the gaps listed. The full table is under
Status details.

## Help wanted

VIPort moves as fast as people help it. Small tasks are the quickest way in:

| You have | You can | Where |
|----------|---------|-------|
| a Windows PC with a GPU and your own game files | run it and report how far it got | [#4](https://github.com/DesertGamer/VIPort/issues/4) |
| the same, and two minutes | count the DirectStorage failures on your GPU (zero is a useful answer) | [#15](https://github.com/DesertGamer/VIPort/issues/15) |
| a Windows PC and Rust, or a GPU of any vendor | pick a task (performance, shader translation, hardware reports, tests, docs), claim it and send a pull request | [#29](https://github.com/DesertGamer/VIPort/issues/29) |

Every issue has the exact failure and what "done" looks like (label
`help wanted`). Authorship stays: every merged pull request keeps its author in
the history.

## What VIPort changes

- **Community pull requests, merged.** Open upstream PRs were merged into VIPort in
  batches until 2026-11-25. The authors of the original commits stay the authors
  in the history.
- **Reviewed before merging.** Every PR is checked first for things that do not
  belong in a code change: binary files and archives, build scripts
  (`build.rs`), git hooks, `.cargo` configuration, shell/PowerShell/batch
  scripts, downloads, and new dependencies. PRs with such content are not taken
  without a manual read of the diff.
- **Tested after every batch.** `cargo test --workspace` runs after each batch.
  If a batch fails, the PR that caused it is found and dealt with before
  anything else is merged.
- **Conflicts are resolved, not hidden.** When two PRs are fine alone but
  contradict each other (they change the same behaviour in different ways),
  VIPort keeps one and records why in the commit message of the change that
  removes the other.

## What VIPort does not do

- It does not contain, and will never contain, any game data. The asset policy
  from upstream applies unchanged: see
  [docs/asset-policy.md](docs/asset-policy.md). You supply your own files.
- It does not promise that the game is playable. See *Status* below.

## Where to talk

- [#1: entering the world fails with a GPU device removed](https://github.com/DesertGamer/VIPort/issues/1): the main blocker; post diagnostics and findings here.
- [#2: what is merged and what is not](https://github.com/DesertGamer/VIPort/issues/2): the list of merged bundles and of those that still need a hand merge.
- [#3: single upstream pull requests](https://github.com/DesertGamer/VIPort/issues/3): how to take one and how to report a clash.
- [#4: hardware reports](https://github.com/DesertGamer/VIPort/issues/4): how far it gets on your machine.

Outside GitHub: Telegram `desertdev`, Discord `desert_gamer`, e-mail
desert_gamer@icloud.com.

## Contributing, security, upstream

- How to contribute: [CONTRIBUTING.md](CONTRIBUTING.md).
- Found a security problem: [SECURITY.md](SECURITY.md). This code runs inside a
  process with your user's rights, so please read it before reporting in public.
- VIPort no longer merges from the upstream repository. Upstream stays a
  reference: its pull requests, discussions and issues. A fix that is useful to
  everyone belongs upstream too: if you send a change to VIPort, consider
  sending it to the original project as well.

## Status details (2026-11-25)

**Not playable yet.** The title boots, runs its menus at its own 30 fps,
loads the world and shows it: slowly, and with rendering defects.

VIPort, 2026-11-25, on Windows 11 with an NVIDIA RTX 5070: the title no longer
loses the host GPU at start. Two fixes made that so: textures in formats the
GPU refuses to render to or write (B4G4R4A4, B5G5R5A1) are created without
those uses, and typed unordered views are made only in formats the GPU can
store to. The start sequence, the intro splash included, then runs smoothly.
Trouble begins when the first cutscene starts: it stutters, and a run can end
with the host GPU removed after a single submission that took about 5
seconds, longer than the Windows driver watchdog allows. In a release run the
frame counter read 16 to 30 fps, and 127 shaders were translated at first use
(70 seconds in all, the slowest 13 seconds); a run with the shader cache warm
has not been measured yet. VIPort makes no claim that it renders more than
upstream; that needs a measurement under the same conditions.

The tables below are upstream's findings of 2026-11-23; VIPort has not
re-measured them.

| Stage | State |
|-------|-------|
| Boot, first-boot screens (accessibility, language, settings, legal) | works, 30 fps |
| Intro video with sound | works |
| Start screen, profile and saves | works |
| Loading into the world (about 50 s) | works |
| The world (first mission's intro) | drawn and shown: streets, buildings, vehicles, characters, the title card and credits; 1-2 s per frame. Surfaces are unlit, a band of distant geometry is missing, characters come out broken in some shots |

Upstream's table was measured on Windows 11 with an AMD RX 6700 XT; VIPort's
notes above on Windows 11 with an NVIDIA RTX 5070.

> **Warning.** Entering the world on a real GPU has hung it in earlier
> builds, and Windows then resets the display driver (every monitor goes
> black for a moment). The latest runs did not, but it is not ruled out; a
> run can also end on a GPU fault (`crashes.log`). A diagnostics build with
> `VIPORT_D3D12_WARP=1` renders on the software adapter instead (too slow
> to reach the world in minutes).
> A world frame can also outlast Windows' 2 s GPU timeout on slower GPUs
> (`slow host submission` above 2000 ms, then the device is removed as hung);
> raising `TdrDelay` and `TdrDdiDelay` (for example to 60) under
> `HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers` and rebooting
> avoids that reset.

What each part does today and what it still needs:

| Subsystem | Today | Needs |
|-----------|-------|-------|
| Loader | Runs the title's executable and its DLLs in our process; crash reports name the faulting code and are kept in `crashes.log` | – |
| Runtime services | One signed-in offline user, licences, packages, saves that survive a kill at any step, text entry dialog | Narration plays through the host's SAPI voice, silence when there is none; the dialog and relaunch are untested live |
| Network | Offline by design: the title cannot reach the network | – |
| Files and streaming | Archives and streamed data read, zlib and BCPack decoded in parallel | Loading is limited by writes into title memory |
| Input | XInput pads, keyboard, keyboard stand-in pad, rumble | Rumble unverified in game |
| Audio | Menu, video and loading sound; XMA voices and Opus streams decode | Reverb is silent; Opus results unverified against the title |
| GPU: menus | Draws, compute and presentation on host D3D12; only changed title memory is copied | Frame pacing drifts on one screen in release builds |
| GPU: world | The scene is drawn and presented: mesh pipelines, indirect execution, views the shaders pick from the heap themselves, title memory read by address (ray-tracing structures), depth written from compute, pipelines pre-built or made by worker threads and kept on disk | Lighting (surfaces are unlit) and some missing geometry; frames take 1-2 s; draws of untranslated shaders are dropped; real queries, depth bounds, HDR and scaling are missing |
| Shaders | Console GPU code recompiled to DXIL, ahead of time (`translate --cache`) or at first use, cached on disk. Menus: all. World: mesh 8,765 of 8,765, vertex/pixel 12,550 of 12,592, compute 2,579 of 2,637 | Merged geometry stages (195 programs) and about 100 others; fused multiply-adds follow the host GPU; compute programs that use wave operations and need 64-lane waves need a GPU with them, and so do mesh programs written for 64-lane waves (32-lane GPUs skip those draws) |
| Textures | Console tiled layouts and detiling for the modes the title uses | Render-target metadata planes |
| Series S mode | Runs through the menus to the loading screen | The world, as above |

## Getting started

Requirements: Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with
shader model 6.6 (and mesh shaders for the world), Rust (pinned in
`rust-toolchain.toml`).

For a dated summary of Windows 10 runtime and GPU feature caveats, see
[Windows and GPU support](docs/windows-and-gpu-support.md).

To install Rust, use rustup (`winget install --id Rustlang.Rustup -e`, or
the installer from https://rustup.rs). The first `cargo` command in this
repository then fetches the pinned toolchain. Building needs the MSVC C++
build tools: Visual Studio or its Build Tools with the "Desktop development
with C++" workload.

The title also needs several GiB of available Windows commit at startup.
Check **Committed** under **Task Manager → Performance → Memory**. If
`crashes.log` reports Windows error 1455, close other applications or increase
the Windows paging file size, then retry.

Keep the game folder on an SSD if you can. From a hard drive the first
screen stays black, at 30 fps and about 3 draws/frame, for a minute and a
half or more while the title reads its files: the drive stays 100% busy with
small random reads, and nothing shows until they finish. Wait for it rather
than closing the window. A later launch is faster while Windows still holds
the files in its cache.

```powershell
cargo xtask install-hooks                # asset-policy check on every commit
copy viport.example.toml viport.toml   # then set your paths (outside the repo)
cargo test --workspace -- --test-threads=1 # serializes D3D12 tests; no game data
cargo run -p viport -- config           # check your paths
```

The shader tests' GPU checks run on the default adapter and WARP. On a machine
with two GPUs, `$env:VIPORT_ADAPTER=1` runs them on the second (DXGI's
adapter order, 0 being the default); the first test to make a device names it.

Run the title:

```powershell
cargo build --release -p viport
target\release\viport.exe translate --cache --pipelines <game dir>\shaders.rpf <game dir>\<the title's exe> <game dir>\XboxBvhBuilder.dll <game dir>\amd_fidelityfx_upscaler_xbox.dll
target\release\viport.exe run <game dir>\<the title's exe> --execute
```

The `translate --cache` step (minutes; again after a change of the shader
translator) translates every shader the title can ask for into the cache
(about 1.3 GB), so a run does not translate them while it plays; without it
they are translated at first use, and their draws wait. With `--pipelines`
it then makes every pipeline in the title's shader pack (inside
`shaders.rpf`) into the host pipeline library (about 27,000 pipelines, 4 MB;
some 20 minutes on 16 threads, most of it the 2,700 compute ones), so a run
compiles none of those either; the library belongs to the GPU and driver it
was made on. Run again, it skips what is there in seconds; stopped
early, it keeps what it made.

Upscaling (Series S mode): the title upscales with AMD FidelityFX. To run
it with the PC build on your GPU instead of the console build, get the
[FidelityFX SDK](https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK)
and point `VIPORT_FIDELITYFX_DIR` (or `[paths].fidelityfx_dir`) at its
`Kits/FidelityFX/signedbin` folder, which holds
`amd_fidelityfx_upscaler_dx12.dll`. Without it, or if that DLL offers no
upscaler for your GPU (the log says so), the title's own DLLs run. Series X
mode uses the title's own upscaler; a diagnostics build switches it to
FidelityFX with `VIPORT_UPSCALER` and `VIPORT_FFX_SCALE` (below).

Linux (Wine or Proton) is not a supported host, but the title runs as far
as its loading screen there. The host needs an audio output device: under
Wine, install its sound driver (on Fedora `wine-pulseaudio`, which `wine`
alone does not pull in). Without one the title stops on an assert about
15 s in, and VIPort warns "the host has no audio output device".

The window caption shows the framerate. Saves, settings and `crashes.log`
are kept under the data folder (default `%LOCALAPPDATA%\viport\data`), derived
data under the cache folder.

Set `VIPORT_WINDOW_MAX=1920x1080` before launching to limit the title's
top-level window to that bounding box. Smaller windows keep their size,
larger windows keep their proportions, and the monitor's work area still
limits them. This scales the displayed image; it does not change the
console render resolution or the swap-chain buffers. With the variable
unset, window sizing is unchanged.

Input: XInput pads. With none connected the keyboard is a pad while the
title's window has focus:

| Keys | Pad |
|------|-----|
| W A S D / I J K L | left / right stick |
| arrows | D-pad |
| Enter, Backspace, X, Y | A, B, X, Y |
| Q / E, Z / C | shoulders, triggers |
| F / H | stick clicks |
| Esc, Tab | Menu, View |

## Commands

```
viport inspect <exe|dll> [--imports] [--exports]
viport census [paths...] [--missing] [--strict]
viport lib-exports <import.lib> [--list]
viport shader-info [paths...] [--verbose] [--disasm] [--effects]
viport translate [paths...] [--validate] [--pipelines] [--list] [--jobs N]
viport translate [paths...] --cache [--pipelines] [--jobs N]
viport meshdump [paths...] [--hash <16 hex>] [--isa] [--compute]
viport run <exe> [--execute] [--unimplemented trap|zero] [--strict]
            [--console series-x|series-s] [-- <title arguments>]
viport config
```

`translate --jobs N` requires a positive worker count. Omit it to use the
default worker count.

Logging: `VIPORT_LOG=viport_loader=trace,info` (a release build logs
info and above).

`meshdump` surveys the title's mesh (and with `--compute`, compute)
programs without running it: per program, the group shape (threads, LDS,
vertex/primitive caps), the `s_barrier` count, and whether a barrier sits
in a block only some lanes reach - such a barrier deadlocks a group on a
host whose wave is narrower than the console's. `--hash` limits the survey
to listed 16-hex content hashes; `--isa` also prints the decoded GFX10
instructions. Use it to check the divergent-barrier hypothesis for a hang
before touching the translator.

### Windows shader-test validator

The shader tests use `dxil.dll` to validate Shader Model 6.6 containers.
An older Windows SDK validator can load successfully but reject them with
`Unknown shader model 'ps_6_6'`. If this happens, use a current x64 validator
from [Microsoft's DirectX Shader Compiler releases](https://github.com/microsoft/DirectXShaderCompiler/releases)
or a current Windows SDK. Set its path for the test session:

```powershell
$env:VIPORT_DXIL = 'C:\tools\dxc\bin\x64\dxil.dll'
cargo test -p viport-shader --lib --locked -- --test-threads=1
```

Without this override, the validator loader selects the newest installed
Windows SDK's `bin/<version>/x64/dxil.dll`, then falls back to the DLL search
path when no SDK copy is found. This is a test/offline-validation dependency;
the translated shaders do not require it at runtime.

## Debugging

If the title presents one or two black frames and exits with `0x80000003`,
check the archive files before investigating rendering. The loader's import
report only counts bindings, so it can report zero missing imports with a
damaged archive. Check the SHA-256 of the files your run actually uses against
a known-good copy of the **same build**. For example, in PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'C:\path\to\title\anim.rpf'
```

If a hash differs, restore that file from your verified backup and rerun with
the same build of VIPort and the same options. A breakpoint can have other
causes. Include the archive verification outcome in your test report.

A release build has no debugging aids. Build them in with

```powershell
cargo build --profile diag -p viport --features diagnostics   # target\diag\viport.exe
```

The on/off switches below (`...=1`) are off when unset or set to `0`.

| Variable | Effect |
|----------|--------|
| `VIPORT_LOG=<target>=debug,...` | debug and trace output |
| `VIPORT_LOG=viport_gpu::sync_wait=trace,viport_gpu::sync_write=trace` | requested command-list memory waits and their constant-value producers at recording, submission, and storage in guest memory |
| `VIPORT_STACKS=20,60` | every thread's stack at those seconds |
| `VIPORT_WATCH=<rva>,...` | logs a title u32 when it changes |
| `VIPORT_POKE=<rva>:<byte>,...` | writes a title byte twice a second (a hang watchdog's tick, say) |
| `VIPORT_KEYS=30:Enter,35:X` | presses keys at those seconds, focus or not |
| `VIPORT_NO_HOST_PAD=1` | ignores XInput pads, so the keyboard drives the stand-in pad |
| `VIPORT_CRASH_BREAKPOINTS=1` | appends first-chance breakpoints to `crashes.log`, including ones a handler may recover from |
| `VIPORT_CRASH_SAVE=<rva>:<len>,...` | saves title memory to the cache folder on a crash |
| `VIPORT_TITLE_ASSERTS=<n>` | continues past up to `n` `int3` asserts in title code, where the first one ends the process; the check is taken as passed, so what follows it is undefined |
| `VIPORT_CAPTURE=<dir>` | saves presented frames (powers of two, or `VIPORT_CAPTURE_FRAMES=<list>`) |
| `VIPORT_DUMP_TARGETS=1` | with the two above, saves every render target of those frames |
| `VIPORT_CAPTURE_WORLD=<list>` | with `VIPORT_CAPTURE`, also saves (and with `VIPORT_DUMP_TARGETS` dumps) the frames at these offsets from the first frame that ran 500 draws (the world's first; its number depends on how fast the title loaded) |
| `VIPORT_DUMP_WRITERS=<hash>,...` | with the two above, also the textures a pipeline containing a listed shader hash writes, the first frame it runs, and for its buffers a log line (dwords changed, dwords not zero) |
| `VIPORT_PEEK=<hex address>[:<bytes>],...` | in listed frames, those bytes of title memory logged after each submission. Listed frames also log targets of 16 texels or fewer as values, each table view's view words and whether its host slot is null, the host copy of every buffer of 64 bytes or fewer a draw reads (at submission and after its list), and each 1D or 3D texture a dispatch writes, read back right after it |
| `VIPORT_D3D12_DEBUG=1` | host debug layer |
| `VIPORT_D3D12_GBV=1` | with the above, GPU-based validation (bad descriptor use reported, not faulted; slow) |
| `VIPORT_D3D12_DRED=1` | on a GPU failure, the allocation hit and the commands in flight |
| `VIPORT_SKIP_PIPELINES=<hash>,...` | omit draws and dispatches, including indirect ones, whose pipeline contains a listed 16-digit shader hash |
| `VIPORT_GPU_TIMING=1` | each list of a submission run and timed on its own; slow lists are logged, and with `VIPORT_D3D12_DRED=1` their slowest commands are named too — the per-command notes come from that switch, so `VIPORT_GPU_TIMING` alone reports `commands=0`; a device removal names the list it happened in and lists all its commands |
| `VIPORT_TRACE_SHADERS=<hash>,...` | with `VIPORT_D3D12_DRED`, every draw and dispatch of a listed shader logged with what it binds (user data, heap slots, root views and their first dwords; the first 500) |
| `VIPORT_D3D12_WARP=1` | host device on the software adapter (slow; cannot reset the driver) |
| `VIPORT_BORDERLESS=1` | removes the game window's title bar and frame (the window keeps them by default) |
| `VIPORT_LAZY_VIEWS=1` | experimental: placed buffer views of heap slots no draw or shader has read are made at their first read instead of at each submission (that first read sees a null view) |
| `VIPORT_SUBMIT_MAX_RUNS=<n>` | at most `n` command lists per host submission, so a hang or a slow frame is cut into shorter GPU jobs (`1` runs every list on its own) |
| `VIPORT_PROFILE=<ms>` | a sampling profiler of the whole process (title threads, our workers, the driver): every 5 s it logs, per thread, the CPU time and the most frequent call stacks; `<ms>` is the sampling period of busy threads (4 by default) |
| `VIPORT_PIPELINE_WORKERS=<n>` | host pipeline compile workers, 1 to 64 (default half the logical processors, 2 to 8; any build); more workers empty a first run's pipeline queue faster |
| `VIPORT_LEARN_UAV_EXTENT=1` | experimental: after 64 submissions a root buffer view of a pipeline is snapshotted and compared only up to twice the highest byte its shaders wrote (every 32nd submission checks the whole range and logs a warning if a shader wrote past the learned extent) |
| `VIPORT_AUTO_ENTER=0` | stops the automatic Enter presses (every 3 s from the 5th to the 45th second) that pass the terms screen |
| `VIPORT_MODE=<width>x<height>` | report that display mode instead of the console's 3840x2160 (smaller render targets on smaller hosts) |
| `VIPORT_PIPELINE_LOG=<file>` | a line per title pipeline created (key, shaders, state), first used, and made or loaded (library name); `translate --cache --pipelines` writes the last kind too |
| `VIPORT_PREBUILD_KEYS=<file>` | `translate --cache --pipelines` makes nothing and lists each pack record's key, shaders and state (or why it is skipped) |
| `VIPORT_MESH64_ON_32=1` | console 64-lane mesh programs that read no lane layout and order their shared memory by barriers run in host waves of 32 (own shader cache entries); a pair whose mesh program does not qualify is refused as before |
| `VIPORT_WAVE64_ON_32=1` | console 64-lane compute programs run as two 32-lane host waves: shared memory is ordered by barriers and lane operations exchange through shared memory, in code every thread of the group reaches (own shader cache entries); a program that cannot be made so keeps `WaveSize(64)` and is refused on 32-lane hosts |
| `VIPORT_SHADER_OPT=<mask>` | with `diagnostics`, which cleanup passes run over translated shaders (all by default; `0` none; own shader cache entries) |
| `VIPORT_TRANSLATE_ONLY=<prefixes>` | `translate` handles only the programs whose hash starts with one of the comma-separated prefixes |
| `VIPORT_SHADER_LOOP_LIMIT=<n>` | translated shader loops stop after `n` iterations per lane instead of 2^14 (own shader cache entries); if a lower `n` makes world frames much faster, loops hitting the limit are what makes them slow |
| `VIPORT_SHADER_DUMP=<dir>` | writes each shader container and its DXIL as `<hash>.bin` / `<hash>.dxil` when it is translated, for the hashes DRED and timing lines name (`dxc -dumpbin <hash>.dxil`) |
| `VIPORT_AUDIO_CAPTURE=<file.wav>` | records what the title plays (our process only) |
| `VIPORT_XMA_DUMP=<dir>` | saves the first 32 XMA voices' context and input |
| `VIPORT_UPSCALER=<rva>[,<kind>]` | the title's upscaler picker returns `kind` (default 7, FidelityFX; 1.0.2.1: `7E93F0`): FidelityFX in Series X mode |
| `VIPORT_FFX_SCALE=<scale>[,<rva>]` | render scale of the title's FidelityFX path (`0.6667`: 1440p for 4K, `0.5`: 1080p; 1.0.2.1 default rva `28EF680`); with the above, Series X otherwise renders native 4K and overflows its memory plan |

Every build appends unhandled exceptions, panics, and host GPU failures to
`crashes.log` in the title's data folder.

For a startup breakpoint (`0x80000003`), run the diagnostics build with
`VIPORT_CRASH_BREAKPOINTS=1`. Keep the console output along with the new
`crashes.log` entries. A host DLL refusal includes the caller stack in the
console output. The refusal is expected for DLLs outside the host policy,
including `rpcrt4.dll`.

On Series 1.0.2.1, a missing `appdata0.rpf` reproduced the breakpoint at
`+0x2237178` before the first window. Restore the archive from the same
package beside the title executable. `run --execute` checks that it can
read the RPF9 header before starting this build.

To compare hardware and software rendering, repeat with
`VIPORT_D3D12_WARP=1` and check the console for
`host device on the software adapter (WARP)` to confirm the WARP device was
created. Compare the exception's module and offset, stack frames, and
preceding messages across the two runs.

[docs/debugging-notes-from-a-gta-v-port.md](docs/debugging-notes-from-a-gta-v-port.md)
collects what got another RAGE port from "the world loads" to "the game
runs": what the title waited for, and how each wait was found.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
