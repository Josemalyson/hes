# Architecture Fitness Sensors Reference

> Used in: Step 9 — Configure architecture fitness sensors
> "Feedforward and feedback controls are currently scattered across delivery steps.
>  Building the outer harness is an ongoing engineering practice." — Fowler, 2026

---

## Java / Spring Boot — ArchUnit

**File:** `src/test/java/{{BASE_PACKAGE}}/architecture/ArchitectureTest.java`

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

    // ─── Layered Architecture Rules ──────────────────────────

    @ArchTest
    static final ArchRule controllers_do_not_depend_on_repositories =
        noClasses()
            .that().resideInAPackage("..controller..")
            .should().dependOnClassesThat()
            .resideInAPackage("..repository..")
            .because("Controller must not access data — violates SRP and HES RULE-01");

    @ArchTest
    static final ArchRule services_do_not_depend_on_controllers =
        noClasses()
            .that().resideInAPackage("..service..")
            .should().dependOnClassesThat()
            .resideInAPackage("..controller..")
            .because("Service must not know about the HTTP layer");

    @ArchTest
    static final ArchRule repositories_do_not_depend_on_services =
        noClasses()
            .that().resideInAPackage("..repository..")
            .should().dependOnClassesThat()
            .resideInAPackage("..service..")
            .because("Repository must not contain business logic");

    // ─── Naming Rules ───────────────────────────────────────────

    @ArchTest
    static final ArchRule controllers_must_have_suffix =
        classes()
            .that().resideInAPackage("..controller..")
            .should().haveSimpleNameEndingWith("Controller");

    @ArchTest
    static final ArchRule services_must_have_suffix =
        classes()
            .that().resideInAPackage("..service..")
            .and().areNotInterfaces()
            .should().haveSimpleNameEndingWith("Service")
            .orShould().haveSimpleNameEndingWith("UseCase");
}
```

**pom.xml dependency:**

```xml
<!-- Architecture Fitness Sensor — HES v3.3 -->
<dependency>
    <groupId>com.tngtech.archunit</groupId>
    <artifactId>archunit-junit5</artifactId>
    <version>1.3.0</version>
    <scope>test</scope>
</dependency>
```

**Run:** `mvn test -Dtest=ArchitectureTest`

---

## Node.js / NestJS / TypeScript — dependency-cruiser

```bash
npm install --save-dev dependency-cruiser
npx depcruise --init

# Add to package.json:
# "check:arch": "depcruise --validate src"
# "check:arch:ci": "depcruise --validate --output-type err-long src"
```

Configure `.dependency-cruiser.js` with boundary rules between modules.

**Run:** `npm run check:arch`

---

## Python / FastAPI — import-linter

```bash
pip install import-linter --break-system-packages
```

**File:** `.importlinter`

```ini
[contract:layers]
type = layers
layers =
    api_layer
    service_layer
    repository_layer
```

**Run:** `lint-imports`

---

## Register in Domain Fitness README

**File:** `.hes/domains/{{domain}}/fitness/README.md`

```markdown
# Fitness Functions — {{DOMAIN}}

Computational architecture fitness sensors for the {{DOMAIN}} domain.
Reference: Fowler (2026) — Architecture Fitness Harness.

## Installed sensors
- {{SENSOR}} (computational sensor)

## Defined boundary rules
- {{BOUNDARY_RULES}}

## How to run
{{COMMAND}}
```
