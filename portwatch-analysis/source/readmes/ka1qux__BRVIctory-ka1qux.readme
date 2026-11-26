# BRVIctory-ka1qux

Runs an Xbox Series title natively on Windows, from files the user supplies.
A fork of [victory-fork](https://github.com/fxceless/victory-fork) by fxceless,
itself a fork of [VIctory](https://github.com/Marvisak/VIctory) by Marvisak,
developed and measured on an AMD Radeon card.

This fork collects what it took to get the title's world drawn on one AMD
machine: fixes of its own, open pull requests of victory-fork that were tested
there one by one, and ports from other forks. Every change that affects the
picture was checked in the running title on that machine, most of them against
a counter rather than against a screenshot.

**This repository contains no game files, code or assets.** You need your own
copy of the game. It is not affiliated with or endorsed by the game's developer
or publisher.

## State on the test machine (2026-11-26)

Windows 11, Intel Core i5-13600KF, AMD Radeon RX 7800 XT 16 GB (RDNA3, driver
32.0.32029.2010), 32 GB RAM. Series X profile, diagnostics build.

| Stage | Status | Measured |
|---|---|---|
| Boot, menus, saves | ✅ | work (as upstream) |
| Getting into the world | ✅ | about 3 minutes from launch, with the caches warm and the movies skipped |
| The world | ✅ | drawn from a save: rooms with walls, ceilings and textures, lit by their lamps and by the sun; characters with skin, hair and clothes; exteriors with buildings; HUD and prompts. Also the open world later in the story (a save converted from another console, below): a city of high-rise buildings, palms, pools, a beach and the sea with boats |
| Light in shadow | 🟡 | the title's own ray-traced light runs, on by default (`VICTORY_RAYS=0` turns it off): its structures are built and traced, and shaded faces of buildings, trees and characters get bounced light, where without it they are near black. Four runs on the street, 5 to 11 minutes in the world, with no crash and no device removal; a frame costs about 0.05 to 0.1 s more |
| Play | 🟡 | a 25-minute play session, from the first room on to the next objective, on an earlier build of this branch; a 17-minute session in the open world with victory-fork's speed defaults on, with no crash |
| Frame rate | 🟡 | in the open world, with ray-traced light and the switches below: a median of 0.30 to 0.32 s a frame (about 3.1 to 3.3 frames a second) on a street with 5,800 to 7,300 draws a frame, 0.15 to 0.23 s at best; per draw about 51 to 55 µs, against 60 µs before this build's memory and submission changes. Preparing 76 ms and copying back 35 ms a frame, against 108 and 55. 0.53 to 0.56 s without victory-fork's speed defaults |
| Stability | ✅ | no crash and no device removal in the last fifty runs (4 to 25 minutes each), four of them with ray tracing on |
| Memory | 🟡 | the process takes about 31 GB of a 32 GB PC (it was 32.5): part of the title's memory is now read by the card in place instead of copied (1.9 GB in a street run), and root constant buffer views get 64 KiB copies instead of 4 MiB ones. The card holds about 12 to 12.7 GB of its 14 GB budget; textures it has no room for are made at a lower resolution or wait (below) |
| Upscaling | ✅ | AMD's FSR 4.1.2 (FidelityFX SDK 2.4.0, DLLs supplied by the user) runs on the RX 7800 XT in place of the title's own upscaler: rendering at 1920x1080 for a 3840x2160 picture in a street run, picture sharp (below) |
| Tests | ✅ | `cargo test --workspace` runs 873 tests and all pass on the test machine (one GPU test fails now and then when the whole suite runs in one thread; it passes alone) |

Known problems:

- The title's ray-traced light is on by default (below) but has been measured
  on one street of the open world only; interiors, night and other scenes are
  not checked yet. With `VICTORY_RAYS=0` a constant stands in for that light,
  so shaded places are lit, but flat.
- In a cutscene at the start of the save used for testing, the main
  character's torso shows the clothes of an earlier scene while the sleeves
  are right: the title bakes the outfit before the new outfit's textures have
  reached its memory. Under investigation.
- Loading is slower than the title's clock. A scene starts before all of it
  has streamed in: the shell of the first room (walls and ceiling) arrives 10
  to 25 seconds into the opening shot, in every launch looked at. An earlier
  version of this page called that "missing in some launches"; it was one
  picture taken at different moments of the shot.
- The characters' baked skin and clothes were right in 2 launches of 5 on the
  previous build and are right in all five since victory-fork's `310c6eb`
  and its pull requests #606 and #632 went in (below). That is still a small
  count; `VICTORY_BAKE_PROBE=1` reads the bake's result back, and its
  sequence of hashes was the same in the launches it was on.
- In the open world the card fills up. Textures it has no room for are now
  made without their largest mips (below); before, thousands waited and walls,
  cupboards and some objects showed black with light speckles. Such a texture
  stays at the lower resolution until it is let go.
- The frame is still bound by the processor, not the card: FSR at 1080p
  draws as sharp a picture but did not shorten the frame on this machine. Of
  a 0.3 s frame about 0.08 s is preparing, 0.035 s copying back, and the card
  is busy about a quarter of the time; the rest is the title's thread waiting
  on submissions.
- With the card near its budget (12 to 12.7 GB of 14), 1,000 to 1,500 passes
  a run find no room for a texture, and some far buildings show dark until
  room comes back. `VICTORY_LEVELS_ON_DEMAND=1` frees 1.2 GB of the card but
  still shows black facades on some buildings (fixes being ported).
- Two of the title's compute programs do not translate, and the programs that
  only shade ray-tracing hits are left out on purpose.
- Tested on one machine only. The switches under "Running it" are the ones the
  state above was measured with.

## How it works

Nothing is emulated. The title's executable is a PE32+ image of x86-64 code:
the loader maps it, applies its relocations, sets up its TLS and binds its
imports to implementations of the console's interfaces (an HLE of the
XGameRuntime, memory (`xmem`), DirectStorage and D3D12.X layers), so its code
runs on the host CPU as it is. Its command lists become host D3D12 command
lists. Its shaders are machine code for the console's RDNA2 graphics
processor; a shader recompiler translates each program to DXIL when the title
makes a pipeline, and caches the result. Textures are detiled from the
console's layouts (swizzle and tiling modes) and BCPack streams are unpacked;
audio is decoded from XMA2 and Opus; the title's Bink movies play through its
own library. [docs/architecture.md](docs/architecture.md) has the crates.

## What this fork adds to victory-fork

Each change is explained in its commit message and in a comment where it is.

**Title memory read in place, and leaner copies** (`VICTORY_UNIFIED=1`):

- The card reads parts of the title's memory where they are, through heaps
  opened with `OpenExistingHeapFromAddress1` over a view of this layer's own
  (never over the section's handle, which on this machine keeps the section
  committed until a reboot): runs of consecutive physical pages, and runs
  inside the title's large private arenas, in windows of 256 KiB to 32 MiB,
  within the host's shared GPU memory budget. In a street run 378 windows over
  physical pages (813 MB) and 249 over private memory (1,060 MB) had no copy.
  When the title frees or protects memory a window covers, the window is let
  go first (the idea and the retry of upstream pull request #2921). Probes on
  the card: nothing stays committed after a run, and opening a heap over
  committed memory does not charge the commit again.
- A root constant buffer view the title names without a length gets a 64 to
  128 KiB copy instead of a 4 MiB one (a constant buffer reads at most 64 KiB;
  found by avatarmanz/VIctory-7900XTX issue #38). `VICTORY_CBV_WINDOW=0` goes
  back.

**Frame-time switches** (off by default; the state above was measured with
them on): `VICTORY_ASYNC_SUBMIT=1` (the title's thread hands submissions to a
thread of ours instead of waiting on the submission lock), `VICTORY_CARD_AWAKE=1`
(a small compute keeps the card's clock up between submissions; from
avatarmanz/VIctory-7900XTX), `VICTORY_CARD_SYNC_BATCH=1` (victory-fork #1227),
`VICTORY_CARD_REHASH_RUNS=1`, `VICTORY_REUSE_ROOT_CBV=1` (#1212),
`VICTORY_FILL_HOT=1`, `VICTORY_STEP_INDEX=1` and `VICTORY_BURY_ASIDE=1` (#1224
and victory-fork's main), `VICTORY_FILL_WORKERS` (upstream #2900) and
`VICTORY_MARKS_THREADS` (upstream #2914).

**Picture fixes from other projects**, on by default with a switch to go back:
early depth for pixel shaders that ask for it (victory-fork #907, upstream
#2085; `VICTORY_EARLY_DEPTH=0`), normalized integer codes to the nearest float
(upstream `da82e444`: on AMD 125 of 256 8-bit codes came out one step low and
picked the wrong material; `VICTORY_NORM_QUOTIENT=0`), anisotropic samplers
with point mips (upstream #2031; `VICTORY_ANISO_POINT_MIP=0`), the size of a
mip past the last reads 0 (`VICTORY_RESINFO_BEYOND=0`), fills wait for flights
(victory-fork #1205, the blurred oval; `VICTORY_FILL_WAIT=0`), a slot picked by
index reads as a constant buffer only if it holds one (victory-fork #1216, AMD
page faults; `VICTORY_CONSTANT_MARKS=0`), a marked page's copy-back writes only
the bytes shaders changed (upstream #2918; `VICTORY_MARKED_RUNS=0`), and the
levels-on-demand fixes #1210 and #795.

**Upscaling with AMD FidelityFX on the host:**

- The console's FidelityFX loader is served by AMD's PC DLL: what the Series S
  profile needs (its two present planes are also composed into one picture;
  `VICTORY_PRESENT_PLANE=n` shows one).
- Series X: `VICTORY_FSR=quality|balanced|performance|ultra-performance|off`
  makes the title take its own FSR path and render at 1/1.5, 1/1.7, 1/2 or
  1/3 of its output. The two places of the title's code that pick the
  upscaler and its scale are changed in memory only (never in its files), at
  patterns named by a profile file the user keeps (`VICTORY_FSR_PROFILE`; its
  format is in `apps/victory/src/title_profile.rs`). No bytes, addresses or
  names of the title are in this repository; each pattern must match exactly
  once, or nothing is written and the title's own upscaler runs.
- The DLLs are AMD's and are not shipped here: `amd_fidelityfx_upscaler_dx12.dll`
  (and `amd_fidelityfx_framegeneration_dx12.dll` for frame generation) from
  [GPUOpen-LibrariesAndSDKs/FidelityFX-SDK](https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK),
  tag v2.4.0, `Kits/FidelityFX/signedbin`, in `VICTORY_FIDELITYFX_DIR` or a
  `fidelityfx` folder beside `victory.exe`. On the RX 7800 XT the provider
  picked FSR 4.1.2. Without the DLLs the title's own path runs.
- `VICTORY_FRAME_GEN=1` (diagnostics builds): AMD frame generation on the swap
  chain, from upstream pull request #1917. Not measured here; the HUD is
  interpolated with the scene.

**Copies of title memory that went stale** (walls, ceilings and materials
missing in some launches and not in others):

- A diagnostic that measures it, `VICTORY_STALE_CHECK=1`: at every update,
  each page of a copy the write tracking calls unchanged is compared with the
  title's. Before the fixes 5.4 % of those pages differed, 300,000 of them all
  zeros in the copy; with them 0.1 %.
- The fixes are open pull requests of victory-fork applied here: #438 by
  sennecools (write guards see the other views of the same physical pages, and
  the runtime's own writes) and #571 by arminkhaleghirod (DirectStorage page
  writes are told where the pages are mapped).

**Views and textures**

- A raw or structured buffer view that does not begin on 16 bytes of the host
  copy of its memory is made on a copy of its own range. The host's raw views
  begin on 16 bytes and the console's anywhere, so such views read wrong or
  were left null: more than 100,000 view creations a run.
- A command list's reset lets go of the textures its prelude uploaded. Two
  pull requests that were each right alone left every list holding every
  texture it had ever uploaded: no idle texture was freed, the card filled, and
  some 10,000 textures picked by index were never made.
- The queue of textures picked by index: slots never uploaded go ahead of
  re-looks at uploaded ones; re-looks are bounded per frame and back off for
  textures that keep changing.
- Texture views are told apart by the memory their mips really take, uploads
  start at the first mip that is there, and views the queue lost are put back
  (ported from [myokex/victory-amd](https://github.com/myokex/victory-amd)).
- Textures the card has no room for are made without their mips larger than
  256 texels a side, up to 97 % of the card's budget, instead of being
  refused (`VICTORY_TEXTURE_SHORT=0` goes back; `VICTORY_TEXTURE_DROP_MIPS=N`
  is victory-fork's pull request #610). A bake's own sources are made first,
  past the line, so characters keep their skin when the card is full.
- The title bakes its characters' skin and clothes while it loads, from
  textures it picks by index. Before each bake the texture pass runs until
  nothing more is due (it took at most 4,096 slots, once). That alone did not
  settle the bakes: they came out right in 2 launches of 5. What did, as far
  as the launches since show, came from victory-fork: its main at `310c6eb`
  (a newer view makes an older one stale only when it starts within its first
  4 KiB, where every neighbour of a packed texture used to be taken out of the
  queue; a texture with a host copy is uploaded again when the card is full)
  and its open pull requests #606 by laptopnotebook (a remap under an
  uploaded texture uploads it again; this path marked a source of a bake in
  each launch measured) and #632 by ryotdev (a late mapping check no longer
  clears the view that replaced the one it looked at).
- In the open world the card fills up, and late bakes found the textures
  they read still waiting for room (13,000 due, none made): characters came
  out with black skin and white eyes. A bake's own sources now go first and
  may be made past the card's usual line, up to 96 % of its budget
  (`VICTORY_BAKE_SOURCES_FIRST=0` turns it off, `VICTORY_BAKE_ROOM_PERCENT`
  sets the line). In an A/B on the same save, skin and clothes came out right
  with it and black-speckled without it.
- The texture ring of the intro movie no longer shows its frames out of order.
- A descriptor read only for its texture's size is answered by the host.

**Dispatches and pipelines**

- A dispatch of more than 65,535 groups in one dimension is run in parts,
  direct or indirect, with the clamp of indirect arguments on or off. The
  title's final gather of indirect light asks for 115,200. (After
  myokex/victory-amd, extended to any number of parts and to count buffers.)
- Compute programs that only shade ray-tracing hits get no host pipeline while
  the ray-tracing structures are not built: they cost AMD's compiler seconds
  each. Compute pipelines are waited for longer while a world loads.
- Offline warm-up of the shader cache and of the pipelines earlier runs used
  (victory-fork #282 by t4l03 and #237 by fffluffy-dev). The shader cache is
  keyed by the translator's sources, so a rebuild that leaves the translator
  alone keeps it, and a run after a warm-up compiles next to nothing while it
  plays (2 pipelines made, 2,770 loaded, in the run that measured it).

**Loading**

- A DirectStorage queue made for manual submission waits for `Submit`
  (victory-fork #575 by Cuebert), and a page list still being filled is read
  again for a moment before its request fails.
- `VICTORY_SKIP_MOVIES=1` ends the title's non-looping movies on their first
  playback tick (`all`: looping ones too).
- `VICTORY_PATCH=<rva>=<bytes>[:<expected>],...` writes bytes into the title's
  code in memory before it starts, only where the original bytes match; the
  title's files are not changed. Used here, with
  [LilBigJP/ztrx-ps5-save-import](https://github.com/LilBigJP/ztrx-ps5-save-import),
  to load a story save converted from another console and test the open world.

**Upscaling and display** (all off unless you supply AMD's DLLs; nothing is
downloaded, and none of them ships here)

- The title's FidelityFX calls (the upscaler that Series S mode uses) can run on
  your GPU through AMD's PC build instead of the console build.
  Get the [FidelityFX SDK](https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK)
  (release v2.4.0 was current on 2026-11-25) and copy
  `Kits/FidelityFX/signedbin/amd_fidelityfx_upscaler_dx12.dll` (the only file
  loaded; the folder's other DLLs may go along) into a `fidelityfx` folder
  beside `victory.exe`, or name the folder with
  `VICTORY_FIDELITYFX_DIR` (or `[paths].fidelityfx_dir`; the SDK's root works).
  Without the file, or if it offers no upscaler for the GPU, the log says so in
  one line and the title's own DLLs run. AMD's documentation says FSR 4
  requires an AMD 7000 series discrete GPU or an AMD 9000 series GPU or later
  (SDK `docs/techniques/super-resolution-ml.md`, which lists the RX 7800 XT
  under its INT8 model), so the Radeon this was measured on is covered.
- `VICTORY_FSR=quality|balanced|performance|off`. Unset, the host serves
  whatever FidelityFX calls the title makes when the DLL is there; `off` never
  does. A preset also makes a Series X title that does not use FidelityFX on
  its own pick it, rendering at AMD's named ratio of its output size (1.5x:
  2560x1440 for 3840x2160; 1.7x: 2258x1270; 2x: 1920x1080), through a
  *title profile* (`VICTORY_FSR_PROFILE`, or `[paths].fsr_profile`): a text
  file you keep that says where in the title's code the upscaler is picked.
  Nothing about a title is built into this program. The file has lines `key =
  value` (`#` comments): `build` (optional, the executable's BLAKE3), `picker`
  (a byte pattern, `??` for any byte, of the function that picks the upscaler:
  replaced by `mov eax, 7; ret`), and, for the render scale, `scale` (a pattern
  of the function), `scale.loads` (offsets in the match of its two
  `vmovss xmm, [rip+disp32]` loads) and `scale.slot` (the offset of four `0xCC`
  padding bytes that take the new scale), and any number of `scale.edit = <offset>
  <bytes>` (`{mode}` standing for the preset's quality mode, 1 to 3, for code
  that records it). Each pattern must match exactly once
  in the executable sections or nothing is written; the patched copy is in
  memory only. The idea is Marvisak/VIctory PR 1793's; the log's `fsr` lines say
  what was done, and the first dispatch says whether the title renders at the
  preset's size.
- `VICTORY_FRAME_GEN=1` (diagnostics builds): AMD's frame generation, from
  `amd_fidelityfx_framegeneration_dx12.dll` in the same folder as the upscaler.
  The presenter's swap chain becomes AMD's proxy, and each frame the title
  upscales on the host feeds it that upscale's depth and motion vectors
  (FSR 3 frame generation, which needs no camera matrices; the title's HUD is
  interpolated with the scene, and only an RGBA8 swap chain works). Ported from
  Marvisak/VIctory pull request 1917 (AwkGrep256), whose generated frames in the
  world were not confirmed on hardware either; the log's `FidelityFX frame
  generation` lines say whether it ran and how many frames it made. Not run
  here yet.
- Series S mode presents the world and the interface as two planes; they are
  blended into one 1080p image (from Linox-IDK/LNX-victory), or one plane is
  shown alone with `VICTORY_PRESENT_PLANE=<n>`.

**Frame time** (the street of the open world, ~6,100 draws a frame, 0.83 s a
frame after the merge of victory-fork's main, 0.42 s with these):

- Views' own copies of title memory are let go a few at a time and their
  buffers reused (each new copy used to look at all 12,000 kept ones and make
  a buffer of its own; the pass over the heap took about 850 ms a frame, now
  about 170).
- A copy-back writes the GPU's bytes back under one hold of the write guards
  per stretch instead of one per run of bytes (1.3 million runs a frame):
  275 ms a frame down to about 100.
- **Write marks**: shaders mark the 64 KiB pages they write through views,
  and copies go back by the marked pages instead of comparing snapshots
  (`VICTORY_VIEW_MARKS=0` goes back; with relay and late waits off). Measured
  on the same street, the same build with and without: 0.42 against 0.53 s a
  frame, copy-back 53 against 101 ms, preparing 92 against 137 ms. After
  VIctory's own write marks (`cd94d35`, `940d32f`) and its open pull requests
  #2455, #2437, #2409 and #2474, with two guard fixes of
  [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD).
- The pass over textures takes at most 50 ms a frame while the card is at
  its line (it could spend 750 ms making 1,500 textures in one frame when a
  little memory was let go), and does not look again at slots it just made.

**Ray tracing** (on by default; `VICTORY_RAYS=0` turns it off):

- The title's ray-tracing structure builder runs whole on the card without
  corrupting the title's memory, and the programs that shade ray hits are
  made. The cause of the crashes was the layer's: the builder dispatches by
  thread counts (`DispatchX` with `USE_THREAD_DIMENSIONS`), which were taken
  for group counts, so its stages ran up to 64 times the work and wrote empty
  nodes over the title's objects. Now the counts make groups and the threads
  past them leave (after victory-fork's pull request #646).
- Writes are declared only where shaders store by address; the address
  directory follows the buffers the title releases or replaces; list upload
  memory sits where shaders can reach it; only the copies a list names are kept
  current; node tests count an absent child or an unmapped page as no hit, and
  nothing hits while no structure is built; sun-shadow traces read structure
  addresses from a per-slot table. After victory-fork's pull request #994 (by
  PiloteCode) and [DexNom/VIctory](https://github.com/DexNom/VIctory), which
  first ran the title's ray tracing on an AMD card.
- While the builder runs, the constant stand-in for indirect light steps
  aside (`VICTORY_AMBIENT_WITH_RAYS=1` keeps it, to compare).

**Light**

- While the ray-traced light does not run, the output of the program that
  resolves the indirect diffuse light is replaced by a constant
  (`VICTORY_AMBIENT=<level>`, 0.6 by default; `off` keeps the program's
  output, which here is magenta on leaves and cloth and blocks of colour
  indoors). After [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD).
- The constant has a colour (`VICTORY_AMBIENT_TINT=r,g,b`) and less of it
  reaches creases and the underside of things, worked out from the scene's
  depth (`VICTORY_AMBIENT_SHADE`, on by default; `=0` off). Also after Belobug.

**Translator**

- A pixel shader reads the other pixels of its 2x2 quad through quad reads,
  helper pixels included: wave reads give 0 from helper pixels on AMD, so a
  derivative a shader took by hand was wrong along every triangle's edge
  (lines on paint, glass and skin). After Belobug/VIctory-Belobug-AMD.
- Mesh primitive exports take 9-bit vertex indices (ported from upstream).
- The valid-mask bit of a pixel export decides which pixels survive.
- A heap buffer asked only for its size gets a non-uniform handle
  (victory-fork #452 by MalfoyDraco99, for a crash of AMD's compiler).
- Sixteen-bit float outputs of a mesh shader reach the pixel shader as zeros on
  this card, and the 32 KiB limit on mesh outputs is the validator's alone:
  both are measured in tests (`mesh_size_tests`).

**Diagnostics**

- `VICTORY_STALE_CHECK=1` (above; `fix` also copies what it finds) and
  `VICTORY_FULL_REFRESH=1` (every copy copied whole at each update).
- The frame statistics say what became of buffer views that did not fit their
  copy, how the texture queue stands, and what each bake found due.
- `VICTORY_BAKE_PROBE=1`: for the draws of the character bake, the state of
  every texture their data names, a second look at those some seconds later,
  whether materials sample the bake's own target, and a read-back of what the
  bake wrote (blocks and texels with colour, and a hash to compare launches).
- `VICTORY_RENDERDOC=1` loads RenderDoc before the device and captures a
  frame on request.

### Pull requests of victory-fork merged or applied here

Thanks to their authors. Each was read for what it adds, built, and run
through the test suites on the Radeon before it went in; #123 was taken back
out because its tests fail on this card.

#9, #25, #71 and #185 (Noname0202), #24 (NuraadGit), #32 (armin), #38
(spacede), #40 and #52 (jaschinski97-ops), #49 (fever308), #51 (pgm1207), #61
(srcamarda), #67 and #83 (ryotdev), #77 (m335671), #78 and #129
(vicennpacheco), #80, #119 and #506 (Adrito), #87 and #374 (davutsimsekk), #90
(António Mendes), #98 (sillynocodecat), #104 and #112 (avt0m4t), #106
(PastiiJay), #114 (Grégory Bonzon), #121 and #175 (Kamiloj9), #122 (Davi713),
#135 (alexdeliu), #154 (BitWuehler), #169 (HailLucifer666), #186 (Vyacheslav
Venglovsky), #191 (gdawid94), #196 (JaumeMarRib), #237 (fffluffy-dev), #282
(t4l03), #362 (renzowit35), #438 (sennecools), #452 (MalfoyDraco99), #571
(arminkhaleghirod), #575 (Cuebert), #606 (laptopnotebook), #632 (ryotdev),
#927 (tippythetaidum), #987 (several authors), #1023 and #1031 (Lkxex /
NetherySiloX), #1069 (alexis27yt). From upstream VIctory's open pull
requests: the BCPack fixes #2648 and #2649 (chaseb64), the mesh dispatch
of #2624 (andrewpozdnakov7-jpg), and the BCPack, tiling and write-mark speed-ups
#2735, #2736 and #2755 (brainbudt), the wave64 mask set by halves #2783
(BastienRodz) and audio that keeps up with slow frames #2788 (0xkn0wh3r3). Through victory-fork #1112 (KyleS98), two
translator fixes of DexNom/VIctory; victory-fork #1126 (Vladimir-Human): more
exact DXIL clean-up passes (loop-invariant code motion, local and shared-memory
forwarding, redundant barriers). From VIctory #2825 (0xkn0wh3r3): 16-bit float
arithmetic in native half where the host has 16-bit operations and the program
rounds to nearest even (45 of the saved programs; it rounds as the console does,
where the f32 path rounded toward zero; `VICTORY_F16_IN_F32=1` goes back).

## Running it

Requirements: Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with shader
model 6.6 and mesh shaders, Rust (pinned in `rust-toolchain.toml`) with the
MSVC build tools, and several GB of free Windows commit.

Windows charges the PC's commit for every byte of the card's own memory that
the driver hands out (measured here: +1.02 to 1.04 GB of commit per GB of
textures or buffers on the card, even made not resident). The texture queue
fills the card to 90 % of its budget, so a run takes 29 to 32 GB of commit;
with 32 GB of RAM, leave a page file large enough, or set
`VICTORY_COMMIT_RESERVE_MB` (one run with 6144: the PC kept 5.4 GB free
where it had kept 1.7 GB, at the same frame time).

```powershell
cargo build --profile diag -p victory --features diagnostics

$g = "<your game folder>"
$env:VICTORY_GAME_DIR  = $g
$env:VICTORY_CACHE_DIR = "<a folder for caches, outside the repository>"
$env:VICTORY_DATA_DIR  = "<a folder for saves, outside the repository>"

# Once after every change to the translator (5 to 15 minutes): translate the
# title's shaders and prebuild the pipelines earlier runs used. Use the same
# executable and the same switches as the run.
target\diag\victory.exe translate --cache --pipelines --used-pipelines `
    "$g\shaders.rpf" "$g\<the title's exe>" "$g\XboxBvhBuilder.dll" "$g\amd_fidelityfx_upscaler_xbox.dll"

# The switches the state above was measured with.
$env:VICTORY_INDIRECT_CLAMP = "0"   # the clamp of indirect arguments has dropped geometry here
$env:VICTORY_SKIP_MOVIES    = "1"
$env:VICTORY_COMMIT_RESERVE_MB = "6144"  # stop filling the card with texture copies when the
                                         # PC has less than this left to commit (see above)
$env:VICTORY_COPY_PLAIN = "1"; $env:VICTORY_JOIN_PARTS = "1"; $env:VICTORY_BACK_OWN_VIEW = "1"  # victory-fork's, off there
$env:VICTORY_UNIFIED = "1"; $env:VICTORY_ASYNC_SUBMIT = "1"; $env:VICTORY_CARD_AWAKE = "1"
$env:VICTORY_CARD_SYNC_BATCH = "1"; $env:VICTORY_CARD_REHASH_RUNS = "1"; $env:VICTORY_REUSE_ROOT_CBV = "1"
$env:VICTORY_FILL_HOT = "1"; $env:VICTORY_STEP_INDEX = "1"; $env:VICTORY_BURY_ASIDE = "1"
$env:VICTORY_CARD_WINDOWS_MB = "512"     # more of the card for textures
# FSR (AMD's DLLs and your own title profile, above):
# $env:VICTORY_FIDELITYFX_DIR = "<folder with amd_fidelityfx_upscaler_dx12.dll>"
# $env:VICTORY_FSR_PROFILE = "<your profile file>"; $env:VICTORY_FSR = "performance"
# $env:VICTORY_RAYS = "0"            # without the title's ray-traced light (on by default)
# The slower, older settings (no submissions sent ahead of the card):
# $env:VICTORY_RELAY = "0"; $env:VICTORY_WIDE_BACK = "0"
# $env:VICTORY_CARD_BUFFERS_MIN_MB = "16"; $env:VICTORY_CARD_BUFFERS_MB = "512"
# $env:VICTORY_LATE_WAIT_LISTS = "128"

target\diag\victory.exe run "$g\<the title's exe>" --execute
```

victory-fork's speed defaults send submissions ahead of the card. On this card
they bring the street from a median of 0.53 to 0.56 s down to 0.33 to 0.35 s a
frame, with skin, hair and clothes right in three launches (on earlier builds
baked hair and skin came out wrong with them; the bakes' sources now go first in
the texture queue). `VICTORY_BAKE_SETTLE=1` makes the two seconds after each
character bake run with every submission waited for, and
`VICTORY_STALE_AFTER_FLIGHTS=1` keeps a slot's old view until the submissions in
the air are done; both are off, as the picture came out right without them.

Three of victory-fork's switches that only act with its speed defaults
(`VICTORY_COPY_PLAIN`, `VICTORY_JOIN_PARTS`, `VICTORY_BACK_OWN_VIEW`) cut the
preparing from about 123 to 86 to 102 ms a frame and the copy-back from 65 to
44 to 52 ms in two launches here (0.28 and 0.31 s a frame against 0.30 s
without them). The recording threads no longer take the descriptor heap's lock
for a slot already made from the record it holds (victory-fork #1117 and #1146,
VIctory #2821; `VICTORY_HEAP_LOCKS=0` takes it every time): 0.345 → 0.303 s.

The frame rate is drawn in the top left corner of the window
(`VICTORY_FPS_COUNTER=0` turns it off; victory-fork's main).

Fixes taken in this round, with thanks to their authors: avatarmanz/VIctory-7900XTX
(the card kept awake, the 64 KiB constant windows' finding), Linox-IDK/LNX-victory
(Series S planes), victory-fork pull requests #795, #907, #1205, #1210, #1212,
#1216, #1224 and #1227, and upstream VIctory's #2031, #2085, #2900, #2914,
#2918, #2921 and commit `da82e444`.

Input: XInput pads; with none connected the keyboard is a pad while the
title's window has focus. Commands, the full list of switches and debugging
notes are in [docs/victory-fork-readme.md](docs/victory-fork-readme.md);
[docs/architecture.md](docs/architecture.md) describes the layers and
[docs/asset-policy.md](docs/asset-policy.md) what may never enter the
repository.

## Credits

- **[VIctory](https://github.com/Marvisak/VIctory)** by Marvisak and its
  contributors: the loader, the runtime services, the Direct3D 12 back end and
  the shader translator.
- **[victory-fork](https://github.com/fxceless/victory-fork)** by fxceless and
  the authors of its pull requests: the work that first drew the title's world,
  and most of what is merged here.
- **[myokex/victory-amd](https://github.com/myokex/victory-amd)**: fixes found
  on the same graphics card, some ported here.
- **[LilBigJP/ztrx-ps5-save-import](https://github.com/LilBigJP/ztrx-ps5-save-import)**:
  the code-patch option and the save converter used to test the open world.
- **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**:
  a fork of upstream VIctory on another AMD card; the quad reads of pixel
  shaders and the stand-in for indirect light are ported from it.
- **[DexNom/VIctory](https://github.com/DexNom/VIctory)** and victory-fork's
  pull request #994 by PiloteCode: the ray-tracing work ported here, and the
  material-record texture order (off by default).
- **[Marvisak/VIctory](https://github.com/Marvisak/VIctory)** pull request 1793
  by AwkGrep256 (the idea of finding the title's upscaler picker by a pattern at
  launch), **[Linox-IDK/LNX-victory](https://github.com/Linox-IDK/LNX-victory)**
  (the Series S plane composition) and DexNom/VIctory (the host FidelityFX
  module's context checks and input preparation); the module itself is
  upstream's; the frame generation is Marvisak/VIctory pull request 1917's.
  AMD's FidelityFX SDK (MIT) names the API's descriptions.
- **[XCL](https://github.com/xcl-dev/xcl)**: a different project with the same
  aim, whose public notes on the console's formats and on driver behaviour
  pointed at several problems. No code of it is used here.
- This fork's own changes were developed with
  [Claude Code](https://claude.com/claude-code).

## License

GPL-3.0-or-later, as VIctory and victory-fork (see `LICENSE`). The history of
both is kept below this fork's commits.
