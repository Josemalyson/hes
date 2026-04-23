# Contributing to HES

Thank you for your interest in contributing to the Harness Engineer Standard (HES)!

> **v4.0 Roadmap em andamento** — Se quiser contribuir with os new agents (planner, orchestrator, harness-evolver, optimizer, reviewer), veja a seção [Contribuindo with agents v4.0](#-contribuindo-with-agents-v40) abaixo.

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

See [INSTALL.md](INSTALL.md) for instructions on installing HES skill-files in your IDE or AI coding tool.

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
- `plan` — plano arquitetural, roadmap, stubs de agents
- `stub` — implementation parcial (protocolo complete, execution pendente)

Examples:
```
feat(harness): add session manager skill
fix(bootstrap): handle missing state file gracefully
docs: add contribution guide
chore: update agent registry
plan(v4.0): add multi-agent orchestration roadmap
stub(planner): add task decomposition protocol
```

---

## ◈ Branch Strategy

- `main` — protected branch, only merged via PRs
- `feat/<n>` — feature branches (implementações completes)
- `fix/<n>` — bug fix branches
- `docs/<n>` — documentation branches
- `plan/<n>` — roadmap e planos arquiteturais (stubs incluídos)
- `stub/<n>` — implementation parcial de new agents

---

## ◈ Pull Request Requirements

Every PR must include:
- [ ] Linked issue (bug or improvement)
- [ ] Description of changes
- [ ] Testing notes (what was tested, how)
- [ ] Updated documentation if behavior changed
- [ ] for stubs v4.0: `status: stub` e `target_version` no cabeçalho do skill-file

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

HES is um sistema based em skill-files for orquestrar agents de IA em um flow de desenvolvimento estruturado.

1. **SKILL.md** — Entry point. Lê o state of the project e roteia for o skill correto.
2. **skills/XX-name.md** — Skill-files individuais que guiam o Agent em each phase.
3. **.hes/state/** — Files de state generateds by the bootstrap.
4. **.hes/agents/registry.json** — Registry de agents: qual Agent lida with qual phase/comando.

flow de phase sequencial (padrão):
```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE
```

flow multi-Agent (v4.0 roadmap):
```
/hes start --parallel → planner.md → orchestrator.md → [Agent Fleet] → integração → fluxo sequencial
```

---

## ◈ Contribuindo with agents v4.0

O HES v4.0 is implementando 5 new agents. each um tem um stub available em `skills/` with o protocolo complete especificado. Contribuições are well-vindas for implementar any um deles.

### agents available for implementation

| Agent | Stub | Target | O que do |
|---|---|---|---|
| `planner.md` | ✅ `skills/planner.md` | v3.6 | Implementar generation de `execution-plan.json` + lógica de decomposição |
| `orchestrator.md` | ✅ `skills/orchestrator.md` | v3.7 | Implementar dispatch de agents + gerenciamento de Git worktrees |
| `harness-evolver.md` | ✅ `skills/harness-evolver.md` | v3.8 | Implementar analysis de `events.log` + aplicação de trust-policy |
| `optimizer.md` | ✅ `skills/optimizer.md` | v3.9 | Implementar as 5 transformações + gate de validation pós-otimização |
| `reviewer.md` | ✅ `skills/reviewer.md` | v4.0 | Implementar as 5 dimensões de revisão + integração GitHub/GitLab |

### Conventions for Skill-Files de Agent

Todo skill-file de Agent must have o cabeçalho:

```markdown
# nome-agente.md — Descrição do Agente
# version: X.Y.Z
# status: stable | stub
# target_version: X.Y.Z (se stub)
# HES Phase: NOME_DA_FASE | SYSTEM
```

### Conventions for Stubs

Stubs are well-vindos when:
- O protocolo complete is especificado (STEPS, gates, outputs)
- O cabeçalho inclui `status: stub` e `target_version`
- O rodapé inclui `<!-- HES vX.Y STUB — implementation complete em vX.Y -->`

### Adicionando um Agent ao Registry

Ao implementar um Agent stub, atualize `.hes/agents/registry.json`:

```json
{
  "agent": "nome-agent",
  "type": "system",
  "skill_file": "skills/nome.md",
  "trigger": "/hes comando",
  "status": "stable"  // remover "stub" e "target_version" ao completer
}
```

### new RULES for agents v4.0

Ao implementar um new Agent, adicione o RULE correspondente ao `SKILL.md` (RULE-29 a RULE-33 já reservadas for os 5 agents do roadmap v4.0). see [PLAN-v4.0.md](PLAN-v4.0.md) for detalhes.

---

## ◈ Roadmap de Contribuição Sugerido

```
Q2 2026 — v3.6 (aberto para contribuição)
  → Implementar skills/planner.md complete
  → Integrar security-policy.yml na fase SECURITY (skills/10-security.md)
  → Adicionar suporte a Git worktrees no SKILL.md (RULE-29)

Q3 2026 — v3.7
  → Implementar skills/orchestrator.md complete
  → Create scripts/hooks/worktree-manager.sh
  → Testar com /hes start --parallel em projetos reais

Q4 2026 — v3.8
  → Implementar skills/harness-evolver.md complete
  → Integrar trust-policy.yml com auto-modificação controlada
  → Adicionar /hes insights ao session-manager
```

see [PLAN-v4.0.md](PLAN-v4.0.md) for roadmap complete.

---

*Thank you for contributing!*
