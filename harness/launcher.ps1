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
  Write-Host '  Review prompts carefully; setup and fork support are not guaranteed.' -ForegroundColor DarkGray
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
function Get-ConfiguredEngine {
  if ($script:Cfg -and -not [string]::IsNullOrWhiteSpace([string]$script:Cfg.engine)) {
    return [string]$script:Cfg.engine
  }
  return 'ccs03'
}

# ============================ setup wizard ============================
function Setup-Wizard {
  param([string]$presetHarness)
  $priorConfig = Load-Config
  Write-Banner
  Write-Host '--- SETUP (4 basic questions; engine profile is asked if needed) ---' -ForegroundColor Green
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

  # A binary path change can imply a different fork/console profile. The executable
  # name alone is not enough, so recognize our install paths or ask explicitly.
  $priorHarness = if ($priorConfig -and $priorConfig.harness) { [string]$priorConfig.harness } else { '' }
  $priorEngine = if ($priorConfig -and $priorConfig.engine) { [string]$priorConfig.engine } else { 'ccs03' }
  $pathChanged = -not [string]::IsNullOrWhiteSpace($priorHarness) -and
    -not [string]::Equals($priorHarness.Trim(), ([string]$harness).Trim(), [StringComparison]::OrdinalIgnoreCase)
  $detectedEngine = $null
  $harnessPath = [string]$harness
  if ($harnessPath -match '(?i)[\\/]setup[\\/]CCS03[\\/]target[\\/]release[\\/]victory\.exe$') { $detectedEngine = 'ccs03' }
  elseif ($harnessPath -match '(?i)[\\/]setup[\\/]foxhound[\\/]target[\\/]release[\\/]victory\.exe$') { $detectedEngine = 'foxhound' }
  elseif ($harnessPath -match '(?i)[\\/]setup[\\/]victory-unified[\\/]target[\\/]release[\\/]victory\.exe$') { $detectedEngine = 'unified' }
  elseif ($harnessPath -match '(?i)[\\/]setup[\\/]fxce[\\/]target[\\/]release[\\/]victory\.exe$') { $detectedEngine = 'fxce' }
  $engineChoice = $priorEngine
  if ($detectedEngine) {
    $engineChoice = $detectedEngine
    if ($engineChoice -ne $priorEngine) {
      Write-Host "Detected '$engineChoice' from the selected executable path; the old engine profile will not be reused." -ForegroundColor Yellow
    }
  } elseif ($pathChanged -or -not $priorConfig -or -not $priorConfig.PSObject.Properties['engine']) {
    Write-Host ''
    Write-Host 'Choose the launcher profile that matches this executable. A mismatch can cause startup/rendering failures.' -ForegroundColor Yellow
    Write-Host '  [1] CCS03 (default installer)'
    Write-Host '  [2] Foxhound (NVIDIA fork)'
    Write-Host '  [3] victory-unified'
    Write-Host '  [4] fxceless (experimental; high memory use, not recommended for 6 GB / 16 GB systems)'
    $profileDefault = 1
    if ($priorEngine -eq 'foxhound') { $profileDefault = 2 }
    elseif ($priorEngine -eq 'unified') { $profileDefault = 3 }
    elseif ($priorEngine -eq 'fxce') { $profileDefault = 4 }
    $profilePick = Ask-Number 'Select engine profile 1-4' $profileDefault 1 4
    $engineChoice = switch ($profilePick) { 1 { 'ccs03' } 2 { 'foxhound' } 3 { 'unified' } 4 { 'fxce' } }
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
    Write-Host '  If you select CCS03, its instructions document two D3D12 compatibility DLLs for this OS.' -ForegroundColor Yellow
    Write-Host '  That check applies to CCS03 only; missing files are one possible pipeline issue, not a universal black-screen cause.' -ForegroundColor Yellow
  } else {
    Write-Host "QUESTION 4: Windows build $build detected - the CCS03 Windows 10 workaround is not applied." -ForegroundColor Green
  }

  # Preserve non-path settings, but update the engine profile to match the selected
  # binary. Custom extraEnv values are retained; they are fork-specific and should
  # be reviewed whenever the engine profile changes.
  $cfg = $priorConfig
  if (-not $cfg) { $cfg = [PSCustomObject]@{} }
  if ($pathChanged -or $engineChoice -ne $priorEngine) {
    [void]$cfg.PSObject.Properties.Remove('engineCommit')
    [void]$cfg.PSObject.Properties.Remove('engineCommitEngine')
    if ($cfg.extraEnv) {
      Write-Host 'Existing extraEnv overrides were preserved. Review them; they may not apply to the selected fork.' -ForegroundColor Yellow
    }
  }
  $cfg | Add-Member -NotePropertyName engine    -NotePropertyValue $engineChoice -Force
  $cfg | Add-Member -NotePropertyName gameExe   -NotePropertyValue $game -Force
  $cfg | Add-Member -NotePropertyName harness   -NotePropertyValue $harness -Force
  $cfg | Add-Member -NotePropertyName dataDir   -NotePropertyValue $data -Force
  $cfg | Add-Member -NotePropertyName createdAt -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -Force
  New-Item -ItemType Directory -Force -Path $data | Out-Null
  Save-Config $cfg
  Write-Host ''
  Write-Host 'SETUP SAVED. From now on just press 1 to play.' -ForegroundColor Green
  Pause-OK
}

