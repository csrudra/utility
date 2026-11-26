# xbem — experimentální kompatibilní vrstva pro Xbox Series X|S

> **Stav: výzkumný prototyp.** xbem dnes načte a nativně spustí konzolové PE binárky,
> které používají jádro systému (vlákna, synchronizace, paměť, soubory, TLS,
> DLL, XTaskQueue). **Skutečnou hru zatím nevykreslí** — chybí GPU vrstva
> (D3D12.X). Analytické nástroje ale už teď řeknou přesně, co konkrétní hra
> potřebuje a co chybí.

## Proč to vůbec jde — a kde je to těžké

| Vrstva | Xbox Series X\|S | Co s tím dělá xbem |
|---|---|---|
| **CPU** | AMD Zen 2, x86‑64 | **Nic se neemuluje** – kód hry běží nativně na tvém CPU (stejný princip jako Wine/Proton). `xbem cpu` ověří, že tvoje CPU má potřebné instrukce. |
| **OS / systémové DLL** | upravené Windows jádro, `kernelx.dll`, GDK runtime (`XGameRuntime`) | **HLE** (high‑level emulace): vlastní reimplementace funkcí, které hra importuje. Co chybí, se automaticky nahradí stubem, který to zaloguje. |
| **GPU** | RDNA2, Direct3D 12.X, shadery předkompilované do nativního strojového kódu GPU | **Největší chybějící kus.** Hra dostává „headless“ D3D12.X zařízení (práce GPU se hned dokončí, nic se nekreslí); shadery se dají zachytit a disassemblovat (RDNA2). Plán je v [docs/GPU.md](docs/GPU.md). |
| **Balíčky** | `.xvc` / `.msixvc` (šifrované) | xbem **nic nedešifruje** a nepracuje s klíči. Potřebuješ „loose“ build – složku, kterou vytvoří build GDK před zabalením. |

### Nejdřív upřímná rada

Když máš hru **přímo od vývojáře**, nejrychlejší cesta, jak ji hrát na PC, je
**požádat ho o PC build**. Microsoft GDK umí stejný kód přeložit i pro PC
(platforma `Gaming.Desktop.x64`) a je to pro vývojáře o řády jednodušší než
cokoliv, co zvládne emulátor. xbem dává smysl jako výzkumný projekt, nebo když
PC build z nějakého důvodu není možný.

## Co funguje

