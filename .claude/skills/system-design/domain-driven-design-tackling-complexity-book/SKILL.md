---
name: domain-driven-design-tackling-complexity-book
description: Use when you need to model, design, refactor, or review software guided by Domain-Driven Design — the patterns and principles of *Domain-Driven Design: Tackling Complexity in the Heart of Software* by Eric Evans — covering knowledge crunching and deep models, Ubiquitous Language, Model-Driven Design, the building blocks (Layered Architecture, Entities, Value Objects, Domain Services, Modules, Aggregates, Factories, Repositories), refactoring toward deeper insight (making implicit concepts explicit, Specifications, Supple Design — Intention-Revealing Interfaces, Side-Effect-Free Functions, Assertions, Conceptual Contours, Standalone Classes, Closure of Operations, Declarative Design), and strategic design (Bounded Context, Context Map, Shared Kernel, Customer/Supplier, Conformist, Anticorruption Layer, Separate Ways, Open Host Service, Published Language, Core Domain distillation, Generic Subdomains, Large-Scale Structure). This should trigger for requests such as Apply Domain-Driven Design to this code; Is this an Entity or a Value Object?; Define the Aggregate boundary / root; Add a Repository or Factory; Establish a Ubiquitous Language; Define Bounded Contexts and a Context Map; Add an Anticorruption Layer; Distill the Core Domain; Refactor toward a deeper model. Distilled from Domain-Driven Design, Eric Evans (2003).
license: Apache-2.0
metadata:
  author: Eric Evans (source); skill synthesized from Domain-Driven Design - Tackling Complexity in the Heart of Software (2003)
  version: 1.0.0
---
# Domain-Driven Design (Eric Evans)

Model, design, refactor, and review software by applying the patterns and principles of *Domain-Driven Design: Tackling Complexity in the Heart of Software* by Eric Evans (2003).

**What is covered in this Skill?**

- **Putting the Domain Model to Work** (Part I): knowledge crunching, deep models, the **Ubiquitous Language**, **Model-Driven Design**, **Hands-On Modelers** — keeping model, language, and code in tight correspondence
- **The Building Blocks of a Model-Driven Design** (Part II): **Layered Architecture** (isolate the domain layer), the **Smart UI** anti-pattern, **Entities** (identity & continuity), **Value Objects** (attributes, immutability), **Domain Services** (stateless operations), **Modules** (cohesive packages that tell the story), **Aggregates** (consistency boundaries with a root), **Factories** (encapsulated creation), **Repositories** (collection-like access to aggregate roots)
- **Refactoring Toward Deeper Insight** (Part III): **Breakthrough**, **making implicit concepts explicit** (Constraints, Processes), **Specification** (predicate value objects), and **Supple Design** — **Intention-Revealing Interfaces**, **Side-Effect-Free Functions**, **Assertions**, **Conceptual Contours**, **Standalone Classes**, **Closure of Operations**, **Declarative Design**
- **Strategic Design** (Part IV):
  - **Maintaining Model Integrity**: **Bounded Context**, **Continuous Integration**, **Context Map**, **Shared Kernel**, **Customer/Supplier Development Teams**, **Conformist**, **Anticorruption Layer**, **Separate Ways**, **Open Host Service**, **Published Language**
  - **Distillation**: **Core Domain**, **Generic Subdomains**, **Domain Vision Statement**, **Highlighted Core**, **Cohesive Mechanisms**, **Segregated Core**, **Abstract Core**
  - **Large-Scale Structure**: **Evolving Order**, **System Metaphor**, **Responsibility Layers**, **Knowledge Level**, **Pluggable Component Framework**

## Constraints

DDD changes are model and design changes — they affect object identity, boundaries, transactions, persistence, and team/context organization. Before and after applying them, keep the project building and tested.

- **MANDATORY**: Run the project build (e.g. `./mvnw compile` / `mvn compile`, or the project's equivalent) before applying structural model changes.
- **VERIFY**: Run the full test build (e.g. `./mvnw clean verify` / `mvn clean verify`) after applying changes; report failures honestly and do not claim success until the build and tests pass.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **PRESERVE BEHAVIOR**: Refactoring toward a deeper model (extracting Value Objects, changing aggregate boundaries, introducing Repositories/Factories, translating across contexts) must preserve observable behavior unless the user explicitly asks to change a contract.
- **ENGAGE DOMAIN EXPERTS**: DDD is collaborative. When domain meaning is ambiguous, surface the ambiguity and ask the user (acting for the domain expert) rather than inventing terminology — a change in the model is a change in the Ubiquitous Language.
- **MODEL BEFORE CODE**: Anchor every recommendation in a domain concept and name it in the Ubiquitous Language; do not introduce a class, service, or layer that does not correspond to a domain idea (avoid anemic/"phony" objects and stringly-typed concepts).
- **RESPECT TRANSACTIONAL CONSISTENCY**: Aggregate boundaries are consistency boundaries — invariants hold within one aggregate per transaction; cross-aggregate consistency is eventual.
- **INCREMENTAL**: Apply one pattern/refactoring at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full pattern catalog with rationale and Good/Bad examples.

## When to use this skill

- Apply Domain-Driven Design to this code / domain
- Decide whether a concept is an **Entity** or a **Value Object**; make a Value Object immutable
- Define an **Aggregate**: choose the root, set the boundary, enforce invariants in one transaction
- Add a **Repository** (only for aggregate roots) or a **Factory** (encapsulated creation)
- Introduce a **Domain Service** for an operation that is not a natural responsibility of an Entity/Value Object
- Establish or refine a **Ubiquitous Language** and align names in code with it
- Isolate the domain with a **Layered Architecture**; remove a **Smart UI** anti-pattern
- Make an **implicit concept explicit** (a Constraint, Process, or **Specification**)
- Improve **Supple Design** (intention-revealing names, side-effect-free functions, assertions, closure of operations)
- Define **Bounded Contexts** and draw a **Context Map**; add an **Anticorruption Layer**, **Shared Kernel**, **Open Host Service**, or **Published Language**
- **Distill the Core Domain**; extract **Generic Subdomains**; write a **Domain Vision Statement**
- Introduce a **Large-Scale Structure** (Responsibility Layers, Knowledge Level, etc.)

## Workflow

1. **Validate the project before recommendations**

   Run the project build and stop if compilation fails.

2. **Crunch knowledge and read the reference**

   Read `references/domain-driven-design-tackling-complexity-book.md`, then study the target domain and code. Identify the model concepts in play and the language used; map each smell to a specific DDD pattern by name.

3. **Categorize and prioritize findings**

   Group by layer/scope — **Tactical** (Entities, Value Objects, Services, Aggregates, Factories, Repositories, Supple Design) vs **Strategic** (Bounded Contexts, Context Map, Distillation, Large-Scale Structure) — and by impact (CRITICAL model/consistency integrity, MAINTAINABILITY, EXPRESSIVENESS, STRATEGIC alignment). Order remediation: language and isolation first (Ubiquitous Language, Layered Architecture), then tactical building blocks, then strategic context boundaries and distillation.

4. **Refactor toward deeper insight, incrementally, and verify**

   Apply one pattern at a time, preserving behavior, naming everything in the Ubiquitous Language, and re-run the full test build after each substantive change. Cite each applied pattern by name (e.g., "Aggregate", "Anticorruption Layer").

## Reference

For the full pattern catalog with rationale and Good/Bad examples, see [references/domain-driven-design-tackling-complexity-book.md](references/domain-driven-design-tackling-complexity-book.md).
