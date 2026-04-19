#!/usr/bin/env bash
# HES v3.5.0 — Step Budget Manager
# Uso:
#   bash scripts/hooks/step-budget.sh decrement          → decrementa budget da fase atual
#   bash scripts/hooks/step-budget.sh status             → mostra budget atual
#   bash scripts/hooks/step-budget.sh reset <PHASE>      → reseta budget de uma fase
#   bash scripts/hooks/step-budget.sh set-tokens <N>     → atualiza token estimate
set -euo pipefail

CMD="${1:-status}"
STATE=".hes/state/current.json"
EVENTS=".hes/state/events.log"

[ -f "$STATE" ] || { echo "ERROR: $STATE not found"; exit 1; }

case "$CMD" in
  decrement)
    python3 << 'PYEOF'
import json, sys
from datetime import datetime, timezone

state_path = ".hes/state/current.json"
events_path = ".hes/state/events.log"

with open(state_path) as f:
    state = json.load(f)

# Detectar fase atual
feature = state.get("active_feature")
phase = "UNKNOWN"
if feature:
    phase = state.get("features", {}).get(feature, "UNKNOWN")

budget = state.setdefault("step_budget", {})
phase_budget = budget.setdefault(phase, {"max": 30, "used": 0})

phase_budget["used"] = phase_budget.get("used", 0) + 1
used = phase_budget["used"]
max_steps = phase_budget.get("max", 30)
pct = used / max_steps

with open(state_path, "w") as f:
    json.dump(state, f, indent=2)

# Status output
if pct >= 1.0:
    print(f"⚠️  STEP BUDGET ESGOTADO [{phase}]: {used}/{max_steps}")
    print("→ Execute /hes checkpoint ou /hes unlock --force")
    # Log evento
    event = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "session_id": open(".hes/state/session-id").read().strip() if __import__("os").path.exists(".hes/state/session-id") else "unknown",
        "action_type": "GATE_CHECK",
        "status": "FAILED",
        "phase": phase,
        "feature": feature or "unknown",
        "details": {"target": "step-budget", "result_summary": f"ESGOTADO {used}/{max_steps}"}
    }
    with open(events_path, "a") as f:
        f.write(json.dumps(event) + "\n")
    sys.exit(2)
elif pct >= 0.8:
    print(f"⏳ Budget [{phase}]: {used}/{max_steps} ({int(pct*100)}%) — approaching limit")
else:
    print(f"  Budget [{phase}]: {used}/{max_steps} ({int(pct*100)}%)")
PYEOF
    ;;

  status)
    python3 << 'PYEOF'
import json
with open(".hes/state/current.json") as f:
    state = json.load(f)
budget = state.get("step_budget", {})
feature = state.get("active_feature", "none")
feats = state.get("features", {})
phase = feats.get(feature, "UNKNOWN") if feature else "UNKNOWN"
print(f"Feature: {feature} | Phase: {phase}")
print(f"{'Fase':<12} {'Used':>4} {'Max':>4} {'%':>5}")
print("-" * 30)
for p, b in budget.items():
    used = b.get("used", 0)
    mx = b.get("max", 30)
    bar = "█" * int(used/mx*10) + "░" * (10 - int(used/mx*10)) if mx > 0 else "░"*10
    marker = " ←" if p == phase else ""
    print(f"{p:<12} {used:>4} {mx:>4} {int(used/mx*100):>4}%{marker}")
tokens = state.get("token_tracking", {})
if tokens.get("tokens_estimated", 0) > 0:
    print(f"\nTokens ~{tokens['tokens_estimated']:,} | Cost ~${tokens['cost_usd_estimated']:.4f}")
PYEOF
    ;;

  reset)
    PHASE="${2:-}"
    [ -z "$PHASE" ] && { echo "Usage: step-budget.sh reset <PHASE>"; exit 1; }
    python3 -c "
import json
from datetime import datetime, timezone
with open('.hes/state/current.json') as f:
    s = json.load(f)
s.setdefault('step_budget', {}).setdefault('$PHASE', {})['used'] = 0
s['step_budget']['$PHASE']['last_reset'] = datetime.now(timezone.utc).isoformat()
with open('.hes/state/current.json', 'w') as f:
    json.dump(s, f, indent=2)
print('Budget reset: $PHASE')
"
    ;;

  set-tokens)
    TOKENS="${2:-0}"
    python3 -c "
import json
with open('.hes/state/current.json') as f:
    s = json.load(f)
tt = s.setdefault('token_tracking', {'tokens_estimated': 0, 'cost_usd_estimated': 0.0, 'model_price_per_1k_input': 0.003, 'model_price_per_1k_output': 0.015})
tt['tokens_estimated'] = tt.get('tokens_estimated', 0) + $TOKENS
price_avg = (tt['model_price_per_1k_input'] + tt['model_price_per_1k_output']) / 2
tt['cost_usd_estimated'] = tt['tokens_estimated'] / 1000 * price_avg
with open('.hes/state/current.json', 'w') as f:
    json.dump(s, f, indent=2)
print(f'Tokens: {tt[\"tokens_estimated\"]:,} | Cost: \${tt[\"cost_usd_estimated\"]:.4f}')
"
    ;;
esac
