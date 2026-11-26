# gta6

Tools and reverse-engineering notes for **GTA VI** (current focus: the Xbox Series
install layout). This repository is dedicated to **clean-room** tooling: the RPF9
reader/extractor is written from observed file behaviour and format analysis, not
derived from any existing extractor. The reader lives in the native Rust crate under
`rpfkit/` (AES-NI + multithreaded, with Python bindings); the `gta6/` Python package is
a thin CLI over it.

Game files and extracted output stay **outside** this repository. Paths come from
`.env` (see `.env.example`). No game data, keys, or extraction output is committed.

## Setup

```powershell
cd D:\code\gta6
python -m venv .venv
.\.venv\Scripts\pip install -e ".[dev]"
copy .env.example .env
# edit .env if your game or artifact root differs
```

The `gta6` package itself only needs `python-dotenv`. The AES and disassembly work is
done natively in `rpfkit/`, so there are no Python crypto/disasm extras to install.

### Native `rpfkit` module

The `gta6` commands run through the native Rust core, built separately with
[maturin](https://www.maturin.rs):

```powershell
cd rpfkit
python -m maturin develop --release   # installs the `rpfkit` module into the active venv
```

The native module is required for the info/extract commands; they report a clear error
if it is missing.

## Paths

```powershell
python -m gta6 paths
```

Default artifact tree (created on demand):

- `GTA6_ARTIFACT_ROOT/extractions/` — RPF extract output
- `GTA6_ARTIFACT_ROOT/manifests/` — JSON logs per extraction
- `GTA6_ARTIFACT_ROOT/note-attachments/` — blobs linked from notes

## Inventory

```powershell
python -m gta6 inventory --scripts-only
```

## Extraction

Extraction runs through the native `rpfkit` reader (see above). Xbox builds use
**RPF9** (magic `0x52504639`): the reader parses the container, entry table and name
table, decrypts the file tables with the whitened AES-256-CBC cipher, and inflates the
(cleartext) data region.

```powershell
python -m gta6 rpf-info      pack\story000\story000_script.rpf
python -m gta6 extract-rpf   pack\story000\story000_script.rpf
python -m gta6 extract-install
python -m gta6 rpf9-extract  pack\story000\story000_script.rpf
python -m gta6 extract-scripts
```

`extract-rpf` / `extract-install` / `rpf9-extract` all use the native reader;
`extract-install` defaults to every `*script*.rpf` under the game root. The key-context
blob is recovered from the game executable (`GTA6_GAME_EXE`, default
`game_scarlett_master.exe` under the game root). A raw key (the earlier ECB hypothesis)
can also be supplied via `GTA6_AES_KEY_HEX` / `GTA6_AES_KEY_FILE`; when both are present
the whitened cipher is tried first.

`extract-scripts` writes every `*script*.rpf` into `GTA6_RPF_OUTPUT_ROOT` (default
`D:\data\gta6\rpf`). While the TOC/names tables are still encrypted (the whitening byte
orderings are unpinned), a normal extract is `blocked`, so this falls back to a
**key-free raw-data dump**: the cleartext data region is carved into individual
raw-deflate streams (`<archive-stem>/data.NNNN.bin`) so the script content can be
explored now. Pass `--raw` to copy the region verbatim instead. When the TOC *is*
readable, the proper directory tree is extracted instead.

Structural validation (header self-consistency, region bounds, entry-table coherence,
and that the data region inflates) lives in the native reader — run it with
`rpfkit validate <archive>` (or `cargo run -p rpfkit --release -- validate <archive>`).
It does not match any build-specific bytes, so it stays valid across builds and the
production release.

The TOC and name tables are **encrypted** on this retail layout. Until the whitening
byte orderings are pinned by a dynamic trace, real archives report `blocked`
(`wrong_aes_key_or_cipher`) rather than extracting — the names-plausibility oracle is
the acceptance gate, so an unproven cipher model degrades to `wrong_key` instead of
producing garbage.

## Key recovery

The archive cipher is a table-driven **AES-256 with input/output whitening in CBC
mode**, driven by a precomputed key-context blob the game keeps in its image. The
blob's *address* is build-specific, so it is recovered from the executable rather
than hard-coded. This recovery lives in the native reader and runs automatically when
you list or extract an archive (the exe is read from `GTA6_GAME_EXE`). To inspect it
directly:

```powershell
rpfkit recover-keyctx game_scarlett_master.exe
# or: cargo run -p rpfkit --release -- recover-keyctx game_scarlett_master.exe
```

It locates the blob by scanning for the provider descriptor getter and validating the
registry structurally (the blob length is derived from the data). No key bytes or
absolute addresses are stored in this repo — they are read from the exe at run time.

The earlier known-plaintext key sweep (which used a build-specific template as an
oracle) was part of the Python research layer that has since been dropped; it is
preserved in the git history if needed again.

## Offline run helper

```powershell
# native (rpfkit CLI)
cargo run -p rpfkit --release -- net-offline -- --timeout 600
# or, once built, the standalone binary:
rpfkit net-offline -- --timeout 600
```

Blocks all outbound traffic for the game executable (Windows Firewall rules via
`netsh advfirewall`, with UAC self-elevation), launches it, and waits for it to exit —
used to observe the game's behaviour with no network access. This is the native port of
the former `python -m gta6 net-offline`; the Win32 calls (elevation check, `ShellExecuteExW`
relaunch, process wait) go through the `windows` crate directly.

## Research notes

A publishable summary of the RPF9 findings lives in
[docs/rpf9-research.md](docs/rpf9-research.md) - container layout, structural
validation, the known-plaintext key-recovery model, what was ruled out, and the
key-recovery method, described without build-specific constants.

The day-to-day working notes under docs/notes/ are kept local and **not**
published, because they quote build-specific static addresses, Ghidra symbols, and
raw key/template bytes lifted from the proprietary executable.

### What is known (summary)

- **Container:** a file may hold several concatenated RPF9 archives ("bases"),
  found by scanning for the magic. Each base is a 32-byte header, an encrypted
  `TOC || names` blob, then a **cleartext** data region of raw-deflate streams.
- **Data region is cleartext**, so file *content* extraction does not need the key;
  only the TOC/name tables do.
- **Known plaintext (key-recovery aid):** within one build the TOC blob has a fixed
  48-byte region at a constant offset, plus (in some archives) long all-zero name
  runs — enough guaranteed plaintext to reject wrong keys. These bytes are
  build-specific and not committed; they feed the key sweep, not the validity check.
- **Validity is structural:** the native `rpfkit validate` confirms an archive is
  well-formed from its header, region bounds, entry table and inflate behaviour — no
  byte matching, so it holds across builds.
- **Ruled out:** plain AES-256-ECB of the whole blob, a single global keystream, and
  simple header-derived keys.
- **Identified:** whitened AES-256-CBC (above). Key recovery is the remaining step.

## Layout

```text
rpfkit/            native Rust RPF9 reader + CLI (info/list/extract/validate/
                   dump-data/recover-keyctx/net-offline) + pyo3 bindings (maturin)
gta6/
  config.py        .env path resolution (incl. GTA6_RPF_OUTPUT_ROOT)
  extract.py       extraction via the native rpfkit core (incl. extract_scripts)
  rpfkit_native.py import bridge to the native module
  cli.py           `python -m gta6 ...` entry point
tests/             unit tests (synthetic fixtures; no game data)
docs/notes/        local research notes (gitignored)
tools/             one-off probe scripts (gitignored)
```

## License

Apache-2.0. See `LICENSE`. Game assets and the executable are trademarks/copyright
of their respective owners and are **not** included in this repository.
