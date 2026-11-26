# C-5 · Licence matrix

**Question this answers:** can project A reuse project B's code, and what is stopping it?

Coordination fails silently when licences are incompatible or absent. These are the current facts, taken from each repository's `LICENSE`/package metadata.

## The runtime projects

| Project | Licence | Reuse note |
| :--- | :--- | :--- |
| `ItsNotRexed/Leonida` | GPL-3.0 | Cannot absorb GPL-2.0-**only** code. |
| `ivall/xcl` | GPL-2.0-**only** | One-way incompatible with GPL-3.0 projects. `xbox-emulator` #142: "XCL is GPL-2.0-only, so I would not copy any code." |
| `omonkeyz/xbox-emulator` | GPL-3.0-or-later | Same constraint as Leonida against `xcl`. |
| `R0Y00/Xbox2Windows` | MIT | Safe donor for everything. |
| `californiaAlmonds/OpenScarlett` | MIT | Safe donor. |
| `Freminet/ScarlettX` | **none** | No licence file → legally "all rights reserved"; blocks all reuse. |
| `sammwyy/xvalkyrie` | GPL-3.0 | Compatible with GPL-3.0 projects only. |
| `drycheetah84/TomBox` | `MIT OR Apache-2.0` per crate, **no root LICENSE** | Crate metadata only; a root file is needed for clarity. |
| `brcly/TuxBox` | **none** | No licence file. |
| `boykopovar/AnyPS5` | GPL-2.0 | Upstream for `americas-recomp` and `GTAVI-Recomp`; GPL-2.0 vs GPL-3.0 applies here too. |

## The asset/tool side

Unlicensed or metadata-only: `meetox80/6stars`, `breadbbbb/rpf9-explorer`, `offs/rpf9-extract`, `drycheetah84/TomBox`, `oguzhanozfe/gta-vi-port-research`. Mixed: `Ahmet-Dedeler/*` repos are `NOASSERTION` at the API level (per-repo licence files still apply).

## Why this is a coordination problem, not pedantry

- The single most reusable artefact in the ecosystem — `xcl`'s reimplemented `d3d12_xs`/`kernelx` — cannot be copied into the two largest GPL-3.0 efforts. Every project re-derives it.
- `ScarlettX` and `TuxBox` contain unique work (XS2 shader lifting pipeline, Linux-first layer) that nobody may legally reuse.
- A shared corpus (see [C-4](conformance.md)) must be CC0 or dual-licensed to be usable by GPL-2.0, GPL-3.0 and unlicensed projects alike.

## Asks

- [ ] `ScarlettX`, `TuxBox`: add a `LICENSE` (MIT or GPL-3.0 would both unblock).
- [ ] `TomBox`: add a root `LICENSE` matching the crate metadata (`MIT OR Apache-2.0`).
- [ ] `xcl`: consider `GPL-2.0-or-later` — a one-character-ish change that makes it GPL-3.0-compatible.
- [ ] `6stars`, `rpf9-explorer`, `rpf9-extract`, `gta-vi-port-research`: pick a licence.

If a maintainer prefers a different licence, that is fine — the point is that it is written down. Update this table when it changes.
