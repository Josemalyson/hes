# HES — Telemetry Protocol (v3.5.0)
# OpenTelemetry-style spans: latency, cost, action hierarchy
# Reference: OpenAI Codex (2026) — ephemeral observability stack per worktree

---

## ◈ PROBLEM SOLVED

The Action Event Protocol (v3.4.0) records WHAT happened.
Telemetry records HOW LONG it took and HOW MUCH it cost.
Together they form the complete observability stack of HES.

---

## ◈ SPAN SCHEMA (OpenTelemetry-compatible)

```json
{
  "trace_id":      "uuid-of-feature — immutable per feature",
  "span_id":       "uuid-of-action — unique",
  "parent_span_id":"uuid-parent (phase = parent of action)",
  "name":          "EXEC_CMD:pytest",
  "phase":         "GREEN",
  "feature":       "payment",
  "session_id":    "uuid-of-session",
  "start_time":    "ISO8601",
  "end_time":      "ISO8601",
  "duration_ms":   2340,
  "tokens_estimated": 1200,
  "cost_usd_estimated": 0.0036,
  "status":        "SUCCESS | FAILED | TIMEOUT",
  "attributes": {
    "target":       "pytest tests/unit/",
    "result":       "42 passed, 0 failed",
    "offloaded":    false
  }
}
```

---

## ◈ TELEMETRY FILE

```
.hes/state/telemetry.jsonl   ← one span per line (JSONL format)
```

---

## ◈ TOKEN ESTIMATE BY ACTION TYPE

| Action type           | Token estimate           |
|-----------------------|--------------------------|
| File read          | `chars / 4`              |
| Command execution  | 300 (output + analysis)  |
| Artifact generation| 1,200 (spec/ADR)         |
| Architectural decision | 1,500                  |
| Security scan      | 600 (findings analysis)  |
| BDD scenario (1)      | 200                      |

Reference pricing (Claude Sonnet):
- Input:  $0.003 / 1K tokens
- Output: $0.015 / 1K tokens
- Média:  $0.009 / 1K tokens

---

## ◈ PROTOCOL (LLM executes)

```bash
# Start PHASE span (parent span)
bash scripts/hooks/telemetry.sh start_phase GREEN {feature}

# For each action within the phase:
bash scripts/hooks/telemetry.sh start_action EXEC_CMD "pytest tests/" {phase_span_id}
# ... executar ação ...
bash scripts/hooks/telemetry.sh end_action {action_span_id} SUCCESS "42 passed" 2340

# When finishing the phase:
bash scripts/hooks/telemetry.sh end_phase {phase_span_id} SUCCESS
```

---

## ◈ USEFUL QUERIES

```bash
# Timeline of a feature
bash scripts/hooks/telemetry.sh timeline payment

# Slowest phases (all time)
bash scripts/hooks/telemetry.sh slowest-phases

# Cost per session
bash scripts/hooks/telemetry.sh cost --session {session_id}

# Output:
# Feature: payment | Total: 45.2 min | Cost: ~$0.38
# ┌─────────────┬──────────┬─────────┬──────────┐
# │ Phase       │ Duration │ Steps   │ Cost     │
# ├─────────────┼──────────┼─────────┼──────────┤
# │ DISCOVERY   │  8.2 min │  9 stp  │ $0.04    │
# │ SPEC        │ 12.1 min │ 14 stp  │ $0.08    │
# │ GREEN       │ 18.4 min │ 22 stp  │ $0.19    │
# │ SECURITY    │  6.5 min │  8 stp  │ $0.07    │
# └─────────────┴──────────┴─────────┴──────────┘
```

---

## ◈ INTEGRATION WITH ANNOUNCE BLOCK

Add to step 3 of SKILL.md:

```
📍 HES v3.5.0 — {PROJECT}
Feature  : {feature} | Phase: {phase}
Budget   : {steps_used}/{steps_max} steps
Telemetry: ~{duration_min:.1f}min | ~{tokens:,} tokens | ~${cost:.3f}
```
