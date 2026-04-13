# Contributing to HES

Thank you for your interest in contributing to the Harness Engineer Standard (HES)!

---

## ◈ How to Report a Bug

Found a bug? The best way to report it is via a GitHub Issue.

### Option 1: Use the HES Skill (Recommended)

If you're working in a project with HES installed, run:

```
/hes bug
```

This will automatically collect system diagnostics and create a properly formatted issue.

### Option 2: Manual Issue Creation

1. Go to [Issues](../../issues/new)
2. Use the "Bug Report" template
3. Fill in the steps to reproduce
4. Include your system information (run `uname -a`, `git describe --tags`, and paste `.hes/state/current.json`)

### What Makes a Good Bug Report?

- **Clear reproduction steps** — numbered, specific steps
- **Expected vs actual behavior** — what should happen vs what did happen
- **System information** — HES version, OS, IDE, git commit
- **State file** — paste the contents of `.hes/state/current.json` for debugging context

---

## ◈ How to Propose an Improvement

Have an idea for a new feature or enhancement?

### Option 1: Use the HES Skill

```
/hes improvement
```

### Option 2: Manual Issue Creation

1. Go to [Issues](../../issues/new)
2. Use the "Improvement" template
3. Describe the problem you're trying to solve

### What Makes a Good Improvement Proposal?

- **Clear motivation** — why does this matter?
- **Proposed solution** — how could it work? (optional but helpful)
- **Alternatives considered** — other approaches you've thought about

---

## ◈ Development Setup

See [SETUP.md](SETUP.md) for instructions on installing HES skill-files in your IDE or AI coding tool.

---

## ◈ Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat` — new feature or enhancement
- `fix` — bug fix
- `docs` — documentation changes
- `chore` — maintenance tasks (tooling, configs)
- `refactor` — code refactoring without behavior changes
- `test` — adding or modifying tests

Examples:
```
feat(harness): add session manager skill
fix(bootstrap): handle missing state file gracefully
docs: add contribution guide
chore: update agent registry
```

---

## ◈ Branch Strategy

- `main` — protected branch, only merged via PRs
- `feat/<name>` — feature branches
- `fix/<name>` — bug fix branches
- `docs/<name>` — documentation branches

---

## ◈ Pull Request Requirements

Every PR must include:
- [ ] Linked issue (bug or improvement)
- [ ] Description of changes
- [ ] Testing notes (what was tested, how)
- [ ] Updated documentation if behavior changed

Example PR description:

```markdown
## What
Add session manager skill with lifecycle management.

## Why
Needed for context preservation across sessions and phase-lock enforcement.

## Testing
- Manual: triggered via /hes status, verified state persistence
- Behavioral: followed skill protocol through full lifecycle
```

---

## ◈ HES Workflow (For Newcomers)

HES is a skill-based system for orchestrating AI coding agents. Here's how it works:

1. **SKILL.md** — The entry point. It reads the project state and routes to the right skill.
2. **skills/XX-name.md** — Individual skill files that guide the agent through each phase.
3. **.hes/state/** — Generated state files tracking feature progress.
4. **.hes/agents/** — Agent registry defining which agent handles which phase.

When you run `/hes`, the system reads the current state and dispatches to the appropriate agent for the current phase (DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE).

---

*Thank you for contributing!*
