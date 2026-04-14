# Git Hooks Reference — LLM-Executable Sensors

> **v3.4 Change**: All computational sensors are now LLM-executed instructions.
> No Python scripts. The LLM runs these checks autonomously before each commit.

---

## Pre-commit: Safety Validator

**Trigger**: Before every `git commit`

**The LLM MUST check staged files for:**

```
BLOCKED PATTERNS (commit BLOCKED if found):
  (?i)(password|secret|api_key|token)\s*=\s*["\'][^"\']{4,}
      → Hardcoded secret detected
  (?i)DROP\s+TABLE
      → DROP TABLE without explicit approval (HES RULE-04)
  (?i)DELETE\s+FROM\s+\w+\s*;
      → DELETE without WHERE clause
  (?i)TRUNCATE\s+TABLE
      → TRUNCATE without explicit approval (HES RULE-04)
  \bTODO\b|\bFIXME\b|\bHACK\b
      → Unresolved pending task in code

SKIP EXTENSIONS: .lock, .sum, .mod, .png, .jpg, .svg, .ico, .bin
```

**Execution:**
```
1. git diff --cached --name-only  → list staged files
2. For each file (skipping SKIP_EXTENSIONS):
   → Read file content
   → Check each BLOCKED PATTERN
   → If any match found → BLOCK COMMIT with details
3. If no violations → proceed with commit
```

---

## Commit-msg: SDD Commit Checker

**Trigger**: Before every `git commit`

**The LLM MUST validate commit message:**

```
VALID TYPES:
  feat, fix, docs, test, refactor, chore, spec, design,
  data, discovery, review, harness, fitness

PATTERN: ^(<type>)(<scope>)?!?:\s.{10,}$
  → Type is required
  → Scope is optional (wrapped in parentheses)
  → Breaking change: ! before : (optional)
  → Description: minimum 10 characters

VALID EXAMPLES:
  feat(payment): implement PIX checkout flow
  fix(auth): resolve token refresh race condition
  docs: update API documentation for v2
  harness: add ArchUnit rules for service layer
  refactor!: break backward compatibility for v2 API

INVALID EXAMPLES:
  fixed bug              → missing type
  feat: fix              → description too short
  Feat(Payment): add X   → wrong casing
```

**Execution:**
```
1. Read .git/COMMIT_EDITMSG (commit message file)
2. Extract first line
3. Match against PATTERN
4. If no match → BLOCK COMMIT with expected format
5. If match → proceed with commit
```

---

## Pre-commit: File Size Check

**Trigger**: Before every `git commit`

```
MAX FILE SIZES:
  → Source code: no limit
  → Binary files (.png, .jpg, .pdf): max 1MB each
  → Total diff size: warn if > 5MB

Execution:
1. git diff --cached --name-only --diff-filter=ACM
2. For binary files > 1MB → WARN and suggest compression
3. For total diff > 5MB → WARN about large commit
```

---

## Pre-commit: Sensitive Data Scanner

**Trigger**: Before every `git commit`

```
SCAN FOR (in file content AND filename):
  → .env, .pem, .key, .credentials, .p12
  → password*, secret*, api_key*, token*
  → AWS keys, GCP tokens, Stripe keys
  → Database connection strings with credentials

If any found in staged files:
  → BLOCK COMMIT
  → List: file, line, detected pattern
  → Suggest: add to .gitignore and use env variables
```

---

## ◈ LLM RESPONSIBILITY

The LLM executes ALL sensors autonomously before each commit.
No scripts required. The LLM IS the computational sensor.

**Protocol:**
```
On git commit:
  1. Run pre-commit sensors (secrets, size, sensitive data)
  2. If BLOCKED → output violations and abort commit
  3. If PASSED → proceed with commit
  4. Run commit-msg sensor on commit message
  5. If BLOCKED → output expected format and abort
  6. If PASSED → commit completes
```
