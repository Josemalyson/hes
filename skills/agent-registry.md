# HES Skill — Agent Registry Reference

> Reference document for the agent registry schema and creating custom agents.
> NOT an executable skill — use as reference when registering or creating agents.
> HES v3.3+

---

## ◈ REGISTRY SCHEMA

File: `.hes/agents/registry.json`

### Root Structure

```json
{
  "version": "3.2.0",
  "agents": { ... },
  "sub_agents": { ... },
  "custom_agents": { ... }
}
```

### Agent Types

| Type | Description | Trigger |
|------|-------------|---------|
| `orchestrator` | Default agent — routes phases | `/hes`, `/hes start` |
| `phase` | Executes a specific HES phase | `feature state = PHASE` |
| `system` | System-level operations | Commands (`/hes report`, etc.) |
| `custom` | User-defined extensions | Custom triggers |

### Agent Entry Schema

```json
{
  "agent-name": {
    "description": "What this agent does",
    "type": "orchestrator|phase|system|custom",
    "phase": "DISCOVERY|SPEC|DESIGN|DATA|RED|GREEN|REVIEW",
    "triggers": ["command", "state condition"],
    "context_load": ["file1.md", "file2.json"],
    "sub_agents": ["sub-agent-1", "sub-agent-2"]
  }
}
```

**Fields:**
- `description` (required): Human-readable description
- `type` (required): One of orchestrator, phase, system, custom
- `phase` (optional): Required for type=phase — maps to HES state
- `triggers` (required): Commands or state conditions that activate this agent
- `context_load` (required): Files this agent loads (scoped context)
- `sub_agents` (optional): Sub-agents this agent can spawn

### Sub-Agent Entry Schema

```json
{
  "sub-agent-name": {
    "description": "What this sub-agent does",
    "parent": "parent-agent-name",
    "trigger": "when this sub-agent runs",
    "scope": ["file patterns", "rules"]
  }
}
```

### Custom Agent Entry Schema

```json
{
  "custom-agent-name": {
    "description": "What this custom agent does",
    "reference": "https://github.com/... (optional)",
    "type": "custom",
    "triggers": ["/hes run agent-name", "automatic event"],
    "context_load": ["skills/custom/agent-name.md"],
    "output": "where output is saved"
  }
}
```

---

## ◈ CREATING A CUSTOM AGENT

### Step 1: Define in Registry

Add entry to `.hes/agents/registry.json` under `custom_agents`:

```json
{
  "custom_agents": {
    "my-agent": {
      "description": "Description of what my agent does",
      "type": "custom",
      "triggers": ["/hes run my-agent"],
      "context_load": ["skills/custom/my-agent.md"],
      "output": ".hes/tasks/my-agent-output.md"
    }
  }
}
```

### Step 2: Create Skill File

Create `skills/custom/my-agent.md` with the agent's behavior:

```markdown
# HES Custom Skill — My Agent

> Trigger: /hes run my-agent
> Description: What this agent does.

## ◈ STEP 1 — ...

[Agent behavior definition]

▶ NEXT ACTION
...
```

### Step 3: Validate

```bash
# Validate registry JSON
python3 -c "import json; json.load(open('.hes/agents/registry.json')); print('OK')"

# Verify skill file exists
test -f skills/custom/my-agent.md && echo "Skill file OK" || echo "MISSING"
```

### Step 4: Use

```
/hes run my-agent
```

---

## ◈ BUILT-IN AGENTS

### Phase Agents

| Agent | Phase | Skill-file | Responsibility |
|-------|-------|-----------|----------------|
| discovery-agent | DISCOVERY | skills/01-discovery.md | Capture RN, use cases, domain |
| spec-agent | SPEC | skills/02-spec.md | BDD scenarios, API contracts |
| design-agent | DESIGN | skills/03-design.md | Components, ADRs, architecture |
| data-agent | DATA | skills/04-data.md | Schema, migrations, data modeling |
| test-agent | RED | skills/05-tests.md | Write failing tests |
| impl-agent | GREEN | skills/06-implementation.md | Write production code |
| review-agent | REVIEW | skills/07-review.md | 5 dimensions, DONE gate |

### System Agents

| Agent | Trigger | Skill-file | Responsibility |
|-------|---------|-----------|----------------|
| session-manager | /hes status, /clear, /new | skills/session-manager.md | Session lifecycle |
| error-recovery-agent | /hes error, error detected | skills/error-recovery.md | Error diagnosis |
| refactor-agent | /hes refactor | skills/refactor.md | Safe refactoring |
| report-agent | /hes report | skills/report.md | Batch learning |
| harness-health-agent | /hes harness | skills/harness-health.md | Harness coverage check |

### Sub-Agents (scoped to impl-agent)

| Agent | Trigger | Scope |
|-------|---------|-------|
| test-runner | After code change | tests/, build output |
| linter | Before commit | Source code files |
| arch-check | Before commit | Architecture rules |

---

## ◈ REGISTRY MAINTENANCE

### Adding a New Phase Agent

1. Add entry in `agents` section of registry
2. Create corresponding skill-file in `skills/`
3. Update SKILL.md routing table if new phase
4. Commit both files together

### Removing an Agent

1. Remove entry from registry
2. Optionally delete skill-file
3. Update SKILL.md routing table if removed phase
4. Commit

### Upgrading Registry Version

When HES version changes:
1. Update `version` field in registry
2. Check if new agent types are needed
3. Run validation: `python3 -c "import json; r=json.load(open('.hes/agents/registry.json')); assert r['version'] == '3.3.0'"`