# ============================ env bundle ==============================
function Set-GameEnv([string[]]$profiles, [string]$TextureNoWait = '') {
  if ($TextureNoWait -notin @('', '0', '1')) {
    throw "VICTORY_TEXTURE_NO_WAIT override must be empty, 0, or 1 (got '$TextureNoWait')."
  }
  $engine = Get-ConfiguredEngine
  if ($engine -notin @('ccs03', 'foxhound', 'fxce', 'unified')) {
    throw "Unknown engine '$engine'. Supported profiles: ccs03, foxhound, fxce, unified."
  }

  # Build a reproducible child-process environment. The launcher stays open while
  # users run multiple profiles; without clearing inherited switches, a prior
  # DEBUG / slow-motion / custom run silently contaminates the next one.
  # Preserve only runtime paths and selectors that this profile does not own.
  # Put any other intentional VICTORY_* override in config.json's `extraEnv` object.
  $preserveEnv = @(
    'VICTORY_CONFIG', 'VICTORY_GAME_DIR', 'VICTORY_CACHE_DIR',
    'VICTORY_DATA_DIR', 'VICTORY_D3D12_ADAPTER'
  )
  Get-ChildItem Env: | Where-Object {
    $_.Name -like 'VICTORY_*' -and $_.Name -notin $preserveEnv
  } | ForEach-Object {
    Remove-Item -Path "Env:$($_.Name)" -ErrorAction SilentlyContinue
  }

  # Load disabled resources from config (if any)
  $disabled = @()
  if ($script:Cfg -and $script:Cfg.disabledResources) {
    $disabled = $script:Cfg.disabledResources -split ',' | ForEach-Object { $_.Trim() }
  }
  function ShouldDisable($k) {
    return $disabled -contains $k
  }
  function E([string]$k, [string]$v) {
    if (-not (ShouldDisable $k)) {
      Set-Item -Path "Env:$k" -Value $v
    } else {
      Remove-Item -Path "Env:$k" -ErrorAction SilentlyContinue
    }
  }
  function Apply-ExtraEnv {
    if ($script:Cfg -and $script:Cfg.extraEnv) {
      foreach ($entry in $script:Cfg.extraEnv.PSObject.Properties) {
        if ($entry.MemberType -ne 'NoteProperty') { continue }
        $k = [string]$entry.Name
        if ($k -notmatch '^VICTORY_[A-Z0-9_]+$') { continue }
        if (ShouldDisable $k) {
          Remove-Item -Path "Env:$k" -ErrorAction SilentlyContinue
        } else {
          Set-Item -Path "Env:$k" -Value ([string]$entry.Value)
        }
      }
    }
    # The per-run A/B choice is more specific than config.json's extraEnv;
    # disabledResources still wins so the setting is never silently re-enabled.
    if ($TextureNoWait -ne '') {
      if (ShouldDisable 'VICTORY_TEXTURE_NO_WAIT') {
        Remove-Item -Path 'Env:VICTORY_TEXTURE_NO_WAIT' -ErrorAction SilentlyContinue
      } else {
        Set-Item -Path 'Env:VICTORY_TEXTURE_NO_WAIT' -Value $TextureNoWait
      }
    }
  }
  $ambientValue = $null
  if ($script:Cfg -and $script:Cfg.ambientByEngine -and
      $script:Cfg.ambientByEngine.PSObject.Properties[$engine] -and
      -not [string]::IsNullOrWhiteSpace([string]$script:Cfg.ambientByEngine.$engine)) {
    $ambientValue = [string]$script:Cfg.ambientByEngine.$engine
  } elseif ($engine -eq 'ccs03' -and $script:Cfg -and
            $script:Cfg.PSObject.Properties['ambient'] -and
            -not [string]::IsNullOrWhiteSpace([string]$script:Cfg.ambient)) {
    # Backward compatibility: the old scalar setting was only calibrated for CCS03.
    $ambientValue = [string]$script:Cfg.ambient
  }
  $ambientDefault = switch ($engine) {
    'foxhound' { '0.8' }
    'fxce' { '1.25' }
    'unified' { '0.8' }
    default { '0.9' }
  }
  $ambientEffective = if ($null -ne $ambientValue) { $ambientValue } else { $ambientDefault }

  if ($engine -eq 'foxhound') {
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
    E VICTORY_AMBIENT $ambientEffective
    E VICTORY_AMBIENT_AIR '1.5';       E VICTORY_AMBIENT_SPECULAR '1'
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
    Apply-ExtraEnv
    return
  }

  if ($engine -eq 'fxce') {
    # Experimental fxceless/victory-fork profile. Its PRs address some texture
    # residency/bake cases, but its current README still reports transient black
    # faces. The current ray-tracing builder is extremely slow and memory-heavy;
    # this engine profile is not appropriate for a 6 GB / 16 GB machine.
    # Ambient settings are a fallback only when the builder is not running.
    E VICTORY_HEAP_RECHECK '1';  E VICTORY_LEVELS_ON_DEMAND '1';  E VICTORY_MAX_FPS '30'
    E VICTORY_AMBIENT $ambientEffective
    E VICTORY_TEXTURE_BUDGET_MB '1024'; E VICTORY_CARD_BUFFERS_MB '768'
    E VICTORY_TEXTURE_STAGE_MS '25'; E VICTORY_TEXTURE_STAGE_MB '48'
    E VICTORY_CARD_HASH_LEN '1'; E VICTORY_HEAP_WORKER '1'
    # Series X profile (required for this fork)
    $consoleProfile = "series-x"
    if ($profiles -contains "fast")    { E VICTORY_TURBO_THREADS "1"; E VICTORY_DISPLAY_MODE "1280x720" }
    if ($profiles -contains "smooth")  { E VICTORY_DISPLAY_MODE "1280x720"
                                       E VICTORY_TEXTURE_STAGE_MS "25"; E VICTORY_TEXTURE_STAGE_MB "48" }
    if ($profiles -contains 'steady')  { E VICTORY_GAME_STEP_MS '33' }   # slow-motion clock (opt-in)
    if ($profiles -contains 'debug')   { E VICTORY_D3D12_DRED 'faults'; E VICTORY_NO_WATCHDOG '1' }
    Apply-ExtraEnv
    return
  }

  if ($engine -eq 'unified') {
    # Mirror Itsbatt/victory-unified's current scripts/play.ps1, not CCS03's
    # Series S bundle. In particular, do not set BVH_MISS here: it prevents
    # real ray hits on trees that support the optional BVH builder.
    E VICTORY_TEXTURE_NO_WAIT '1'; E VICTORY_RELAY '2'; E VICTORY_WIDE_BACK '1'
    E VICTORY_CARD_REHASH_RUNS '1'; E VICTORY_JOIN_COPIES '1'; E VICTORY_INDIRECT_WINDOW '1'
    E VICTORY_RELAY_COPY '1'; E VICTORY_CARD_STEPS '2'; E VICTORY_INDIRECT_BATCH '2'
    E VICTORY_MAP_THREADS '1'; E VICTORY_TITLE_PRIORITIES '0'; E VICTORY_CARD_AWAKE '1'
    E VICTORY_SHOW_AFTER '1'
    E VICTORY_AMBIENT $ambientEffective
    E VICTORY_D3D12_DRED 'light'
    E VICTORY_UNDER_WIDE '0'; E VICTORY_LAND_ECHO '0'
    E VICTORY_THIN '1'; E VICTORY_JOIN_PARTS '8'; E VICTORY_UPLOAD_AHEAD '1'
    if ($profiles -contains 'debug') { E VICTORY_D3D12_DRED 'faults'; E VICTORY_NO_WATCHDOG '1' }
    Apply-ExtraEnv
    return
  }

  # -- CCS03-specific laptop profile. Switches are fork/commit-specific and must be verified upstream.
  E VICTORY_DISPLAY_MODE '1920x1080';  E VICTORY_RELAY '2';            E VICTORY_ASYNC_SUBMIT '1'
  E VICTORY_QUEUE2 '1';                E VICTORY_INDIRECT_WINDOW '1';  E VICTORY_COPY_PLAIN '1'
  E VICTORY_TEXTURE_NO_WAIT '1';       E VICTORY_WIDE_TEXTURES '1';    E VICTORY_TEXTURE_DROP_MIPS '1'
  E VICTORY_TEXTURE_ROOM_PERCENT '86'; E VICTORY_CARD_ROOM_FOR_TARGETS_MB '1024'
  # CCS03's own play.ps1 uses 0.9 (ambient.rs default is 0.6); this is the
  # upstream script's starting value, not a promise of physically correct GI.
  E VICTORY_AMBIENT $ambientEffective
  E VICTORY_JOIN_PARTS '1';            E VICTORY_BACK_OWN_VIEW '1'
  E VICTORY_INDIRECT_GATHER '1';       E VICTORY_CARD_REHASH_RUNS '1'; E VICTORY_TEXTURE_BACK '1'
  E VICTORY_CARD_HASH_LEN '1'
  # -- CCS03 present/upscale profile values; support depends on the source revision
  E VICTORY_OWN_UPSCALER '1';          E VICTORY_COMPOSE '1';          E VICTORY_SHOW_AFTER '1'
  E VICTORY_PIPELINE_WAIT_MS '10000';  E VICTORY_PIPELINE_PRIORITY 'normal'
  E VICTORY_DYNAMIC_SLOTS '262144';    E VICTORY_D3D12_DRED 'light';   E VICTORY_WAVE_WIDE '0'
  # CCS03 laptop profile keeps its structure builder off; end stale ray walks.
  # This switch is intentionally absent from the ray-tracing-capable unified profile.
  E VICTORY_BVH_MISS '1'
  # -- performance-related switches reported for CCS03; not independently measured here
  E VICTORY_HOIST_CLAMPS '7';          E VICTORY_CARD_BUFFERS_MIN_MB '1'
  E VICTORY_HAIR '0';                  E VICTORY_WIDE_REFRESH '1'
  E VICTORY_TEXTURE_CATCHUP '0';       E VICTORY_CARD_FETCH_INFLIGHT '0'
  # -- 6 GB card budget
  E VICTORY_TEXTURE_BUDGET_MB '768';   E VICTORY_CARD_BUFFERS_MB '512'

  if ($profiles -contains 'fast')    { E VICTORY_TURBO_THREADS '1'; E VICTORY_DISPLAY_MODE '1280x720' }
  if ($profiles -contains 'smooth')  { E VICTORY_DISPLAY_MODE '1280x720'
                                       E VICTORY_TEXTURE_STAGE_MS '25'; E VICTORY_TEXTURE_STAGE_MB '48' }
  if ($profiles -contains 'steady')  { E VICTORY_GAME_STEP_MS '33' }   # slow-motion clock (opt-in)
  if ($profiles -contains 'debug')   { E VICTORY_D3D12_DRED 'faults'; E VICTORY_NO_WATCHDOG '1' }
  Apply-ExtraEnv
}

