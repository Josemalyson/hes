# HES Skill — 05: Tests (RED Phase — TDD)

> Skill loaded when: feature.state = RED
> Pre-condition: `04-data.md` approved, migration executed successfully.
>
> Role in the harness: **Primary Sensor of the Behaviour Harness**
> Tests are the sensor that verifies whether the code implements the spec.
> "Keep quality left" — the earlier the sensor detects the problem, the cheaper it is to fix.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/specs/{{feature}}/02-spec.md → all BDD scenarios
2. Read .hes/specs/{{feature}}/03-design.md → components (classes/interfaces to mock)
3. Read .hes/specs/{{feature}}/04-data.md → DTOs (fields and validations)
4. Verify testing framework in use:
   - Java:   JUnit 5 + Mockito + AssertJ? TestContainers?
   - Node:   Jest? Vitest? Supertest?
   - Python: Pytest + pytest-mock?
5. Verify existing test structure to maintain pattern
6. Verify if ArchUnit is configured (.hes/domains/*/fitness/)
   → If yes: add architecture fitness test to the suite
```

---

## ◈ "KEEP QUALITY LEFT" — SENSOR DISTRIBUTION (Fowler, 2026)

```
Before commit (pre-commit hook — computational sensor):
  → safety_validator.py: secrets, destructive SQL, TODO/FIXME

Along with development (runs on each change):
  → Unit tests (fast — < 1s per test)
  → Linter with quality rules
  → Type checker (TypeScript / mypy)

In the RED phase (this stage):
  → Write tests BEFORE the code
  → Confirm they fail for the right reason

In the GREEN phase:
  → Confirm they pass
  → Measure coverage ≥ 80%

In the REVIEW phase:
  → ArchUnit / dep-cruiser (architecture fitness)
  → Inferential review checklist (5 dimensions)
```

---

## ◈ ANTI-HALLUCINATION — BEFORE ANY TEST

```
[ ] Have I listed all classes that will be referenced in tests?
[ ] For each class: does it ALREADY EXIST in src/?
    → Yes: read the file before using
    → No: declare as interface/mock placeholder
[ ] Do all imports exist in the project?
[ ] Never instantiate a concrete class that doesn't exist — use mock
[ ] Does each BDD scenario from 02-spec.md have at least 1 test?
```

---

## ◈ STEP 1 — TEST STRUCTURE

```
tests/
  unit/
    {{feature-slug}}/
      {{NomeService}}Test.{{ext}}         ← isolated business rule
      {{NomeValidator}}Test.{{ext}}       ← validations (if applicable)
  integration/
    {{feature-slug}}/
      {{NomeFeature}}IntegrationTest.{{ext}}  ← HTTP → DB
  architecture/
    ArchitectureTest.{{ext}}             ← fitness functions (if ArchUnit)
```

---

## ◈ STEP 2 — UNIT TEMPLATE

### Java (JUnit 5 + Mockito + AssertJ)

```java
@ExtendWith(MockitoExtension.class)
class {{NomeService}}Test {

    @Mock private {{NomeRepository}} repository;
    @InjectMocks private {{NomeService}} service;

    // ─── Happy Path ───────────────────────────────────────────
    @Test
    @DisplayName("UC-01 — {{scenario description}}")
    void should_{{result}}_when_{{condition}}() {
        // Given
        var request = {{NomeRequest}}Builder.valid().build();
        when(repository.{{method}}(any())).thenReturn({{mock_return}});

        // When
        var response = service.{{method}}(request);

        // Then
        assertThat(response.{{field}}()).isEqualTo({{expected_value}});
        verify(repository).{{method}}(any());
    }

    // ─── Business Rule ────────────────────────────────────────
    @Test
    @DisplayName("BR-01 — {{rule name}}")
    void should_throw_exception_when_br01_violated() {
        // Given — condition that violates BR-01
        var request = {{NomeRequest}}Builder.with_violation_br01().build();

        // When / Then
        assertThatThrownBy(() -> service.{{method}}(request))
            .isInstanceOf({{ExceptionType}}.class)
            .hasMessage("{{EXACT_MESSAGE_FROM_02_SPEC_MD}}"); // ← copy from spec
    }

    // ─── Input Validation ─────────────────────────────────────
    @Test
    @DisplayName("Field {{field}} is required")
    void should_throw_exception_when_required_field_missing() {
        var request = {{NomeRequest}}Builder.without_{{field}}().build();

        assertThatThrownBy(() -> service.{{method}}(request))
            .isInstanceOf(ValidationException.class)
            .hasMessage("{{field}} is required"); // ← copy from spec
    }
}
```

### Node.js (Jest / TypeScript)

```typescript
describe('{{NomeService}}', () => {
    let service: {{NomeService}};
    let repository: jest.Mocked<{{NomeRepository}}>;

    beforeEach(() => {
        repository = { {{method}}: jest.fn() } as any;
        service = new {{NomeService}}(repository);
    });

    it('should {{result}} when {{condition}}', async () => {
        repository.{{method}}.mockResolvedValue({{mock_return}});
        const result = await service.{{method}}(build{{NomeRequest}}());
        expect(result.{{field}}).toBe({{expected_value}});
    });

    it('should throw error when BR-01 is violated', async () => {
        const input = build{{NomeRequest}}({ {{field}}: {{invalid_value}} });
        await expect(service.{{method}}(input))
            .rejects.toThrow('{{EXACT_MESSAGE_FROM_02_SPEC_MD}}');
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

    def test_should_{{result}}_when_{{condition}}(self, service):
        svc, repo = service
        repo.{{method}}.return_value = {{mock_return}}
        response = svc.{{method}}(build_{{nome_request}}())
        assert response.{{field}} == {{expected_value}}

    def test_should_throw_exception_when_br01_violated(self, service):
        svc, _ = service
        with pytest.raises({{ExceptionType}},
                           match="{{EXACT_MESSAGE_FROM_02_SPEC_MD}}"):
            svc.{{method}}(build_{{nome_request}}({{field}}={{invalid_value}}))
```

---

## ◈ STEP 3 — INTEGRATION TEMPLATE

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
    @DisplayName("POST /{{route}} — happy path (UC-01)")
    void should_{{result}}_with_valid_request() {
        var response = restTemplate.postForEntity(
            "/{{route}}", buildValid{{NomeRequest}}(), {{NomeResponse}}.class
        );
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().{{field}}()).isNotNull();
    }

    @Test
    @DisplayName("POST /{{route}} — 400 required field missing")
    void should_return_400_when_field_missing() {
        var response = restTemplate.postForEntity(
            "/{{route}}", build{{NomeRequest}}Without{{Field}}(), ErrorResponse.class
        );
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody().error())
            .isEqualTo("{{EXACT_MESSAGE_FROM_02_SPEC_MD}}");
    }
}
```

---

## ◈ STEP 4 — ARCHITECTURE FITNESS TEST (computational sensor — if ArchUnit configured)

> "Keep quality left" — the architecture fitness sensor should run early.
> "Computational sensors are cheap and fast enough to run on every change." — Fowler, 2026

If ArchUnit is configured, verify whether the new feature needs new rules:

```java
// Add to src/test/java/.../ArchitectureTest.java (if applicable):

@ArchTest
static final ArchRule {{FEATURE_NAME}}_boundary_rule =
    noClasses()
        .that().resideInAPackage("..{{NEW_PACKAGE}}..")
        .should().dependOnClassesThat()
        .resideInAPackage("..{{FORBIDDEN_PACKAGE}}..")
        .because("{{JUSTIFICATION_FROM_ADR}}");
```

Update `.hes/domains/{{domain}}/fitness/README.md` with the new rule.

---

## ◈ STEP 5 — SELF-REFINEMENT LOOP (max. 3 attempts)

```
⏱ Time Budget: 10 minutes for RED phase

Attempt {{N}}/3:
  1. Analyze the full error
  2. Is the problem in the TEST or in the spec?
  3. Fix the test (never change expected message to make it pass)
  4. Run the test to verify
  5. If still failing and N < 3 → Loop detection: "Consider a different approach."

After 3 unsuccessful attempts:
  → Record in lessons.md (Category B — technical error)
  → Present analysis to user
  → Load skills/error-recovery.md
```

**Rule:** If a test passes without implementation → it is testing the wrong thing. Investigate.

---

## ◈ STEP 6 — RED CHECKLIST

```
[ ] Does each BDD scenario from 02-spec.md have at least 1 test?
[ ] Traceability: error messages = exactly those from spec?
[ ] Do unit tests cover the BR-xx?
[ ] Does integration test cover the happy path (UC-01)?
[ ] Was architecture fitness test added (if ArchUnit active)?
[ ] Is NO test passing without implementation?
[ ] Do tests compile but fail for the expected reason?
```

---

## ◈ STEP 7 — UPDATE STATE

### `.hes/state/current.json`: `"{{FEATURE}}": "RED"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "DATA",
  "to": "RED",
  "agent": "hes-v3.3",
  "metadata": {
    "unit_tests": {{N}},
    "integration_tests": {{N}},
    "architecture_fitness_tests": {{N}},
    "status": "failing_as_expected"
  }
}
```

---

▶ NEXT ACTION — RED CONFIRMATION

```
🔴 Tests written — confirm they are failing for the right reason:

  [Java]   mvn test 2>&1 | tail -30
  [Node]   npm test 2>&1 | tail -30
  [Python] pytest -v 2>&1 | tail -30

  [A] "tests failing — class not found / method not implemented"
      → Perfect. Starting implementation (skills/06-implementation.md)

  [B] "compilation failed: [error]"
      → Analyze and fix the compilation issue

  [C] "some tests passed without implementing"
      → Serious problem: the test is not testing the right thing. Let's review together.

📄 Next skill file: skills/06-implementation.md
💡 Tip (Fowler): tests are sensors. A good sensor fails exactly when the code
   is wrong and passes exactly when it is right.
   The error message from the failing test is the implementation contract.
```
