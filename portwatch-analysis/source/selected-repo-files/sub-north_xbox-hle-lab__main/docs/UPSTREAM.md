# Upstream xcl — what moved, what we adopted

`ivall/xcl` moves quickly. This page records only the commits that matter to this lab and what we
carried over from them; upstream's `HANDOFF.md` is the changelog, and this page does not repeat it.

## Where we sit

| Role | Commit | Date | Note |
|---|---|---|---|
| Frozen lab baseline (`lab/nvidia-wave32-v2`) | `217ac85` | - | The 30/30 guest baseline. First-exe runs use this. |
| Upstream head we last built for the VM | `9add721` | 2026-11-23 | "Retail game bring-up" |
| Current public upstream head | `9add721` | 2026-11-23 | Previous head was `484dd57` |

`9add721` is upstream's **"Retail game bring-up"** commit. That title is the commit subject
(**reported**); everything below was read from that commit's tree and its `HANDOFF.md` entry
(**verified**).

## What upstream 9add721 contains

- **Placeholder `VirtualAlloc`** (`kernelx/placeholders.rs`) — reserves address space without
  backing it, so the title can split, replace and coalesce placeholders.
- **`XMemMapPhysicalPagesScatter`** — maps a caller-supplied list of physical page numbers to
  addresses, one 64 KiB page at a time.
- **Fence slot 12** (`d3d12x/fence_x.rs`) — the newer fence interface the retail title asks for.
- **`GetResourceAllocationInfo2`** (device #108) — per-resource `{offset, alignment, size}` plus the
  combined size and alignment.
- **1D and 3D `xg` layouts** (`xg.rs`) — texture layouts beyond 2D and arrays.
- **Physical pages** — page numbers are 4 KiB frames with step 16.

## What we contributed

- **0001 — `D3D12ConfigureVirtualMemoryX`** (patch `0001`): adds the console GPU virtual-memory
  entry point; applies to the baseline **and** current `main`.
- **0002 — `XMemVirtualAlloc`** (patch `0002`): baseline-only. Upstream now implements the same
  five-argument function with more behaviour, so do not apply it on `main`.
- Upstream now also answers the DirectStorage factory IID `62959d11-…`, so our local dstorage alias
  is a **stopgap only** — drop it rather than carry it forward.

Patch details and apply recipes: `patches/xcl/README.md`.

## How to follow upstream

```sh
git clone https://github.com/ivall/xcl
cd xcl
git fetch origin
git log --oneline -20
```

A clean patch application on current `main` may need a three-way merge:

```sh
git am -3 /path/to/0001-*.patch
```

`git am -3` is needed because the surrounding `d3d12x` code moves between releases.

## Caution

Upstream changes fast. Any patch published here may be superseded within hours, and a function we
stubbed may already exist upstream. Check the upstream file under `crates/xcl/src/hle/` before
applying anything, and never apply our patch over an upstream definition.
