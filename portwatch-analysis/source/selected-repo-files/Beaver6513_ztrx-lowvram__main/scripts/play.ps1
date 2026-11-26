# ztrx launcher: runs the game for normal play (no scripted presses, no capture).
param(
    [Parameter(Mandatory = $true)][string]$Game,
    [string]$Cache = "$env:LOCALAPPDATA\ztrx\cache",
    [string]$Data = "$env:LOCALAPPDATA\ztrx\data",
    # D3D12 Agility SDK folder (the unpacked NuGet package or the folder with
    # D3D12Core.dll): needed on Windows 10, whose own D3D12 stops at SM 6.5.
    [string]$D3D12 = "",
    # Skip the title's movies that do not loop (logos at start-up).
    [switch]$SkipMovies,
    # Overlap the CPU's copy-back with the card's work (VICTORY_RELAY=2):
    # about half the frame time on a GTX 1650.
    [switch]$Fast,
    # F8 holds A for you, the title's cut-scene skip (it must be held until
    # the prompt's ring fills); F8 again lets go.
    [switch]$SkipCutscene,
    # Other buttons F8 holds for you in turn, e.g. "A,X" (overrides the above).
    [string]$AutoPress = "",
    # Default: target\release\victory.exe beside this script (set below:
    # $PSScriptRoot is empty while Windows PowerShell 5.1 reads the defaults).
    [string]$Exe = ""
)
if (-not $Exe) { $Exe = Join-Path $PSScriptRoot "..\target\release\victory.exe" }
foreach ($v in "VICTORY_KEYS", "VICTORY_CAPTURE", "VICTORY_CAPTURE_FRAMES", "VICTORY_DUMP_TARGETS") {
    Remove-Item "Env:$v" -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force $Cache, $Data | Out-Null
$env:VICTORY_CACHE_DIR = $Cache
$env:VICTORY_DATA_DIR = $Data
if ($D3D12) { $env:VICTORY_D3D12_DIR = $D3D12 }
if (-not $AutoPress -and $SkipCutscene) { $AutoPress = "A" }
if ($AutoPress) { $env:VICTORY_AUTO_PRESS = $AutoPress } else { Remove-Item Env:VICTORY_AUTO_PRESS -ErrorAction SilentlyContinue }
if ($Fast) { $env:VICTORY_RELAY = "2" } else { Remove-Item Env:VICTORY_RELAY -ErrorAction SilentlyContinue }
if ($SkipMovies) { $env:VICTORY_SKIP_MOVIES = "1" } else { Remove-Item Env:VICTORY_SKIP_MOVIES -ErrorAction SilentlyContinue }
& $Exe run $Game --execute 2>&1 | Out-File "$env:TEMP\ztrx.log" -Encoding utf8
Write-Host "Exited with $LASTEXITCODE; log: $env:TEMP\ztrx.log"
