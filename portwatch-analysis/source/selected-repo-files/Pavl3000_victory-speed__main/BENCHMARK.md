# Radeon runtime testing, 25 November 2026

The Windows diagnostics release at `e061c69032b84ec6e2ec17340469cd689500dafd` built with the pinned toolchain. It includes GPU readback changes from `6a4e2b1` and descriptor allocation changes from `e061c69`.

| Check | Result |
| --- | --- |
| GPU library tests on the D3D12 WARP software adapter | 163 passed, 0 failed, 3 ignored |
| Pixel shaders previously refused in the mission capture | All 11 translated, passed DXIL validation and produced test pipelines |
| Upstream repository asset-policy scan | 182 tracked files passed |

In a preliminary Chapter 1 City comparison, the old and new readback paths used the same checkpoint, shader cache and renderer settings. Across 93 matched indoor presents, frame rate was 3.52 and 4.05 FPS respectively. The 95th-percentile frame time was 432 and 352 ms. Two comparisons of the outdoor camera gave different results, ranging from an 18% loss to an 8% gain. The indoor figure currently has one run of the new build.

The City interior can render with an overexposed doorway and a silhouetted character. The ray-tracing structure builder is disabled by default. Whole-game shader coverage and correct indoor lighting remain open.

## Subsequent shader and pipeline checks

- Before the static sampler fix, the archive scan translated 25,702 shaders and refused 56. Offline tests of those 56 recovered 37 pixel shaders and three mesh shaders. All 40 passed Microsoft's DXIL validator. A synthetic shader run on WARP returned the expected texels for wrap and clamp across four alternating selections.
- A full archive run with the sampler change translated 25,742 of 25,758 shaders. A follow-up test recovered one more pixel shader used for voxel visibility. The corrected translator recognized both halves of a restored wave64 lane mask. Retesting all 56 original refusals produced 41 validated shaders and 15 remaining refusals. The visual effect in the City interior still needs a gameplay comparison.
- On an RX 7900 XTX the original windshield-wiper pipeline failed creation with blending enabled on an integer target. The corrected pipeline created successfully with the same shaders and framebuffer formats. The other active targets retained their blending state and all three write masks were preserved.
- A clean Windows installation built all three programs, resolved all static imports of the tested game executable, and executed a synthetic title through the Start-menu shortcut. Re-running setup preserved existing state.
