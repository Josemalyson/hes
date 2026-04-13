# HES Skill — 00: Bootstrap

> Skill loaded when: global state = ZERO (new project) or HARNESS_INSTALLED (no active feature).
> Execute this file in full before any action.

---

## ◈ EXPECTED CONTEXT

This skill is invoked when:
- `.hes/state/current.json` does not exist (new project)
- Project exists but without HES structure
- Harness installed but without an active feature defined

---

## ◈ STEP 1 — COLLECT INFORMATION (maximum 4 questions)

```
🚀 HES Bootstrap v3.2 — I'll configure the project harness.

I need 4 pieces of information:

1. Project name (e.g., livehome, payment-service): [AUTO-GENERATE]
2. Primary stack (e.g., Java 17 + Spring Boot / Node + NestJS / Python + FastAPI): [AUTO-GENERATE]
3. Is this a new project or do you want to integrate existing code? [AUTO-GENERATE]
4. Does the system have defined DDD domains? If so, list them (e.g., billing, auth, catalog — or "no" if it's a simple monolith): [AUTO-GENERATE]
```

Try to auto-generate the answers; if unable, wait for user response.
With the answers, execute the steps below.

---

## ◈ STEP 1.5 — VALIDATE SETUP STRUCTURE

> Before generating any directory, verify that HES files were copied correctly.
> This step runs AFTER the user copies the files and BEFORE generating the structure.

### 0. Pre-check — Hidden Directory

**Before the main checklist, check if there is a hidden `.skills/` directory:**

```bash
# If .skills/ exists but skills/ does not:
if [ -d ".skills" ] && [ ! -d "skills" ]; then
  echo "⚠ Attention: hidden '.skills/' folder detected."
  echo "   The correct folder is 'skills/' (without the dot)."
  echo "   Rename it: mv .skills skills"
fi
```

### 1. Validation Checklist

Run the checks below (use `ls`, `test -f`, `test -d` or equivalent):

```
📋 Validating HES file structure v3.2...

  [ ] SKILL.md exists at project root
  [ ] Directory skills/ exists (VISIBLE, not .skills/)
  [ ] skills/00-bootstrap.md
  [ ] skills/01-discovery.md
  [ ] skills/02-spec.md
  [ ] skills/03-design.md
  [ ] skills/04-data.md
  [ ] skills/05-tests.md
  [ ] skills/06-implementation.md
  [ ] skills/07-review.md
  [ ] skills/legacy.md
  [ ] skills/error-recovery.md
  [ ] skills/refactor.md
  [ ] skills/report.md
  [ ] skills/harness-health.md
```

**If any file is missing**, display a clear error:

```
🚨 HES structure INCOMPLETE — the following files were not found:

  ❌ skills/02-spec.md
  ❌ skills/05-tests.md

Possible actions:
  1. Recopy the skills/ folder from the original HES repository
  2. Verify the destination path is correct (must be skills/, not .skills/)
  3. Run this bootstrap again after fixing
```

### 2. Installation Type

If the structure is valid, ask the user:

```
📦 Installation Type — how will HES be used?

  [A] Local (this project only)
      → Files stay in the project, versioned with git
      → Ideal: isolated project, each project has its own version

  [B] Global (shared across projects)
      → Files in ~/.hes/skills/ with symlinks in projects
      → Ideal: multiple projects, centralized updates
      → Command:
        # Copy to global location
        cp -r skills/ ~/.hes/skills/

        # Remove local copy and create symlink
        rm -rf skills/
        ln -s ~/.hes/skills/ ./skills
```

- If **[A] Local**: register `"installation_type": "local"` and proceed to Step 2.
- If **[B] Global**: perform the copy and symlink creation, register `"installation_type": "global"`, then proceed to Step 2.

### 3. Generate Validation Report

