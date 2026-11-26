<img width="1280" height="424" alt="ascvdvas2" src="https://github.com/user-attachments/assets/5b21323c-885d-40fd-9d46-e2239b715f4e" />

# OpenRPF9

A lightweight Windows tool for inspecting and carving data out of Rockstar `RPF9` archives.

<p align="center">
  <img width="671" height="426" alt="Screenshot 2026-11-22 194706" src="https://github.com/user-attachments/assets/5db3533a-069b-4b8c-815a-8fbe2cd22b69" />
</p>

## How it works

Right now, the `RPF9` Table of Contents (TOC) is encrypted, so OpenRPF9 bypasses the directory tree and carves unencrypted payloads directly from the archive:

- **Header check:** Reads the first 4 bytes to verify the `RPF9` magic (`0x52504639` / `9FPR` in little-endian).
- **Stream carving:** Scans aligned offsets for compressed payloads and inflates them via `DeflateStream`. Each valid stream is tagged as `text` or `binary` based on printable ASCII/UTF-8 bytes.
- **Offset jumping:** Once a stream inflates, the scanner jumps past the consumed compressed bytes (`ms.Position`) and aligns to the next 16-byte boundary so it doesn't pick up false-positive fragments mid-stream.

## Features

- open TTPF files and view textures.
- a list of carved streams with file offsets, detected type (`text` / `binary`) and decompressed sizes.
- hex dump and live text/XML preview.
- export individual streams (`Export Selected`) or dump everything to a folder (`Export All Streams`).

## Building

Requires the [.NET SDK](https://dotnet.microsoft.com/en-us/download) (Windows):

```bash
dotnet build -c Release
```

Or run it directly:

```bash
dotnet run --project src/OpenRPF9.Gui.WinForms
```

## Contributing

[CONTRIBUTORS.md](CONTRIBUTORS.md).

