# HES Skill — 00: Bootstrap

> Skill carregada quando: estado global = ZERO (novo projeto) ou HARNESS_INSTALADO (sem feature ativa).
> Execute este arquivo integralmente antes de qualquer ação.

---

## ◈ CONTEXTO ESPERADO

Este skill é invocado quando:
- `.hes/state/current.json` não existe (projeto novo)
- Projeto existe mas sem estrutura HES
- Harness instalado mas sem feature ativa definida

---

## ◈ PASSO 1 — COLETAR INFORMAÇÕES (máximo 4 perguntas)

```
🚀 HES Bootstrap v3.2 — vou configurar o harness do projeto.

Preciso de 4 informações:

1. Nome do projeto (ex: livehome, payment-service): [GERAR AUTOMATICAMENTE]
2. Stack principal (ex: Java 17 + Spring Boot / Node + NestJS / Python + FastAPI): [GERAR AUTOMATICAMENTE]
3. Este é um projeto novo ou você quer integrar código existente? [GERAR AUTOMATICAMENTE]
4. O sistema possui domínios DDD definidos? Se sim, liste-os (ex: billing, auth, catalog — ou "não" se for monolito simples): [GERAR AUTOMATICAMENTE]
```

Tentar gerar as respostas automaticamente, se não conseguir aguardar resposta.
Com as respostas, executar os passos abaixo.

---

## ◈ PASSO 1.5 — VALIDAR ESTRUTURA DE SETUP

> Antes de gerar qualquer diretório, verifique se os arquivos HES foram copiados corretamente.
> Este passo é executado APÓS o usuário copiar os arquivos e ANTES de gerar a estrutura.

### 0. Verificação Prévia — Diretório Oculto

**Antes do checklist principal, verifique se não há um diretório oculto `.skills/`:**

```bash
# Se .skills/ existe mas skills/ não existe:
if [ -d ".skills" ] && [ ! -d "skills" ]; then
  echo "⚠ Atenção: pasta '.skills/' (oculta) detectada."
  echo "   A pasta correta é 'skills/' (sem o ponto)."
  echo "   Renomeie: mv .skills skills"
fi
```

### 1. Checklist de Validação

Execute as verificações abaixo (use `ls`, `test -f`, `test -d` ou equivalente):

```
📋 Validando estrutura de arquivos HES v3.2...

  [ ] SKILL.md existe na raiz do projeto
  [ ] Diretório skills/ existe (VISÍVEL, não .skills/)
  [ ] skills/00-bootstrap.md
  [ ] skills/01-discovery.md
  [ ] skills/02-spec.md
  [ ] skills/03-design.md
  [ ] skills/04-data.md
  [ ] skills/05-tests.md
  [ ] skills/06-implementation.md
  [ ] skills/07-review.md
  [ ] skills/legacy.md
  [ ] skills/error-recovery.md
  [ ] skills/refactor.md
  [ ] skills/report.md
  [ ] skills/harness-health.md
```

**Se algum arquivo estiver faltando**, exiba erro claro:

```
🚨 Estrutura HES INCOMPLETA — os seguintes arquivos não foram encontrados:

  ❌ skills/02-spec.md
  ❌ skills/05-tests.md

Ações possíveis:
  1. Recopie a pasta skills/ do repositório HES original
  2. Verifique se o caminho de destino está correto (deve ser skills/, não .skills/)
  3. Execute este bootstrap novamente após corrigir
```

### 2. Tipo de Instalação

Se a estrutura estiver válida, pergunte ao usuário:

```
📦 Tipo de Instalação — como o HES será usado?

  [A] Local (este projeto apenas)
      → Arquivos ficam no projeto, versionados com git
      → Ideal: projeto isolado, cada projeto tem sua versão

  [B] Global (compartilhado entre projetos)
      → Arquivos em ~/.hes/skills/ com symlinks nos projetos
      → Ideal: múltiplos projetos, atualização centralizada
      → Comando:
        # Copiar para localização global
        cp -r skills/ ~/.hes/skills/

        # Remover cópia local e criar symlink
        rm -rf skills/
        ln -s ~/.hes/skills/ ./skills
```

- Se **[A] Local**: registre `"installation_type": "local"` e siga para Passo 2.
- Se **[B] Global**: execute a cópia e criação do symlink, registre `"installation_type": "global"`, e siga para Passo 2.

### 3. Gerar Relatório de Validação

