# Performance architecture

2026-11-25. Runtime: victory-gta6 `9376fd6`, plus the HybridGt and ZTRX patches (`patches/victory-gta6/`).
Hardware: Ryzen 7 5800X3D, RTX 4070 Ti, 32 GB, Windows 11. Every number below comes from a run
log in `HybridGt-work/logs/` and is named by its run.

## How a frame moves through the runtime

```
title code (native x86-64, in process)
  │  calls D3D12.X / XMem / DirectStorage APIs (victory-hle modules)
  ▼
title threads record command lists ──► draw.rs: per draw, descriptor tables are
  │                                      resolved (HostHeap::mirror, one heap lock)
  ▼
submission (host.rs, submitting thread)
  ├─ descriptor sync: records the title byte-copied into its heaps (descriptor.rs sync_heaps)
  ├─ run_deferred: per list, the buffer ranges shaders read are brought up to date
  │    write watch / guards → read changed pages → upload into the host copy
  │    (copies in the card's memory: sent up, then hashed on the card)
  ├─ texture refreshes (texture.rs): read in place under watch::MAPPING (read side)
  └─ ExecuteCommandLists on the host's one direct queue ──► RTX 4070 Ti
                                                              │
relay thread (copy-back, VICTORY_RELAY) ◄─────────────────────┘
  ├─ waits for the flight's fence
  ├─ compares the card copies' pieces the shaders may have written (compute pass)
  ├─ fetches flagged pieces (a list of its own on the same queue, then waits)
  └─ merges them into title memory (Shadow::card_merge_relay)
       │
title threads that read that memory wait for the landing ("title memory read" settles)
```

Memory remapping runs beside this on the title's streaming threads:
`XMemMapPhysicalPages(Scatter)` and the queue's `CopyPageMappingsBatchX`
(`victory-hle/src/modules/xmem.rs`). Every change of a mapping holds
`watch::MAPPING` (write side), and the GPU side is told
(`title_memory_remapped`, `title_memory_view`).

## Synchronous boundaries and what they cost (steady world frame, run next9, 280 ms)

| Boundary | Who waits | Per frame | Why it exists |
|---|---|---|---|
| "title memory read" settle | submitting thread | 154 ms | the title reads memory that a flight's shaders write; it must see the GPU's result |
| card-copy fetch round trip | relay thread | 134 ms in 7 fetches | flagged pieces come down with a list of their own, queued behind newer flights |
| GPU idle behind our CPU work | GPU | 66 ms | preparation of the next submission is serial with it |
| CPU preparation | submitting thread | 96–104 ms | buffer copies 58–64 ms (176–186 MB), textures 3–5 ms, descriptor sync |
| GPU work | GPU | 150–155 ms | 4,700 draws, translated shaders |
| descriptor mirroring "lock and lookup" | all recording threads | 50 ms of thread time | one `made` lock per heap; draw-time lookups |
| remap lock (`watch::MAPPING`) | streaming threads, texture refreshes | up to 4.4 s per frame while streaming (next9, loading) | readers must not meet the unmapped gap of a remap |

## Per-item operations (each runs once per X)

| Operation | Granularity | Where |
|---|---|---|
| remap lock + unmap/map (4 system calls) | per page for scatter and constant-page aliases (before patch 0014) | xmem.rs |
| descriptor mirror | per changed slot, per draw-table slot | descriptor/host.rs |
| buffer refresh | per range per submission | host.rs run_deferred, shadow.rs |
| card compare | per 64 KiB piece of a written range | host.rs relay |
| fetch | per flagged piece, per landing | host.rs relay_card_back |

## Optimisations already in place (upstream)

- **Relay stage 2** (`VICTORY_RELAY`): copy-back on its own thread.
- **Late wait 3**, **wide copy-back** and **card buffers from 1 MiB**: these are now the defaults.
- **Write watch plus guards**: only changed pages are read.
- **Descriptor sync** (`9376fd6`): a cheap fingerprint, and draw-table slots left to their draws.
- **Levels on demand** (`VICTORY_LEVELS_ON_DEMAND=1`): texture memory only for loaded levels.
- **Wide refresh** (`VICTORY_WIDE_REFRESH=1`): refreshes spread over threads.

## Known gaps that add cost

- The title's two console pipeline methods (`0x1c8`, `0x218`) are not implemented
  (`docs/SERIES_S_AND_FSR.md`).
- 247 of 25,985 shaders do not translate; about 330–1,000 draws a frame are dropped.
- No GPU timing per shader yet: the diagnostics build has `VICTORY_GPU_TIMING`, not yet run on
  this machine.

## Improvements made and planned

See `PERFORMANCE_OPTIMIZATION.md` (log with measurements) and `BREAKTHROUGH_ARCHITECTURE.md`.
