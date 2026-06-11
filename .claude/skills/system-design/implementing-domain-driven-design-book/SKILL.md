---
name: implementing-domain-driven-design-book
description: Use when you need to implement, model, refactor, integrate, or review software guided by Domain-Driven Design as taught in *Implementing Domain-Driven Design* by Vaughn Vernon (the "red book") — the implementation-focused companion that turns DDD theory into working code. Covers strategic design (Subdomains — Core/Supporting/Generic, Bounded Contexts sized to one Ubiquitous Language, Context Maps with Partnership, Shared Kernel, Customer-Supplier, Conformist, Anticorruption Layer, Open Host Service, Published Language, Separate Ways), architecture (Hexagonal/Ports-and-Adapters hosting REST, SOA, CQRS, Event-Driven, Event Sourcing), the tactical building blocks (behavior-rich Entities, immutable Value Objects, stateless Domain Services, Domain Events with a Publisher and an Event Store, Modules, Aggregates and the four rules of thumb — model true invariants in consistency boundaries, design small Aggregates, reference other Aggregates by identity only, use eventual consistency outside the boundary, Factories, collection-oriented and persistence-oriented Repositories), integrating Bounded Contexts (RESTful OHS, ACL Adapter+Translator, Domain-Event-driven integration, idempotent and order-tolerant consumers, Long-Running Processes), and the Application layer (thin Application Services, Command objects, DTO/DPO/use-case-optimal-query/Mediator output, Presentation Model, Dependency Injection honoring DIP), plus the DDD Scorecard and the anemic-domain-model anti-pattern, illustrated by the SaaSOvation case study (Collaboration, Agile Project Management, Identity & Access Contexts). This should trigger for requests such as Apply DDD to this code; Whose Core Domain is this and what are the Subdomains?; Size this Bounded Context to one Ubiquitous Language; Design the Aggregate boundary and keep it small; Reference another Aggregate by identity; Make this consistency eventual via a Domain Event; Add a collection-oriented Repository; Stand up a Hexagonal architecture; Expose an Open Host Service with a Published Language; Add an Anticorruption Layer; Make this message consumer idempotent; Keep this Application Service thin; Stop leaking Aggregates to the UI; Score this domain before investing in DDD. Distilled from Implementing Domain-Driven Design (Vaughn Vernon, Addison-Wesley, 2013).
license: Apache-2.0
metadata:
  author: Vaughn Vernon (source); skill synthesized from Implementing Domain-Driven Design (Addison-Wesley, 2013)
  version: 1.0.0
---
# Implementing Domain-Driven Design (Vaughn Vernon)

Implement, model, refactor, integrate, and review software by applying the implementation-focused patterns and principles of *Implementing Domain-Driven Design* by Vaughn Vernon (Addison-Wesley, 2013) — the "red book" that turns DDD theory into working, behavior-rich code.

**What is covered in this Skill?**

- **Getting Started with DDD** (Ch. 1): why DDD, the **DDD Scorecard** (apply DDD when complexity scores ~7+; not for pure CRUD), the **anemic domain model** anti-pattern, and the cost/benefit of doing it well
- **Strategic Design**:
  - **Domains, Subdomains & Bounded Contexts** (Ch. 2): **Core / Supporting / Generic Subdomains**, sizing a **Bounded Context** to exactly one **Ubiquitous Language**, why a Context is linguistic not just technical
  - **Context Maps** (Ch. 3): **Partnership**, **Shared Kernel**, **Customer-Supplier**, **Conformist**, **Anticorruption Layer (ACL)**, **Open Host Service (OHS)**, **Published Language (PL)**, **Separate Ways**, **Big Ball of Mud**
