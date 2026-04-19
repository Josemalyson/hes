#!/usr/bin/env bash
# HES v3.5.0 — Context Offload Helper
# Uso:
#   bash scripts/hooks/context-offload.sh save <action_id> <file_with_content>
#   bash scripts/hooks/context-offload.sh summary <file_path>
#   bash scripts/hooks/context-offload.sh clean [--days 7]
set -euo pipefail

CMD="${1:-summary}"
CONTEXT_DIR=".hes/context/tool-outputs"
mkdir -p "$CONTEXT_DIR"

THRESHOLD_CHARS=8000
THRESHOLD_LINES=100

case "$CMD" in
  save)
    ACTION_ID="${2:-$(python3 -c 'import uuid; print(str(uuid.uuid4())[:8])')}"
    INPUT_FILE="${3:-/dev/stdin}"
    OUTPUT_FILE="$CONTEXT_DIR/${ACTION_ID}.txt"

    # Contar tamanho
    CONTENT=$(cat "$INPUT_FILE")
    CHAR_COUNT=${#CONTENT}
    LINE_COUNT=$(echo "$CONTENT" | wc -l)

    if [ "$CHAR_COUNT" -gt "$THRESHOLD_CHARS" ] || [ "$LINE_COUNT" -gt "$THRESHOLD_LINES" ]; then
      echo "$CONTENT" > "$OUTPUT_FILE"
      HEAD=$(echo "$CONTENT" | head -40)
      TAIL=$(echo "$CONTENT" | tail -20)
      echo "--- HEAD (40 lines) ---"
      echo "$HEAD"
      echo "... [OFFLOADED: $OUTPUT_FILE — $LINE_COUNT lines, $CHAR_COUNT chars] ..."
      echo "--- TAIL (20 lines) ---"
      echo "$TAIL"
    else
      echo "$CONTENT"
    fi
    ;;

  summary)
    FILE="${2:-}"
    [ -f "$FILE" ] || { echo "File not found: $FILE"; exit 1; }
    LINES=$(wc -l < "$FILE")
    CHARS=$(wc -c < "$FILE")
    echo "File: $FILE ($LINES lines, $CHARS chars)"
    echo "--- HEAD (40 lines) ---"
    head -40 "$FILE"
    echo "... [$((LINES - 60)) lines omitted] ..."
    echo "--- TAIL (20 lines) ---"
    tail -20 "$FILE"
    ;;

  clean)
    DAYS="${2:---days}"
    DAYS_N="${3:-7}"
    [ "$DAYS" = "--days" ] || { DAYS_N="$DAYS"; }
    COUNT=$(find "$CONTEXT_DIR" -mtime +"$DAYS_N" -name "*.txt" | wc -l)
    find "$CONTEXT_DIR" -mtime +"$DAYS_N" -name "*.txt" -delete
    echo "Cleaned $COUNT offloaded files older than ${DAYS_N} days"
    ;;
esac
