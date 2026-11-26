# Engine responsibility map — what is missing, and how much

Question: is the missing executable a small bootstrap, or effectively the whole runtime?

**Answer: the whole runtime/behaviour layer.** Every subsystem is "data recoverable, runtime missing".
The dump is unusually complete on content and empty on logic.

## Combined map

Public state from CodeWalker `485d56b`, OpenRAGE `5c9c19d`, FiveM `8cbec36`, nativedb
`424fb5b`/`e8558ab`. Dump figures from `sixng info` and cached indexes.

| # | Subsystem | Public code/docs | In our dump | Missing |
|---|---|---|---|---|
| 1 | Resource/streaming | RPF/RSC read+write (V), read (RDR2); streaming budgets in FiveM | 22 RPF9 (~150 GiB), 57 TTPF (~58 GiB), all TOC-encrypted | residency policy, virtual-memory manager |
| 2 | Entity/archetype | full data parse incl. MLO (CodeWalker) | levels ~71 GiB, story000 ~19 GiB, core_bvh4 ~8 GiB | spatial DB, entity runtime, streaming/population coupling |
| 3 | Script VM / natives | disassemblers (OpenRAGE `ysc.rs`), nativedb, FiveM `GetNativeHandler` | **3,321 PSIN records / 78.1 MB, opaque**; no registry | opcode semantics, native dispatch, program loader |
| 4 | Animation | clip/expression parsers, preview | `anim.rpf` ~4 GiB, 265 entries | blend trees, IK, facial runtime |
| 5 | Physics | bounds/frag/collision/handling data | collision in levels/bvh4, navmeshes ~6 GiB | solver, vehicle model, dynamics |
| 6 | AI / navigation | navmesh + scenario data, population natives | navmesh, paths, scenarios | behaviour logic, decision making |
| 7 | World simulation | time/weather/popzone tables | tables in data/common | scheduling, time-weather-population coupling |
| 8 | Rendering orchestration | **nothing** (no draw-list/visibility code public) | shaders 383 MiB (PS09), TTPF textures ~58 GiB | draw lists, culling, pass scheduling, binding |
| 9 | Audio | bank decode (AWC/ADAT) | `audio.rpf` ~27 GiB, 103 entries | mix graph, voice runtime |
| 10 | Networking | deepest behavioural map (FiveM OneSync) | none usable | exe-bound; VI unknown |

## What this means

1. **Data is not the bottleneck.** World geometry, navmesh, audio, cinematics and textures are
   essentially complete (the full package).
2. **Behaviour is.** Not one subsystem has a public runtime implementation that can be pointed at
   our data. Parsers and metadata exist; schedulers, solvers, VMs and draw submission do not.
3. **The executable is not a bootstrap.** It is the module that contains items 3–8's runtime:
   script dispatch, entity/world simulation, physics, AI, animation blending and draw submission.
4. **The remaining unknown is `story000_script.rpf`**, not PSIN: PSIN inside `script.rpf` is a
   binary-XML DOM, so that route is closed — there is no bytecode to decode there. Of the **2,309**
   records in `story000_script.rpf`, **119** have been parsed; the rest are unread. If those carry a
   recoverable native-call encoding, a minimal native-service layer could run *logic* even without the
   engine; if not, the reconstruction route has no foundation and should stop.
5. **Rendering is the weakest public area** — even with perfect game logic, draw submission would be
   built from scratch against our own reverse-engineering of the PS09/command-list work.

## Next probe, if the route is pursued

Only one cheap test is justified: run the RASM fork (`DeusMaveriX/RAGE-Assembler-Disassembler`) with
console/opcode-version targets against a de-page-wrapped PSIN blob, and `Jaycadox/ysc-utils`
`native_table` if a header parses. Positive result → documented script disassembly. Negative →
close the route rather than build an interpreter on speculation.
