# The plan from here

The frame in the opening cutscene is ~126 ms and ~76 ms of it is the price of
separate memory: 86 MB copied up (21.8 ms), 36 MB copied back (19.1 ms),
textures 38-74 MB (6.8-15.9 ms), and ~28 ms of waiting because the next frame
reads what the previous frame's shaders wrote. That price cannot be optimised -
it is already at memcpy speed - it can only be **removed** by letting the card
see the title's memory, or **hidden** by doing it beside the render.

Everything below is ordered by "how much of that price it can take out, per unit
of risk", and each phase has a gate: a number read from the log that says go on
or stop.

## Phase 0 - does in-place memory work here at all (one run)

`VICTORY_INPLACE_PROBE=2` - the probe stage already in `inplace.rs`:

- the **device probe**: whether the host will wrap title memory as a D3D12 heap
  at all, and with what kind of allocation;
- the **census** at 30 s and 150 s: how many bytes of the title's buffers could
  be opened in place, refused by the host, or are over `VICTORY_INPLACE_MB`;
- the **real test** (`probe_level >= 2`): 64 KiB of title memory mapped in place
  and read by the GPU - "N of 65536 bytes equal to what the CPU read just before
  or just after". That is the only proof that matters: the card reading the
  title's own bytes through a heap of ours.

**Gate.** Go on if the census says a large share of the title's buffer traffic
can be opened in place (the copies are 86 MB a frame; if most of that memory is
openable) **and** the GPU reads the right bytes. Stop if the host refuses the
memory, or if only a small share qualifies.

## Phase 1 - hide the copies beside the render (no game change)

Uploads (copies up, textures) on a **copy queue**, fenced against the render
queue, so the 28 ms of copying happens while the card draws the previous
submission. This does not remove the price, it takes it off the frame's path -
and it is independent of Phase 0, so it can be done while the census is read.

**Gate.** The frame line's `copies` and `textures` should stop adding to the
frame: 126 ms -> ~100 ms with nothing else changed.

## Phase 2 - in-place for the ranges Phase 0 approved

The copies for those ranges disappear, the copy-back becomes "the card wrote
there", and `WHY_STALE` turns from "wait for a landing and a copy" into a
question of what the guards and the title's own writes do to the same pages.
This is the phase that changes the order of magnitude - and the one that has to
deal with the guard pages, the DirectStorage writes and the re-mapping the title
does at runtime.

**Gate.** The frame's `copies` row approaches zero and the copy-back too; then
the card's own time is what is left.

## Phase 3 - the command price (only if 2 lands)

The title emits ~4 000 commands a frame; a plain draw costs the card 1.36 us
(native) and an element of the indirect stream 10-21 us, because the layer
expands the stream itself. The windows halved that; the merge
(`VICTORY_INDIRECT_MERGE`) collapsed nothing, so the remaining lever is fewer
commands of our own: cached command templates per pipeline and state, or a
persistent indirect path whose per-element work is done once.

**Gate.** The per-command table's `indirect ... us a command` should approach
a draw's 1.36 us. If it cannot, 30 fps is off the table on this architecture and
~15 fps is the platform's ceiling for this title through an HLE layer.

## Not the plan, and why

- **Another language.** Nothing measured is CPU-side with a clear win left: the
  costs are kernel calls, driver calls, memcpy and the card. A rewrite in C++
  would move none of them.
- **Lower internal resolution.** Measured and refuted: the render-size poke
  breaks the picture, and pixels are not the cost (0.56 Mpx a draw, a normal
  deferred renderer; VRS helped nothing).
- **The shader emitter.** The census closed it: 1 269 812 of 2 596 542 descriptor
  loads are already scalar, the constants fold, and the rest are per-lane where
  the clamp is load-bearing.

## What "good" would look like

```
today          126 ms in the cutscene (card 29-58, copies 48, waiting 28)
after Phase 1   ~100 ms   (the copies beside the render)
after Phase 2    ~60 ms   (only the card's own time and the round trip left)
after Phase 3    ~40 ms   (30 fps) only if our commands cost what a draw costs
```
