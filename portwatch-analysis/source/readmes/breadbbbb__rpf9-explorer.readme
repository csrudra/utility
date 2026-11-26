# rpf9-explorer 1.5

A desktop viewer for RPF archives and game assets on Windows, macOS and Linux. Open multiple archives or a folder, search textures, preview models and media, export files, and save replacement projects.

RPF9 can open in indexed mode with a compatible local decoder, or use the built-in recovery scans. Indexed mode browses the native member table, including nested archives, and reads supported stored, chunked, and transformed members. Archive rebuilding remains unavailable.

See the [RPF9 research notes](docs/rpf9-format-findings.md) for the format findings and the [local decoder guide](docs/rpf9-index-provider.md) for setup.

## About GTA 6

This is an unofficial project developed while inspecting RPF9 files associated with GTA 6. **The source contains no actual GTA 6 game code.** GTA 6 source code, decompiled game code, game executables, and game scripts are not included.

The source package contains the explorer's code, build files and documentation. The Windows build includes the required third-party notices. Game archives and raw model, texture, audio, and movie files are not bundled. The screenshots show the app displaying files loaded locally.

This project is not affiliated with, endorsed by, or sponsored by Rockstar Games or Take-Two Interactive. GTA 6 and related names belong to their respective owners.

## Choose a build

Choose your operating system and processor under **Releases**. Each package includes its own .NET runtime and the command-line tools.

| Platform | Getting started |
| --- | --- |
| Windows x64 | Extract the ZIP and launch the desktop app. |
| macOS on Apple silicon or Intel | Extract the matching archive and open the application bundle. The build uses an ad hoc signature. It has no Apple notarization. |
| Desktop Linux on x64 or ARM64 | Extract the archive with permissions intact and run the desktop launcher from the extracted folder. The viewer uses X11 or XWayland. |

On macOS and Linux, use **Open files**, **Open folder**, or drop sources onto the window. Search across sources, sort by size, and double-click a nested archive to browse it. **Parent archive** returns to the previous index. **Scan archive** runs the recovery scanners. **Decoder…** accepts a compatible local bridge configuration.

Select a texture to preview it. Select a model to rotate it by dragging and zoom with the wheel. The drawable selector switches fragment children or dictionary components. **Export OBJ** saves the displayed geometry. For metadata, select a block, choose a record, or follow a populated array to its target. **Extract selected** writes the selected entry into a destination folder of your choice.

Use **Models** on macOS and Linux to assemble a vehicle at its wheel mounts, choose an authored wardrobe kit, or queue model parts across searches. The **Edit** menu stages replacements and compares them with the originals. **Workspace** saves and reopens projects. Select a movie or audio stream to use the player, or use **Export** to save a decoded stream or texture.

**Browse by content** on Windows and the **All content** selector on macOS and Linux group assets across archives. Choose a group or use a query such as `group:"Radio stations"` or `group:"World / Maps"`. Open an audio archive with the indexed decoder to see station names, score, dispatch, vehicle sounds and other banks named by its audio configuration. Double-click a station to browse its banks, then select a stream to play it. When a sibling conversation catalogue matches a scripted speech bank, the stream selector shows the recorded take, scene cues and original stream ID. Search with `cue:` followed by a cue or part of its name. Station membership can be known even when an individual song title is missing.

Select a vehicle with recognized wheel mounts and choose **Assemble vehicle** to preview its loaded components. On a character part, **Find outfits** lists the authored kits that reference it. Load the wardrobe catalogue and its model sources in the same workspace.

Select a supported native shader to inspect its decoded RDNA 2 instructions and register-level pseudocode. Operations that require hardware-specific semantics keep their instruction spelling. **Save shader listing** exports the text. The compiled shader remains available through extraction.

## Open files or a folder

On Windows, extract the build ZIP and launch the rpf9-explorer desktop app. Keep the `Tools` and `Licenses` folders beside the application.

- Click **Open** or press **Ctrl+O** to select one or more `.rpf`, `.ttpf`, or `.zip` files.
- Click **Open folder** to find supported files in a folder and its subfolders.
- You can also drag files or a folder into the window.

Opening more files adds them to the current workspace. Use **File > Clear loaded sources** to start over. A workspace can hold up to 512 source files.

