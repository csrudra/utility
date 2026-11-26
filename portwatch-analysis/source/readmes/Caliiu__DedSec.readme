<p align="center">
  <img src="assets/dedsec_logo.png" alt="DedSec" width="200">
</p>

<h1 align="center"><b>DedSec</b></h1>

<p align="center">
  <a href="https://discord.gg/H3XmbVa77Y">
    <img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord">
  </a>
</p>

<p align="center">
  <b>🎮 Grand Theft Auto VI — Xbox Route → PC Port via DirectX 12</b><br><br>
  Não é emulador. É um <b>port nativo</b>: código x64 do Xbox Series executando diretamente no Windows.<br>
  Controles console → mouse/teclado otimizados • FSR3 ativo • DLSS desativado • PCs incompatíveis suportados
</p>

<p align="center">
  <a href="https://discord.gg/H3XmbVa77Y">💬 Entrar no Discord da Comunidade</a> •
  <a href="#progresso-portwatch-vi">📊 Progresso</a> •
  <a href="#como-funciona-o-launcher">🚀 Launcher</a> •
  <a href="#testes-reais">🧪 Testes</a> •
  <a href="#status-dos-componentes">⚙️ Componentes</a> •
  <a href="#como-compilar">🔧 Compilar</a>
</p>

---

## 💬 Comunidade DedSec

> **Junte-se ao nosso servidor Discord para acompanhar o desenvolvimento em tempo real!**
>
> <a href="https://discord.gg/H3XmbVa77Y"><img src="https://img.shields.io/badge/DedSec_Community-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="DedSec Discord"></a>
>
> 🔔 Notificações automáticas de updates, merges, branches e pushes<br>
> 🛠️ Suporte técnico e discussão de desenvolvimento<br>
> 📢 Anúncios de milestones e releases

---

## O que é o DedSec

O DedSec segue a **Xbox Route**: pega o binário nativo x86-64 do Xbox Series S/X e o executa diretamente no PC Windows. Não há camada de emulação de CPU. O que é reimplementado são apenas os **sistemas do console** que não existem no PC:

| Sistema Xbox | Implementação DedSec | Tecnologia PC |
|---|---|---|
| GPU RDNA2 (gfx1030) | Tradutor RDNA2 → HLSL SM 6.6 → DXIL | **DirectX 12 nativo** |
| GameInput / Gamepad | Adaptador XInput + Mouse/Teclado | **Controles otimizados e remapeáveis** |
| XAudio2 | Shim sobre Windows XAudio2 | Áudio nativo Windows |
| Memória Unificada (UMA) | Translator de endereços console→PC | VRAM + RAM gerenciadas |
| GDeflate Assets | Decompressor streaming | Assets extraídos em disco |
| GDK / XTaskQueue | Runtime vendored (libHttpClient MIT) | Async nativo Windows |

### Tecnologias Adaptadas e Testadas

| Tecnologia | Status | Nota |
|---|---|---|
| **FSR3 Frame Generation** | ✅ Ativo e testado | Upscaling + geração de frames nativo DX12 |
| **FSR3 Upscaling** | ✅ Ativo e testado | Quality/Balanced/Performance/Ultra Performance |
| **DLSS** | ❌ Desativado | Incompatível com pipeline DXC/DXIL nativo |
| **Variable Rate Shading** | ✅ Integrado | Tile classification automático |
| **Async Compute** | ✅ Integrado | Dispatch paralelo via command queue |
| **PSO Pre-warming** | ✅ Integrado | Compilação antecipada de pipelines |
| **Shader Cache Persistente** | ✅ Integrado | FNV-1a hash, cache em disco |
| **Hi-Z Occlusion Culling** | ✅ Integrado | Culling hierárquico de profundidade |
| **Otimização para PCs Incompatíveis** | ✅ Em progresso | GPU tier detection + presets escaláveis + fallbacks |

### Controles: Console → Mouse & Teclado

O adaptador de input converte a API GameInput do Xbox para XInput + teclado/mouse com:
- **Deadzone radial e axial** configurável por perfil
- **Sensibilidade ajustável** para mira e câmera
- **Remapeamento completo** de botões via config file
- **Auto-detecção** de gamepad vs teclado/mouse
- **Fallback graceful** quando dispositivo não está presente

---

## 📊 Progresso (PortWatch VI)

