# Root cause analysis: black world frame

## Where the image goes black (run 19, frame 1,900)

1. **Scene input reaches the GPU.** An R8_UINT mask pass (render target 274) shows the
   port, cranes, terrain and buildings in correct perspective. Camera, transforms and
   at least one geometry path work.
2. **G-buffer is empty.** The colour/normal/material targets are a flat clear value:
   the main geometry passes did not write them.
3. **Lighting has nothing to light**, so composition is black; only the 2D title card
   (drawn after) appears.

So the break is between the mask pass and the G-buffer passes: the draws that fill the
G-buffer are dropped or produce no pixels.

## Leading cause (not yet proven)

The G-buffer is drawn mostly by mesh shaders. All of them are wave64 and VIctory runs
them as wave32 on NVIDIA without emulation, and the `LinearDepthSkin` family fails
translation ("scalar memory read as data"). Combined with the 1,400–1,800 dropped draws
per second, the most likely cause is that the G-buffer mesh/pixel shaders are either
untranslated (dropped) or run with wrong wave semantics (cull everything).

## Next proof step

Count, per pass of one frame, the draws submitted vs dropped and which shader hash
caused each drop; if the G-buffer passes are all drops, fix translation of the top
shader classes first. Under the 2026-11-24 rule, game runs are made by the user; the
agent works from logs and dumps the user provides, plus synthetic wave64 mesh-shader
tests in `hgt-gfxdiag`.

## Update (run 20)

Run 19's game build included an uncommitted mesh-shader emulation experiment.
It refused 469 mesh shaders ("an emulated wave operation outside uniform control
flow"), the largest drop class in that run; dropped mesh draws are the most
likely reason the G-buffer stayed empty. With the experiment set aside (run 20),
mesh refusals fell to 11, but the GPU was removed about frame 1,651 as the world
started drawing. The `wave64` check in `hgt-gfxdiag` proves the RTX 4070 Ti
gives 32-lane ballots where the console code expects 64 — see
`NVIDIA_WAVE64_COMPATIBILITY.md`. Next: mesh-stage two-half emulation, tested in
`hgt-gfxdiag` first, then one game run with DRED breadcrumbs.
