param([switch]$ExperimentalBakeBudget)

$ErrorActionPreference = 'Stop'

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$exe = Join-Path $root 'victory-8gb\target\release\victory.exe'
$gameDir = Join-Path $root 'GTA6.Xbox.v1.0.2.1-CYBERLEEK'
$game = Join-Path $gameDir 'game_scarlett_master.exe'
$env:VICTORY_CONFIG = Join-Path $root 'auditoria\victory-8gb-local.toml'
$env:VICTORY_DXIL = 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\dxil.dll'
$env:VICTORY_DISPLAY_MODE = '1280x720'
$env:VICTORY_LOG = 'info'
$env:VICTORY_PIPELINE_SMALL_FIRST = '1'
# O checkpoint jogavel nao tinha este override. Teste somente com a opcao explicita.
if ($ExperimentalBakeBudget) {
    $env:VICTORY_BAKE_TEXTURES_MS = '0'
} else {
    [Environment]::SetEnvironmentVariable('VICTORY_BAKE_TEXTURES_MS', $null, 'Process')
}
$env:VICTORY_TEXTURE_DROP_MIPS = '1'
$env:VICTORY_SMALL_TEXTURE_KB = '0'
$env:VICTORY_QUEUE2 = '1'
$env:VICTORY_INDIRECT_WINDOW = '1'
$env:VICTORY_ASYNC_SUBMIT = '1'
$env:VICTORY_ASYNC_SUBMIT_SAFE = '1'
$env:VICTORY_CARD_HASH_WIDE = '1'
$env:VICTORY_LATE_WAIT = '2'
$env:VICTORY_BACK_SETTLE = '0'

if (!(Test-Path -LiteralPath $exe -PathType Leaf) -or !(Test-Path -LiteralPath $game -PathType Leaf)) {
    throw 'Executavel do VIctory ou do jogo nao encontrado.'
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class VictoryWindow
{
    [StructLayout(LayoutKind.Sequential)]
    private struct Rect { public int Left, Top, Right, Bottom; }

    [DllImport("user32.dll")]
    private static extern IntPtr SetThreadDpiAwarenessContext(IntPtr value);

    [DllImport("user32.dll")]
    private static extern bool GetWindowRect(IntPtr window, out Rect rect);

    [DllImport("user32.dll")]
    private static extern bool GetClientRect(IntPtr window, out Rect rect);

    [DllImport("user32.dll")]
    private static extern bool SetWindowPos(IntPtr window, IntPtr after, int x, int y,
        int width, int height, uint flags);

    public static bool SetClientSize(IntPtr window, int width, int height)
    {
        var previous = SetThreadDpiAwarenessContext(new IntPtr(-4));
        try {
            Rect outer, client;
            if (!GetWindowRect(window, out outer) || !GetClientRect(window, out client))
                return false;
            var borderWidth = (outer.Right - outer.Left) - (client.Right - client.Left);
            var borderHeight = (outer.Bottom - outer.Top) - (client.Bottom - client.Top);
            // Keep the position and Z-order, and verify the drawable area.
            if (!SetWindowPos(window, IntPtr.Zero, 0, 0, width + borderWidth,
                height + borderHeight, 0x0002 | 0x0004 | 0x0010))
                return false;
            return GetClientRect(window, out client)
                && client.Right - client.Left == width
                && client.Bottom - client.Top == height;
        } finally {
            if (previous != IntPtr.Zero) SetThreadDpiAwarenessContext(previous);
        }
    }
}
"@

$runId = Get-Date -Format 'yyyyMMdd-HHmmss'
$logs = Join-Path $root "victory-diagnostics\launch-8gb-720p-$runId"
New-Item -ItemType Directory -Path $logs | Out-Null
$process = Start-Process -FilePath $exe -WorkingDirectory $gameDir -PassThru -WindowStyle Hidden `
    -ArgumentList @('run', ('"' + $game + '"'), '--execute', '--console', 'series-s', '--unimplemented', 'trap') `
    -RedirectStandardOutput (Join-Path $logs 'stdout.txt') `
    -RedirectStandardError (Join-Path $logs 'stderr.txt')

$deadline = [DateTime]::UtcNow.AddSeconds(60)
do {
    $process.Refresh()
    if ($process.HasExited) {
        throw "O VIctory encerrou antes de abrir a janela. Logs em $logs"
    }
    if ($process.MainWindowHandle -ne [IntPtr]::Zero -and
        [VictoryWindow]::SetClientSize($process.MainWindowHandle, 1280, 720)) {
        "Area do jogo confirmada em 1280x720. Logs em $logs"
        exit 0
    }
    Start-Sleep -Milliseconds 250
} while ([DateTime]::UtcNow -lt $deadline)
throw "Nao foi possivel confirmar uma janela de 1280x720. Logs em $logs"
