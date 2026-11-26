# The performance log

A condenser of this fork's own runs: what the log said, what it meant, what
changed, and what the next run then said. The numbers are from one machine
(Ryzen 9 9950X3D, RTX 3080 Ti 12 GB, 32 GB) on 2026-11-25, in the opening
cutscene unless said otherwise - the cutscene because it is the same spot every
time, which is what makes one number comparable with another.

The point of writing it down: **every second entry here is a conclusion that
turned out to be wrong, and the number that killed it.** That is the part worth
copying.

## The starting point

```
4.6 fps, 219.0 ms a frame
  preparing        68.4 ms  (copies 37.5 ms / 148.7 MB, textures 12.0 ms / 63.3 MB)
  on the GPU      107.2 ms
  copying back    124.4 ms / 62.1 MB
  3 859 draws a frame, 161 dropped (no host pipeline)
  heap buffers 1.0 passes 54.5 ms
  textures: 144 484 uploaded so far = 64 GB, 11 218 waiting
```

Three buckets, 274 MB moved a frame against a 33 MB 4K frame, and the two
obvious suspects: the copy-back and the texture pass.

## 1. The copy-back is a thread, not a row of the budget

**Measured.** The relay line split the copy-back:

```
the relay per frame: waited 9.8-42.8 ms for the card with nothing to land,
  73.6-272.5 ms for fetches of card copies' pieces, was 89.3-289.6 ms landing
```

**Read.** The submitting thread waits for the copy-back at exactly one point -
the present - and that point measured `0.0 ms`. So the 124 ms "copying back"
never was part of the 219 ms frame: it is another thread's time, overlapping.

**Wrong conclusion drawn from it (kept here on purpose).** The same log line
`settled for: ... title memory changed under shader writes 73.7` was read as
milliseconds, and it is *counts per frame*. The millisecond counterpart is the
line after it, which says 73.7 ms of waiting - for a reason the counts could not
name. Two days of theory were built on that misreading.

## 2. The fetch waits go away, the frame does not

**Changed.** `VICTORY_CARD_FETCH_INFLIGHT=1` (`..._MB=128`): the pieces a
flight's compare flags are fetched inside the flight instead of by a fetch list
behind the queue.

**Measured after.**
```
waited 0.0 ms for fetches (was 73.6-272.5); landing 22.9-32.5 ms (was 89.3-289.6)
frame: unchanged (290-800 ms in that spot, 1.2-3.4 fps)
```
**Read.** The switch does exactly what it says and buys nothing, because the
thread it speeds up was never on the frame's path. It stays on - it is free -
but it moved the needle not at all.

## 3. The per-command table: where the card's 99 ms actually is

**Measured** (diagnostics build, `VICTORY_GPU_TIMING=1 VICTORY_D3D12_DRED=1
VICTORY_SLOW_LIST_MS=200`), 6 288 draws a frame:

```
all 2259 kinds together: 98.6 ms a frame
  indirect 53.2 ms in 2691   (19.8 us a command)
  dispatch 29.6 ms in  796
  texture   6.2 ms in 1367   (4.5 us)
  draw      6.1 ms in 4500   (1.36 us a command)   <- native-level
  alias     2.5 ms in   84
```

**Read.** Not "per-command overhead everywhere": a plain draw is as cheap as on
any PC game. The title's indirect stream is expanded into one host command a
record and costs 15x a draw. And the dispatches are mostly one title compute
pass of 10.9-16.9 ms plus *our own* clamps.

**Wrong bet #1.** Opening memory ranges instead of the kernel's write
(`VICTORY_OPEN_COPIES=2`) plus a raised merge cap (`MERGE_RUNS=8192`): 13 ms a
MB against 0.6, `write_syscalls=0`, 223 130 calls moving 10.5 GB, and the wait
*worse* (108-110 ms against 73.7). Both reverted within the hour.

**Wrong bet #2.** The shader emitter as the next big thing. The offline census
said: of 2 596 542 descriptor loads, 1 269 812 are already `scalar` (one a wave,
not a pixel), 174 561 are constants that fold, and the rest are per-lane where
the clamp is what keeps the index inside the heap. Nearly nothing left to win
there - the command stream, not the shader bodies, is where the time is.

## 4. The indirect stream: half of it, twice

**Changed.** `VICTORY_INDIRECT_WINDOW=1`: a run of the title's records is
clamped once into a scratch buffer, so each host command reads its record
instead of re-clamping it.

