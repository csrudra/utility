# TRY-UNIFIED - one-click switcher to victory-unified (Itsbatt/victory-unified):
# a VIctory-family fork tuned for NVIDIA RTX 3070-class cards that fixes
# BLACK CHARACTERS / dark faces (character bake/skin/hair texture rechecks,
# VICTORY_HEAP_RECHECK) and tunes indirect light so character clothes keep
# readable color (VICTORY_AMBIENT=1.25). Community build - unverified beyond
# its own README (58-minute stable runs, ~2-3 fps open world).
#
#   TRY-UNIFIED.cmd               install/switch to victory-unified
#   TRY-UNIFIED.cmd -Restore      switch back to your previous engine
#
# Never rebuilds finished work; never destroys your setup (config.json.backup).
# Your game, saves and logs are untouched. Note: this fork wants the Series X
# profile and commits ~20 GB of RAM - keep your 48-64 GB pagefile ON.

param(
  [switch]$Restore,
  [string]$Repo = 'https://github.com/Itsbatt/victory-unified'
)

$ErrorActionPreference = 'Stop'
$root    = $PSScriptRoot
$setup   = Join-Path $root 'setup'
$engDir  = Join-Path $setup 'victory-unified'
$engExe  = Join-Path $engDir 'target\release\victory.exe'
$cfgPath = Join-Path $root 'config.json'
$backup  = Join-Path $root 'config.json.backup'

function Say([string]$m, [string]$c = 'White') { Write-Host $m -ForegroundColor $c }

if ($Restore) {
  if (-not (Test-Path $backup)) { Say "No $backup - nothing to restore." Yellow; exit 1 }
  Copy-Item $backup $cfgPath -Force
  Say 'Restored your previous engine config. START.cmd [1] PLAY works as before.' Green
  exit 0
}

# ---------- 1. get the source ----------
if (-not (Test-Path (Join-Path $engDir '.git'))) {
  Say 'Cloning victory-unified (one time)...' Cyan
  New-Item -ItemType Directory -Force -Path $setup | Out-Null
  & git clone --depth 1 $Repo $engDir
  if ($LASTEXITCODE -ne 0) { Say 'git clone failed. Check the repo URL and your internet.' Red; exit 1 }
} else {
  Say 'victory-unified source already present - keeping it.' DarkGray
}

# ---------- 2. build (skip if built) ----------
if (Test-Path $engExe) {
  Say "Build found - using it as-is: $engExe" Green
} else {
  $cargo = Join-Path "$env:USERPROFILE\.cargo\bin" 'cargo.exe'
  if (-not (Test-Path $cargo)) { $cargo = 'cargo' }
  Say 'Building victory-unified (10-15 min the first time). Progress in harness\data\logs\' Cyan
  $logDir = Join-Path $root 'data\logs'; New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $buildLog = Join-Path $logDir 'victory-unified-build.log'
  $p = Start-Process -FilePath $cargo -ArgumentList @('build','--release','-p','victory') `
       -WorkingDirectory $engDir -NoNewWindow -PassThru `
       -RedirectStandardOutput "$buildLog.out" -RedirectStandardError "$buildLog.err"
  while (-not $p.HasExited) {
    Start-Sleep -Seconds 20
    $mins = [math]::Round(((Get-Date) - $p.StartTime).TotalMinutes, 0)
    Say ("  still building... ($mins min elapsed, safe to leave alone)") DarkGray
  }
  Get-Content "$buildLog.err" -Tail 40 | Set-Content $buildLog
  if ($p.ExitCode -ne 0 -or -not (Test-Path $engExe)) {
    Say "BUILD FAILED (exit $($p.ExitCode)). See $buildLog" Red
    Say 'Most common cause: missing "Desktop development with C++" in Visual Studio Build Tools.' Yellow
    exit 1
  }
  Say "Build OK: $engExe" Green
}

# ---------- 3. flip the launcher config ----------
if (-not (Test-Path $cfgPath)) {
  Say 'No harness\config.json yet. Run START.cmd once (choose your game) FIRST.' Red
  exit 1
}
$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
if (-not (Test-Path $backup)) { Copy-Item $cfgPath $backup; Say 'Your previous config was saved to config.json.backup.' DarkGray }

$cfg | Add-Member -NotePropertyName engine  -NotePropertyValue 'unified' -Force
$cfg | Add-Member -NotePropertyName harness -NotePropertyValue $engExe -Force
$cfg | ConvertTo-Json -Depth 5 | Set-Content $cfgPath -Encoding UTF8

Say ''
Say '=============================================================' Green
Say ' SWITCHED TO VICTORY-UNIFIED (character-fix engine)' Green
Say '=============================================================' Green
Say 'Play as usual:  START.cmd  ->  [1] PLAY'
Say ''
Say 'What this engine is for: fixing BLACK CHARACTERS / dark faces in shade'
Say '(texture rechecks + tuned indirect light). Community-reported numbers:'
Say 'RTX 3070 8GB: ~3 fps open world, 58 minutes without a crash.'
Say ''
Say 'Warnings for your 6 GB / 16 GB laptop:'
Say '  - this fork commits ~20 GB RAM: KEEP the 48-64 GB pagefile ON'
Say '  - it uses the Series X profile (the launcher handles this automatically)'
Say '  - expect 2-4 fps; it is a community build, tested once by its author'
Say ''
Say 'Switch back any time:   TRY-UNIFIED.cmd -Restore' Cyan
