# C-2 · Shader census convention

**Question this answers:** how many shaders does GTA VI have, and what does "99% translated" mean?

Right now it means nothing, because the community publishes at least four incompatible denominators. This document proposes one convention so that coverage claims become comparable.

## The disagreement

| Source | Number | What it apparently counts |
| :--- | --: | :--- |
| `ItsNotRexed/Leonida` | 26,503 | RDNA2 shaders translated from the retail `shaders.rpf` |
| `ivall/xcl` | 24,064 | "programs in a RAGE 9 `shaders.rpf`" |
| `omonkeyz/xbox-emulator` | 25,727 (TomBox #5) | shader census for the same title |
| `R0Y00/Xbox2Windows` (#594) | 12,101 PS / 2,689 CS / … | records executed per stage |
| Console shader cache | 21,522 | cached entries, different population again |
| `omonkeyz` mesh subset | 8,765 | mesh programs; 8,749 carry no RTS0 chunk |

`Xbox2Windows` #594 cross-files to `TomBox` #5 asking for exactly this: one convention instead of two numbers that cannot be reconciled. None of these are wrong — they count different populations (PSIN entries vs. stage programs vs. cache entries vs. translated records). That is the problem.

## Proposed convention

**Unit of counting: one *program record*** = one PSIN entry in an RPF9 shader archive, identified by `(archive, stage, byte-size, content-hash)`.

Report a census as a tuple, never a single percentage:

```json
{
  "archive": "shaders.rpf",
  "total": 26503,
  "by_stage": { "vs": 0, "ps": 0, "cs": 0, "gs": 0, "hs": 0, "ds": 0, "as": 0, "ms": 0 },
  "by_format": { "rdna2_binary": 0, "console_cache_entry": 0 },
  "method": "PSIN walk; dedupe by content hash",
  "tool": "owner/repo@commit"
}
```

**Status vocabulary** — a record is in exactly one state, per project:

| State | Meaning |
| :--- | :--- |
| `parsed` | header/ISA decoded, no output produced |
| `translated` | output emitted (SPIR-V or DXIL) |
| `validated` | output accepted by `spirv-val` / `dxc -Vd` |
| `bound` | root arguments and descriptors resolved for a draw |
| `executed` | ran on a GPU |
| `matched` | output compared bit-exactly or within tolerance against a reference |

"Coverage" must be reported as `state / total` for the same `total`. A project that translates 26,503/26,503 but binds 0 is not at 100%.

## Why per-stage matters

The blocking stage is not uniform:

- `R0Y00/Xbox2Windows` reports 851/12,101 pixel and 12/2,689 compute shaders *actually executed*, one mesh entry.
- `drycheetah84/TomBox` reports roughly a third of vertex shaders translating; mesh shaders and root-signature-less shaders are the blockers.
- `ItsNotRexed/Leonida` reports all 26,503 translated to valid SPIR-V, with GPU tests run on test shaders rather than the game's own.
- `sammwyy/xvalkyrie` translates 1,786/2,055 shaders one title creates; `realdody/americas-recomp` reports vertex 64.7% strict, pixel 99.97%, compute 99.6%, mesh 99.5%, geometry 100% on the Series branch.

A single percentage hides all of that.

## How to adopt it

1. Publish your census with the JSON shape above (any filename, e.g. `docs/census.json`).
2. Open an issue here titled `C-2: census — <project>` with the JSON.
3. The hub keeps the reconciled table in this document.

Nothing about this convention requires sharing code or game data; it is a reporting format.

## Open questions

- Does the console shader cache (21,522 entries) overlap the PSIN population, or is it a disjoint set? Nobody has published the set difference.
- Should mesh (`ms`) programs without RTS0 count in the same denominator as those with one? Proposal: yes, but reported as a separate `rts0_present` boolean, because it is the dominant real-world blocker (see [C-3](root-signature-fallback.md)).
- Are the 26,503 and 25,727 numbers from the same archive revision? A hash per program would settle it.
