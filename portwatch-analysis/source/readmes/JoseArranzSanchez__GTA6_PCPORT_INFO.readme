# GTA VI on PC / Xbox Series X — Open Feasibility Report

**Document:** technical, market and legal research on the state of the unofficial GTA VI PC port.
**Audience:** anyone interested in the topic, with no prior knowledge required.
**Data cut-off:** 24 November 2026, 19:00 CET (18:00 UTC).
**Last review:** 25-11-2026, 01:50 CET.
**Last addition:** PortWatch VI, 24-11-2026, 20:27 CET.
**Nature:** documentation and research. Not legal advice.

> **Important notice**
> This report **does not include links or instructions to download the leaked executable, decrypt it, extract keys or bypass console protections**. That is exactly what Take-Two is pursuing with DMCA notices and lawsuits, and what makes the project a crime in Spain and the United States. The rest —what exists, what is real, what can be learned and how to play cheaply— is covered here.
>
> **Scope:** this repository is documentation and research. It does not contain game files, keys or circumvention instructions. See [DISCLAIMER.md](DISCLAIMER.md). Original content license: [CC BY 4.0](LICENSE).
>
> **Found an error?** Open an [issue](https://github.com/JoseArranzSanchez/GTA6_PCPORT_INFO/issues) with the section, the sentence and the source. Corrections are welcome.

## About this document

- **Data cut-off:** 24-11-2026, 19:00 CET (18:00 UTC). Everything below is a snapshot of that moment.
- **What was consulted:** GitHub API (repository searches and metadata), project pages and READMEs, linked press, Xbox Wire, GitHub DMCA notices and Code Bear's video.
- **How dates are shown:** each section states the cut-off date of its data. Publication dates are shown when the source makes them visible; otherwise, "n/d" is used.
- **Limitations:** project statuses are self-reported and have not been independently reproduced. GitHub figures change daily and include noise.
- **Tools:** this document was produced with the help of **OpenCode** (AI agent) and the **DeepSeek V4.1 Flash 1017** model, with human review by the maintainer.
- **Automatic updates:** the "Status right now" block, [`STATUS.md`](STATUS.md) and [`data/status.json`](data/status.json) are regenerated every hour by GitHub Actions. The rest of the document is manually curated with a 24-11-2026, 19:00 CET cut-off.
- **Last addition (24-11-2026, 20:27 CET):** PortWatch VI, an external progress tracker and its repository, covered in section 3.6.
- **Scope of automation:** GitHub metrics only (searches, stars, issues and last push). Press, legal, analysis and contacts are manually curated.
- **Force an update:** on GitHub, **Actions → Update status → Run workflow**. The cron runs every hour at minute 0 (UTC).
- **Time zone:** Europe/Madrid (CET, UTC+1).

### Information traceability

| Block | Last consulted | Published |
|---|---|---|
| Code Bear video | 24-11-2026, 19:00 CET | 23-11-2026 |
| Press and analysis | 24-11-2026, 15:20-15:45 CET | n/d for most |
| Repositories and metadata | 24-11-2026, 19:00 CET (main) / 15:30-15:45 CET (forks) | last push: 24-11-2026 |
| DMCA and legal | 24-11-2026, 15:35-15:45 CET | 18-11-2026 and 19-02-2021 |
| Xbox Wire / cloud | 24-11-2026, 15:35-15:45 CET | 10-11-2026 and 23-11-2026 |
| Topic `reverse-engineer-anything` | 24-11-2026, 15:30-15:45 CET; count refreshed at 19:00 CET | n/d |
| PortWatch VI | 24-11-2026, 20:27 CET | 24-11-2026 (Notebookcheck article) / live data |

<!-- AUTO:STATUS:START -->
### Status right now (auto-updated)

**Last update:** 26-11-2026, 05:46 CET (Europe/Madrid).

- **GTA VI:** released on 19-11-2026 on PS5 and Xbox Series X|S; no PC version announced.
- **Unofficial port:** no public project is playable; the best state is menus and a black world load.
- **GitHub:** `gta 6` 20,685 · `gta6` 17,715 · `leonida` 2,845 · `topic:gta6` 1,123.
- **XCL:** 8.3k stars · 1,657 issues+PRs · last push 2026-11-26.
- **VIctory:** 12.7k stars · 1,841 issues+PRs · last push 2026-11-25.
- **Leonida:** 2.4k stars · 1,405 issues+PRs · last push 2026-11-26.
- **Legal:** Take-Two continues DMCA takedowns; the 18-11 notice is about GTA V (Muguet), not GTA VI.
- **Cloud:** GTA VI on Xbox Cloud Gaming is console-only; on PC only Remote Play from a console.

[Full detail](STATUS.md) · [JSON data](data/status.json)
<!-- AUTO:STATUS:END -->

---

## 0. Verdict in 30 seconds

1. **GTA VI launched on 19-11-2026 on PS5 and Xbox Series X|S. No PC version has been announced.** The most cited rumour points to Q1 2027, but Rockstar has not confirmed it.
2. **There is no general Xbox Series X|S emulator.** What exists are compatibility layers and experimental recompilation projects that, at best, boot the leaked executable and reach the menus. **Nothing is playable.**
3. **"The CPU is almost the same" is true and irrelevant at the same time.** The CPU is x86-64 Zen 2, yes, but the game talks to a Windows-derived OS, a hypervisor, the GDK's `kernelx`/`d3d12_xs` APIs and custom RDNA2 shaders. Instruction compatibility is ~5% of the problem.
4. **Running the leaked build locally is not viable with €0 or without a PC.** Not for lack of talent, but because it needs Windows hardware with a 16 GB GPU, the leaked game (illegal) and months or years of team work.
5. **What is possible with €0:** learning reverse engineering with free tools and legal targets, and contributing to open-source projects by compiling and running tests in the cloud (no hardware).
6. **The cheapest way to play GTA VI in Spain:** a used Xbox One + the game + Xbox Cloud Gaming hours (cloud is only enabled on Xbox consoles), or a used Series S. From a laptop you can use **Remote Play** from a console that has the game.
7. **External tracking:** PortWatch VI monitors ~30 projects and also answers "not yet". Its top entry (CGBJ, 72%) is a private build that nobody outside the group can reproduce.

---

## 1. The video: what it is and what it says

| Field | Value |
|---|---|
| Title | *Is GTA 6 Really PORTED to PC? (fact checked)* |
| Channel | Code Bear (`@thecodebear`) |
| Published | 23-11-2026 (the page does not show the time) |
| Consulted | 24-11-2026, 15:30 and 19:00 CET |
| Views / likes at last check | 35,708 / 491 |
| Credits | Code Bear (`@thecodebear`), YouTube |
| Link | https://www.youtube.com/watch?v=P0o-Fh-VSxo |

**Video credits:** written, narrated and edited by **Code Bear**. This document summarises his analysis and links his sources; the credit for the original work belongs to the author.

**Thesis of the video:** four days after launch, the Internet filled up with "GTA 6 on PC" videos. The **Cyberleek/Cyberleak** group had released the Xbox executable and several amateur teams were racing to make it boot on Windows. The author splits the problem into **5 stages** (boot, picture, menus, world, playable), reviews **41 viral clips** and concludes that some are real, some are fake, and **the real ones show far less than their headlines claim**. There is no playable version. "GTA 6 PC downloads" are malware.

**Chapters:**

| Minute | Chapter |
|---|---|
| 0:00 | Ported to PC |
| 1:07 | One missing file |
| 2:12 | Why an Xbox game won't just run on PC |
| 4:33 | The race starts |
| 5:31 | Stage 1: does it start? |
| 5:58 | Stage 2: a picture |
| 6:28 | Stage 3: the menus |
| 7:12 | Stage 4: the world |
| 8:45 | Stage 5: playable? |
| 9:06 | Checking the viral clips |
| 12:29 | Leonida goes dark |
| 13:23 | Take-Two and the law |
| 14:40 | The scams |
| 15:25 | Where it really stands |

**Two notes about the video itself:**

- YouTube labels it as **"Made with AI"** ("Sounds or visuals were altered or fully generated"). It should be used as a map and a source list, not as definitive technical proof.
- The video says Take-Two has not commented on the executable, but **there is a Take-Two DMCA notice dated 18-11-2026 on GitHub**. Note: that notice **is not about GTA VI**; it is about *Muguet*, a **GTA V** port to iOS/macOS. It is still relevant because it contains the applicable doctrine: *"bring your own files" does not protect you*. It is detailed in section 5.

---

## 2. All sources from the video description

**Method:** ✅ marks sources that responded correctly when checked; ⚠️ marks those that block bots or could not be fully verified. All sources in this section were consulted on **24-11-2026 between 15:20 and 15:45 CET**; the publication date is shown when the page makes it visible; otherwise, the consultation date is recorded.

### 2.1. Press and analysis

| Source | Link | What it contributes |
|---|---|---|
| XDA — the leaked .exe and the recompilation projects | https://www.xda-developers.com/gta-6-xbox-executable-leaked-opening-door-for-pc-recompilation-projects-begin-testing/ | ⚠️ Blocks automated access; cited in the video |
| GamesRadar — "the game almost boots" | https://www.gamesradar.com/games/grand-theft-auto/gta-6-pc-version-is-close-modders-say-after-cyberleek-releases-executable-the-game-almost-boots/ | ✅ Context and status |
| TweakTown — boots in 3 hours | https://www.tweaktown.com/news/114839/gta-6-boots-on-pc-only-3-hours-after-xbox-executable-leaked/index.html | ✅ The headline that made it viral |
| VGTimes — menus, not gameplay | https://vgtimes.com/gaming-news/175531-unverified-gta-6-pc-videos-show-menus-not-gameplay.html | ✅ Separates menus from gameplay |
| Notebookcheck — .exe release | https://www.notebookcheck.net/Cyberleek-releases-GTA-6-Xbox-build-exe-boosting-playable-PC-port-chances.1457977.0.html | ✅ Timeline |
| LevelUp — version 1.0.2.1 | https://www.levelup.com/en/news/cyberleek-leaks-gta-6s-executable-file-and-modders-are-already-working-on-a-playable-pc-version/ | ✅ Specific build |
| TwistedVoxel — the Leonida developer quits | https://twistedvoxel.com/gta-6-pc-recompilation-leonida-developer-quits/ | ✅ Key to understanding sustainability |
| MakeUseOf — "unofficial port on the way" | https://www.makeuseof.com/gta-6-unofficial-pc-port-on-its-way/ | ⚠️ Blocks bots |
| XDA — the viral "port" was a hoax using GTA V footage | https://www.xda-developers.com/that-viral-gta-6-pc-port-video-hoax-made-from-recycled-gta-5-footage/ | ⚠️ Key to not believing clips |
| XDA — NotRexed / Hookshot | https://www.xda-developers.com/?s=GTA+6 | ⚠️ Exact link not verifiable; site search |
| Notebookcheck — PS5 Pro + DLSS 5 | https://www.notebookcheck.net/GTA-6-PS5-Pro-performance-jumps-to-280-fps-on-PC-with-DLSS-5-transforming-Lucia.1453555.0.html | ✅ Example of marketing figures |
| Basic Tutorials — VirusTotal 34/68 | https://basic-tutorials.com/news/gta-6-pc-cyberleek-releases-xbox-exe-leonida-port-remains-unreleased/ | ✅ Security |

### 2.2. Repositories cited in the video

| Project | Link | What it is |
|---|---|---|
| VIctory | https://github.com/marvisak/VIctory | GTA VI-specific runtime |
| XCL | https://github.com/xcl-dev/xcl | Xbox Series → Windows compatibility layer |
| Xbox2Windows | https://github.com/R0Y00/Xbox2Windows | Static recompilation x64 → C++ |
| GTA6-BootTest | https://github.com/OnlyMoisties/GTA6-BootTest | Stand-in DLLs + harness |
| Leonida (continuation) | https://github.com/ubiquitarianism/leonida | Xbox → PC interface, GPL-3.0 |
| "Race" tracker | https://vuyp.github.io/gta6-pc-race/ | Aggregator of self-reported claims |

### 2.3. Legal

| Source | Link | What it contributes |
|---|---|---|
| Take-Two DMCA, 18-11-2026 | https://github.com/github/dmca/blob/master/2026/11/2026-11-18-take-two.md | ✅ **It is about Muguet (GTA V), not GTA VI**; contains the doctrine that "bring your own files" does not protect you |
| Take-Two DMCA against re3/reVC, 2021 | https://github.com/github/dmca/blob/master/2021/02/2021-02-19-take-two.md | ✅ Direct precedent |
| TorrentFreak — Take-Two sues re3/reVC | https://torrentfreak.com/take-two-sues-enthusiasts-behind-gta-fan-projects-re3-revc-210903/ | ✅ |
| Dexerto — Zelnick's warning | https://www.dexerto.com/gta/gta-6-boss-sends-warning-to-pirates-who-make-ai-generated-pc-version-before-official-release-3426850 | ✅ |
| RTÉ — "GTA hacker" sentenced | https://www.rte.ie/news/2026/1123/1600335-gta-hacker/ | ✅ Recent criminal case |

### 2.4. Security and scams

| Source | Link | What it contributes |
|---|---|---|
| Cyber Security News — 355+ fake domains | https://cybersecuritynews.com/fake-gta-6-pc-launchers/ | ✅ |
| Netcraft — campaign around launch | https://www.netcraft.com/blog/how-attackers-are-capitalizing-on-the-hype-around-the-grand-theft-auto-vi-release | ✅ |
| MakeTechEasier — $200 scam kit | https://maketecheasier.com/gta-6-pc-port-scam-kit/ | ✅ |

### 2.5. Technical references cited in the video

| Project | Link | Why it matters |
|---|---|---|
| Xenia (Xbox 360) | https://github.com/xenia-project/xenia | A real emulator for the previous generation |
| Zelda64Recomp | https://github.com/Zelda64Recomp/Zelda64Recomp | Example of static recompilation |
| UnleashedRecomp | https://github.com/hedge-dev/UnleashedRecomp | Another example of a recompilation port |

---

## 3. Real state of the ecosystem (cut-off: 24-11-2026, 19:00 CET)

### 3.1. What is on GitHub, in numbers

Searches run against the GitHub API on **24-11-2026 at 20:27 CET (19:27 UTC)**. The numbers change every hour:

| Search | Results |
|---|---:|
| `gta 6` (name, description, README) | 20,437 |
| `gta6` | 17,616 |
| `leonida` | 2,804 |
| `"grand theft auto vi"` | 418 |
| `topic:gta6` | 1,121 |
| `topic:xbox-series-x` | 63 |
| `topic:reverse-engineer-anything` | 20 |

**Translation:** there are no 3,000 port projects. There are tens of thousands of matches, and the vast majority are:

- clipping tools for streamers ("turn GTA 6 streams into Shorts"),
- HUDs and mods for GTA V,
- SEO/affiliate repos generated with AI, created in bulk,
- **fake emulators and "preloads"** that are malware or simply an empty ZIP,
- duplicate forks of the same 4-5 real projects.

Of the 25 most popular repositories reviewed, **fewer than 10 contain real technical code**. The rest is noise. Star counts are not reliable either: some projects have more than 10,000 stars and were created less than 24 hours ago.

### 3.2. The 5 stages, and who is at each one

| Stage | What it means | Real status |
|---|---|---|
| 1. It boots | The .exe loads and executes code | Several projects get here |
| 2. A picture | The D3D12 device is created and a frame is produced | Some, with translated shaders |
| 3. Menus | Navigable UI | XCL, VIctory, Leonida and forks |
| 4. World | World load and visible scene | **Partial and dark only**; 0.3–1.8 s per frame |
| 5. Playable | You can actually play | **Nobody** |

The authors themselves say it in their READMEs: "the game does not boot", "there is no complete frame", "self-reported, one machine". Treat them as lab prototypes, not products.

### 3.3. The projects that matter

> **Note:** main data refreshed on **24-11-2026 at 19:00 CET**; forks and asset tools were consulted between 15:30 and 15:45 CET. Stars are from that moment. "Status" is what the project **claims**, not something independently reproduced. Several repos have disappeared in the last 48 hours.

| Project | What it is | Claimed status | Stars | Note |
|---|---|---|---:|---|
| **XCL** (`xcl-dev/xcl`) | Wine-style compatibility layer: runs native x64 code and reimplements `kernelx`, `d3d12_xs`, DirectStorage and XAudio2; translates RDNA2 shaders to DXIL | Boots in ~4 s, menus and settings, ~30 fps without crashing; **does not reach gameplay**; ~15 GB RAM. Also runs *Minecraft Preview* and *Unicorn Overlord* | 7.4k | The most technically credible. GPL-2.0. 1,019 open issues |
| **VIctory** (`marvisak/VIctory`) | GTA VI-specific runtime: loads native x86-64, reimplements APIs and recompiles shaders to DXIL | Boot, intro with sound, start screen at 30 fps; loads the world but the scene is dark at 0.5–1.8 s/frame; can hang the driver | 10.2k | The "furthest" in public, but **not playable**. 1,193 open issues |
| **Leonida** (`ubiquitarianism/leonida`) | Continuation of the largest static recompilation project; GPL-3.0 | Its README still says the game does not boot; 824 open issues | 1.6k | The original `ItsNotRexed/Leonida` went offline on 23-11 |
| `ProjectLeonidaL/leonida` | "Official" continuation of Project Leonida | Static recompilation, no complete frame | 256 | Created on 24-11 |
| `LeonidaReforge/Leonida` | Another continuation | Same | 379 | Fork with 354 MB of history |
| `avivetech/Leonida` | Copy after the fall of `ItsNotRexed` | Same | 134 | "main = last upstream main" |
| `luizwidmer/palmetto` | "Clean-room" runtime | Its author says it gets further into rendering; no frame | 118 | Leonida continuation |
| `IAmNotSiob/leonida-ce` | Community edition | Same | 19 | Duplicate |
| `Cappi1998/LONDBackup` | Backup of the tree | Same | 20 | Duplicate |
| **Xbox2Windows** (`R0Y00/Xbox2Windows`) | Static recompilation: x64 → C++ and gfx1013 → DXIL | With a **modified** build that skips asserts, it played the intro and reached loading; the unmodified .exe, menus and gameplay **are unverified** | 1.9k | Research, not a product. 156 open issues |
| **AnyXboxX** (`LooperSalty/AnyXboxX`) | GDK HLE on Unicorn + C++ runtime | Opening credits with a black scene at 0.3–0.5 fps | 218 | Prototype. 39 open issues |
| **OpenScarlett** (`californiaAlmonds/OpenScarlett`) | Scarlett translation layer: PE32+ loader, `d3d12_xs`, `kernelx`, RDNA2 → SPIR-V/DXIL | Runs 6 Microsoft samples; *Minecraft Preview* playable; GTA VI only resolves imports and creates render targets | 80 | Not GTA-specific |
| **XValkyrie** (`sammwyy/xvalkyrie`) | Xbox One + Series compatibility layer | 49 titles in its table: 8 playable, 12 reach a menu; GTA VI does not | 214 | The most "Wine-like" |
| **GTA6-BootTest** (`OnlyMoisties/GTA6-BootTest`) | Stand-in DLLs, debug harness and shader translator | Boots, streams files, runs the frame loop and draws the first UI; compute/tiled textures/blending incomplete | 40 | "No game code" |
| **awesome-gta6-reverse-engineering** | Curated list of GTA VI RE tools | Updated on 24-11 | 670 | **The best entry point** |

### 3.4. The Leonida saga: the most important lesson

- The **Leonida** project was born on 20-21 November, accumulated thousands of PRs and translated **26,503 RDNA2 shaders to SPIR-V**, exported models, textures and audio.
- The author **announced he was leaving on 23-11** and the repository and its Discord disappeared that same night.
- In less than 24 hours, **six continuations** appeared (`ubiquitarianism`, `ProjectLeonidaL`, `LeonidaReforge`, `avivetech`, `palmetto`, `leonida-ce`), several with the full 350 MB tree.
- **None has published a complete frame.**

That is not a technical problem: it is a problem of **sustainability, ego and legal risk**. A project that depends on a leaked binary and a single person is not a project; it is an incident.

### 3.5. How to tell a real repo from a scam

Quick checklist:

- **Creation date:** if the repo was created this week and promises "100% working", be suspicious.
- **Code vs. README:** open `src/`, look at real commits. A 500-line README with a ZIP is not a project.
- **Stars:** 10,000 stars in less than 24 hours = hype, not quality.
- **Issues:** a real project has reproducible bugs, logs and technical discussion. A fake one has "not working" and nothing else.
- **Releases:** binaries with hashes, reproducible builds, CI. A 146 MB unsigned `.exe` is a game of Russian roulette.
- **Claims:** "GTA 6 PC 2026", "preload included", "no BIOS", "DLSS 5", "120 fps" → scam keywords.
- **Game files:** if the repo includes the .exe, keys or assets, it is direct infringement. If it says "bring your own copy", it is still a legal risk (see section 5).
- **VirusTotal:** the video itself cites a case with **34/68 detections**.

### 3.6. PortWatch VI: external progress tracker

[PortWatch VI](https://portwatch-vi.xyz/) is a separate, fan-made tracker that aggregates community GTA VI recompilation and emulation efforts on one ladder.

- **Site:** https://portwatch-vi.xyz/
- **Repository:** https://github.com/4lwayz/portwatch-vi
- **Machine-readable data:** https://portwatch-vi.xyz/data/tracker.json (refreshed every 3 hours by its scout)
- **What it tracks:** ~30 projects, a leaderboard, news, a watchlist of early efforts, an asset-toolkit section and a fake-download warning page.
- **Status at 24-11-2026, 20:27 CET:** the site answers "Not yet". Its leaderboard is topped by CGBJ at 72% (a private build; PortWatch says it verified in-game movement, but the code is not public and nobody outside the group can reproduce it). The public projects are still around the menus/world-load stage.
- **Method and caveat:** scores come from each project's public README, commits and issues; self-reported claims are labelled. It is not independent verification, and the leaderboard can change every 3 hours. The site states that it does not host or link game files, keys or executables.
- **Repository data at 20:27 CET:** 2.5k stars, 58 forks, 42 open issues.
- **Press:** Notebookcheck covered the tracker on 24-11-2026: https://www.notebookcheck.net/GTA-6-This-website-lets-you-track-the-PC-recompilation-live.1458797.0.html
- **Credits:** 4lwayz (maintainer) and the tracker's X account, [@lithuaniangroyp](https://x.com/lithuaniangroyp).

For the live GitHub metrics of PortWatch's repository, see [`STATUS.md`](STATUS.md).

---

## 4. Why "the CPU is the same" is not enough

### 4.1. The specs do look similar

| | Xbox Series X | Typical equivalent PC |
|---|---|---|
| CPU | AMD Zen 2, 8C/16T, 3.8 GHz (3.66 with SMT) | Ryzen 7 3700X / 5800X |
| GPU | RDNA 2, 52 CUs, 1.825 GHz, 12.15 TFLOPS | RX 6700 XT / RTX 4060 Ti |
| RAM | 16 GB GDDR6 (10 GB at 560 GB/s + 6 GB at 336 GB/s) | 16-32 GB DDR4/DDR5 |
| OS | Windows-derived Xbox OS + hypervisor | Windows 11 |
| Graphics API | `d3d12_xs` (console D3D12) + extensions | D3D12 / Vulkan |
| Shaders | RDNA2 `gfx1013`, compiled for the console | DXIL / SPIR-V |
| Package | Signed and encrypted MSIXVC | .exe / Steam / Epic |

### 4.2. What is really missing

1. **The OS and the hypervisor.** An Xbox game does not run "on Windows": it runs on an Xbox OS partition, with a hypervisor managing memory, GPU and security. That does not exist on PC.
2. **The APIs.** The binary imports `kernelx`, `d3d12_xs`, `xgameruntime`, `xmem`, DirectStorage, XAudio2/XMA2. Windows does not have those DLLs. They must be reimplemented (that is XCL/XValkyrie) or the binary must be translated (recompilation).
3. **The package format.** MSIXVC is signed and encrypted. Copying the .exe is not enough: the package must be mounted, and that involves keys and protection.
4. **The shaders.** They are not PC DXIL: they are RDNA2 ISA with console extensions. Tens of thousands of programs (`shaders.rpf`) must be translated. XCL claims 26,698; Leonida, 26,503. It is enormous, partial work.
5. **Memory.** 16 GB unified with two pools of different speeds and aliasing (`xmem`). A PC with a dedicated GPU has a different model; memory bugs are the usual cause of hangs.
6. **I/O.** Console DirectStorage, BCPack compression, tiled textures, Bink 2, AWC/ADAT. All of that must be decoded.

### 4.3. Why there is no "Series X emulator"

- **Xenia** emulates Xbox 360 (PowerPC, 2005). **Xemu** emulates the original Xbox (2001). **Neither** runs Series X games.
- **RPCS3** (PS3) and **shadPS4** (PS4) exist because there are years of research, documentation and a huge community. For Series X there is no public boot chain, no hypervisor documentation and no keys.
- The projects that do exist are **HLE** (reimplementing APIs) or **static recompilation** (translating code), not full emulation. It is the difference between "Wine" and "a PlayStation 3 emulator".
- **XEVOD, APKOD, "Xbox Series X Emulator for PC"**: they are not emulators. They are download pages with a ZIP, marketing and, at best, a visual theme. The very article that lists them admits that "there is no official emulator".

### 4.4. What the current state does prove

- That a small team **can** take a console binary to show menus on Windows in days. That is a real achievement.
- That "showing menus" and "playing" are separated by an abyss: world, streaming, GPU, memory, audio, input, physics, missions.
- That the bottleneck is not the CPU: it is **the GPU, memory and the system**.

### 4.5. Gap map: from menus to "playable"

Section 4.2 explains why the architecture is not enough. This section breaks down the remaining work, layer by layer.

> High-level engineering analysis. **It is not an execution guide** for the leaked binary and does not include offsets, keys, patches or circumvention instructions.

| Layer | What already exists | What is missing | Difficulty |
|---|---|---|---|
| **1. Loading and boot** | PE loader, imports, memory, file system | Little; this is the most solved part | Low |
| **2. Device and UI** | D3D12 device, swapchain, 2D, video, input | Little; menus already render | Low-medium |
| **3. World** | RPF9, textures, models, initial streaming | Full streaming, LOD, collisions, interiors | High |
| **4. World rendering** | Shader translation to DXIL/SPIR-V | Compute, lighting, shadows, materials, post-processing, barriers | **Very high** |
| **5. Simulation** | Nothing relevant | Physics, animation, AI, traffic, missions, weather | **Very high** |
| **6. Audio** | Partial | XAudio2/XMA2, mixing, APU | Medium |
| **7. Memory** | Basic `xmem` | Alias/commit/decommit, residency, 10+6 GB pools | **Very high** |
| **8. Threading** | Partial | 8-core job system, fibers, waits, priorities | High |
| **9. Performance** | 0.5-1.8 s/frame in the world | Get to 33 ms without breaking the image | **Very high** |
| **10. Verification** | Self-reported claims | Reference captures, GPU matrix, CI, regression | High |

**GPU: translating is not preserving semantics.** XCL claims to have translated 26,698 programs and VIctory 26,503, but a correct translation is not the same as a faithful one. RDNA2 has wave32/wave64, lane masks, LDS, bindless descriptors, denormal flushing, NaN, saturation, integer dot products and bounds-checking rules that DXIL does not replicate 1:1. A single mistranslated intrinsic in a compute shader leaves the world black or hangs the driver. And what is missing is not one shader: it is **the entire GPU-driven pipeline** (culling, skinning, particles, hair, volumetric fog, deferred lighting and post-processing). Menus use a small 2D subset; the world uses the whole engine.

**Memory: the real wall.** Series X has 16 GB unified in two pools (10 GB fast + 6 GB slow) and the game uses `xmem` to alias, reserve and free memory as if it owned it. On PC, VRAM and RAM are separate. The compatibility layer has to emulate that address space, residency and barriers. If a resource ends up in the wrong state, no error appears: garbage, a hang or a driver TDR appears. The projects themselves ask for ~15 GB of RAM; with 16 GB of VRAM you are at the limit.

**Streaming and threading: the world is not a screen.** Loading the RPF9 and drawing the first screen is the easy part. What is missing is **cell streaming** (LOD, interiors, collisions, navmesh) and the **job system** that distributes physics, animation, AI and traffic across 8 cores with fibers and wait-on-address. On PC the scheduler is different: deadlocks, priority inversions and races appear that do not exist in menus. That is why "loads the world" and "can be played" are different milestones.

**Performance: the current frame is incomplete.** That 0.5-1.8 s/frame is with a black scene and no compute. Adding lighting, shadows and post-processing **increases** the cost, not decreases it. For 30 fps you need 15 to 60 times less time, and also to prevent Windows from restarting the driver due to TDR (2 s by default). It is not fixed with a faster GPU: it is fixed by correcting the pipeline.

**Verification: without a reference there is no proof.** Public results are self-reported, on one machine and without comparable captures. Real verification needs a reference (console capture, API trace, frame capture), a GPU and driver matrix, and regression tests. That is lab work, not a weekend project.

**Why "it reaches the menu" is misleading.** A menu exercises boot, file system, 2D renderer, video, input and a small subset of D3D12. The world exercises streaming, compute, culling, materials, physics, animation, 3D audio, memory and all 8 cores. It is the difference between starting the car and winning a race. The milestone is real and commendable, but it covers a small percentage of the engine.

**Order of magnitude.** There is no honest figure, but the remaining work is on the order of **a team of 5-15 people for 1-3 years**, with Windows hardware and a 16 GB GPU, and legal access to the binary. Public projects have been running for days and have already fragmented into six forks; Leonida shut down in 72 hours. It is not a talent problem: most of the engine is still missing.

### 4.6. Paths to a working port (and their legal status)

> This section lists families of solutions and their viability, including the illegal ones, only to explain why they are not viable or why they do not exist. **It is not an execution guide**: it does not include steps, keys, offsets, links to leaked material or instructions to bypass protections.

| Path | What it would require | Status at 24-11-2026, 19:00 CET | Legal status |
|---|---|---|---|
| **1. Official port** | Rockstar developing and publishing the PC version | Not announced; rumour Q1 2027 | **Legal** |
| **2. Cloud / Remote Play** | A console with the game and streaming | Xbox Cloud is console-only; Remote Play to PC works | **Legal** |
| **3. Xbox Series X\|S emulator** | Boot chain, hypervisor, keys, GPU, firmware | No public emulator exists; Xenia is 360 and Xemu is original Xbox | **Illegal** if protections are bypassed; no public technical base |
| **4. HLE compatibility layer** | Reimplement `kernelx`, `d3d12_xs`, `xmem`; translate shaders | XCL/VIctory reach menus; no gameplay | The software is legal; running a leaked copy is **not** |
| **5. Static recompilation** | Translate x86-64→C++ and gfx1013→DXIL | Xbox2Windows/Leonida, prototypes | The tool is legal; the source binary is **not** |
| **6. Clean-room reimplementation** | Write an engine compatible with the assets | Does not exist; years of work | **Legal** if no code is copied; the assets remain protected |
| **7. "ISO + emulator"** | An ISO that the emulator can mount | **Does not apply**: Series X uses encrypted/signed MSIXVC, not ISO; no emulator mounts it | **Not viable**; circumvention is illegal |
| **8. Patching the .exe** | Convert imports/ABI and replace the renderer | What HLE/recomp attempts; no shortcut | **Illegal** without authorisation |

Paths 3, 4, 5 and 8 are only viable with an unauthorised copy of the game; path 7 is also technically impossible. This document does not develop any of them.

**Why the emulator does not exist.** A general Series X|S emulator would need, at minimum: the boot chain and firmware, documentation of the hypervisor and security system, the decryption keys, emulation of the RDNA2 GPU with its console extensions, and years of engineering and testing on real hardware. None of that is public. Xenia emulates Xbox 360 (PowerPC) and Xemu the original Xbox; neither runs Series X binaries. The projects that do boot GTA VI are HLE layers or recompilers, not full emulators.

**Why "ISO + emulator" does not work.** The idea comes from PS2, PSP and Xbox 360, where the game was distributed as an image the emulator could mount. Xbox One and Series X|S do not use that model: the game is an encrypted, signed MSIXVC package on a Windows-derived OS with a hypervisor. An ISO of a Series X game would not boot in Xenia or Xemu, because they are a different architecture and generation. And even if someone packaged the game as an ISO, the same encrypted package would still be inside: the ISO does not remove the protection. There is no public emulator that mounts that format.

**What would have to happen for an emulator to exist.** It would need boot-chain research, hypervisor documentation, firmware dumps, keys, GPU emulation and a legal framework that allowed it. None of those pieces is public today, and obtaining keys or firmware through unauthorised means is illegal. That is why there is no "Series X Xenia" and none is expected in the short term.

**The HLE and static recompilation path.** They do not need to emulate the whole console: they reimplement the APIs (`kernelx`, `d3d12_xs`, `xmem`) or translate the x86-64 code and shaders into something Windows understands. That is what XCL, VIctory, Xbox2Windows and Leonida do. The problem is not only technical: the only available binary is the leaked one, and running it is infringement. Even with a legal copy, the remaining work is the world, the GPU and memory (section 4.5).

**The clean-room path.** It would mean writing an engine compatible with RAGE 9 assets without copying Rockstar code. It is legal in theory, but it is a multi-year project, it cannot distribute the assets and it does not solve "playing GTA VI" in the short term. It is not a realistic alternative for one person.

**The only complete and legal path.** The **official port** is the only one that provides native performance, support, saves and online without relying on reverse engineering. **Cloud / Remote Play** is the only legal way to play it on a PC screen today, with the limitation that Xbox Cloud for GTA VI is restricted to Xbox consoles and Remote Play needs a console with the game.

**Conclusion.** There is no shortcut: "ISO + emulator" is a myth from other generations, the Series X|S emulator does not exist, and the HLE/recompilation path is real but requires the leaked binary and most of the engine. The only complete, legal solution is the official port; the only legal way to see it on PC today is Remote Play from a console.

---

## 5. The legal side (what videos usually leave out)

*(Legal framework and sources consulted on 24-11-2026 between 15:35 and 15:45 CET.)*

### 5.1. Downloading and using the leaked build is infringement

- The game is a protected work. **Downloading it, sharing it or running it without a licence** is unauthorised reproduction/public communication.
- In Spain, Article 270 of the Criminal Code punishes the reproduction, distribution or public communication of protected works without authorisation, with penalties of up to **4 years in prison** in aggravated cases (for profit, relevant harm).
- "Private copying" does **not** cover downloading a leak from the Internet, and does **not** cover bypassing protections.

### 5.2. Bypassing protection is an additional offence

- The console build is encrypted and signed. Running it requires **circumventing technological protection measures** (TPM/DRM).
- US: **DMCA §1201** (anti-circumvention), in addition to §106 (copyright).
- EU: Directive 2001/29/EC, Art. 6; in Spain, the Intellectual Property Law and the Criminal Code.
- Rockstar's EULA expressly prohibits **reverse engineering, decompilation and circumvention**.

### 5.3. "I do not include game files" does not exempt you from liability

This is the most important part, and the one the video illustrates with a real case:

- Take-Two's DMCA notice of **18-11-2026** is not against GTA VI: it is against **Muguet**, a **GTA V** port to iOS/macOS.
- Take-Two asked for the repo **and its 263 forks** to be taken down.
- Its exact argument: *"Claiming that this repository does not directly provide game files and requires users to own the game files does not excuse blatant facilitation of an unauthorized reproduction"*.
- In other words: **"bring your own files" is not a shield**. If the project exists to run an unauthorised copy, it can be taken down anyway.

### 5.4. Precedents

- **re3/reVC (2021):** Take-Two sued the authors of the GTA III/Vice City port, even though the code was "clean room" and contained no assets. The project was withdrawn.
- **Muguet (2026):** mass DMCA, 263 forks.
- **"GTA hacker" criminal case (2026):** recent conviction, reported by RTÉ on 23-11-2026.
- **GitHub:** in addition to removal, the account can be suspended. If you contribute to an infringing repo, your name stays in the history.

### 5.5. What is legal (or much less grey)

- **Reimplementing an API** (like Wine) is legal in itself.
- **Writing format-analysis tools** (RPF9, TTPF, BCPack) is legal in itself, as long as you do not distribute keys or game content.
- **Analysing your own binaries** (programs you compiled, open-source software, CTFs) is legal.
- **Dumping your own console game** is a grey area and, in practice, requires bypassing protections; in Spain it is not a clear defence. It is not recommended.
- **Playing on a console you own** and using Remote Play to a laptop is 100% legal.

---

## 6. Reverse engineering: the reference topic

*(Topic and repos consulted on 24-11-2026 between 15:30 and 15:45 CET; the total count was refreshed at 19:00 CET.)*

### 6.1. What is really in `github.com/topics/reverse-engineer-anything`

The topic has **19 repos**. Most are **skill packs for AI agents** ("REA" = *Reverse Engineer Anything*), case lists and prompts for Claude Code/Codex/Cursor. It is not the classic RE community, and it does not replace Ghidra.

| Repo | Stars | What it is |
|---|---:|---|
| `AIshihzong/awesome-reverse-engineer-anything` | 895 | Curated list of AI-assisted RE cases |
| `smartworldarafath/REA_Skill` | 43 | 21 skills + 500 prompts for agents |
| `git-sanbu/awesome-rea` | 32 | Case studies with sources |
| `jammyfu/reverse-engineering-atlas` | 19 | Map of existing decompilations and reimplementations |
| `tonchovet/REA-Windows-Github` | 12 | REA ↔ Hopper/Ghidra bridge |
| `DrBellubins/DecompileAnything` | 6 | x86 decompilation to "byte-matching" source (experimental) |
| `hieunguyenak92/rea-pro-max` | 3 | RE MCP/skill/CLI |

**Assessment:** these repositories are useful for **triage and automation**, never as a substitute for understanding the binary. An agent that "explains" a decompilation without the reader knowing x86-64 is a hallucination with a progress bar.

### 6.2. The RE stack that actually matters (all free or with a free tier)

| Tool | Link | Use |
|---|---|---|
| **Ghidra** | https://github.com/NationalSecurityAgency/ghidra | Decompiler and framework; the free standard |
| **radare2** | https://github.com/radareorg/radare2 | Analysis CLI |
| **Rizin** | https://github.com/rizinorg/rizin | Modern radare2 fork |
| **Cutter** | https://github.com/rizinorg/cutter | GUI on top of Rizin |
| **x64dbg** | https://github.com/x64dbg/x64dbg | Windows user-mode debugger |
| **Frida** | https://github.com/frida/frida | Dynamic instrumentation and hooking |
| **Unicorn** | https://github.com/unicorn-engine/unicorn | Instruction-level CPU emulation |
| **Qiling** | https://github.com/qilingframework/qiling | Binary + OS emulation |
| **angr** | https://github.com/angr/angr | Symbolic analysis |
| **RetDec** | https://github.com/avast/retdec | Retargetable decompiler |
| **ImHex** | https://github.com/WerWolv/ImHex | Hex editor with patterns |
| **PE-bear** | https://github.com/hasherezade/pe-bear | PE inspection |
| **Detect It Easy** | https://github.com/horsicq/Detect-It-Easy | Binary/packer identification |
| **capa** | https://github.com/mandiant/capa | Capability identification |
| **FLARE VM** | https://github.com/mandiant/flare-vm | Windows analysis VM |
| **LIEF** | https://github.com/lief-project/LIEF | Executable parsing/modification |
| **Binary Ninja API** | https://github.com/Vector35/binaryninja-api | Commercial alternative with a public API |
| **crackmes.one** | https://crackmes.one | Legal challenges to practise |

### 6.3. Legal targets to practise on (and actually learn)

| Project | Link | What you learn |
|---|---|---|
| **OpenRW** | https://github.com/rwengine/openrw | Open-world engine reimplementation (GTA III), no assets |
| **N64Recomp** | https://github.com/N64Recomp/N64Recomp | Static recompilation |
| **Zelda64Recomp** | https://github.com/Zelda64Recomp/Zelda64Recomp | Recompilation + port |
| **UnleashedRecomp** | https://github.com/hedge-dev/UnleashedRecomp | Static recompilation port |
| **Xenia** | https://github.com/xenia-project/xenia | Xbox 360 emulation |
| **Xemu** | https://github.com/xemu-project/xemu | Original Xbox emulation |
| **RPCS3** | https://github.com/RPCS3/rpcs3 | PS3 emulation |
| **shadPS4** | https://github.com/shadps4-emu/shadPS4 | PS4 emulation |
| **Kyty** | https://github.com/InoriRus/Kyty | PS4/PS5, HLE |
| **XCL / XValkyrie** | https://github.com/xcl-dev/xcl · https://github.com/sammwyy/xvalkyrie | Console compatibility layers |

**Golden rule:** practise with binaries you can analyse legally. A CTF, an open-source game or your own code. Do not start with the most protected binary of the year.

### 6.4. 12-week curriculum (6-8 h/week, €0)

| Weeks | Goal | Deliverable |
|---|---|---|
| 1-2 | x86-64, PE/COFF, calling conventions, memory, C/C++ | A `hello world` compiled and dissected by hand |
| 3-4 | Ghidra: decompiler, scripts, headless | Script that lists functions and strings in a binary |
| 5-6 | File formats: parse ZIP/PNG, then a custom format | Python/Rust parser with tests |
| 7-8 | Unicorn/Qiling: emulate a function, hook APIs | Test that runs a function without the full binary |
| 9-10 | Shaders: DXIL/SPIR-V, LLVM AMDGPU, RenderDoc | Translate a small shader and validate it |
| 11-12 | Contribute to an open-source project | PR with tests + green CI |

**Where to contribute without hardware:** documentation issues, unit tests, format parsers, CLI tools, CI. Projects like XCL have hundreds of issues; many do not require a GPU.

---

## 7. Options with €0 and no PC

*(Prices and availability consulted on 24-11-2026 between 15:35 and 15:45 CET; they may change.)*

The problem hides **three different projects**, with very different answers.

### Route A — **Play** GTA VI without a PC

| Option | Approximate cost | Requirements | Quality | Verdict |
|---|---|---|---|---|
| Wait for the PC port | €0 now; ~€80 for the game; €800-1,500 PC later | PC | The best | The most sensible if you are not in a hurry |
| **Used Xbox One + game + cloud** | €80-150 console + €80 game + hours/Game Pass (€15-20/month) | 20+ Mbps, Xbox account, controller | 1080p, Series S settings, queues | **The cheapest way to play now** |
| **Used Series S + game** | €180-250 + €80 = **€260-330** | TV/monitor, HDMI | 1080p/30 approx. | **Best value for money** |
| Used Series X + game | €320-400 + €80 = **€400-480** | 4K TV | 4K/30 approx. | For the best console quality |
| PS5 + game | €400-500 + €80 | TV | Similar | Same idea, another platform |
| Friend/family console + **Remote Play** | €0 if lent | Their console on + a laptop or phone | Their console's quality | Legal and free, but depends on someone else |
| Rental / gaming café | €10-25/session | — | High | To try it for a weekend |
| GeForce NOW / Shadow PC | €20-40/month | — | — | **Does not work: there is no PC version** |
| "GTA 6 PC" from GitHub/Discord/Telegram | €0 | — | — | **Scam/malware + crime** |

**Key facts:**

- Xbox Cloud Gaming for GTA VI is enabled **only on Xbox consoles** (Xbox One and Series X|S), at Series S settings. It is **not** available on PC, mobile, TV or browser, at least at launch. Xbox confirmed it on 10-11-2026 and Matthew Ball and Xbox Wire repeated it.
- **Remote Play** does work from a console that has the game to PC, Mac, mobile or Steam Deck. It is the only legal way to see GTA VI on a computer screen today.
- The game costs **€79.99** (Standard) and **€99.99** (Ultimate) in Spain. The physical edition is a code, not a disc.
- A used **Series S** is **€180-250**; a **Series X**, **€320-400**; an **Xbox One**, considerably less.

**Lowest-cost recommendation:** if the goal is to play now, **used Xbox One + GTA VI + an hourly cloud subscription**. If the budget allows, **used Series S**: it does not depend on the cloud and supports Remote Play to a laptop.

### Route B — **Learn reverse engineering** for real (€0)

1. Complete the 12-week curriculum in section 6.4.
2. Choose a legal project: OpenRW, N64Recomp, Xenia, shadPS4.
3. Start with documentation and test issues, not the core.
4. Set up **GitHub Codespaces** (60 h/month free on the free plan, 2 cores/8 GB) to work from anywhere.
5. Use **Oracle Cloud Always Free** (4 ARM Ampere cores, 24 GB RAM) for Ghidra headless: Ghidra is Java and runs on ARM64. It is the best free VM for static analysis.
6. Publish write-ups. That is worth more than 10,000 stars on a 24-hour repo.

**What cannot be verified without a PC:** that the game renders, that it runs at 30 fps or that it does not hang the driver. That requires Windows + GPU + the game. There is no legal shortcut.

### Route C — "Try the port anyway" (not recommended)

If you insist, this is what it would really cost:

| Resource | Realistic minimum | Cost |
|---|---|---|
| Team | 3-10 people with x86-64, GPU, D3D12/Vulkan and shader experience | €0 if volunteers; years of time |
| Hardware | Windows 11, 8-16 cores, 32-64 GB RAM, 16 GB VRAM GPU, 2 TB NVMe | €1,500-2,500 |
| Cloud GPU (if no PC) | RTX 3090/4090 by the hour | €0.30-0.80/h; 4 h/day × 12 months ≈ €600-1,500 |
| Legal | Lawyer, DMCA, possible lawsuit | Thousands of euros |
| Time | 1-3 years for something "playable", with luck | — |

And all of that **without** a legal binary, which does not exist: the only available copy is the leaked one.

**Conclusion:** it is not a €0 project and it is not a one-person project. It is a team project, with hardware, a lawyer and years. What you can do is **contribute to the legal side of the ecosystem** (format tools, tests, documentation) and learn.

---

## 8. Common myths

| Myth | Reality |
|---|---|
| "The CPU is the same, so it is easy" | The ISA is 5%. OS, hypervisor, GDK, GPU, memory and DRM are missing |
| "It is x86, it should run like Wine" | Wine reimplements Win32. Xbox uses `kernelx`, `d3d12_xs` and encrypted packages |
| "A Series X emulator already exists" | No. There are HLE layers and prototypes; XEVOD/APKOD are download pages, not emulators |
| "If the repo does not include game files, it is legal" | Take-Two has already taken down 263 forks with that argument |
| "Gameplay videos prove it" | 41 clips reviewed; many are recycled GTA V or menus. Menus ≠ game |
| "3,000 repos = huge community" | 20,000 matches, but <10 real technical projects |
| "You can do it with €0 and a laptop" | You can learn and compile; you cannot run or verify the game |
| "Xbox cloud works on PC" | For GTA VI, no: Xbox consoles only at launch |

---

## 9. Appendix: full link list

All links in this appendix were checked on **24-11-2026 between 15:20 and 15:45 CET**; GitHub data was refreshed at **19:00 CET**. URLs may change or disappear.

### 9.1. Video and original sources

- Video: https://www.youtube.com/watch?v=P0o-Fh-VSxo
- Channel: https://www.youtube.com/@thecodebear
- XDA (exe): https://www.xda-developers.com/gta-6-xbox-executable-leaked-opening-door-for-pc-recompilation-projects-begin-testing/
- GamesRadar: https://www.gamesradar.com/games/grand-theft-auto/gta-6-pc-version-is-close-modders-say-after-cyberleek-releases-executable-the-game-almost-boots/
- TweakTown: https://www.tweaktown.com/news/114839/gta-6-boots-on-pc-only-3-hours-after-xbox-executable-leaked/index.html
- VGTimes: https://vgtimes.com/gaming-news/175531-unverified-gta-6-pc-videos-show-menus-not-gameplay.html
- Notebookcheck (exe): https://www.notebookcheck.net/Cyberleek-releases-GTA-6-Xbox-build-exe-boosting-playable-PC-port-chances.1457977.0.html
- LevelUp: https://www.levelup.com/en/news/cyberleek-leaks-gta-6s-executable-file-and-modders-are-already-working-on-a-playable-pc-version/
- TwistedVoxel: https://twistedvoxel.com/gta-6-pc-recompilation-leonida-developer-quits/
- MakeUseOf: https://www.makeuseof.com/gta-6-unofficial-pc-port-on-its-way/
- XDA (hoax): https://www.xda-developers.com/that-viral-gta-6-pc-port-video-hoax-made-from-recycled-gta-5-footage/
- Notebookcheck (DLSS 5): https://www.notebookcheck.net/GTA-6-PS5-Pro-performance-jumps-to-280-fps-on-PC-with-DLSS-5-transforming-Lucia.1453555.0.html
- Tracker: https://vuyp.github.io/gta6-pc-race/
- PortWatch VI: https://portwatch-vi.xyz/
- PortWatch VI repository: https://github.com/4lwayz/portwatch-vi
- PortWatch VI data: https://portwatch-vi.xyz/data/tracker.json
- Notebookcheck (PortWatch): https://www.notebookcheck.net/GTA-6-This-website-lets-you-track-the-PC-recompilation-live.1458797.0.html

### 9.2. Ecosystem repos

- https://github.com/marvisak/VIctory
- https://github.com/xcl-dev/xcl
- https://github.com/R0Y00/Xbox2Windows
- https://github.com/OnlyMoisties/GTA6-BootTest
- https://github.com/ubiquitarianism/leonida
- https://github.com/ProjectLeonidaL/leonida
- https://github.com/LeonidaReforge/Leonida
- https://github.com/avivetech/Leonida
- https://github.com/luizwidmer/palmetto
- https://github.com/IAmNotSiob/leonida-ce
- https://github.com/Cappi1998/LONDBackup
- https://github.com/LooperSalty/AnyXboxX
- https://github.com/californiaAlmonds/OpenScarlett
- https://github.com/sammwyy/xvalkyrie
- https://github.com/TrinitronClient/zenith-x
- https://github.com/fablinoo/palmwave
- https://github.com/ubiquitarianism/leonida
- https://github.com/Ahmet-Dedeler/awesome-gta6-reverse-engineering
- https://github.com/4lwayz/portwatch-vi
- https://github.com/TrinitronClient/GTA6-Asset-Info
- https://github.com/breadbbbb/rpf9-explorer
- https://github.com/rpatty-dev/PercyStar
- https://github.com/holdmysocks/SixNG
- https://github.com/Ahmet-Dedeler/bcpack-rs

### 9.3. Searches to reproduce the sweep

- https://github.com/search?q=gta+6&type=repositories&s=stars&o=desc
- https://github.com/search?q=gta6&type=repositories&s=stars&o=desc
- https://github.com/search?q=leonida&type=repositories&s=stars&o=desc
- https://github.com/topics/gta6
- https://github.com/topics/leonida
- https://github.com/topics/xbox-series-x
- https://github.com/topics/reverse-engineer-anything

### 9.4. Legal and security

- https://github.com/github/dmca/blob/master/2026/11/2026-11-18-take-two.md
- https://github.com/github/dmca/blob/master/2021/02/2021-02-19-take-two.md
- https://torrentfreak.com/take-two-sues-enthusiasts-behind-gta-fan-projects-re3-revc-210903/
- https://www.dexerto.com/gta/gta-6-boss-sends-warning-to-pirates-who-make-ai-generated-pc-version-before-official-release-3426850
- https://www.rte.ie/news/2026/1123/1600335-gta-hacker/
- https://cybersecuritynews.com/fake-gta-6-pc-launchers/
- https://www.netcraft.com/blog/how-attackers-are-capitalizing-on-the-hype-around-the-grand-theft-auto-vi-release
- https://maketecheasier.com/gta-6-pc-port-scam-kit/
- https://basic-tutorials.com/news/gta-6-pc-cyberleek-releases-xbox-exe-leonida-port-remains-unreleased/

### 9.5. Playing cheaply / officially

- https://news.xbox.com/en-us/2026/11/10/grand-theft-auto-6-comes-to-xbox-cloud-gaming-november-19
- https://news.xbox.com/en-us/2026/11/23/grand-theft-auto-vi-xbox-cloud-and-remote-play
- https://www.xbox.com/es-es/games/grand-theft-auto-vi
- https://www.playstation.com/en-us/support/subscriptions/psportal-cloud-game-streaming
- https://www.xbox.com/play

### 9.6. RE tools and learning

- https://github.com/NationalSecurityAgency/ghidra
- https://github.com/radareorg/radare2
- https://github.com/rizinorg/rizin
- https://github.com/rizinorg/cutter
- https://github.com/x64dbg/x64dbg
- https://github.com/frida/frida
- https://github.com/unicorn-engine/unicorn
- https://github.com/qilingframework/qiling
- https://github.com/angr/angr
- https://github.com/avast/retdec
- https://github.com/WerWolv/ImHex
- https://github.com/hasherezade/pe-bear
- https://github.com/horsicq/Detect-It-Easy
- https://github.com/mandiant/capa
- https://github.com/mandiant/flare-vm
- https://github.com/lief-project/LIEF
- https://github.com/Vector35/binaryninja-api
- https://crackmes.one

### 9.7. Legal projects to study/reuse

- https://github.com/rwengine/openrw
- https://github.com/N64Recomp/N64Recomp
- https://github.com/Zelda64Recomp/Zelda64Recomp
- https://github.com/hedge-dev/UnleashedRecomp
- https://github.com/xenia-project/xenia
- https://github.com/xemu-project/xemu
- https://github.com/RPCS3/rpcs3
- https://github.com/shadps4-emu/shadPS4
- https://github.com/InoriRus/Kyty

### 9.8. Topic `reverse-engineer-anything`

- https://github.com/topics/reverse-engineer-anything
- https://github.com/AIshihzong/awesome-reverse-engineer-anything
- https://github.com/smartworldarafath/REA_Skill
- https://github.com/git-sanbu/awesome-rea
- https://github.com/jammyfu/reverse-engineering-atlas
- https://github.com/tonchovet/REA-Windows-Github
- https://github.com/DrBellubins/DecompileAnything
- https://github.com/hieunguyenak92/rea-pro-max

---

## 10. Recommendations, in order

1. **Do not download anything** from "GTA 6 PC". Not the .exe, not the "preload", not the "emulator". The malware and legal risk are not worth it.
2. **Decide the real goal:** play, learn or research. If it is play, Route A. If it is learn, Route B.
3. **If the goal is to play:** look for a used Xbox One or Series S and the game. Try Remote Play on a laptop. Hard budget: €260-330 with a Series S.
4. **If the goal is to learn:** start the 12-week curriculum, with OpenRW or a CTF. Create a GitHub account and Codespaces.
5. **If the goal is to research:** follow the tracker and read the XCL/VIctory READMEs, but **do not run** the leaked binary. Save the links and wait for the official port.
6. **If the PC port arrives in 2027:** buy it. The wait will have been worth it.

---

## 11. Final note

The technical intuition at the start —"the CPU is the same"— is not nonsense: it is why these projects exist and why XCL can run native x64 code. But confusing "same ISA" with "same system" is like saying a diesel engine and a petrol engine are the same because both have pistons.

What happened in November 2026 is fascinating: in four days, a community took a console binary to menus on Windows. It is also a good example of why hype is dangerous: 10,000 stars, 26,000 translated shaders, six forks... and not one playable frame. The distance between "it boots" and "a game" is the distance between a prototype and a product.

With €0 and no PC you can learn a lot. What you cannot do is skip physics, law and 20 years of console engineering.

---

## 12. Contact and community

Public channels of the projects and the people who maintain them. **The recommended route for technical questions is GitHub Issues**, not direct messages: that way the answer is documented and helps others.

| Project | Maintainer | Main channel | Other |
|---|---|---|---|
| **XCL** | [@xcl-dev](https://github.com/xcl-dev) | [Discord](https://discord.gg/xcl) | [Repo](https://github.com/xcl-dev/xcl) |
| **VIctory** | [@Marvisak](https://github.com/Marvisak) | [Issues](https://github.com/Marvisak/VIctory/issues) | [Repo](https://github.com/Marvisak/VIctory) |
| **Leonida (continuation)** | [@ubiquitarianism](https://github.com/ubiquitarianism) | [Discord](https://discord.gg/ETf4qj5acN) | [Repo](https://github.com/ubiquitarianism/leonida) |
| **Xbox2Windows** | [@R0Y00](https://github.com/R0Y00) | [Discord](https://discord.gg/DMcmNtpd6R) | [Repo](https://github.com/R0Y00/Xbox2Windows) |
| **AnyXboxX** | [@LooperSalty](https://github.com/LooperSalty) | [Discord](https://discord.gg/TcX42vRyPU) | [Repo](https://github.com/LooperSalty/AnyXboxX) |
| **OpenScarlett** | [@californiaAlmonds](https://github.com/californiaAlmonds) | [Discord](https://discord.gg/sShMY2fjR) | [Repo](https://github.com/californiaAlmonds/OpenScarlett) |
| **XValkyrie** | [@sammwyy](https://github.com/sammwyy) | [X/Twitter](https://x.com/sammwyy) | [Web](https://sammwy.com/) |
| **GTA6-BootTest** | [@OnlyMoisties](https://github.com/OnlyMoisties) | [Issues](https://github.com/OnlyMoisties/GTA6-BootTest/issues) | [Repo](https://github.com/OnlyMoisties/GTA6-BootTest) |
| **awesome-gta6-RE** | [@Ahmet-Dedeler](https://github.com/Ahmet-Dedeler) | [Discord](https://discord.gg/CjcDBg3nf) | [X/Twitter](https://x.com/ahmetbuilds) |
| **PortWatch VI** | [@4lwayz](https://github.com/4lwayz) | [X/Twitter](https://x.com/lithuaniangroyp) | [Repo](https://github.com/4lwayz/portwatch-vi) · [Site](https://portwatch-vi.xyz/) |
| **GTA6-Asset-Info** | [@TrinitronClient](https://github.com/TrinitronClient) | [Issues](https://github.com/TrinitronClient/GTA6-Asset-Info/issues) | [Repo](https://github.com/TrinitronClient/GTA6-Asset-Info) |
| **rpf9-explorer** | [@breadbbbb](https://github.com/breadbbbb) | [Issues](https://github.com/breadbbbb/rpf9-explorer/issues) | [Repo](https://github.com/breadbbbb/rpf9-explorer) |
| **PercyStar** | [@rpatty-dev](https://github.com/rpatty-dev) | [Issues](https://github.com/rpatty-dev/PercyStar/issues) | [Web](https://nitech.dev) |
| **SixNG** | [@holdmysocks](https://github.com/holdmysocks) | [Issues](https://github.com/holdmysocks/SixNG/issues) | [Web](https://holdmysocks.dev) |
| **Project Leonida Legacy** | [@ProjectLeonidaL](https://github.com/ProjectLeonidaL) | [Discord](https://discord.gg/dxMD2XqyEJ) | [Repo](https://github.com/ProjectLeonidaL/leonida) |
| **Reference video** | [Code Bear](https://www.youtube.com/@thecodebear) | [YouTube](https://www.youtube.com/@thecodebear) | [Instagram](https://instagram.com/thecodebear) |
| **This repository** | [@JoseArranzSanchez](https://github.com/JoseArranzSanchez) | [Issues](https://github.com/JoseArranzSanchez/GTA6_PCPORT_INFO/issues) | — |

**Telegram links are not included** because ownership could not be verified; several projects publish them in their READMEs, but they are not recommended for support. Personal emails and phone numbers are not included either.

### How to write a good issue

1. Exact project version or commit.
2. Windows, GPU, driver and amount of RAM/VRAM.
3. Steps to reproduce, what was expected and what happened.
4. Logs and a screenshot; for a hang, Event Viewer or the minidump.
5. One concrete question, without mixing several topics.

### What not to do

- Do not ask for builds, keys, ISOs, links to leaked material or "the .exe".
- Do not attach game files or dumps to issues or Discord.
- Do not send the same message to every maintainer at once.
- Do not use unverified channels (Telegram, DMs, servers without rules) for support.

### Errors in this document

If you find a technical error, a broken link, an incorrect attribution or an outdated fact, open an [issue](https://github.com/JoseArranzSanchez/GTA6_PCPORT_INFO/issues) with:

- the section and the exact sentence;
- the source or the correct fact;
- if it is a link, the URL and what is wrong.

Do not use issues to ask for builds, keys or leaked material: those messages will be closed.

### Link responsibility

The links in this document were reviewed on **24-11-2026** and point to public project, press and documentation pages. **No downloads, executables, keys or leaked material are linked.** No guarantee can be given that third-party content will remain available, safe or unchanged: curation is limited to the cut-off date. If a link is broken or looks malicious, open an issue and it will be removed.

The links are also in [`LINKS.csv`](LINKS.csv) (with an `open` column for Excel/LibreOffice), [`LINKS.md`](LINKS.md) (clickable table on GitHub) and [`LINKS.html`](LINKS.html) (browser).

---

## 13. Credits and attributions

This document would not be possible without the work of the following people and projects. Errors are the responsibility of the repository maintainer; credit belongs to those who did the original work.

### Reference video

- **Code Bear** (`@thecodebear`), *Is GTA 6 Really PORTED to PC? (fact checked)*, YouTube, published on **23-11-2026**, consulted on **24-11-2026 at 19:00 CET**. Writing, narration and editing: Code Bear.
- Link: https://www.youtube.com/watch?v=P0o-Fh-VSxo

### Press and sources cited

- **XDA Developers** (several articles on the .exe, the hoax and NotRexed/Hookshot).
- **GamesRadar+**, **TweakTown**, **VGTimes**, **Notebookcheck**, **LevelUp**, **TwistedVoxel**, **MakeUseOf**, **Basic Tutorials**.
- **Dexerto**, **RTÉ**, **TorrentFreak**, **Cyber Security News**, **Netcraft**, **MakeTechEasier**.
- **Xbox Wire** (Microsoft) and **PlayStation Blog / PlayStation Support** for official cloud and Remote Play information.

### Projects and maintainers

- **XCL** (`xcl-dev/xcl`), **VIctory** (`marvisak/VIctory`), **Xbox2Windows** (`R0Y00/Xbox2Windows`), **GTA6-BootTest** (`OnlyMoisties/GTA6-BootTest`).
- **Leonida** and its continuations: `ubiquitarianism/leonida`, `ProjectLeonidaL/leonida`, `LeonidaReforge/Leonida`, `avivetech/Leonida`, `luizwidmer/palmetto`, `IAmNotSiob/leonida-ce`, `Cappi1998/LONDBackup`.
- **AnyXboxX** (`LooperSalty/AnyXboxX`), **OpenScarlett** (`californiaAlmonds/OpenScarlett`), **XValkyrie** (`sammwyy/xvalkyrie`), **zenith-x** (`TrinitronClient/zenith-x`), **palmwave** (`fablinoo/palmwave`).
- **awesome-gta6-reverse-engineering** (`Ahmet-Dedeler`), **GTA6-Asset-Info** (`TrinitronClient`), **rpf9-explorer** (`breadbbbb`), **PercyStar** (`rpatty-dev`), **SixNG** (`holdmysocks`), **bcpack-rs** (`Ahmet-Dedeler`).
- **PortWatch VI** (`4lwayz/portwatch-vi`), an external progress tracker; its leaderboard and data are cited with its own caveats.
- **Cyberleek/Cyberleak**: the group that published the leaked material. It is mentioned for journalistic context; no technical credit is attributed to it and its content is not linked.

### Tools and data

- **GitHub API** and **GitHub Docs**, for repository data and searches.
- **Ghidra** (NSA), **radare2**, **Rizin**, **Cutter**, **x64dbg**, **Frida**, **Unicorn**, **Qiling**, **angr**, **RetDec**, **ImHex**, **PE-bear**, **Detect It Easy**, **capa**, **FLARE VM**, **LIEF** and **Binary Ninja**, for the foundation of the reverse-engineering stack.
- **OpenCode** (AI agent) and **DeepSeek V4.1 Flash 1017**, for producing and reviewing the document. Editorial responsibility and errors remain with the maintainer.
- **Creative Commons**, for the CC BY 4.0 licence text.
- **Take-Two Interactive** and **Rockstar Games**, for public launch information and for the DMCA notices that make the legal framework explainable.

### How to cite this document

> Arranz Sánchez, J. (2026). *GTA VI on PC / Xbox Series X: Open Feasibility Report* (cut-off 24-11-2026, 19:00 CET). GitHub: https://github.com/JoseArranzSanchez/GTA6_PCPORT_INFO

### License and trademarks

Original content is published under **CC BY 4.0** (see [LICENSE](LICENSE)). Trademarks, quotes, screenshots and third-party material belong to their owners. *Grand Theft Auto*, *GTA*, *GTA VI* and *Rockstar Games* are trademarks of Take-Two Interactive. This repository is not affiliated with Rockstar, Take-Two, Microsoft or Xbox.

---

*Document updated on 24-11-2026 at 19:00 CET. Repository, star and status data change daily; verify before making decisions.*
