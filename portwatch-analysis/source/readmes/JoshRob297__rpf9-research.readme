# rpf9-research

**English** · [Español](README.es.md)

Reverse engineering of the **RPF9** container used by GTA VI (Xbox Series X|S), from a 209 GiB
package holding 22 `.rpf` archives and 57 `.ttpf` files.

## What is known before starting

- The magic is `39 46 50 52` in the first four bytes: `RPF9` read as a little-endian integer.
  GTA V uses `RPF7` (`37 46 50 52`).
- The bytes right after the magic are neither text nor a readable table: the region behind them
  looks encrypted (high entropy, no plain-text names in the first 2 MB).
- In GTA V the RPF7 table of contents is AES-encrypted and public tools (OpenIV, CodeWalker)
  know that key. For RPF9 there is no public tool.

## Goal

Determine, with reproducible evidence, **the layout of the header and the table of contents** of
RPF9, and how far one can get without the key. The expected output is a document
(`docs/RPF9.md`) plus a prototype (`tools/rpf9.py`) that:

1. reads the header and explains each field with its measurement,
2. states whether the TOC is encrypted and on what evidence (not by assumption),
3. lists entries if it manages to decrypt it, or explains exactly what is missing.

## What this repository does not contain

No game files, no game code, no extracted assets, no lists of asset names. Every number here is a
measurement of a format; the evidence under `raw/` is either a header slice of a few hundred bytes
per container (the geometry claim needs it) or the output of our own tools.

Concretely, this repository has never contained:

```
.rpf or .ttpf payloads        no container bytes beyond 64-byte headers
executables or libraries      no binaries from any build
asset names                   no path list; only salted hashes and a 200-path sample
decompiled code               none, from any file
```

If a future contribution would add any of those, it does not belong here.

## Repository rules

- **Every number in the documentation needs its transcript in `raw/`.** Nothing is claimed that
  has not been measured.
- Anything that cannot be determined is written as **undetermined**, together with the test that
  was attempted and failed.
- `raw/` holds the command output exactly as produced. Those transcripts are in Spanish because
  that is the language the commands were run in; they are evidence and are not translated.
- Sample binaries are **not versioned** (see `.gitignore`); only their manifest with hashes is.
- Documentation ships in pairs: `README.md` (English) and `README.es.md` (Spanish); likewise
  `docs/RPF9.md`, `docs/NAMES.md`, `docs/INDEX.md`, `docs/NESTED.md`, `docs/PSIN.md` and
  `docs/COMPARATIVA.md` with their `.es.md` counterparts.

See `METHODOLOGY.md`.

## What the scan produced

A full pass over the 22 archives — 150.2 GiB, 92 slices — recovered **215,028 named streams (9.62%)**,
**168,660 unique paths** and **511,526 unique identifiers**. Coverage is 100% for shaders and 1.03%
for `0DRP` containers. The last 27.2 GiB were read separately and are documented in `docs/INDEX.md`
along with the negative results.

The full path index is not published: it is the game's asset manifest, not the format. The repo
ships the tools, the counts and salted hashes so anyone can diff their own run against ours.

## Merging indexes from different sources

`tools/merge_index.py` still accepts the historical form, unchanged:

```sh
tools/merge_index.py <chunks_dir> <output_dir> --skip packs_1.json,packs_2.json,packs_3.json
```

The multi-source form requires every origin to declare its type; the merger does not guess it:

```sh
tools/merge_index.py <output_dir> \
    --source name_recover=<dir_or_json> \
    --source paths=<names.txt|names.json> \
    --source inventory-tsv=<inventory.tsv> \
    --source inventory-csv=<inventory.csv> \
    --source hashes=<paths.sha256>
```

| type | input | contributes |
|---|---|---|
| `name_recover` | JSON from `tools/name_recover.py` | streams, paths, identifiers and offsets |
| `paths` | one path per line, or `{"paths": [...]}` | paths without offset or size |
| `inventory-tsv` / `inventory-csv` | `archive, offset, path` (`offset` decimal or `0x...`) | paths with archive and absolute offset |
| `hashes` | salted `sha256` list like `raw/paths.sha256` | coverage comparison only; never merges |

Conflicts are resolved in this order, which is also written to `report.json`:

1. A path recovered literally from the payload (mount XML) beats any pattern-derived version
   when they disagree on the offset.
2. The same path, container, offset and size merge into one entry without a mark.
3. The same path and container with a different offset, or the same offset with a different
   size, become a `conflict` entry with every version and the reason. Nothing is chosen.
4. Two different paths with the same hash become a `collision`.
5. An entry without a path but with an identifier becomes an `orphan`.

A discrepancy resolved by rule 1 is still written to `conflict` with `resolution: literal`;
only `unresolved` entries keep more than one version in `index.tsv`.

