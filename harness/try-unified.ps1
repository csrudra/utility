# TRY-UNIFIED - one-click switcher to victory-unified (Itsbatt/victory-unified).
# This is an experimental fork with character texture rechecks and a lighting
# stand-in, not a guaranteed fix for black faces or a full ray-tracing solution.
# As of 2026-11-27, its README describes VICTORY_AMBIENT=1.25 while its current
# scripts/play.ps1 sets 0.8; the current ray-tracing note says ambient is off
# while the BVH builder runs. This launcher defaults to 0.8; its ambient menu is
# CCS03-only. Its RTX 3070 test reports roughly 20 GB commit and about
# 2-3 world fps; a 16 GB / 6 GB laptop is outside those measured conditions.
#
#   TRY-UNIFIED.cmd               install/switch to victory-unified
#   TRY-UNIFIED.cmd -Restore      switch back to your previous engine
#
# Reuses an existing executable by path alone; source/build provenance is not checked.
# Saves the previous config to config.json.backup. Back up saves before switching.
# One upstream test reports about 20 GB commit; this is not a universal requirement
# or a 16 GB system guarantee. Check actual commit headroom and OOM logs.

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
Say 'This is an experimental fork with texture rechecks and lighting controls; it is not a guaranteed fix for black faces or dark rooms.'
Say 'Its reported test results are from one RTX 3070 system and are not a prediction for your PC.'
Say ''
Say 'Warnings for lower-memory systems:'
Say '  - one report describes about 20 GB commit; a 16 GB system may page heavily or fail.'
Say '  - a larger pagefile is not a substitute for RAM; inspect commit/OOM evidence before changing it.'
Say '  - the launcher uses this fork''s Series X profile, but results still depend on the exact build/driver.'
Say ''
Say 'Switch back any time:   TRY-UNIFIED.cmd -Restore' Cyan
