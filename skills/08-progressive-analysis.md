# HES Skill — 08: Progressive Analysis

> Skill loaded when: analyzing a large codebase (>50 files) or resuming an interrupted session.
> Objective: incremental analysis with state preservation between sessions.
> Precondition: project exists with code to analyze.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Check if .hes/state/analysis-state.json exists:
   → Yes: previous session interrupted — follow STEP 5 (recovery)
   → No: new analysis — follow STEP 1 (generate tree)
2. If state exists, load and show progress:
   → Files analyzed: X/Y
   → Last file processed: {{PATH}}
   → Rules mapped: {{N}}
   → Open questions: {{N}}
3. If state does not exist, verify the project exists:
   → ls of root directory confirms code is present
```

---

## ◈ ANTI-HALLUCINATION — MANDATORY BEFORE ANY ANALYSIS

```
[ ] Do not assume dependencies not explicit in imports
[ ] Do not invent business rules not evident in the code
[ ] If a file is too large (>500 lines), summarize only the structure,
    do not attempt line-by-line analysis
[ ] Cite the exact file path when referencing code
[ ] Do not generalize patterns from one file to the entire project without verifying
[ ] Domain rules must be in the code or project docs — do not infer
```

If any item is uncertain → register as an open question, do not invent.

---

## ◈ STEP 1 — GENERATE FILE TREE (if it does not exist)

> Executed only once per feature. Produces the inventory that guides incremental analysis.

### 1.1 — Scan structure

```bash
# Generate project JSON inventory
cd {{ROOT_DIRECTORY}} && find . -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/.venv/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  -not -path '*/__pycache__/*' \
  -not -name '*.lock' \
  -not -name '*.log' | sort