Salve o resultado em `.hes/state/setup-validation.json`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "installation_type": "local|global",
  "structure_valid": true|false,
  "files_expected": ["SKILL.md", "skills/00-bootstrap.md", "skills/01-discovery.md", "skills/02-spec.md", "skills/03-design.md", "skills/04-data.md", "skills/05-tests.md", "skills/06-implementation.md", "skills/07-review.md", "skills/legacy.md", "skills/error-recovery.md", "skills/refactor.md", "skills/report.md", "skills/harness-health.md"],
  "files_missing": [],
  "issues": []
}
```

- `files_expected`: lista completa de arquivos que deveriam existir
- `files_missing`: lista de arquivos não encontrados (vazia se todos presentes)
- `issues`: lista de problemas adicionais (ex: `"skills/ é diretório oculto (.skills/), deveria ser visível"`)
- `structure_valid`: `true` apenas se `files_missing` estiver vazio

---

## ◈ PASSO 1.5.1 — IDE AUTO-DETECTION (NOVO em v3.2)

> Detectar o ambiente de IDE e gerar configuração específica automaticamente.

### Detection Order

```
1. Check for marker files/dirs:
   - .vscode/ → VS Code
   - .cursor/ or .cursorrules → Cursor
   - .claude/ or CLAUDE.md → Claude Code
   - .gemini/ → Gemini CLI
   - .openhands/ → OpenHands
   - .windsurf/ → Windsurf

2. If multiple detected → ask user:
   "Detected: {{lista_de_IDEs}}. Which is your primary IDE?"

3. If none detected → ask user:
   "What IDE/editor are you using?"
   [A] Claude Code  [B] Cursor  [C] VS Code  [D] Windsurf  [E] Copilot  [F] OpenHands  [G] Other
```

### IDE-Specific Config Generation

**Claude Code detected (or selected):**
```bash
mkdir -p .claude
```

Generate `.claude/CLAUDE.md` with updated HES v3.2 content (update version references in the existing PASSO 5 content to v3.2).

**Cursor detected (or selected):**
Generate `.cursorrules`:
```
# HES — Harness Engineer Standard v3.2

Ao receber /hes ou qualquer comando de engenharia:
1. Ler SKILL.md na raiz do projeto
2. Ler .hes/state/current.json e .hes/agents/registry.json
3. Identificar agente correto via registry para a fase atual
4. Carregar APENAS o contexto definido no registry
5. Seguir o skill-file do agente sem desvios
6. NUNCA pular etapas — phase lock é obrigatório
7. Orquestrador NUNCA implementa — apenas roteia
8. Sempre terminar com o bloco PRÓXIMA AÇÃO
```

**VS Code detected (or selected):**
```bash
mkdir -p .vscode
```

Generate `.vscode/hes-agent.md`:
```markdown
# HES Agent for VS Code — v3.2

When working on this project:
1. Read SKILL.md first
2. Read .hes/state/current.json to identify phase
3. Read .hes/agents/registry.json to identify agent
4. Load only the context specified in registry
5. Follow the agent's skill-file
6. Never skip stages — phase lock enforced
```

**Windsurf detected (or selected):**
Generate `.windsurfrules` (same content as `.cursorrules`)

**Generic (none detected or "Other"):**
Generate `AGENTS.md`:
```markdown
# HES — Harness Engineer Standard v3.2

Ao iniciar qualquer sessão:
1. Ler SKILL.md na raiz do projeto
2. Ler .hes/state/current.json para identificar estado
3. Ler .hes/agents/registry.json para identificar agente
4. Carregar skill-file do agente correspondente
5. Seguir instruções do skill-file sem desvios
6. NUNCA pular etapas
7. Orquestrador NUNCA implementa — apenas roteia
8. Sempre terminar com o bloco PRÓXIMA AÇÃO
```

### Register IDE in current.json

Add `"ide": "{{detected_ide}}"` to the current.json schema in PASSO 3.

---

## ◈ PASSO 1.6 — AGENT REGISTRY INIT (NOVO em v3.2)

> Gerar o arquivo de registro de agentes.

```bash
mkdir -p .hes/agents
```

Verify `.hes/agents/registry.json` exists (should already exist from Task 1). If not found, display warning:
```
🚨 Agent registry not found: .hes/agents/registry.json

Please ensure HES v3.2 agent registry is installed.
```

If registry exists, validate:
```bash
python3 -c "import json; r=json.load(open('.hes/agents/registry.json')); assert r['version'] == '3.2.0'; print('Registry OK')"
```

If version < 3.2.0, prompt for upgrade.

---

## ◈ PASSO 1.7 — SESSION MANAGER INIT (NOVO em v3.2)

> Inicializar o session manager e arquivo de checkpoint.

1. Verify `skills/session-manager.md` exists. If not:
```
🚨 Session manager skill not found: skills/session-manager.md

