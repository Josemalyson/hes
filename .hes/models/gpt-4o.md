# HES — GPT-4o Adaptations
# Aplica quando: model = "gpt-4o*" em current.json

## Context Window
- gpt-4o: 128K tokens
- gpt-4o-mini: 128K tokens
- Compaction trigger: > 90K tokens usados

## Tool Use
- Suporta function_calling via tools[] array
- Shell via subprocess tool ou Code Interpreter
- File operations via custom tools

## AGENTS.md
- Equivalente ao CLAUDE.md para GPT
- Localização: AGENTS.md (raiz do projeto)

## Quirks
- Mais literal nas instruções — ser mais explícito nos prompts
- Menos capacidade de inferência implícita — documentar assumptions
- function_calling resposta em JSON estruturado
