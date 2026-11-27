<#
.SYNOPSIS
  Read-only triage hints for a black or blank game window.
.DESCRIPTION
  Checks a few host and log clues. It does not cover every failure mode,
  verify GPU feature support, apply fixes, or diagnose dark lighting/artifacts.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File fix-blackscreen.ps1 -VictoryExe C:\src\CCS03\target\release\victory.exe -Engine ccs03
#>
[CmdletBinding()]
param(
  [string]$VictoryExe,
  [string]$RunLog,           # optional: captured stdout log
  [string]$RunErrorLog,      # optional: matching captured stderr log
  [string]$Engine = 'ccs03'
)

function Say($s, $c = 'White') { Write-Host $s -ForegroundColor $c }

Say '=== Black-screen diagnosis (read-only; this script changes nothing) ===' White
Say ''

# 1. Harness sanity ------------------------------------------------------
if ($VictoryExe -and (Test-Path $VictoryExe)) {
  Say "[OK] Harness found: $VictoryExe" Green
  $exeDir = Split-Path $VictoryExe
  Say '     Confirm which repository and commit produced this binary; forks have different switches and present paths.' Cyan
  Say '     A missing Series S upscaler/compose path is one possible black-window cause, not a universal rule.' Cyan
} else {
  Say '[!!] Harness binary not found at the configured path.' Red
  Say '     This prevents a reliable diagnosis. Check config.json and the build log.' Cyan
}

# 2. Windows 10 Agility files: only documented for this CCS03 setup --------
$os = Get-CimInstance Win32_OperatingSystem
if ([int]$os.BuildNumber -lt 22000 -and $Engine -eq 'ccs03') {
  $agilityDir = if ($VictoryExe) { Join-Path (Split-Path $VictoryExe) 'D3D12' } else { $null }
  $core = if ($agilityDir) { Join-Path $agilityDir 'D3D12Core.dll' } else { $null }
  $layers = if ($agilityDir) { Join-Path $agilityDir 'd3d12SDKLayers.dll' } else { $null }
  if ($core -and $layers -and (Test-Path $core) -and (Test-Path $layers)) {
    Say '[INFO] Both Agility SDK files documented for CCS03 are present; their versions still need to match.' Green
  } else {
    Say '[WARN] One or both Agility SDK files documented for CCS03 are missing; this is one possible pipeline issue, not a diagnosis.' Yellow
    Say '       Check that D3D12Core.dll and d3d12SDKLayers.dll are both in D3D12\ beside victory.exe.' Cyan
  }
} elseif ([int]$os.BuildNumber -lt 22000) {
  Say "[INFO] Windows 10 SDK guidance is fork-specific; not applying the CCS03 check to '$Engine'." Cyan
} else {
  Say '[INFO] Windows 11 detected; GPU feature support and driver health still need to be verified from the run log.' Cyan
}

# 3. Laptop adapter ------------------------------------------------------
Say ''
Say '--- Hybrid-GPU hint (this is not adapter verification) ---' White
$intel = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'Intel' }
if ($intel) {
  Say "[INFO] Hybrid graphics detected ($($intel.Name) + dGPU). Check the run log to see which adapter was actually selected." Yellow
  Say '     - For NVIDIA: NVIDIA Control Panel -> Manage 3D -> victory.exe -> High-performance NVIDIA processor.' Cyan
  Say '     - Windows Settings -> Display -> Graphics -> the exe -> High performance, then verify the adapter in the log.' Cyan
  Say '     - Some forks support VICTORY_D3D12_ADAPTER=<index|name>; check that exact fork before using it.' Cyan
  Say '     - If your laptop has a MUX switch, dGPU-only mode is an A/B test, not a diagnosis by itself.' Cyan
}
$logsToScan = @($RunLog, $RunErrorLog) | Where-Object {
  -not [string]::IsNullOrWhiteSpace([string]$_) -and (Test-Path $_)
}
foreach ($logPath in $logsToScan) {
  Say ''
  Say "--- Scanning run log: $logPath ---" White
  $log = Get-Content $logPath
  $adapter = $log | Select-String -Pattern 'adapter|Adapter|GPU' | Select-Object -First 3
  if ($adapter) { $adapter | ForEach-Object { Say "     $($_.Line.Trim())" Gray } }
  $errs = $log | Select-String -Pattern 'DXGI_ERROR|0x887A|device (removed|lost)|TDR|headless|swapchain' | Select-Object -First 8
  if ($errs) {
    Say '[WARN] Matching error clues found; inspect the surrounding log context:' Yellow
    $errs | ForEach-Object { Say "     $($_.Line.Trim())" Red }
    Say '     0x887A0001 / INVALID_CALL -> inspect the failing API/path; an upscaler flag helps only if this exact build implements it.' Cyan
    Say '     0x887A0005/0x887A0006 -> device removed/hung; collect DRED + Event Viewer evidence before changing VRAM/pagefile settings.' Cyan
    Say '     headless / swapchain -> inspect swapchain/HDR/window mode; turning HDR off is an A/B test, not a guaranteed fix.' Cyan
  } else {
    Say '[INFO] No matching error signature was found in this log; that does not rule out a failure.' Gray
  }
}

# 4. Memory -------------------------------------------------------------
Say ''
Say '--- Memory gates ---' White
$pf = Get-CimInstance Win32_PageFileUsage
$pfGB = if ($pf) { [math]::Round(($pf | Measure-Object AllocatedBaseSize -Sum).Sum / 1024, 1) } else { 0 }
if ($pfGB -ge 48) { Say "[INFO] Pagefile allocation ${pfGB} GB (not the configured maximum or current commit headroom)." Gray }
else { Say "[INFO] Pagefile allocation ${pfGB} GB; this is below one test reference, not evidence of a black-screen cause." Gray }
$free = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
Say "     Free physical RAM now: ${free} GB. Check Task Manager > Memory > Committed and the run log for actual commit/OOM exhaustion." Yellow
Say '     Shader/pipeline caches are machine/build-specific; do not copy caches from another machine or build.' Cyan

# 5. HDR ----------------------------------------------------------------
$hdr = $null
try { $hdr = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings' -Name EnableHDRForPlayback -ErrorAction Stop } catch { }
if ($hdr -and $hdr.EnableHDRForPlayback -ne 0) {
  Say '[INFO] HDR registry flag is set; confirm the actual setting in Windows Display Settings. HDR off is a useful A/B test, not a proven cause.' Yellow
} else {
  Say '[INFO] HDR registry flag is off or unavailable; this script cannot reliably verify the active HDR state.' Gray
}

# 6. Env + isolation ----------------------------------------------------
Say ''
Say '--- Relevant paths to check (support varies by repository/commit) ---' White
Say '     Series S upscaler/compose flags may matter, but only when this build implements them.' Cyan
Say '     The launcher clears inherited VICTORY_* switches; put intentional diagnostics in config.json extraEnv.' Cyan
Say '     Example: "extraEnv": { "VICTORY_PRESENT_PLANE": "0" } (compare 0, 1, then remove it).' Cyan
Say ''
Say '--- Useful next evidence ---' White
Say '     1. Distinguish a black game window from dark shadows, black faces/textures, and a driver reset.' Cyan
Say '     2. Compare the run log, settings-*.txt, Windows Event Viewer, and screenshot from the same scene.' Cyan
Say '     3. Use a Series X vs Series S profile only if the selected fork documents both; this launcher has no profile toggle.' Cyan
Say ''
Say 'This script is read-only. It reports clues; it has not changed settings or repaired anything.' White
