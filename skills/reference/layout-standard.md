# HES Layout Standard v2.0

> Single source of truth for all response and skill-file formatting.
> Every skill-file and every agent response must follow this standard.

---

## ◈ PHASE HEADER (top of every skill-file)

```
# {{NN}} · {{PHASE}} — {{Title}}

phase  {{PHASE}}  ·  pre  {{PREVIOUS_PHASE}}  ·  next  {{NEXT_PHASE}}
gate   {{gate condition}}
skill  skills/{{NN-name}}.md
```

---

## ◈ NEXT ACTION BLOCK (end of every response)

Read `current.json.interaction_tool` before rendering.
Full protocol: `skills/reference/interactive-ui.md`.

**Mode A — interaction_tool != null (e.g. claude-code → AskUserQuestion)**

Output a one-line summary, then call the native tool with structured choices.
Do NOT print A/B/C text — the tool renders the UI.

**Mode B — interaction_tool == null (text fallback)**

Replace the old `▶ NEXT ACTION` code-block format entirely.
Use this structure — plain text, no wrapping code block:

```
────────────────────────────────────────────────────────────────
  {{PHASE}} complete
  {{short summary of what was done — 1 line}}
────────────────────────────────────────────────────────────────
  → {{NEXT_PHASE}}                         skills/{{NN-name}}.md

  A  {{primary action — happy path}}
  B  {{secondary — adjust/fix}}
  C  {{tertiary — question or edge case}}

  💡 {{one concrete tip relevant to the transition}}
────────────────────────────────────────────────────────────────
```

Rules (Mode B):
- A is ALWAYS the happy-path pointer to the next phase
- Options use single letters without brackets: A  B  C  (not [A] [B] [C])
- No code block wrapping the options
- Horizontal rule uses exactly 68 `─` characters
- Summary line: past tense, max 80 chars
- Tip: concrete and specific — never generic like "be careful"

---

## ◈ EXECUTION DIRECTIVES (for steps that run commands)

When a step requires the agent to run a command, use this format:

```
→ EXECUTE
  {{command}}
  expected: {{what success looks like}}
```

Never put executable commands inside a NEXT ACTION block as user instructions.
The agent runs sensors. The user sees results. Not the other way around.

---

## ◈ STATUS ANNOUNCEMENT (session start)

```
  HES {{version}} · {{project}}
  ─────────────────────────────
  feature   {{active_feature or none}}
  phase     {{phase}}
  language  {{lang}}    mode  {{mode}}
  cycles    {{N}}       lessons  {{N}}
```

---

## ◈ GATE BLOCK (before phase transition)

```
  gate check · {{PHASE}} → {{NEXT_PHASE}}
  ─────────────────────────────
  {{criterion 1}}   {{✓ or ✗}}
  {{criterion 2}}   {{✓ or ✗}}
  {{criterion 3}}   {{✓ or ✗}}
  ─────────────────────────────
  {{PASS → advancing / BLOCK → reason}}
```
