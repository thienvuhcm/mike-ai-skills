---
name: fundamentals-of-software-architecture-book
description: Use when you need to define, review, evaluate, or evolve a software architecture using the engineering approach of Fundamentals of Software Architecture (Mark Richards & Neal Ford, 2020) — covering the four dimensions of architecture (structure, characteristics, decisions, design principles), the eight architect expectations, and the Laws of Software Architecture (everything is a trade-off; why beats how); architectural thinking (architecture-vs-design continuum, technical breadth over depth, trade-off analysis, staying hands-on without being the bottleneck); modularity metrics (cohesion, afferent/efferent coupling, abstractness/instability/distance from the Main Sequence, and connascence); defining architecture characteristics ("-ilities") with the three-part test and the operational/structural/cross-cutting categories; identifying and limiting characteristics (the least-worst architecture, scalability vs. elasticity, translating domain language to characteristics); measuring and governing them (cyclomatic complexity, fitness functions, automated governance, chaos engineering); scoping them with the architecture quantum and DDD bounded contexts; component-based thinking (technical vs. domain partitioning, Conway's Law and the Inverse Conway Maneuver, avoiding the entity trap); the architecture styles and their trade-offs (layered, pipeline, microkernel, service-based, event-driven broker/mediator, space-based, orchestration-driven SOA, microservices) plus the eight fallacies of distributed computing; choosing a style by domain/architecture isomorphism and defaulting to synchronous/monolithic; and the techniques and soft skills — architecture decision records (ADRs), risk matrices and risk storming, diagramming and presenting, making teams effective (control boundaries, Elastic Leadership, checklists), negotiation and leadership, and developing a career path (the 20-minute rule, a personal technology radar). This should trigger for requests such as Which architecture style should I use; Help me define or prioritize the architecture characteristics for this system; Review/limit my -ilities list; Is this one quantum or several; Apply Conway's Law / partition my components; Should this be a monolith or distributed, synchronous or asynchronous; Broker vs. mediator event-driven; Write an ADR for this decision; Run a risk-storming or risk assessment; Diagram or present this architecture; How much should I control this team; or Help me negotiate this characteristic with a stakeholder. Distilled from Fundamentals of Software Architecture: An Engineering Approach (Mark Richards & Neal Ford, O'Reilly, 2020).
license: Apache-2.0
metadata:
  author: Mark Richards and Neal Ford (source); skill synthesized from Fundamentals of Software Architecture (O'Reilly, 2020)
  version: 1.0.0
---
# Fundamentals of Software Architecture — Characteristics, Styles, Trade-offs, and Soft Skills

Define, review, evaluate, and evolve a software architecture by applying the engineering approach of *Fundamentals of Software Architecture: An Engineering Approach* by Mark Richards and Neal Ford. The throughline is that **there are no right answers in architecture, only trade-offs** (and ones that are more or less expensive) — so every recommendation should name its trade-off and the *why* behind it.

**What is covered in this Skill?**

- **Foundations** (Part I): architecture as four dimensions (**structure**, **architecture characteristics**, **architecture decisions**, **design principles**); the eight **architect expectations** and the two **Laws** (everything is a trade-off; why beats how); **architectural thinking** (architecture/design continuum, breadth over depth, the Frozen Caveman trap, trade-off analysis, hands-on without the bottleneck trap); **modularity** (cohesion levels and LCOM; afferent/efferent coupling; abstractness, instability, distance from the Main Sequence with the Zones of Uselessness/Pain; **connascence** static→dynamic with strength/locality/degree); **architecture characteristics** (the three-part test; operational/structural/cross-cutting; implicit vs. explicit); **identifying characteristics** (the *least worst* architecture, the Vasa warning, top-3 not rank-all, the domain→characteristics translation table, scalability vs. elasticity); **measuring & governing** (cyclomatic complexity; fitness functions; automated governance; chaos engineering); **scope** (the **architecture quantum** and DDD **bounded contexts**); **component-based thinking** (technical vs. domain partitioning, **Conway's Law** and the **Inverse Conway Maneuver**, the **entity trap** vs. Actor/Actions, Event Storming, and Workflow identification)
- **Architecture styles** (Part II): the **eight fallacies of distributed computing** plus distributed logging/transactions/contract pains; **layered** (closed layers, Layers of Isolation, the architecture sinkhole); **pipeline** (pipes + Producer/Transformer/Tester/Consumer filters); **microkernel** (core + plug-ins + contracts, the only domain-*and*-technically-partitioned style); **service-based** (4–12 coarse domain services, often one shared database, ACID-friendly, the pragmatic middle ground); **event-driven** (broker vs. mediator topology, preventing data loss, request-reply); **space-based** (tuple space, in-memory data grids, data pumps/writers/readers, data-collision tuning for extreme/variable scale); **orchestration-driven SOA** (the reuse-begets-coupling cautionary lesson); **microservices** (bounded contexts, duplication over coupling, granularity, sidecar/service mesh, no distributed transactions — sagas sparingly); and **choosing a style** by decision criteria, **domain/architecture isomorphism**, quantum count, and synchronous-by-default
- **Techniques and soft skills** (Part III): **architecture decisions** (the Covering-Your-Assets/Groundhog-Day/Email-Driven anti-patterns; **ADRs** with Title/Status/Context/Decision/Consequences/Compliance/Notes; emphasizing *why* and governability); **analyzing risk** (the impact×likelihood **risk matrix**; **risk assessments** with direction; **risk storming** — individual identification, collaborative consensus and mitigation); **diagramming & presenting** (representational consistency, visual language, UML/C4/ArchiMate; manipulating time, incremental builds, invisibility, infodecks vs. presentations); **making teams effective** (control-freak/armchair/effective boundaries, **Elastic Leadership**'s five factors, the three team-size warning signs, **checklists**); **negotiation and leadership** (grammar/facts/divide-and-conquer, demonstration defeats discussion, justify don't dictate, the 4 C's, pragmatic-yet-visionary, lead by example); and **developing a career path** (the **20-minute rule**, a **personal technology radar**, diversify your portfolio, weak links)

## Constraints

Architecture work changes module boundaries, dependency direction, deployment topology, and team structure — it ripples through behavior, builds, operations, and people. Validate before and after, and prefer reversible, incremental moves.

- **MANDATORY**: Run the project's build/test (e.g. `./mvnw clean verify`, `mvn test`, `npm test`, `dotnet test`) before applying any structural change.
- **VERIFY**: Re-run the full build and tests after each change; report failures honestly and never claim success until they pass.
- **CRITICAL SAFETY**: If the build is broken before you start, STOP and ask the user to fix it first.
- **FIRST LAW IS THE INVARIANT**: *Everything in software architecture is a trade-off.* If a choice seems to have no downside, you simply haven't found the trade-off yet (Corollary 1). State what every recommendation costs.
- **DERIVE, DON'T GUESS, CHARACTERISTICS**: Characteristics must be explicit, **few** (top 3, not the whole list), and traceable to domain concerns, requirements, or implicit needs. Resist the *least worst* / Generic Architecture trap of supporting every "-ility."
- **MEASURE OBJECTIVELY**: Prefer fitness functions, cyclomatic complexity, coupling/connascence metrics, and the architecture quantum over subjective opinion.
- **DEFAULT TO SIMPLE**: Prefer synchronous over asynchronous and monolithic over distributed until a concrete force (differing quanta) requires more — distributed architectures inherit the eight fallacies.
- **PRESERVE BEHAVIOR**: Splitting a component, inverting a dependency, or changing topology must keep observable behavior identical unless the user asks to change it.
- **INCREMENTAL**: Change one component boundary, dependency, quantum, or style decision at a time and re-validate; never batch many structural changes without intermediate verification.
- **CAPTURE WHY**: Record the rationale and trade-offs (Second Law) — in ADRs or in the response — so deliberate trade-offs aren't later "fixed" and reintroduced as bugs.
- **BEFORE APPLYING**: Read the reference for the full set of practices with Good/Bad examples and the principle each one serves.

## When to use this skill

- **Choose or combine an architecture style** by matching topology to the problem (domain/architecture isomorphism) and weighing each style's trade-offs (layered, pipeline, microkernel, service-based, event-driven, space-based, SOA, microservices)
- **Define and prioritize architecture characteristics** ("-ilities") with the three-part test, keep the list short (top 3), and translate business goals into characteristics
- **Distinguish scalability from elasticity**, surface implicit characteristics, and avoid the *least worst* / Vasa over-engineering trap
- **Measure and govern** structure — cyclomatic complexity, coupling/connascence, abstractness/instability/distance — and codify the important rules as **fitness functions**
- **Scope characteristics with the architecture quantum** and DDD bounded contexts; decide whether a design is one quantum (monolith) or several (distributed)
- **Identify components** via Actor/Actions, Event Storming, or workflow — avoiding the **entity trap** — and partition technically vs. by domain (with Conway's Law / the Inverse Conway Maneuver)
- **Decide monolith vs. distributed and synchronous vs. asynchronous**, accounting for the eight fallacies of distributed computing and the cost of distributed transactions/logging/contracts
- **Choose broker vs. mediator** event-driven topology; prevent message data loss; design request-reply
- **Write ADRs**, emphasizing *why* and how each decision will be governed, and avoid the decision anti-patterns
- **Analyze and mitigate risk** with the impact×likelihood matrix, risk assessments that show direction, and collaborative **risk storming**
- **Diagram and present** an architecture effectively (representational consistency, visual language, C4/UML/ArchiMate; incremental builds, invisibility)
- **Lead a development team** — right-size the control boundary (Elastic Leadership), watch team-size warning signs, leverage checklists, negotiate with stakeholders/architects/developers, and develop your own breadth (the 20-minute rule, a personal radar)

## Workflow

1. **Validate the project before recommendations**

   Run the build and tests; stop if they fail. Confirm you understand the domain, the explicit requirements, and the organizational/team constraints before proposing structure.

2. **Read the reference and map the four dimensions**

   Read `references/fundamentals-of-software-architecture-book.md`. Identify the system's **structure** (style[s]), its **characteristics** (and whether they were derived or guessed), its **decisions** (rules) vs. **design principles** (guidelines), and its **quanta** (one vs. several). Map each smell to a specific practice by chapter section and title (e.g. "[7.1] Scope characteristics with the architecture quantum" or "[17.4] Don't do distributed transactions — fix granularity").

3. **Categorize and prioritize findings**

   Group by impact (CHARACTERISTICS, STRUCTURE/STYLE, MODULARITY/QUANTUM, DECISIONS/RISK, TEAM/COMMUNICATION) and by part. Prioritize: first get the **characteristics** short and derived and the **quantum count** right (they drive everything); then fix **style/topology** mismatches and modularity (coupling/connascence, partitioning); then formalize **decisions** as ADRs and analyze **risk**; then address diagramming, team, and leadership concerns. For every recommendation, **state the trade-off** it makes.

4. **Apply improvements incrementally and verify**

   Make one structural change at a time — split one component, adjust one quantum boundary, invert one dependency, change one communication style, or add one fitness function — preserving behavior, and re-run the build and tests after each. Cite each applied practice by chapter section and title, name the principle/law it serves, and record the *why* (Second Law) in an ADR or in your summary. Resist gold-plating: support the fewest characteristics, default to synchronous and monolithic, and apply distribution or extra boundaries only where a concrete force requires them.

## Reference

For the full set of practices across the 24 chapters (Foundations, Architecture Styles, and Techniques & Soft Skills) — each with rationale, the law/principle it serves, and Good/Bad examples — see [references/fundamentals-of-software-architecture-book.md](references/fundamentals-of-software-architecture-book.md).