Save the result to `.hes/state/setup-validation.json`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "installation_type": "local|global",
  "structure_valid": true|false,
  "files_expected": ["SKILL.md", "skills/00-bootstrap.md", "skills/01-discovery.md", "skills/02-spec.md", "skills/03-design.md", "skills/04-data.md", "skills/05-tests.md", "skills/06-implementation.md", "skills/07-review.md", "skills/legacy.md", "skills/error-recovery.md", "skills/refactor.md", "skills/report.md", "skills/harness-health.md"],
  "files_missing": [],
  "issues": []
}
```

- `files_expected`: full list of files that should exist
- `files_missing`: list of files not found (empty if all present)
- `issues`: list of additional issues (e.g., `"skills/ is hidden (.skills/), should be visible"`)
- `structure_valid`: `true` only if `files_missing` is empty

---

## ◈ STEP 1.5.1 — IDE AUTO-DETECTION (NEW in v3.2)

> Detect the IDE environment and generate specific configuration automatically.

### Detection Order

```
1. Check for marker files/dirs:
   - .vscode/ → VS Code
   - .cursor/ or .cursorrules → Cursor
   - .claude/ or CLAUDE.md → Claude Code
   - .gemini/ → Gemini CLI
   - .openhands/ → OpenHands
   - .windsurf/ → Windsurf

2. If multiple detected → ask user:
   "Detected: {{list_of_IDEs}}. Which is your primary IDE?"

3. If none detected → ask user:
   "What IDE/editor are you using?"
   [A] Claude Code  [B] Cursor  [C] VS Code  [D] Windsurf  [E] Copilot  [F] OpenHands  [G] Other
```

### IDE-Specific Config Generation

**Claude Code detected (or selected):**
```bash
mkdir -p .claude
```

Generate `.claude/CLAUDE.md` with updated HES v3.2 content (update version references in the existing STEP 5 content to v3.2).

**Cursor detected (or selected):**
Generate `.cursorrules`:
```
# HES — Harness Engineer Standard v3.2

When receiving /hes or any engineering command:
1. Read SKILL.md at the project root
2. Read .hes/state/current.json and .hes/agents/registry.json
3. Identify the correct agent via registry for the current phase
4. Load ONLY the context defined in the registry
5. Follow the agent's skill-file without deviations
6. NEVER skip steps — phase lock is mandatory
7. Orchestrator NEVER implements — only routes
8. Always end with the NEXT ACTION block
```

**VS Code detected (or selected):**
```bash
mkdir -p .vscode
```

Generate `.vscode/hes-agent.md`:
```markdown
# HES Agent for VS Code — v3.2

When working on this project:
1. Read SKILL.md first
2. Read .hes/state/current.json to identify phase
3. Read .hes/agents/registry.json to identify agent
4. Load only the context specified in registry
5. Follow the agent's skill-file
6. Never skip stages — phase lock enforced
```

**Windsurf detected (or selected):**
Generate `.windsurfrules` (same content as `.cursorrules`)

**Generic (none detected or "Other"):**
Generate `AGENTS.md`:
```markdown
# HES — Harness Engineer Standard v3.2

When starting any session:
1. Read SKILL.md at the project root
2. Read .hes/state/current.json to identify state
3. Read .hes/agents/registry.json to identify agent
4. Load the corresponding agent's skill-file
5. Follow the skill-file instructions without deviations
6. NEVER skip steps
7. Orchestrator NEVER implements — only routes
8. Always end with the NEXT ACTION block
```

### Register IDE in current.json

Add `"ide": "{{detected_ide}}"` to the current.json schema in STEP 3.

---

## ◈ STEP 1.6 — AGENT REGISTRY INIT (NEW in v3.2)

> Generate the agent registry file.

```bash
mkdir -p .hes/agents
```

Verify `.hes/agents/registry.json` exists (should already exist from Task 1). If not found, display warning:
```
🚨 Agent registry not found: .hes/agents/registry.json

Please ensure HES v3.2 agent registry is installed.
```

If registry exists, validate:
```bash
python3 -c "import json; r=json.load(open('.hes/agents/registry.json')); assert r['version'] == '3.2.0'; print('Registry OK')"
```

If version < 3.2.0, prompt for upgrade.

---

## ◈ STEP 1.7 — SESSION MANAGER INIT (NEW in v3.2)

> Initialize the session manager and checkpoint file.

1. Verify `skills/session-manager.md` exists. If not:
```
🚨 Session manager skill not found: skills/session-manager.md