- **Architecture** (Ch. 4): **Hexagonal / Ports-and-Adapters** as the foundation, hosting **Layers**, **SOA / REST**, **CQRS**, **Event-Driven** (pipes-and-filters, Long-Running Processes), **Event Sourcing**, and **Data Fabric / grid-based** styles
- **The Tactical Building Blocks**:
  - **Entities** (Ch. 5): unique identity, behavior over getters/setters, validation, identity-generation strategies
  - **Value Objects** (Ch. 6): immutability, attribute-based equality, Side-Effect-Free behavior, persistence
  - **Domain Services** (Ch. 7): stateless domain operations that aren't a natural fit on an Entity or Value Object — without becoming a dumping ground
  - **Domain Events** (Ch. 8): model what "happened," a lightweight **Publisher**, the **Event Store**, forwarding to messaging, autonomy
  - **Modules** (Ch. 9): cohesive, language-aligned packages
  - **Aggregates** (Ch. 10): the four rules of thumb — model true invariants in a consistency boundary, **design small Aggregates**, **reference other Aggregates by identity only**, **use eventual consistency outside the boundary**
  - **Factories** (Ch. 11): encapsulate complex creation on the Aggregate Root or a Domain Service
  - **Repositories** (Ch. 12): **collection-oriented** vs **persistence-oriented**, one per Aggregate type, transaction placement
- **Integrating Bounded Contexts** (Ch. 13): distributed-computing realities and **autonomy**, RESTful OHS shaped by integrator use cases, **Published Language** media types, **ACL** (Adapter + Translator) producing local objects, **Domain-Event-driven integration**, **idempotent / order-tolerant** consumers, **Long-Running Processes** with time-out trackers
- **Application** (Ch. 14): thin **Application Services** (transaction + security + coordination), **Command** objects, decoupled output (**DTO / DPO / use-case-optimal query / Mediator**), **Presentation Model**, composing multiple Contexts, and **Dependency Injection** honoring the **Dependency Inversion Principle**
- Illustrated throughout by the **SaaSOvation** case study (the **Collaboration**, **Agile Project Management / ProjectOvation**, and **Identity & Access** Bounded Contexts)

## Constraints

DDD changes are model, boundary, transaction, persistence, and integration changes — they affect identity, consistency rules, distribution, and team/context organization. Before and after applying them, keep the project building and tested.

