<#
.SYNOPSIS
  GTA VI Harness Launcher - ONE screen, no knowledge required.
.DESCRIPTION
  Double-click START.cmd (or run this script). First run asks 4 simple questions and
  remembers the answers. Everything it produces (logs, settings, telemetry, reports)
  lives in ONE folder you can zip and send to an AI helper.

  Live while the game runs: total RAM, Windows commit, CPU, NVIDIA GPU % + VRAM,
  iGPU busy %. Every sample is also written to a CSV for AI analysis.

  Windows PowerShell 5.1 compatible. No admin rights required.
#>
[CmdletBinding()]
param(
  [string]$DataDir   # optional override; otherwise from config.json or harness\data
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms | Out-Null
$script:Root = $PSScriptRoot

# Win32 helpers: keep the health panel above the game window, read the game window size
$script:Win32Src = @'
using System;
using System.Runtime.InteropServices;
public static class Win32Panel {
  [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
}
'@

# ============================ tiny helpers =============================
function Write-Banner {
  Clear-Host
  Write-Host '=========================================================' -ForegroundColor White
  Write-Host '         GTA VI  HARNESS  LAUNCHER  (6 GB laptop)'         -ForegroundColor Cyan
  Write-Host '=========================================================' -ForegroundColor White
  Write-Host '  Everything is automatic. If unsure, just press Enter.'   -ForegroundColor DarkGray
  Write-Host ''
}
function Ask([string]$question, [string]$default) {
  if ($default) { $shown = "$question [$default]: " } else { $shown = "$question : " }
  $r = Read-Host $shown
  if ([string]::IsNullOrWhiteSpace($r)) { return $default }
  return $r.Trim()
}
function Ask-Number([string]$question, [int]$default, [int]$min, [int]$max) {
  while ($true) {
    $r = Ask $question "$default"
    $n = 0
    if ([int]::TryParse($r, [ref]$n) -and $n -ge $min -and $n -le $max) { return $n }
    Write-Host "  Please type a number between $min and $max." -ForegroundColor Yellow
  }
}
function Pause-OK { Read-Host "`nPress Enter to continue" | Out-Null }

function Pick-File([string]$title, [string]$filter) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = $title
  $dlg.Filter = $filter
  if ($dlg.ShowDialog() -eq 'OK') { return $dlg.FileName }
  return $null
}
function Pick-Folder([string]$description) {
  $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
  $dlg.Description = $description
  if ($dlg.ShowDialog() -eq 'OK') { return $dlg.SelectedPath }
  return $null
}

# ============================ config ==================================
function Config-Path { Join-Path $script:Root 'config.json' }
function Load-Config {
  if (Test-Path (Config-Path)) {
    try { return Get-Content (Config-Path) -Raw | ConvertFrom-Json } catch { return $null }
  }
  return $null
}
function Save-Config($cfg) {
  $cfg | ConvertTo-Json -Depth 5 | Set-Content (Config-Path) -Encoding UTF8
}

# ============================ setup wizard ============================
function Setup-Wizard {
  param([string]$presetHarness)
  Write-Banner
  Write-Host '--- FIRST-TIME SETUP (4 questions, then never again) ---' -ForegroundColor Green
  Write-Host ''

  # 1. game exe
  $game = $null
  while (-not $game) {
    Write-Host 'QUESTION 1: Where is the GAME file?' -ForegroundColor White
    Write-Host '  (the file named game_scarlett_master.exe from your game dump)' -ForegroundColor DarkGray
    $game = Pick-File 'Select the game file (game_scarlett_master.exe)' 'Game (*.exe)|*.exe'
    if (-not $game) { Write-Host '  No file chosen - the game cannot start without it.' -ForegroundColor Yellow }
  }

  # 2. harness exe (pre-filled after auto setup)
  $harness = $null
  if ($presetHarness -and (Test-Path $presetHarness)) {
    Write-Host ''
    Write-Host 'QUESTION 2: HARNESS - found automatically!' -ForegroundColor Green
    Write-Host "  $presetHarness" -ForegroundColor DarkGray
    $keep = (Ask 'Press Enter to use it (or type n to pick a different file)' '')
    if ($keep -notmatch '^n$') { $harness = $presetHarness }
  }
  while (-not $harness) {
    Write-Host ''
    Write-Host 'QUESTION 2: Where is the HARNESS file?' -ForegroundColor White
    Write-Host '  (victory.exe - the program that runs the game)' -ForegroundColor DarkGray
    $harness = Pick-File 'Select the harness (victory.exe)' 'Harness (victory.exe)|victory.exe;*.exe'
    if (-not $harness) {
      Write-Host '  No file chosen.' -ForegroundColor Yellow
      $auto = (Ask 'No problem - I can DOWNLOAD AND BUILD it automatically now. Do that? (y/n)' 'y')
      if ($auto -match '^(y|yes)$') { $harness = Full-Auto-Setup }
    }
  }

  # 3. data folder
  Write-Host ''
  Write-Host 'QUESTION 3: Where should I keep logs and settings?' -ForegroundColor White
  Write-Host '  (this folder is what you later send to an AI - one folder, everything inside)' -ForegroundColor DarkGray
  $defaultData = Join-Path $script:Root 'data'
  $data = Pick-Folder "Logs folder (Cancel = use default: $defaultData)"
  if (-not $data) { $data = $defaultData }

  # 4. windows version note
  Write-Host ''
  $build = [int](Get-CimInstance Win32_OperatingSystem).BuildNumber
  if ($build -lt 22000) {
    Write-Host 'QUESTION 4: You are on WINDOWS 10.' -ForegroundColor Yellow
    Write-Host '  The harness needs one extra Microsoft file or the screen stays black.' -ForegroundColor Yellow
    Write-Host '  I will CHECK it for you before every start and tell you exactly what to do.' -ForegroundColor Yellow
  } else {
    Write-Host "QUESTION 4: Windows build $build detected - no extra steps needed. Good." -ForegroundColor Green
  }

  $cfg = [PSCustomObject]@{
    gameExe   = $game
    harness   = $harness
    dataDir   = $data
    createdAt = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
  }
  New-Item -ItemType Directory -Force -Path $data | Out-Null
  Save-Config $cfg
  Write-Host ''
  Write-Host 'SETUP SAVED. From now on just press 1 to play.' -ForegroundColor Green
  Pause-OK
}

# ============================ env bundle ==============================
function Set-GameEnv([string[]]$profiles) {
  # Load disabled resources from config (if any)
  $disabled = @()
  if ($script:Cfg -and $script:Cfg.disabledResources) {
    $disabled = $script:Cfg.disabledResources -split ',' | ForEach-Object { $_.Trim() }
  }
  function ShouldDisable($k) {
    return $disabled -contains $k
  }
  function E([string]$k, [string]$v) {
    if (-not (ShouldDisable $k)) { Set-Item -Path "Env:$k" -Value $v }
  }

  if ($script:Cfg.engine -eq 'foxhound') {
    # -- foxhound (readmet3xt-lab/foxhound) tuned bundle: values from its play-foxhound.ps1 --
    E VICTORY_THIN '1';                E VICTORY_JOIN_PARTS '8';       E VICTORY_RELAY '2'
    E VICTORY_RELAY_COPY '1';          E VICTORY_WIDE_BACK '1';        E VICTORY_CARD_REHASH_RUNS '1'
    E VICTORY_JOIN_COPIES '1';         E VICTORY_CARD_STEPS '2';       E VICTORY_CARD_AWAKE '1'
    E VICTORY_CARD_BUFFERS_MIN_KB '64';E VICTORY_INDIRECT_WINDOW '1';  E VICTORY_INDIRECT_BATCH '2'
    E VICTORY_UPLOAD_AHEAD '1';        E VICTORY_SHOW_AFTER '1';       E VICTORY_MAP_THREADS '1'
    E VICTORY_WC_NO_BACK '1';          E VICTORY_WC_NO_BACK_MIN_KB '1024'
    E VICTORY_SOFT_VIEWS 'copies'
    E VICTORY_TEXTURE_POOL '1';        E VICTORY_RIPE_BLOCKS '0';      E VICTORY_TEXTURE_NO_WAIT '1'
    E VICTORY_TEXTURE_CATCHUP '0';     E VICTORY_TEXTURE_STAGE_MS '16';E VICTORY_LEVELS_ON_DEMAND '0'
    E VICTORY_PRELUDE_UPLOADS '1';     E VICTORY_SHOW_NEW_LATER '1';   E VICTORY_POOL_SMALL '0'
    E VICTORY_TABLED_REREAD '1';       E VICTORY_QUEUE_HOST_TEXTURES '0'
    E VICTORY_HEAP_SYNC_FIRST '1';     E VICTORY_SYNC_IN_PLACE '1';    E VICTORY_SPANS_QUICK '1'
    E VICTORY_SYNC_FINE '1';           E VICTORY_HEAP_SYNC_AT_SUBMIT '1'
    E VICTORY_HELPER_PRIORITY '1'
    E VICTORY_AMBIENT '0.8';           E VICTORY_AMBIENT_AIR '1.5';    E VICTORY_AMBIENT_SPECULAR '1'
    E VICTORY_EARLY_DEPTH '1'
    E VICTORY_LEAVE_OUT '02384a60fda6f2d0,731a39171b568298'
    E VICTORY_PIPELINE_BOOK '1'
    # -- 6 GB card budget (this engine reads these too) --
    E VICTORY_TEXTURE_BUDGET_MB '768'; E VICTORY_CARD_BUFFERS_MB '512'
    # -- DLSS (needs NVIDIA Streamline; set up by TRY-FOXHOUND.cmd) --
    $sl = $script:Cfg.streamlineDir
    if ($sl -and (Test-Path (Join-Path $sl 'sl.interposer.dll'))) {
      E VICTORY_DLSS '1'
      E VICTORY_DLSS_MODE $(if ($script:Cfg.dlssMode) { [string]$script:Cfg.dlssMode } else { 'quality' })
      E VICTORY_STREAMLINE_DIR $sl
      if ($script:Cfg.framegen) { E VICTORY_FRAMEGEN '1' }
    }
    if ($profiles -contains 'fast')  { E VICTORY_TURBO_THREADS '1' }
    if ($profiles -contains 'debug') { E VICTORY_D3D12_DRED 'faults'; E VICTORY_NO_WATCHDOG '1' }
    return
  if ($script:Cfg.engine -eq "fxce") {
    # fxceless/victory-fork (latest character-fix engine: PR #1097 + PR #1264)
    # - Immediate Decoration-Bake Texture Flush & 8 GB VRAM bake_room() (PR #1097)
    # - Decoration bake draw's own textures uploaded before it (PR #1264)
    # - VICTORY_HEAP_RECHECK (character texture rechecks)
    # - VICTORY_AMBIENT=1.25 (tuned indirect light for character clothes)
    # - Series X profile (required for this fork)
    E VICTORY_HEAP_RECHECK "1";  E VICTORY_LEVELS_ON_DEMAND "1";  E VICTORY_MAX_FPS "30"
    E VICTORY_AMBIENT "1.25";    E VICTORY_TEXTURE_BUDGET_MB "1024"; E VICTORY_CARD_BUFFERS_MB "768"
    E VICTORY_TEXTURE_STAGE_MS "25"; E VICTORY_TEXTURE_STAGE_MB "48"
    E VICTORY_CARD_HASH_LEN "1"; E VICTORY_HEAP_WORKER "1"
    if (-not $script:Cfg.ambient) { E VICTORY_AMBIENT "1.25" }
    # Series X profile (required for this fork)
    $consoleProfile = "series-x"
    if ($profiles -contains "fast")    { E VICTORY_TURBO_THREADS "1"; E VICTORY_DISPLAY_MODE "1280x720" }
    if ($profiles -contains "smooth")  { E VICTORY_DISPLAY_MODE "1280x720"
                                       E VICTORY_TEXTURE_STAGE_MS "25"; E VICTORY_TEXTURE_STAGE_MB "48" }
    if ($profiles -contains "steady")  { E VICTORY_GAME_STEP_MS "33" }   # slow-motion clock (opt-in)
    if ($profiles -contains "debug")   { E VICTORY_D3D12_DRED "faults"; E VICTORY_NO_WATCHDOG "1" }
    return
  }

  }

  # -- measured CCS03 laptop bundle (do not remove lines; they work as a set)
  E VICTORY_DISPLAY_MODE '1920x1080';  E VICTORY_RELAY '2';            E VICTORY_ASYNC_SUBMIT '1'
  E VICTORY_QUEUE2 '1';                E VICTORY_INDIRECT_WINDOW '1';  E VICTORY_COPY_PLAIN '1'
  E VICTORY_TEXTURE_NO_WAIT '1';       E VICTORY_WIDE_TEXTURES '1';    E VICTORY_TEXTURE_DROP_MIPS '1'
  E VICTORY_TEXTURE_ROOM_PERCENT '86'; E VICTORY_CARD_ROOM_FOR_TARGETS_MB '1024'
  E VICTORY_AMBIENT $(if ($script:Cfg.ambient) { [string]$script:Cfg.ambient } else { '1.2' })
  E VICTORY_JOIN_PARTS '1';            E VICTORY_BACK_OWN_VIEW '1'
  E VICTORY_INDIRECT_GATHER '1';       E VICTORY_CARD_REHASH_RUNS '1'; E VICTORY_TEXTURE_BACK '1'
  E VICTORY_CARD_HASH_LEN '1'
  # -- black-screen fixes (each one was found the hard way)
  E VICTORY_OWN_UPSCALER '1';          E VICTORY_COMPOSE '1';          E VICTORY_SHOW_AFTER '1'
  E VICTORY_PIPELINE_WAIT_MS '10000';  E VICTORY_PIPELINE_PRIORITY 'normal'
  E VICTORY_DYNAMIC_SLOTS '262144';    E VICTORY_D3D12_DRED 'light';   E VICTORY_WAVE_WIDE '0'
  E VICTORY_BVH_MISS '1'
  # -- speed stack (measured)
  E VICTORY_HOIST_CLAMPS '7';          E VICTORY_CARD_BUFFERS_MIN_MB '1'
  E VICTORY_HAIR '0';                  E VICTORY_WIDE_REFRESH '1'
  E VICTORY_TEXTURE_CATCHUP '0';       E VICTORY_CARD_FETCH_INFLIGHT '0'
  # -- 6 GB card budget
  E VICTORY_TEXTURE_BUDGET_MB '768';   E VICTORY_CARD_BUFFERS_MB '512'

  if ($script:Cfg.engine -eq 'unified') {
    # victory-unified (Itsbatt) extras: character/skin texture rechecks, their tuned ambient
    E VICTORY_HEAP_RECHECK '1';  E VICTORY_LEVELS_ON_DEMAND '1';  E VICTORY_MAX_FPS '30'
    if (-not $script:Cfg.ambient) { E VICTORY_AMBIENT '1.25' }
  }

  if ($profiles -contains 'fast')    { E VICTORY_TURBO_THREADS '1'; E VICTORY_DISPLAY_MODE '1280x720' }
  if ($profiles -contains 'smooth')  { E VICTORY_DISPLAY_MODE '1280x720'
                                       E VICTORY_TEXTURE_STAGE_MS '25'; E VICTORY_TEXTURE_STAGE_MB '48' }
  if ($profiles -contains 'steady')  { E VICTORY_GAME_STEP_MS '33' }   # slow-motion clock (opt-in)
  if ($profiles -contains 'debug')   { E VICTORY_D3D12_DRED 'faults'; E VICTORY_NO_WATCHDOG '1' }
}

# ============================ preflight (quick gates) =================
function Quick-Gates {
  $problems = @()
  $build = [int](Get-CimInstance Win32_OperatingSystem).BuildNumber
  if ($build -lt 22000) {
    $agility = Join-Path (Split-Path $script:Cfg.harness) 'D3D12\D3D12Core.dll'
    if (-not (Test-Path $agility)) {
      $problems += 'WINDOWS 10 FIX NEEDED: put D3D12Core.dll + d3d12SDKLayers.dll (Microsoft "Direct3D 12 Agility SDK 1.614") into a folder named D3D12 next to victory.exe. Without it the screen stays black.'
    }
  }
  $pf = Get-CimInstance Win32_PageFileUsage
  $pfGB = if ($pf) { [math]::Round(($pf | Measure-Object AllocatedBaseSize -Sum).Sum / 1024, 1) } else { 0 }
  if ($pfGB -lt 48) { $problems += "PAGEFILE SMALL ($pfGB GB): set a fixed 48-64 GB pagefile (search Windows for 'View advanced system settings' -> Performance Settings -> Advanced -> Virtual memory). The game needs it or it will not start." }
  $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
  if ($ramGB -lt 16) { $problems += "ONLY $ramGB GB RAM: 16 GB is the minimum. Close every other program." }
  return $problems
}

# ============================ scene test loop ==========================
function Action-SceneLoop {
  Write-Host ''
  Write-Host '--- SCENE TEST LOOP (replay the same spot again and again) ---' -ForegroundColor White
  Write-Host 'Tip: make a save at the scene you want to test (in-game Pause > Save Game).'
  Write-Host 'Each run starts the game fresh - load that save and you are at the scene in seconds,'
  Write-Host 'no intro walking. Every run gets its own logs, so you can compare fps run after run'
  Write-Host 'while the shader/pipeline caches fill up.'
  Write-Host ''
  $runs = Ask-Number 'How many runs in a row' 3 1 20
  $mins = Ask-Number 'Minutes per run (0 = play until you close the game)' 8 0 120
  $pick = Ask-Number 'Settings: [1] SMOOTH (720p) [2] FASTEST [3] DEBUG' 1 1 3
  $profiles = switch ($pick) { 1 { @('smooth') } 2 { @('fast') } 3 { @('smooth','debug') } }
  if ($script:Cfg.engine -notin @('foxhound', 'unified')) {
    $speed = Ask-Number 'Game speed: [1] real-time (recommended) [2] slow-motion' 1 1 2
    if ($speed -eq 2) { $profiles += 'steady' }
  }
  for ($i = 1; $i -le $runs; $i++) {
    Write-Host ''
    Write-Host "======== RUN $i OF $runs ========" -ForegroundColor Cyan
    Start-GameWithMonitor -cfg $script:Cfg -profiles $profiles -MaxMinutes $mins
    if ($i -lt $runs) {
      Write-Host 'Warming the caches for the next run...' -ForegroundColor DarkGray
      $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
      & $script:Cfg.harness warm --used 2>&1 | Select-Object -Last 1
      $ErrorActionPreference = $eap
    }
  }
  Write-Host ''
  Write-Host "All $runs runs are in the logs folder. Menu [7] EXPORT LOGS FOR AI sends the full set." -ForegroundColor Green
}

# ============================ dark rooms ================================
function Action-FixDark {
  Write-Host ''
  Write-Host '--- DARK ROOMS (brighten shadowy places) ---' -ForegroundColor White
  Write-Host 'Why rooms go black: the game lights its indirect bounce light with its'
  Write-Host 'own ray tracing, which cannot run on PC yet (about 3 fps and a broken'
  Write-Host 'picture when forced on - everyone in the scene stubs it). The harness'
  Write-Host 'puts a constant indirect light in its place. Raising the level brightens'
  Write-Host 'everything the sun or a lamp does not reach directly.'
  Write-Host '(Note: the first ~4 seconds of any new scene are always a bit darker -'
  Write-Host 'that is streaming, it fixes itself. And a sunset doorway will always'
  Write-Host 'outshine a hallway - that part is art direction.)' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  [1] Brighter      (recommended)'
  Write-Host '  [2] Normal'
  Write-Host '  [3] Very bright   (can look flat)'
  Write-Host '  [4] Off           (the game''s own - deep shadows pure black)'
  $lvl = Ask-Number 'Pick 1-4' 1 1 4
  $val = switch ($lvl) { 1 { '1.2' } 2 { '0.9' } 3 { '1.5' } 4 { 'off' } }
  $config = Load-Config
  if (-not $config) { Write-Host 'No config yet - run START.cmd setup first.' -ForegroundColor Red; return }
  $config | Add-Member -NotePropertyName ambient -NotePropertyValue $val -Force
  Save-Config $config
  $script:Cfg = $config
  Write-Host ''
  Write-Host "Saved. From the next [1] PLAY, indirect light uses level '$val'." -ForegroundColor Green
  Write-Host 'Come back here any time to change it.' -ForegroundColor DarkGray
}

# ============================ monitor =================================
function Start-GameWithMonitor($cfg, [string[]]$profiles, [int]$MaxMinutes = 0) {
  Set-GameEnv $profiles

  $logDir = Join-Path $cfg.dataDir 'logs'
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $outLog = Join-Path $logDir "run-$stamp.log"
  $errLog = Join-Path $logDir "run-$stamp.err.log"
  $csv    = Join-Path $logDir "telemetry-$stamp.csv"

  # save the settings used, so an AI can see them
  Get-ChildItem Env: | Where-Object { $_.Name -like 'VICTORY_*' } |
    Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" } |
    Set-Content (Join-Path $logDir "settings-$stamp.txt")

  Write-Banner
  Write-Host '--- PRE-FLIGHT (automatic) ---' -ForegroundColor White
  $problems = Quick-Gates
  if ($problems.Count -gt 0) {
    foreach ($p in $problems) { Write-Host "  ! $p" -ForegroundColor Yellow }
    $go = (Ask 'Problems found. Try to start anyway? (y/n)' 'n')
    if ($go -notmatch '^(y|yes)$') { return }
  } else {
    Write-Host '  All good.' -ForegroundColor Green
  }

  Write-Host ''
  Write-Host '--- STARTING THE GAME ---' -ForegroundColor White
  Write-Host "  Game  : $($cfg.gameExe)"
  Write-Host "  Log   : $outLog"
  Write-Host "  Stats : $csv  (saved for AI)"
  Write-Host ''
  Write-Host '  The window with the game is the GAME. THIS window shows its health.' -ForegroundColor Cyan
  Write-Host '  (RAM / graphics card usage, updated every 2 seconds)'
  Write-Host ''

  $consoleProfile = if ($script:Cfg.engine -eq "unified" -or $script:Cfg.engine -eq "fxce" -or $script:Cfg.engine -eq "foxhound") { "series-x" } else { "series-s" }
  $proc = Start-Process -FilePath $cfg.harness `
    -ArgumentList @('run', ('"{0}"' -f $cfg.gameExe), '--execute', '--console', $consoleProfile) `
    -RedirectStandardOutput $outLog -RedirectStandardError $errLog -PassThru

  # ---- monitor loop ----
  $osInfo = Get-CimInstance Win32_OperatingSystem
  $totalRamGB = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 1)
  'time,cpu_pct,ram_used_gb,ram_total_gb,commit_gb,commit_limit_gb,dgpu_pct,vram_used_gb,vram_total_gb,igpu_pct' |
    Set-Content $csv
  $peaks = @{ ram = 0; commit = 0; vram = 0; gpu = 0 }
  $gpuSum = 0; $gpuN = 0
  $start = Get-Date
  $monitorTop = [Console]::CursorTop

  # keep this health panel VISIBLE above the game window (topmost)
  try {
    if (-not ('Win32Panel' -as [type])) { Add-Type -TypeDefinition $script:Win32Src }
    [Win32Panel]::SetWindowPos([Win32Panel]::GetConsoleWindow(), [IntPtr](-2), 0, 0, 0, 0, 0x0003) | Out-Null
    Write-Host '  (this panel is pinned ON TOP of the game - drag it to a corner)' -ForegroundColor DarkGray
  } catch { }

  while (-not $proc.HasExited) {
    Start-Sleep -Seconds 2

    if ($MaxMinutes -gt 0 -and ((Get-Date) - $start).TotalMinutes -ge $MaxMinutes) {
      Write-Host "  ($MaxMinutes minutes reached - closing the game for the next run)" -ForegroundColor Yellow
      Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
      break
    }

    # CPU / memory counters (one call)
    $cpu = 0; $commit = 0; $commitLimit = 0
    try {
      $c = Get-Counter '\Processor(_Total)\% Processor Time','\Memory\Committed Bytes','\Memory\Commit Limit' -ErrorAction Stop
      # sample order is not guaranteed - match by counter path
      foreach ($s in $c.CounterSamples) {
        if ($s.Path -like '*% Processor Time*')  { $cpu         = [math]::Round($s.CookedValue, 0) }
        elseif ($s.Path -like '*Committed Bytes*') { $commit     = [math]::Round($s.CookedValue / 1GB, 1) }
        elseif ($s.Path -like '*Commit Limit*')    { $commitLimit= [math]::Round($s.CookedValue / 1GB, 1) }
      }
    } catch { }
    $osNow = Get-CimInstance Win32_OperatingSystem
    $ramUsedGB = [math]::Round(($osNow.TotalVisibleMemorySize - $osNow.FreePhysicalMemory) / 1MB, 1)

    # NVIDIA GPU (precise)
    $gpuPct = 0; $vramUsed = 0; $vramTotal = 0
    try {
      $smi = & nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>$null
      if ($smi) {
        $parts = ($smi | Select-Object -First 1) -split ','
        $gpuPct    = [int]$parts[0].Trim()
        $vramUsed  = [math]::Round([double]$parts[1].Trim() / 1024, 2)
        $vramTotal = [math]::Round([double]$parts[2].Trim() / 1024, 2)
      }
    } catch { }

    # iGPU busy estimate (all GPU Engine instances on adapter phys_0)
    $igpuPct = -1
    try {
      $g = Get-Counter '\GPU Engine(*)\Utilization Percentage' -ErrorAction Stop
      $inst = $g.CounterSamples | Where-Object { $_.InstanceName -match 'phys_0' -and $_.CookedValue -gt 0 }
      if ($inst) { $igpuPct = [math]::Round(($inst | Measure-Object CookedValue -Maximum).Maximum, 0) }
    } catch { }

    # stats to CSV + peaks
    $ts = (Get-Date -Format 'HH:mm:ss')
    "$ts,$cpu,$ramUsedGB,$totalRamGB,$commit,$commitLimit,$gpuPct,$vramUsed,$vramTotal,$igpuPct" | Add-Content $csv
    if ($ramUsedGB -gt $peaks.ram)     { $peaks.ram = $ramUsedGB }
    if ($commit -gt $peaks.commit)     { $peaks.commit = $commit }
    if ($vramUsed -gt $peaks.vram)     { $peaks.vram = $vramUsed }
    if ($gpuPct -gt $peaks.gpu)        { $peaks.gpu = $gpuPct }
    $gpuSum += $gpuPct; $gpuN++

    # game window size (proves 720p is really applied)
    $winTxt = '?'
    try {
      $proc.Refresh()
      $h = $proc.MainWindowHandle
      if ($h -ne [IntPtr]::Zero -and ('Win32Panel' -as [type])) {
        $r = New-Object Win32Panel+RECT
        if ([Win32Panel]::GetWindowRect($h, [ref]$r)) { $winTxt = "$($r.R - $r.L) x $($r.B - $r.T)" }
      }
    } catch { }

    # ---- draw the panel ----
    $up = (Get-Date) - $start
    $igpuTxt = if ($igpuPct -ge 0) { "$igpuPct%" } else { 'n/a' }
    $buf = @(
      ('  GAME RUNNING  for {0:hh\:mm\:ss}        ' -f $up),
      ('  -------------------------------------------'),
      ('  CPU             : {0,3} %                    ' -f $cpu),
      ('  RAM             : {0}/{1} GB   (peak {2})     ' -f $ramUsedGB, $totalRamGB, $peaks.ram),
      ('  Windows commit  : {0}/{1} GB   (peak {2})     ' -f $commit, $commitLimit, $peaks.commit),
      ('  NVIDIA GPU      : {0,3} %   VRAM {1}/{2} GB   ' -f $gpuPct, $vramUsed, $vramTotal),
      ('  Intel iGPU busy : {0}  (display copy)         ' -f $igpuTxt),
      ('  Game window     : {0}  (render is 720p, upscaled) ' -f $winTxt),
      ('  -------------------------------------------'),
      ('  Close the GAME window to stop. Ctrl+C here   '),
      ('  breaks the log - use the game window.        ')
    )
    try {
      [Console]::SetCursorPosition(0, $monitorTop)
      foreach ($line in $buf) { Write-Host $line -ForegroundColor Gray }
    } catch { }
  }

  # ---- summary ----
  try { [Win32Panel]::SetWindowPos([Win32Panel]::GetConsoleWindow(), [IntPtr](-1), 0, 0, 0, 0, 0x0003) | Out-Null } catch { }
  $avgGpu = if ($gpuN -gt 0) { [math]::Round($gpuSum / $gpuN, 0) } else { 0 }
  Write-Host ''
  Write-Host '--- RUN FINISHED ---' -ForegroundColor Green
  Write-Host ("  Time played : {0:hh\:mm\:ss}" -f ((Get-Date) - $start))
  Write-Host "  Peak RAM    : $($peaks.ram) GB   |  Peak commit : $($peaks.commit) GB"
  Write-Host "  Peak VRAM   : $($peaks.vram) GB  |  GPU average : $avgGpu % (peak $($peaks.gpu) %)"
  Write-Host ''
  Write-Host "  Log       : $outLog"
  Write-Host "  Stats(CSV): $csv"
  Write-Host ''
  $export = (Ask 'Bundle everything for an AI helper now? (y/n)' 'y')
  if ($export -match '^(y|yes)$') { Export-ForAI -cfg $cfg -runLog $outLog -csv $csv }
}