**Measured after.** 19.8 us a command became **8.4-10 us**; the GPU total of the
slice 98.6 -> ~72 ms; in the world `indirect 26.4 ms in 1 234` (was 53.2 in
2 691).

**Read.** Half the article, and the command *count* is unchanged - one
`ExecuteIndirect` a call, ~8 us each. The other half needs one command per run
(`VICTORY_INDIRECT_MERGE=1`), which is written but crashed once: a clamp
overwrote the scratch buffer of a run that had not been drawn yet. Fixed
(`0b07e0d`) and not yet run again.

## 5. Our own clamps were the dispatches

**Changed.** The window's first size became a switch, then 64
(`VICTORY_INDIRECT_WINDOW_RECORDS`).

**Measured after.**
```
our clamps of the title's indirect arguments per frame: 501, over 17.0 records each
                                                     ->  46, over 64.0 records each
```
**Read.** We were clamping 8 500 records a frame where the title asked for
1 234, one compute dispatch each. A switch, no rebuild, 11x fewer dispatches -
and the card's time in the cutscene 53 -> **29 ms**.

## 6. The texture pass was allowed to eat the frame

**Measured.** The pass over textures picked by index: 246-420 ms a frame,
250 MB, the oldest slot waiting 744 frames. Its budget with `CATCHUP` was 96 MB
x3 and 250 ms x3.

**Changed.** `VICTORY_TEXTURE_CATCHUP=0`, `VICTORY_TEXTURE_STAGE_MS=100`.

**Measured after.** 32.1 ms, 29.5 MB a frame. The frame did not move, and that
was the useful part: `196.4 = 57.6 preparing + 99.0 the card + 32.1 the pass`.
The CPU's own work was no longer the wall - the card was.

**Also measured there:** of the uploads, 54% were of a span already uploaded,
62% of the bytes; and of those, 54% "their memory moved" (a remap made a slot
due again with the same view and bytes), 31% "more of it mapped", 16% "filled
after its upload". So the title streams a lot and the invalidation re-queues
too eagerly - the second half was never fixed.

## 7. Four bytes a kernel call

**Measured** (a counter added for it):
```
what shaders wrote into title memory per frame, by the path that did it:
  the CPU's compare back 250236 calls 1.0 MB, the card's merge 1203 calls 63.6 MB
```
**Changed.** `VICTORY_BACK_GAP=16`: the runs of what shaders wrote and the title
did not are joined over small gaps before they go back (the gap's bytes are the
title's own as read a moment before, so the price is upstream #2009's race over
16 bytes and one call).

**Measured after.** `write_calls=170812` over 1 024 frames = **167 a frame**
(was 250 236), 7.4 MB a frame instead of 1.0.

## 8. The resets: `keep` without a set

**Measured.** `lists reset in 32.9 ms (17.3 deferred, 5.9 allocator, 5.5 command
list, 1.9 notes, 0.7 maps, 0.1 scratch)` - the 129.8 ms first reported was the
diagnostics build's own bookkeeping.

**Read from the code.** `HostList::keep` pushed every object it was given with
no set behind it, and it is called on every heap bind and by every texture that
goes through a staging buffer: one list held thousands of `AddRef`s of the same
two objects and released them all at the reset.

**Changed.** A set of the interface pointers kept; one object, one entry.

## Where it ended

```
cutscene    5.1 fps / 196 ms  ->  8-10 fps / 101-129 ms
the card    99 ms             ->  29 ms
heavy spot  4 900 draws: 5.7 fps / 176 ms, of which 110 ms is the card
```

What is left is not bookkeeping: `preparing 53 ms` (copies 27.5 ms / 117.9 MB at
4.3 GB/s - the title's own memory, nothing to shave), `the card 29 ms`, `copying
back 18 ms`, and ~28 ms of waiting at `WHY_STALE` - the next frame reading what
the previous frame's shaders wrote, the one thing a console does not pay.

## The rules this session wrote for itself

1. Read one number, change one thing, read the same number again.
2. A line that says "0.0" is worth checking against its unit before a theory is
   built on it.
3. A thread that is busy is not the frame. Find where the *submitting* thread
   waits.
4. Nothing that cannot be turned off without a rebuild goes in.
5. If a change cannot be measured by a line already in the log, add the line
   first.