Select a source or folder on the left to browse it. With a local decoder configured, double-click a nested archive row to open its index and use **Up** to return to its parent. Files with a matched path candidate show that name. Other entries show a slot number and name hash. Read the header signature result in the archive information.

In recovery mode, model discovery searches the RPF9 file on first open, including drawable dictionaries that contain character components. Later opens use the saved scan results. **Scan entire archive** switches to recovery mode for that source and searches other supported payloads.

## Find and preview textures

Choose **Images** in the filter above the file list. Turn on **Thumbnails** to browse image previews, then select an image to see it on the right. Thumbnail pages contain up to 96 images.

![Texture search with thumbnails and a full texture preview](docs/screenshots/texture-search.png)

Searches match all the words you enter. Use quotes for a phrase, `-word` to exclude a word, and `*` or `?` for wildcards. Search is case-insensitive.

| Search | Result |
| --- | --- |
| `type:image name:glass` | Images with glass in their name |
| `format:bc7 width:>=1024` | BC7 images at least 1024 pixels wide |
| `source:textures -normal` | Matches in texture sources, excluding normal |
| `size:<2MiB height:>=512` | Files smaller than 2 MiB and at least 512 pixels high |

Other fields are `archive:`, `key:`, `hash:`, `mips:`, `w:`, and `h:`. Numeric fields accept `>`, `>=`, `<`, `<=`, and `=`. Size values accept `KiB`, `MiB`, and `GiB`.

**Search all sources** searches every loaded file while a query is entered. Uncheck it to search the current location. **Available only** hides entries that cannot be extracted with the current decoders. Selecting a folder in the tree clears the search.

### Browse a texture dictionary

Expand an archive and its folders under **Sources and textures**, then expand a texture dictionary to see its images. You can also double-click a **Texture folder** row. Use **Up** to return to its parent.

![Individual images listed inside an expanded texture dictionary](docs/screenshots/texture-dictionary.png)

The texture selector above the preview switches between images in the same dictionary. Arrays, cube maps, and volumes also have a slice or face selector where supported. **Export DDS** saves the texture in DDS format, including the available mip levels.

Supported TTPF layouts include compact 2D mip chains, 2D arrays, streaming cube maps, and single-mip 3D volumes, including Xbox BCPack BC1, BC3, BC4, and BC5 chunks. The preview can select individual slices or faces, and DDS exports preserve the supported texture shape. R16G16B16A16_UNORM previews retain the original 16-bit channels in DDS exports. Unvalidated storage profiles, unsupported formats, and unsupported BCPack codecs (BC6H/BC7) remain unavailable. These additional layouts and BCPack-compressed textures are read-only; they do not add native replacement support.

Streaming textures may have generated names based on native keys. These are not claimed to be their original filenames.

Integrations using `RpfPreview.Core` can load local BC1/BC3/BC4/BC5 history tables with `BcpackHistory.Load(path)` and pass them to the decoding or export overloads. The desktop viewer uses the built-in tables. History files are not bundled; BC6H/BC7 history tables remain unsupported.

## Appearance

Use the **Dark mode** switch at the top right to change the app's appearance. Buttons, file lists, navigation, and preview details follow the selected theme. The setting is remembered when the app reopens.

## Vehicle previews

Supported vehicle shaders use approximate paint, tyre, glass, lens, and light materials. Select a vehicle fragment with recognized skeleton wheel mounts, then choose **Assemble vehicle**. Load the relevant wheel and brake resources into the same workspace first. **Export OBJ** saves the assembled geometry.

An optional vehicle configuration beside the source archive or app can provide paint color, wheel scales, and part names. Without a matching configuration, assembly can use generic available rims and tyres. These are preview approximations; they do not reproduce the game's complete paint system or prove an authored vehicle configuration. Missing textures and unsupported native shaders can remain unresolved.

## Preview models

Choose **Models**, search for a model, and select it. The preview loads supported geometry and matches diffuse textures by their native asset keys. It checks embedded model textures, loaded texture sources, and sibling game texture folders when available.

![Model preview with an automatically matched diffuse texture](docs/screenshots/model-preview.png)

Drag with the left mouse button to orbit, drag with the right mouse button to pan, and use the mouse wheel to zoom. **Reset view** resets the camera. **Export OBJ** saves decoded geometry and supported UV coordinates.

