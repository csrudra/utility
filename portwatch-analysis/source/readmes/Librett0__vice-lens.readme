# Vice Lens

<!-- Preview: drag preview.mp4 into this file in GitHub's editor; GitHub
puts the video's link here. -->

An unofficial, open-source desktop app for exploring the Xbox Series data
(version 1.0.2.1) of Grand Theft Auto VI, on Linux and Windows. It reads a
copy of the game you own, in place and without changing it: the whole
island as a map with every placement, models in 3D, vehicles that open
and steer, people and animals posed and animated with the game's own
clips (cutscenes too), textures, movies, sound, archives byte by byte and
the game's text; and from any point on the map, a 3D world you can fly
through (Vulkan, through wgpu).

> **No game files are included, and none are downloaded.** This
> repository holds only Vice Lens's own code and documentation: no game
> code, data, models, textures, animations, sound, movies or text. To use
> Vice Lens you need your own copy of the game's files. It reads them in
> place and never changes them, and what it makes from them (caches,
> exports, captures) stays on your machine.

## Getting started

Download Vice Lens for Linux or Windows from the releases, unpack it and run
`vice-lens` (on Linux it needs WebKitGTK 4.1, present on most desktops, and
a Vulkan driver for the 3D world). Everything it needs comes in the
archive, the FFmpeg that plays the game's Bink 2 movies included. In
**Setup**, choose your game folder (the one that holds `levels.rpf`,
`data.rpf`, `textures.rpf`, ...) and press
**Build missing caches**: Vice Lens reads the map, the placements and the
model index from your copy once (about an hour on a fast disk; about 2 GB),
and you can explore while it works.

To build it yourself you need Rust (stable, 2024 edition) and, on Linux, the
WebKitGTK 4.1 and GTK 3 development packages
(`libwebkit2gtk-4.1-dev libgtk-3-dev` on Debian and Ubuntu,
`webkit2gtk4.1-devel gtk3-devel` on Fedora):

```bash
./vice-lens.sh                        # the app
./vice-lens.sh --serve                # or in a browser, at http://127.0.0.1:7878
./vice-lens.sh --build-caches --game /path/to/your/game/folder
```

The game folder can also come from `--game` or `VICE_LENS_GAME`. With
`VICE_LENS_PROBE=1` the app measures how many frames its window gets (still,
panning the map, turning a model), writes them to the log and closes. With
`VICE_LENS_CAPTURE=DIR`, the page in a browser can save the frames it draws
to that folder, for videos made of real frames: from the browser's console,
`viceLensFilm('name', 150, { turn: 1.5 })` films the 3D view shown (and the
clip playing on it), `viceLensMapFilm` the map.
[docs/caches.md](docs/caches.md) lists what each cache holds.

## The app

A research console: activity bar, tabs, an inspector for whatever is
selected, a status bar with background work, and `Ctrl K` to search
everything or jump to coordinates (`-560, 44`). Every list and table takes
the arrow keys (Enter opens, Shift+F10 or right-click for the menu). Tabs
scroll with the wheel, the button at the strip's end lists them all, and
`Ctrl Tab`, `Ctrl PageUp`/`PageDown` and `Ctrl W` move between and close
them. Each search stays at the top of its list and takes options: match
case (`Aa`), whole words, a regular expression (`.*`), and the list's own
filters. Whatever you look at saves: models as glTF, movies as MP4, as
stored (`.bk2`) or a frame as PNG, files and segments as bytes, text as
TSV, sounds as Opus, textures as PNG. `Ctrl Shift F` shows the frame rate.

- **Map**: the island drawn from the game's own LOD models, 2 m a pixel, in
  three styles (switch in the corner, or M): **satellite** (the textures),
  **clay** (one pale material, buildings and hills by their shade) and
  **relief** (coloured by height, contour lines every 10 m). Zoom in and
  every placement shows as a dot: detailed models, LOD and super-LOD
  stand-ins, water tiles. Point at one and its model turns at the top of
  the inspector; click it for its position, rotation, LOD distances,
  archetype and the file it comes from; find any model and see everywhere
  it is placed; right-click anywhere to **explore it in 3D**.
- **Models**: search the 260 000 drawables by name or hash (filter by kind,
  by whether the map places them, without LOD stand-ins; sort by placements)
  and open them in 3D (orbit, pan, zoom, wireframe). The inspector shows
  every texture each shader names (colour, a second colour such as dirt,
  normals, specular, tint palette, ground layers): click one to look
  through them all over the model (arrows, zoom, save), the cube puts it
  on the model; the toolbar steps through the model's variants (`bin_04a` to
  `bin_04e`); **Export .glb** saves the model with the textures shown.
  Props get their colours from tint palettes, which are in none of the
  texture packs, so they show in their base colour (a bin is white).
