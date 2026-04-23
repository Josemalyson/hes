# HES Skill — 11: Eval Harness (EVAL Phase)
# Invocation: /hes eval [--phase <name>] [--k 3] [--llm-judge]
# Goal: measure whether the harness still works — regression testing of skill-files

---

## ◈ CONTEXT

> "Good evaluations help teams ship AI agents more confidently.
>  Without them, it's easy to get stuck in reactive loops — catching issues
>  only in production." — Anthropic (2026)

The Eval Harness tests the **harness itself**, not the project code.
Runs against golden tasks in `.hes/evals/tasks/` and compares against
baselines in `.hes/evals/baselines/`.

---

## ◈ METRICS

### pass@k
Probability of at least 1 success in k attempts.
Measures: **capability** (can the harness do this?)

### pass^k
Probability of all k attempts succeeding.
Measures: **reliability** (does the harness do this consistently?)

**Interpretation:**
- `pass@k high + pass^k low` → harness can do it, but inconsistently
- `pass@k low` → harness cannot — critical regression
- `pass@k == pass^k` → harness is deterministic in this dimension

---

## ◈ GRADER TYPES

### Determinístico (rápido, gratuito, reproduzível)
```python
# Examples of deterministic checks:
count_rn_items = len(re.findall(r'RN-\d+', output))
has_keywords   = all(kw in output for kw in expected_keywords)
bandit_high    = json.loads(bandit_output)["metrics"]["_totals"]["SEVERITY.HIGH"]
gate_exit_code = subprocess.run(["python3", ".hes/scripts/check-security-gate.py"]).returncode
```

### LLM-as-judge (qualitativo, more lento)
```python
# Prompt for LLM-as-judge:
JUDGE_PROMPT = """
Evaluate the HES agent output according to the criterion below.
Respond ONLY with: PASS or FAIL, followed by one line of justification.

Criterion: {rubric}

Agent output:
---
{output}
---
"""
# Score: PASS = 1.0, FAIL = 0.0
# Use claude-haiku to reduce cost
```

---

## ◈ EXECUTION FLOW

### STEP 0 — Log start
```bash
bash scripts/hooks/log-action.sh TOOL_CALL STARTED "eval-harness" "starting eval"
```

### STEP 1 — Load tasks
```python
import json
from pathlib import Path

PHASE = "DISCOVERY"  # ou argumento --phase
task_dir = Path(f".hes/evals/tasks/{PHASE.lower()}")
tasks = [json.loads(f.read_text()) for f in task_dir.glob("*.json")]
print(f"Loaded {len(tasks)} tasks for phase {PHASE}")
```

### STEP 2 — Load baseline
```python
import glob
baseline_files = sorted(glob.glob(".hes/evals/baselines/scores-*.json"))
baseline = json.loads(open(baseline_files[-1]).read()) if baseline_files else {}
```

### STEP 3 — Run tasks (k times each)
```python
K = 3  # ou argumento --k
results = {}

for task in tasks:
    task_results = []
    for trial in range(K):
        # LLM executes the simulated task
        output = llm_execute_task(task)

        # Run deterministic graders
        det_scores = []
        for grader in [g for g in task["graders"] if g["type"] == "deterministic"]:
            score = evaluate_deterministic(grader["check"], output)
            det_scores.append(score)

        # LLM-as-judge (only with --llm-judge flag)
        llm_scores = []
        if llm_judge_enabled:
            for grader in [g for g in task["graders"] if g["type"] == "llm-judge"]:
                score = evaluate_llm_judge(grader["rubric"], output)
                llm_scores.append(score * grader.get("weight", 1.0))

        all_scores = det_scores + llm_scores
        trial_pass = all(s >= 0.5 for s in all_scores)
        task_results.append(trial_pass)

    pass_at_k  = any(task_results)                    # ≥1 success
    pass_all_k = all(task_results)                    # all successes
    results[task["task_id"]] = {
        "pass_at_k": pass_at_k,
        "pass_all_k": pass_all_k,
        "trials": task_results,
        "baseline": task.get("baseline_score", 0.8)
    }
```

### STEP 4 — Compare with baseline and detect regressions
```python
regressions = []
for task_id, result in results.items():
    baseline_score = result["baseline"]
    current_score = 1.0 if result["pass_at_k"] else 0.0
    if current_score < baseline_score - 0.1:  # 10% degradation = regression
        regressions.append({
            "task_id": task_id,
            "baseline": baseline_score,
            "current": current_score,
            "delta": current_score - baseline_score
        })
```

### STEP 5 — Save results
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

### STEP 6 — Display result to user
```
📊 HES Eval Report — {PHASE} (k={K})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tasks:       {total}
pass@k:      {pass_at_k_rate:.0%}  (capability)
pass^k:      {pass_all_k_rate:.0%}  (reliability)

Regressions detected: {len(regressions)}
{regression per task if any}

GATE: ✅ No regressions — harness stable
      ❌ {N} regression(s) — investigate before merging
```

### STEP 7 — Log completion
```bash
bash scripts/hooks/log-action.sh TOOL_CALL SUCCESS "eval-harness" \
  "pass@k={rate}% | {regressions} regressions"
```

---

## ◈ REGRESSION GATE (for CI/CD)

Run in GitHub Actions:
```bash
python3 scripts/ci/run-eval.py --phase DISCOVERY --k 3
# Exit 0 = sem regressão
# Exit 1 = regressão detectada — PR bloqueado
```

---

## ◈ COMMANDS

```
/hes eval                           → eval all phases (deterministic)
/hes eval --phase DISCOVERY         → eval specific phase
/hes eval --k 5                     → k=5 trials per task
/hes eval --llm-judge               → include LLM-as-judge (slower)
/hes eval --update-baseline         → save current result as new baseline
```

---

▶ NEXT ACTION

```
📊 Eval executado.

  [A] "/hes eval --update-baseline"
      → Save current scores as new baseline (only after human verification)

  [B] "/hes eval --phase {failing_phase} --llm-judge"
      → Detailed diagnosis of the phase with regression

  [C] "/hes report"
      → Correlate regressions with recent harness changes

📄 Skill-file: skills/11-eval.md
💡 Tip: run evals BEFORE merging changes to skill-files.
   Regression = signal that the change broke expected behavior.
   pass@k = capability | pass^k = reliability.
```
