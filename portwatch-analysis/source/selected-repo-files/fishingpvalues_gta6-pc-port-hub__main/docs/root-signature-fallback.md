# C-3 · Root-signature-less shaders (the shared bug)

**Question this answers:** why do thousands of GTA VI shaders stop at their first resource load, and what is the agreed fallback?

This is the single most duplicated unfixed bug in the ecosystem: the same failure is described independently in four codebases, and no shared specification exists for the fix.

## The problem

Xbox Series (`Scarlett`) shaders normally carry an **RTS0** chunk describing the root signature — the binding contract between the draw call and the shader's register space. Many RAGE 9 programs do not.

Evidence from the projects:

| Project | Observation |
| :--- | :--- |
| `omonkeyz/xbox-emulator` (`docs/BLOCKERS.md`) | All **8,765** GTA VI mesh programs lack an RTS0 chunk; **8,749** stop at the first resource load. Amplification shaders are untranslated. |
| `drycheetah84/TomBox` | "Shaders that carry no root signature" are named blockers alongside mesh shaders; ~1/3 of vertex shaders translate. |
| `ivall/xcl` | Static samplers and draw-time root-arg→SGPR binding are open items. |
| `californiaAlmonds/OpenScarlett` | Bridges missing root layouts through a bindless `s0..s15` descriptor convention. |

Each has invented a private answer. `omonkeyz/xbox-emulator` #142 asks whether an RTS0-less / `FORCE_MEMORY_BASED_ABI` fallback belongs in the design — that question is bigger than one repo.

## What the fallback has to define

A "memory-based root ABI" spec would fix, once:

1. **Descriptor model.** When RTS0 is absent, assume a flat descriptor heap addressed through a known register range aquad (OpenScarlett's `s0..s15` is a working precedent) and state the exact index space.
2. **Root argument delivery.** How draw-time constants reach SGPRs when the layout is unknown: a fixed per-stage window, and the rule for which registers the title actually reads.
3. **Static samplers.** Where sampler state comes from with no root signature — a default sampler table, and how to override it per draw.
4. **Fallback ordering.** Try RTS0 → then the AMD extended-ABI header → then memory-based convention, and log which path won.
5. **Validation.** A shader that only *binds* under the fallback must be distinguishable from one that binds natively; otherwise census numbers (see [C-2](shader-census.md)) become meaningless.

## Proposal (draft — needs your review)

```
if RTS0 present:            use it
elif extended ABI header:   use it
else:                       memory-based root ABI v1
    descriptors:            flat heap, s0..s15 = first 16 tables
    root args:              stage-uniform 32-DWORD window at SGPR[0..31]
    static samplers:        s#_s[] default table, overridable per draw
    unknown reads:          zero-fill, record in a per-program audit log
```

The audit log is the important part: it turns a silent stall into a list of programs that need a real root signature, which feeds C-2.

## Tasks

- [ ] Write `spec/memory-root-abi-v1.md` with the exact register/descriptor layout.
- [ ] Publish a fixture: one RTS0-less mesh program plus its expected bound-output hash, usable by any project (see [C-4](conformance.md)).
- [ ] Get four implementations (`xbox-emulator`, `TomBox`, `xcl`, `OpenScarlett`) to report which path they took per program.
- [ ] Confirm whether GTA VI's 8,749 programs share one layout, or several — that decides whether one fallback is enough.

## Discussion

Open an issue with the `C-3` label. If you implement the fallback in your project, say so here and the table gets a row.
