# Ownership & claims

Claims are **advisory**: they exist to stop two people solving the same problem in the same week. Anyone may work on anything.

## Workstreams

| Workstream | Owner | Status |
| :--- | :--- | :--- |
| C-1 Package inventory | _open_ | inventory recorded, hashes pending |
| C-2 Shader census convention | _open_ | convention drafted, no project has adopted it yet |
| C-3 Root-signature-less shaders | _open_ | problem documented in 4 codebases, spec not written |
| C-4 Conformance corpus | _open_ | proposed, no fixtures published |
| C-5 Licence compatibility | _open_ | matrix recorded, asks not filed |
| C-6 Wave64-on-wave32 results | _open_ | four private harnesses, no shared table |

## Subsystem slots

Use these names when you claim something, so the table stays greppable. Add your row in the same PR.

| Slot | Meaning | Owner |
| :--- | :--- | :--- |
| `d3d12_xs` | console D3D12 shim | — |
| `kernelx` | kernel / memory aliasing | — |
| `xg_xs` | tiling and swizzle | — |
| `rdna2-lift` | RDNA2 → SPIR-V or DXIL | — |
| `bcpack` | BCPack decode | — |
| `xma2` | XMA2 audio decode | — |
| `storage` | DirectStorage / XVD / GDeflate | — |
| `shader-census` | counting and reporting | — |
| `root-abi` | memory-based root ABI | — |
| `wave64` | wave size emulation | — |
| `exe-provenance` | what the missing executable is and where it legally comes from | — |

## Hardware lab

List the GPUs you can test on, so requests can be aimed at someone who has the hardware.

| Handle | GPU | Driver | OS | Can test |
| :--- | :--- | :--- | :--- | :--- |
| — | — | — | — | — |