- **Textures**: the UI and effect texture dictionaries as galleries; open
  any texture to zoom and pan, or save it as PNG.
- **Video**: the 515 Bink 2 movies, with posters, filtered by shape (the
  phone clips are portrait), sound and length. A movie converts to MP4 as it
  opens (progress on its poster; once, a few seconds) and plays with a
  player's keys: Space, arrows and J/L to seek, `,` `.` a frame, `[` `]`
  speed, O loop, F full screen, N/P the next or previous movie. 196 hold
  sound tracks (Bink Audio 2; a movie with several lets you switch between
  them while it plays), 16 of them only silence; the other 319, mostly
  short screen loops, hold none. Movies play through an FFmpeg with a Bink
  2 decoder, which stock FFmpeg lacks: the releases carry one next to Vice
  Lens ([vice-lens-ffmpeg](https://github.com/Librett0/vice-lens-ffmpeg)),
  with the fix the phone-shaped clips (720×1280) need
  ([docs/formats.md](docs/formats.md#movies-moviesrpf)). Of the one Setup
  names, the one next to Vice Lens and `ffmpeg` on the PATH, it uses the
  first that has the `bink2video` decoder. A movie converts to MP4 (H.264)
  where the window plays it, else to WebM (VP9, Opus): on Linux the window
  plays video through GStreamer, which has no H.264 decoder without
  `gst-libav` (left out by a fresh Arch or CachyOS), while VP9 and Opus
  come with its good and base plugins.
- **Sound**: the sound banks of `audio.rpf`; effects and speech play straight
  from the data (Opus, wrapped in Ogg without re-encoding) and save as
  `.opus`. Music banks are listed but do not play yet.
- **Files**: list any archive once, filter its files, and read any of them
  byte by byte (as stored, or a resource's virtual and physical segments).
- **Vehicles**: a showroom of 173 vehicles: the detailed body, wheels from
  the game's catalogue of rims and tyres on the wheel bones (style and
  number, size), a paint of your choosing (the game makes its paint at
  runtime, so the body's own colour is not in the data), and the tuning
  parts on the car, one per kind (bonnets, bumpers, splitters, spoilers,
  skirts, roofs, exhausts…; a whole bonnet, bumper or exhaust takes the
  stock one's place). **Take it apart**: the body comes in its pieces
  (doors, seats, steering wheel, bonnet, boot, bumpers, engine, lights,
  hubs, glass…), each shown or hidden, seen alone, or spread out from the
  middle with the Apart slider. **Moving parts**: every piece of the body
  follows one of the vehicle's bones, so the doors, bonnet and boot open on
  their hinges, the wheels roll (Drive) and the front ones steer with the
  steering wheel.
- **People**: the wardrobe. Over 300 characters and outfits (the cutscene
  cast, the protagonists' outfits, crowd faces and the game's creatures)
  dressed in their own clothes, with
  their other items to swap in; and some 5 900 clothes and accessories by
  body (men, women, bigger, older, children) and slot (tops, jackets, legs,
  shoes, hats, glasses, masks, jewellery, watches, bags, armour…) to put on
  and take off, on a shop mannequin (the game has no plain bare body). The
  game colours clothes with masks and palettes at runtime, so each slot
  wears a plain colour; hair, brows and lashes are a kind of geometry not
  read yet. **Pose**: everything worn is skinned on the body's skeleton
  (the game's crowd bodies, 450–600 bones), so turning a bone bends the
  person and their clothes together. **Animations**: the game's clips
  play on the person: 416 155 clips in 78 102 dictionaries of `anim.rpf`
  and the story pack (walking, running, dancing, eating, push-ups, and the
  story's cutscenes, shot by shot, a clip per actor), all but 14 whole.
  The 8 008 dictionaries of motions (the game blending several clips by
  speed, distance or the feet's phase) list their clips to play one by
  one. Clothes bend with the body (a jacket's armhole may still open in a
  fast move).
- **Animals**: 268 animals and other creatures by class (mammals, birds,
  fish, reptiles, amphibians, crustaceans, insects), each put together from
  its parts (body, head, eyes, teeth, fur, feathers…), with its looks: the
  named animals and costumes (`missmojo`, `cowboy`, `legendary`, road-kill
  and others) swap in as a set, or part by part, posed on the animal's own
  skeleton and animated with the game's clips (dogs barking and
  galloping, a deer running, chickens eating, crows, sheep…). The face's
  rig comes from the head, so jaw, tongue and teeth follow their bones,
  but mouths stay shut: a face clip moves controls that the game's
  expressions, not read yet, turn into the rig's motion. Fur and feathers
  are the same kind of geometry as people's hair and are not drawn yet.
- **Text**: search the game's English text by content or label: the
  interface (36 888 lines) and 586 other tables (246 055 lines of dialogue in
  scenes, calls and on the street, posts and messages); open any table
  whole.

On Linux the window is WebKitGTK's. It draws through shared memory by
default; Setup can switch it to the GPU, which paces frames more evenly.
WebKitGTK may still hold the page to 60 frames a second (it does on NVIDIA
under Wayland, where it finds no display to follow); the globe button in
the top bar opens the same page in your browser at the screen's full rate.

## The 3D world and the pause menu

Under the app is a native renderer, also run from the command line:

```bash
./vice-lens.sh --world -560,44,400 --window       # fly over downtown
./vice-lens.sh --world -560,44,300 --flight 300 --capture frames/
./vice-lens.sh --make-map                         # the map, for the minimap and the app
./vice-lens.sh --menu                             # the pause menu
./vice-lens.sh --menu --capture menu.png --size 3840x2160 --input down,accept
```

In the window: WASD move, Q/E down/up, arrows or left-drag look, Shift
fast, F12 saves a frame to `captures/`. A minimap turns with the camera; M
opens the full map, where the wheel zooms, a drag pans, a click teleports and
Escape closes.

Environment: `VICE_LENS_CAM=x,y,z,yaw,pitch` places the camera,
`VICE_LENS_SPEED` and `VICE_LENS_TURN` steer a `--flight`,
`VICE_LENS_SUN=azimuth,elevation` (degrees, azimuth from east) moves the sun,
`VICE_LENS_NO_SHADOWS` turns shadows off, `VICE_LENS_LOD_SCALE` stretches every
LOD distance (1, as on the console), `VICE_LENS_TRACE` logs what each flight
frame adds and drops, `VICE_LENS_DUMP=file` writes the first frame's
placements. `--bench FRAMES` flies the window's loop offscreen and logs where
each frame's time goes. `VICE_LENS_BUILD_PREFIX` wraps the build in
`vice-lens.sh` (for example in a memory cap).

## Where it stands

The pause menu screen (`SCRN_PauseMenu`) is laid out and drawn from the
game's UI data, with its text, fonts, icons and the VI mark; focus moves
through the six entries, and entries that open a sub-screen of the menu
(Game: save, load, new, exit) open it, with Escape to go back.

Styles come from the game's style store (fonts by alias, sizes, tracking,
which named colour and alpha, gradients, per-state styles of list items).
Two things the data does not hold are Vice Lens's own: the RGB of each named
colour and the face behind each `$fontN` alias (`crates/fwui/src/style.rs`).

Not yet: layout styles (the blade's width is Vice Lens's), the apps that
flow links open (`to_map`, `to_settings`, `to_store`, ...; Vice Lens logs
them), menu animations and sounds, and the boot sequence. The backdrop is two
layers of a loading screen arranged by Vice Lens until the loading-screen
movies play.

The 3D world shows the map's placed entities and instance batches
around a point, streamed in by worker threads in rings by the game's own LOD
levels (detailed, LOD, super-LOD), with the game's albedo textures at full
size near the camera and small copies farther; models dissolve in and out
instead of popping. A sky with a sun, sun shadows in two cascades, water
with waves and reflections, height haze and filmic tone mapping. Each
shader's render bucket decides how it draws: decals and glass blended over
what is behind them, water as water. Not yet: terrain layer blending (one
layer is drawn), textures whose top level is BCPack (11% of them, drawn
grey), the furnishing scripts switch on in interiors (the first of each set
of variants is shown), lights at night, time of day. Interiors (shops,
flats, offices) stand furnished where the world places them.

## Layout

- `crates/rage`: readers for the data formats ([docs/formats.md](docs/formats.md)).
- `crates/fwui`: reads the game's UI data and lays it out: elements,
  layout, draw commands, styles.
- `crates/vice-lens`: the program: the app (`src/app.rs`, `src/lens`, its
  page in `lens/`), data loading, the Vulkan renderer, the menu and the
  world.
- `tools/`: scripts that build the caches.

## Disclaimer

Vice Lens is a fan research project. It is not affiliated with, endorsed or
sponsored by Rockstar Games or Take-Two Interactive. Grand Theft Auto and
related names are trademarks of their owners and are used here only to say
which data the tools read. The repository holds no game code or data; the
caches and captures Vice Lens makes from your copy stay on your machine.

## Licence

MIT; see [LICENSE](LICENSE).

The release archives also carry `ffmpeg`, a separate program that Vice Lens
runs to play movies and shares no code with. It is under the GNU Affero
General Public License 3.0 or later (`FFMPEG-LICENSE.txt` beside it), and
its complete source, with the script that builds it, is
[Librett0/vice-lens-ffmpeg](https://github.com/Librett0/vice-lens-ffmpeg)
(`FFMPEG-SOURCE.txt` names the commit).
