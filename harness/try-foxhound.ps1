# TRY-FOXHOUND - one-click switcher between the default harness (CCS03) and
# foxhound (readmet3xt-lab/foxhound), a VIctory fork tuned for NVIDIA RTX:
# DLSS Super Resolution / Frame Generation, 64->32-lane compute fixes, fewer
# stalls, pipeline pre-warm. See harness\README.md ("Try foxhound").
#
#   TRY-FOXHOUND.cmd              install/switch to foxhound (builds it once)
#   TRY-FOXHOUND.cmd -Restore     switch back to the CCS03 harness
#
# Never rebuilds finished work: an existing foxhound build is adopted as-is.
# Never destroys your setup: the old config.json is saved to config.json.backup
# (kept forever) and -Restore brings it back. Your game, saves and logs are
# untouched by this script.

param(
  [switch]$Restore,
  [string]$StreamlineDir,   # folder that contains sl.interposer.dll (optional, DLSS)
  [ValidateSet('off','dlaa','quality','balanced','performance')]
  [string]$Dlss = 'quality',
  [switch]$FrameGen         # DLSS Frame Generation (officially RTX 40+)
)

$ErrorActionPreference = 'Stop'
$root   = $PSScriptRoot                                   # ...\harness
$repo   = Split-Path $root -Parent                        # ...\utility-main
$setup  = Join-Path $root 'setup'
$foxDir = Join-Path $setup 'foxhound'
$foxExe = Join-Path $foxDir 'target\release\victory.exe'
$cfgPath = Join-Path $root 'config.json'
$backup  = Join-Path $root 'config.json.backup'

function Say([string]$m, [string]$c = 'White') { Write-Host $m -ForegroundColor $c }

# ---------- switch back ----------
if ($Restore) {
  if (-not (Test-Path $backup)) { Say "No $backup - nothing to restore." Yellow; exit 1 }
  Copy-Item $backup $cfgPath -Force
  Say 'Restored the CCS03 harness config. Start.cmd [1] PLAY works as before.' Green
  exit 0
}

# ---------- 1. get the source ----------
if (-not (Test-Path (Join-Path $foxDir '.git'))) {
  Say 'Cloning foxhound (one time)...' Cyan
  New-Item -ItemType Directory -Force -Path $setup | Out-Null
  & git clone --depth 1 https://github.com/readmet3xt-lab/foxhound $foxDir
  if ($LASTEXITCODE -ne 0) { Say 'git clone failed. Check your internet and try again.' Red; exit 1 }
} else {
  Say 'foxhound source already present - keeping it (delete harness\setup\foxhound to re-fetch).' DarkGray
}

# ---------- 2. build (skip if built) ----------
if (Test-Path $foxExe) {
  Say "Build found - using it as-is: $foxExe" Green
} else {
  $cargo = Join-Path "$env:USERPROFILE\.cargo\bin" 'cargo.exe'
  if (-not (Test-Path $cargo)) { $cargo = 'cargo' }
  Say 'Building foxhound (10-15 min the first time). Progress in harness\data\logs\foxhound-build.log' Cyan
  Say 'Safe to leave alone - never interrupt a first build.' DarkGray
  $logDir = Join-Path $root 'data\logs'; New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $buildLog = Join-Path $logDir 'foxhound-build.log'
  $p = Start-Process -FilePath $cargo -ArgumentList @('build','--release','--locked','-p','victory') `
       -WorkingDirectory $foxDir -NoNewWindow -PassThru `
       -RedirectStandardOutput "$buildLog.out" -RedirectStandardError "$buildLog.err"
  $dots = 0
  while (-not $p.HasExited) {
    Start-Sleep -Seconds 20; $dots++
    $mins = [math]::Round(((Get-Date) - $p.StartTime).TotalMinutes, 0)
    Say ("  still building... ($mins min elapsed)" ) DarkGray
    if ($dots % 9 -eq 0) { Get-Content "$buildLog.err" -Tail 2 -ErrorAction SilentlyContinue | ForEach-Object { Say "    $_" DarkGray } }
  }
  Get-Content "$buildLog.err" -Tail 40 | Set-Content $buildLog
  if ($p.ExitCode -ne 0 -or -not (Test-Path $foxExe)) {
    Say "BUILD FAILED (exit $($p.ExitCode)). See $buildLog" Red
    Say 'Most common cause: missing "Desktop development with C++" in Visual Studio Build Tools.' Yellow
    exit 1
  }
  Say "Build OK: $foxExe" Green
}

