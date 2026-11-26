# ztrx PS5 save importer

Load a **decrypted PS5 GTA VI story save** in the **Xbox Series build running under
[ztrx](https://github.com/Zettrox/ztrx)** on PC.

This repo contains **no game files, no saves and no keys**. You need your own copy of the
game, a working ztrx build, and a PS5 save that a PS5 save tool has already decrypted.

## How it works (short)

- PS5 and Xbox saves share one format: an `ASAV` header + LZ4-packed `JSAV` data
  (a JSON document of hashed save blocks). Only the header and the encryption differ.
- The game only encrypts story saves when one function (`0x28d0d60`) says so.
  `ztrx-save-patch.diff` adds a `VICTORY_PATCH` option to ztrx, and the launcher uses it
  to make that function answer "no" **in memory**. Your game files are never modified.
- The importer wraps the PS5 data in an Xbox header, LZ4-packs it and writes all three
  checksums (signed-byte Jenkins one-at-a-time; header seed `0x4bf672ed`).

## Setup (once)

You need: ztrx built (`cargo build --release -p victory`), [Node.js](https://nodejs.org), Git.

1. **Patch ztrx.** In your ztrx folder:
   ```powershell
   git apply C:\path\to\this-repo\ztrx-save-patch.diff
   cargo build --release -p victory
   ```
2. **Add the launcher.** Copy `Play-GTA6-SaveMod.bat` into your ztrx folder (next to
   `Cargo.toml`). Edit the `GAME=` line to point at your `game_scarlett_master.exe`.
3. **Run the game once** with `Play-GTA6-SaveMod.bat` until the main menu, then quit.
   This makes ztrx create its saves folder.

## Import a save

Drag the decrypted PS5 save (the `.zip` from your PS5 save tool, or its folder) onto
**`Import-PS5Save.bat`**. Then start the game with `Play-GTA6-SaveMod.bat`. It boots
into the imported save (also listed under *Pause > Load Game*).

The importer:
- finds the decrypted story file (the one whose first 4 bytes are `JSAV`, usually named
  `SARC0001`); encrypted saves are refused with a message,
- installs it as the next free `SARCnnnn` slot, never overwriting a save,
- moves your other story saves to `<data>\save-backups\` so the game loads the new one.

### Example save

`examples/company-cars-70pct/` is a ready-to-import save (Company Cars, Chapter 4, 70%; a
modded save with about 999M cash). Drag that folder onto `Import-PS5Save.bat` to try it.
See its README for where it came from and what was left out.

## Where the saves go

ztrx keeps two separate folders: **the ztrx folder** (the code you built) and **the data
folder** (saves, profile, settings). Saves are in the data folder, **not** in the ztrx folder.

```
ztrx\                                  <- the repo you cloned and built
├─ Cargo.toml
├─ target\release\victory.exe
└─ Play-GTA6-SaveMod.bat               <- copy it here; its DATA= line picks the data folder

%LOCALAPPDATA%\ztrx\data\              <- the data folder (default: DATA= in the launcher,
│                                         -Data in ztrx's scripts\play.ps1, VICTORY_DATA_DIR)
└─ 7952987A\                           <- the game's title ID
   ├─ storage\settings\settings.xml    <- the game's graphics settings
   └─ saves\
      └─ 0009000000000001\
         └─ 00000000-0000-0000-0000-00007952987a\     <- the saves folder
            ├─ Player~333dc56ddffd8ea0\               <- profile (leave alone)
            ├─ SettingsProfileSettings~0b4e25fca06268d0\
            ├─ SARC0001~f3a9b5e1a0576e49\             <- one story save per folder
            │  └─ v1\
            │     ├─ 0            <- save data (ASAV header + LZ4 JSAV)
            │     ├─ 1            <- save header (296 bytes)
            │     └─ manifest     <- container name, title, blob names
            └─ SARC0015~f3ad35e1a05a7da0\             <- autosave slot
```

- `%LOCALAPPDATA%` is usually `C:\Users\<you>\AppData\Local`. Paste
  `%LOCALAPPDATA%\ztrx\data` into Explorer's address bar to open it.
- If your launcher uses a different data folder (for example `DATA=D:\ztrx-data`), give the
  importer the same one:
  ```powershell
  powershell -ExecutionPolicy Bypass -File Import-PS5Save.ps1 <save.zip> -AutoLoad -DataDir D:\ztrx-data
  ```
- The folder name after `~` is a 64-bit FNV-1a hash of the slot name; the importer computes it.
  Don't rename save folders by hand.
- To restore a save that was moved aside, move its `SARCnnnn~...` folder from
  `<data>\save-backups\...` back into the saves folder.

## Notes

- Saves made or imported this way **only load with the SaveMod launcher**: they are not
  encrypted, and the stock launcher would try to decrypt them.
- A save from a different game update may be refused by the game ("Couldn't load").
- Story progress inside the save (current mission) is not editable yet: the data is
  hundreds of hashed records. This tool converts saves; it does not change missions.
- ztrx itself is early: expect low frame rates and rendering problems.

## License

GPL-3.0-or-later, like ztrx (the patch is a change to ztrx). See `LICENSE`.
Not affiliated with or endorsed by Rockstar Games, Take-Two, Sony, Microsoft or the ztrx authors.
