---
name: issue-create
version: 1.0.0
trigger: /hes issue | /hes bug | /hes improvement
author: HES Team | 2026
framework: HES — Harness Engineer Standard v3.3
---

# HES Skill — 09: Issue Creation

> Skill for creating well-structured GitHub Issues with automatic diagnostic collection.
> Triggered by: /hes issue, /hes bug, /hes improvement

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Determine issue type:
   - /hes bug      → bug template
   - /hes improvement → improvement template
   - /hes issue    → ask user to classify

2. Collect diagnostics (run these commands):
   - HES version: grep from SKILL.md YAML header (version field)
   - OS: uname -a (or equivalent)
   - IDE/CLI: read from .hes/state/current.json (ide field if present)
   - Git commit: git describe --tags 2>/dev/null || git rev-parse --short HEAD
   - gh CLI: gh --version 2>/dev/null || echo "not installed"
   - Relevant runtime: detect project type (node --version, java -version, python --version)
   - State file: cat .hes/state/current.json
```

---

## ◈ PROTOCOL

### STEP 1 — DETECT TYPE

```
If trigger was /hes bug:
  → template = bug
If trigger was /hes improvement:
  → template = improvement
If trigger was /hes issue or ambiguous:
  → Ask: "Is this a bug report or an improvement suggestion?"
    [A] Bug → template = bug
    [B] Improvement → template = improvement
```

### STEP 2 — COLLECT DIAGNOSTICS

```
Run the following and capture results:

1. HES_VERSION: Extract version from SKILL.md header
   → grep "version:" SKILL.md → extract value

2. OS_INFO: uname -a

3. IDE_CLI: Read from .hes/state/current.json if exists
   → Fallback: detect from environment ($TERM_PROGRAM, $EDITOR, etc.)

4. GIT_COMMIT: git describe --tags || git rev-parse --short HEAD

5. GH_CLI_VERSION: gh --version || "not installed"

6. RELEVANT_RUNTIME:
   → If package.json exists: node --version
   → If pom.xml exists: java -version
   → If requirements.txt exists: python --version
   → Else: "N/A"

7. STATE_FILE_CONTENT: cat .hes/state/current.json (or "not initialized")

Store all values for template filling.
```

### STEP 3 — GATHER USER INPUT

```
Ask the user:

1. "What is the issue title?" (required — must be descriptive)

2. For BUG type:
   a. "Describe the bug — what happened?" (required)
   b. "What was the expected behavior?" (required)
   c. "Steps to reproduce (numbered, one per line):" (required)
   d. "Any additional context, screenshots, or logs?" (optional)

3. For IMPROVEMENT type:
   a. "What do you want to improve?" (required)
   b. "Why does this matter?" (required)
   c. "Proposed solution (optional):"
   d. "Alternatives considered (optional):"
```

### STEP 4 — GENERATE ISSUE BODY

```
1. Load the appropriate template from .hes/templates/
2. Replace all {{PLACEHOLDER}} values with collected diagnostics
3. Insert user-provided description, steps, context
4. Format as clean markdown
```

Template filling rules:
- {{HES_VERSION}} → extracted version or "unknown"
- {{OS_INFO}} → uname output
- {{IDE_CLI}} → detected IDE or "unknown"
- {{GIT_COMMIT}} → git commit hash
- {{HES_STATE_SNAPSHOT}} → summary of current.json (active_feature, features state)
- {{GH_CLI_VERSION}} → gh version or "not installed"
- {{RELEVANT_RUNTIME}} → detected runtime or "N/A"
- {{STATE_FILE_CONTENT}} → full current.json content (for bug reports)

### STEP 5 — CREATE ISSUE

```
Check if gh CLI is available:

If gh IS available:
  → Run: gh issue create --title "<title>" --body-file <temp-file-with-body> --label "<label>"
  → Label: "bug" for bug reports, "enhancement" for improvements
  → Announce: "Issue created: <issue URL>"
  → Log event in .hes/state/events.log

If gh IS NOT available:
  → Print the full generated markdown
  → Announce: "gh CLI not found. Please copy the markdown below and create the issue manually at: <repo>/issues/new"
  → Provide the markdown in a code block for easy copying
```

### STEP 6 — LOG EVENT

```
Append to .hes/state/events.log:

{
  "timestamp": "<ISO8601>",
  "feature": "issue-creation",
  "from": "N/A",
  "to": "issue-created",
  "agent": "issue-create-skill",
  "metadata": {
    "type": "bug|improvement",
    "title": "<issue title>",
    "gh_available": true|false,
    "diagnostics_collected": true
  }
}
```

---

## ◈ ERROR HANDLING

| Scenario | Behavior |
|----------|----------|
| SKILL.md not found | Use "unknown" for HES version, continue |
| .hes/state/ missing | Use "not initialized" for state, continue |
| gh CLI fails with rate limit | Print markdown fallback, show error message |
| User provides empty title | Reject, ask again — title is mandatory |
| Template file missing | Generate basic markdown without template, warn user |

---

## ◈ NEXT ACTION FORMAT (mandatory)

```
▶ NEXT ACTION — ISSUE CREATED

Issue type : bug|improvement
Title      : <title>
Method     : gh CLI|manual copy-paste
URL        : <issue URL or "manual creation required">

📄 Template: .hes/templates/issue-{bug|improvement}.md
💡 Tip: Include the state file content for better debugging
```

---

*HES Skill v1.0.0 — Issue Creation (09-issue-create)*
*Auto-diagnostic GitHub Issue generator*
