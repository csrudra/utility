# Neptune HyperEngine by Dolberth (VIctory Fork) — Generic Windows 10/11 Launcher
# Profile tuned for 8 GB NVIDIA GPUs + 6-core Ryzen CPUs + 16 GB RAM (100% standalone native FPS).
#
# Usage:
#   .\run-neptune.ps1 -Title 'D:\Titles\Example\title.exe'
#   .\run-neptune.ps1 -Title 'D:\Titles\Example\title.exe' -TextureMaxDim 2048
#   .\run-neptune.ps1 -Title 'D:\Titles\Example\title.exe' -Window '1600x900'
#   .\run-neptune.ps1 -Title 'D:\Titles\Example\title.exe' -SeriesX

param(
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [string]$Resolution = '1920x1080',
    [string]$Window = 'fullscreen',
    [string]$Ambient = '',
    [switch]$SeriesX,
    [string]$TextureMaxDim = '0',
    [switch]$Taa,
    [switch]$NoThin,
    [switch]$SyncSubmit,
    [switch]$RawIndirect,
    [switch]$WarmShaders,
    [switch]$SkipWarm,
    [switch]$Dred,
    [switch]$BelowNormal
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$exe = Join-Path $root 'target\release\victory.exe'
if (-not (Test-Path -LiteralPath $exe)) {
    Write-Error "Binary not found: $exe (run: cargo build --release -p victory)"
    exit 1
}
if (-not (Test-Path -LiteralPath $Title)) {
    Write-Error "Title executable not found: $Title"
    exit 1
}
if (Get-Process -Name victory -ErrorAction SilentlyContinue) {
    Write-Error "victory.exe is already running. Close it before launching a new session."
    exit 1
}

# Helpful check for Windows 10 users (build < 22000 requires Agility SDK 1.620.2 D3D12Core.dll)
$osBuild = [Environment]::OSVersion.Version.Build
$d3dCore = Join-Path (Split-Path $exe -Parent) 'D3D12\D3D12Core.dll'
if ($osBuild -lt 22000 -and -not (Test-Path -LiteralPath $d3dCore)) {
    Write-Warning "Windows 10 detected (build $osBuild) without $d3dCore. Download Microsoft DirectX 12 Agility SDK 1.620.2 and place D3D12Core.dll in target\release\D3D12\ if D3D12 initialization fails."
}

# Scale worker pools cleanly across 4C/6C/8C+ CPUs (matches 5/6 on 6C/12T)
$logical = [Environment]::ProcessorCount
$thinThreads  = [Math]::Max(4, [Math]::Min(8, [int][Math]::Floor($logical / 2)))
$turboThreads = [Math]::Max(3, [Math]::Min(6, $thinThreads - 1))

$set = [ordered]@{
    # 8 GB VRAM & 16 GB RAM profile (Neptune VRAM Guardian + ad3lre 8GB)
    VICTORY_CARD_WINDOWS_MB          = '512'
    VICTORY_CARD_BUFFERS_MB          = '640'
    VICTORY_CARD_ROOM_FOR_TARGETS_MB = '512'
    VICTORY_CARD_ROOM_FOR_BUFFERS    = '0'
    VICTORY_TEXTURE_ROOM_PERCENT     = '92'
    VICTORY_TEXTURE_HEAPS            = '1'
    VICTORY_SLOT_EVICT               = '1'
    VICTORY_SLOT_EVICT_PERCENT       = '90'
    VICTORY_SLOT_EVICT_MB            = '256'
    VICTORY_VRAM_EVICT               = '92'
    VICTORY_VRAM_IDLE_MS             = '15000,4000,1500'
    VICTORY_TEXTURE_MAX_DIM          = $TextureMaxDim
    VICTORY_RAM_TRIM_MB              = '512'
    VICTORY_LIST_POOL_MB             = '384'
    VICTORY_LIST_POOL_MOST           = '768'
    VICTORY_LIST_POOL_IDLE_S         = '10'
    VICTORY_TEXTURE_STAGE_MB         = '256'
    VICTORY_DSTORAGE_STAGING_MB      = '64'
    VICTORY_LEVELS_ON_DEMAND         = '1'
    VICTORY_DROP_DXIL                = '1'

    # Neptune HyperEngine + Vertex + ad3lre CPU/GPU pipeline optimizations
    VICTORY_PROCESS_PRIORITY         = 'normal'
    VICTORY_TURBO_THREADS            = "$turboThreads"
    VICTORY_SHADER_META_CACHE        = '1'
    VICTORY_THIN                     = '1'
    VICTORY_THIN_THREADS             = "$thinThreads"
    VICTORY_WATCH_4K                 = '1'
    VICTORY_GUARD_REST               = '3000'
    VICTORY_RANGED                   = '1'
    VICTORY_INDIRECT_RAW             = $(if ($RawIndirect) { '2' } else { '3' })
    VICTORY_INDIRECT_WINDOW          = '1'
    VICTORY_GROUPED_MESH_CLAMP       = '1'
    VICTORY_SMART_COPY_BACK          = '1'
    VICTORY_SMART_COPY_BACK_KB       = '4'
    VICTORY_RELAY_OWN_QUEUE          = '1'
    VICTORY_RELAY                    = '2'
    VICTORY_COPY_CHANGED             = '1'
    VICTORY_QUIET_BACK               = '1'
    VICTORY_UNDER_WRITES_WORDS       = '1'
    VICTORY_UNDER_WRITES_RUNS        = '100000'
    VICTORY_UNDER_WRITES_MASKS       = '1'
    VICTORY_UNDER_WRITES_MASKS_LEAST = '1'
    VICTORY_WIDE_MERGE               = '1'
    VICTORY_WIDE_REFRESH             = '1'
    VICTORY_WIDE_THREADS             = "$thinThreads"
    VICTORY_ASK_ONCE                 = '1'
    VICTORY_ASK_QUIET                = '8'
    VICTORY_TEXTURE_NO_WAIT          = '1'
    VICTORY_TEXTURE_HASH_EVERY       = '32'
    VICTORY_CARD_REHASH_RUNS         = '1'
    VICTORY_CARD_REHASH_GAP          = '4'
    VICTORY_CARD_SYNC_BATCH          = '1'
    VICTORY_STEP_INDEX               = '1'
    VICTORY_REFRESH_STAMP            = '0'
    VICTORY_TAA                      = $(if ($Taa) { '1' } else { '0' })
    VICTORY_JOIN_COPIES              = '1'
    VICTORY_WINDOW_TAILS             = '1'
    VICTORY_WINDOW_KB                = '1024'
    VICTORY_CARD_BUFFERS_MIN_KB      = '64'
    VICTORY_CARD_WINDOW_UPLOAD       = '1'
    VICTORY_LATE_WAIT_LISTS          = '1024'
    VICTORY_D3D12_BACKGROUND         = '0'
    VICTORY_WAVE_OWN_LDS_GROUPS      = '64,128'

    # Shader cache, streaming and stability
    VICTORY_NAN_GUARD                = '0'
    VICTORY_BAKE_TEXTURES_MS         = '2000'
    VICTORY_EARLY_TEXTURES_MS        = '35'
    VICTORY_TEXTURE_BATCH            = '1'
    VICTORY_HEAP_SYNC                = '1'
    VICTORY_DESC_DATA                = '1'
    VICTORY_OCEAN_READBACK           = '1'
    VICTORY_RT_RESOLVE               = '0'
    VICTORY_ACTIVATE_RAYS            = '0'
    VICTORY_PIPELINE_WORKERS         = '3'
    VICTORY_PIPELINE_WAIT_MS         = '2500'
    VICTORY_TITLE_WATCHDOG           = '0'
    VICTORY_TEARING                  = '1'
    VICTORY_DISCORD                  = '0'
}

$amb = Join-Path $root 'ambient.txt'
if (-not (Test-Path $amb)) { Set-Content -Path $amb -Value '0.36 0.05 0.4 1.0 0.6 0.1 0.45 0.5' -Encoding ascii }
$set['VICTORY_AMBIENT_FILE'] = $amb
if ($Ambient -ne '') { $set['VICTORY_AMBIENT'] = $Ambient }
if ($NoThin) { $set.Remove('VICTORY_THIN') }
if ($Dred) { $set['VICTORY_D3D12_DRED'] = '1' }
if (-not $SyncSubmit) {
    $set['VICTORY_ASYNC_SUBMIT'] = '1'
    $set['VICTORY_ASYNC_PRESENT'] = '1'
}

$console = if ($SeriesX) { @('--console', 'series-x') } else { @('--console', 'series-s') }

Get-ChildItem Env:VICTORY_* -ErrorAction SilentlyContinue | Remove-Item
if ($Resolution -ne '' -and $console[1] -eq 'series-x') { $set['VICTORY_RESOLUTION'] = $Resolution }
if ($Window -ne '') { $set['VICTORY_WINDOW_SIZE'] = $Window }
foreach ($k in $set.Keys) { Set-Item -Path ("Env:$k") -Value $set[$k] }
$env:VICTORY_GAME_DIR = Split-Path -Parent (Resolve-Path -LiteralPath $Title)

# Automatic one-time offline shader warmer (prevents live shader compilation freezes on first launch)
if (-not $SkipWarm) {
    $shaderPack = Join-Path $env:VICTORY_GAME_DIR 'shaders.rpf'
    $cacheDir = Join-Path $env:LOCALAPPDATA 'victory\cache\shaders'
    $stampFile = Join-Path $cacheDir '.warmed-neptune-stamp'
    $packItem = Get-Item -LiteralPath $shaderPack -ErrorAction SilentlyContinue
    $wantStamp = if ($packItem) {
        "neptune-v2:$($packItem.Length):$($packItem.LastWriteTimeUtc.Ticks)"
    } else {
        'neptune-v2:generic'
    }
    $hasStamp = (-not $WarmShaders) -and (Test-Path -LiteralPath $stampFile) -and `
        ((Get-Content -LiteralPath $stampFile -Raw -ErrorAction SilentlyContinue).Trim() -eq $wantStamp)
    if (-not $hasStamp) {
        Write-Output "Warming shader cache offline (first launch only, ~3-5 min; prevents live stutter)..."
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $exe warm
        $warmCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEap
        if ($warmCode -eq 0) {
            New-Item -ItemType Directory -Force $cacheDir | Out-Null
            Set-Content -LiteralPath $stampFile -Value $wantStamp -NoNewline
        } else {
            Write-Warning "Shader warm exited with code $warmCode; continuing to launch."
        }
    } else {
        Write-Output "Shader cache already warmed (use -WarmShaders to force re-warm)."
    }
}

$log = Join-Path $env:TEMP 'neptune-last.log'
$prev = Join-Path $env:TEMP 'neptune-prev.log'
if (Test-Path $log) { Move-Item -Force $log $prev }
if (Test-Path "$log.err") { Move-Item -Force "$log.err" "$prev.err" }

$argv = @('run', "`"$Title`"", '--execute') + $console
$p = Start-Process -FilePath $exe -ArgumentList $argv `
    -WorkingDirectory (Split-Path $exe -Parent) `
    -RedirectStandardOutput $log -RedirectStandardError "$log.err" `
    -WindowStyle Normal -PassThru
if ($BelowNormal) { $p.PriorityClass = 'BelowNormal' }
Write-Output "Neptune HyperEngine by Dolberth started (PID $($p.Id), profile=$($console[1]), log=$log.err)"
$p.WaitForExit()
Write-Output "Neptune HyperEngine by Dolberth exited (code $($p.ExitCode))."