Please ensure HES v3.2 skill-files are installed.
```

2. Generate empty checkpoint:

```json
{
  "timestamp": null,
  "feature": null,
  "phase": null,
  "agent": null,
  "last_action": null,
  "completed_steps": [],
  "pending_steps": [],
  "context_summary": "",
  "artifacts_created": [],
  "context_tokens_remaining": null
}
```

Save to `.hes/state/session-checkpoint.json`.

3. Verify session-manager entry exists in registry.json.

---

## ◈ STEP 2 — GENERATE DIRECTORY STRUCTURE

```bash
# HES base structure
mkdir -p .claude/commands
mkdir -p .hes/state
mkdir -p .hes/specs
mkdir -p .hes/decisions
mkdir -p .hes/tasks
mkdir -p .hes/inventory
mkdir -p scripts/hooks

# If DDD domains exist
for domain in {{PROVIDED_DOMAINS}}; do
  mkdir -p .hes/domains/$domain/decisions
  mkdir -p .hes/domains/$domain/fitness   # ← NEW v3.2: computational sensors per domain
done
```

The `fitness/` folder is where architecture fitness computational sensors live
(ArchUnit rules, dep-cruiser config, import-linter rules) — generated in Step 9.

---

## ◈ STEP 3 — GENERATE `.hes/state/current.json`

```json
{
  "project": "{{PROJECT_NAME}}",
  "stack": "{{STACK}}",
  "active_feature": null,
  "features": {},
  "domains": [{{DOMAINS_OR_EMPTY_ARRAY}}],
  "dependency_graph": {},
  "harness_version": "3.2.0",
  "completed_cycles": 0,
  "last_updated": "{{CURRENT_ISO_DATE}}"
}
```

---

## ◈ STEP 4 — GENERATE `.hes/state/events.log`

```json
[
  {
    "timestamp": "{{CURRENT_ISO_DATE}}",
    "feature": "global",
    "from": "NONE",
    "to": "HARNESS_INSTALLED",
    "agent": "hes-v3.2",
    "metadata": {
      "project": "{{PROJECT_NAME}}",
      "stack": "{{STACK}}",
      "harness_version": "3.2.0"
    }
  }
]
```

---

## ◈ STEP 5 — GENERATE `.claude/CLAUDE.md`

```markdown
# Agent Identity — {{PROJECT_NAME}}

## Mission
You are a Harness Engineer (HES v3.2) for the project {{PROJECT_NAME}}.
Your role is to conduct the 7-step SDD+TDD pipeline deterministically.

NEVER write code before completing approved Steps 1–4.
ALWAYS read SKILL.md at the start of each session.
ALWAYS read .hes/state/current.json to identify the current state.
ALWAYS end any action with the NEXT ACTION block.

## Stack
{{STACK}}

## Inviolable Rules
1. Read SKILL.md before any action
2. Follow the 7 steps in order — no skipping
3. Consult specs/ before implementing anything
4. Record decisions in .hes/decisions/ as ADRs
5. Update lessons.md after any error or learning
6. Never assume business rules — always ask
7. Recurring issue (N >= 2) → improve the harness, not just fix the instance

## Harness Taxonomy (Fowler, 2026)
Guides (feedforward): SKILL.md, skill-files, specs, CLAUDE.md, domain context
Sensors (feedback):   git hooks, build, coverage, linters, ArchUnit/dep-cruiser
Dimensions: Maintainability | Architecture Fitness | Behaviour

## Available Skill-files
- SKILL.md                    → orchestrator (always read first)
- skills/00-bootstrap.md      → initial configuration
- skills/01-discovery.md      → problem understanding
- skills/02-spec.md           → BDD scenarios + API contracts
- skills/03-design.md         → architecture + ADR + fitness functions
- skills/04-data.md           → schema + migrations
- skills/05-tests.md          → tests before code (RED) + ArchUnit
- skills/06-implementation.md → minimal implementation (GREEN)
- skills/07-review.md         → 5-dimension review + DONE
- skills/legacy.md            → inventory + harnessability assessment
- skills/error-recovery.md    → error diagnosis and resolution
- skills/refactor.md          → safe refactoring by type
- skills/report.md            → batch learning from events.log
- skills/harness-health.md    → 3-dimension regulation diagnosis