Core integrations can call `RageModelDecoder.Decode(system, graphics, drawableOffset, lod)` with `lod` from 0 to 3 to choose a model's level of detail. The returned model records the selection in `Lod`. Individual model previews use LOD 0. Wardrobe assembly chooses the most detailed readable native variant within its preview limits. An unavailable LOD returns `null`.

Some fragments contain several drawables. Use the selector in the Model tab to switch between the primary and its children. **Export OBJ** saves the displayed drawable. In Core, `DecodeModels` returns readable drawables in record order. Each fragment model exposes its `FragmentDrawableIndex` and `DrawableOffset`.

### Inspect RAGE resources

Open an indexed RPF9 archive and double-click a child archive to browse its contents. Select a generic RAGE resource to see where its system and graphics sections begin and how many bytes each occupies. Geometry, textures and other supported assets open in their existing viewers.

Choose **Metadata** or search for `format:0drp` to find recognized version 122 metadata. The **Structure** tab lists the numbered data blocks, marks the root, and shows field hashes and offsets from its structure definition. Supported array fields show an item count and the block they reference. **Hex** shows the beginning of the decoded resource. You can also drop an extracted 0DRP resource into the app without configuring an archive decoder. Detailed metadata inspection supports up to 16 MiB.

Character parts inside drawable dictionaries appear as individual model results using their native names. Search for a character by name, or use `body`, `arms` or `legs` to include shared skin components. Different detail variants may share a name. Use the source offset to distinguish them.

Use **Add selected parts** to collect model components across different searches. **Preview queued parts** overlays the collected components in their original coordinates and keeps their supported texture bindings. **Clear parts** empties the queue. You can also Ctrl- or Shift-select two or more visible rows and click **Preview together**. **Assembly details** lists every component, omitted selection, source and material mapping. Manual selection does not infer an outfit or fill in missing body parts. Alternate clothes and detail variants can overlap.

![Character component recovered from a drawable dictionary](docs/screenshots/character-parts.png)

![Selected body parts retained across searches and previewed together](docs/screenshots/model-assembly.png)

Load the relevant texture pools if a model appears gray. The text below the preview reports missing materials, lower-resolution mip levels, and layered-material approximations. Layered materials show the first available supported color layer. Some distant models use their native vertex colors when they have no UV coordinates.

For an unfinished download, the model archive can be complete while its sibling texture pools still contain missing regions. Finish downloading the character texture pools, then select the model or assemble the outfit again. The app checks changed texture pools on the next preview. Empty compressed chunks and unreadable pool indexes are reported in the assembly details.

Some outfit materials have a native SLOD color intended for distant views. If no color image is available, supported opaque appearances can use that value as a uniform color approximation. Supported palette selections also use their native palette SLOD color when all three selected tint channels agree. This does not reproduce surface texture detail or full palette shading. The app counts these separately from textured mesh parts. Composite appearances and ambiguous material assignments remain unresolved. Normal, specular and material ID maps are not used as substitute color textures.

Model recovery also supports fragments with absent optional header pointers, supported 16-bit bone-palette declarations, larger validated geometry lists, and zero-radius drawables. Empty declared bounds use the decoded geometry for the preview. OBJ export saves geometry and UV coordinates, in their stored pose; it does not contain a skeleton or animation tracks.

Use **Scan entire archive** to rebuild a saved model index after a decoder update. Model recovery supports RPF9 resources with small uncompressed metadata or geometry tails alongside their zlib blocks.

Some models still have missing or unsupported material bindings, even when the pools are loaded. Unsupported Xbox BCPack codecs (BC6H/BC7) remain unavailable. Full game shaders and palette effects are not reproduced.

## Assemble outfits

1. Load the archives containing the wardrobe catalogue and character components, along with the relevant texture pools.
2. Use **Scan entire archive** if the required models or metadata have not been indexed. Open **File > Assembled wardrobe**.
3. Choose a catalogue, search by kit ID or native component name, then click **Assemble outfit**. You can also open an extracted PSIN/0DRP wardrobe catalogue.

Wardrobe selection follows the catalogue's native drawable and appearance identifiers, including inherited preset states. Each selected model is decoded and its native identifier is checked again. Models appear together in their stored coordinates. Body morphs, cloth simulation and strand hair are not reproduced. Unavailable components are reported. A kit ID or shared component name does not establish a character's identity or guarantee a complete body.

