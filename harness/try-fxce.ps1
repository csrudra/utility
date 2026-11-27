<#
.SYNOPSIS
  Build/switch the launcher to the experimental fxceless/victory-fork renderer.
.DESCRIPTION
  This is a fork switcher, not a visual fix. The upstream README reports very low
  world frame rates and memory use measured on a single higher-end PC; results on
  other hardware are unknown. The source branch is mutable, and an existing local
  checkout or executable is reused unless -Rebuild is requested.

  TRY-FXCELESS.cmd -Restore returns to the configuration saved before the first
  fxceless switch. It does not delete the source tree, build files, or game data.
#>
[CmdletBinding()]
param(
  [switch]$Restore,
  [switch]$Rebuild,
  [switch]$Force  # skip the interactive risk confirmation; warnings are still shown
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$setup = Join-Path $root 'setup'
$fxDir = Join-Path $setup 'fxce'
$fxExe = Join-Path $fxDir 'target\release\victory.exe'
$cfgPath = Join-Path $root 'config.json'
$backupPath = Join-Path $root 'config.json.fxce-backup'
$repoUrl = 'https://github.com/fxceless/victory-fork'

function Say([string]$message, [string]$color = 'White') {
  Write-Host $message -ForegroundColor $color
}

# Restore does not need Git, Cargo, or an upstream checkout.
if ($Restore) {
  if (-not (Test-Path $backupPath)) {
    Say "No fxceless backup found at $backupPath - nothing was changed." Yellow
    exit 1
  }
  Copy-Item $backupPath $cfgPath -Force
  Say 'Restored the launcher config saved before the first fxceless switch.' Green
  Say 'The fxceless source/build remains in harness\setup\fxce; no game files were changed.' DarkGray
  exit 0
}

if (-not (Test-Path $cfgPath)) {
  Say 'No harness\config.json yet. Run START.cmd once and finish setup before switching engines.' Red
  exit 1
}
try {
  $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
} catch {
  Say "Could not read harness\config.json: $($_.Exception.Message)" Red
  exit 1
}
if (-not $cfg -or $cfg -is [System.Array]) {
  Say 'harness\config.json is not a valid launcher configuration object.' Red
  exit 1
}

Say ''
Say '=============================================================' Yellow
Say ' FXCELESS IS EXPERIMENTAL -- REVIEW BEFORE CONTINUING' Yellow
Say '=============================================================' Yellow
Say 'The upstream README (checked 2026-11-27) reports 0.2-3 world fps,' Yellow
Say 'about 23-27 GB system memory and 9.2-9.6 GB VRAM on one RTX 4070 /' Yellow
Say '32 GB test PC. These are not predictions for this computer.' Yellow
Say 'A 6 GB GPU / 16 GB RAM laptop is well below that reported test setup;' Yellow
Say 'paging, severe stalls, crashes, or no visual improvement are possible.' Yellow
Say 'This switcher does not enable the ray-tracing builder or promise to fix' Yellow
Say 'black faces, lighting, or textures. It only builds/switches the renderer.' Yellow
Say 'Source comes from a mutable third-party Git branch; binary provenance is' Yellow
Say 'not verified. Back up saves and confirm you have permission to use the game.' Yellow
Say ''
if (-not $Force) {
  $answer = Read-Host 'Build/switch to fxceless anyway? Type Y to continue'
  if ($answer -notmatch '^(?i:y|yes)$') {
    Say 'Cancelled; launcher config was not changed.' DarkGray
    exit 0
  }
}

# ---------- source checkout ----------
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCommand) {
  Say 'Git was not found. Install Git for Windows, then run this switcher again.' Red
  exit 1
}
$gitPath = $gitCommand.Source
if (-not (Test-Path $fxDir)) {
  Say 'Cloning fxceless/victory-fork (one time)...' Cyan
  New-Item -ItemType Directory -Force -Path $setup | Out-Null
  # Git writes progress to stderr on some versions; keep that ordinary output
  # from becoming a terminating NativeCommandError in Windows PowerShell 5.1.
  $oldEap = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    & $gitPath clone --depth 1 $repoUrl $fxDir
    $cloneExit = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $oldEap
  }
  if ($cloneExit -ne 0) {
    Say 'Git clone failed. Check the network and try again; the launcher config is unchanged.' Red
    exit 1
  }
} elseif (-not (Test-Path (Join-Path $fxDir '.git'))) {
  Say "The path $fxDir exists but is not a Git checkout. It was left untouched; move it aside yourself if appropriate." Red
  exit 1
} else {
  Say 'fxceless source already present; keeping this checkout without fetching updates.' DarkGray
}
if (-not (Test-Path (Join-Path $fxDir 'Cargo.toml'))) {
  Say "No Cargo.toml found in $fxDir; refusing to build this directory." Red
  exit 1
}

$sourceCommit = (& $gitPath -C $fxDir rev-parse HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $sourceCommit) {
  Say 'Could not identify the fxceless checkout revision; refusing to update launcher config.' Red
  exit 1
}
$sourceCommit = ([string]$sourceCommit).Trim()
Say "Source checkout revision: $sourceCommit" DarkGray

