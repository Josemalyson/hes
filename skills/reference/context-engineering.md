# HES — Context Engineering: Tool Output Offloading (v3.5.0)
# Previne context bloat de outputs grandes de ferramentas
# Referência: LangChain (2026), arxiv:2603.05344 — "Building AI Coding Agents"

---

## ◈ PROBLEMA RESOLVIDO

> "A single long-running test suite could consume 30,000 tokens of context
>  in one tool call. The per-tool summarizer reduced this to under 100 tokens."
> — arxiv:2603.05344 (2026)

Sem offloading, outputs grandes (pytest, bandit, git diff) consomem o context
window rapidamente, degradando a qualidade das decisões do LLM.

---

## ◈ THRESHOLD DE OFFLOADING

| Critério            | Threshold       | Ação                        |
|---------------------|-----------------|-----------------------------|
| Tamanho do output   | > 8.000 chars   | Offload + head+tail summary |
| Linhas de output    | > 100 linhas    | Offload + line count summary|
| JSON aninhado       | > 50 entries    | Offload + count summary     |

---

## ◈ CANDIDATOS PRIORITÁRIOS for OFFLOADING

| Ferramenta         | Cenário que gera output grande           |
|--------------------|------------------------------------------|
| pytest / mvn test  | Muitas falhas with stack traces complete |
| bandit -r .        | Muitos findings no codebase              |
| git diff           | PRs grandes with muitos Files          |
| grep -r            | Muitos matches em codebase grande        |
| npm test           | Suite de tests extensa                  |
| mypy / pylint      | Muitos erros de tipo/lint                |

---

## ◈ PROTOCOLO DE OFFLOADING (LLM executa)

```
Quando output de ferramenta > 8.000 chars:

1. bash scripts/hooks/context-offload.sh save "{action_id}" "{output}"
   → Salva output completo em .hes/context/tool-outputs/{action_id}.txt

2. LLM usa no contexto a versão comprimida:
   HEAD (primeiras 40 linhas)
   + "... [OFFLOADED: .hes/context/tool-outputs/{action_id}.txt — {total_lines} linhas] ..."
   + TAIL (últimas 20 linhas — onde erros geralmente aparecem)

3. Se LLM precisar do conteúdo completo:
   → Ler .hes/context/tool-outputs/{action_id}.txt via ferramenta de leitura
   → NÃO injetar o arquivo inteiro de volta no contexto — usar grep/search específico

4. Logar:
   bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "{cmd}" "output offloaded ({total_lines} lines)"
```

---

## ◈ PADRÃO DE SUMMARY POR FERRAMENTA

### pytest / jest / mvn test
```
TEST SUMMARY (offloaded: {N} linhas → .hes/context/tool-outputs/{id}.txt)
  Passed:  {N}
  Failed:  {N}
  Errors:  {N}
  Duration: {T}s

First failure:
  {first_test_name}: {first_error_line}

Last 5 lines:
  {tail_5_lines}
```

### bandit
```
BANDIT SUMMARY (offloaded: {N} findings → .hes/context/tool-outputs/{id}.txt)
  HIGH:   {N} findings
  MEDIUM: {N} findings
  LOW:    {N} findings

First HIGH finding:
  [{test_id}] {file}:{line} — {issue_text}
```

### git diff
```
DIFF SUMMARY (offloaded: {N} linhas → .hes/context/tool-outputs/{id}.txt)
  Files changed: {N}
  Insertions: +{N}
  Deletions:  -{N}

Files:
  {file_list}
```

---

## ◈ RULE-28 (adicionada ao SKILL.md)

```
RULE-28  LLM OFFLOADS tool outputs > 8000 chars to .hes/context/tool-outputs/
         Inject head (40 lines) + offload marker + tail (20 lines) in context
         Access full output via file read only when specifically needed
         Never inject full large output back into working context
```

---

## ◈ LIMPEZA DE CONTEXT

```bash
# Limpar outputs offloadados mais antigos que 7 dias
find .hes/context/tool-outputs/ -mtime +7 -delete

# /hes checkpoint inclui limpeza automática
```