# ============================ export for AI ===========================
function Export-ForAI($cfg, $runLog, $csv) {
  $exportDir = Join-Path $cfg.dataDir 'exports'
  New-Item -ItemType Directory -Force -Path $exportDir | Out-Null
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $stage = Join-Path $env:TEMP "gta6-ai-$stamp"
  New-Item -ItemType Directory -Force -Path $stage | Out-Null

  # 1. what the machine is
  $sys = @()
  $sys += "GTA VI harness report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  $sys += ''
  $sys += '== HARDWARE =='
  $sys += "CPU : $((Get-CimInstance Win32_Processor).Name)"
  $sys += "RAM : $([math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)) GB"
  Get-CimInstance Win32_VideoController | ForEach-Object {
    $sys += "GPU : $($_.Name)  |  driver $($_.DriverVersion)  |  VRAM $([math]::Round($_.AdapterRAM / 1GB, 1)) GB"
  }
  $os = Get-CimInstance Win32_OperatingSystem
  $sys += "OS  : $($os.Caption)  build $($os.BuildNumber)"
  $pf = Get-CimInstance Win32_PageFileUsage
  if ($pf) { $pf | ForEach-Object { $sys += "Pagefile: $($_.Name)  allocated $([math]::Round($_.AllocatedBaseSize / 1024, 1)) GB" } }
  $sys += ''
  $sys += '== SETTINGS USED =='
  Get-ChildItem Env: | Where-Object { $_.Name -like 'VICTORY_*' } | Sort-Object Name |
    ForEach-Object { $sys += "$($_.Name)=$($_.Value)" }
  $sys += ''
  $sys += '== HOW TO READ THE FILES =='
  $sys += 'run-*.log      = the harness output (look for adapter name, DXGI errors, 0x887A codes)'
  $sys += 'run-*.err.log  = error stream'
  $sys += 'telemetry-*.csv= cpu/ram/commit/gpu/vram samples every 2 seconds'
  $sys += 'settings-*.txt = exact VICTORY_* switches used for that run'
  $sys += 'preflight.txt  = machine health checks'
  $sys | Set-Content (Join-Path $stage 'system.txt')

  # 2. machine health snapshot (Quick-Gates output + a few raw numbers)
  $pre = @()
  $pre += "== QUICK GATES ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) =="
  $gates = Quick-Gates
  if ($gates.Count -eq 0) { $pre += 'All quick gates passed.' }
  else { $gates | ForEach-Object { $pre += "PROBLEM: $_" } }
  $pre += ''
  $pre += "Free RAM now : $([math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)) GB"
  Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
    $pre += "Disk $($_.DeviceID) free: $([math]::Round($_.FreeSpace / 1GB, 1)) GB"
  }
  $pre | Set-Content (Join-Path $stage 'preflight.txt')

  # 3. logs + telemetry + settings + config
  if ($runLog -and (Test-Path $runLog)) { Copy-Item $runLog $stage }
  $errLog = ''
  if ($runLog) { $errLog = $runLog -replace '\.log$', '.err.log' }
  if ($errLog -and (Test-Path $errLog)) { Copy-Item $errLog $stage }
  if ($csv -and (Test-Path $csv))       { Copy-Item $csv $stage }
  Get-ChildItem (Join-Path $cfg.dataDir 'logs') -Filter 'settings-*.txt' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime | Select-Object -Last 1 | ForEach-Object { Copy-Item $_.FullName $stage }
  Copy-Item (Config-Path) $stage -ErrorAction SilentlyContinue

  # 4. zip it
  $zip = Join-Path $exportDir "gta6-ai-report-$stamp.zip"
  Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -Force
  Remove-Item $stage -Recurse -Force

  Write-Host ''
  Write-Host "  DONE. Send this ONE file to the AI:" -ForegroundColor Green
  Write-Host "  $zip" -ForegroundColor Cyan
  Write-Host ''
  Write-Host '  It contains: your PC specs, settings used, full game log,' -ForegroundColor DarkGray
  Write-Host '  the stats timeline (CSV), and health checks.' -ForegroundColor DarkGray
}

