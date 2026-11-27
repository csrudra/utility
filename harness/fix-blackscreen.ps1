<#
.SYNOPSIS
  Automated diagnosis ladder for "Series S / 720p shows no screen" on a VIctory-family harness.
.DESCRIPTION
  Checks, in the order that covers ~all published black-screen reports:
    1. Harness binary + tree sanity          4. Pagefile / commit / disk
    2. Windows 10 Agility SDK gate           5. HDR state
    3. Laptop GPU adapter selection          6. Env fixes + the present-plane isolation trick
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File fix-blackscreen.ps1 -VictoryExe C:\src\CCS03\target\release\victory.exe
#>
[CmdletBinding()]
param(
  [string]$VictoryExe,
  [string]$RunLog            # optional: latest run log to grep for adapter / DXGI errors
)

function Say($s, $c = 'White') { Write-Host $s -ForegroundColor $c }

Say '=== Black-screen diagnosis (PORTWATCH_720P_BLACKSCREEN.md) ===' White
Say ''

# 1. Harness sanity ------------------------------------------------------
if ($VictoryExe -and (Test-Path $VictoryExe)) {
  Say "[OK] Harness found: $VictoryExe" Green
  $exeDir = Split-Path $VictoryExe
  Say '     Is this CCS03 (ccs03 branch), VKarameloVI, zsy-miao or Linox?' Cyan
  Say '     A tree without the Series S present path (FSR replacement + compose) ALWAYS black-screens with --console series-s.' Cyan
} else {
  Say "[!!] Harness binary not found. A random fork at an old commit is cause #1 of black screens." Red
  Say '     Use CCS03 branch ccs03 (see harness/README.md).' Cyan
}

# 2. Win10 Agility gate --------------------------------------------------
$os = Get-CimInstance Win32_OperatingSystem
if ([int]$os.BuildNumber -lt 22000) {
  $agility = if ($VictoryExe) { Join-Path (Split-Path $VictoryExe) 'D3D12\D3D12Core.dll' } else { $null }
  if ($agility -and (Test-Path $agility)) {
    Say "[OK] Windows 10 + Agility SDK D3D12Core.dll present" Green
  } else {
    Say "[!!] Windows 10 WITHOUT the D3D12 Agility SDK -> literally 'no pipeline can be made and the screen stays black' (CCS03)." Red
    Say '     Fix: Microsoft.Direct3D.D3D12 1.614 (NuGet) -> copy D3D12Core.dll + d3d12SDKLayers.dll into D3D12\ beside victory.exe.' Cyan
  }
} else {
  Say '[OK] Windows 11: SM 6.6 pipelines work with the built-in D3D12 runtime' Green
}

# 3. Laptop adapter ------------------------------------------------------
Say ''
Say '--- GPU adapter (the #1 laptop trap) ---' White
$intel = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'Intel' }
if ($intel) {
  Say "[..] Hybrid graphics detected ($($intel.Name) + dGPU). The run MUST execute on the NVIDIA GPU." Yellow
  Say '     - NVIDIA Control Panel -> Manage 3D -> victory.exe -> High-performance NVIDIA processor' Cyan
  Say '     - Windows Settings -> Display -> Graphics -> the exe -> High performance' Cyan
  Say '     - Or set: VICTORY_D3D12_ADAPTER=<index|name>  (CCS03 prints the adapter in the log)' Cyan
  Say '     - If your laptop has a MUX switch: enable dGPU-only mode (Advanced Optimus)' Cyan
}
if ($RunLog -and (Test-Path $RunLog)) {
  Say ''
  Say "--- Scanning run log: $RunLog ---" White
  $log = Get-Content $RunLog
  $adapter = $log | Select-String -Pattern 'adapter|Adapter|GPU' | Select-Object -First 3
  if ($adapter) { $adapter | ForEach-Object { Say "     $($_.Line.Trim())" Gray } }
  $errs = $log | Select-String -Pattern 'DXGI_ERROR|0x887A|device (removed|lost)|TDR|headless|swapchain' | Select-Object -First 8
  if ($errs) {
    Say '[!!] Errors found in log:' Red
    $errs | ForEach-Object { Say "     $($_.Line.Trim())" Red }
    Say '     DXGI_ERROR_INVALID_CALL / 0x887A0001 in FFX/FSR  -> VICTORY_OWN_UPSCALER=1 missing (play.ps1 sets it)' Cyan
    Say '     0x887A0005/0x887A0006 device removed            -> VRAM/commit pressure: lower TextureBudgetMB, raise pagefile' Cyan
    Say '     headless / swapchain                             -> swapchain creation failed: turn HDR OFF, run borderless windowed' Cyan
  } else {
    Say '[OK] No known black-screen error signatures in log' Green
  }
}

# 4. Memory -------------------------------------------------------------
Say ''
Say '--- Memory gates ---' White
$pf = Get-CimInstance Win32_PageFileUsage
$pfGB = if ($pf) { [math]::Round(($pf | Measure-Object AllocatedBaseSize -Sum).Sum / 1024, 1) } else { 0 }
if ($pfGB -ge 48) { Say "[OK] Pagefile ${pfGB} GB" Green }
else { Say "[!!] Pagefile only ${pfGB} GB -> fix at 48-64 GB on NVMe (commit exhaustion = boot-time black screen)" Red }
$free = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
Say "     Free RAM now: ${free} GB. The title needs SEVERAL GB of free commit at startup (Linox). Close browsers." Yellow
Say '     Shader cache needs ~5 GB free disk and is PER-PC (VICTORY_CACHE_DIR). Never copy a cache from another machine.' Cyan

# 5. HDR ----------------------------------------------------------------
$hdr = $null
try { $hdr = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings' -Name EnableHDRForPlayback -ErrorAction Stop } catch { }
if ($hdr -and $hdr.EnableHDRForPlayback -ne 0) {
  Say '[!!] Windows HDR ON -> swapchain failures / silent headless mode. TURN HDR OFF.' Red
} else {
  Say '[OK] HDR off or not detectable' Green
}

# 6. Env + isolation ----------------------------------------------------
Say ''
Say '--- The fixes that produce a picture (play.ps1 sets all of these) ---' White
Say '     VICTORY_OWN_UPSCALER=1   (Series S FSR step draws NOTHING without it)' Cyan
Say '     VICTORY_COMPOSE=1        (Series S = two planes; without compose: black menus/loading)' Cyan
Say '     VICTORY_SHOW_AFTER=1     (present-before-upload = device loss every ~15 min)' Cyan
Say '     VICTORY_DYNAMIC_SLOTS=262144 (NVIDIA view cap; without it the screen rarely updates)' Cyan
Say ''
Say '--- Isolation trick (which plane/path is broken?) ---' White
Say '     1. VICTORY_PRESENT_PLANE=0 then =1  -> shows world plane / interface plane alone' Cyan
Say '     2. Launch with -SeriesX (play.ps1) at 720p -> if Series X shows a picture but Series S does not,' Cyan
Say '        your tree lacks the Series S present path: switch to CCS03.' Cyan
Say '     3. Still nothing: run play.ps1 -Diag and read why draws are dropped.' Cyan
Say ''
Say 'Done. Fix [!!] items top-down, then relaunch with play.ps1.' White
