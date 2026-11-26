
===== AvatarManz Section F =====
## F. Correcoes importantes

### F-1. Slot nulo no fim do heap de views (D-14)

- **O que estava errado.** Indice de view vindo de dados do titulo podia passar do fim do heap; na NVIDIA isso trava a GPU, na RDNA3 remove o dispositivo.
- **Como foi corrigido.** `set_view_heap_limit(null_slot)` grava o limite na traducao; toda leitura de view indexada e clampada para esse slot, que e mantido nulo, e o limite entra na chave do cache de shader (`translation_fingerprint`).
- **Por que funciona.** Transforma comportamento indefinido (leitura fora do heap) em leitura de descritor nulo definida, sem custo de branch por acesso (um `UMin` — o comentario registra que a forma `compare+select` gerava bitcode invalido quando emitida em `dx.op.binary`).
- **Dependencias.** Requer `shader model 6.6` + heap de 2^22; requer que a traducao conheca o limite no momento de emitir (por isso ele entra na impressao digital).
- **Reutilizavel.** Sim, e **obrigatorio** em qualquer camada que rode shaders de console sobre D3D12 com heap limitado. E o mesmo padrao que outros dois forks resolveram de forma independente (`fix/amd-view-heap-clamp` de triippywhale, `fix/nvidia-view-heap-cap` do PR #21 do Marvisak).

### F-2. Raw twins: uma view raw dos mesmos bytes para cada view de buffer do heap (D-13)

- **O que estava errado.** "Picked buffer" (buffer escolhido por indice calculado) lido como bytes crus: na AMD, load raw por view tipada **nao tem fim**; descritor de textura lido como buffer = endereco selvagem; indice alem dos slots do titulo alcanca slots dinamicos de outras listas.
- **Como foi corrigido.** Heaps de 2^22 views; acima de 2^21, para cada view de buffer de slot do titulo existe uma view raw dos mesmos bytes (view de constant buffer para constant buffer; view raw **nula** para todo o resto e para todo slot alem dos do titulo). Picks raw e constant passam a ler ali. Uma view que nao comeca em 16 bytes nao pode ser raw: seu twin e a propria view.
- **Por que funciona.** O acesso passa a ter um limite real imposto pelo hardware, e o tipo do descritor deixa de depender do que o titulo pos no slot.
- **Custo.** "Every shader is translated again (8 min)"; heaps 2x maiores.
- **Conflitos possiveis.** Colide com qualquer outro esquema de "slot reservado" no fim do heap (F-1 usa o ultimo slot; os twins ocupam a faixa 2^21..2^22). Ao consolidar, os dois esquemas precisam ser desenhados **juntos**.
- **Riscos.** `VICTORY_RAW_VIEWS` e parte da traducao; um cache de shader compartilhado entre forks com valores diferentes corrompe silenciosamente.

### F-3. Regras de float da RDNA escritas como a instrucao unica do driver (D-11 / secao I)

- **O que estava errado.** `v_max_f32`/`v_min_f32` ordenam -0 abaixo de +0; `DXIL FMax/FMin` devolvem qualquer zero. `v_mul_legacy_f32` faz `0 * x = 0` (assinatura do zero pode ser a outra). `v_med3_f32` com NaN devolve o **minimo** dos tres. `v_fract_f32` nunca chega a 1.0. A traducao "correta em qualquer host" gastava 7 operacoes por max/min, 5 por produto legacy, etc.
- **Como foi corrigido.** `set_host_rdna(amd && WaveLaneCountMin==32 && WaveLaneCountMax==64)`; com `VICTORY_RDNA_FLOAT` (bits `MAX_MIN|LEGACY|MED3|FRACT`, default todos), cada instrucao vira a operacao unica que o driver compila na instrucao nativa; a analise `bounded()` prova por 12 niveis que um fator nao pode ser infinito/NaN para poder usar produto simples.
- **Por que funciona.** O hardware do host **e** o hardware do console (RDNA2 no console, RDNA3 no host): as regras de NaN/zero sao as mesmas.
- **Ganho medido.** 18,41 -> 17,58 ms no frame do quintal (12 loops), 0,4 ms so dos produtos legacy; imagem igual (79 dB; dois replays do mesmo conjunto diferem por 68).
- **Reutilizavel.** Sim, **e o item de maior valor para uma consolidacao**: e o unico ganho de tradutor medido e reprodutivel em RDNA3.

### F-4. Clamp indireto em compute shader com cobranca por grupo (base, mantido)

- **O que estava errado.** Argumentos indiretos escritos por passes do titulo; um pass dropado ou mal traduzido deixa lixo e "um draw de quatro bilhoes de vertices roda ate o host resetar o driver".
- **Como foi corrigido.** Um compute de 64 threads copia e limita os registros ativos para um scratch device-local, sem tocar nos buffers do titulo; cada grupo cobra o custo dos seus registros com **uma** operacao atomica (soma saturada em ordem de lane), e cada thread le se o seu registro coube.
- **Por que funciona.** O custo e cobrado saturando sem wrap de 32 bits, entao milhares de registros lixo nao rodam por segundos; e o scratch fica legivel como argumentos indiretos depois do clamp, sem barreira por execucao (os draws que leem registros clampados juntos seguem sem nada entre eles).
- **Reutilizavel.** Sim — mas ver D-01: o **rateio** do orcamento e a parte que ainda machuca.

### F-5. Texturas que shaders escrevem e a CPU le voltam para a memoria do titulo (barcos flutuam)

- **O que estava errado.** Mapas de altura/deslocamento do oceano sao escritos por compute e **amostrados pela fisica na CPU**; nunca voltavam para a memoria do titulo. "Boats sank, the sea plane went under."
- **Como foi corrigido.** `23925a4` (de fxeceless `f5c03f3b` / PR 999, Geckomacabre `895c0b8f`, `04df4350`): quando uma lista fecha com escrita de shader numa textura de certos tipos, copia para um read-back buffer e, quando a lista roda, **retila** os texels na memoria do titulo no layout do console.
- **Por que funciona.** A fisica le exatamente os bytes que a GPU teria deixado.
- **Dependencia.** Lista de 4 formatos fixos (D-18) — o ponto fragil.

### F-6. Emulacao de instrucoes AMD que o Intel nao tem (monitorx/mwaitx/clzero/extrq/insertq)

- **O que estava errado.** O console e Zen 2; o titulo usa `monitorx`, `mwaitx`, `clzero`, `rdpru`, SSE4a `extrq/insertq`, `clwb`. Num i9-12900K cada uma levanta `STATUS_ILLEGAL_INSTRUCTION` — **25.000 excecoes por segundo** nos lacos `clzero` de uma funcao.
- **Como foi corrigido.** Handler vetorado decodifica e emula; `2132366` **substitui no lugar** no primeiro fault (`monitorx` -> nop de 3 bytes, `mwaitx` -> `pause` + nop); `13ffc28` cobre waits que passam do fim de 8 bytes e transforma lacos `clzero` em stores simples. Um cache de "regiao lembrada" evita perguntar ao Windows a cada instrucao (a query custava 2-9 ms em heaps de 0,6-2,2 GB e 89 ms no pool de 6,2 GB do titulo).
- **Por que funciona.** O laco do titulo volta a olhar o valor logo depois do wait; `pause`+nop preserva a semantica observavel; o store em vez de `clzero` e identico em memoria coerente.
- **Custo.** Auto-modificacao de codigo do titulo (precisa da pagina gravavel).

### F-7. Detiling de cadeia parcial de mips (`bytes_from`)

- **O que estava errado.** Uma textura streamada em que so os mips menores estao presentes tem outra textura logo atras na memoria; exigir `Layout::size` bytes para detilar falhava com `TooSmall` (e o titulo nao tinha o buffer inteiro).
- **Como foi corrigido.** `Layout::bytes_from(first)` calcula o prefixo necessario: o maior fim de mip a partir de `first` (alinhamento quando o mip tem `tail`); vale o layout inteiro se houver mais de uma slice, se for `thick`, 3D, multisample ou `first >= mips`.
- **Por que funciona.** Os mips menores ficam **no inicio** do bloco tiled; teste `smaller_mips_need_only_the_start_of_the_texture` verifica byte a byte que detilar o prefixo da o mesmo resultado que detilar o todo, e que um byte a menos da `TooSmall`.
- **Origem.** victory-amd `bddfb4a5` (myokex).

---


===== AvatarManz Section I =====
## I. Conhecimento reutilizavel

Priorizo o que e **exclusivo deste fork** (89 arquivos so dele) e o que e **codigo especifico de GPU**, como pedido.

### I-1. Tradutor: regras de float da RDNA (maximo valor de consolidacao)

- **Problema resolvido.** Instrucoes VALU do console (`v_max_f32`, `v_min_f32`, `v_mul_legacy_f32`, `v_med3_f32`, `v_fract_f32`) traduzidas por formas portaveis custam de 5 a 7 operacoes; nas formas nativas custam 1.
- **Implementacao.** `crates/victory-shader/src/emit/lower.rs`: `max_min()` (linha ~3710), `med3()` (~3847), `fract()` (~3887), `legacy_mul()` (~3940); dispatch em `set_host_rdna` (`emit/lower.rs:1120-1141`); bits em `emit/mod.rs:249-263`; deteccao em `host.rs:922-927` (`WaveLaneCountMin == 32 && WaveLaneCountMax == 64` e `VendorId == 0x1002`).
- **Detalhe que importa.** `max_min` sem o bit RDNA emite a sequencia que preserva a ordem de zeros: `or` dos bits, mascara `0x7FFF_FFFF`, comparacao com zero, escolha do zero com sinal (`and` para max, `or` para min). `legacy_mul` usa `Module::bounded(v, 12)` — analise de **magnitude** que devolve `ceil(log2(|k|))` para constantes e propaga por conversoes (`UiToFp`/`SiToFp` -> 32), com corte em `b < 126` para nao aceitar potencia que estoura — para provar que nenhum fator pode ser infinito/NaN e entao usar produto simples.
- **Ganho.** 18,41 -> 17,58 ms/frame no frame do quintal, 0,4 ms so dos produtos legacy; mesma imagem (79 dB).
- **Dependencias.** Precisa de `WaveLaneCountMin/Max` do host **e** identificacao do vendor; precisa entrar na impressao digital do cache (`translation_fingerprint` ja inclui `host_rdna`).
- **Riscos na consolidacao.** O bit `LEGACY` **muda a assinatura do zero** ("a zero may have the other sign"): qualquer lugar que compare `mul_legacy` por bits (hashes de frame, replay `--compare`, testes de diff) pode divergir. Medido e aceito pelo autor.

### I-2. Tradutor: wave64 do console em wave32 do host, com escada de retry

- **Problema.** Programas de compute wave64 do console rodando num host de waves de 32; barreiras de grupo dentro de branches/loops sao indefinidas quando nem toda thread do grupo as alcanca.
- **Implementacao.** `emit/mod.rs:440-620`: escada ordenada — (1) forma idiom (`lower::wave_local`, exata), (2) remocao de skips que o codigo seguinte nao ve (`ir::without_skips`), (3) `widen()` (branches por wave inteira, **2 barreiras de grupo por branch**), (4) "local waves" aproximadas por host wave, (5) "any mask". Diagnostics por `VICTORY_WAVE_WHY`, `VICTORY_WAVE_LOCAL`, `VICTORY_WAVE_DEEP_SKIPS`, `VICTORY_WAVE_WIDE`, `VICTORY_GROUP_SYNC` (0/1/2) e a **regra de ouro**: com `GROUP_SYNC=0` programas wave64 em duas waves calculam errado (documentado no proprio codigo).
- **Helper lanes.** `first_lane()` (`lower.rs:4785-4803`) e `helper_lane()` (`isHelperLane.i1`, op 221).
- **Risco.** A forma (3) "lost the card in a submission of two programs that had just moved to it (`ptfx_CS_lightAtlas_Sprite` e `_Trail`, runs 121-124)": e opt-in, nao padrao.

### I-3. Descritores do host com o layout da RDNA 2

- **Fato.** Views de 32 bytes e samplers de 16 — **o tamanho dos descritores de imagem e sampler da RDNA 2** — para que um titulo que **copia descritores ele mesmo** mova descritores inteiros e corretos. Views de render target e depth sao so do host; 128 bytes deixam folga para qualquer stride que o titulo suponha (`descriptor.rs:1-7`).
- **Consequencia pratica.** Qualquer tabela de descriptor mirroring, comparacao de descritores do titulo ou decode de bits (I-5) depende desse layout. Ao consolidar com forks que usam 64/32 bytes ou stride diferente, **todo** o espelhamento de descritores quebra.
- **Contrapartida de VRAM.** 2^22 views x 32 B por heap (F-2) e um custo fixo que precisa entrar no orcamento de I-6.

### I-4. `book.rs`: decode dos bits de descritor AMD para diagnostico de device loss

- **Problema.** Um device loss nomeia um endereco que faltou e, de uma lista curta, o que foi liberado ali; uma textura "sumida ha minutos" cai em "nada nomeado"; qual descritor ainda a nomeia nao e dito.
- **Implementacao.** `crates/victory-gpu/src/book.rs` (so deste fork). Mantem "livro" de todo buffer, textura e bloco de textura com o **endereco desde que foi criado** e a hora em que saiu; no loss, quem tem/teve o endereco (mais novo primeiro) e **cada slot do heap cuja descricao alcanca o endereco**. `VICTORY_SLOT_CHECK=1` varre o heap com uma thread enquanto nada esta perdido. Decodifica o descritor de 32 bytes como o hardware AMD tem desde RDNA 2 (`decode`), com teste de bytes reais lidos na RX 7900 XTX (textura 64x64 e 2048x2048, buffer raw).
- **Aplicabilidade.** Ferramenta de campo para qualquer camada D3D12 sobre RDNA 2/3. **Nao** funciona em outra placa por design ("on another card nothing is decoded as an address we know, and nothing is said").
- **Custo.** `GONE = 400_000` entradas; `LONGEST = 2 GiB`; entradas acima de `LONG = 64 MiB` sao procuradas uma a uma.

### I-5. VRAM: o "budget" da RX 7900 XTX e metade do cartaz

- **Fato medido.** `host.rs:9051-9088`: `IDXGIAdapter3::QueryVideoMemoryInfo` com `DXGI_MEMORY_SEGMENT_GROUP_LOCAL`/`NON_LOCAL`. O autor registra que o budget local **caiu de 11.242 MB para ~10.300 MB** no primeiro frame do mundo. Ou seja: numa placa de 24 GB, o orcamento que o Windows reporta e ~11 GiB, nao 24 — e o `victory` nao reserva nada.
- **Bug que isso causou.** Sem reserva, a fila de texturas enchia a placa ate 99-100,5 % e **as copias de buffer eram recusadas** (runs 193/197/198: 652 MB antes do mundo, 2.255-2.352 MB logo depois do primeiro frame, 2.800-3.100 MB dois minutos depois, "none of them idle").
- **Correcao reutilizavel.** `VICTORY_CARD_ROOM_FOR_TARGETS_MB` (padrao **3.072 MB**, teto 8.192, 0 = nenhum) — a fila de texturas deixa essa folga para render targets e copias que ainda nao existem (`resource.rs:1707-1737`, de fxceless `a26859f`).
- **Limiares de "copia de buffer vai para a placa" escalonados por VRAM** (`shadow.rs:180-248`): budget <= 12 GiB -> 16 MiB / 512 MiB; < 20 GiB -> 4 MiB / 2.048 MiB; >= 20 GiB -> 1 MiB / `min(budget/4, 8 GiB)` (= **6.144 MiB** numa de 24 GB). Overrides: `VICTORY_CARD_BUFFERS_MIN_MB`, `VICTORY_CARD_BUFFERS_MB`, e `VICTORY_CARD_BUFFERS_MIN_KB` (desce abaixo de 1 MiB; 64 KiB = todo buffer do titulo, "in the PC's memory every load, store and atomic a shader does on them crosses the bus"). `VICTORY_CARD_ALL=1` põe tudo na placa.
- **Recomendacao de adaptacao.** Nao copiar os numeros; copiar a **forma**: orcar por `QueryVideoMemoryInfo`, reservar folga para targets, escalonar o limiar de copia por VRAM, e logar budget/uso quando o budget varia mais de 256 MB.

### I-6. Alocacao de textura: pool de blocos, nao alocacao por textura

- **Fato.** Na RX 7900 XTX **uma alocacao custa ~310 microssegundos independentemente do tamanho**, numa thread (`texture::allocation_costs`, citado em `pool.rs:1-20`). O pass que cria as texturas que shaders escolhem por indice fazia 350-500 das 24.000 enfileiradas a cada turno de 250 ms — "some forty seconds of a world without its textures".
- **Solucao.** `pool.rs` (so deste fork): texturas e staging cortados de blocos feitos uma vez; peca devolvida so e reutilizada **2 segundos** depois (nada que a placa recebeu antes disso ainda esta rodando — "Windows resets a card that takes that long over one submission") e so quando nenhuma lista a nomeia. `VICTORY_TEXTURE_POOL=0` volta ao antigo.

### I-7. Formato de bloco e tiling: swizzles `SW_*` + `bytes_from`

- **Swizzles do console** (`victory-formats/src/texture.rs:43-55`): `SW_4KB_S/D`, `SW_64KB_S/D`, `SW_64KB_S_T/D_T`, `SW_4KB_S_X/D_X/R_X`, `SW_64KB_Z_X/S_X/D_X/R_X` — a familia addrlib. Tabelas imutáveis compartilhadas (`8961e15`, TG0000) e **teste contra os proprios tamanhos e enderecos da addrlib** (`8f08131`, Vyacheslav Venglovsky) — este teste e o ativo mais valioso para confiar no detiling.
- **Benchmark de layout** (`crates/victory-formats/examples/texture_layout_bench.rs`, so deste fork): BC7 `64KB_D`, BC1 `64KB_S`, RGBA8 `4KB_D`, R8 `64KB_S`, volume RGBA8, linear — 50.000 chamadas por caso, com `black_box`.
- **Cadeia parcial de mips** (`bytes_from`, F-7) — o caso real de streaming de textura.
- **Armadilha que o fork documenta** (`inplace.rs:29-32`): uma textura em heap aberto da memoria do titulo precisa ser **row-major com um nivel**; **tile mappings nesse heap sao recusados e REMOVEM O DISPOSITIVO**. Ou seja: nao se pode combinar "heap aberto do titulo" com "textura tiled do console" — a detiling tem de acontecer na copia.

### I-8. Memoria do titulo: guards por bits, "beside", e o que o Windows recusa

- **Fatos operacionais raros e uteis** (`inplace.rs`): `OpenExistingHeapFromFileMapping` aceita secao `SEC_COMMIT` e **recusa** `SEC_RESERVE` (como o `xmem` faz o pool do titulo); abrir um heap de 256 MiB custa 0,2 ms e nao traz working set; enquanto o heap aberto existe, `VirtualFree`/`VirtualProtect` das paginas dele **falham com erro 87** e nao se pode desmapear uma view; `MEM_WRITE_WATCH = 0x20_0000` nao esta no modulo de memoria do `windows-sys`.
- **Escrita "beside"** (`f19e55b`, `83a1bcf`): em vez de mudar protecao, a escrita do titulo vai por **nossa propria view** da pagina, e o bloco e marcado como escrito por um bit que a proxima pergunta consome — "no protection changes, for the write or for the next taking". `memcpy`/`memmove`/`memset` interceptados (imports nossos) e stores que faultam decodificados no handler; "too many to a block, or code that fills blocks: opened as before". Os dois ficam **desligados** por padrao (`VICTORY_COPY_BESIDE=1`, `VICTORY_STORE_BESIDE=1`) e `scripts/play.ps1` **nao** os liga — so `VICTORY_RELAY`/`VICTORY_RELAY_COPY` (o caminho relacionado, de relay) estao no script.
- **Escritas que nao mudam nada nao sao feitas** (`83a1bcf`): store que faulta ou parte de copia cujo byte ja esta la e omitida; o arquivo `VICTORY_WRITE_SITES=<file>` guarda **offsets** (nao codigo) dos `or byte, const` do titulo que seguem essa regra, aplicados no load.
- **Bloco que acabou de ser escrito "descansa"** antes de ser guardado de novo (`VICTORY_GUARD_REST`, `7bc7c07`), e um fault abre **so a view por onde veio** (`VICTORY_OPEN_ONE_VIEW`).
- **Reuso.** Todo esse conjunto e a resposta ao problema central de camadas de console: notar escrita de CPU sem `VirtualProtect` por pagina. E **ortogonal** ao tradutor e ao backend, entao e o candidato mais direto a entrar num repositorio unificado.

### I-9. Indireto: clamp, orcamento, e o que a placa aguenta

- **Numeros que valem como ponto de partida:** `BUDGET = 2^27` (vertex-instances ou threads por lista; grupo de compute conta 64 threads, mesh 128); `MOST_DRAW = 2^23` (vertices/instancias de um registro de draw); `GROUPS = 2^20` (grupos por dispatch); mesh maximo 65.535; `WIDEST = 2^20` em AMD para compute indireto (testado na 7900 XTX: "every group once, under its number").
- **Heuristicas de "slot nao preenchido"** (todas conservadoras, todas capazes de cortar trabalho legitimo): draw com `want.x > 2^24` ou `want.y > 2^24` quando ha janela `ahead` -> vazio; `want.x >= 2^23` -> vazio; mesh `g.x > 65535` -> vazio. O autor documenta o achado que motivou ("90 of 2^24 vertices in one list", de victory-fork `f85101b6`).
- **Diagnostico no proprio buffer:** palavras 4/8 = maior contagem de mesh e total pedidos; 12/16 = registros recusados por orcamento e maior custo visto (>= 2^22); consumidas pela linha de frame do `Meter`. **Este e o instrumento que falta em outros forks para provar D-01.**

### I-10. Replay de frame (o maior ativo de engenharia exclusivo)

- **O que e.** `crates/victory-gpu/src/replay/*` (15 arquivos, ~13.800 linhas; mais `apps/victory/src/replay.rs` na CLI): grava um frame do mundo (tudo entre dois presents), roda de novo sem o titulo, mede por comando, compara variantes de shader turno a turno, e descobre **qual comando mudou um pixel**.
- **Numeros.** Captura de um frame de tamanho de titulo: +3-10 ms por frame com o gravador ligado; a captura para 5,4 s e ocupa 9 GB (8 GB de memoria da placa a 2,3 GB/s + 1 GB de CPU) em `docs/replay.md`.
- **Capacidades que sustentam todas as conclusoes deste fork:** `--compare`, `--retranslate`, `--shaders-b`, `--pixel`, `--diverge`/`--diverge-picture`, `--upcopies`, `--flow`, `--images`, `--watch`, `--slots`, `--skip-*`, `--buffers vram|sysmem`.
- **Limitacao conceitual documentada:** shaders que distribuem lugares com atomics dao resultados diferentes a cada run; o replay **funde** as copias da CPU com o que a placa escreveu nesta run (`merge.rs`), e `--no-merge` desliga isso. Sem esse cuidado, "lists e o que aponta para elas sao de duas runs".
- **Reuso.** E o instrumento que permite medir GPU sem o jogo. Para consolidar, e mais valioso que qualquer otimizacao individual.

### I-11. Preparacao assincrona: thin lists, submit thread, landing, card steps

- `VICTORY_THIN` (`list/thin.rs`): chamadas de lista so **anotam** argumentos em `CHUNK = 1024` palavras; 8 threads traduzem ao lado. Motivo medido: 45.000-60.000 chamadas/frame, 3,5 us cada, 160-190 ms de CPU.
- `VICTORY_ASYNC_SUBMIT` (`b8b30d1`): uma thread prepara e envia; o titulo nao executa nada na hora — **esta e a origem de toda a classe de bugs de ordem** (D-05).
- `VICTORY_LAND` (`0d5e4c8`, `2aa8134`): o que shaders escreveram volta para a memoria do titulo **ao lado dos guards**, por dwords alteradas, em thread propria; 16 MB/frame.
- `VICTORY_CARD_STEPS` (`=2` no script): fills de buffer que precisam de bytes que ainda estao na placa sao feitos **na placa** (`host/card_steps.rs`) em vez de esperar.
- **Reuso.** Conjunto coerente e medido; mas cada peca depende de contadores proprios e de um modelo de ordem global. Ao consolidar, **nao misturar** com outro modelo de submissao: o par thin+async e indivisivel na pratica (`thin` exige `queue::line_on()`).

### I-12. Impressao digital do tradutor (cache de shader que sobrevive a rebuild)

- **Problema.** 2.500 pipelines levam minutos; um rebuild que nao mudou o tradutor nao deveria invalidar nada.
- **Implementacao.** `victory-gpu/build.rs` (so deste fork): BLAKE3 sobre os **fontes** de `victory-shader` + `victory-shader/Cargo.toml` + `shader_cache.rs` + `Cargo.lock` + `rust-toolchain.toml`, com `\r` removido (line endings iguais em todo checkout) -> `VICTORY_TRANSLATOR` (env em tempo de build). Em runtime, `translation_fingerprint()` (`emit/mod.rs:283-304`) concatena: hash do fonte, `cfg!(feature="diagnostics")`, `cfg!(debug_assertions)`, **valor de cada `VICTORY_*` que o tradutor le** (lista gerada em build), `host_max_wave`, `host_rdna`, `view_heap_limit`, `raw_views`, `loop_limit`, `group_sync`, `shader_opt`.
- **Reuso.** Modelo para qualquer camada que traduza shader: a chave do cache deve ser (fonte do tradutor, switches lidos, fatos do dispositivo), nao o executavel.
- **Risco.** O desenho e correto, mas **quebrou uma vez na pratica**: `VICTORY_BVH_FENCES` teve de ser adicionado explicitamente (`30f46c9` adiciona o nome na lista de `shader_cache.rs:74-77`), o que mostra que a lista de switches e manual e pode esquecer um.

### I-13. CPU do console: instrucoes AMD ausentes no Intel (ver D/F-6)

- Reutilizavel em qualquer camada que rode binarios de console em CPU Intel; a origem e XCL (ver D-17 — **nao copiar sem resolver a licenca**).

### I-14. Pipeline: pre-aquecimento e particao por custo

- `apps/victory/src/warm.rs` + `pipeline/known.rs`: todo pipeline que o titulo cria e escrito em `known-pipelines.bin` (containers em `known-shaders.bin`, no cache — "they are the title's code"); `victory warm` os fabrica em processos idle de 200 (agora 40), grava `warm-done.txt`/`warm-bad.txt`; `VICTORY_EARLY_ALL` faz isso dentro do titulo. Chave por **versao do driver** (`host.driver()` = `IDXGIAdapter::CheckInterfaceSupport(&IDXGIDevice::IID)`) e tradutor.
- `make.rs`: tres filas (tela, lenta, normal), `slow-pipelines.txt` alimentado por medicao real (>= 1 s) em `warm.rs` e em `library.rs` — **duas constantes `SLOW_MS` separadas** (`apps/victory/src/warm.rs:22` `f64 = 1000.0`; `pipeline/library.rs:705` `u64 = 1000`), que precisam concordar e nao sao compartilhadas (a de `library` e `pub(crate)`). Ponto de atencao na consolidacao.

### I-15. O que **nao** vale a pena repetir (medido e descartado)

Registrado pelo autor em `docs/findings.md` e nos comentarios — economiza dias de quem consolidar:
pipeline early unordered para tudo (o compilador da AMD crashou); perfil Series S, texturas menores, segunda fila de desenho, `ASYNC_SUBMIT` off; mapear paginas em 16 threads (D-04); 4 dwords por load (`VICTORY_SHADER_OPT=127`: 18,47 -> 18,45 ms, "the driver joins the loads"); tamanhos de wave por programa de compute (+0,1 a +0,26 ms); `v_mad` como FMA; reciprocos rapidos; buffers "picked" lidos sem perguntar o tipo (0,12 ms); **remover todas as barreiras (0)**; rodar o codigo do console nativamente na placa (o driver do Windows nao aceita codigo cru; "what is left to gain from shader code was guessed at under 1 ms").

---


===== Belobug-AMD Section F =====
## F. Correcoes importantes

### F-01 - Substituir a luz indireta em vez de elevar o que esta la (`4f45ab8`)

- **O que estava errado**: o passe de resolve de probes tem saida invalida sem
  rays; a primeira correcao somava um piso a esse valor, o que apenas garantia
  que o lixo fosse claro o bastante para ser visto.
- **Por que funciona**: a imagem R9G9B9E5 e **historia** do proximo frame; basta
  escrever o valor desejado (constante tingida) para que a iluminacao do titulo o
  aplique com as cores das superficies. Nao ha dependencia dos dados do passe.
- **Dependencias**: nome do programa (`CS_ScreenProbes_TemporalResolve`), root
  parameter e indice na tabela (`LIGHT = (1, 176)`), formato de empacotamento
  R9G9B9E5 implementado em HLSL no proprio modulo, `D3DCompile` em runtime,
  `shader_cache` para nao recompilar.
- **Reutilizavel?** Sim, como **padrao**: identificar por prefixo de nome o passe
  cuja entrada nunca e produzida e substituir sua saida; manter o valor num
  arquivo recarregavel a quente para calibrar. Especifico do titulo nos numeros.
- **Efeitos colaterais**: sem oclusao; interiors sem RT continuam pretos;
  reflexos precisaram de contencao propria (`c3bd561`/`REFLECTED =
  CS_UpdateHistory`).

### F-02 - Leituras de quad em pixel shader (`03629f3`)

- **O que estava errado**: derivadas por `quad_perm` liam lanes comuns e
  recebiam 0 de helper lanes.
- **Por que funciona**: `quad_pick` le explicitamente os quatro pixels do quad
  (via leitura de quad do hardware/`QuadReadLaneAt`), que **incluem** helpers;
  helper lane e justamente quem carrega a informacao nas bordas.
- **Dependencias**: nenhuma alem de `self.s.pixel` (estagio) e do caminho
  `quad_pick` ja existente para mesh shaders.
- **Reutilizavel?** Sim, e a mudanca mais barata e mais geral do fork: 17 linhas
  em `lower.rs`. Upstream faz isso apenas depois de `discard`; a AMD exige sempre
  em pixel shader.
- **Risco**: em hardware onde leitura de quad de helper lane nao e barata, ha
  custo; em NVIDIA o comportamento ja era outro (o fork nao testou NVIDIA).

### F-03 - Hoisting dos clamps de indiretos (`ccab973`, `918ab03`, `76387c2`, `684a9b5`)

- **O que estava errado**: trabalho de emulacao (clamp) intercalado com o
  trabalho real (draw), um dispatch + 3 barreiras por draw.
- **Por que funciona**: os argumentos de todos os draws de uma corrida sao
  clampados **antes** de qualquer draw da corrida, em buffers lidos por offset;
  a lista e cortada no primeiro indireto (`Hoist { clamps, into, writes }`) e
  invalidada se um dispatch/copia posterior escrever os argumentos
  (`writes` comparado). Modo 7 executa os clamps em sequencia para eliminar a
  corrida que causava flicker.
- **Dependencias**: `indirect.rs` (`bound`, `record_clamp`, `hoist_mode`),
  `draw.rs` (`State::hoist`/`hoists_into`/`end_hoist`), `list.rs`
  (`keep_until_run`, `count_write`), `host.rs` (tempo de GPU por comando).
- **Reutilizavel?** Sim: e o padrao classico "emulacao por comando -> lote".
  Exige que a emulacao seja **pura** e que a invalidadacao por escrita seja
  correta - e onde o flicker nasceu.
- **Risco**: qualquer escrita nos argumentos entre a lista de clamps e a lista
  de draws invalida o lote; o teste de `writes` e a unica protecao.

### F-04 - Contagem de elementos pela tabela do host (`1503444`)

- **O que estava errado**: `GetDimensions`/size query de structured buffer com
  certos strides **crasha o compilador da AMD**.
- **Por que funciona**: o host ja sabe o `NumElements` da view do titulo
  (`view_count`); publica strides e contagens numa tabela de constantes
  (`COUNTS_AT = OWN_SLOTS`) que os shaders leem em vez de perguntar ao recurso.
- **Dependencias**: `victory_shader::emit::OWN_SLOTS` (contrato entre crates),
  `StrideTable` alocada com `COUNTS_AT + len` dwords, `set_stride_count` em todo
  caminho que cria view.
- **Reutilizavel?** Sim, sempre que um driver crashar em reflection de recurso:
  mover a informacao para uma tabela alimentada pelo host.
- **Risco**: tabela e visao do host; se um shader criar a view dinamicamente
  sem passar por `keep_with_view`, a contagem fica 0 (o proprio fork tem
  `fa042f6` "Raw-viewed structured buffers keep their size query" para o caso
  oposto).

### F-05 - Passes de limpeza no bitcode antes do driver (`ae75a66` + `opt.rs`)

- **O que estava errado**: o lowering emite uma instrucao por instrucao do
  console, sem nada entre ele e o compilador do driver; programas enormes
  (upscaler com 10.000 instrucoes, ray tracing) faziam o compilador nao terminar.
- **Por que funciona**: cinco passes **exatos** (DCE, fold/identidades, CSE de
  instrucoes sem efeito, fatos de branch, CSE de leituras dentro do bloco), cada
  um preservando valores e efeitos para toda entrada; resultado: o compute
  `39f0e9aeb156a61c` compila em 36 s onde antes nunca terminava.
- **Dependencias**: `emit::shader_opt()` (`VICTORY_SHADER_OPT`, mascara de bits)
  e a **chave do cache de shader** (mudar os passes invalida o cache - e a origem
  provavel de D-15).
- **Reutilizavel?** Sim: 2.155 linhas de `opt.rs` vieram do fork `ba8697aa`
  (GPL-3.0-or-later) e foram adaptadas a outro modelo de modulo (arrays locais,
  doubles, joins de registrador que ninguem escreve - que **nao** podem virar
  `undef`, senao o validador recusa).
- **Risco**: os passes sao exatos por contrato; qualquer pass novo tem de ser
  provado, e o validador da Microsoft foi usado como rede (25.623 shaders do
  pack passam).

### F-06 - Guarda de memoria por VEH endurecida (`2b6adbb`, `e7e6c00`, `579a8d9`, `ae90937`)

- **O que estava errado**: tres falhas independentes no mesmo mecanismo
  (buracos nao mapeados, runs que cruzam views, escritas assincronas do kernel) e
  uma premissa errada (uma view por pagina).
- **Por que funciona**: o estado do guard passa a ser explicito e completo -
  `holes` (nao mapeado), `protected`/`clean` (read-only e sem escrita), `pins`
  (kernel pode escrever por 2 s), `aliased` (views da mesma pagina), epocas por
  regiao para invalidar copias.
- **Dependencias**: VEH, `VirtualProtect`, `VirtualQuery`, mapeamento de
  secoes do `xmem`, `shadow` (copias) e `resource` (views).
- **Reutilizavel?** Sim para qualquer emulacao de memoria de console com copia
  no host; e a peca mais delicada do fork.
- **Risco**: cada falha dessa classe se manifesta como "o titulo para" sem
  stack util; o fork gastou ~6 commits so nisso em 24 h.

### F-07 - Mapear a "stretch" do titulo num endereco proprio (`0434b3a`)

- **O que estava errado**: o titulo mapeia heaps de streaming em views de 64 KiB,
  cada uma sua alocacao; o host nao consegue abrir isso como um heap unico, e
  cada bindless custava copia.
- **Por que funciona**: as paginas sao **contiguas na secao**; mapear a mesma
  secao de novo no nosso espaco de enderecos cria uma janela contigua e o heap do
  host e aberto ali - zero copia. 33 janelas por frame: copy-back 36 -> 12 ms,
  frame 227-266 -> 202-216 ms.
- **Dependencias**: conhecimento do alocador do `xmem` (views de 64 KiB), secao
  subjacente, `VICTORY_STRETCH=0` como escape.
- **Reutilizavel?** Sim para qualquer titulo que fracione heaps; exige que a
  contiguidade seja **verificada**, nao presumida (`78028ad` mostra o custo de
  errar: leitura 2,3 GB alem do buffer, page fault).

### F-08 - Contencao do compilador do driver (`95e935d`, `0d2f6a6`, `7263339`)

- **O que estava errado**: um pipeline problematico derrubava a execucao inteira
  (crash do compilador) ou a travava por minutos (compilacao sem fim, 16 GB).
- **Por que funciona**: (a) VEH dedicado que registra o nome do pipeline em
  `crashed.txt` e o pula nas proximas execucoes; (b) detector de compilacao sem
  fim por tempo **e** por crescimento de memoria, com `SuspendThread` apenas
  quando o RIP esta no modulo do driver (nunca em ntdll/ucrtbase, cujos locks a
  thread suspensa poderia segurar); (c) workers perdidos sao substituidos e
  ninguem espera por eles.
- **Dependencias**: nomes estaveis de pipeline (hash do codigo traduzido + root
  signature + estado), `pipelines/crashed.txt` no cache, `GetThreadContext`,
  `GetModuleHandleExW`.
- **Reutilizavel?** Sim, e uma das partes mais uteis para qualquer tradutor
  GFX10->DXIL em AMD.
- **Risco**: `crashed.txt` e estado persistente; um criterio de timeout mal
  calibrado (20 s/3 GiB) exclui pipelines legitimos **para sempre** (foi o que
  `7263339` corrigiu).

### F-09 - Reflexos contidos na luz ambiente (`c3bd561`, `REFLECTED = CS_UpdateHistory`)

- **O que estava errado**: sem rays, todo material glossy refletia o ceu aberto,
  inclusive em interiores; pisos de madeira, balcao e vidros ganhavam um brilho
  branco 5-10x mais claro que a sala.
- **Por que funciona**: depois do ultimo passe que escreve reflexos
  (`CS_UpdateHistory`), o valor e limitado a uma fracao da luz ambiente
  (`VICTORY_AMBIENT_REFLECT`, 0.5 default), e um decimo numero no arquivo de
  ambiente da um piso para reflexos escuros (`LEAST`).
- **Reutilizavel?** Como padrao de "conter o que o RT deveria ocluir": identificar
  o ultimo produtor do buffer e aplicar um limite fisico plausivel.


===== Belobug-AMD Section I =====
## I. Conhecimento reutilizavel

Prioridade para o que e **exclusivo deste fork** (nao existe no upstream) e
aproveitavel num repositorio unificado.

### I-01 - Substituicao do passe de luz indireta (EXCLUSIVO)

| Campo | Conteudo |
|---|---|
| Problema resolvido | RT indireto ausente -> saida invalida do resolve -> magenta/blocos/preto |
| Implementacao | hook por prefixo de nome do programa; reescreve a tabela de descritores; compute HLSL proprio (`D3DCompile` em runtime) que escreve constante tingida em R9G9B9E5; sombreamento por profundidade; nivel seguindo o ceu (`gain*mean^power+least`); piso de reflexos |
| Origem | este fork, modulo novo |
| Commits | `0603123`, `4f45ab8`, `cd9f78c`, `c3bd561`, `e48eb83`, `705a2d0`, `4f62c2a` |
| Arquivos | `crates/victory-gpu/src/ambient.rs` (592 linhas), `draw.rs`, `shader_cache.rs`, `victory-shader/src/native.rs` |
| Dependencias | nome/indice do programa no titulo; `HostList` para emitir o compute; cache de shader |
| Conflitos | qualquer outro fork que tambem reescreva `CS_ScreenProbes_*`; `VICTORY_AMBIENT*` pode colidir com `VIToriaBr`/`AvatarManz`, que tambem tem `ambient.rs` |
| Riscos | constante global sem oclusao; nao substitui RT; nomes e offsets sao do titulo |
| Recomendacao | portar como modulo isolado com a lista de programas/offsets em tabela de configuracao, nao hardcoded; manter o arquivo de ajuste a quente |

### I-02 - Leituras de quad em pixel shader (EXCLUSIVO, 17 linhas)

Problema: derivadas por leitura de lane devolvem 0 de helper lanes na AMD.
Implementacao: `helpers_read(quad) = quad && self.s.pixel` e uso de `quad_pick`
em `deriv`/`ds_swizzle`-like. Commit `03629f3`; arquivo
`victory-shader/src/emit/lower.rs`.
Dependencias: `quad_pick` existente. Conflitos: qualquer fork que reescreva
`lower.rs` (todos os cinco divergem nesse arquivo). Riscos: custo de quad reads
em hardware onde helper lane nao e barato; upstream so faz depois de `discard`.
Recomendacao: **portar primeiro**, e o melhor custo/beneficio do repositorio.

### I-03 - Hoisting de emulacao por comando (EXCLUSIVO no desenho, upstream na ideia)

Problema: emulacao de `ExecuteIndirect` (clamp) custando um dispatch + 3
barreiras por draw. Implementacao: `Hoist { clamps, into, writes }`, lista
cortada no primeiro indireto, buffers lidos por offset, invalidacao por
`writes`, modos 0-7 para A/B, modo 7 (sequencial) como default por causa do
flicker. Commits `ccab973`, `afca189`, `918ab03`, `76387c2`, `684a9b5`.
Arquivos `draw.rs`, `indirect.rs`, `list.rs`, `host.rs`.
Dependencias: `set_budget`/`indirect_scratch` por lista; `keep_until_run`.
Conflitos: PR #242 upstream (`1f7f7d2`) reescreve o mesmo `record_clamp`.
Riscos: invalidacao incompleta = descritores/argumentos errados (flicker).
Recomendacao: portar com o teste de invalidacao explicito.

### I-04 - Contagem de elementos pela tabela do host (EXCLUSIVO)

Problema: size query crasha o compilador AMD. Implementacao: `COUNTS_AT =
OWN_SLOTS`, `StrideTable` dimensionada com `COUNTS_AT + len`, `view_count()`
para SRV/UAV buffer, leitura pelos shaders. Commit `1503444` (+ `1ebf29d`,
`fa042f6`). Contrato entre `victory-shader` e `victory-gpu` - portar os dois
lados juntos. Riscos: manter contagem sincronizada em todo caminho de criacao
de view.

### I-05 - Passes de limpeza de bitcode (de TERCEIRO, adaptado aqui)

Origem: fork `ba8697aa` (GPL-3.0-or-later), trazido em `ae75a66` como
`victory-shader/src/emit/bitcode/opt.rs` (2.155 linhas + testes). Cinco passes
exatos + trace (`VICTORY_SHADER_OPT_TRACE`). Ganho medido: compute
`39f0e9aeb156a61c` compila em 36 s (antes nunca terminava). Dependencias: modelo
de modulo (`Op`, `Attr`, `for_each_operand`, `successors`) e a chave do cache.
Conflitos: `DexNom` e `VItoriaBr` tambem tem `bitcode/opt.rs` (mesma origem,
adaptacoes diferentes) - unificar exige escolher **um** modelo de modulo.
Riscos: um pass que transforme join em `undef` faz o validador recusar
programas (aconteceu com seis programas do mundo, corrigido no proprio commit).

### I-06 - Guarda de memoria por VEH completa (EXCLUSIVO na completude)

Problema: copia no host de memoria de console escrita por CPU e por GPU.
Implementacao: `Guards { protected, clean, holes, aliased, pins }` + epocas por
regiao + `writing()` com pins de 2 s + guarda de todas as views de uma pagina
fisica + devolucao bloco a bloco. Commits `2b6adbb`, `a873b24`, `1c7231d`,
`e7e6c00`, `579a8d9`, `ae90937`, `f2cc100`, `4c1766c`. Arquivo `watch.rs`.
Riscos: e a area com mais modos de falha (o titulo simplesmente para); qualquer
port precisa dos testes de regiao/alias/pin.

### I-07 - Stretch mapping para heaps fragmentados (EXCLUSIVO)

Problema: views de 64 KiB, uma alocacao cada, nao abrem como heap unico.
Implementacao: mapear a mesma secao de novo num endereco proprio e abrir o heap
ali; 36 -> 12 ms de copy-back. Commit `0434b3a`; `host.rs`/`memory.rs`.
Riscos: presumir contiguidade sem verificar leva a leitura fora do buffer
(`78028ad`).

### I-08 - Contencao de compilacao do driver (EXCLUSIVO na combinacao)

`pipelines/crashed.txt` + VEH + detector de compilacao sem fim (tempo **e**
memoria) + `SuspendThread` so no modulo do driver + substituicao de workers +
workers proprios para screen passes (`18e57db`). Commits `1b0c6b5`, `2655edb`,
`95e935d`, `0d2f6a6`, `7263339`, `18e57db`. Riscos: criterio de timeout errado
exclui pipelines legitimos (H-04).

### I-09 - Diagnostico que pagou por si

- `VICTORY_GPU_TIMING` (tempo de GPU por tipo de comando e por pipeline) foi o
  que revelou os 225 ms (`ccab973`).
- Hash DXIL por shader, o mesmo que o **Radeon GPU Detective** usa para nomear um
  shader em voo (README).
- `VICTORY_SHADER_PATCH` (muda uma palavra do codigo da maquina antes de
  traduzir) e `VICTORY_SHADER_SWAP` (troca containers por arquivo) - permitem
  isolar um shader culpado sem rebuild.
- `VICTORY_SHADER_OPT_TRACE` (quais chamadas o DCE descarta).
- `placed_census` (`c28201f`): quantas texturas colocadas existem, quantos bytes
  do titulo cobrem, quantos enderecos tem varias, quantas estao sobre memoria que
  o titulo nao tem mais.
- `VICTORY_HOIST_FILE`, `VICTORY_AMBIENT_FILE`: ajuste ao vivo de modulo em jogo.
Recomendacao: portar o conjunto inteiro para o repo unificado; e o que permitiu
achar em uma hora o que contadores proprios nao acharam em um dia.

### I-10 - Descartado/nao recomendado

- `RwLock` na tabela de views (`ff920f2`): correta, mas **sem ganho** de frame
  time - o gargalo e a thread que submete; nao portar esperando desempenho.
- Os oito PRs de romainhedouin (`13d6b73`, `ed273ef`, `684a9b5`, `f53ae3d`,
  `58655f9`, `0145ca7`, `a1ef2dd`, `127830e`): "None of the eight moved the frame
  time measurably here; nothing broke" - portar por higiene, nao por fps.
- Thin LTO (`a23d1b4`): sem medicao de ganho no documento.


===== DexNom Section F =====
## F. Correcoes importantes

### F-1 - Bypass de blending em alvo inteiro (`ddb7332`)

**O que estava errado.** Estado de blend do console repassado ao D3D12 sem considerar formatos de alvo inteiros; o PSO era
recusado na criacao. **Por que a correcao funciona.** O console, para superficie inteira, ignora o blender; o D3D12 **valida** a
combinacao na criacao. Desligar `BlendEnable` apenas nos alvos inteiros reproduz o console e satisfaz o validador. O detalhe que
faz a diferenca e a **expansao do estado compartilhado** antes de sobrescrever um alvo: sem ela, `IndependentBlendEnable = false`
faria o D3D12 ler o slot 0 para todos, e o write mask dos outros alvos seria perdido. **Dependencias.** Nenhuma externa; so o
estado de pipeline. **Reutilizavel?** Sim, integralmente, em qualquer camada que traduza estado de blend de console para D3D12.
**Risco de adaptacao.** A lista de formatos inteiros precisa ser completa para o seu conjunto de formatos (aqui: 20 formatos
`UINT`/`SINT`, sem os `_UNORM`/`_FLOAT`).

### F-2 - Sampler por phi com duas amostragens e selecao no edge (`ddb7332`)

**O que estava errado.** Um sampler vindo de um phi de duas constantes era "nao rastreado" e o shader era recusado. **Por que a
correcao funciona.** Amostrar duas vezes com as **mesmas derivadas** e escolher o resultado resolve o caso porque a escolha do
sampler e uniforme (mesmo edge para toda a wave); o custo e uma amostra extra, nao uma reestruturacao de CFG. O caso de um
predecessor nao finalizado e tratado separadamente (usa o sampler daquele lado), o que evita um phi com aresta indefinida.
**Dependencias.** Exige que `Val::I32` de todas as saidas seja reconstruivel (`i32_of`), o que limita a forma das instrucoes
tratadas. **Reutilizavel?** Sim: o padrao "duplicar a operacao e selecionar no join" serve para qualquer operando uniforme vindo
de phi. **Risco.** Dobra o custo da amostragem nesses shaders; para shaders de particula/UI pode ser irrelevante, para G-buffer
nao.

### F-3 - Escrita de convidado rastreada (`bc3cd4b`, `writeback.rs`)

**O que estava errado.** Declarar toda janela mapeada como escrita forcava snapshot + comparacao de 12,8 GB por frame e 2 s de
espera. **Por que a correcao funciona.** Duas coisas separadas:
(1) *Quem escreveu* - o tradutor sabe, por construcao, se um store vai para memoria de convidado ou para UAV do host; a
informacao e propagada para o host.
(2) *Quem e o dono dos bytes* - `writeback.rs` mantem intervalos disjuntos com o numero da submissao mais recente ja iniciada,
porque **uma fence pode completar depois de o titulo desmapear e reusar o endereco**. Sem isso, o copy-back escreveria em memoria
que ja pertence a outro objeto. **Dependencias.** `STARTED`/`PUBLISHED`/`LAST_CHANGE` com `Release`/`Acquire`; a publicacao tem de
terminar antes da libertacao do intervalo. **Reutilizavel?** Sim, e um pattern de **writeback com posse temporal** aplicavel a
qualquer camada de memoria unificada emulada sobre memoria discreta. **Risco.** Se a ordenacao fence -> merge mudar, a garantia
some silenciosamente; o modulo tem 321 linhas e merece teste de concorrencia proprio (nao ha teste de corrida nele).

### F-4 - Bitmap de paginas marcadas pelo tradutor (`cd94d35`)

**O que estava errado.** Comparar 2,8-4,5 GB por frame para descobrir que 98% nao mudou. **Por que a correcao funciona.** O
tradutor emite, para cada store/atomico **atraves de view de buffer nao ordenada**, um bit por pagina de 64 KiB numa bitmap; o
host compara so as paginas marcadas. Uma tabela de marcas por slot vive no host view heap (`marks`, dois dwords por slot,
`0xFFFF...` = sem marca). A pagina que o titulo escreve e que os shaders tambem podem escrever guarda os bytes de antes (salvos
pelo guard na primeira escrita), preservando **os dois escritores**. **Dependencias.** Requer `emit::Options::view_marks` e que o
cache de shader seja invalidado quando a opcao muda (o cache e chaveado pelo tradutor, `c47b529`). **Reutilizavel?** Sim - e a
ideia mais transferivel do repositorio: *nao compare o que ninguem escreveu; faca o tradutor dizer o que escreveu*.

### F-5 - `OpenExistingHeapFromAddress` para memoria do titulo (`inplace.rs`)

**O que estava errado.** Toda leitura/escrita de memoria do titulo passava por uma copia host, com sincronizacao. **Por que a
correcao funciona (quando funciona).** `inplace.rs` documenta, com medicao, as regras reais do Direct3D neste PC: o
`OpenExistingHeapFromAddress` aceita **so a base de uma alocacao `VirtualAlloc` inteira**, com todas as paginas comprometidas e
uma unica protecao; abrir trava todas as paginas na memoria do PC (256 MiB nunca tocados = 70 ms e 256 MB de working set). A
variante 1 (`ID3D12Device13`) aceita qualquer parte comprometida, inclusive views sobrepostas; e
`OpenExistingHeapFromFileMapping` aceita `SEC_COMMIT` e recusa `SEC_RESERVE` (que e como `xmem` faz o pool do titulo hoje).
**Reutilizavel?** Sim - este arquivo e um **estudo de caso documentado** de zero-copy de memoria de convidado em D3D12.
**Risco.** A elegibilidade depende do driver e do arranjo de `xmem`; o proprio modulo traz um probe
(`VICTORY_INPLACE_PROBE`) e um censo - ou seja, o autor nao presumiu, mediu.

### F-6 - Regra de seguranca do builder de BVH (`5f4c3df`, `pipeline.rs`)

**O que estava errado.** Um builder parcialmente funcional escrevia limites invalidos na memoria do titulo e **crashava o jogo**.
**Por que a correcao funciona.** `builder_runs()` so devolve `true` se **todo** pipeline do builder que o titulo criou tem
pipeline de host; qualquer queda (`builder_off`) desliga **todos** os estagios de uma vez. Assim o conjunto nunca executa meio
certo. `VICTORY_BVH_QUARANTINE=1` mantem os stores do builder fora da memoria do titulo para um primeiro teste.
**Reutilizavel?** Sim, como padrao: **atomicidade de conjunto** para subsistemas cujo funcionamento parcial e pior que a ausencia.

### F-7 - `subresource_len` para staging (D-10) - a correcao que nao sobreviveu

Vale registrar por si: a correcao estava certa (clampar o slice ao `total - offset`), tinha teste (`subresource_len(0,256,4,1,784)
== 784`), e mesmo assim **nao esta no HEAD**. E o exemplo mais claro de por que "existe um fix no historico" nao equivale a
"existe um fix no produto".


===== DexNom Section I =====
## I. Conhecimento reutilizavel

> Foco: o que e **exclusivo deste fork** (ausente na base e nos outros forks segundo `_fatos/FORK_DIVERGENCIA.md`) e vale levar
> para um repositorio unificado. Para cada item: problema, implementacao, arquivos, dependencias, conflitos, risco, recomendacao.

### I-1 - Marca de escrita emitida pelo tradutor (`view_marks`) + bitmap por pagina no host
- **Problema resolvido.** Copy-back/sincronizacao de GPU baseada em "ranges declarados como escritos" custa GB/frame. Aqui:
  2,8-4,5 GB/frame, 98% inalterado, 0,45-0,7 s de um frame de 1,5-1,7 s (`cd94d35`).
- **Implementacao.** `emit::Options { view_marks: true }` faz o emissor marcar, por store/atomico **atraves de view de buffer nao
  ordenada**, um bit por pagina de 64 KiB numa bitmap; o host mantem uma **tabela de marcas por slot** no view heap (dois dwords
  por slot; `VIEW_MARK_NONE` = sem marca, inicializado `0xFF`); cada copia host rastreada e dona de um run de bits; apos a
  submissao, so as paginas marcadas sao comparadas e escritas de volta. Pagina escrita pelos dois lados guarda os bytes de antes.
- **Arquivos.** `crates/victory-shader/src/emit/{mod.rs,lower.rs,shader.rs}`, `crates/victory-gpu/src/{shadow.rs,watch.rs,draw.rs,
  descriptor/host.rs,copystat.rs,shader_cache.rs}`.
- **Dependencias.** `emit::Options` tem de entrar na chave do cache de shader (senao um shader traduzido sem marcas e reusado);
  contadores de diagnostico (`C::MarkedPages`, `MarkedBytes`, `MarkedUs`, `MarkedKept`, `SavedPages`).
- **Conflitos possiveis.** Com `bindless`/`external` da base (que aqui nao existem) a enumeracao de views muda; com qualquer
  caminho que escreva em buffer **sem** view (descritor direto) a marca nao sai - o codigo cai no snapshot, o que e seguro mas
  silencioso.
- **Risco.** Um `store` que o tradutor nao reconheca como escrita gera **perda de bytes** (nao corrupcao), porque a pagina nao e
  comparada. Mitigacao correta: manter o caminho de snapshot para copias nao rastreadas (o codigo faz isso).
- **Recomendacao.** **Adotar**, e o item de maior valor da lista. Comecar pelos contadores (`MarkedKept`/`SavedPages`) para
  detectar perda silenciosa.

### I-2 - Posse temporal dos bytes do convidado durante escritas em voo (`writeback.rs`)
- **Problema resolvido.** Uma fence pode completar **depois** de o titulo desmapear e reusar o endereco; o copy-back escreveria
  em memoria de outro objeto.
- **Implementacao.** `BTreeMap` de intervalos disjuntos com o numero da submissao mais recente ja iniciada; `STARTED` (`Release`),
  `PUBLISHED` (`fetch_max`), `LAST_CHANGE`; o intervalo so e libertado depois de a publicacao terminar.
- **Arquivos.** `crates/victory-gpu/src/writeback.rs` (321 linhas, novo em `bc3cd4b`).
- **Dependencias.** Ordem fence -> merge -> publicacao na thread de submissao (o comentario de cabecalho fixa essa premissa).
- **Risco.** Nao ha teste de concorrencia no modulo; a garantia e um argumento de ordenacao. Se outro fork paralelizar o merge,
  quebra.
- **Recomendacao.** **Adotar** o conceito (ownership por intervalo + numero de submissao) mesmo que a implementacao seja
  reescrita; escrever um teste com fence atrasada e reuso de endereco.

### I-3 - Memoria do titulo como memoria da placa (`inplace.rs`)
- **Problema resolvido.** Copia host no caminho de toda leitura/escrita de shader.
- **Implementacao.** Tres aberturas D3D12 documentadas com medicao: `OpenExistingHeapFromAddress` (so base de alocacao inteira,
  todas as paginas comprometidas, uma protecao; 256 MiB = 70 ms + 256 MB de working set), `OpenExistingHeapFromAddress1`
  (`ID3D12Device13`, qualquer parte comprometida, views sobrepostas), `OpenExistingHeapFromFileMapping` (aceita `SEC_COMMIT`,
  recusa `SEC_RESERVE`). Inclui probe (`VICTORY_INPLACE_PROBE`) e censo do que seria elegivel.
- **Arquivos.** `crates/victory-gpu/src/inplace.rs`, `memory.rs`.
- **Conflitos.** O pool do titulo e feito por `xmem` com `SEC_RESERVE` - justamente o que
  `OpenExistingHeapFromFileMapping` recusa. Unificar exige mudar `xmem` ou usar a via de endereco.
- **Recomendacao.** **Adotar como referencia medida**; o valor imediato e o texto (as regras do runtime/D3D12), que evita semanas
  de tentativa e erro. Validar no driver alvo, nao no WARP.

### I-4 - `texback`: textura que o shader escreve e a CPU do titulo le (`texback.rs`)
- **Problema resolvido.** No console CPU e GPU compartilham memoria: um passe de compute escreve um height map e o codigo de CPU
  do titulo o amostra. No PC, a textura fica na copia host e a CPU le memoria que ninguem escreveu. Sintoma observado: **os barcos
  afundavam** (`run rw1`, `VICTORY_READ_WATCH=1`: ~30 leituras do titulo a esses dois tipos).
- **Implementacao.** Para os tipos listados em `VICTORY_TEXTURE_BACK` (`<w>x<h>f<format>`), uma lista cujos shaders escrevem a
  textura copia para um read-back buffer ao fechar e, terminada a lista, **retila** os texels no layout do console dentro da
  memoria do titulo.
- **Arquivos.** `crates/victory-gpu/src/texback.rs` (novo neste fork).
- **Limitacao declarada.** E por **tipo**, nao por textura: texturas do tipo que o titulo nunca le tambem sao copiadas (~1 MB por
  lista). E "a copia mostra o que a ultima escrita da lista deixou": uma leitura do titulo no meio ve o frame anterior.
- **Recomendacao.** **Adotar** - e um caso de "shared memory semantics" que quase todo emulador de console esquece; o padrao
  (detectar por read-watch, corrigir por tipo, documentar o atraso) e reutilizavel.

### I-5 - `material_demand`: leitura antecipada de descritores guiada pelo proprio material
- **Problema resolvido.** Shader nativo indexa textura por indice vindo direto do registro de material; o heap pass sobe as
  texturas depois, e o objeto aparece escuro por varios frames (a "waterfront house" levou 18 s para ganhar detalhe,
  `BENCHMARK.md`).
- **Implementacao.** Le **o mesmo buffer de GPU que o shader** le, em ordem de comando, e agenda as texturas indicadas; o heap pass
  normal continua dono de validacao, upload e retry. `LIMIT = 8`, `MAX_AGE = 4`, `TABLE_DWORDS = 688`, `SLOT_BYTES = 32`; opt-in
  por `VICTORY_MATERIAL_TEXTURE_DEMAND=1`.
- **Arquivos.** `crates/victory-gpu/src/material_demand.rs` (novo em `b8ff22e`), `descriptor/host.rs`, `draw.rs`, `shadow.rs`.
- **Risco.** Exige conhecer o layout exato do registro de material (688 dwords, slots de 32 bytes) - e **especifico do titulo**.
  Se o layout mudar, agenda lixo.
- **Recomendacao.** **Adotar com isolamento**: manter atras de switch e por titulo, como esta. O conceito (prefetch de recurso
  dirigido pelo dado que o shader vai ler) e generico.

### I-6 - Emulacao das instrucoes de BVH do console em DXIL + referencia Rust bit-a-bit
- **Problema resolvido.** O jogo nao usa API de RT; traz BVH no formato do console e usa `image_bvh64_intersect_ray` /
  `image_bvh_intersect_ray`. Mapear para DXR e "nao pratico" (a camada teria de conhecer geometria que o titulo nunca descreve) -
  a justificativa esta escrita em `docs/fork-ray-tracing.md`.
- **Implementacao.** `bvh.rs` e a **referencia em Rust** (slab test, rede de ordenacao, teste agua-estanque de raio/triangulo);
  `emit/intersect.rs` emite DXIL equivalente; **311 casos de raio/no** rodam na GPU e sao comparados bit a bit com a referencia.
  `packed_mask.rs`/`own_bits.rs`/`wave64_tests.rs` tratam mascaras de lane como numeros e wave64 sobre wave32.
- **Arquivos.** `crates/victory-shader/src/bvh.rs`, `emit/intersect.rs`, `emit/intersect_tests.rs`, `emit/typed_views.rs`,
  `emit/guest_address.rs`.
- **Conflitos.** A base tem `emit/lower/bvh.rs` e `emit/bvh_tests.rs` com outra estrutura; unificar exige escolher um dos dois
  (o deste fork tem a distincao de residencia de pagina, essencial com page table).
- **Recomendacao.** **Adotar `bvh.rs` como referencia de teste**, independentemente da implementacao escolhida. O padrao
  "referencia Rust + comparacao bit-a-bit na GPU" e o que torna essa emulacao auditavel.

### I-7 - Regra de atomicidade de conjunto para subsistema que "funciona pela metade"
- **Problema resolvido.** Builder parcial escrevia limites invalidos e crashava o titulo.
- **Implementacao.** `builder_runs()` exige host pipeline para **todos** os pipelines do builder; `builder_off(why)` desliga tudo;
  `VICTORY_BVH_BUILDER=1` liga, `VICTORY_BVH_QUARANTINE=1` mantem stores fora da memoria do titulo.
- **Arquivos.** `crates/victory-gpu/src/pipeline.rs`.
- **Recomendacao.** **Adotar.** E a defesa certa para qualquer tradutor cujo parcial seja pior que o ausente.

### I-8 - `WAVE_OPS`/quad nativo para pixel e mesh, com atalho por padrao
- **Problema resolvido.** Operacoes de quad em pixel shader precisam ser quad-nativeis (incluindo *helper lanes* de borda).
- **Implementacao.** `use_quad = quad && (pixel || mesh)`; `quad_pick(x, src, pattern)` com identidade para `0xe4`, um
  `quadReadLaneAt` para `0x00/0x55/0xaa/0xff`, `quadOp` para `0xb1/0x4e/0x1b`; DPP8 so quad-local se cada destino fica no proprio
  quad.
- **Arquivos.** `crates/victory-shader/src/emit/lower.rs`.
- **Recomendacao.** **Adotar**; o atalho por padrao e o que viabiliza desempenho em shaders que usam DPP em todo lugar.

### I-9 - Deteccao de adaptador de hardware por dois sinais
- **Problema resolvido.** CI sem GPU rodava testes "hardware-only" no WARP.
- **Implementacao.** `hardware_adapter()`: percorre adaptadores e aceita o primeiro **nao** `DXGI_ADAPTER_FLAG_SOFTWARE` **e** com
  `DedicatedVideoMemory > 0`; sem nenhum, `Err("no hardware adapter")` -> skip conhecido.
- **Arquivos.** hoje so `crates/victory-shader/src/emit/host.rs` (o arquivo de teste que a usava foi apagado).
- **Recomendacao.** **Adotar em qualquer CI de GPU.** O sinal "flag software" sozinho nao basta - isso esta provado no CI deste
  repositorio (`ccfb029`).

### I-10 - Convencao de documentar compromissos no codigo com `shortcut:`
- **O que e.** 44 arquivos marcam a decisao consciente com `// shortcut: ...`, incluindo o custo ("BC1 ~30-60 MB/s"), o limite
  ("descriptors past the host's limit are left out") e o que fazer ("add them when a title uses"). Sem `TODO`/`FIXME`.
- **Por que vale.** Num codebase de emulacao, "nao implementado" e "implementado com atalho" sao estados diferentes e ambos
  precisam ser auditaveis. `git grep shortcut:` da um mapa de risco em um comando.
- **Recomendacao.** **Adotar como convencao** e indexar num documento unificado (o fork nao tem indice; so o grep).

### I-11 - `snapshot/` e `backup/` como refs de checkpoint nomeadas
`origin/backup/main-before-intro-2026-11-25` e `origin/snapshot/intro-tested` documentam, no proprio nome, o antes/depois de uma
operacao de risco. Custo zero, valor alto em arqueologia: permitiu reconstruir que `b8ff22e` foi o "intro testado" e `921d8d3` o
"antes". **Recomendacao:** adotar.

### I-12 - Correcoes de tradutor que valem para a base (nao sao especificas do fork)
Tres dos consertos catalogados atacam codigo **compartilhado com a base**, e nao o overlay privado:

| Correcao | Defeito | Por que serve na base |
|---|---|---|
| `ddb7332` (sampler por phi) | D-02, presente desde `2849477` | `Lower::image` e o mesmo; qualquer titulo com sampler escolhido por desvio uniforme perde os mesmos shaders |
| `76749ce` (mascara wave64 via `s_mov_b32`) | D-03, presente desde `2849477` | `structure.rs` e o mesmo; e o caso de wave64 sobre wave32, que a base tambem enfrenta |
| `921d8d3` (quad/Dpp8) | D-07, presente desde `2849477` | `mesh_quad` e literalmente a mesma linha na base |

- **Conflitos.** `ddb7332` depende de `image_with_sampler` (refatoracao local) e `76749ce` de `move_source`; ambos sao aditivos.
  `921d8d3` mexe em `quad_pick`, cuja assinatura muda (`pattern`), e em `use_quad` - conflito textual garantido com qualquer fork
  que tenha mexido no emissor.
- **Recomendacao.** **Portar estes tres primeiro**, antes de qualquer coisa da lista: sao os itens com melhor relacao
  valor/risco, porque corrigem codigo que a base tambem tem e vem com teste (inclusive um teste **negativo** em D-03).


===== GTA6-Asset-Info Section F =====
## F. Correcoes importantes

**F-1 — Ancora de heading numerado (`4b3beb1`, `README.md:50`).**
Errado: `#how-to-resume` para `## 6.4 How to resume`. Correcao: `#64-how-to-resume`. Funciona porque o slug do GitHub baixa a caixa, remove a pontuacao e transforma espacos em hifens, preservando o prefixo numerico — `6.4` vira `64`. Reutilizavel em qualquer Markdown com headings numerados; e a classe de link que quebra em silencio, porque o renderizador nao avisa. Dependencia: nenhuma. Risco: se o heading for renumerado, a ancora quebra de novo — e um acoplamento manual; heading sem numero + ancora estavel seria mais robusto. Verificacao atual: auditoria dos 154 links relativos do repositorio (caminho + slug) retorna 0 problemas.

**F-2 — Reenquadramento legal sem perda de escopo (`14b4bff`, `LEGAL.md`).**
Errado: o texto juridico descrevia a ferramenta ("SixNG works only on game files from your own copy… It does not download, unlock or decrypt anything"). O repositorio passou a ser so documentacao. Correcao: reescrever o sujeito de "SixNG" para "these notes", preservando as quatro proibicoes (arquivos de jogo, assets extraidos, chaves, material proprietario/NDA) e a nao-afiliacao, e acrescentando uma clausula que faltava: "Short identifiers that appear in them (structure offsets, hash values, flag names, sample asset names) are there to describe the formats, not to reproduce game content" (`LEGAL.md:22-25`). Essa clausula e a correcao mais bem pensada do historico: ela antecipa a objecao de que um doc de RE reproduz conteudo proprietario, e separa identificador de conteudo. Reutilizavel como padrao quando um repo docs-only se separa do codigo. Risco residual: ver H-05.

**F-3 — Lei do header `0x2C` (`structure/01:25-33`).** Errado: `0x2C` = "unknown flags" (`formats/01:20`). Correcao: dois grupos de valores (`0x90F01` para audio/navmeshes/packs/textures/script/restofworld/bvh4; `0x90F02` para levels/data/anim/story000/movies/common/core_bvh4), e no segundo grupo `0x2C = round16(10 x file_count)` exato (2.078 x 10 + 4 = 20.784). Converte um campo "unknown" em predicao testavel, mas so para um dos grupos — o texto e explicito que o primeiro nao segue a lei. Reutilizavel: usar um campo constante por classe como rotulo de variante e mais barato que decodifica-lo.

**F-4 — Largura de indice de osso por tamanho de secao (`formats/07:140-146`).** Errado: assumir u8 porque o format code e `0x00`. Correcao: largura = `(offset da proxima secao − offset desta) / V`; slot 8 tem **2 bytes por vertice** em esqueletos com >255 ossos (corpo de carro high-LOD tem 295); exportar `JOINTS_0` como u16 quando o indice passa de 255; reexportar GLBs antigos. Principio geral: quando codec-code e layout divergem, o layout vence.

**F-5 — Regra dos system streams extras (`formats/02:14-22`).** Errado: parar nos streams do page-map; continuacoes de sistema caiam no lado grafico e deslocavam todos os offsets ("the model has no geometry"). Correcao: anexar o proximo stream enquanto houver >= `max(2, size / 64 KiB)` valores `0x5…` **alinhados a 4** apontando para dentro dele. O texto documenta as duas tentativas: exigir alinhamento 8 e estrito demais (meta resources alcancam a continuacao por ponteiros 4-alinhados), e valores tipo hash puxam streams graficos se o alinhamento nao for filtrado. Heuristica com modo de falha bidirecional explicitado — o melhor exemplo de metodo do corpus.

**F-6 — Mip tail e ordem invertida de mips (`formats/05:74-86`).** Errado: sem regra de tail, os mips pequenos sao impossiveis (compartilham um bloco e nao seguem o passo dos grandes). Correcao: mips do menor para o maior; `max_mips_in_tail` = 8 (blocos de 4 KiB) / 12 (64 KiB); `m = max_mips_in_tail − 1 − k`; `off = m > 6 ? 16 << m : m << 8`; origem por bits pares/impares de `off`. Validado por downsample (erro 0-4 niveis) em BC1/3/4/5/7 em todos os modos.

**F-7 — Recuperacao de mip inferior para BCPack (`formats/05:98-107`).** Errado: textura com mip 0 em BCPack descartada como irrecuperavel. Correcao: chunks sao faixas de bytes, nao texturas, e os mips vao do menor para o maior, entao os mips pequenos frequentemente caem em chunks zlib; exportar o maior mip inteiro fora dos chunks BCPack. Impacto declarado: 14.441 texturas (4,1 %) exportadas em mip inferior; 29.310 (8,3 %) sem nenhum mip legivel. Padrao reutilizavel para qualquer codec opaco armazenado em blocos independentes.

**F-8 — Walk de `PSIN` e causa unica das falhas (`structure/04:29-36`).** Errado: tratar falhas de secao como variantes de formato. Correcao: `tail_length = size − 12` (o tamanho inclui o header de 8 bytes) e a causa real das falhas de walk e o corte de pagina de 64 KiB do container, nao o formato. Reutilizavel: erro recorrente em offsets altos ⇒ suspeitar do container antes do formato.

---


===== GTA6-Asset-Info Section I =====
## I. Conhecimento reutilizavel

- **I-1 — joaat como oraculo de consistencia documental.** Problema resolvido: distinguir "campo desconhecido" de "hash transcrito errado". Implementacao: reimplementar o Jenkins one-at-a-time e recalcular **todo** hash que o documento nomeia; validar o oraculo antes num valor conhecido (`hauler -> 0x5A82F9AE`). Resultado neste corpus: 15 de 16 exatos, 1 falha (D-20), mais 2 hashes nao nomeados reproduzidos (`lightType`, `timeFlags`). Origem: `formats/08:31-33`, `formats/09:29-35`, `formats/15`, `structure/05:50-51`. Dependencias: nenhuma; ~15 linhas. Riscos: falso negativo se o documento usar hash de 64 bits ou outra funcao; colisao de 32 bits e irrelevante para nomes curtos distintos. Adaptacao: qualquer corpus de RE que publique hashes de nomes pode ser auditado assim, e o mesmo teste descobre nomes que o documento nao revelou.
- **I-2 — Hash de struct = joaat do nome da classe, quando a classe e conhecida.** Descoberta desta analise (D-24): 10 de 10 structs nomeadas pelo corpus reproduzem joaat do nome GTA V (`CEntityDef`, `CBaseArchetypeDef`, `CMapData`, `CExtensionDefLightEffect`, `CLightAttrDef`, `CMloInstanceDef`, `CMloArchetypeDef`, `CMloRoomDef`, `CMloPortalDef`, `CMloEntitySet`), enquanto 5 structs novos/nao nomeados nao reproduzem nada. Utilidade: resolve a tabela de structs de meta resource e a tabela de tipos de PSO por dicionario de nomes de classe. Conflito: a regra escrita pelo corpus diz o contrario (`formats/08:34`) — nao seguir a regra escrita, testar.
- **I-3 — Fechamento aritmetico como filtro de leitura.** Problema: separar erro real de impressao. Implementacao: para cada paragrafo com total + parcelas, somar; para cada percentual, dividir; para cada "N de M", subtrair; para cada "N named" com tabela, contar linhas. Neste corpus, das 23 checagens da tabela da secao B, 16 fecham e 7 nao (D-16 a D-20, D-23, D-26). Origem: a regra e do proprio corpus (`structure/00-INDEX.md:27-28`). Risco: somas que legitimamente excedem o total (mascaras de bits, D-18) e cotas compartilhadas (G-05). Recomendacao: rodar antes de usar qualquer numero como especificacao, e nunca "consertar" o total antes de descobrir qual parcela e a unidade errada.
- **I-4 — Cadeia de 64 KiB do RPF9 como causa unica de falhas de parse.** Implementacao (`structure/01:52-58`): um bloco continua no proximo stream **se e somente se** decodificou exatamente 65.536 bytes e o proximo comeca no slot 16-alinhado seguinte; nao ha flag. Aplicacao: walk de `PSIN`, paginas de recurso, streams extras de sistema. Riscos: regioes vazias sao ausentes em vez de padding (`structure/01:58`); archives aninhados exigem varredura de magic a cada 4 KiB (`structure/01:60-65`). Recomendacao: implementar a remontagem antes de qualquer parser de estrutura.
- **I-5 — Largura implicita em streams compactos.** Implementacao: `largura = (offset da proxima secao − offset desta) / V`; nunca confiar so no format code (`formats/07:41,140-146`). Risco: falha silenciosa se `V` estiver errado por 2x. Invariante de checagem: soma das larguras x V = tamanho da secao.
- **I-6 — Projecao por alinhamento + densidade.** Implementacao: F-5. Risco: limiar `max(2, size/64 KiB)` e empirico. Recomendacao: documentar tambem as tentativas rejeitadas (alinhamento 8), como o repositorio fez — e o que torna a regra auditavel.
- **I-7 — Ordem invertida de mips + mip tail (RDNA2 tiled).** Implementacao: F-6/F-7. Dependencia: familia de tiling por descriptor (bits 24-27, `formats/05:59`). Reutilizavel em qualquer extracao de console com blocos de 4/64 KiB; a receita "exportar o maior mip fora do codec opaco" e independente do formato.
- **I-8 — Teste do bit de fronteira para campos mascarados.** D-11 mostra que validar um campo so contra os valores observados nao prova a largura: 357.115 descritores "sem valores desconhecidos" nao distinguem `&0x7F` de `&0xFF` porque o bit 10 nunca aparece. Regra: para cada campo mascarado, verificar se o **bit mais alto declarado** ja foi visto ligado; se nao, a largura e inferencia, nao observacao. Corolario util: um valor unico acima do limite (aqui, formato 157) derruba a mascara estreita sozinho.
- **I-9 — Metodo de auditoria do corpus (o que deu retorno).** Em ordem de retorno por minuto gasto: (1) `git log -1 --format=%h -- <arquivo>` por arquivo, para provar quais arvores pararam de ser tocadas; (2) auditoria mecanica de links + ancoras (slug do GitHub); (3) reimplementacao de hashes e somas contra o texto; (4) busca de **vocabulario divergente** (`confirmed/inferred/unknown` x `OBSERVED/INFERRED/UNKNOWN/DISPUTED`) como detector de camadas escritas por autores diferentes; (5) `grep` de "not decoded" contra `grep` de "decoded" para achar estados obsoletos; (6) verificacao de que o numero prometido no titulo de uma secao aparece na tabela abaixo dele; (7) grep dos numeros que sumiram entre duas versoes do README (`git show <commit>:README.md` x HEAD). Custo total: minutos. Retorno: 28 defeitos, 26 confirmados, 1 ja corrigido.

---


===== OpenScarlett Section F =====
## F. Correcoes importantes

- **F-01 -- `76adeff` (ABI do DirectStorage com `static_assert`).** O valor nao esta em acertar os offsets, e sim em **tornar o erro impossivel de compilar**: `sizeof`/`offsetof` verificados no build. Todo shim que declara struct de console deveria ter esse par de assercoes; sem elas, o desvio so aparece quando um titulo real enfileira I/O. Reutilizavel em qualquer camada que traduza ABI (`dstorage`, `xaudio2`, `gameinput`, `xmem`).
- **F-02 -- `675d9f4` (deteccao de ABI em vez de recusa).** Discutivel como engenharia (ver G-05), mas didatico: mostra que **a alternativa a uma assinatura correta e uma heuristica que pode errar**, e que a decisao precisa ser explicita no codigo. O comentario descreve o chamador real (flags `0x20000001`, struct de 32 bytes nao inicializado) e e a melhor documentacao de ABI do repositorio.
- **F-03 -- `022a8b2` (assincronia de fence com caminho sincrono preservado).** O acerto e nao remover a espera: ela vira `OPENSCARLETT_SYNC_DIAG_DRAIN`/`OPENSCARLETT_SYNC_DEFERRED_WRITES`. Diagnostico de `DEVICE_REMOVED` continua possivel, e o caminho quente deixa de pagar 200 ms por frame. Reutilizavel em qualquer shim que precise de "modo confiavel" e "modo rapido" no mesmo binario.
- **F-04 -- `d71ed46` (nao evictar o que o titulo usa).** Separa budget **sintetico de teste** de budget **real de driver**. A regra "so evictar com override" e a formulacao correta: um limite que voce inventou nao autoriza destruir estado de terceiro.
- **F-05 -- `f7566aa` (traduzir regra de alinhamento entre plataformas).** Xbox 64/256 vs desktop 512/256. O padrao -- detectar o caso ilegal, alinhar em staging e usar a API que aceita granularidade fina (`CopyBufferRegion`) -- vale para qualquer par console/desktop com regras de pitch diferentes.
- **F-06 -- `5d3809b` (contorno de bug de compilador no lowering).** Quando o compilador do host dobra uma expressao para uma forma que o driver recusa, a saida e escolher uma forma que ele nao dobre (laco CAS), nao tentar outra grafia da mesma algebra. O comentario registra driver e versao, o que torna o contorno auditavel.
- **F-07 -- `438fdb0` (teste que aceita duas topologias de ambiente).** Em vez de proibir `C:`, o teste passa a exigir "sem `C:`" **somente quando os binarios estao fora de `C:`** e a comparar com o fallback esperado. E a forma correta de testar uma politica dependente de ambiente sem transformar o ambiente em pre-condicao.
- **F-08 -- `0cbc742` (validar enum antes de entregar ao runtime).** Faixa legal explicita (`1..5`, `10..13`, `33..64`) e remapeamento com log limitado. Um valor invalido entregue a um driver nao produz erro: produz hang, e hang nao tem stack.


===== OpenScarlett Section I =====
## I. Conhecimento reutilizavel

- **I-01 -- Struct de ABI de console: declare e prove com `static_assert`.** `sizeof` e `offsetof` de cada campo, no build, no header do shim. Sem isso, a divergencia so aparece quando um titulo real enfileira I/O, e o sintoma e memoria arbitraria. Arquivos: `include/openscarlett/io/dstorage_abi.h`; commit `76adeff`.
- **I-02 -- Cabecalho de compatibilidade de teste e parte do oraculo.** Se o duplo de teste declara uma vtable/struct menor que a real, a suite valida o shim contra a coisa errada e nao pode falhar. Sincronize o header de teste com o de produto e prefira gerar um do outro. Arquivos: `tests/external_gdk/gdk_compat_headers/xaudio2_xs.h`; commits `59bd45a`, `3cc1984`.
- **I-03 -- Enums de console nao sao enums de desktop.** Valide a faixa antes de entregar ao runtime e remapeie com log limitado; um valor ilegal nao retorna erro, trava o pushbuffer. Arquivos: `command_list_x.cpp`, `device_x.cpp`; commit `0cbc742`.
- **I-04 -- Alinhamento de footprint difere entre console e desktop.** Xbox aceita offset de 64/256 e pitch < 256; desktop exige 512/256. Planeje um caminho de staging por `CopyBufferRegion`, que aceita granularidade de 1 byte. Arquivo: `command_list_x.cpp`; commit `f7566aa`.
- **I-05 -- `condition_variable` de objeto cuja vida termina no despertar: notifique dentro do lock.** "Notificar fora do lock" e otimizacao para objetos que sobrevivem ao waiter; aqui e use-after-free. Arquivo: `src/shims/dstorage_shim.cpp`; commit `a208562`.
- **I-06 -- Nunca chame codigo de terceiro com o proprio mutex tomado.** Atualize o estado, solte, notifique. Arquivo: `src/core/telemetry.cpp`; commits `acbdb7c`, `2b42f72`.
- **I-07 -- Budget sintetico nao autoriza evictar estado de terceiro.** Se o limite foi inventado pelo shim, a resposta a estourar e recusar alocacao ou paginar, nunca `Evict` em recurso vivo. Arquivo: `device_x.cpp`; commit `d71ed46`.
- **I-08 -- Cache de traducao precisa da versao do tradutor na chave.** Um cache de entrada serve bytecode de outra versao do lowering depois de qualquer correcao; a versao precisa ser bumpada no mesmo commit que muda a semantica, e um teste deve forcar a igualdade das duas constantes. Arquivos: `shader_cache.h`, `shader_cache.cpp`; commit `538e904`. Estado: aberto (D-05).
- **I-09 -- Regra de traducao de caminho deve ser uma funcao, nao N blocos.** "Este caminho e virtual?" foi aplicada em `CreateFile`, depois em `GetFileAttributes`/`CreateDirectory`, depois em CRT, depois em `GetFinalPathNameByHandleW`. Cada API nova e um bug. Arquivo: `src/loader/hook_dll.cpp`; commits `990c3ff`, `e7c5f85`, `be0fda1`, `4bc2db4`.
- **I-10 -- Politica de ambiente nao entra no produto nem na assercao.** "Nunca escrever em `C:`" e higiene de uma maquina; virou `ResolveDefaultWorkDirW` e assercao de teste, e quebrou em qualquer host com build em `C:`. Separe "onde eu prefiro escrever" de "o que e correto". Arquivos: `vfs_mounts.cpp`, `test_loader_vfs_config.cpp`; commits `7e2dd9b`, `438fdb0`.
- **I-11 -- Metrica publicada precisa ser medida no mesmo ato em que e publicada.** Ler `LastTest.log` publica o resultado da ultima execucao, nao o da suite; rodar um subconjunto imprime `6/6` no README. Leia a lista de testes registrados no build (ou `ctest -N`) e valide contra o esperado. Arquivo: `tools/generate_status.py`; commit `4af2702`.
- **I-12 -- Skip precisa de codigo dedicado.** Early `return` num teste de hardware conta como `Passed`; sem `SKIP_RETURN_CODE` (ou equivalente), "90/90" nao significa "90 testes exercitaram o produto". Arquivos: `tests/*`, `cmake/build_speedups.cmake`; estado: aberto (D-09).
- **I-13 -- Tempo de parede e oraculo toxico em suite paralela.** Qualquer teste com limite de tempo precisa de `RUN_SERIAL` e isolamento de GPU. Arquivo: `cmake/build_speedups.cmake`; commits `7e2dd9b`, `1ffd939`.
- **I-14 -- Contorno de bug de compilador: mude a forma, nao a grafia.** DXC dobra toda algebra equivalente de `-x`; o caminho e um laco CAS, documentado com driver e versao. Arquivo: `rdna2_isa_mem_img.cpp`; commit `5d3809b`.
- **I-15 -- Injetar `int3` continuado por padrao e uma decisao de produto, nao um detalhe.** Se asserts do convidado sao absorvidos, registre a contagem por execucao e exponha no relatorio; sem isso, "bootou" perde significado diagnostico. Arquivo: `src/loader/hook_dll.cpp`; estado: aberto (G-01).


===== SixNG Section F =====
## F. Correcoes importantes

**F-01 — `sys_need_of`: agrupar streams pelo page-map pointer (`b7fbe3a`).**
O que estava errado: a decisao de "novo recurso" ignorava quanto system page o recurso anterior ainda precisava. Por que a correcao funciona: o ponteiro de page-map (+0x08, `0x5xxxxxxx`) e a unica informacao no proprio fluxo que diz o tamanho do system page; `(pm & 0x0FFF_FFFF) + 8` da o total necessario, e a comparacao `e.usize < sys_need` transforma "parece um recurso novo" em "ainda e a continuacao". Por que e reutilizavel: o mesmo principio (usar o ponteiro interno em vez de heuristica de alinhamento) vale para qualquer formato RAGE com page map. Dependencias: nenhuma alem do proprio `scan.rs`. Risco ao adaptar: assume `pm >> 28 == 5` (ponteiro de sistema); se a build usar outro espaco de endereco, o teste `group_tests` existente protege o comportamento antigo mas nao o novo formato.

**F-02 — `uv0_tangents`: construir o frame do UV com que o mapa e amostrado (`3bfa416`).**
O que estava errado: usar o frame armazenado (UV1) para amostrar um mapa em UV0, com um flip fixo de verde por cima.
Por que funciona: o frame e reconstruido do proprio conjunto de UV usado na amostragem (`dP/du`, `dP/dv` acumulados por triangulo, ortogonalizados contra a normal, `w` derivado do sinal de `cross(n,t)·b`); e o shader deixa de aplicar o flip porque a convencao DirectX agora esta embutida no `w`.
Reutilizavel: sim, para qualquer pipeline que receba tangentes de um DCC/engine com convencao de UV diferente da do consumidor.
Risco: o custo e O(triangulos) na carga e o frame e descartado para vertices sem area de UV (que mantem o frame armazenado — um caso misto).

**F-03 — Ordem de leitura de ponteiro: pool antes de ponteiro real (`38de2e5`).**
O que estava errado: `Meta::ptr` preferia a leitura de ponteiro real; valores como `0x50000003` sao ambiguos por construcao.
Por que funciona: no espaco de valores observado, a interpretacao de pool e a correta para todos os 14.471 valores ambiguos (todos caem num bloco do struct esperado); a ordem inverte o custo do erro. Reutilizavel: e um caso de "desambiguacao por ordem, validada por censo" — o padrao (medir todos os casos ambiguos, nao uma amostra) e o que da confianca.
Risco: se um arquivo futuro usar ponteiro real com offset baixo, ele sera lido como pool; o censo cobre os arquivos atuais.

**F-04 — Invalidacao de cache por versao (`INDEX_VERSION`, `EXPORT_VERSION`, `FORMAT`).**
O projeto tem tres numeros de versao independentes e os sobe sempre que o conteudo/estrutura muda: `INDEX_VERSION` 4 → 5 → 6 → 7 (7 em `d7e9bdc`); `vehcolour::EXPORT_VERSION` 7 → 8 (D-13), e depois um numero por mudanca de `model.json`, com a legenda no proprio codigo (21 = `_COLOR1` no GLB, 22 = `part_patches`, 23 = `sliding_doors`, 24 = slot de cor do pneu nao aplicado, D-15); `vehcolour::FORMAT` 18 → 19 (`27c045c`) → 20 (D-15); `vehicles::FORMAT` 11 → 12 (`ef4e085`). E a defesa sistematica contra o defeito de D-19 (cache velho escondendo conserto de decoder). Reutilizavel: sim — mas o repositorio mostra o limite: `--force` foi necessario **porque** nem todo cache esta coberto por versao (texturas compartilhadas), ver I-03.

**F-05 — Decoder por especificacao em vez de dependencia (`2979c57`).**
Quando a crate de terceiro tem tres desvios da especificacao, o conserto e escrever o decoder. Reutilizavel como decisao: o `bc6h.rs` e pequeno, testavel contra a spec e remove um risco de dependencia. Custou: uma tarde e a obrigacao de reprocessar 234+17 texturas.

**F-06 — Medir a regra depois de otimizar o objetivo (`783eaa4`).**
A licao operacional mais nitida do repositorio: `18bc31c` melhorou a imagem e **piorou** um invariante (no-wrap 221 → 288). O conserto seguinte mediu o invariante de novo e o trouxe a 85. Isso so aconteceu porque cada commit reporta as duas metricas (qualidade e regra) lado a lado. Reutilizavel: sempre reportar a metrica de correcao junto da metrica de qualidade, no mesmo commit.


===== SixNG Section I =====
## I. Conhecimento reutilizavel

**I-01 — Indice de formato binario por carving, com versao e com correcao dirigida por ponteiro interno.**
Problema resolvido: extrair de um container cujo diretorio e cifrado. Implementacao: varrer streams zlib, classificar por cabecalho, agrupar continuacoes por tres sinais (chunk de 64 KiB exato, tipo que nao inicia arquivo, desalinhamento), e — o ponto nao obvio — **estender o grupo enquanto o ponteiro interno de page map do proprio recurso nao estiver coberto** (`sys_need_of`). Repo: SixNG. Commits: `6b68f75`, `b7fbe3a`, `d7e9bdc`. Arquivos: `crates/sixng-core/src/scan.rs`. Dependencias: nenhuma. Riscos ao adaptar: o sinal `pm >> 28 == 5` e especifico do espaco de endereco do console; a heuristica precisa de teste unitario com streams sinteticos (o repositorio tem: `group_tests`). Recomendacao: copiar o padrao (ponteiro interno como fonte de verdade + versao de cache), nao os numeros.

**I-02 — Reconstruir frame tangente do UV de amostragem.**
Problema: tangentes armazenadas por um engine com convencao de UV diferente da do consumidor. Implementacao: acumular `dP/du`, `dP/dv` por triangulo (com sinal do determinante), ortogonalizar contra a normal, derivar `w` do sinal de `cross(n,t)·b`; nao aplicar flip de verde. Repo: SixNG, `3bfa416`, `crates/sixng-gui/src/glb.rs::uv0_tangents`. Riscos: perde o frame para vertices sem area de UV; custo linear em triangulos na carga. Recomendacao: aplicar tambem no **exportador** (e o que falta em G-02).

**I-03 — Invalidacao de cache: versionar o artefato, nao o codigo.**
Problema: conserto de decoder invisivel para quem tem saida antiga. Implementacao observada: `INDEX_VERSION` para o indice, `EXPORT_VERSION`/`FORMAT` para os JSON de export, e a mensagem ao usuario no README ("should be re-exported"). Falha observada: texturas compartilhadas ficaram fora e precisaram de `--force` (`6e23570`). Recomendacao: um unico `CACHE_VERSION` que cubra **todos** os artefatos derivados, com o `--force` como escape e nao como politica.

**I-04 — Ajustar tabela ausente por medicao contra o mip vizinho, com a regra como restricao.**
Problema: BCPack nao guarda as 256 posicoes de preset. Implementacao: ajustar os slots contra o mip seguinte decodificado ("plain reference"), incluindo a asercao de que o resultado e *plausivel* (no-wrap, three-colour sem indice 3, p-bit igual entre endpoints de um subset, `e0 >= e1` em BC4/BC5) como penalidade, e rejeitar slots cuja contribuicao nao se sustenta em held-out. Repo: SixNG, `bc6pack_tables.rs`/`bc7pack_tables.rs`/`bc1pack_tables.rs`/`bc45pack_tables.rs`/`bc3pack_tables.rs`; commits `8eff158`, `063d35e`, `783eaa4`. Riscos: **cada metrica nova pode reverter slots antigos** (H-02) — o conjunto de validacao tem de ser fixo e por textura, nao por par. Recomendacao: guardar o conjunto de validacao e o script de ajuste junto das tabelas (no repositorio os ajustes nao estao versionados — ver L).

**I-05 — Codificar geometria/estado em "desambiguacao por ordem, validada por censo".**
`Meta::ptr` prefere pool a ponteiro real; a escolha e justificada por um censo de **todos** os 14.471 valores ambiguos, nao por amostra (`38de2e5`). Padrao reutilizavel: quando um campo tem duas leituras possiveis, medir todos os casos ambiguos e escolher a ordem que zera os absurdos (posicoes 1e10, escalas inf).

**I-06 — README como especificacao viva com datas e numeros.**
240 alteracoes no README (mais que qualquer arquivo de codigo). Cada linha de estado carrega a data da mudanca e a medicao ("since 2026-11-21", "81 % → 86 %", "before, 22 resources were split"). Reutilizavel como pratica: para projetos de engenharia reversa, o README e o unico lugar onde "o que se sabe" e "quao certo se sabe" cabem juntos; changelog separado perderia a segunda metade.

**I-07 — Chamar as rotinas de cifra do proprio executavel do jogo (branch `claude/rpf9-toc`).**
Problema: TOC cifrado, chaves derivadas em runtime. Implementacao: mapear o PE como imagem (sem executa-lo), prover apenas as rotinas de memoria C que as rotinas usadas importam, **trap em todo outro import**, e chamar `setkey`/`decrypt` de bloco e de stream nos enderecos fixos de uma build identificada por `BUILD_STAMP` + `IMAGE_SIZE`; lista de 24 chaves em `KEY_LIST 0x66e_5900`, com `key_flag` 2. Repo: SixNG, `5433b45`, `crates/sixng-core/src/gamecipher.rs`. Dependencias: Windows x64 + AVX2; uma unica build do jogo. Riscos: offsets fixos quebram em qualquer atualizacao do jogo; executar codigo de terceiro no processo (ainda que sem `CreateProcess`) e uma superficie de ataque; o codigo so existe fora de master (G-01). Recomendacao: adaptar com deteccao de build por assinatura (nao so por stamp) e fallback para carving.


===== TuxBox Section F =====
## F. Correcoes importantes

### F-01 - Thread auxiliar com 64 MiB para criar pipeline (`c679f13`)

**O que estava errado:** criar pipeline em thread de 1 MiB. **Por que falhava:** o vkd3d-proton compila DXIL->SPIR-V na thread chamadora e sua analise de fluxo recursa fundo; shaders traduzidos grandes estouram a pilha dentro do compilador. **Como foi corrigido:** thread *scoped* com pilha reservada de 64 MiB por criacao, com join; fallback para a thread atual se a criacao falhar. **Por que funciona:** a pilha e reservada, nao comprometida, entao o custo e virtual; o join preserva a semantica sincrona exigida pelo D3D12. **Dependencias:** nenhuma alem de `std::thread::scope` (Rust >= 1.63). **Reutilizavel:** sim, para qualquer camada D3D12->Vulkan que compile shader no `Create*PipelineState`. E o tipo de correcao que o autor de uma camada Windows-only nunca precisa fazer.

### F-02 - `-O1 -disable-lifetime-markers` para compute grande (`e9c8fb6`)

**O que estava errado:** usar `-O0` como unica saida para programas que estouram o otimizador. **Por que falhava:** `-O0` quadruplica os blocos de DXIL e o conversor DXIL->SPIR-V do vkd3d-proton explode (364 s). **Como foi corrigido:** `-O1` com *lifetime markers* desligados, mantendo `-O0` como fallback em falha/timeout de 60 s; as flags entram na **chave de cache** (`VARIANTS`) e no *fingerprint* do compilador. **Por que funciona:** o custo do DXC esta em *Jump Threading* alimentado por *lifetime markers*; desligando-os, `-O1` fica barato e o resultado e otimo o bastante para o driver. **Dependencias:** DXC >= 1.9 (release da Microsoft). **Reutilizavel:** sim - e uma receita para "DXIL que o vkd3d-proton nao digere". **Risco:** a chave de cache precisa incluir as flags, senao DXIL antigo e reaproveitado (o proprio commit trata isso).

### F-03 - Esconder `VK_EXT_descriptor_buffer` por GPU, em camada Vulkan (`72766e7`)

**O que estava errado:** desabilitar a extensao para todas as GPUs. **Por que falhava:** em RADV que nao precisa do caminho de descriptor set, isso forcava um caminho que corrompia heap (5 de 6 execucoes). **Como foi corrigido:** a camada `VK_LAYER_TUXBOX_console_cbv` intercepta `vkEnumerateDeviceExtensionProperties` e esconde a extensao apenas quando `minUniformBufferOffsetAlignment > 16 && minStorageBufferOffsetAlignment <= 16`. **Por que funciona:** o criterio e exatamente a condicao em que o contorno de CBV de 16 bytes e necessario; nas demais GPUs o driver fica no caminho nativo. **Reutilizavel:** sim, como padrao "contorno por camada Vulkan com predicado de dispositivo" em vez de variavel de ambiente global.

### F-04 - Nomes listados uma vez para evitar `readdir` do Wine (`4b4c08c`)

**O que estava errado:** abrir nomes que talvez nao existam no cache. **Por que falhava:** o Wine resolve nomes sem diferenciar maiusculas lendo o diretorio inteiro; com ~40 mil arquivos isso domina o tempo de CPU do processo. **Como foi corrigido:** `Names` guarda um `HashSet<String>` por diretorio (lista uma vez, com `OnceLock<Mutex<...>>`), consulta antes de abrir e acrescenta nomes criados pelo proprio processo; a traducao passa a ser lida da cache em vez de copiada para a sessao. **Por que funciona:** elimina a syscall patologica; um arquivo criado depois da listagem so custa uma requisicao, respondida pela cache do host. **Reutilizavel:** sim, para qualquer codigo que abra muitos arquivos em prefixo Wine/Proton, independente de shader.

### F-05 - Presentation check com present repetido (`1b0dfaa`)

**O que estava errado:** assumir que uma unica `PresentX` produz pixels visiveis. **Por que falhava:** no GE-Proton11-14 a imagem pode so aparecer em um present posterior; o teste lia a janela inalterada por 4 s. **Como foi corrigido:** extrair o `submit` em lambda e reapresentar ate 3 vezes, a cada 250 ms, durante a janela de amostragem. **Por que funciona:** reproduz o que um titulo faz (present por frame) sem afrouxar o criterio (continua falhando se nenhum frame chegar). **Reutilizavel:** sim, para qualquer teste de apresentacao em Proton; e um sintoma que nao existe em camada Windows-only.

### F-06 - Xwayland rootful privado com cookie e display livre (`00200ba` + `1b9df5d`)

**O que estava errado:** amostrar a tela pela janela raiz do X do desktop. **Por que falhava:** XWayland rootless recusa `GetImage` (`BadMatch`). **Como foi corrigido:** subir `Xwayland -displayfd -geometry 2560x1440 -noreset -auth <arquivo 0600>` com um `MIT-MAGIC-COOKIE-1` aleatorio em registro `FamilyWild`, trocar `DISPLAY`/`XAUTHORITY` so durante as checagens, escolher numero de display livre por `/tmp/.X<n>-lock` e matar a arvore de processos no timeout. **Por que funciona:** a raiz do servidor privado e legivel, e o isolamento evita colisao com a sessao do usuario. **Reutilizavel:** sim, para qualquer teste de janela em Linux/Wayland. **Risco:** depende de `WAYLAND_DISPLAY` e do binario `Xwayland`; sem eles falha rapido com a causa.

### F-07 - Escrita de valor de fence em vez de timestamp (`e8af9fd`)

**O que estava errado:** tratar `Write64BitValueBottomOfPipeX` como escrita de timestamp e falhar a lista inteira quando um comando nao era traduzivel. **Por que falhava:** as filas do titulo esperam labels arbitrarios; perder a escrita = travar; derrubar a lista = perder tambem a escrita. **Como foi corrigido:** a escrita aceita valor comum e flush, com ordenacao de marker-out; `Recording::skip` isola o comando problematico. **Por que funciona:** a lista continua valida e as dependencias entre filas permanecem satisfeitas. **Reutilizavel:** sim - e a regra "nunca falhar a lista inteira por um comando" que qualquer camada de traducao de command list deveria seguir.

### F-08 - `recording` como estrutura unica com `Segments` (`6bae710`)

**O que estava errado:** `CommandRecording` misturava a lista nativa e o estado do convidado sob um lock; uma espera de fence compute podia substituir a lista nativa no meio da gravacao. **Como foi corrigido:** `Recording` passa a carregar `active`, `list_type`, `compact`, `segments`, `written_ranges` e snapshots de estado grafico; a lista e dividida em segmentos e reproduzida por tipo de fila (COPY/COMPUTE/DIRECT), com fence persistente por fila e notifier compartilhado em vez de polling de 1 ms. **Por que funciona:** a espera no meio da lista vira uma fronteira explicita de segmento, com replay do estado vinculado (root signature, PSO, RTV/DSV snapshots). **Dependencias:** `queue_trace::note` e `retire_fence`. **Reutilizavel:** conceitualmente sim (o padrao "segmentar a lista em esperas"), mas o codigo e muito especifico do ABI Xbox. **Risco:** foi essa reescrita que gerou a regressao de `direct-copy` (`4ba74bc`).


===== TuxBox Section I =====
## I. Conhecimento reutilizavel

### Especifico de Linux/Proton (nao existe em camada Windows-only)

**I-01 - Pilha de 64 MiB para compilar pipeline no vkd3d-proton.** Problema: `virtual_setup_exception stack overflow` em threads de 1 MiB. Implementacao: thread *scoped* com pilha reservada de 64 MiB por `Create*PipelineState`, join. Origem: TuxBox `c679f13`, `runtime/d3d12/src/big_stack.rs`. Dependencias: Rust >= 1.63 (`std::thread::scope`). Conflitos: qualquer codigo que assuma pilha pequena ou que use o stack para passar estado entre threads. Riscos: 64 MiB reservados por thread concorrente (virtual, mas conta no *overcommit*). Recomendacao: adotar sempre que a camada chamar um compilador recursivo (vkd3d-proton, dxil-spirv) dentro de uma API sincrona.

**I-02 - Flags de otimizacao para DXIL que o vkd3d-proton digere.** `-O1 -disable-lifetime-markers` para `cs_6_6`, com `-O0` como fallback e **timeout separado**; a chave de cache e o *fingerprint* do compilador devem incluir as flags. Origem: `e9c8fb6`. Riscos: esquecer as flags na chave faz o cache devolver DXIL de outra configuracao (o commit trata explicitamente). Recomendacao: reutilizavel em qualquer pipeline HLSL->DXIL->SPIR-V.

**I-03 - Esconder `VK_EXT_descriptor_buffer` por predicado de dispositivo.** Camada Vulkan que intercepta `vkEnumerateDeviceExtensionProperties` e esconde a extensao apenas quando `minUniformBufferOffsetAlignment > 16 && minStorageBufferOffsetAlignment <= 16`. Origem: `72766e7`, `tools/reference/cbv-layer/layer.c`. Conflito: forks de Proton que ja tem override proprio (o codigo mantem os dois caminhos). Risco: predicado errado reintroduz corrupcao de heap em RADV. Recomendacao: nunca desabilitar extensao Vulkan globalmente por variavel de ambiente.

**I-04 - Evitar abertura de nomes ausentes em prefixo Wine.** Listar o diretorio uma vez em `HashSet`, abrir so nomes conhecidos, e aceitar que arquivos criados depois custam uma requisicao. Origem: `4b4c08c`. Ganho medido: 3 min 45 s -> 1 min 16 s em um trecho de carregamento. Recomendacao: qualquer cache de arquivos com dezenas de milhares de entradas sob Wine.

**I-05 - Cache de pipeline NVIDIA por prefixo, no formato certo.** `__GL_SHADER_DISK_CACHE_PATH=<prefix>/shadercache`, `__GL_SHADER_DISK_CACHE_SIZE=8GiB`, `__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1`, e os arquivos devem estar em `<path>/GLCache/<device32hex>/<app>`. Origem: `9b18f7c`, `d10b369`, `d439070`. Risco: sobrescrever um caminho definido pelo usuario sem preservar o tamanho faz o driver descartar o bucket no meio do boot.

**I-06 - Teste de apresentacao em Wayland.** Subir `Xwayland` rootful privado (`-displayfd`, cookie `MIT-MAGIC-COOKIE-1` em arquivo 0600, `-noreset`), escolher display livre por `/tmp/.X<n>-lock`, trocar `DISPLAY`/`XAUTHORITY` so no bloco, matar a arvore de processos via `/proc`. Origem: `00200ba`, `1b9df5d`, `project_tuxbox/verify.py`. Risco: depender de `WAYLAND_DISPLAY`/`Xwayland`; sem eles, falhar rapido com causa explicita - nunca amostrar preto silenciosamente.

**I-07 - Present repetido como premissa de teste.** Em Proton, uma `PresentX` isolada pode nao chegar a tela; repetir ate 3 vezes a cada 250 ms mantem o teste util sem afrouxar o criterio. Origem: `1b0dfaa`.

**I-08 - Pre-flight do DXC.** Compilar um shader minimo com o `dxc` selecionado antes do build, e falhar nomeando o release da Microsoft quando o binario da distro estiver quebrado. Origem: `baa315b` (Arch, `LLVM HungOffUses`, SIGILL). Reutilizavel: qualquer projeto que dependa de DXC/SPIRV-Cross/DXC-like empacotado por distro.

**I-09 - Link e toolchain Windows a partir do Linux.** `rustc --print native-static-libs` e a fonte de verdade para `synchronization.lib` (Rust 1.100+); `-Wcast-function-type-mismatch` do clang 19 precisa ser desligado **depois** dos flags por arquivo, senao `/W4` reativa; `rust-version` no workspace evita erro E0658 confuso em toolchain antigo. Origem: `baa315b`, `ca772f1`, `04641a6`.

**I-10 - Mapear o pacote em `G:` e restaurar depois.** Registrar `dosdevices/g:` e `g::` antes do launch, gravar `tuxbox-package-drive.json`, restaurar no fim **e** quando o setup falhar, e nao tocar em `G:` que nao seja symlink. Origem: `84c35b3`, `c561d03`, `22caa19`. Riscos: um launch morto deixa o link trocado; a restauracao no proximo launch cobre isso.

**I-11 - Emulacao de instrucoes AMD-only em CPU Intel.** `clzero`: handler vetorizado que limpa a linha de 64 bytes e, quando reconhece o laco, a faixa inteira; `monitorx`/`mwaitx`: reescrever o segundo byte do opcode para `1F` (`NOP` de mesmo tamanho) na primeira falha; `clwb` -> `clflushopt` em pre-Ice Lake. Origem: `e1262ac`, `371c839`, `7d281f8`. Riscos: reescrever codigo do titulo exige checar `CPUID` e que a falha esteja na imagem do titulo; memoria nao gravavel deve continuar falhando.

**I-12 - Fixar o Proton por medicao, nao por padrao.** `bd847b5` escolhe GE-Proton11-14 porque seu `dxil-spirv` faz 1,1 s onde o Experimental levava 36,6 s. Licao: em Linux-first, a versao do runtime Proton e parte da especificacao de desempenho; um fallback silencioso para "Experimental" esconde regressao de minutos.

### Especifico de traducao de command list Xbox (vale tambem em Windows)

**I-13 - Nunca falhar a lista inteira por um comando.** `Recording::skip` descarta o comando, loga com taxa limitada (16 primeiras + potencias de 2) e preserva as escritas de fence das quais outras filas dependem. Origem: `e8af9fd`. Risco: mascarar bugs de traducao - mitigado pelo log com RVA do chamador.

**I-14 - Aposentar descritor por fence, nao por tempo.** `e4783b4` usa 3 s; `98043df` troca por *lease* + *fence pinning*. Licao: qualquer estrutura que a GPU le por handle precisa de vida util ancorada em fence de conclusao, e nao em relogio.

**I-15 - Segmentar a lista em esperas e reproduzir o estado vinculado.** `6bae710`: dividir em segmentos nos pontos de espera, replicar heaps, root signature/argumentos, PSO, estados IA/SO/RS/OM com snapshots de RTV/DSV, predication; reter fallback de barreira apenas para casos nao snapshotaveis. Reutilizavel como desenho, nao como codigo.


===== VIctory Section F =====
## F. Correcoes importantes

**F-01 - Derrubar o draw em vez de degradar em silencio (D-01, `3c81420`).**
O que estava errado: um recurso esgotado (slots dinamicos) era tratado como "pode continuar com o que o titulo deixou ali". Por que funcionava mal: a tabela do titulo nao tem constant buffer views nos slots que o host usa para tabelas frescas; ler um descritor de textura como buffer gera endereco base invalido e o driver remove o device. Como foi corrigido: `bind()` devolve `bool`; `tables()` marca `table_failed`; o chamador descarta draw/dispatch/mesh/indirect. Por que funciona: a unidade de trabalho (o draw) e descartavel, o device nao e. Dependencias: precisa de contadores de descarte (`DROPPED`, log em potencia de dois). Reutilizavel: sim - o padrao "recurso escasso -> falha local, nunca fallback silencioso em estrutura binaria" e geral.

**F-02 - Heap dimensionado pela capacidade real do host (D-02, `3827767` + `e8d3b64`).**
O que estava errado: assumir que o heap do titulo cabe no host. Correcao: (a) toda tabela que passa dos slots de titulo e refeita em slots dinamicos, com o offset novo entregue ao shader; (b) o range dinamico e escolhido conforme o host aceite `count + DYNAMIC`, com `MIN_DYNAMIC` como piso. Por que funciona: o shader nunca indexa um slot que o host nao tem - ou o indice foi traduzido para um slot novo, ou o draw cai. Dependencias: `HostHeap::count()`, `mirror()` com aviso. Reutilizavel: sim, para qualquer emulacao de recurso com limite do host menor que o do alvo.

**F-03 - Prova antes de colapsar um loop (D-06, `b1c8306`).**
O que estava errado: reconhecer a **forma** de um waterfall (readfirstlane + compare + retry) e assumir a **semantica** (cada lane le o seu). Correcao: prova de satisfabilidade sobre condicoes de lane - o acesso deve servir exatamente as lanes que casam, a back edge deve manter exatamente as que faltam - com `meet` de condicoes; sem prova, nada e emitido e a razao e reportada. Por que funciona: transforma uma otimizacao em teorema verificavel sobre o CFG, com contraexemplos virando testes. Dependencias: `structure` com condicoes por lane (`Structured::reach`), IR com leitura de EXEC por instrucao. Reutilizavel: altamente - e o modelo para qualquer lowering que dependa de "todas as lanes deste acesso concordam".

**F-04 - Politica de imagem PE preparada (D-04, `c21208c` + `25a3e95`).**
O que estava errado: (a) zerar um campo que ainda tem realocacao; (b) escolher entre "zerar diretorios" e "apontar para o terminador vazio" sem entender o efeito no loader do OS. Correcao: reescrever a entrada DIR64 do campo zerado como ABSOLUTE; manter o diretorio de import apontando para o descritor nulo (com RVA calculado por `imports.len()`, nao pelo `Size` declarado) para o Windows atribuir TLS estatico. Por que funciona: o loader do OS ve uma tabela de import valida e vazia, e nenhuma realocacao ressuscita o ponteiro zerado. Dependencias: parser PE com contagem validada de descritores. Reutilizavel: sim, para qualquer loader que mapeie uma imagem "preparada" com imports proprios.

**F-05 - Copy-back por diff (D-07, `35b054e`).**
O que estava errado: devolver o range inteiro declarado pela GPU sobrescrevia escritas concorrentes da CPU do titulo (crash real). Correcao: instantaneo previo do range, comparacao byte a byte apos a submissao, devolucao so do que difere; buffer de instantaneo reutilizado em pool (sem isso, ~2,3 M page faults por frame). Por que funciona: separa "o que a GPU escreveu" de "o que a CPU escreveu depois", sem mascara de dirty no lado da GPU. Reutilizavel: sim; e o padrao classico para memoria compartilhada CPU/GPU com escrita dos dois lados.

**F-06 - Reescrita de caminho uma vez so (D-05, `27b530e`).**
O que estava errado: chamar o proprio wrapper wide com um caminho que ja era host, reentrando na traducao de drive virtual. Correcao: os wrappers narrow chamam a funcao wide do **host**. Por que funciona: ha exatamente um ponto de traducao por chamada. Dependencias: `host!` (resolucao tardia de export do sistema). Reutilizavel: sim - regra geral: nunca passar um caminho ja traduzido por um tradutor.

**F-07 - Limitacao de entrada antes da aritmetica (D-09, D-11).**
O que estava errado: aritmetica de layout e de pacotes confiando em valores do titulo. Correcao: (a) validar contra o maximo que o hardware pode enderecar (`16384` texels por lado), nao contra um numero inventado; (b) `checked_*` nos caminhos de copia; (c) regra de auto-consistencia no parser de frame (`bits > LENGTH_BITS`). Por que funciona: o limite e derivado do descritor de hardware, entao nenhum dado valido e recusado. Reutilizavel: sim; o harness de entrada aleatoria que achou a maioria destes (`005ad49`, `e6a2c54`, `5fbea47`, `ea24ea1`) e a tecnica reaproveitavel, e `e158d95` mostra a continuacao necessaria: fechar os sitios vizinhos que o primeiro limite nao cobria.

**F-08 - Fidelidade de erro como requisito funcional (D-14, `f0ee35e`, `28c1b07`, `376b3cf`).**
O que estava errado: devolver o erro do PC onde o contrato do console especifica outro. Correcao: separar cota de disco (`E_GS_OUT_OF_LOCAL_STORAGE` vs `E_GS_QUOTA_EXCEEDED`), `E_GS_PROVIDED_BUFFER_TOO_SMALL` para buffer pequeno, `E_FAIL` para path curto. Por que funciona: o titulo ramifica no HRESULT; a mensagem ao jogador e o comportamento seguem. Reutilizavel: sim - em HLE, o codigo de erro e parte da API.


===== VIctory Section I =====
## I. Conhecimento reutilizavel

**I-01 - Registro de `shortcut:` como passivo explicito.**
- Problema resolvido: separar "nao implementado de proposito" de "bug", num codebase que precisa rodar um titulo real em dias.
- Implementacao: comentario iniciando por `shortcut:` no ponto exato, dizendo o que falta e qual e o efeito; 124 ocorrencias no HEAD.
- Origem: VIctory, pratica presente desde `2849477` (`crates/victory-gpu/src/memory.rs:30`, `shadow.rs:153`, `texture.rs:13`).
- Conflitos/riscos: virou um passivo grande e sem dono; alguns shortcuts tem efeito visual (DCC/HTILE), outros sao limites de formato. Recomendacao: manter, mas gerar um relatorio (`xtask`) que liste por arquivo e ligue a um teste que falha quando o comportamento mudar.

**I-02 - Falha local em vez de fallback silencioso (D-01, F-01).**
- Problema: recurso escasso com fallback "usa o que esta la" produz corrupcao de estado de GPU, nao erro.
- Implementacao: `bind() -> bool`, `table_failed`, descarte da unidade de trabalho + contador.
- Origem: `crates/victory-gpu/src/draw.rs` (`3c81420`).
- Riscos: descarte silencioso vira "geometria faltando" e pode esconder bug; por isso o log em potencia de dois e o contador por frame.
- Recomendacao: adaptar para qualquer emulador de recurso com limite (descritores, handles, mappings).

**I-03 - Prova de equivalencia antes de otimizar lowering (D-06, F-03).**
- Problema: reconhecer a forma de um padrao de compilador e assumir a semantica.
- Implementacao: satisfabilidade sobre condicoes por lane (`meet`/`reach`), testes com as formas invalidas.
- Origem: `crates/victory-shader/src/resource.rs` (`b1c8306`).
- Riscos: custo de compilacao e falsos negativos (programa valido recusado); mitigado por mensagens de recusa especificas (`6c63dea`).
- Recomendacao: alto valor para tradutores de ISA e para qualquer lowering que dependa de convergencia de lanes/warp.

**I-04 - Instantaneo + diff para memoria compartilhada CPU/GPU (D-07, F-05).**
- Problema: devolver a GPU o range inteiro sobrescreve escritas da CPU.
- Implementacao: copia previa do range (pool), comparacao, devolucao so do que difere.
- Origem: `crates/victory-gpu/src/shadow.rs` (`35b054e`).
- Riscos: custo de copia (resolvido por pool; sem ele, 2,3 M page faults/frame) e granularidade (ranges declarados).
- Recomendacao: usar quando nao houver mascara de dirty do lado da GPU; e o caminho mais simples e correto.

**I-05 - Limite de entrada derivado do hardware (D-11, F-07).**
- Problema: valores do titulo em aritmetica de layout.
- Implementacao: `MAX_EXTENT = 1 << 14` (o maximo que um descritor GFX10 endereca) + `checked_*` nos caminhos de copia.
- Origem: `crates/victory-formats/src/texture.rs` (`e6a2c54`, `e158d95`).
- Riscos: se o alvo mudar (GFX11+), o limite muda; documentar a origem do numero.
- Recomendacao: sempre derivar o limite do formato/descritor, nunca de um "numero redondo".

**I-06 - Tabela de terceiro nao e especificacao (D-27, D-20).**
- Problema: opcode e semantica de predicado vieram de fontes secundarias (Mesa) ou de uma leitura "equivalente" (`fcmp one`).
- Implementacao: corrigir pela ISA/LLVM/medicao em hardware, com teste que falha no comportamento errado.
- Origem: `79fb722` (opcode), `51f1627` (predicado), `36eb0b4`/`0b499d7` (medicoes de hardware de outro projeto, issue #2).
- Riscos: divergencia por driver (o caso AMD de `fcmp one`) so aparece em hardware especifico.
- Recomendacao: para cada instrucao critica, um teste que roda em hardware **e** em WARP.

**I-07 - Mapear imagem PE "preparada" com imports proprios (D-04, F-04).**
- Problema: mapear a imagem com imports zerados quebra o loader do OS (TLS estatico, leitura de diretorio) e a realocacao ressuscita campo zerado.
- Implementacao: import aponta para o descritor nulo (RVA por contagem de descritores validada), DIR64 do campo zerado vira ABSOLUTE.
- Origem: `crates/victory-loader/src/prepare.rs` (`c21208c`, `25a3e95`).
- Riscos: depende do comportamento do loader do Windows 10/11 e do Wine; precisa de teste que mapeie uma DLL de verdade (existe: `windows_assigns_static_tls_to_a_prepared_dll`).
- Recomendacao: reutilizavel para qualquer emulador que injete imports.

**I-08 - Harness de entrada aleatoria sobre parsers e sobre o tradutor inteiro.**
- Problema: parsers de formato e lowering recebem dados hostis por definicao.
- Implementacao: gerar entradas aleatorias decodificaveis; rodar `ir -> resource -> io -> structure -> emit`. Achados: XMA zero-length, 4 sitios de overflow de textura, underflow de canal de input, stack overflow de lane mask, e "um milhao de programas sem panic/hang/overflow" como criterio de saida.
- Origem: `005ad49`, `e6a2c54`, `e158d95`, `5fbea47`, `ea24ea1`, `4cca767`.
- Riscos: cobertura depende do gerador; nao substitui teste semantico (D-20/D-21 vieram de medicao, nao de fuzz).
- Recomendacao: adotar como gate de CI noturno, com seed fixa.

**I-09 - Descritor como dado: guarda por tabela de strides (D-03, `d71c388`).**
- Problema: shader pega indice de descritor da memoria; o slot pode conter textura onde se espera buffer, e textura lida como buffer e endereco base absurdo (shift de 8 bits).
- Implementacao: tabela de stride por slot (root SRV `VIEW_STRIDES`); stride 0 -> `NULL_BUFFER_VIEW`; clamp de indice em `HEAP_VIEWS - 1`.
- Origem: `crates/victory-shader/src/emit/lower.rs` (`fn buffer_guard`), `emit/shader.rs` (`NULL_BUFFER_VIEW`).
- Riscos: um load extra por acesso (custo) e a tabela precisa cobrir slots dinamicos.
- Recomendacao: essencial para qualquer runtime bindless sobre D3D12; e a diferenca entre "leitura errada" e "device removido".


===== VItoriaBr Section F =====
## F. Correcoes importantes

**F-01 — Merge de escritas da CPU no cartao por mascara de bits (`9ceb7e7`).**
*O que estava errado:* quando o titulo escrevia memoria que shaders em voo tambem escrevem, a camada subia cada run alterado como copia propria (ate 512) e, acima disso, **esperava o cartao** (~1 settle/frame, 55-100 ms). *Por que falhava:* o volume de runs (centenas de milhares de poucos bytes) e estrutural, nao anomalo — o cap era sempre atingido. *Como foi corrigido:* `shadow::Masked::take` compara pagina de 8 em 8 bytes e marca **1 bit por byte alterado** por bloco de 64 KiB; o compute `CARD_MERGE` faz `card = (card & ~m) | (title & m)` com um thread por dword de mascara; bytes fora da mascara preservam o que os shaders escreveram; as mascaras viajam por submissao e sao recicladas quando o fence passa (ate 32 buffers). *Por que funciona:* a escrita da CPU e **fundida** com o resultado do shader na granularidade do byte, sem esperar, e a operacao e idempotente por construcao. *Dependencias:* compute shader cs_5_1, `shadow.rs`, `host.rs`, GPU com copy/fill; fallback para copia por run se faltar buffer, shader ou alinhamento de 64 KiB. *Reutilizavel:* **sim, altamente** — o padrao "mascara de bytes + merge no device" serve a qualquer camada que espelhe memoria de CPU em memoria de GPU com produtores concorrentes.

**F-02 — Hash de peca de copia com grupo de 64 threads (`713a095`).**
*O que estava errado:* um thread por peca de 64 KiB, 4.096 passos dependentes; o passe custa o tempo de uma peca e o cartao fica ocioso. *Como foi corrigido:* thread `t` hasheia os passos `t, t+64, ...` (coalescido), a lane 0 dobra os 64 hashes na ordem das lanes. *Por que funciona:* cada passo e **bijecao** do estado, entao qualquer mudanca confinada aos passos de uma lane muda o hash da peca; e a forma e escolhida **uma vez por processo** (`card_hash_wide()`), porque hashes armazenados e comparados tem de ser do mesmo algoritmo. *Dependencias:* limite de 16.385 pecas por dispatch (copias < 1 GiB), `groupshared`, WARP test. *Reutilizavel:* sim, com o aviso do acoplamento.

**F-03 — Espelho de registros de descriptor copiados como bytes (`a26859f` + `9376fd6` + `213fa54`).**
*O que estava errado:* o titulo copia registros de descriptor para o heap como **bytes**, sem chamada de API; os slots do host ficavam nulos ou velhos (~40.000 registros/frame medidos). *Como foi corrigido:* write-watch nas paginas de heaps *placed*; por slot, fingerprint barato; espelho antes de cada submissao; slots que draws leem por tabela ficam para os draws; hash de tabela antes de comparar os 3 dwords. *Por que funciona:* o passe olha so paginas sujas e compara registros **de verdade** depois do hash — colisao custa uma copia, nunca um descriptor errado. *Dependencias:* `watch.rs` (`Tracked`), `descriptor.rs` (`sync_heaps`), `draw.rs` (`fresh_tables`), `VICTORY_HEAP_SYNC`/`VICTORY_HEAP_SYNC_TABLES`. *Reutilizavel:* sim — e a resposta geral para "o titulo escreve em memoria que a API nao ve".

**F-04 — Regra `Rule::Start` para spans de textura (`310c6eb`).**
*O que estava errado:* invalidar por sobreposicao de span em tamanho cheio anula texturas empacotadas. *Como foi corrigido:* invalidar so quando a view nova **comeca** onde a antiga comeca (ou nos primeiros 4 KiB), com `HEAD = 4096` justificado por 129 pares medidos em 2 runs. *Por que funciona:* a menor cadeia de mips de uma textura ocupa um bloco de 4 KiB que **nao e compartilhado** por outra textura; logo "mesmo inicio" identifica reuso real, e "so alcanca os mips grandes ausentes" nao diz nada. *Dependencias:* `Spans`/`Rule`; `VICTORY_STALE_TEXTURES`. *Reutilizavel:* sim, mas a heuristica e **empirica para este titulo** — em outro titulo, medir de novo.

**F-05 — Rechecagem agendada de textura indexada (`a803c87`).**
*O que estava errado:* corrida entre "view escrita" e "memoria preenchida". *Como foi corrigido:* fingerprint de 48 KiB nos frames 4/12/40/120/400; mudou, reenvia e recomeca. *Por que funciona:* cobre a janela tipica de streaming sem custo por frame e sem depender de aviso do titulo. *Dependencias:* `TextureQueue::recheck`, `HostHeap::texture_slot_checked`. *Reutilizavel:* sim, com o **defeito conhecido** de amostrar so inicio/meio/fim (D-08).

**F-06 — `SLOT_VIEWS` com stride nomeado (`b62bbc0` + `5603b45`).**
*O que estava errado:* offset de 8 bytes para entradas de 16. *Como foi corrigido:* `SLOT_VIEW_BYTES` compartilhado entre emissor e host, `read_view_slot()` com clamp e offset unicos. *Por que funciona:* uma unica constante define o layout dos dois lados do contrato shader<->host. *Reutilizavel:* sim; a licao e **nomear o stride no ponto de contrato**, nao nos dois pontos de uso.

**F-07 — Bounds check de LDS com o tamanho do **programa** (`40beb26`).**
*O que estava errado:* comparar com o total alocado pelo host (inclui scratch de troca de metades). *Como foi corrigido:* `lds_dwords` do console separado do total, predicado `IULT` e indice seguro 0, leitura devolve 0 e escrita e descartada. *Por que funciona:* reproduz a semantica do RDNA2 e evita trap de groupshared na NVIDIA. *Dependencias:* `Lower`, `io::ComputeIo::lds_bytes`. *Reutilizavel:* sim, especialmente para qualquer lowering que rode wave64 do console em duas waves do host.

**F-08 — Ordem de publicacao no `relay_land` (`aa85bb0`).**
*O que estava errado:* liberar ranges antes de publicar `line.written` e acordar waiters. *Como foi corrigido:* coletar todos os ranges por flight, consumir a fila, atualizar `line.written`, `notify_all`, **e so entao** `copy_back_done`, sem deduplicar entre flights. *Por que funciona:* a liberacao e o **ultimo** evento; nenhum refresh concorrente ve o range livre enquanto o merge escreve. *Reutilizavel:* sim — e uma instancia do padrao "estado -> sinal -> libera recurso" que qualquer pool com espera deve seguir.

**F-09 — Cache de shaders chaveado pela traducao, nao pelo executavel (`a6a8d39`, `ef30575`, `a393a19`).**
*O que estava errado:* o guia dizia que a chave incluia o hash de `victory.exe`, o que invalidava o cache inteiro a cada recompilacao. *Como foi corrigido:* `translation_fingerprint()` = hash dos fontes de `victory-shader` (gerado por `build.rs`), flags de build, **valores em runtime de todos os `VICTORY_*` lidos pelo tradutor**, `loop_limit`/`group_sync`/`shader_opt`, e capacidades do host (`view_heap_limit`, `host_max_wave`); `VICTORY_SHADER_CACHE_KEY=exe` e opt-in. *Por que funciona:* identifica exatamente as entradas da traducao, e a impressao e recalculada a cada consulta (nao grava traducao feita antes do device informar capacidades). *Dependencias:* `build.rs` do `victory-shader`, `shader_cache.rs`. *Reutilizavel:* sim; e a correcao certa para qualquer cache de traducao.

**F-10 — Deteccao de codigo entre lanes por lista de nomes, com teste por opcode (`448416c`).**
*O que estava errado:* um conjunto de nomes incompleto decide a semantica de lane. *Como foi corrigido:* incluir `v_permlane*` e **testar lowering de cada opcode VALU isoladamente** num compute. *Por que funciona:* transforma uma lista sujeita a esquecimento em um caso de teste por opcode. *Reutilizavel:* sim — o metodo ("baixar cada opcode sozinho") encontra buracos que a leitura de codigo nao encontra.


===== VItoriaBr Section I =====
## I. Conhecimento reutilizavel

> Foco: o que e **exclusivo deste fork** (nao existe na base Marvisak nem, em parte, nos outros quatro forks) e o que **sobrevive a um repositorio unificado**.

**I-01 — Merge de escritas de CPU no device por mascara de bits (`9ceb7e7`, `shadow.rs` + `host.rs`).**
*Problema resolvido:* escritas da CPU e da GPU na mesma memoria, sem esperar a GPU. *Implementacao:* 1 bit por byte alterado por bloco de 64 KiB; compute `CARD_MERGE` (3 constantes de root, SRV titulo, SRV mascara, UAV cartao) com um thread por dword de mascara e `for k in 0..8` sobre 4 bytes; mascaramento em inteiros (`((four & 1) | ((four & 2) << 7) | ((four & 4) << 14) | ((four & 8) << 21)) * 255`). *Origem:* fxceless/victory-fork, importado em `9ceb7e7` (Martin Hartfelder). *Arquivos:* `crates/victory-gpu/src/{shadow,host,indirect}.rs`. *Dependencias:* SM 5.1 compute, fence por submissao, blocos de 64 KiB. *Conflitos provaveis:* qualquer outro mecanismo de "merge de runs" (`VICTORY_MERGE_GAP`, `VICTORY_MERGE_RUNS`) e o caminho de relay (`relay_land`), que precisa transportar as mascaras por numero de envio. *Riscos:* se a mascara e a copia divergirem de tamanho, bytes fora da mascara ficam do shader — correto — e bytes dentro ficam do titulo — correto; o risco real e o **relay**: `card_merge_relay` precisa excluir byte a byte. *Recomendacao:* portar como um par (mascara + shader) com os testes WARP de 3.000 runs aleatorios de 1-9 bytes cruzando dwords; nao portar pela metade.

**I-02 — Hash de 64 KiB com grupo de 64 threads + decisao por processo (`713a095`).**
*Problema:* comparar copias de cartao sem pagar o tempo de uma peca por passe. *Implementacao:* `CARD_COMPARE_WIDE` com `groupshared uint4 lanes[64]`, dobra na lane 0, `compare` em tres modos (armazena, compara, compara e armazena). *Origem:* fxceless (Martin Hartfelder). *Dependencias:* `OnceLock` de decisao (`card_hash_wide`), copias < 1 GiB, `groupshared`. *Conflitos:* qualquer hash de copia armazenado antes (`CARD_COMPARE`) — **incompativel por definicao**; a forma tem de ser escolhida uma vez e nunca misturada. *Riscos:* colisao de hash = peca nao buscada = dado velho no titulo; mitigado pela bijecao por passo. *Recomendacao:* portar os dois shaders juntos e manter o switch como **diagnostico**, nao como configuracao de usuario.

**I-03 — Sync de descriptor heap por fingerprint + comparacao de registros (`a26859f`, `9376fd6`, `213fa54`).**
*Problema:* o titulo copia registros como bytes; a API nao ve. *Implementacao:* write-watch por pagina; por slot `u64` de fingerprint (multiplica-e-dobra); hash de tabela (`Plain` hasher com `write_u64`) antes de comparar os 3 dwords; slots lidos por tabela ficam para os draws. *Origem:* fxceless (apos upstream 86a5ed6) + uiliannn (`213fa54`, de belobug `127830e` + romainhedouin `b41f3f3`). *Dependencias:* `watch::Tracked`, `Spans`, heaps *placed*. *Conflitos:* `SHADER_HEAPS` (RwLock) e a invariante de nao retomar o lock; qualquer codigo que escreva descriptors sem passar por `mirror`. *Riscos:* hash de tabela colidindo custa copia (aceitavel por desenho); o perigo e **nao comparar** os registros. *Recomendacao:* levar o trio completo; medir com o contador de "slots deixados aos draws".

**I-04 — Tabela `SLOT_VIEWS` (endereco/len/stride por slot) com stride nomeado (`b62bbc0`, `5603b45`).**
*Problema:* o console le o **endereco de um descritor** cujo indice e calculado em runtime; sem tabela, o shader nao tem como resolver. *Implementacao:* root SRV 252 com 4 dwords por slot; clamp `SLOT_VIEWS_COUNT-1`; `rawBufferLoad` de 4 componentes. *Origem:* uiliannn; correcao de stride por Lilith133T (`pr-7`). *Dependencias:* layout identico nos dois lados. *Conflitos:* `bindless.rs` da base (que este fork nunca teve — ver L-03) e qualquer tabela de views paralela. *Riscos:* **exatamente o que aconteceu** (8 vs 16 bytes). *Recomendacao:* portar com a constante unica e o teste de stride; e o unico jeito de manter o contrato.

**I-05 — Regra de invalidez de textura `Rule::Start` + `HEAD=4096` (`310c6eb`).**
*Problema:* texturas empacotadas com spans sobrepostos. *Implementacao:* invalidar so por "mesmo inicio" (ou dentro dos primeiros 4 KiB); modos `overlap`/`0` como diagnostico. *Origem:* fxceless. *Dependencias:* `Spans` (`BTreeMap` por inicio + `HashMap` por slot). *Conflitos:* qualquer logica que assuma spans disjuntos (comentarios antigos do proprio arquivo). *Riscos:* heuristica empirica de **um** titulo; em outro, `HEAD` precisa ser remedido. *Recomendacao:* portar o **mecanismo** (regra configuravel + contador de pares medidos), nao o numero 4096 como verdade.

**I-06 — Rechecagem agendada de textura indexada (`a803c87`).**
*Problema:* streaming preenche a memoria depois da view. *Implementacao:* fingerprint de 48 KiB nos frames 4/12/40/120/400; reenvia e recomeca. *Origem:* fxceless. *Dependencias:* `TextureQueue`. *Conflitos:* `VICTORY_PAGE_WRITES=slots` (mecanismo alternativo do mesmo fork, que re-enfileira texturas *placed*). *Riscos:* os dois mecanismos juntos podem reenviar demais; medir. *Recomendacao:* portar com fingerprint **maior ou por pagina suja**, corrigindo o gap declarado.

**I-07 — `ambient.rs`: luz ambiente sombreada por profundidade como *fallback* de RTGI (`d0af132`, `692bce4`).**
*Problema:* sem RTGI, tudo que o sol nao bate e preto (interiores, lado sombreado do rosto) — e isso e **a maior parte da imagem**. *Implementacao:* apos o programa `CS_ScreenProbes_TemporalResolve*`, substitui a saida (R9G9B9E5 em inteiros) por uma constante sombreada por oclusao de profundidade; `VICTORY_AMBIENT`, `_TINT`, `_SHADE`, `_FILE` (le `level r g b [strength radius near tan_y] [ceiling floor]` duas vezes por segundo em builds de diagnostico). *Origem:* Belobug (`0603123..cd9f78c`), gancho de historico de reflexao de `44dcd43`. *Dependencias:* o programa do titulo existir e escrever naquele slot de tabela (root 1, posicao 176); `resource::host_made` sem gate de feature. *Conflitos:* qualquer porte de iluminacao que escreva no mesmo alvo; `ceiling/floor` de reflexao precisa ficar opt-in (o proprio commit diz). *Riscos:* **substitui** a saida do titulo — e uma aproximacao declarada, nao uma correcao; e o tipo de porte que muda a imagem globalmente. *Recomendacao:* levar como paliativo nomeado, com o switch de desligar, e remover quando o RTGI funcionar.

**I-08 — HUD por fonte bitmap + anel de upload (`ca8829f`, `e140f41`).**
*Problema:* o contador de FPS precisa estar **na imagem** (captura de stream nao leva a legenda da janela), sem biblioteca de fontes e sem tocar o frame do titulo. *Implementacao:* fonte 5x7 propria; texto desenhado na CPU; buffer feito **uma vez por texto** e nunca reescrito (um present em voo le o que foi gravado); anel de 4 slots para nao vazar memoria. *Origem:* fxceless (base), expandido por uiliannn (2 linhas, VRAM, GPU). *Dependencias:* copia para o back buffer antes do `Present`; nome do adaptador. *Conflitos:* captura de frame (`shot.rs`) e qualquer coisa que leia o back buffer. *Riscos:* baixo; o desenho e no back buffer, nao no frame do titulo. *Recomendacao:* portar — e 300 linhas que substituem uma dependencia inteira de UI.

**I-09 — Captura de frame embutida (`shot.rs`, 1.016 linhas, `79cfdd9`).**
*Problema:* RenderDoc 1.45 carregado por hook *"did not survive here"*, entao nao havia como ver o frame. *Implementacao:* grava comandos de um frame, o relogio do cartao antes de cada, e a imagem que cada passe deixou; sem carregar biblioteca e sem device envolvido; imagens em partes quando falta memoria. *Origem:* fxceless. *Dependencias:* `VICTORY_SHOT`; `capture::op` desviando linhas. *Conflitos:* `framelog`/`cardmeter` (instrumentacao concorrente). *Riscos:* custo de memoria no pior momento (por isso "em partes"). *Recomendacao:* portar como **ferramenta**, nao como feature de produto; e a unica forma de diagnostico de frame que funcionou neste ambiente.

**I-10 — `test_skip` com `VICTORY_STRICT_TESTS` (`b4180ea`).**
*Problema:* testes que exigem GPU/compilador eram "pulados" com `eprintln!`, indistinguiveis de sucesso. *Implementacao:* `test_skip::skip(msg)` imprime `VICTORY TEST SKIPPED` e, com `VICTORY_STRICT_TESTS=1`, **falha**; `Host::new` loga o adaptador uma vez. *Origem:* Luiz Gustavo Benicio Neves (`#32`/`#43`). *Dependencias:* nenhuma. *Conflitos:* nenhum. *Riscos:* nenhum. *Recomendacao:* portar para qualquer suite com testes dependentes de hardware — resolve o "verde que nao testou nada".

**I-11 — CI duplo (Windows completo + Linux portatil) e `cargo xtask ci` (`d52d84c`, `defaac8`).**
*Problema:* o tradutor de shaders e a parte mais ativa e nao precisa de Windows; contribuidores sem Windows ficavam de fora. *Implementacao:* job `portable` em `ubuntu-latest` com `-p victory-core -p victory-pe -p victory-pipeline -p victory-shader -p victory-formats -p victory-game -p xtask` e `clippy -D warnings`; `xtask ci` roda o mesmo localmente, e no Linux tambem **type-checka** `x86_64-pc-windows-msvc` com `CARGO_FEATURE_PURE=1` para o blake3. *Origem:* Anderson Florentino da Silva (`#3`), estendido por lcg007xd-c (`#77`). *Dependencias:* `cfg(windows)` correto nos testes. *Conflitos:* testes que parseiam o proprio binario como PE (resolvido com `#[cfg(windows)]`). *Recomendacao:* portar sem hesitar; foi o que pegou H-08.

**I-12 — Warm cache de shaders (`a6a8d39`, `ef30575`, `d8b281a`, `a393a19`).**
*Problema:* primeira execucao paga a traducao (minutos de pop-in). *Implementacao:* `victory warm <dir>` descobre containers acessiveis, corta cada um ao extent declarado, deduplica por hash completo e grava pelo writer do runtime; `victory translate --warm <arquivo|all>` aceita lista de hashes de 16 digitos com `--jobs`/`VICTORY_WARM_SECONDS`; `VICTORY_HOST_WAVE`/`VICTORY_VIEW_LIMIT` aplicados ao warm (`#24`). *Dependencias:* chave de cache do F-09 (**sem ela, aquecer e inutil**). *Conflitos:* `--warm` nao aplica o recorte `Container::bytes_of` que `victory warm` aplica — as duas rotas **nao** cobrem as mesmas entradas (documentado em `docs/precompilacao-shaders.md`, corrigido por `a393a19`). *Riscos:* aquecer com chave errada produz cache que nunca acerta. *Recomendacao:* portar as duas rotas **e** o documento que explica a diferenca.


===== XCL Section F =====
## F. Correcoes importantes

**F-1. Endereco efetivo de 64 bits antes da escolha da janela (`f9e5ee9`).**
O que estava errado: a janela era escolhida pelo dword alto da base, e o offset somava em 32 bits. Por que importa: uma janela de 4 GiB e exatamente o tamanho de um espaco de 32 bits, entao **qualquer** offset nao trivial pode cruzar a fronteira. Como foi corrigido: `uint64_t {t}_ea = <endereco completo>`, depois `window_read((uint)(ea >> 32))` ou `window_write(...)`; a base da UMA entra por `IO_UMA_BASE_HI` (io slot 112) e o range-check e `hi - xcl_uma_base` com os accessors usando `default` para "fora da UMA" (leitura 0, escrita/atômico descartado). Por que funciona: elimina a aritmetica de 32 bits no ponto errado e, de bonus, impede que um ponteiro fora da UMA **apelide** uma janela viva. Dependencias: `mem_accessors` precisa de um `default` que nao seja o `mem` da janela 0; `window_read` e `window_write` diferem de proposito (`hi == 0` e tabela de descritores de 32 bits do console: le da janela 0, mas **nao** escreve). Reutilizavel em qualquer camada de traducao de GPU com janelas: regra geral = "nunca derive o seletor de regiao de um pedaco do endereco antes de completar o endereco".

**F-2. Reverter e uma decisao de engenharia, nao um fracasso (`70f8dc4`).**
O que estava errado: um crash deterministico dentro de um componente de terceiro (o compilador da AMD), disparado por uma mudanca correta em nivel de linguagem. Como foi corrigido: revert mecanico (`git revert -m 1`) isolando **um** PR, com o motivo registrado no PR original e em `HANDOFF.md`. Por que funciona: restaura o estado que rodava, sem tocar no que veio junto no lote (o merge de #124, onze minutos depois, fica). Licao reutilizavel: quando dois PRs entram no mesmo minuto e um quebra, o revert por merge (nao por commit) e o unico jeito de separa-los; e `git revert -m 1 <merge>` gera exatamente esse diff (13+/93-).

**F-3. Fallback como instrumento de correcao (`fe8dc84`, `878afda`, `ac34cb6`, `66879ef`).**
Em vez de "consertar" um lowering incompleto, o bridge do per-lane mantem a lista `DIFFERS_ON_1426` e recusa aquelas instrucoes; o programa cai para o caminho HLSL, que e correto. Isso e uma correcao **de corretude** com custo de cobertura, e e o padrao dominante do repositorio (`Translation::complete()` / `unsupported_why`). Reutilizavel: em tradutor com dois backends, uma lista de divergencias conhecidas por opcode, com o motivo e o link do bug, e mais segura do que tentar igualar semantica sob pressao.

**F-4. Recusa por "uniformidade sobre EXEC" (`66879ef`, `uniform_over`).**
O que estava errado: a analise respondia "o bit desta lane?" quando a pergunta do console era "alguma lane da wave?". Como foi corrigido: uma pergunta BDD — a condicao e constante em toda lane que chega com seu bit de EXEC (`implies(reach & exec, c)` ou `implies(reach & exec, !c)`)? Se nao, recusa. Por que funciona: cobre os dois casos legitimos (`s_and_saveexec` + `s_cbranch_execz`, VCC == EXEC) sem enumerar padroes de codigo. Reutilizavel em qualquer lowering que troque semantica wave-uniforme por per-lane.

**F-5. "Todo valor escrito num bloco que algumas lanes pulam precisa de definicao propria" (`a23b6ff`).**
O que estava errado: o mapa `def_block` (usado para detectar leitura de valor obsoleto) registrava o bloco do **valor**, nao o da **escrita**; uma copia (`s_mov s4, s0`) num bloco parcial herdava o bloco antigo e a leitura posterior deixava de ser recusada. Como foi corrigido: `own()` cria `or v, 0` no bloco parcial para materializar a escrita. Por que funciona: torna o valor "deste bloco" sem mudar o resultado numerico. Reutilizavel: e o mesmo problema de "SSA com caminhos divergentes" que aparece em qualquer lowering por lane.

**F-6. Identidade de cache derivada das fontes do produtor (`bfb8133`).**
`build.rs` hasheia `PER_LANE_SOURCES` em `XCL_PER_LANE_SOURCE_ID`; a identidade vira `xcl-per-lane-<hash>`. Separar a identidade por caminho (`TRANSLATOR_SOURCES` vs `PER_LANE_SOURCES`) evita invalidar o cache do HLSL quando so o per-lane muda. Reutilizavel literalmente: `cargo:rerun-if-changed` + hash FNV do conteudo + `concat!` na chave.

**F-7. Isolar o driver: transicao de `INDIRECT_ARGUMENT` como barreira portavel (`4e3515e`).**
Quando uma dependencia de dados so existe via UAV barrier e um driver a ignora, usar uma transicao de estado que o driver **precisa** respeitar, num recurso proprio da camada (nao do titulo), e um padrao robusto e barato (duas transicoes por `ExecuteIndirect`). Reutilizavel em qualquer camada D3D12 que sintetize listas.

**F-8. Testes que afirmam a **forma** do codigo gerado (`425b869`, `0b64aa0`, `2a2d54b`).**
`direct_msaa_loads_precede_get_dimensions` desmonta o DXIL e verifica ordem por bloco; `multi_window_mem_format_and_bvh_validate` valida o DXIL para 1..=4 janelas; `gpu_geometry_direct_records` passou a comparar a forma split do HLSL. Isso protege contra regressoes de **forma** que nenhum teste de resultado capturaria (e que, no caso da AMD, sao a diferenca entre rodar e crashar).


===== XCL Section I =====
## I. Conhecimento reutilizavel

**I-1. Seletor de regiao a partir de endereco completo (D-01 / F-1).**
Problema: janelas de 4 GiB + offsets de 32 bits. Implementacao: `uint64_t ea = base64 + (uint64_t)off;` e depois `w = ea >> 32` menos a base; leitura e escrita com regras diferentes; `default` que nao apelida. Origem: XCL `f9e5ee9`. Arquivos: `gpu/recomp/emit.rs` (`window_read`, `window_write`, `emit_flat_addr`), `gpu/recomp/runner.rs`, `hle/d3d12x/bind.rs` (slot 112). Dependencias: um slot de I/O para a base da UMA. Conflitos: com a forma switch (cada acesso vira um `switch`), que foi o gatilho do bug do driver. Riscos: a aritmetica de 64 bits por acesso e a forma acusada no crash de #123 — em alvo AMD, preferir descriptor heap (uma comparacao) ou carry em 32 bits. Recomendacao: adotar, com teste de carry **e** de borrow, e um teste que verifique que um `hi` fora da faixa nao apelida janela viva.

**I-2. Guarda por nome de campo: falhe alto (D-05).**
Problema: `["...","OPSEL"]` nunca dispara porque `field_value` devolve `None` e `unwrap_or(0)` engole. Implementacao recomendada: um modo de teste em que `field_value(nome_desconhecido)` e erro, ou uma lista de campos validada contra a tabela de encoding. Origem: XCL `b3c0b37`/`ac34cb6`. Riscos: nenhum. Recomendacao: obrigatorio em decodificadores tabelados.

**I-3. Identidade de cache = hash das fontes do produtor (D-11 / F-6).**
Origem: `crates/xcl/build.rs` (`TRANSLATOR_SOURCES`, `PER_LANE_SOURCES`, FNV-64, `cargo:rerun-if-changed`). Reutilizavel em qualquer pipeline com cache em disco de artefato gerado. Recomendacao: uma lista **por caminho de traducao**, nunca uma global.

**I-4. Lista de divergencias conhecidas entre backends (F-3).**
Origem: `DIFFERS_ON_1426` em `gpu/recomp/lower.rs`. Estrutura: `const [&str]` + comentario com sintoma e autor do relato. Recomendacao: manter a lista **com data e issue**, e um teste que falhe quando o item for corrigido no outro backend (senao ela apodrece).

**I-5. Recusa por uniformidade sobre EXEC (D-12 / F-4).**
Origem: `lane_masks.rs::uniform_over`. Aplicavel a qualquer lowering que troque semantica wave-uniforme por per-lane (ballot, `readlane`, `mbcnt`, decisoes "any lane").

**I-6. Diagnostico de driver: quatro padroes AMD ja mapeados.**
(a) `getDimensions` antes de `textureLoad` em MSAA indexado por heap -> null deref (`425b869`); (b) aritmetica de 64 bits antes de um `switch` de janela -> null deref no compilador (`70f8dc4`); (c) reorganizacao de comparacoes float apos `!(a>=b)` -> resultado unordered errado (`emit.rs:136`); (d) `no-signed-zeros` implicito -> `+0` no lugar de `-0` (`b1bfd1e`). Uso: lista de "coisas que o alvo faz e nao estao na spec", cada uma com um teste que verifica a **forma** do codigo gerado, nao so o resultado.

**I-7. Emular barreira de dados com transicao de estado (`4e3515e` / F-7).**
Origem: `hle/d3d12x/bind.rs` (duas transicoes `INDIRECT_ARGUMENT` num buffer proprio em volta de cada `ExecuteIndirect`). Aplicavel a qualquer backend onde o driver comprovadamente ignora UAV barriers para uma operacao especifica.

**I-8. Testes de GPU que pulam, com razao legivel (D-23).**
Padrao: `fn gpu_waves() -> bool` + `runner::skip_test("no GPU with 32-lane waves")` + contagem no fim de `scripts/test.ps1` + `XCL_REQUIRE_GPU=wave64|mesh` para transformar skip em falha quando se quer cobertura de verdade (`ff9430e`). Recomendacao: nunca `#[ignore]`, sempre skip explicito — e **sempre** um modo que falhe.

**I-9. `then(|| ...)` em vez de `then_some(...)` quando o valor pode panicar (D-16/`dd566c0`).**
`then_some((r - 1, true))` avalia `r - 1` mesmo quando a condicao e falsa (underflow em `s0`). Bug de uma linha, panic em debug, comportamento errado em release.

**I-10. Limite heuristico para codegen patologico (`69a892c`).**
`STRUCTURED_BYTES_PER_CODE_BYTE = 128` com re-traducao em outra forma. Padrao geral: medir o tamanho da saida contra o da entrada e trocar de estrategia; mais robusto do que prever quais programas estouram.


===== Xbox2Windows Section F =====
## F. Correcoes importantes

- **F-01 -- `583178d4` (NaN em comparacoes f32).** O erro era depender da **forma fonte** `!(a < b)`, que FXC e DXC reescrevem por algebra de comparacao sem `-Gis`. A correcao expressa a condicao como `!(ORDERED && a OP b)` e `o`/`u` como teste dos bits das duas palavras, o que nao depende de flag de compilador. Funciona porque `ORDERED` e o mesmo teste de bits que `lg` ja usava desde #1920. Reutilizavel em qualquer lowering que precise de semantica IEEE sob FXC/DXC. Risco: assumir que "not ordered" e o complemento de "ordered" -- so vale com o teste de bits, nunca com `==`/`!=` de float.
- **F-02 -- `2a898640` (tempo de vida da superficie).** Command lists nao seguram recursos. A correcao toma referencia da superficie ao submeter a copia e solta depois do fence; se `Signal` falha, o sampler entra em "stranded" e mantem os objetos ate o processo terminar em vez de arriscar use-after-free. A parte reutilizavel e o **controle negativo**: `unheld_source_control_warp` so passa quando a debug layer acusa o recurso liberado -- prova que o caminho positivo segura de verdade.
- **F-03 -- `21e8f5c0` (placeholder e rollback de slab).** Duas correcoes no mesmo arquivo: (a) so dividir placeholder que o shim reservou, com checagem de tamanho; (b) commitar o primeiro slot dentro da factory para que a falha feche o handle e nao deixe slab contabilizado. Padrao: "adquira e registre no mesmo ponto; em falha, desfaca antes de publicar estado". Reutilizavel em qualquer alocador com reserva/commit separados (`SEC_RESERVE` + `MEM_COMMIT`).
- **F-04 -- `b87a99a3` (publicacao atomica de shader).** Compila os dois estagios em diretorio temporario, so publica `.cso` depois de ambos terem bytecode, retira o manifesto antigo quando as bindings mudam e apaga o `.fail` no sucesso. O criterio de retomada passa a exigir `.txt` + ambos `.cso` (ou manifest-only). Elimina a mistura manifesto/bytecode de revisoes diferentes e o bloqueio permanente apos uma rodada sem fxc.
- **F-05 -- `ac539650` (hooks opt-in).** Separa hooks de arquivo (necessarios ao offline) de hooks de chamada (que param o processo). Os segundos passam a exigir `--trace-calls 1`, mantendo o comportamento antigo sob a flag. O teste com DLL source-built sob o nome do movie player conta 0 chamadas por padrao e exatamente 7 com a flag -- distingue "nao armou" de "armou e nao contou".
- **F-06 -- `2260b7a4` (container de save).** O nome pode sobreviver ao close enquanto um update o mantem; logo "aberto" e `refs_ > 0`, nao `name != ""`. O teste cobre o caso exato: update aberto + close + segundo `begin_update`.
- **F-07 -- `e50a72bc` (command signature).** Reconhecer so o valor observado (`0x69`) e deixar o resto para o runtime torna o shim resistente a ampliacao da enumeracao do desktop; validar `readable`/`writable` evita excecao em descritor invalido; o fallback depois da falha real preserva compatibilidade sem sequestrar tipos validos. E a unica correcao do pacote que **reduz** o escopo de um shim em vez de aumenta-lo.
- **F-08 -- `07f2464f` (default viewport por tamanho).** O estado "o titulo definiu" e o estado "ja encaminhei o default" sao coisas diferentes. A correcao guarda o **tamanho** ja encaminhado (`default_viewport_w/h`, `default_scissor_w/h`, zerados em `reset_viewport_state`) e regenera o default quando o alvo muda de tamanho. Reutilizavel em qualquer camada que sintetize estado de pipeline ausente: nunca use a flag do chamador para registrar o que voce mesmo sintetizou.
- **F-09 -- `c3c3ab3c` (cache invalidado por revisao).** O fix de `a16` e mecanico, mas a parte que generaliza e a **revisao de cache**: `x2w-startup-shader-5` -> `-6`, escrita nos dois lados (tool e runtime). Qualquer mudanca de semantica de traducao que possa reutilizar bytecode antigo exige bump nos dois arquivos; em HEAD os dois concordam (`d3d12_draw.inl:201`, `gfx2hlsl.py:2176`).
- **F-10 -- `22989d61` (revert disciplinado).** O valor aqui e processual: uma mutacao commitada para provar um teste foi revertida em 88 s, com o corpo do commit citando o hash original, e o revert e byte-exato (mesmo blob). Verificar "o revert foi completo" e barato: comparar o blob antes da mutacao com o blob do revert (`git rev-parse <rev>:<path>`).


===== Xbox2Windows Section I =====
## I. Conhecimento reutilizavel

- **I-01 -- Placeholder: so divida o que voce possui.** Antes de `MEM_RELEASE | MEM_PRESERVE_PLACEHOLDER`, confirme que a faixa pertence a uma reserva do proprio componente e que o tamanho cabe nela. Preserve o erro original apenas se o split **nao** ocorreu; se ocorreu e o retry falhou, reporte o erro do retry. Arquivos: `src/xmem_mapped_pages.cpp`; commits `0478a386`, `21e8f5c0`. Risco: dividir placeholder alheio corrompe o estado do chamador.
- **I-02 -- Reserva/commit sob demanda com rollback simetrico.** Crie o slab com `SEC_RESERVE`, commite o slot no primeiro uso e, em falha, feche o handle e nao registre o slab. Nunca insira o objeto numa colecao antes da operacao que pode falhar sem caminho de remocao. Arquivos: `src/xmem_mapped_pages.cpp`, `src/xmem_slab_slots.h`; commits `9727c306`, `21e8f5c0`.
- **I-03 -- Recurso de GPU: referencia ate o fence.** Command lists nao retem recursos; quem enfileira copia precisa de referencia propria ate o fence. Se o sinal falhar, mantenha o recurso e marque o subsistema como parado em vez de liberar. Teste reutilizavel: controle que so passa quando a debug layer acusa o recurso liberado. Arquivos: `src/startup_stubs/present_signature_sampler.h`; commits `8c2d82f6`, `2a898640`.
- **I-04 -- "Aberto" e refcount, nao nome.** Em tabelas que mantem o nome apos o close para nao invalidar updates, a condicao de abertura deve ser `refs > 0`. Arquivos: `src/startup_stubs/save_store.h`; commits `ca92741e`, `2260b7a4`.
- **I-05 -- Semantica IEEE nao sobrevive a `!(a OP b)`.** Expresse ordenado/nao-ordenado com teste de bits e nunca com `a == a`/`a != a`. Valide com FXC **e** DXC sem `-Gis`; a flag muda o resultado. Arquivos: `tools/startup/gfx2hlsl.py`, `tests/startup_gfx2hlsl_f32_nan_check.py`; commit `583178d4`.
- **I-06 -- Campo assinado: sign-extend antes de imprimir.** Para `OFFSET[20:0]` de SMEM, mascare e estenda o bit 20; imprima `-0x...` para negativos e fixe vetores em -1, minimo e maximo positivo. Arquivos: `tools/disasm_rdna2.py`; commits `eefc3f86`, `83bb752d`. Risco: automacao que compara desmontagem ve offsets diferentes do LLVM.
- **I-07 -- Gate de log atomico deve saturar.** `InterlockedIncrement <= N` estoura e reabre o log; use CAS com `seen < limit` e pare em `limit`. Arquivos: `src/startup_stubs/local_log.h`; commit `f360d30a`. Risco: consumidor que faz poll de status reativa o log depois de ~2^31 chamadas.
- **I-08 -- Publicacao de artefato de build: staging + manifesto por ultimo.** Compile tudo em diretorio temporario, publique bytecode so com o par completo, retire o manifesto antigo quando as bindings mudam e apague o `.fail` no sucesso. Arquivos: `tools/startup/gfx2hlsl.py`; commit `b87a99a3`. Risco: manifesto e bytecode de revisoes diferentes; retomada bloqueada apos rodada manifest-only.
- **I-09 -- CLI de ferramenta: modos uniformes.** Todo modo (inclusive `--hex`) deve passar pelo mesmo writer de `--output`; entrada malformada usa `parser.error` (exit 2) sem traceback; alvo ausente vai para stderr e exit 1 **depois** de processar os demais. Arquivos: `tools/disasm_rdna2.py`; commit `20fa94a9`.
- **I-10 -- Teste de fixture: nunca reutilize o nome da variavel.** Um `asm` reutilizado troca silenciosamente o programa medido; separe `asm` e `pseudo_ops_asm` e fixe a medicao no fixture original. Arquivos: `tests/form_coverage_check.py`; commits `5b2dadd7`, `14d6023e`.
- **I-11 -- Estado sintetizado nao compartilha flag com o estado do chamador.** Se a camada cria um default (viewport, scissor, blend, root signature), registre o que **ela** encaminhou (e de que tamanho/versao) numa variavel separada da flag do chamador; caso contrario o default nunca e regenerado quando o contexto muda. Arquivos: `src/startup_stubs/d3d12_draw.inl`, `d3d12_xs_device.cpp`; commits `ffb70f6a`, `07f2464f`.
- **I-12 -- Mudanca de semantica de traducao exige bump de cache nos dois lados.** Tool e runtime devem carregar a mesma string de revisao; um `shader_cache/` mantido entre execucoes e o caminho normal do projeto, entao o bump e o que impede bytecode pre-fix de sobreviver ao fix. Arquivos: `src/startup_stubs/d3d12_draw.inl`, `tools/startup/gfx2hlsl.py`; commit `c3c3ab3c`.
- **I-13 -- Mutacao temporaria: revert comprovado por blob, nao por mensagem.** Se for commitada uma mutacao para provar um teste, o revert deve citar o hash original **e** restaurar o blob identico (`git rev-parse <rev>:<path>` antes e depois). Verifique tambem `git log <mutacao>..HEAD -S'<texto mutado>'` para garantir que ninguem reintroduziu o texto noutro arquivo. Commits `1f24626b`, `22989d61`.
- **I-14 -- Cobertura de tabela de classificacao: amostra por entrada + verificacao reversa.** Uma tabela `pattern -> token` sem amostra por linha acumula causas silenciosamente em `other`; o teste deve alimentar cada entrada, casar a amostra de volta ao indice e exigir que toda entrada tenha amostra. Arquivos: `tests/startup_triage_run_check.py`; commit `13745b1b`.
- **I-15 -- Skip de capacidade precisa de codigo dedicado e documentado.** A convencao 77 do CTest funciona, mas exige que o binario so retorne 77 por ausencia de capacidade; qualquer outro motivo contamina o relatorio. Commits `0b649c69`, `86c225cc`; arquivos `CMakeLists.txt`, `tests/desktop_gpu.h`.


===== victory-fork Section F =====
## F. Correcoes importantes

### F-01 - Switch de ambiente como unidade de experimento, com a chave do cache derivada dele

- **O que estava errado**: um interruptor que muda o codigo gerado nao entrava na identidade do artefato cacheado; o experimento "desligado" reutilizava o artefato "ligado". Isso e um erro de **corretude experimental**, nao de desempenho. Na forma antiga a chave era o BLAKE3 do **proprio executavel**: dois runs do mesmo binario com switches diferentes tinham a mesma chave.
- **Como foi corrigido**: `e9765a7` acrescenta manualmente os quatro switches de wave; `8dd30ab` troca o esquema por `translation_fingerprint()`, e `crates/victory-shader/build.rs` **descobre os switches lendo o proprio codigo**: varre `crates/victory-shader/src/**/*.rs`, acha todo literal que comece com `"VICTORY_`, e emite `cargo:rustc-env=VICTORY_SHADER_SWITCHES=<lista>`; em tempo de execucao os valores entram na chave. O mesmo fingerprint inclui fonte do tradutor (FNV-1a de todos os `.rs`), feature `diagnostics`, `debug_assertions`, `host_max_wave`, `view_heap_limit`, `loop_limit`, `group_sync` e `shader_opt`.
- **Por que funciona**: a chave e funcao pura de (fonte do tradutor, configuracao efetiva, fatos do host) e a lista de configuracao e **derivada do codigo**, nao mantida a mao - um switch novo dentro do crate entra na chave sem ninguem lembrar. Um switch que muda a emissao sem literal no crate (ou fora dele) e o unico furo restante.
- **Dependencias**: `victory-pipeline::Cache` (escrita atomica), `include_bytes!("shader_cache.rs")` (invalida quando o proprio arquivo de cache muda), `VICTORY_SHADER_CACHE_KEY=exe` como volta ao esquema antigo.
- **Reutilizavel?** Sim, e o padrao mais valioso do repositorio para qualquer sistema com cache + flags: **toda flag que altera a saida entra na chave, e a lista de flags e gerada a partir do codigo**. Custo: um `blake3` por lookup. Risco: confiar na descoberta textual (um switch lido por nome montado em tempo de execucao escapa).

### F-02 - Guarda sobre todas as views de uma pagina fisica

- **O que estava errado**: o titulo mostra a mesma pagina fisica em varios enderecos; a copia host era protegida em **um** endereco so, entao uma escrita por outra view nao gerava fault e a copia ficava velha - silenciosamente. Medido: 0,8-1,0 **milhao** de escritas por outra view em cinco minutos.
- **Como foi corrigido**: `8dd30ab` (codigo de myokex/victory-amd `c6dc4d8`, adaptando PR #115 de Spexivus, correcao de joroyt, parte de VIctory #1122 de tightfall): ao proteger um bloco, **todas** as views mapeadas daquela pagina ficam read-only; o handler devolve acesso a todas. `VICTORY_VIEW_GUARD=0` desliga.
- **Por que funciona**: a protecao e uma propriedade da **pagina fisica**, nao do endereco virtual; aplicar em todas as views transforma qualquer escrita em fault, de qualquer alias.
- **Dependencias**: o runtime precisa informar map/unmap (`title_memory_remapped`); ha limite `MANY_VIEWS` (paginas com views demais nao sao guardadas); `VICTORY_PAGE_WRITES` conta/abre os blocos sob escrita do storage.
- **Reutilizavel?** Sim, para qualquer emulacao de memoria compartilhada com alias (guest/host). Risco: custo de manter a lista de views e de reaplicar protecao; e um caminho quente, com 3 a 6 views por frame tipicamente.

### F-03 - Copia in-place sem pilha com handler que so aceita leitura

- **O que estava errado**: `ReadProcessMemory` no proprio processo custa o que custa uma syscall que trava e sonda cada pagina: 35 ms/frame para ~100 MB (3 GB/s) onde o `memcpy` faz o triplo.
- **Como foi corrigido**: `0b0074e`/`a253706` - `plaincopy.rs`: funcao em assembly (`victory_copy_guarded`, `rep movsb`, sem uso de pilha, preservando `rsi`/`rdi` em `r9`/`r10`), com dois pontos de retorno rotulados; um handler **primeiro da cadeia** olha cada access violation: se for **leitura** e o `RIP` for exatamente `victory_copy_guarded_at`, retoma em `victory_copy_guarded_fault` (retorna 0) e o chamador cai no kernel; escrita que falha **nao** e tomada.
- **Por que funciona**: o caso comum (pagina presente) e um `rep movsb` puro; o caso raro (pagina ausente) e uma excecao tratada no proprio handler, sem syscall. A restricao a leitura impede que o handler engula corrupcao de destino.
- **Dependencias**: x86-64; `LEAST=256` e `RECENT` (2 s) para nao capturar as sondagens; precisa de um caminho de fallback correto no kernel (`copy_mapped`), que tambem preenche zeros.
- **Reutilizavel?** Sim, com cuidado: `global_asm!` + `unsafe extern "C"` + handler vetorizado e especifico de plataforma. O par (limiar de tamanho, quarentena por bloco) e a parte transferivel e mais subestimada.

### F-04 - Substituir hash criptografico por fingerprint barato no caminho quente

- **O que estava errado**: o sync de descritores calculava BLAKE3 de cada registro para saber se mudou: 35-42 ms/frame em 250.000-300.000 registros, e o passe inteiro custava 70-220 ms/frame.
- **Como foi corrigido**: `9376fd6` - fingerprint de multiplicar-e-dobrar sobre o registro, no lugar; e, mais importante, **nao olhar** os slots que os draws leem por tabela (`VICTORY_HEAP_SYNC_TABLES=1` espelha tambem). Resultado: ~3 ms/frame.
- **Por que funciona**: o objetivo nao e resistencia a colisao criptografica, e detectar "mudou ou nao" em um registrador de descritor de 32-64 bytes; um fold multiplicativo separa bem entradas reais. A segunda metade (dispensar slots) elimina trabalho em vez de acelera-lo.
- **Dependencias**: o draw precisa reconstruir o descritor da tabela no momento do uso; `COPIED_TABLED` conta os dispensados.
- **Reutilizavel?** Sim, com a ressalva: colisao aqui significa **deixar de espelhar** um descritor mudado - um erro silencioso de imagem. O autor mediu em jogo, mas nao ha teste de colisao adversarial.

### F-05 - Hash de peca por grupo de 64 threads com dobra em ordem de lane

- **O que estava errado**: `CARD_COMPARE` dava **uma thread por peca de 64 KiB**, que percorria 4.096 loads de 16 bytes em serie. O tempo de uma pass era o de **uma** peca, independentemente de quantas pecas houvesse, e a placa nao rodava mais nada: "the card waits on one load at a time and runs next to nothing else".
- **Como foi corrigido**: `5557224` (PR #1014 de martindevbr) - `CARD_COMPARE_WIDE`: thread `t` do grupo 64 hasheia os passos `t, t+64, t+128...` (threads vizinhas leem bytes vizinhos, coalescido); a thread 0 dobra os 64 hashes de lane **em ordem de lane** e grava/compara. Uma peca por grupo => no maximo 16.385 grupos por dispatch (copias < 1 GiB).
- **Por que funciona**: transforma latencia serial em paralelismo massivo e mantem o hash **deterministico e igual entre store e compare**, porque a dobra e em ordem fixa.
- **Dependencias**: e **outro hash** - todo o processo tem de usar uma forma so (`card_hash_wide()` escolhido uma vez por `OnceLock`); `card_compare_groups` muda de `pieces.div_ceil(64)` para `pieces`; `VICTORY_CARD_HASH_LEN` muda o comprimento hasheado nas duas formas (`6d20eed`).
- **Reutilizavel?** Sim: e o padrao canonico de "hash paralelo com reducao ordenada" para comparar buffers grandes na GPU. **Risco medido e assumido**: `6d20eed` torna a forma **opt-in** porque "it has not run in a game on this tree yet, and it is another hash with another rare pattern of changes it cannot see".

### F-06 - Driver watch: transformar um sinal externo em fail-safe

- **O que estava errado**: a camada descobria a perda do device quando o device ja tinha ido. Havia, porem, um aviso previo **fora do processo**: entradas do driver de video no event log do Windows (`nvlddmkm`, evento 153), de 2,7 a 6,3 s antes, em todos os runs que perderam a placa; runs sem a entrada nao perderam nada.
- **Como foi corrigido**: `a253706` - `drvwatch.rs` assina o log (`EvtSubscribe` para eventos futuros), loga com relogio proprio, conta, e no primeiro evento marca `TRIPPED`; `draw::windows()` consulta `tripped()` **a cada chamada** (fora do `OnceLock`), entao as janelas caem para o caminho seguro pelo resto do run.
- **Por que funciona**: troca "perder a placa" por "andar mais devagar"; usa um canal de diagnostico do SO em vez de inferencia.
- **Dependencias**: provider do driver (NVIDIA observado); `VICTORY_DRIVER_WATCH=0` desliga; custo de abrir a assinatura no start.
- **Reutilizavel?** Muito. E um padrao de **canario externo** para qualquer camada que possa derrubar um device: assinar o log do driver e degradar preventivamente e mais barato que diagnosticar depois. Limitacao: e especifico de Windows/driver e nao cobre perda sem evento (run 277 teve "device removed" sem evento).

### F-07 - Levels on demand

- **O que estava errado**: a copia host de uma textura era uma textura **committed**: todos os niveis tomavam memoria da placa desde o primeiro upload. O titulo coloca a cadeia inteira no espaco de enderecos mas segura so alguns niveis (os menores, no inicio). Medido no run 189: 2,2-3,0 GB de 4,3-5,5 GB de copias host estavam em niveis cuja memoria do titulo **nao estava mapeada**, em ~1.600 copias; com 2,2-3,1 GB de render targets enchendo a placa, texturas que precisavam de copia nova esperavam por espaco (inclusive o rosto do personagem).
- **Como foi corrigido**: `8dd30ab`/`a26859f` com as correcoes do PR #747 de AscilCH (`tiles.rs`, 1.419 linhas): memoria da placa por nivel, niveis segurados recebem memoria so enquanto ha espaco e sao pedidos de novo (`VICTORY_LEVELS_ON_DEMAND=1`, **off**).
- **Por que funciona**: alinha a alocacao ao que o titulo realmente mantem, e nao ao tamanho declarado da cadeia.
- **Dependencias**: tabela de spans/`Levels min KB`; interage com `Rule::Start` (D-05), porque as duas coisas dependem do mesmo modelo de "o que esta mapeado".
- **Reutilizavel?** Sim, para qualquer titulo que use streaming por nivel (comum em consoles). **Estado**: rodou na placa pela primeira vez em `a26859f` (RTX 4070: 3,1 GB nao alocados, sem perda), mas continua off por default.

### F-08 - Warm-up de shaders com chave estavel por fonte do tradutor

- **O que estava errado**: cada build novo re-traduzia milhares de shaders do titulo, o que mantinha os primeiros minutos de todo run sem pipelines.
- **Como foi corrigido**: `8dd30ab` - `victory translate --warm <arquivo de hashes> --jobs N` traduz para o cache, no processador, tudo que o run vai precisar (4,5-6,5 min); a chave do cache passa a ser a fonte do tradutor, nao o executavel inteiro. O log de um run nomeia shaders por 16 digitos hex, que alimentam o arquivo de warm.
- **Por que funciona**: separa "o que ja foi traduzido" de "qual binario esta rodando"; um build que nao toca o tradutor comeca quente.
- **Dependencias**: `VICTORY_HOST_WAVE` e `VICTORY_VIEW_LIMIT` precisam ser iguais aos do run; `translation_fingerprint` precisa incluir tudo que muda a emissao (D-02).
- **Reutilizavel?** Sim, e um dos padroes mais transferiveis: **warm-up offline + chave por fonte** e uma pratica que qualquer camada de recompilacao deveria ter desde o inicio.

---


===== victory-fork Section I =====
## I. Conhecimento reutilizavel

### I.1 O mecanismo que permite varios builds privados divergirem do mesmo codigo

O achado estrutural deste fork nao e um algoritmo: e a **disciplina de switches de ambiente** que transforma um binario em uma familia de builds. Sao **219 nomes distintos** lidos por `env::var`/`env::var_os` (`Select-String` case-sensitive sobre `*.rs`), em 246 pontos de leitura. Juntos, eles cobrem: correcao, desempenho, memoria, diagnostico, validacao e selecao de host.

As regras que o codigo segue, e que explicam por que varios builds privados podem divergir sem forks de codigo:

1. **Default = o que ja rodou em jogo.** Um mecanismo novo nasce desligado; so vira default depois de um run real. Frases literais: "Off by default until a game run has carried it" (`shadow.rs`, `changed_list`), "All off by default; none has run in a game yet" (`6d20eed`), "off by default: it has not run in a game on this tree yet" (`card_hash_wide`).
2. **O switch diz que esta ligado, no log.** `card_hash_wide` loga ao ligar; `changed_list` loga a cada alternancia; `spread` loga os processadores extras; `probe_view_limit` loga o tamanho de heap escolhido. Isso e o que permite reconstruir a configuracao de um run a partir do log - e o que o `diagnostics/timing-run-2026-11-25.txt` faz.
3. **`=alt`: A/B dentro de um unico run.** Vinte segundos com, vinte sem, em turnos, cada troca logada. Resolve o maior problema de medicao do repositorio (dois runs nunca estao na mesma cena - ver D-14). Presente em `VICTORY_CHANGED_RUNS=alt`, `VICTORY_CARD_CHANGED_LIST=alt`, `VICTORY_ABSENT_ONCE=alt`, `VICTORY_SPREAD=alt`, `VICTORY_WIDE_REFRESH=alt`, `VICTORY_STAGING_POOL=alt`, `VICTORY_BACK_READS=alt`, `VICTORY_WINDOW_JUMP=alt`, `VICTORY_CARD_REHASH_RUNS=alt`, `VICTORY_WAVE_LOCAL`.
4. **O switch nao pode mentir sobre o artefato.** Toda flag que muda a emissao entra na chave do cache de shader (D-02, F-01) e o limite de heap do host tambem (`31714de`).
5. **Fallback dinamico, nao apenas estatico.** `drvwatch::tripped()` e `FILL_WAIT`'s `WAIT` mudam de valor **durante** o run: o primeiro erro de driver desliga janelas; o primeiro mismatch religa a espera. O switch e o default; o estado de execucao pode sobrepor.
6. **Pares que precisam andar juntos.** `changed_kept()` responde "manter a lista?" e `changed_list()` "usar a lista?"; `card_hash_wide()` escolhe a forma e `card_compare_groups()` muda o dispatch; `wide_on` e `deep_on` compartilham o gate. Sao os pontos onde um build privado quebra se ligar so metade.
7. **Switch morto fica, desligado, documentado.** O README tem uma secao fixa "Measured and found to give nothing (switches left in, off): `VICTORY_REFRESH_ONCE`, `VICTORY_ASYNC_PRESENT`, `VICTORY_VIEW_KNOWN`, ...". E um registro negativo - tao importante quanto o positivo, porque impede que o proximo build privado repita o experimento.

### I.2 Catalogo minimo de switches (por valor estrategico)

| Switch | Default | O que faz | Por que importa |
|---|---|---|---|
| `VICTORY_ASYNC_SUBMIT` | off | thread propria prepara e envia submissoes | tirou 257 de 292 ms da thread de render |
| `VICTORY_QUEUE2` | off | copy queue para fetch/up | espera do copy-back 125 -> 7 ms |
| `VICTORY_INDIRECT_WINDOW` | off | janela de registros indirect + clamp em lote | maior ganho de placa; exige o guard 2^23 |
| `VICTORY_INDIRECT_GATHER` | off | um clamp por lista para registros espalhados | 10,3 fps nas primeiras salas |
| `VICTORY_COPY_PLAIN` | off | copia in-place com handler | kernel do submit 44 -> 20 ms |
| `VICTORY_CARD_BUFFERS` / `_MIN_MB` / `_MB` / `_MIN_KB` | on / 16 / 512 / (64 off) | copias na memoria da placa | -18 ms de placa, -5 ms de frame com `_MIN_KB=64` |
| `VICTORY_CARD_HASH_LEN` | 0 | hash so dos bytes uteis do buffer | corrige agua preta; ~1/4 mais barato por lista |
| `VICTORY_CARD_HASH_WIDE` | off (opt-in) | hash por grupo de 64 threads | 35 -> 10 ms de placa; outro hash |
| `VICTORY_CARD_CHANGED_LIST` | off | lista de copias sujas em vez de varredura | ~3.900 copias, 10-18 submissoes/frame |
| `VICTORY_CHANGED_RUNS` | mascara | runs de bytes mudados por mascara de 64 bytes | -3,8 ms/frame na thread de submit |
| `VICTORY_WAVE_WIDE` | **off** | forma wave64 com barreiras de grupo | hang de device; so com `=1` |
| `VICTORY_SHADER_OPT` | 63 | passes de limpeza no DXIL (bit 64: loads agrupados) | -43% instrucoes, ~20 ms de GPU |
| `VICTORY_HEAP_SYNC` / `_TABLES` | on / off | espelhar registros copiados como bytes | 40.000 slots/frame |
| `VICTORY_STALE_TEXTURES` | `Start` | regra de invalidez de views | corrige texturas vizinhas |
| `VICTORY_HEAP_RECHECK` | on | reexame de textura enviada inteira | corrige rosto/cabelo |
| `VICTORY_LEVELS_ON_DEMAND` | off | memoria de placa por nivel mantido | -3,1 GB |
| `VICTORY_TEXTURE_BACK` | off | textura escrita por shader volta para a CPU | o barco flutua |
| `VICTORY_VIEW_GUARD` | on | guarda em todas as views da pagina | 0,8-1M escritas invisiveis |
| `VICTORY_PAGE_WRITES` | contado | abre guardas sob escrita do storage | 10k-50k blocos |
| `VICTORY_ABSENT_ONCE` / `ABSENT_MS` | off / 100 | nao reperguntar bloco nao mapeado | 690.000 perguntas/20 s |
| `VICTORY_DRIVER_WATCH` | on | assina event log do driver | canario de perda de device |
| `VICTORY_FAST_CORES` | on | threads da camada nos cores rapidos | 6% -> 0 em core lento |
| `VICTORY_SPREAD` | off | espalha threads presas do titulo | 11 threads em 2,5 cores |
| `VICTORY_FRAME_LOG` / `_CARD_METER` | diag | composicao de cada frame / tempo por lista | o instrumento que achou D-13 |
| `VICTORY_PROFILE` | off (diag) | profiler amostral interno | achou o submit path |
| `VICTORY_SHOT` | off | captura de frame dentro da camada | substitui RenderDoc, que quebrou |
| `VICTORY_GPU_TIMING` / `D3D12_DRED` | off | timing por lista / breadcrumbs | log higienizado publicado |

### I.3 Padroes reutilizaveis (com dependencias e riscos)

**I.3.1 - Lista de objetos sujos ativada por transicao vazio -> nao-vazio.** Problema: varrer N objetos a cada submissao para achar poucos mudados (3.900 copias x 10-18 submissoes/frame). Implementacao (`6d20eed`, `shadow.rs`): cada copia guarda `Weak<Shadow>` em sua propria estrutura; quando `dirty` passa de vazio para nao-vazio, empurra o weak para `CHANGED`; o consumidor faz `mem::take` da lista e `upgrade()` de cada weak. Ordem dos objetos pode diferir; os ranges sao identicos. Riscos: (a) a lista precisa ser **drenada** mesmo no modo varredura, senao cresce sem limite (o codigo faz isso explicitamente); (b) `Weak` exige que o objeto se registre uma vez (`me: OnceLock<Weak<Shadow>>`); (c) transicao perdida = objeto sujo nunca enviado - e por isso que o modo `alt` existe para comparar com a varredura.

**I.3.2 - Duas granularidades para a mesma pergunta.** `changed_runs` tem tres implementacoes no mesmo arquivo: byte a byte (`changed_runs_bytes`), mascara de 64 bytes (`changed_runs_wide`) e alternancia; e dois testes de equivalencia (`changed_runs_are_the_ones_a_walk_byte_by_byte_finds`, `changed_runs_are_exactly_the_bytes_that_differ`). E a forma mais barata de otimizar um diff sem perder a referencia: **manter a versao ingenua como oraculo testado**.

**I.3.3 - Comparar na GPU, buscar so o que difere.** `shadow.rs`: copia "before" na placa, passe de comparacao por peca de 64 KiB, lista de pecas diferentes, fetch so delas. Dependencia: assumir que shaders escrevem apenas em ranges declarados como escritos (o codigo declara essa premissa e o que acontece quando ela falha). Reutilizavel para qualquer readback caro.

**I.3.4 - Amostrar o que a CPU realmente leu, sem tocar em protecao.** `backreads.rs` (694 linhas): depois do store, as paginas de 4 KiB do trecho sao tiradas do working set com `VirtualUnlock` (Documentado: paginas nao locked), mantendo os bytes em memoria fisica porque a view propria da secao segura as mesmas paginas; o proximo acesso por endereco do titulo e um soft fault que o Windows resolve sozinho e que recoloca a pagina no working set, visivel por `QueryWorkingSetEx`. Medido: 5,4 us para trimar 64 KiB com seis threads rodando, 2,8 us para perguntar das 16 paginas, 0,89 us por pagina lida. **Nenhum byte muda, nenhuma protecao muda.** E a tecnica mais transferivel de todo o repositorio para responder "quem le esta memoria?" sem instrumentar o leitor.

**I.3.5 - Fingerprint no lugar de hash, com contagem de dispensados.** `COPIED_TABLED` conta quantos slots foram deixados para os draws; o log imprime por frame. Padrao: toda otimizacao "nao fazer" deve reportar **quanto** deixou de fazer, senao a proxima pessoa nao sabe se esta funcionando.

**I.3.6 - Sanitizar o que se publica.** `diagnostics/README.md` descreve o scrubbing: nomes de usuario/maquina, pastas, nomes de arquivo/produto/pack do titulo, title id, nomes de rede, nomes de shader e programa do titulo sao substituidos por placeholders; hashes de shader e pipeline ficam. Um log real, anonimizado, e mais util que uma tabela de numeros - e o fork publicou um.

### I.3.7 - Onde NAO seguir este repositorio

- **Nao copie a explosao de switches.** 219 nomes, 246 leituras, triplicacao de parsers (`match env::var(...) { Ok("1") => 1, Ok("alt") => 2, _ => 0 }` repetido dezenas de vezes) e pares que precisam andar juntos. Funciona para um operador unico; em equipe, vira um sistema de configuracao sem schema. O que vale copiar e a **regra** (default off, loga, alt, entra na chave), nao a forma.
- **Nao copie o padrao de merge sem teste na arvore mergeada** (D-17).
- **Nao confie em numero de fps de commit message.** Tres dos maiores ganhos anunciados eram de placa, nao de frame (E-07); um foi retratado (D-14).
- **Cuidado com `shortcut:`** (164 ocorrencias): sao aproximacoes conscientes do console, e varias sao especificas deste titulo e desta GPU.

---


===== xbox-emulator Section F =====
## F. Correcoes importantes

**F-01 — Ler o *stride* do elemento na tabela de bindings do container (FSSM).** *Problema:* o tipo HLSL do buffer era adivinhado pela extensao que a ISA toca, e o D3D12 deriva o stride do tipo, deslocando todos os elementos. *Como foi corrigido:* `fssm_buffer_strides()` parseia a tabela, exige `stride >= 4`, `stride % 4 == 0`, `register <= 0xffff`, e **descarta** registradores com strides conflitantes. *Por que funciona:* o stride do descritor original e exatamente o que o D3D12 vai reconstruir a partir do tipo HLSL; casar os dois elimina o mismatch na origem. *Dependencias:* `fssm_bind::parse`, `#289`. *Reutilizavel:* sim — a regra "derivar layout de buffer do metadado do container, nunca do padrao de acesso" vale para qualquer tradutor de ISA para API tipada. *Risco:* quando a tabela falta ou conflita, a heuristica volta e o erro volta silenciosamente; o ideal e **recusar** em vez de adivinhar (o projeto faz isso para raw+IDXEN, mas nao aqui). `b03b39b`, `hlsl.rs`.

**F-02 — `ByteAddressBuffer` para buffers raw, com recusa de `IDXEN`.** *Problema:* view raw (stride 0) lida como estruturada de 16 bytes. *Implementacao:* `BufRef::{Elem,Raw}` (`hlsl/bufref.rs`), endereco de byte em MUBUF/MTBUF, `Interlocked*` no endereco, `Load/Store` para sub-dword com mascara. *Por que funciona:* um buffer raw nao tem elemento; a unica unidade correta e o byte. *Reutilizavel:* sim, integralmente — e o mesmo raciocinio que qualquer camada de traducao D3D11/D3D12 precisa. *Risco:* `IDXEN` em raw passa a ser recusado, o que troca corrupcao silenciosa por falha alta; e o trade-off certo. `3e9676d`.

**F-03 — Guardas de IEEE contra o compilador do host (`tb_hz`, `tb_pz`, `tb_pzf`, `tb_fsub`, `tb_trunc64`).** *Problema:* o compilador do host dobra `x - x`, `x + 0.0` e `-0`, e descarta `fneg` dobrado em conversao `double(int64)`. *Implementacao:* helpers que reconstroem o resultado por operacoes inteiras (`asuint`, mascara de fracao, teste de classe NaN/inf) e forcam `+0` onde a ISA exige. `tb_trunc64` trunca por mascara de bits do expoente, sem passar por `int64`. *Por que funciona:* o resultado deixa de depender de provas algebricas que ignoram o bit de sinal do zero; o teste passa a ser bit-exato em WARP, NVIDIA e AMD. *Reutilizavel:* **sim, e um dos achados mais valiosos do repositorio** — qualquer tradutor ISA->HLSL/DXIL que emita aritmetica "natural" herda esse bug. *Risco:* custo de instrucoes; o projeto aplica so onde o caso e alcancavel (`pz` condicionado a operando zero). `65893a4`, `3f1bc0f`, `d0fabcb`.

**F-04 — `readlane_dst()`: uma funcao por contexto de codigo escalar.** *Problema:* o campo de destino de 8 bits tem significado diferente em `v_readlane_b32` (SGPR/M0/NULL/EXEC), em `sdst` de VOP3B e no carry-out inteiro. *Implementacao:* um decodificador unico, com a numeracao de GFX10.3, e recusa alta para o que nao esta mapeado. *Por que funciona:* elimina as tres tabelas divergentes. *Reutilizavel:* sim — o padrao "um decodificador por classe de campo, nao por instrucao" e o que impede a reincidencia. `9b7c93a`.

**F-05 — Regra de largura pelo opcode, nao pelo sufixo.** *Problema:* sufixo `_b64` implicava destino de 64 bits. *Implementacao:* `i32_result_of_64()` centraliza a excecao e os quatro sitios a consultam. *Reutilizavel:* sim; e um caso concreto de "semantica do opcode vence convencao de nome". `8f71091`.

**F-06 — Leitura de memoria de recurso colocado com recuperacao de falha (SEH), em vez de copia.** *Problema:* ler memoria de textura colocada que pode ser *decommitada* por outra thread durante a leitura (corrida com o titulo) causava crash; a primeira solucao (`595eb3a`) **copiava** com *snapshot*, cara e ainda sujeita a janela. *Implementacao:* `guard.rs` (242 linhas) expõe uma chamada que recupera a falha de acesso e devolve "nao disponivel"; `upload.rs` deixa de copiar. *Por que funciona:* a leitura acontece uma vez, no lugar, e uma falha vira **skip do upload** em vez de terminacao do processo. *Reutilizavel:* sim para qualquer camada que leia memoria de GPU compartilhada com o convidado. *Risco:* depende de SEH (`__try`/`__except` no Windows); nao e portavel. `5d5bc33` (+ `fe391fe`).

**F-07 — Stand-in de objeto COM para API que "nunca falha" no console.** *Problema:* `GameInputCreate` pode falhar no host, mas o titulo nao checa. *Implementacao:* objeto estatico com vtable de 22 metodos, tokens de registro unicos, `E_NOTIMPL`/`E_NOTFOUND` reais, e adocao condicionada a nao haver objeto real ja patchado. *Por que funciona:* preserva o contrato do console (nunca nulo) sem mentir sobre capacidades (cada metodo devolve um codigo real). *Reutilizavel:* **sim, e um padrao geral** para qualquer API de plataforma cujo contrato seja "sempre sucede". `146286e`.

**F-08 — Conformance contra o binario real, como harness.** *Problema:* "o que o runtime do console faz" era conjectura. *Implementacao:* o mesmo conjunto de cenarios roda contra o emulador e contra o `System32\xgameruntime.dll` carregado por `LoadLibraryExW` + `InitializeApiImpl(0x4a61, 0x2712)` + `QueryApiImpl`, **sem os hooks do emulador**; um `const DIFFERS` lista os cenarios divergentes e os **pula** com motivo (ou roda com `TOMBOX_XSYS_ALL=1`). *Por que funciona:* transforma comportamento de API em teste executavel e faz a divergencia ser um dado, nao uma opiniao. *Reutilizavel:* sim, com a ressalva de que depende de o runtime real existir na maquina (senao o teste faz `SKIP`). `acfede3`, `c3292cc`, `e7377c9`, `883d1c8`, `8dce1e7`.

**F-09 — GBV como oraculo de traducao.** *Problema:* erros de layout de descritor sao invisiveis em WARP e em comparacao de imagem. *Implementacao:* `TOMBOX_D3D12_GBV=1` habilita `ID3D12Debug1::SetEnableGPUBasedValidation`, opt-in, com o IID conferido por teste contra `d3d12sdklayers.h`. *Por que funciona:* a validacao de GPU compara **views do titulo** com **tipos do shader traduzido**, exatamente a fronteira onde a traducao pode errar. *Reutilizavel:* sim. `8c481f4`.

**F-10 — Prelaunch/`pack` de shaders com chave de modo.** `pack_key::Mode` + `shader_cache` + `xshader_prelaunch` permitem pre-traduzir e servir do pacote, com o custo de a traducao "ao vivo" (e seus avisos, como `gather_lod_blind`) nao acontecer para shaders do pacote. *Reutilizavel:* sim como estrategia de latencia; *risco:* perde telemetria (o proprio `d2dad0c` registra isso). `shader_xlat.rs`, `pack_key.rs`.


===== xbox-emulator Section I =====
## I. Conhecimento reutilizavel

### I.1 Arquitetura do tradutor de shaders (o nucleo do projeto)

O que torna este repositorio diferente de uma camada de compatibilidade comum e que **o programa de GPU do convidado e codigo nativo da maquina do console**, e nao um API call. A cadeia, documentada em `crates/tombox-xshader/src/lib.rs:1-16` e em `d3d12_xs/src/shader_xlat.rs:1-6`:

```
DXBC  ->  chunk DXIL (com o bitcode removido, marcado NOBC)
      ->  chunk DXIL substituido por payload XDAT (nativo do console)
      ->  zlib inflate
      ->  container FSSM  (cabecalho + tabela de bindings + ISA)
      ->  microcodigo RDNA2 (gfx10xx)
      ->  decodificador ISA  ->  IR de instrucoes
      ->  emissor HLSL (SM6, as_6_5/ms_6_5/ps_6_x...)
      ->  DXC (dxcompiler.dll)  ->  DXIL
      ->  cache por hash FNV-1a (+ pack de prelaunch)
```

Componentes reaproveitaveis, cada um com um problema bem delimitado:

1. **`extract()` + `fssm_bind::parse()`.** O container do console carrega o que o driver original sabia: o *estagio de hardware*, o *slot* de cada estagio, a **tabela de bindings com registro/classe/stride**, e um byte de contagem de user SGPR (0xd6). Isso resolve tres classes inteiras de bug de traducao (D-01, D-03, e os samplers literais de #329) sem heuristica. **Licao transferivel:** quando o binario do convidado vem de um driver real, o *metadado do driver* e a fonte de verdade do layout; o padrao de acesso na ISA e apenas um palpite.
2. **`meta.rs` / `dxil_meta.rs` (PSV0).** Le nome/tipo/registro/mask de assinaturas de entrada/saida, primitiva de entrada e topologia de saida de GS, `numthreads` de CS, e as uniões de **mesh** (`parse_psv0_mesh`) e **tess** (`parse_psv0_tess`, `10834855`). O PSV0 e o equivalente ao "reflection" do DXIL e e o que permite reconstruir a interface do estagio na HLSL sem root signature.
3. **Inferencia de bindings em camadas, com fallback explicito.** Ordem observada: root signature estatica -> tabela FSSM -> user data por chute de estagio -> retry por `s_swappc`. Cada camada **recusa com nome** quando nao fecha (`"buffer in table of kind None"`, `"base sN is not a root table pointer"`, `"not a root pointer"`). O padrao "camadas com recusa nomeada" e o que permite rodar 105.506 shaders e saber *por que* cada um falhou.
4. **`rootmem.rs` (ABI de root memory).** Implementa o `FORCE_MEMORY_BASED_ABI`: root constants e descritores de CBV/SRV/UAV lidos por `s_load` em `s[0:1]` com offset constante, mapeados para a root signature. Regra de ouro descoberta por medicao: **todo PSO com estagio de amplificacao usa esse ABI**, sem deteccao heuristica (`3d90f6f`).
5. **Modelo de aneis para mesh/amplification (`amp.rs`, `mesh.rs`).** O AS do console nao "desenha": escreve em dois aneis em memoria (`args`, `payload`) e o driver emite `DISPATCH_DIRECT` + `DispatchMesh`. O tradutor fixa `s2/s3` como bases de anel, mapeia stores `flat/global` do grupo para `groupshared` (`tb_args`/`tb_pl`), conta qualquer outro endereco como **falha** (e nao como escrita silenciosa), e emite `DispatchMesh(tb_args[0], max(tb_args[1],1), 1, tb_pl)`. ABI do MS: `v5 = workgroup vertex id`, `s3[27:24] = wave index`, `s_sendmsg 9` (`GS_ALLOC_REQ`) com `m0 = prims << 12 | verts`, `exp pos 12` / `clip-cull 13-15`, `exp prim 20`.
6. **Modelo de modo numerico (`hlsl/mode.rs`).** `MODE` (FP_ROUND, FP_DENORM, DX10_CLAMP, IEEE) e derivado de `PGM_RSRC1` e propagado por `s_setreg`; `reachable`/`analyze` comecam dele e `tb_hw1` e inicializado com ele. **Licao:** o comportamento de denormal/arredondamento **nao e global**, e estado por onda — um tradutor que fixa `0xf0` acerta por acidente em muitos shaders e erra em todos os que dependem de modo.
7. **Refusals como contrato.** O emissor prefere falhar a emitir errado: `pck` so em imagem usada tambem com atomics 32/64 bits (porque loads tipados sempre convertem pelo formato da view), `D16` sem forma pck, atomicos float, `R128/TFE/LWE`, raw+IDXEN. **Licao:** num tradutor de ISA, "nao suportado" com motivo nomeado vale mais que "aproximado".
8. **Prova bit-exata.** `tests/exec*.rs` compilam o HLSL com DXC e **executam** em WARP (`TOMBOX_EXEC_HW=1` para GPU real), comparando bits; `tests/isa_sweep` varre mnemonicos; `src/trans32/amd.rs` embute modelos de `v_log/exp/sin/cos` vindos do rocjitsu (MIT). Este e o ativo mais reutilizavel do repositorio: **um harness que transforma "o shader traduzido esta correto" em teste executavel**.

### I.2 Shims de sistema: onde o projeto se separa de uma camada estilo Wine/XCL

Uma camada estilo Wine (e, pelo que se pode inferir do nome, o XCL do mesmo ecossistema) resolve o problema **na fronteira de API/syscall do sistema operacional**: intercepta chamadas Win32/WinRT, mapeia para o SO hospedeiro, reimplementa objetos COM e entrega o trabalho grafico a API do host por traducao de *chamadas* (D3D->Vulkan, etc.). O programa do convidado e tratado como codigo x86 que so precisa de um ambiente.

O xbox-emulator precisa de tudo isso **e mais tres coisas que uma camada Wine nao tem**:

1. **O programa de GPU do convidado nao e uma chamada de API, e binario de hardware.** Nao ha "D3D11 -> Vulkan": ha ISA RDNA2 -> HLSL -> DXIL. Isso obriga a reconstruir **layout de recurso, ABI de estagio, modo numerico e semantica de cada opcode** — e a manter exatidao bit a bit onde o hardware do console difere do PC (denormals, NaN, `-0`, arredondamento de blend, `MIMG pck`, `SDWA`, GDS, atomics de DS). Uma camada Wine pode dizer "o comportamento e o do driver"; aqui o comportamento e o **do console**, e o driver do host e um adversario.
2. **A ABI de objeto do console nao e a do PC, e muda por versao de SDK.** `d3d12_xs` remapeia *slots de vtable*: 127 (`CreateCommittedResource3`), 133 (`CreatePlacedResourceX` com desc 1) para chamadores GXDK 2504+ (`945731f`), 131/132 que mudam de sentido conforme a edicao (`6d19943`), e uma tabela de shim que cresceu de 128 para 256 entradas para que os slots existam. Pior: o **significado** de um slot depende da edicao do SDK com que o modulo chamador foi compilado, lida do campo `_xbld_edition_sdktype=GXDK,<edition>` na secao `.xbld` do PE do chamador, com o chamador identificado pelo primeiro endereco de retorno fora do emulador (`cl_edition.rs`, 430 linhas). Nao existe equivalente disso em Wine.
3. **O modelo de memoria e de recursos e do console.** Heaps colocados, aliasing de VA, `MSAA` com layout proprio, *tile patterns* (tiling Scarlett consultavel por `GetResourceTiling`, `62c525d`), spans de recurso que precisam ser rastreados e liberados quando o recurso morre (`fa9f1ca`). O PC D3D12 nao expoe essas garantias, entao o shim mantem **bookkeeping proprio** (`alias.rs`, `placed_offset.rs`, `gpu_va.rs`) e as vezes precisa ler memoria que o titulo pode estar desmapeando (F-06).

Em contrapartida, o projeto tambem faz o que uma camada Wine faz, e faz com o mesmo metodo: `compat-common` reimplementa XAsync/XTaskQueue/XSystem/XUser/XGameSave/gamepad/fs/registry/redes; `xg_xs` reimplementa o runtime grafico de baixo nivel; `xcrdapi` reimplementa DirectStorage (incluindo o decodificador **BCPack** com rANS, `crates/compat/xcrdapi/src/bcpack`, portado de `bcpack-rs` e `silicon-rans`). A diferenca de postura e a **fonte de verdade**: aqui ela e medida contra o binario real (`InitializeApiImpl(0x4a61,0x2712)` + `QueryApiImpl` do `xgameruntime.dll`) e contra silicio real (`tools/rdna2-hwprobe`), com a divergencia registrada em `const DIFFERS` em vez de tolerada.

### I.3 Padroes de engenharia reaproveitaveis (independentes de Xbox)

| Padrao | Problema que resolve | Onde | Como adaptar |
|---|---|---|---|
| Falha alta com motivo nomeado | traducao que "funciona" e corrompe | `rectlist::refuse`, refusals de MIMG/raw | trocar todo `unwrap_or(default)` de parsing por erro com contexto |
| Metadado do produtor como fonte de verdade | inferencia de layout por padrao de acesso | `fssm_bind`, PSV0 | se o binario foi gerado por um driver, leia o que o driver sabia |
| Conformance contra o binario de referencia | semantica de API conjecturada | `gdk_*_conformance(_real)` | carregue o DLL real, rode os mesmos cenarios, liste `DIFFERS` |
| Validacao de GPU como oraculo de traducao | erro de descritor invisivel em WARP | `TOMBOX_D3D12_GBV` | habilite GBV/`VK_LAYER_KHRONOS_validation` e trate o relatorio como teste |
| Guarda de IEEE contra o compilador do host | dobramento algebrico muda bits | `tb_pz`, `tb_hz`, `tb_trunc64` | nunca emita `a - b`/`a + 0` crus quando o bit de zero importa |
| Teste por contador, nao por imagem | duplicacao de trabalho invisivel | query de oclusao em `tests/amp.rs` | meça invocacoes/amostras, nao so pixels |
| Fuzz de caminho com alfabeto Unicode | panic por fronteira de caractere | `fuzzed_console_paths_never_leave_their_drive` | qualquer parser de caminho de entrada hostil |
| Validacao com estado entre entradas | colisao em filesystem case-insensitive | `tombox-archive::validate` | normalize antes de comparar; trate colisao como bloqueio |
| Teste que espera assincronia do SO | flaky "de timing" que e comportamento real | `ab6d485` | meça o efeito observavel, depois espere com limite |
| Mutacao que derruba o teste | teste que passa por acidente | varios PRs (`d2dad0c`, `bd185fa`, `753e851`) | para cada fix, escreva a mutacao que o quebra |
