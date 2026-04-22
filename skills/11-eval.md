# HES Skill — 11: Eval Harness (EVAL Phase)
# Invocation: /hes eval [--phase <nome>] [--k 3] [--llm-judge]
# Objetivo: medir se o harness still funciona — regression testing dos skill-files

---

## ◈ CONTEXTO

> "Good evaluations help teams ship AI agents more confidently.
>  Without them, it's easy to get stuck in reactive loops — catching issues
>  only in production." — Anthropic (2026)

O Eval Harness testa o **harness em si**, not o code of the project.
Roda contra golden tasks curadas em `.hes/evals/tasks/` e compara
with baselines em `.hes/evals/baselines/`.

---

## ◈ MÉTRICAS

### pass@k
Probabilidade de by the menos 1 sucesso em k tentativas.
Mede: **capacidade** (o harness consegue do isso?)

### pass^k
Probabilidade de all k tentativas serem sucesso.
Mede: **confiabilidade** (o harness faz isso de forma consistente?)

**Interpretação:**
- `pass@k alto + pass^k baixo` → harness consegue, but de forma inconsistente
- `pass@k baixo` → harness not consegue — regression crítica
- `pass@k == pass^k` → harness is determinístico nesta dimensão

---

## ◈ TIPOS DE GRADERS

### Determinístico (rápido, gratuito, reproduzível)
```python
# Exemplos de checks determinísticos:
count_rn_items = len(re.findall(r'RN-\d+', output))
has_keywords   = all(kw in output for kw in expected_keywords)
bandit_high    = json.loads(bandit_output)["metrics"]["_totals"]["SEVERITY.HIGH"]
gate_exit_code = subprocess.run(["python3", ".hes/scripts/check-security-gate.py"]).returncode
```

### LLM-as-judge (qualitativo, more lento)
```python
# Prompt para LLM-as-judge:
JUDGE_PROMPT = """
Avalie a saída do agente HES segundo o critério abaixo.
Responda APENAS com: PASS ou FAIL, seguido de uma linha de justificativa.

Critério: {rubric}

Saída do agente:
---
{output}
---
"""
# Score: PASS = 1.0, FAIL = 0.0
# Usar claude-haiku para reduzir custo
```

---

## ◈ flow DE execution

### STEP 0 — Log start
```bash
bash scripts/hooks/log-action.sh TOOL_CALL STARTED "eval-harness" "iniciando eval"
```

### STEP 1 — Carregar tasks
```python
import json
from pathlib import Path

PHASE = "DISCOVERY"  # ou argumento --phase
task_dir = Path(f".hes/evals/tasks/{PHASE.lower()}")
tasks = [json.loads(f.read_text()) for f in task_dir.glob("*.json")]
print(f"Loaded {len(tasks)} tasks for phase {PHASE}")
```

### STEP 2 — Carregar baseline
```python
import glob
baseline_files = sorted(glob.glob(".hes/evals/baselines/scores-*.json"))
baseline = json.loads(open(baseline_files[-1]).read()) if baseline_files else {}
```

### STEP 3 — Executar tasks (k vezes each)
```python
K = 3  # ou argumento --k
results = {}

for task in tasks:
    task_results = []
    for trial in range(K):
        # LLM executa a task simulada
        output = llm_execute_task(task)

        # Rodar graders determinísticos
        det_scores = []
        for grader in [g for g in task["graders"] if g["type"] == "deterministic"]:
            score = evaluate_deterministic(grader["check"], output)
            det_scores.append(score)

        # LLM-as-judge (apenas se --llm-judge flag)
        llm_scores = []
        if llm_judge_enabled:
            for grader in [g for g in task["graders"] if g["type"] == "llm-judge"]:
                score = evaluate_llm_judge(grader["rubric"], output)
                llm_scores.append(score * grader.get("weight", 1.0))

        all_scores = det_scores + llm_scores
        trial_pass = all(s >= 0.5 for s in all_scores)
        task_results.append(trial_pass)

    pass_at_k  = any(task_results)                    # ≥1 sucesso
    pass_all_k = all(task_results)                    # todos sucessos
    results[task["task_id"]] = {
        "pass_at_k": pass_at_k,
        "pass_all_k": pass_all_k,
        "trials": task_results,
        "baseline": task.get("baseline_score", 0.8)
    }
```

### STEP 4 — Comparar with baseline e detectar regressões
```python
regressions = []
for task_id, result in results.items():
    baseline_score = result["baseline"]
    current_score = 1.0 if result["pass_at_k"] else 0.0
    if current_score < baseline_score - 0.1:  # 10% degradação = regressão
        regressions.append({
            "task_id": task_id,
            "baseline": baseline_score,
            "current": current_score,
            "delta": current_score - baseline_score
        })
```

### STEP 5 — Salvar resultados
```python
from datetime import datetime, timezone
report = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "harness_version": "3.5.0",
    "phase_evaluated": PHASE,
    "k": K,
    "total_tasks": len(tasks),
    "results": results,
    "regressions": regressions,
    "aggregate": {
        "pass_at_k_rate": sum(1 for r in results.values() if r["pass_at_k"]) / len(results),
        "pass_all_k_rate": sum(1 for r in results.values() if r["pass_all_k"]) / len(results)
    }
}

timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
output_path = f".hes/evals/results/eval-report-{timestamp}.json"
Path(".hes/evals/results").mkdir(parents=True, exist_ok=True)
with open(output_path, "w") as f:
    json.dump(report, f, indent=2)
```

### STEP 6 — Exibir resultado ao usuário
```
📊 HES Eval Report — {PHASE} (k={K})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tasks:       {total}
pass@k:      {pass_at_k_rate:.0%}  (capacidade)
pass^k:      {pass_all_k_rate:.0%}  (confiabilidade)

Regressões detectadas: {len(regressions)}
{regressão por tarefa se existirem}

GATE: ✅ Sem regressões — harness estável
      ❌ {N} regressão(ões) — investigar antes de mergear
```

### STEP 7 — Log conclusão
```bash
bash scripts/hooks/log-action.sh TOOL_CALL SUCCESS "eval-harness" \
  "pass@k={rate}% | {regressions} regressões"
```

---

## ◈ GATE DE REGRESSÃO (for CI/CD)

Rodar no GitHub Actions:
```bash
python3 scripts/ci/run-eval.py --phase DISCOVERY --k 3
# Exit 0 = sem regressão
# Exit 1 = regressão detectada — PR bloqueado
```

---

## ◈ COMANDOS

```
/hes eval                           → eval todas as fases (determinístico)
/hes eval --phase DISCOVERY         → eval fase específica
/hes eval --k 5                     → k=5 trials por task
/hes eval --llm-judge               → inclui LLM-as-judge (mais lento)
/hes eval --update-baseline         → salva resultado atual como novo baseline
```

---

▶ NEXT ACTION

```
📊 Eval executado.

  [A] "/hes eval --update-baseline"
      → Salvar scores atuais como novo baseline (apenas após verificação humana)

  [B] "/hes eval --phase {failing_phase} --llm-judge"
      → Diagnóstico detalhado da fase com regressão

  [C] "/hes report"
      → Correlacionar regressões com mudanças recentes no harness

📄 Skill-file: skills/11-eval.md
💡 Tip: rodar evals ANTES de mergear mudanças em skill-files.
   Regressão = sinal de que a mudança quebrou comportamento esperado.
   pass@k = capacidade | pass^k = confiabilidade.
```