# ============================ preflight (quick gates) =================
function Quick-Gates {
  $problems = @()
  $engine = Get-ConfiguredEngine
  $build = [int](Get-CimInstance Win32_OperatingSystem).BuildNumber
  if ($build -lt 22000 -and $engine -eq 'ccs03') {
    $agilityDir = Join-Path (Split-Path $script:Cfg.harness) 'D3D12'
    $core = Join-Path $agilityDir 'D3D12Core.dll'
    $layers = Join-Path $agilityDir 'd3d12SDKLayers.dll'
    if (-not (Test-Path $core) -or -not (Test-Path $layers)) {
      $problems += 'WINDOWS 10 AGILITY SDK INCOMPLETE: both D3D12Core.dll and d3d12SDKLayers.dll are required in the D3D12 folder next to victory.exe. This is one possible pipeline-start failure, not the only cause of a black screen.'
    }
  }
  $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
  if ($ramGB -lt 16) { $problems += "SYSTEM RAM IS $ramGB GB: below one test reference of 16 GB. Memory demand varies by fork and scene; check the selected build's requirements and actual commit/OOM evidence." }
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
  $engine = Get-ConfiguredEngine
  if ($engine -in @('unified', 'foxhound')) {
    $pick = Ask-Number 'Settings: [1] launcher profile [2] GPU diagnostics' 1 1 2
    $profiles = @()
    if ($pick -eq 2) { $profiles = @('debug') }
    if ($engine -eq 'unified') {
      Write-Host 'The optional BVH builder remains off; its documented cost is substantial.' -ForegroundColor Yellow
    }
  } else {
    $pick = Ask-Number 'Settings: [1] SMOOTH (720p) [2] FASTEST [3] DEBUG' 1 1 3
    $profiles = switch ($pick) { 1 { @('smooth') } 2 { @('fast') } 3 { @('smooth','debug') } }
  }
  if ($engine -notin @('foxhound', 'unified')) {
    $speed = Ask-Number 'Timing: [1] default timing [2] slow-motion diagnostic' 1 1 2
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

# ============================ ambient fallback ==========================
function Action-FixDark {
  $engine = Get-ConfiguredEngine
  Write-Host ''
  Write-Host '--- TUNE AMBIENT-LIGHT FALLBACK ---' -ForegroundColor White
  if ($engine -ne 'ccs03') {
    Write-Host "No ambient preset is exposed for '$engine'. Forks use different VICTORY_AMBIENT semantics; this menu will not change it." -ForegroundColor Yellow
    Write-Host 'Use only a value documented by the selected fork, or switch to CCS03 before using this menu.' -ForegroundColor DarkGray
    return
  }
  Write-Host 'This changes only CCS03 VICTORY_AMBIENT, a constant approximation for missing'
  Write-Host 'indirect diffuse light. It is not display brightness, exposure, or full GI.'
  Write-Host 'More light can lift shadows but also flatten contrast; it cannot fix a'
  Write-Host 'black game window, missing textures, or black character faces.' -ForegroundColor DarkGray
  Write-Host ''
  Write-Host '  [1] 0.9  CCS03 play-script starting point'
  Write-Host '  [2] 1.2  Brighter experiment (may wash out contrast)'
  Write-Host '  [3] 1.5  Strong lift (likely to look flat)'
  Write-Host '  [4] off  Disable the fallback; raw title output may still be black/invalid'
  $lvl = Ask-Number 'Pick 1-4' 1 1 4
  $val = switch ($lvl) { 1 { '0.9' } 2 { '1.2' } 3 { '1.5' } 4 { 'off' } }
  $config = Load-Config
  if (-not $config) { Write-Host 'No config yet - run START.cmd setup first.' -ForegroundColor Red; return }
  if (-not $config.ambientByEngine) {
    $config | Add-Member -NotePropertyName ambientByEngine -NotePropertyValue ([PSCustomObject]@{}) -Force
  }
  $config.ambientByEngine | Add-Member -NotePropertyName ccs03 -NotePropertyValue $val -Force
  Save-Config $config
  $script:Cfg = $config
  Write-Host ''
  Write-Host "Saved CCS03 ambient setting. The next run will request VICTORY_AMBIENT=$val." -ForegroundColor Green
  Write-Host 'Restart the game for the setting to take effect. This is not a lighting fix for black output.' -ForegroundColor DarkGray
}

# ============================ monitor =================================
function Start-GameWithMonitor($cfg, [string[]]$profiles, [int]$MaxMinutes = 0, [string]$TextureNoWait = '') {
  Set-GameEnv $profiles $TextureNoWait

  $logDir = Join-Path $cfg.dataDir 'logs'
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $outLog = Join-Path $logDir "run-$stamp.log"
  $errLog = Join-Path $logDir "run-$stamp.err.log"
  $csv    = Join-Path $logDir "telemetry-$stamp.csv"

  # Record run identity as well as switches. A switch list alone is not enough
  # to reproduce a fork-specific rendering failure.
  $engine = Get-ConfiguredEngine
  $profileLabel = if ($profiles -and $profiles.Count -gt 0) { $profiles -join ',' } else { 'launcher-default' }
  if ($TextureNoWait -ne '') { $profileLabel += ",texture-no-wait=$TextureNoWait" }
  $sourceRoot = 'not detected'
  $sourceCommit = 'not recorded (source archive or no Git metadata)'
  if ($cfg.harness) {
    $releaseDir = Split-Path -Parent $cfg.harness
    $targetDir = Split-Path -Parent $releaseDir
    $candidateRoot = Split-Path -Parent $targetDir
    if (Test-Path (Join-Path $candidateRoot 'Cargo.toml')) {
      $sourceRoot = $candidateRoot
      if ($cfg.engineCommitEngine -eq $engine -and $cfg.engineCommit) {
        $sourceCommit = [string]$cfg.engineCommit
      } elseif ((Test-Path (Join-Path $candidateRoot '.git')) -and (Get-Command git -ErrorAction SilentlyContinue)) {
        $gitCmd = Get-Command git -ErrorAction SilentlyContinue
        $gitPath = $gitCmd.Source
        $gitRev = & $gitPath -C $candidateRoot rev-parse HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $gitRev) { $sourceCommit = ([string]$gitRev).Trim() }
      }
    }
  }
  $settings = @(
    "captured_at=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')"
    "engine=$engine"
    "engine_executable=$($cfg.harness)"
    "engine_source=$sourceRoot"
    "engine_source_revision=$sourceCommit"
    'binary_build_provenance=not verified by this launcher'
    "run_profile=$profileLabel"
  )
  $envSettings = @(Get-ChildItem Env: | Where-Object { $_.Name -like 'VICTORY_*' } |
    Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" })
  $settings += $envSettings
  $settings | Set-Content (Join-Path $logDir "settings-$stamp.txt")

  Write-Banner
  Write-Host '--- PRE-FLIGHT (automatic) ---' -ForegroundColor White
  $problems = Quick-Gates
  if ($problems.Count -gt 0) {
    foreach ($p in $problems) { Write-Host "  ! $p" -ForegroundColor Yellow }
    $go = (Ask 'Warnings found. Try to start anyway? (y/n)' 'n')
    if ($go -notmatch '^(y|yes)$') { return }
  } else {
    Write-Host '  No warnings from these quick checks; they do not verify every requirement.' -ForegroundColor Green
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

    # Game window bounds (do not infer internal render resolution from them).
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
      ('  Game window     : {0}  (window bounds only; render resolution may differ) ' -f $winTxt),
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
  if ($gates.Count -eq 0) { $pre += 'No warnings from quick checks.' }
  else { $gates | ForEach-Object { $pre += "WARNING: $_" } }
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
  Write-Host '  This downloads the CCS03 source and build tools, then builds the harness.' -ForegroundColor White
  Write-Host '  It does not include the game or guarantee that every PC can start it.' -ForegroundColor White
  Write-Host ''
  Write-Host '  What happens now:' -ForegroundColor White
  Write-Host '   1. Downloads the harness source code (about 50 MB)'
  Write-Host '   2. Installs the free "Rust" build tool if missing (about 1 GB)'
  Write-Host '   3. Installs Microsoft build tools if missing (several GB - slow!)'
  Write-Host '   4. Builds the harness (10-40 minutes of scrolling text - normal)'
  Write-Host '   5. On Windows 10, checks the two D3D12 files documented by CCS03 (one possible pipeline issue)'
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

  # ---- 4. build (reuses an existing binary by path; provenance is not verified) ----
  Write-Host ''
  Write-Host 'STEP 4/5: building the harness...' -ForegroundColor Cyan
  $victory = Join-Path $src 'target\release\victory.exe'
  if (Test-Path $victory) {
    Write-Host '    EXECUTABLE EXISTS - reusing it by path. Source revision/build provenance are not checked.' -ForegroundColor Yellow
  } else {
    Write-Host '    First build: 10-40 minutes. Please keep this window open.' -ForegroundColor Yellow
    Write-Host '    Cargo may reuse completed artifacts on retry, but setup is not guaranteed to resume every download/installer step.' -ForegroundColor DarkGray
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
    if ($p.ExitCode -ne 0 -or -not (Test-Path $victory)) {
      Write-Host ''
      Write-Host "    BUILD FAILED (exit code $($p.ExitCode)). Last errors:" -ForegroundColor Red
      Get-Content $buildErr -Tail 10 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "      $_" -ForegroundColor Red }
      Get-Content $buildOut -Tail 10 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
      Write-Host ''
      Write-Host "    Full log: $buildErr" -ForegroundColor Cyan
      Write-Host '    Tip: run setup again first - builds CONTINUE, and most failures are' -ForegroundColor Cyan
      Write-Host '    one-time glitches (antivirus, internet). If it fails again, use menu' -ForegroundColor Cyan
      Write-Host '    [7] EXPORT LOGS FOR AI and send the zip.' -ForegroundColor Cyan
      Pause-OK
      return $null
    }
    Write-Host '    harness built.' -ForegroundColor Green
  }

  # ---- 5. Windows 10 D3D12 compatibility files ----
  Write-Host ''
  Write-Host 'STEP 5/5: checking the documented Windows 10 D3D12 files...' -ForegroundColor Cyan
  $osBuild = [int](Get-CimInstance Win32_OperatingSystem).BuildNumber
  if ($osBuild -lt 22000) {
    $d3dDir = Join-Path (Split-Path $victory) 'D3D12'
    $corePath = Join-Path $d3dDir 'D3D12Core.dll'
    $layersPath = Join-Path $d3dDir 'd3d12SDKLayers.dll'
    New-Item -ItemType Directory -Force -Path $d3dDir | Out-Null
    if (-not (Test-Path $corePath) -or -not (Test-Path $layersPath)) {
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
        $core = Get-ChildItem $x -Recurse -Filter 'D3D12Core.dll' | Where-Object { $_.FullName -match 'x64' } | Select-Object -First 1
        $layers = Get-ChildItem $x -Recurse -Filter 'D3d12SDKLayers.dll' | Where-Object { $_.FullName -match 'x64' } | Select-Object -First 1
        if ($core)   { Copy-Item $core.FullName   $corePath -Force }
        if ($layers) { Copy-Item $layers.FullName $layersPath -Force }
        Remove-Item $x -Recurse -Force -ErrorAction SilentlyContinue
      }
      if (-not (Test-Path $corePath) -or -not (Test-Path $layersPath)) {
        Write-Host '    Agility SDK files remain incomplete; consult the selected fork''s Windows 10 instructions.' -ForegroundColor Yellow
      } else {
        Write-Host '    both documented Agility SDK files are present.' -ForegroundColor Green
      }
    } else {
      Write-Host '    both documented Agility SDK files are already present.' -ForegroundColor Green
    }
  } else {
    Write-Host '    Windows 11 detected; skipping the Windows 10-only Agility SDK package.' -ForegroundColor DarkGray
  }

  Write-Host ''
  Write-Host 'SETUP STEPS FINISHED. Review any warnings above and confirm the selected fork''s requirements.' -ForegroundColor Green
  Pause-OK
  return $victory
}

# ============================ menu actions ============================
function Action-CheckPC {
  Write-Banner
  Write-Host '--- CHECKING YOUR PC ---' -ForegroundColor White
  & (Join-Path $script:Root 'preflight.ps1') -VictoryExe $script:Cfg.harness -Engine (Get-ConfiguredEngine)
  Pause-OK
}
function Action-FixBlack {
  Write-Banner
  Write-Host '--- BLACK-SCREEN DIAGNOSIS (read-only) ---' -ForegroundColor White
  $logDir = Join-Path $script:Cfg.dataDir 'logs'
  $latest = Get-ChildItem $logDir -Filter 'run-*.log' -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notlike '*.err.log' } |
            Sort-Object LastWriteTime | Select-Object -Last 1
  $logArg = if ($latest) { $latest.FullName } else { $null }
  $errArg = if ($logArg) { $logArg -replace '\.log$', '.err.log' } else { $null }
  if ($logArg) { Write-Host "Using latest log: $logArg" -ForegroundColor DarkGray }
  & (Join-Path $script:Root 'fix-blackscreen.ps1') -VictoryExe $script:Cfg.harness -RunLog $logArg -RunErrorLog $errArg -Engine (Get-ConfiguredEngine)
  Pause-OK
}
function Action-Play {
  Write-Banner
  $engine = Get-ConfiguredEngine
  if ($engine -in @('unified', 'foxhound')) {
    Write-Host "--- $($engine.ToUpperInvariant()) PLAY PROFILE ---" -ForegroundColor White
    Write-Host 'This applies launcher settings based on a checked fork play script; the exact binary support is not verified.' -ForegroundColor DarkGray
    Write-Host 'The CCS03 720p/FAST presets do not apply.' -ForegroundColor DarkGray
    Write-Host '  [1] PLAY with the launcher profile'
    Write-Host '  [2] PLAY with GPU diagnostics (slower, more logging)'
    if ($engine -eq 'unified') {
      Write-Host '  Ray tracing is not enabled by default. The upstream builder has a substantial GPU-time and memory cost.' -ForegroundColor Yellow
    }
    Write-Host ''
    $pick = Ask-Number 'Pick 1 or 2' 1 1 2
    $profiles = @()
    if ($pick -eq 2) { $profiles = @('debug') }
  } else {
    Write-Host '--- CHOOSE HOW IT SHOULD RUN ---' -ForegroundColor White
    Write-Host '  [1] SMOOTH  720p and a bounded texture pass (default)'
    Write-Host '  [2] FASTEST 720p with extra CPU threads'
    Write-Host '  [3] DEBUG   extra GPU error details (slower)'
    Write-Host ''
    $pick = Ask-Number 'Pick 1, 2 or 3' 1 1 3
    $profiles = switch ($pick) { 1 { @('smooth') } 2 { @('fast') } 3 { @('smooth','debug') } }
  }
  if ($script:Cfg.engine -in @('foxhound', 'unified')) {
    Write-Host '  (this engine paces the world per frame - below 30 fps the game runs slower than real time.)' -ForegroundColor DarkGray
  } else {
    $speed = Ask-Number 'Timing: [1] default timing [2] slow-motion diagnostic (easier to steer)' 1 1 2
    if ($speed -eq 2) { $profiles += 'steady' }
  }

  # CCS03's selected profile enables the nonblocking texture-remap path;
  # fxceless leaves it off by default. Let users compare each engine's baseline
  # with the opposite value, one launch at a time, without changing saved config.
  $textureNoWait = ''
  if ($engine -in @('ccs03', 'fxce')) {
    $disabledNoWait = $false
    if ($script:Cfg -and $script:Cfg.disabledResources) {
      $disabledNoWait = @($script:Cfg.disabledResources -split ',' | ForEach-Object { $_.Trim() }) -contains 'VICTORY_TEXTURE_NO_WAIT'
    }
    if ($disabledNoWait) {
      Write-Host ''
      Write-Host 'VICTORY_TEXTURE_NO_WAIT is disabled in config.json. Remove it from disabledResources to run this A/B test.' -ForegroundColor Yellow
    } else {
      $baselineNoWait = if ($engine -eq 'ccs03') { '1' } else { '0' }
      $comparisonNoWait = if ($baselineNoWait -eq '1') { '0' } else { '1' }
      $baselineLabel = if ($engine -eq 'ccs03') { 'CCS03 PROFILE BASELINE' } else { 'FXCE SOURCE DEFAULT' }
      Write-Host ''
      Write-Host '--- TEXTURE REMAP A/B (this launch only) ---' -ForegroundColor White
      Write-Host 'Repeat the same scene with each choice. This switch may affect stalls during texture remapping; it is not a guaranteed visual fix.' -ForegroundColor DarkGray
      Write-Host 'The source supports this switch, but this launcher cannot prove the selected executable consumed it.' -ForegroundColor Yellow
      Write-Host "  [1] $baselineLabel  VICTORY_TEXTURE_NO_WAIT=$baselineNoWait"
      Write-Host "  [2] A/B COMPARISON  VICTORY_TEXTURE_NO_WAIT=$comparisonNoWait"
      Write-Host '  1 = nonblocking refresh; 0 = wait for refresh (may stall). Compare the matching settings-*.txt files.' -ForegroundColor DarkGray
      $noWaitPick = Ask-Number 'Choose baseline or comparison' 1 1 2
      $textureNoWait = if ($noWaitPick -eq 1) { $baselineNoWait } else { $comparisonNoWait }
    }
  }

  # Use the same switch set for cache warm-up and the subsequent run. The
  # launcher clears/rebuilds this set again at the actual start.
  Set-GameEnv -profiles $profiles -TextureNoWait $textureNoWait
  Write-Host ''
  Write-Host 'Optional: run the build''s warm-up command first? It may pre-cache work if this fork supports it (y/n).' -ForegroundColor DarkGray
  $warm = (Ask 'Warm up before playing? (y/n)' 'y')
  if ($warm -match '^(y|yes)$') {
    $logDir = Join-Path $script:Cfg.dataDir 'logs'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    Write-Host 'Warming up (this can take many minutes the first time)...' -ForegroundColor Yellow
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    if ($engine -eq 'foxhound') {
      # foxhound: translate shaders once per build+switches, then pre-compile known pipelines
      $env:VICTORY_HOST_WAVE = '32'
      & $script:Cfg.harness shaders (Split-Path -Parent $script:Cfg.gameExe) 2>&1 |
        Select-Object -Last 3 | Tee-Object -FilePath (Join-Path $logDir "shaders-$(Get-Date -Format 'yyyyMMdd-HHmmss').log")
      Remove-Item Env:VICTORY_HOST_WAVE -ErrorAction SilentlyContinue
    }
    $warmOut = & $script:Cfg.harness warm --used 2>&1 | Tee-Object -FilePath (Join-Path $logDir "warm-$(Get-Date -Format 'yyyyMMdd-HHmmss').log") | Out-String
    $ErrorActionPreference = $eap
    if ($warmOut -match 'unrecognized (subcommand|argument)') {
      Write-Host '  (this build did not recognize the optional warm-up command; continuing without it.)' -ForegroundColor DarkGray
    }
  }
  Start-GameWithMonitor -cfg $script:Cfg -profiles $profiles -TextureNoWait $textureNoWait
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
  Write-Host '--- SYSTEM RESOURCE SNAPSHOT (no per-switch attribution) ---' -ForegroundColor White
  Write-Host '  This summarizes host-level telemetry only: RAM, commit, CPU and (on NVIDIA) GPU/VRAM.' -ForegroundColor DarkGray
  Write-Host '  It cannot tell how much memory or time a specific VICTORY_* switch uses, and will not change settings.' -ForegroundColor DarkGray
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

  Write-Host '  --- PEAKS FROM THE LATEST TELEMETRY CSV ---' -ForegroundColor Cyan
  Write-Host ('  Peak RAM       : {0} GB' -f $peaks.ram) -ForegroundColor White
  Write-Host ('  Peak commit    : {0} GB' -f $peaks.commit) -ForegroundColor White
  Write-Host ('  Peak CPU       : {0} %' -f $peaks.cpu) -ForegroundColor White
  Write-Host ('  Peak NVIDIA GPU: {0} %' -f $peaks.gpu) -ForegroundColor White
  Write-Host ('  Peak NVIDIA VRAM: {0} GB' -f $peaks.vram) -ForegroundColor White
  Write-Host '  Note: NVIDIA counters may be zero/unavailable on AMD/Intel systems.' -ForegroundColor DarkGray
  Write-Host ''

  # Save only the counters actually present in telemetry. No switch-level
  # attribution exists here, so do not invent per-component numbers or toggles.
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $report = Join-Path $logDir "resource-usage-$stamp.txt"
  @(
    "--- SYSTEM RESOURCE SNAPSHOT ($stamp) ---"
    "Source CSV: $latestCsv"
    ""
    "Peak RAM: $($peaks.ram) GB"
    "Peak commit: $($peaks.commit) GB"
    "Peak CPU: $($peaks.cpu) %"
    "Peak NVIDIA GPU: $($peaks.gpu) %"
    "Peak NVIDIA VRAM: $($peaks.vram) GB"
    ""
    'No per-switch resource attribution is collected. These system totals cannot justify disabling a VICTORY_* option.'
  ) | Set-Content $report
  Write-Host "  Snapshot saved: $report" -ForegroundColor Green
  Write-Host '  No settings were changed.' -ForegroundColor DarkGray
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
  Write-Host '  [1] PLAY               (profile settings + live stats)' -ForegroundColor White
  Write-Host '  [2] CHECK MY PC        (is everything ready?)' -ForegroundColor White
  Write-Host '  [3] DIAGNOSE BLACK SCREEN (read-only checks; no auto-fix)' -ForegroundColor White
  Write-Host '  [4] TUNE AMBIENT LIGHT   (approximation only; not full GI)' -ForegroundColor White
  Write-Host '  [5] SCENE TEST LOOP    (replay the same spot again and again)' -ForegroundColor White
  Write-Host '  [6] CHANGE SETTINGS    (game file, folders, start over)' -ForegroundColor White
  Write-Host '  [7] EXPORT LOGS FOR AI (makes one .zip to send)' -ForegroundColor White
  Write-Host '  [8] OPEN LOG FOLDER' -ForegroundColor White
  Write-Host '  [9] UPDATE FROM GITHUB (get the newest fixes)' -ForegroundColor White
  Write-Host '  [10] Quit' -ForegroundColor White
  Write-Host '  [11] RESOURCE SNAPSHOT (system totals only; no per-switch attribution)' -ForegroundColor White
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