Archives can be read while another app is downloading them. Only complete, validated resource ranges are usable. Indexes created while a writer has the file open remain partial; refresh them after the download finishes. An allocated file size does not mean all its data has arrived.

## Play movies and audio

Select a supported movie or audio bank to open its preview. Audio banks have a stream selector. Playback controls include play, pause, seek, loop, and volume. Movie previews also have frame stepping and full screen.

Native game audio and Bink movie previews need the corresponding helpers in `Tools`. The release packages include native helpers for each operating system. Playback uses local files and the first movie audio track. Some audio codecs remain unsupported, and decoded audio previews are limited to 120 seconds. AWC Opus previews and exported WAV files play at 48 kHz.

## Browse PSIN metadata

**Scan entire archive** also finds PSIN metadata containers anywhere in an RPF9 file, including containers with 64 KiB blocks that are stored without compression. A container is listed only when its CHKS checksum matches. The Structure tab shows its sections; both section lists (`LSCH…` and `PMAP…`) are accepted. The meaning of the binary fields is not decoded, and a PSIN container is not a script.

## Browse animation dictionaries

Choose **Animations** to list recovered clip dictionaries, or search `type:animation`. Selecting one shows its name, its animation count and the names of its clips. Use **Scan entire archive** first: clip dictionaries are usually beyond the part of an archive that is searched on open.

The list preview shows dictionary metadata and clip names only. Animation playback is not included. Motion-matcher sets use a different record layout and are not listed as ordinary clip dictionaries.

## Extract files

Select results and click **Extract selected**. Use Ctrl or Shift to select multiple rows or thumbnails. **Extract results** exports available entries in the current filtered results.

Exports are grouped into separate source folders. Existing files are not overwritten. Texture image entries export as DDS files. Recovered model entries now export their selected geometry as OBJ, including the correct drawable dictionary child. Texture dictionary payloads use the app's `.r9texdata` format. **Export OBJ** saves the current model or assembly in its displayed pose.

Extraction exports the original assets. Staged replacements are stored separately in the workspace.

## Command line

`rpf9-cli` searches and exports assets without opening the desktop app. It accepts the same sources as **Open folder** and reuses the recovery scans the app has already saved, so a source that was scanned once opens quickly.

```powershell
$source = Read-Host "Source archive or folder"
$out = Read-Host "Export folder"
rpf9-cli search $source -q "type:model"
rpf9-cli export $source -q (Read-Host "Model search term") --best --merge assembly -o "$out\assembly"
rpf9-cli export $source --id (Read-Host "Asset IDs from search, separated by commas") -o "$out\parts"
rpf9-cli export $source -t textures -q "name:glass" -o "$out\textures"
rpf9-cli kits $source --complete
rpf9-cli export $source --kit (Read-Host "Kit ID from the list") --merge outfit -o "$out\outfit"
rpf9-cli scan $source --kinds textures,psin
```

- `inspect` reads a decoded resource or an indexed archive member. Select a block and record with `--block` and `--record`, both numbered from one. The default is the first root record. Add `--json` for the block directory, field hashes, array targets and a bounded hex preview of the selected record.
- For nested archives, run `search --json` to get indexed slot numbers, then pass `--inside` with a slot to search, inspect or export its contents. Repeat it to descend further. For fragment exports, `--drawable 0` selects the primary and higher numbers select its children.
- `search` prints an ID, type, size, source and name for each match. Add `--json` for machine-readable output. An ID names one source, entry and subresource: a source tag, then the offset (and drawable child or texture index), or the entry index where offsets repeat.
- `export` writes models as OBJ + MTL with PNG color and normal maps, textures as PNG, and other assets as stored files. `--merge` writes every model into one OBJ with each part as its own object. Parts keep their native bind-space coordinates, so character components line up when merged.
- `kits` lists authored wardrobe kits and the indexed models each one selects. `export --kit <id>` exports a kit with its authored albedo and normal maps, or its SLOD color where no albedo texture is available.
- `scan` runs the full payload scan on every RPF9 source and saves it to the shared index cache. Kinds that already have a full scan are skipped, `--kinds` limits the scan, and a failing kind does not stop the others.
- `--query` uses the app's search syntax. `--id` selects exact rows from `search`; an unknown ID stops the export before anything is written. `--best` keeps the largest variant of each name. `--lod` picks a detail level and `--max-texture` limits texture size.
- Each export folder contains a JSON manifest listing every part, the texture source used for each material, and the reason any material or asset could not be exported.
- Existing exports are not overwritten unless you add `--overwrite`.

