# Runs the game and presses ENTER once the title's window is up, so the
# world loads without anyone at the keyboard.
param(
    [string] $Log = "logs\auto-$(Get-Date -Format HHmmss)",
    [int] $Press = 1,
    [int] $WaitSeconds = 240
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

$env:VICTORY_CONFIG = "D:\Jogos\GTAVI\DexNom\victory.toml"
$exe = "D:\Jogos\GTAVI\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe"

$p = Start-Process -FilePath "D:\Jogos\GTAVI\DexNom\target\release\victory.exe" `
    -ArgumentList 'run', $exe, '--execute' `
    -RedirectStandardOutput "$Log.log" -RedirectStandardError "$Log.err" -PassThru
"pid: $($p.Id)  log: $Log"

$pressed = 0
$deadline = (Get-Date).AddSeconds($WaitSeconds)
while ((Get-Date) -lt $deadline -and $pressed -lt $Press) {
    Start-Sleep -Seconds 6
    if ($p.HasExited) { "exited early: $($p.ExitCode)"; break }
    $win = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
    if (-not $win -or $win.MainWindowHandle -eq 0) { continue }
    # Only press once the title's own window is the one in front.
    try {
        [Microsoft.VisualBasic.Interaction]::AppActivate($p.Id) | Out-Null
        Start-Sleep -Milliseconds 700
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        $pressed++
        "pressed ENTER at $((Get-Date).ToString('HH:mm:ss'))"
    } catch {
        "could not focus: $_"
    }
}
"pressed $pressed time(s)"
