# PERFORMANCE — GTA VI Xbox no Windows via VIctory (DexNom)

Medido nesta máquina: **Intel Core i3-10105 (4 núcleos / 8 threads), 32 GB DDR4,
GeForce RTX 3050 8 GB, 2× 1920×1080, Windows 11**. Jogo:
`GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe` (TitleID `7952987A`).

Todos os números vêm da linha de frame do próprio runtime
(`victory_gpu::host`), que separa o tempo do frame em preparação, espera da GPU
e cópia de volta. Nenhum número aqui é estimado.

## Linha de base

Primeira medida confiável, build do DexNom em `921d8d3`, sem
`--features diagnostics`, dentro do mundo (interior aceso):

| Medida | Valor |
|---|---|
| fps | 1,3–1,6 |
| ms/frame | 600–890 (picos de 5,4–6,9 s durante streaming) |
| draws/frame | 6 886–8 074 |
| RAM do processo | ~16 GB |
| CPU | 70–97 % |
| GPU (medidor do runtime) | 18–26 % busy |
| crashes | 0 |

A GPU ficar a 20 % com a CPU a 90 % já dizia onde estava o gargalo: **a thread
de submissão**, não a placa.

## Onde o frame ia (antes)

`copying back` 345–500 ms de um frame de ~665 ms. O log detalhado
(`host copies in the card's memory`, `shader writes looked for on the CPU`)
mostrou o seguinte:

| Etapa | Custo por frame | Tráfego |
|---|---|---|
| espera dos fetches da GPU (5 por frame) | 150–197 ms | 1,9 MB |
| comparação CPU do que os shaders escreveram | 267–309 ms | 712 MB |
| snapshots dos ranges declarados | 130–169 ms | 690 MB |
| cópias título → cópia do host | 155–207 ms | 172–211 MB |
| trabalho real da GPU | 94–200 ms | — |

Dois fatos explicam tudo:

1. **cinco esperas por frame para mover 1,9 MB.** Cada fetch era um
   `ExecuteCommandLists` + `Signal` + `WaitForSingleObject` que drenava a fila
   inteira antes de copiar 12 KB por range.
2. **1,4 GB de tráfego de memória por frame** para descobrir 1,9 MB de bytes
   alterados. O snapshot copia o range declarado inteiro (690 MB), e a
   comparação lê os dois lados (712 MB × 2). Num i3 com 4 núcleos isso é o
   frame inteiro.

## Alterações feitas

### 1. O fetch da GPU não espera mais no meio do frame

`crates/victory-gpu/src/host.rs`: `relay_card_back` emitia o fetch e esperava
por ele na hora. Agora ele emite, guarda os pieces em `RelayFetch::pending`, e
`relay_fetch_merge` só espera **depois** do merge na CPU das outras cópias — a
GPU executa o fetch enquanto a CPU trabalha.

| | antes | depois |
|---|---|---|
| fetch por frame | 150–197 ms | **1,5–3,5 ms** |

### 2. Mais threads na comparação e no snapshot

`crates/victory-gpu/src/shadow.rs`: o pool de `wide()` era
`available_parallelism()/4` (2 threads num i3 de 8 threads lógicos). Passou a
`/2` (4 threads), com teto 8.

### 3. Instrumentação permanente do "copying back"

`BACK_PARTS` em `host.rs` separa o tempo de cópia de volta em merge do relé,
fetch do relé, card fetch/merge do settle e do submit, e snapshots. É o que
torna cada otimização seguinte mensurável.

### 4. `VICTORY_AUTO_ENTER` (automação de teste)

`crates/victory-hle/src/modules/gameinput.rs`: `VICTORY_AUTO_ENTER=<segundos>`
aperta A (Enter no pad substituto) a cada N segundos por cinco minutos, e
`VICTORY_KEYS` deixou de exigir `--features diagnostics`. Serve para rodar
testes sem ninguém no teclado — a tela de seleção de conta do título só aceita
botão de controle, e com um controle real conectado o teclado não a alcança.

## Resultado medido

Build atual, dentro do mundo, cena de ~5 040 draws, **sem nenhuma variável de
display** (o default do código reporta o monitor):

| | antes | agora |
|---|---|---|
| fps | 1,3–1,6 | **1,7–2,0** |
| ms/frame | 600–890 | **506–595** |
| CPU | 70–97 % | **46–53 %** |
| GPU (medidor do runtime) | 18–26 % | 31–47 % |
| draws/frame | 6 886–8 074 | ~5 040 |
| imagem | material em fallback (camisa chapada, chão preto) | **cena iluminada e texturizada** |
| crashes | 0 | 0 |

