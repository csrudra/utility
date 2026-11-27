<#
.SYNOPSIS
  Advisory host checks for a VIctory-family harness.
.DESCRIPTION
  Reports host and environment clues. It cannot identify a black-screen root cause,
  verify every adapter/fork requirement, or prescribe a universal pagefile/HDR setting.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File preflight.ps1 -VictoryExe C:\src\CCS03\target\release\victory.exe
#>
[CmdletBinding()]
param(
  [string]$VictoryExe,                     # optional: also verify the built harness exists
  [string]$Engine = 'ccs03',
  [int]$MinDiskGB = 30,
  [int]$MinPagefileGB = 48
)

$script:fail = 0
function Result($status, $name, $detail, $fix) {
  $color = switch ($status) { 'PASS' {'Green'} 'INFO' {'Cyan'} 'WARN' {'Yellow'} default {'Red'} }
  if ($status -eq 'FAIL') { $script:fail++ }
  Write-Host ("[{0,-4}] {1}: {2}" -f $status, $name, $detail) -ForegroundColor $color
  if ($fix) { Write-Host ("       fix: {0}" -f $fix) -ForegroundColor Cyan }
}

Write-Host "=== Harness preflight (engine: $Engine; advisory checks) ===" -ForegroundColor White

# --- OS -----------------------------------------------------------------
$os = Get-CimInstance Win32_OperatingSystem
$build = [int]$os.BuildNumber
if ($build -ge 22000) {
  Result 'INFO' 'OS' "$($os.Caption) (build $build) - Windows 11 detected; this check does not verify D3D feature support or driver health"
} elseif ($Engine -eq 'ccs03') {
  Result 'WARN' 'OS' "$($os.Caption) (build $build) - CCS03 documents a D3D12 Agility SDK runtime on Windows 10" `
    'Check the exact source/build instructions. Missing SDK files are one possible pipeline failure, not proof of the cause.'
} else {
  Result 'INFO' 'OS' "$($os.Caption) (build $build) - D3D12 SDK requirements are fork-specific for '$Engine'"
}

# --- CPU ----------------------------------------------------------------
$cpu = Get-CimInstance Win32_Processor
$avx2 = $null
try { $avx2 = [System.Runtime.Intrinsics.X86.Avx2]::IsSupported } catch { }
if ($avx2 -eq $true) {
  Result 'PASS' 'CPU' "$($cpu.Name) - AVX2 present"
} elseif ($avx2 -eq $false) {
  Result 'WARN' 'CPU' "$($cpu.Name) - this runtime reports AVX2 unavailable" 'Check the selected fork''s documented CPU requirement. This advisory does not establish a rendering failure.'
} else {
  $name = $cpu.Name
  Result 'INFO' 'CPU' "$name - this PowerShell/.NET runtime could not query AVX2 support" 'Check the selected fork''s documented CPU requirement; a model-name heuristic is intentionally not treated as proof.'
}

# --- GPU ----------------------------------------------------------------
$gpuFound = $false
try {
  $smi = & nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>$null
  if ($smi) {
    $gpuFound = $true
    $line = ($smi | Select-Object -First 1)
    Result 'INFO' 'NVIDIA device' $line 'nvidia-smi sees a device; this does not prove that the game selected it. Confirm the adapter name in the run log.'
  }
} catch { }
if (-not $gpuFound) {
  $gpus = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name
  Result 'INFO' 'GPU adapters' ($gpus -join ', ') `
    'nvidia-smi is unavailable; this is normal on AMD/Intel. The adapter actually used must be confirmed in the selected fork''s run log.'
}

# --- RAM + commit -------------------------------------------------------
$cs = Get-CimInstance Win32_ComputerSystem
$ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
$os2 = Get-CimInstance Win32_OperatingSystem
$freeGB = [math]::Round($os2.FreePhysicalMemory / 1MB, 1)
$ramStatus = if ($ramGB -lt 16) { 'WARN' } else { 'INFO' }
Result $ramStatus 'RAM' "$ramGB GB visible, $freeGB GB currently free" 'Memory demand varies sharply by fork, scene, and settings; compare commit usage and the selected fork''s stated requirements. This is not a universal pass/fail threshold.'

