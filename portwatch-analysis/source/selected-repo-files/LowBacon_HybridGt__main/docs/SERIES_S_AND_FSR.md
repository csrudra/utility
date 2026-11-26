# Series S black screen and FidelityFX (FSR)

2026-11-25. Runs fork13 (old base) and next4s (`hybridgt/next`): `--console series-s`, 1080p.

## What happens

- The title loads its FidelityFX loader. HybridGt's module (patches 0002–0003) loads AMD's signed
  PC upscaler, and the title's calls succeed:
  - `ffxCreateContext` with descriptors `0x10000` (upscale), `0x1000002` (Xbox backend) and
    `0x1000b` (version), answer 0;
  - `ffxQuery` with `0x10004` (jitter phase count), answer 0;
  - "upscale context made on the host device".
- The title **never calls `ffxDispatch`**. From frame 256 on, every frame is 11 draws and 4
  dispatches at 30 fps, and the screen stays black. The user confirmed this in both runs.
- Device method **`0x218`** is called over and over in Series S. The log lines report it at 4,
  8, 64 and 512 calls, and it was still being called. In Series X it is called 22 times in all.
  The method is not implemented, so every call fails. The title appears to retry it every frame
  and never gets past this screen.

So the black screen is not the upscaler. It is a pipeline the title cannot make, so the title
never reaches the frames that would use FSR.

## What methods 0x218 and 0x1c8 take

Saved with `VICTORY_SAVE_PIPELINES` (patch 0013) in a 150 s Series S run: 48 calls of each
method, 1,000 files in `HybridGt-work/pipeline-dump/`, which stay on this machine.

`0x218` (compute). The description is an array of 12 64-bit words per entry, and each call
passes one entry:

| Word | Content | Seen |
|---|---|---|
| 0 | an object (a root signature?) | same per group of calls |
| 1, 2 | pointer, size 0x1c | `4005cf00 6c090102 0 00080008 1 402c0343 b8a`: shader register words (`0x4005cf00`, `0x6c090102`), **thread group 8×8×1**, two more words |
| 3, 4 | pointer, size 0x14 | a 32-bit hash per pipeline, then `3, 0, 0, 0` |
| 5, 6 | pointer, size 0x180–0x400 | **native GFX10 code** at a GPU address (`0x948a2xxxx`), starting with the hash-carrying `v_nop` header that shader containers' native code also has |
| 7, 8 | pointer, size 0x118–0x1d8 | a 16-byte header (`0x403, 0x104, 0x60, 0`), then 32-byte records tagged `0x41` (user-data / register mapping), `0x42` (bindings) and `0x43` (the code's 16-byte hash) |
| 9, 10 | two pointers | not looked at yet |
| 11 | 64-bit value | differs per pipeline; matches none of the title's shader container hashes |

`0x1c8` (graphics): the same shape with two code blobs (vertex and pixel, 0x200 bytes each) and
graphics register state (0x184-byte blob starting `4005d808`).

## What implementing it takes

1. Decode the `0x41` / `0x42` records into the translator's `RootParam` / `UsedResource` (user SGPR
   per root parameter, descriptor kinds), and the register words into wave size, VGPR count and
   thread group.
2. Build a `NativeProgram` from the code and that metadata, translate it as a container's native
   program is translated, and make the host pipeline.
3. Check it against the same code where a shader container also has it (the `v_nop` hash header
   names the code).

Until then Series S cannot get past this screen, and FSR is never asked for. In Series X the
title makes no FSR call at all.
