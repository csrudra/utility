# PSIN probe — RASM reuse test (2026-11-21)

**Question:** are the 3,321 PSIN records in `script.rpf` / `story000_script.rpf` executable RAGE
bytecode that an existing disassembler can decode?

**Answer: no existing tool can test it. The cheap reuse route is closed.** This is not proof that PSIN
contains no code — only that RASM cannot decode it and has no target for the title.

## Tool and build (verified)

`DeusMaveriX/RAGE-Assembler-Disassembler` @ `0f587fc2`, C++/MSVC, built Release x64 with MSVC 14.51
(toolset v143→v145), NuGet restored (Boost 1.79, zlib, zstd). Binary `x64\Release\RASM.exe`.
Targets: `GTAIV | RDR | RDR_SCO | GTAV | RDR2`; platforms `XBOX | PSX | PC`. **No target for the title.**

## Condition 1 — validated on known-compatible bytecode

| Input | Target/platform | Result |
|---|---|---|
| `MenuBase.ysc` (GTA V, 805,104 B) | GTAV / PC, `-nv 158` | **pass** — 3,589,911 B decompiled, real header, statics, opcodes, natives |
| `rdr2_test.ysc` | RDR2 / PC | **pass** — 753 B, `SetSignature`, `Function`, `CallNative` |
| `freemodeRDR.xsc` | RDR / XBOX | **pass** — 586,834 B (console mode works for RDR) |
| `MenuBase.xsc` (GTA V console) | GTAV / XBOX | **fail** — `0xC0000005`, on the repo's own sample |
| `example.xsc` (GTA IV console) | GTAIV / XBOX | **fail** — `0xC0000005` |

So the disassembler is real and GTA V PC + RDR console modes work. **GTA V console mode is broken in this
build**, which rules it out as a PSIN test vehicle.

## Condition 2 — PSIN sections

Extracted from `unnamed_3e5000.pso` (119,296 B): whole record and the four section slices at `0x50`,
`0xac8`, `0x26f0`, `0x157f0`. Tested GTAV/XBOX and GTAV/PC.

| Input | XBOX | PC |
|---|---|---|
| whole PSIN | `0xC0000005` | `0xC0000005` |
| `0x50` slice | `0xC0000005` | `0xC0000005` |
| `0xac8` slice | — | `0xC0000005` |
| `0x26f0` slice | — | `0xC0000005` |
| `0x157f0` slice | — | `0xC0000005` |

No output file produced in any case; the tool crashes rather than rejecting cleanly.

## Condition 3 — stop

- No opcodes were invented, no interpreter written, no decryption attempted.
- RASM failing does **not** establish that PSIN has no executable code. PSIN is a new container
  (`PSIN` magic, section table at `0x18`, no RSC7 header), and no public tool targets the title.
- The **genuine disassembly evidence** we required (instruction boundaries, control flow, native calls
  consistent across scripts) was not obtained and cannot be claimed.

## Decision

Per the agreed table: **new or opaque format → document and park.** Do not build a script interpreter.

What would reopen the lead: a title-aware container/opcode specification, a GTA V console mode that
actually works in a maintained disassembler, or the executable (which holds the native registry and the
loader's format expectations).

Artifacts: RASM build in `archive/repos/RASM`; slices in `%TEMP%\opencode\psin\slices`; this report.

## Update 2026-11-21 23:45 — a new parser decoded them

`Ahmet-Dedeler/rage9-re` (MIT OR Apache-2.0, first commit 5 h earlier) implements the PSIN container.
Built and run against our dump, read-only:

```
script.rpf:  PSIN containers parsed: 1012/1012 | DOM trees verified: 1012/1012
             nodes=20379 attributes=63288 vectors=7929 u64_hashes=13440
story000_script.rpf: PSIN containers parsed: 119/2309 | DOM trees verified: 0/2309
```

Container layout (parser + docs): `PSIN -> LSCH -> LENM -> LSNS -> LGID -> LRSC -> CHKS`, big-endian
section headers, little-endian bodies; `PSIN` is a PSO v122 instance-block table whose payload is a
**compiled binary-XML script-data DOM** with root struct `0xde396fe2`. The emitted tree is typed nodes
and attributes (hashes and values), not opcodes.

**Verdict, with evidence:** in `script.rpf`, PSIN is **data, not bytecode**. The reconstruction route is
closed by observation, not by tool failure. The earlier RASM result stands as "RASM cannot decode it",
which is a different statement.

**What remains unknown:**
- `story000_script.rpf` (2,309 records, 74.65 MB): only 119 containers parse structurally, none produce
  a DOM. Encrypted or a different schema; our entropy check already showed a high-entropy tail.
- A 334,688-byte block at `0x1480` in sub-RPF9 #1 of `script.rpf`, entropy 7.988 — the only remaining
  candidate for hidden data, and it is encrypted.

Both require a key or an exe-side reader. No script interpreter should be built.