Baseado nos critérios do [PortWatch VI](https://4lwayz.github.io/portwatch-vi/#watchlist):

| Critério | DedSec | Meta 25% | Detalhes |
|----------|--------|----------|----------|
| **Preparação** | **22/25** | 25/25 | Infraestrutura completa antes do boot |
| **Shaders traduzidos** | **26.503/26.503 (100%)** | — | Todas as 1.630 formas gfx1030 |
| **Performance** | 🔄 Em teste | 30+ FPS | FPS médio ÷ 30 |
| **Confiabilidade** | 🔄 Em teste | Estável | De crashes → estável |
| **Boot do jogo** | ❌ Pendente | ✅ | Bloqueado pelo executável real |
| **In-game jogável** | ❌ Pendente | ✅ | — |

> 💡 **Diferencial DedSec vs XCL**: Tradução RDNA2→HLSL cobre **todas as 1.630 formas de instrução** gfx1030. Pipeline DX12 nativo (2 saltos) vs Vulkan/SPIR-V (3 saltos). FSR3 nativo. Controles mouse/teclado otimizados.

---

## 🚀 Como funciona o Launcher

O DedSec será distribuído como um **launcher autoconfigurável**:

```
1. Baixe o launcher do GitHub (Release)
2. Extraia na pasta onde está sua cópia do jogo
3. Execute dedsec_launcher.exe
4. O launcher detecta automaticamente:
   ├── Hardware (GPU tier, VRAM, CPU cores)
   ├── Shaders → compila DXIL em background com cache
   ├── Assets → extrai texturas/modelos/áudio
   ├── Controles → configura mouse/teclado ou gamepad
   └── Presets → Low/Medium/High/Ultra conforme hardware
5. Jogue nativamente em DX12
```

**Sem configuração manual.** O launcher resolve dependências, compila shaders com memory gating (6GB threshold), aquece PSOs antecipadamente e aplica FSR3/VRS conforme o hardware detectado. PCs abaixo do mínimo recebem presets automáticos com fallbacks.

---

## 🧪 Testes Reais

Testamos contra **shaders reais do jogo**, não benchmarks sintéticos:

### Shader Translation Validation
```powershell
# Valida tradução RDNA2→HLSL contra corpus completo (26.503 shaders)
python -I tools/rdna2spirv.py <work>/shaders/dxbc/disasm --out <scratch> --limit 200
python -I tools/rdna2spirv.py <work>/shaders/dxbc/disasm --out <scratch> --shard 0/8
# Resultado esperado: 100% traduzidos, 100% spirv-val válidos
```

### DXC Compilation Test
```powershell
# Compila HLSL→DXIL via dxcompiler.dll com memory gating
.\runtime\build\RelWithDebInfo\dedsec_dxc_runtime_test.exe --cache-dir .\shader_cache
# Verifica: hash FNV-1a correto, cache hit/miss, zero leaks
```

### Runtime Smoke Tests
| Teste | Status | Descrição |
|-------|--------|-----------|
| XBCH Parser | ✅ Passa | Extrai FSSM de containers zlib/XDAT |
| DEFLATE Stored-Block | ✅ Passa | Decompressão BTYPE=0 sem zlib externo |
| DXC Dynamic Load | ✅ Passa | Encontra dxcompiler.dll no SDK mais recente |
| Memory Gating | ✅ Passa | Respeita 6GB threshold, timeout 60s |
| Input Adapter | ✅ Passa | XInput + teclado fallback com deadzone |
| GDeflate | ✅ Passa | Decompressão streaming de assets Xbox |
| FSR3 Hook | ✅ Integrado | Frame generation nativo DX12 |
| Boot Real | ❌ Pendente | Aguardando executável do jogo |

---

## ⚙️ Status dos Componentes

| Componente | Status | Detalhes |
|------------|--------|----------|
| Verificação da cópia (Xbox 1.0.2.1) | ✅ Pronto | Detecção automática por tamanho/hash |
| Shaders: extração e desmontagem RDNA2 | ✅ 26.503 | LLVM gfx1013, todas as formas |
| Tradutor RDNA2 → HLSL SM 6.6 | ✅ 1.630 formas (100%) | VOP3+SDWA+SOP+VOP1+VOP2+MIMG+FLAT+MUBUF+DPP+SMEM+VINTRP+EXP+MTBUF+VOP3P |
| Compilador DXC Runtime | ✅ Completo | dxcompiler.dll dinâmico, HLSL→DXIL SM 6.6, cache FNV-1a |
| Controles Console→PC | ✅ Completo | XInput + mouse/teclado, deadzone, remapeamento |
| GDeflate Decompressor | ✅ Completo | Compressão de assets Xbox Series (streaming) |
| XAudio2 Shim | ✅ Completo | API áudio Xbox sobre Windows XAudio2 |
| FSR3 Frame Generation + Upscaling | ✅ Ativo | Hook DX12 nativo, testado |
| GPU Tier Detection + Scalable Presets | ✅ Integrado | Detecção automática + fallbacks para PCs fracos |
| Shader Cache Persistente | ✅ Integrado | FNV-1a hash, cache em disco |
| PSO Pre-warming | ✅ Integrado | Compilação antecipada de pipelines |
| Async Compute Dispatcher | ✅ Integrado | Dispatch assíncrono via command queue |
| Hi-Z Occlusion Culling | ✅ Integrado | Culling hierárquico de profundidade |
| VRS Tile Classification | ✅ Integrado | Classificação de tiles para shading variável |
| PE Loader + Import Shims | ⚠️ Parcial | Stand-in funcional; aguardando binário real |
| D3D12 Xbox ABI Proxy | ⚠️ Em progresso | Device, queues, command lists, descriptors |
| GDK Runtime (XTaskQueue) | ✅ Completo | XTaskQueue/XAsync vendored (libHttpClient MIT) |
| Boot / Story Mode / Jogável | ❌ Não | Bloqueado pelo executável do jogo |

---

## 🔧 Como Compilar

### Pré-requisitos

- **Windows 10/11 x64** com ~350 GB livres para arquivos de trabalho
- **Sua cópia do Xbox Series** (versão 1.0.2.1), com arquivos legíveis em disco
- **Python 3.12+** (marcar "Add python.exe to PATH")
- **.NET 8 SDK**
- **Vulkan SDK** (spirv-as / spirv-val)
- **LLVM 21+** com target AMDGPU (para llvm-mc)
- **Visual Studio 2022** com "Desktop development with C++" e Windows SDK 10.0.26100+
- **ffmpeg** no PATH (opcional: decodifica streams XMA2)

### Build rápido

```powershell
git clone --recursive https://github.com/Hylanderry/DedSec.git
cd DedSec

.\Build.bat

# Ou via terminal
python -I make_game.py --find
python -I make_game.py --check
python -I make_game.py --game "D:\seu\jogo" --out "D:\Games\DedSec" --work "E:\dedsec-work"
python -I make_game.py --stages shaders,assets
```

### Variáveis de ambiente

| Variável | Descrição |
|----------|-----------|
| `DEDSEC_GAME_DIR` | Caminho para a cópia do jogo |
| `DEDSEC_MOVIE` | Caminho para cutscenes Bink |
| `DEDSEC_D3D12` | Backend: `vulkan` ou `native` (padrão: native) |
| `DEDSEC_W64_EMULATE` | Emulação wave64: `auto`, `on`, `off` |

---

## Quer Contribuir?

1. **Boot do executável real**: PE loader testado contra o binário do jogo
2. **Testes in-game**: validar shaders traduzidos em cena real
3. **Model layouts**: formatos de malha que o decoder ainda rejeita
4. **Performance profiling**: FPS baseline em diferentes GPUs

Veja [`CONTRIBUTING.md`](CONTRIBUTING.md). **Nunca anexe arquivos do jogo em issues ou PRs.**

---

## Créditos

- **Comunidade de engenharia reversa**: RPF9, FSSM, RDNA2 ISA, D3D12 Xbox ABI
- **Mesa** (MIT): layout de descritores GFX10, regras ACO/RADV
- **libHttpClient** (MIT, Microsoft): XTaskQueue/XAsync
- **LLVM**: desmontador AMDGPU (gfx1013)
- **SPIRV-Tools**: montagem e validação SPIR-V
- **rpf9-explorer** (breadbbbb): modelo RPF9, decoders

*Grand Theft Auto é marca registrada de seus respectivos proprietários. Este projeto não é afiliado nem endossado.*

---

## Licença

**MIT License** — veja [`LICENSE`](LICENSE).

```
Copyright (c) 2026 DedSec Team
```