Onde o frame vai agora:

| Etapa | Custo | Antes |
|---|---|---|
| comparação do que os shaders escreveram (relé) | 179–184 ms | 267–309 ms |
| snapshots dos ranges declarados | 98–110 ms | 130–169 ms |
| cópias título → host | 64–182 ms | 155–207 ms |
| trabalho/espera da GPU | 160–280 ms | 94–200 ms |
| fetch da GPU | **1,4–5,2 ms** | 150–197 ms |

Dois terços do frame ainda são o caminho de cópia na CPU (relé + snapshots =
278–300 ms de ~550). A GPU não é mais o teto: ela fica a 31–47 %.

## Atualização do upstream (`921d8d3` → `2e01ab4`)

Três commits do DexNom entraram por merge, sem perder nada do que está aqui:

| Commit | O que traz |
|---|---|
| `b8ff22e` | sincroniza 15 arquivos do renderer privado: descriptor tables, draw, memória, `material_demand`, `shadow`, `texture`, emissão de shader |
| `4775e8a` | isola o teste de leitura de material do avanço concorrente de frame (só teste) |
| `2e01ab4` | texturas de teste em cache ficam dentro da memória reservada (só teste) |

O que interessa para o fps é o primeiro, e num ponto específico: o pool de
snapshots. Antes eram **8 buffers** reaproveitados; agora é um `SnapshotPool`
com orçamento de **512 MiB / 512 buffers**, escolhendo o menor backing que
serve. O comentário do upstream diz o motivo: *"limiting this pool to eight
buffers discarded already committed pages even when most of the byte budget was
free"*. Ou seja — o custo de snapshot que este fork mediu (94–119 ms) era em
parte alocação nova e page fault, não cópia.

### Medido com o merge, mesma build, mundo carregado

| | antes do merge | com o merge |
|---|---|---|
| fps | 1,8–2,1 | **1,5–2,0** |
| ms/frame (cena leve, ~1 000 draws) | 486–546 | **499–506** |
| ms/frame (cena pesada, ~5 000 draws) | — | 588–760 |
| draws/frame | 5 000–6 900 | 976–5 182 |
| cópias título → host | 99–142 ms | 64–182 ms |
| trabalho/espera da GPU | 136–224 ms | 122–410 ms |
| relay merge | 168–227 ms | 124–306 ms |
| snapshots | 94–119 ms | 99–134 ms |
| imagem | correta | correta |
| crashes | 0 | 0 |

**Veredito: o merge é neutro, não é regressão.** Na mesma cena (o interior do
começo, ~1 000 draws, cache quente) deu **499–506 ms** contra 486–546 da build
anterior — dentro da variação de cena. Os 588–760 ms da primeira medição eram
uma cena de **5 000 draws**, não o merge. O número anterior de "70–150 ms de
custo" estava errado: era comparação de cenas diferentes.

O pool novo de snapshots do upstream também não mudou nada aqui: 99–113 ms com
ele, 94–119 sem.

### Cache de shader: o merge invalida os 5 GB

O merge mexeu em `victory-shader/src/emit/lower.rs` e `typed_views.rs`, e isso
muda o hash de todo shader traduzido. Consequência medida: o primeiro run depois
do merge passou **~4 minutos a 10–12,5 s por frame** com
`dropped 764 without a host pipeline (961 being made)`, reescrevendo 72 885
arquivos de cache (5,2 GB). Depois assentou em 588–760 ms.

Para não pagar isso dentro do jogo, `warm-shaders.bat` roda
`victory-warm.exe`, que traduz e compila tudo para o cache antes:

```bat
target\release\victory-warm.exe "D:\...\game_scarlett_master.exe"
```

Regra prática: **mudou o emissor de shader (qualquer merge do upstream mexe),
rode o `warm-shaders.bat` antes de medir fps.** Medir com cache frio dá 12 s por
frame e não diz nada sobre o runtime.

## O jogo estava renderizando em 4K

O runtime informa ao título qual televisão está plugada. O default do
`display_size()` em `crates/victory-gpu/src/dxgi.rs` é **3840×2160** — com um
`shortcut:` do próprio autor dizendo que ainda não usa o tamanho do monitor do
PC. O log de toda run provava:

