---
name: clean-architecture-book
description: Use when you need to design, review, or refactor a system's architecture and dependency structure guided by Clean Architecture (Robert C. Martin, 2017) — covering the two values of software (behavior vs. structure) and the Eisenhower urgency/importance trap, the programming paradigms as disciplines that remove capabilities (structured, object-oriented, functional), the SOLID design principles (SRP responsible to one actor, OCP open-closed, LSP substitutability, ISP depend on nothing you don't use, DIP depend on abstractions), the component principles for cohesion (REP, CCP, CRP) and coupling (ADP no cycles, SDP depend toward stability, SAP stable=abstract, the Main Sequence), and architecture itself — the Dependency Rule (source-code dependencies point inward), keeping options open by deferring decisions, drawing boundaries, policy and level, Entities and Use Cases (business rules), Screaming Architecture, the Clean Architecture's concentric circles (Entities, Use Cases, Interface Adapters, Frameworks & Drivers), the Humble Object pattern, partial boundaries, Main as the ultimate detail, the truth about microservices, the test boundary, embedded/HAL, and treating the database, web/UI, and frameworks as details. This should trigger for requests such as Review my architecture or dependency direction; Which way should this dependency point; Apply the Dependency Rule / Dependency Inversion; Refactor toward Clean Architecture or hexagonal/ports-and-adapters; Decouple business rules from the database/web/framework; Split this class by actor (SRP); Break a dependency cycle between components; Decide where to draw a boundary; Structure use cases and entities; or Is this design too coupled to a framework. Distilled from Clean Architecture (Robert C. Martin, Prentice Hall, 2017).
license: Apache-2.0
metadata:
  author: Robert C. Martin (source); skill synthesized from Clean Architecture (Prentice Hall, 2017)
  version: 1.0.0
---
# Clean Architecture — Dependency Rules, SOLID, Components, and Boundaries

Design, review, and refactor a system's structure by applying the practices of *Clean Architecture: A Craftsman's Guide to Software Structure and Design* by Robert C. Martin (Uncle Bob).

**What is covered in this Skill?**