# ---------- build ----------
$cargo = $null
if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
  $cargoCandidate = Join-Path $env:USERPROFILE '.cargo\bin\cargo.exe'
  if (Test-Path $cargoCandidate) { $cargo = $cargoCandidate }
}
if (-not $cargo) {
  $cargoCommand = Get-Command cargo.exe -ErrorAction SilentlyContinue
  if ($cargoCommand) { $cargo = $cargoCommand.Source }
}
if (-not $cargo) {
  Say 'Cargo was not found. Run the normal START.cmd setup (which installs Rust) or install Rust for Windows, then retry.' Red
  exit 1
}

$builtNow = $false
if ($Rebuild -or -not (Test-Path $fxExe)) {
  $logDir = Join-Path $root 'data\logs'
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $buildOut = Join-Path $logDir "fxce-build-$stamp.out.log"
  $buildErr = Join-Path $logDir "fxce-build-$stamp.err.log"
  Say ''
  Say 'Building fxceless (the first release build may take a long time)...' Cyan
  Say "  stdout: $buildOut" DarkGray
  Say "  stderr: $buildErr" DarkGray
  Say 'Keep this window open; the build runs in the background and writes separate logs.' DarkGray
  $started = Get-Date
  try {
    $process = Start-Process -FilePath $cargo `
      -ArgumentList @('build', '--release', '--locked', '-p', 'victory') `
      -WorkingDirectory $fxDir -NoNewWindow -PassThru `
      -RedirectStandardOutput $buildOut -RedirectStandardError $buildErr
  } catch {
    Say "Could not start Cargo: $($_.Exception.Message)" Red
    exit 1
  }
  while (-not $process.HasExited) {
    Start-Sleep -Seconds 15
    $minutes = [math]::Round(((Get-Date) - $started).TotalMinutes, 0)
    Say "  still building... ($minutes min elapsed)" DarkGray
  }
  if ($process.ExitCode -ne 0 -or -not (Test-Path $fxExe)) {
    Say "BUILD FAILED (exit $($process.ExitCode)). Recent stderr:" Red
    Get-Content $buildErr -Tail 30 -ErrorAction SilentlyContinue | ForEach-Object { Say "  $_" Red }
    Say "Full logs: $buildOut and $buildErr" Cyan
    Say 'The launcher config was not changed.' Yellow
    exit 1
  }
  $builtNow = $true
  Say "Build OK: $fxExe" Green
} else {
  Say "Executable found - reusing by path only: $fxExe" Green
  Say 'Its build revision/options are not verified. Use -Rebuild to compile this checkout before switching.' Yellow
}

# ---------- save the prior config and switch ----------
if ($cfg.engine -ne 'fxce') {
  if (-not (Test-Path $backupPath)) {
    Copy-Item $cfgPath $backupPath
    Say "Saved the prior launcher config to $backupPath (kept until you remove it)." DarkGray
  } else {
    Say "Keeping the existing fxceless restore point at $backupPath; it will not be overwritten." Yellow
  }
} elseif (-not (Test-Path $backupPath)) {
  Say 'The current config already selects fxceless and there is no earlier config to back up.' Yellow
}

# These fields describe the selected source snapshot, not a verified executable
# build. Only record an engine commit when this invocation just completed Cargo.
[void]$cfg.PSObject.Properties.Remove('engineCommit')
[void]$cfg.PSObject.Properties.Remove('engineCommitEngine')
$cfg | Add-Member -NotePropertyName engine -NotePropertyValue 'fxce' -Force
$cfg | Add-Member -NotePropertyName harness -NotePropertyValue $fxExe -Force
$cfg | Add-Member -NotePropertyName fxceDir -NotePropertyValue $fxDir -Force
if ($builtNow) {
  $cfg | Add-Member -NotePropertyName engineCommit -NotePropertyValue $sourceCommit -Force
  $cfg | Add-Member -NotePropertyName engineCommitEngine -NotePropertyValue 'fxce' -Force
}
if ($cfg.extraEnv) {
  Say 'Your existing extraEnv values were preserved. Review them; switches may differ between forks.' Yellow
}
$tempCfg = "$cfgPath.fxce-tmp"
try {
  $cfg | ConvertTo-Json -Depth 6 | Set-Content $tempCfg -Encoding UTF8
  Move-Item -Path $tempCfg -Destination $cfgPath -Force
} catch {
  Remove-Item $tempCfg -Force -ErrorAction SilentlyContinue
  Say "Could not save the launcher config: $($_.Exception.Message)" Red
  Say 'The prior configuration backup, if created, remains available.' Yellow
  exit 1
}

Say ''
Say '=============================================================' Green
Say ' SWITCHED TO FXCELESS (experimental renderer)' Green
Say '=============================================================' Green
Say 'Play with START.cmd -> [1] PLAY. The launcher applies its fxceless profile.'
Say 'Its environment switches are recorded per run; presence in the log does not prove the binary used them.' Yellow
Say 'To return to the saved configuration: TRY-FXCELESS.cmd -Restore' Cyan
Say 'The source/build stays in harness\setup\fxce. This has not been Windows/D3D12 tested by this switcher.' DarkGray