```
INFO victory_gpu::dxgi: display mode reported to the title width=3840 height=2160
```

Numa janela de 1920×1080. O jogo montava os alvos em 4K, desenhava **4× os
pixels** e o runtime encolhia para a janela. Consequência medida: alvos de 4K
comendo VRAM que faltava para as texturas (9 194 esperando) e GPU a 30–50 %.

`VICTORY_DISPLAY_MODE=1920x1080` diz a verdade ao título. Medido, mesma cena:

| | 4K reportado | 1080p reportado |
|---|---|---|
| imagem | camisa chapada, chão preto, carro flutuando, cubo cinza | pôr do sol, god rays, chão texturizado, plantas, gente no pátio, vidro com reflexo |
| GPU ocupada | 30–50 % | **21–27 %** |
| espera da GPU | 122–410 ms | **122–256 ms** |
| ms/frame | 588–760 | **573–650** |
| fps | 1,5–2,0 | 1,5–1,7 |
| texturas esperando | 9 194 | 17 051 → 8 996 caindo |

**O ganho maior não é fps, é imagem e teto.** O frame agora tem GPU a 21–27 % e
CPU a 47 %: o gargalo virou 100 % o caminho de cópia na CPU (`relay merge
230–312 ms + snapshots 126–140 ms`), não a placa. Antes a GPU mascarava isso.

Prova: print da cena em `logs/shot-1080p.png` (fora do repo, `/logs/` é ignorado).

## O que foi tentado e descartado (com o número)

