<#
.SYNOPSIS
  Updates this folder from GitHub. Double-click pull.bat.
.DESCRIPTION
  Safe by design: it NEVER touches your build (harness\setup), your settings
  (harness\config.json) or your logs (harness\data) - only the program files
  are updated. Works both for folders from "Download ZIP" and "git clone".
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$root = $PSScriptRoot

Write-Host '=== Update from GitHub ===' -ForegroundColor Cyan
Write-Host ''

# --- show what is new (best effort, needs internet) ---
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $ProgressPreference = 'SilentlyContinue'
  $commits = Invoke-RestMethod 'https://api.github.com/repos/csrudra/utility/commits?per_page=1' -UseBasicParsing
  if ($commits -and $commits.Count -gt 0) {
    Write-Host "Newest change on GitHub: $($commits[0].commit.message)" -ForegroundColor DarkGray
    Write-Host "                         ($($commits[0].commit.author.date))" -ForegroundColor DarkGray
    Write-Host ''
  }
} catch { }

# ============================ git folder ==============================
if ((Test-Path (Join-Path $root '.git')) -and (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host 'This is a git folder - pulling the latest changes...' -ForegroundColor White
  & git -C $root pull --ff-only origin main
  if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host 'Done. You are up to date.' -ForegroundColor Green
  } else {
    Write-Host ''
    Write-Host 'Automatic git update did not finish. Easiest fix for a non-technical user:' -ForegroundColor Yellow
    Write-Host 'download https://github.com/csrudra/utility/archive/refs/heads/main.zip' -ForegroundColor Cyan
    Write-Host 'and unzip it over this folder (your setup/data/config are kept).' -ForegroundColor Cyan
  }
  exit $LASTEXITCODE
}

# ============================ ZIP folder ==============================
Write-Host 'This is a Download-ZIP folder - downloading the latest version...' -ForegroundColor White
$tmp = Join-Path $env:TEMP ("utility-update-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$zip = Join-Path $tmp 'main.zip'

try {
  Invoke-WebRequest 'https://github.com/csrudra/utility/archive/refs/heads/main.zip' -OutFile $zip -UseBasicParsing
} catch {
  Write-Host ''
  Write-Host 'DOWNLOAD FAILED. Check your internet connection and run this again.' -ForegroundColor Red
  exit 1
}

try {
  Expand-Archive -Path $zip -DestinationPath $tmp -Force
} catch {
  Write-Host 'Could not open the downloaded files. Run this again.' -ForegroundColor Red
  exit 1
}
$srcDir = Get-ChildItem $tmp -Directory | Select-Object -First 1
if (-not $srcDir) {
  Write-Host 'Could not read the downloaded files. Run this again.' -ForegroundColor Red
  exit 1
}

# never touch these (the user's own stuff)
$protected = @('harness\setup', 'harness\data', 'harness\config.json')
function Test-Protected([string]$rel) {
  foreach ($p in $protected) {
    if ($rel.Equals($p, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    if ($rel.StartsWith($p + '\', [StringComparison]::OrdinalIgnoreCase)) { return $true }
  }
  return $false
}

$new = 0; $upd = 0; $skipped = 0
$failed = New-Object System.Collections.Generic.List[string]

foreach ($f in (Get-ChildItem $srcDir.FullName -Recurse -File)) {
  $rel = $f.FullName.Substring($srcDir.FullName.Length + 1)
  if (Test-Protected $rel) { $skipped++; continue }
  $dest = Join-Path $root $rel
  $isNew = -not (Test-Path $dest)
  if (-not $isNew) {
    try {
      if ((Get-FileHash $f.FullName).Hash -eq (Get-FileHash $dest).Hash) { continue }  # identical - leave it
    } catch { }
  }
  try {
    $destDir = Split-Path $dest
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    Copy-Item $f.FullName $dest -Force
    if ($isNew) { $new++ } else { $upd++ }
  } catch {
    $failed.Add($rel)
  }
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

# --- report, in plain words ---
Write-Host ''
if (($new + $upd) -eq 0) {
  Write-Host 'You already have the latest version. Nothing was changed.' -ForegroundColor Green
} else {
  Write-Host "Updated: $new new file(s), $upd changed file(s)." -ForegroundColor Green
}
if ($failed.Count -gt 0) {
  Write-Host ''
  Write-Host 'These files could not be updated (probably open in another program):' -ForegroundColor Yellow
  $failed | Select-Object -First 5 | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
  Write-Host 'Close the launcher and run pull.bat again.' -ForegroundColor Yellow
}
Write-Host ''
Write-Host 'Your build (harness\setup), settings (config.json) and logs (harness\data)' -ForegroundColor DarkGray
Write-Host 'were NOT touched - that is by design.' -ForegroundColor DarkGray

# remember when we last updated (useful for AI reports)
try {
  $markerDir = Join-Path $root 'harness\data'
  New-Item -ItemType Directory -Force -Path $markerDir | Out-Null
  "pull.bat ran $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - new:$new updated:$upd failed:$($failed.Count)" |
    Add-Content (Join-Path $markerDir 'last-update.txt')
} catch { }

Write-Host ''
Write-Host 'If the launcher was running: close it and double-click START.cmd again.' -ForegroundColor Cyan
exit 0
