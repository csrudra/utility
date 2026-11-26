# xseries-wine

**An experimental research harness for running Xbox Series X|S (codename "Scarlett") GDK executables on PC and Linux through Wine/Proton.**

> ⚠️ **Nothing is playable.** This project is at the very first step: finding out how far a
> console executable boots before it hits something PC doesn't have. If you're looking for a way
> to play a console game on PC today, this isn't it yet.

---

## Contents

- [How it works](#how-it-works)
- [What it does and doesn't do](#what-it-does-and-doesnt-do)
- [Goals](#goals)
- [Compatibility](#compatibility)
- [Getting started](#getting-started)
- [How you can help](#how-you-can-help)
- [Rules](#rules)
- [FAQ](#faq)
- [Related projects](#related-projects)

---

## How it works

Xbox Series games are normal-looking 64-bit Windows `.exe` files, but they depend on DLLs that only
exist on console firmware:

| Console DLL | What it does on Xbox |
|---|---|
| `d3d12_xs.dll`, `xg_xs.dll` | Console Direct3D 12 (talks to the GPU directly) |
| `XboxBvhBuilder.dll` | Ray-tracing acceleration structures |
| `xmem.dll` | Console memory manager |
| `xapu.dll`, `AcpHal.dll`, `chad.dll` | Audio processor and DSP hardware |
| `XCRDAPI.dll` | DirectStorage (fast asset streaming) |
| `GameInput.dll` | Controllers |
| `libHttpClient.GDK.dll` | Networking |
| `xgameruntime.dll` | The GDK runtime: users, saves, store, system info (loaded at runtime, not imported) |

Wine and Proton have none of these, so the game won't even start. xseries-wine:

1. Reads your exe's import table (`gen.py`).
2. Generates a stand-in DLL for every console-only import it finds.
3. Logs every call to `xbstub.log` next to the exe.

The log shows exactly how far the game gets and which console features it needs next.

---

## What it does and doesn't do

### ✅ It does

- Generate stub DLLs for **any** Xbox Series GDK executable, not just one game
- Provide a working **memory allocator** (`xmem.dll` → `VirtualAlloc`)
- Let the GDK runtime initialise and **log every runtime interface** the game asks for (by GUID)
- Mark the point where the game reaches **GPU initialisation**
- Work under Wine, Proton (Steam), and Windows

### ❌ It doesn't (yet)

- Render anything: graphics are the main unsolved problem (see [Goals](#goals))
- Play audio, read controllers, or load save games
- Run any game to a playable state

### 🚫 It never will

- Include or distribute game files, assets, executables, or Microsoft GDK binaries
- Decrypt console packages or provide keys
- Bypass licensing, DRM, or store entitlement checks
- Connect to Xbox Live or any online service

---

## Goals

Roughly in order of difficulty:

| # | Milestone | Status |
|---|---|---|
| 1 | Exe loads under Wine/Proton with stub DLLs | 🟡 Built, untested |
| 2 | Game reaches GPU init (`D3D12XboxCreateDevice`) | ⬜ Not started |
| 3 | Real `xgameruntime` interfaces: XSystem, XPackage, offline XUser, XGameSave | ⬜ Not started |
| 4 | Controllers: GameInput → SDL | ⬜ Not started |
| 5 | File streaming: DirectStorage (`XCRDAPI`) → plain file I/O | ⬜ Not started |
| 6 | Audio: XApu / ACP / XDsp → FAudio | ⬜ Not started |
| 7 | Graphics: console D3D12 → vkd3d-proton / Vulkan | ⬜ Not started |
| 8 | Shaders: native RDNA2 GPU binaries → SPIR-V recompiler | ⬜ Not started |

**Milestones 7 and 8 are the big ones.** Console games ship shaders already compiled to AMD RDNA2
machine code, not portable DirectX bytecode, so they need a shader recompiler like the one
[shadPS4](https://github.com/shadps4-emu/shadPS4) built for the PS4's GCN GPU. That took years. Be realistic.

---

## Compatibility

| Title | Platform build | Status | Notes |
|---|---|---|---|
| *No titles reported yet* | | | |

Status key: ⬜ untested · 🔴 crashes before stubs · 🟠 boots to runtime init · 🟡 reaches GPU init · 🟢 renders · ✅ playable

Tested another Scarlett title? Open an issue with your log (see [Reporting a test result](#reporting-a-test-result)).

---

## Getting started

### Requirements

- Your own legally obtained Xbox Series executable and game data
- Python 3 + `pefile`
- A MinGW-w64 cross-compiler (`x86_64-w64-mingw32-gcc`)
- Steam with Proton, or Wine 9+

### Build

```sh
git clone https://github.com/ReverendOzmund/xseries-wine.git
cd xseries-wine
pip install pefile
python3 gen.py /path/to/game.exe gen
./gen/build.sh
```

The DLLs end up in `gen/dll/`.

**Bazzite / SteamOS / other immutable distros**: build inside a distrobox:

```sh
distrobox create -n xbdev -i fedora:41
distrobox enter xbdev
sudo dnf install -y mingw64-gcc python3-pip
pip install --user pefile
```

### Run (Steam + Proton)

1. Copy everything in `gen/dll/` into the folder with the game exe.
2. In Steam: **Games → Add a Non-Steam Game** → pick the exe.
3. Right-click it → **Properties → Compatibility** → force **Proton Experimental**.
4. Set **Launch Options** to:
   ```
   PROTON_LOG=1 WINEDEBUG=+loaddll,+seh,err+module %command%
   ```
5. Launch it. A crash or instant close is expected at this stage.
6. Check `xbstub.log` (game folder) and `~/steam-<appid>.log`.

### Run (plain Wine)

```sh
cd /path/to/game
WINEDEBUG=+loaddll,+seh wine game.exe 2> wine.log
```

### Going further with TuxBox

The stubs here only show how far an executable boots. [TuxBox](https://github.com/brcly/TuxBox)
implements the console services and translates shaders. For setting it up on Bazzite, a log
summariser and a WineDbg hang-snapshot script, see [docs/bazzite-tuxbox.md](docs/bazzite-tuxbox.md)
and [`tools/`](tools).

### Reading the log

| You see | Meaning |
|---|---|
| No `xbstub.log` at all | The exe died before any stub loaded; check the Wine/Proton log for a missing DLL |
| `xgameruntime.dll (xbstub) loaded` | The GDK runtime started |
| `QueryApiImpl(provider=..., iid=...)` | The game asked for a runtime service; these GUIDs are the to-do list |
| `STUB <name>` | The game called something we haven't implemented |
| `*** MILESTONE: D3D12XboxCreateDevice reached ***` | 🎉 Got all the way to graphics init |

---

## How you can help

You don't need to be a reverse engineer to be useful.

### Testers
- Run the shim against any Xbox Series title you own and **report how far it gets**.
- Test on different setups: Proton versions, Wine versions, distros, Windows.

### Developers
Good first areas, easiest first:
- **Runtime services** (milestone 3): implement interfaces behind the GUIDs in the logs. Offline-only fakes are fine.
- **Input** (milestone 4): map GameInput onto SDL3.
- **Storage** (milestone 5): DirectStorage requests → ordinary reads.
- **Audio** (milestone 6): route XApu/XDsp to FAudio.
- **Generator**: better detection of console DLLs, typed stubs instead of `E_NOTIMPL`.

### Researchers
- Document console-only D3D12 extensions, `xg` texture swizzle modes, and RDNA2 shader binary formats **from public sources and your own analysis only**.

### Everyone
- Improve these docs, star the repo, and share it with people who'd actually contribute.

### Reporting a test result

Open an issue titled `[test] <game> - <furthest status>` and include:
- Distro / OS, GPU, and Proton or Wine version
- The **last 50 lines** of `xbstub.log`
- Any `err:` lines from the Wine/Proton log

Don't attach game files, full memory dumps, or anything containing game code.

---

## Rules

1. **No game files or links**: no executables, assets, dumps, or download links, in issues, PRs, or discussions. They will be deleted and the user blocked.
2. **No DRM or licence bypass**: PRs that fake store entitlements or skip licence checks will be rejected.
3. **No Microsoft GDK code**: don't paste headers or code from the NDA GDK. Clean-room and public documentation only.
4. **Be patient**: this is a hobby project. "When will X be playable?" issues will be closed.

---

## FAQ

**Can I play Xbox Series games on PC with this?**
No. It doesn't render anything yet, and there is no estimate for when, or whether, it will.

**Where do I get the game files?**
Not from here. You need your own legally obtained copy. Don't ask in issues.

**Why not just wait for the PC version?**
You probably should, if all you want is to play. This project is about console preservation and
the technical challenge of Scarlett compatibility.

**Is this an emulator?**
No, it's a compatibility layer, like Proton. Xbox Series and PC both use x86-64 CPUs, so the code runs
natively. Only the console-specific APIs need translating.

**Does this work for Xbox One games?**
Those use a different SDK (XDK/Durango). Look at WinDurango or XWine1 instead.

---

## Related projects

- **WinDurango**: open-source Xbox One compatibility layer
- **XWine1**: Xbox One compatibility layer (private)
- **[shadPS4](https://github.com/shadps4-emu/shadPS4)**: PS4 emulator; reference for GPU shader recompilation
- **[vkd3d-proton](https://github.com/HansKristian-Work/vkd3d-proton)**: D3D12 → Vulkan, the likely graphics backend
- **[TuxBox](https://github.com/brcly/TuxBox)**: a much further-along Linux-first Scarlett compatibility layer with a working RDNA2 shader translator; if you want to contribute to the furthest open effort, start there

---

## Keywords

Xbox Series X emulator · Xbox Series S emulator · Xbox Scarlett emulation · Xbox GDK compatibility layer ·
run Xbox games on PC · run Xbox games on Linux · Xbox on Steam Deck · Xbox Proton · Xbox Wine ·
D3D12.X · d3d12_xs · xgameruntime · GameCore · console preservation

---

## AI disclosure

The initial harness and documentation were written with AI assistance (Claude). All changes are reviewed and tested by the maintainer.

## License

[MIT](LICENSE). Covers this project's code only. All game and platform trademarks belong to their owners;
this project is not affiliated with Microsoft or any game publisher.
