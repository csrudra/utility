

===== avatarmanz/VIctory-7900XTX =====
4: that runs an Xbox Series title natively on Windows from files the user supplies.
5: This one is about **speed on AMD RDNA 3**: the world at 30 frames a second on
6: one PC, without giving up the picture. It is not there yet.
13: 
14: Tested on one machine only: Windows 11, Intel i9-12900K, 64 GB RAM, Radeon
15: RX 7900 XTX, 1440p, the Series X profile.
18: |---|---|
19: | Menus, videos, loading screens | 30 fps |
20: | Prologue, indoors | 50-75 ms a frame (13-20 fps) |
21: | First mission with the boat | 46-53 ms (19-22 fps) |
22: | Street chase with many cars and people | 100-165 ms (6-10 fps), single frames far longer |
23: | Outdoors on foot, the camp | 60-90 ms |
24: | Flying | 42-57 ms |
25: | Longest session so far | 41 minutes, no crash |
26: | Memory | 40-46 GB of private memory: **64 GB of RAM recommended** |
27: 
36:   pipelines (`victory warm` makes them ahead).
37: - Recording a frame in the world makes the title's own watchdog end it.
38: 
40: 
41: You need Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with shader
42: model 6.6 and mesh shaders, Rust (the toolchain is pinned), the MSVC build
52: 
53: `scripts\play.ps1 -Safe` leaves out the newest, faster ways; try it first when
54: something is wrong. `-RayTracing` turns the title's ray-traced indirect light on.
58: ```powershell
59: target\diag\victory.exe shaders <the shader archives>   # every shader translated, minutes
60: target\diag\victory.exe warm --used                     # pipelines earlier runs drew with, for a new driver or build
72:   (`VICTORY_THIN`): eight threads of ours translate them.
73: - **Submissions are prepared by a thread of ours and joined**
74:   (`VICTORY_ASYNC_SUBMIT`, `VICTORY_JOIN_PARTS`), with what can be spread over
75:   threads spread: refreshes, compares (AVX2), descriptor records, landings.
76: - **What shaders wrote comes back beside the write guards**, by the dwords that
77:   changed, on a thread of its own (`VICTORY_RELAY`, `VICTORY_LAND`).
78: - **Buffer fills that need bytes still on the card are done on the card**
81:   blocks that rest, places in the title's code that look before they write.
82: - **Textures go up on a copy queue of their own** and a slot shows one only after
83:   its upload ran, which also ended a device loss that came every 15 minutes or so.
84: - **Boats float**: textures that shaders write and the title's CPU reads go back
85:   to title memory (from fxceless and Geckomacabre, on by default here).
86: - **Frame record and replay** with per-pass times and shader variants compared
87:   turn by turn ([docs/replay.md](docs/replay.md)).
95:   contributors: the loader, the runtime services, the Direct3D 12 back end and
96:   the shader recompiler.
97: - **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)**: the fork
100:   cube gradients, sparse textures.
101: - **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**:
102:   the ambient light idea, pipeline workers, and work by romainhedouin.
103: - **[FQY55kai/ZJOU-VICTORY](https://github.com/FQY55kai/ZJOU-VICTORY)**.
104: - **[myokex/victory-amd](https://github.com/myokex/victory-amd)**: the guard over
105:   every view of a page (with Spexivus, joroyt and tightfall), and Joshua Odom's
106:   reads into title memory.
107: - **Geckomacabre** and **cxy0072019-sketch**: the texture read-back.
108: - **[XCL](https://github.com/ivall/xcl)** (GPL-2.0-only) was read for how the same


===== Belobug/VIctory-Belobug-AMD =====
4: that runs an Xbox Series title natively on Windows from files the user supplies.
5: This one is about **speed on AMD RDNA 3**: the world at 30 frames a second on
6: one PC, without giving up the picture. It is not there yet.
13: 
14: Tested on one machine only: Windows 11, Intel i9-12900K, 64 GB RAM, Radeon
15: RX 7900 XTX, 1440p, the Series X profile.
18: |---|---|
19: | Menus, videos, loading screens | 30 fps |
20: | Prologue, indoors | 50-75 ms a frame (13-20 fps) |
21: | First mission with the boat | 46-53 ms (19-22 fps) |
22: | Street chase with many cars and people | 100-165 ms (6-10 fps), single frames far longer |
23: | Outdoors on foot, the camp | 60-90 ms |
24: | Flying | 42-57 ms |
25: | Longest session so far | 41 minutes, no crash |
26: | Memory | 40-46 GB of private memory: **64 GB of RAM recommended** |
27: 
36:   pipelines (`victory warm` makes them ahead).
37: - Recording a frame in the world makes the title's own watchdog end it.
38: 
40: 
41: You need Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with shader
42: model 6.6 and mesh shaders, Rust (the toolchain is pinned), the MSVC build
52: 
53: `scripts\play.ps1 -Safe` leaves out the newest, faster ways; try it first when
54: something is wrong. `-RayTracing` turns the title's ray-traced indirect light on.
58: ```powershell
59: target\diag\victory.exe shaders <the shader archives>   # every shader translated, minutes
60: target\diag\victory.exe warm --used                     # pipelines earlier runs drew with, for a new driver or build
72:   (`VICTORY_THIN`): eight threads of ours translate them.
73: - **Submissions are prepared by a thread of ours and joined**
74:   (`VICTORY_ASYNC_SUBMIT`, `VICTORY_JOIN_PARTS`), with what can be spread over
75:   threads spread: refreshes, compares (AVX2), descriptor records, landings.
76: - **What shaders wrote comes back beside the write guards**, by the dwords that
77:   changed, on a thread of its own (`VICTORY_RELAY`, `VICTORY_LAND`).
78: - **Buffer fills that need bytes still on the card are done on the card**
81:   blocks that rest, places in the title's code that look before they write.
82: - **Textures go up on a copy queue of their own** and a slot shows one only after
83:   its upload ran, which also ended a device loss that came every 15 minutes or so.
84: - **Boats float**: textures that shaders write and the title's CPU reads go back
85:   to title memory (from fxceless and Geckomacabre, on by default here).
86: - **Frame record and replay** with per-pass times and shader variants compared
87:   turn by turn ([docs/replay.md](docs/replay.md)).
95:   contributors: the loader, the runtime services, the Direct3D 12 back end and
96:   the shader recompiler.
97: - **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)**: the fork
100:   cube gradients, sparse textures.
101: - **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**:
102:   the ambient light idea, pipeline workers, and work by romainhedouin.
103: - **[FQY55kai/ZJOU-VICTORY](https://github.com/FQY55kai/ZJOU-VICTORY)**.
104: - **[myokex/victory-amd](https://github.com/myokex/victory-amd)**: the guard over
105:   every view of a page (with Spexivus, joroyt and tightfall), and Joshua Odom's
106:   reads into title memory.
107: - **Geckomacabre** and **cxy0072019-sketch**: the texture read-back.
108: - **[XCL](https://github.com/ivall/xcl)** (GPL-2.0-only) was read for how the same


===== DexNom/VIctory =====
1: # DexNom RayTime (AMD)
2: 
3: DexNom RayTime is a community fork of Marvisak's VIctory for Windows x64. It runs an Xbox Series executable from your own game installation and translates its GPU work for Direct3D 12. This is our most complete tested build so far and the source for the FSR Quality 4K baseline. Game files, executables, saves and generated shader caches stay on your own computer.
4: 
5: AMD Radeon is the primary target and the best-tested GPU path for this build. See [Experimental NVIDIA](#experimental-nvidia) for the untested NVIDIA launch options. The current performance priorities are reducing VRAM use and improving FPS and frame-time stability.
6: 
7: The Radeon FSR Quality 4K build is our most stable tested baseline for shaders and texture streaming. See [Things to Be Done](#things-to-be-done) for open work and how to measure a contribution.
8: 
12: | --- | --- |
13: | GPU | AMD Radeon RX 7900 XTX, 24 GB GDDR6 |
14: | CPU | Intel Core Ultra 9 285K, 24 cores |
15: | System memory | 64 GB DDR5 |
16: | OS | Windows 11 Pro x64, build 26200 |
17: | Render profile | Series X, ray tracing on, 2560×1440 render, FSR 4.1.2 Quality, 3840×2160 output |
18: 
19: [AMD Radeon RX 7900 XTX specifications](https://www.amd.com/en/products/graphics/desktops/radeon/7000-series/amd-radeon-rx-7900xtx.html)
20: 
22: 
23: 1. Use 64-bit Windows and a current Direct3D 12 driver. The game uses mesh shaders and Shader Model 6.6. The Radeon gameplay results and known issues are listed below.
24: 2. Install Rust for Windows and Visual Studio Build Tools. In the Visual Studio installer, select **Desktop development with C++**, including the x64 MSVC toolset and a Windows 10 or 11 SDK. [Rust installer](https://rustup.rs/) · [Microsoft C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
25: 3. Download this repository using **Code → Download ZIP**, extract the ZIP to a writable folder, and double-click **Setup.cmd**. Select the Series X game executable inside your own extracted game installation. Keep its accompanying files together. Setup downloads the pinned build dependencies, verifies the BCPack format tables, and compiles the three Windows programs locally. [Download source ZIP](https://github.com/DexNom/VIctory/archive/refs/heads/main.zip)
26: 4. Open **DexNom RayTime** from the Windows Start menu. Use a controller for the game's first-time setup. The launcher and your local data are in `%LOCALAPPDATA%\DexNom Runtime`. Saves are in `state`, shader caches in `cache`, and per-run diagnostics in `logs`. The file `logs\latest.txt` points to the latest game log.
27: 
33: 
34: To warm the shader cache, open `victory-warm.exe` in the installed runtime directory. The log lists translated and refused shaders. Graphics pipelines also depend on draw state encountered during play. If you see a missing `VCRUNTIME140.dll` error, install Microsoft's x64 redistributable. [Microsoft Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)
35: 
36: For a manual build, run `.\Initialize-FormatTables.ps1`, then `cargo build --locked --release -p victory --features diagnostics --bins`. The release binaries are in `target\release`. Place all three together outside the checkout and pass the game executable path to `victory-play.exe`. Custom data and cache directories are documented in the configuration example. [Configuration example](victory.example.toml)
37: 
38: ## FSR Quality 4K baseline
39: 
40: Open **DexNom RayTime (FSR Quality 4K)** to use the tested Series X profile. It renders at 2560×1440 and presents at 3840×2160 with ray tracing enabled. FSR 4.1.2 takes the place of the game's TAA upscaler in this profile.
41: 
46: ```powershell
47: & "$env:LOCALAPPDATA\DexNom Runtime\victory-play.exe" --rt --console series-x --local-gpu-memory --fsr-quality --sparse-textures --no-upload-ahead --capture-readbacks --rt-write-stats
48: ```
53: 
54: ## Experimental NVIDIA
55: 
56: NVIDIA gameplay is untested. Start with ray tracing off and the game's display path. Replace `--rt` with `--no-rt` and leave out `--fsr-quality`, `--fsr-balanced`, and `--fsr-performance`. After setup, run the following in PowerShell.
57: 
63: 
64: `--no-rt` skips the ray-tracing builder, traversal, and lighting resolve. Supported material shaders use a lightweight diffuse ambient fill based on their base color. Some interiors can still look darker. [RT pass selection](crates/victory-gpu/src/pipeline/ray_tracing.rs) · [Ambient fill](crates/victory-shader/src/emit/mod.rs)
65: 
66: For a separate partial RT experiment, replace `--no-rt` with `--rt-static-bvh` and keep the FSR preset off. This skips rebuilding the acceleration structure for dynamic geometry and still traces rays through the prebuilt world structure. Ray traversal and lighting resolve can still be expensive, and moving objects may have incomplete shadows or reflections. Baked lighting or a probe-based indirect-light fallback is future work. [Static BVH mode](crates/victory-gpu/src/pipeline/ray_tracing.rs)
67: 
71: 
72: A fresh public download reached the City waterfront on an RX 7900 XTX with FSR 4.1.2 and ray tracing enabled. The first in-game frames took longer while pipelines compiled. Warm samples reached about 1.1–1.3 FPS with zero dropped draws. Some materials still rendered black.
73: 
74: - **Reduce buffer copy-back.** Track which pages the GPU actually writes and read back the ranges needed by CPU consumers. Start with the ray-tracing header builder, which declares much broader write ranges than it uses. Check fence ordering, CPU writes, aliases, and remaps when narrowing synchronization. [Submission and readback](crates/victory-gpu/src/host.rs) · [Buffer snapshots](crates/victory-gpu/src/shadow.rs) · [Guest memory directory](crates/victory-gpu/src/memory.rs)
75: - **Reduce VRAM use and stabilize texture streaming.** Measure local VRAM and GPU-shared system memory separately. Look for duplicate resident resources, oversized staging allocations, and repeated mip uploads. Keep a valid resident mip available until its replacement has finished uploading. For black materials, trace the draw's base color back to the bound texture and mip. [Texture residency](crates/victory-gpu/src/texture.rs) · [Texture descriptors](crates/victory-gpu/src/descriptor/host.rs)
76: - **Improve frame-time stability.** Measure cold pipeline compilation and warm gameplay separately. Look for CPU waits on buffer publication, repeated uploads, and pipeline work that can be prepared before the first draw. Compare pipeline counts and the rendered scene to check for regressions. [Shader translation](crates/victory-shader/src/emit) · [Pipeline creation](crates/victory-gpu/src/pipeline.rs)
77: 
78: For a before-and-after test, use the same scene, camera, and driver with ray tracing on and FSR Quality at 1440p → 4K. Report median and 95th-percentile frame times, dedicated and shared GPU memory, upload and copy-back time and bytes, and dropped draws or pending pipelines. Include the commit, hardware, and relevant log lines. [Benchmark notes](BENCHMARK.md)
79: 
81: 
82: - Pixel shaders that read neighboring pixels in a 2×2 group now preserve the values at triangle edges. On an RX 7900 XTX, this reduced incorrect edge pixels from 32 to zero in each of two adjoining-triangle tests. Cube-map sampling also selects the correct mip level for explicit gradients and honors the shader's minimum mip level.
83: - The ray-tracing memory directory can grow beyond 1,023 backing buffers. Each recorded draw or dispatch uses only the views available when it was recorded. Older command lists keep their original views.
84: - Streamed textures can upload when only their middle pages are resident. The runtime merges overlapping memory notifications and rescans tracked textures if the notification queue fills. Previously used depth-only pipelines now warm ahead of speculative material pipelines to reduce missing shadows during loading.
85: - Some dock objects still appear black in the City save. The same distant dock fixtures appeared dark with the ray-structure builder disabled. The effect of these changes on those objects and on gameplay FPS is still being tested.
86: - GPU readback identifies changed pages and combines adjacent copy ranges. This targets CPU/GPU synchronization and transfer overhead.
87: - Ray-structure builder dispatches now honor the game's thread counts and mask excess lanes in the final group. Read-only traversal no longer declares the entire guest memory directory writable when the shader sends its output to another buffer or texture.
88: - Texture handling searches for contiguous descriptor slots and admits already-resident textures under memory pressure. Earlier changes address publication order, placed-texture ownership and supported render-XOR layouts.
89: - Shaders can choose between two static samplers across a uniform branch. This recovered 40 shader variants from the tested archive. Another fix recovered one voxel visibility shader by recognizing a saved and restored wave64 lane mask. Mixed render targets retain their individual write masks when an integer target bypasses blending.
90: - The runtime preserves the game's vertex output interpolation and fixes output signature ordering. All 2,191 archive vertex shaders passed the Microsoft DXIL validator, including 18 water shaders. New textures and retries share the upload budget, and a previously refused buffer view is checked again when its backing allocation changes.
91: - The runtime resolves guest addresses from ray-tracing descriptors, preserves raw buffer offsets and prepares the memory each command list reads. Texture uploads can proceed while Windows remaps unrelated memory. In-game ray-traced lighting is still experimental.
92: - Five additional shadow compute shaders compile and create pipelines on the RX 7900 XTX. The translated ray-node regression also exercises three reflections through the guest-page directory. Changes confined to the standalone execution tests now preserve cached shader translations.
93: - Shader translation preserves the guest wave width for lane permutations and handles heap-indexed texture-size queries. Save handling flushes copied blobs before publication and can recover a complete checkpoint.
94: 
95: The source ZIP builds with the Windows setup script. The test report covers shader validation, a Radeon pipeline check, gameplay frame times and the remaining interior lighting issue. [Test and benchmark report](BENCHMARK.md)
96: 
98: 
99: For a local experiment, open PowerShell and run the following after setup. The process uses four CPU workers for eligible upload batches and can record independent transition command lists on the shared worker pool. The final GPU queue, fence signals and resource transitions retain the game's submission order. Compare the same save and camera after the initial streaming period. The default launcher uses the baseline settings.
100: 
110: - **ZSlayerHQ and the victory-world contributors**, including **triippywhale** and **asdaasdsaddf**, supplied the Radeon rendering work used as the basis for this fork. [victory-world-runtime](https://github.com/ZSlayerHQ/victory-world-runtime) · [Integrated revision](https://github.com/ZSlayerHQ/victory-world-runtime/commit/99f8834aa16b98d7f3943b8de262a8d4857bda7b)
111: - **The XCL contributors** published an independent Xbox Series compatibility layer that informed our work on shader translation and CPU/GPU memory synchronization. [XCL](https://github.com/xcl-dev/xcl)
112: - **AMD** supplies the FSR 4.1.2 upscaler used by the Quality 4K profile. [AMD FSR SDK](https://gpuopen.com/amd-fsr-sdk/)
113: 
117: 
118: VIctory source is licensed under GPL-3.0-or-later. The upstream project identifies the required BCPack format tables as separately supplied data outside that license. This source archive omits that file. The setup script verifies a local or upstream copy before use. [License](LICENSE) · [Upstream asset policy and table notice](docs/asset-policy.md)


===== fxceless/victory-fork =====
16:   contributors is the base of everything here: the loader, the runtime
17:   services, the Direct3D 12 back end and the shader recompiler. Licensed
18:   GPL-3.0-or-later; so is this fork. Upstream's history is kept intact below
22:   another layer. Fixes inspired by it were written anew in VIctory's code.
23: - The guard over every view of a memory page is code by **myokex**
24:   ([victory-amd](https://github.com/myokex/victory-amd), commit `c6dc4d8`), which
25:   adapts pull request #115 here by Spexivus, its correction by joroyt and a part of
26:   VIctory #1122 by tightfall. The read-beside fix for kernel reads into title
27:   memory is by **Joshua Odom** (commit `10ea38e` of the same fork family). Both
28:   are carried here unchanged apart from one merge conflict.
37: yet. Shadowed areas are still black.**
38: Tested on one machine: Windows 11, Intel i7-14700KF, NVIDIA RTX 4070 12 GB,
39: 32 GB RAM. The Series X profile is used throughout.
40: 
42: |-------|--------------------|
43: | Boot, menus, start screen | works, 30 fps (as upstream) |
44: | Opening cutscene | plays from start to finish, in order, lit: title cards, credits cards, night and dusk shots |
48: | Light in shadow | missing: the game's ray-traced bounce light and ray-traced lamp and sun shadows do not run yet, so anything the sun does not hit directly is black |
49: | Frame rate in the world | **9 to 12 fps in rooms and light outdoor views**: 110 ms a frame in the first rooms at about 4,700 draws (run 275), 86 to 102 ms on the water at about 1,300 draws (run 279). **5 to 6 fps in heavy outdoor views** (160 to 208 ms at 7,200 to 9,700 draws). A frame is about 70 ms plus 13 ms per 1,000 draws: the thread that prepares submissions is the limit, the card idles 12 to 40 ms a frame. It started at 3 to 6 seconds a frame. Measured with the switch set in `diagnostics/README.md` plus `VICTORY_CARD_HASH_LEN=1`; the defaults are slower |
50: | Stability | **the card is lost after 30 to 50 minutes of play**: Windows reports the device removed (0x887A0005) with no driver event and no freeze, twice (runs 277 and 279); once a hang after 6 minutes with two driver events (run 276). Cause not known. In the tree to find it: crash tracing cheap enough to leave on (`VICTORY_D3D12_DRED=faults`), the memory at the moment of a loss, and a cap on oversized constant views (an invalid call another tester's card answered with a removal) |
51: | Memory | about 23 to 27 GB of the PC's 32 GB and 9.2 to 9.6 GB of the card's 10.3 GB budget while playing |
52: 
60:   pass's time unchanged). Left off.
61: - **Fixed from Direct3D's debug layer's own words** (runs 283 and 289): a pipeline that blends into
62:   an integer render target; a draw whose pipeline declares another render target format than the
63:   one bound (a pipeline for the bound format is made, `VICTORY_TARGET_VARIANTS=0` turns that off).
64: - **Pull request #1241** (a view of a card-written texture copied even after an upload of the same
65:   view) is in. It did not change the black in shadowed areas (run 291).
66: - **Still open:** the card is lost 30 to 50 minutes into a session (the memory figures at two
67:   losses: 1.3 and 2.0 GB of the PC's 32 free, the process at its largest; another tester reports
68:   the same signature with "Kernel memory failure" under the debug layer; not shown to be the cause
69:   here). Shadowed areas are black. In a heavy outdoor scene (7,000 to 9,000 draws) the frame is
78:   constant views far larger than the host allows (its author logged one of 1,306,368 bytes); making
79:   such a view is an invalid call, and its author's NVIDIA card removed the device for it. A warning
80:   is logged once when a view is capped. Whether this is behind the card losses on the test machine
83:   copied in place. There are 8,000 to 12,000 a frame and each was a kernel call of about 400 ns; in
84:   place it is about 30 ns (timed offline). Expected: about 3 ms off the submitting thread a frame.
85: - **`VICTORY_STEP_INDEX=1`**: the passes over a submission's steps find a step's copy by an index
94:   (a fix to `VICTORY_ABSENT_MS=told`).
95: - **`VICTORY_D3D12_DRED=faults`** (and `light`): crash tracing cheap enough to play with. The full
96:   form cost about 50 ms a frame.
97: - **Instruments for the card loss**: at a removal the log now has the process's, the PC's and the
98:   card's memory at that moment and the card's peak use since the last line (the memory line was
99:   one look in five seconds); a line a second with the peak (`VICTORY_VIDEO_LOOK=0`: none); and
100:   what Present answers, which was thrown away.
101: - **The fourth loss (38 minutes in, with `VICTORY_D3D12_DRED=faults`)**: removal reason 0x887A0005
102:   again, and the runtime reported no page fault address, so it was not the card reading freed or
103:   unmapped memory. The three long sessions all ended on the way to the same place in the story,
104:   so the trigger looks tied to what is drawn or made there, not to the time played. Nothing in the
106:   cost nothing measurable up to 4,000 draws a frame.
107: - **Looked at for the card loss and not found to be the cause**: video memory. In four sessions
108:   the card was at 84 to 92 % of its budget throughout and never over it at a sample, the session
109:   with no loss as full as the others, and no out-of-memory result in any log. The cause is open.
110: - **`VICTORY_BVH_NO_HIT=1`** (a translator change: the shader cache is rebuilt once after this
111:   commit): the title's ray-traced passes run although nothing builds their structures, and each
120: 
121: **Small buffers into the card's memory: about 18 ms of card time a frame gone, 5 ms of frame so far.**
122: Tested on the machine above, first rooms, at like draw counts (runs 274 and 275).
123: - **Why some compute passes were slow.** A title buffer's host copy under 1 MiB stayed in the PC's
124:   memory (about 3,700 of 3,800 copies, 30 MB in all), so every load, store and atomic a shader did
125:   on it crossed the bus. The passes that were slow by the thread were small dispatches on such
126:   buffers. `VICTORY_CARD_BUFFERS_MIN_KB=64` (with `VICTORY_CARD_BUFFERS_MB=1280`; off by default)
127:   puts every copy in the card's memory: the title's lists went from 68.0 to 49.8 ms of card time a
128:   frame; single passes from 6.7 to 1.6 ms, from 4.1, 2.7 and 2.0 ms to under 0.3 each. The frame:
130:   is hashed over a whole 64 KiB); `VICTORY_CARD_HASH_LEN=1` hashes the buffer's own bytes instead
131:   and has not run in a game yet. The card now idles 12 to 40 ms a frame: the thread that prepares
132:   submissions is the limit.
134:   64 bytes at a time as one mask of differing bytes. 3.8 ms less work a frame on the submitting
135:   thread at equal draws; the frame's gain is inside the noise. A first form (64 equal bytes, then
136:   eight at a time) was a fifth slower than the walk on sparse changes and never ran.
140:   buffer loads fall by 38 %. Tested on the software adapter, also across a view's end. Whether a
141:   card is faster for it is not measured yet.
142: - **Pull request #999 merged** (cxy0072019-sketch, porting a patch by Geckomacabre):
143:   `VICTORY_TEXTURE_BACK=1` copies textures of the ocean's kinds that shaders write back into title
144:   memory, where the title's own code reads them. Off by default. Without it a boat sank here and
145:   its mission failed at once (run 275). With it (run 276, both shader caches wiped first): 22,900
146:   read-backs landed in six minutes of play and the tester got past that point: the largest step
150: - **What the copy-back is worth, measured** (`VICTORY_BACK_READS=alt`, diagnostics builds; run 277,
151:   49 minutes of play): 497 GB were copied back from the card into title memory. Of 438,000 stores
152:   looked at (one page in 8): 60 % were touched by nothing before the next store, 36 % only by the
168:   gives 0 for the one outside; what the card does is not tested.
169: - **The card was lost twice**: run 276 after 6 minutes (two driver events, then a hang) and run 277
170:   after 49 minutes (device removed with no driver event, 8 ms after a sweep let go 150 texture
171:   copies). Causes not known. `diagnostics/` holds a scrubbed log of a short run with
172:   `VICTORY_GPU_TIMING=1` and `VICTORY_D3D12_DRED=1` for anyone who wants real numbers.
173: - **`VICTORY_ABSENT_ONCE=1|alt`** (off): a block of view memory found unmapped is not asked of
174:   Windows again for 100 ms. Outdoors those questions were 44 ms a frame of the submitting thread.
175:   Not run in a game yet. `VICTORY_D3D12_DRED=1` costs about 50 ms a frame in a diagnostics build.
176: - The texture pass's time budget: never reached in the first rooms (about 5 ms a frame); 15 to
177:   30 % of the frame in an open-world session. The translator emits no stack slots to promote:
179: - Not run in this tree: the unit tests after the merge (the same changes passed them in the
180:   working tree they came from: 182 of the graphics crate's, the new shader test both ways).
181: 
194:   making a Direct3D 11-on-12 device on the wrapped device. A MISTAKE of
195:   that run: the driver refused the saved pipeline library and the layer
196:   saved an empty one over it (366 MB of 3,385 pipelines became 32 bytes;
200:   loaded the library is neither read nor saved.
201: - **DirectStorage reads wait for the title's Submit** (after upstream
202:   VIctory eddde734: its hold and two tests, not its diagnostics). The
203:   title fills a batch's page list only right before its Submit; a queue
204:   that sent itself when half full started reads into physical pages
205:   before that. Run 266: 3 such cases (2,079 reads held of a queue of
206:   4,159), no stall, 0 failed page writes, frame time not worse. Faces
207:   were right in that one launch; face faults come and go between
208:   launches, so a cure is not shown yet.
209: - **Processor use, per core and per thread (runs 266, 267): nothing is
210:   full.** Of 28 logical processors the machine keeps 6.7 busy in the
211:   cutscene and 4.5 in the room, the process about 3.6 and 3.1. The
212:   busiest thread, the layer's submit thread, is 42 to 58 % busy; the
213:   title's most crowded pinned group is 25 to 29 % full. No look in the
214:   room found the render, the submit or a recording thread on a slow core
215:   (0 of 1, 0 of 8, 0 of 120). `VICTORY_SPREAD=alt` in the cutscene: 262 ms
216:   a frame off, 262 on. The frame is a chain of waits: more cores alone
217:   give nothing. Splitting the submit thread's work would use them: it
218:   works 83 ms of the room's 122 ms frame (bound: a frame of about 100).
219: - **`VICTORY_WIDE_REFRESH=alt`: no gain, dropped** (copies of title memory
220:   refreshed on several threads, twenty seconds on, twenty off). Cutscene,
222:   predicted. Room, run 269, 10 readings each way: copies 30.6 ms off, 34.1
223:   on; submit thread 78.6 against 78.4 ms.
224: - **Frame shot: a capture of one frame, built into the layer**
227:   shot holds every command of the frame in order (draws, dispatches,
228:   copies, submissions, with list and thread), the card's clock before
229:   each command, and a picture of each texture as a pass leaves it. It
230:   loads no DLL and wraps no device: only texture read-backs and
231:   timestamps, which every run uses already. Hence built in, not outside.
232: - With little memory free, a shot takes at most half of what is free
233:   above 0.7 GB, and pictures that do not fit are taken in parts from
260:   found; that driver error had also come up before the pool existed).
261:   Predicted: page faults per texture upload from about 100 to well under
262:   50, long frames 60 to 115 ms shorter at equal uploads. Measured: 6.27
264:   ways). Long frames average 391 ms with 204 uploads off, 421 ms with 310
265:   on: 1.92 ms an upload off, 1.36 on, but the texture pass fills its 250
266:   ms time budget either way, so frames are no shorter. Page faults per
267:   upload: 132.7 off, 128.9 on: prediction not met. No gain shown: not
269:   off; it counts now.
270: - **Memory, measured.** The process holds about 24 GB, 16 GB of it in
271:   memory, on a 32 GB PC. Free: 3.6 GB in the cutscene and 0.9 to 1.8 GB
272:   in the room in run 269; 3.6 to 5.3 GB late in run 270 (why they differ
273:   is not known). The card is nearly full: 9.0 of a 10.2 GB budget. Title
274:   buffers of 1 MiB and more are in its memory in these runs (1,024 MB at
275:   most); the 872 copies of what the title's own allocator hands out
276:   (vertices, indices, constants: 3.6 GB) are in the PC's memory and read
277:   over the bus at every draw. The card has no room for all of them: it
278:   would come out of the textures' share.
279: - **Some of those copies in the card's memory: fewer long frames, in two
280:   launches of two** (`VICTORY_CARD_WINDOWS_MB`, off by default). Run 271
282:   2,048 MB (355 copies, 1,356 MB, went there; the layer's own line at 80 %
283:   of the card's budget turned the rest down). Both: 300 s, 0 errors, no
284:   driver event, pictures right. Frames a second in three stretches of the
299:   draws cost the card the same per command with and without (+1 %, 37
300:   shader sets found in both captures). The price: passes that made no
301:   texture for lack of room rose (2,067 and 1,280 without; 2,504 and 3,699
302:   with). Four launches, two each way, and earlier launches without it
303:   reached 3.4 to 5.1 in the first stretch: a result, not yet a default.
304: - **The same copies written straight into the card's memory**
305:   (`VICTORY_WINDOW_UPLOAD=1` with `VICTORY_CARD_WINDOWS_MB`, off by
310:   273 (closed at 155 s; 0 errors, no driver event, picture right): 368
311:   copies (1,400 MB) were one buffer each, with no side in the PC's memory
312:   and no pass that sends them up. The PC's memory shared with the card:
313:   3.8 GB against 5.7 GB in run 272; free memory 3.2 to 3.6 GB against 1.1
314:   to 1.9 GB. Frame rate as run 272, as far as one shortened launch can
316:   5.42 and 8.16). The send-and-hash lists did not fall as predicted (12.3
317:   against 13.6 ms a frame at like draws). A memory gain; no speed gain
318:   shown.
328:   reads it, where today every changed piece is fetched back every frame
329:   (42 to 70 MB): being studied, nothing built; (4) a faster byte compare
330:   for the submit thread (8 and 64 bytes at a time; its test of 20,000
331:   cases against the byte-by-byte walk passes; not in a run yet); (5) the
332:   texture pass's time budget, 250 ms against less. Title buffers in
333:   place (`VICTORY_INPLACE`) were listed as the large step; a closer look
334:   at this PC says otherwise: both ways of opening title memory to the
335:   card pin it in a PC with 1 to 5 GB free, and the buffer that carries
336:   the most traffic cannot be opened at all. A memory step and a modest
337:   time step, not the road to 30 frames a second by itself.
344: with all of them, from about 120 ms in the morning. Still far from the console's 33 ms.
345: - How the title paces itself (new meters in `fence.rs` and
346:   `console_insn.rs`): it never asks for an event. Each frame begins with
347:   one small submission and a signal, and a title thread then waits for
348:   that fence value by reading it in memory with `monitorx` / `mwaitx`
349:   (AMD-only: about 280,000 emulated exceptions a second on an Intel
350:   processor, all from this wait). The value is set when the layer has
354:   more processors, changes nothing (both measured).
355: - Two walls stand side by side and both are full: the layer's submit
356:   thread (about 95 ms of a 120 ms frame in the morning) and the card
357:   (about 102 ms busy, by a timestamp pair around every host list:
359: - `VICTORY_JOIN_PARTS=1` (off by default): the title's lists wait for
360:   memory values, which cut its ~15 submissions a frame into ~29 parts;
361:   parts that follow one another now go to the host as one submission
363: - `VICTORY_BACK_OWN_VIEW=1` (off by default): what shaders wrote goes
364:   back into title view memory through a view of the layer's own, so the
365:   copy that wrote it is not read in again. About 9 % (submit thread 93 ->
366:   81 ms a frame, 104 -> 80 MB a frame checked). A CORRECTION: an earlier
371: - Where the card's time goes now (`VICTORY_CARD_METER_PIPELINES=1`, a
372:   table by pipeline): no pass is large. About 82 ms of the title's lists
373:   are spread over ~3,400 pipeline bindings a frame; ~2,400 of the
374:   indirect commands still get a clamp pass of the layer's with draw
380:   the list's prelude clamps all such records in one pass by a table of
381:   their offsets (the clamp shader with a gather bit), where each draw had
382:   a compute pass of the layer's in front of it. Proved by clamping every
398: - `VICTORY_COPY_CHANGED=1` (off by default): a refresh of a copy in the
399:   card's memory sends on only the 256-byte chunks that differ from the
400:   copy's CPU side. The layer's sync lists on the card fall from 12 to 8
401:   ms a frame, the submit thread pays 3.6 ms for the compare and is then
402:   the limit: no net gain yet.
405:   the time goes to frames of ~490 ms in which the card is idle for ~330
406:   ms: some 850 remaps of title memory, 260 texture uploads and 450 disk
407:   reads in one frame. That is the next thing to measure and cut.
410:   with half the time in frames of ~490 ms in which the card is idle for
411:   ~330 ms. In those frames the title's render thread waits for its own
412:   jobs, not for the layer. One of those jobs is the title's page-mapping
413:   copies (`CopyPageMappingsBatchX` -> `xmem::map_alias`): the title maps
414:   every streamed texture page into its tiled heap, a range of one page
415:   each (over 4,096 different pool pages in a minute, about 850 pages in
423:   or red and one run drew garbage in 3 launches of 3, against none in 6
424:   launches without it). Reverted; why a longer view breaks texture
425:   streaming is not known yet.
435: What did it, on top of the list below:
436: - Descriptor records the title copies into its heap as plain bytes are
437:   mirrored before every submission (pull request #305 by Flyander, after
445:   the runs before made 1, and the processor no longer compares 550 to
446:   710 MB a frame looking for shader writes (25 MB now).
447: - Levels on demand ran on the card for the first time
449:   pull request #747 by AscilCH): 3.1 GB of the card not allocated for
450:   texture levels the title does not hold, no device loss.
451: - Guarded blocks under storage writes are opened by default; 14 more
452:   shader programs translate; a program is translated with first-half
453:   interpolation pairs only if it was refused for one (with that on for
454:   every program, 8,551 working pixel programs came out changed).
455: - Frame rate, first cuts on the processor side: the descriptor sync uses a
456:   cheap fingerprint and leaves draw-table slots to their draws (the pass
457:   over the heap went from 70-220 ms a frame to about 3), and memory the
458:   guards already hold is not asked of the write watch (pull request #670
460:   flights (pull request #648 by Jonirulah, `VICTORY_CARD_FETCH_INFLIGHT=1`,
461:   off by default: the copy-back thread's wait went from 181 ms a frame to
462:   0 here, but the card got busier, so no gain is claimed yet). The frame is
479:   - `VICTORY_ASYNC_SUBMIT=1`: submissions are prepared and sent by a
480:     thread of the layer, not by the title's render thread, which a
481:     profile showed inside the submit path for 257 of 292 ms a frame.
482:   - `VICTORY_QUEUE2=1`: fetches of what shaders wrote go to a copy queue
483:     (brought back, with the fix for a piece fetched beside a later
484:     flight); the copy-back thread's wait fell from about 125 to 7 ms a
485:     frame.
486:   - `VICTORY_INDIRECT_WINDOW=1`: see above.
487:   - `VICTORY_TEXTURE_NO_WAIT=1`: a texture refresh no longer waits while
488:     the title remaps memory; the loading phase had 5 readings over a
489:     second where it had 18.
490:   - `VICTORY_MERGE_GAP=64 VICTORY_MERGE_RUNS=4096`: title bytes put in
491:     under flights' shader writes are joined over small gaps (NOT exact:
492:     read the comment at `merge_gap` before using it).
493:   - On by default: fills of upload memory and read-only buffer copies no
494:     longer wait for flights and are checked against what the flights then
495:     wrote (`VICTORY_FILL_WAIT=1` waits as before; no mismatch in any run
496:     so far); up to 512 idle host lists and texture staging buffers are
497:     reused instead of made and freed every frame.
502:     frame's length, and for the usual frame and each long one what it was
503:     made of (the render thread's time in the present call, the submit
504:     thread's work, copies, copy-back, recording, texture work, faults,
505:     disk). A card meter (`VICTORY_CARD_METER`) adds the card's time by
507:   - What they showed, windows off: a usual frame of 136 ms; the title's
508:     render thread waits 77 ms of it in the present call for the submit
509:     thread, which works 118 ms (copies of title memory 41, copy-back 40);
510:     the card is 85-98 % busy, of about 130 ms a frame 16 ms in our lists
511:     that bring card copies up to date, 10 ms in our compare lists and 102
512:     ms in the title's own lists with the per-record clamp. Frame time is
513:     linear in draws (about 32 microseconds a draw all-in): the title draws
516:     frame (`VICTORY_CAPTURE_WORLD`, every 8th world frame) is read back
517:     and written as a PNG inside the present, 235 ms each.
518:     `VICTORY_CAPTURE_WORLD_EVERY=64` for runs that measure speed.
533:     them lost its device.
534:   - A copy between two title textures that share one host texture is no
535:     longer recorded (the host does not allow a texture copied onto
536:     itself): 402 of them in a five-minute run.
537:   - The list of shader-visible heaps is a reader-writer lock (recording
538:     threads waited 48 ms a frame, summed, behind the heap sync); the heap
539:     sync looks at a changed page's records under one lock, fingerprint
540:     first; guarded view memory is left out of a submission's write-watch
541:     askings ahead (after triippywhale).
542:   - `VICTORY_COPY_PLAIN=1`: copies of title memory made in place by this
543:     process, with a handler that falls back to the kernel's copy on a
547:     faulted is left alone for two seconds (4 to 9 faults a frame). The
548:     submit thread's kernel time fell from 44 to 20 ms a frame; the
549:     picture is the same.
550:   - The layer's submit and copy-back threads ask for the fast cores of a
551:     hybrid processor (`VICTORY_FAST_CORES=0`: not): the submit thread was
552:     found on a slow core in 6 % of its looks, now in none of 21,059.
558:     `VICTORY_BACK_OWN_VIEW=1` (picture to be checked),
559:     `VICTORY_ASYNC_PRESENT=1` (the present goes behind the queue's line;
560:     no gain while the card is the limit).
566:     frame log found the title's render and recording threads on fast
567:     cores in every look of a run, and the layer's submit thread on a slow
568:     core in 6 % of its looks.
569:   Still open: the per-record clamp is most of the card's time, and the
570:   copies between the PC's memory and the card's are most of the submit
571:   thread's; the cause of the one device loss with windows is not known.
572:   A first play session past the first rooms reached the open world and
574:   the card had no room for new textures from the opening cutscene on
575:   (9.2 of a 10.3 GB budget on a 12 GB card; 2,073 passes made no texture
576:   for lack of room; 44,613 textures let go and made again in 13 minutes).
578: - Known and counted, not fixed yet: an indirect compute pass asks for
579:   about 77,500 thread groups in x where one dispatch runs 65,535 (the
580:   rest is cut off).
581: 
582: Memory sync between the title's memory and the copies on the card:
583: - **A write through one view of a physical page is seen by the copies taken
590:   in some runs.
591: - Kernel reads into title memory are read beside and copied in, so a block
592:   guarded again in between no longer fails the read.
598: 
599: Card memory (the test card is full from the first frame of the world: 85 to
600: 99 % of its budget for a whole run, about 26,000 texture copies let go and
601: 3,400 made again in five minutes, 2.8 GB of render targets that are all in
602: use):
603: - Levels on demand, **off by default** (`VICTORY_LEVELS_ON_DEMAND=1`): a
604:   texture the title fills takes card memory only for the levels the title
605:   holds (2.2 to 3.0 GB of the copies were levels it does not hold). Its test
606:   runs on the software adapter; it has not run on a card yet.
607: - Refused texture slots are held back for a few seconds so that a pass
608:   reaches the slots behind them (`VICTORY_FULL_CARD_PASS=0` = as before);
612: Tools and diagnostics:
613: - `victory translate <shader file> --warm all --jobs N` translates every
614:   shader ahead of a run, on the processor only (about 4.5 to 6.5 minutes
615:   here); the shader cache is keyed on the translator's source, so a new
616:   build that does not touch the translator starts warm.
619:   copy-backs), `VICTORY_WALLS_TRACE`, `VICTORY_CARD_ACCOUNTING`, and a census
620:   of the copies the texture sweep never lets go.
621: 
624: Rendering:
625: - Meshlet culling read its scene buffers as the wrong kind of view, so the world drew almost nothing; fixed.
626: - Per-draw descriptor tables could run out, after which draws used slots never made for them and the card hung; fixed.
627: - Light packed by the game's compute shaders was read back through empty copies (sky, probes, fog); fixed for every mip level and layer.
628: - The fog reconstruction, shadow-mask, hair, blend-shape skinning, fire and several material programs did not translate; fixed.
629: - Gathers at a named mip level (with and without an offset) read level 0; fixed.
630: - Implicit-level samples outside pixel shaders produced invalid DXIL in 730 compute programs; fixed.
631: - Rectangle lists, depth and stencil twins for depth textures written by compute, texture read-backs.
632: - Ray tracing, in progress and off by default: the game's own structure-builder programs translate, title memory can be read by raw address from shaders, the hardware ray/box and ray/triangle test is emulated in DXIL (checked against a reference on the GPU), and 59 of the 64 trace programs translate. Nothing is lit by it yet. See [docs/fork-ray-tracing.md](docs/fork-ray-tracing.md).
633: 
634: Speed and memory:
635: - Waits for memory values, write-watch queries and page queries no longer walk page tables per call.
636: - Large title buffers get a copy in card memory, with shader writes found by hashing on the card.
637: - Submissions can be sent ahead of the wait for the card (`VICTORY_LATE_WAIT`), with a relay thread that lands results as the card finishes (`VICTORY_RELAY`): in a first five-minute run the card's idle time behind the submitting thread fell from about 136 to 30 ms per frame.
638: - Title memory can be opened as a graphics heap so that buffers are used in place instead of copied (`VICTORY_INPLACE`, first stage only; a probe confirmed the approach on the test GPU).
639: - The bindless texture queue no longer uploads stale views; the view table no longer grows without bound; the pipeline library is mapped instead of read into memory.
640: - An intermittent device loss was traced to the pipeline library file being replaced while mapped; fixed. A library the driver rejects is kept under another name and never saved over.
641: 
652: - The interior of the first gameplay room is sometimes not drawn after the cutscene hands over to gameplay.
653: - Around 24 GB of memory is in use during play, about 16 GB of it in memory: the 32 GB test PC has about 1 to 5 GB free, and the 12 GB card is nearly full, so textures are let go and made again for lack of room.
654: - A few style lints are switched off for this fork in the workspace `Cargo.toml` until the newer code is tidied.
673: 
674: **Not playable yet.** The title boots, runs its menus at its own 30 fps and
675: loads the world, where rendering fails.
678: |-------|-------|
679: | Boot, first-boot screens (accessibility, language, settings, legal) | works, 30 fps |
680: | Intro video with sound | works |
684: 
685: Tested on one machine: Windows 11, AMD RX 6700 XT.
686: 
687: > **Warning.** Entering the world on a real GPU can currently hang it, and
688: > Windows then resets the display driver (every monitor goes black for a
695: |-----------|-------|-------|
696: | Loader | Runs the title's executable and its DLLs in our process; crash reports name the faulting code and are kept in `crashes.log` | – |
697: | Runtime services | One signed-in offline user, licences, packages, saves that survive a kill at any step, text entry dialog | Speech is silent; the dialog and relaunch are untested live |
698: | Network | Offline by design: the title cannot reach the network | – |
699: | Files and streaming | Archives and streamed data read, zlib and BCPack decoded in parallel | Loading is limited by writes into title memory |
700: | Input | XInput pads, keyboard, keyboard stand-in pad | Trigger rumble |
701: | Audio | Menu, video and loading sound; XMA voices and Opus streams decode | Reverb is silent; Opus results unverified against the title |
702: | GPU: menus | Draws, compute and presentation on host D3D12; only changed title memory is copied | Frame pacing drifts on one screen in release builds |
703: | GPU: world | Mesh pipelines, shader-written buffers, descriptor lifetimes, indirect execution (arguments clamped), pipelines made by worker threads and kept on disk | Most of the scene is still missing (untranslated shaders drop draws); frames take seconds; real queries, depth bounds, HDR and scaling are missing |
704: | Shaders | Console GPU code recompiled to DXIL at first use, cached on disk. Menus: all. World: mesh 8,191 of 8,506, vertex/pixel 10,617 of 12,346, compute 1,643 of 2,539 | 64-bit image atomics, merged geometry stages, the ray-tracing builder's shaders; some compute programs need a GPU with 64-lane waves |
710: Requirements: Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with
711: shader model 6.6 (and mesh shaders for the world), Rust (pinned in
712: `rust-toolchain.toml`).
714: The title also needs several GiB of available Windows commit at startup.
715: Check **Committed** under **Task Manager → Performance → Memory**. If
716: `crashes.log` reports Windows error 1455, close other applications or increase
734: are kept under the data folder (default `%LOCALAPPDATA%\victory\data`), derived
735: data under the cache folder.
736: 
754: victory lib-exports <import.lib> [--list]
755: victory shader-info [paths...] [--verbose] [--disasm]
756: victory translate [paths...] [--validate] [--pipelines] [--list] [--jobs N]
775: | `VICTORY_LOG=<target>=debug,...` | debug and trace output |
776: | `VICTORY_STACKS=20,60` | every thread's stack at those seconds |
777: | `VICTORY_WATCH=<rva>,...` | logs a title u32 when it changes |
778: | `VICTORY_KEYS=30:Enter,35:X` | presses keys at those seconds, focus or not |
779: | `VICTORY_CRASH_SAVE=<rva>:<len>,...` | saves title memory to the cache folder on a crash |
780: | `VICTORY_CAPTURE=<dir>` | saves presented frames (powers of two, or `VICTORY_CAPTURE_FRAMES=<list>`) |
782: | `VICTORY_D3D12_DEBUG=1` | host debug layer |
783: | `VICTORY_D3D12_GBV=1` | with the above, GPU-based validation (bad descriptor use reported, not faulted; slow) |
784: | `VICTORY_D3D12_DRED=1` | on a GPU failure, the allocation hit and the commands in flight |
785: | `VICTORY_PIPELINE_WAIT_MS=24` | reduce the per-frame wait for background pipeline creation from the default of 500 ms. A draw can be omitted until its pipeline is ready |
786: | `VICTORY_SKIP_PIPELINES=<hash>,...` | omit draws and dispatches, including indirect ones, whose pipeline contains a listed 16-digit shader hash |
787: | `VICTORY_GPU_TIMING=1` | with the above, each list of a submission run and timed on its own; slow lists logged with their slowest commands |
788: | `VICTORY_D3D12_WARP=1` | host device on the software adapter (slow; cannot reset the driver) |
789: | `VICTORY_SHADER_LOOP_LIMIT=<n>` | translated shader loops stop after `n` iterations per lane instead of 2^20 (own shader cache entries); if a lower `n` makes world frames much faster, loops hitting the limit are what makes them slow |
790: | `VICTORY_AUDIO_CAPTURE=<file.wav>` | records what the title plays (our process only) |


===== Marvisak/VIctory =====
14: world.** Nothing else keeps the game from working: the title boots, runs its
15: menus at its own 30 fps, loads the world, plays the intro cutscene and
16: reaches the **prologue**, the mission after it, with the graphics fully
20: |-------|-------|
21: | Boot, first-boot screens (accessibility, language, settings, legal) | works, 30 fps |
22: | Intro video with sound | works |
24: | Loading into the world (about a minute) | works |
25: | The intro cutscene | plays at about 1 fps (0.9-1.0 s a frame, warm cache, quiet machine): textured and lit characters with whole hair, buildings, sky, depth of field, the title card, credits and interface. Missing: ray-traced shadows and indirect light, the local-light shadow mask. Seen in some shots: a pink band over nearer bodies, a stand-in head on a secondary character for a few frames |
26: | The prologue | reached; the graphics are fully displayed, at about 1 fps |
27: 
28: In the intro cutscene at 1 fps the opening credits land over other shots than
29: on a console: they follow the frame count, the shots follow the clock.
30: 
31: Tested on one machine: Windows 11, AMD RX 6700 XT (12 GB).
32: 
43: |-----------|-------|-------|
44: | Loader | Runs the title's executable and its DLLs in our process; crash reports name the faulting code and are kept in `crashes.log` | – |
45: | Runtime services | One signed-in offline user, licences, packages, saves that survive a kill at any step, text entry dialog | Speech is silent; the dialog and relaunch are untested live |
46: | Network | Offline by design: the title cannot reach the network | – |
47: | Files and streaming | Archives and streamed data read, zlib and BCPack decoded in parallel | Loading is limited by writes into title memory |
48: | Input | XInput pads, keyboard, keyboard stand-in pad | Trigger rumble |
49: | Audio | Menu, video and loading sound; XMA voices and Opus streams decode | Reverb is silent; Opus results unverified against the title |
50: | GPU: menus | Draws, compute and presentation on host D3D12; only changed title memory is copied | Frame pacing drifts on one screen in release builds |
51: | GPU: world | The scene is drawn and presented: mesh pipelines, indirect execution, views the shaders pick from the heap themselves, title memory read by address, depth written from compute, lists that wait for values other queues write, textures made when a shader first reads them, pipelines pre-built or made by worker threads and kept on disk, depth bounds on supporting adapters (synthetic tests) | The title's ray-tracing structures are never built (no ray-traced shadows or indirect light in the intro cutscene); about 1 s a frame; draws of untranslated shaders are dropped; real queries, HDR and scaling are missing |
52: | Shaders | Console GPU code recompiled to DXIL, ahead of time (`translate --cache`) or at first use, cached on disk. Menus: all. World: all but under 300 of 24,387 programs | Merged geometry stages (195 programs) and under 100 others; fused multiply-adds follow the host GPU; some compute programs need a GPU with 64-lane waves |
53: | Textures | Console tiled layouts and detiling for the modes the title uses | Render-target metadata planes |
58: Requirements: Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with
59: shader model 6.6 (and mesh shaders for the world), Rust (pinned in
60: `rust-toolchain.toml`).
75: 
76: A run in the world takes about 33 GB of Windows commit (RAM plus paging
77: file) and about 10 GB of video memory. The tested machine has 32 GB of RAM
78: and a commit limit of about 80 GB. Check **Committed** under **Task Manager →
79: Performance → Memory**. If `crashes.log` reports Windows error 1455, close
80: other applications or increase the Windows paging file size, then retry.
92: cargo build --release -p victory
93: target\release\victory.exe translate --cache --pipelines <game dir>\shaders.rpf <game dir>\<the title's exe> <game dir>\XboxBvhBuilder.dll <game dir>\amd_fidelityfx_upscaler_xbox.dll
94: target\release\victory.exe run <game dir>\<the title's exe> --execute
96: 
97: The `translate --cache` step (minutes; again after a change of the shader
98: translator) translates every shader the title can ask for into the cache
99: (about 1.3 GB), so a run does not translate them while it plays; without it
100: they are translated at first use, and their draws wait. With `--pipelines`
101: it then makes every pipeline in the title's shader pack (inside
102: `shaders.rpf`) into the host pipeline library (about 27,000 pipelines, 4 MB;
103: estimated at 20 minutes on 16 threads, but about 2 pipelines a second after a
114: 
115: Upscaling (Series S mode): the title upscales with AMD FidelityFX. To run
116: it with the PC build on your GPU instead of the console build, get the
124: are kept under the data folder (default `%LOCALAPPDATA%\victory\data`), derived
125: data under the cache folder.
126: 
151: victory lib-exports <import.lib> [--list]
152: victory shader-info [paths...] [--verbose] [--disasm] [--effects]
153: victory translate [paths...] [--validate] [--pipelines] [--list] [--jobs N]
154: victory translate [paths...] --cache [--pipelines] [--jobs N]
155: victory run <exe> [--execute] [--unimplemented trap|zero] [--strict]
165: 
166: ### Windows shader-test validator
167: 
168: The shader tests use `dxil.dll` to validate Shader Model 6.6 containers.
169: An older Windows SDK validator can load successfully but reject them with
170: `Unknown shader model 'ps_6_6'`. If this happens, use a current x64 validator
171: from [Microsoft's DirectX Shader Compiler releases](https://github.com/microsoft/DirectXShaderCompiler/releases)
172: or a current Windows SDK. Set its path for the test session:
175: $env:VICTORY_DXIL = 'C:\tools\dxc\bin\x64\dxil.dll'
176: cargo test -p victory-shader --lib --locked -- --test-threads=1
177: ```
196: | `VICTORY_LOG=<target>=debug,...` | debug and trace output |
197: | `VICTORY_STACKS=20,60` | every thread's stack at those seconds |
198: | `VICTORY_WATCH=<rva>,...` | logs a title u32 when it changes |
199: | `VICTORY_POKE=<rva>:<byte>,...` | writes a title byte twice a second (a hang watchdog's tick, say) |
200: | `VICTORY_KEYS=30:Enter,35:X` | presses keys at those seconds, focus or not |
201: | `VICTORY_CRASH_BREAKPOINTS=1` | appends first-chance breakpoints to `crashes.log`, including ones a handler may recover from |
202: | `VICTORY_CRASH_SAVE=<rva>:<len>,...` | saves title memory to the cache folder on a crash |
203: | `VICTORY_CAPTURE=<dir>` | saves presented frames (powers of two, or `VICTORY_CAPTURE_FRAMES=<list>`) |
205: | `VICTORY_CAPTURE_WORLD=<list>` | with `VICTORY_CAPTURE`, also saves (and with `VICTORY_DUMP_TARGETS` dumps) the frames at these offsets from the first frame that ran 500 draws (the world's first; its number depends on how fast the title loaded) |
206: | `VICTORY_DUMP_WRITERS=<hash>,...` | with the two above, also the textures a pipeline containing a listed shader hash writes, the first frame it runs, and for its buffers a log line (dwords changed, dwords not zero) |
207: | `VICTORY_PEEK=<hex address>[:<bytes>],...` | in listed frames, those bytes of title memory logged after each submission. Listed frames also log targets of 16 texels or fewer as values, each table view's view words and whether its host slot is null, the host copy of every buffer of 64 bytes or fewer a draw reads (at submission and after its list), and each 1D or 3D texture a dispatch writes, read back right after it |
208: | `VICTORY_D3D12_DEBUG=1` | host debug layer |
209: | `VICTORY_D3D12_GBV=1` | with the above, GPU-based validation (bad descriptor use reported, not faulted; slow) |
210: | `VICTORY_D3D12_DRED=1` | on a GPU failure, the allocation hit and the commands in flight |
211: | `VICTORY_SKIP_PIPELINES=<hash>,...` | skip host pipeline creation and omit draws and dispatches, including indirect ones, when the pipeline contains a listed 16-digit shader hash |
212: | `VICTORY_GPU_TIMING=1` | with the above, each list of a submission run and timed on its own; slow lists logged with their slowest commands; a device removal names the list it happened in and lists all its commands |
213: | `VICTORY_TRACE_SHADERS=<hash>,...` | with `VICTORY_D3D12_DRED`, every draw and dispatch of a listed shader logged with what it binds (user data, heap slots, root views and their first dwords; the first 500, and all of them in listed capture frames); the records of its indirect executions are read back and logged in every frame (records with work, the first four, the frame) |
214: | `VICTORY_D3D12_WARP=1` | host device on the software adapter (slow; cannot reset the driver) |
215: | `VICTORY_PIPELINE_LOG=<file>` | a line per title pipeline created (key, shaders, state), first used, and made or loaded (library name); `translate --cache --pipelines` writes the last kind too |
216: | `VICTORY_PREBUILD_KEYS=<file>` | `translate --cache --pipelines` makes nothing and lists each pack record's key, shaders and state (or why it is skipped) |
217: | `VICTORY_SHADER_LOOP_LIMIT=<n>` | translated shader loops stop after `n` iterations per lane instead of 2^20 (own shader cache entries); if a lower `n` makes world frames much faster, loops hitting the limit are what makes them slow |
218: | `VICTORY_AUDIO_CAPTURE=<file.wav>` | records what the title plays (our process only) |


===== xcl-dev/xcl =====
9:   <img alt="Windows 10 / 11 x64" src="https://img.shields.io/badge/Windows-10%20%2F%2011%20x64-2f80ed?style=for-the-badge">
10:   <img alt="Direct3D 12, Shader Model 6.6" src="https://img.shields.io/badge/D3D12-SM%206.6-1fb9d8?style=for-the-badge">
11:   <img alt="Rust" src="https://img.shields.io/badge/Rust-stable--msvc-1fb9d8?style=for-the-badge">
37: <p align="center">
38:   <img src="assets/readme/status.svg" width="100%" alt="A newer retail game, about 60 % of the way to playable (estimate): ~4 s to its first frame, 30 fps in its menus, ~5 fps in its 3D world, 100 % of its shaders translate">
39: </p>
46: | **XDefiant**<br><sub>`Ubisoft.XDefiant-Game` 1.0.0.186</sub> | ✅&nbsp;works | works fully, as far as the game allows without its servers | the game's own servers have been shut down |
47: | **A newer retail game** | 🚧&nbsp;**≈&nbsp;60&nbsp;%**<br><sub>estimate</sub> | starts in ~4 s, runs at a steady 30 fps without a crash, shows its menus and goes on past the first one to its settings; fits a 32 GB machine (~15 GB committed in the menus). With the NVIDIA integration branch ([#2057](https://github.com/xcl-dev/xcl/pull/2057)) it goes on into its 3D world: **~5 fps there** on an RTX 5090 (14 fps on average over a whole 5-minute run, its menus and loading included) | not playable yet: the picture of the world is incomplete (its minimap and other mesh pipelines are refused), and it does not keep running there for long |
48: 
57:     <td width="33%" valign="top" align="center">
58:       <img src="assets/readme/icon-shader.svg" width="56" alt=""><br>
59:       <p align="left"><b>100 % of a retail game's shaders translate</b> – all 26 698 RDNA2 programs (26 503 records) of its shader pack become HLSL; random samples compile to DXIL with 0 errors.</p>
60:     </td>
62:       <img src="assets/readme/icon-dll.svg" width="56" alt=""><br>
63:       <p align="left"><b>The game's own console DLLs run on the PC</b> – its Bink 2 video codec decodes the game's movies, its ray-tracing BVH builder builds acceleration structures on a PC GPU, the AMD FSR 4 console upscaler runs a whole frame on a PC GPU, the GDK HTTP library initialises.</p>
64:     </td>
67:     <td width="33%" valign="top" align="center">
68:       <img src="assets/readme/icon-texture.svg" width="56" alt=""><br>
69:       <p align="left"><b>Console textures decode exactly</b> – the GFX10 tiling and mip layout reproduce 909 of 912 textures of the game's texture archive byte for byte, its volume textures included.</p>
70:     </td>
72:       <img src="assets/readme/icon-storage.svg" width="56" alt=""><br>
73:       <p align="left"><b>The console's storage queues</b> – DirectStorage with file and memory sources, zlib and BCPack (BC1, BC3 – BC7).</p>
74:     </td>
84: <p align="center">
85:   <img src="assets/readme/how.svg" width="100%" alt="How XCL works: the game's x64 code goes through the PE loader to the CPU and calls the console system libraries, which XCL implements; its RDNA2 shaders go through the shader recompiler to the Direct3D 12 driver and the GPU; its textures, sound and video go through XCL's memory, textures and DirectStorage">
86: </p>
88: The game's code runs on the CPU as it is; each call into a console library lands in XCL's own
89: implementation of it, and each shader is translated once and cached. The details:
90: [`docs/specs/2026-11-20-xcl-design.md`](docs/specs/2026-11-20-xcl-design.md), status and
121: <details>
122: <summary><b>Running the game's code</b> – PE loader, kernelx, Memory, File system, DirectStorage</summary>
123: 
126: | **PE loader** | ✅ | relocations, imports by name / ordinal / delay-load, TLS callbacks, exception tables, game DLLs, data-driven import routing (HLE / Windows / stub) | the game's 16 console DLLs load with 0 unresolved imports |
127: | **kernelx** | ✅ | title memory (budget from MicrosoftGame.Config, physical pages), threads on the PC's processors, modules, OS / console info | unit + end-to-end tests |
128: | **Memory** | ✅ | title graphics memory shared by CPU and GPU without copies, up to 16 GB (4 GiB windows) | GPU tests: loads, stores and atomics across windows |
129: | **File system** | ✅ | console paths (`GAME:`, `G:`, `D:` …) → the game folder; writes go to an overlay, the game folder is never modified; the console's drives: `S:\` (persistent local storage) and `T:\` (temp) in the title's data folder; free disk space answered for console paths | end-to-end: the test title's folder stays byte-identical; PLS and free space through the real call path |
130: | **DirectStorage** | ✅ | the console's DirectStorage queues: file and memory sources, zlib, and BCPack – the console's texture compression – for BC1, BC3, BC4, BC5, BC6H and BC7 (BC2 and the hardware swizzle are refused) | unit tests on synthetic streams; retail BCPack chunks of all six modes byte-identical with a reference decoder (`XCL_SAMPLE_BCPACK`) |
131: 
138: |---|---|---|---|
139: | **XGameRuntime** | ✅ | the GDK thunk protocol real titles use, laid out from a table of all 396 GDK runtime functions; offline XUser, XGameSave, persistent local storage, XPackage, XGame (title id), XSystem – the title sees an Xbox Series X / S; task queues, async, networking and dialogs through the PC's XGameRuntime | the game's libHttpClient initialises; users, saves and storage through the real call path; slot layout cross-checked against the game's own thunks |
140: | **Input** | ✅ | GameInput: one gamepad – the PC's XInput controller or a PlayStation controller, and keyboard and mouse as a gamepad (see [Controls](#controls)) | unit tests; an Xbox controller in Minecraft; a DualShock 4 (USB) |
145: <details>
146: <summary><b>Graphics</b> – Shader recompiler, Pipelines, D3D12.X compute, D3D12.X graphics, Textures, Ray tracing, Upscaling</summary>
147: 
149: |---|---|---|---|
150: | **Shader recompiler** | ✅ | RDNA2 → HLSL → DXIL: VS, PS, CS, mesh (NGG), GS; atomics, LDS, scratch, images, samplers incl. static ones, wave ops, ray-tracing instructions; structured control flow; parallel DXC, disk cache | 26 698 / 26 698 programs of the retail pack; 0 DXC errors on random samples; per-instruction GPU tests |
151: | **Pipelines** | ✅ | PSOs from console shaders: VS+PS, CS, MS+PS, VS+GS+PS; root signature with the shaders' static samplers; non-blocking creation – a pipeline whose shaders are not compiled yet gets a stand-in at once and is built in the background | GPU tests drawing the game's own VS / PS pairs, also built in the background |
152: | **D3D12.X compute** | ✅ | console device slots, console descriptor heaps (T# / V# / S#), buffers at their console addresses, compute command lists recorded in the console format and replayed (tables, barriers, clears, copies) | the game's BVH builder and FSR 4 record and run through XCL |
153: | **D3D12.X graphics** | ✅ | device, resources and heaps (also placed in title memory), pipelines; the title's graphics command lists – draws, indirect draws, graphics root arguments, barriers, copies, clears – and command lists recorded by console code, replayed; `PresentX` and frame pacing into an XCL window | Minecraft Preview plays its worlds (millions of draws, none skipped); Fortnite and XDefiant draw their screens |
154: | **Textures** | ✅ | GFX10 tiling (all 14 2D swizzle modes, the 6 3D thick modes, linear), mip chains with mip tail, arrays, cubes and 3D textures → PC textures | 909 / 912 retail textures exact (the 3 volume LUTs decode smooth); GPU upload bit exact |
155: | **Ray tracing** | ✅ | BLAS / TLAS built on the GPU by the game's own XboxBvhBuilder; RDNA2 BVH node format; BVH intersection instructions emulated in shaders | GPU traversal = brute force reference; the game's builder output checked on the GPU |
156: | **Upscaling** | ✅ | the game's AMD FSR 4 console DLL (`amd_fidelityfx_upscaler_xbox.dll`): context, the 29 pipelines in the console driver's own container (FSPX) translated, a frame's 20 passes recorded and run on the GPU | end-to-end with the real DLL: a 1280×720 → 1920×1080 frame on an RX 9070, the input's gradient in the output |
157: 
168: | **Video** | ✅ | the game's Bink 2 console DLL decodes its movies (720p / 1080p) on the CPU; the game's own YUV → RGB display shaders (`PS_Bink…` in its pack) translate like any other. Bink's GPU-assisted mode needs no Bink-specific support: its compute shaders ship with the game and go through the recompiler too (no game seen using it yet) | a game movie decodes frame by frame, picture checked |
169: | **Tools** | ✅ | `xcl inspect`, `xcl run`, `xcl disasm` (RDNA2, console shader containers), `xcl shaders` (pack statistics, recompile / compile runs), `xcl rpf` | – |
170: 
191: and `dxil.dll`, looked up in `Windows Kits\10\bin\<version>\x64`, next to `xcl.exe` or in
192: `%XCL_DXC_DIR%`), a D3D12 GPU with Shader Model 6.6 and mesh shaders, and the system XGameRuntime
193: (`System32\xgameruntime.dll`, part of Windows / Gaming Services). On **Windows 10** (22H2
202:   folder has DXC 1.7.2308 or 1.8.2502, depending on the SDK's revision). DXC 1.7's DXIL was 2–2.7 times the
203:   size of 1.9's for translated compute programs and took an NVIDIA driver 1.4–2.2 times as long to build
204:   pipelines from ([#156](https://github.com/ivall/xcl/issues/156)). `xcl run` prints the DXC it loaded, and
205:   `report.json` has it under `dxc`. A compute program with many memory-window accesses is compiled
206:   as two libraries, the program and its accessors, and linked, which is much faster for DXC
207:   (`XCL_LINK_MEM=0` turns it off); the linker needs DXC 1.8 or newer. With an older one the first
208:   attempt fails, `xcl.log` says so, and every program is compiled whole after that.
209: - **GPU:** developed on AMD RDNA4. The console's geometry and NGG programs run as a compute pass plus a
210:   mesh pass, so a GPU without mesh shaders draws none of them. On GPUs with 32-lane waves only
211:   (NVIDIA) console wave64 compute, geometry and mesh programs run as two 32-lane halves that exchange
212:   masks and lane values ([`docs/wave64-on-wave32.md`](docs/wave64-on-wave32.md)) – slower than
222: xcl run D:\Game [-- game arguments]        # run
223: xcl disasm <shader.bin> [--hex]            # RDNA2 disassembler (console containers too)
224: xcl shaders D:\data\shaders.rpf --top 50   # pack statistics; --recomp / --compile N
227: xcl shaders D:\data\shaders.rpf --export-hlsl out --record-hash HEX  # exact compute HLSL for investigation
228: xcl shaders D:\data\shaders.rpf --measure-pso HEX --repeat 3         # cold driver PSO timing (cache disabled)
229: xcl rpf D:\data\shaders.rpf --extract NAME --out folder
235: - For compute shaders that XCL can split, the runtime first tries the saved driver blob for
236:   the whole shader. A usable blob lets the GPU run it in one dispatch. If the blob is missing
237:   or the driver rejects it, XCL builds the split pieces.
261:     for a `Wait32BitValueX` / `Wait64BitValueX` that nothing satisfies (2000 ms) and the
262:     watchdog for a GPU queue wait (5000 ms). A value that is not a number above 0 keeps the
263:     default.
264: - Translated shaders are reused across XCL rebuilds when the translator sources and DXC
265:   toolchain are unchanged; `XCL_TRANSLATED_CACHE=0` disables that disk cache.
266: - Direct compute dispatches can split large programs into pipelines built in parallel.
269:   target gets its own piece, up to four times the target. Larger components and indirect
270:   dispatches use the whole pipeline.
271: - Huge pipelines (translated DXIL of `XCL_HUGE_PSO_BYTES` or more, default 262144) built on the
272:   background `xcl-pso*` workers take turns in the driver's compiler: `XCL_HUGE_PSO_CONCURRENCY`
273:   at once (default 1, maximum 64). Pipelines of 4 MiB or more use a separate one-wide lane so
274:   they cannot occupy the ordinary huge-pipeline slot; one of them can therefore run next to the
275:   ordinary ones, and each gated compile starts only with 3 GB of commit free. Smaller pipelines
276:   and those a game thread waits for never wait. `xcl.log` shows each huge one as a numbered
277:   `driver compile start #K` / `driver compile finish #K: … PSO, N B DXIL, M ms` pair (compute
278:   ones with `record HASH`, the console record's hash that `--measure-pso` and
279:   `--export-hlsl --record-hash` take), with whether it was gated and how long it waited;
280:   `XCL_PSO_TRACE=1` logs every driver compile. A huge compute program the driver refuses is
281:   logged with the driver's verdict (`the driver refused the compute PSO of record HASH … with
282:   0x…`): its dispatches are skipped.
285:   those on which the GPU completed at least one operation. For each, it names the translated
286:   pipeline bound at the last operation DRED saw complete and those bound after it, by their
287:   console shaders' hashes (`cs`, `vs` / `ps`, `ms` / `ps`, `vs` / `gs` / `ps`).
288: - `XCL_DSTORAGE_PARALLEL_DECOMPRESS=1` enables parallel CPU decompression for file-backed zlib
289:   requests with virtual destinations. Defaults: four workers and a shared 32 MiB staging budget
290:   (`XCL_DSTORAGE_WORKERS`, `XCL_DSTORAGE_MEMORY_BUDGET_MIB`). Requests retire in queue order.
291: - Every run writes `report.json` (called stubs, unknown D3D12.X slots and interfaces, XGameRuntime
292:   classes asked for, shader statistics, audio formats, crash).
293:   `d3d12.presents` counts presentations, not visible content. With `XCL_FRAME_DUMP=N` (`N > 1`),
305:     line with what the title did in that time (presents, submits, draws, dispatches, frame-event
306:     waits, DirectStorage requests), and a `memory:` line with the process's commit and the video
307:     memory in use. Where the lines stop changing is where the title stopped.
308:   - `XCL_THREAD_DUMP_AT=s1,s2,…`: at each of those seconds after the start, the state of every
309:     thread of the title goes into `xcl.log`, for a title that stalls.
310:   - `XCL_TRACE_FAULTS=1` (any value): the first 32 access violations are logged as they are raised
311:     (read, write or execute, the address, some registers and the callers on the stack), before the
312:     title's own handlers see them – for a title whose crash filter ends the process without a trace.
313:   - `XCL_TRACE_MEM=1` (any value turns it on): the title's memory allocations of 64 KiB or more
314:     are logged, the first 60 (`XCL_TRACE_MEM=n` with `n > 1`: the first `n`). The same variable
315:     also logs XCL's own allocations of 1 MB or more in the title's committed memory window, and
316:     the ones that fail.
325: - Title data: `%LOCALAPPDATA%\XCL\<title>\` (`%XCL_DATA_ROOT%`): `xcl.toml`, `overlay\`, `saves\`,
326:   `pls\` (the title's `S:\`), `temp\` (`T:\`), `cache\`, `logs\xcl.log`, `logs\report.json` (the
327:   previous run's: `xcl.prev.log`, `report.prev.json`).
342: those skips fail. Tests on real game data are opt-in through
343: environment variables pointing at your own files – `XCL_SAMPLE_RPF` (shader pack),
344: `XCL_SAMPLE_DLLS` (the game's console DLLs), `XCL_SAMPLE_TTPF` (texture archive),
345: `XCL_SAMPLE_BCPACK` (a folder of BCPack streams `<name>.bc<mode>` with a reference decoder's blocks of each, `<name>.vic<mode>`), `XCL_SAMPLE_BK2` (a movie), `XCL_SAMPLE_BVH4`, `XCL_SAMPLE_AWC` (a sound) – described in `HANDOFF.md`; without them those
346: tests pass without running anything (`scripts/test.ps1` lists the ones not set). No game data is
358: 
359: **GPL-2.0-only** (`LICENSE`); third-party sources: `THIRD_PARTY.md` (including AMD's
360: machine-readable ISA, AMD addrlib swizzle patterns, LLVM disassembler tests, AnyPS5,
361: libHttpClient headers). WinDurango serves only as a reference – no code is ported from it. The


===== uiliannn/VItoriaBr =====
8: 
9: > **Base e licença:** Fork/continuação baseada no projeto open-source [Marvisak/VIctory](https://github.com/Marvisak/VIctory), com integração das melhorias GPL-3.0 de renderização do mundo 3D, iluminação, relay/VRAM e otimizador DXIL de [fxceless/victory-fork](https://github.com/fxceless/victory-fork), mantido sob a licença **GPL-3.0-or-later** ([LICENSE](LICENSE)). **Este repositório não contém nem distribui nenhum arquivo de jogo** — todos os caminhos de jogo, cache e dados devem ficar fora do repositório ([docs/asset-policy.md](docs/asset-policy.md)).
10: 
14: 
15: **Em desenvolvimento ativo — mundo aberto 3D já renderizando ao vivo!** O título inicia, roda os menus e vídeos a 30 fps cravados, salva perfil/configurações, entra no mundo 3D sem TDR e chega a **até `6 fps`** na RTX 5060 Ti (`3.500–4.400 draws/frame`), com profundidade/iluminação (`OMSetDepthBounds`), água, veículos, HUD e legendas funcionando.
16: 
25: | Rendering | Avaliação do autor: **~95% do console**; mundo aberto iluminado com texturas, terreno, vegetação, água, veículos, pele e HUD; restam glitches menores e algumas áreas/efeitos |
26: | Performance | **30 fps** em menus/vídeos; **4–6 fps** no preset atual do `main`; **22 fps** na melhor medição de mundo aberto com o build experimental do GPT (RTX 5060 Ti, 1080p), ainda não integrado ao preset padrão |
27: | Stability | Sessões longas sem TDR; ainda ocorrem crashes ocasionais na transição para o mundo e em cenas específicas. Não é “stable” |
28: | Hardware | Windows 11 Pro · Ryzen 7 5700X · 40 GB RAM · NVIDIA RTX 5060 Ti 16 GB · título `1.0.2.1` |
29: | Código | Público, GPL-3.0-or-later; 26.599 containers de shader analisados, 25.344 PSOs aceitos na RTX 5060 Ti |
30: 
31: O **22 fps** é uma medição experimental do build do GPT, não do preset padrão desta `main`; o preset padrão continua documentado como **4–6 fps**. O PortWatch classifica por leitura de README/commits e pode manter os valores anteriores até uma revisão manual.
32: 
33: Campos que esta evidência sustenta, para revisão: `playable=1`, `story=0.25` (primeira missão), `render=0.95` (avaliação do autor), `fps=22` (melhor medição experimental) e `stability=0.55` (crashes ocasionais). São dados self-reported; o PortWatch deve confirmá-los com o vídeo/logs antes de alterar a nota.
34: 
35: ### Testes reais em hardware (NVIDIA Blackwell)
36: Testado em: **Windows 11 Pro (build 26300)** · **Ryzen 7 5700X** · **40 GB RAM** · **NVIDIA RTX 5060 Ti 16 GB** (SM 6.6 + Mesh Shaders, driver `621.24`), sobre dump local Xbox Series `1.0.2.1`.
37: 
39: |---------|--------|
40: | Boot, telas iniciais (acessibilidade, idioma PT-BR, configurações, legal) | ✅ Funciona — **30 fps** |
41: | Vídeo de introdução com áudio | ✅ Funciona (render limpo) |
43: | Tela de loading entrando no mundo (~50 s) | ✅ Funciona |
44: | Mundo 3D (cutscene de abertura, sala inicial e mundo aberto) | 🟢 **Renderizando ao vivo na RTX 5060 Ti (até `6 fps`, zero TDR, `1.700–4.400 draws/frame`)** — pele fotorrealista, iluminação ambiente por profundidade (`VICTORY_AMBIENT=0.6`), terreno/vegetação e sombras funcionando |
45: 
46: ### Cobertura de Shaders & PSOs medida na RTX 5060 Ti (`1.0.2.1`)
47: Medido com `victory translate --validate --pipelines` (`dxil.dll` Windows SDK `10.0.26100.0` + driver NVIDIA `621.24`):
48: - **Containers analisados:** `26.599` (`26.148` programas traduzidos para IR e 100% estruturados — `40,6 milhões` de instruções IR).
56: 
57: > Os únicos `397` PSOs recusados pela RTX 5060 Ti são compute shaders que exigem **wave64** (GPUs NVIDIA são wave32).
58: 
59: ### Melhorias já aplicadas no VItoriaBr
60: - **Sync `fxceless/victory-fork` (`4f9a19d`, `b401954`) + Estabilidade & PRs da comunidade (`32d7848`, `aa85bb0`, `faca57e`, `d396d11`, `06161b9`):**
61:   - Depth bounds test (`#82`), renderização completa da primeira sala (`a26859f`), fingerprint barato no sync de descriptors (`9376fd6`) e `VICTORY_RELAY=2` com correção de race condition em `relay_land()` (`aa85bb0`).
62:   - Guard de tempo/bytes (`PASS_BUDGET`, `faca57e`) em `heap_textures` evitando travamento do watchdog de 30 s no 1º frame 3D.
63:   - Fixes de estabilidade do upstream (loader lock deadlock, XMA wrap/continuation, dynamic descriptor wraparound, `SHADER_HEAPS` UAF em `mirror()`/`make_waiting()`).
64:   - PRs da comunidade: **`#6` (`victory warm`)**, **`#3` (Linux portable CI + `docs/visao-geral.md`)**, **`#7` (fix de stride de 16 bytes em `SLOT_VIEWS`)**, **`#10` (RDNA2 LDS bounds checks)**, **`#11` (formatos de textura 189–191)** e **`#12` (packed dot products `dot4AddPacked`)**.
65: - **Assinaturas e interpolação reconciliadas** (`c0b60a0`, `crates/victory-shader/src/emit/{shader,container}.rs`):
66:   - `reconcile_row_interp` foi restaurada (o merge grande a havia removido): elementos empacotados na mesma row compartilham um único modo de interpolação; **~250 shaders** deixaram de falhar no `dxil.dll`.
68:   - Resultado no v7: **`25.588` validados** (eram `25.413`).
69: - **Descritores de tabela com índice calculado lidos como dado (SLOT_VIEWS)** (`b62bbc0`, `18df163`, `77ad907`, `crates/victory-shader/src/emit/lower.rs` + `crates/victory-gpu`):
70:   - A nova root SRV `SLOT_VIEWS` (252) expõe, por slot do heap, o endereço/len/stride da view de buffer; o emissor usa essa tabela quando o console lê o **endereço de um descritor** cujo índice é calculado em runtime.
71:   - `calculateLOD` de texturas array agora deixa a coordenada do slice `undef`, como o DXC exige; isso zerou os `3` `out of bound coord must be undef`.
72:   - Resultado no v13: **`25.741 / 25.758` DXIL (99,9%)**, **`25.670` validados**, **`25.344` PSOs**; as categorias `descriptor read only as data` (40), `out of bound coord` (3) e `descriptor chosen by control flow` (40) foram **zeradas**.
73: - **Dois samplers imediatos escolhidos por branch** (`67bb579`, `c248547`): o phi entre os dois samplers constantes virou um handle de **static sampler range** com índice dinâmico. O seletor é um **phi de caminho no join** (true vindo do segundo predecessor), não `reach[pred]` — este último definia o valor em um predecessor e não dominava o join, invalidando o bitcode. Os **40** shaders da categoria (`37 PS_TexturedLit` + `3 MST_DS`) agora emitem, validam e criam PSO.
74: - **Rastreamento completo de estado de `Shadow` buffers no `HostList`** (`crates/victory-gpu/src/{shadow,host,indirect,draw}.rs`):
76:   - Agora cada `Shadow` buffer rastreia seu estado via `prelude()` e transições intra-lista (`GENERIC_READ` para VB/IB/CBV/SRV/Indirect `args`+`counter`, `UNORDERED_ACCESS` para UAV/clamp), **zerando os erros de barreira no D3D12 Debug Layer** e estendendo significativamente a execução dentro do mundo 3D na RTX 5060 Ti.
77: - **Suporte a `MIMG` `a16` e operações LDS de byte/half** (`2471a62`, `crates/victory-shader/src/emit/lower.rs`):
78:   - `image_sample_b`, `_cl`/`_o`, `image_gather4_l` e leitura/escrita thread-safe de bytes/halves em LDS (`ds_read_{u8,i8,u16,i16}`, `ds_write_{b8,b16}{,_d16_hi}`).
79: - **Reconciliação de modos de interpolação DXIL por row da assinatura** (`5943771`, `crates/victory-shader/src/emit/shader.rs`):
80:   - Elementos que compartilham a mesma row na assinatura passam a emitir o mesmo modo de interpolação, **zerando ~48 erros do validador `dxil.dll`**.
81: - **Reciclagem imediata de slots dinâmicos do descriptor heap** (`a65d054`, `bd33acc`, `crates/victory-gpu/src/{descriptor/host,draw,list,queue}.rs`):
82:   - Os slots voltam ao heap assim que o `host.execute` síncrono termina, e o `MIN_DYNAMIC` sobe para **`2^18` (262.144)** em heaps limitados (NVIDIA, limite de 1.000.000 views), **zerando os 16.384+ draws/dispatches descartados** no mundo 3D.
83: - **Cubemap `image_sample_d_cl`** (`77b4b4c`, `crates/victory-shader/src/emit/lower.rs`):
84:   - `deriv_dwords` ajustado para `grads = 2` em cubemaps (`kind == 5`), destravando +27 shaders.
85: - **Estabilidade de Mesh Shaders, LDS e barreiras na NVIDIA Blackwell (wave32)** (`bd33acc`, `a13a719`, `1ece3a6`, `911267c`, `808a209`, `crates/victory-shader/src/emit/lower.rs`):
86:   - `mesh_prologue` limita `setMeshOutputCounts` ao número de threads para não deixar primitivas não-inicializadas; `emitIndices`, `storeVertexOutput` e `storePrimitiveOutput` validam limites contra `max_vertices`/`max_primitives`.
87:   - Todos os acessos a `LDS` (`ds_read`, `ds_write`, atomics) fazem bounds check fiel ao RDNA2 (OOB lê `0` e descarta escrita, evitando traps de SRAM na NVIDIA).
88:   - `s_barrier` em blocos que não pós-dominam a entrada, dentro de loops ou após `abort_block` emite apenas memory fence (`TGSM_FENCE`/`UAV_FENCE`), prevenindo deadlocks de `BAR.SYNC` em wave32.
89: - **Proteção anti-TDR em submissões e `ExecuteIndirect`** (`1ca533d`, `8a75883`, `6f99f75`, `crates/victory-gpu/src/{host,indirect}.rs`):
90:   - `host::execute()` submete 1 command list por vez com fence wait (evitando acumular >2 s de TDR); `indirect.rs` zera argumentos `DispatchMesh` corrompidos e limita dispatches válidos (`4096` grupos, `BUDGET = 2^22`).
91:   - `VICTORY_SHADER_LOOP_LIMIT` habilitado também em `release` (com padrão `4096`).
92: 
93: > **Aviso de GPU (TDR):** entrar no mundo 3D em uma GPU real ainda pode disparar reset do driver de vídeo (TDR). Para inspecionar sem risco de travar o driver, use o perfil `diag` com `VICTORY_D3D12_WARP=1` (adaptador em software).
94: 
98: 
99: **Requisitos:** Windows 10/11 x64, CPU com AVX2, GPU Direct3D 12 com Shader Model 6.6 + Mesh Shaders, Rust (`rust-toolchain.toml` — toolchain `x86_64-pc-windows-msvc`), VS 2022 MSVC e Windows SDK.
100: 
113: cargo build --release -p victory
114: # (opcional) pré-traduz os shaders para o cache antes da 1ª execução
115: .\target\release\victory.exe warm <pasta_do_jogo>
120: 
121: ### Preset recomendado (testado na RTX 5060 Ti 16 GB — até `6 fps`)
122: ```powershell
123: # Opcional (1x por atualização): pré-aquece todo o cache de shaders antes de abrir o título
124: .\target\release\victory.exe warm <pasta_do_jogo>
125: 
126: # Preset recomendado na RTX 5060 Ti 16 GB (visual completo 4K/1080p, ondas reais, zero pele preta, zero TDR — até 5.8 fps em 4K)
127: $env:VICTORY_RELAY = "2"
147: 
148: ### Preset para GPUs de 8 GB VRAM (AMD RDNA2 / PCIe x4) + HDD
149: O preset acima (`VICTORY_CARD_BUFFERS_MB = "2048"`, `VICTORY_TEXTURE_BUDGET_MB = "10240"`) é dimensionado para placas de 16 GB de VRAM. Em GPUs de **8 GB de VRAM** (como a **Radeon RX 6500 XT**, especialmente em barramentos PCIe 3.0 x4 e com os arquivos em HDD), ajustar os limites de memória para caber com folga evita paginação excessiva, texturas de pele pretas e *driver timeouts* (`0x887A0006`):
150: 
167: 
168: - **Dicas para 16 GB de RAM + HDD:** Feche navegadores e aplicativos pesados antes de iniciar para liberar RAM ao cache de leitura do Windows, e configure um arquivo de paginação (*Pagefile*) manual de **16 GB a 24 GB** no SSD para evitar erro `1455` durante o carregamento.
169: 
170: #### Achados importantes de tuning & diagnóstico
171: - **Pele ou chão pretos (VRAM cheia / streaming):** dois fatores resolvidos:
172:   1. **`VICTORY_CARD_BUFFERS_MB=2048` + `VICTORY_TEXTURE_BUDGET_MB=10240`** (em 8 GB: `1024` e `5120`) evita o limite de 90% da VRAM (`no room for new ones`), que impedia novas texturas de pele/terreno de subir.
173:   2. **`VICTORY_PAGE_WRITES=slots`** re-enfileira automaticamente texturas `placed` que foram subidas antes de o título terminar de gravar seus bytes (recuperou 7.000+ texturas por sessão).
174: - **`VICTORY_TABLE_BUFFERS=1` + `VICTORY_SYNC_NULL_SKIP` (padrão) + `VICTORY_INDIRECT_GATHER=1`:** dobraram o FPS no mundo aberto na RTX 5060 Ti (`2,7 → 5,8 fps` em `3840x2160`, derrubando `preparing` de `~230 ms` para `~105–113 ms` e `copies` para `~37–49 ms`).
175: - **`VICTORY_TEXTURE_BACK=1`:** habilita readback de texturas escritas por shaders (como ondas 3D da água), combinado com layouts XOR swizzle (portado de `myokex/victory-amd` `1544bd5`, GPL-3.0 / Mesa addrlib MIT).
176: - **HUD em tela (`VICTORY_FPS_COUNTER`):** ligado por padrão em 2 linhas no canto superior esquerdo (`VITORIABR | FPS | MS | DRAWS` + `RES | VRAM | GPU`); use `compact` para só FPS ou `0` para desligar.
177: - **`VICTORY_QUEUE2=1` + `VICTORY_ASYNC_SUBMIT=1` + `VICTORY_COPY_PLAIN=1`:** corta `copying back` em **~3×** (`~205 ms → ~65–78 ms`) usando a Copy Queue dedicada, executa ~12.400 cópias in-place/frame (`~290 MB/frame`) sem syscall do kernel e derruba `textures` pela metade (`~40 ms → ~20 ms`).
178: - **`VICTORY_AMBIENT=0.6` (padrão):** ativa o pass de iluminação ambiente com sombreamento por profundidade (portado de `Belobug/VIctory-Belobug-AMD`, GPL-3.0), mantendo personagens, pele, veículos, água e interiores totalmente iluminados enquanto o RTGI completo ainda não roda. Use `0` para desligar.
179: - **`VICTORY_TEXTURE_NO_WAIT=1`**: elimina stalls de lock na leitura de memória do título durante refresh de texturas (`textures` cai de `900–3.700 ms` para `6–25 ms`).
180: - **`VICTORY_DISPLAY_MODE=1920x1080`**: reduz a resolução interna de renderização mesmo em monitores 4K (a janela apenas faz upscale barato no `Present`).
181: - **`VICTORY_CARD_FETCH_INFLIGHT` (deixar desligado / `0`)**: ligá-lo derruba `copying back` de `~162 ms` para `~45 ms`, mas sobrecarrega a GPU (`on the GPU` sobe de `~50–65 ms` para `~200–330 ms`), reduzindo o FPS total na RTX 5060 Ti (`1.9–2.6 fps` vs `3.5–6.0 fps`).
182: - **Duração da sessão:** para ver há quanto tempo o processo está no ar (e a RAM/CPU acumulada):
183:   ```powershell
187:   ```
188:   Exemplo medido (v19, 25/11): **2 h 12 min** de processo, **14,9 GB** de RAM e **~10 h** de CPU acumulada.
189: - **`VICTORY_BVH_BUILDER=1` (RTGI — experimental)**: com a prova de uniformidade do scan, os 3 shaders de `v_readfirstlane_b32` (`39321a95223001ed`, `77360df21e12ea43`, `9fc111d3be79364f`) agora traduzem e validam em wave32; `VICTORY_FIRSTLANE_OWN=1` deixou de ser necessário. Restam 2 PSOs recusados no builder para investigar.
195: Principais variáveis de ambiente no `diag`:
196: - `VICTORY_D3D12_WARP=1` — força adaptador WARP em software (lento, não causa TDR)
197: - `VICTORY_D3D12_DRED=1` — grava breadcrumbs DRED em `crashes.log` se ocorrer `DEVICE_HUNG`
224: 
225: > **Upstream & License:** Derived from [Marvisak/VIctory](https://github.com/Marvisak/VIctory) with GPL-3.0 world-rendering, lighting, relay/VRAM, and DXIL optimizer improvements integrated from [fxceless/victory-fork](https://github.com/fxceless/victory-fork), licensed under **GPL-3.0-or-later** ([LICENSE](LICENSE)). **No game files or derived assets are shipped or allowed in this repository** ([docs/asset-policy.md](docs/asset-policy.md)).
226: 
228: 
229: **Active development — 3D open world rendering live!** Boot, menus, intro video with audio, profile/saves, and loading work at 30 fps; inside the 3D open world on RTX 5060 Ti it runs with **zero TDR** at **up to `6 fps`** (`3,500–4,400 draws/frame`), with depth-bounds lighting, ocean/water, vehicles, HUD, and subtitles.
230: 
239: | Rendering | Author's assessment: **~95% of the console**; lit open world with textures, terrain, foliage, water, vehicles, skin and HUD; minor glitches and some areas/effects remain |
240: | Performance | **30 fps** menus/videos; **4–6 fps** on the current `main` preset; **22 fps** best open-world measurement from the experimental GPT build (RTX 5060 Ti, 1080p), not yet in the default preset |
241: | Stability | Long sessions without TDR; crashes still occur occasionally at world transition and in specific scenes. Not “stable” |
242: | Hardware | Windows 11 Pro · Ryzen 7 5700X · 40 GB RAM · NVIDIA RTX 5060 Ti 16 GB · title `1.0.2.1` |
243: | Code | Public GPL-3.0-or-later; 26,599 shader containers scanned, 25,344 PSOs accepted on RTX 5060 Ti |
244: 
245: The **22 fps** figure is an experimental GPT-build measurement, not this `main` preset's result; the default preset remains documented at **4–6 fps**. PortWatch scores from README/commits and may keep earlier values until a manual review.
246: 
247: Fields this evidence supports, for review: `playable=1`, `story=0.25` (first mission), `render=0.95` (author's assessment), `fps=22` (best experimental measurement) and `stability=0.55` (occasional crashes). These are self-reported; PortWatch should confirm them against the stream/logs before changing the score.
248: 
249: #### Real Hardware Test Results (NVIDIA Blackwell)
250: Tested on: **Windows 11 Pro (build 26300)** · **Ryzen 7 5700X** · **40 GB RAM** · **NVIDIA RTX 5060 Ti 16 GB** (SM 6.6 + Mesh Shaders, driver `621.24`), Xbox Series build `1.0.2.1`.
251: 
253: |-------|--------|
254: | Boot & first-boot screens (accessibility, language, settings, legal) | ✅ Works — **30 fps** |
255: | Intro video with audio | ✅ Works |
257: | Loading into the world (~50 s) | ✅ Works |
258: | 3D world (opening cutscene, first room & open world) | 🟢 **Rendering live on RTX 5060 Ti (up to `6 fps`, zero TDR, `1,700–4,400 draws/frame`)** — photorealistic skin, depth-shaded ambient light (`VICTORY_AMBIENT=0.6`), terrain/foliage and shadows working |
259: 
260: #### Measured Shader & PSO Coverage on RTX 5060 Ti (`1.0.2.1`)
261: Measured via `victory translate --validate --pipelines` (`dxil.dll` Windows SDK `10.0.26100.0` + NVIDIA driver `621.24`):
262: - **Containers scanned:** `26,599` (`26,148` programs translated & 100% structured — `40.6M` IR instructions).
263: 
264: | Stage | DXIL Emitted | Validated (`dxil.dll`) | Host PSOs (RTX 5060 Ti) | PSO Rate |
265: |-------|--------------|------------------------|-------------------------|----------|
270: 
271: > The `397` refused Compute PSOs are wave64-only shaders (NVIDIA GPUs run wave32).
272: 
274: - **Full `Shadow` buffer D3D12 resource state tracking in `HostList`** (`crates/victory-gpu/src/{shadow,host,indirect,draw}.rs`):
275:   - Previously, `indirect::done()` left shared title buffers stuck in `D3D12_RESOURCE_STATE_UNORDERED_ACCESS`, causing `IASetVertexBuffers` and barrier mismatch (`id=527`) errors in the D3D12 Debug Layer.
276:   - Each `Shadow` buffer now tracks its state across lists via `prelude()` and intra-list barriers (`GENERIC_READ` for VB/IB/CBV/SRV/indirect `args`+`counter`, `UNORDERED_ACCESS` for UAV/clamp), **eliminating all buffer state errors in the D3D12 Debug Layer** and significantly extending 3D world execution on the RTX 5060 Ti.
277: - **`MIMG` `a16` support and LDS byte/half operations** (`2471a62`, `crates/victory-shader/src/emit/lower.rs`):
278:   - `image_sample_b`, `_cl`/`_o`, `image_gather4_l`, plus thread-safe byte/half reads and writes in LDS (`ds_read_{u8,i8,u16,i16}`, `ds_write_{b8,b16}{,_d16_hi}`).
279: - **Per-row DXIL interpolation mode reconciliation on the signature** (`5943771`, `crates/victory-shader/src/emit/shader.rs`):
280:   - Elements sharing the same signature row now emit the same interpolation mode, **clearing ~48 `dxil.dll` validator errors**.
281: - **Immediate recycling of dynamic descriptor-heap slots** (`a65d054`, `bd33acc`, `crates/victory-gpu/src/{descriptor/host,draw,list,queue}.rs`):
282:   - Slots return to the heap as soon as the synchronous `host.execute` completes, and `MIN_DYNAMIC` rises to **`2^18` (262,144)** on capped heaps (NVIDIA, 1,000,000-view limit), **eliminating the 16,384+ dropped draws/dispatches** in the 3D world.
283: - **Cubemap `image_sample_d_cl`** (`77b4b4c`, `crates/victory-shader/src/emit/lower.rs`):
284:   - Uses `grads = 2` for `deriv_dwords` on cubemaps (`kind == 5`), unblocking +27 shaders.
285: - **Mesh Shader, LDS, and barrier safety on NVIDIA Blackwell (wave32)** (`bd33acc`, `a13a719`, `1ece3a6`, `911267c`, `808a209`, `crates/victory-shader/src/emit/lower.rs`):
286:   - `mesh_prologue` caps `setMeshOutputCounts` to thread count so no uninitialized primitives are left; `emitIndices`, `storeVertexOutput`, and `storePrimitiveOutput` enforce `max_vertices`/`max_primitives` bounds.
287:   - All `LDS` reads, writes, and atomics enforce RDNA2-accurate OOB semantics (read `0`, drop writes) to prevent NVIDIA shared-memory traps.
288:   - `s_barrier` in non-post-dominating, loop, or post-`abort_block` blocks emits a memory-only fence (`TGSM_FENCE`/`UAV_FENCE`), preventing `BAR.SYNC` deadlocks on wave32.
289: - **Anti-TDR submission chunking & indirect bounds** (`1ca533d`, `8a75883`, `6f99f75`, `crates/victory-gpu/src/{host,indirect}.rs`):
290:   - `host::execute()` submits one command list per fence wait; `indirect.rs` zeroes out-of-range `DispatchMesh` arguments and caps valid dispatches (`4096` groups, `BUDGET = 2^22`).
291:   - `VICTORY_SHADER_LOOP_LIMIT` enabled in `release` builds as well (default `4096`).
292: 
293: > **Warning:** Entering the 3D world on a real GPU can still trigger a display driver reset (TDR). Use a `diag` build with `VICTORY_D3D12_WARP=1` to inspect safely on the software adapter.
294: 
301: cargo build --release -p victory
302: .\target\release\victory.exe warm <game_dir>   # optional: pre-translate shaders into the cache first
303: 
304: # Recommended preset tested on RTX 5060 Ti 16 GB (up to 5.8 fps in 4K, real 3D waves, zero black skin, zero TDR)
305: $env:VICTORY_RELAY = "2"
325: 
326: #### Preset for 8 GB VRAM GPUs (AMD RDNA2 / PCIe x4) + HDD
327: The 16 GB preset above (`VICTORY_CARD_BUFFERS_MB = "2048"`, `VICTORY_TEXTURE_BUDGET_MB = "10240"`) exceeds 8 GB cards. On **8 GB VRAM GPUs** (such as the **Radeon RX 6500 XT**, especially over PCIe 3.0 x4 and with files on an HDD), lowering the budgets avoids paging, black skin textures, and display driver timeouts (`0x887A0006`):
328: 
345: 
346: - **16 GB RAM + HDD tips:** Close browsers and heavy background apps before launching to leave RAM for Windows file caching, and set a manual **16 GB–24 GB** SSD pagefile to prevent Windows error `1455` during loading.
347: 
348: > **Tuning notes (RTX 5060 Ti & 8 GB GPUs):** Enabling `VICTORY_TABLE_BUFFERS=1`, `VICTORY_INDIRECT_GATHER=1`, and `VICTORY_SYNC_NULL_SKIP` (default on) doubled open-world FPS on RTX 5060 Ti (`2.7 → 5.8 fps` at `3840x2160`, cutting `preparing` from `~230 ms` to `~105–113 ms`). `VICTORY_TEXTURE_BACK=1` restores shader-written water wave textures. The 2-line performance HUD (`VITORIABR | FPS | MS | DRAWS` + `RES | VRAM | GPU`) is controlled via `VICTORY_FPS_COUNTER` (`1`/`full` default, `compact`, or `0`). Use `VICTORY_CARD_BUFFERS_MB=2048` + `VICTORY_TEXTURE_BUDGET_MB=10240` on 16 GB GPUs (`1024` / `5120` on 8 GB GPUs) together with `VICTORY_PAGE_WRITES=slots` to prevent `the card has no room for new ones` and re-upload late-written placed textures (fixing black skin and ground). Keep `VICTORY_CARD_FETCH_INFLIGHT` off (`0`, default). To check session uptime, RAM and accumulated CPU:
349: >
355: >
356: > Measured example (v19, Nov 25): **2 h 12 min**, **14.9 GB** RAM, **~10 h** CPU.
357: 


===== Linox-IDK/LNX-victory =====
5: runs an Xbox Series title natively on Windows from files the user supplies.
6: This fork is tuned for **8 GB NVIDIA cards** (tested on an RTX 5060 Ti 8 GB,
7: Ryzen 5 9600X, 32 GB RAM, Windows 11).
8: 
13: 
14: **Reaches gameplay (the prison yard, "Move around") at about 4 fps on an 8 GB RTX 5060 Ti.** Series X
15: profile, 1080p output.
18: | --- | --- |
19: | Boot, menus | works, 30 fps |
20: | Opening cutscene, prison yard | plays in 3D: hair, haze, sun shafts, textures |
21: | Frame rate in the world | 3.3-4.6 fps (was 1.3): `VICTORY_CARD_FETCH_INFLIGHT` off (it tripled GPU time, a VItoriaBr finding) and `VICTORY_TEXTURE_NO_WAIT=1` |
22: | Textures | fixed for 8 GB cards: the texture-skip switch now really works (~4 GB of card memory saved) |
23: | Shaders | 268 translator tests pass; 245 of 26,599 shaders do not translate (was 337); in a run only 2-4 compute programs fail, no pipeline is refused |
24: | Ray tracing | its structure builder now gets all 53 pipelines, but the title crashes when it runs, so it stays off |
25: | Shadowed areas, skin | lit by a constant ambient floor (from Belobug/VIctory-Belobug-AMD, `VICTORY_AMBIENT`) until ray-traced light runs |
26: | Stability | no driver hang or device loss; no crash with default settings |
27: 
29: 
30: - **Texture memory for 8 GB cards** (`VICTORY_TEXTURE_SKIP_MIPS=1`): big
31:   block-compressed textures become tiled resources with memory only from
32:   their second level down (about 4x less each); views clamp sampling there.
34:   made every one fail before).
35: - **Shader work merged from the other ports**: fxceless's latest main (first room
36:   rendering, skin and hair textures, levels on demand, in-flight copy-back,
38:   instructions, 64-bit shifts and mul_hi without INT64, wave64 barriers,
39:   ds_permute across two waves, a 256-thread GPU compare shader, LTO build),
40:   24+ upstream VIctory fixes (f16 interpolation op_sel/omod/clamp, helper-lane
48:   waves for LDS shared inside a lane branch run as two waves of 32; this is
49:   what lets the shadow and ray-tracing builder programs get pipelines on NVIDIA.
50: - **Shader cache that survives rebuilds**, **offline pre-compiling**
51:   (`VICTORY_WARM_CACHE=1`), **pipeline builders that are not starved**,
52:   the **R9G9B9E5 colour fix**, **Series S** composition.
53: - **Ambient light floor** (from [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)):
54:   after the title's screen-probe resolve, its indirect diffuse light is a
57: - **Diagnostics**: every silent draw drop names its reason;
58:   `VICTORY_PSO_DUMP=<dir>` saves the blocks of the console pipeline calls
59:   0x1c8/0x218 that are not implemented yet (16,000+ calls a run).
88:   the world rendering, lighting and speed work this fork builds on.
89: - **[VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)** by Belobug (ambient light floor),
90:   **[VItoriaBr](https://github.com/uiliannn/VItoriaBr)** by Uilian (shader fixes, the 5060 Ti preset findings),
91:   **[ztrx](https://github.com/Zettrox/ztrx)** by Zettrox (pull requests).
109: 
110: - Series S + host FSR: 7-8 fps on an RTX 5060 Ti 8 GB, GPU ~66% busy (CPU-side bound).
111: - NPC faces lit by the skin fill; player skin still black; ambient 0.6 makes the fog glow
116: **Not playable yet, but the world renders.** The title boots, runs its menus
117: at 30 fps, plays its opening cutscene in 3D and reaches the first gameplay.
118: 
120: | --- | --- |
121: | Boot, first-boot screens (accessibility, language, settings, legal) | works, 30 fps |
122: | Intro video with sound | works |
125: | Opening cutscene | plays in 3D with correct colours; title and credit cards render |
126: | First gameplay (prison) | reached; characters, cars, sky and sunlight draw; about 2.5 fps on average, 4-4.6 fps in lighter shots |
127: 
128: Tested on: Windows 11, NVIDIA RTX 5060 Ti 8 GB, Ryzen 5 9600X, 32 GB RAM,
129: Series X profile, 1080p output. No driver hang or device loss in our runs
130: (with `VICTORY_SHADER_LOOP_LIMIT=1024`).
135: | --- | --- | --- |
136: | Loader | Runs the title's executable and its DLLs in our process; crash reports name the faulting code and are kept in `crashes.log` | – |
137: | Runtime services | One signed-in offline user, licences, packages, saves that survive a kill at any step, text entry dialog | Speech is silent; the dialog and relaunch are untested live |
138: | Network | Offline by design: the title cannot reach the network | – |
139: | Files and streaming | Archives and streamed data read, zlib and BCPack decoded in parallel | Loading is limited by writes into title memory |
140: | Input | XInput pads, keyboard, keyboard stand-in pad | Trigger rumble |
142: | GPU: menus | Draws, compute and presentation on host D3D12 | Still images flicker with another copy of themselves |
143: | GPU: world | Renders in 3D; submissions sent ahead with a relay thread; copies and compares on several threads; pipelines built by worker threads, kept on disk and started early on the next run | ~80-100 ms of GPU work a frame, but ~300 ms copying title memory to and from the card; ray-traced bounce light and shadows (shadowed areas and skin are dark) |
144: | Shaders | Console GPU code recompiled to DXIL, cached on disk by translator version (rebuilds keep the cache) and pre-compilable offline (26,599 shaders, ~26,260 translate) | About 14 used in gameplay still fail: descriptors read as data, some wave64 forms, half interpolations |
145: | Textures | Console tiled layouts and detiling; optional top-level skip so 8 GB cards hold the title's textures | Untextured objects when VRAM is full without the skip |
146: | Series S mode | Two planes composed into one image | The world: use the Series X profile |
150: Requirements: Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with
151: shader model 6.6 (and mesh shaders for the world), Rust (pinned in
152: `rust-toolchain.toml`).
154: The title also needs several GiB of available Windows commit at startup.
155: Check **Committed** under **Task Manager → Performance → Memory**. If
156: `crashes.log` reports Windows error 1455, close other applications or increase
170: set VICTORY_WARM_CACHE=1
171: set VICTORY_HOST_MAX_WAVE=32             # NVIDIA; 64 on a card with 64-lane waves
172: set VICTORY_SHADER_LOOP_LIMIT=1024       # the same value the runs use
175: 
176: Run the title (our settings for an 8 GB NVIDIA card):
177: 
196: are kept under the data folder (default `%LOCALAPPDATA%\victory\data`), derived
197: data under the cache folder.
198: 
216: victory lib-exports <import.lib> [--list]
217: victory shader-info [paths...] [--verbose] [--disasm]
218: victory translate [paths...] [--validate] [--pipelines] [--list] [--jobs N]
230: | --- | --- |
231: | `VICTORY_TEXTURE_SKIP_MIPS=1` | big block-compressed textures get no memory for their top level (about 4x less each; needs tiled resources tier 2) |
232: | `VICTORY_WARM_CACHE=1` | with `translate`: fills the runtime shader cache instead of reporting |
233: | `VICTORY_SHADER_KEY_EXE=1` | key the shader cache on the executable again (every rebuild re-translates) |
234: | `VICTORY_PIPELINE_WORKERS=<n>` | pipeline builder threads (default half the logical processors, 2-8) |
235: | `VICTORY_PIPELINE_PRIORITY=normal` | builders at normal priority (below normal, a busy title starves them) |
236: | `VICTORY_RGB9E5_AS_R11=1` | name R9G9B9E5 as R11G11B10 (Series S render targets on NVIDIA; breaks the title's packed light) |
237: | `VICTORY_PRESENT_PLANE=<n>` | show plane `n` alone; unset, two planes are composed (Series S) |
242: | `VICTORY_GAMMA=<g>` | raise the presented image to 1/g (costs a submission; washes bright scenes) |
243: | `VICTORY_LDS_REGION_RACE=1` | LDS read and written in one lane branch taken as two 32-lane waves (shadow and ray-tracing programs on NVIDIA; approximate) |
244: | `VICTORY_BALLOT_OWN=1` | experimental: ballots and wave reductions in lane branches use each 32-lane half's own lanes (cascade shadows and water translate, but shadows come out striped) |
245: | `VICTORY_LDS_BOUNDS=0` | turn off the console's LDS bounds rule (on by default) |
246: | `VICTORY_PSO_DUMP=<dir>` | save the blocks of the unimplemented pipeline calls 0x1c8/0x218 (diagnostics) |
247: 
258: | `VICTORY_LOG=<target>=debug,...` | debug and trace output |
259: | `VICTORY_STACKS=20,60` | every thread's stack at those seconds |
260: | `VICTORY_WATCH=<rva>,...` | logs a title u32 when it changes |
261: | `VICTORY_KEYS=30:Enter,35:X` | presses keys at those seconds, focus or not |
262: | `VICTORY_CRASH_SAVE=<rva>:<len>,...` | saves title memory to the cache folder on a crash |
263: | `VICTORY_CAPTURE=<dir>` | saves presented frames (powers of two, or `VICTORY_CAPTURE_FRAMES=<list>`) |
265: | `VICTORY_D3D12_DEBUG=1` | host debug layer |
266: | `VICTORY_D3D12_GBV=1` | with the above, GPU-based validation (bad descriptor use reported, not faulted; slow) |
267: | `VICTORY_D3D12_DRED=1` | on a GPU failure, the allocation hit and the commands in flight |
268: | `VICTORY_PIPELINE_WAIT_MS=24` | reduce the per-frame wait for background pipeline creation from the default of 500 ms. A draw can be omitted until its pipeline is ready |
269: | `VICTORY_SKIP_PIPELINES=<hash>,...` | omit draws and dispatches, including indirect ones, whose pipeline contains a listed 16-digit shader hash |
270: | `VICTORY_GPU_TIMING=1` | with the above, each list of a submission run and timed on its own; slow lists logged with their slowest commands |
271: | `VICTORY_D3D12_WARP=1` | host device on the software adapter (slow; cannot reset the driver) |
272: | `VICTORY_SHADER_LOOP_LIMIT=<n>` | translated shader loops stop after `n` iterations per lane instead of 2^20 (own shader cache entries); if a lower `n` makes world frames much faster, loops hitting the limit are what makes them slow |
273: | `VICTORY_AUDIO_CAPTURE=<file.wav>` | records what the title plays (our process only) |


===== JozefDeTremmerie/CCS03 =====
7: files the user supplies; victory-fork adds a large amount of rendering,
8: lighting, frame-rate and memory work on top. CCS03 is where a small team
9: reviews, combines and tests fixes, and builds its own on top of
20:   reviewers report problems, and does the whole test suite pass on Windows
21:   with an NVIDIA GPU (32-lane waves). The list, with authors, is in
22:   [CCS03.md](CCS03.md).
23: - A focus on NVIDIA cards with 8 GB and on laptops. The title's Series S
24:   profile runs with its own upscaler and interface plane, large textures
25:   leave out their largest level when the card's memory is small, the
26:   high-performance GPU of a laptop is used, and the title's missing
44: 
45: GTA VI (Xbox Series build, our own dump) on Windows with an NVIDIA card
46: of 8 GB, on a laptop (GeForce RTX 4060 Laptop GPU, Ryzen 9 7845HX):
47: 
50: | Loads and boots | yes: logos, account picker and loading screens |
51: | Main menu | yes, at 30 fps |
52: | In the world | yes: the opening cutscene (the diner) plays with sound, characters and room lit |
53: | Playable | yes, slowly: the player walks Lucia through the cell, the prison yard and the prologue's later scenes, and steers Jason's boat, with an Xbox pad, a PlayStation 5 pad (read by CCS03 itself, no helper program) or the keyboard |
54: | Frame rate | 30 fps in the menus; 1 to 3 fps in the opening cutscene (slowest in its first minutes while textures stream onto the 8 GB card); 3 to 7.8 fps in the prison and on the water (127 to 300 ms a frame, 3,400 to 6,000 draws) |
55: | Stability | runs of 2.5 to 31 minutes, each closed by us: no crash, out-of-memory or device removal |
56: | Story | Lucia's prologue played through to chapter 1, and on into Jason's first mission (the boat, following the plane); that mission fails so far ("Cal fell off the boat"): the water is drawn through the boat, and the boat is hard to steer at 3 to 8 fps |
57: 
63: authors is in [CCS03.md](CCS03.md)): textures without their largest
64: levels on 8 GB cards, the title's Series S upscaler and second present
65: plane, the write-watch journal and the heap's slot lock no longer held
76: 
77: Machine: the same laptop, GeForce RTX 4060 Laptop GPU (8 GB), Ryzen 9
78: 7845HX. Game files: `game_scarlett_master.exe` and its packages, dumped
85: |-------|-------------|
86: | Boot, menus, start screen | 30 fps |
87: | Opening cutscene (the diner) | plays with sound; characters, faces, hair and the room drawn and lit; 1 to 3 fps. The first seconds of a shot are washed out, nearly white, while its textures stream onto the 8 GB card (up to 1.7 GB in five seconds), then the picture settles |
88: | Prologue, prison | the game hands control over ("Move around / Move the camera"); the player walks the character and turns the camera in the yard; 5.5 to 7.6 fps, 130 to 190 ms a frame, about 3,400 to 4,600 draws |
89: | Stability | four runs of 2.5 to 11 minutes on this build, each closed by us: no crash, out-of-memory or device removal |
90: | Draws left out | almost all are the stages of the ray-tracing structure builder, which is off (700 to 3,200 a frame in cutscenes); besides those, 3 compute programs: 1 that does not translate, 2 the driver refuses |
110:   mission: in the boat, following the plane, until the mission failed.
111:   Two runs of 13.5 and 22.5 minutes, closed by us, no crash.
112: - A PlayStation 5 pad on USB is found and plays as the first pad;
117:   indirectly).
118: - With the texture pass held to 25 ms and 48 MB a frame
119:   (`VICTORY_TEXTURE_STAGE_MS=25 VICTORY_TEXTURE_STAGE_MB=48
120:   VICTORY_TEXTURE_CATCHUP=0`) the world runs at 6.3 to 7.0 fps with fewer
121:   stalls; a new scene shows its background bright for longer while its
122:   textures come in. On the water, `VICTORY_WIDE_REFRESH=1` took the
123:   copies of title memory from 60-210 to 38-95 ms a frame and the time the
124:   card waits for us from 120-185 to 56-70 ms; the frame rate stayed at 5.5
128:   holding lanes elsewhere read as data, in a console wave64 program on
129:   NVIDIA's 32-lane waves; so does `CS_TransmissionVolumetrics`). Both
130:   are the Series S profile's own containers of programs victory-fork
131:   already lets take the wave-wide form; with their hashes on that list
132:   the submerged one translates to 32-lane waves, its pipeline is made and
133:   the title runs it on the water (a run of 10 minutes, no device loss, the
140: 
141: ### Test run of 2026-11-25, afternoon: Series S on an 8 GB laptop
142: 
145: 
146: Machine: a laptop with a GeForce RTX 4060 Laptop GPU (8 GB) and a Ryzen 9
147: 7845HX.
153: |-------|-------------|
154: | Boot, menus, loading screen | 30 fps |
155: | The cell and the first rooms | lit, with textures on walls, beds and posters, characters with skin, faces and hair, the yard and the guard tower through the window; 3 to 6 fps, 170 to 350 ms a frame, the card busy only 30 to 100 ms of it |
156: | Cutscenes | play in order; the first seconds of a new one run at about 1 frame a second while its textures stream in, and faces stay dark until theirs are there |
157: | Stability | no crash, out-of-memory or device removal in five runs of 3 to 35 minutes |
158: 
159: What changed since the morning (same day, RTX 2060 SUPER 8 GB, Series X
160: profile: 1 to 3 fps, most of what was not lit directly black, textures
161: blurry or missing):
164:   own upscaler (victory-fork #798), its interface plane is drawn (#188).
165:   About twice the frame rate of Series X on the same card, and it fits 8 GB.
166: - victory-fork's frame-rate work of 25 November with its switches on: from
167:   about 4 to 6 fps on the laptop.
168: - Textures without their largest level on 8 GB cards (from victory-fork
169:   #814): before, about 450 textures waited for room on the card and figures
172:   the sun does not reach is no longer black.
173: - 50 more shader programs translate (victory-fork #25 and #215): cascade
174:   shadows and characters' cut-out clothing and hair.
177: 
178: - The processor side is the limit: one submit thread spends about 130 ms a
179:   frame preparing, 80 ms copying the title's memory to the card and 60 ms
180:   copying back (measured with victory-fork's frame log).
181: - Faces in a cutscene's first seconds, and dark scenes.
182: - Ray tracing: victory-fork #814 runs live ray-traced light on 8 GB cards,
183:   at about 1 frame a second; not in CCS03.
189: 
190: `victory translate` over the title's shader pack and executable, as for a
191: host with 32-lane waves and a 1,000,000-view heap: all 26,096 programs
196: 
197: `ccs03/shader-report.ps1` makes the same pass into a text report for any
198: card, with a run's log beside it if there is one: what translates, in
203: 
204: The recommended way on an 8 GB card, as a set of environment variables:
205: 
217: `VICTORY_TEXTURE_BACK=1` (victory-fork PR 999) copies the water textures
218: the title reads on the CPU back into its memory: without it a boat sinks
219: and the first boat mission fails. victory-fork's tester saw the card lost
228: 
229: `-Smooth` holds the texture pass to 25 ms and 48 MB a frame (fewer stalls,
230: textures come in over more frames), `-Fast` refreshes host copies on
234: `-Steady` (`VICTORY_GAME_STEP_MS=33`) holds each frame to 33 ms for the
235: title: at 3-4 fps the game runs slower than real time instead of moving
236: the world in 250-300 ms jumps. The title times its frames with
249: 
250: A shader and pipeline cache per PC (`VICTORY_CACHE_DIR`) keeps two
251: machines with different cards from rebuilding each other's pipelines.
252: Without the Series S profile, an 8 GB card runs out of memory in the world
253: at 1080p; `VICTORY_DISPLAY_MODE=1280x720` keeps it inside.
262: 
263: The title's root signatures use directly indexed descriptor heaps (shader
264: model 6.6). The D3D12 runtime built into Windows 10 refuses them, so without
265: help no pipeline can be made and the screen stays black. Windows 11 is not
266: affected.
274: The test programs do not load the Agility SDK yet, so on Windows 10 the GPU
275: tests that need shader model 6.6 fail ("no SM 6.6 device"). Run them on
276: Windows 11, or compare against `ccs03` as the maintainers do.
282: - Building: `cargo build --release -p victory`. Requirements: Windows 10/11
283:   x64, a CPU with AVX2, a Direct3D 12 GPU with shader model 6.6 (and mesh
284:   shaders for the world), and Rust as pinned in `rust-toolchain.toml`. On
285:   Windows 10 also the `D3D12` folder described above.
286: - GPU: the high-performance card is used (on a laptop the NVIDIA or AMD
287:   card, not the one in the processor); `VICTORY_D3D12_ADAPTER=<index|name>`
289: - Display size: the title is told about a 1080p display;
290:   `VICTORY_DISPLAY_MODE=3840x2160` reports a 4K one (more memory).
291: - Console profile: `--console series-s` for cards with 8 GB (see Running
292:   above); the Series X profile renders at 2560x1440 inside.
304: | [JozefDeTremmerie](https://github.com/JozefDeTremmerie) | Maintainer: reviews and merges |
305: | [9hvn9yt2vk-netizen](https://github.com/9hvn9yt2vk-netizen) | Contributor: shader and GPU fixes |
306: 
310:   contributors: the loader, the runtime services, the Direct3D 12 back end
311:   and the shader recompiler.
312: - [victory-fork](https://github.com/fxceless/victory-fork) by fxceless and
313:   its contributors: the rendering, lighting, frame-rate and memory work
314:   CCS03 is based on. victory-fork used [XCL](https://github.com/ivall/xcl)


===== Dolberthi/neptune-dolberth-nvidia-8gb =====
4:   <img src="https://img.shields.io/badge/Windows%2010%20%26%2011-0b0a15?style=flat-square&logo=windows11&logoColor=white" alt="Windows 10 & 11">
5:   <img src="https://img.shields.io/badge/NVIDIA%208GB%20%2B%2016GB%20RAM-0b0a15?style=flat-square&logo=nvidia&logoColor=76b900" alt="NVIDIA 8GB + 16GB RAM">
6:   <img src="https://img.shields.io/badge/AMD%20Ryzen%20Zen%202%2F3%2F4%2F5-0b0a15?style=flat-square&logo=amd&logoColor=ed1c24" alt="AMD Ryzen">
7:   <img src="https://img.shields.io/badge/D3D12%20%2B%20Agility%20SDK%201.620-0b0a15?style=flat-square" alt="D3D12 Agility SDK">
11: <p align="center">
12:   A performance-focused fork of the <b>VIctory / Neptune</b> Xbox Series (Scarlett) PE loader, RDNA2-to-DXIL shader translator, and D3D12 compatibility layer for Windows 10 &amp; Windows 11 — tuned for <b>8 GB NVIDIA GPUs</b>, <b>6-core CPUs</b>, and <b>16 GB RAM</b> without external upscaler DLLs.
13: </p>
22: 
23: This fork unifies community CPU/VRAM/NVIDIA improvements from **Neptune-VE**, **`ad3lre/victory-nvidia-8gb`**, and **`proneonn/Vertex`** together with custom runtime subsystems (**Neptune HyperEngine**, **Clear-TAA**, and **VRAM Guardian**):
24: 
25: ### 1. Neptune HyperEngine (CPU, Hashing & Streaming Pipeline)
26: - **Persistent Zero-Spawn Worker Pool (`turbo.rs`)**: Eliminates per-frame `std::thread::scope` thread creation overhead across texture refreshes (`texture.rs`), descriptor heap synchronization (`descriptor.rs`), and write-watch flushes (`host.rs`).
27: - **Zero-Dependency `FxHasher` (`FastMap` / `FastSet`)**: Replaces SipHash-1-3 across hot submission, shadow-range, and draw-state hash tables (`shadow.rs`, `draw.rs`, `host.rs`).
28: - **AVX2 256-bit Vector Hasher & Zero-Page Early Skip**: High-throughput descriptor and texture change hashing, plus instant skip of untouched zeroed descriptor pages.
29: - **Shader Metadata Sidecar Cache (`neptune-meta.bin`)**: Persists RDNA2 container metadata (`stores`, `walks`, `used`) alongside `%LOCALAPPDATA%\victory\cache\shaders` (~97% hit rate), skipping redundant `Container::parse` + `native_programs()` disassembly on warm launches.
30: - **Zero-Allocation SIMD Texture Detiler (`victory-formats/src/texture.rs`)**: Thread-local reused run buffers + unchecked 16/32/64-byte chunk detiling for Scarlett XOR-swizzled textures.
31: - **Parallel Draw Translation (`VICTORY_THIN=1`) & Smart Copy-Back v2 (`smart_back.rs`)**: Parallel command translation combined with size-filtered GPU-to-CPU copy-backs (`VICTORY_SMART_COPY_BACK_KB=4`) and CPU-validated indirect draw arguments (`VICTORY_INDIRECT_RAW=3`).
37: 
38: ### 3. VRAM Guardian & 8 GB GPU / 16 GB RAM Optimizations (fused with `ad3lre/victory-nvidia-8gb`)
39: - **Texture Mip Dimension Cap (`VICTORY_TEXTURE_MAX_DIM=1024`)**: Caps highest mip levels on 8 GB GPUs to reclaim ~1.5–2 GB of VRAM and prevent `0x887A0006` OOM/TDR crashes (set `2048` for higher detail or `0` to disable).
40: - **2-Tier Tight Placed-Resource Slab Allocator (`placement.rs`)**: Packs `<= 128 KiB` resources into `2 MiB` heaps and `128–512 KiB` into `4 MiB` heaps with automatic trimming at `78%` VRAM pressure to minimize slab fragmentation.
41: - **Shared-RAM & VRAM Pressure Trim (`VICTORY_RAM_TRIM_MB=2048`)**: Drains spare upload staging pools, idle staging buffers, and stale shadows when shared GPU memory or VRAM crosses pressure thresholds.
42: - **Batched Card Sync & Indexed Submission Steps**: Integrates `VICTORY_CARD_REHASH_GAP=4`, `VICTORY_CARD_SYNC_BATCH=1`, and `VICTORY_STEP_INDEX=1` (backed by `FastMap`/`FastSet`).
43: 
44: ### 4. Refresh Stamp (fused with `proneonn/Vertex`)
45: - **Monotonic Refresh Stamp (`stamp.rs`, `VICTORY_REFRESH_STAMP=1` opt-in)**: Skips redundant CPU shadow-buffer refreshes when title memory has not been written since the last upload stamp.
46: 
49: - **Host-Friendly Scheduling**: Runs at `VICTORY_PROCESS_PRIORITY=normal` to keep Windows DWM responsive on 6-core CPUs.
50: - **Live Telemetry Script ([neptune-diag.ps1](neptune-diag.ps1))**: Parses frame times, VRAM/shared-RAM usage, copy-back buckets, shader cache hit rates, and runtime warnings.
51: 
56: - **OS:** Windows 11 or Windows 10 (22H2 / 19045+ with `D3D12\D3D12Core.dll` from DirectX 12 Agility SDK `1.620.2`)
57: - **GPU:** DirectX 12 Ultimate GPU with 8 GB+ VRAM (tested on NVIDIA RTX 4060 8 GB)
58: - **CPU:** 6+ cores recommended (AMD Ryzen Zen 2+ executes Xbox Zen 2 instructions natively; tested on Ryzen 5 5500 6C/12T)
59: - **RAM:** 16 GB+
60: - **Toolchain:** [rustup](https://rustup.rs) (nightly toolchain via `rust-toolchain.toml`) + Visual Studio Build Tools (MSVC + Windows SDK)
79: ```powershell
80: # Launch with the 8 GB NVIDIA / 16 GB RAM profile.
81: # First launch automatically warms the shader cache offline once (~3-5 min) to prevent
82: # live compilation stutter; all subsequent launches start immediately.
83: .\run-neptune.ps1 -Title 'D:\Path\To\Your\title.exe'
87: 
88: # Higher texture cap (12 GB+ VRAM) or windowed mode
89: .\run-neptune.ps1 -Title 'D:\Path\To\Your\title.exe' -TextureMaxDim 2048 -Window '1600x900'
102: |:--|:--|:--|
103: | `VICTORY_TEXTURE_MAX_DIM` | `0` | Optional texture mip cap (`1024`/`2048` to reduce non-XOR mip memory; `0` default for highest FPS) |
104: | `VICTORY_RAM_TRIM_MB` | `512` | Emergency idle-pool trim only when free physical RAM drops below threshold (avoids buffer thrashing) |
105: | `VICTORY_TAA` | `0` | Spatial Anti-Crumb + FXAA 3.11 by default (zero ghosting); set `1` / `-Taa` to enable temporal resolve |
108: | `VICTORY_CARD_REHASH_GAP` | `4` | Joins nearby dirty buffer sub-ranges before rehashing |
109: | `VICTORY_CARD_SYNC_BATCH` | `1` | Coalesces card buffer sync + rehash passes |
110: | `VICTORY_TURBO_THREADS` | `5` | Persistent worker pool thread count |
111: | `VICTORY_SHADER_META_CACHE` | `1` | Enables `neptune-meta.bin` RDNA2 metadata sidecar cache |
112: | `VICTORY_SMART_COPY_BACK` / `_KB` | `1` / `4` | Filters small unnecessary GPU-to-CPU copy-backs |
113: | `VICTORY_THIN` / `_THREADS` | `1` / `6` | Parallel command list draw translation |
114: | `VICTORY_INDIRECT_RAW` | `3` | CPU-validated indirect draw arguments |
115: | `VICTORY_PROCESS_PRIORITY` | `normal` | Keeps host desktop/DWM responsive on 6-core CPUs |
116: | `VICTORY_NAN_GUARD` | `0` | Keeps compiled shader cache valid (`-WarmShaders` required if changed) |
117: 
124: - **[Marvisak/VIctory](https://github.com/Marvisak/VIctory)** — original loader and emulator architecture
125: - **fxceless & myokex** — core runtime, levels on demand, heap sync (with PRs by Jonirulah, Flyander, AscilCH)
126: - **soldsawn** — RDNA2-to-DXIL shader translator
127: - **Neptune (VIctory Edit.) — Traffic, imgone & zm0kie** — Neptune-VE base, thin lists, overlay, ambient pass, indirect validation (`RAW3`)
128: - **[ad3lre/victory-nvidia-8gb](https://github.com/ad3lre/victory-nvidia-8gb)** — `VICTORY_TEXTURE_MAX_DIM`, `VICTORY_RAM_TRIM_MB`, AVX2 zero-page skip, `VICTORY_CARD_REHASH_GAP`, `VICTORY_CARD_SYNC_BATCH`, and `VICTORY_STEP_INDEX`
129: - **[proneonn/Vertex](https://github.com/proneonn/Vertex)** & **tippythetaidum (PR #927)** — monotonic refresh stamp (`stamp.rs`) and NVIDIA 16-bit `d16` typed buffer fix (`halves.rs` / `half_views`)
130: - **avatarmanz (`VIctory-7900XTX`)** — `list_views` and descriptor optimizations
131: - **Belobug & ShakiraRED-dt** — ambient pass


===== lucas-TagDev/VKarameloVI =====
2: 
3: VKarameloVI runs an Xbox Series title natively on Windows on NVIDIA cards, from files the user supplies. It is
4: [VIctory-NVIDIA](https://github.com/trustno1-coder/VIctory-NVIDIA) (itself built on
5: [VIctory-7900XTX](https://github.com/avatarmanz/VIctory-7900XTX) and [VIctory](https://github.com/Marvisak/VIctory))
6: as set up and measured on an RTX 4060 Ti 16 GB, Ryzen 5 5600X and 32 GB of RAM: about 7-12 frames a second in the
7: world (86-176 ms a frame) with the Series S profile at half render scale, after its shaders and pipelines are warmed
13: 
14: What this fork adds on top of VIctory-NVIDIA:
15: 
23: This repository did not come from one place. Over several weeks we built, ran
24: and measured the work of many projects on the same NVIDIA machine, kept what
25: worked on this card, and brought the best of each together here. No single one
26: of them runs this well on NVIDIA by itself; the combination is what gets it to
27: where it is now.
31: - [avatarmanz/VIctory-7900XTX](https://github.com/avatarmanz/VIctory-7900XTX):
32:   Its threading, write relay, card fills, copy queue and texture
33:   read-back are all kept.
35:   compatibility layer under everything else (loader, runtime services,
36:   Direct3D 12 back end, shader recompiler).
37: - [fxceless/victory-fork](https://github.com/fxceless/victory-fork) (formerly
39:   plane (pull request 1189, Tissma95), which fixed the black menus.
40: - victory-perf, carrying patches from
41:   [ZigZagBoi1/ScarlettPort](https://github.com/ZigZagBoi1/ScarlettPort): the
42:   title patches for render scale, the title's own upscaler and the watchdog.
43: - Through the 7900 XTX fork:
44:   [DexNom/VIctory](https://github.com/DexNom/VIctory),
45:   [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD),
46:   [FQY55kai/ZJOU-VICTORY](https://github.com/FQY55kai/ZJOU-VICTORY),
47:   [myokex/victory-amd](https://github.com/myokex/victory-amd), Geckomacabre and
48:   cxy0072019-sketch.
58:   table below came from.
59: - [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)
60:   builds with its fixes combined.
69: 
70: Everything below is what `scripts\play-nvidia.ps1` turns on. Measured on an
71: RTX 5070 12 GB with a Ryzen 7 9800X3D, in the prologue:
72: 
73: | Setup | fps | GPU time a frame |
74: |---|---|---|
75: | The 7900 XTX fork's own settings, Series X | high, but thousands of draws a frame skipped (the picture jumps) | - |
76: | With the descriptor fix, Series X, full scale | 6.0 | 110 ms |
77: | The same, half render scale | 7.2 | 82-88 ms |
78: | Series S, half scale, own upscaler, ray walks skipped | 11.0 | 33 ms |
79: | Plus memory compares on the card | 21.8 | about 6 ms |
80: 
92: 3. **The title's own upscaler** (`VICTORY_OWN_UPSCALER=1`). On Series S the
93:    title upscales with AMD FidelityFX (FSR), whose compute programs cannot be
94:    translated here, so that step drew nothing. A patch makes the title use its
99:    Instead of walking stale nodes, every box and triangle test is a miss. That
100:    avoids a hang and saves about 10 ms a frame, but light bounced off nearby
101:    surfaces is lost, so some dim rooms look darker.
102: 
103: ### Settings that make it faster without changing the picture
104: 
105: 5. **Memory compares on the card** (`VICTORY_CARD_BUFFERS_MIN_MB=1`,
106:    `VICTORY_CARD_BUFFERS_MB=1536`). Once the settings above had cut the GPU's
107:    work, the CPU was the limit: every frame it compared about 190 MB of title
108:    memory to find what the title had changed. These move the compares of copies
109:    of 1 MiB or more to the graphics card. Copying back fell from about 27 to
110:    10 ms a frame, and the frame rate doubled (11 to 21.8 fps).
111: 6. **Wait for new shaders** (`VICTORY_PIPELINE_WAIT_MS=10000`). Draws wait for
112:    a pipeline still being made instead of being skipped: nothing is missing,
113:    with a short hitch the first time a place is seen.
114: 7. **NVIDIA Smooth Motion** (by default in `play-nvidia.ps1`). The script
115:    starts a copy of the build named `victory_sm.exe`; with Smooth Motion turned
116:    on for that exe in the NVIDIA App, the driver inserts a generated frame
117:    between real ones, so motion looks about twice as smooth. The title still
118:    runs at the real rate underneath, so controls respond at about 20 fps.
119: 
120: ### Code changes (what makes it work on NVIDIA at all)
121: 
122: 8. **No more skipped draws on NVIDIA** (`VICTORY_DYNAMIC_SLOTS=524288`,
123:    `crates/victory-gpu/src/descriptor/host.rs`). NVIDIA caps the shader-visible
124:    view heap at 1,000,000 views, below the 1,245,184 the title asks for. The
125:    pool of dynamic descriptor slots (2^18) then ran out, and 1,100-4,800
126:    descriptor tables a frame were refused, each one a dropped draw: the screen
127:    rarely updated and the character jumped from place to place. The pool can
129: 9. **Series S interface plane** (`VICTORY_COMPOSE=1`,
130:    `crates/victory-gpu/src/compose.rs`, `host.rs`, `queue.rs`). A Series S
131:    title presents two planes: the game (1080p) and the interface (4K). Only the
134:    is shown. Ported from fxceless/victory-gta6 pull request 1189 (Tissma95),
135:    without its FSR stand-in (the own upscaler is used instead).
136: 10. **Title patches** (`crates/victory-loader/src/hooks.rs`, `lib.rs`,
137:     `windows.rs`): render scale, own upscaler, and `VICTORY_NO_WATCHDOG`
138:     (keeps the title's watchdog from ending a slow frame), taken from the
139:     victory-perf patches.
140: 11. **Ray walks end at the root** (`crates/victory-shader/src/emit/intersect.rs`,
141:     `crates/victory-gpu/src/shader_cache.rs`): the `VICTORY_BVH_MISS` switch, made
142:     part of the shader cache key so translated shaders with and without it are
143:     kept apart.
144: 12. **`scripts/play-nvidia.ps1`**: the launcher with all of the above.
145: 
150: layer that runs an Xbox Series title natively on Windows from files the user
151: supplies. That fork is tuned for an AMD RX 7900 XTX. This one makes it **draw
152: everything on NVIDIA cards and run fastest there**, using the Series S profile.
153: 
159: 
160: Tested on one machine only: Windows 11, AMD Ryzen 7 9800X3D, 64 GB RAM,
161: GeForce RTX 5070 12 GB, the Series S profile at half render scale
162: (`scripts\play-nvidia.ps1`).
163: 
165: |---|---|
166: | Prologue, indoors | about 20-22 fps on average, 24-31 fps in lighter places |
167: | Device losses | none in the measured runs |
172: (the picture jumped and rarely updated), and the Series X profile at full scale
173: ran at about 6 fps.
174: 
181: - Everything listed in the 7900 XTX fork's README still applies (flicker of far
182:   plants outdoors, textures appearing late while the title streams, a stutter on
183:   the first run with a new driver or build).
186: 
187: You need Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with shader
188: model 6.6 and mesh shaders, Rust (the toolchain is pinned), the MSVC build
191: ```powershell
192: git clone https://github.com/trustno1-coder/VIctory-NVIDIA
193: cd VIctory-NVIDIA
194: copy victory.example.toml victory.toml      # then set your paths, outside this folder
195: cargo build --locked --profile diag -p victory --features diagnostics
196: scripts\play-nvidia.ps1 -Exe <path of your copy's executable>
197: ```
198: 
199: `scripts\play-nvidia.ps1` starts a copy of the build named `victory_sm.exe`, so
200: NVIDIA Smooth Motion applies every time once it is turned on for that exe in the
201: NVIDIA App. `-NoSmoothMotion` runs `victory.exe` itself; `-SeriesX` uses the
202: Series X profile (sharper, much slower). The fork's own `scripts\play.ps1` is
203: still there for AMD cards.
204: 
207: ```powershell
208: target\diag\victory.exe shaders <the shader archives>   # every shader translated, minutes
209: target\diag\victory.exe warm --used                     # pipelines earlier runs drew with, for a new driver or build
219: 7900 XTX fork added is kept: translation of list calls on threads
220: of ours, submissions prepared and joined on a thread of ours, the write relay,
221: fills done on the card, textures on their own copy queue, texture read-back
222: (boats float), and frame record and replay. Its
233:   contributors: the loader, the runtime services, the Direct3D 12 back end and
234:   the shader recompiler.
235: - **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)**: the fork
239:   cube gradients, sparse textures.
240: - **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**:
241:   the ambient light idea, pipeline workers, and work by romainhedouin.
242: - **[FQY55kai/ZJOU-VICTORY](https://github.com/FQY55kai/ZJOU-VICTORY)**.
243: - **[myokex/victory-amd](https://github.com/myokex/victory-amd)**: the guard over
244:   every view of a page (with Spexivus, joroyt and tightfall), and Joshua Odom's
245:   reads into title memory.
246: - **Geckomacabre** and **cxy0072019-sketch**: the texture read-back.
247: - **[XCL](https://github.com/xcl-dev/xcl)** (GPL-2.0-only) was read for how the same


===== GiovannaSGuerrera/Victory-RTX2080 =====
2: 
3: Runtime experimental em Rust para executar GTA VI no Windows com uma NVIDIA RTX 2080 de 8 GB. O projeto reúne carregamento nativo de código x86-64, compatibilidade com serviços Xbox e tradução gráfica para DirectX 12, com um perfil local de execução em modo Series S.
4: 
15: | Interação | O usuário confirmou conseguir jogar; não foi validada a conclusão de uma missão |
16: | Desempenho | Amostras recentes entre aproximadamente 0,3 e 2,5 FPS em cenas pesadas; não é benchmark controlado |
17: | Estabilidade e imagem | Ainda há crashes, superfícies pretas, exposição excessiva e draws descartados |
18: 
19: Os 30 FPS vistos em algumas telas iniciais não correspondem ao desempenho do cenário. Não foram feitos testes comparativos em outras máquinas neste projeto.
20: 
22: 
23: Especificações consultadas diretamente no Windows e no driver NVIDIA em **25/11/2026**:
24: 
26: |---|---|
27: | Processador | AMD Ryzen 5 5500 — 6 núcleos e 12 threads |
28: | Placa de vídeo | NVIDIA GeForce RTX 2080 — 8 GB de VRAM (8192 MiB) |
29: | Driver NVIDIA | 621.14 |
30: | Memória RAM | 32 GB, em 2 módulos de 16 GB; velocidade configurada informada pelo Windows: 2133 |
31: | Placa-mãe | ASUS PRIME B450M-GAMING/BR |
62: | `victory-gpu` | Objetos D3D12.X, comandos, heaps, descritores, cópias, sincronização, pipelines e apresentação em D3D12 |
63: | `victory-shader` | Decodificação GFX10, representação intermediária, análise de recursos e emissão DXIL |
64: | `victory-formats` | Layouts e conversões de formatos, incluindo texturas e áudio |
65: | `victory-pipeline` | Conversões e cache por conteúdo |
66: | `victory-game` | Identificações e integrações específicas do título |
72: 
73: Requisitos para o runtime gráfico: Windows x64, CPU com AVX2, GPU Direct3D 12 com Shader Model 6.6 e mesh shaders para o cenário, ferramentas MSVC e Windows SDK. A versão Rust está fixada em `rust-toolchain.toml`.
74: 
80: 
81: O executável é gerado em `target\release\victory.exe`. Com as dependências já disponíveis no cache Cargo, a compilação também pode usar `--offline`.
82: 
84: 
85: Crie `victory.toml` a partir de `victory.example.toml`. Ajuste os caminhos para seus arquivos, sempre fora do repositório. Separe cache de dados persistentes:
86: 
89: game_dir = 'D:\VictoryLocal\game'
90: cache_dir = 'D:\VictoryLocal\cache'
91: data_dir = 'D:\VictoryLocal\data'
104: 
105: O checkpoint inclui `scripts/Start-Local.ps1`, a configuração de referência e o [registro de recuperação](docs/local-playable-checkpoint.md). Esse launcher foi feito para a estrutura local `J:\GTA6\victory-8gb`; seus caminhos devem ser ajustados antes de usá-lo em outro diretório. O comando manual acima funciona independentemente dessa organização.
106: 
112: | `VICTORY_PIPELINE_SMALL_FIRST` | `1` | Prioriza pipelines menores e limita a concorrência dos computes grandes |
113: | `VICTORY_TEXTURE_DROP_MIPS` | `1` | Omite o maior mip de texturas elegíveis para reduzir seu tamanho no host |
114: | `VICTORY_SMALL_TEXTURE_KB` | `0` | Desativa a reserva adicional para admitir texturas pequenas quando a placa está cheia |
116: | `VICTORY_INDIRECT_WINDOW` | `1` | Processa argumentos de draws indiretos em janelas de registros |
117: | `VICTORY_ASYNC_SUBMIT` | `1` | Prepara e submete comandos por uma thread do runtime |
118: | `VICTORY_ASYNC_SUBMIT_SAFE` | `1` | Mantém a espera segura de leitura da memória do título |
124: 
125: A opção de prioridade de pipelines foi habilitada ao mesmo tempo em que se reaproveitou um cache anterior. O aparecimento do cenário não permite atribuir a melhora exclusivamente a essa opção.
126: 
127: ## Cache, entrada e diagnóstico
128: 
129: O runtime mantém traduções e uma biblioteca de pipelines para reutilização. O cache de shaders considera a identidade do tradutor; mudanças nele podem exigir nova tradução. Uma primeira execução pode levar vários minutos compilando, e um checkout do Git não contém o cache já produzido localmente.
130: 
133: ```powershell
134: .\target\release\victory.exe translate 'D:\VictoryLocal\game' --cache
135: ```
156: - **Pipelines recusados:** zerar a fila de compilação não elimina falhas de criação ou draws descartados.
157: - **Imagem incompleta:** há exposição excessiva, regiões escuras, vegetação pontilhada e partes do cenário ausentes. Uma imagem isolada não determina se a causa é textura, shader, geometria ou sincronização.
158: - **Memória:** o processo e a memória compartilhada da GPU podem consumir bastante commit do Windows. A pressão de memória foi observada, mas não foi comprovada como causa única dos crashes.
161: 
162: Os dados do título, saves e cache ficam no computador do usuário. Este repositório contém código, ferramentas e documentação; não distribui arquivos do jogo, capturas, dumps ou executáveis do título, nem fornece chaves ou mecanismos para contornar proteções.
163: 


===== Ryanabcraft/scarlett-victory-bench =====
8: This fork exists for one reason: **the frame the runtime produces was bound by
9: memory traffic, not by the GPU, and nobody had measured it.** Everything here is
10: a measurement, the fix that came out of it, and the ones that were tried and
13: 
14: Game files, executables, saves and generated shader caches stay on your own
15: computer. Nothing from the game is in this repository — see
20: Measured on **Intel Core i3-10105 (4 cores / 8 threads), 32 GB DDR4, GeForce RTX
21: 3050 8 GB, Windows 11**, inside the world, same scene. Upstream's own numbers
22: come from a Radeon RX 7900 XTX; this fork is the NVIDIA side of that, and the
23: interior lighting the upstream test report calls wrong renders here (lit
27: |---|---|---|
28: | fps | 1.3–1.6 | **1.7–2.0** |
29: | ms/frame | 600–890 | **506–595** |
35: The GPU sitting at 20 % with the CPU at 90 % was the tell: the submitting
36: thread was the bottleneck, and the frame line said where it went. The image
37: was the second tell, and it had a different cause — a display mode the title
51: runtime squeezed the result into a 1920×1080 window. The 4K targets also ate the
52: VRAM the textures needed (9 194 waiting).
53: 
69: `relay_card_back` in `crates/victory-gpu/src/host.rs` emitted a fetch of the
70: bytes shaders wrote to copies in the card's memory and then **waited for it on
71: the spot** — five times a frame, to move 1.9 MB.
83: `BACK_PARTS` separates the time into relay merge, relay fetch, settle card
84: fetch/merge, submit card fetch/merge and snapshots, printed on its own line
85: every five seconds. Every optimisation below was chosen from that line.
86: 
87: ### 4. More threads where the memory work is
88: 
89: `wide()` in `crates/victory-gpu/src/shadow.rs` sized its pool at
90: `available_parallelism() / 4` — two threads on an eight-thread machine — and is
91: now `available_parallelism() - 2`, capped at 8. Snapshots went from 130 ms to
109: |---|---|
110: | `VICTORY_CARD_BUFFERS_IN_RAM=1` — compare on the card over the copy in the PC's memory | 710–748 ms; 700 MB a frame over the bus costs more than the CPU's compare |
111: | `VICTORY_FAST_COPY=1` — `memcpy` guarded by SEH (`fastcopy.c`) | copies 127–205 ms against 104–147; one missing page fails the whole range |
112: | `VICTORY_INPLACE=2` | the driver refuses the big buffers (view memory) |
113: | `VICTORY_CARD_BUFFERS=0` | the world never loads |
122: |---|---|---|
123: | preparing (CPU) | **148–179 ms** | submitting thread |
124: | — title → host copies | 90–116 ms / 155–177 MB | `wide()` pool |
125: | — textures | 5–13 ms | submitting thread |
126: | — recording the command lists | ~50 ms (~10 µs a draw) | submitting thread |
127: | waiting for the card | **113–143 ms**, of which 130 ms is *the title reading memory a shader may write* | submitting thread |
128: | copying back | **251–269 ms** | relay thread |
129: | — **waiting for the fetch of what shaders wrote** | **157–167 ms** | relay thread |
130: | — waiting for the card with nothing to land | 32–42 ms | relay thread |
131: | — merging what came back | 6.5–13 ms | relay thread |
132: | — snapshots (the "before" image) | 3.0–5.1 ms | `wide()` pool |
142: 
143: Getting there needed **VRAM**: at 1,882 MB of texture copies the card was full
144: when the world's buffers were copied, so 96–98 of them were refused and 700 MB
148: 
149: What is left is one thing: **the fetch waits 157–167 ms a frame for a queue that
150: has a whole frame of draws in front of it**, with the card at 26–32 % busy. It
155: 
156: ### What that means for 30 fps
157: 
158: The two CPU-side items that dominated the frame are gone. What remains, in
159: order: the fetch's 157–167 ms of queue latency, the 90–116 ms of title → host
160: copies, and the 130 ms the submitting thread spends waiting for shader output
161: the title reads. 30 fps would need all three gone and the lists recorded in
162: parallel — a different shape of renderer, not another optimisation pass.
163: 
164: For scale: the upstream author measures **~10 fps** on a Ryzen 7 5700X3D with an
165: RX 7800 XT — roughly three to four times this machine.
173: 1. 64-bit Windows and a current Direct3D 12 driver. The game uses mesh shaders
174:    and Shader Model 6.6.
175: 2. Rust for Windows and Visual Studio Build Tools with **Desktop development
177: 3. `powershell -File .\Initialize-FormatTables.ps1` — verifies and installs the
178:    BCPack format tables (SHA-256 checked; `-FromCheckout <dir>` takes them from
179:    a local checkout instead of downloading).
192: ```powershell
193: .\sync-upstream.ps1            # fetch, merge, build, push if the build is green
194: .\sync-upstream.ps1 -NoPush    # fetch and build only
195: ```
201: 
202: **After any merge that touches the shader emitter, run `warm-shaders.bat`
203: before measuring.** Shader hashes change, the 5 GB cache is invalid, and the
204: first run then spends minutes at 10–12 s a frame compiling pipelines mid-game
205: (`dropped 764 without a host pipeline (961 being made)`). The preloader
206: translates and compiles everything up front instead.
209: on the same scene** — 499–506 ms against 486–546 ms before it, with a warm
210: shader cache and ~1 000 draws. The 588–760 ms seen at first was a 5 000-draw
211: scene, not the merge.


===== zsy-miao/victory-perf =====
1: # victory-perf
2: 
4: 
5: The project combines a native x86-64 PE32+ loader, console HLE modules (`xgameruntime`, `kernelx`, `d3d12_xs`, GameInput), a `d3d12_xs` → host D3D12 graphics backend, and an RDNA2 (GFX10) → DXIL shader recompiler, with targeted CPU/GPU synchronization optimizations, ahead-of-time shader precompilation, lighting stand-ins for shadowed interiors, Series S overlay compositing, and keyboard/mouse support.
6: 
13: Tested on one machine:
14: - **CPU:** AMD Ryzen 7 9800X3D (8C / 16T)
15: - **GPU:** NVIDIA GeForce RTX 4070 SUPER 12 GB (Resizable BAR enabled)
16: - **RAM:** 64 GB
17: - **OS:** Windows 11 Pro x64
21: | PE32+ loader & GDK HLE (`kernelx`, `xgameruntime`) | ✅ Working | Runs x86-64 title code natively; offline profile, saves, and Series S/X profiles |
22: | Boot, intro, and menus | ✅ Working | Runs at 30 fps target with audio and input |
23: | Prologue & interior gameplay | ✅ Playable | Character movement, HUD, pause menu, gamepad and keyboard/mouse input |
24: | Frame rate (Series S, 50% render scale) | 🟡 4.5–14+ fps | **14 fps (71 ms)** prison corridor, **11 fps (95 ms)** heist interior, **9 fps (115 ms)** cell; **4.5–6.5 fps** in heavy scenes (~10,000 draws/frame) — up from 2.5–4 fps baseline |
25: | Shadowed interior lighting | 🟡 Lit via stand-ins | Ambient and shadowmask stand-ins (`VICTORY_AMBIENT_STUB=1`, `VICTORY_SHADOWMASK_STUB=1`) illuminate pitch-black shadow zones; full ray-traced lighting is still WIP |
26: | Stability (`--console series-s`) | ✅ Stable in testing | Avoids AMD FFX FSR4 `DXGI_ERROR_INVALID_CALL` crash via `VICTORY_OWN_UPSCALER=1`; no screen flicker observed |
27: 
35: - **Coalesced `CARD_COMPARE` + 128 MiB inline L0 readback ring (`crates/victory-gpu`):** Rewrote GPU-side buffer diffing to 64 coalesced threads per 64 KiB chunk with LDS hash reduction and inline readback slots, dropping relay fetch stalls from ~200 ms/frame to ~0 ms.
36: - **Scoped indirect clamp barriers (`VICTORY_CLAMP_SCOPED`, default on):** Replaces global full-GPU UAV drains around `ExecuteIndirect` argument clamps with resource-scoped UAV barriers on dedicated argument/count buffers and removes the redundant post-clamp global barrier.
37: - **Per-list UAV barrier deduplication (`VICTORY_BARRIER_MERGE`, default on):** Tracks `uav_pending` (including image stores) per `HostList` and skips redundant global UAV barriers across `barrier_groups` and clamp passes.
38: - **Expanded indirect clamp windows & light PSO restore:** Enables `VICTORY_INDIRECT_WINDOW` by default, increases `VICTORY_INDIRECT_WINDOW_MOST` from `64` to `4096`, and enables `VICTORY_CLAMP_LIGHT_RESTORE` by default so graphics root bindings survive clamp dispatches.
39: - **CPU stall & spike elimination (`crates/victory-gpu/src/host.rs`, `resource.rs`, `texture.rs`):** Removed O(N²) loops in `host.rs`, moved `heap_buffers` pruning/refresh to 1/16th incremental work per frame (removing ~142 ms periodic spikes), relaxed VRAM texture eviction (`EVICT_IDLE_FRAMES=120`), enabled parallel refresh flushes, and enabled overlapped texture refreshes / fast hashing (`VICTORY_TEXTURE_OVERLAP`, `VICTORY_FAST_HASH`, `VICTORY_KNOWN_WRITES`, all default on).
40: - **Ahead-of-time shader precompilation (`apps/victory/src/precompile.rs`, `crates/victory-gpu/src/precompile.rs`, `shader_cache.rs`):** Precompiles cached RDNA2 → DXIL shader pipelines ahead of runtime to cut first-use hitches.
41: 
43: Integrated and adapted from [ZigZagBoi1/ScarlettPort](https://github.com/ZigZagBoi1/ScarlettPort) (`runtime/victory`, GPL-3.0-or-later):
44: - **Lighting stand-ins & merged shader lowering:** `crates/victory-shader/src/emit/stand_in.rs`, `exposure.rs`, and `merged.rs` (`VICTORY_AMBIENT_STUB=1`, `VICTORY_SHADOWMASK_STUB=1`, `VICTORY_EXPOSURE_STUB=1`).
45: - **Series S overlay compositing:** `crates/victory-gpu/src/over.rs`.
46: - **Loader resolution, upscaler, and watchdog hooks:** `crates/victory-loader/src/hooks.rs` (`VICTORY_OWN_UPSCALER=1`, `VICTORY_RENDER_SCALE=<0.2..=1.0>`, `VICTORY_NO_WATCHDOG=1`).
47: - **Keyboard & mouse input:** `crates/victory-core/src/kbm.rs` and `crates/victory-hle/src/modules/controls.rs` / `gameinput.rs` (`Alt` toggles mouse capture).
48: - **Memory copy, ReBAR, and readback helpers:** `crates/victory-gpu/src/memcopy.rs`, `rebar.rs`, and `readback.rs`.
49: 
53: 
54: **Requirements:** Windows 10/11 x64, AVX2-capable CPU, Direct3D 12 GPU with Shader Model 6.6 + Mesh Shaders, and the Rust toolchain pinned in `rust-toolchain.toml`.
55: 
68: 
69: ### Recommended Launch Profile (Series S, 10+ fps target)
70: 
94: 
95: - **[Marvisak/VIctory](https://github.com/Marvisak/VIctory)** (GPL-3.0-or-later) — foundational PE32+ loader, runtime HLE, `d3d12_xs` graphics layer, BCPack/swizzle texture decoders, and RDNA2 → DXIL shader recompiler.
96: - **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)** (GPL-3.0-or-later) — direct upstream base adding world rendering, shader optimizations, card buffers, relay threading, and in-place memory work.
97: - **[ZigZagBoi1/ScarlettPort](https://github.com/ZigZagBoi1/ScarlettPort)** (GPL-3.0-or-later) — source of ported GPL-3.0-or-later modules and design ideas listed above.


===== LowBacon/HybridGt =====
3: Engineering work toward running the Xbox Series X|S build of Grand Theft Auto VI, from files the
4: user owns, natively on Windows x64. Tested on one PC: Windows 11, NVIDIA RTX 4070 Ti.
5: 
11:   VIctory (`patches/victory/`, superseded);
12: - **independent tools and tests** (`crates/`): a D3D12 diagnostic harness and texture code;
13: - **documentation** of measurements, failures and root causes (`docs/`).
22: |---|---|---|
23: | Shader programs translated | `███████████████████░` 99.9 % | `shaders.rpf`: 26,069 of 26,084 programs emit; 15 do not: 5 ray-traced shadow (`CS_TraceShadowRays_*`, descriptor read as data), 10 POPS ped pixel shaders (`PS_PedTexturedCutOutTint_Zero`, off: glowing eyes). The 29 FidelityFX DXBC shaders live in other files and are not counted here (inventory reconciled 2026-11-25: earlier "45/43" mixed sources) |
24: | Shader containers the runtime translates (whole game folder) | `███████████████████░` 99.8 % | 25,938 of 25,985; 242 -> 47 failing after the runtime learned geometry-only containers (195 voxel-lighting GS). Left: 29 Xbox FidelityFX (replaced by PC FidelityFX), 10 POPS, 5 ray-traced shadow, 3 stubs with no GPU code |
25: | Shaders passing Microsoft's DXIL validator | `███████████████████░` 99.1 % | the rest: signature rows mixing flat and interpolated values, 71 mesh shaders over 32 KiB of outputs (NVIDIA takes them) |
26: | Geometry shaders (voxel lighting) | `████████████████████` 100.0 % | translate and validate; host pipelines behind `VICTORY_TITLE_GS=1` |
27: | Console pipeline methods 0x218 / 0x1c8 | `██████████████████░░` 90.0 % | 0x218 compute: 2,048 made, 0 missed. 0x1c8 graphics (the title's main renderer path): 1,746 of 1,746 captured prologue descriptions make D3D12 pipelines offline (vertex, vertex-only, mesh); on in play-fast.cmd; not yet seen in game; stencil ops not decoded |
28: | Frame rate vs 30 fps goal | `████░░░░░░░░░░░░░░░░` 19.3 % | median 5.8 fps, best 6.9, slowest frame 345 ms in the world (run next40, lock-free descriptor mirror; was 4.8 fps median, 647 ms worst) |
29: | Compute pipelines the RTX 4070 Ti accepts | `███████████████████░` 99.9 % | 1 of 3 wave64-only programs fixed (`CS_AlphTransmissionPrefilterMip`, the refraction mips water and glass sample); GPU heap defrag and a VFX triangle pass still refused |
32: | Ray tracing | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | BVH builder off; DexNom's builder work needs a merge by hand |
33: | FSR 1 upscale on present | `████████████████████` 100.0 % | runs in game (`VICTORY_FSR=1`, 720p -> 1080p); no frame-rate gain measured: the frame is CPU-bound |
34: | FSR 3.1 (temporal) | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | needs the game's motion vectors and depth: the game calls FSR only on its Series S path (blocked by 0x1c8/0x218) |
35: | Series S boot | `░░░░░░░░░░░░░░░░░░░░` 0.0 % | blocked on device method 0x1c8 |
41: **Not playable.** From the user's save the world renders and the boat mission starts at
42: **5–7 fps** (median 5.8 fps in run next40) on an RTX 4070 Ti, but the mission fails at its start
43: ("Cal fell off the boat": the boat sinks), and mouths do not move when characters talk.
48: |---|---|
49: | Boot, intro, menus at 30 fps | run logs `fork3`–`fork8` |
50: | Prologue renders: characters (Lucia, hair), textures, sky, sunlit exteriors, HUD prompts | user screenshots, `docs/MASTER_STATUS.md` |
52: | 5,000–6,500 draws per frame in the world | run log `fork8` |
53: | Shader translation: 14,160 of 14,259 vertex/pixel, 2,718 of 2,734 compute, 8,762 of 8,765 mesh programs | offline `translate` over the title's shaders |
54: | No GPU hang or device removal in the last runs | run logs `fork6`, `fork8` |
55: 
59: [ZTRX](https://github.com/Zettrox/ztrx) `main`, plus the fork's own work since then: depth bounds,
60: texture re-checks, descriptor mirroring, and the CPU-side frame work. See
61: [docs/ZTRX_IMPLEMENTATION_AUDIT.md](docs/ZTRX_IMPLEMENTATION_AUDIT.md).
65: | 0001 | Wave-wide branch form as last resort on 32-lane GPUs | HybridGt |
66: | 0002–0003 | FidelityFX: the title's FSR calls run AMD's PC upscaler (`VICTORY_FFX_DIR`) | HybridGt |
67: | 0004 | Constant samplers in reserved host sampler slots | HybridGt |
71: | 0013–0015 | `fma_mix`, `mul_hi` without INT64, 23 more VALU instructions | ZTRX PRs #56, #51, #10 |
72: | 0012, 0016, 0022 | Diagnostics: pipeline-method samples, descriptor timers, read benchmark | HybridGt |
73: | 0017–0019 | Memory remapping: locks once per call; no-op remaps skipped; remap counters; `VICTORY_KEYS` in release builds | HybridGt |
74: | 0020–0021 | Buffer copies and scratch fills that would wait for in-flight GPU work run on the GPU (`VICTORY_GPU_BUFFER_COPIES=1`, `VICTORY_GPU_FILLS=1`) | HybridGt |
80: |---|---|---|
81: | next1 | about 3.0 fps | 309–337 ms |
82: | next9 (remap locking) | 3.5–3.6 fps | 276–284 ms |
83: | next12 (with both GPU-copy switches) | **3.7–4.0 fps** | **252–270 ms** |
84: 
93: - **Frame rate.** Measured per world frame: about 105 ms CPU preparation (about 130 MB of title
94:   memory copied to the GPU), about 94 ms GPU work, about 38 ms copying results back, all on one
95:   CPU thread. Next: a GPU timing run naming the slowest shaders, and the fork's copy-free
96:   `VICTORY_INPLACE` mode.
97: - **FSR (stage 2).** The title's upscaler uses the same five-function API as AMD's PC FidelityFX
98:   SDK (MIT). The plan is to run the PC upscaler on the host's command list when the title calls
99:   `ffxDispatch`. Not started beyond stage 1.
100: - **Series S mode** (`--console series-s`, lower resolution): it stopped at a black screen
101:   because the FSR DLL was refused; retest with patch 0007 pending.
102: 
108: | Some sun shadows and mirror reflections missing (40 programs) | A sampler chosen between a loaded one and a constant one; needs reserved slots in the host sampler heap |
109: | Menu / startup animation flickers back and forth | Unknown; not the relay or texture switches (tested). Next: a RenderDoc capture |
110: | 2 compute programs still need 64-lane waves; 1 mesh pipeline refused at run time | — |
111: | 2 device methods (`0x1c8`, `0x218`) not implemented: 29 pipelines skipped | Unknown layout; likely ray-tracing state |
112: | 195 voxelization geometry shaders do not translate | No geometry-shader stage; not requested in the scenes tested |
113: 
137: $env:VICTORY_GAME_DIR  = '<your game folder>'
138: $env:VICTORY_CACHE_DIR = '<a cache folder>'
139: $env:VICTORY_DATA_DIR  = '<a save-data folder>'
141: 
142: Translate every shader into the cache once per build (about 20 minutes; it reads the game files
143: and writes only to the cache). On an NVIDIA GPU this setting matches what the game run picks:
144: 


===== Itsbatt/victory-unified =====
2: 
3: A unified fork by **[Itsbatt](https://github.com/Itsbatt)** (built and tuned with **Antigravity / Google Deepmind AI**) combining the latest performance, shader/pipeline fixes, and rendering advances from **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)**, **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**, **[DexNom/VIctory](https://github.com/DexNom/VIctory)**, and **[Zettrox/ztrx](https://github.com/Zettrox/ztrx)** on top of **[Marvisak/VIctory](https://github.com/Marvisak/VIctory)**.
4: 
11: - **Graphics & Lighting:**
12:   - **Indirect diffuse / ambient light (`crates/victory-gpu/src/ambient.rs`, `VICTORY_AMBIENT=1.25`):** Built on `Belobug/VIctory-Belobug-AMD` (`4f45ab8`) and tuned with a higher `1.25` diffuse floor plus a subtle hemispherical sky-to-ground tint (`±8%`) so daylight outdoor shadows (foliage, terrain, buildings, character clothes) retain readable color and depth without overexposing interiors.
13:   - **Helper-lane quad reads (`crates/victory-shader/src/emit/lower.rs`):** Ported from `Belobug/VIctory-Belobug-AMD` (`03629f3`) and extended with `DexNom/VIctory` (`921d8d3`) fast quad intrinsics (`quadReadLaneAt`/`quadOp`) and quad-local `DPP8` support. Pixel shader quad operations preserve helper pixels so triangle edges no longer show lines on car paint, glass, and skin.
14:   - **Shader, cubemap & PSO fixes ported from `DexNom/VIctory` (`ddb7332`, `76749ce`, `5f4c3df`, `921d8d3`):**
15:     - Uniform branching across immediate static samplers (`lower.rs`, +40 shader variants).
16:     - Restored `wave64` scalar-copy lane mask recognition (`structure.rs`, voxel visibility).
17:     - Vertex output signature ordering by name offset, declared PSV interpolation, and matching unused packed PS inputs (`container.rs`, `emit/mod.rs`, `shader.rs`, fixing DXIL validation on 39 vertex shaders including 18 water shaders).
18:     - Cube-map explicit-gradient LOD fix (`LOG2_E` double-scaling bug removed + min-LOD clamp) and `CalculateLOD` spatial coordinate fix (`lower.rs`).
19:     - Integer render-target blend bypass on mixed MRTs (`pipeline/host.rs`, `pipeline.rs`, fixing strict D3D12 PSO validation) and depth-only pipeline pre-warming priority (`pipeline/make.rs`).
20:   - **Full `fxceless/victory-fork` rendering base (`0b0074e`):** Depth bounds test (`#82`), character bake/skin/hair texture rechecking (`VICTORY_HEAP_RECHECK`), first-room descriptor mirroring, `VICTORY_LEVELS_ON_DEMAND=1`, and 59/64 trace programs.
21: - **Performance, Stability & Input:**
22:   - **Hoisted indirect draw clamps (`indirect.rs`, `draw.rs`, `host.rs`, `list.rs`, opt-in `VICTORY_HOIST_CLAMPS=7`):** Ported from `Belobug/VIctory-Belobug-AMD` (`ccab973`, `afca189`, `918ab03`, `76387c2`). Moves indirect-draw argument clamping into a preceding command list with sequential barriers (`mode 7`). Defaults to `0` (inline clamps) on NVIDIA `late` queues to avoid per-frame list-split stalls while remaining available via `VICTORY_HOIST_CLAMPS=7`.
23:   - **Texture streaming & memory-range locking (`watch.rs`, `xmem.rs`, `texture.rs`, `descriptor/host.rs`):** Ported from `DexNom/VIctory` (`5f4c3df`, `921d8d3`). Replaces the global `MAPPING` lock with per-range locks (`title_memory_reading_range` / `title_memory_remapping_range`) + `join_placeholders` so DirectStorage remaps do not block unrelated texture uploads, keeps `O(1)` unmapped fast-path rejection in `mapped_bytes` (avoiding kernel `VirtualQuery` contention unless `VICTORY_COMMITTED_QUERY=1`), alternates retries with fresh textures (`TextureQueue::due`), and avoids dropping full remap queues (`record_remap` / `merge_remaps`).
24:   - **Tuned RTX 3070 8 GB launcher (`scripts/play.ps1`):** Uses `VICTORY_DISPLAY_MODE=1920x1080`, `VICTORY_ASYNC_SUBMIT=1`, `VICTORY_QUEUE2=1` (`VICTORY_QUEUE2_LANDING_MB=128`), `VICTORY_REFRESH_ONCE=1`, `VICTORY_COPY_PLAIN=1`, `VICTORY_CARD_BUFFERS_MIN_MB=1`, `VICTORY_CARD_BUFFERS_MB=768`, `VICTORY_MERGE_GAP=64`, `VICTORY_MERGE_RUNS=4096`, `VICTORY_JOIN_COPIES=1`, `VICTORY_CARD_REHASH_RUNS=1`, `VICTORY_VIEW_KNOWN=1`, `VICTORY_UNWATCHED_FRAMES=4`, `VICTORY_DISK_CORES=slow`, `VICTORY_PIPELINE_WAIT_MS=100`, `VICTORY_LATE_WAIT_LISTS=256`, `VICTORY_TEXTURE_BUDGET_MB=2560`, `VICTORY_TEXTURE_CATCHUP=0`, `VICTORY_TEXTURE_STAGE_MB=64`, and `VICTORY_TEXTURE_STAGE_MS=40`, while keeping `VICTORY_INDIRECT_WINDOW=0`, `VICTORY_HOIST_CLAMPS=0`, `VICTORY_LEVELS_ON_DEMAND`, `VICTORY_TEXTURE_NO_WAIT`, and `VICTORY_INPLACE` off for 8 GB NVIDIA stability.
25:   - **Safe descriptor lifetime (`crates/victory-gpu/src/descriptor/host.rs`, `descriptor.rs`, `host.rs`):** Defers live shader-visible descriptor `unmake` / view-remake writes whenever GPU submissions are in flight (`crate::host::flying()`), flushing them in `Host::sweep()` (`flush_idle_heaps()`) once the GPU is idle so executing shader warps never read torn descriptors.
26:   - **30 FPS frame cap (`VICTORY_MAX_FPS=30` in `crates/victory-gpu/src/queue.rs`):** Caps menus/loading screens cleanly at 30 FPS.
27:   - **Lower commit memory (`crates/victory-gpu/src/shadow.rs`):** Caps the idle snapshot pool at `64 MiB` and drains it on tight commit memory before retrying allocations.
28:   - **Keyboard + XInput pad support (`crates/victory-hle/src/modules/gameinput.rs`):** Maps `Space` alongside `Enter` to `A`, and keeps keyboard fallback buttons active on slot `0` while focused even when a physical or virtual XInput controller (e.g., DS4Windows) is connected.
40: 
41: - **CPU:** AMD Ryzen 5 5600XT (6 cores / 12 threads)
42: - **GPU:** NVIDIA GeForce RTX 3070 (8 GB VRAM, driver `32.0.16.2114`)
43: - **Memory:** `31.93 GB` RAM, `47.93 GB` total virtual commit (`C:\pagefile.sys` set to `16384–24576 MB` on SATA SSD)
44: 
46: |---|---|
47: | Boot, menus, start screen | Works; capped at `30 fps` (`VICTORY_MAX_FPS=30`); `Enter` / `Space` mapped to `A` |
48: | Progression reached | Advances past menus, opening intro, first room, and into gameplay (`Player` + `SARC0015` autosave reached; `ambient light` active) |
49: | Long-run stability | After fixing in-flight descriptor mutation (`768735a` / `flush_idle_heaps()`), ran **~58 minutes** continuously (`19:28:28Z` → `20:25:50Z`, zero crashes) into the outdoor camp mission (`8,011 draws/frame`, `3 fps` at `344.0 ms/frame`); earlier runs hit `nvlddmkm Event ID 13` `MMU Fault` (`0xf812b60` / `0x1104`, `0x887A0006`) after **49m 42s** and **49m 47s** (`18:49:15` → `19:39:02`) before that fix |
50: | Frame time & utilization | `425 ms` on a heavy `9,940`-draw frame under `diag` telemetry (`0.0 ms` CPU card wait, `2.2 ms` heap pass, `4.9 ms` texture refreshes, `77%` GPU busy); `~2+ fps` in normal `release` play |
51: | Memory footprint | `19.66–20.51 GB` commit / `15.13–15.40 GB` active RAM in-world (requires adequate Windows commit memory; `2–4 GB` pagefile caused OOM in `shadow::pooled`) |
52: | Known incompatibilities on this GPU | `VICTORY_ASYNC_PRESENT=1` crashed in `nvwgf2umx.dll` (kept off); `--console series-s` hit `0x887A0001` in `FFX_FSR4` (Series X used) |
55: 
56: - **[Itsbatt](https://github.com/Itsbatt)** & **Antigravity (Google Deepmind AI)** — unification, performance tuning, memory pool hardening, frame limiter, and input fixes in this repository.
57: - **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)** (`0b0074e`) — async submission/copy queue, plain-copy path, fast descriptor sync, depth bounds test (`#82`), trace shader translation, character texture recheck, and `VICTORY_LEVELS_ON_DEMAND`.
58: - **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)** (`4f45ab8`, `03629f3`, `ccab973`, `afca189`, `918ab03`, `76387c2`) — indirect ambient light pass (`ambient.rs` / `VICTORY_AMBIENT`), pixel-shader helper-lane quad reads, and hoisted indirect-draw argument clamps (`VICTORY_HOIST_CLAMPS`).
59: - **[DexNom/VIctory](https://github.com/DexNom/VIctory)** (`ddb7332`, `76749ce`, `5f4c3df`, `921d8d3`) — uniform static-sampler branching, `wave64` scalar-copy mask recovery, vertex signature order & interpolation validation fixes, cubemap explicit-LOD & `CalculateLOD` fixes, quad-op/DPP8 improvements, integer-target blend bypass, and depth-only PSO pre-warming priority.
60: - **[Zettrox/ztrx](https://github.com/Zettrox/ztrx)** — streamlined Windows play script structure and defaults.
61: - **[VIctory](https://github.com/Marvisak/VIctory)** by Marvisak and its contributors is the base of everything here: the loader, the runtime services, the Direct3D 12 back end and the shader recompiler. Licensed GPL-3.0-or-later; so is this fork.
62: - **[XCL](https://github.com/ivall/xcl)** by ivall and its contributors (GPL-2.0-only) was used as a reference for how the same title behaves under another layer.
63: - **myokex** ([victory-amd](https://github.com/myokex/victory-amd), commit `c6dc4d8`, adapting PR #115 by Spexivus, joroyt, and #1122 by tightfall) and **Joshua Odom** (`10ea38e`) — memory page guards and read-beside fixes.
64: - Upstream `fxceless` changes were developed with [Claude Code](https://claude.com/claude-code).


===== Beaver6513/ztrx-lowvram =====
3: A fork of [**ztrx**](https://github.com/Zettrox/ztrx), which runs the Xbox
4: Series build of the game natively on Windows PCs with NVIDIA graphics cards,
5: from game files you supply yourself. This fork makes it run on **older and
15: |---|---|---|
16: | **DirectX 12 Agility SDK at run time** | Windows 10's own D3D12 stops at shader model 6.5, even on cards that do 6.6 (GTX 16 series). ztrx needs 6.6 and mesh shaders, so it refused to start. Now an Agility SDK folder you point it at is loaded through `ID3D12SDKConfiguration1`, and every device, debug interface and `d3d12.dll` export goes through it. | `crates/victory-shader/src/agility.rs` |
17: | **Memory limits for small cards** | On a card with less than 6 GB, texture copies are kept to about a sixth of the card's memory budget (instead of a fixed 2 GB), and copies of the title's buffers stay in the PC's memory. A GTX 1650 had been at **6.0 GB used against a 3.3 GB budget**, Windows moving memory to and from the card every frame. | `crates/victory-gpu/src/{host,resource,shadow}.rs` |
18: | **`-Fast` launcher switch** | Turns on upstream's `VICTORY_RELAY=2`, which overlaps the CPU's copy-back with the card's work. | `scripts/play.ps1` |
23: 
24: GTX 1650 (4 GB), Intel i7-10700, 32 GB RAM, Windows 10 22H2, Agility SDK 1.620.
25: Median frame time over 3.5-minute runs in the same 3D scene, 20 or so
26: 5-second samples each:
27: 
28: | Setup | Median ms/frame | Middle half of samples | Card memory in use / budget |
29: |---|---|---|---|
31: | `-Fast` | 642 | 535–824 | – |
32: | **`-Fast` + this fork's memory limits** | **548** | **529–576** | **4.1 GB / 3.3 GB** |
33: 
34: What the frame time was made of before (from ztrx's own counters and a
35: timing run): about two thirds waiting for the card, of which about a quarter
36: were copies of a few kilobytes stalled for up to 579 ms while Windows moved
37: memory back onto the card; the rest the CPU preparing submissions and
38: comparing shader-written buffers, with the card idle meanwhile.
39: 
41: 
42: - The card is still about 0.8 GB over its budget; most of what is left is the
43:   title's own render targets (about 2.4 GB at its Series X resolution).
45:   and may appear late.
46: - `--console series-s` (which would lower resolution and texture sizes) does
47:   not work yet: the title waits forever on an internal "ready" signal from one
51: 
52: Tested by upstream on Windows 11 with an **NVIDIA GeForce RTX 3050** (8 GB):
53: 
57: | Prologue | playable from the cell to the boat chase: cell, cafeteria, robbery, police chase (wanted level, minimap), boat, binoculars |
58: | Stability | 1 h 30 min+ in one session without a crash |
59: | Frame rate | 1-3 fps in the world (the first run is slower while shaders translate; they are cached after that) |
60: | Known problems | anything in shadow is black and bright scenes overexpose (the game's ray-traced lighting does not run yet); some blocky artifacts; boats sit low in the water |
64: - Windows 10/11 x64, a CPU with AVX2
65: - A Direct3D 12 GPU with shader model 6.6 and mesh shaders (NVIDIA RTX 20 or
66:   GTX 16 series or newer)
72: - Rust (the version in `rust-toolchain.toml`)
73: - Several GB of free Windows commit memory (raise the paging file if `crashes.log` reports error 1455)
74: 
93: | `-AutoPress "A,X"` | F8 holds these buttons in turn instead |
94: | `-Cache`, `-Data` | where the shader cache and saves are kept |
95: 
104: | `VICTORY_D3D12_DIR` | the Agility SDK folder (`-D3D12`) |
105: | `VICTORY_TEXTURE_BUDGET_MB` | cap on texture copies, in MB (default: a sixth of the card's budget, at most 2 GB) |
106: | `VICTORY_CARD_BUFFERS=0` / `=1` | copies of the title's buffers in the card's memory off / on (default: on for cards with 6 GB or more) |
107: | `VICTORY_RELAY=2` | relay submissions (`-Fast`) |


===== lukinhasnojento/gta6-port-knowledge =====
56: |---|---|---|
57: | `Belobug/VIctory-Belobug-AMD` | 751 | 1º — 77,4% |
58: | `DexNom/VIctory` | 547 | 2º |


===== fishingpvalues/gta6-pc-port-hub =====
21: | Declared in package manifest | `<Application Id="GTAO" Executable="game_scarlett_master.exe">` | `appxmanifest.xml` |
22: | Executables actually present | **0** | [docs/package-inventory.md](docs/package-inventory.md) |
23: | Package identity | `RockstarGamesInc.28872443D20A7`, Publisher `CN=3164F9C2-…0054`, TitleId `7952987A` | `MicrosoftGame.Config` |
38: | :--- | :--- | :--- | :--- | :--- | :--- |
39: | [ItsNotRexed/Leonida](https://github.com/ItsNotRexed/Leonida) | Python, C# | Xbox Series → Windows (Vulkan) | GPL-3.0 | All 26,503 RDNA2 shaders translated to SPIR-V; PE loader runs a stand-in executable; Xbox D3D12 → Vulkan device in progress. Does not boot. | No executable to run; Vulkan backend still lacks buffer views, root signatures, pipelines, draws, placed resources, 1D textures and swapchain. |
40: | [ivall/xcl](https://github.com/ivall/xcl) | Rust | Xbox Series → Windows (D3D12) | GPL-2.0-only | Console x64 code runs natively with kernelx / XGameRuntime / d3d12_xs / DirectStorage / XAudio2 shims; 24,064 shader programs translate; XDefiant, Fortnite and Minecraft reach title screens. | HANDOFF.md: little left to do without the executable. Open items: MSAA in the tiled layout, hull/domain/amplification shaders, draw-time root-arg → SGPR binding. |
41: | [californiaAlmonds/OpenScarlett](https://github.com/californiaAlmonds/OpenScarlett) | C++20 | Xbox Series → Windows | MIT | v0.5.0-alpha: 51/51 automated tests, official GDK samples run unmodified; 66/66 CTest; 774/779 GFX10.3 opcodes lifted. | Commercial retail Xbox Series games are not playable yet. |
42: | [omonkeyz/xbox-emulator](https://github.com/omonkeyz/xbox-emulator) | Rust | Xbox Series → Windows | GPL-3.0-or-later | Continuation of TomBox + rage9; reimplements d3d12_xs, RDNA2 translation, unified memory and console DLLs; Fortnite reaches its lobby. | GTA VI not run — dump has no executable. 8,749 of 8,765 mesh programs stall at first resource load (no RTS0 chunk). |
43: | [R0Y00/Xbox2Windows](https://github.com/R0Y00/Xbox2Windows) | C++, Python | Xbox Series → Windows | MIT | Source-built programs run entry to exit; two translated pixel shaders match hardware and WARP reference outputs; Windows CI with coverage dashboard. | Main executable absent. Coverage wall: 851/12,101 PS and 12/2,689 CS shaders actually executed. |
44: | [drycheetah84/TomBox](https://github.com/drycheetah84/TomBox) | Rust | Xbox Series → Windows | MIT OR Apache-2.0 (per crate, no root LICENSE) | Upstream runtime for omonkeyz/xbox-emulator; one title reaches its main menu. | No executable; ~1/3 of vertex shaders translate — mesh shaders and root-signature-less shaders are the blockers. |
45: | [sammwyy/xvalkyrie](https://github.com/sammwyy/xvalkyrie) | C++20 | Xbox One + Series → Windows | GPL-3.0 | Wine-style import shimming for both console generations; on Series 37/40 GDK samples draw and retail titles present frames. | Shaders carrying only the console's GPU code (no DXBC) are untranslated — exactly GTA VI's case. 1,786/2,055 retail shaders translate. |
46: | [Freminet/ScarlettX](https://github.com/Freminet/ScarlettX) | C++ | Xbox Series → Windows | none | Clean-room HLE: PE64 loader, DirectStorage/XVD (unencrypted), d3d12_xs → D3D12, GameInput, XGameSave, XAudio2; Concept Destruction and Unicorn Overlord playable. | RDNA2 XS2 shader lifting is 0 of 16 — and all GTA VI shaders ship as precompiled RDNA2 XS2. |
47: | [brcly/TuxBox](https://github.com/brcly/TuxBox) | Rust, Python | Xbox Series → Linux (Proton); Windows in progress | none | The Matrix Awakens runs from menu through the highway chase into the open city under stock Proton; publishes per-library export and shader coverage. | Windows column is pending for all 14 gates; PresentX gate fails on 3 of 4 Linux hosts; no CI and no issue tracker. |
48: 
54: | :--- | :--- | :--- | :--- |
55: | [TrinitronClient/GTA6-Asset-Info](https://github.com/TrinitronClient/GTA6-Asset-Info) | 17-part spec | GPL-3.0 | Byte-level RPF9, resources, textures, tiling, BCPack, models, map, interiors, vehicles, collision, navmesh, PSO, BVH4 and AWC/ADAT specs. |
56: | [holdmysocks/SixNG](https://github.com/holdmysocks/SixNG) | Rust | GPL-3.0 | RPF9 asset extraction to glTF, textures and map data with streaming 3D map view, LOD and shader/parameter name resolution. |
57: | [Ahmet-Dedeler/bcpack-rs](https://github.com/Ahmet-Dedeler/bcpack-rs) | Rust, Python | MIT OR Apache-2.0 | Standalone BCPack decoder: BC1 verified on held-out pools at 34.7/34.0 dB median; entropy layer exact for BC3/4/5/6H/7; BC7 block decode in progress. |
58: | [Ahmet-Dedeler/rage9-re](https://github.com/Ahmet-Dedeler/rage9-re) | Rust, Python | NOASSERTION (see repo) | script.rpf PSO script data and anim.rpf crAnimation channels decoded with glTF 2.0 export. |
59: <!-- STATUS:END -->
71: | C-1 | **Package inventory** | Five projects re-derive "which files exist"; nobody publishes a canonical manifest. | [docs/package-inventory.md](docs/package-inventory.md) |
72: | C-2 | **Shader census convention** | 26,503 records (Leonida, xcl, Xbox2Windows #594) vs 25,727 (TomBox #5) vs 21,522 console-cache entries. Denominators disagree, so "99% translated" is unmeasurable. | [docs/shader-census.md](docs/shader-census.md) |
73: | C-3 | **Root-signature-less shaders** | The same unfixed bug in four codebases: 8,749 GTA VI mesh programs carry no RTS0 chunk and stall at the first resource load. No shared memory-based root ABI fallback exists. | [docs/root-signature-fallback.md](docs/root-signature-fallback.md) |
74: | C-4 | **Conformance corpus** | `d3d12_xs` is reimplemented in ≥6 repos, `kernelx` in ≥5, RDNA2 lifting in 6 — each with its own GPU suite and no shared fixtures. | [docs/conformance.md](docs/conformance.md) |


===== sub-north/xbox-hle-lab =====
10: 
11: The title now runs at **30 FPS** by the runtime's own present-rate counter: **30.7 presents/s**
12: instantaneous and **17.8 presents/s** averaged over a full run, against a previous best of 8.4/s and
15: (`XDXR` count 0, four acceleration structures accepted, the first at `0xed8b010000`), and the GPU
16: driver's compiled pipeline blobs now persist and replay: `N compute pipelines made from the driver's
17: blob of an earlier run (kept on disk)`, with per-PSO lines reading like `… (86776 B DXIL, 5 ms, the
18: driver's blob of an earlier build)` where the same pipeline cost 681 ms to build cold.
19: 
24: and [`docs/STALL-DETECTOR.md`](docs/STALL-DETECTOR.md) for the two rules behind the abort. The compile
25: load that fills that stall is priced in [`docs/PIPELINE-DEMAND.md`](docs/PIPELINE-DEMAND.md): ~200
26: fresh compiles per run, one in flight after startup, ~3 per minute.
31: views below 2^40, instead of walking eight fixed hints into the block it had just placed
32: ([`docs/BVH-WALL-CLEARED.md`](docs/BVH-WALL-CLEARED.md)). **Driver blob cache**: pipeline blobs
33: written by an earlier run are found and reused — 5 ms replay against 681 ms cold, 29 → 56 entries
42: |---|---|
43: | `tools/gpu_probe/` | device/UMA/present probes, root-signature deserializer oracle |
44: | `tools/vm/` | App Sandbox VM automation (create, GPU assign, exec, file push) |
66: ```bat
67: gpu_probe.exe                 :: adapters, VRAM, feature level, wave lanes, tiers
68: uma_probe.exe                 :: 4 GiB-aligned 2 GB region as a D3D12 heap
69: present_probe.exe 12 0        :: 12 s clear/present, sync interval 0
70: rootsig_check.exe blob.bin    :: deserialize a root signature blob


===== POMXARK/bcpack-gpu-hlsl =====
1: # bcpack-gpu-hlsl — Clean-Room Xbox Series BCPack (MDU rANS) Decoder in DirectX 12 HLSL SM 6.6
2: 
3: [![DirectX 12](https://img.shields.io/badge/DirectX%2012-SM%206.6%20%2B%20MeshShaders%20%2B%20DXR%201.1%20%2B%20VRS%20Tier2-2f80ed)](sdk/shaders/bcpack_decode.hlsl)
4: [![v0.12.0](https://img.shields.io/badge/v0.12.0-BC1%2F3%2F4%2F5%2F7%20(0..7)%20%7C%2021%2F21%20PASS-ff4081)](#verified-bit-exactness-bcpack-gpu-demo---verify--2121-pass)
5: [![Standalone SDK](https://img.shields.io/badge/Hardware%20SDK-POMXARK%2Fbcpack--gpu--sdk-orange)](https://github.com/POMXARK/bcpack-gpu-sdk)
6: [![BC7 16-Lane](https://img.shields.io/badge/BC7%20rANS-6.02%20GB%2Fs%20(32%2F32)-9b59b6)](sdk/shaders/bcpack_bc7_rans.hlsl)
9: 
10: ![v0.10.0 4-Mode AAA Benchmark Showcase (60 / 120 / 240 / Unlimited MAX > 450 FPS on RTX 5080)](media/aaa_benchmark_4modes.gif)
11: - **Full HD (`1920×1080`) Captures:** [`60 FPS MP4`](media/aaa_benchmark_60fps.mp4) | [`120 FPS MP4`](media/aaa_benchmark_120fps.mp4) | [`240 FPS MP4`](media/aaa_benchmark_240fps.mp4) | [`Unlimited (MAX) MP4`](media/aaa_benchmark_unlimited.mp4) | [`3-Act 8s Overview GIF`](media/aaa_showcase_v8.gif)
12: 
13: **Full 4K AAA GPU-streaming showcase, 12.41M Mesh-Shader demo, and 19-test verification harness built on top of the standalone clean-room SDK [`POMXARK/bcpack-gpu-sdk`](https://github.com/POMXARK/bcpack-gpu-sdk) (linked via Git submodule at [`sdk/`](sdk)).**
14: 
15: > Want only the lightweight, zero-bloat C-ABI DLL (`bcpack_gpu.dll`), `bcpack_gpu.h`, HLSL/DXIL compute kernels, and **Vulkan 1.3 SPIR-V (`.spv`)** binaries? Use **[`POMXARK/bcpack-gpu-sdk`](https://github.com/POMXARK/bcpack-gpu-sdk)** directly!
16: > Clean-room implementation (`MIT OR Apache-2.0`) using **100% open synthetic and procedurally generated `.bcpack` assets** — zero copyrighted or proprietary game data. AI/LLM spec: [`docs/AI_ARCHITECTURE.md`](docs/AI_ARCHITECTURE.md) & [`llms.txt`](llms.txt).
17: 
19: 
20: ## What's New in `v0.11.0` — Low-VRAM Scaling, TAAU Upscaler & Hardware VRS Tier 2
21: 
22: Built for 8 GB / budget GPUs (`RTX 3060 / 4060 / RX 6600 / iGPU`) alongside high-refresh 1080p/1440p monitors:
23: 1. **Auto-VRAM Detection (`IDXGIAdapter3::QueryVideoMemoryInfo`) & 3-Tier Presets (`--preset auto|low|medium|ultra`, `--scale <0.4..1.0>`):**
24:    - Automatically selects `--preset low` when dedicated VRAM `<= 8192 MiB` (otherwise `ultra`), scaling internal resolution, DXR/RTGI, VRS Tier 2, and SFS budget together.
25: 2. **True Temporal Upscaling (TAAU `50% / 67% / 100%`, [`shaders/aaa_taa.hlsl`](shaders/aaa_taa.hlsl)):**
28:    - Compute pass generates a `16×16`-tile `R8_UINT` rate image (`D3D12_RESOURCE_STATE_SHADING_RATE_SOURCE`) preserving **`1×1`** around the focal center & high-contrast edges, dropping peripheral/low-contrast or high-motion tiles to **`2×2`** (and flat upper sky to **`4×4`** on `low`). Live **`[K]`** toggle / CLI `--vrs` / `--no-vrs`.
29:    - **Verified VRS Tier 2 gain on `ultra` (`1080p` native + Full DXR 1.1 + Compute RTGI):** **`196.77 → 258.91 FPS Avg` (`+31.6%`)** and **`313.19 → 420.63 FPS Peak` (`+34.3%`)**.
30: 4. **Cross-Vendor Xbox/RDNA2-Style Compute `RayQuery` RTGI ([`shaders/aaa_rtgi_cs.hlsl`](shaders/aaa_rtgi_cs.hlsl) + [`aaa_rtgi_cs.spv`](shaders/spirv/aaa_rtgi_cs.spv)):**
31:    - Moves diffuse RTGI out of fragment pixel shaders into a coalesced `[numthreads(8,8,1)]` (`2× Wave32` NVIDIA / `1× Wave64` AMD RDNA2+) Compute pass using pure standard DXR 1.1 Inline `RayQuery` + Vulkan 1.3 `VK_KHR_ray_query` — eliminating `2×2` pixel-quad helper ray waste and overdraw rays across NVIDIA & Radeon (`155.66 → 196.77 FPS Avg` VRS OFF, `202.55 → 258.91 FPS Avg` VRS ON).
32: 5. **SFS Budget Thrashing Hysteresis (`src/aaa_scene.rs`):**
33:    - Guards `SfsResidencyManager` against pointless eviction/re-decode ping-pong when tight budgets (`--vram-budget-mb 64`) leave less than one 4K Mip-0 (`16 MiB`) free above lower-mip residency (`Evictions: 708 → 3`, raising `--preset low` from `160.82` → **`551.51 FPS Avg`**).
34: 
35: | Preset (`1920×1080` Output, RTX 5080 `5.0s`) | Internal → Out (TAAU) | Pipeline Active | Average FPS | Peak (`1% High`) | `1% Low` | SFS VRAM Used / Saved |
36: |---|---|---|---:|---:|---:|---:|
37: | **`--preset ultra`** | `1920×1080 → 1080p` (`100%`) | DXR 1.1 + **Compute RTGI** + `128 MiB` SFS (`VRS OFF`) | **`196.77 FPS`** | **`313.19 FPS`** | `52.28 FPS` | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
38: | **`--preset ultra --vrs`** | `1920×1080 → 1080p` (`100%`) | DXR 1.1 + **Compute RTGI + VRS Tier 2** + `128 MiB` SFS | **`258.91 FPS`** | **`420.63 FPS`** | `71.64 FPS` | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
39: | **`--preset medium`** | `1280×720 → 1080p` (`67%`) | DXR 1.1 + **TAAU + VRS Tier 2** + `96 MiB` SFS | **`394.24 FPS`** | **`639.06 FPS`** | **`219.86 FPS`** | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
40: | **`--preset low`** | `960×540 → 1080p` (`50%`) | Raster + **TAAU + VRS Tier 2** + `64 MiB` SFS | **`551.51 FPS`** | **`853.53 FPS`** | **`320.31 FPS`** | **`53.7 / 204.7 MiB`** (**`-151.0 MiB`**) |
41: 
42: > All 3 presets (`ultra`, `medium`, `low`) verified under **DX12 Debug Layer (`--debug`) with 0 errors**, plus `bcpack-gpu-demo.exe --verify`: **`19/19 PASS`**.
43: 
47: 
48: 1. **Zero-Copy Shared-Device & Direct 2D Texture C-ABI in `bcpack_gpu.dll` ([`include/bcpack_gpu.h`](include/bcpack_gpu.h), [`src/ffi.rs`](src/ffi.rs)):**
49:    - **`bcpack_gpu_create_from_device(d3d12_device, d3d12_compute_queue, ...)`:** Attaches directly to a translator/emulator's existing `ID3D12Device*` (preserving caller ownership, optional external Compute queue).
50:    - **`BcPackDecodeToBuffer(...)` (`PASS 18/19`):** Decodes BCPack + Gfx10 detile directly into a caller-owned `D3D12_HEAP_TYPE_DEFAULT` GPU buffer with zero CPU readback.
51:    - **`BcPackDecodeToTexture2D(...)` (`PASS 19/19`):** Runs BCPack decode (+ optional `SW_64KB_D` / `SW_4KB_S` detile) on the **Async Compute Queue**, handoffs purely on GPU (`Queue::Wait` via `BcPackGetComputeFence`), and uploads directly into any caller `DXGI_FORMAT_BC1_UNORM` 2D texture subresource/mip via `CopyTextureRegion` — automatically padding RowPitch to 256 bytes on small mip levels, signaling `BcPackGetDirectFence`.
52: 2. **HLSL SM 6.6 → Vulkan 1.3 SPIR-V Compute (`dxc -spirv`, [`shaders/spirv/*.spv`](shaders/compile_spirv.sh)):**
55:    - Full GPU BC1 endpoint + quad reconstruction in [`shaders/bcpack_decode.hlsl`](shaders/bcpack_decode.hlsl) (`11.33 GB/s`, `0` mismatches).
56:    - Verified 16-lane BC7 rANS entropy stage at **100% Wave32** (`32/32` lanes in [`shaders/bcpack_bc7_rans.hlsl`](shaders/bcpack_bc7_rans.hlsl), `6.02 GB/s equiv`) + GPU compute **16-byte block packer** ([`shaders/bc16_pack.hlsl`](shaders/bc16_pack.hlsl)) collapsing `8 × uint` symbol rows into `16B` BC7 Mode 6 / BC5 blocks on VRAM. Full multi-mode hardware BC7 (Modes 0–7) / BC3 / BC4 / BC6H GPU block-reconstruction pass planned to align with upstream [`Ahmet-Dedeler/bcpack-rs`](https://github.com/Ahmet-Dedeler/bcpack-rs).
57: 
63: |---|---|---|---|---|
64: | **Zero-Barrier Wave32 rANS** | CPU `~40 MB/s` BCPack stall (`IDStorageQueueX`); 4,096+ LDS barriers/chunk | 2 chunks/warp (`24/32` BC1, **`32/32` BC7**), register 64B window + `WaveReadLaneAt`, 4-step branchless binary search | **`11.33 GB/s`** BC1 (**282×**), **`6.02 GB/s`** BC7 (**247×**), **`5 → 189 FPS`** live | [`bcpack_decode.hlsl`](shaders/bcpack_decode.hlsl), [`bcpack_bc7_rans.hlsl`](shaders/bcpack_bc7_rans.hlsl) |
65: | **DXC 1.8 `-O3` Ballot Fix** | `WavePrefixCountBits` + `WaveActiveCountBits` miscompiles `stream_pos` at `-O3` | Replace with explicit `WaveActiveBallot` + `countbits(mask & ((1u << ll) - 1u))` | **0 byte mismatches** under full `-O3` (`PASS 1..7`) | [`bcpack_decode.hlsl`](shaders/bcpack_decode.hlsl) |
66: | **Fused AMD Gfx10 Detile** | Xbox MDU outputs `SW_64KB_D` / `SW_4KB_S`; CPU detile bottlenecks PCIe | Inline Compute bit-permutation pass (`xyxxyyxyxyxyx` / `xyyxxyxyx`) before `CopyTextureRegion` | **`432.6 GB/s`** (`0.144 ms` / `64 MiB`) | [`gfx10_detile.hlsl`](shaders/gfx10_detile.hlsl) |
67: | **Ping-Pong Async Compute + `bc16_pack`** | Direct queue serializes decode/render; 16-lane BC7 emits 32B/row | Double-buffered `COMPUTE` + `ID3D12Fence` overlap + GPU `Store2` 16B packer | **`101.8 → 189.4 FPS`** live, **`171.9 FPS` @ `32 MiB/f`** | [`gpu_decoder.rs`](src/gpu_decoder.rs), [`bc16_pack.hlsl`](shaders/bc16_pack.hlsl) |
68: | **1.25M Descriptor Heap Paging** | NVIDIA ~1M `shader-visible` heap cap → `E_OUTOFMEMORY` crash (`d3d12_xs`) | SM 6.6 `ResourceDescriptorHeap[NonUniformResourceIndex(g_VirtToPhys[id])]` LRU via `CopyDescriptorsSimple` | **`1.25M → 262K` slots** in **`0.064 ms`** (`0` mismatches) | [`descriptor_paging.rs`](src/descriptor_paging.rs), [`bindless_paging.hlsl`](shaders/bindless_paging.hlsl) |
69: | **Active GPU Sampler Feedback (SFS)** | Full 4K BC7/BC5 11-mip chains saturate VRAM (`204.67 MiB` pool) | Pixel-shader `InterlockedMin` into `g_SfsFeedback : u0` → LRU `ResourceMinLODClamp` | **`86.2 / 204.7 MiB`** (**`118.5 MiB` VRAM saved**) | [`aaa_pbr.hlsl`](shaders/aaa_pbr.hlsl), [`aaa_scene.rs`](src/aaa_scene.rs) |
70: | **RTX 5080 `621.24` RT-Cache Fix** | Flickering **8×8 dark squares** under DXR 1.1 `RayQuery` + Async Compute | Isolated TLAS build + `uav_barrier_all()` + explicit fence flush before G-Buffer | **0 tile artifacts** across 9,000+ frames | [`aaa_scene.rs`](src/aaa_scene.rs) |
71: | **Mesh Shaders + 6-Mip Hi-Z** | Boxy LOD geometry vs slow 12M-tri vertex shading | `as_6_5`/`ms_6_5` 1-draw dispatch + `R32_TYPELESS` 6-mip MAX depth pyramid | **`12.41M → 0.99M`** avg visible (`0.015 ms` Hi-Z) | [`aaa_meshlet_as.hlsl`](shaders/aaa_meshlet_as.hlsl), [`hiz_build.hlsl`](shaders/hiz_build.hlsl) |
72: | **GPU Crowd Skinning (`500` NPCs)** | CPU skeletal animation stalls open-world crowd streaming | 4-bone LBS in Compute (`[numthreads(64,1,1)]`) + per-limb TAA motion vectors | **`0.075 ms`** for `512k` verts (`max_err=7.63e-6`) | [`crowd_skin.hlsl`](shaders/crowd_skin.hlsl), [`aaa_crowd.hlsl`](shaders/aaa_crowd.hlsl) |
73: | **Textured DXR 1.1 + TAA/AgX/CAS** | Flat instance reflections, specular aliasing, RTGI noise shimmer | `RtInstMeta` (`t34`) ray-hit UV sampling + 4-pass A-Trous + YCoCg TAA + AgX Filmic | **`150.61 FPS` Avg** (`1080p` HDR, 60s benchmark) | [`aaa_pbr.hlsl`](shaders/aaa_pbr.hlsl), [`aaa_taa.hlsl`](shaders/aaa_taa.hlsl), [`aaa_composite.hlsl`](shaders/aaa_composite.hlsl) |
74: | **Zero-Copy C-ABI & Vulkan SPIR-V** | Cross-process copies; Vulkan 1.3/Linux Proton shaders needed (`OpenScarlett`) | `bcpack_gpu_create_from_device`, `BcPackDecodeToTexture2D`, official DXC `-spirv` | **0 CPU readback**, 9 Vulkan 1.3 `.spv` kernels | [`include/bcpack_gpu.h`](include/bcpack_gpu.h), [`compile_spirv.sh`](shaders/compile_spirv.sh) |
75: | **Compute `RayQuery` RTGI + TAAU + VRS Tier 2** | 8 GB / RDNA2 GPUs (`RTX 3060/4060`, `RX 6600`) stalled by PS RTGI quads + 1080p SFS | Cross-vendor `[numthreads(8,8,1)]` `VK_KHR_ray_query` CS, 5-tap TAAU, `16×16` VRS (`[K]`), SFS hysteresis | **`196.8 FPS`** Ultra CS RTGI, **`258.9 FPS`** (`420.6 Peak`) +VRS, **`551.5 FPS`** Low | [`aaa_rtgi_cs.hlsl`](shaders/aaa_rtgi_cs.hlsl), [`aaa_vrs.hlsl`](shaders/aaa_vrs.hlsl), [`aaa_taa.hlsl`](shaders/aaa_taa.hlsl) |
76: 
78: 
79: ## Open AAA Benchmark (`v0.11.0` — 4K BC7/BC5 + Active SFS + 12.41M Mesh-Shader City + 500 NPCs + DXR 1.1 + TAAU + VRS Tier 2)
80: 
81: > **Important Throughput Note:** `60 / 120 / 240 FPS` in the top-of-page showcase GIF/MP4s are **display/capture cap presets** (`--fps-cap` / HUD slider)—**NOT** the hardware limit. Uncapped on NVIDIA GeForce RTX 5080 (`1920×1080` native HDR), the benchmark runs at **`196.77 FPS Avg` (`313.19 FPS Peak`)** with full **DXR 1.1 + Compute RTGI + 12.41M City + 500 NPCs**, **`258.91 FPS Avg` (`420.63 FPS Peak`)** with **Compute RTGI + VRS Tier 2** (`--preset ultra --vrs`), **`394.24 FPS`** on `--preset medium`, **`551.51 FPS`** on `--preset low`, and **`452.01 FPS Avg` (`708.27 FPS Peak`)** (`> 400 FPS`) in core **4K BC7/BC5 SFS** streaming (`--no-rt --no-rtgi --no-city --no-crowd`).
82: 
83: | Benchmark Preset (`1920×1080` Native HDR, RTX 5080) | Pipeline Active | Average FPS | Peak (`1% High`) | `1% Low` | SFS VRAM Used / Saved |
84: |---|---|---:|---:|---:|---:|
85: | **60 FPS Cap** (`--fps-cap 60`) | Full AAA + DXR 1.1 + RTGI + 12.41M City + 500 NPCs | `58.31 FPS` | `60.00 FPS` | `34.77 FPS` | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
86: | **120 FPS Cap** (`--fps-cap 120`) | Full AAA + DXR 1.1 + RTGI + 12.41M City + 500 NPCs | `111.00 FPS` | `119.98 FPS` | `41.05 FPS` | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
87: | **240 FPS Cap** (`--no-rt --no-rtgi --fps-cap 240`) | Raster AAA + 12.41M Mesh-Shader City + 500 NPCs + 4K SFS | `204.43 FPS` | `239.92 FPS` | `69.07 FPS` | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
88: | **Unlimited (`MAX`, Full DXR 1.1)** (`--no-vsync --fps-cap 0`) | Full AAA + DXR 1.1 + RTGI + 12.41M City + 500 NPCs | **`163.30 FPS`** | **`250.96 FPS`** | `49.07 FPS` | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
89: | **Unlimited (`MAX`, Raster City)** (`--no-vsync --no-rt --no-rtgi`) | Raster AAA + 12.41M Mesh-Shader City + 500 NPCs + 4K SFS | **`231.62 FPS`** | **`361.79 FPS`** | `141.80 FPS` | `86.2 / 204.7 MiB` (`-118.5 MiB`) |
90: | **Unlimited (`MAX`, Core 4K SFS >400 FPS)** (`--no-rt --no-rtgi --no-city --no-crowd`) | 4K BC7/BC5 Tile Streaming + Active SFS + Hero PBR + TAA/AgX | **`452.01 FPS`** | **`708.27 FPS`** | `212.65 FPS` | `54.2 / 204.7 MiB` (`-150.5 MiB`) |
91: 
92: ![v0.8.0 Cinematic AAA Benchmark: 4K BC7/BC5 + Modular Mesh-Shader City + 500 GPU-Skinned NPCs + DXR 1.1 + AgX + TAA](media/aaa_showcase_v8.png)
93: 
94: ![v0.8.0 Live SFS + Meshlet City X-Ray Heatmap: 4K Mip-0 Resident (Green/Cyan) vs SFS Budget Saved Mip 1+ (Amber)](media/aaa_xray_v8.png)
95: 
96: A photorealistic GPU-streaming benchmark (**`bcpack-aaa-demo.exe`** / [`src/aaa_scene.rs`](src/aaa_scene.rs) + [`src/aaa_world.rs`](src/aaa_world.rs)) converting open-source CC-BY 4.0 & CC0 4K PBR assets directly into `.bcpack` 64 KiB tiles:
97: - **Stage 1 — Lighting, DXR, Shadows & TAA:** Textured DXR 1.1 `RayQuery` reflections & shadows (`g_InstMeta`/`g_SceneVB`/`g_SceneIB`), GPU histogram Auto-Exposure + AgX Filmic tone mapping + HDR Bloom (`threshold=1.45`), 8-step Screen-Space Contact Shadows, and 4-MRT Motion Vectors + Halton(2,3) Jitter + YCoCg Variance-Clipped TAA + 5-tap CAS ([`shaders/aaa_taa.hlsl`](shaders/aaa_taa.hlsl), [`shaders/aaa_autoexp.hlsl`](shaders/aaa_autoexp.hlsl)).
98: - **Stage 2 — 4K BC7 / BC5 Streaming & Active GPU SFS:** Khronos [`CarConcept.glb`](https://github.com/KhronosGroup/glTF-Sample-Assets) (`162,766` verts, `213,347` tris, `109` submeshes + `6` parked + `5` traffic cars, `14` BC7/BC5 textures) + **9× Poly Haven CC0 4K (`4096×4096`) PBR maps** (`asphalt_pit_lane`, `brick_pavement`, `concrete_wall_008` in **BC7 Mode 6** / **BC5**, `11` mip levels + Packed Mip Tail, `204.67 MiB` full VRAM pool), decompressed via ping-pong Async Compute [`Bc16GpuStreamer`](src/gpu_decoder.rs) ([`shaders/bc16_pack.hlsl`](shaders/bc16_pack.hlsl)) with live pixel-shader Sampler Feedback (`g_SfsFeedback : u0`) and LRU `ResourceMinLODClamp` budget control (`--vram-budget-mb 128`, `[F]` toggle).
99: - **Stage 3 — Modular 12.41M-Tri Mesh-Shader City, Hi-Z & 500 GPU-Skinned NPCs:** Hardware `as_6_5`/`ms_6_5`/`ps_6_6` pipeline ([`shaders/aaa_meshlet_ps.hlsl`](shaders/aaa_meshlet_ps.hlsl)) rendering `851` instances / `219,774` meshlets (**`12.41M` pre-cull tris**) across modular glass-curtain skyscrapers, Art-Deco hotels, palms, streetlamps, seawall balustrade, road lane markings, and far bayfront skyline HLOD with a live 6-mip conservative Hi-Z pyramid (`hiz_build.dxil`), plus **`500` GPU-skinned walking pedestrians** (`154,000` verts/frame via `crowd_skin.dxil` + [`shaders/aaa_crowd.hlsl`](shaders/aaa_crowd.hlsl)).
100: - **Interactive Controls, Live HUD Sliders & 60s Benchmark (`START_AAA_BENCHMARK.bat`):**
101:   - **VSync ON by default** (`--no-vsync` / `[L]` to uncap), **`[K]` VRS Tier 2** (`--vrs` / `--no-vrs`), **`[H]` On-Screen HUD Sliders** (mouse-draggable **FPS Cap `15–300 / MAX`** and **Simulation Speed `0.00x–4.00x`**, `[` / `]` FPS step, `-` / `=` / `[0]` sim speed, `[P]` Pause), `[T]` Flush VRAM Wave, `[V]` X-Ray SFS Heatmap, `[F]` SFS Budget ON/OFF, `[SPACE]` GPU Async vs 1T CPU, `[R]` DXR 1.1, `[G]` RTGI, `[C]` Camera (`Showroom` / `Chase` / `FreeCam`), **`START_AAA_BENCHMARK.bat`** (`--benchmark-run` 60s 3-act automated flythrough; optional CLI `--preset auto|low|medium|ultra`, `--scale <F>`, `--fps-cap <N>`, `--sim-speed <F>`, `--show-hud` / `--no-hud`).
102: - **Measured on NVIDIA RTX 5080 (`1920×1080` native HDR):**
103:   - **60s `--benchmark-run` (`9,026` frames):** **`150.61 FPS` Avg** (`6.64 ms`) | **`87.07 FPS` 1% Low** | **`43.37 FPS` 0.1% Low** | Active SFS **`86.2 / 204.7 MiB`** (**`118.5 MiB` VRAM saved**) | Mesh Shaders + Hi-Z **`12.41M` pre-cull → `0.99M` avg visible** (`0.18M` Hi-Z occluded) | **`500` GPU-Skinned NPCs** | DX12 Debug Layer clean (`0` errors).
104:   - **`--flush-bench` (`153.50 MiB` Mip0 BC7/BC5, `2,456` 64K-tiles):** GPU Async Compute **`217.011 ms`** vs 1-Core CPU **`5,487.356 ms`** (**`25.3×` kernel speedup**, `0.74 GB/s` full 16-lane BC7/BC5 encode+pack).
105: 
111: 
112: ![Coastal Highway 3D Live GPU BCPack + DXR 1.1 Streaming Demo](media/highway_demo.gif)
113: 
114: What `v0.6.0` adds to stress-test full Xbox Series X open-world workloads every frame alongside **Async Compute BCPack decompression**:
115: - **Hardware DX12 Ultimate Mesh Shaders (`[N]`, `shaders/meshlet_{as,ms,ps}.hlsl`):** Wave32 Amplification Shader frustum + distance culling (`~37%` culled) feeding a single `DispatchMesh` across **52,949 meshlets / 4.01M triangles** (6 Art-Deco skyline avenues, beachfront hotels, high-poly curved palms, streetlamps, and **101 animated supercars**).
116: - **1,536-Instance TLAS + 1-spp Diffuse RTGI (`[G]`, `src/rtgi.rs`):** 16-bit HDR 3-MRT G-Buffer (`R16G16B16A16_FLOAT`) with spatiotemporal IGN cosine-weighted diffuse bounce rays, **2-pass A-Trous normal/depth bilateral denoiser** (`rtgi_denoise.hlsl`), and HDR composite (`rtgi_composite.hlsl`).
117: - **32×32 World Grid LRU Residency + NVMe Streaming (`[F]`, `--world-stream --nvme-stream`):** 250 m sector grid with `LOD0 / LOD1 / HLOD` visibility rings, frustum-turn priority bursts (`509–1062 MB/s` peaks), slab page fragmentation tracking, and real out-of-order `.bcpack_pkg` SSD reads (`0.05 ms/frame`).
118: - **1440p Internal HDR (`--1440p`) & BCPack 8B Quantized Geometry:** Full `2560×1440` internal G-buffer + RTGI (`128.62 FPS` on RTX 5080) plus **8-byte UNORM16/OctN/UV meshlet vertex decompression (`1.20x` ratio, `6,241.2 MB/s` GPU)**.
119: - **Camera Modes (`[C]`):** **Chase Cam** / **Free Drive (`WASD` + `QE`)** / **Helicopter Orbit**
120: 
121: ### Side-by-Side v0.1 Comparison Video (GPU vs 1-Core CPU: 45 FPS vs 5 FPS)
122: ![GPU HLSL SM 6.6 vs CPU bcpack-rs side-by-side comparison](media/demo_preview.gif)
123: - **Full HD comparison video:** [`media/demo_comparison.mp4`](media/demo_comparison.mp4) ([Release `v0.1.0`](https://github.com/POMXARK/bcpack-gpu-hlsl/releases/tag/v0.1.0))
124: - **AI / Systems Architecture & Optimizations Guide:** [`docs/AI_ARCHITECTURE.md`](docs/AI_ARCHITECTURE.md) (complete module map, 11 unique optimizations, DXC `-O3` & RTX 5080 `621.24` workarounds, register bindings, C-ABI invariants)
129: 
130: ## What's New in `v0.3.0`: Xbox Series X|S Hardware Pipeline Parity
131: 
132: | Hardware Feature | Xbox Series X\|S | `bcpack-gpu-hlsl v0.3.0` (PC DX12) | Shader / Module |
133: |---|---|---|---|
134: | **MDU Multi-Format (BC1 + BC7)** | 12-lane BC1 & 16-lane BC7 silicon MDU | **Dual-Chunk Wave32 BC1 (24/32 lanes)** + **BC7 16-lane rANS (100% Wave32: 32/32 active lanes!)** | [`shaders/bcpack_decode.hlsl`](shaders/bcpack_decode.hlsl), [`shaders/bcpack_bc7_rans.hlsl`](shaders/bcpack_bc7_rans.hlsl) |
135: | **Gfx10 / RDNA2 64KB Swizzling** | MDU outputs `SW_64KB_D` / `SW_4KB_S` directly | GPU Compute detile pass (**184.1 GB/s**, `0.34 ms` for 64 MiB), fused on Async Compute before texture copy | [`shaders/gfx10_detile.hlsl`](shaders/gfx10_detile.hlsl) |
136: | **Parallel Compute Engine** | MDU runs asynchronously from render shaders | True **`D3D12_COMMAND_LIST_TYPE_COMPUTE`** queue + cross-queue **`ID3D12Fence`** sync (**101.8 → 140.1 FPS**) | [`src/gpu_decoder.rs`](src/gpu_decoder.rs) |
137: | **IDStorageQueueX Integration** | DirectStorage hardware decompression hook | Ready-to-link C-ABI **`bcpack_gpu.dll`** + [`include/bcpack_gpu.h`](include/bcpack_gpu.h) (`BcPackDecodeAsync`) | [`src/ffi.rs`](src/ffi.rs) |
138: | **SFS & Console Workload Profiles** | Sampler Feedback Streaming + Mip Tails + High-Entropy Normal/UI | **`[F]` SFS mode**, **Packed Mip Tail**, **High-Entropy Stress** & **1.0 GiB OOO Disk-to-Fence** bench | [`src/assets.rs`](src/assets.rs), [`src/main.rs`](src/main.rs) |
139: 
140: > **Scope note on BC7:** Upstream `Ahmet-Dedeler/bcpack-rs` (`bc5-bc7` branch) has finalized the exact 16-lane BC7 rANS entropy parameters (`BC7_ALPHABET_BITS`) while some 128-bit block-mode dictionary entries remain WIP. Consequently, [`shaders/bcpack_bc7_rans.hlsl`](shaders/bcpack_bc7_rans.hlsl) implements and bit-exactly verifies the full **16-lane rANS entropy stage (2 chunks × 16 lanes = 32/32 threads per Wave32)** against `bcpack::rans::decode_slice`.
141: 
143: 
144: ## Architecture & Pipeline
145: 
147: flowchart LR
148:     SSD["Compressed .bcpack / .ttpf Chunks (NVMe Disk / Container)"] -->|"Out-of-Order Read -> UPLOAD Heap Ring"| GPU_IN["VRAM: ByteAddressBuffer g_Streams"]
149:     GPU_IN -->|"DX12 Async Compute Queue (bcpack_decode / bcpack_bc7_rans)"| SHADER["HLSL SM 6.6 Wave32 (2 Chunks/Warp, 80B Models, groupshared Cache)"]
150:     SHADER -->|"Optional GPU Gfx10 Detile (SW_64KB_D / SW_4KB_S @ 184 GB/s)"| DET["Linear BCn Blocks (VRAM DEFAULT)"]
151:     DET -->|"ID3D12Fence -> DIRECT Queue CopyTextureRegion"| TEX["DXGI_FORMAT_BCn Textures"]
152:     TEX -->|"Render Scene + Optional [F] SFS Residency"| FRAME["SwapChain Present (140.1 FPS Live)"]
153: ```
154: 
155: ### Key Technical Solutions (`v0.4.0` Zero-Barrier + Ping-Pong Architecture)
156: 1. **Zero `GroupMemoryBarrierWithGroupSync` Inside the Hot Loop:** Both [`bcpack_decode.hlsl`](shaders/bcpack_decode.hlsl) and [`bcpack_bc7_rans.hlsl`](shaders/bcpack_bc7_rans.hlsl) keep the 64B stream window in registers and exchange bytes + decoded symbols across lanes via `WaveReadLaneAt` — eliminating 4,096+ shared-memory barriers per chunk.
157: 2. **4-Step Branchless Binary Search + Fused `decode_and_advance`:** Halves LDS lookups per symbol by locating the rANS segment with 4 binary steps and immediately computing `next_p0` in the same helper.
158: 3. **100% Wave32 Utilization on BC7 16-Lane rANS (`bcpack_bc7_rans.hlsl`):** Lanes `0..15` decode Chunk A and lanes `16..31` decode Chunk B concurrently (**all 32 threads active**, reaching **6.02 GB/s equiv BC7**).
159: 4. **Double-Buffered Ping-Pong Async Compute (`demo_scene.rs` + `gpu_decoder.rs`):** Two independent `Bc1SlotResources` slots + triple-buffered SwapChain overlap frame `N+1` decompression on `COMPUTE` with frame `N` texture copy & 3D rendering on `DIRECT` (**140.1 → 189.4 FPS** @ 8 MiB/f, **171.9 FPS** @ 32 MiB/f).
160: 5. **DXC 1.8 `-O3` Wave Intrinsics Pitfall Solved:** Replaced `WavePrefixCountBits` + `WaveActiveCountBits` inside the clocked loop with explicit `WaveActiveBallot` + `countbits(want_half & ((1u << ll) - 1u))` — **zero byte mismatches at `-O3`**.
161: 6. **AMD Gfx10 Swizzle → Linear Detile (`gfx10_detile.hlsl`):** GPU pass for `SW_64KB_D` and `SW_4KB_S` running at **432.6 GB/s** (`0.144 ms` for 64 MiB), fused on Async Compute in `BcPackDecodeAsync`.
162: 
164: 
165: ## Verified Bit-Exactness (`bcpack-gpu-demo --verify` — 21/21 PASS)
166: 
167: Tested on **NVIDIA GeForce RTX 5080** with **DX12 Debug Layer + Async Compute Queue** enabled (`v0.12.0` — **21/21 PASS**, `0` mismatches):
168: 1. **PASS 1/18 — BC1 synthetic streams** (`5` chunks, `21,824` blocks, odd chunk count): `0` byte mismatches
171: 4. **PASS 4/18 — BC7 16-lane rANS (100% Wave32 32/32)** (`5` chunks, `14,976` symbol-rows across Standard, High-Entropy Normal, and Sharp UI profiles): `0` symbol mismatches
172: 5. **PASS 5/18 — AMD Gfx10 Swizzle → BCPack → Async GPU Decode → GPU Detile → Linear BC1**: both `SW_64KB_D` (`512×512`) and `SW_4KB_S` (`256×256`) match original BC1 with `0` byte mismatches
173: 6. **PASS 6/18 — Full Mipmap Chain + Packed Mip Tail** (`512×512 .. 64×64` + `85`-block packed tail `32..4`): `0` byte mismatches
174: 7. **PASS 7/18 — C-ABI FFI `BcPackDecodeAsync` Smoke Test**: Linear BC1 + Fused Gfx10 `SW_64KB_D` + Non-blocking Async BC7 16-lane: `0` mismatches
175: 8. **PASS 8/18 — DXR 1.1 Hardware BLAS/TLAS + Inline `RayQuery`** (`4` analytical rays against unit box BVH, `0` mismatches)
176: 9. **PASS 9/18 — World Grid 32×32 Streaming + LRU VRAM Residency** (`180` frames simulated, `256` tiles GPU-verified, `242` evictions, `320`-tile turn burst, `480 MB/s` peak, `0` mismatches)
177: 10. **PASS 10/18 — Hardware Mesh Shaders (`as_6_5`/`ms_6_5`) + Frustum Culling** (`4.01M` city tris, `52,949` meshlets, `27,023` visible / `25,926` culled, `2.02M` visible tris, `25,783` lit FP16 pixels, `0` mismatches)
178: 11. **PASS 11/18 — DXR 1.1 Scale (1,536-Instance TLAS) + Bilateral RTGI Denoiser** (`0.095 ms` TLAS build; noisy FP16 variance `0.0324 -> 0.0000`, `edge_jump = 0.83`, `0` mismatches)
179: 12. **PASS 12/18 — BCPack 8B Quantized Meshlet Geometry** (`16,384` verts = `128 KiB`, ratio `1.20x`, `0` mismatches)
180: 13. **PASS 13/18 — AAA `CarConcept.glb` + Poly Haven 4K PBR BCPack** (`162,766` verts, `213,347` tris, `109` submeshes [`5` glass], `16` tex / `664` tiles = `41.50 MiB`, `0` mismatches)
181: 14. **PASS 14/18 — Virtual Descriptor Paging (SM 6.6 `ResourceDescriptorHeap[]` Tier 3)** (`1.25M` virtual IDs → `262,144` physical GPU heap slots via `CopyDescriptorsSimple`, `300,000` ops, `37,856` evictions, `65,536` verified pixel samples, `0` mismatches, [`src/descriptor_paging.rs`](src/descriptor_paging.rs) + [`shaders/bindless_paging.hlsl`](shaders/bindless_paging.hlsl))
182: 15. **PASS 15/18 — Jet-Flight 64×64 Supersonic World Grid Streaming** (`64×64 = 4,096` sectors / `256 km²`, `360` frames Mach 1/2 sweep, `14,500` tiles / `453.1 MiB` streamed, `1,487` LRU evictions, `512`-tile `16.0 MiB` burst, `960 MB/s` peak, `0` mismatches, [`src/world_streaming.rs`](src/world_streaming.rs))
183: 16. **PASS 16/18 — Two-Pass Hi-Z Occlusion Culling over 12.04M-Tri Skyline** (`159,171` meshlets, `45,585` frustum culled, `113,348` Hi-Z occluded = `8.53M` tris, `build=0.009 ms`, `cull=0.006 ms`, `0` mismatches, [`src/hiz_culling.rs`](src/hiz_culling.rs) + [`shaders/hiz_{build,cull}.hlsl`](shaders/hiz_cull.hlsl))
184: 17. **PASS 17/18 — 500 GPU-Skinned NPC Crowd Compute (4-Bone LBS)** (`500 × 1,024 = 512k` verts, `32,000` bones, `4,096` CPU-oracle samples verified, `max_err=7.63e-6`, `GPU=0.075 ms`, `0` mismatches, [`src/crowd_skinning.rs`](src/crowd_skinning.rs) + [`shaders/crowd_skin.hlsl`](shaders/crowd_skin.hlsl))
185: 18. **PASS 18/19 — Zero-Copy Shared-Device C-ABI (`bcpack_gpu_create_from_device` + `BcPackDecodeToBuffer` + GPU `Queue::Wait`):** Shares caller `ID3D12Device*`, decodes + Gfx10 `SW_64KB_D`-detiles directly into a caller GPU buffer (`D3D12_HEAP_TYPE_DEFAULT`), and syncs cross-queue via `BcPackGetComputeFence` with `0` byte mismatches ([`include/bcpack_gpu.h`](include/bcpack_gpu.h), [`src/ffi.rs`](src/ffi.rs)).
186: 19. **PASS 19/21 — Direct 2D Texture C-ABI (`BcPackDecodeToTexture2D`):** Decodes + Gfx10-detiles directly into a caller `DXGI_FORMAT_BCn_UNORM` `Texture2D` subresource (Mip 0 `512×512 SW_64KB_D` + Mip 3 `64×64` with automatic `256B` row-pitch padding), `0` byte mismatches.
187: 20. **PASS 20/21 — Full Multi-Mode `BC7` (`Modes 0..7` + Rotations + IndexSel + Dict + C-ABI `SW_64KB_D` `Texture2D`):** `5` chunks / `1,984` blocks (`9.163 ms`), bit-exact vs `bcpack::bc7::decode`, `0` byte mismatches ([`sdk/shaders/bcpack_bc7_rebuild.hlsl`](sdk/shaders/bcpack_bc7_rebuild.hlsl)).
188: 21. **PASS 21/21 — Full `BC3` + `BC4` + `BC5` GPU Decode + C-ABI:** `1,152` mixed blocks (`1.289 ms`), bit-exact vs `bcpack::bcn::decode`, `0` byte mismatches ([`sdk/shaders/bcpack_bcn_rans.hlsl`](sdk/shaders/bcpack_bcn_rans.hlsl), [`sdk/shaders/bcpack_bcn_rebuild.hlsl`](sdk/shaders/bcpack_bcn_rebuild.hlsl)).
189: 
193: 
194: ### 1. Headless Compute Benchmarks (`bcpack-gpu-demo --bench`)
195: 
196: #### BC1 Tiled 4K-Block Strips (4,096 blocks = 32 KiB BC1 per chunk — Zero-Barrier Async Compute)
197: | Batch Size | Output BC1 | CPU 1-Core | CPU Multi-Core (Rayon) | RTX 5080 v0.4 GPU | Speedup vs 1T / MT |
210: #### BC1 Monolithic 16K-Block Chunks (`128 KiB BC1 per chunk`)
211: | Batch Size | Output BC1 | CPU 1-Core | CPU Multi-Core | v0.4 Async GPU | Speedup vs 1T / MT |
212: |---:|---:|---:|---:|---:|---:|
217: #### Console-Realistic Passes (Gfx10 Detile, High-Entropy Stress & 1.0 GiB Disk Container Burst)
218: - **AMD Gfx10 `SW_64KB_D` Detile Pass (512 × 512×512 = 64.0 MiB):** **`0.144 ms` (`432.6 GB/s` effective)**
219: - **High-Entropy Stress Profiles (`1,024 × 4K-tiles = 32.0 MiB BC1`):**
222:   - Sharp Contrasting UI / HUD Grid (`2.08x`, `15,720 B/tile`): **`5.120 ms` (`6,250.4 MB/s`)**
223: - **Out-of-Order Disk Container Streaming (`1.00 GiB` over 16 × 2,048 non-sequential seeks):** Disk Read `281.53 ms` + Upload/AsyncGPU/Fence `242.55 ms` (`Kernel=91.09 ms`) = **`1.91 GB/s` sustained**
224: 
225: ### 2. Live 1280×720 3D Highway Scene FPS (Every Tile Decompressed On-the-Fly Every Frame)
226: 
227: | Executable / Mode | Streamed / Frame | Measured Live FPS | Decompression / Frame |
228: |---|---:|---:|---:|
229: | `bcpack-demo-cpu.exe` (OLD: CPU 1-Core) | 256 tiles (8.0 MiB) | **5.26 FPS** | 189.00 ms |
230: | `bcpack-demo-cpu.exe --mt` (OLD: CPU Multi-Core) | 256 tiles (8.0 MiB) | **31.14 FPS** | 29.71 ms |
231: | `bcpack-demo-gpu.exe` (v0.2 Direct Queue) | 256 tiles (8.0 MiB) | **101.81 FPS** | 5.28 ms |
232: | `bcpack-demo-gpu.exe` (v0.3 Async Compute) | 256 tiles (8.0 MiB) | **140.13 FPS** | 5.31 ms |
233: | `bcpack-demo-gpu.exe` (**v0.4 Zero-Barrier + Ping-Pong**) | 256 tiles (8.0 MiB) | **189.36 FPS** | **4.81 ms** |
234: | `bcpack-demo-gpu.exe --chunks 1024` (**v0.4 32 MiB/frame!**) | 1024 tiles (32.0 MiB) | **171.86 FPS** | **5.15 ms** |
235: | `bcpack-demo-gpu.exe` (**v0.5 + Hardware DXR 1.1 RT Shadows & Reflections**) | 256 tiles (8.0 MiB) | **171.45 FPS** | **4.77 ms** |
236: | `bcpack-demo-gpu.exe --no-rt` (**v0.5 binary w/ DXR OFF**) | 256 tiles (8.0 MiB) | **172.98 FPS** | **4.86 ms** |
237: | `bcpack-demo-gpu.exe` (**v0.6: 4.01M Mesh Shaders + 1536-TLAS + RT + RTGI**) | 256 tiles (8.0 MiB) | **152.99 FPS** | **4.77 ms** |
238: | `bcpack-demo-gpu.exe --1440p --debug` (**v0.6: 2560×1440 HDR + 4M MS + RTGI**) | 256 tiles (8.0 MiB) | **128.62 FPS** | **4.76 ms** |
239: | `bcpack-demo-gpu.exe --world-stream --nvme-stream` (**v0.6: 32×32 LRU + SSD**) | Dynamic (`0.1–8 MiB`) | **155.35 FPS** | **4.79 ms** |
240: 
247: ```bat
248: git clone --recursive https://github.com/POMXARK/bcpack-gpu-hlsl.git
249: cd bcpack-gpu-hlsl
250: cargo build --release --workspace
252: REM 1. Run all 17 bit-exact verifications (incl. 1.25M Paging, 64x64 Jet-Flight, 12M Hi-Z, 500 NPCs) + benchmark suite
253: target\release\bcpack-gpu-demo.exe --verify --bench
254: target\release\bcpack-gpu-demo.exe --rage-stress
255: 
256: REM 2. OLD CPU baseline (5 FPS) vs NEW Ping-Pong + DXR 1.1 GPU demo (153-189 FPS)
257: target\release\bcpack-demo-cpu.exe
258: target\release\bcpack-demo-gpu.exe
259: 
260: REM 3. Unified toggleable demo ([SPACE] GPU <-> CPU, [R] DXR 1.1, [G] RTGI, [N] MeshShaders, [F] WorldStream, [C] Camera)
261: target\release\bcpack-gpu-demo.exe --demo
262: 
264: python tools\fetch_aaa_assets.py
265: target\release\bcpack-aaa-demo.exe --aaa-dir aaa_assets
266: target\release\bcpack-aaa-demo.exe --aaa-dir aaa_assets --flush-bench
267: ```
268: 
269: Precompiled `bcpack_gpu.dll`, `bcpack_gpu.dll.lib`, [`sdk/include/bcpack_gpu.h`](sdk/include/bcpack_gpu.h), `.dxil`, and **Vulkan 1.3 SPIR-V ([`sdk/shaders/spirv/*.spv`](sdk/shaders/compile_spirv.sh))** are built cleanly by [`POMXARK/bcpack-gpu-sdk`](https://github.com/POMXARK/bcpack-gpu-sdk) in `target\release\` (and attached to SDK Release `v0.11.0`) for zero-copy C/C++ integration into `IDStorageQueueX` / `OpenScarlett` wrappers:
270: ```c
273: BcPackContext* ctx = bcpack_gpu_create_from_device(d3d12_device, NULL, 2048, 8388608, 96 * 1024 * 1024);
274: uint64_t fence = 0;
275: BcPackDecodeToTexture2D(ctx, stream, stream_len, num_blocks,
276:                         BCPACK_FORMAT_BC1, BCPACK_SWIZZLE_GFX10_64KB_D,
277:                         128, 128, caller_tex2d, 0, 0, 0, &fence);
278: direct_queue->Wait((ID3D12Fence*)BcPackGetDirectFence(ctx), fence);
279: ```
280: 
281: To recompile all 25 HLSL shader outputs yourself (requires Windows 10/11 SDK `dxc.exe`):
282: ```bat
287: Licensed under `MIT OR Apache-2.0`. See [`LICENSE-MIT`](LICENSE-MIT), [`LICENSE-APACHE`](LICENSE-APACHE), and [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
288: Related open-source projects & research: [`Ahmet-Dedeler/bcpack-rs`](https://github.com/Ahmet-Dedeler/bcpack-rs), [`microsoft/silicon-rans`](https://github.com/microsoft/silicon-rans), [`xcl-dev/xcl`](https://github.com/xcl-dev/xcl), [`ifBars/rage-texture`](https://github.com/ifBars/rage-texture), [`facebookresearch/dietgpu`](https://github.com/facebookresearch/dietgpu), [`weissenberger/multians`](https://github.com/weissenberger/multians).


===== Ahmet-Dedeler/bcpack-rs =====
1: # bcpack-rs
2: 
3: Decoder for **BCPack**, the rANS entropy codec that the Xbox Series X|S Media Decompression Unit (MDU) uses for block-compressed (`BC1`-`BC7`) textures. Rust crate and CLI, a stdlib-only Python reference decoder, and a written spec ([`docs/BCPACK_SPEC.md`](docs/BCPACK_SPEC.md)).
4: 
14: 
15: **BC1, BC3, BC4, BC5 and BC7 decode in the Rust library and CLI.** The synthetic stream encoder and whole-texture DDS export support all five formats. PNG export, store scanning and the Python reference handle BC1. **BC6H** has its entropy layer solved (16 lanes in `src/format.rs`), with block rebuild not implemented yet.
16: 
18: |---|---|
19: | Entropy layer (rANS) | **Exact.** Microsoft's MDU tables from the public [`silicon-rans`](https://github.com/microsoft/silicon-rans) Verilog (MIT), a clock-for-clock port of its lane decoder, bytes fed in lane order (8 per clock) with all lanes (12 or 16) in lockstep. Every lane must consume exactly its byte budget and end in a legal state, so a wrong rule fails loudly |
20: | BC1 (`bcpack::bc1`, CLI, Python) | **Decodes.** Endpoints verified (back-reference distance + zigzag residuals), complete 255-entry preset window (`data/bc1_window.json`), fitted 256-entry quadrant index codebook (`data/bc1_quad_table.json`; two independent fits agree on 248/256 entries, 99.76% of quadrants, 8 rare mirror pairs uncertain). Stream order = standard Gfx10 tiled order |
21: | BC3, BC4, BC5 (`bcpack::bcn`) | **Decodes.** Exact block rebuild rules and complete constant tables (`data/bc3.json`, `bc4.json`, `bc5.json`: 64-entry alpha pair ranks, BC3 256-entry colour quadrant ranks, 255-entry dictionaries). Byte-identical to a reference decoder on all 35 BC3 (660,992 blocks), 77 BC4 (201,728 blocks) and 333 BC5 (4,890,368 blocks) chunks across 57 stores, and independently validated on 100 BC5 + 1 BC3 chunks in issue #5. |
22: | BC7 (`bcpack::bc7`) | **Decodes.** 16 lanes (widths `4,4,8,8,8,8,8,7,7,5,6,8,8,8,8,5`), two symbols per lane per 16-byte block, exact block rebuild, all 285 control codes and the 255-entry single-subset dictionary (`data/bc7.json`). Byte-identical to a reference decoder on all 5,167 BC7 chunks (80,055,040 blocks) across 57 stores, and independently validated on 28 chunks in issue #5. |
23: | BC6H (`bcpack::format::Mode::Bc6h`) | **Entropy layer only.** 16 lanes (widths `4,4,8,8,8,5,5,5,6,6,6,8,8,8,8,5`); every chunk in the corpus converges at the rANS layer. Block rebuild not implemented yet |
24: 
26: 
27: All measured on retail Xbox Series texture pools with the commands in [Reproducing](#reproducing) (plus `docs/findings/bc345-bc7.md`). No game data is in this repository.
28: 
30: |---|---|
31: | BC3 / BC4 / BC5 / BC7 chunk decode vs reference decoder (all 57 stores, `data/bc{3,4,5,7}.json`) | **0 differing blocks** across **5,612 chunks / 85.8 M blocks**: BC3 35 chunks (660,992 blocks), BC4 77 (201,728), BC5 333 (4,890,368), BC7 5,167 (80,055,040). Independent check on issue #5 (129 chunks: 1 BC3, 100 BC5, 28 BC7; 651,264 blocks): 129/129 decode cleanly, 0 unknown BC7 controls, mip MAE matching plain baselines |
32: | BC1 exact convergence (`bcpack scan --every 20`, every 20th BC1 chunk of all 57 pools) | **5,162/5,162** chunks (97.9 M blocks): all 12 lanes end in a legal state with exactly `blocks` symbols, and the bytes consumed equal the stored length minus the pad in 5,162/5,162. 5,161 touch no unfitted preset-window slot |
33: | BC1 Rust vs the Python research pipeline (probe simulator + endpoint rule + codebook), byte for byte | **520/520** chunks identical, sampled round-robin across 52 stores (1,024-16,384 blocks), plus **12/12** chunks of 32,768-65,536 blocks |
34: | BC1 mip consistency, 600 random pair textures (BCPack mip 0 decoded, downsampled 2x, compared with the plain mip 1) | 600/600 decode, none touching an unfitted window slot. Median **35.5 dB**, p10 30.7, p90 42.0 (flat mean-colour baseline 22.6); 0 below 25 dB, 16 not at least 3 dB above flat. With the purely fitted window the same set scored median 35.4, p10 30.2, 3 below 25 dB. With only the first 16 window slots the same set scored median 27.6, p10 7.3 |
35: | BC1 held-out check of the fitted tables (fit on half the texture pools, decode the other half) | Preset window fitted on even pools, scored on odd: 1,514 textures, median **34.7 dB**, p10 29.7. Reverse: 1,481 textures, median **34.0 dB**, p10 28.7. In-sample on all: 34.4 dB. The two half-fits agree within ±1 on 228/249 slots (99.9% of blocks by use). Index codebook fitted on half the pools: 36.6 / 36.1 dB held out, 248/256 entries identical between halves. 200 random textures larger than 512 px: 200/200 decode, median 37.4 dB. Plain BC1 ceiling on the same test: 37.9 dB |
36: | BC1 speed | **34-40 MB/s of BC1 output per core** (4.3-5 M blocks/s, 25 MB/s compressed input), CPU time, `bcpack bench` on 4,096- and 65,536-block chunks. Chunks decode independently, so `scan` scales across cores (8 threads on a heavily shared machine: about 110 MB/s). Below the 50 MB/s per-core target |
37: 
38: The plain-BC1 ceiling of the mip-consistency check is about 37.9 dB median. The 5 chunks the research simulator reported as non-converging decode here (see `docs/findings/decoder.md`).
39: 
46: | `patent` | Reference decoder with tables generated from Microsoft's `mdu_minirans.v`, patent (`US11234023B2`) notes |
47: | `prior-work` | Public BCPack facts collected from other projects, with contradictions noted |
48: | `probe` | Cycle-level multi-lane MDU simulator, BC1 convergence scan over 15,000 chunks |
49: | `harness` | Shared test bench: corpus index, convergence oracle, mip-consistency scorer |
50: | `sem-indices` | The 256-entry quadrant index codebook and its held-out checks |
63: cargo build --release
64: bcpack decode-bc1 chunk.bin 4096 out.bc1        # chunk bytes (zero pad allowed) + block count
65: bcpack decode-bc5 chunk.bin 4096 out.bc5        # decode-bc3, decode-bc4 and decode-bc7 work likewise
66: bcpack symbols --format bc5 chunk.bin 4096      # one line per lane (default format: bc1)
67: bcpack ttpf-export pool.ttpf 318 out.png        # mip 0 of a BC1 texture, decoded + detiled (.png or .dds)
68: bcpack scan --jobs 8 --every 10 pools/*.ttpf    # convergence and speed over stores
69: bcpack ttpf-export pool.ttpf 318 out.dds        # mip 0 in BC1, BC3, BC4, BC5 or BC7
70: bcpack bench --format bc7 chunk.bin 4096        # single-core speed (default format: bc1)
71: ```
78: // BC1 (8 bytes per block)
79: let window = bcpack::bc1::Window::default_table();
80: let quads = bcpack::bc1::QuadTable::default_table();
81: let bc1_out = bcpack::bc1::decode(&chunk, blocks, &window, &quads)?; // blocks * 8 bytes
82: 
83: // BC3 / BC4 / BC5 (`unpacked_len` is the chunk's virtual byte length)
84: let bc5_tables = bcpack::bcn::Tables::default_for(bcpack::format::Mode::Bc5).unwrap();
85: let bc5_out = bcpack::bcn::decode(&chunk, unpacked_len, bc5_tables)?;
86: 
87: // BC7 (`unpacked_len` is the chunk's virtual byte length)
88: let bc7_tables = bcpack::bc7::Tables::default_table();
89: let bc7_out = bcpack::bc7::decode(&chunk, unpacked_len, bc7_tables)?;
90: ```
94: ```toml
95: bcpack-rs = { git = "https://github.com/Ahmet-Dedeler/bcpack-rs", default-features = false }
96: ```
97: 
98: Features: `ttpf` adds the RDS5 store reader, Gfx10 detiling, whole-texture decode and PNG output (`flate2`, `png`; PNG for BC1). `cli` (default) adds the `bcpack` tool on top (`rayon`).
99: 
100: Python reference (BC1, slow, readable): `python3 -I python/bcpack.py decode-bc1 chunk.bin 4096 out.bc1`.
101: 
108: - `src/bc7.rs`: lane symbols to BC7 blocks (control codes, 255-entry dictionary, BC7 block pack/unpack)
109: - `src/ttpf.rs`: RDS5 stores, ETPF texture index, Gfx10 mip layout and detiling, BC1 to RGBA, DDS/PNG
110: - `src/encode.rs`: synthetic stream encoder for tests (reverse rANS per fragment, interleaved by replaying the feeder)
111: - `src/tables.rs`, `python/bcpack_tables.py`: generated from `mdu_minirans.v` by `tools/gen_tables.py`
112: - `data/`: built-in constant tables (`bc1_window.json`, `bc1_quad_table.json`, `bc3.json`, `bc4.json`, `bc5.json`, `bc7.json`)
113: - `python/bcpack.py`: BC1 reference decoder, pure Python
114: 
118: cargo test --release
119: python3 -I python/bcpack.py selftest
120: ```
125: 
126: The retail checks need your own copy of the texture pools; point the harness at it with `BCPACK_GAME_ROOT`. The bench scripts live on the `harness` branch (`tools/bench`).
127: 
128: - convergence: `bcpack scan --jobs 8 --every 20 $BCPACK_GAME_ROOT/data/ttdb/**/*.ttpf $BCPACK_GAME_ROOT/pack/*/data/ttdb/**/*.ttpf`
129: - mip consistency: decode each pair texture's mip-0 chunk with `bcpack decode-bc1` and score with `tools/bench/mipscore.py score TEXTURE_ID out.bc1 --order stream`
130: 
133: - Microsoft [`silicon-rans`](https://github.com/microsoft/silicon-rans) (MIT): the reference MDU rANS decoder and its exact model tables. See `THIRD_PARTY_NOTICES.md`. The same design is described in patent US11234023B2.
134: - SixNG format notes (holdmysocks, walkthestars, TrinitronClient and contributors): RDS5/ETPF container, chunk table, Gfx10 layouts, BCPack header observations.
135: - Xbox2Windows (R0Y00) and MarlomMedeiros' corpus-wide BCPack measurements (issue #15): fixed 8-byte rounds, demand-driven refills, the 2/3-byte length flag, lane-dependent constant models.
136: - Leonida (Kam471): per-codec chunk counts and size statistics across all pools.
137: - paryzius' ttpf-viewer: exact Gfx10 detiling and mip-tail placement, ported in `src/ttpf.rs`.
138: 