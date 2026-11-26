<img width="1600" height="900" alt="screenshot" src="https://github.com/user-attachments/assets/4addf923-44fa-4875-8b5d-a9361c637aa2" />

# Grand Theft Auto VI Styled Launcher shows the key art as a splash screen, runs a short boot
sequence, then starts the real game install.

## Run it

```
dist\game_scarlett_master.exe
```

Portable single-file build — no install. It extracts to `%TEMP%` on launch.

- **ENTER / SPACE** — launch the game
- **R** — rescan for an install
- **ESC** — dismiss the error panel
- Window controls are top-right (frameless window)

## How it finds the game

`game-finder.js` resolves a launch target at startup, in this order:

1. `game.aumid` in `config.json` — a Microsoft Store / MSIX AppUserModelID,
   launched as `shell:appsFolder\<aumid>`
2. `game.path` — an absolute path to the game executable
3. **Steam** — scans the registry Steam path plus every drive's
   `SteamLibrary`, follows `libraryfolders.vdf`, and looks for an
   `appmanifest_*.acf` whose `"name"` is `Grand Theft Auto VI`. Launching goes
   through `steam://rungameid/<appid>` so Steam handles DRM/overlay.
4. **Xbox / GDK PC install** — `<drive>:\XboxGames\Grand Theft Auto VI\Content\*.exe`

If nothing matches, the splash shows `GAME NOT INSTALLED — PRESS ENTER FOR
DETAILS` and ENTER opens a panel listing what it searched.

### config.json

```json
{
  "logo": "assets/logo.png",
  "title": "GRAND THEFT AUTO VI",
  "game": {
    "path": "",
    "args": [],
    "cwd": "",
    "aumid": ""
  }
}
```

| Key | Meaning |
| --- | --- |
| `game.path` | Absolute exe path. Empty = auto-detect. |
| `game.args` | Array of arguments passed to the exe. |
| `game.cwd` | Working directory. Defaults to the exe's folder. |
| `game.aumid` | Store app id, e.g. `Publisher.Hash_8wekyb3d8bbwe!GTAO`. Wins over `path`. |

Example for a Store copy:

```json
"game": {
  "aumid": "Publisher.1234567890ABC_8wekyb3d8bbwe!App"
}
```

## Rebuild

```
powershell -ExecutionPolicy Bypass -File scripts\build.ps1
```

Steps: `electron-builder --win portable` → sign with the novelty cert → output
`dist\game_scarlett_master.exe`.

`scripts\build.ps1` only packages the files listed in `package.json`'s `build.files`
array, so `game-finder.js` must be in that list (it is).

## Metadata / signature

File properties report:

| Field           | Value                                                        |
| --------------- | ------------------------------------------------------------ |
| CompanyName     | Scarlett Novelty Works                                       |
| ProductName     | Scarlett Launcher                                            |
| FileVersion     | 1.0.2                                                        |
| LegalCopyright  | © 2026 Scarlett Novelty Works. Unofficial fan project.       |
| LegalTrademarks | All trademarks are the property of their respective owners.  |

The exe is signed with a **self-signed** certificate whose subject is
`CN=Scarlett Novelty Works` — created locally by `scripts\make-cert.ps1`.
The pfx lives at `signing\scarlett-novelty.pfx`.

Consequences, by design:

- Windows shows **Unknown publisher** and SmartScreen may warn.
- `Get-AuthenticodeSignature` returns `UnknownError` because the root is not trusted.
- The certificate was **not** installed into any trust store.

It is a novelty build.

## Layout

```
main.js              Electron main process (window, config, IPC, spawn)
game-finder.js       install discovery (AUMID / path / Steam / XboxGames)
preload.js           contextBridge API
config.json          titles + game target
renderer/            splash + boot sequence (HTML/CSS/JS)
assets/splash.png    GTA VI key art
assets/logo.png      app icon source
assets/icon.ico      256x256 icon
scripts/make-cert.ps1  creates the novelty signing cert
scripts/build.ps1      build + sign
```

Dev run: `npm start` (add `--screenshot` to auto-capture the splash after boot).
