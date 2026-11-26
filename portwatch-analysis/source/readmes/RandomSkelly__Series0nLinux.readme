# Series0nLinux

An experimental open-source compatibility layer and clean-room DLL reimplementation project designed to run modern Xbox Series console executables on Linux via Wine and Proton.

## Overview

Modern Xbox console titles share significant architectural DNA with Windows (x86-64, PE binaries, DirectX 12), yet rely on console-specific Portable Executable (PE) subsystems and proprietary runtime libraries (`xgameruntime`, `kernelx`, etc.) that standard Wine/Proton prefixes do not implement out of the box.

**Series0nLinux** aims to bridge this gap through clean-room API stubbing, subsystem translation, and runtime shims—allowing developers and researchers to study console-to-Linux compatibility without modifying proprietary game assets.

## Project Goals

* **Subsystem Translation:** Safe tooling to inspect and translate console-specific PE header subsystems (`0x000E`) to standard Windows GUI subsystems (`0x0002`) for Wine/Proton loader compatibility.
* **Clean-Room Runtime Stubs:** Pre-compiled, open-source (`x86_64-w64-mingw32`) replacement DLLs implementing core Xbox GDK/runtime entry points.
* **Diagnostic Logging:** Detailed `stderr` and trace logging for unimplemented API calls to map out missing dependencies systematically.
* **DirectX 12 / VKD3D Interop:** Bridging console-specific graphics extensions to standard Vulkan translation layers on Linux.

## Repository Structure

```text
Series0nLinux/
├── build/              # Pre-compiled x86_64 Windows DLL shims
├── scripts/            # Python utilities for PE header inspection & diagnostics
└── docs/               # Architecture notes & API compatibility tracking
```

## Prerequisites

To use the compatibility shims and diagnostic scripts on Linux, you will need:

* **Wine / Proton:** Proton Experimental or Wine-Staging (9.0+)
* **Python 3.10+:** With `pefile` installed (`pip install pefile`) for PE subsystem inspection scripts

### Installing Dependencies (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install python3 python3-pip
pip install pefile
```

### Installing Dependencies (Arch Linux)
```bash
sudo pacman -S python python-pip
pip install pefile
```

## Usage

1. Clone or download the repository:
   ```bash
   git clone https://github.com/yourusername/Series0nLinux.git
   cd Series0nLinux
   ```

2. Copy the pre-compiled `.dll` shims from `build/` into your target application's prefix directory (or override them via `WINEDLLOVERRIDES`).

3. Run your target executable through Proton with debug logging enabled:
   ```bash
   WINEDLLOVERRIDES="xgameruntime=n,b" PROTON_LOG=1 proton run ./your_target_binary.exe
   ```

4. Check the terminal output or generated log file for `[Series0nLinux]` stub traces to identify unimplemented function calls.

## Progress
-Boots to a white screen and then crashes. Stayed booted for 1 second before crashing.
-According to the logs, the game reads the .dll files and attempts to boot, but is still missing some dependencies. 

## Legal Disclaimer

* **No Proprietary Code or Assets:** This repository contains **zero** proprietary source code, copyrighted binaries, cryptographic keys, or game assets. All shims are clean-room implementations created from scratch based on publicly available documentation and standard ABI specifications.
* **Educational & Research Purposes:** Series0nLinux is developed strictly for interoperability research, preservation, and educational purposes under fair use / interoperability provisions.
* **User Responsibility:** Users must supply their own legally obtained software backups. Do not open issues or pull requests containing copyrighted binaries, leaked SDKs, or links to pirated material—they will be immediately deleted.

## Contributing

Contributions are welcome! Please ensure all pull requests adhere to clean-room reverse-engineering practices:
1. Reference only public Microsoft GDK documentation or observed runtime behavior.
2. Never submit code or binaries copied from proprietary or leaked SDKs.
3. Document any new exported stub signatures and expected return values.

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