- **MANDATORY**: Run the project build (e.g. `./mvnw compile` / `mvn compile`, or the project's equivalent) before applying structural model changes.
- **VERIFY**: Run the full test build (e.g. `./mvnw clean verify` / `mvn clean verify`) after applying changes; report failures honestly and do not claim success until the build and tests pass.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **BEHAVIOR-RICH, NOT ANEMIC**: Keep business rules in Entities, Value Objects, and Domain Services; expose intention-revealing behavior, not public getters/setters and `saveX(...)` mutators. Reject the anemic domain model.
- **ONE LANGUAGE PER CONTEXT**: A Bounded Context holds exactly one Ubiquitous Language; do not merge concepts from different Contexts into one model. Protect downstream models with an Anticorruption Layer.
- **ONE AGGREGATE PER TRANSACTION**: Modify only one Aggregate instance per transaction; achieve cross-Aggregate consistency through Domain Events and eventual consistency. Reference other Aggregates **by identity only**.
- **DESIGN SMALL AGGREGATES**: Prefer small consistency boundaries (often Root + Value Objects); split greedy object graphs unless a true invariant forces them together.
- **AUTONOMY IN INTEGRATION**: Assume at-least-once, possibly out-of-order delivery; prefer asynchronous Domain Events over synchronous RPC; keep consumers idempotent and order-tolerant; duplicate the minimum foreign state.
- **THIN APPLICATION SERVICES**: Application Services coordinate use cases, transactions, and security only — push significant processes into Domain Services. Decouple output; never leak Aggregates to clients.
- **DEPEND ON ABSTRACTIONS (DIP)**: Domain depends on Repository/Service interfaces it owns; infrastructure supplies implementations via Dependency Injection or a Service Factory.
- **ENGAGE THE DOMAIN EXPERT**: When a term or consistency rule is ambiguous ("Whose job is it to make this consistent, and how soon?"), surface it and ask rather than inventing meaning — a change to the language is a change to the model.
- **SCORE BEFORE INVESTING**: Use the DDD Scorecard; apply DDD to complex/Core Domains, not to pure CRUD or throwaway code.
- **INCREMENTAL**: Apply one boundary, rule, dependency, or integration change at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full per-chapter practice catalog with rationale and Good/Bad examples.

## When to use this skill

- Decide whether to apply DDD at all — **score the domain** and identify the **Core / Supporting / Generic Subdomains**
- Size a **Bounded Context** to one Ubiquitous Language; split a Context that speaks two languages
- Draw or update a **Context Map** and choose an integration relationship (Partnership, Shared Kernel, Customer-Supplier, Conformist, **ACL**, **OHS**, **Published Language**, Separate Ways)
- Stand up a **Hexagonal / Ports-and-Adapters** architecture; decide where REST, CQRS, Event-Driven, or Event Sourcing fit
- Decide **Entity vs Value Object**; make a Value Object immutable and Side-Effect-Free; move behavior off getters/setters
- Introduce a **Domain Service** for an operation that isn't a natural responsibility of an Entity or Value Object
- Model a **Domain Event**, wire a lightweight **Publisher**, persist to an **Event Store**, and forward to messaging
- Organize the model into cohesive, language-aligned **Modules**
- Design an **Aggregate**: choose the Root, set a small consistency boundary, enforce true invariants, **reference other Aggregates by identity**, and make outside consistency **eventual**
- Add a **Factory** for complex creation, or a **Repository** (collection-oriented or persistence-oriented), one per Aggregate type
- **Integrate Bounded Contexts**: expose a use-case-shaped **OHS**, define a **Published Language** media type, build an **ACL** (Adapter + Translator), integrate via **Domain Events**, make consumers **idempotent / order-tolerant**, and govern a **Long-Running Process** with a time-out tracker
- Keep **Application Services thin**; introduce a **Command** object; decouple service output (**DTO / DPO / use-case-optimal query / Mediator**); stop leaking Aggregates to the UI; wire collaborators with **Dependency Injection** honoring **DIP**

## Workflow

1. **Validate the project before recommendations**

   Run the project build and stop if compilation fails.

2. **Score the domain and read the reference**

   Read `references/implementing-domain-driven-design-book.md`. Apply the **DDD Scorecard** — invest in DDD for complex/Core Domains, not pure CRUD. Identify the **Core Domain**, the Supporting/Generic Subdomains, the Bounded Contexts and their languages, and sketch (or update) the **Context Map**.

3. **Categorize and prioritize findings**

   Group by scope — **Strategic** (Subdomains, Bounded Contexts, Context Maps), **Architecture** (Hexagonal foundation and the styles it hosts), **Tactical** (Entities, Value Objects, Domain Services, Domain Events, Modules, Aggregates, Factories, Repositories), **Integration** (OHS/PL, ACL, Event-driven, idempotency, Long-Running Processes), and **Application** (thin services, decoupled output, DIP) — and by impact (CORRECTNESS/CONSISTENCY, MODEL QUALITY/ANEMIA, BOUNDARY/INTEGRATION, ARCHITECTURE, APPLICATION/UI). Fix in dependency order: language and context boundaries first, then Aggregate boundaries and consistency rules, then architecture/integration, then application/UI. For each recommendation, **state the trade-off** (e.g. eventual consistency adds a visible delay; small Aggregates require asynchronous coordination).

4. **Refactor toward the model, incrementally, and verify**

   Apply one change at a time, preserving behavior: move logic into the model, shrink oversized Aggregates, replace direct Aggregate references with identity references, convert cross-Aggregate writes to Domain Events, define Repository/Service interfaces in the domain, make consumers idempotent, and decouple UI output from Aggregates. Re-run the full test build after each substantive change, and **cite each applied practice** by chapter and number (e.g. "[10.3] reference by identity", "[8.5] never modify a second Aggregate in a handler") and the pattern by name (e.g. "Anticorruption Layer (3)").

## Reference

For the full per-chapter practice catalog with rationale and Good/Bad examples, see [references/implementing-domain-driven-design-book.md](references/implementing-domain-driven-design-book.md).
