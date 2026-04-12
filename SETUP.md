# HES v3 — Guia de Setup

> Como instalar e configurar os skill-files nos diferentes ambientes de IA.

---

## ◈ ESTRUTURA DE ARQUIVOS (o que você vai instalar)

```
seu-projeto/
├── SKILL.md                       ← coloque na raiz do projeto
│
└── skills/
    ├── 00-bootstrap.md
    ├── 01-discovery.md
    ├── 02-spec.md
    ├── 03-design.md
    ├── 04-data.md
    ├── 05-tests.md
    ├── 06-implementation.md
    ├── 07-review.md
    ├── legacy.md
    ├── error-recovery.md
    ├── refactor.md
    └── report.md
```

> Os arquivos `.hes/` são gerados automaticamente pelo bootstrap.
> Você só instala manualmente os arquivos acima.

---

## ◈ AMBIENTE 1 — CLAUDE CODE (CLI)

### Instalação

```bash
# Na raiz do projeto
mkdir -p skills

# Copiar os arquivos HES v3 para o projeto
cp /caminho/para/hes/SKILL.md ./SKILL.md
cp /caminho/para/hes/skills/*.md ./skills/
```

### Uso

O Claude Code lê automaticamente o `CLAUDE.md` no início de cada sessão.
Após o bootstrap, `.claude/CLAUDE.md` vai instruir o agente a ler `SKILL.md`.

```
# Na primeira sessão — aciona o bootstrap:
/hes

# Nas sessões seguintes — retomada automática:
/hes status
```

### Configuração `.claude/CLAUDE.md` (gerada pelo bootstrap)

O bootstrap gera automaticamente. Mas se quiser instalar manualmente antes:

```markdown
# HES — Harness Engineer Standard

Ao iniciar qualquer sessão:
1. Ler SKILL.md integralmente
2. Identificar estado via .hes/state/current.json
3. Carregar o skill-file correto
4. Executar a ação da fase atual
```

---

## ◈ AMBIENTE 2 — CURSOR / WINDSURF / COPILOT

### Instalação

Mesma estrutura de arquivos. A diferença é como o agente é instruído a ler:

```
# No início de cada conversa com o agent:
"Leia SKILL.md e identifique o estado atual do projeto"

# Ou configure um snippet de prompt de sistema no Cursor:
Configurações → AI → System Prompt:
"Sempre que eu disser /hes, leia SKILL.md e execute o protocolo HES v3"
```

### Alternativa — `.cursorrules`

```
# .cursorrules
Ao receber /hes ou qualquer comando de engenharia:
1. Ler SKILL.md na raiz do projeto
2. Ler .hes/state/current.json
3. Carregar o skill-file correspondente ao estado atual
4. Seguir as instruções do skill-file sem desvios
```

---

## ◈ AMBIENTE 3 — CLAUDE.AI (Web / App)

O HES v3 pode ser usado via **Projects** do Claude.ai:

### Configuração via Project Instructions

Em **Settings → Project → Instructions**, adicionar:

```
Você é um Harness Engineer (HES v3).

Ao receber /hes ou ser invocado para tarefas de engenharia:
1. Solicite ao usuário que cole o conteúdo de SKILL.md
2. Leia e siga as instruções do orquestrador
3. Solicite o conteúdo do skill-file indicado pelo orquestrador
4. Execute a fase correspondente

Se o usuário colar um skill-file diretamente, execute-o imediatamente.
```

### Uso no chat (sem Project)

Cole o conteúdo do SKILL.md no início da conversa:

```
Vou compartilhar o sistema HES v3. Leia e siga as instruções:

[cole o conteúdo de SKILL.md aqui]

Estado atual: [cole o conteúdo de current.json aqui]
```

---

## ◈ AMBIENTE 4 — OPENHANDS / CODEX CLI / GEMINI CLI

Ferramentas com suporte a system prompt ou arquivo de configuração:

```bash
# OpenHands — via AGENT.md na raiz
cp SKILL.md AGENT.md

# Codex CLI — via --system-prompt flag
codex --system-prompt "$(cat SKILL.md)"

# Gemini CLI — via .gemini/system.md
mkdir -p .gemini
cp SKILL.md .gemini/system.md
```

---

## ◈ FLUXO DE USO — SESSÃO A SESSÃO

### Sessão 1 (projeto novo)

```
1. Usuário: /hes
2. Agente lê SKILL.md → detecta ZERO → carrega skills/00-bootstrap.md
3. Bootstrap faz 4 perguntas
4. Gera toda estrutura .hes/
5. Sugere: "Qual é a primeira feature?"
6. Usuário: "quero implementar autenticação JWT"
7. Agente carrega skills/01-discovery.md → inicia Discovery
```

### Sessão 2 (retomada)

```
1. Usuário: /hes status
2. Agente lê current.json → mostra estado de todas as features
3. Usuário: "continuar"
4. Agente carrega o skill-file da fase atual automaticamente
```

### Sessão N (paralelo de features)

```
1. Usuário: /hes switch billing
2. Agente atualiza active_feature → carrega skill da fase atual de "billing"
3. Ao terminar: /hes switch payment → retorna ao payment
```

---

## ◈ COMO INVOCAR UM SKILL-FILE DIRETAMENTE

Em qualquer momento, você pode invocar um skill-file específico:

```
"Leia skills/03-design.md e refaça o design do módulo de pagamento"
"Tivemos um erro de migration — carregue skills/error-recovery.md"
"Quero refatorar o PaymentService — skills/refactor.md"
"Gere o relatório de ciclos — skills/report.md"
```

O agente carrega APENAS aquele skill-file, sem precisar passar pelo orquestrador.
Isso é útil quando você sabe exatamente o que precisa.

---

## ◈ DICAS DE MANUTENÇÃO

**Versionar os skill-files com o projeto:**
```bash
git add SKILL.md skills/
git commit -m "chore: instalar HES v3.0.0"
```

**Evoluir skills conforme aprendizados:**
- Lições promovidas do `lessons.md` → adicionar no skill-file correspondente
- Sempre que uma fase parecer lenta → revisar o skill-file daquela fase

**Atualizar a versão:**
Mudar o campo `version` no header do `SKILL.md` a cada evolução significativa.

---

*HES v3.0.0 — Setup Guide | Josemalyson Oliveira | 2026*
