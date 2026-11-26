# Console-DLL harness — HLE readiness

Target: execute a real shipped Xbox Series DLL under xcl, in the VM, and validate the
root-signature path. Frozen baseline `lab/nvidia-wave32-v2 @ 217ac85`.

Subject DLL: `XboxBvhBuilder.dll` (SHA-256 `99f803ac…23707e`, 884,224 B). Its imports resolve through
the two console modules `d3d12_xs` and `xmem`, and two are load-bearing for this test:
`d3d12_xs!D3D12SerializeVersionedRootSignature` and `xmem!XMemVirtualQuery`. That is narrower than the
HLE surface the harness exercises — **7 imports across 6 rows** in the Level 1 table below (one row
covers `XMemAlloc`/`XMemFree`; `XAudio2_9!ord#1` belongs to the probe, not the DLL).

## Acceptance criteria (4 levels)

| Level | Required evidence |
|---|---|
| 1. Import resolution | Already covered by source audit — not a milestone |
| 2. Actual execution | Real GPU backend, a callable export, genuine serialization |
| 3. Correctness | Valid blob, independently deserialized and compared with PC `d3d12.dll` |
| 4. Console fidelity | Original console flags recorded **before** the `0xFFF` mask |

Non-negotiable:
- Reject the null backend's 16-byte zero blob even when `S_OK`.
- Capture flags at `hle/d3d12x/mod.rs:118-129`; a PC-compatible blob alone does not prove the console
  bits were handled correctly.


## Level 1 — import resolution (source audit, verified)

| Import | Status | Behaviour | Source |
|---|---|---|---|
| `D3D12SerializeVersionedRootSignature` | **implemented** | copies 48-byte desc, masks flags at `+40` to `0xFFF` (console `0x3000000` dropped + logged), forwards to system `d3d12.dll` on the real backend | `hle/d3d12x/mod.rs:115-151`, export `:33` |
| `D3D12CreateRootSignatureDeserializer` | **implemented** | real-backend forward; null backend `E_NOTIMPL`, `*ppv=NULL` | `mod.rs:170-177`; `null.rs:715-720` |
| `XMemVirtualQuery` | **implemented** | `VirtualQueryEx`; writes "CPU-readable" at `+48`; no graphics/system split | `hle/kernelx.rs:243-256` |
| `XMemAlloc` / `XMemFree` | **implemented** | `type==0` → aligned heap, else UMA, fallback `VirtualAlloc` | `kernelx.rs:225-237` |
| `XMemGetWorkingSetStatistics` | **stub** | always `FALSE`, writes nothing | `kernelx.rs:258-263` |
| `XAudio2_9!ord#1` | **implemented** | `XAudio2Create`, console flags stripped, real engine if `xaudio2_9.dll` present | `stubdb.toml:29-31`; `xaudio2.rs:163-165` |

`xmem.dll` has no module route, so its imports are resolved as `HleOther("kernelx.dll")`
(`hle/mod.rs:101-115`, `resolver.rs:220-223`). Unknown imports are logging stubs, never load failures
(`resolver.rs:175-178, 225`).

**Consequence:** a successful `LoadLibrary` proves almost nothing. That was already the case for the
test title, and it remains true here.

## Level 2 — real execution

- **On the VM's real backend** the serialize call is genuine: desc copied, flags masked, forwarded to
  PC `d3d12.dll`, real blob returned. This is the only configuration where level 2 means anything.
- **With `graphics="null"`** the same call returns `S_OK` with a **16-byte zero blob**. A harness would
  "succeed" while producing nothing. Never run this test headless.
- Flag masking (`0x3000000` console bits dropped) happens **before** serialization, so the returned
  blob cannot show the console flags. If the harness needs them, capture at `mod.rs:118-129`.

## Level 3 — semantic correctness

Reference: PC `d3d12.dll` serializing/deserializing the same `D3D12_VERSIONED_ROOT_SIGNATURE_DESC`.
Compare normalised structure — flags, parameters, descriptor ranges, register spaces, static samplers —
not raw bytes.

Caveat: `XboxBvhBuilder`'s root signatures are internal BVH pipelines. A match validates xcl's
serializer/HLE path, not the title's game-specific signatures.

## Level 4 — console fidelity

