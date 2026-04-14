> **SCOPE BOUNDARY**: This skill-file defines how the LLM dispatches TOOLS
> (shell commands, linters, test runners) to sub-processes.
> It does NOT authorize delegation of skill-file execution to other LLM agents.
> See RULE-15 in SKILL.md for the authoritative boundary.

---

# HES Skill — Agent Delegation

> Skill invoked by the orchestrator (SKILL.md) when delegating to specialized agents.
> Objective: multi-agent delegation pattern, sub-agent spawning, dispatch protocol.
> Reference: HES v3.3 Agent Registry (.hes/agents/registry.json)

---

## ◈ DELEGATION MODEL

The orchestrator (harness-agent) NEVER implements — only dispatches, validates, and advances state.

```
ORCHESTRATOR (SKILL.md)
  → Reads current.json
  → Queries registry.json
  → Identifies agent for current phase
  → Loads required context
  → Delegates to agent's skill-file
  → Validates DONE criteria
  → Advances state + logs event
```

---

## ◈ DISPATCH PROTOCOL

```
STEP 1 — READ STATE
  → .hes/state/current.json
  → Identify: active_feature, features[feature], session.phase_lock

STEP 2 — QUERY REGISTRY
  → .hes/agents/registry.json
  → Find agent where: agents[X].phase == current_phase
     OR agents[X].type == "system" (for commands like /hes report)

STEP 3 — IDENTIFY AGENT
  → If feature = DISCOVERY → discovery-agent
  → If feature = SPEC     → spec-agent
  → If feature = DESIGN   → design-agent
  → If feature = DATA     → data-agent
  → If feature = RED      → test-agent
  → If feature = GREEN    → impl-agent
  → If feature = REVIEW   → review-agent
  → If system command   → session-manager | report-agent | etc.
  → If not found        → use harness-agent (fallback) + warning

STEP 4 — LOAD CONTEXT
  → Load ONLY the files in agents[X].context_load
  → Do NOT load skill-files from other phases

STEP 5 — DELEGATE
  → Load corresponding skill-file
  → Follow skill-file instructions
  → Do NOT take actions beyond what the skill-file specifies

STEP 6 — VALIDATE
  → Check phase DONE criteria
  → If NOT satisfied → remain in current phase

STEP 7 — ADVANCE
  → Update current.json: features[feature] = next_phase
  → Register event in events.log
  → Announce next phase + next agent
```

---

## ◈ SUB-AGENT SPAWNING

Sub-agents are child agents executed within the context of a parent agent.

### Sub-Agent Registry (in registry.json)

```json
{
  "sub_agents": {
    "test-runner": {
      "parent": "impl-agent",
      "trigger": "after code change",
      "scope": ["tests/", "build output"]
    },
    "linter": {
      "parent": "impl-agent",
      "trigger": "before commit",
      "scope": ["*.java", "*.ts", "*.py"]
    },
    "arch-check": {
      "parent": "impl-agent",
      "trigger": "before commit",
      "scope": ["architecture rules"]
    }
  }
}
```

### Sub-Agent Execution Protocol

```
When impl-agent generates code:

1. Spawn test-runner:
   → Run feature tests
   → If failure → correction loop (max 3 iterations)
   → If passes → proceed

2. Spawn linter:
   → Run linter on generated code
   → If violation → fix automatically
   → If clean → proceed

3. Spawn arch-check:
   → Validate architectural boundaries
   → If violation → BLOCKED + explain violation
   → If ok → proceed to commit

RULES:
- Sub-agents run SEQUENTIALLY (not concurrently)
- Maximum 3 self-refinement iterations per sub-agent
- If fails after 3 attempts → escalate to user
```

### Sub-Agent Failure Escalation

```
⚠ SUB-AGENT FAILURE — {{SUB_AGENT_NAME}}

{{sub_agent}} failed after 3 self-refinement iterations.
Last error: {{ERROR_MESSAGE}}

Options:
  [A] Show me the error — I'll fix manually
  [B] Skip this check (NOT recommended)
  [C] Retry with different approach
```

---

## ◈ MULTI-FEATURE PARALLEL SUPPORT

Different features can have different agents active simultaneously via `/hes switch`:

```json
{
  "active_feature": "payment",
  "features": {
    "payment": "GREEN",    ← impl-agent active
    "auth": "DONE",
    "billing": "SPEC"      ← spec-agent active (when switched)
  }
}
```

### `/hes switch <feature>` Protocol

```
1. Save checkpoint of current feature (optional but recommended)
2. Update current.json: active_feature = <feature>
3. Check dependencies in dependency_graph
   → If dependency not DONE → warning + suggest switching to dependency
4. Load agent for new phase
5. Announce: "Switched to {{feature}}. Phase: {{phase}}. Agent: {{agent}}"
```

---

## ◈ CUSTOM AGENTS

Users can extend the system with custom agents.

### Registry Entry

Add to `.hes/agents/registry.json`:

```json
{
  "custom_agents": {
    "my-agent": {
      "description": "Description of what the agent does",
      "type": "custom",
      "triggers": ["/hes run my-agent", "automatic event"],
      "context_load": ["skills/custom/my-agent.md"],
      "output": ".hes/tasks/my-agent-output.md"
    }
  }
}
```

### Creating a Custom Agent

1. Add entry in `custom_agents` in the registry
2. Create `skills/custom/<agent-name>.md` with behavior definition
3. Trigger via `/hes run <agent-name>` or automatic dispatch from parent agent

### Example: Graphify Agent

```json
{
  "custom_agents": {
    "graphify-agent": {
      "description": "Analyzes dependency graphs, suggests module boundaries",
      "reference": "https://github.com/safishamsi/graphify",
      "type": "custom",
      "triggers": ["/hes analyze", "design-agent requests analysis"],
      "context_load": ["skills/custom/graphify-agent.md"],
      "output": ".hes/domains/{{domain}}/analysis.md"
    }
  }
}
```

---

## ◈ ERROR HANDLING

### Agent Not Found

```
⚠ AGENT NOT FOUND

Phase: {{PHASE}}
Expected agent: {{AGENT_NAME}}
Status: Not found in registry

Fallback: Using harness-agent (default orchestrator)

  [A] Proceed with harness-agent
  [B] Register agent in .hes/agents/registry.json
```

### Context Load Failure

```
⚠ CONTEXT LOAD ERROR

Agent "{{agent_name}}" requires: {{missing_file}}
Status: File not found

  [A] Skip missing file — load what's available
  [B] Create missing file now
  [C] Abort and fix registry
```

---

▶ NEXT ACTION — DELEGATION COMPLETED

```
Agent delegation handled.

  [A] "delegate to next agent"
      → Execute DISPATCH PROTOCOL → advance to next phase

  [B] "spawn sub-agent {{name}}"
      → Execute Sub-Agent Execution Protocol

  [C] "switch to feature {{name}}"
      → Execute /hes switch protocol

  [D] "add custom agent"
      → Follow Custom Agents creation flow

📄 Skill-file: skills/tool-dispatch.md (you are here)
💡 Tip: each agent loads ONLY its required context.
   This keeps the session clean and focused on the current task.
```
