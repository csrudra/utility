# Residência de memória para placas de 8 GB — projeto

Objetivo: rodar `game_scarlett_master.exe` (Series S) no XCL num PC com **RTX 4060 8 GB + 16 GB de RAM**,
juntando o que cada projeto faz de melhor. Escrito em 25/11/2026 a partir de 25 testes medidos e da
leitura do código de Eden (sucessor do yuzu), AnyPS5, Xenia, VKD3D-Proton e SCARAB.

## 1. O problema, medido

O XCL deixa tudo o que a placa pode ler residente na placa. O ztrx/VIctory copia por quadro só o que
é usado (cabe, mas a ~3,5 s por quadro). O XCL é rápido (menus e carregamento a 30 fps), mas não cabe.

Limites reais deste PC:

| Recurso | Limite real | Observação |
|---|---|---|
| Memória de vídeo para o jogo | **~5,9 GB** | o driver recusa a partir daí (o Windows informa 7,2 GB de orçamento; o resto é do Windows e outros programas) |
| RAM travada pela placa | ~6 GB | memória lida pela placa via PCIe não pode ir para o arquivo de paginação |
| RAM livre com o jogo aberto | ~10 GB | o app do Claude e o Windows ocupam ~5 GB |

O que ocupa a placa (teste 25, com mapeamento preguiçoso e janela coerente de 512 MB):

| Fase | Cópia da memória do jogo | Alvos de renderização | Texturas | Total pedido |
|---|---|---|---|---|
| Tela de carregamento (~60 s) | 1,9 GB | 2,1 GB (1.175 alvos) | ~0,5 GB | ~5,8 GB — cabe |
| Cena 3D (~180 s) | 3,0 GB | 2,2 GB | 27 mil pequenas + 1.031 grandes (8,2 GB nas cadeias completas) | > 10 GB — não cabe |

Os maiores alvos de renderização são de 2048×2048 com 12 mips (8 deles, 171 MB), um de 3840×2160 (63 MB) e
dezenas de 1280×720 — tamanhos de um jogo de Series S, não inflados pelo XCL.

## 2. O que já está feito (branch `ztrx/vram-fallback`)

| Peça | Efeito medido | Liga com |
|---|---|---|
| Compositor de planos (Series S) | menus e artes aparecem (antes: tela preta) | padrão |
| Mapeamento preguiçoso da cópia | cópia na placa 4,4 → 1,4–2,4 GB | `XCL_SPARSE_LAZY=1` |
| Janela coerente pequena | RAM travada 5,4 → 1,1 GB | `XCL_COHERENT_MB=512` |
| Teto + muro da placa | sem tela azul (antes: 0x13A ao lotar a VRAM) | padrão |
| Texturas grandes em meia resolução | 1.031 texturas a 1/4 da memória | padrão (`XCL_TEXTURE_HALF_MB`) |
| Corte do mip maior (gerenciador v1) | pouco efeito: corta por idade, sem saber o que está em uso | padrão |

Descartado: `XCL_COHERENT_HEAPS=sparse` (o jogo se fecha aos 2 s numa checagem de endereço).

## 3. O que os outros fazem

**Eden / yuzu (Switch).** Cache de texturas e de buffers com fila LRU: todo uso de uma textura ou buffer a
"toca" com o número do quadro. A cada quadro, se a memória de vídeo usada passa de um limite derivado do
tamanho da placa, descarta o que não foi tocado há 50 quadros (25 em alta pressão, 10 em pressão crítica),
poucos itens por quadro. Uma textura que a placa escreveu é **copiada de volta para a memória do jogo antes
de ser descartada** — nada se perde, e por isso alvos de renderização também podem sair.

**AnyPS5 (PS5, `ResidentMirror`).** Espelho da memória do jogo num buffer esparso de blocos de 64 KB; só os
blocos não-zero ganham memória; os demais apontam para **um único bloco de zeros compartilhado**; há um
orçamento para o espelho; uma escrita da placa num bloco sem memória própria é detectada e tratada como erro.
É a mesma ideia do nosso mapeamento preguiçoso, com o bloco de zeros no lugar do "nada".

**Xenia (Xbox 360).** Antes de cada desenho, pede a faixa de memória que o desenho usa (`RequestRange`):
mapeia só ela na placa e envia só as páginas alteradas (vigiadas por proteção de página). Não descarta
(o 360 tem 512 MB), mas é o modelo de "residência por uso".

**VKD3D-Proton / SCARAB.** Deixam a residência para o driver e o Windows; não resolvem o caso de um jogo que
pede mais que a placa tem. SCARAB serve como catálogo do runtime gráfico do console (útil para lacunas de API).

