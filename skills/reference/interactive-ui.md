# HES Interactive UI Protocol v1.1

> Single source of truth for how the harness invokes native interaction tools
> across every CLI and IDE environment it runs on.
>
> The harness is engine-agnostic: it detects the host environment once at
> session start (Step 0-C in SKILL.md) and routes ALL user-choice moments
> through the tool mapped for that environment — automatically, without
> changing any skill-file logic.

---

## ◈ ENVIRONMENT MAP

| IDE / CLI          | interaction_tool    | Availability | Mechanism                            |
|--------------------|---------------------|--------------|--------------------------------------|
| claude-code        | `AskUserQuestion`   | Native       | LLM tool call (CLI + VS Code + JetBrains) |
| gemini-cli         | `ask_user`          | Native v0.29+ | Dialog via message bus (TUI)        |
| opencode           | `question`          | Native       | Deferred blocking (TUI + HTTP API)  |
| cursor             | `AskQuestion`       | Plan Mode only | Chat-embedded question widget      |
| windsurf           | `null`              | Not native   | Text fallback (Cascade chat)        |
| vscode-copilot     | `null`              | Not native   | Text fallback (feature request open) |
| codex-cli          | `null`              | Not native   | Text fallback (TUI free-text only)  |
| kiro               | `null`              | Not native   | Text fallback (supervised mode chat) |
| generic            | `null`              | —            | Text fallback                       |

`null` = no native structured-choice tool. Use layout-standard.md text format (A / B / C).

> **Cursor note:** `AskQuestion` is currently restricted to Plan Mode.
> Outside Plan Mode (regular Agent Mode) it does not fire.
> Map Cursor to `null` unless the harness is explicitly running in Plan Mode.
> When Plan Mode is confirmed: set `interaction_tool = "AskQuestion"`.

---

## ◈ WHEN TO CALL THE INTERACTIVE TOOL

Call the native tool at every point where the user must make a choice:

| Moment | Examples |
|--------|---------|
| NEXT ACTION block | Phase-end options (advance / revise / pause) |
| Discovery questions | Structured choices before spec |
| Gate approval | "Approve and advance to next phase?" |
| Dependency conflict | "Switch to blocked feature now, or continue?" |
| Error escalation | Sub-agent failed — choose recovery path |
| Rollback confirmation | "/hes rollback — choose target phase" |
| IDE tool selection | Auto-install: which tools to enable |

Open-ended free-text answers (problem statements, business rules) always go
through regular chat — never through a structured-choice tool.

---

## ◈ CLAUDE CODE — `AskUserQuestion`

Available in: Claude Code CLI, VS Code extension, JetBrains plugin.

### Call schema

```json
{
  "questions": [
    {
      "question": "<full question text shown to user>",
      "header": "<short label, max 12 chars>",
      "options": [
        { "label": "<choice label>", "description": "<what this choice does>" },
        { "label": "<choice label>", "description": "<what this choice does>" }
      ],
      "multiSelect": false
    }
  ]
}
```

- `questions`: 1–4 per call; split larger sets into sequential calls
- `options`: 2–4 per question
- `multiSelect: true` for checkboxes (e.g. IDE tool selection)
- `header`: TUI tab label — keep ≤ 12 chars

### Return value

```json
{ "answers": { "<question text>": "<selected label>" } }
```

Multi-select: labels joined as `"Claude Code, Cursor"`.

### Patterns

**NEXT ACTION (gate approval):**
```json
{
  "questions": [{
    "question": "SPEC is complete. Advance to DESIGN?",
    "header": "Gate",
    "options": [
      { "label": "Advance",  "description": "All gate criteria met — move to DESIGN" },
      { "label": "Revise",   "description": "I want to change something in the spec" },
      { "label": "Pause",    "description": "Save checkpoint and continue later" }
    ],
    "multiSelect": false
  }]
}
```