# ---------- 3. DLSS / Streamline (optional) ----------
$candidates = @($StreamlineDir, $env:VICTORY_STREAMLINE_DIR, 'C:\dev\sdk\streamline-sdk-v2.14.16\bin\x64') |
              Where-Object { $_ } | ForEach-Object { $_.TrimEnd('\') }
$sl = $candidates | Where-Object { Test-Path (Join-Path $_ 'sl.interposer.dll') } | Select-Object -First 1
if (-not $sl) {
  Say ''
  Say 'DLSS (recommended on RTX): download the NVIDIA Streamline SDK release from' Yellow
  Say 'https://github.com/NVIDIA-RTX/Streamline - unzip it anywhere, then run:' Yellow
  Say '  TRY-FOXHOUND.cmd -StreamlineDir "D:\sdk\streamline\bin\x64"' Yellow
  Say 'Continuing WITHOUT DLSS (the title''s own upscaling is used).' Yellow
} else {
  Say "DLSS: found Streamline at $sl" Green
}

# ---------- 4. GPU check for Frame Generation ----------
$gpuNames = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object Name)
$fgOk = [bool]($gpuNames -match 'RTX (40|50)\d{2}')   # RTX 40xx / 50xx
if ($FrameGen -and -not $fgOk) {
  Say 'NOTE: DLSS Frame Generation officially needs an RTX 40+ card.' Yellow
  Say 'Your RTX 30 card can still use DLSS Super Resolution. (Community FG unlocks for' Yellow
  Say 'RTX 30 exist - dlssg_for_sm86 / NVSmooth30 - but are untested with this stack.)' Yellow
  $FrameGen = $false
}
if ($sl -and -not $fgOk) { Say 'DLSS Super Resolution works on every RTX card - you get it.' DarkGray }

# ---------- 5. flip the launcher config ----------
if (-not (Test-Path $cfgPath)) {
  Say 'No harness\config.json yet. Run START.cmd once (choose your game) FIRST, then run this again.' Red
  exit 1
}
$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
if (-not (Test-Path $backup)) { Copy-Item $cfgPath $backup; Say 'Your CCS03 config was saved to config.json.backup (kept forever).' DarkGray }

$cfg | Add-Member -NotePropertyName engine      -NotePropertyValue 'foxhound' -Force
$cfg | Add-Member -NotePropertyName harness     -NotePropertyValue $foxExe -Force
$cfg | Add-Member -NotePropertyName foxhoundDir -NotePropertyValue $foxDir -Force
$cfg | Add-Member -NotePropertyName dlssMode    -NotePropertyValue $Dlss -Force
$cfg | Add-Member -NotePropertyName framegen    -NotePropertyValue ([bool]$FrameGen) -Force
if ($sl) { $cfg | Add-Member -NotePropertyName streamlineDir -NotePropertyValue $sl -Force }
$cfg | ConvertTo-Json -Depth 5 | Set-Content $cfgPath -Encoding UTF8

Say ''
Say '=============================================================' Green
Say ' SWITCHED TO FOXHOUND (NVIDIA-tuned engine)' Green
Say '=============================================================' Green
Say 'Play as usual:  START.cmd  ->  [1] PLAY'
Say ''
Say 'What you should expect on an RTX 3060 6GB / i7-12700H / 16 GB:'
Say '  - more fps than the default harness (community: RTX 3080 ~15 fps,'
Say '    i5-12600KF ~10-15 fps in the prologue), sharper image with DLSS'
Say '  - WARNING: below 30 fps the world runs slower than real time (the'
Say '    title steps its world per frame - the fork says so honestly).'
Say '  - WARNING: the fork wants 32 GB RAM. Keep the 48-64 GB pagefile'
Say '    on and close browsers. Watch the RAM line in the panel.'
Say '  - Keep the 6GB budgets (768/512) - they work in this engine too.'
Say ''
Say 'Switch back any time:   TRY-FOXHOUND.cmd -Restore' Cyan