`streams.tsv`, `paths.tsv` and `ids.tsv` keep their previous meaning: the mention log of the
`name_recover` sources, so the counts in `docs/INDEX.md` still reproduce. `index.tsv` is the
normalized path index (one row per version, `estado=conflict` when unresolved) and
`report.json` holds the `conflict`, `collision`, `orphan` and `unrecognized` lists plus the
per-source counts. `--skip` still drops files by name.

## From a path to the bytes

`tools/resolve_path.py` closes the loop between the index and the files: given a path from the
manifest it returns the asset itself.

```sh
tools/resolve_path.py --index <idx> --containers <dir> --path "<path>" --out asset.bin
tools/resolve_path.py --index <idx> --containers <dir> --verify 200 --rpf data
```

It seeks instead of loading the container, decides compression by the first byte (`0x78` is zlib,
anything else is raw), and checks the result against the `inflated` size the sweep recorded. The
errors carry stable reasons (`path_not_found`, `container_missing`, `inflate_failed`,
`size_mismatch`) so a caller can branch on the cause. `--verify` is seeded, so two runs of the same
version differ only if the data differs.

Measured on `data.rpf` (481 MB, 28,509 streams, 4,639 paths): `--verify 200` resolved 200 of 200,
and a full pass over 2,295 paths / 4,704 mentions failed zero times, every result measuring exactly
the size in the index. Details and limits in `docs/RESOLVER.md`.

This matters because the TOC of these containers is encrypted: a port cannot ask the archive for a
file by name the way the original engine did. The index plus this resolver is that missing layer.

## Documents

| document | what it measures |
|---|---|
| `docs/INDEX.md` | per-archive, per-type and per-container name coverage, with the negative results |
| `docs/RPF9.md` | container header, table region geometry (9 or 10 byte stride, 16-byte padding) |
| `docs/NAMES.md` | where names come from, and the confidence taxonomy |
| `docs/PSIN.md` | the PSIN chunk chain, measured on retail streams |
| `docs/NESTED.md` | nested containers and how they are found |
| `docs/TEXTURES.md` | the `.ttpf` / BCPack payload shape |
| `docs/AUDIO.md` | audio streams at offset zero, and why there is no container magic |
| `docs/COMPARATIVA.md` | our measurements next to three public RPF9 implementations |
| `docs/RESOLVER.md` | path to bytes, and the limits of doing it from an index |
| `docs/INDEX-SQLITE.md` | the same merge through SQLite, as an independent check |
| `docs/DETECCION.md` | the Antigravity plugin against its own CLI, with one measured rule |

## Related projects and what this data answers

This repository measures one retail package. These projects consume the same format, and each one
needs a different part of what is published here.

| project | what it does | what this repo answers |
|---|---|---|
| [ItsNotRexed/Leonida](https://github.com/ItsNotRexed/Leonida) | native PC recompilation of the Xbox build | per-archive and per-type name coverage (`docs/INDEX.md`), 168k salted hashes to diff against its own walker, and the resolver a loader can call |
| [penwin2000/open-vfs](https://github.com/penwin2000/open-vfs) | virtual filesystem for the containers | 22 header fixtures in five formats (`raw/cabeceras/`) and the table-region formula, measured on 22 of 22 |
| [ivall/xcl](https://github.com/ivall/xcl) | compatibility layer, RDNA2 shaders to DXIL | 25,043 `sgd5_shader_dxbc` streams, 100% of them named, against the 24,064 and 26,503 figures published elsewhere |
| [R0Y00/Xbox2Windows](https://github.com/R0Y00/Xbox2Windows) | static recompilation research | where texture-bearing streams live per archive, as counts, without names |
| [omonkeyz/xbox-emulator](https://github.com/omonkeyz/xbox-emulator) | progress notes for running the builds | the container map, so the notes can point at offsets instead of file names |

The rule is the same for all of them: measured facts and geometry, never the asset manifest.

`docs/COMPARATIVA.md` puts our measurements of PSIN, nested containers and table geometry next to
three public RPF9 implementations (`rpf9-extract`, `PercyStar`, `rpf9`), read but never run, with a
`[verified]`/`[hypothesis]` tag on every claim.

## License

GPL-3.0-or-later.

The reason is practical: the closest reference work, `ItsNotRexed/Leonida`, is GPL-3.0 and
publishes measured format facts about this same package. Facts can be taken with attribution,
but if code is ever reused, this is the only license that allows it without conflict. Projects
under GPL-2.0-only (`xcl`, `americas-recomp`) and non-commercial licenses (`PercyStar`) remain
reading references, never a source of code.

See also `docs/` for the measured state of the format.
