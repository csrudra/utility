# The work order (next sessions, in order)

Each task: what to change, what it must make the log say, and what to do if it
does not. Numbers are from the runs of 2026-11-25, in the opening cutscene.

## Task 1 - why stage 1 opens nothing (no game run needed)

`VICTORY_INPLACE=1` ran with no effect: no `in place ...` line, `copies` stayed
at 19.7 ms / 95.6 MB. The census had approved 294 MB of the title's buffers as
"private, committed whole (a part can be opened)".

Read `crates/victory-gpu/src/inplace.rs`, level 1: `level()`, the opening path
around lines 100-210, and the criteria it applies to a span. Compare with
`census_of` (what it counts as openable). Answer one question in a comment:
**which condition does a span the census approved fail at `open()`?**

**Acceptance**: the answer is written down (a comment or a note here). No code
change yet.

## Task 2 - in-place for the approved buffers (the phase 2a that pays)

Likely shape, to be confirmed by Task 1: open a heap over a span **when it is
first used**, keep it while the title does not re-map or guard those pages, and
take it down on the `REMAPPED` events the layer already collects for the texture
queue. The probe's numbers say a standing heap blocks the title's own
`decommit`/guard inside it (`decommit inside false`), and the level-2 probe test
killed the run at 00:17 by mapping over live title memory - so the teardown is
the work, not a detail.

**Acceptance**: `in place ...` lines appear; the frame line's `copies` falls from
95 MB toward the share of traffic the opened spans carry; no crash in ten
minutes of the cutscene; the picture unchanged.
**Rollback**: `VICTORY_INPLACE=0`.

## Task 3 - the copies beside the render (phase 1, independent)

Uploads (copies up and textures) on a copy queue, fenced against the render
queue, so ~28 ms of copying happens while the card draws the previous
submission. Does not depend on Task 2 and cannot be blocked by it.

**Acceptance**: the frame loses ~20-30 ms with `copies`/`textures` unchanged in
absolute terms - they moved off the frame's path, not away.
**Rollback**: a switch around the second queue.

## Task 4 - the texture invalidation (small, safe)

Three touches, as designed at the end of the 2026-11-25 session:
`Waiting` gets `print: u64`; `Waiting::changed()` keeps it; the pass checks it
before uploading a slot made due by a *memory* event (not a new view) and skips
when the fingerprint matches. Counter `remap_skipped=` on the `reuploaded=` line.
Switch `VICTORY_TEXTURE_REMAP_CHECK`, off by default.

**Acceptance**: `reuploaded=` falls from 54% (of uploads; 62% of bytes) toward
20-30%, `textures ... MB` in the frame line roughly halves, and no texture stays
stale in a streaming scene.
**Rollback**: `VICTORY_TEXTURE_REMAP_CHECK=0`.

## The order and why

1 then 2: the big prize, and 2 cannot be written before 1 says what blocks it.
3 beside them: independent, bounded, and the only certain 20-30 ms left.
4 last: smallest win, and the only one whose failure is *silent*.

## What not to do (measured, so nobody spends a night on it)

- switch permutations: three of tonight's changes were bets that the log then
  refused (`VICTORY_OPEN_COPIES=2` 13 ms/MB against 0.6; `MERGE_RUNS=8192` made
  the wait worse; `VICTORY_INDIRECT_MERGE=1` collapsed no commands but crashed
  once before it could be judged);
- the shader emitter (census: nothing left);
- another language (no measured article is CPU code with headroom);
- lowering the internal resolution (breaks the picture; pixels are not the cost).
