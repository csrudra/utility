# Source check — claims about reconstructing the title (2026-11-21)

What each cited project actually proves, with license and usability. Rule applied: a project is
"load-bearing" only if it cites measured console artifacts, not intent.

| Project | Claim | Verdict | Evidence | License | Use |
|---|---|---|---|---|---|
| `ivall/xcl` @217ac85 | needs the game exe for title execution | **verified** | `README.md:8-12,55,69-74`; `docs/FIRST-RUN.md` (Reproduction) | GPL-2.0-only | usable shell: 24,064/24,064 shaders (a survey of xcl's translated shaders, not full corpus coverage), real Bink/BVH/FSR4 verified; draw/present absent |
| LibertyRecomp (`hamishakl`, `OZORDI`) | GTA IV recompilation, needs original exe | **verified but wrong generation** | README: Xbox **360**, PAL `default.xex` + TU5, ReXGlue PowerPC→C++ | GPL-3.0 | architecture reference only; our dump is x86-64 Scarlett |
| `citizenfx/fivem` | loads the original exe, not a RAGE replacement | **verified** | README; `LICENSE` © Take-Two; only listed dirs LGPL-2 | proprietary + LGPL subset | architecture knowledge; only LGPL dirs reusable |
| `Two-Play/openrage` | GTA V/RDR2 tooling; a later generation planned | **verified** | README status table: next generation "once it comes to PC" | GPL-3.0 (one crate AGPL) | no formats decoded; needs keys from own copy |
| `R0Y00/Xbox2Windows` @496fc28 | documents RTS0/ACCC root-sig containers and PC deserialization | **verified** | `docs/experiments.md:892-893,923,1057` — 52 containers, flags `0x03000000`, 52/52 accepted | MIT | **load-bearing**: only public measured RTS0 source; no console run |
| assets → engine claims | gameplay reconstructable from assets alone | **no supporting evidence** | strongest xcl still has no frame; Leonida headline says "running" but status says "does not boot", D3D12→Vulkan "Not started"; GTA6-Asset-Info: "Nothing has been confirmed against game code" | — | decorative |

## Load-bearing vs decorative

1. Load-bearing: **xcl** and **Xbox2Windows** — measured artifacts.
2. Decorative for execution: OpenRAGE, GTA6-Asset-Info, SixNG — asset knowledge, no code path to a frame.
3. Misleading: Leonida (headline contradicts its own status table); LibertyRecomp is genuine but 360-era.
4. FiveM is architecturally useful, legally unusable outside its LGPL directories.

**No public claim reconstructs RAGE code or gameplay from assets. The dump has 0 executables, so there
is no code to recompile.**

## New leads from the same sweep

| Lead | What | Status |
|---|---|---|
| `DeusMaveriX/RAGE-Assembler-Disassembler` | RASM fork: disassembler with opcode-version (`-ov`) and native-version (`-nv`) flags; GTA IV/V, RDR2; XSC/CSC/YSC; console targets | verified; **most promising** for PSIN opcode test |
| `Jaycadox/ysc-utils` | `native_table` dumps a script's native table; `basic_disassemble` | verified |
| `ShinyWasabi/scrDbg` | runtime RAGE script debugger/VM hook | reported; repo 404, GTAForums topic 1006545 |
| `xodus-gaming/xgameruntime-docs`, `nocts-software/xgameruntime`, `thecatontheceiling/shimbox` | clean-room xgameruntime spec, Wine/Proton GDK runtime, `QueryApiImpl` vtable hook framework | verified; **no equivalent for `d3d12_xs`** |
| `VIRUXE/rage-cli` | RPF/RSC7 round-trip, active | verified; RSC7 only |
| `GTA6-Archive-Project/gta6-preload-decryptor` | RPF9 parser/decryptor | repo now 404; the container is closed to us and the executable that would open it is out of scope |
| `alloc8or` / `DottieDot` nativedb | GTA V/RDR3 native names+hashes | no native list for the title exists publicly |

Flagged and excluded: gta6recomp.com, percystar "breakthroughs", "113 GB build" malware, fake preload
download (credential stealer), crypto-scam impersonation sites, Kcsg013 SEO spam.

**Dead ends:** native hashes for the title and any public `d3d12_xs` specification.
