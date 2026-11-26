<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/sentinel-lockup.png">
  <img src="assets/sentinel-lockup-inverted.png" alt="SentinelInteractive" width="340">
</picture>

# 0x52504639 Research Division

Research documentation, Project 0x52504639.

RPF9 archive research for GTA VI, plus the TTPF texture database that ships beside it. Notes, catalogues and small tooling. We work from a copy we own and publish no game assets, keys or extracted content.

## Status

**Container**

- [x] 64-byte header and every field mapped
- [x] Both 16-byte record tables and the trailer located
- [x] Payload confirmed as plain zlib
- [x] 4,330 headers catalogued
- [x] 2,090,676 streams indexed
- [x] GTA V NG cipher ruled out against the RPF9 tables
- [ ] Table cipher key
- [x] Exact cipher identity

**Content**

- [x] 2,067,172 bin streams in a local zstd store, 3.26x
- [x] 357,115 texture descriptors mapped through RDS5 and ETPF
- [x] BC7 and BC6H decode, with 88.91 percent of texel bytes reachable in software
- [x] 69,679 audio banks and 797 videos catalogued
- [x] 0DRPz tables grouped and strings counted
- [x] 2,281,720 entity records read from resource block maps
- [x] BCPack entropy layer identified
- [ ] BCPack surfaces decoded
- [ ] Animation clips
- [ ] Seamless map assembly

## Numbers

| Measure | Value |
| --- | ---: |
| RPF9 headers | 4,330 |
| Carved streams | 2,090,676 |
| Bin streams stored | 2,067,172 |
| Bin store size | 102.60 GiB |
| Texture descriptors | 357,115 |
| Texture chunks | 1,026,947 |
| Virtual texture bytes | 151.59 GB |
| Entity records | 2,281,720 |

Every figure is marked measured or derived in `data/counts.md`. Bin-store sizes are binary units: 102.60 GiB stored and 334.12 GiB raw, with exact byte counts in `data/catalog-summary.json`.

Localisation is counted, not dumped: 25,834 tables, 7,289,933 strings and 231,374,054 characters are reported as totals, and no string is published.

## Coverage

Every resource type is accounted for, not just the ones we can read.

- Index: 1,255,039 slots, 4,373 headers, 0 parse failures.
- Typed: 1,153,560 slots carry a verified type name from the engine's own enum table.
- Decoded end to end: 168,643 slots, the script type (746) and the standalone drawable type (167,897). The nested container layer is read in full as well (4,351 child archives).
- Partial: 982,775 slots, 22 named types with a verified container, root record or subset layer.
- Classified: 2,142 slots across 12 small types. No type word at all: 101,479.
- One row per type, with its report or `none`: [docs/coverage.md](docs/coverage.md).

## Documents

| File | Answers |
| --- | --- |
| `docs/rpf9-container.md` | Archive layout and header fields |
| `docs/ttpf-rds5-etpf.md` | RDS5 and ETPF structure, chunk addressing |
| `docs/bcpack-entropy.md` | BCPack entropy layer, coverage and what stays open |
| `docs/cipher-constraints.md` | What the table cipher is not, and what stays open |
| `docs/placement-resources.md` | Entities, props and grass in `0DRPz` |
| `docs/drpz-localisation.md` | `0DRPz` wrapper, table classifier, string counts |
| `docs/coverage.md` | Every type, its slots, and how much of it is decoded |
| `docs/content-inventory.md` | Content classes and reachable volume |
| `docs/open-questions.md` | Unknowns and what would resolve them |
| `data/counts.md` | All aggregates with status |
| `data/catalog-summary.json` | The same numbers for machines |

## Method

- Streams are carved on zlib and container signatures at 16-byte seeds, then classified and indexed with offset, sizes, kind and hash.
- Texture chunks come from the RDS5 chunk table and the ETPF descriptor table.
- Entity records come from each resource's own block map, which resolves virtual and physical pages inside the zlib stream.

None of that needs the archive directory, which is why the payload layer is complete while the table cipher is not.

## Snapshot

`.github/workflows/refresh.yml` runs weekly and on demand. It validates the JSON, checks that the documents exist, and writes `data/last-check.json` with the date and the commit. It cannot re-dump the game because a runner has no game files, so it dates and validates the snapshot rather than changing the numbers.

`scripts/publish.ps1` does a local refresh from a checkout: it copies the sanitized docs, runs the validator, and prints the git commands.

## Not in this repository

- Game assets, dialogue, path lists, model or texture names, content dumps.
- Keys, key material, or anything about recovering an executable.
- Viewer or site source.
- Comparisons with other projects.
- Download sources or instructions for obtaining the game.

## Licence

MIT, see `LICENSE`. `NOTICE.md` covers the research scope and the trademark position. GTA and Rockstar belong to their owners. This work is not affiliated with or endorsed by them.
