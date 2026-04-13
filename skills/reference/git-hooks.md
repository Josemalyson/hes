# Git Hooks Reference

> Used in: Step 10 — Generate Git hooks
> All hooks are computational sensors that block invalid commits

---

## Pre-commit Hook: Safety Validator

**File:** `scripts/hooks/safety_validator.py`

```python
#!/usr/bin/env python3
"""HES Safety Validator v3.2 — pre-commit hook
Computational sensor: blocks secrets, destructive SQL, and pending tasks."""
import subprocess, sys, re

BLOCKED_PATTERNS = [
    (r'(?i)(password|secret|api_key|token)\s*=\s*["\'][^"\']{4,}', 'Hardcoded secret detected'),
    (r'(?i)DROP\s+TABLE', 'DROP TABLE without explicit approval (HES RULE-04)'),
    (r'(?i)DELETE\s+FROM\s+\w+\s*;', 'DELETE without WHERE clause'),
    (r'(?i)TRUNCATE\s+TABLE', 'TRUNCATE without explicit approval (HES RULE-04)'),
    (r'\bTODO\b|\bFIXME\b|\bHACK\b', 'Unresolved pending task in code'),
]
SKIP_EXTENSIONS = {'.lock', '.sum', '.mod', '.png', '.jpg', '.svg', '.ico'}

def get_staged_files():
    result = subprocess.run(['git', 'diff', '--cached', '--name-only'],
                            capture_output=True, text=True)
    return [f for f in result.stdout.strip().split('\n') if f]

def check_file(filepath):
    import os
    ext = os.path.splitext(filepath)[1]
    if ext in SKIP_EXTENSIONS:
        return []
    violations = []
    try:
        with open(filepath, 'r', errors='ignore') as f:
            for i, line in enumerate(f, 1):
                for pattern, msg in BLOCKED_PATTERNS:
                    if re.search(pattern, line):
                        violations.append(
                            f'  ⚠  {msg}\n     {filepath}:{i} → {line.strip()[:80]}'
                        )
    except Exception:
        pass
    return violations

violations = []
for f in get_staged_files():
    violations.extend(check_file(f))

if violations:
    print('\n🚨 HES Safety Validator v3.2 — COMMIT BLOCKED\n')
    for v in violations:
        print(v)
    print('\nFix the issues above before committing.')
    print('Override (not recommended): git commit --no-verify\n')
    sys.exit(1)

print('✅ HES Safety Validator v3.2 — OK')
```

---

## Commit-msg Hook: SDD Commit Checker

**File:** `scripts/hooks/sdd_commit_checker.py`

```python
#!/usr/bin/env python3
"""HES SDD Commit Checker v3.2 — commit-msg hook
Computational sensor: validates Conventional Commits and HES stage."""
import sys, re

VALID_TYPES = [
    'feat', 'fix', 'docs', 'test', 'refactor',
    'chore', 'spec', 'design', 'data', 'discovery', 'review',
    'harness',   # ← NEW v3.2: harness improvement commits
    'fitness',   # ← NEW v3.2: fitness function commits
]
PATTERN = re.compile(
    r'^(' + '|'.join(VALID_TYPES) + r')(\(\w[\w-]*\))?!?: .{10,}$'
)

msg_file = sys.argv[1]
with open(msg_file) as f:
    msg = f.read().strip()

first_line = msg.split('\n')[0]

if not PATTERN.match(first_line):
    print('\n🚨 HES Commit Checker v3.2 — Invalid message\n')
    print(f'  Received : {first_line}')
    print(f'  Expected : <type>(<scope>): <description with 10+ chars>')
    print(f'  Types    : {", ".join(VALID_TYPES)}')
    print(f'  Examples : feat(payment): implement PIX endpoint')
    print(f'             harness(arch): add ArchUnit rules for service layer\n')
    sys.exit(1)

print('✅ HES Commit Checker v3.2 — OK')
```

---

## Install Script

**File:** `scripts/hooks/install.sh`

```bash
#!/usr/bin/env bash
set -e
echo "🔧 Installing HES Git Hooks v3.2..."
HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
SCRIPTS_DIR="$(git rev-parse --show-toplevel)/scripts/hooks"
ln -sf "$SCRIPTS_DIR/safety_validator.py"   "$HOOKS_DIR/pre-commit"
ln -sf "$SCRIPTS_DIR/sdd_commit_checker.py" "$HOOKS_DIR/commit-msg"
chmod +x "$SCRIPTS_DIR"/*.py
echo "✅ Hooks installed (HES v3.2 computational sensors):"
echo "   pre-commit  → safety_validator.py"
echo "   commit-msg  → sdd_commit_checker.py"
echo ""
echo "Test: git commit --allow-empty -m 'harness: validate HES v3.2 hooks'"
```

---

## Installation

```bash
bash scripts/hooks/install.sh
```
