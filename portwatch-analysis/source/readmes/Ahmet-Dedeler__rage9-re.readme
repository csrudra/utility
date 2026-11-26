# rage9-re

Rust and Python tools for two RAGE9 archive types: `script.rpf` (script data) and `anim.rpf` (animations), with a glTF 2.0 exporter for decoded clips. Written from scratch from observed file structure; no game code or data is included.

<p align="center">
  <a href="https://discord.gg/CjcDBg3nf"><img src="https://img.shields.io/badge/Join%20the%20Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Join the Discord" height="36" /></a>
  <br />
  <sub>Questions, previews, bug reports and format research. Come say hi.</sub>
</p>

**License:** `MIT OR Apache-2.0`. You need your own copy of the game files to run the inspectors.

## What works

### `script.rpf`

- Scans the nested RPF9 (`9FPR`) containers and carves and stitches the 16-byte-aligned zlib streams (1,057 of 1,057 streams inflate).
- Parses `PSIN` (PSO v122) containers: `PSIN -> LSCH -> LENM -> LSNS -> LGID -> LRSC -> CHKS`. All 1,012 files parse.
- Rebuilds the compiled binary-XML script-data DOM (root struct `0xde396fe2`) and writes it out as XML or JSON.
- Walks the serialised object graph in the first sub-archive (30,683 records, 483 root trees) and resolves its `0x71717171`-tagged pointers.

### `anim.rpf`

- Parses `crClipDictionary -> crClip -> crAnimation -> crAnimSequence`.
- Decodes the channel classes seen in the archive: static quaternion / vector / float (0, 1, 2), per-frame quantized float (4), indexed quantized float (5), quaternion component reconstruction (7), quaternion normalization (8), and the 64-frame superblock 2nd-order zigzag delta curves (10).
- Exports a clip as `.glb` for viewing in Blender or any glTF viewer.

How it was checked: all 21,084 class-10 curves in the sampled windows land exactly on their superblock bit offsets and anchors. A sample exported clip moves smoothly, with a median rotation change of 0.85° per frame at 30 Hz.

## Known gaps

- The glTF exporter only maps a handful of named bones (`skel_root`, `skel_pelvis`, spine, hands, feet, `ik_*`, `ph_*`). The full skeleton hierarchy is not reconstructed yet.
- A small fraction of frames show large jumps (1% of steps over 20°), so some channel or quantization edge case is likely still wrong.
- `anim.rpf` is read in windows. Not every clip dictionary in the 4.4 GB archive has been decoded and checked.
- Field names in the DOM come from hashes; most are not resolved to readable names.

## Usage

```bash
cargo build --release
./target/release/rage9-re inspect-script /path/to/script.rpf --dump-xml 0 --dump-objgraph 0
./target/release/rage9-re inspect-anim /path/to/anim.rpf --export-glb out.glb
```

Python package: `python/rage9_re`.

## Tests

```bash
cargo test
python3 -m unittest discover -s tests -v
```

The tests use synthetic data built in the test files.

## Format notes

- [`docs/SCRIPT_FORMAT.md`](docs/SCRIPT_FORMAT.md): `script.rpf`, `PSIN`, the binary-XML DOM and the object graph.
- [`docs/ANIM_FORMAT.md`](docs/ANIM_FORMAT.md): `anim.rpf` and the `crAnimSequence` channel classes.

## Related projects

- [Percy6Stars](https://github.com/Ahmet-Dedeler/Percy6Stars): RPF9/TTPF archive explorer for macOS and Windows
- [awesome-gta6-reverse-engineering](https://github.com/Ahmet-Dedeler/awesome-gta6-reverse-engineering): every open-source GTA VI reverse engineering project in one list
- [bcpack-rs](https://github.com/Ahmet-Dedeler/bcpack-rs): clean-room decoder for Xbox Series BCPack textures
- [bink-player-mac](https://github.com/Ahmet-Dedeler/bink-player-mac): Bink 2 (`.bk2`) video player for macOS
- [weather-study](https://github.com/Ahmet-Dedeler/weather-study): WebGL2 weather and timecycle visualizer

Questions, previews and format research: [join the Discord](https://discord.gg/CjcDBg3nf).
