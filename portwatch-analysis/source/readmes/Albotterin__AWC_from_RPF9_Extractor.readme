# AWC from RPF9 Extractor & AWC Radio

**Music from RAGE-engine `audio.rpf` archives: extract the audio, or listen to the game's radio stations – on the PC and on Android.**

🇩🇪 [Deutsche Version](README.de.md) · ⬇️ [**Download (Releases)**](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/latest) · 📱 [Android app](#-awc-radio-app-for-android) · 📊 [Radio progress](radio/docs/RADIO-PROGRESS.md)

| 🎛 AWC Audio Extractor | 📻 AWC Radio |
|:---:|:---:|
| ![AWC Audio Extractor](extractor/docs/screenshots/01-main.png) | ![AWC Radio](radio/docs/screenshots/06-radio.png) |

| 📱 AWC Radio on Android – stations | 📱 AWC Radio on Android – player |
|:---:|:---:|
| <img src="radio/docs/screenshots/09-app-radio.png" width="300" alt="stations"> | <img src="radio/docs/screenshots/10-app-player.png" width="300" alt="player"> |

> ⚠️ **Please read the [disclaimer](DISCLAIMER.md).** No game data is included: you need your own copy of the game.
> Nothing is decrypted, no copy protection is circumvented and nothing in the game is changed.

## Two projects in one repository

| | 🎛 AWC Audio Extractor | 📻 AWC Radio |
|---|---|---|
| **What for** | Find, play and extract every music stream | Listen to the stations like on a real radio |
| **Folder** | [`extractor/`](extractor/README.md) | [`radio/`](radio/README.md) |
| **Programs** | `AWC-Tool.exe` | `AWC-Radio.exe` + `AWC-Radio.apk` (Android) |
| **Guide** | [Extractor guide](extractor/README.md) | [Radio guide](radio/README.md) |
| **Technical notes** | [AWC / RPF9 format](extractor/docs/FORMAT.md) | [Station definitions](radio/docs/STATIONS.md) |

The extractor is the base: it reads the archive and the AWC files. AWC Radio builds on its modules, so keep both
folders next to each other when you run from source.

## Quick start

1. Download `AWC-Tool-…-win64.zip` from the [latest release](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/latest) and unzip it. It holds both Windows programs.
2. Put `ffmpeg.exe` and `ffplay.exe` ([ffmpeg.org](https://ffmpeg.org/download.html)) next to them, or into your `PATH`.
3. Start **`AWC-Tool.exe`** to extract, or **`AWC-Radio.exe`** to listen, and pick the `audio.rpf` of your own game.
   Keep the game's `data.rpf` in the same folder to get the titles of the podcast episodes and of the parts of the mixes.
   The radio also asks for the texture file `data\ttdb\ui\ttdb_ui.ttpf` (station logos).
4. **On the phone:** install the Android app, write the station and podcast packs with **Android packs…** in AWC Radio, copy them
   into one folder on the phone and choose that folder in the app.

From source (Python 3 with tkinter; Pillow for the logos):

```bash
git clone https://github.com/Albotterin/AWC_from_RPF9_Extractor.git
cd AWC_from_RPF9_Extractor
python extractor/awc_tool.py     # the extractor
python radio/awc_radio.py        # the radio
```

## 🎛 AWC Audio Extractor

* Scans `.rpf` archives of any size for audio containers – no table of contents needed.
* Writes the original Opus packets 1:1 into `.opus` files (no re-encoding); optionally FLAC, WAV or MP3.
* Plays every stream straight from the archive.
* Shows an archive **by radio station**: songs, DJ intros and outros, adverts, jingles and talk, with the station logo – plus the **podcasts** and the **score** in groups of their own.
* Reads the game's **score** (the interactive music): pieces mixed from its instrument layers, grouped into open world,
  missions, compounds and activities, to listen to, save or put on the phone (needs FFmpeg).
* Names streams from the game's own config, from the public credits page or from your own lists; station logos optional.
* English and German interface.

➡️ [**Extractor guide**](extractor/README.md)

## 📻 AWC Radio

* **34 stations**, among them the talk stations **WKTT** and **The Wipe** and the game's venues (**Jack of Hearts**, **VYB**,
  **The Vault**, **Thrillbilly Mud Club**), read with their playlists from the game's own audio config.
* A live programme by the UTC clock: every station keeps running, everybody with the same time hears the same song.
* Jingles, DJ talk and crossfades between the songs; long DJ mixes show the title of the current part.
* **The DJ**, if you switch him on: intros and outros spoken over the songs, in the windows the song files mark for them
  (default: off).
* **Adverts on demand**: every station with or without advert breaks (default: without).
* **Podcasts**: the game's 5 podcasts with their 20 episodes and titles, playable in the Android app and on the PC.
* An [**Android app**](#-awc-radio-app-for-android) plays the same programme on the phone and in the car, and wakes you with it.

➡️ [**Radio guide**](radio/README.md)

## 📱 AWC Radio app for Android

The radio for your pocket, your car and your bedside. **`AWC-Radio.apk`** (version 1.12; version 1.11 is tested on a real
Android phone) plays the same live programme as
the PC: same UTC clock, same order, same crossfades – with station packs from the same version, phone and PC play the same
song at the same time.

| | |
|---|---|
| 🎧 **Listening** | Station logos as a grid, a mini player and a large player in the colour of the station; swipe over the logo to change the station. Keeps playing in the background with a media notification, lock screen, headset and Bluetooth buttons |
| 🎙 **Podcasts** | An area of their own next to the radio: covers, episode list, a player with seek bar, 15 seconds back and 30 forward; the place in every episode is remembered and the next one follows by itself |
| 🗣 **DJ** | Intros and outros over the songs, switched on in the settings; the music steps back while the DJ talks |
| 🎼 **Score** | A tab of its own: open world, missions, compounds and activities, each with its sub groups and pieces |
| ⏰ **Radio alarm** | Several alarms with weekdays, station, volume, gentle start and snooze; a sunrise screen over the lock screen. If the radio cannot be heard, the phone's own alarm tone rings; alarms survive a restart |
| 🚗 **Android Auto** | The stations as a grid with their logos, song and station on the player screen, voice commands such as *"play Radio On-U on AWC Radio"* |
| 😴 **Sleep timer** | Stops the radio after the time you choose |
| 📢 **Adverts** | A switch in the player and on the settings page, off by default; on 18 stations |
| ⚙️ **Settings** | A settings page: crossfade on/off and 1-12 s (only between two songs), adverts, pack folder, battery settings, info and log |
| 📦 **Packs** | One file per station (`.radiopak`), per podcast (`.podpak`) and per score group (`.scorepak`), all in one folder on the phone: add or update single ones without copying everything again |
| 🔒 **Offline** | The app has no internet permission: everything comes from the packs on the phone |
| 🌍 **Languages** | English and German |
| 📋 **Needs** | Android 7.0 or newer |

**Set it up**

1. Install `AWC-Radio.apk` (from the [latest release](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/latest), or build it from [`radio/android/`](radio/README.md#awc-radio-for-android)). Allow notifications: the alarm needs them.
2. On the PC, click **Android packs…** in AWC Radio, choose a folder and write the packs (original quality, about 4.8 GB for all 34 stations and 0.2 GB for the podcasts). Later only new or changed packs are written. The score packs (about 1.6 GB) are offered there once the score has been read in AWC Tool (button **Score…**), or are written from its score window.
3. Copy the `.radiopak`, `.podpak` and `.scorepak` files into the same folder on the phone, start the app and choose that folder once.
4. For Android Auto: in the Android Auto settings tap *Version* about ten times, open the developer settings in the three-dot menu and switch on *Unknown sources*.

**Good to know**

* The APK contains **no game data** and is the same file for everybody. Station and podcast packs contain audio and pictures from your own game: for your own use only, do not share them.
* The single `.dat` pack of earlier versions is no longer read.
* Test an alarm on your phone before you rely on it: some manufacturers' battery savers stop apps in the background.
* A newer APK installs over the old one.

## Progress

Status **2026-11-26** (v2.9.0), measured with a 28.5 GB `audio.rpf`.

| Area | State | |
|---|---|---|
| Music containers found by the scan | 3,008, with 3,116 streams (about 101 hours), all of them Opus and extractable | ✅ |
| Songs the credits page lists for the music stations | **793 of 809** found (98.0 %) | 🟢 |
| Talk radio | all 5 shows the credits name, **15 episodes** | ✅ |
| Stations in AWC Radio | 34 (including 3 "(Mix)" stations, 4 venues and "Clubmixes") | ✅ |
| Venues | Jack of Hearts (100 min DJ set), VYB (45 min), The Vault (Club, 84 min), Thrillbilly Mud Club (20 songs) | ✅ |
| Adverts | 239 spots, optional in the programme of 18 stations | ✅ |
| DJ intros and outros over the songs | 714 songs with an intro, 687 with an outro, 2,221 lines on 18 stations | ✅ |
| Extractor by station | 28 stations and 5 podcasts with logo, 3,417 DJ lines | ✅ |
| Podcasts | all 5 the credits name, with 20 episodes and their titles (3 h 36 min), in the app and on the PC | ✅ |
| Score | 2,543 pieces (about 33 h), a folder of their own in the extractor; 974 of at least 30 seconds (26.5 h) go into the app packs | ✅ |
| Titles from `data.rpf` | 839 of the 865 track numbers the recordings carry have a title and artist in the game's own table | ✅ |
| Android app | version 1.12: radio, podcasts, score, DJ, adverts, radio alarm, Android Auto; version 1.11 runs on a real Android phone | ✅ |
| The Vault Radio | plays as one long mix; 23 of its 24 listed songs are named as parts of it | 🎚 |

![AWC Radio – station progress](radio/docs/radio-progress.svg)

Details for every station: [radio progress](radio/docs/RADIO-PROGRESS.md).

### Still open

- [ ] 16 listed songs without a file of their own at that station (the club DJ sets, one each of Worldwide FM and Radio On-U):
      6 play on Vice City Rap Radio and Dirty South Classics, 1 is part of the Radio On-U mix, 9 were found nowhere
      (neither a stream of the archive nor the game's title table carries their names)
- [ ] The 8 original songs of "Honey FM – Liquid City" (not found either)
- [x] The podcast episodes carry their titles from the game
- [ ] One 61-minute club mix stays in "Clubmixes": no track list and no place of the config plays it,
      and it has no track markers
- [x] AWC Radio on the PC plays the podcasts
- [x] The radio speaks the DJ intros and outros over the songs (PC and app)
- [x] The Android app runs on a real phone
- [x] Score and DJ in the app are tested on a real phone
- [ ] Extractor: Opus only; the RPF9 table of contents is not read, so there are no file names

### Milestones

| Version | Date | What was added |
|---|---|---|
| [v1.0.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v1.0.0) | 2026-11-22 | 🎛 Archive scan, player, lossless extraction |
| [v1.1.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v1.1.0) | 2026-11-22 | 🎛 Groups by position in the archive |
| [v1.7.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v1.7.0) | 2026-11-23 | 🎛 Song names and station logos · 📻 first AWC Radio |
| [v1.8.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v1.8.0) | 2026-11-23 | 📻 Programme by the UTC clock |
| [v1.9.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v1.9.0) | 2026-11-23 | 📻 Crossfades |
| [v2.0.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.0.0) | 2026-11-23 | 📻 Android app and station packs |
| [v2.1.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.1.0) | 2026-11-24 | 📻 More stations and songs, mix stations |
| [v2.2.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.2.0) | 2026-11-24 | 📻 The Vault Radio, Clubmixes, titles inside mixes |
| [v2.3.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.3.0) | 2026-11-24 | 📻 Android Auto, new app design |
| [v2.4.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.4.0) | 2026-11-25 | 📻 Talk radio and complete station playlists |
| [v2.4.1](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.4.1) | 2026-11-25 | 🎛 📻 Own station logo reader, no download needed |
| [v2.5.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.5.0) | 2026-11-25 | 📻 One pack per station, app 1.5 with radio alarm and new design, venue stations |
| [v2.6.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.6.0) | 2026-11-25 | 📻 Optional adverts (app 1.6) · 🎛 View by radio station with DJ intros, outros and adverts |
| [v2.7.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.7.0) | 2026-11-25 | 🎙 Podcasts in the app (1.8, own area, `.podpak`) and the extractor |
| [v2.8.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.8.0) | 2026-11-25 | 🎼 The game's score (AWC Tool and app 1.11, `.scorepak`) · 📻 DJ intros and outros, podcasts on the PC, crossfade settings · 🎛 40 more music containers |
| [v2.9.0](https://github.com/Albotterin/AWC_from_RPF9_Extractor/releases/tag/v2.9.0) | 2026-11-26 | 🏷 Titles from the game's table: all 20 podcast episodes, the parts of the mixes, 5 corrected and 2 completed song names · 🎼 the score as groups in AWC Tool · app 1.12 |

## Repository layout

```
extractor/     AWC Audio Extractor: program, shared modules, format notes, screenshots
radio/         AWC Radio: program, station reader, progress, screenshots
  android/     the Android app (source, build script, tests)
DISCLAIMER.md  what the programs do and do not do, and your duties (DISCLAIMER.de.md in German)
LICENSE        MIT
README.md      this overview (README.de.md in German)
```

## Legal notice – please read

**The full text is in the [disclaimer](DISCLAIMER.md).** In short:

* This repository contains **only source code and documentation**. It contains **no game files, no archives
  and no extracted audio**, and it never will.
* You need to supply your own files, from a game you legally own. What you do with extracted audio is your
  responsibility – the audio is subject to the copyright of its owners. Personal, non-commercial analysis and
  archiving is one thing; redistributing it is generally not allowed. A pack contains game audio: do not share it.
* The screenshots show station logos and song titles from the game only to illustrate what the programs read from your
  own files.
* This project is **not affiliated with, endorsed by or connected to** Rockstar Games, Take-Two or any other
  publisher. All trademarks belong to their respective owners.

## Credits and license

The AWC block layout was worked out with the help of [**vgmstream**](https://github.com/vgmstream/vgmstream); general
AWC/RPF knowledge comes from the community, notably [**CodeWalker**](https://github.com/dexyfex/CodeWalker). The layout
of the game's audio config follows the notes of the **Leonida** project (ItsNotRexed). Playback and
conversion use [FFmpeg](https://ffmpeg.org/).

[MIT](LICENSE) – applies to the source code in this repository only, not to any game data.
