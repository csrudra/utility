# C-1 · Package inventory

**Question this answers:** what exactly is in the circulating `1.0.2.1` package, and what is missing from it?

Five projects independently report that the game executable is absent. This document is the single place that fact — and the whole file list — is recorded, so nobody has to re-derive it from a local dump.

> Clean-room note: only **file names, sizes and hashes** are recorded. No game assets, no strings, no executables.

## Headline numbers

| Metric | Value |
| :--- | :--- |
| Release | `1.0.2.1`, Xbox Series (`Scarlett`) |
| Package identity | `RockstarGamesInc.28872443D20A7` |
| Publisher | `CN=3164F9C2-2C28-4832-BBE3-A642A4EF0054` |
| TitleId | `7952987A` |
| MSAAppId | `000000004060F900` |
| Files | 108 |
| Total size | 223,880,932,870 bytes (208.51 GiB) |
| Executables (`.exe`) | **0** |
| Declared executable | `game_scarlett_master.exe` |

The manifest declares one application:

```xml
<Application Id="GTAO" Executable="game_scarlett_master.exe" EntryPoint="GamingProxyApp.Application.EntryPoint">
```

and `MicrosoftGame.Config` repeats it:

```xml
<Executable Name="game_scarlett_master.exe" Id="GTAO" TargetDeviceFamily="Scarlett" ... />
```

No file matching `game_scarlett_master.exe` exists in the dump. The `.xvd` (`gameos.xvd`, 332 MiB) is the Game OS system volume, not the title binary.

## By extension

| Extension | Files | What it is |
| :--- | --: | :--- |
| `.ttpf` | 57 | RAGE 9 GPU-tiled texture stores (mostly `data/ttdb/terrain/`) |
| `.rpf` | 22 | RPF9 archives (22 top-level + `pack/*`) |
| `.dll` | 16 | Console-side runtime DLLs (see below) |
| `.png` | 5 | Store logos / splash |
| `.bin` | 2 | `Catalog000.bin`, `microsoft_gameconfig.bin` |
| `.xml` | 2 | `appxmanifest.xml`, layout XML |
| other | 4 | `.xvd`, `.pri`, `.Config`, `.alignmentchunk` |

## Largest archives

| File | Size |
| :--- | --: |
| `levels.rpf` | 76,155,065,056 |
| `audio.rpf` | 28,543,454,672 |
| `pack/story000/story000.rpf` | 20,022,508,672 |
| `movies.rpf` | 8,832,481,776 |
| `pack/core_bvh4/core_bvh4.rpf` | 8,297,921,520 |
| `navmeshes.rpf` | 6,707,512,496 |
| `packs.rpf` | 4,798,213,264 |
| `anim.rpf` | 4,407,626,384 |

## Console DLLs present

`Bink2Scarlett.dll`, `XCurl.dll`, `XboxBvhBuilder.dll`, `amd_fidelityfx_loader_xbox.dll`, `amd_fidelityfx_upscaler_xbox.dll`, `libHttpClient.GDK.dll`, `vccorlib140.dll`, `vcomp140.dll`, `concrt140.dll`, `msvcp140*.dll`, `vcruntime140*.dll`.

`Freminet/ScarlettX` (#44) notes that only `xmem.dll` is Xbox-specific in GTA VI's sidecar set, so a four-function `xmem.dll` shim would make the whole DLL set import-resolvable — a concrete, small task that unblocks every loader project.

## Verifying your own copy

```bash
# file count and total bytes
find GTA6.Xbox.v1.0.2.1-CYBERLEEK -type f -printf '%P\t%s\n' | sort > manifest.tsv
wc -l manifest.tsv
awk -F'\t' '{s+=$2} END {print s}' manifest.tsv   # expect 223880932870

# executable check
grep -ci '\.exe$' manifest.tsv                     # expect 0
```

If your numbers differ, open an issue with the diff — a differing manifest is a different dump, and that matters for every bug report downstream.