# --- commit/pagefile clues ----------------------------------------------
$pf = Get-CimInstance Win32_PageFileUsage
if ($pf) {
  $pfGB = [math]::Round(($pf | Measure-Object -Property AllocatedBaseSize -Sum).Sum / 1024, 1)
  if ($pfGB -lt $MinPagefileGB) {
    Result 'INFO' 'Pagefile' "$pfGB GB currently allocated (below the optional $MinPagefileGB GB reference target)" `
      'This value is not the commit limit and does not prove exhaustion. Check Task Manager > Performance > Memory > Committed and run logs for actual OOM/commit errors.'
  } else {
    Result 'INFO' 'Pagefile' "$pfGB GB currently allocated; this is not the configured maximum or proof of available commit headroom"
  }
} else {
  Result 'INFO' 'Pagefile' 'Win32_PageFileUsage reported no allocated pagefile; a system-managed pagefile may still be configured' `
    'Check Windows virtual-memory settings and Task Manager committed-memory headroom; this check does not prove why the game is black.'
}

# --- disk ---------------------------------------------------------------
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$small = $disks | Where-Object { [math]::Round($_.FreeSpace / 1GB, 1) -lt $MinDiskGB }
if ($small) {
  foreach ($d in $small) {
    Result 'WARN' "Disk $($d.DeviceID)" ("{0} GB free" -f [math]::Round($d.FreeSpace / 1GB, 1)) `
      "Below this tool's $MinDiskGB GB conservative free-space buffer. Actual build/cache needs depend on the selected fork; this is not evidence for a black frame."
  }
} else {
  Result 'INFO' 'Disk' "All fixed disks have at least $MinDiskGB GB free (the tool's conservative buffer)"
}

# --- HDR ----------------------------------------------------------------
$hdr = $null
try {
  $hdr = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings' -Name EnableHDRForPlayback -ErrorAction Stop
} catch { }
if ($hdr -and $hdr.EnableHDRForPlayback -ne 0) {
  Result 'INFO' 'HDR registry hint' 'A registry value is set; this does not reliably verify active Windows HDR state' 'If the failure began after a display-mode change, compare the same scene with HDR toggled in Windows Display Settings, one change at a time.'
} else {
  Result 'INFO' 'HDR registry hint' 'HDR appears off or could not be detected; this script cannot reliably verify the active state'
}

# --- harness binary -----------------------------------------------------
if ($VictoryExe) {
  if (Test-Path $VictoryExe) {
    Result 'PASS' 'Harness' $VictoryExe
    $d3d12Dir = Join-Path (Split-Path $VictoryExe) 'D3D12'
    $d3d12 = Join-Path $d3d12Dir 'D3D12Core.dll'
    $layers = Join-Path $d3d12Dir 'd3d12SDKLayers.dll'
    if ($build -lt 22000 -and $Engine -eq 'ccs03' -and ((-not (Test-Path $d3d12)) -or (-not (Test-Path $layers)))) {
      Result 'WARN' 'Agility SDK' "One or both CCS03-documented files are missing: $d3d12 and $layers" 'Confirm the exact CCS03 build instructions and that the versions match. This is one possible failure, not a universal black-screen diagnosis.'
    }
  } else {
    Result 'FAIL' 'Harness' "Not found: $VictoryExe" "Verify the selected '$Engine' installation and the configured executable path."
  }
}

Write-Host ''
if ($script:fail -gt 0) {
  Write-Host "PREFLIGHT: $script:fail FAIL item(s) - fix them before launching." -ForegroundColor Red
  exit 1
} else {
  Write-Host 'PREFLIGHT: no critical failure was detected by these limited checks; confirm the selected fork''s requirements.' -ForegroundColor Green
  exit 0
}