Texture lookup follows the app's model preview: embedded textures, texture dictionaries in the loaded sources, loaded and sibling texture pools, and validated resident defaults. Wardrobe catalogues are read from scanned PSIN metadata; a model whose catalogue states all agree on one albedo uses it even without `--kit`. Normal maps are written in OpenGL (Y+) convention, with the blue channel rebuilt for two-channel sources. Skeletons, morphs and animation are not exported.

Run `rpf9-cli help export` for every option. Exit codes: 0 success, 1 failure, 2 invalid usage, 3 nothing matched.

## Save edits and reopen a workspace

1. Select an asset and click **Stage replacement**.
2. Choose the replacement file. Models accept OBJ, textures accept DDS/PNG/JPEG, and audio streams accept WAV.
3. If prompted, choose where to save the workspace.
4. Use **Original** and **Staged replacement** to compare them. **Remove replacement** removes the project override.

![A staged texture replacement with comparison and removal controls](docs/screenshots/staged-texture.png)

Imports and removals save automatically. **Save workspace** or **Ctrl+S** also saves the source list, search, folder, and selection. Open it again with **File > Open workspace**.

Keep the `.rpfworkspace` file and its `.rpfworkspace.assets` folder together. Keep the source files at their saved paths. A workspace does not contain a backup of the archives. Older `.rpfproject` files can still be opened.

Matching staged texture edits are used when previewing a model. **They are not written into the original RPF9 archive.** Full RPF9 write-back remains unavailable. The experimental pool-copy export supports certain compatible DDS replacements in RDS5 pools; in-game compatibility is unverified.

## Build from source

Install the .NET 10 SDK. On macOS or Linux, use `dotnet run --project ./Desktop` from the repository root to launch the portable viewer. On Windows, build the WPF app with PowerShell.

```powershell
dotnet build ./App -c Release
```

Run the PowerShell publish script in the repository root to create self-contained Windows x64 builds of the desktop app and CLI under `dist`. NuGet restores the pinned dependencies. To search from source, use `dotnet run --project ./Cli -c Release -- search $source -q "type:model"`, with `$source` set to your archive or folder.

### Optional media helpers

The `Tools` folder contains the Bink and Opus helper sources and their PowerShell build scripts. The scripts require Visual C++ and the Windows SDK. Set the compiler and SDK paths for your installation.

Bink requires a separately installed licensed Unreal Bink SDK. Opus requires libopus headers and a library. Build the helpers before running the publish script so it can copy them into the published `Tools` folder.

For XMA2 and WAV previews, put an FFmpeg build configured with `--disable-network` and only the `file,pipe` protocols in `Tools` before publishing. The publish script checks both settings. The app loads preview helpers from the local `Tools` folder.

The Windows build uses libopus 1.6.1. To use your own static libopus build, pass its installation root to `-OpusRoot` and its x64 `/MT` static library to `-OpusLibrary` when running the Opus helper build script. Compiler and Windows SDK paths can also be supplied as parameters.

Model and texture browsing do not need the media helpers.

## Source layout

| Folder | Contents |
| --- | --- |
| `App` | WPF interface and preview sessions |
| `Desktop` | macOS and Linux desktop interface and model renderer |
| `Core` | Archive readers, decoders, search, extraction, and edit projects |
| `Cli` | `rpf9-cli` command-line search and export |
| `Tools` | Native helper source, build scripts, and the indexing CLI |
| `docs/screenshots` | Screenshots used in this README |

## Third-party notice

AMD addrlib-derived address patterns and mip layout:
Copyright (c) 2007-2024 Advanced Micro Devices, Inc. All Rights Reserved.
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

### Microsoft Silicon-rANS

BCPack probability models use tables from [Microsoft Silicon-rANS](https://github.com/microsoft/silicon-rans/tree/2f6827d8a4e6a78029c372f20d8b61f7cd408fc5).

MIT License

Copyright (c) Microsoft Corporation.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
