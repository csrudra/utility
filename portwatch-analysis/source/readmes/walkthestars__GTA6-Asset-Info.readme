# GTA6 Asset Info

Technical notes on the asset formats of **GTA VI (Xbox Series build)**:
how the archives, textures, models and map data are laid out, what is
understood, and what is still unknown.

Everything here was worked out from the data itself: headers, statistics
over many samples, and checking decoded output by eye. Nothing has been
confirmed against game code or official documentation. This repository holds
documentation only: no game files, no extracted assets, no keys. Read
[LEGAL.md](LEGAL.md).

## Formats

| Area | Pages |
|------|-------|
| Containers | [RPF9 archives](formats/01-rpf9.md) · [Resources and pages](formats/02-resources.md) |
| Textures | [Texture dictionaries](formats/03-texture-dictionaries.md) · [Xbox tiling](formats/04-xbox-tiling.md) · [`ttpf` stores](formats/05-ttpf.md) · [BCPack](formats/06-bcpack.md) |
| Models | [Drawables, fragments and vehicles](formats/07-models.md) |
| Map data | [Meta resources](formats/08-meta.md) · [Placements and batches](formats/09-placements.md) · [Interiors](formats/10-interiors.md) |
| World | [Collision](formats/13-collision.md) · [Navmesh](formats/14-navmesh.md) · [Lights](formats/15-lights.md) · [Road graph](formats/16-roads.md) |
| Materials | [Vehicle paint](formats/11-vehicle-paint.md) · [Material classes](formats/12-materials.md) |
| Other | [PSO, RBF, BVH4, audio, animation](formats/17-other.md) |

The [format index](formats/README.md) has the conventions. Every page gives
each field a confidence level and ends with its open questions.

## State of knowledge

As of **2026-11-20**, from one retail Xbox Series install. Other builds may
differ.

| Area | Understood | Not yet |
|------|-----------|---------|
| RPF9 archives | header layout; payload is plain zlib | the table of contents is encrypted, so there are no file names or paths |
| Resources | system/graphics pages, pointers, names inside resources | some unnamed resources |
| Textures | dictionary textures; Xbox tiling for BC formats; `ttpf` stores with AMD Gfx10 layouts (84.6 % of 352 K store textures readable) | **BCPack** (8.3 % of textures have no readable mip); 4-/2-byte layouts |
| Models | vertex streams, meshlet index buffers, LODs, skeletons, skinning (incl. u16 bone indices), shaders' texture references | shader and parameter names (unknown hash), constant buffers |
| Vehicles | parts, damage and mod-kit parts, wheel mounts | paint colour tables, wheel sizes, handling |
| Map data | self-describing meta resources; entities, LOD hierarchy, archetypes, grass and prop batches, interiors | prefab placement, some hashed fields |
| Collision | bounds geometry and primitives, surface ids; inferred surface categories for 98.3 % of area | surface names (unknown hash) |
| Navmesh | tiles, polygons, road flag | most other flags |
| Lights | position, colour, type, intensity, range, cones, hour mask | a few fields |
| Road graph | nodes, links, lanes, speed limits, 34 of 51 node flags, junctions, traffic-light phases | some link flags, street names |

## Biggest open problems

- **BCPack**, the Xbox Series hardware texture codec. The rANS coder and the
  stream layout are partly mapped; there is no decoder.
  [Details and how to resume](formats/06-bcpack.md#64-how-to-resume).
- **The name hash** used for shaders, shader parameters and collision
  surfaces is unknown.
- **The RPF9 TOC** is encrypted.
- **Vehicle data**: paint tables, wheel sizes and handling sit in PSO data
  with 64-bit field hashes.

## Conventions

- Offsets are hexadecimal, little-endian unless stated.
- Hashes are hex. Where a field or enum name is known, it is the
  case-sensitive joaat ("one-at-a-time") hash of that name.
- The game is RAGE Z-up, right-handed, metres. glTF output conventions are
  Y-up: `gltf(x, y, z) = rage(x, z, −y)`.
- Confidence: **confirmed** (holds over many samples, output checked by
  eye), **inferred** (consistent with the data, not proven), **unknown**.

## Tool notes

The [tool/](tool/README.md) folder documents the extractor these notes were
worked out with: its commands and the files it writes.

## Licence

GPL-3.0; see [LICENSE](LICENSE). This covers these notes only, not anything
from the game.