Please ensure HES v3.2 skill-files are installed.
```

2. Generate empty checkpoint:

```json
{
  "timestamp": null,
  "feature": null,
  "phase": null,
  "agent": null,
  "last_action": null,
  "completed_steps": [],
  "pending_steps": [],
  "context_summary": "",
  "artifacts_created": [],
  "context_tokens_remaining": null
}
```

Save to `.hes/state/session-checkpoint.json`.

3. Verify session-manager entry exists in registry.json.

---

## ◈ PASSO 2 — GERAR ESTRUTURA DE DIRETÓRIOS

```bash
# Estrutura base HES
mkdir -p .claude/commands
mkdir -p .hes/state
mkdir -p .hes/specs
mkdir -p .hes/decisions
mkdir -p .hes/tasks
mkdir -p .hes/inventory
mkdir -p scripts/hooks

# Se houver domínios DDD
for domain in {{DOMINIOS_INFORMADOS}}; do
  mkdir -p .hes/domains/$domain/decisions
  mkdir -p .hes/domains/$domain/fitness   # ← NOVO v3.2: sensors computacionais por domínio
done
```

A pasta `fitness/` é onde ficam os sensors computacionais de architecture fitness
(ArchUnit rules, dep-cruiser config, import-linter rules) — gerados em Passo 9.

---

## ◈ PASSO 3 — GERAR `.hes/state/current.json`

```json
{
  "project": "{{NOME_PROJETO}}",
  "stack": "{{STACK}}",
  "active_feature": null,
  "features": {},
  "domains": [{{DOMINIOS_OU_ARRAY_VAZIO}}],
  "dependency_graph": {},
  "harness_version": "3.2.0",
  "completed_cycles": 0,
  "last_updated": "{{DATA_ATUAL_ISO}}"
}
```

---

## ◈ PASSO 4 — GERAR `.hes/state/events.log`

```json
[
  {
    "timestamp": "{{DATA_ATUAL_ISO}}",
    "feature": "global",
    "from": "NONE",
    "to": "HARNESS_INSTALADO",
    "agent": "hes-v3.2",
    "metadata": {
      "project": "{{NOME_PROJETO}}",
      "stack": "{{STACK}}",
      "harness_version": "3.2.0"
    }
  }
]
```

---

## ◈ PASSO 5 — GERAR `.claude/CLAUDE.md`

```markdown
# Identidade do Agente — {{NOME_PROJETO}}

## Missão
Você é um Harness Engineer (HES v3.2) para o projeto {{NOME_PROJETO}}.
Sua função é conduzir o pipeline SDD+TDD de 7 etapas de forma determinística.

NUNCA escreva código antes de completar as Etapas 1–4 aprovadas.
SEMPRE leia SKILL.md no início de cada sessão.
SEMPRE leia .hes/state/current.json para identificar o estado atual.
SEMPRE termine qualquer ação com o bloco PRÓXIMA AÇÃO.

## Stack
{{STACK}}

## Regras Invioláveis
1. Ler SKILL.md antes de qualquer ação
2. Seguir as 7 etapas em ordem — sem pular
3. Consultar specs/ antes de implementar qualquer coisa
4. Registrar decisões em .hes/decisions/ como ADRs
5. Atualizar lessons.md após qualquer erro ou aprendizado
6. Nunca assumir regras de negócio — sempre perguntar
7. Issue recorrente (N ≥ 2) → melhorar o harness, não só corrigir a instância

## Taxonomia do Harness (Fowler, 2026)
Guides (feedforward): SKILL.md, skill-files, specs, CLAUDE.md, domain context
Sensors (feedback):   git hooks, build, coverage, linters, ArchUnit/dep-cruiser
Dimensões: Maintainability | Architecture Fitness | Behaviour

## Skill-files disponíveis
- SKILL.md                    → orquestrador (ler sempre primeiro)
- skills/00-bootstrap.md      → configuração inicial
- skills/01-discovery.md      → entendimento do problema
- skills/02-spec.md           → cenários BDD + contratos de API
- skills/03-design.md         → arquitetura + ADR + fitness functions
- skills/04-data.md           → schema + migrations
- skills/05-tests.md          → testes antes do código (RED) + ArchUnit
- skills/06-implementation.md → implementação mínima (GREEN)
- skills/07-review.md         → 5 dimensões de revisão + DONE
- skills/legacy.md            → inventário + harnessability assessment
- skills/error-recovery.md    → diagnóstico e resolução de erros
- skills/refactor.md          → refactoring seguro por tipo
- skills/report.md            → batch learning sobre events.log
- skills/harness-health.md    → diagnóstico das 3 dimensões de regulação