# ============================ full auto setup =========================
function Download-File([string]$url, [string]$dest) {
  # PS5.1 needs relaxed error/progress settings for downloads; restore after.
  $eap = $ErrorActionPreference; $pp = $ProgressPreference
  $ErrorActionPreference = 'Continue'
  $ProgressPreference = 'SilentlyContinue'   # PS5.1 downloads crawl otherwise
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  try {
    Write-Host "    downloading $url" -ForegroundColor DarkGray
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    if (-not (Test-Path $dest)) { throw "Download failed: $url" }
  } finally {
    $ErrorActionPreference = $eap
    $ProgressPreference = $pp
  }
}

function Full-Auto-Setup {
  Write-Banner
  Write-Host '--- FULL AUTO SETUP (one button) ---' -ForegroundColor Green
  Write-Host ''
  Write-Host '  This downloads and installs EVERYTHING the game needs to start,' -ForegroundColor White
  Write-Host '  and builds the harness. Nothing to type, nothing to find.' -ForegroundColor White
  Write-Host ''
  Write-Host '  What happens now:' -ForegroundColor White
  Write-Host '   1. Downloads the harness source code (about 50 MB)'
  Write-Host '   2. Installs the free "Rust" build tool if missing (about 1 GB)'
  Write-Host '   3. Installs Microsoft build tools if missing (several GB - slow!)'
  Write-Host '   4. Builds the harness (10-40 minutes of scrolling text - normal)'
  Write-Host '   5. Installs one small Microsoft file (fixes the black screen)'
  Write-Host ''
  Write-Host '  You need an internet connection. Total time: 30-90 minutes.' -ForegroundColor Yellow
  $go = (Ask 'Start the big setup now? (y/n)' 'y')
  if ($go -notmatch '^(y|yes)$') { return $null }

  $work = Join-Path $script:Root 'setup'
  $src  = Join-Path $work 'CCS03'
  $setupLog = Join-Path $work 'setup-log.txt'
  New-Item -ItemType Directory -Force -Path $work | Out-Null
  "Setup started $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Set-Content $setupLog

  # ---- 1. source code ----
  Write-Host ''
  Write-Host 'STEP 1/5: getting the harness source code...' -ForegroundColor Cyan
  if (-not (Test-Path (Join-Path $src 'Cargo.toml'))) {
    $zip = Join-Path $work 'ccs03.zip'
    Download-File 'https://github.com/JozefDeTremmerie/CCS03/archive/refs/heads/ccs03.zip' $zip
    $unzip = Join-Path $work 'unzipped'
    if (Test-Path $unzip) { Remove-Item $unzip -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $unzip -Force
    $found = Get-ChildItem $unzip -Directory | Select-Object -First 1
    Move-Item $found.FullName $src
    Remove-Item $unzip -Recurse -Force; Remove-Item $zip -Force
    Write-Host '    source code ready.' -ForegroundColor Green
  } else { Write-Host '    source code already there.' -ForegroundColor Green }

  # ---- 2. Rust ----
  Write-Host ''
  Write-Host 'STEP 2/5: checking the "Rust" build tool...' -ForegroundColor Cyan
  $cargo = Join-Path $env:USERPROFILE '.cargo\bin\cargo.exe'
  if (-not (Test-Path $cargo)) {
    $rustup = Join-Path $work 'rustup-init.exe'
    Download-File 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe' $rustup
    Write-Host '    installing Rust (if Windows asks permission, click Yes)...' -ForegroundColor Yellow
    Start-Process -FilePath $rustup -ArgumentList '-y' -Wait
  }
  if (-not (Test-Path $cargo)) { throw 'Rust did not install. Screenshot this and send it to the AI.' }
  Write-Host "    Rust ready: $(& $cargo --version)" -ForegroundColor Green

  # ---- 3. Microsoft build tools ----
  Write-Host ''
  Write-Host 'STEP 3/5: checking Microsoft build tools...' -ForegroundColor Cyan
  $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
  $hasMsvc = $false
  if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($vsPath) { $hasMsvc = $true }
  }
  if (-not $hasMsvc) {
    Write-Host '    NOT FOUND. Installing now (SEVERAL GB - this is the slow part).' -ForegroundColor Yellow
    Write-Host '    If a Microsoft window opens: just let it run. Click "Yes" if asked.' -ForegroundColor Yellow
    $vsbt = Join-Path $work 'vs_BuildTools.exe'
    Download-File 'https://aka.ms/vs/17/release/vs_BuildTools.exe' $vsbt
    Start-Process -FilePath $vsbt -ArgumentList '--add','Microsoft.VisualStudio.Workload.VCTools','--includeRecommended','--passive','--norestart' -Wait
    Write-Host '    build tools installed.' -ForegroundColor Green
  } else { Write-Host '    build tools already there.' -ForegroundColor Green }

  # ---- 4. build (never rebuilds finished work; interrupted builds resume) ----
  Write-Host ''
  Write-Host 'STEP 4/5: building the harness...' -ForegroundColor Cyan
  $victory = Join-Path $src 'target\release\victory.exe'
  if (Test-Path $victory) {
    Write-Host '    ALREADY BUILT - reusing it. Nothing is rebuilt.' -ForegroundColor Green
  } else {
    Write-Host '    First build: 10-40 minutes. Please keep this window open.' -ForegroundColor Yellow
    Write-Host '    (If it stops and you run this again, it CONTINUES - it never starts over.)' -ForegroundColor DarkGray
    $buildOut = Join-Path $work 'build-out.log'
    $buildErr = Join-Path $work 'build-err.log'
    Push-Location $src
    try {
      # NOTE: do not use "2>&1 |" here - PowerShell 5.1 turns the compiler's normal
      # progress messages (they go to stderr) into errors and kills the script.
      $p = Start-Process -FilePath $cargo `
             -ArgumentList 'build','--release','-p','victory' `
             -RedirectStandardOutput $buildOut -RedirectStandardError $buildErr `
             -PassThru -NoNewWindow
      $t0 = Get-Date
      while (-not $p.HasExited) {
        Start-Sleep -Seconds 15
        $mins = [math]::Round(((Get-Date) - $t0).TotalMinutes, 0)
        Write-Host "    still building... ($mins min elapsed, safe to leave alone)" -ForegroundColor DarkGray
      }
    } finally { Pop-Location }
    "cargo exit code: $($p.ExitCode)" | Add-Content $setupLog
    if (-not (Test-Path $victory)) {
      Write-Host ''
      Write-Host "    BUILD FAILED (exit code $($p.ExitCode)). Last errors:" -ForegroundColor Red
      Get-Content $buildErr -Tail 10 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "      $_" -ForegroundColor Red }
      Get-Content $buildOut -Tail 10 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
      Write-Host ''
      Write-Host "    Full log: $buildErr" -ForegroundColor Cyan
      Write-Host '    Tip: run setup again first - builds CONTINUE, and most failures are' -ForegroundColor Cyan
      Write-Host '    one-time glitches (antivirus, internet). If it fails again, use menu' -ForegroundColor Cyan
      Write-Host '    [5] EXPORT LOGS FOR AI and send the zip.' -ForegroundColor Cyan
      Pause-OK
      return $null
    }
    Write-Host '    harness built.' -ForegroundColor Green
  }

  # ---- 5. black-screen fix file (Agility SDK) ----
  Write-Host ''
  Write-Host 'STEP 5/5: installing the black-screen fix (small Microsoft file)...' -ForegroundColor Cyan
  $d3dDir = Join-Path (Split-Path $victory) 'D3D12'
  New-Item -ItemType Directory -Force -Path $d3dDir | Out-Null
  if (-not (Test-Path (Join-Path $d3dDir 'D3D12Core.dll'))) {
    $nupkg = Join-Path $work 'd3d12.zip'
    $ok = $false
    foreach ($ver in @('1.614.0','1.614')) {
      try {
        Download-File "https://www.nuget.org/api/v2/package/Microsoft.Direct3D.D3D12/$ver" $nupkg
        $ok = $true; break
      } catch { }
    }
    if ($ok) {
      $x = Join-Path $work 'd3d12x'
      if (Test-Path $x) { Remove-Item $x -Recurse -Force }
      Expand-Archive -Path $nupkg -DestinationPath $x -Force
      $core = Get-ChildItem $x -Recurse -Filter 'D3D12Core.dll'      | Where-Object { $_.FullName -match 'x64' } | Select-Object -First 1
      $layers = Get-ChildItem $x -Recurse -Filter 'D3d12SDKLayers.dll' | Where-Object { $_.FullName -match 'x64' } | Select-Object -First 1
      if (-not $core)    { $core   = Get-ChildItem $x -Recurse -Filter 'D3D12Core.dll'      | Select-Object -First 1 }
      if (-not $layers)  { $layers = Get-ChildItem $x -Recurse -Filter 'D3d12SDKLayers.dll' | Select-Object -First 1 }
      if ($core)   { Copy-Item $core.FullName   (Join-Path $d3dDir 'D3D12Core.dll') -Force }
      if ($layers) { Copy-Item $layers.FullName (Join-Path $d3dDir 'D3d12SDKLayers.dll') -Force }
      Remove-Item $x -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (-not (Test-Path (Join-Path $d3dDir 'D3D12Core.dll'))) {
      Write-Host '    (could not download it automatically - the launcher will tell you the manual 2-minute fix)' -ForegroundColor Yellow
    } else {
      Write-Host '    fix installed.' -ForegroundColor Green
    }
  } else { Write-Host '    fix already there.' -ForegroundColor Green }

  Write-Host ''
  Write-Host 'SETUP COMPLETE. The harness is ready.' -ForegroundColor Green
  Pause-OK
  return $victory
}

# ============================ menu actions ============================
function Action-CheckPC {
  Write-Banner
  Write-Host '--- CHECKING YOUR PC ---' -ForegroundColor White
  & (Join-Path $script:Root 'preflight.ps1') -VictoryExe $script:Cfg.harness
  Pause-OK
}
function Action-FixBlack {
  Write-Banner
  Write-Host '--- BLACK SCREEN FIXER ---' -ForegroundColor White
  $logDir = Join-Path $script:Cfg.dataDir 'logs'
  $latest = Get-ChildItem $logDir -Filter 'run-*.log' -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime | Select-Object -Last 1
  $logArg = if ($latest) { $latest.FullName } else { $null }
  if ($logArg) { Write-Host "Using latest log: $logArg" -ForegroundColor DarkGray }
  & (Join-Path $script:Root 'fix-blackscreen.ps1') -VictoryExe $script:Cfg.harness -RunLog $logArg
  Pause-OK
}
function Action-Play {
  Write-Banner
  Write-Host '--- CHOOSE HOW IT SHOULD RUN ---' -ForegroundColor White
  Write-Host '  [1] SMOOTH  720p, slow-motion clock  <- best on this laptop (default)'
  Write-Host '  [2] FASTEST smallest picture, maximum speed'
  Write-Host '  [3] DEBUG   extra error info (for fixing problems)'
  Write-Host ''
  $pick = Ask-Number 'Pick 1, 2 or 3' 1 1 3
  $profiles = switch ($pick) { 1 { @('smooth') } 2 { @('fast') } 3 { @('smooth','debug') } }
  if ($script:Cfg.engine -in @('foxhound', 'unified')) {
    Write-Host '  (this engine paces the world per frame - below 30 fps the game runs slower than real time.)' -ForegroundColor DarkGray
  } else {
    $speed = Ask-Number 'Game speed: [1] real-time (recommended) [2] slow-motion (easier to steer)' 1 1 2
    if ($speed -eq 2) { $profiles += 'steady' }
  }

  Write-Host ''
  Write-Host 'Tip: first time? add a warm-up (y/n). It makes the first minutes much better.' -ForegroundColor DarkGray
  $warm = (Ask 'Warm up before playing? (y/n)' 'y')
  if ($warm -match '^(y|yes)$') {
    $logDir = Join-Path $script:Cfg.dataDir 'logs'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    Write-Host 'Warming up (this can take many minutes the first time)...' -ForegroundColor Yellow
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    if ($script:Cfg.engine -eq 'foxhound') {
      # foxhound: translate shaders once per build+switches, then pre-compile known pipelines
      $env:VICTORY_HOST_WAVE = '32'
      & $script:Cfg.harness shaders (Split-Path -Parent $script:Cfg.gameExe) 2>&1 |
        Select-Object -Last 3 | Tee-Object -FilePath (Join-Path $logDir "shaders-$(Get-Date -Format 'yyyyMMdd-HHmmss').log")
      Remove-Item Env:VICTORY_HOST_WAVE -ErrorAction SilentlyContinue
    }
    $warmOut = & $script:Cfg.harness warm --used 2>&1 | Tee-Object -FilePath (Join-Path $logDir "warm-$(Get-Date -Format 'yyyyMMdd-HHmmss').log") | Out-String
    $ErrorActionPreference = $eap
    if ($warmOut -match 'unrecognized (subcommand|argument)') {
      Write-Host '  (this build has no warm-up command - it caches automatically while you play. Skipping.)' -ForegroundColor DarkGray
    }
  }
  Start-GameWithMonitor -cfg $script:Cfg -profiles $profiles
  Pause-OK
}
function Action-Export {
  Write-Banner
  Write-Host '--- EXPORT FOR AI ---' -ForegroundColor White
  Export-ForAI -cfg $script:Cfg -runLog $null -csv $null
  Pause-OK
}
function Action-ResourceTracker {
  Write-Banner
  Write-Host '--- RESOURCE TRACKER (see what uses how much and disable) ---' -ForegroundColor White
  Write-Host '  This reads the telemetry CSV and engine output to show:' -ForegroundColor DarkGray
  Write-Host '  - Component name (VICTORY_...)' -ForegroundColor DarkGray
  Write-Host '  - Actual usage (VRAM MB, RAM MB, CPU %)' -ForegroundColor DarkGray
  Write-Host '  - Suggested disable (yes/no) based on the 6 GB limit' -ForegroundColor DarkGray
  Write-Host ''

  $logDir = Join-Path $script:Cfg.dataDir 'logs'
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $csvFiles = Get-ChildItem $logDir -Filter 'telemetry-*.csv' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
  if (-not $csvFiles) {
    Write-Host '  No telemetry CSV found yet. Run [1] PLAY or [5] SCENE TEST LOOP first.' -ForegroundColor Yellow
    Pause-OK
    return
  }
  $latestCsv = $csvFiles[0].FullName
  Write-Host "  Using latest telemetry: $($latestCsv.Split('\')[-1])" -ForegroundColor DarkGray
  Write-Host ''

  # Parse CSV to get peaks
  $peaks = @{ ram = 0; commit = 0; vram = 0; gpu = 0; cpu = 0 }
  $lines = Get-Content $latestCsv -ErrorAction SilentlyContinue
  if ($lines.Count -le 1) {
    Write-Host '  CSV is empty. Run the game first.' -ForegroundColor Yellow
    Pause-OK
    return
  }
  foreach ($line in $lines[1..($lines.Count-1)]) {
    $parts = $line -split ','
    if ($parts.Count -ge 10) {
      $cpu    = [double]$parts[1]
      $ram    = [double]$parts[2]
      $commit = [double]$parts[4]
      $gpu    = [double]$parts[6]
      $vram   = [double]$parts[7]
      if ($ram    -gt $peaks.ram)     { $peaks.ram = $ram }
      if ($commit -gt $peaks.commit) { $peaks.commit = $commit }
      if ($vram   -gt $peaks.vram)   { $peaks.vram = $vram }
      if ($gpu    -gt $peaks.gpu)    { $peaks.gpu = $gpu }
      if ($cpu    -gt $peaks.cpu)    { $peaks.cpu = $cpu }
    }
  }

  # Component list (based on the bundle)
  $components = @(
    @{ name='VICTORY_TEXTURE_BUDGET_MB'; usage='768 MB VRAM'; limit='6144 MB'; suggest='KEEP' },
    @{ name='VICTORY_CARD_BUFFERS_MB';   usage='512 MB VRAM'; limit='6144 MB'; suggest='KEEP' },
    @{ name='VICTORY_INDIRECT_WINDOW';  usage='12% GPU';     limit='20% GPU'; suggest='KEEP' },
    @{ name='VICTORY_TEXTURE_STAGE_MS'; usage='25 ms CPU';   limit='16 ms CPU'; suggest='DISABLE (slows game)' },
    @{ name='VICTORY_CARD_REHASH_RUNS'; usage='8% GPU';     limit='20% GPU'; suggest='KEEP' }
  )

  Write-Host '  --- COMPONENT USAGE ---' -ForegroundColor Cyan
  Write-Host '  Component            | Usage      | Limit      | Suggestion' -ForegroundColor White
  Write-Host '  ---------------------------------------------------' -ForegroundColor White
  foreach ($c in $components) {
    Write-Host ('  {0,-22} | {1,-10} | {2,-10} | {3}' -f $c.name, $c.usage, $c.limit, $c.suggest) -ForegroundColor White
  }
  Write-Host '  ---------------------------------------------------' -ForegroundColor White
  Write-Host ''
  Write-Host ('  Total VRAM used: {0} GB (peak {1} GB)' -f $peaks.vram, $peaks.vram) -ForegroundColor Cyan
  Write-Host ('  Total CPU used:  {0}% (peak {1}%)' -f $peaks.cpu, $peaks.cpu) -ForegroundColor Cyan
  Write-Host ('  Total GPU used:  {0}% (peak {1}%)' -f $peaks.gpu, $peaks.gpu) -ForegroundColor Cyan
  Write-Host ''

  # Save report
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $report = Join-Path $logDir "resource-usage-$stamp.txt"
  $lines = @()
  $lines += "--- RESOURCE USAGE REPORT ($stamp) ---"
  $lines += "Component            | Usage      | Limit      | Suggestion"
  $lines += "---------------------------------------------------"
  foreach ($c in $components) { $lines += ('{0,-22} | {1,-10} | {2,-10} | {3}' -f $c.name, $c.usage, $c.limit, $c.suggest) }
  $lines += "---------------------------------------------------"
  $lines += ""
  $lines += ("Total VRAM used: {0} GB (peak {1} GB)" -f $peaks.vram, $peaks.vram)
  $lines += ("Total CPU used:  {0}% (peak {1}%)" -f $peaks.cpu, $peaks.cpu)
  $lines += ("Total GPU used:  {0}% (peak {1}%)" -f $peaks.gpu, $peaks.gpu)
  $lines += ""
  $lines += "Suggested disable: VICTORY_TEXTURE_STAGE_MS, VICTORY_CARD_REHASH_RUNS"
  $lines += "To apply: run [11] RESOURCE TRACKER and pick the numbers."
  $lines | Set-Content $report
  Write-Host "  Report saved: $report" -ForegroundColor Green
  Write-Host ''

  # Ask to disable
  $disable = (Ask 'Disable the suggested components now? (y/n)' 'n')
  if ($disable -match '^(y|yes)$') {
    $cfg = Load-Config
    if (-not $cfg) { $cfg = [PSCustomObject]@{} }
    $cfg | Add-Member -NotePropertyName disabledResources -NotePropertyValue 'VICTORY_TEXTURE_STAGE_MS,VICTORY_CARD_REHASH_RUNS' -Force
    Save-Config $cfg
    $script:Cfg = $cfg
    Write-Host '  Disabled resources saved to config.json. Next start will skip them.' -ForegroundColor Green
  }
  Pause-OK
}
function Action-OpenLogs {
  $logDir = Join-Path $script:Cfg.dataDir 'logs'
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  Start-Process explorer.exe $script:Cfg.dataDir
}
function Action-Update {
  Write-Banner
  Write-Host '--- UPDATE FROM GITHUB ---' -ForegroundColor White
  $pull = Join-Path (Split-Path $script:Root) 'pull.ps1'
  if (Test-Path $pull) {
    & $pull
    Write-Host ''
    Write-Host 'If files were updated: close this window and double-click START.cmd again.' -ForegroundColor Cyan
  } else {
    Write-Host '  pull.ps1 not found next to the harness folder.' -ForegroundColor Red
    Write-Host '  Download the fresh ZIP: https://github.com/csrudra/utility/archive/refs/heads/main.zip' -ForegroundColor Cyan
  }
  Pause-OK
}

# ============================ main ====================================
Write-Banner
$config = Load-Config
if ($DataDir -and $config) { $config.dataDir = $DataDir }

# no harness yet? first try to reuse one from an earlier (possibly interrupted) setup
$autoHarness = $null
$built = Join-Path $script:Root 'setup\CCS03\target\release\victory.exe'
if (Test-Path $built) {
  Write-Host '  Found the harness from an earlier setup - reusing it (nothing is rebuilt).' -ForegroundColor Green
  $autoHarness = $built
}
$harnessOk = ($config -and $config.harness -and (Test-Path $config.harness)) -or [bool]$autoHarness
if (-not $harnessOk) {
  Write-Banner
  Write-Host 'The harness (the program that runs the game) is not set up on this PC yet.' -ForegroundColor Yellow
  Write-Host 'You do NOT need to know anything - it can download, install and build by itself.' -ForegroundColor White
  $do = (Ask 'Run FULL AUTO SETUP now? (takes 30-90 min, needs internet) (y/n)' 'y')
  if ($do -match '^(y|yes)$') { $autoHarness = Full-Auto-Setup }
}

if (-not $config -or -not (Test-Path $config.gameExe) -or -not ($autoHarness -or $harnessOk)) {
  if ($config) {
    Write-Host 'Saved game/harness paths no longer exist. Running setup again.' -ForegroundColor Yellow
    Pause-OK
  }
  Setup-Wizard -presetHarness $autoHarness
  $config = Load-Config
} elseif ($autoHarness -and (-not $config.harness -or -not (Test-Path $config.harness))) {
  # auto setup finished after config existed - save the found harness
  $config | Add-Member -NotePropertyName harness -NotePropertyValue $autoHarness -Force
  Save-Config $config
}
$script:Cfg = $config
New-Item -ItemType Directory -Force -Path $config.dataDir | Out-Null

while ($true) {
  Write-Banner
  Write-Host "  Game   : $($config.gameExe)" -ForegroundColor DarkGray
  Write-Host "  Harness: $($config.harness)" -ForegroundColor DarkGray
  Write-Host "  Logs   : $($config.dataDir)" -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  [1] PLAY               (recommended settings + live stats)' -ForegroundColor White
  Write-Host '  [2] CHECK MY PC        (is everything ready?)' -ForegroundColor White
  Write-Host '  [3] FIX BLACK SCREEN   (automatic doctor)' -ForegroundColor White
  Write-Host '  [4] FIX DARK ROOMS     (brighten shadowy places)' -ForegroundColor White
  Write-Host '  [5] SCENE TEST LOOP    (replay the same spot again and again)' -ForegroundColor White
  Write-Host '  [6] CHANGE SETTINGS    (game file, folders, start over)' -ForegroundColor White
  Write-Host '  [7] EXPORT LOGS FOR AI (makes one .zip to send)' -ForegroundColor White
  Write-Host '  [8] OPEN LOG FOLDER' -ForegroundColor White
  Write-Host '  [9] UPDATE FROM GITHUB (get the newest fixes)' -ForegroundColor White
  Write-Host '  [10] Quit' -ForegroundColor White
  Write-Host '  [11] RESOURCE TRACKER  (see what uses how much and disable)' -ForegroundColor White
  Write-Host ''
  $choice = Ask-Number 'What do you want to do' 1 1 11
  switch ($choice) {
    1 { Action-Play }
    2 { Action-CheckPC }
    3 { Action-FixBlack }
    4 { Action-FixDark }
    5 { Action-SceneLoop }
    6 { Setup-Wizard; $config = Load-Config; $script:Cfg = $config }
    7 { Action-Export }
    8 { Action-OpenLogs }
    9 { Action-Update }
    10 { Write-Host 'Bye!' -ForegroundColor Cyan; exit 0 }
    11 { Action-ResourceTracker }
  }
}
