# Checkpoint jogavel local — 25/11/2026

Base: CuteBooty/victory-8gb, commit b472495fbe9516469b0694f51b849133d761ce4e.
O usuario confirmou que conseguiu jogar na sessao local 22:02:11.
Em uma sessao anterior, o agente confirmou visualmente personagens e cenario 3D.
Isso nao comprova estabilidade: houve crash anterior, FPS baixo e defeitos de
iluminacao, materiais e geometria. Nenhum asset, dump ou log do titulo integra
este commit.

## Perfil preservado

O launcher versionado e `scripts/Start-Local.ps1`. A raiz local esperada e
J:\GTA6, com este repositorio em victory-8gb. Ele usa Series S, area cliente
1280x720, PIPELINE_SMALL_FIRST=1 e os demais parametros que produziram o
estado observado. O arquivo scripts/victory-8gb-local.toml preserva os caminhos
locais, sem credenciais. O manifesto local-playable-checkpoint.json registra
identidade do build e hashes dos arquivos.

O parametro VICTORY_BAKE_TEXTURES_MS=0 foi preparado depois do inicio da
sessao jogavel. Nao havia validacao desse ajuste no momento do checkpoint.
Por isso, o launcher padrao limpa esse override e conserva o comportamento
original do fork. `-ExperimentalBakeBudget` permite testar o ajuste isoladamente.

## Reconstruir e abrir

1. Compilar neste repositorio: `cargo build --release --locked --offline -p victory`.
   Se o cache Cargo nao estiver disponivel, resolver as dependencias fixadas
   antes de tentar a compilacao offline. Toolchain fixada em rust-toolchain.toml.
2. Manter o pacote proprio no caminho configurado, fora do repositorio.
3. Se necessario, restaurar scripts/victory-8gb-local.toml para
   J:\GTA6\auditoria\victory-8gb-local.toml.
4. Abrir J:\GTA6\Iniciar-VIctory.cmd ou executar
   `powershell.exe -NoProfile -File .\scripts\Start-Local.ps1`.

O iniciador externo chama o script versionado. A opcao experimental nao e
ativada pelo iniciador padrao. Alterar esses scripts nao muda um processo
ja aberto.

## Dados preservados fora do Git

- Saves e configuracoes do titulo: J:\GTA6\victory-data.
- Cache de shaders e pipelines: J:\GTA6\victory-8gb-cache. Um checkout sem esse
  cache pode demorar muito mais para apresentar o cenario.
- Logs locais: J:\GTA6\victory-diagnostics.
- Binario construido e iniciadores externos copiados para
  C:\Users\giuse\AppData\Local\VItoriaBr\checkpoints\victory-8gb-jogavel-20261125.

O commit nao e um backup de saves/cache nem captura o ponto atual da missao.
Esses arquivos continuam preservados localmente. Nenhum processo do jogo
foi encerrado para criar o checkpoint. Nao houve push.