**Discovery questions (structured choices only):**
```json
{
  "questions": [
    {
      "question": "Who uses this feature?",
      "header": "Persona",
      "options": [
        { "label": "End user",       "description": "Direct consumer of the product" },
        { "label": "Admin",          "description": "Internal operator / back-office" },
        { "label": "External API",   "description": "Third-party system or integration" },
        { "label": "Other",          "description": "Describe in next message" }
      ],
      "multiSelect": false
    },
    {
      "question": "Are there external integrations?",
      "header": "Integrations",
      "options": [
        { "label": "None",           "description": "Fully internal" },
        { "label": "Third-party API","description": "REST/GraphQL external service" },
        { "label": "Legacy system",  "description": "Internal legacy or mainframe" },
        { "label": "Queue/Events",   "description": "Kafka, SQS, RabbitMQ, etc." }
      ],
      "multiSelect": true
    }
  ]
}
```

**IDE tool selection (auto-install, multiSelect):**
```json
{
  "questions": [{
    "question": "Which AI tools do you want HES installed for?",
    "header": "Tools",
    "options": [
      { "label": "Claude Code",     "description": "CLI + VS Code + JetBrains" },
      { "label": "Gemini CLI",      "description": "GEMINI.md + .gemini/" },
      { "label": "OpenCode",        "description": ".opencode/skills/hes/" },
      { "label": "Cursor",          "description": ".cursor/rules/hes.mdc" },
      { "label": "Codex CLI",       "description": "AGENTS.md + .agents/" },
      { "label": "Windsurf",        "description": ".windsurfrules" },
      { "label": "GitHub Copilot",  "description": ".github/copilot-instructions.md" },
      { "label": "Kiro (AWS)",      "description": ".kiro/steering/hes.md" }
    ],
    "multiSelect": true
  }]
}
```

---

## ◈ GEMINI CLI — `ask_user`

Available in: Gemini CLI v0.29+. Renders as a radio-button dialog in the TUI.

### Call schema

```json
{
  "questions": [
    {
      "question": "<full question text>",
      "header": "<short label, max 16 chars>",
      "type": "choice",
      "options": [
        { "label": "<choice>", "description": "<explanation>" }
      ],
      "multiSelect": false
    }
  ]
}
```

Supported `type` values:
- `"choice"` — radio buttons or checkboxes (use `multiSelect: true` for checkboxes)
- `"text"` — free-form input field; set `placeholder` for hint text
- `"yesno"` — Yes / No confirmation dialog

### Return value

```json
{ "answers": { "0": "<selected label>", "1": "<text or label>" } }
```

Answers are indexed by question position (0, 1, 2…), not by question text.

### Patterns

**Gate approval:**
```json
{
  "questions": [{
    "question": "SPEC is complete. Advance to DESIGN?",
    "header": "Gate",
    "type": "choice",
    "options": [
      { "label": "Advance", "description": "Move to DESIGN phase" },
      { "label": "Revise",  "description": "Go back and adjust the spec" },
      { "label": "Pause",   "description": "Checkpoint and stop" }
    ],
    "multiSelect": false
  }]
}
```

**Yes/No confirmation (rollback, destructive actions):**
```json
{
  "questions": [{
    "question": "Roll back from GREEN to RED?",
    "header": "Rollback",
    "type": "yesno"
  }]
}
```

**Free-text question (when a choice list is not sufficient):**
```json
{
  "questions": [{
    "question": "What is the name of the feature?",
    "header": "Feature",
    "type": "text",
    "placeholder": "e.g. payment-processing"
  }]
}
```

---

## ◈ OPENCODE — `question`

Available in: OpenCode CLI (native, always on). Blocks execution via Deferred
pattern until user responds through the TUI or HTTP API.

### Call schema

```json
{
  "sessionId": "<current session ID>",
  "questions": [
    {
      "header": "<question text>",
      "options": [
        { "label": "<choice>", "description": "<explanation>" }
      ],
      "multiSelect": false
    }
  ]
}
```

- `header`: the question text (OpenCode uses `header` for the question string)
- `options`: 2-4 items; each has `label` and `description`
- `multiSelect`: true for multi-select

### Return value

Array of selected label strings: `["Advance"]` or `["Claude Code", "Cursor"]`.

If the user dismisses the dialog, `Question.RejectedError` is thrown —
catch it and fall back to proceeding with the default/safe option and log a warning.

### Pattern