The console flag word (`0x3000000` bits) is masked at `hle/d3d12x/mod.rs:118-129` before the call
reaches PC `d3d12.dll`, so it can never appear in the returned blob. Record the pre-mask value and the
descriptor that produced it. A blob that merely deserializes on PC is not evidence that console flags
were preserved.

## Staging (done 2026-11-21)

Built static-CRT probe binary from `crates/xcl/tests/console_dlls_e2e.rs` at `217ac85`; the probe already
exists at this baseline (`xbox_bvh_builder_on_xcl_device_probe`, line 404). Guest now holds:

```
C:\lab\bvhtest.exe          (7,523,328 B, static CRT)
C:\lab\dlls\*.dll           (all 16 shipped DLLs, XCL_SAMPLE_DLLS)
```

The run executed as planned (VM only, real GPU backend, after the Ghidra report); its result is the
next section.

```
set XCL_SAMPLE_DLLS=C:\lab\dlls
set XCL_TEST_MEM_GB=6
set XCL_PROBE_BVH_DEVICE=1
set XCL_PROBE_BVH_RECORD=1
set XCL_D3D12_TRACE=1
set XCL_CONSOLE_LISTS=1
set XCL_FORCE_WAVE32=1
C:\lab\bvhtest.exe xbox_bvh_builder_on_xcl_device_probe --nocapture --test-threads=1
```

What to read: `D3D12XboxCreateDevice` HRESULT, `XboxBvhBuilder constructed`, `CreateRootSignature` +
"console flags … dropped" (level 4), `sizes: result/scratch` and the recorded BLAS (level 2). A
`graphics="null"` run must be rejected as evidence.

## Result — first VM run (2026-11-21)

Existing probe `xbox_bvh_builder_on_xcl_device_probe`, real GPU backend, `XCL_SAMPLE_DLLS=C:\lab\dlls`.
Exit `-1073740791` (`0xC0000409`, fail-fast) after the failure below.

| Level | Result | Evidence |
|---|---|---|
| 1. Imports | pass (source audit) | all imports in the Level 1 table resolve |
| 2. Execution | **pass** | `XboxBvhBuilder constructed`; 17 serializations (16 descriptor builders per GHIDRA-BVH §2.3) → `CreateRootSignature`; prebuild returned **13,312 B result / 23,872 B scratch** in UMA |
| 3. Correctness | **pass** | captured 140-byte blob (`34a9ff3eb9f959b6`, SHA-256 `9be87e1c…1eec`) deserialized by PC `d3d12.dll`: 3 params — UAV(0,0), UAV(1,0), 32-bit constants count 16; flags `0x0`; 0 static samplers |
| 4. Console fidelity | **pre-mask value captured (level-4 input); preservation unproven** | log: `D3D12SerializeVersionedRootSignature: console flags 0x3000000 dropped`; returned blob carries flags `0x0`, so console survival of `0x03000000` is not verified. Ghidra shows the middleware ORs `0x3000000` at desc `+0x28` |

Ghidra corroboration (`GHIDRA-BVH.md`): `FUN_18000C2D0` copies 48 bytes, sets `flags |= 0x3000000`,
serializes, then calls device vtable `+0x80`. Only reachable from the constructor `0x180021330`.
52 embedded `RTS0` blobs carry flags `0x03000000` and are dead data (0 code refs).

### First unsupported operation

```
[STUB] d3d12_xs.dll!ID3D12GraphicsCommandList10::#148 (not on PC)
       first called from xboxbvhbuilder.dll+0x20ed9 → returning 0x0
Failed to allocate upload buffer
fatal runtime error: Rust cannot catch foreign exceptions, aborting
```

Slot **#148 is `AllocateUploadMemory(size, alignment) → CPU pointer`** (the repo's fake-list test already
models it). Returning 0 makes the middleware throw; xcl's foreign-exception path aborts the process.

Second, separate gap: `dxcompiler.dll not found` in the guest, so the BVH compute shaders are not
translated for the PSOs. Not needed for the recorded build, needed for executing it.

Stop condition met: runtime capability demonstrated, specific failure identified. No fix applied in this
pass.

## Open items for the harness

1. Which export reaches the serialize path (Ghidra agent).
2. Whether the object can be constructed with a console device under xcl without calling deeper
   D3D12.X slots that are stubbed.
3. Whether to call the middleware export or `D3D12SerializeVersionedRootSignature` directly; the
   direct call tests less but isolates the HLE.
