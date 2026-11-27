<#
.SYNOPSIS
  Custom 6 GB / 16 GB laptop launcher for the VIctory-family harness (CCS03 base).
.DESCRIPTION
  Sets the measured CCS03 switch bundle + 6 GB VRAM overrides + every documented
  black-screen fix, then runs:  victory.exe run <title> --execute --console series-s

  Unknown VICTORY_* variables are ignored by builds that do not implement them, so this
  union bundle (CCS03 + VKarameloVI + Belobug + zsy-miao + Linox switches) is safe on any
  VIctory-family tree.

  Profiles (combine freely):
    Low        1280x720 display mode (recommended on 6 GB)
    Steady     game clock 33 ms/step -> controllable slow motion at 4-9 fps (recommended)
    Smooth     texture pass held to 25 ms / 48 MB per frame (recommended)
    Fast       host-copy refresh on several threads
    Diag       diagnostics build + drop-draw logging (run this when debugging)
    NoWatchdog do not let the title's watchdog kill slow frames (pair with logs!)
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File play.ps1 -Title "D:\g\game_scarlett_master.exe" `
      -VictoryExe "C:\src\CCS03\target\release\victory.exe" -Prewarm
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Title,
  [Parameter(Mandatory = $true)][string]$VictoryExe,
  [ValidateSet('Low','Default','Steady','Smooth','Fast','Diag','NoWatchdog')]
  [string[]]$Profile = @('Low','Steady','Smooth'),
  [switch]$Prewarm,          # warm pipelines before the run (add -ShaderArchives to also translate)
  [string[]]$ShaderArchives, # optional: shader archive paths for 'victory shaders <archives>'
  [switch]$SeriesX,          # debug: Series X profile (isolates the Series S present path)
  [int]$TextureBudgetMB = 768,
  [int]$CardBuffersMB = 512,
  [string]$LogDir = (Join-Path $PSScriptRoot 'logs')
)

$ErrorActionPreference = 'Stop'
$Title = (Resolve-Path $Title).Path
$VictoryExe = (Resolve-Path $VictoryExe).Path
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$runLog = Join-Path $LogDir "run-$stamp.log"

function Set-Env([string]$k, [string]$v) { Set-Item -Path "Env:$k" -Value $v }
function Invoke-Native {
  # Native exes write to stderr; PS 5.1 turns that into ErrorRecords which a
  # 'Stop' preference would escalate. Relax only around the native call.
  param([string[]]$ArgList, [string]$LogFile)
  $eap = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $VictoryExe @ArgList 2>&1 | Tee-Object -FilePath $LogFile }
  finally { $ErrorActionPreference = $eap }
}

# ---- 1. Base bundle: CCS03 measured 8 GB / laptop profile (README "Running") ----
Set-Env VICTORY_DISPLAY_MODE        '1920x1080'
Set-Env VICTORY_RELAY               '2'
Set-Env VICTORY_ASYNC_SUBMIT        '1'
Set-Env VICTORY_QUEUE2              '1'
Set-Env VICTORY_INDIRECT_WINDOW     '1'
Set-Env VICTORY_COPY_PLAIN          '1'
Set-Env VICTORY_TEXTURE_NO_WAIT     '1'
Set-Env VICTORY_WIDE_TEXTURES       '1'
Set-Env VICTORY_TEXTURE_DROP_MIPS   '1'
Set-Env VICTORY_TEXTURE_ROOM_PERCENT '86'
Set-Env VICTORY_CARD_ROOM_FOR_TARGETS_MB '1024'
Set-Env VICTORY_AMBIENT             '0.9'
Set-Env VICTORY_JOIN_PARTS          '1'
Set-Env VICTORY_BACK_OWN_VIEW       '1'
Set-Env VICTORY_INDIRECT_GATHER     '1'
Set-Env VICTORY_CARD_REHASH_RUNS    '1'
Set-Env VICTORY_TEXTURE_BACK        '1'   # boats stop sinking (victory-fork PR 999)
Set-Env VICTORY_CARD_HASH_LEN       '1'

# ---- 2. Black-screen fixes (PORTWATCH_720P_BLACKSCREEN.md) ---------------------
Set-Env VICTORY_OWN_UPSCALER        '1'   # Series S FSR step draws nothing / crashes without it
Set-Env VICTORY_COMPOSE             '1'   # Series S presents two planes; without compose: black menus
Set-Env VICTORY_SHOW_AFTER          '1'   # never present a texture before its upload ran
Set-Env VICTORY_PIPELINE_WAIT_MS    '10000'
Set-Env VICTORY_PIPELINE_PRIORITY   'normal'
Set-Env VICTORY_DYNAMIC_SLOTS       '262144'
Set-Env VICTORY_D3D12_DRED          'light'
Set-Env VICTORY_WAVE_WIDE           '0'
Set-Env VICTORY_BVH_MISS            '1'

# ---- 3. Stage-A speed stack (PORTWATCH_20FPS_WORKAROUND.md) --------------------
Set-Env VICTORY_HOIST_CLAMPS        '7'   # Belobug: GPU 225 -> ~80 ms
Set-Env VICTORY_CARD_BUFFERS_MIN_MB '1'   # VKarameloVI: compares on the GPU
Set-Env VICTORY_HAIR                '0'   # wardevsa: hair sim ~80 ms GPU
Set-Env VICTORY_WIDE_REFRESH        '1'   # CCS03: copies 60-210 -> 38-95 ms
Set-Env VICTORY_TEXTURE_CATCHUP     '0'
Set-Env VICTORY_CARD_FETCH_INFLIGHT '0'   # =1 tripled GPU time on 3 independent tests

# ---- 4. 6 GB overrides ---------------------------------------------------------
Set-Env VICTORY_TEXTURE_BUDGET_MB   "$TextureBudgetMB"
Set-Env VICTORY_CARD_BUFFERS_MB     "$CardBuffersMB"

# ---- 5. Profiles ---------------------------------------------------------------
if ($Profile -contains 'Low')        { Set-Env VICTORY_DISPLAY_MODE '1280x720' }
if ($Profile -contains 'Steady')     { Set-Env VICTORY_GAME_STEP_MS '33' }
if ($Profile -contains 'Smooth')     { Set-Env VICTORY_TEXTURE_STAGE_MS '25'; Set-Env VICTORY_TEXTURE_STAGE_MB '48' }
if ($Profile -contains 'Fast')       { Set-Env VICTORY_TURBO_THREADS '1' }   # Dolberthi worker pool (CCS03 -Fast equivalent)
if ($Profile -contains 'Diag')       {
  Set-Env VICTORY_D3D12_DRED 'faults'
  Write-Host 'Diag: full drop-draw logging needs CCS03''s diagnostics build (their play.ps1 -Diag / SHADERS.md).' -ForegroundColor Yellow
}
if ($Profile -contains 'NoWatchdog') { Set-Env VICTORY_NO_WATCHDOG '1' }

# ---- 6. Prewarm ----------------------------------------------------------------
if ($Prewarm) {
  Write-Host 'Prewarm: warming pipelines (first time = several GB, many minutes)...' -ForegroundColor Yellow
  if ($ShaderArchives) {
    Invoke-Native -ArgList (@('shaders') + $ShaderArchives) -LogFile (Join-Path $LogDir "prewarm-$stamp.log")
  }
  Invoke-Native -ArgList @('warm', '--used') -LogFile (Join-Path $LogDir "warm-$stamp.log")
}

# ---- 7. Launch -----------------------------------------------------------------
$consoleArg = if ($SeriesX) { 'series-x' } else { 'series-s' }
$runArgs = @('run', $Title, '--execute', '--console', $consoleArg)

Write-Host ''
Write-Host "=== Launching ===" -ForegroundColor White
Write-Host "  title    : $Title"
Write-Host "  harness  : $VictoryExe"
Write-Host "  profile  : $($Profile -join ', ')  |  console: --console $consoleArg"
Write-Host "  display  : $($env:VICTORY_DISPLAY_MODE)  |  texture budget: ${TextureBudgetMB} MB  |  card buffers: ${CardBuffersMB} MB"
Write-Host "  log      : $runLog"
Write-Host ''
Write-Host 'CHECK THE LOG after startup: it must name the NVIDIA GPU as the adapter.' -ForegroundColor Cyan
Write-Host 'If it shows Intel, force the dGPU (NVIDIA Control Panel / VICTORY_D3D12_ADAPTER) and rerun.' -ForegroundColor Cyan
Write-Host 'If the screen is black: run fix-blackscreen.ps1.' -ForegroundColor Cyan
Write-Host ''

Invoke-Native -ArgList $runArgs -LogFile $runLog

Write-Host ''
Write-Host "Run finished. Log kept at: $runLog" -ForegroundColor White