## Estado Atual
Ver: .hes/state/current.json
```

---

## ◈ PASSO 6 — GERAR `.hes/tasks/lessons.md`

```markdown
# Lessons Learned — {{NOME_PROJETO}}

> Atualizado após cada sessão (hot path) e consolidado via /hes report (offline).
> Lições que aparecem 2× são promovidas ao skill-file correspondente.
> Issue recorrente → melhorar o harness, não só a instância (Fowler, 2026).

## Categorias
A — Violação de regra HES
B — Erro técnico recorrente
C — Gap de guide (feedforward insuficiente)
D — Gap de sensor (feedback não detectou)
E — Processo (fluxo de aprovação, comunicação)

## Lições Consolidadas (promovidas ao SKILL.md ou skill-file)
_nenhuma ainda_

---
```

---

## ◈ PASSO 7 — GERAR `.hes/tasks/backlog.md`

```markdown
# Backlog — {{NOME_PROJETO}}

## 🔴 Alta Prioridade
_adicionar via /hes start [nome-da-feature]_

## 🟡 Média Prioridade

## 🟢 Baixa Prioridade

## ✅ Concluídas
```

---

## ◈ PASSO 8 — GERAR DOMÍNIOS (se informados)

Para cada domínio em `{{DOMINIOS_INFORMADOS}}`:

### `.hes/domains/{{domain}}/context.md`

```markdown
# Bounded Context — {{DOMAIN}}

Domínio: {{DOMAIN}} | Projeto: {{NOME_PROJETO}}

## Linguagem Ubíqua
| Termo | Definição no domínio | Diferença de outros domínios |
|-------|---------------------|------------------------------|
| _a preencher_ | | |

## Responsabilidades do Domínio
_o que pertence a este contexto_

## Limites Explícitos
_o que NÃO pertence a este contexto_

## Integrações com Outros Domínios
| Domínio | Tipo de Integração | Protocolo |
|---------|-------------------|-----------|
| | | |
```

### `.hes/domains/{{domain}}/fitness/README.md`

```markdown
# Fitness Functions — {{DOMAIN}}

Sensors computacionais de architecture fitness para o domínio {{DOMAIN}}.
Referência: Fowler (2026) — Architecture Fitness Harness.

## Sensors instalados
_a preencher após configuração em Passo 9_

## Regras de boundary definidas
_a preencher após configuração_

## Como executar
_a preencher após configuração_
```

---

## ◈ PASSO 9 — CONFIGURAR ARCHITECTURE FITNESS SENSORS (NOVO em v3.2)

> "Feedforward and feedback controls are currently scattered across delivery steps.
>  Building the outer harness is an ongoing engineering practice." — Fowler, 2026

Perguntar ao usuário:

```
🏗 Configurar sensors de Architecture Fitness?
   (detecta automaticamente violações de module boundaries)

  [A] "sim, configurar agora" → executo setup para {{STACK}}
  [B] "depois" → registro em harness backlog e sigo
```

**Se Stack = Java / Spring Boot:**

Gerar `src/test/java/{{BASE_PACKAGE}}/architecture/ArchitectureTest.java`:

```java
package {{BASE_PACKAGE}}.architecture;

import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;

@AnalyzeClasses(packages = "{{BASE_PACKAGE}}")
class ArchitectureTest {

    // ─── Regras de Layered Architecture ──────────────────────────

    @ArchTest
    static final ArchRule controllers_nao_dependem_de_repositories =
        noClasses()
            .that().resideInAPackage("..controller..")
            .should().dependOnClassesThat()
            .resideInAPackage("..repository..")
            .because("Controller não deve acessar dados — viola SRP e HES REGRA-01");

    @ArchTest
    static final ArchRule services_nao_dependem_de_controllers =
        noClasses()
            .that().resideInAPackage("..service..")
            .should().dependOnClassesThat()
            .resideInAPackage("..controller..")
            .because("Service não deve conhecer a camada HTTP");

    @ArchTest
    static final ArchRule repositories_nao_dependem_de_services =
        noClasses()
            .that().resideInAPackage("..repository..")
            .should().dependOnClassesThat()
            .resideInAPackage("..service..")
            .because("Repository não deve ter lógica de negócio");

