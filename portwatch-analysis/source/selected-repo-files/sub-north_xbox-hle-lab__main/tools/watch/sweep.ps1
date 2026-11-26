# Fast upstream source check for the title watch list.
# Reads tools\watch\sources.json; writes notes\watch\state.json, latest.json, deltas.md.
# Usage: powershell -File sweep.ps1

$ErrorActionPreference = "Continue"
$here = $PSScriptRoot
$root = Split-Path -Parent (Split-Path -Parent $here)
$watch = Join-Path $root "notes\watch"
New-Item -ItemType Directory -Force -Path $watch | Out-Null

$statePath = Join-Path $watch "state.json"
$latestPath = Join-Path $watch "latest.json"
$deltaPath = Join-Path $watch "deltas.md"

$sourcesPath = Join-Path $here "sources.json"
$repos = @()
if (Test-Path $sourcesPath) {
    $repos = Get-Content $sourcesPath -Raw | ConvertFrom-Json
} else {
    Write-Output "missing sources.json next to sweep.ps1"
    exit 1
}

function Get-Subjects([string]$name, [string]$branch) {
    try {
        $url = "https://github.com/$name/commits/$branch.atom"
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20
        $out = @()
        foreach ($m in [regex]::Matches($r.Content, '(?s)<entry>.*?<title[^>]*>(.*?)</title>')) {
            $t = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value).Trim()
            if ($t) { $out += $t }
            if ($out.Count -ge 3) { break }
        }
        return ,$out
    } catch { return ,@() }
}

$old = @{}
if (Test-Path $statePath) {
    try {
        $json = Get-Content $statePath -Raw | ConvertFrom-Json
        foreach ($p in $json.PSObject.Properties) { $old[$p.Name] = $p.Value }
    } catch { }
}

$new = @{}
$records = @()
$now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")

foreach ($repo in $repos) {
    $name = $repo.name
    $lines = & git ls-remote --heads "https://github.com/$name.git" 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $lines) {
        $records += [ordered]@{ repo = $name; branch = ""; status = "unreachable"; subjects = @() }
        continue
    }
    $heads = @{}
    foreach ($line in $lines) {
        if ($line -match '^([0-9a-f]{40})\s+refs/heads/(.+)$') { $heads[$Matches[2]] = $Matches[1] }
    }
    $new[$name] = $heads
    $prev = $old[$name]
    $keys = @($heads.Keys)
    if ($prev) { $keys += $prev.PSObject.Properties.Name }
    foreach ($b in ($keys | Sort-Object -Unique)) {
        if ($repo.branches -and ($repo.branches -notcontains $b)) { continue }
        $h = $heads[$b]
        $p = $null
        if ($prev -and $prev.PSObject.Properties.Name -contains $b) { $p = $prev.$b }
        if ($h -and $p -and $h -ne $p) {
            $subs = Get-Subjects $name $b
            $records += [ordered]@{ repo = $name; branch = $b; status = "changed"; from = $p.Substring(0,8); to = $h.Substring(0,8); subjects = $subs }
        } elseif ($h -and -not $p) {
            $subs = Get-Subjects $name $b
            $records += [ordered]@{ repo = $name; branch = $b; status = "new"; to = $h.Substring(0,8); subjects = $subs }
        } elseif (-not $h -and $p) {
            $records += [ordered]@{ repo = $name; branch = $b; status = "gone"; from = $p.Substring(0,8); subjects = @() }
        }
    }
}

$new | ConvertTo-Json -Depth 4 | Set-Content $statePath -Encoding UTF8
[ordered]@{ checked_utc = $now; changes = $records } | ConvertTo-Json -Depth 6 | Set-Content $latestPath -Encoding UTF8

$linesOut = @()
if ($records.Count -eq 0) {
    $linesOut += "$now  no head changes"
} else {
    $linesOut += $now
    foreach ($r in $records) {
        if ($r.status -eq "changed") { $line = "- $($r.repo) [$($r.branch)]: $($r.from) -> $($r.to)" }
        elseif ($r.status -eq "new") { $line = "- $($r.repo) [$($r.branch)]: new $($r.to)" }
        elseif ($r.status -eq "gone") { $line = "- $($r.repo) [$($r.branch)]: branch gone" }
        else { $line = "- $($r.repo): UNREACHABLE" }
        $linesOut += $line
        foreach ($s in $r.subjects) { $linesOut += "    - $s" }
    }
}
Add-Content $deltaPath $linesOut -Encoding UTF8
Write-Output ($linesOut -join "`n")
