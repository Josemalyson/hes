# HES Skill — 08: Progressive Analysis

> Skill carregada quando: análise de codebase grande (>50 arquivos) ou retomada de sessão interrompida.
> Objetivo: análise incremental com preservação de estado entre sessões.
> Pré-condição: projeto existe com código para analisar.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Verificar se .hes/state/analysis-state.json existe:
   → Sim: sessão anterior interrompida — seguir PASSO 5 (recuperação)
   → Não: análise nova — seguir PASSO 1 (gerar árvore)
2. Se state existe, carregar e mostrar progresso:
   → Arquivos analisados: X/Y
   → Último arquivo processado: {{PATH}}
   → Regras mapeadas: {{N}}
   → Perguntas em aberto: {{N}}
3. Se state não existe, verificar que o projeto existe:
   → ls do diretório raiz confirma código presente
```

---

## ◈ ANTI-ALUCINAÇÃO — OBRIGATÓRIO ANTES DE QUALQUER ANÁLISE

```
[ ] Não assuma dependências não explícitas nos imports
[ ] Não invente regras de negócio não evidentes no código
[ ] Se arquivo for muito grande (>500 linhas), resuma apenas a estrutura,
    não tente analisar linha a linha
[ ] Cite o caminho exato do arquivo quando referenciar código
[ ] Não generalize padrões de um arquivo para o projeto inteiro sem verificar
[ ] Regras de domínio devem estar no código ou em docs do projeto — não inferir
```

Se qualquer item estiver incerto → registrar como pergunta em aberto, não inventar.

---

## ◈ PASSO 1 — GERAR ÁRVORE DE ARQUIVOS (se não existe)

> Executado apenas uma vez por feature. Produz o inventário que guia a análise incremental.

### 1.1 — Escanear estrutura

```bash
# Gerar inventário JSON do projeto
cd {{DIRETORIO_RAIZ}} && find . -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/.venv/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  -not -path '*/__pycache__/*' \
  -not -name '*.lock' \
  -not -name '*.log' | sort