    // ─── Regras de Nomenclatura ───────────────────────────────────

    @ArchTest
    static final ArchRule controllers_devem_ter_sufixo =
        classes()
            .that().resideInAPackage("..controller..")
            .should().haveSimpleNameEndingWith("Controller");

    @ArchTest
    static final ArchRule services_devem_ter_sufixo =
        classes()
            .that().resideInAPackage("..service..")
            .and().areNotInterfaces()
            .should().haveSimpleNameEndingWith("Service")
            .orShould().haveSimpleNameEndingWith("UseCase");
}
```

Adicionar dependência no `pom.xml`:

```xml
<!-- Architecture Fitness Sensor — HES v3.2 -->
<dependency>
    <groupId>com.tngtech.archunit</groupId>
    <artifactId>archunit-junit5</artifactId>
    <version>1.3.0</version>
    <scope>test</scope>
</dependency>
```

Registrar em `.hes/domains/{{domain}}/fitness/README.md`:

```markdown
## Sensors instalados
- ArchUnit 1.3.0 (sensor computacional)

## Regras de boundary
- Controller → Service → Repository (unidirecional)
- Nomenclatura de sufixos obrigatória

## Como executar
mvn test -Dtest=ArchitectureTest
```

**Se Stack = Node.js / NestJS / TypeScript:**

```bash
npm install --save-dev dependency-cruiser
npx depcruise --init

# Adicionar em package.json:
# "check:arch": "depcruise --validate src"
# "check:arch:ci": "depcruise --validate --output-type err-long src"
```

Configurar `.dependency-cruiser.js` com regras de boundary entre módulos.

**Se Stack = Python / FastAPI:**

```bash
pip install import-linter --break-system-packages

# Criar .importlinter com contratos de boundary:
# [contract: layers]
# type = layers
# layers =
#   api_layer
#   service_layer
#   repository_layer
```

---

## ◈ PASSO 10 — GERAR GIT HOOKS

### `scripts/hooks/safety_validator.py` (pre-commit — sensor computacional)

```python
#!/usr/bin/env python3
"""HES Safety Validator v3.2 — pre-commit hook
Sensor computacional: bloqueia secrets, SQL destrutivo e pendências."""
import subprocess, sys, re

BLOCKED_PATTERNS = [
    (r'(?i)(password|secret|api_key|token)\s*=\s*["\'][^"\']{4,}', 'Secret hardcoded detectado'),
    (r'(?i)DROP\s+TABLE', 'DROP TABLE sem aprovação explícita (HES REGRA-04)'),
    (r'(?i)DELETE\s+FROM\s+\w+\s*;', 'DELETE sem cláusula WHERE'),
    (r'(?i)TRUNCATE\s+TABLE', 'TRUNCATE sem aprovação explícita (HES REGRA-04)'),
    (r'\bTODO\b|\bFIXME\b|\bHACK\b', 'Pendência não resolvida no código'),
]
SKIP_EXTENSIONS = {'.lock', '.sum', '.mod', '.png', '.jpg', '.svg', '.ico'}

def get_staged_files():
    result = subprocess.run(['git', 'diff', '--cached', '--name-only'],
                            capture_output=True, text=True)
    return [f for f in result.stdout.strip().split('\n') if f]

def check_file(filepath):
    import os
    ext = os.path.splitext(filepath)[1]
    if ext in SKIP_EXTENSIONS:
        return []
    violations = []
    try:
        with open(filepath, 'r', errors='ignore') as f:
            for i, line in enumerate(f, 1):
                for pattern, msg in BLOCKED_PATTERNS:
                    if re.search(pattern, line):
                        violations.append(
                            f'  ⚠  {msg}\n     {filepath}:{i} → {line.strip()[:80]}'
                        )
    except Exception:
        pass
    return violations

violations = []
for f in get_staged_files():
    violations.extend(check_file(f))

if violations:
    print('\n🚨 HES Safety Validator v3.2 — COMMIT BLOQUEADO\n')
    for v in violations:
        print(v)
    print('\nCorrija os problemas acima antes de commitar.')
    print('Override (não recomendado): git commit --no-verify\n')
    sys.exit(1)

print('✅ HES Safety Validator v3.2 — OK')
```

### `scripts/hooks/sdd_commit_checker.py` (commit-msg — sensor computacional)

```python
#!/usr/bin/env python3
"""HES SDD Commit Checker v3.2 — commit-msg hook
Sensor computacional: valida Conventional Commits e estágio HES."""
import sys, re