```json
{
  "sessionId": "{{SESSION_ID}}",
  "questions": [{
    "header": "SPEC complete. What next?",
    "options": [
      { "label": "Advance to DESIGN", "description": "All gate criteria met" },
      { "label": "Revise spec",       "description": "Adjust before moving on" },
      { "label": "Pause",             "description": "Save and continue later" }
    ],
    "multiSelect": false
  }]
}
```

---

## ◈ CURSOR — `AskQuestion` (Plan Mode only)

Available in: Cursor Plan Mode only. Outside Plan Mode → `null` (text fallback).

Cursor's `AskQuestion` is invoked by the model as a natural pause during planning.
There is no documented public schema — the model produces the question text and
Cursor renders it in the chat panel as an inline question widget.

### Usage rule

The harness instructs the model to use `AskQuestion` by adding to its prompt:

> "Use the AskQuestion tool for any interaction requiring user input —
> choosing between options, confirming a proposed action, or clarifying
> an ambiguous request."

### Practical fallback within Cursor

Because `AskQuestion` is schema-less from the harness perspective, treat
Cursor as follows:

```
Plan Mode confirmed  → interaction_tool = "AskQuestion" (model-native, no schema)
Agent Mode / other   → interaction_tool = null → text fallback
```

For Plan Mode, the harness outputs structured text that the model will
naturally convert into an AskQuestion call:

```
Choose next action:
  A — Advance to DESIGN (gate criteria met)
  B — Revise spec
  C — Pause and checkpoint
```

---

## ◈ TEXT FALLBACK (interaction_tool == null)

Applies to: Windsurf, GitHub Copilot/VS Code, Codex CLI, Kiro, Cursor (Agent Mode).

Use the layout-standard.md NEXT ACTION format:

```
────────────────────────────────────────────────────────────────
  {{PHASE}} complete
  {{summary}}
────────────────────────────────────────────────────────────────
  → {{NEXT_PHASE}}                         skills/{{NN-name}}.md

  A  {{happy path}}
  B  {{adjust/fix}}
  C  {{edge case or question}}

  💡 {{concrete tip}}
────────────────────────────────────────────────────────────────
```

**Windsurf note:** Cascade reads the text options and waits for the user to
type a letter or phrase. Works reliably in both Write and Agent modes.

**Kiro note:** Kiro's Supervised Mode shows accept/reject buttons for tool
calls. Text options presented in chat are answered by the user typing a reply.

**Codex CLI note:** Codex has a rich TUI but no native question tool.
The user types `a`, `b`, or `c` in the composer.

**GitHub Copilot note:** An "Ask tool" is an open feature request
(vscode/issues#285952). Until merged, text fallback is the only option.

---

## ◈ DETECTION DURING AUTO-INSTALL

When `current.json` does not yet exist, detect the host from the filesystem:

```
.claude/      present  →  claude-code   →  AskUserQuestion
.gemini/      present  →  gemini-cli    →  ask_user
.opencode/    present  →  opencode      →  question
.cursor/      present  →  cursor        →  null (unless Plan Mode confirmed)
.windsurfrules present →  windsurf      →  null
.kiro/        present  →  kiro          →  null
.github/copilot-instructions.md → vscode → null
AGENTS.md     present  →  codex-cli     →  null
none of above           →  generic      →  null
```

Multiple markers → prefer the first match in the order above (most capable first).

---

## ◈ RULES

```
UI-01  Read interaction_tool from current.json BEFORE every decision point.
UI-02  During auto-install, detect IDE from filesystem (table above).
UI-03  NEVER mix modes in a session — if Mode A at bootstrap, ALL subsequent
       decisions in the same session must also use Mode A.
UI-04  Open-ended free-text questions are NEVER routed through a choice tool.
       Use chat for prose answers; use choice tools only for structured options.
UI-05  Max questions per call: 4 (AskUserQuestion, ask_user, question).
       Split larger sets into sequential calls.
UI-06  multiSelect: true only when the user must pick more than one item.
UI-07  After receiving answers, update current.json if any answer affects state
       (e.g. ide selection, audience_mode, feature name).
UI-08  On Question.RejectedError (OpenCode) or timeout: proceed with the default
       safe option, log a WARNING to events.log.
UI-09  Cursor outside Plan Mode → treat as null regardless of .cursor/ presence.
```

---

*HES Interactive UI Protocol v1.1 — Josemalyson Oliveira | 2026*
