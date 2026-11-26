# Geometry shaders (196 programs, voxel lighting)

2026-11-25. From the translator's failure dump (`VICTORY_FAIL_DUMP`, kept on this machine only)
and `victory shader-info --disasm`.

## What they are

Every geometry-stage program of the title fails translation; 195 of them are
`GS_VoxelizeGeneric_*` (voxelization for the lighting), one more fails on a lane mask. Each
container holds **only the geometry program** (about 1 KiB, ~145 instructions); the vertex
part is another container, compiled for the ES stage.

They are **legacy (non-NGG) geometry shaders** of GFX10:

- Inputs: the triangle's three vertices are read from LDS (the ES-GS ring) with `ds_read2_b32`
  at vertex offsets the hardware gives packed in `v0`/`v1` (`(v << 2) & 0x3fffc`).
- Outputs: each emitted vertex is 20 dwords written to LDS (the GS-VS ring) at
  `v12 = 0xF0 * lane + (s0 << 8) + s2`, then `s_sendmsg GS_EMIT`; three emits, `GS_CUT`,
  `GS_DONE`. A **copy shader** the console driver generates (not in the title's files) reads the
  ring and exports position and parameters.
- `s0` comes from `s_load_dword` at offset `0xB8` of a pointer in user data 0-1
  (`s[8:9]`, low byte of `s9`): a driver table, not a root parameter. This is the reported
  failure ("an address in an SGPR that is no root parameter"); it only places the ring.

## What a real implementation needs

1. ES programs translated as host vertex shaders whose ES-GS ring stores become outputs
   (dword `k` of a vertex -> output element `k`).
2. The GS program as a DXIL geometry shader (`[maxvertexcount(n)]`, triangle input): ES-GS ring
   reads at `vertex offset + 4k` -> `input[vertex][k]`; GS-VS ring writes at
   `emit * 20 dwords + k` -> output element `k` of the vertex being built; `GS_EMIT` ->
   `EmitStream`, `GS_CUT` -> `CutStream`. The ring addressing (`s0`, `s2`, lane) drops out.
3. The copy shader's mapping of the 20 dwords to position and parameters: **solved** by the
   container's own signatures (`ISG1`: `SV_Position`, `TEXCOORD0.xy`; `OSG1`: `SV_Position`,
   `TEXCOORD0-3`, five registers = 20 dwords): ring dword `k` is register `k / 4`, column
   `k % 4`.
4. Host pipelines with a GS stage (`D3D12_GRAPHICS_PIPELINE_STATE_DESC::GS`), and the draw
   path that binds them.

Until then the draws with these pipelines are dropped, and the voxel lighting they feed has no
input.

## Status (2026-11-25, evening)

- Translator (`emit/lower/gs.rs`, fork commit `6535505`): geometry programs lower as host
  geometry shaders. ES-GS reads at a vertex's offset -> `loadInput` of that vertex (`v0` low/high
  half: vertices 0/1, `v1` low: vertex 2); GS-VS writes kept per vertex (stride: 4 dwords an
  output register) and stored as outputs at each `GS_EMIT`, then `emitStream`; `GS_CUT` ->
  `cutStream`. The driver's table (`resource::DRIVER`) reads as zeros; `s3` reads 64 GS threads;
  the opening EXEC mask holds for every host invocation.
- Offline over the title: **all 195 geometry programs emit DXIL that passes `dxil.dll`'s
  validator** (`logs/translate-list-19.txt`).
- Not yet: the 195 **ES programs** (the voxelization's vertex stage; the console merges them with
  the geometry program) are not translated, and the runtime makes no host pipeline for a title
  pipeline with a geometry stage (`pipeline.rs`: "geometry stages keep their containers only"),
  so these draws are still dropped.
- Not yet checked: the emitted shaders' results on the GPU.