VALID_TYPES = [
    'feat', 'fix', 'docs', 'test', 'refactor',
    'chore', 'spec', 'design', 'data', 'discovery', 'review',
    'harness',   # ← NOVO v3.2: commits de melhoria do harness
    'fitness',   # ← NOVO v3.2: commits de fitness functions
]
PATTERN = re.compile(
    r'^(' + '|'.join(VALID_TYPES) + r')(\(\w[\w-]*\))?!?: .{10,}$'
)

msg_file = sys.argv[1]
with open(msg_file) as f:
    msg = f.read().strip()

first_line = msg.split('\n')[0]

if not PATTERN.match(first_line):
    print('\n🚨 HES Commit Checker v3.2 — Mensagem inválida\n')
    print(f'  Recebido : {first_line}')
    print(f'  Esperado : <type>(<scope>): <descrição com 10+ chars>')
    print(f'  Tipos    : {", ".join(VALID_TYPES)}')
    print(f'  Exemplos : feat(pagamento): implementar endpoint PIX')
    print(f'             harness(arch): adicionar regras ArchUnit para camada de serviço\n')
    sys.exit(1)

print('✅ HES Commit Checker v3.2 — OK')
```

### `scripts/hooks/install.sh`

```bash
#!/usr/bin/env bash
set -e
echo "🔧 Instalando HES Git Hooks v3.2..."
HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
SCRIPTS_DIR="$(git rev-parse --show-toplevel)/scripts/hooks"
ln -sf "$SCRIPTS_DIR/safety_validator.py"   "$HOOKS_DIR/pre-commit"
ln -sf "$SCRIPTS_DIR/sdd_commit_checker.py" "$HOOKS_DIR/commit-msg"
chmod +x "$SCRIPTS_DIR"/*.py
echo "✅ Hooks instalados (sensors computacionais HES v3.2):"
echo "   pre-commit  → safety_validator.py"
echo "   commit-msg  → sdd_commit_checker.py"
echo ""
echo "Teste: git commit --allow-empty -m 'harness: validar hooks HES v3.2'"
```

---

## ◈ PASSO 11 — EXIBIR RESUMO DO BOOTSTRAP (v3.2)

```
✅ HES Bootstrap v3.2 Concluído — {{NOME_PROJETO}}

Guides instalados (feedforward):
  .claude/CLAUDE.md (ou equivalente)   ← identidade do agente
  .hes/state/current.json              ← estado do projeto (v3.2 schema)
  .hes/state/events.log                ← log de transições (traces)
  .hes/state/session-checkpoint.json   ← checkpoint de sessão (NOVO v3.2)
  .hes/agents/registry.json            ← registro de agentes (NOVO v3.2)
  .hes/tasks/lessons.md                ← memória de aprendizado
  .hes/tasks/backlog.md                ← backlog de features
  {{.hes/domains/*/context.md}}        ← bounded contexts (se domínios)
  {{.hes/domains/*/fitness/}}          ← sensors de architecture fitness

Agents registrados:
  {{N}} phase agents + {{N}} system agents + {{N}} sub-agents

Sensors instalados (feedback):
  scripts/hooks/safety_validator.py    ← pre-commit (computacional)
  scripts/hooks/sdd_commit_checker.py  ← commit-msg (computacional)
  {{src/.../ArchitectureTest.java}}    ← ArchUnit (se configurado)

IDE detectada: {{IDE}} → config gerada: {{CONFIG_FILE}}
Session manager: skills/session-manager.md ✅
Agent delegation: skills/agent-delegation.md ✅

Para ativar os git hooks:
  bash scripts/hooks/install.sh
```

---

▶ PRÓXIMA AÇÃO — DISCOVERY

```
O harness está instalado. Qual é a primeira feature que você quer desenvolver?

  [A] "quero implementar [nome da feature]"
      → Inicio Discovery (skills/01-discovery.md)

  [B] "quero ver o backlog antes"
      → Mostro .hes/tasks/backlog.md

  [C] "o projeto tem código existente para analisar"
      → Carrego skills/legacy.md para inventário + harnessability assessment

  [D] "/hes harness"
      → Diagnóstico da cobertura inicial do harness recém-instalado

📄 Skill-file próximo: skills/01-discovery.md
💡 Dica: o Discovery captura as Regras de Negócio (RN-xx).
   Tudo não capturado aqui gera retrabalho nas etapas seguintes.
   É o guide inferencial mais importante do behaviour harness.
```
