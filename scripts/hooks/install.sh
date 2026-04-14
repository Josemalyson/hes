#!/usr/bin/env bash
set -e
echo "🔧 Installing HES Git Hooks v3.3..."
HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
SCRIPTS_DIR="$(git rev-parse --show-toplevel)/scripts/hooks"
mkdir -p "$HOOKS_DIR"
ln -sf "$SCRIPTS_DIR/safety_validator.py"   "$HOOKS_DIR/pre-commit"
ln -sf "$SCRIPTS_DIR/sdd_commit_checker.py" "$HOOKS_DIR/commit-msg"
chmod +x "$SCRIPTS_DIR"/*.py
echo "✅ Hooks installed (HES v3.3 computational sensors):"
echo "   pre-commit  → safety_validator.py"
echo "   commit-msg  → sdd_commit_checker.py"
echo ""
echo "Test: git commit --allow-empty -m 'harness: validate HES v3.3 hooks'"
