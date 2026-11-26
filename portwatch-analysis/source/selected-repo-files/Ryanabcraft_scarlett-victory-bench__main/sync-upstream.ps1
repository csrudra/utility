# Puxa o DexNom (origin) para este fork e sobe.
#
# Nada aqui acontece sozinho: o GitHub nao faz merge de fork em fork, e o
# upstream nao abre PR para ca. Rodar isto e o "atualizar".
#
#   .\sync-upstream.ps1            # traz, compila e sobe se compilar
#   .\sync-upstream.ps1 -NoPush    # so traz e compila
#
# Conflito: para no primeiro arquivo, deixa o merge aberto para resolver a mao.
param([switch]$NoPush)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

Get-Process victory, game_scarlett_master -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

git fetch origin
$behind = [int](git rev-list --count HEAD..origin/main)
if ($behind -eq 0) {
    "upstream: nada novo (HEAD = origin/main)"
    exit 0
}
"upstream: $behind commit(s) novos"

git merge origin/main --no-edit
if ($LASTEXITCODE -ne 0) {
    "merge parado. Resolva os conflitos e rode de novo:"
    git diff --name-only --diff-filter=U
    exit 1
}

cargo build --release -p victory --bins
if ($LASTEXITCODE -ne 0) {
    "build falhou. Nada foi enviado."
    exit 1
}

if (-not $NoPush) {
    git push fork main
    "enviado: $(git log --oneline -1)"
}
