# HES — Claude-specific Adaptations
# Applies when: model = "claude-*" in current.json

## Context Window
- claude-opus-4: 200K tokens
- claude-sonnet-4-6: 200K tokens
- claude-haiku-4-5: 200K tokens
- Compaction trigger: > 150K tokens usados

## Tool Use
- Supports native tool_use
- Prefers shell calls via Bash tool
- Files via Read/Write/Edit tools

## CLAUDE.md
- Auto-loaded at the start of each session
- Location: .claude/CLAUDE.md (project root)

## Quirks
- Longer responses in reasoning mode — be conscious of max_tokens
- Extended thinking: improves quality in DESIGN and SPEC phases
- Avoid asterisks for emphasis in prompts (may be interpreted as markdown)
