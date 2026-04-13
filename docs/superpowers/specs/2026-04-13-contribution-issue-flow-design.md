# Design Spec: Contribution + Issue Flow (Phase 1)

**Date:** 2026-04-13
**Author:** HES Brainstorming Session
**Status:** Draft — Pending User Review

---

## Overview

This spec defines two interconnected artifacts that standardize how contributors interact with the HES project:

1. **`CONTRIBUTING.md`** — A contribution guide documenting how to report bugs, propose improvements, and follow project conventions.
2. **`skills/09-issue-create.md`** — A HES skill that guides users through creating well-structured GitHub Issues with automatic diagnostic collection.

The goal is to replace the `melhorias/todo.md` ad-hoc tracking with a formal GitHub Issues workflow, making the project more accessible and maintainable.

---

## Architecture

### Flow

```
User invokes issue creation
    │
    ▼
skills/09-issue-create.md
    │
    ├─── Ask: bug or improvement?
    │
    ├─── Collect diagnostics (automatic):
    │     • HES version (from SKILL.md YAML header)
    │     • IDE/CLI (from .hes/state/current.json)
    │     • OS info (uname -a or equivalent)
    │     • Git state (git describe --tags)
    │     • HES state snapshot (current.json)
    │     • Relevant CLI versions (gh --version, git --version)
    │
    ├─── Load issue template (.hes/templates/)
    │
    ├─── Fill template with collected data + user description
    │
    └─── Create issue:
          ├── If `gh` CLI available → `gh issue create` directly
          └── Else → output formatted markdown for manual paste
```

### Components

#### 1. CONTRIBUTING.md

Location: `CONTRIBUTING.md` (project root)

Contents:
- **How to report a bug** — links to issue template or invokes `/hes issue`
- **How to propose an improvement** — same flow, different label
- **Development setup** — links to `SETUP.md`
- **Commit conventions** — Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)
- **Branch strategy** — `main` protected, feature branches `feat/<name>`, fix branches `fix/<name>`
- **Pull Request requirements** — linked issue, description, testing notes
- **HES workflow summary** — brief explanation of the skill-based system for newcomers

#### 2. skills/09-issue-create.md

Location: `skills/09-issue-create.md`

Type: System skill (triggered by `/hes issue` or `/hes bug` or `/hes improvement`)

Responsibilities:
- Classify issue type (bug vs improvement)
- Collect system diagnostics automatically
- Fill the appropriate template
- Create or output the issue

Protocol:
1. **Detect type** — if user said "bug" → bug template; if "improvement" → improvement template; otherwise ask
2. **Gather context** — read SKILL.md version, current.json, run diagnostic commands
3. **Ask user** for: title, description, steps to reproduce (if bug), expected behavior
4. **Generate** — fill template with collected + provided data
5. **Create** — if `gh` CLI is available, create the issue directly; otherwise print the markdown for manual creation
6. **Log** — register event in events.log

#### 3. Issue Templates

Location: `.hes/templates/`

**Bug Template** (`issue-bug.md`):
```markdown
---
title: "[Bug] <short description>"
labels: bug
assignees: ""
---

## Bug Description
<what happened>

## Expected Behavior
<what should have happened>

## Steps to Reproduce
1. 
2. 
3. 

## System Information
- **HES Version:** <auto-filled>
- **OS:** <auto-filled>
- **IDE/CLI:** <auto-filled>
- **Git Commit:** <auto-filled>
- **HES State:** <auto-filled snapshot>
- **gh CLI:** <auto-filled or "not installed">
- **Node/Java/Python (relevant runtime):** <auto-filled>

## State File
<attach or paste .hes/state/current.json content for debugging>

## Additional Context
<screenshots, logs, related issues>
```

**Improvement Template** (`issue-improvement.md`):
```markdown
---
title: "[Improvement] <short description>"
labels: enhancement
assignees: ""
---

## Description
<what you want to improve>

## Motivation
<why this matters>

## Proposed Solution
<how it could work — optional>

## Alternatives Considered
<other approaches — optional>

## System Information
- **HES Version:** <auto-filled>
- **OS:** <auto-filled>
- **IDE/CLI:** <auto-filled>

## Additional Context
<references, links, related issues>
```

---

## Data Flow

```
┌──────────────┐     ┌───────────────────┐     ┌──────────────────┐
│   User Input  │────▶│  09-issue-create   │────▶│   Issue Template  │
│  (type + desc)│     │     (skill)        │     │  (.hes/templates) │
└──────────────┘     └─────────┬─────────┘     └────────┬─────────┘
                               │                         │
                    ┌──────────▼──────────┐              │
                    │  Diagnostic Collector │              │
                    │  • SKILL.md version    │              │
                    │  • current.json        │─────────────▶│
                    │  • uname / git / gh    │   Fill data │
                    └───────────────────────┘              │
                                                          │
                               ┌──────────────────────────┘
                               ▼
                    ┌──────────────────────┐
                    │  gh issue create      │
                    │  OR markdown output   │
                    └──────────────────────┘
```

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| `gh` CLI not installed | Fall back to printing the filled markdown for manual copy-paste |
| `.hes/state/current.json` missing | Use "unknown" for state-dependent fields, continue |
| SKILL.md not found or no version header | Use "unknown" for HES version |
| User provides no description | Prompt again — description is mandatory |
| GitHub API rate limit (via `gh`) | Display error message with filled markdown as fallback |

---

## Testing Strategy

Since this is a skill (inferential guide), testing is behavioral:

1. **Unit (behavioral)** — Verify the skill correctly classifies bug vs improvement
2. **Integration** — Run through full flow: invoke skill → provide inputs → verify generated markdown matches template structure
3. **Manual** — Test `gh issue create` flow on a test repository

---

## File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| `CONTRIBUTING.md` | Create | Project contribution guide |
| `skills/09-issue-create.md` | Create | Issue creation skill |
| `.hes/templates/issue-bug.md` | Create | Bug report template |
| `.hes/templates/issue-improvement.md` | Create | Improvement proposal template |
| `melhorias/todo.md` | Deprecate | Add deprecation notice, point to GitHub Issues |
| `.hes/templates/` | Create dir | Template directory |

---

## Out of Scope (Future Phases)

- **Phase 2:** PR analysis skill — automatic review of opened PRs, checking if changes make sense, commenting
- **Phase 3:** External link/article research skill — user provides URL, skill analyzes and opens issue
- **Phase 4:** AGENTS.md migration — making HES more generic for non-Qwen agents
- **Phase 5:** Auto-research pattern from projects like `karpathy/autoresearch`

---

## Success Criteria

- [ ] `CONTRIBUTING.md` exists and covers bug reporting + improvement proposals
- [ ] `skills/09-issue-create.md` works end-to-end (bug + improvement flows)
- [ ] Templates exist in `.hes/templates/` with auto-fill placeholders
- [ ] `melhorias/todo.md` has deprecation notice
- [ ] Skill integrates into HES registry as a system skill
- [ ] `gh` CLI flow works (creates issue with labels)
- [ ] Fallback works (prints markdown when `gh` unavailable)