## Current State
See: .hes/state/current.json
```

---

## ◈ STEP 6 — GENERATE `.hes/tasks/lessons.md`

```markdown
# Lessons Learned — {{PROJECT_NAME}}

> Updated after each session (hot path) and consolidated via /hes report (offline).
> Lessons that appear 2x are promoted to the corresponding skill-file.
> Recurring issue → improve the harness, not just the instance (Fowler, 2026).

## Categories
A — HES rule violation
B — Recurring technical error
C — Guide gap (insufficient feedforward)
D — Sensor gap (feedback did not detect)
E — Process (approval flow, communication)

## Consolidated Lessons (promoted to SKILL.md or skill-file)
_none yet_

---
```

---

## ◈ STEP 7 — GENERATE `.hes/tasks/backlog.md`

```markdown
# Backlog — {{PROJECT_NAME}}

## 🔴 High Priority
_add via /hes start [feature-name]_

## 🟡 Medium Priority

## 🟢 Low Priority

## ✅ Completed
```

---

## ◈ STEP 8 — GENERATE DOMAINS (if provided)

For each domain in `{{PROVIDED_DOMAINS}}`:

### `.hes/domains/{{domain}}/context.md`

```markdown
# Bounded Context — {{DOMAIN}}

Domain: {{DOMAIN}} | Project: {{PROJECT_NAME}}

## Ubiquitous Language
| Term | Definition in domain | Difference from other domains |
|------|---------------------|-------------------------------|
| _to fill_ | | |

## Domain Responsibilities
_what belongs to this context_

## Explicit Boundaries
_what does NOT belong to this context_

## Integrations with Other Domains
| Domain | Integration Type | Protocol |
|--------|-----------------|----------|
| | | |
```

### `.hes/domains/{{domain}}/fitness/README.md`

```markdown
# Fitness Functions — {{DOMAIN}}

Computational architecture fitness sensors for the {{DOMAIN}} domain.
Reference: Fowler (2026) — Architecture Fitness Harness.

## Installed sensors
_to fill after setup in Step 9_

## Defined boundary rules
_to fill after setup_

## How to run
_to fill after setup_
```

---

## ◈ STEP 9 — CONFIGURE ARCHITECTURE FITNESS SENSORS (NEW in v3.2)

> "Feedforward and feedback controls are currently scattered across delivery steps.
>  Building the outer harness is an ongoing engineering practice." — Fowler, 2026

Ask the user:

```
🏗 Configure Architecture Fitness sensors?
   (automatically detects module boundary violations)

  [A] "yes, configure now" → run setup for {{STACK}}
  [B] "later" → register in harness backlog and proceed
```

**If Stack = Java / Spring Boot:**

Generate `src/test/java/{{BASE_PACKAGE}}/architecture/ArchitectureTest.java`:

```java
package {{BASE_PACKAGE}}.architecture;

import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;

@AnalyzeClasses(packages = "{{BASE_PACKAGE}}")
class ArchitectureTest {

    // ─── Layered Architecture Rules ──────────────────────────

    @ArchTest
    static final ArchRule controllers_do_not_depend_on_repositories =
        noClasses()
            .that().resideInAPackage("..controller..")
            .should().dependOnClassesThat()
            .resideInAPackage("..repository..")
            .because("Controller must not access data — violates SRP and HES RULE-01");

    @ArchTest
    static final ArchRule services_do_not_depend_on_controllers =
        noClasses()
            .that().resideInAPackage("..service..")
            .should().dependOnClassesThat()
            .resideInAPackage("..controller..")
            .because("Service must not know about the HTTP layer");

    @ArchTest
    static final ArchRule repositories_do_not_depend_on_services =
        noClasses()
            .that().resideInAPackage("..repository..")
            .should().dependOnClassesThat()
            .resideInAPackage("..service..")
            .because("Repository must not contain business logic");

    // ─── Naming Rules ───────────────────────────────────────────

