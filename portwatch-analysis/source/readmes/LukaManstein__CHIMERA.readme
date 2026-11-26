<p align="center">
  <img src="docs/assets/chimera-banner.svg" alt="CHIMERA" width="100%">
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: GPL-3.0-or-later" src="https://img.shields.io/badge/license-GPL--3.0--or--later-7a5cff"></a>
  <img alt="Language: Rust" src="https://img.shields.io/badge/rust-stable-ff9a3c">
  <img alt="Platform: Windows 10/11" src="https://img.shields.io/badge/windows-10%20%7C%2011-ff4d8d">
  <img alt="Status: work in progress" src="https://img.shields.io/badge/status-work%20in%20progress-555">
</p>

**CHIMERA** runs an Xbox Series title natively on Windows, from files you
supply yourself. It is built on
[victory-perf](https://github.com/vitutu1/victory-perf) — the fastest public
fork of [VIctory](https://github.com/Marvisak/VIctory) /
[victory-fork](https://github.com/fxceless/victory-fork) — and adds
**Windows 10 support**, **stability fixes** and **faster memory copies**
gathered from across the community, plus its own audio work. The name is the
point: it is stitched together from the best parts of many people's work.

> **This repository contains no game files, keys, code or assets of the title,
> and never links to any.** You need your own copy. CHIMERA is not affiliated
> with or endorsed by the title's developer or publisher, or by Microsoft.
> There is no download of a ready-to-play build — anything offering one is a scam.

---

## How to run it

| Your graphics card | Take |
|---|---|
| **NVIDIA** RTX 20xx–50xx | **CHIMERA (NVIDIA)** — the installer below; it uses the tested `stable-nvidia-…` releases |
| NVIDIA, newest work | branch `next-nvidia` |
| **AMD** Radeon | not tested on CHIMERA yet — see [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD) |

**Installer + desktop shortcut** (PowerShell, not as administrator):

```powershell
irm https://raw.githubusercontent.com/LukaManstein/CHIMERA/turbo-next/scripts/install.ps1 | iex
```

It installs what is missing (Git, Rust, the C++ build tools), builds CHIMERA, asks for the folder of your own copy
of the title, translates the shaders and puts **CHIMERA (NVIDIA)** on the desktop. Every start checks for a newer
`stable-nvidia` release and asks before updating.

**Step by step: [docs/CHIMERA.md on branch `turbo-next`](https://github.com/LukaManstein/CHIMERA/blob/turbo-next/docs/CHIMERA.md)** — what you need, build, shader warm-up, play, keyboard, troubleshooting. In short:

```bat
git clone --branch turbo-next https://github.com/LukaManstein/CHIMERA.git
cd CHIMERA
cargo build --release -p victory
cargo xtask agility
set GAME=D:\path	o\your	itle-folder
scripts\chimera-turbo.cmd warm
scripts\chimera-turbo.cmd
```

## Newest: branch `next-nvidia` / `turbo-next` (2026-11-26)

**Measured on a 2018 CPU: median 4.9 fps on the first boat mission at ~6,200 draws a frame**
(p90 5.5, peaks 6.2–7.5), an 18-minute session with no crash or device removal, sound without crackles.
The PC: **AMD Ryzen 7 2700** (8 cores, Zen+, 2018), DDR4 at 2400, 32 GB RAM, **NVIDIA RTX 3080 Ti**,
Windows 10 LTSC; Series X profile, 1280×720, every switch in `scripts/chimera-turbo.cmd`.
Same mission and PC on `turbo` (2026-11-25): median 3.9 fps at ~3,600 draws.
All numbers are the layer's own frame lines (`VICTORY_FRAME_LOG=1`), the first quarter of each session left out.

What is new since `turbo`:

| Change | From | Effect here |
|---|---|---|
| Upload fills copied on several threads (`VICTORY_WIDE_FILL`), thin LTO | LukaManstein (LTO: Key) | city 2.4–3.1 → 4.3–5.1 fps |
| Late-written placed textures uploaded again (`VICTORY_PAGE_WRITES=slots`), table buffers (`VICTORY_TABLE_BUFFERS`) | [VItoriaBr](https://github.com/uiliannn/VItoriaBr) v19 (uiliannn, ports from myokex/victory-amd) | **skin and ground textures are back** (were black) |
| Rays miss while no structure is built (`VICTORY_BVH_MISS`) | [Geckomacabre/vx-layer](https://github.com/Geckomacabre/vx-layer) `bdef933`, after Flamingo | shadowed areas lit by the sky instead of black |
| Water texture copy-back with allocation tickets (`VICTORY_TEXTURE_BACK=1`) | [fxceless/victory-fork](https://github.com/fxceless/victory-fork) PR #999 (cxy0072019-sketch, after Geckomacabre) | the boat floats |
| XMA decoder thread at time-critical priority (`VICTORY_XMA_PRIORITY`) | LukaManstein | **audio crackles gone** with 12 pipeline workers busy |
| Card room released after 20 s idle, texture read-back skips XOR layouts, own copies of misaligned raw views | LukaManstein | black textures on 12 GB cards fixed |
| `VICTORY_WRITE_STATS`, `VICTORY_WIDE_HEAP`, `VICTORY_SKIP_PIPELINES` in release builds | LukaManstein | measuring tools: copy-back is mostly character skinning (needed), the heap mirror on threads gave no measurable gain |

Known wrong in this build: horizontal stripes on sunlit characters and seats (the adaptive shadow-ray compute
pass is one of the 196 shaders that do not translate yet; a fix is being integrated), a checker pattern on
some boat hulls, the sun disc drawn black when looked at, dark water when facing the sun.

### Compared with the top of the [PortWatch](https://portwatch-vi.xyz) board

Each team's own numbers, **each on its own PC** (not measured here). The layer is bound by the CPU and memory
copies, not the graphics card, so the CPU matters most when comparing.

| Build | Frame rate in the world | CPU | GPU | Code |
|---|---|---|---|---|
| **CHIMERA `next-nvidia`** | **4.9 fps median** on the boat mission, ~6,200 draws | Ryzen 7 2700 (2018) | RTX 3080 Ti | open, GPL |
| [AvatarManz](https://github.com/avatarmanz/VIctory-7900XTX) | ~16 average (PortWatch), 19–22 on the boat mission (README) | i9-12900K | RX 7900 XTX | open, GPL |
| [Belobug](https://github.com/Belobug/VIctory-Belobug-AMD) | ~4 fps (PortWatch) | Ryzen 7 9800X3D | RX 9070 XT | open, GPL |
| [VItoriaBr](https://github.com/uiliannn/VItoriaBr) | up to 4 on stream (PortWatch), 5.8 in 4K (README) | not stated | RTX 5060 Ti | open, GPL |
| [LNX-victory](https://github.com/Linox-IDK/LNX-victory) | 3.3–4.6 (Series X), 7–8 (Series S + FSR) | not stated | RTX 5060 Ti 8 GB | open, GPL |
| darkworldhm | 12–15, 5 to 24 (stream) | not stated | not stated | closed |

AvatarManz is clearly ahead: it records the title's list calls and translates them on eight threads of its own
(`VICTORY_THIN`). It is being built and measured on this PC next; if it holds up on an NVIDIA card, CHIMERA
will move onto it and keep its own Windows 10, audio, texture and launcher work on top.

## Branch `turbo`

> **2026-11-25: playable (slowly) — the boat chase of "Gone Fishing" played through** — the boat floats and is driven from the handover
> to Jason on foot at the camp, in a 31-minute session without a crash, on an RTX 3080 Ti under **Windows 10**
> (median 3.9 fps in the mission; [recording](https://vimeo.com/share/28c69e71-0bed-4f73-8a9e-d9b476d70db8)). The boat fix is
> [Geckomacabre/vx-layer `eee5667d`](https://github.com/Geckomacabre/vx-layer/commit/eee5667d7119bc4a378214621e1b18a814ebe80f)
> (textures shaders write that the CPU reads are copied back to title memory), cherry-picked into `turbo`;
> how the bug was narrowed down is on [fxceless/victory-fork#863](https://github.com/fxceless/victory-fork/issues/863).

Branch [`turbo`](https://github.com/LukaManstein/CHIMERA/tree/turbo) is CHIMERA rebuilt on the newest
[victory-fork](https://github.com/fxceless/victory-fork) (`f85101b`: async submit, copy queue for
fetches, cheap descriptor-sync fingerprint) with:

| Change | From | Why |
|---|---|---|
| 77 shader-translator fixes (signature rows, interpolation, samplers, LDS bounds, packed dot products, 64-bit image atomics) | [VItoriaBr](https://github.com/uiliannn/VItoriaBr) by uiliannn and contributors | shaders that do not translate: 254 → **208**; draws dropped per frame in the world: ~300 → **~100** |
| Constant indirect light after the probe resolve (`VICTORY_AMBIENT`, 0.6) | ported from [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD) | without ray tracing everything the sun misses was black |
| Pipeline workers: `VICTORY_PIPELINE_WORKERS`, `VICTORY_PIPELINE_NORMAL` | LukaManstein | with 8 below-normal workers and the title on every core, pipelines were built at ~1 per 2 s and half the draws were missing for minutes |
| D3D12 Agility SDK runtime | kykifox1337-source | Windows 10 |
| Texture copy-back: what shaders write into the ocean height/displacement maps reaches title memory (`eee5667d`) | Geckomacabre/vx-layer | **the boat floats**; before, it sank in the first mission for every build |
| Raw buffer views off 16 bytes get their own copy instead of a null view; water diagnostics (`VICTORY_WATCH_HASH`, `VICTORY_WHY_INDIRECT`) | LukaManstein | a lost write fixed; the boat bug narrowed down on #863 |

**Measured** (same PC as below, emulator's own frame lines, Series X, 1280×720, all switches in the branch's launcher):
a 22-minute session from the prologue into **Chapter 1** with no crash or device removal; the title wrote its story
autosave. In the world: median **3.5–3.8 fps**, 4.3–5.8 in lighter scenes, peaks of 8.4, dips to ~1.3 in heavy ones.
Shaders are translated ahead of time with `victory warm <game>\shaders.rpf` (~4 min on 16 threads); the card's pipelines
are built in the first session and kept on disk.

### Compared on this PC (NVIDIA RTX 3080 Ti, Windows 10)

The race leader [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD) (`71652a2`) built
here with only the Windows 10 Agility SDK commit added, the author's settings, same save, same machine:

| | `turbo` (CHIMERA) | Belobug (`71652a2` + Agility) |
|---|---|---|
| Shaders that do not translate for this card (of 25,889) | **208** | 559 — mostly wave64 programs on a 32-lane card |
| Pipelines the NVIDIA driver's compiler crashed on | 0 | 5 (left out) |
| Draws dropped per frame in the world | ~100 | ~1,370 of ~2,770 (pipelines still being built after 10 minutes) |
| Frame rate in the world | **3.5–4 fps** median | 1.4 fps median (~700 ms a frame) |
| What it looked like | lit, playable with keyboard/pad into Chapter 1 | nearly black, controls did not respond, the boat mission did not work either (as in ours: victory-fork #863) |

Belobug is tuned for AMD RDNA (32- and 64-lane waves) and its author reports 3–5 fps on an RX 9070 XT; this table
only says how it runs on an NVIDIA card. Its ambient-light idea is in `turbo` (`VICTORY_AMBIENT`). To make the
comparison fair it got a small `translate --warm` command (every shader into its cache ahead of the run, 434 s
on 16 threads), so neither build translated shaders during play.

## Status (main branch, victory-perf base)

Measured on **Windows 10 LTSC 21H2 · AMD Ryzen 7 2700 · NVIDIA RTX 3080 Ti 12 GB · 32 GB RAM**
(a 2018 CPU — the emulation is bound by single-thread speed and CPU↔GPU synchronisation).

| Stage | State |
|---|---|
| Boot, first-boot screens, intro, menus | works, 30 fps |
| Saves and settings | work |
| Prologue gameplay (Series X profile, 50 % render scale) | plays, **4.3–4.9 fps** once shaders are built; 3–4 fps in heavy scenes |
| Shadowed interiors | lit by stand-ins (`VICTORY_AMBIENT_STUB`, `VICTORY_SHADOWMASK_STUB`), not real ray tracing |
| First launch | slow: shaders and pipelines are built — run `scripts\precompile.cmd` first |
| Series S profile | boots; may crash while streaming the prologue's scripted scene |

For the upstream author's numbers on a faster PC (9–14 fps on a Ryzen 7 9800X3D) see
[docs/victory-perf-README.md](docs/victory-perf-README.md).

## What CHIMERA adds on top of victory-perf

| Change | From | Why |
|---|---|---|
| D3D12 Agility SDK runtime | kykifox1337-source | **Windows 10**: shader model 6.6 without Windows 11 |
| Title-memory copies in user mode, guard pages kept (`VICTORY_TITLE_COPY`, on) | TG0000 (triippywhale/victory-fork) | no system call per copy — the copies are the biggest part of a frame |
| Compute loops capped at 256, bounded direct dispatches | spacede (Emiriley/victory-fork) | no GPU driver reset (TDR) after minutes of play |
| XMA decoder at time-critical priority, decoder state carried across contexts (`VICTORY_XMA_CARRY`, on), audio stats in the log | LukaManstein | audio crackles at every stream seam |

## Requirements

- Windows 10 or 11, x64, a CPU with AVX2
- A Direct3D 12 GPU with shader model 6.6 and mesh shaders (NVIDIA RTX 20 series or newer)
- [Rust](https://rustup.rs) — the version is pinned in `rust-toolchain.toml`
- 32 GB RAM recommended. If `crashes.log` reports Windows error **1455**, enlarge the paging file.

## Build

```powershell
git clone https://github.com/LukaManstein/CHIMERA
cd CHIMERA
cargo build --release -p victory
cargo xtask agility          # Windows 10 only: puts the D3D12 runtime beside victory.exe
```

## Play

```powershell
scripts\precompile.cmd "D:\path\to\your\dump"                       # once: ~20 min, resumable
scripts\play.cmd       "D:\path\to\your\dump\<the title's exe>"     # Series X profile
scripts\play.cmd       "D:\path\to\your\dump\<the title's exe>" s   # Series S profile
```

The launcher sets the fastest known switches (below), runs windowed and writes a
log next to the repository.

Keyboard (when no pad is connected): **WASD** left stick · **IJKL** right stick ·
**arrows** D-pad · **Enter** A · **Backspace** B · **X / Y** · **Q / E** shoulders ·
**Z / C** triggers · **Esc** Menu · **Tab** View. XInput pads work as they are.

### The launcher's switches

| Variable | Effect |
|---|---|
| `VICTORY_OWN_UPSCALER=1`, `VICTORY_RENDER_SCALE=0.5` | render at half resolution through the title's own upscaler |
| `VICTORY_AMBIENT_STUB=1`, `VICTORY_SHADOWMASK_STUB=1` | light pitch-black shadowed areas with stand-ins |
| `VICTORY_RELAY=2`, `VICTORY_LATE_WAIT=3`, `VICTORY_WIDE_BACK=1` | overlap CPU and GPU work |
| `VICTORY_CARD_BUFFERS_MIN_MB=1`, `VICTORY_CARD_BUFFERS_MB=2048` | keep title buffers in video memory |
| `VICTORY_PIPELINE_WAIT_MS=100` | a frame waits at most 100 ms for a pipeline still being built (upstream waits up to 12 s) |
| `VICTORY_TITLE_COPY=0` / `VICTORY_XMA_CARRY=0` | turn CHIMERA's copy or audio change off, for comparison |

## Roadmap

- [ ] Audio without crackles — state carry is in, still being verified
- [ ] A steady 5+ fps in the world on a Ryzen 7 2700-class CPU
- [ ] GPU particle emitters the host refuses (27 compute pipelines, `E_INVALIDARG`)
- [ ] Textures that change after upload without being noticed
- [ ] Real ray-traced light and shadows

## Community

**Want to help?** Fixes and test reports from anyone are welcome: see [CONTRIBUTING.md](CONTRIBUTING.md) (fork → pull request into `next-nvidia`, or attach a `.patch` to an issue).
Bugs go to [Issues](https://github.com/LukaManstein/CHIMERA/issues) (use the form).
Never post game files, keys, executables or links to them — anywhere.

## Credits

CHIMERA is mostly other people's work, and proud of it. Every commit keeps its original author.

- **[VIctory](https://github.com/Marvisak/VIctory)** by **Marvisak** and its contributors — the loader, runtime services, Direct3D 12 back end and shader recompiler.
- **[victory-fork](https://github.com/fxceless/victory-fork)** by **fxceless** and contributors — rendering, speed and stability work that takes the title into the world.
- **[victory-perf](https://github.com/vitutu1/victory-perf)** by **vitutu1** — the copy, barrier and CPU-stall work CHIMERA is built on, and its port of modules from **[ScarlettPort](https://github.com/ZigZagBoi1/ScarlettPort)** by **ZigZagBoi1** (lighting stand-ins, merged lowering, overlay, keyboard and mouse, loader hooks).
- **TG0000** and the **[triippywhale/victory-fork](https://github.com/triippywhale/victory-fork)** collection — user-mode title copies.
- **spacede** ([Emiriley/victory-fork](https://github.com/Emiriley/victory-fork)) — the stability caps.
- **kykifox1337-source** — Windows 10 Agility SDK support; **LovettCustoms** and the Windows 10 / RTX 30 testers for the findings behind it.
- **[XCL](https://github.com/ivall/xcl)** by **ivall** — used upstream as a reference.
- Audio work and CHIMERA packaging: **LukaManstein**. Much of this family of forks was developed with [Claude Code](https://claude.com/claude-code).

## License

GPL-3.0-or-later, the same as VIctory — see [LICENSE](LICENSE). If you share a
build, you must share its source under the same license.
