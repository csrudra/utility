# Performance baseline

## Run next1: `hybridgt/next` (victory-gta6 `a26859f` + HybridGt + ZTRX #32 #36 #43), 2026-11-25

RTX 4070 Ti, Windows 11. Series X profile, `VICTORY_DISPLAY_MODE=1920x1080`, fork defaults (relay
stage 2, late wait 3, wide copy-back, card buffers 1–1,024 MB), `VICTORY_FFX_DIR` set. Shader
cache warmed first: 25,738 of 25,985 translated, 247 refused, 207 s on 12 threads. Log:
`HybridGt-work/logs/next1.log`. About 4.5 min, ended by closing the window. No device loss.

| Phase | fps | ms/frame | Draws/frame |
|---|---|---|---|
| Boot, intro, menus | 30.0 | 33.3 | 3–11 |
| Loading | 0.5–0.8 | 1,270–1,830 | 12–1,104 |
| World (prologue) | 1.9–3.2 | 309–518 | 4,965–6,487 |

Steady world frame (07:40:38): 337 ms in all.

| Part | Time |
|---|---|
| CPU preparing | 139.5 ms (buffer copies 87.8 ms for 194 MB; textures 4.7 ms) |
| GPU | 110.6 ms |
| Copy-back thread | 182 ms for 75 MB |
| Descriptor-record mirroring (new upstream) | 49.5 ms per frame (50,399 of 234,346 slots changed) |
| GPU idle | 145–166 ms a frame (52–60 % busy); 118–127 ms of that behind the submitting thread |
| Dropped draws | 336–398 per frame "without a host pipeline" |

Other counts:
- 2 compute pipelines refused by the driver (`2da4beb386509b77`, `02384a60fda6f2d0`); the old base had 5.
- 22 calls to the unimplemented device methods `0x1c8` / `0x218` (the description carries 64-bit shader identifiers, likely ray-tracing state objects).

**Compared with the old base** (fork `1684989` + HybridGt, best 3.5–3.8 fps with the same speed
switches set by hand): world fps is not better, at about 3.0. That is with up to 30 % more draws
per frame, and with the new 50 ms of descriptor mirroring.

**Textures:** the user saw faces textured, but many assets still lack textures. The log
says the card is full:
- "the card has no room for new ones", reached 16,000 times;
- 6,258 texture slots waiting for memory, 2,431 uploaded only in part.

Upstream's `VICTORY_LEVELS_ON_DEMAND=1` (off by default) gives textures memory only for the detail
levels the title has loaded. Upstream measured 3.1 GB freed on an RTX 4070. It is the next test.
