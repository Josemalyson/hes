# HES — Claude-specific Adaptations
# Aplica quando: model = "claude-*" em current.json

## Context Window
- claude-opus-4: 200K tokens
- claude-sonnet-4-6: 200K tokens
- claude-haiku-4-5: 200K tokens
- Compaction trigger: > 150K tokens usados

## Tool Use
- Suporta tool_use nativo
- Prefere chamadas shell via Bash tool
- Arquivos via Read/Write/Edit tools

## CLAUDE.md
- Lido automaticamente no início de cada sessão
- Localização: .claude/CLAUDE.md (raiz do projeto)

## Quirks
- Respostas mais longas em reasoning mode — usar max_tokens consciente
- Extended thinking: aumenta qualidade em fases de DESIGN e SPEC
- Não usar asteriscos para ênfase em prompts (pode ser interpretado como markdown)
