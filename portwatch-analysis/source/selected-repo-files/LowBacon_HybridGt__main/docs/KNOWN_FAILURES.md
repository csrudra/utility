# Known failures

Measured on RTX 4070 Ti with patches 0001–0010 enabled (runs 16–19, before 2026-11-24).

| # | Failure | Evidence | Status |
|---|---|---|---|
| 1 | Final frame black apart from the title card | Run 19 frame-1900 dumps: G-buffer flat grey, final image only "PROLOGUE" card. Run 19's build carried an unfinished mesh-emulation experiment that refused 469 mesh shaders | Cause of run 19 found; open |
| 1b | GPU removed ~frame 1,651 once mesh shaders run (run 20, experiment removed) | `logs/run20.log`: DXGI 0x887A0006, no breadcrumbs | Open, top priority |
| 2 | 1,400–1,800 draws dropped per second | `victory_logstats.py` on runs 17–19 | Open |
| 3 | Untranslated shaders: SGPR address not a root parameter; scalar memory read as data (`LinearDepthSkin` mesh shaders); structured buffer of unknown stride | Translator logs, ranked by drops | Open |
| 4 | 51 refused pipelines | Run logs | Open |
| 5 | Wave64 mesh shaders on 32-lane NVIDIA: no emulation (compute only) | All 9,282 mesh shaders are wave64; mesh emulation attempt fails "emulated wave operation outside uniform control flow" (not committed) | Open |
| 6 | Occasional GPU reset | Run 18, frame 2,113 | Open |
| 7 | ~1 fps | All runs; L0 system-memory shadows read at 8.5 GB/s vs ~277 GB/s VRAM | Open, after rendering |

## Rejected fixes (measured, did not help)

Loop cap 4096; dynamic slots; heap index limit as hang cause; garbage indirect args;
GPU_UPLOAD shadows (14–48 s/frame); video-memory mirrors (patch 0009, worse);
compute-only wave64 emulation alone (still hung until queue waits were added).

## Fork runs (fxceless/victory-gta6 + HybridGt patches), 2026-11-24

| Finding | Evidence | Status |
|---|---|---|
| Startup animation flickers back and forth | fork1, fork3 (VICTORY_RELAY=2), fork4 (no relay), fork5 (legacy texture switches) all flicker | Open; not relay, not the 5 texture switches |
| Legacy texture switches lose Lucia's hair | user: hair visible in fork3 (defaults), gone in fork5 | Keep fork defaults |
| Menus 30 fps, 0 dropped draws | fork3.log | OK |
| 5 pipelines refused by the NVIDIA driver (4 compute, 1 mesh+pixel) | fork3/fork5 "host pipeline refused" E_INVALIDARG | Open; shaders to be saved next run |
| Lighting shaders not translated: IrradianceCache_Shade, IrradianceCache_ShadeSecondary ("wave reduction where not every lane runs"), cascade shadows ("lane mask exchanged…"), RaytracingResolve | fork3/fork5 | Open |
| Device methods 0x1c8 / 0x218 unimplemented (likely ray-tracing state objects): 29 pipelines skipped | fork1 | Open |