```

### 1.2 — Classificar por prioridade

Aplicar regras de scoring:

| Prioridade | Tipo de Arquivo | Exemplos |
|------------|-----------------|----------|
| 10 | Entry points | `main.py`, `app.py`, `index.js`, `server.js`, `Application.java` |
| 9 | Config files | `package.json`, `pom.xml`, `settings.py`, `application.yml`, `tsconfig.json`, `.env` |
| 8 | Domain entities / models | `*entity*`, `*model*`, `*domain*`, `*/entities/*` |
| 7 | Use cases / services | `*service*`, `*usecase*`, `*use_case*`, `*/services/*` |
| 6 | Adapters / controllers | `*controller*`, `*adapter*`, `*handler*`, `*/routes/*` |
| 5 | Utilities / helpers | `*util*`, `*helper*`, `*common*`, `*shared*` |
| 3 | Tests | `*test*`, `*spec*`, `*/tests/*` |
| 1 | Docs, READMEs, static | `README*`, `*.md`, `*.txt`, `static/*` |

### 1.3 — Gerar `.hes/state/file-tree.json`

```json
{
  "project": "{{NOME_PROJETO}}",
  "generated_at": "{{DATA_ISO}}",
  "total_files": 142,
  "total_directories": 35,
  "files": [
    {
      "path": "src/main/app.py",
      "size_bytes": 4521,
      "type": "python",
      "priority": 10,
      "is_entry_point": true,
      "analyzed": false
    }
  ]
}
```

> **Nota:** A ordem do array `files` DEVE ser decrescente por `priority` (10 primeiro, 1 por último).

---

## ◈ PASSO 2 — ANALISAR PRÓXIMO LOTE (processamento chunked)

> Processar arquivos em ordem de prioridade. Cada arquivo gera um documento individual de análise.

### 2.1 — Determinar lote

```
Quantos arquivos analisar neste ciclo? (sugestão: 5-10 por vez)
- Codebase pequeno (<200 arquivos): 10 por lote
- Codebase médio (200-500): 5 por lote
- Codebase grande (>500): 3 por lote

Se tokens estão ficando escassos → reduzir para 1-2 por lote.
```

### 2.2 — Para CADA arquivo no lote:

```
1. Ler conteúdo do arquivo (cortar em 500 linhas se maior)
2. Identificar:
   - Imports/dependências
   - Classes, funções, métodos
   - Regras de negócio (RN-xx — apenas se explícitas no código ou comentários)
   - Padrões arquitetônicos (se evidentes)
3. Gerar documento individual em:
   .hes/analysis/{{feature}}/files/{{file-slug}}.md
4. Marcar como analyzed=true no file-tree.json
5. Atualizar estado cumulativo (PASSO 3)
```

### 2.3 — Template de análise individual

> Salvar em `.hes/analysis/{{feature}}/files/{{file-slug}}.md`

```markdown
# Analysis — {{FILE_PATH}}

Feature: {{FEATURE}} | Analyzed: {{DATA_ISO}} | Analyst: hes-v3.1

## Purpose
{{O QUE ESTE ARQUIVO FAZ EM 1-2 FRASES}}

## Key Components
| Component | Type | Responsibility |
|-----------|------|----------------|
| {{CLASS_OR_FUNC}} | Class/Function | {{WHAT IT DOES}} |

## Dependencies
| Module | Type | Direction |
|--------|------|-----------|
| {{IMPORT}} | Direct/Transitive | Inbound/Outbound |

## Domain Rules
| Rule ID | Description | Implementation |
|---------|-------------|----------------|
| {{RN-XX}} | {{REGRA}} | {{COMO FOI IMPLEMENTADA}} |

## Observations
- {{OBSERVAÇÃO_1}}
- {{OBSERVAÇÃO_2}}

## Questions
- [ ] {{PERGUNTA_EM_ABERTO — ou "Nenhuma"}}
```

> **Anti-alucinação:** Se o arquivo for grande (>500 linhas), preencher apenas a tabela de Key Components com a estrutura (nomes de classes/funções), sem detalhar o corpo de cada uma.

---

## ◈ PASSO 3 — ATUALIZAR ESTADO CUMULATIVO

> Executar APÓS cada lote processado. Garante que progresso nunca se perca.

### 3.1 — Atualizar `.hes/state/analysis-state.json`

```json
{
  "feature": "{{FEATURE_SLUG}}",
  "started_at": "{{DATA_ISO}}",
  "last_updated": "{{DATA_ISO}}",
  "total_files": 142,
  "analyzed_count": 45,
  "pending_count": 97,
  "current_file": "src/services/payment.py",
  "status": "in_progress|completed|interrupted",
  "summary": {
    "domain_rules_found": 12,
    "architectural_patterns": ["hexagonal", "cqrs"],
    "key_files_analyzed": ["main.py", "config.py", "models.py"],
    "open_questions": 3
  }
}
```

### 3.2 — Atualizar também `file-tree.json`

```json
// Para cada arquivo processado no lote:
"files[i].analyzed": true
```

### 3.3 — Quando parar

```
Parar o lote atual se:
- Tokens restantes < 10% do orçamento
- Agente detectar degradação de qualidade nas respostas
- Usuário solicitar pausa

Ao parar:
1. Salvar analysis-state.json (PASSO 3.1)
2. Salvar file-tree.json atualizado
3. Registrar status = "interrupted"
4. Próxima sessão retoma automaticamente (PASSO 5)
```

---

## ◈ PASSO 4 — GERAR SUMÁRIO CONSOLIDADO

> Executado quando análise está completa (analyzed_count == total_files) ou sob demanda pelo usuário.

### 4.1 — Gerar `.hes/analysis/{{feature}}/summary.md`

```markdown
# Análise Consolidada — {{FEATURE}}

Data: {{DATA}} | Arquivos analisados: X/Y | Status: {{STATUS}}

## Visão Geral do Codebase
{{RESUMO_DO_PROJETO_EM_3_PARAGRAFOS}}

## Arquitetura Identificada
{{PADROES_ENCONTRADOS — ex: hexagonal, MVC, CQRS, event-driven}}

## Regras de Negócio Mapeadas
| ID | Regra | Arquivo(s) | Confiança |
|----|-------|------------|-----------|
| RN-01 | {{REGRA}} | {{ARQUIVOS}} | Alta/Média/Baixa |

## Dependências Críticas
{{MAPA_DE_DEPENDENCIAS — quais módulos externos o projeto usa}}

## Dívida Técnica Identificada
{{ISSUES_ENCONTRADAS — TODOs, FIXMEs, código duplicado, acoplamento}}

## Riscos
{{RISCOS_IDENTIFICADOS — dependências obsoletas, single points of failure}}

## Perguntas em Aberto
- [ ] {{PERGUNTA}}

## Arquivos de Análise
- `.hes/analysis/{{feature}}/files/` → análises individuais por arquivo
- `.hes/state/file-tree.json` → inventário completo com status
- `.hes/state/analysis-state.json` → tracker de progresso
```

### 4.2 — Atualizar estado final

```json
// .hes/state/analysis-state.json
{
  "status": "completed",
  "completed_at": "{{DATA_ISO}}"
}
```

---

## ◈ PASSO 5 — RETOMADA DE SESSÃO (recovery protocol)

> Executado automaticamente quando a skill é carregada e o state file existe com status != "completed".

### 5.1 — Detectar sessão interrompida

```
🔄 Sessão anterior interrompida detectada.

Progresso recuperado:
  Arquivos analisados: {{ANALYZED_COUNT}}/{{TOTAL_FILES}}
  Último arquivo: {{CURRENT_FILE}}
  Regras de negócio mapeadas: {{DOMAIN_RULES_COUNT}}
  Perguntas em aberto: {{OPEN_QUESTIONS_COUNT}}

  [A] "continuar análise" → retoma do próximo arquivo pendente
  [B] "gerar sumário parcial" → gera summary.md com progresso atual
  [C] "reiniciar análise" → limpa estado e começa do zero
```

### 5.2 — Opção A: Continuar análise

```
1. Carregar .hes/state/analysis-state.json
2. Carregar .hes/state/file-tree.json
3. Encontrar próximo arquivo com analyzed = false (maior prioridade)
4. Retomar do PASSO 2 com esse arquivo como início do lote
5. Exibir progresso: "Analisando arquivo X de Y: {{file_path}}"
```

### 5.3 — Opção B: Sumário parcial

```
1. Coletar todos os arquivos já analisados
2. Executar PASSO 4 com os dados disponíveis
3. No summary.md, marcar status = "parcial (X/Y arquivos)"
4. Manter analysis-state.json com status = "in_progress"
```

### 5.4 — Opção C: Reiniciar análise

```
1. Confirmar com usuário: "Isso vai apagar {{ANALYZED_COUNT}} análises feitas. Continuar?"
2. Se sim:
   → Remover .hes/state/analysis-state.json
   → Remover .hes/analysis/{{feature}}/files/
   → Voltar ao PASSO 1
```

---

## ◈ DIRETÓRIOS GERADOS

```
.hes/
├── state/
│   ├── file-tree.json              ← inventário completo com prioridades
│   └── analysis-state.json         ← tracker de progresso
└── analysis/
    └── {{feature}}/
        ├── summary.md              ← sumário consolidado
        └── files/
            ├── app-py.md           ← análise individual por arquivo
            ├── config-py.md
            └── ...
```

---

## ◈ NOTAS DE USO

```
- Esta skill é REUTILIZÁVEL — não contém valores hardcoded de projeto específico
- O tamanho do lote deve ser ajustado conforme o orçamento de tokens disponível
- Para codebases muito grandes (>1000 arquivos), considere escopar por diretório:
  → Analisar apenas src/ primeiro, depois tests/, depois docs/
- O state file É A ÚNICA FONTE DE VERDADE do progresso — sempre salvá-lo antes
  de qualquer operação que possa consumir tokens significativos
```

---

▶ PRÓXIMA AÇÃO — ESCOLHER FLUXO

```
O que fazer agora?

  [A] "iniciar análise de {{FEATURE}}"
      → PASSO 1: gerar árvore de arquivos (se ainda não existe)

  [B] "retomar análise anterior"
      → PASSO 5: recovery protocol — carregar estado e continuar

  [C] "analisar apenas diretório {{PATH}}"
      → Executar PASSO 1 com escopo limitado ao subdiretório

  [D] "gerar sumário da análise atual"
      → PASSO 4: consolidar análises já feitas em summary.md

📄 Skill-files relacionados:
  → skills/01-discovery.md (entendimento inicial da feature)
  → skills/02-spec.md (especificação após análise)
  → skills/03-design.md (design de componentes)
  → skills/error-recovery.md (se sessão falhar repetidamente)
```
