<#
.SYNOPSIS
  Preflight checks for running a VIctory-family harness (CCS03) on a 6 GB / 16 GB laptop.
.DESCRIPTION
  Verifies OS, GPU, RAM/commit, pagefile, disk, HDR and CPU features before you burn an
  evening on a black screen. Prints PASS / WARN / FAIL with the exact fix per failure.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File preflight.ps1 -VictoryExe C:\src\CCS03\target\release\victory.exe
#>
[CmdletBinding()]
param(
  [string]$VictoryExe,                     # optional: also verify the built harness exists
  [int]$MinDiskGB = 30,
  [int]$MinPagefileGB = 48
)

$script:fail = 0
function Result($status, $name, $detail, $fix) {
  $color = switch ($status) { 'PASS' {'Green'} 'WARN' {'Yellow'} default {'Red'} }
  if ($status -eq 'FAIL') { $script:fail++ }
  Write-Host ("[{0,-4}] {1}: {2}" -f $status, $name, $detail) -ForegroundColor $color
  if ($fix) { Write-Host ("       fix: {0}" -f $fix) -ForegroundColor Cyan }
}

Write-Host "=== GTA VI harness preflight (6 GB / 16 GB laptop profile) ===" -ForegroundColor White

# --- OS -----------------------------------------------------------------
$os = Get-CimInstance Win32_OperatingSystem
$build = [int]$os.BuildNumber
if ($build -ge 22000) {
  Result 'PASS' 'OS' "$($os.Caption) (build $build) - SM 6.6 pipelines work out of the box"
} else {
  Result 'WARN' 'OS' "$($os.Caption) (build $build) - Windows 10 refuses the title's SM 6.6 descriptor heaps" `
    "Agility SDK 1.614: put D3D12Core.dll + d3d12SDKLayers.dll in a 'D3D12' folder BESIDE victory.exe (CCS03 PR 7). Without it: no pipeline can be made and the screen stays black."
}

# --- CPU ----------------------------------------------------------------
$cpu = Get-CimInstance Win32_Processor
$avx2 = $null
try { $avx2 = [System.Runtime.Intrinsics.X86.Avx2]::IsSupported } catch { }
if ($avx2 -eq $true) {
  Result 'PASS' 'CPU' "$($cpu.Name) - AVX2 present"
} elseif ($avx2 -eq $false) {
  Result 'FAIL' 'CPU' "$($cpu.Name) - AVX2 NOT supported" 'The harness requires AVX2. This CPU cannot run it.'
} else {
  Result 'WARN' 'CPU' "$($cpu.Name) - AVX2 could not be auto-detected (PowerShell 5.1)" 'Verify AVX2 manually (i5/i7/i9 12th gen = yes).'
}

# --- GPU ----------------------------------------------------------------
$gpuFound = $false
try {
  $smi = & nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>$null
  if ($smi) {
    $gpuFound = $true
    $line = ($smi | Select-Object -First 1)
    Result 'PASS' 'GPU (NVIDIA)' $line "Confirm at run time that the LOG shows this GPU as the adapter (play.ps1 prints the check). If it shows Intel, force: NVIDIA Control Panel -> victory.exe -> High-performance processor; or set VICTORY_D3D12_ADAPTER."
  }
} catch { }
if (-not $gpuFound) {
  $gpus = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name
  Result 'WARN' 'GPU' ("nvidia-smi not found; adapters: " + ($gpus -join ', ')) `
    'Install the NVIDIA Game Ready driver. The harness auto-picks the discrete GPU but always verify the adapter line in the run log.'
}

# --- RAM + commit -------------------------------------------------------
$cs = Get-CimInstance Win32_ComputerSystem
$ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
$os2 = Get-CimInstance Win32_OperatingSystem
$freeGB = [math]::Round($os2.FreePhysicalMemory / 1MB, 1)
if ($ramGB -ge 32) { Result 'PASS' 'RAM' "$ramGB GB installed, $freeGB GB free" }
elseif ($ramGB -ge 16) {
  Result 'WARN' 'RAM' "$ramGB GB installed, $freeGB GB free - builds commit 22-46 GB" `
    'It will run, but expect paging frame spikes. 32/64 GB SODIMMs are the single biggest real-fps upgrade for this project. Close browsers before launch.'
} else {
  Result 'FAIL' 'RAM' "$ramGB GB installed" '16 GB minimum; 32 GB strongly recommended.'
}

# --- pagefile -----------------------------------------------------------
$pf = Get-CimInstance Win32_PageFileUsage
if ($pf) {
  $pfGB = [math]::Round(($pf | Measure-Object -Property AllocatedBaseSize -Sum).Sum / 1024, 1)
  if ($pfGB -ge $MinPagefileGB) {
    Result 'PASS' 'Pagefile' "$pfGB GB allocated"
  } else {
    Result 'WARN' 'Pagefile' "$pfGB GB allocated (want >= $MinPagefileGB GB)" `
      "Set a FIXED $MinPagefileGB-64 GB pagefile on the fastest NVMe (SystemPropertiesAdvanced -> Performance -> Advanced). Error 1455 / commit exhaustion otherwise."
  }
} else {
  Result 'WARN' 'Pagefile' 'No pagefile found (system-managed?)' `
    "Set a FIXED $MinPagefileGB-64 GB pagefile on the fastest NVMe."
}

# --- disk ---------------------------------------------------------------
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$small = $disks | Where-Object { [math]::Round($_.FreeSpace / 1GB, 1) -lt $MinDiskGB }
if ($small) {
  foreach ($d in $small) {
    Result 'WARN' "Disk $($d.DeviceID)" ("{0} GB free" -f [math]::Round($d.FreeSpace / 1GB, 1)) `
      "The shader/pipeline cache alone rewrites ~5 GB. Free at least $MinDiskGB GB."
  }
} else {
  Result 'PASS' 'Disk' "All fixed disks have >= $MinDiskGB GB free (cache + pagefile headroom)"
}

# --- HDR ----------------------------------------------------------------
$hdr = $null
try {
  $hdr = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings' -Name EnableHDRForPlayback -ErrorAction Stop
} catch { }
if ($hdr -and $hdr.EnableHDRForPlayback -ne 0) {
  Result 'WARN' 'HDR' 'Windows HDR appears enabled' 'Turn HDR OFF (Settings -> Display). HDR swapchains fail or run out of memory in these layers; some go silently "headless" (no window) on swapchain failure.'
} else {
  Result 'PASS' 'HDR' 'HDR off or not detectable'
}

# --- harness binary -----------------------------------------------------
if ($VictoryExe) {
  if (Test-Path $VictoryExe) {
    Result 'PASS' 'Harness' $VictoryExe
    $d3d12 = Join-Path (Split-Path $VictoryExe) 'D3D12\D3D12Core.dll'
    if ($build -lt 22000 -and -not (Test-Path $d3d12)) {
      Result 'FAIL' 'Agility SDK' "Missing: $d3d12" 'Windows 10 needs it. See the OS entry above.'
    }
  } else {
    Result 'FAIL' 'Harness' "Not found: $VictoryExe" 'Build it: cargo build --release -p victory (branch ccs03).'
  }
}

Write-Host ''
if ($script:fail -gt 0) {
  Write-Host "PREFLIGHT: $script:fail FAIL item(s) - fix them before launching." -ForegroundColor Red
  exit 1
} else {
  Write-Host 'PREFLIGHT: all critical checks passed. Launch with play.ps1.' -ForegroundColor Green
  exit 0
}
