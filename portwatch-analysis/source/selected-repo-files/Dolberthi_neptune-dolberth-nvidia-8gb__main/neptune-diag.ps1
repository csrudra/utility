# Neptune HyperEngine by Dolberth — Ferramenta de Diagnostico e Telemetria em Tempo Real / Pos-Sessao
# Uso:
#   .\neptune-diag.ps1                       (analisa %TEMP%\neptune-ultimo.log.err)
#   .\neptune-diag.ps1 -Log 'caminho\log'    (analisa qualquer log)
#   .\neptune-diag.ps1 -AoVivo               (atualiza a cada 3 segundos enquanto voce joga)
param(
    [string]$Log = (Join-Path $env:TEMP 'neptune-ultimo.log.err'),
    [switch]$AoVivo
)

function Show-Report([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "Log nao encontrado: $Path" -ForegroundColor Red
        return
    }
    $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
    if (-not $raw) { Write-Host "Log vazio."; return }
    $esc = [char]27
    $clean = [regex]::Replace($raw, "$esc\[[0-9;]*m", '')
    $lines = $clean -split "`r?`n"

    $world = @()
    foreach ($l in $lines) {
        if ($l -match '([0-9.]+) fps, ([0-9.]+) ms/frame \(([0-9.]+) preparing: copies ([0-9.]+) ms ([0-9.]+) MB, textures ([0-9.]+) ms ([0-9.]+) MB; ([0-9.]+) on the GPU; ([0-9.]+) copying back ([0-9.]+) MB\), ([0-9]+) draws/frame') {
            $draws = [int]$Matches[11]
            if ($draws -ge 300) {
                $world += [pscustomobject]@{
                    Fps = [double]$Matches[1]; FrameMs = [double]$Matches[2]
                    PrepMs = [double]$Matches[3]; CopyMs = [double]$Matches[4]; CopyMB = [double]$Matches[5]
                    TexMs = [double]$Matches[6]; TexMB = [double]$Matches[7]
                    GpuMs = [double]$Matches[8]; BackMs = [double]$Matches[9]; BackMB = [double]$Matches[10]
                    Draws = $draws
                }
            }
        }
    }

    $lastRam   = ($lines | Where-Object { $_ -match 'ram line:' } | Select-Object -Last 1)
    $lastTurbo = ($lines | Where-Object { $_ -match 'Neptune HyperEngine:' } | Select-Object -Last 1)
    $lastSmart = ($lines | Where-Object { $_ -match 'smart copy-back' } | Select-Object -Last 1)
    $lastThin  = ($lines | Where-Object { $_ -match 'list calls translated' } | Select-Object -Last 1)
    $lastHeap  = ($lines | Where-Object { $_ -match 'the pass over the heap per frame' } | Select-Object -Last 1)
    $ooms      = ($lines | Where-Object { $_ -match '0x8007000E|out of memory|device removed|0x887A0006' }).Count
    $shaders   = ($lines | Where-Object { $_ -match 'shader translated' }).Count

    Clear-Host
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "   NEPTUNE HYPERENGINE - DIAGNOSTICO DE FPS, SHADERS & TEXTURAS   " -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "Log: $Path ($($lines.Count) linhas) | Shaders traduzidos: $shaders | Erros criticos/OOM: $ooms"

    if ($world.Count -eq 0) {
        Write-Host "`nAinda carregando (nenhum frame de mundo >300 draws registrado ainda)." -ForegroundColor Yellow
        $lastFps = ($lines | Where-Object { $_ -match 'host: [0-9.]+ fps,' } | Select-Object -Last 1)
        if ($lastFps) { Write-Host ("Ultimo frame: " + ($lastFps -replace '.*host: ', '')) }
    } else {
        $avgFps  = ($world.Fps | Measure-Object -Average).Average
        $maxFps  = ($world.Fps | Measure-Object -Maximum).Maximum
        $minFps  = ($world.Fps | Measure-Object -Minimum).Minimum
        $recent  = $world | Select-Object -Last ([Math]::Min(10, $world.Count))
        $rMs     = ($recent.FrameMs | Measure-Object -Average).Average
        $rPrep   = ($recent.PrepMs | Measure-Object -Average).Average
        $rCopy   = ($recent.CopyMs | Measure-Object -Average).Average
        $rCopyMB = ($recent.CopyMB | Measure-Object -Average).Average
        $rTex    = ($recent.TexMs | Measure-Object -Average).Average
        $rTexMB  = ($recent.TexMB | Measure-Object -Average).Average
        $rGpu    = ($recent.GpuMs | Measure-Object -Average).Average
        $rBack   = ($recent.BackMs | Measure-Object -Average).Average
        $rBackMB = ($recent.BackMB | Measure-Object -Average).Average
        $rDraws  = ($recent.Draws | Measure-Object -Average).Average

        Write-Host ("`nFPS NO MUNDO ({0} amostras):  Media {1:N1} FPS  |  Pico {2:N1} FPS  |  Min {3:N1} FPS" -f $world.Count, $avgFps, $maxFps, $minFps) -ForegroundColor Green
        Write-Host ("Frame medio recente: {0:N1} ms  ({1:N0} draws/frame)" -f $rMs, $rDraws)
        Write-Host ("  - Preparing (CPU):  {0,6:N1} ms  (copies {1:N1} ms / {2:N1} MB | textures {3:N1} ms / {4:N1} MB)" -f $rPrep, $rCopy, $rCopyMB, $rTex, $rTexMB)
        Write-Host ("  - Espera GPU:       {0,6:N1} ms" -f $rGpu)
        Write-Host ("  - Copy-back:        {0,6:N1} ms  ({1:N1} MB)" -f $rBack, $rBackMB)

        $other = [Math]::Max(0, $rMs - $rPrep - $rGpu - $rBack)
        Write-Host ("  - Jogo/Gravacao:    {0,6:N1} ms" -f $other)

        $maxPart = @(@('Preparing CPU', $rPrep), @('Espera GPU', $rGpu), @('Copy-back', $rBack), @('Jogo/Gravacao', $other)) | Sort-Object { $_[1] } -Descending | Select-Object -First 1
        Write-Host ("`n>> GARGALO DOMINANTE: {0} ({1:N1} ms / {2:N0}% do frame)" -f $maxPart[0], $maxPart[1], (100.0 * $maxPart[1] / [Math]::Max(1, $rMs))) -ForegroundColor Yellow
    }

    Write-Host "`n--- Motores Neptune HyperEngine ---" -ForegroundColor Cyan
    if ($lastTurbo) { Write-Host ("  " + ($lastTurbo -replace '.*turbo: ', '')) }
    if ($lastSmart) { Write-Host ("  " + ($lastSmart -replace '.*smart_back: ', '')) }
    if ($lastThin)  { Write-Host ("  " + ($lastThin  -replace '.*thin: ', '')) }
    if ($lastHeap)  { Write-Host ("  " + ($lastHeap  -replace '.*host: ', '').Substring(0, [Math]::Min(160, ($lastHeap -replace '.*host: ', '').Length))) }

    if ($lastRam) {
        Write-Host "`n--- Memoria (RAM & VRAM) ---" -ForegroundColor Cyan
        if ($lastRam -match 'process working set ([0-9]+) MB, private ([0-9]+) MB; PC free ([0-9]+) MB') {
            Write-Host ("  RAM: processo {0} MB (privado {1} MB) | Livre no PC: {2} MB" -f $Matches[1], $Matches[2], $Matches[3])
        }
        if ($lastRam -match 'card \(VRAM\) ([0-9]+) MB in use of ([0-9]+) MB budget, shared ([0-9]+) MB in use') {
            Write-Host ("  VRAM: {0} / {1} MB | Compartilhada (RAM): {2} MB" -f $Matches[1], $Matches[2], $Matches[3])
        }
        if ($lastRam -match 'evicted under pressure ([0-9]+) ([0-9]+) MB') {
            Write-Host ("  Evictions por pressao VRAM: {0} texturas ({1} MB)" -f $Matches[1], $Matches[2])
        }
    }
    Write-Host "==================================================================" -ForegroundColor Cyan
}

if ($AoVivo) {
    while ($true) {
        Show-Report $Log
        Write-Host "(Atualizando a cada 3s - Ctrl+C para sair)" -ForegroundColor DarkGray
        Start-Sleep -Seconds 3
    }
} else {
    Show-Report $Log
}