| Tentativa | Resultado |
|---|---|
| `VICTORY_CARD_BUFFERS_MIN_MB=1` | no-op: o padrão já é 1 MiB |
| `VICTORY_CARD_REHASH_RUNS=1` + `VICTORY_JOIN_COPIES=1` | pior: 660–1 193 ms, mais tráfego |
| `VICTORY_CARD_BUFFERS=0` | quebra o boot: fica no menu, 30 fps, 13 draws |
| `VICTORY_INPLACE=2` + `VICTORY_CARD_BUFFERS=0` + `VICTORY_RELAY=0` | pior: 912–1 386 ms; o in-place é recusado nas cópias grandes (memória de view) |
| `VICTORY_RELAY=1` sozinho | pior: desliga o `relay_exact` |
| `VICTORY_CARD_BUFFERS_IN_RAM=1` (compare na GPU lendo a RAM) | pior: 710–748 ms, GPU 459–467 ms de espera; 700 MB por frame pela PCIe custa mais que a comparação na CPU. Fica no código, desligado |
| `VICTORY_FAST_COPY=1` (`memcpy` com SEH, `fastcopy.c`) | pior: cópias 127–205 ms contra 104–147; um range com uma página faltando falha inteiro e o retry de 64 KiB custa mais que a cópia do kernel. Fica no código, desligado |
| `VICTORY_COPY_PLAIN=1` (PR #32: `rep movsb` + handler de exceção) | **neutro**: 269–484 MB/s contra 247–462 MB/s do kernel, mesma cena, 4 500–6 500 chamadas de ~38 KB. O benchmark isolado explica: com destino residente o `memcpy` faz 3,9–5,8 GB/s contra 1,9–3,4 GB/s do `ReadProcessMemory`, mas no runtime o destino é frio e os dois empatam |
| `VICTORY_KEEP_SNAPSHOTS=1` (+`_MB=2048`) | **não dá para isolar**: `relay()` devolve `false` quando `keeps()` está ligado (`&& !keeps()`), então o teste virou "relé desligado + snapshot mantido". Ficou 553–727 ms com 1 851–3 774 draws, contra 563–612 ms com ~5 000 draws do relé ligado — inconclusivo e não habilitado |
| pool de `wide()`: 2 → 4 → 6 threads | melhora pequena e real: snapshots 130 → 94 ms |

## Onde os 652 ms estão (medido, não estimado)

Cena do mundo, ~5 000 draws, 1080p, RTX 3050 + i3-10105 (4 núcleos / 8 threads).
Cada linha sai de um contador do próprio runtime (`host.rs`, `shadow.rs`,
`plaincopy.rs`), não de inferência.

| Etapa | Medida | Onde roda |
|---|---|---|
| preparar (CPU da thread principal) | **305 ms** | thread principal |
| — gravar as listas de comando | ~170 ms (34 µs por draw) | thread principal |
| — refreshes título → host | 146–247 MB a **247–462 MB/s** em 4 538–8 648 chamadas | pool `wide()` |
| — texturas | 19 ms / 50 MB | thread principal |
| espera pela GPU (bloqueio) | **266 ms**, dos quais **180–216 ms** são "o título leu memória que um shader pode escrever" | thread principal |
| copiar de volta (thread do relé) | **408–432 ms** | thread do relé |
| — merge das cópias em RAM (comparação) | **179–198 ms** | pool `wide()` |
| — snapshots (copiar o "antes") | **98–110 ms** | pool `wide()` |
| — espera do fetch + merge do cartão | ~244 ms (derivado) | thread do relé |
| volume comparado por frame | **585–731 MB** em 339–406 ranges | |
| volume snapshotado por frame | **577–696 MB** | |
| bytes que realmente mudaram | **68–74 MB** | |
| CPU do processo | 46,3 % de 8 threads = **~2,2 s de CPU por frame** | |
| VRAM | 7,50 GB de 7,52 GB de orçamento; 98 recusas de "card copy: no room" | |

Três números explicam o resto:

1. **1,4 GB de tráfego de memória por frame** (160 MB refresh + 577–696 MB
   snapshot + 585–731 MB comparação + 69 MB de volta) para descobrir **~70 MB**
   de alteração. A banda de DRAM desta máquina é o teto dessa conta.
2. **O refresh título → host roda a 250–460 MB/s** porque cada range de ~38 KB
   é uma chamada `ReadProcessMemory` que faz o kernel percorrer as tabelas de
   página uma a uma. São 4 500–8 600 chamadas por frame.
3. **A thread principal não pode correr na frente**: ela bloqueia 180–216 ms por
   frame esperando o relé entregar o que o jogo lê. O jogo lê saída de shader
   (buffer de culling/instâncias) e essa leitura é uma dependência real.

## A banda desta máquina, medida

Benchmark isolado (Rust, mesma máquina, buffers residentes):

| Padrão | 1 thread | 4 threads |
|---|---|---|
| leitura de 1 stream (1 GiB) | 12,4 GB/s | 22,0 GB/s |
| `memcpy` (ler + escrever), destino quente | 4,4–5,8 GB/s | — |
| `ReadProcessMemory` de 4 600 ranges de 38 KB | 1,9–3,4 GB/s | — |
| comparação de 2 streams | 12,4 GB/s | — |

Duas conclusões que fecham portas:

- **O método de cópia não importa** no runtime: `ReadProcessMemory` e `memcpy`
  empatam porque o destino é memória fria. Foi por isso que o `plaincopy` deu
  neutro (269–484 MB/s contra 247–462).
- **Não há custo por chamada**: 38 KB custam 20,4 µs e 22,8 MB custam 12 ms —
  a mesma vazão. Coalescer os 7 632 ranges do refresh não ganharia nada.

O caminho de cópia entrega **1,85 GB/s agregado** (308–321 MB/s por thread × 6
threads), contra 22 GB/s de banda disponível. O limite é a **soma dos bytes**,
não a vazão da máquina: são 1,4 GB de tráfego por frame.

## O teto real desta máquina

- A GPU faz **bem menos** que o frame: o relógio do cartão mostra 50–73 % de
  "ocupado", e boa parte disso é a placa **parada com trabalho na fila** enquanto
  a CPU grava as listas (265 ms por frame nesse estado). O frame não é limitado
  pela placa.
- O teto é a **banda de memória da CPU** mais a **thread principal serial**.
  Cortar o snapshot e a comparação inteiros levaria o frame a ~300 ms — 3,3 fps.
  É o máximo do caminho de cópia atual.
- Para 30 fps seria preciso reduzir o tráfego de coerência de 1,4 GB para ~50 MB
  por frame, ou seja **parar de perguntar à memória o que mudou**. As duas saídas
  são grandes: máscara de páginas sujas escrita pelos shaders (projeto de
  emissor), ou memória do convidado que a GPU escreve direto (outro backend).

## Auditoria do upstream: as "write marks" já estiveram neste histórico

A pergunta era se os commits `cd94d35388765f85d4dd88f24d444e018c468ccd` e
`940d32f69b22265690a0b5a15d6ded572ba33baf` (Marvisak, marcação de páginas
escritas pelos shaders) faltavam no nosso fork. **Faltam — mas não por
desatualização.** Os dois são ancestrais da nossa base: chegaram, e depois foram
**substituídos**.

```
940d32f  ← base comum das duas linhagens
├── 570a941 "Publish DexNom Runtime Radeon sources"  (170 arquivos, −36.762 linhas)
│   └── 2e01ab4 → ... → cda80b3   (24 commits, o nosso main)
└── +83 commits                    (marvisak/main)
```

`git log -S'mark_entry'` mostra exatamente dois commits: `cd94d35` adiciona e
`570a941` remove. O mesmo para `Write marks` no emissor. Não foi um revert
cirúrgico: o `570a941` trocou a árvore por outra implementação do mesmo problema.

**As duas arquiteturas são incompatíveis na raiz**, e os conflitos provam:

| marcas (Marvisak) | a nossa base |
|---|---|
| `memory`, `memory_writes`, `view_addresses`, `heap`, `heap_writes`, `view_marks` | `written_root_uavs`, `writes_guest_memory`, `root_indexed_views` |

O emissor da nossa base **não tem a tabela de páginas** (`t0`/`u0` em
`MEMORY_SPACE`) que as marcas usam para traduzir endereço calculado em página.
Portar as marcas seria portar a emulação de memória inteira junto.

Medido, não estimado: merge completo de `marvisak/main` = **37 conflitos**;
cherry-pick só dos dois commits = **20 conflitos**, incluindo 5 arquivos de teste
que a nossa base apagou. Nenhum dos dois é um caminho razoável.

**O que a nossa linhagem tem no lugar:** o caminho do cartão. Uma cópia de
buffer do título grande fica na VRAM (`shadow::card_for`) e é comparada por um
compute shader nosso, `CARD_COMPARE`, que devolve por peça de 64 KiB uma máscara
de 16 bits das páginas de 4 KiB sujas — a mesma granularidade fina das marcas,
sem tocar no emissor.

## A espera do fetch, medida sem a contaminação do merge

A linha do relé dizia "402 ms esperando fetches", mas a janela começava no
*submit* do fetch e incluía o merge da CPU. Instrumentei a espera **pura**
(`WaitForSingleObject` apenas, `RELAY_STATS[5]`):

| run | cópias no cartão | espera pura do fetch | merge | snapshots | frame |
|---|---|---|---|---|---|
| `wait-174043` | 1 / 174 MB | **123–149 ms** | 191–216 ms | 108–115 ms | 477–585 ms |
| `vram70-175704` | 41 / 536 MB | **231 ms** | 73,8 ms | 43,2 ms | 457–461 ms |
| `room70-180632` | 2 / 175 MB | **143–175 ms** | 239–248 ms | 101–104 ms | 481–591 ms |

A espera bate com o tempo de GPU por frame (125–251 ms) e a placa fica a 26–32 %
de ocupação: o fetch não está esperando banda, está **enfileirado atrás de um
frame inteiro de draws**. É o problema que o `queue2.rs` do PR #32 resolve.

## O caminho do cartão vale, e o preço dele é a VRAM

A/B direto, mesma build, mesma cena, só o switch:

| | frame | merge | snapshots | relé |
|---|---|---|---|---|
| `VICTORY_CARD_BUFFERS=0` (tudo na CPU) | 575–671 ms | 244–287 ms | 153–176 ms | 282–339 ms |
| padrão (caminho do cartão ligado) | 477–585 ms | 191–216 ms | 108–115 ms | 368–399 ms |

**O caminho do cartão vale ~80–100 ms.** Desligá-lo não é opção.

O que decide o tamanho do ganho é **quantos buffers cabem na VRAM**. Com 536 MB
cardados em vez de 174 MB o merge caiu 191 → 74 ms e os snapshots 115 → 43 ms.
Mas `card_for` recusa acima de 4/5 do orçamento, e o cartão chega ao carregamento
do mundo a 92–93 %: **96–98 recusas por run**, 700 MB comparados na CPU.

`VICTORY_TEXTURE_ROOM_PERCENT` **não é a alavanca** para isso — testado a 70 e
depois como padrão no código: voltou a 2 cópias e 96 recusas. O `room()` só
governa cópias de textura, e a variável não muda o que ocupa o cartão no
carregamento. A run que cardou 536 MB foi **variância de VRAM**, não a variável.

A alavanca é `VICTORY_TEXTURE_BUDGET_MB`, que limita de fato as nossas cópias de
textura (1.882 MB) e portanto abre espaço para as cópias de buffer.

### Resultado: 768 MB de textura, o resto para o cartão

`VICTORY_TEXTURE_BUDGET_MB=768`, e depois como **padrão do código**, mesma cena
(~5 000 draws), mesma build:

| | antes | depois |
|---|---|---|
| cópias de buffer no cartão | 1–2 / 174 MB | **97 / 941 MB** |
| recusas de "no room on the card" | 96–98 | **0** |
| comparado na CPU por frame | 717–733 MB | **25 MB** |
| relay merge | 191–248 ms | **6,5–13 ms** |
| snapshots | 100–115 ms | **3,0–5,1 ms** |
| copiar de volta (soma) | 308–352 ms | **14–22 ms** |
| frame | 477–585 ms | **339–371 ms** |
| fps no mundo | 1,7–2,1 | **2,7–3,0** |

A comparação de 717 MB na CPU **acabou**: 941 MB de cópias de buffer moram na
VRAM e são comparadas lá, com granularidade de 4 KiB, sobrando 25 MB para a CPU.
É a resposta à pergunta do item 4 da operação: **sim, liberar VRAM transfere o
trabalho do caminho lento da CPU para o caminho do cartão, e vale ~130 ms de
frame.** O preço é o orçamento das cópias de textura (1.882 → 768 MB); as texturas
que já estavam esperando por memória continuam esperando.

Com o merge quase zerado, o frame agora é outra coisa:

| etapa | custo | onde |
|---|---|---|
| preparar | 148–179 ms | thread principal (copies 90–116, texturas 5–13, listas ~50) |
| esperar o cartão | 113–143 ms | thread principal (130 ms é "título leu memória de shader") |
| copiar de volta | 251–269 ms | thread do relé |
| — **espera pura do fetch** | **157–167 ms** | thread do relé |
| — espera com nada para pousar | 32–42 ms | thread do relé |

**O gargalo agora é um só: o fetch do que os shaders escreveram.** 157–167 ms por
frame para buscar ~54 MB, com a placa a 26–32 % de ocupação. Não é banda — é fila.

## Próximas otimizações, por ordem de retorno

1. **Fila de cópia própria para o fetch** (o `queue2` do PR #32 do upstream): é o
   maior item removível, **123–231 ms de espera pura** por frame, e não é banda —
   a placa está a 26–32 %. O fetch é submetido na fila principal e espera um frame
   inteiro de draws passar na frente. Uma fila `D3D12_COMMAND_LIST_TYPE_COPY`
   faria ele rodar ao lado. **Não é uma mudança segura de poucas linhas**: o merge
   usa `Pending::after` (a ordem da fila no momento do fetch) para decidir quais
   envios já estão incluídos, e numa fila separada o fetch pode rodar antes dos
   envios que ele presumiu ver. Exige um fence por valor de ordem, ou fazer o
   próprio `CARD_COMPARE` escrever os bytes sujos no readback (aí o fetch some e
   a ordem é exata por construção, porque tudo fica na mesma submissão).
2. ~~**VRAM para as cópias de buffer**~~ — **feito e medido**: 768 MB de
   orçamento de textura como padrão põe 97 cópias / 941 MB no cartão, zera as
   recusas, tira 700 MB da CPU e leva o frame de 477–585 para 339–371 ms.
3. **"Antes" incremental em vez de snapshot por frame** (~100 ms): hoje o "antes"
   é copiado inteiro (577–696 MB) a cada submissão. Se cada escrita na cópia — o
   refresh e o merge do que os shaders escreveram — também for aplicada à imagem
   "antes", o snapshot por frame some.
4. **Os ~146 ms de gravação de listas** (~30 µs por draw, 10× o que uma camada
   D3D12 bem escrita gasta). Precisa de um profiler de amostragem na thread
   principal; o build `diagnostics` não serve (6–13 s por frame).
5. **Dirty mask no emissor**: descartado como próximo passo. As marcas do
   Marvisak exigem a tabela de páginas, que a nossa linhagem não tem (ver a
   auditoria acima). O caminho equivalente aqui é o `CARD_COMPARE`, e ele já
   entrega granularidade de 4 KiB.

**Descartado com número:** coalescer os runs do refresh não ganha nada — o
benchmark isolado mostra que não há custo por chamada (38 KB custam 20,4 µs,
22,8 MB custam 12 ms, mesma vazão).

