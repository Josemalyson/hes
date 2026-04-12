# HES Skill — 05: Tests (Fase RED — TDD)

> Skill carregada quando: feature.estado = RED
> Pré-condição: `04-data.md` aprovado, migration executada com sucesso.
>
> Papel no harness: **Sensor Primário do Behaviour Harness**
> Os testes são o sensor que verifica se o código implementa a spec.
> "Keep quality left" — quanto mais cedo o sensor detecta o problema, mais barato corrigir.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/specs/{{feature}}/02-spec.md → todos os cenários BDD
2. Ler .hes/specs/{{feature}}/03-design.md → componentes (classes/interfaces a mockar)
3. Ler .hes/specs/{{feature}}/04-data.md → DTOs (campos e validações)
4. Verificar framework de testes em uso:
   - Java:   JUnit 5 + Mockito + AssertJ? TestContainers?
   - Node:   Jest? Vitest? Supertest?
   - Python: Pytest + pytest-mock?
5. Verificar estrutura de testes existente para manter padrão
6. Verificar se ArchUnit está configurado (.hes/domains/*/fitness/)
   → Se sim: adicionar teste de architecture fitness na suite
```

---

## ◈ "KEEP QUALITY LEFT" — DISTRIBUIÇÃO DOS SENSORS (Fowler, 2026)

```
Antes do commit (pré-commit hook — sensor computacional):
  → safety_validator.py: secrets, SQL destrutivo, TODO/FIXME

Junto com o desenvolvimento (roda a cada mudança):
  → Testes unitários (rápidos — < 1s por teste)
  → Linter com regras de qualidade
  → Type checker (TypeScript / mypy)

Na fase RED (esta etapa):
  → Escrever testes ANTES do código
  → Confirmar que falham pelo motivo certo

Na fase GREEN:
  → Confirmar que passam
  → Medir coverage ≥ 80%

Na fase REVIEW:
  → ArchUnit / dep-cruiser (architecture fitness)
  → Review checklist inferencial (5 dimensões)
```

---

## ◈ ANTI-ALUCINAÇÃO — ANTES DE QUALQUER TESTE

```
[ ] Listei todas as classes que serão referenciadas nos testes?
[ ] Para cada classe: ela JÁ EXISTE em src/?
    → Sim: ler o arquivo antes de usar
    → Não: declarar como interface/mock placeholder
[ ] Todos os imports existem no projeto?
[ ] Nunca instanciar classe concreta que não existe — usar mock
[ ] Cada cenário BDD do 02-spec.md tem ao menos 1 teste?
```

---

## ◈ PASSO 1 — ESTRUTURA DE TESTES

```
tests/
  unit/
    {{feature-slug}}/
      {{NomeService}}Test.{{ext}}         ← regra de negócio isolada
      {{NomeValidator}}Test.{{ext}}       ← validações (se aplicável)
  integration/
    {{feature-slug}}/
      {{NomeFeature}}IntegrationTest.{{ext}}  ← HTTP → DB
  architecture/
    ArchitectureTest.{{ext}}             ← fitness functions (se ArchUnit)
```

---

## ◈ PASSO 2 — TEMPLATE UNITÁRIO

### Java (JUnit 5 + Mockito + AssertJ)

```java
@ExtendWith(MockitoExtension.class)
class {{NomeService}}Test {

    @Mock private {{NomeRepository}} repository;
    @InjectMocks private {{NomeService}} service;

    // ─── Caminho Feliz ────────────────────────────────────────
    @Test
    @DisplayName("UC-01 — {{descricao do cenario principal}}")
    void deve_{{resultado}}_quando_{{condicao}}() {
        // Given
        var request = {{NomeRequest}}Builder.valido().build();
        when(repository.{{metodo}}(any())).thenReturn({{mock_retorno}});

        // When
        var response = service.{{metodo}}(request);

        // Then
        assertThat(response.{{campo}}()).isEqualTo({{valor_esperado}});
        verify(repository).{{metodo}}(any());
    }

    // ─── Regra de Negócio ─────────────────────────────────────
    @Test
    @DisplayName("RN-01 — {{nome da regra}}")
    void deve_lancar_excecao_quando_rn01_violada() {
        // Given — condição que viola RN-01
        var request = {{NomeRequest}}Builder.com_violacao_rn01().build();

        // When / Then
        assertThatThrownBy(() -> service.{{metodo}}(request))
            .isInstanceOf({{TipoDeExcecao}}.class)
            .hasMessage("{{MENSAGEM_EXATA_DO_02_SPEC_MD}}"); // ← copiar da spec
    }

    // ─── Validação de Entrada ─────────────────────────────────
    @Test
    @DisplayName("Campo {{campo}} obrigatório")
    void deve_lancar_excecao_quando_campo_obrigatorio_ausente() {
        var request = {{NomeRequest}}Builder.sem_{{campo}}().build();

        assertThatThrownBy(() -> service.{{metodo}}(request))
            .isInstanceOf(ValidationException.class)
            .hasMessage("{{campo}} é obrigatório"); // ← copiar da spec
    }
}
```

### Node.js (Jest / TypeScript)

```typescript
describe('{{NomeService}}', () => {
    let service: {{NomeService}};
    let repository: jest.Mocked<{{NomeRepository}}>;

    beforeEach(() => {
        repository = { {{metodo}}: jest.fn() } as any;
        service = new {{NomeService}}(repository);
    });

    it('deve {{resultado}} quando {{condicao}}', async () => {
        repository.{{metodo}}.mockResolvedValue({{mock_retorno}});
        const result = await service.{{metodo}}(build{{NomeRequest}}());
        expect(result.{{campo}}).toBe({{valor_esperado}});
    });

    it('deve lançar erro quando RN-01 é violada', async () => {
        const input = build{{NomeRequest}}({ {{campo}}: {{valor_invalido}} });
        await expect(service.{{metodo}}(input))
            .rejects.toThrow('{{MENSAGEM_EXATA_DO_02_SPEC_MD}}');
    });
});
```

### Python (Pytest)

```python
class Test{{NomeService}}:

    @pytest.fixture
    def service(self, mocker):
        repo = mocker.MagicMock(spec={{NomeRepository}})
        return {{NomeService}}(repository=repo), repo

    def test_deve_{{resultado}}_quando_{{condicao}}(self, service):
        svc, repo = service
        repo.{{metodo}}.return_value = {{mock_retorno}}
        response = svc.{{metodo}}(build_{{nome_request}}())
        assert response.{{campo}} == {{valor_esperado}}

    def test_deve_lancar_excecao_quando_rn01_violada(self, service):
        svc, _ = service
        with pytest.raises({{TipoDeExcecao}},
                           match="{{MENSAGEM_EXATA_DO_02_SPEC_MD}}"):
            svc.{{metodo}}(build_{{nome_request}}({{campo}}={{valor_invalido}}))
```

---

## ◈ PASSO 3 — TEMPLATE DE INTEGRAÇÃO

### Java (TestContainers + RestTemplate/MockMvc)

```java
@SpringBootTest(webEnvironment = RANDOM_PORT)
@AutoConfigureTestDatabase(replace = NONE)
@Testcontainers
class {{NomeFeature}}IntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:15");

    @Autowired private TestRestTemplate restTemplate;

    @Test
    @DisplayName("POST /{{rota}} — caminho feliz (UC-01)")
    void deve_{{resultado}}_com_request_valida() {
        var response = restTemplate.postForEntity(
            "/{{rota}}", build{{NomeRequest}}Valido(), {{NomeResponse}}.class
        );
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().{{campo}}()).isNotNull();
    }

    @Test
    @DisplayName("POST /{{rota}} — 400 campo obrigatório ausente")
    void deve_retornar_400_quando_campo_ausente() {
        var response = restTemplate.postForEntity(
            "/{{rota}}", build{{NomeRequest}}Sem{{Campo}}(), ErrorResponse.class
        );
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody().error())
            .isEqualTo("{{MENSAGEM_EXATA_DO_02_SPEC_MD}}");
    }
}
```

---

## ◈ PASSO 4 — ARCHITECTURE FITNESS TEST (sensor computacional — se ArchUnit configurado)

> "Keep quality left" — o sensor de architecture fitness deve rodar cedo.
> "Computational sensors are cheap and fast enough to run on every change." — Fowler, 2026

Se ArchUnit está configurado, verificar se a nova feature precisa de novas regras:

```java
// Adicionar em src/test/java/.../ArchitectureTest.java (se aplicável):

@ArchTest
static final ArchRule {{NOME_FEATURE}}_boundary_rule =
    noClasses()
        .that().resideInAPackage("..{{PACOTE_NOVO}}..")
        .should().dependOnClassesThat()
        .resideInAPackage("..{{PACOTE_PROIBIDO}}..")
        .because("{{JUSTIFICATIVA_DO_ADR}}");
```

Atualizar `.hes/domains/{{domain}}/fitness/README.md` com a nova regra.

---

## ◈ PASSO 5 — SELF-REFINEMENT LOOP (máx. 3 tentativas)

```
Se os testes não compilam corretamente:

Tentativa {{N}}/3:
  1. Analisar o erro completo
  2. É problema no TESTE ou na spec?
  3. Corrigir o teste (nunca mudar mensagem esperada para fazer passar)
  4. Repetir

Após 3 tentativas sem sucesso:
  → Registrar em lessons.md (Categoria B — erro técnico)
  → Apresentar análise ao usuário
  → Carregar skills/error-recovery.md
```

**Regra:** Se um teste passa sem implementação → está testando errado. Investigar.

---

## ◈ PASSO 6 — CHECKLIST DO RED

```
[ ] Cada cenário BDD do 02-spec.md tem ao menos 1 teste?
[ ] Rastreabilidade: mensagens de erro = exatamente as da spec?
[ ] Testes unitários cobrem as RN-xx?
[ ] Teste de integração cobre o caminho feliz (UC-01)?
[ ] Architecture fitness test adicionado (se ArchUnit ativo)?
[ ] NENHUM teste está passando sem implementação?
[ ] Testes compilam mas falham pelo motivo esperado?
```

---

## ◈ PASSO 7 — ATUALIZAR ESTADO

### `.hes/state/current.json`: `"{{FEATURE}}": "RED"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "DATA",
  "to": "RED",
  "agent": "hes-v3.1",
  "metadata": {
    "unit_tests": {{N}},
    "integration_tests": {{N}},
    "architecture_fitness_tests": {{N}},
    "status": "failing_as_expected"
  }
}
```

---

▶ PRÓXIMA AÇÃO — CONFIRMAÇÃO DO RED

```
🔴 Testes escritos — confirme que estão falhando pelo motivo certo:

  [Java]   mvn test 2>&1 | tail -30
  [Node]   npm test 2>&1 | tail -30
  [Python] pytest -v 2>&1 | tail -30

  [A] "testes falhando — classe não encontrada / método não implementado"
      → Perfeito. Inicio a implementação (skills/06-implementation.md)

  [B] "compilação falhou: [erro]"
      → Analiso e corrijo o problema de compilação

  [C] "alguns testes passaram sem implementar"
      → Problema sério: o teste não testa o certo. Revisamos juntos.

📄 Skill-file próximo: skills/06-implementation.md
💡 Dica (Fowler): os testes são sensors. Um bom sensor falha exatamente
   quando o código está errado e passa exatamente quando está certo.
   A mensagem de erro do teste falhando é o contrato da implementação.
```