## 4. O que falta no XCL: saber o que está em uso

O XCL não sabe quais texturas um quadro usa: os shaders traduzidos leem os descritores de um heap global
(bindless). Sem isso, qualquer descarte é um chute (foi o erro do gerenciador v1).

**Proposta: retorno de uso feito pela própria placa.** O tradutor de shaders já sabe onde cada leitura de
textura pega o seu descritor (palavra 0 do T# = índice do SRV no heap global). Em cada leitura de textura, o
shader traduzido marca um bit num buffer de retorno (`InterlockedOr(feedback[i >> 5], 1 << (i & 31))`). A cada
quadro o XCL lê esse buffer (assíncrono, com um quadro de atraso) e "toca" na fila LRU as texturas cujos
índices foram marcados. Custo: uma operação atômica por leitura de textura, em memória pequena (1 bit por
descritor: 128 KB para 1 milhão de descritores).

Alternativa mais barata, menos exata: no momento do desenho, resolver as tabelas de descritores com
deslocamentos fixos (o caso comum) a partir dos argumentos de raiz — o que Xenia e yuzu fazem com os seus
"binds". Fica como plano B se o retorno pela placa custar caro.

## 5. Plano, em fases

Cada fase é um lote com teste medido. Ordem pela economia esperada e pelo risco.

### Fase 1 — Cache de texturas com descarte por uso (maior ganho na cena 3D)
1. Buffer de retorno de uso no tradutor de shaders (seção 4) + leitura por quadro.
2. Fila LRU por textura posicionada (`vram::Target`): tocada pelo retorno de uso.
3. Coletor por quadro no estilo Eden, com o **muro** como orçamento: acima de muro − 1 GB descarta o que
   não foi usado há 50 quadros; acima de muro − 512 MB, há 25; acima do muro, há 10.
4. Descartar = desmapear **todas** as páginas da textura (não só o mip maior) e marcá-la "fora".
5. Volta: textura "fora" tocada pelo retorno → mapear de novo e reenviar inteira a partir da memória do jogo
   (que continua na RAM). No quadro de volta ela aparece em branco/zero — o mesmo "pop-in" de um jogo de PC
   com streaming.
6. Substitui o corte por idade do gerenciador v1 e torna a meia resolução opcional.

Economia esperada: tudo o que a cena 3D carregou e não está desenhando no quadro — provavelmente a maior
parte dos 27 mil + 1.031 texturas.

### Fase 2 — Bloco de zeros compartilhado e detecção de escrita da placa (segurança do mapeamento preguiçoso)
1. Blocos preguiçosos apontam para um bloco de zeros compartilhado (AnyPS5) em vez de nada.
2. Detectar escrita da placa em bloco preguiçoso (comparar o bloco de zeros após cada submissão): se
   acontecer, dar memória própria àquele bloco a partir daí e registrar no log.
3. Ligar `XCL_SPARSE_LAZY` por padrão quando o teste passar sem detecções inesperadas.

### Fase 3 — Alvos de renderização ociosos fora da placa (Eden)
1. Alvos não usados há muitos quadros (sombras de cenas passadas, telas de menu) são copiados para a RAM e
   desmapeados; voltam (cópia para a placa) quando o jogo os usa de novo.
2. Precisa do retorno de uso também para render targets e UAVs (marcar no bind do alvo, que o XCL já vê).

### Fase 4 — Usar o processador inteiro
1. Reenvio e destile de texturas em várias threads (o XCL já tem trabalhadores; ampliar para o volume da
   Fase 1) e cópias da memória do jogo em várias threads (ideia do fork Belobug).
2. Medir núcleos em uso: hoje 1,2–1,5 de 16 threads.

## 6. Riscos

- **Custo do retorno de uso**: uma atômica por leitura de textura pode pesar em shaders com muitas leituras.
  Medir; se pesar, marcar só a primeira leitura por descritor em cada onda, ou usar o plano B.
- **Pop-in**: texturas que voltam aparecem vazias por um quadro. Aceitável; reduzir com folga maior no
  orçamento.
- **Compatibilidade**: mudanças no tradutor invalidam o cache de shaders (recompilação no primeiro uso).
- **Escrita da placa em memória preguiçosa** (Fase 2) — hoje é um experimento; pode causar falhas visuais
  ainda não vistas.

## 7. Como medir cada fase

Mesmo roteiro dos testes 19–25: Series S, janela 854×480 no canto, A a cada 6 s, capturas a cada 300
quadros, proteção de RAM. Indicadores: memória de vídeo (local/não-local), páginas de textura, cópia na
placa, RAM livre, fps, até onde o jogo chega, e as capturas.
