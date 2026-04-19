#!/usr/bin/env bash
# =============================================================================
# HES v3.4.0 — Action Event Logger
# Registra ações do LLM no events.log com granularidade intra-fase
#
# Uso:
#   bash scripts/hooks/log-action.sh <action_type> <status> <target> <result_summary>
#
# action_type: READ_FILE | WRITE_FILE | EXEC_CMD | GENERATE_ARTIFACT |
#              LLM_DECISION | TOOL_CALL | GATE_CHECK | SECURITY_SCAN
# status:      STARTED | SUCCESS | FAILED | SKIPPED
#
# Exemplos:
#   bash scripts/hooks/log-action.sh EXEC_CMD STARTED "bandit -r ." "iniciando security scan"
#   bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "bandit -r ." "0 HIGH, 2 MEDIUM, 5 LOW"
#   bash scripts/hooks/log-action.sh GATE_CHECK FAILED "security-gate" "1 HIGH finding restante"
# =============================================================================
set -euo pipefail

ACTION_TYPE="${1:-UNKNOWN}"
STATUS="${2:-UNKNOWN}"
TARGET="${3:-}"
RESULT_SUMMARY="${4:-}"

EVENTS_LOG=".hes/state/events.log"
SESSION_FILE=".hes/state/session-id"
STATE_FILE=".hes/state/current.json"

# Garantir que o diretório existe
mkdir -p ".hes/state"

# Obter ou criar session-id
if [ ! -f "$SESSION_FILE" ]; then
  python3 -c "import uuid; print(str(uuid.uuid4()))" > "$SESSION_FILE"
fi
SESSION_ID=$(cat "$SESSION_FILE")

# Obter fase e feature do estado atual
PHASE="UNKNOWN"
FEATURE="UNKNOWN"
if [ -f "$STATE_FILE" ]; then
  PHASE=$(python3 -c "
import json
try:
    d = json.load(open('$STATE_FILE'))
    feat = d.get('active_feature') or 'global'
    feats = d.get('features', {})
    print(feats.get(feat, d.get('session', {}).get('phase_lock', 'UNKNOWN')))
except Exception:
    print('UNKNOWN')
" 2>/dev/null || echo "UNKNOWN")
  FEATURE=$(python3 -c "
import json
try:
    d = json.load(open('$STATE_FILE'))
    print(d.get('active_feature') or 'global')
except Exception:
    print('UNKNOWN')
" 2>/dev/null || echo "UNKNOWN")
fi

TIMESTAMP=$(python3 -c "from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat())" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
ACTION_ID=$(python3 -c "import uuid; print(str(uuid.uuid4())[:8])" 2>/dev/null || echo "00000000")

python3 << PYEOF
import json, os

event = {
    "timestamp": "$TIMESTAMP",
    "session_id": "$SESSION_ID",
    "action_id": "$ACTION_ID",
    "feature": "$FEATURE",
    "phase": "$PHASE",
    "action_type": "$ACTION_TYPE",
    "status": "$STATUS",
    "details": {
        "target": """$TARGET""",
        "result_summary": """$RESULT_SUMMARY"""
    }
}

log_path = "$EVENTS_LOG"
with open(log_path, "a") as f:
    f.write(json.dumps(event) + "\n")
PYEOF

# Feedback visual (apenas em terminal interativo)
if [ -t 1 ]; then
  case "$STATUS" in
    STARTED)  printf "  ⏳ [%s] %s\n" "$ACTION_TYPE" "$TARGET" ;;
    SUCCESS)  printf "  ✅ [%s] %s → %s\n" "$ACTION_TYPE" "$TARGET" "$RESULT_SUMMARY" ;;
    FAILED)   printf "  ❌ [%s] %s → %s\n" "$ACTION_TYPE" "$TARGET" "$RESULT_SUMMARY" ;;
    SKIPPED)  printf "  ⏭️  [%s] %s → %s\n" "$ACTION_TYPE" "$TARGET" "$RESULT_SUMMARY" ;;
  esac
fi