- **Introduction** (Part I): the goal of architecture is to *minimize the human resources required to build and maintain* a system; software has **two values** — behavior (what it does) and structure (architecture, how easily it changes); the urgency/importance trap (Eisenhower's matrix) where the urgent-but-unimportant crowds out the important-but-not-urgent architecture
- **Programming paradigms** (Part II): each paradigm *removes* a capability rather than adding one — **structured** programming disciplines direct transfer of control (proof by decomposition; tests show the presence, not the absence, of bugs), **OO** disciplines indirect transfer of control (polymorphism → the plugin architecture and absolute control over dependency direction), **functional** programming disciplines assignment (immutability, segregating mutable state, event sourcing)
- **Design principles (SOLID)** (Part III): **SRP** — a module is responsible to one and only one actor; **OCP** — open for extension, closed for modification, achieved by dependency direction; **LSP** — subtypes must be substitutable, and violations leak into special-case architecture; **ISP** — don't depend on modules that contain more than you use; **DIP** — depend on abstractions (interfaces), never on volatile concretions; use Abstract Factory to manage creation
- **Component principles** (Part IV): cohesion — **REP** (Reuse/Release Equivalence), **CCP** (Common Closure ≈ SRP for components), **CRP** (Common Reuse ≈ ISP for components), and the tension between them; coupling — **ADP** (no dependency cycles; break them with DIP or a new component), **SDP** (depend in the direction of stability), **SAP** (a stable component should be abstract), and the **Main Sequence**
- **Architecture** (Part V): architecture is about **keeping options open** by deferring decisions; the architect is still a programmer; support all use cases while decoupling them; the **Dependency Rule** (*source code dependencies must point only inward, toward higher-level policies*); drawing boundaries and boundary anatomy; **policy and level**; **business rules** (Entities = Critical Business Rules, Use Cases = application-specific rules with request/response models); **Screaming Architecture**; the **Clean Architecture** circles (Entities, Use Cases, Interface Adapters, Frameworks & Drivers) and crossing boundaries with DIP; the **Humble Object** pattern; partial boundaries; layers vs. boundaries (don't over- or under-engineer); **Main** as the ultimate detail/plugin; the truth about services and microservices; the **test boundary** (Fragile Tests, a testing API); clean **embedded** architecture (firmware vs. software, the HAL)
- **Details** (Part VI): the **database is a detail**, the **web/UI is a detail**, **frameworks are details** — keep them outside the boundary as plugins to the business rules; a worked case study; and *The Missing Chapter* — package by layer vs. feature vs. ports-and-adapters vs. component, and how frameworks quietly break encapsulation

## Constraints

Architecture work changes dependency direction, module boundaries, and deployment structure — it can subtly break behavior or builds. Validate before and after.

- **MANDATORY**: Run the project's build/test (e.g. `./mvnw clean verify`, `mvn test`, `npm test`, `dotnet test`) before applying any change.
- **VERIFY**: Re-run the full build and tests after each change; report failures honestly and do not claim success until they pass.
- **CRITICAL SAFETY**: If the build is broken before you start, STOP and ask the user to fix it first.
- **DEPENDENCY DIRECTION IS THE INVARIANT**: The Dependency Rule (source-code dependencies point inward, toward higher-level policy) is the core check. When in doubt, verify which way the `import`/`#include`/`using` arrows point — high-level policy must never depend on low-level detail.
- **DON'T OVER-ENGINEER**: Boundaries, abstractions, and partial boundaries have real cost. Apply them where an axis of change actually exists; deferring a boundary you might need is itself a valid Clean Architecture decision (Ch24–25). Avoid speculative interfaces.
- **PRESERVE BEHAVIOR**: Inverting a dependency, extracting an interface, or moving code across a boundary must keep observable behavior identical unless the user asks to change it.
- **INCREMENTAL**: Invert/extract/move one dependency or boundary at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full set of practices with Good/Bad examples and the principle each one serves.

## When to use this skill

- Decide **which way a dependency should point** and enforce the Dependency Rule (high-level policy independent of low-level detail)
- Apply **Dependency Inversion** to decouple business rules from the database, the web/UI, a framework, or an external service
- Refactor toward **Clean Architecture / hexagonal (ports & adapters)**: extract Entities and Use Cases, push frameworks and I/O to the outside as plugins
- Split a class by **actor (SRP)**, or make a module **open for extension** (OCP) by inverting a dependency
- Diagnose an **LSP/ISP** violation that forces special-case code or fat-interface coupling
- Organize code into **components** and **break dependency cycles** (ADP); decide which components should be stable/abstract (SDP/SAP, the Main Sequence)
- Decide **where to draw a boundary** — and whether to defer it (partial boundary) to avoid over-engineering
- Structure **business rules** (Entities vs. Use Cases) and keep the architecture **screaming** the domain, not the framework
- Make the system **testable** by applying the Humble Object pattern and avoiding Fragile Tests
- Review whether a design is **too coupled to a framework, ORM, or delivery mechanism**

## Workflow

1. **Validate the project before recommendations**

   Run the build and tests; stop if they fail.

2. **Read the reference and map the dependency structure**

   Read `references/clean-architecture-book.md`. Identify the components, the business rules (policy) vs. the details (I/O, DB, web, frameworks), and the actual direction of source-code dependencies. Map each smell to a specific practice by chapter section and title (e.g. "22.1 Enforce the Dependency Rule: source code dependencies point only inward").

3. **Categorize and prioritize findings**

   Group by impact (DEPENDENCY-DIRECTION/COUPLING, COMPONENT STRUCTURE, SOLID, BOUNDARY/TESTABILITY) and by part. Prioritize: fix violated dependency direction and cycles first (they block everything else), then SOLID at the class level, then component cohesion/coupling, then boundary placement and testability.

4. **Apply improvements incrementally and verify**

   Invert one dependency, extract one boundary, or split one class at a time, preserving behavior, and re-run the build and tests after each change. Cite each applied practice by chapter section and title, and name the principle it serves. Resist speculative boundaries — apply a boundary only where a real axis of change exists.

## Reference

For the full set of practices across the 34 chapters and Appendix A (the two values through the Details, with the Dependency Rule, SOLID, component principles, and boundaries) — each with rationale, the principle it serves, and Good/Bad examples — see [references/clean-architecture-book.md](references/clean-architecture-book.md).