    @ArchTest
    static final ArchRule controllers_must_have_suffix =
        classes()
            .that().resideInAPackage("..controller..")
            .should().haveSimpleNameEndingWith("Controller");

    @ArchTest
    static final ArchRule services_must_have_suffix =
        classes()
            .that().resideInAPackage("..service..")
            .and().areNotInterfaces()
            .should().haveSimpleNameEndingWith("Service")
            .orShould().haveSimpleNameEndingWith("UseCase");
}
```

Add dependency to `pom.xml`:

```xml
<!-- Architecture Fitness Sensor — HES v3.2 -->
<dependency>
    <groupId>com.tngtech.archunit</groupId>
    <artifactId>archunit-junit5</artifactId>
    <version>1.3.0</version>
    <scope>test</scope>
</dependency>
```

Register in `.hes/domains/{{domain}}/fitness/README.md`:

```markdown
## Installed sensors
- ArchUnit 1.3.0 (computational sensor)

## Boundary rules
- Controller → Service → Repository (unidirectional)
- Suffix naming mandatory

## How to run
mvn test -Dtest=ArchitectureTest
```

**If Stack = Node.js / NestJS / TypeScript:**

```bash
npm install --save-dev dependency-cruiser
npx depcruise --init

# Add to package.json:
# "check:arch": "depcruise --validate src"
# "check:arch:ci": "depcruise --validate --output-type err-long src"
```

Configure `.dependency-cruiser.js` with boundary rules between modules.

**If Stack = Python / FastAPI:**

```bash
pip install import-linter --break-system-packages

# Create .importlinter with boundary contracts:
# [contract: layers]
# type = layers
# layers =
#   api_layer
#   service_layer
#   repository_layer
```

---

## ◈ STEP 10 — GENERATE GIT HOOKS

### `scripts/hooks/safety_validator.py` (pre-commit — computational sensor)

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

### `scripts/hooks/sdd_commit_checker.py` (commit-msg — computational sensor)

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

### `scripts/hooks/install.sh`

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

## ◈ STEP 11 — DISPLAY BOOTSTRAP SUMMARY (v3.2)

```
✅ HES Bootstrap v3.2 Completed — {{PROJECT_NAME}}

Guides installed (feedforward):
  .claude/CLAUDE.md (or equivalent)   ← agent identity
  .hes/state/current.json              ← project state (v3.2 schema)
  .hes/state/events.log                ← transition log (traces)
  .hes/state/session-checkpoint.json   ← session checkpoint (NEW v3.2)
  .hes/agents/registry.json            ← agent registry (NEW v3.2)
  .hes/tasks/lessons.md                ← learning memory
  .hes/tasks/backlog.md                ← feature backlog
  {{.hes/domains/*/context.md}}        ← bounded contexts (if domains)
  {{.hes/domains/*/fitness/}}          ← architecture fitness sensors

Agents registered:
  {{N}} phase agents + {{N}} system agents + {{N}} sub-agents

Sensors installed (feedback):
  scripts/hooks/safety_validator.py    ← pre-commit (computational)
  scripts/hooks/sdd_commit_checker.py  ← commit-msg (computational)
  {{src/.../ArchitectureTest.java}}    ← ArchUnit (if configured)

IDE detected: {{IDE}} → config generated: {{CONFIG_FILE}}
Session manager: skills/session-manager.md ✅
Agent delegation: skills/agent-delegation.md ✅

To activate git hooks:
  bash scripts/hooks/install.sh
```

---

▶ NEXT ACTION — DISCOVERY

```
The harness is installed. What is the first feature you want to develop?

  [A] "I want to implement [feature name]"
      → Start Discovery (skills/01-discovery.md)

  [B] "I want to see the backlog first"
      → Show .hes/tasks/backlog.md

  [C] "the project has existing code to analyze"
      → Load skills/legacy.md for inventory + harnessability assessment

  [D] "/hes harness"
      → Initial harness coverage diagnosis

📄 Next skill-file: skills/01-discovery.md
💡 Tip: Discovery captures Business Rules (RN-xx).
   Anything not captured here causes rework in subsequent steps.
   It is the most important inferential guide in the behaviour harness.
```
