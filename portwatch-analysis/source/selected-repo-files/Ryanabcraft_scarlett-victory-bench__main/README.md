# Scarlett VIctory Bench

A fork of [DexNom/VIctory](https://github.com/DexNom/VIctory), which is itself a
community fork of [Marvisak/VIctory](https://github.com/Marvisak/VIctory): it
runs an Xbox Series executable from your own game installation and translates
its GPU work for Direct3D 12 on Windows x64.

This fork exists for one reason: **the frame the runtime produces was bound by
memory traffic, not by the GPU, and nobody had measured it.** Everything here is
a measurement, the fix that came out of it, and the ones that were tried and
made it worse (kept in the code, switched off, with the numbers in the comment
above them).

Game files, executables, saves and generated shader caches stay on your own
computer. Nothing from the game is in this repository — see
[`docs/asset-policy.md`](docs/asset-policy.md).

## What changed, and why

Measured on **Intel Core i3-10105 (4 cores / 8 threads), 32 GB DDR4, GeForce RTX
3050 8 GB, Windows 11**, inside the world, same scene. Upstream's own numbers
come from a Radeon RX 7900 XTX; this fork is the NVIDIA side of that, and the
interior lighting the upstream test report calls wrong renders here (lit
ceiling lamps, bunks, doorway not overexposed):

| | before | after |
|---|---|---|
| fps | 1.3–1.6 | **1.7–2.0** |
| ms/frame | 600–890 | **506–595** |
| CPU | 70–97 % | **46–53 %** |
| GPU (the runtime's own count) | 18–26 % | 31–47 % |
| image | materials in fallback: flat clothes, black ground | **lit and textured** |
| crashes | 0 | 0 |

The GPU sitting at 20 % with the CPU at 90 % was the tell: the submitting
thread was the bottleneck, and the frame line said where it went. The image
was the second tell, and it had a different cause — a display mode the title
had no business believing (see below).

### 1. The title was rendering at 4K into a 1080p window

`display_size()` in `crates/victory-gpu/src/dxgi.rs` reports **3840×2160** to the
title by default — the console mode, not the PC's display. Every run's log said
so:

```
INFO victory_gpu::dxgi: display mode reported to the title width=3840 height=2160
```

So the title built 4K render targets, drew 8.3 million pixels a frame, and the
runtime squeezed the result into a 1920×1080 window. The 4K targets also ate the
VRAM the textures needed (9 194 waiting).

`VICTORY_DISPLAY_MODE=1920x1080` tells it the truth. Same scene, measured:

| | 4K reported | 1080p reported |
|---|---|---|
| image | flat-shirted characters, black ground, floating cars | sunset, god rays, textured ground, plants, people in the yard, glass with reflection |
| GPU busy | 30–50 % | **21–27 %** |
| GPU wait | 122–410 ms | **122–256 ms** |
| ms/frame | 588–760 | **573–650** |

The bigger win is the image and the ceiling, not the frame rate: with the GPU at
21–27 % and the CPU at 47 %, the frame is now entirely the copy path on the CPU.
The screenshots stay out of the repository: game files and run logs never go in.

### 2. The GPU fetch no longer blocks the frame

`relay_card_back` in `crates/victory-gpu/src/host.rs` emitted a fetch of the
bytes shaders wrote to copies in the card's memory and then **waited for it on
the spot** — five times a frame, to move 1.9 MB.

It now emits the fetch, parks the pieces in `RelayFetch::pending`, and
`relay_fetch_merge` only waits **after** the CPU has merged the other copies.
The card runs the fetch while the CPU works.

| | before | after |
|---|---|---|
| fetch per frame | 150–197 ms | **1.4–2.1 ms** |

### 3. The `copying back` cost is now split and reported

`BACK_PARTS` separates the time into relay merge, relay fetch, settle card
fetch/merge, submit card fetch/merge and snapshots, printed on its own line
every five seconds. Every optimisation below was chosen from that line.

### 4. More threads where the memory work is

`wide()` in `crates/victory-gpu/src/shadow.rs` sized its pool at
`available_parallelism() / 4` — two threads on an eight-thread machine — and is
now `available_parallelism() - 2`, capped at 8. Snapshots went from 130 ms to
94 ms.

### 5. `VICTORY_AUTO_ENTER` — a run with nobody at the keyboard

`crates/victory-hle/src/modules/gameinput.rs`. The title's account picker takes
a **pad** button, and with no pad opened the keyboard drives the stand-in pad —
but only while the window has focus, which a headless run does not have.
`VICTORY_AUTO_ENTER=<seconds>` presses A every that many seconds for five
minutes by injecting the key into the keyboard state the stand-in pad reads.
`VICTORY_KEYS` no longer needs `--features diagnostics`.

## What was tried and made it worse

Kept in the code, off by default, with the reason and the number written above
the switch.

| Switch | Result |
|---|---|
| `VICTORY_CARD_BUFFERS_IN_RAM=1` — compare on the card over the copy in the PC's memory | 710–748 ms; 700 MB a frame over the bus costs more than the CPU's compare |
| `VICTORY_FAST_COPY=1` — `memcpy` guarded by SEH (`fastcopy.c`) | copies 127–205 ms against 104–147; one missing page fails the whole range |
| `VICTORY_INPLACE=2` | the driver refuses the big buffers (view memory) |
| `VICTORY_CARD_BUFFERS=0` | the world never loads |
| `VICTORY_CARD_REHASH_RUNS=1` + `VICTORY_JOIN_COPIES=1` | 660–1193 ms, more traffic |

## Where the frame goes now

Measured, not inferred — every number below comes from a counter in the runtime
(`host.rs`, `shadow.rs`), on a ~5,000-draw scene at 1080p:

| Stage | Cost per frame | Where it runs |
|---|---|---|
| preparing (CPU) | **148–179 ms** | submitting thread |
| — title → host copies | 90–116 ms / 155–177 MB | `wide()` pool |
| — textures | 5–13 ms | submitting thread |
| — recording the command lists | ~50 ms (~10 µs a draw) | submitting thread |
| waiting for the card | **113–143 ms**, of which 130 ms is *the title reading memory a shader may write* | submitting thread |
| copying back | **251–269 ms** | relay thread |
| — **waiting for the fetch of what shaders wrote** | **157–167 ms** | relay thread |
| — waiting for the card with nothing to land | 32–42 ms | relay thread |
| — merging what came back | 6.5–13 ms | relay thread |
| — snapshots (the "before" image) | 3.0–5.1 ms | `wide()` pool |
| compared per frame on the CPU | **25 MB** | |
| compared per frame on the card | **941 MB**, in 16,400 pieces of 64 KiB | GPU |
| bytes fetched back | 39–55 MB in 1,300–2,000 ranges | GPU → CPU |

The comparison moved to the card. The card's own compute pass hashes every
64 KiB piece of the title's buffers against the hashes it stored, returns a
16-bit mask of the dirty 4 KiB pages per piece, and only those pages are
fetched. That took the CPU comparison from 717 MB a frame to 25 MB: merge
191–248 → 6.5–13 ms, snapshots 100–115 → 3.0–5.1 ms.

Getting there needed **VRAM**: at 1,882 MB of texture copies the card was full
when the world's buffers were copied, so 96–98 of them were refused and 700 MB
a frame fell back to the CPU. `VICTORY_TEXTURE_BUDGET_MB` (768 MB by default
now) is what leaves the room: 97 copies / 941 MB on the card, no refusals, and
the frame went **477–585 → 339–371 ms**.

What is left is one thing: **the fetch waits 157–167 ms a frame for a queue that
has a whole frame of draws in front of it**, with the card at 26–32 % busy. It
is not bandwidth (55 MB at 165 MB/s effective). It is ordering.

The GPU is **not** the limit: the card's own clock shows it idle with work
queued for a large part of the frame while the CPU records the lists.

### What that means for 30 fps

The two CPU-side items that dominated the frame are gone. What remains, in
order: the fetch's 157–167 ms of queue latency, the 90–116 ms of title → host
copies, and the 130 ms the submitting thread spends waiting for shader output
the title reads. 30 fps would need all three gone and the lists recorded in
parallel — a different shape of renderer, not another optimisation pass.

For scale: the upstream author measures **~10 fps** on a Ryzen 7 5700X3D with an
RX 7800 XT — roughly three to four times this machine.

Full numbers, the benchmark method and every discarded attempt:
[`PERFORMANCE.md`](PERFORMANCE.md).


## Run it on your PC

1. 64-bit Windows and a current Direct3D 12 driver. The game uses mesh shaders
   and Shader Model 6.6.
2. Rust for Windows and Visual Studio Build Tools with **Desktop development
   with C++** (x64 MSVC toolset and a Windows 10/11 SDK).
3. `powershell -File .\Initialize-FormatTables.ps1` — verifies and installs the
   BCPack format tables (SHA-256 checked; `-FromCheckout <dir>` takes them from
   a local checkout instead of downloading).
4. `cargo build --release -p victory --bins`
5. `start.bat` — edit the game path in it first. It sets `VICTORY_AUTO_ENTER=8`
   so the account picker passes on its own; `0` turns that off.

`start-rt.bat` runs the same build with `--rt` (structure builder, ray traversal
and light resolve). On an RTX 3050 expect seconds per frame.

## Keeping up with upstream

Nothing syncs by itself — GitHub does not merge fork into fork, and upstream
opens no pull requests here. `origin` still points at `DexNom/VIctory`, so:

```powershell
.\sync-upstream.ps1            # fetch, merge, build, push if the build is green
.\sync-upstream.ps1 -NoPush    # fetch and build only
```

It stops on the first conflict and leaves the merge open to resolve by hand;
the one that recurs is `host.rs`, where this fork's `BACK_PARTS` timing sits in
the same lines as upstream's `WriteGroups`. `fork` is the remote this repo
pushes to.

**After any merge that touches the shader emitter, run `warm-shaders.bat`
before measuring.** Shader hashes change, the 5 GB cache is invalid, and the
first run then spends minutes at 10–12 s a frame compiling pipelines mid-game
(`dropped 764 without a host pipeline (961 being made)`). The preloader
translates and compiles everything up front instead.

Measured cost of the merge itself (`921d8d3` → `2e01ab4`) in this fork: **none
on the same scene** — 499–506 ms against 486–546 ms before it, with a warm
shader cache and ~1 000 draws. The 588–760 ms seen at first was a 5 000-draw
scene, not the merge.

## Upstream

- [DexNom/VIctory](https://github.com/DexNom/VIctory) — the snapshot this fork
  starts from (`921d8d3`).
- [Marvisak/VIctory](https://github.com/Marvisak/VIctory) — the original
  Radeon-tested runtime.

Their README is kept as [`README.upstream.md`](README.upstream.md), and
`BENCHMARK.md` as it was.

## Licence

See [`LICENSE`](LICENSE).
