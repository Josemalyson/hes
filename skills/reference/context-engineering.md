# HES — Context Engineering: Tool Output Offloading (v3.5.0)
# Prevents context bloat from large tool outputs
# Reference: LangChain (2026), arxiv:2603.05344 — "Building AI Coding Agents"

---

## ◈ PROBLEM SOLVED

> "A single long-running test suite could consume 30,000 tokens of context
>  in one tool call. The per-tool summarizer reduced this to under 100 tokens."
> — arxiv:2603.05344 (2026)

Without offloading, large outputs (pytest, bandit, git diff) consume the context
window quickly, degrading the quality of LLM decisions.

---

## ◈ OFFLOADING THRESHOLD

| Criterion           | Threshold       | Action                      |
|---------------------|-----------------|-----------------------------|
| Output size         | > 8,000 chars   | Offload + head+tail summary |
| Output lines        | > 100 lines     | Offload + line count summary|
| Nested JSON         | > 50 entries    | Offload + count summary     |

---

## ◈ PRIORITY CANDIDATES FOR OFFLOADING

| Tool               | Scenario that generates large output     |
|--------------------|------------------------------------------|
| pytest / mvn test  | Many failures with full stack traces     |
| bandit -r .        | Many findings in the codebase            |
| git diff           | Large PRs with many changed files        |
| grep -r            | Many matches in a large codebase         |
| npm test           | Extensive test suite                     |
| mypy / pylint      | Many type/lint errors                    |

---

## ◈ OFFLOADING PROTOCOL (LLM executes)

```
When tool output > 8,000 chars:

1. bash scripts/hooks/context-offload.sh save "{action_id}" "{output}"
   → Saves full output to .hes/context/tool-outputs/{action_id}.txt

2. LLM usa no contexto a versão comprimida:
   HEAD (primeiras 40 linhas)
   + "... [OFFLOADED: .hes/context/tool-outputs/{action_id}.txt — {total_lines} lines] ..."
   + TAIL (últimas 20 linhas — onde erros geralmente aparecem)

3. If LLM needs full content:
   → Read .hes/context/tool-outputs/{action_id}.txt via file read tool
   → Do NOT inject the full file back into context — use specific grep/search

4. Logar:
   bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "{cmd}" "output offloaded ({total_lines} lines)"
```

---

## ◈ SUMMARY PATTERN BY TOOL

### pytest / jest / mvn test
```
TEST SUMMARY (offloaded: {N} lines → .hes/context/tool-outputs/{id}.txt)
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
DIFF SUMMARY (offloaded: {N} lines → .hes/context/tool-outputs/{id}.txt)
  Files changed: {N}
  Insertions: +{N}
  Deletions:  -{N}

Files:
  {file_list}
```

---

## ◈ RULE-28 (added to SKILL.md)

```
RULE-28  LLM OFFLOADS tool outputs > 8000 chars to .hes/context/tool-outputs/
         Inject head (40 lines) + offload marker + tail (20 lines) in context
         Access full output via file read only when specifically needed
         Never inject full large output back into working context
```

---

## ◈ CONTEXT CLEANUP

```bash
# Clean up offloaded outputs older than 7 days
find .hes/context/tool-outputs/ -mtime +7 -delete

# /hes checkpoint includes automatic cleanup
```
