# BK2toMP4

Convert Bink 2 (`.bk2`) video files to `.mp4` in batch on Windows, with a small
companion script to carve Bink streams out of `RPF9` archives when the
directory table is encrypted.

Two scripts, no build step, pure Python standard library. Tested on Windows 11.

```
bk2_to_mp4.py    Batch convert *.bk2 to *.mp4 via RAD Video Tools (silent).
extract_bink.py  Carve Bink streams out of an RPF9 archive (optional).
```

---

## Legal

These scripts process files you already have. **Bring your own input.** Do not
use this repo to distribute, trade, or redistribute copyrighted content. No
third-party media or game data is included here and none should ever be
committed to a fork of this repo. The `.gitignore` excludes common media and
archive extensions, but check what you stage.

The Bink codec is proprietary and owned by [RAD Game Tools](https://www.radgametools.com/)
(part of Epic Games). `bk2_to_mp4.py` drives their free RAD Video Tools, which
you install yourself. This repo does not ship or redistribute any part of Bink.

---

## Requirements

| Script | OS | Dependencies |
|---|---|---|
| `extract_bink.py` | Any (tested on Windows) | Python 3.10+ (stdlib only — no `pip install`) |
| `bk2_to_mp4.py`   | Windows 10 / 11 (tested on 11) | Python 3.10+ **and** [RAD Video Tools](https://www.radgametools.com/down/Bink/RADTools.exe) |

RAD Video Tools is a free ~1.3 MB installer signed by Epic Games Inc. Install
with defaults — the converter expects it at `C:\Program Files (x86)\RADVideo\radvideo64.exe`.
If you install it somewhere else, pass `--rad "C:\path\to\radvideo64.exe"`
when running `bk2_to_mp4.py`.

---

## Install

```powershell
git clone <this-repo-url>
cd BK2toMP4

# 1. Install Python 3.10+ (python.org or the Microsoft Store)
# 2. Install RAD Video Tools (only if you want the MP4 conversion step)
#    https://www.radgametools.com/down/Bink/RADTools.exe
# 3. Run
python bk2_to_mp4.py
```

Nothing else to install — no `pip install`, no build step, no virtualenv.

---

## Usage

### bk2_to_mp4.py — batch convert .bk2 to .mp4

Double-click the file, or run it with no arguments for an interactive menu:

```powershell
python bk2_to_mp4.py
```

Or drive it from the command line:

```powershell
python bk2_to_mp4.py <input_dir> [output_dir] [--recursive] [--workers N] [--dry-run] [--rad PATH]
```

| flag | meaning |
|---|---|
| `<input_dir>` | folder containing `*.bk2` files |
| `[output_dir]` | where to write `*.mp4`. Default: `<input_dir>` itself on the command line; the menu suggests `<input_dir>_mp4` |
| `--recursive` | descend into subdirectories |
| `--workers N` | conversions to run at the same time (default 1). More uses more CPU and memory |
| `--dry-run` | list files; in a terminal, then asks whether to convert |
| `--rad PATH` | override the path to `radvideo64.exe` |

The script:

- **converts straight to MP4** (H.264 + AAC), with no AVI in between;
- **stays out of your way**: RAD runs on a separate invisible Windows desktop,
  so its windows can't appear on screen or take keyboard focus;
- **resumes**: files whose `.mp4` already exists are skipped;
- **leaves no half-files under the final name**: it writes to
  `<name>.<random>.tmp.mp4` and renames on success;
- **pads odd sizes**: H.264 needs an even width and height, so an odd one gets
  a single black row or column (for example 1635×720 becomes 1636×720);
- **picks the first audio track by its ID**, which isn't always 0;
- **fails fast**: a RAD error box fails that file and the batch moves on. The
  exit code is 1 if any file failed.

#### Limitations

- Each MP4 holds only the **first audio track** of a multi-track file.
- Only `.bk2` files are picked up, not Bink 1 `.bik`.
- A run that is force-killed can leave a `*.tmp.mp4` behind. It is incomplete
  and safe to delete once nothing is converting.

### extract_bink.py — carve Bink streams from an RPF9

For `RPF9` archives whose directory table is encrypted, but whose Bink streams
are stored as plain data. It doesn't decrypt anything.

```powershell
python extract_bink.py <input.rpf> <output_dir>
python extract_bink.py <input.rpf> --list
```

Produces files named `clip_<index>_at_<offset_hex>.bk2` (and `.bik` for Bink 1).

Each stream is validated before it is written: dimensions and frame rate are
range-checked, and the frame index table must increase steadily and end at
exactly the file length.

#### Limitations

- It is meant for archives made up of **consecutive Bink streams**. It starts
  right after the archive metadata and stops at the first data that is neither
  Bink nor zero padding, so it won't find videos mixed in with other assets.
- Original file names are not recovered.
- It reads at most 64 MB of headers and index tables per archive, so a very
  large archive may be listed only partly.

---

## Example workflow

```powershell
# 1. Extract all Bink streams from your own RPF9 archive
python extract_bink.py "D:\path\to\your_archive.rpf" "D:\out\clips_bk2"

# 2. Convert them to MP4 (H.264 + AAC via RAD's BinkConv)
python bk2_to_mp4.py "D:\out\clips_bk2" "D:\out\clips_mp4"
```

Expect the MP4s to be about 4 times the size of the `.bk2` files. Clips with
no audio tracks become video-only MP4s.

---

## Credits

- The Bink-recovery algorithm in `extract_bink.py` is a Python port of the C#
  implementation in
  [breadbbbb/rpf9-explorer](https://github.com/breadbbbb/rpf9-explorer)
  (`Core/Rpf9MediaRecovery.cs`). Credit for the heuristics belongs there.
- The MP4 conversion is done by [RAD Video Tools](https://www.radgametools.com/)
  via its `BinkConv` command. This repo does not ship, link, or distribute any
  RAD code.

---

## License

[MIT](LICENSE) covers `bk2_to_mp4.py` and this documentation.

It does **not** cover `extract_bink.py`: that file is derived from
rpf9-explorer, which publishes no license for its code, so no permission to
reuse it can be granted here. Bink Video and RAD Video Tools have their own
licenses.
