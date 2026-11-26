# GTA6 PC Port Archive

Archived copies of twelve open-source projects that work on running GTA VI on PC, first saved on 2026-11-23 and updated on 2026-11-24.
ZERO of Rockstars game assets, files, or leaked info is on this repo, NOTHING HERE IS BREAKING ANY LAW OR ANYONE'S TOS
## GTA VI Launcher

**[Download GTA-VI-Launcher.zip](https://github.com/Guernica4u/GTA6-PC-Port-Archive/releases/latest/download/GTA-VI-Launcher.zip)**: a small Windows launcher for these runtimes. Pick your game's .exe once, choose a runtime and press PLAY. See [`launcher/`](launcher).

## Important links

- [portwatch-vi.xyz](https://portwatch-vi.xyz)
- [leonida.now](https://leonida.now)
- [fluxer.gg/YWOKODCW](https://fluxer.gg/YWOKODCW)

| Folder | Project | Original | License |
|---|---|---|---|
| [`leonida-new/`](leonida-new) | Leonida Continued: the new Leonida, carrying on from the original with its full history | `ubiquitarianism/leonida` | GPL-3.0 |
| [`leonida-old/`](leonida-old) | Leonida: the original native PC recompilation of the Xbox version | `ItsNotRexed/Leonida` (removed from GitHub on 2026-11-23) | GPL-3.0 |
| [`xcl/`](xcl) | xcl: Xbox Series compatibility layer for Windows | `ivall/xcl` | GPL-2.0 |
| [`victory/`](victory) | VIctory: an attempt at running GTA VI on PC | `Marvisak/VIctory` | GPL-3.0 |
| [`xbox2windows/`](xbox2windows) | Xbox2Windows: static recompilation of Xbox Series software for x64 Windows | `R0Y00/Xbox2Windows` | MIT |
| [`tuxbox/`](tuxbox) | TuxBox: Xbox Series compatibility layer for Linux and Windows | `brcly/TuxBox` | Apache-2.0 |
| [`hyphenn/`](hyphenn) | hyphenn: a fork of VIctory aimed at getting the world to render and run | `fxceless/victory-fork` (was `victory-gta6`) | GPL-3.0 |
| [`anyxboxx/`](anyxboxx) | AnyXboxX: an Xbox Series X emulator prototype, aimed at GTA VI for now | `LooperSalty/AnyXboxX` | GPL-3.0 |
| [`ztrx/`](ztrx) | ztrx: runs the Xbox Series build natively on Windows with NVIDIA cards, based on VIctory and hyphenn | `Zettrox/ztrx` (removed from GitHub on 2026-11-25) | GPL-3.0 |
| [`dexnom/`](dexnom) | DexNom Runtime: a VIctory fork for AMD Radeon cards | `DexNom/VIctory` | GPL-3.0 |
| [`belobug/`](belobug) | VIctory-Belobug-AMD: a VIctory fork for AMD Radeon cards | `Belobug/VIctory-Belobug-AMD` | GPL-3.0 |
| [`victory-7900xtx/`](victory-7900xtx) | VIctory-7900XTX: a VIctory fork tuned for speed on an AMD RX 7900 XTX | `avatarmanz/VIctory-7900XTX` | GPL-3.0 |
| [`github-export/`](github-export) | each project's issues, pull requests and comments | | |

Each project folder keeps its own license file. Leonida's (old and new) `third_party/rpf9-explorer` submodule
(`breadbbbb/rpf9-explorer`) has no license, so it is not included.

## Branches

The old Leonida's branches keep their original `leonida/` names.

`main` is a single snapshot of all twelve projects. Each project's original history, with its original commits, authors,
hashes and file paths, is on its own branches:

| Project | Code | Pull requests | Issues and comments |
|---|---|---|---|
| Leonida (new) | `leonida-new/main`, other branches as `leonida-new/branch/<name>` (259) | `leonida-new/pr/<number>` (533) | `leonida-new/github-export` |
| Leonida (old) | `leonida/main` | `leonida/pr/<number>` (9,425) | `leonida/github-export` |
| xcl | `xcl/main` | `xcl/pr/<number>` (651) | `xcl/github-export` |
| VIctory | `victory/main` | `victory/pr/<number>` (612) | `victory/github-export` |
| Xbox2Windows | `xbox2windows/main`, other branches as `xbox2windows/branch/<name>` (155), tag `xbox2windows/<tag>` | `xbox2windows/pr/<number>` (1,130) | `xbox2windows/github-export` |
| TuxBox | `tuxbox/main`, other branches as `tuxbox/branch/<name>` (2) | `tuxbox/pr/<number>` (68) | `tuxbox/github-export` |
| hyphenn | `hyphenn/main` | `hyphenn/pr/<number>` (801) | `hyphenn/github-export` |
| AnyXboxX | `anyxboxx/main`, other branches as `anyxboxx/branch/<name>` (2) | `anyxboxx/pr/<number>` (138) | `anyxboxx/github-export` |
| ztrx | `ztrx/main` | `ztrx/pr/<number>` (104) | `ztrx/github-export` |
| DexNom Runtime | `dexnom/main`, other branches as `dexnom/branch/<name>` (2) | `dexnom/pr/<number>` (48) | `dexnom/github-export` |
| VIctory-Belobug-AMD | `belobug/main` | `belobug/pr/<number>` (146) | `belobug/github-export` |
| VIctory-7900XTX | `victory-7900xtx/main` | `victory-7900xtx/pr/<number>` (0) | `victory-7900xtx/github-export` |

Get one project on its own:

```sh
git clone --branch leonida-new/main --single-branch https://github.com/Guernica4u/GTA6-PC-Port-Archive.git leonida-new
```

## Updates

Every hour (around minute 7; each run queues the next one), [`sync.yml`](.github/workflows/sync.yml) runs [`.github/sync.py`](.github/sync.py). For each project still
on GitHub, it fetches the code, branches and pull requests, re-exports issues and comments, and rebuilds the site.
Nothing is deleted: issues and comments removed upstream stay in the archive, and a project that disappears keeps
its last copy. The old Leonida is no longer on GitHub, so it doesn't change.

## Issues and comments

`github-export/<project>/data/` holds gzipped JSON Lines straight from the GitHub API: one issue, pull request or
comment per line. Each folder's README lists the files and counts.