- **PE loader** pro x64 obrazy: mapování sekcí, relokace, importy (i podle ordinálu), exporty a forwardery, ochrany stránek, načítání DLL přibalených ke hře (statické i `LoadLibrary`), `DllMain`.
- **Prostředí vlákna jako ve Windows**: emulovaný TEB/PEB přes segment `GS` (stejně jako Wine), implicitní TLS (`__declspec(thread)`), TLS callbacky, `TlsAlloc`/`FlsAlloc`, `GetLastError` přímo v TEB.
- **HLE `kernelx.dll`** (~410 funkcí, slouží i jako `advapi32`/`ole32`): vlákna, události, semafory, mutexy, `WaitForMultipleObjects`, kritické sekce, SRW zámky, condition variables, `InitOnce`, `WaitOnAddress`, virtuální paměť, haldy, soubory (včetně overlapped I/O a `FindFirstFile`), moduly, čas, řetězce/kódové stránky, systémové informace, **thread pool** (práce, časovače, čekání, cleanup groups), registr (prázdný jako na konzoli), ETW, základ COM, WinRT řetězce a aktivace, locale/NLS (en‑US), `FormatMessage`, formátování data a času, topologie procesoru, PE prostředky (`FindResource`), `oleaut32` (BSTR) a `bcrypt` (náhodná čísla). API‑set názvy (`api-ms-win-core-*`) se přesměrují sem.
- **`xmem.dll`** (správa paměti konzole): `XMemAlloc`, `XMemVirtualAlloc` a **fyzické stránky** (`XMemAllocatePhysicalPages`, `XMemMapPhysicalPages`) emulované sdílenou pamětí, takže stejnou stránku lze namapovat na víc adres jako na konzoli.
- **Offline síť**: `ws2_32` (i importy podle ordinálu), `winhttp`, `crypt32` – vše se chová jako konzole bez připojení, nic neodchází ven.
- **Zatím neemulované části se hlásí samy**: `acphal`/`chad`/`xapu` (zvukový hardware), `xcrdapi` (DirectStorage), `GameInput`, `XAudio2`, Media Foundation, `xg_xs` – volání se zalogují i s argumenty a místem volání a selžou tak, jak to volající kontroluje.
- **Výjimky (SEH)**: `RaiseException`, `RtlUnwindEx`, `RtlVirtualUnwind`, `RtlCaptureContext` a spol. nad unwind daty hry (`.pdata`/`.xdata`). Funguje dvoufázové doručení, kolidující unwind, „consolidate“ mechanismus, kterým MSVC spouští `catch` bloky, vektorové handlery i `RtlCaptureStackBackTrace`. Ověřeno skutečnými C++ výjimkami (`throw`/`catch`, rethrow, výjimky ve vláknech). Neošetřená výjimka vypíše typ C++ výjimky a zásobník.
- **C knihovna (UCRT)** (~660 funkcí za `api-ms-win-crt-*`, tedy to, co hry importují, ale nepřibalují): start/ukončení programu, `atexit`, `errno`, `malloc` a zarovnaná alokace, řetězce a wide řetězce (16bitový `wchar_t`), vlastní `printf`/`scanf` s Windows specifikátory (`%I64d`, `%ls`, …), `FILE` i `_open`/`_read` přes VFS (včetně CRLF v textovém režimu), matematika a `_controlfp`/`fenv`, čas, `qsort`, MSVC `rand()`, `_stat`/`_findfirst`, prostředí, „C“ locale. Pod jménem `msvcrt.dll` slouží i programům z MinGW.
- **HLE `xgameruntime.dll`**: `XGameRuntimeInitialize`, `XSystemGetDeviceType` (Series X / Series S / devkit), `XPackage*`, kompletní **XTaskQueue** (režimy Manual / Immediate / ThreadPool). `XUser`, `XGameSave`, `XStore` atd. zatím vracejí `E_NOTIMPL`.
- **Virtuální souborový systém**: balíček hry jako read‑only `G:\`, zapisovatelný `T:\`, další disky přes `--mount`, **case‑insensitive** cesty i na Linuxu, `..` nemůže utéct z kořene.
- **Diagnostika**: volání neimplementované funkce se zaloguje i s prvními čtyřmi argumenty a místem volání (`hra.exe+0x…`) a na konci běhu vypíše seřazený seznam „implementuj tohle dál“; `--strict` zastaví na první takové funkci; při pádu crash report s registry a pozicí `hra.exe+0x…`. **Když se hra zasekne**: `Ctrl+C` vypíše, kde stojí každé vlákno hry (včetně volané funkce, např. `-> calls kernelx.dll!WaitForSingleObject`) a ukončí běh; `Ctrl+\` vypíše totéž a hra běží dál.
- **Analýza**: `inspect`, `coverage` (JSON/Markdown report pokrytí importů celé hry), `package` (čte `MicrosoftGame.config`), `xvd` (metadata kontejneru, pozná šifrovaný balíček), `cpu`.
- **Komunikace PC ↔ konzole**: [`tools/xbdp`](tools/xbdp/xbdp.py) – klient Xbox Device Portalu (informace, balíčky, spuštění/ukončení aplikace, instalace, přenos souborů včetně rekurzivního stažení loose buildu, screenshot). Viz [docs/DEVKIT.md](docs/DEVKIT.md).

Všechno výše je pokryté testy: 39 unit testů, 8 testů devkit klienta proti
mock serveru a 20 integračních testů, které spouští **skutečné Windows PE
binárky** (sestavené MinGW) importující z `kernelx.dll`, `xgameruntime.dll`
a `api-ms-win-crt-*`, včetně C++ programu s výjimkami a `libstdc++`.

## Sestavení

Spouštění her vyžaduje **Linux x86‑64 nebo WSL2 na Windows** (kvůli nastavení
segmentu `GS`). Analytické nástroje fungují i nativně na Windows.

```bash
sudo apt install cmake ninja-build g++ gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 binutils-mingw-w64-x86-64
```

```bash
cmake -S . -B build -G Ninja
```

```bash
cmake --build build
```

```bash
ctest --test-dir build --output-on-failure
```

MinGW je potřeba jen pro integrační testy (sestavuje testovací „hry“). Bez něj
se testy, které je potřebují, přeskočí. Potřebuješ GCC 13+ nebo Clang 17+
(kvůli `std::format`). Binárka je pak v `build/bin/xbem`.

Na Windows (jen analýza): `cmake -S . -B build` a `cmake --build build --config Release`
ve Visual Studio Developer Promptu.

## Použití

```bash
./build/bin/xbem cpu                                  # zvládne moje CPU kód pro Zen 2?
```

```bash
./build/bin/xbem package ~/hry/MojeHra                # co je v loose buildu
```

```bash
./build/bin/xbem coverage ~/hry/MojeHra --markdown pokryti.md
```

```bash
./build/bin/xbem inspect ~/hry/MojeHra/Game.exe --missing-only
```

```bash
./build/bin/xbem run ~/hry/MojeHra --log-level debug
```

Volby pro `run`: `--strict`, `--device series-x|series-s|devkit`,
`--scratch DIR` (kam se mapuje `T:\`), `--mount X=DIR`, argumenty hře po `--`.

### Doporučený postup s hrou od vývojáře

1. **Získej loose build** — složku s `MicrosoftGame.config`, `.exe`, `.dll` a daty.
   Buď přímo od vývojáře, nebo z devkitu přes `xbdp pull-tree` ([docs/DEVKIT.md](docs/DEVKIT.md)).
   Zabalené `.xvc`/`.msixvc` jsou šifrované a nepoužitelné — `xbem xvd soubor` ti to potvrdí.
2. `xbem cpu` — kontrola instrukční sady.
3. `xbem coverage <složka>` — kolik importů hry už xbem umí a které chybí nejvíc.
4. `xbem run <složka>` — první spuštění. Sleduj hlášky `unimplemented:` a souhrn na konci.
5. Doimplementuj chybějící funkce v `src/hle/` (návod v [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md#jak-p%C5%99idat-hle-funkci))
   a opakuj krok 4. Ve chvíli, kdy hra dojde k inicializaci grafiky, začíná práce na GPU backendu.

## Architektura v kostce

```
            ┌──────────────── xbem (hostitelský proces, Linux/WSL2) ────────────────┐
 loose      │  package/   MicrosoftGame.config, layout, XVD metadata                 │
 build  ──▶ │  loader/    PE parser ──▶ runtime/module_loader: mapování, relokace,   │
            │             importy ──┬──▶ HLE moduly (hle/*.cpp, MS x64 ABI)          │
            │                       ├──▶ DLL přibalené ke hře                        │
            │                       └──▶ stuby neimplementovaných funkcí (log/strict)│
            │  runtime/   proces, vlákna, TEB/PEB přes GS, TLS, handly, VFS          │
            │  gpu/       rozhraní GPU backendu (zatím null) ◀── hle/d3d12.cpp       │
            │  platform/  mmap/VirtualAlloc, pthread, CPUID, crash handler           │
            └───────────────────────────────────────────────────────────────────────┘
   herní kód (x86‑64) běží přímo na CPU hostitele; do xbem se dostane jen voláním importů
```

Detaily: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Aktuální stav práce na konkrétní hře, testovací smyčka a další kroky: [docs/STATUS.md](docs/STATUS.md).

## Struktura repozitáře

| Cesta | Obsah |
|---|---|
| `src/loader/` | PE32+ parser (hlavičky, sekce, importy, exporty, relokace, TLS, CodeView PDB) |
| `src/package/` | `MicrosoftGame.config`, skenování loose layoutu, XVD hlavičky |
| `src/runtime/` | proces, vlákna, TEB/PEB, TLS, handly a waitable objekty, VFS, loader modulů, stuby |
| `src/hle/` | reimplementace systémových DLL (`kernelx`, `xgameruntime`, `d3d12`) |
| `src/gpu/` | rozhraní pro GPU backend |
| `src/platform/` | abstrakce OS (paměť, vlákna, CPUID, signály) |
| `src/app/` | CLI `xbem` |
| `tools/xbdp/` | klient Xbox Device Portalu (Python, jen standardní knihovna) |
| `tests/unit/`, `tests/guest/` | unit testy a testovací „hry“ (PE binárky pro MinGW) |

## Roadmapa

1. **Ověření na reálném titulu** – podle `xbem coverage` doplnit chybějící `kernelx`/GDK funkce a potvrdit skutečné názvy DLL a způsob vazby GDK runtime.
2. **GPU** (viz [docs/GPU.md](docs/GPU.md)) – hotovo: *headless* D3D12.X zařízení (hra projde inicializací grafiky, nic se nekreslí), zachytávání shaderů (`run --dump-shaders DIR`) a dekodér/disassembler instrukcí RDNA2 ověřený proti LLVM (`xbem gpu-disasm`). Dál: rozbor kontejneru shaderů, překlad RDNA2 → SPIR‑V, Vulkan backend.
4. **Vstup a zvuk** – `GameInput` → SDL/evdev, XAudio2 → host audio.
5. **Služby** – offline `XUser`, `XGameSave` do lokální složky.
6. **Nativní Windows host** – přesměrování TEB/TLS bez WSL2.
7. **Hardwarové výjimky jako SEH** – převod `SIGSEGV`/`SIGFPE` v herním kódu na `EXCEPTION_ACCESS_VIOLATION` atd. pro `__try/__except`.
8. **DirectStorage (`xcrdapi`), zvukový hardware (`acphal`/`chad`/`xapu`), XAudio2, GameInput** – podle logů z reálného titulu.

## Právní rámec

- Používej jen hry a data, ke kterým máš práva (tady: build přímo od vývojáře).
- xbem neobsahuje žádný kód, klíče ani soubory Microsoftu. HLE moduly jsou
  vlastní reimplementace podle veřejné dokumentace Win32/GDK.
- xbem **neobchází ochranu** obsahu: nedešifruje balíčky a nepracuje s klíči.

## Licence

xbem je svobodný software pod licencí **GNU General Public License verze 3
nebo (dle tvé volby) jakékoli pozdější** (GPL-3.0-or-later), plný text je v
[LICENSE](LICENSE). Kód převzatý z jiných projektů kompatibilních s GPLv3
(např. Leonida) si nese uvedení původu u příslušných souborů.
