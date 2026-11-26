# GMAC

**GTA VI on Apple Silicon Macs.** GMAC runs the Xbox Series build of Grand Theft Auto VI on an M-series Mac, from a
copy of the game you own, through Wine, Apple's D3DMetal and Rosetta 2.

> [!IMPORTANT]
> **GMAC is not playable yet.** No game files are included here, now or ever. You need your own copy of the game.
> No code is published yet either; this page tracks progress and the plan.

## Where it stands (26 November 2026)

Tested on a **MacBook with an M5 and 16 GB of memory**.

| Stage | Status |
| --- | --- |
| Boot, first-run screens, intro video with sound | works, 45 to 60 fps |
| Rockstar logo, intro art, legal and settings screens | works, rendered correctly |
| Story-mode load ("loading screen" art) | works, a steady 60 fps (Series S mode), 25 to 35 fps as a Series X |
| Story intro (`FBK_STRY000_INTRO`) | streams in, and its dialogue plays |
| Story mode | **reached:** dialogue plays and the minimap shows, but the world is black (its mesh draws are skipped for now), under 1 fps |
| Gameplay | not yet |

### Latest findings

- **Story mode reached (26 November).** With the fixes below the game gets past the load into story mode: the
  dialogue plays and the minimap HUD appears. The world is still black, because its mesh-shader draws are skipped
  to get past a GPU hang, and it runs below 1 fps.
- **Rosetta-safe write tracking.** Tracking which memory pages the game writes (so only those are copied to the
  GPU) used to freeze Rosetta on 256-bit AVX stores that cross into a protected page. GMAC now rewrites 96,833 of
  the game's AVX stores as plain 8-byte moves when it loads the game, found by a disassembler ahead of time. With
  tracking on, memory copies fell from up to 2.2 GB per submission to under 1 MB per frame on the loading screens.
- **The game's own GPU watchdog** ("GPU Loc Sig") stopped the game on purpose when GPU work ran long. It is
  patched out.
- **Series S mode** gives the game about 7.6 GB instead of 13.5 GB, which a 16 GB Mac can hold through the load.
- **60 fps loading screens:** an option paces the console's 30 fps frame clock twice as fast.
- **Next:** D3DMetal's mesh-shader work never finishes in the world (both hung GPU lists were mostly mesh
  shaders), so the world does not draw yet; free memory still falls to about 5% in the world; and Apple's Metal
  shader compiler crashes on some of the game's mesh shaders.

## Target

1. The opening title card and cutscene on screen.
2. The 3D world drawing at **2 to 4 fps**.
3. In the long run, **50 fps** in the world.
4. A setup a Mac owner can run in a few commands.

## How it works

The game's Xbox code is x86-64, like a Windows program, so a loader maps it and stands in for the console:

- **Rosetta 2** runs the x86-64 code.
- **Wine** (CrossOver's, built from source) provides Windows.
- **D3DMetal**, from Apple's Game Porting Toolkit, turns Direct3D 12 into Metal.
- The console's GPU shaders are recompiled to DXIL, **ahead of time and natively on the Mac**.

## Built on VIctory and five-star-recomp

GMAC now runs the game on [VIctory](https://github.com/Marvisak/VIctory) through
[VIctory-macOS](https://github.com/pragyaangaur/VIctory-macOS) (both GPL-3.0), with CrossOver Wine built from
CodeWeavers' source. It started on [five-star-recomp](https://github.com/ThatRecompDev/five-star-recomp) (GPL-3.0),
and the Mac work done there carries over. GMAC's changes will be published under the same licence.

## What GMAC adds for the Mac

- **Rendering on Metal:** pixel-shader inputs numbered as the console numbers them (the intro was one flat colour
  before), descriptor strides for D3DMetal, CPU-built rectangle lists, buffer views at GPU-only addresses, and shader
  hashes D3DMetal can cache by.
- **Fitting 16 GB:** smaller GPU copies of game memory, 1080p and lower render targets, half-size read-only textures,
  and a memory guard that stops the game before the Mac runs out.
- **Loading faster:** all 25,908 shaders compiled natively ahead of time instead of under Rosetta during the load,
  pipelines built ahead of time, buffered file streaming, and the game's AMD-only spin-wait instructions patched so they
  no longer fault through Rosetta's exception thread.
- **Getting through the load:** the game's GPU watchdog trap patched out, its 256-bit AVX stores made safe for
  Rosetta so write tracking can run, Series S mode for memory, and 60 fps loading screens.
- **Staying stable:** giant and slow Metal shader compiles skipped instead of stalling the GPU, a clean quit that
  releases the GPU's memory (no restart needed between runs), a scan that cannot race the game's memory unmaps, and
  a log that names the shaders of a GPU submission that hangs.
- **Tooling:** a launcher with the memory guard, fps and load progress in the window title, and a fail-closed mute.

## Legal

GMAC contains no game code, assets or keys. Grand Theft Auto VI is a trademark of Take-Two Interactive and Rockstar
Games; this project is not affiliated with or endorsed by them.
