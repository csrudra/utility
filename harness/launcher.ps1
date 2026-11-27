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

  # 2. harness exe
  $harness = $null
  while (-not $harness) {
    Write-Host ''
    Write-Host 'QUESTION 2: Where is the HARNESS file?' -ForegroundColor White
    Write-Host '  (victory.exe - the program you built from CCS03. See README step 1)' -ForegroundColor DarkGray
    $harness = Pick-File 'Select the harness (victory.exe)' 'Harness (victory.exe)|victory.exe;*.exe'
    if (-not $harness) { Write-Host '  No file chosen - build it first (README step 1).' -ForegroundColor Yellow }
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
  function E([string]$k, [string]$v) { Set-Item -Path "Env:$k" -Value $v }

  # -- measured CCS03 laptop bundle (do not remove lines; they work as a set)
  E VICTORY_DISPLAY_MODE '1920x1080';  E VICTORY_RELAY '2';            E VICTORY_ASYNC_SUBMIT '1'
  E VICTORY_QUEUE2 '1';                E VICTORY_INDIRECT_WINDOW '1';  E VICTORY_COPY_PLAIN '1'
  E VICTORY_TEXTURE_NO_WAIT '1';       E VICTORY_WIDE_TEXTURES '1';    E VICTORY_TEXTURE_DROP_MIPS '1'
  E VICTORY_TEXTURE_ROOM_PERCENT '86'; E VICTORY_CARD_ROOM_FOR_TARGETS_MB '1024'
  E VICTORY_AMBIENT '0.9';             E VICTORY_JOIN_PARTS '1';       E VICTORY_BACK_OWN_VIEW '1'
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

  if ($profiles -contains 'fast')    { E VICTORY_TURBO_THREADS '1'; E VICTORY_DISPLAY_MODE '1280x720' }
  if ($profiles -contains 'smooth')  { E VICTORY_DISPLAY_MODE '1280x720'; E VICTORY_GAME_STEP_MS '33'
                                       E VICTORY_TEXTURE_STAGE_MS '25'; E VICTORY_TEXTURE_STAGE_MB '48' }
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

# ============================ monitor =================================
function Start-GameWithMonitor($cfg, [string[]]$profiles) {
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

  $proc = Start-Process -FilePath $cfg.harness `
    -ArgumentList @('run', ('"{0}"' -f $cfg.gameExe), '--execute', '--console', 'series-s') `
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

  while (-not $proc.HasExited) {
    Start-Sleep -Seconds 2

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
      ('  -------------------------------------------'),
      ('  Close the GAME window to stop. Ctrl+C here   '),
      ('  breaks the log - use the game window.        ')
    )
    [Console]::SetCursorPosition(0, $monitorTop)
    foreach ($line in $buf) { Write-Host $line -ForegroundColor Gray }
  }

  # ---- summary ----
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

  Write-Host ''
  Write-Host 'Tip: first time? add a warm-up (y/n). It makes the first minutes much better.' -ForegroundColor DarkGray
  $warm = (Ask 'Warm up before playing? (y/n)' 'y')
  if ($warm -match '^(y|yes)$') {
    $logDir = Join-Path $script:Cfg.dataDir 'logs'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    Write-Host 'Warming up (this can take many minutes the first time)...' -ForegroundColor Yellow
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    & $script:Cfg.harness warm --used 2>&1 | Tee-Object -FilePath (Join-Path $logDir "warm-$(Get-Date -Format 'yyyyMMdd-HHmmss').log")
    $ErrorActionPreference = $eap
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
function Action-OpenLogs {
  $logDir = Join-Path $script:Cfg.dataDir 'logs'
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  Start-Process explorer.exe $script:Cfg.dataDir
}

# ============================ main ====================================
Write-Banner
$config = Load-Config
if ($DataDir -and $config) { $config.dataDir = $DataDir }

if (-not $config -or -not (Test-Path $config.gameExe) -or -not (Test-Path $config.harness)) {
  if ($config) {
    Write-Host 'Saved game/harness paths no longer exist. Running setup again.' -ForegroundColor Yellow
    Pause-OK
  }
  Setup-Wizard
  $config = Load-Config
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
  Write-Host '  [4] CHANGE SETTINGS    (game file, folders, start over)' -ForegroundColor White
  Write-Host '  [5] EXPORT LOGS FOR AI (makes one .zip to send)' -ForegroundColor White
  Write-Host '  [6] OPEN LOG FOLDER' -ForegroundColor White
  Write-Host '  [7] Quit' -ForegroundColor White
  Write-Host ''
  $choice = Ask-Number 'What do you want to do' 1 1 7
  switch ($choice) {
    1 { Action-Play }
    2 { Action-CheckPC }
    3 { Action-FixBlack }
    4 { Setup-Wizard; $config = Load-Config; $script:Cfg = $config }
    5 { Action-Export }
    6 { Action-OpenLogs }
    7 { Write-Host 'Bye!' -ForegroundColor Cyan; exit 0 }
  }
}