```

### 1.2 — Classify by priority

Apply scoring rules:

| Priority | File Type | Examples |
|----------|-----------|----------|
| 10 | Entry points | `main.py`, `app.py`, `index.js`, `server.js`, `Application.java` |
| 9 | Config files | `package.json`, `pom.xml`, `settings.py`, `application.yml`, `tsconfig.json`, `.env` |
| 8 | Domain entities / models | `*entity*`, `*model*`, `*domain*`, `*/entities/*` |
| 7 | Use cases / services | `*service*`, `*usecase*`, `*use_case*`, `*/services/*` |
| 6 | Adapters / controllers | `*controller*`, `*adapter*`, `*handler*`, `*/routes/*` |
| 5 | Utilities / helpers | `*util*`, `*helper*`, `*common*`, `*shared*` |
| 3 | Tests | `*test*`, `*spec*`, `*/tests/*` |
| 1 | Docs, READMEs, static | `README*`, `*.md`, `*.txt`, `static/*` |

### 1.3 — Generate `.hes/state/file-tree.json`

```json
{
  "project": "{{PROJECT_NAME}}",
  "generated_at": "{{ISO_DATE}}",
  "total_files": 142,
  "total_directories": 35,
  "files": [
    {
      "path": "src/main/app.py",
      "size_bytes": 4521,
      "type": "python",
      "priority": 10,
      "is_entry_point": true,
      "analyzed": false
    }
  ]
}
```

> **Note:** The `files` array order MUST be descending by `priority` (10 first, 1 last).

---

## ◈ STEP 2 — ANALYZE NEXT BATCH (chunked processing)

> Process files in priority order. Each file generates an individual analysis document.

### 2.1 — Determine batch size

```
How many files to analyze in this cycle? (suggestion: 5-10 at a time)
- Small codebase (<200 files): 10 per batch
- Medium codebase (200-500): 5 per batch
- Large codebase (>500): 3 per batch

If tokens are running low → reduce to 1-2 per batch.
```

### 2.2 — For EACH file in the batch:

```
1. Read file content (truncate at 500 lines if larger)
2. Identify:
   - Imports/dependencies
   - Classes, functions, methods
   - Business rules (RN-xx — only if explicit in code or comments)
   - Architectural patterns (if evident)
3. Generate individual document at:
   .hes/analysis/{{feature}}/files/{{file-slug}}.md
4. Mark as analyzed=true in file-tree.json
5. Update cumulative state (STEP 3)
```

### 2.3 — Individual analysis template

> Save to `.hes/analysis/{{feature}}/files/{{file-slug}}.md`

```markdown
# Analysis — {{FILE_PATH}}

Feature: {{FEATURE}} | Analyzed: {{ISO_DATE}} | Analyst: hes-v3.3

## Purpose
{{WHAT THIS FILE DOES IN 1-2 SENTENCES}}

## Key Components
| Component | Type | Responsibility |
|-----------|------|----------------|
| {{CLASS_OR_FUNC}} | Class/Function | {{WHAT IT DOES}} |

## Dependencies
| Module | Type | Direction |
|--------|------|-----------|
| {{IMPORT}} | Direct/Transitive | Inbound/Outbound |

## Domain Rules
| Rule ID | Description | Implementation |
|---------|-------------|----------------|
| {{RN-XX}} | {{RULE}} | {{HOW IT WAS IMPLEMENTED}} |

## Observations
- {{OBSERVATION_1}}
- {{OBSERVATION_2}}

## Questions
- [ ] {{OPEN_QUESTION — or "None"}}
```

> **Anti-hallucination:** If the file is large (>500 lines), fill only the Key Components table with the structure (class/function names), without detailing each body.

---

## ◈ STEP 3 — UPDATE CUMULATIVE STATE

> Run AFTER each processed batch. Ensures progress is never lost.

### 3.1 — Update `.hes/state/analysis-state.json`

```json
{
  "feature": "{{FEATURE_SLUG}}",
  "started_at": "{{ISO_DATE}}",
  "last_updated": "{{ISO_DATE}}",
  "total_files": 142,
  "analyzed_count": 45,
  "pending_count": 97,
  "current_file": "src/services/payment.py",
  "status": "in_progress|completed|interrupted",
  "summary": {
    "domain_rules_found": 12,
    "architectural_patterns": ["hexagonal", "cqrs"],
    "key_files_analyzed": ["main.py", "config.py", "models.py"],
    "open_questions": 3
  }
}
```

### 3.2 — Also update `file-tree.json`

```json
// For each file processed in the batch:
"files[i].analyzed": true
```

### 3.3 — When to stop

```
Stop the current batch if:
- Remaining tokens < 10% of budget
- Agent detects response quality degradation
- User requests a pause

When stopping:
1. Save analysis-state.json (STEP 3.1)
2. Save updated file-tree.json
3. Register status = "interrupted"
4. Next session resumes automatically (STEP 5)
```

---

## ◈ STEP 4 — GENERATE CONSOLIDATED SUMMARY

> Executed when analysis is complete (analyzed_count == total_files) or on user demand.

### 4.1 — Generate `.hes/analysis/{{feature}}/summary.md`

```markdown
# Consolidated Analysis — {{FEATURE}}

Date: {{DATE}} | Files analyzed: X/Y | Status: {{STATUS}}

## Codebase Overview
{{PROJECT_SUMMARY_IN_3_PARAGRAPHS}}

## Identified Architecture
{{FOUND_PATTERNS — e.g., hexagonal, MVC, CQRS, event-driven}}

## Mapped Business Rules
| ID | Rule | File(s) | Confidence |
|----|------|---------|------------|
| RN-01 | {{RULE}} | {{FILES}} | High/Medium/Low |

## Critical Dependencies
{{DEPENDENCY_MAP — which external modules the project uses}}

## Identified Technical Debt
{{FOUND_ISSUES — TODOs, FIXMEs, duplicated code, coupling}}

## Risks
{{IDENTIFIED_RISKS — outdated dependencies, single points of failure}}

## Open Questions
- [ ] {{QUESTION}}

## Analysis Files
- `.hes/analysis/{{feature}}/files/` → individual per-file analyses
- `.hes/state/file-tree.json` → complete inventory with status
- `.hes/state/analysis-state.json` → progress tracker
```

### 4.2 — Update end state

```json
// .hes/state/analysis-state.json
{
  "status": "completed",
  "completed_at": "{{ISO_DATE}}"
}
```

---

## ◈ STEP 5 — SESSION RESUMPTION (recovery protocol)

> Executed automatically when the skill is loaded and the state file exists with status != "completed".

### 5.1 — Detect interrupted session

```
🔄 Previous session interruption detected.

Progress recovered:
  Files analyzed: {{ANALYZED_COUNT}}/{{TOTAL_FILES}}
  Last file: {{CURRENT_FILE}}
  Mapped business rules: {{DOMAIN_RULES_COUNT}}
  Open questions: {{OPEN_QUESTIONS_COUNT}}

  [A] "continue analysis" → resumes from next pending file
  [B] "generate partial summary" → generates summary.md with current progress
  [C] "restart analysis" → clears state and starts from scratch
```

### 5.2 — Option A: Continue analysis

```
1. Load .hes/state/analysis-state.json
2. Load .hes/state/file-tree.json
3. Find next file with analyzed = false (highest priority)
4. Resume from STEP 2 with that file as the start of the batch
5. Display progress: "Analyzing file X of Y: {{file_path}}"
```

### 5.3 — Option B: Partial summary

```
1. Collect all already-analyzed files
2. Execute STEP 4 with available data
3. In summary.md, mark status = "partial (X/Y files)"
4. Keep analysis-state.json with status = "in_progress"
```

### 5.4 — Option C: Restart analysis

```
1. Confirm with user: "This will erase {{ANALYZED_COUNT}} completed analyses. Continue?"
2. If yes:
   → Remove .hes/state/analysis-state.json
   → Remove .hes/analysis/{{feature}}/files/
   → Return to STEP 1
```

---

## ◈ GENERATED DIRECTORIES

```
.hes/
├── state/
│   ├── file-tree.json              ← complete inventory with priorities
│   └── analysis-state.json         ← progress tracker
└── analysis/
    └── {{feature}}/
        ├── summary.md              ← consolidated summary
        └── files/
            ├── app-py.md           ← individual per-file analysis
            ├── config-py.md
            └── ...
```

---

## ◈ USAGE NOTES

```
- This skill is REUSABLE — it contains no hardcoded values from a specific project
- Batch size should be adjusted according to available token budget
- For very large codebases (>1000 files), consider scoping by directory:
  → Analyze only src/ first, then tests/, then docs/
- The state file IS THE ONLY SOURCE OF TRUTH for progress — always save it before
  any operation that may consume significant tokens
```

---

▶ NEXT ACTION — CHOOSE FLOW

```
What to do now?

  [A] "start analysis of {{FEATURE}}"
      → STEP 1: generate file tree (if it does not exist yet)

  [B] "resume previous analysis"
      → STEP 5: recovery protocol — load state and continue

  [C] "analyze only directory {{PATH}}"
      → Execute STEP 1 with scope limited to the subdirectory

  [D] "generate summary of current analysis"
      → STEP 4: consolidate completed analyses into summary.md

📄 Related skill-files:
  → skills/01-discovery.md (initial feature understanding)
  → skills/02-spec.md (specification after analysis)
  → skills/03-design.md (component design)
  → skills/error-recovery.md (if session fails repeatedly)
```
