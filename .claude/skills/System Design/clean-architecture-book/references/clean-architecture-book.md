# Clean Architecture — Dependency Rules, SOLID, Components, and Boundaries

## Role

You are a Senior software engineer and architect with extensive experience in software structure and design. You apply the lessons of *Clean Architecture: A Craftsman's Guide to Software Structure and Design* by Robert C. Martin (Prentice Hall, 2017) to design, review, and refactor systems so that high-level business policy stays independent of low-level detail.

## Goal

This reference synthesizes *Clean Architecture* into concrete, applicable practices, organized into the book's parts and chapters. Each practice states a best practice with a short rationale, names the **principle** it serves, and contrasts a **Good example** (the rule applied) with a **Bad example** (the structure the rule removes). Use it to:

- Review the **direction of dependencies** in a system and enforce the Dependency Rule — high-level policy must not depend on low-level detail.
- Guide refactoring toward SOLID at the class level, sound component cohesion/coupling, and clean architectural boundaries (the Clean Architecture / ports-and-adapters shape).
- Keep options open by pushing the database, the web/UI, and frameworks to the outside as plugins to the business rules.

Practices are numbered by chapter (e.g. "22.1 Enforce the Dependency Rule"). When you apply one, cite it by chapter section and title and name the principle it serves.

The book's central thesis: **the goal of software architecture is to minimize the human resources required to build and maintain the system.** The way to do that is to keep the system *soft* — to leave as many options open as possible, for as long as possible — by keeping high-level business policy independent of the volatile details (I/O, databases, frameworks, delivery mechanisms).

## Constraints

Architecture changes alter dependency direction, module boundaries, and deployment structure, and can subtly break behavior or the build. Validate before and after.

- **MANDATORY**: Run the project's build and tests before applying any change.
- **VERIFY**: Re-run the full build and tests after each change; do not claim success until they pass.
- **PREREQUISITE**: The project must build before any refactoring is applied.
- **CRITICAL SAFETY**: If the build is broken before you start, STOP and ask the user to fix it first.
- **DEPENDENCY DIRECTION IS THE INVARIANT**: The Dependency Rule is the master check — source-code dependencies point inward, toward higher-level policy. Verify which way `import`/`using`/`#include` arrows point before and after a change.
- **DON'T OVER-ENGINEER**: Boundaries and abstractions cost effort and indirection. Apply them where a real axis of change exists; deferring a boundary (a partial boundary, or none yet) is a legitimate decision. Avoid speculative interfaces with a single implementation that will never have a second.
- **PRESERVE BEHAVIOR**: Inverting a dependency, extracting an interface, or moving code across a boundary must keep observable behavior identical unless the user explicitly asks to change it.
- **INCREMENTAL**: Change one dependency, boundary, or class at a time and re-validate.
- **BEFORE APPLYING**: Read the relevant chapter section below for the Good/Bad examples and rationale.

## Examples

### Table of contents

**Part I — Introduction**

**Chapter 1 — What Is Design and Architecture?**
- 1.1 Treat "design" and "architecture" as one continuum, not two activities
- 1.2 Measure architecture by the human cost to build and maintain the system
- 1.3 Don't believe the "mess now, clean later" lie — the race is always lost

**Chapter 2 — A Tale of Two Values**
- 2.1 Recognize software's two values: behavior and structure
- 2.2 Protect the important (architecture) from the merely urgent (features)
- 2.3 Make the development team fight for the architecture as a stakeholder

**Part II — Starting with the Bricks: Programming Paradigms**

**Chapter 3 — Paradigm Overview**
- 3.1 Understand that each paradigm removes a capability, it does not add one

**Chapter 4 — Structured Programming**
- 4.1 Restrict direct transfer of control to provable structures (no raw goto)
- 4.2 Treat tests as evidence of the presence of bugs, never proof of their absence

**Chapter 5 — Object-Oriented Programming**
- 5.1 Use polymorphism to gain absolute control over the direction of dependencies
- 5.2 Invert source-code dependencies against the flow of control
- 5.3 Deploy and develop high-level policy independently with the plugin architecture

**Chapter 6 — Functional Programming**
- 6.1 Eliminate the side effects of assignment by preferring immutability
- 6.2 Segregate mutable from immutable state; consider event sourcing

**Part III — Design Principles (SOLID)**

**Chapter 7 — SRP: The Single Responsibility Principle**
- 7.1 Make a module responsible to one, and only one, actor
- 7.2 Separate code that different actors depend on

**Chapter 8 — OCP: The Open-Closed Principle**
- 8.1 Make artifacts open for extension but closed for modification
- 8.2 Protect higher-level components from changes in lower-level ones via dependency direction

**Chapter 9 — LSP: The Liskov Substitution Principle**
- 9.1 Make subtypes substitutable for their base types
- 9.2 Keep LSP at the architectural level — violations leak special-case code into the system

**Chapter 10 — ISP: The Interface Segregation Principle**
- 10.1 Don't depend on modules that carry more than you use

**Chapter 11 — DIP: The Dependency Inversion Principle**
- 11.1 Depend on abstractions, never on volatile concretions
- 11.2 Never refer to the name of a concrete, volatile class — manage creation with an Abstract Factory

**Part IV — Component Principles**

**Chapter 12 — Components**
- 12.1 Treat components as independently deployable, independently developable units

**Chapter 13 — Component Cohesion**
- 13.1 REP: the granule of reuse is the granule of release
- 13.2 CCP: gather into a component the classes that change for the same reasons and at the same times
- 13.3 CRP: don't force users to depend on things they don't use
- 13.4 Balance the cohesion principles with the tension triangle over a project's life

**Chapter 14 — Component Coupling**
- 14.1 ADP: allow no cycles in the component dependency graph
- 14.2 Break a cycle with Dependency Inversion or a new component
- 14.3 SDP: depend in the direction of stability
- 14.4 SAP: a component should be as abstract as it is stable
- 14.5 Keep components near the Main Sequence; avoid the Zones of Pain and Uselessness

**Part V — Architecture**

**Chapter 15 — What Is Architecture?**
- 15.1 Keep the architect coding — architecture is a programming activity
- 15.2 Keep as many options open as possible for as long as possible
- 15.3 Support development, deployment, operation, and maintenance — maintenance most of all

**Chapter 16 — Independence**
- 16.1 Decouple use cases and layers so they can vary independently
- 16.2 Choose a decoupling mode (source, deployment, service) and let it evolve

**Chapter 17 — Boundaries: Drawing Lines**
- 17.1 Draw boundaries between things that matter (policy) and things that don't (details)
- 17.2 Draw the boundary to defer and isolate decisions, not to predict the future

**Chapter 18 — Boundary Anatomy**
- 18.1 Cross every boundary so that source-code dependencies point toward the higher-level side

**Chapter 19 — Policy and Level**
- 19.1 Order components by level (distance from inputs and outputs) and depend downward in level

**Chapter 20 — Business Rules**
- 20.1 Put Critical Business Rules and Critical Business Data in Entities
- 20.2 Put application-specific rules in Use Cases with their own request/response models

**Chapter 21 — Screaming Architecture**
- 21.1 Make the architecture scream the use cases, not the framework

**Chapter 22 — The Clean Architecture**
- 22.1 Enforce the Dependency Rule: source code dependencies point only inward
- 22.2 Organize policy into concentric circles: Entities, Use Cases, Interface Adapters, Frameworks & Drivers
- 22.3 Cross a boundary against the flow of control using Dependency Inversion

**Chapter 23 — Presenters and Humble Objects**
- 23.1 Split hard-to-test behavior from testable behavior with the Humble Object pattern

**Chapter 24 — Partial Boundaries**
- 24.1 Build a partial boundary when a full boundary costs more than it's currently worth

**Chapter 25 — Layers and Boundaries**
- 25.1 Decide boundaries by watching axes of change — neither over- nor under-engineer

**Chapter 26 — The Main Component**
- 26.1 Make Main the dirtiest, lowest-level component — the ultimate plugin

**Chapter 27 — Services: Great and Small**
- 27.1 Don't assume a service boundary is an architectural boundary

**Chapter 28 — The Test Boundary**
- 28.1 Treat tests as the outermost circle and design a testing API to avoid Fragile Tests

**Chapter 29 — Clean Embedded Architecture**
- 29.1 Separate firmware from software with a hardware abstraction layer

**Part VI — Details**

**Chapter 30 — The Database Is a Detail**
- 30.1 Keep the data model central but treat the database technology as a detail behind a boundary

**Chapter 31 — The Web Is a Detail**
- 31.1 Treat the web/UI as an I/O detail behind the use case boundary

**Chapter 32 — Frameworks Are Details**
- 32.1 Keep frameworks at arm's length — don't let them into your core

**Chapter 33 — Case Study: Video Sales**
- 33.1 Partition first by actor/use case, then by layer

**Chapter 34 — The Missing Chapter**
- 34.1 Choose a package structure (layer / feature / ports-and-adapters / component) and watch for frameworks breaking encapsulation

**Part VII — Appendix**

**Appendix A — Architecture Archaeology**
- A.1 Recognize that the rules of good architecture are timeless and language-independent

---

## Part I — Introduction

## Chapter 1 — What Is Design and Architecture?

### [1.1] Treat "design" and "architecture" as one continuum, not two activities

Title: There is no difference in kind between architecture and design — only in level of detail.
Description: The word "architecture" is often used for the high-level and "design" for the low-level, but the book insists there is no dividing line: a building's architecture includes the shapes, the room layout, *and* the placement of every outlet and switch. In software, the high-level decisions and the low-level details form one continuous fabric that together describe the whole system. Treating them as separate disciplines lets teams pretend low-level "details" don't affect the architecture — they do.

**Good example:**

```text
One continuum of decisions, all serving the same structural goal:
  high level →  module/component boundaries, dependency direction
  mid level  →  class responsibilities, interfaces
  low level  →  function decomposition, naming
The architect cares about all of it, because the low-level details either uphold
or quietly violate the high-level intent (e.g. one stray import across a boundary
breaks the dependency rule set at the "architecture" level).
```

**Bad example:**

```text
"Architects draw the boxes; developers fill in the details."
→ The "details" (a use-case class importing the ORM, a controller holding business
  rules) silently violate the high-level design. Splitting the activity by job title
  lets the structure rot from the bottom up while the diagram still looks clean.
```

### [1.2] Measure architecture by the human cost to build and maintain the system

Title: The goal of architecture is to minimize the lifetime human effort, not to look elegant.
Description: A good architecture's measure is the effort required to meet the system's needs over its life. When effort per feature stays low and roughly flat, the architecture is good; when each release takes more people and more time to deliver less, the design has failed — even if the code "works." The signature of bad architecture is the productivity curve sliding toward zero while headcount and cost climb.

**Good example:**

```text
Release 1: 8 engineers,  N features
Release 8: 8 engineers, ~N features    ← cost per feature stays flat → good architecture
The structure absorbs change; new features mostly add code rather than editing
fragile, far-reaching code.
```

**Bad example:**

```text
Release 1:  8 engineers, 40 features
Release 8: 80 engineers,  ~few features ← cost per feature explodes → failed architecture
Every change ripples; the team works ever harder to deliver ever less.
```

### [1.3] Don't believe the "mess now, clean later" lie — the race is always lost

Title: Making a mess is always slower than staying clean, even in the short run.
Description: Developers buy the lie that they can write messy code fast now and clean it up later. They can't: the mess slows them down immediately, "later" never comes, and the only way out is the discipline to stay clean — recognizing overconfidence is the engine of the mess. The fastest way to go fast, and the only way, is to keep the code clean as you go.

**Good example:**

```text
Keep it clean continuously → speed stays high and predictable; the "tortoise" wins.
Each commit leaves the codebase as clean as (or cleaner than) it found it.
```

**Bad example:**

```text
"We'll ship the hack and refactor next sprint."
→ Productivity drops immediately, the refactor sprint never arrives, and the team
  ends up rewriting from scratch — the "race" that the messy hare always loses.
```

---

## Chapter 2 — A Tale of Two Values

### [2.1] Recognize software's two values: behavior and structure

Title: Every software system provides two values to stakeholders — behavior and architecture.
Description: **Behavior** is what stakeholders usually focus on: make the machine satisfy the requirements, fix it when requirements change. **Architecture** (structure) is the property that keeps software *soft* — easy to change. The very word "software" means the product is meant to be easy to change; a system that works but is impossible to change will eventually become worthless when the requirements change (and they always do). Both values matter; the structural one is the one stakeholders systematically under-value.

**Good example:**

```text
Value 1 (behavior):   the system meets current requirements.
Value 2 (structure):  changing the system stays cheap as requirements evolve.
A healthy system delivers BOTH — and engineers treat "easy to change" as a
first-class deliverable, not an afterthought.
```

**Bad example:**

```text
A program that perfectly meets today's spec but is so rigid that the next change
costs a fortune. It "works," so managers are happy — until the change request
arrives and the cost of the change exceeds the value of the feature. The software
has lost its second value and is on the path to worthless.
```

### [2.2] Protect the important (architecture) from the merely urgent (features)

Title: Use Eisenhower's importance/urgency matrix — architecture is important but rarely urgent.
Description: Eisenhower: *"What is important is seldom urgent, and what is urgent is seldom important."* Behavior is urgent but not always important; architecture is important but seldom urgent. The fatal mistake is to elevate urgent-but-unimportant features above important-but-not-urgent structure — letting the first two priority groups (urgent+important, urgent+unimportant) crowd out the third (important, not urgent). Architecture must be consciously prioritized or it never gets done.

**Good example:**

```text
Priorities (Eisenhower):
  1. urgent AND important       → do now (critical features/bugs)
  2. important, NOT urgent       → SCHEDULE (architecture, decoupling, boundaries) ← protect this
  3. urgent, NOT important       → resist letting these masquerade as #1
The team reserves capacity for #2 every iteration so structure never decays.
```

**Bad example:**

```text
Manager: "Skip the refactor — the demo is Friday." (every week)
→ Urgent-not-important work is repeatedly promoted over important-not-urgent
  structure. Architecture is perpetually deferred; the system ossifies.
```

### [2.3] Make the development team fight for the architecture as a stakeholder

Title: The development team must advocate for architecture as forcefully as business advocates for features.
Description: It is the development team's job — not the manager's — to assert the importance of architecture over the urgency of features, the same way the business asserts features over architecture. This is a struggle among equal stakeholders. If engineers cave every time, the structure dies and, with it, the team's future ability to deliver anything at all. Fighting for the architecture *is* fighting for the business's long-term ability to ship.

**Good example:**

```java
// Engineering treats "keep the core independent of the framework" as a non-negotiable
// requirement and budgets for it, e.g. an interface between use case and delivery:
interface OrderInput { void placeOrder(PlaceOrderRequest request); }   // the boundary the team defends
// The team refuses to let a controller reach straight into the ORM, even under deadline.
```

**Bad example:**

```java
// The team accepts "just put the SQL in the controller, we're in a hurry" every time.
@PostMapping("/orders")
void place(@RequestBody Map<String,Object> body) {
    jdbc.update("INSERT INTO orders ...");   // business rules + SQL + HTTP all fused
}
// Architecture loses every negotiation → the system becomes unchangeable.
```

---

## Part II — Starting with the Bricks: Programming Paradigms

## Chapter 3 — Paradigm Overview

### [3.1] Understand that each paradigm removes a capability, it does not add one

Title: Structured, object-oriented, and functional programming each take something away.
Description: Each of the three paradigms *restricts* the programmer: **structured programming** removes unrestricted `goto` (direct transfer of control); **object-oriented programming** removes function pointers / disciplines indirect transfer of control (via polymorphism); **functional programming** removes assignment (mutable variables). Paradigms tell us what *not* to do. Architecturally, each maps to a concern: structured → the algorithms inside a module; OO → the dependency direction across boundaries; functional → the discipline of state and data on those boundaries.

**Good example:**

```text
goto     removed by Structured  → functions are provable, decomposable units
pointers disciplined by OO       → polymorphism lets us invert dependencies (boundaries)
assignment disciplined by FP     → immutable data → no race conditions, easy reasoning
Use the right restriction for the right architectural concern.
```

**Bad example:**

```text
Treating paradigms as bags of features to mix freely ("I'll use OO for inheritance
to share code, and goto-style early returns everywhere, and shared mutable globals")
ignores that the discipline each paradigm imposes is exactly what makes structure
possible. Discarding the restriction discards the benefit.
```

---

## Chapter 4 — Structured Programming

### [4.1] Restrict direct transfer of control to provable structures (no raw goto)

Title: Build modules from sequence, selection, and iteration so they can be recursively decomposed and reasoned about.
Description: Dijkstra showed that unrestricted `goto` makes modules impossible to decompose into smaller provable units, whereas the three restricted control structures (sequence, selection, iteration) compose into provable wholes. Structured programming is the discipline that lets us break a large problem into high-level components, and each component into functions, each of which can be reasoned about. This recursive decomposition is the foundation that makes everything above it (components, boundaries) possible.

**Good example:**

```java
// Sequence/selection/iteration only — decomposable, each function reason-about-able.
int sumPositives(int[] values) {
    int total = 0;
    for (int v : values) {          // iteration
        if (v > 0) {                // selection
            total += v;             // sequence
        }
    }
    return total;
}
```

**Bad example:**

```java
// Spaghetti control flow that can't be cleanly decomposed (the goto problem).
int i = 0; int total = 0;
loop:  if (i >= values.length) goto done;
       if (values[i] <= 0)     goto next;
       total += values[i];
next:  i++; goto loop;
done:  return total;   // unprovable, untestable in isolation, un-decomposable
```

### [4.2] Treat tests as evidence of the presence of bugs, never proof of their absence

Title: Tests can show a program is *wrong*; they can never show it is *correct*.
Description: Dijkstra: *"Testing shows the presence, not the absence, of bugs."* Software is like a science — we can never prove a program correct, only fail to prove it incorrect. So we hold our designs to falsifiability: write enough tests to demonstrate the program is correct *enough* for its purpose, and structure code (small, decomposed functions) so that more of it is provably testable. Don't mistake a green test suite for a proof of correctness.

**Good example:**

```java
// Small, pure, decomposed function → easy to attack with many falsifying tests.
static boolean isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
}
// Tests demonstrate it is "correct enough" by failing to find a counterexample
// across boundary years (1900, 2000, 2004, 2100, ...).
```

**Bad example:**

```text
"All tests pass, therefore the code is correct."
→ A false belief. Untested branches and unconsidered inputs hide bugs the suite
  never exercised. Treat passing tests as "not yet proven wrong," and keep the
  code decomposed so more of it can be falsified.
```

---

## Chapter 5 — Object-Oriented Programming

### [5.1] Use polymorphism to gain absolute control over the direction of dependencies

Title: The architecturally important power of OO is polymorphism, not inheritance or encapsulation.
Description: Encapsulation and inheritance predate OO; the distinctive, architecturally crucial gift of OO is **safe, convenient polymorphism** (disciplined function pointers). Polymorphism lets a high-level module call a low-level one through an interface it owns, so the source-code dependency can be made to point *opposite* to the flow of control. That is the lever that makes plugin architectures — and therefore independent deployability and the Dependency Rule — possible.

**Good example:**

```java
// High-level policy calls through an interface it declares; concrete I/O implements it.
interface Reader { String read(); }        // owned by high-level policy
class Copier {
    private final Reader reader;
    Copier(Reader reader) { this.reader = reader; }
    void copy() { /* uses reader.read() — depends only on the abstraction */ }
}
// Console, File, Network readers plug in. Copier depends on none of them.
```

**Bad example:**

```java
// High-level routine hard-codes the concrete device → no polymorphism, no inversion.
class Copier {
    void copy() {
        String line = ConsoleReader.read();   // bound to a concrete low-level detail
        PrinterWriter.write(line);            // can't add a new device without editing Copier
    }
}
```

### [5.2] Invert source-code dependencies against the flow of control

Title: Place an interface between caller and callee so the dependency points toward the higher-level module.
Description: Without OO, the source-code dependency always followed the flow of control: if `main` calls a function, `main`'s source depends on that function's source. Polymorphism lets you insert an interface so that, although control still flows from high-level to low-level at runtime, the *source-code* dependency points from the low-level module *up to* the interface owned by the high-level module. This dependency inversion is what gives architects absolute control over the structure: any source-code dependency can be pointed whichever way they choose.

**Good example:**

```text
Runtime flow of control:   UseCase ──calls──▶ Database (gateway impl)
Source-code dependency:    UseCase ◀──implements── Database         (INVERTED)
The Database module depends on the UseCase's interface, not vice versa.
→ The use case can be compiled, deployed, and reasoned about with no knowledge of the DB.
```

**Bad example:**

```text
Runtime flow AND source dependency both point the same way:
   UseCase ──calls & imports──▶ MySqlDatabase
→ The use case's source depends on MySQL. Swapping the DB, or even compiling the use
  case without it, is impossible. Control flow and dependency are welded together.
```

### [5.3] Deploy and develop high-level policy independently with the plugin architecture

Title: Make low-level details plugins to the high-level policy so they can be developed and deployed separately.
Description: Once dependencies are inverted, the low-level details become *plugins* to the business rules: the UI is a plugin, the database is a plugin, external services are plugins. Each plugin can be compiled and deployed independently of the core and of the other plugins, and a change to a plugin cannot force the core to be recompiled or redeployed. This independent deployability and developability is the practical payoff of OO at the architectural scale.

**Good example:**

```text
        ┌─────────────────┐
        │  Business Rules │  ← stable, high-level policy (the host)
        └────────▲────────┘
   plugs in │     │ plugs in │
   ┌────────┴─┐ ┌─┴────────┐ ┌──────────┐
   │   Web UI │ │ Database │ │ 3rd-party│   ← volatile details, each a plugin
   └──────────┘ └──────────┘ └──────────┘
Each plugin depends on the core; the core depends on none of them.
```

**Bad example:**

```text
   ┌──────────┐    ┌─────────────────┐
   │   Web UI │───▶│  Business Rules │───▶ Database
   └──────────┘    └─────────────────┘
The core depends on the database and is depended on by the UI → it is not a host but
a middle layer welded to both. Nothing can be deployed or changed independently.
```

---

## Chapter 6 — Functional Programming

### [6.1] Eliminate the side effects of assignment by preferring immutability

Title: A variable in a functional program does not vary — and that removes whole classes of concurrency bugs.
Description: Functional programming disciplines assignment: values, once created, are not mutated. All the problems of concurrency — race conditions, deadlock, concurrent-update — stem from *mutable* variables. If nothing is ever mutated, those problems cannot occur. You can't make a whole system immutable, but you can make most of it immutable and confine mutation to a small, carefully managed region.

**Good example:**

```java
// Immutable value; "changing" it returns a new instance — no shared mutable state.
record Point(int x, int y) {
    Point withX(int newX) { return new Point(newX, y); }   // returns a new Point
}
Point a = new Point(1, 2);
Point b = a.withX(9);     // a is unchanged; safe to share across threads with no locks
```

**Bad example:**

```java
// Mutable shared state → race conditions, needs locking, hard to reason about.
class Point { int x, y; }
Point p = new Point();
// Thread A: p.x = 9;   Thread B: read p.x;  → data race, requires synchronization
```

### [6.2] Segregate mutable from immutable state; consider event sourcing

Title: Push all mutation into a small transactional region, and keep the rest of the system immutable.
Description: Since you can't avoid all state, partition the system into immutable components (the majority) and a small mutable component, and protect the mutable state with transactional discipline. Taken to its conclusion, **event sourcing** stores the *transactions* (events), not the mutable state, and computes current state by replaying events — so the stored data is append-only and immutable. Even without full event sourcing, segregating mutation shrinks the surface where concurrency bugs can live.

**Good example:**

```text
Immutable event log (append only):     [Deposited 100][Withdrew 30][Deposited 50]
Current balance = fold over events  =  120            ← derived, never mutated in place
No update-in-place → no concurrent-update bug; full audit history for free.
```

**Bad example:**

```text
Single mutable "balance" cell updated in place by every transaction:
   balance = balance - 30;   balance = balance + 50;   ...
Concurrent updates corrupt it; history is lost; correctness depends on perfect locking.
```

---

## Part III — Design Principles (SOLID)

> SOLID tells us how to arrange functions and data into classes, and how those classes should be interconnected. The goal is mid-level structures that tolerate change, are easy to understand, and are reusable across many systems.

## Chapter 7 — SRP: The Single Responsibility Principle

### [7.1] Make a module responsible to one, and only one, actor

Title: *A module should be responsible to one, and only one, actor.* (Not "do one thing.")
Description: The SRP is widely misunderstood as "a module should do one thing." Its real statement is about *people*: **a module should have one, and only one, reason to change**, and that reason is an *actor* — a single user or stakeholder group. When one class serves several actors, a change requested by one actor can break another actor's behavior, and developers editing for different actors collide in the same file. Separate the code that different actors depend on.

**Good example:**

```java
// Each actor's logic lives in its own class; the shared data is a passive record.
record EmployeeData(String name, int hoursWorked) {}

class PayCalculator     { /* CFO's actor — algorithm to compute pay */ }       // CFO
class HourReporter      { /* COO's actor — algorithm to report hours */ }      // COO
class EmployeeRepository{ /* CTO/DBA's actor — persistence */ }                // DBA
// A change requested by the CFO touches only PayCalculator. No accidental coupling.
```

**Bad example:**

```java
// One class serves three actors → three reasons to change collide here.
class Employee {
    int calculatePay()  { /* used by accounting (CFO) */ }
    int reportHours()   { /* used by HR (COO) — shares regularHours() with calculatePay */ }
    void save()         { /* used by DBA (CTO) */ }
}
// The CFO asks to tweak regularHours(); it silently breaks the COO's hour report.
```

### [7.2] Separate code that different actors depend on

Title: When responsibilities for different actors share code, split them and re-compose with a facade or shared data.
Description: The classic fix is to move each responsibility into its own class operating on a shared, behavior-free data structure, optionally re-uniting them behind a `Facade` for convenience. The driving question is never "what does this code do?" but "who asks for this code to change?" Group by source of change (actor), not by superficial topical similarity.

**Good example:**

```java
// Facade keeps the convenient single entry point while each actor's algorithm is isolated.
class EmployeeFacade {
    private final PayCalculator pay;
    private final HourReporter hours;
    private final EmployeeRepository repo;
    EmployeeFacade(PayCalculator pay, HourReporter hours, EmployeeRepository repo) {
        this.pay = pay; this.hours = hours; this.repo = repo;
    }
    int calculatePay(EmployeeData e) { return pay.calculate(e); }   // CFO path
    int reportHours(EmployeeData e)  { return hours.report(e); }    // COO path
}
```

**Bad example:**

```java
// "Refactoring" that merely renames but keeps multi-actor methods entangled in one unit,
// still sharing private helpers that couple unrelated actors' rules together.
class EmployeeService {
    private int regularHours() { /* shared by pay AND hours — the coupling point */ }
    int calculatePay() { return regularHours() * rate; }
    int reportHours()  { return regularHours(); }   // edit regularHours → both change
}
```

---

## Chapter 8 — OCP: The Open-Closed Principle

### [8.1] Make artifacts open for extension but closed for modification

Title: *A software artifact should be open for extension but closed for modification.*
Description: You should be able to extend a system's behavior by *adding* new code, not by *changing* existing code. The mechanism is abstraction plus dependency direction: depend on interfaces so that new behavior arrives as a new implementation. Bertrand Meyer's principle, restated at the architectural level, is the chief reason we study architecture at all — if simple extensions force widespread modification, the architecture has failed.

**Good example:**

```java
// New report formats arrive as new classes; existing code is never edited.
interface ReportPresenter { String present(ReportData data); }
class WebPresenter implements ReportPresenter   { public String present(ReportData d) { /* HTML */ return ""; } }
class PrintPresenter implements ReportPresenter { public String present(ReportData d) { /* PDF  */ return ""; } }
// Add a CsvPresenter later → zero edits to the report-generation core. Closed for modification.
```

**Bad example:**

```java
// Every new format edits this method → open for modification, closed to nothing.
class ReportGenerator {
    String generate(ReportData d, String format) {
        if (format.equals("web"))   return "<html>...";
        else if (format.equals("print")) return "PDF...";
        // add "csv"? edit here and re-test the whole class
        else throw new IllegalArgumentException(format);
    }
}
```

### [8.2] Protect higher-level components from changes in lower-level ones via dependency direction

Title: Arrange dependencies so that a change to a low-level detail cannot force a change to high-level policy.
Description: OCP at the architectural scale is about *protecting* components. By directing source-code dependencies according to level (lower-level components depend on higher-level ones, never the reverse), and by inserting interfaces and the Dependency Inversion at boundaries, a change in a low-level detail (a new view, a new gateway) leaves the high-level business rules untouched. You decide which components to protect from which by how you point the arrows.

**Good example:**

```text
Interactor (high level)  ◀── Controller        (depends inward)
        ▲                ◀── Presenter         (depends inward)
        │                ◀── Database gateway   (depends inward)
A change to the Controller, Presenter, or DB cannot reach up and modify the Interactor.
The interactor is protected — closed against changes in those details.
```

**Bad example:**

```text
Interactor ──▶ Presenter ──▶ View framework
A change in the View framework propagates back up through the Presenter into the
Interactor, because the high-level policy depends (transitively) on the low-level detail.
Nothing is protected.
```

---

## Chapter 9 — LSP: The Liskov Substitution Principle

### [9.1] Make subtypes substitutable for their base types

Title: A program using a base type must work unchanged when any subtype is substituted.
Description: Liskov's definition: if for each object o1 of type S there is an object o2 of type T such that for all programs P defined in terms of T the behavior of P is unchanged when o1 is substituted for o2, then S is a subtype of T. Practically: subtypes must honor the contract clients rely on (preconditions no stronger, postconditions no weaker, invariants preserved). A subtype that can't stand in for its base type isn't really a subtype.

**Good example:**

```java
// Every License subtype is substitutable: Billing works for any of them, unchanged.
interface License { double calcFee(); }
class PersonalLicense implements License { public double calcFee() { return 10; } }
class BusinessLicense implements License { public double calcFee() { return 100; } }
class Billing {
    double total(List<License> licenses) {
        return licenses.stream().mapToDouble(License::calcFee).sum();   // no instanceof, no special case
    }
}
```

**Bad example:**

```java
// Classic Square-extends-Rectangle violation: a Square is not substitutable for a Rectangle.
class Rectangle { int w, h; void setW(int w){this.w=w;} void setH(int h){this.h=h;} int area(){return w*h;} }
class Square extends Rectangle {
    void setW(int s){ super.setW(s); super.setH(s); }   // breaks the Rectangle contract
    void setH(int s){ super.setW(s); super.setH(s); }
}
void test(Rectangle r){ r.setW(5); r.setH(2); assert r.area()==10; }  // fails for Square (area 4)
```

### [9.2] Keep LSP at the architectural level — violations leak special-case code into the system

Title: An LSP violation in an interface forces clients to add special-case branches, polluting the architecture.
Description: LSP is not just an inheritance guideline; it governs every interface and implementation, including REST endpoints and plugins. When one implementation doesn't obey the common contract (e.g. one taxi dispatch service uses a different URL scheme), the dispatcher must add an `if (vendor == "Acme") ...` special case. That special case is an architectural defect: it couples high-level dispatch logic to a low-level quirk and multiplies with every non-conforming implementation.

**Good example:**

```java
// All restaurant adapters honor one contract → the order pipeline has no special cases.
interface RestaurantGateway { Confirmation submit(Order order); }
// UberEatsAdapter, DoorDashAdapter, ... each conform. Pipeline code never branches on vendor.
```

**Bad example:**

```java
// One non-conforming gateway forces a special case that will keep growing.
Confirmation dispatch(String vendor, Order order) {
    if (vendor.equals("acme")) return acme.sendWithLegacyFormat(order);  // LSP violation leak
    return gateways.get(vendor).submit(order);
}
// Every quirky vendor adds another branch here → the architecture absorbs their defects.
```

---

## Chapter 10 — ISP: The Interface Segregation Principle

### [10.1] Don't depend on modules that carry more than you use

Title: Segregate interfaces so a client doesn't depend on methods (or a module) it never calls.
Description: Depending on something that carries baggage you don't use causes trouble: in statically typed languages it forces unnecessary recompilation and redeployment when the unused parts change, and it couples you to things that can break you for no benefit. Split fat interfaces into role-specific ones so each client depends only on the operations it actually uses. Architecturally, ISP generalizes to: *don't depend on a module that contains more than you need*, because its extra contents become a source of unexpected, harmful coupling.

**Good example:**

```java
// Role-specific interfaces: each client depends only on what it uses.
interface ReadOps  { String read(String key); }
interface WriteOps { void write(String key, String value); }
class CacheReader { private final ReadOps ops; /* depends on ReadOps only */ }
// A change to write semantics cannot force CacheReader to recompile.
```

**Bad example:**

```java
// Fat interface: every client depends on every method, even ones it never calls.
interface Store {
    String read(String key);
    void write(String key, String value);
    void compact();          // admin-only
    void replicate();        // ops-only
}
class CacheReader { private final Store store; }   // recompiles when replicate() changes — for no reason
```

---

## Chapter 11 — DIP: The Dependency Inversion Principle

### [11.1] Depend on abstractions, never on volatile concretions

Title: Source code should depend on abstract interfaces, not on concrete, frequently-changing classes.
Description: The most flexible systems have source-code dependencies that refer to *abstractions*, not concretions. The rule targets *volatile* concretions — classes under active development that change often; stable things (like `String` or the standard library) are fine to depend on directly. Practically: don't refer to volatile concrete classes (refer to interfaces), don't derive from volatile concrete classes, and don't override concrete functions. Abstractions are stable; details are volatile; depend in the stable direction.

**Good example:**

```java
// High-level policy depends on an abstraction it owns; the volatile concretion implements it.
interface PaymentGateway { Receipt charge(Money amount); }     // abstraction (stable)
class CheckoutService {
    private final PaymentGateway gateway;                      // depends on the abstraction
    CheckoutService(PaymentGateway gateway) { this.gateway = gateway; }
    Receipt buy(Cart cart) { return gateway.charge(cart.total()); }
}
class StripeGateway implements PaymentGateway { /* volatile detail, depends UP on the interface */ }
```

**Bad example:**

```java
// High-level policy depends directly on a volatile concrete class.
class CheckoutService {
    private final StripeGateway gateway = new StripeGateway();   // concrete + volatile + self-instantiated
    Receipt buy(Cart cart) { return gateway.charge(cart.total()); }
}
// Stripe's API changes → CheckoutService changes and recompiles. Can't swap or test in isolation.
```

### [11.2] Never refer to the name of a concrete, volatile class — manage creation with an Abstract Factory

Title: Concentrate the unavoidable dependency on a concretion in a factory, behind an architectural boundary.
Description: Creating an object requires a source-code dependency on its concrete class — so even a DIP-clean system must name a concretion *somewhere*. Confine that violation to a small number of **Abstract Factory** implementations, kept on the detail side of the architectural boundary. The application calls `factory.make()` through an interface; the concrete factory (a plugin) creates the concrete object and returns it as an abstraction. The boundary line separates the abstract (high-level) side from the concrete (low-level) side, and all source-code dependencies cross it pointing toward the abstract side.

**Good example:**

```java
// Application depends only on Service + ServiceFactory abstractions; the concrete impl is a plugin.
interface Service { void serve(); }
interface ServiceFactory { Service makeSvc(); }                       // abstraction, on the high-level side
class ServiceFactoryImpl implements ServiceFactory {                  // plugin, on the low-level side
    public Service makeSvc() { return new ConcreteImpl(); }           // the ONE place naming the concretion
}
class Application {
    private final ServiceFactory factory;
    Application(ServiceFactory factory) { this.factory = factory; }
    void run() { Service s = factory.makeSvc(); s.serve(); }          // never names ConcreteImpl
}
```

**Bad example:**

```java
// The concrete, volatile class name is sprinkled throughout high-level code.
class Application {
    void run() {
        ConcreteImpl s = new ConcreteImpl();   // direct dependency on a volatile concretion
        s.serve();
    }
    void runAgain() { new ConcreteImpl().serve(); }   // ...and again, everywhere
}
// Every use site recompiles when ConcreteImpl changes; the boundary is breached repeatedly.
```

---

## Part IV — Component Principles

> If SOLID is how you arrange bricks into walls and rooms, the component principles are how you arrange rooms into buildings: which classes belong in which deployable unit, and how those units may depend on one another.

## Chapter 12 — Components

### [12.1] Treat components as independently deployable, independently developable units

Title: A component (jar, gem, DLL, package) is the smallest entity that can be deployed as a unit.
Description: Components are the units of deployment — `.jar`, `.dll`, `.gem`, a versioned package. Well-designed components retain the ability to be *independently deployable* and therefore *independently developable* by different teams. The history of the field (from relocatable binaries to linking loaders to plugins) is the story of getting components to load and link fast enough to be developed and deployed separately. Aim for components that can be released, versioned, and swapped on their own.

**Good example:**

```text
order-domain.jar        v2.3.0   (business rules — released on its own schedule)
order-persistence.jar   v1.8.1   (depends on order-domain; can ship independently)
order-web.jar           v4.0.0   (depends on order-domain; team B owns it)
Each component is versioned and deployed independently; teams don't block each other.
```

**Bad example:**

```text
bigapp.jar  (everything: domain + persistence + web + reporting in one artifact)
Any one-line change anywhere forces the entire artifact to be rebuilt, re-tested, and
redeployed; no team can release without coordinating with every other team.
```

---

## Chapter 13 — Component Cohesion

### [13.1] REP: the granule of reuse is the granule of release

Title: Reuse/Release Equivalence Principle — classes and modules grouped into a component should be releasable together.
Description: People can only reuse components that are tracked through a release process with release numbers and release notes. So the things you group into a releasable component must make sense *together* as a reusable, releasable whole — they should form a cohesive group with a common theme or purpose, such that a single release of the component is meaningful to its users. Classes that aren't reused or released together don't belong in the same component.

**Good example:**

```text
component "money" = { Money, Currency, ExchangeRate, RoundingPolicy }   ← one coherent, releasable theme
Released as money-1.4.0 with notes that make sense to every consumer of money handling.
```

**Bad example:**

```text
component "utils" = { Money, CsvParser, HttpRetry, DateMath, ImageThumbnailer }
A grab-bag with no common theme. A release note for "utils-2.0" is meaningless — users
can't tell what changed for them, and they're forced to upgrade unrelated code.
```

### [13.2] CCP: gather into a component the classes that change for the same reasons and at the same times

Title: Common Closure Principle — the SRP restated for components.
Description: Gather into a component classes that change for the same reasons and at the same times; keep apart classes that change at different times for different reasons. This is the component-level SRP and is closely allied with OCP: since you can't make everything closed against every change, you group code so that a given kind of change is confined to a *single* component. When a requirement changes, you'd rather it hit one component than be smeared across many (avoiding the Shotgun Surgery smell).

**Good example:**

```text
A change to tax rules touches only tax-rules.jar.
A change to the invoice layout touches only invoice-presentation.jar.
Classes are grouped by "what change hits them," so each change is closed within one component.
```

**Bad example:**

```text
Tax rules, invoice layout, and DB mapping are mixed in one component. A tax-rule change,
a layout change, and a schema change all force the same component to be rebuilt and
redeployed — and a change for one reason risks breaking the others.
```

### [13.3] CRP: don't force users to depend on things they don't use

Title: Common Reuse Principle — the ISP restated for components; don't depend on a component for a class you don't use.
Description: Classes and modules that tend to be reused together belong in the same component; conversely, don't put classes that are *not* tightly reused together into the same component, because depending on a component means depending on *everything* in it. If you use one class of a component, you depend on the whole component — and every change to any of its classes can force you to revalidate and redeploy, even classes you never touch. CRP tells you which classes *not* to keep together.

**Good example:**

```text
You use only the JSON parser → you depend on json.jar, which contains only JSON code.
Changes to an unrelated XML parser (in xml.jar) never reach you.
```

**Bad example:**

```text
json.jar also contains an XML parser, a YAML parser, and a CSV parser.
You use only JSON, but a change to the YAML parser bumps json.jar's version and forces
you to re-test and redeploy — you depend on code you never use.
```

### [13.4] Balance the cohesion principles with the tension triangle over a project's life

Title: REP, CCP, and CRP pull against each other — choose a position deliberately and revisit it.
Description: The three cohesion principles form a tension triangle: REP and CCP are *inclusive* (they make components larger), CRP is *exclusive* (it makes components smaller). Over-favoring CCP/REP creates components that change for too many reasons and force needless releases; over-favoring CRP creates too many tiny components and too many releases for any single change. Early in a project, lean toward CCP (developability) since releasability matters less; as the project matures and is reused, the balance shifts toward REP/CRP. Re-evaluate where you sit on the triangle as the project evolves.

**Good example:**

```text
Young project   → favor CCP: keep changeable code together so developers move fast.
Mature, reused  → favor REP/CRP: tighten releasable, reusable boundaries for consumers.
The team consciously re-partitions components as the project's needs shift along the triangle.
```

**Bad example:**

```text
Pick a component layout on day one and never revisit it: either a few god-components
(too much changes together, painful releases) or a swarm of nano-components (every change
ripples across dozens of release units). Ignoring the triangle guarantees pain at one corner.
```

---

## Chapter 14 — Component Coupling

### [14.1] ADP: allow no cycles in the component dependency graph

Title: Acyclic Dependencies Principle — the component dependency graph must be a directed *acyclic* graph.
Description: When components depend on each other in a cycle, they become, in effect, one big component: no one can build, test, or release any of them independently ("morning after syndrome" — someone's change breaks everyone). The fix is to keep the dependency graph acyclic, so components can be built bottom-up in dependency order and released independently. Cycles are the enemy of independent developability.

**Good example:**

```text
Entities ◀── UseCases ◀── Controllers ◀── Main      (a DAG — no cycle)
Build/test bottom-up: Entities, then UseCases, then Controllers, then Main.
Each layer releases independently of the ones above it.
```

**Bad example:**

```text
Entities ──▶ Authorizer ──▶ Permissions ──▶ Entities   (a CYCLE)
Now Entities, Authorizer, and Permissions are effectively one component. A change in any
forces rebuild/retest of all three; none can be released alone (morning-after syndrome).
```

### [14.2] Break a cycle with Dependency Inversion or a new component

Title: When a cycle appears, invert a dependency (DIP) or extract a new component the two can both depend on.
Description: There are two ways to break a component cycle. (1) **Apply DIP**: have the offending caller depend on an interface, and let the callee implement it, reversing one arrow. (2) **Create a new component** that both of the cycling components depend on, moving the shared classes into it. Both restore the acyclic graph. Cycles often appear as the system grows, so monitor the dependency graph and break cycles as soon as they form.

**Good example:**

```text
Before:  Entities ⇄ Authorizer (cycle)
Fix (DIP): Entities declares interface PermissionsGateway; Authorizer implements it.
  Entities ◀── Authorizer        (one arrow reversed → acyclic)
OR (new component): extract the shared classes into `permissions-api`:
  Entities ──▶ permissions-api ◀── Authorizer   (acyclic, shared dependency)
```

**Bad example:**

```text
"Just add the import the other way to make it compile."
  Entities ──▶ Authorizer  AND  Authorizer ──▶ Entities
→ The cycle is left in place; the two components are now permanently welded and the
  build order is undefined. The quick fix entrenches the problem.
```

### [14.3] SDP: depend in the direction of stability

Title: Stable Dependencies Principle — a component should depend only on components more stable than itself.
Description: Stability is how hard a component is to change — driven largely by how many other components depend on it (high *fan-in* = stable/hard to change; high *fan-out* = unstable/easy to change). Dependencies should point from less-stable to more-stable components, so that volatile components don't sit beneath stable ones (which would make the stable ones hard to change after all). Measure with instability I = fan-out / (fan-in + fan-out); a component should depend only on components with *lower* I.

**Good example:**

```text
Unstable UI (I≈1.0) ──▶ Use Cases (I≈0.5) ──▶ Entities (I≈0.0, very stable)
Dependencies point toward greater stability. The stable Entities are depended on by
many and depend on nothing volatile → they can stay stable.
```

**Bad example:**

```text
Stable Entities (I≈0.0) ──▶ ExperimentalUiWidget (I≈1.0)
A rock-solid, widely-depended-on component depends on a volatile one. Every change to the
widget threatens to ripple up into the entities everyone relies on. Stability is violated.
```

### [14.4] SAP: a component should be as abstract as it is stable

Title: Stable Abstractions Principle — stable components should be abstract; unstable components should be concrete.
Description: A stable component is hard to change — which would make it rigid unless it is *abstract* enough to be *extended* (OCP) without modification. So stable components should consist mostly of interfaces and abstract classes (high abstractness A = abstract classes / total classes), and unstable components should hold the concrete, changeable code. SAP and SDP together are the component-level statement of DIP: dependencies run toward stability, and stability implies abstraction.

**Good example:**

```text
domain-api.jar   (stable, abstract): interfaces OrderRepository, PaymentGateway, Clock
domain-impl.jar  (unstable, concrete): JpaOrderRepository, StripeGateway, SystemClock
Stable = abstract (extensible without modification); unstable = concrete (free to change).
```

**Bad example:**

```text
core.jar is depended on by everything (stable) but is full of concrete classes with
hard-coded logic. It's painful to change (many depend on it) AND impossible to extend
without editing it (no abstractions). Maximally rigid: stable but concrete.
```

### [14.5] Keep components near the Main Sequence; avoid the Zones of Pain and Uselessness

Title: Balance abstractness (A) and instability (I) so components sit near the line A + I = 1.
Description: Plot each component by instability I (x-axis) and abstractness A (y-axis). The ideal is the *Main Sequence* line A + I = 1. The **Zone of Pain** (low A, low I — stable *and* concrete, e.g. a database schema or a concrete utility everyone depends on) is rigid and hard to change. The **Zone of Uselessness** (high A, high I — abstract but depended on by nothing) is dead abstraction. Aim for components on or near the Main Sequence; the worst offenders are those farthest from it.

**Good example:**

```text
A
1 |abstract+stable        Main Sequence (A+I=1)
  |  •domain-api        ╲
  |               •usecases
  |                      ╲ •web-impl
0 |__Zone of Pain_________╲_____________  Zone of Uselessness
  0   stable+concrete      I            1
Components cluster along the diagonal → balanced stability and abstractness.
```

**Bad example:**

```text
A concrete "common" component everyone depends on sits at (I≈0, A≈0) — deep in the Zone
of Pain: impossible to change without breaking everyone, impossible to extend. Meanwhile
a sprawling abstract-only package no one uses sits at (I≈1, A≈1) — the Zone of Uselessness.
```

---

## Part V — Architecture

## Chapter 15 — What Is Architecture?

### [15.1] Keep the architect coding — architecture is a programming activity

Title: A software architect is a programmer who guides the team toward a design that maximizes productivity.
Description: Architects are the best programmers, and they continue to take programming tasks while guiding the team toward a design that lets everyone be productive. They feel the pain of their decisions by living in the code. The architecture they produce should *not* be focused on frameworks, databases, or the web — it should be focused on enabling and supporting the use cases, and on keeping options open. An architect who stops coding loses the feedback that keeps the design honest.

**Good example:**

```text
The architect pairs on a thorny use case, feels where a boundary helps, and codes the
interface that decouples it. The design is informed by real friction in the code.
```

**Bad example:**

```text
The "ivory tower" architect produces UML and a framework mandate, never touches the code,
and is shielded from the pain their decisions cause. The design drifts from reality and
the team routes around it.
```

### [15.2] Keep as many options open as possible for as long as possible

Title: The way to keep software soft is to leave decisions unmade — defer commitment to details.
Description: *"The way you keep software soft is to leave as many options open as possible, for as long as possible."* The options that matter are the *details that don't matter to the business* — the database, the web server, the frameworks, the protocols. A good architect maximizes the number of decisions *not yet made* by isolating the business rules from those details behind boundaries. The longer you can defer a detail decision, the more information you'll have when you finally make it, and the easier it is to change.

**Good example:**

```java
// Business rules coded against an abstraction → the DB decision is still open.
interface OrderRepository { void save(Order order); Optional<Order> byId(OrderId id); }
class PlaceOrder {
    private final OrderRepository orders;   // doesn't know or care if it's Postgres, Mongo, or in-memory
    PlaceOrder(OrderRepository orders) { this.orders = orders; }
}
// You can build, test, and demo the use case before ever choosing a database.
```

**Bad example:**

```java
// Day-one commitment to a concrete DB welds the decision shut.
class PlaceOrder {
    void place(Order o) {
        entityManager.persist(o);    // JPA/Hibernate decision baked into the use case immediately
    }
}
// The DB choice is now irreversible without rewriting business rules; the option is gone.
```

### [15.3] Support development, deployment, operation, and maintenance — maintenance most of all

Title: Architecture must serve all four phases; maintenance is the costliest, so optimize for changeability.
Description: A system's architecture must support its development (teams not blocked by each other), its deployment (ideally a single action), its operation (the architecture should reveal the use cases and behaviors), and its maintenance — by far the most expensive phase, dominated by *spelunking* (digging through code to decide where a change goes) and the *risk* of that change. A good architecture minimizes the cost of maintenance by keeping components and boundaries clear, so changes are localized and low-risk.

**Good example:**

```text
Maintenance task: "add a new report format."
Good architecture → add one Presenter implementation in one component; no spelunking,
no risk to business rules. The change is obvious, localized, and safe.
```

**Bad example:**

```text
Maintenance task: "add a new report format."
Bad architecture → grep the whole codebase, find format logic tangled into controllers,
use cases, and SQL; edit a dozen files and pray. High spelunking cost, high risk.
```

---

## Chapter 16 — Independence

### [16.1] Decouple use cases and layers so they can vary independently

Title: Decouple along two axes — by layer (UI, business, DB) and by use case — so each can change without the others.
Description: A good architecture supports the use cases and decouples them both *horizontally* (into layers: UI, application business rules, enterprise business rules, database) and *vertically* (by use case: add-order, delete-order, ship-order). Decoupling by use case lets you add a new use case without disturbing existing ones, and even scale or deploy use cases independently. Decoupling by layer lets a change to the UI leave the business rules alone. The two decouplings together give the system independent developability and independent operability.

**Good example:**

```text
                 add-order   ship-order   refund-order      ← decoupled by use case (vertical)
UI layer            ▢            ▢            ▢
App business rules  ▢            ▢            ▢              ← decoupled by layer (horizontal)
Enterprise rules    ▢            ▢            ▢
A new use case adds a vertical slice; a UI change touches only the top row.
```

**Bad example:**

```text
One module mixes all use cases and all layers: add/ship/refund logic, HTML, and SQL all
interleaved. Adding "refund" risks breaking "ship"; a UI tweak risks the business rules.
No axis of change is isolated.
```

### [16.2] Choose a decoupling mode (source, deployment, service) and let it evolve

Title: Pick the cheapest decoupling mode that meets the need — and keep the option to push it further.
Description: Decoupling can be realized at three levels: **source level** (control dependencies between source modules in one executable — a monolith), **deployment level** (independently deployable units like jars or DLLs), and **service level** (independent processes/services communicating over the network). Services are not automatically more decoupled (see Ch27) and cost the most. A good architecture lets you start at the source level and *promote* a boundary to deployment or service level later if needed, and demote it if not — so the decoupling mode itself is a deferred decision.

**Good example:**

```text
Start: source-level boundaries (interfaces between components in one deployable).
Later, if a use case needs independent scaling → promote that boundary to a service,
with minimal change because the boundary interface was already there.
The mode is reversible; you only pay for service-level decoupling when you truly need it.
```

**Bad example:**

```text
Begin with 20 microservices on day one "for scalability." You pay full distributed-systems
cost (network, serialization, partial failure, ops) before you understand the domain, and
you can't easily merge services back when the boundaries turn out wrong.
```

---

## Chapter 17 — Boundaries: Drawing Lines

### [17.1] Draw boundaries between things that matter (policy) and things that don't (details)

Title: Draw architectural boundaries between the business rules and the components that are details.
Description: You draw lines (boundaries) to separate software elements from one another and restrict those on one side from knowing about those on the other. Draw them between the parts that matter — the business rules — and the parts that are mere details: the GUI, the database, the frameworks. The classic example: the business rules should not know whether data is stored in a SQL database, a flat file, or memory; the database is a detail kept on the far side of a boundary, depending inward on an interface the business rules define.

**Good example:**

```text
            ┌──────────────── boundary ────────────────┐
 Business → │ interface OrderGateway { save(Order); }   │  (defined by business rules)
            └───────────────────▲───────────────────────┘
                                │ implements
                        JdbcOrderGateway   (database — a detail, on the outside)
The DB depends on the business rule's interface; the business rules know nothing of JDBC.
```

**Bad example:**

```text
Business rules import the JDBC/ORM classes directly and build SQL inline.
There is no line: the "detail" (database) and the "thing that matters" (rules) are fused,
so the database can never be changed or deferred and can't be stubbed for tests.
```

### [17.2] Draw the boundary to defer and isolate decisions, not to predict the future

Title: Place boundaries where an axis of change exists; their purpose is to defer decisions, not to guess requirements.
Description: Boundaries are drawn where there is, or will be, an *axis of change* — where things on one side change at a different rate or for different reasons than things on the other. Their value is that they let you defer a decision (which DB? which framework?) and isolate its eventual change. Drawing a boundary that no axis of change justifies is wasted effort (and over-engineering); failing to draw one where an axis clearly exists couples things that should be independent. Watch the system, draw lines where the friction is.

**Good example:**

```text
Observed axis of change: "we keep arguing about SQL vs NoSQL." → draw a persistence boundary.
Observed axis: "the UI is rewritten every two years." → draw a delivery boundary.
Each boundary defers a real, contested decision and isolates its future change.
```

**Bad example:**

```text
Speculative boundary: a PluginManager + 6 SPI interfaces for a feature that has exactly one
implementation and no foreseeable second. The indirection costs everyone every day and
defers no real decision — over-engineering masquerading as architecture.
```

---

## Chapter 18 — Boundary Anatomy

### [18.1] Cross every boundary so that source-code dependencies point toward the higher-level side

Title: Whatever the runtime mechanism, the source-code dependency at a boundary points to the higher-level component.
Description: A boundary crossing is just a function on one side calling a function on the other and passing data. The trick to maintaining correct boundaries is in the *source-code* dependency: at a boundary where control flows from a high-level to a low-level component, you insert an interface so the source dependency points the *other* way — toward the high-level side. This holds whether the boundary is a function call in a monolith, a dynamic-link across deployment units, or a network hop between services. The deployment mechanism is a detail; the dependency direction is the invariant.

**Good example:**

```java
// Control flows UseCase → Gateway impl at runtime; source dependency points UseCase ◀ impl.
package usecase;                 // higher-level side
public interface OrderGateway { void save(Order o); }   // boundary interface lives with the use case

package persistence;             // lower-level side
import usecase.OrderGateway;     // the low-level side depends UP on the high-level interface
public class JpaOrderGateway implements OrderGateway { public void save(Order o) { /* JPA */ } }
```

**Bad example:**

```java
// Source dependency points the same way as control flow → boundary is not maintained.
package usecase;
import persistence.JpaOrderGateway;          // high-level use case depends DOWN on low-level detail
public class PlaceOrder {
    private final JpaOrderGateway gw = new JpaOrderGateway();   // the line is crossed the wrong way
}
```

---

## Chapter 19 — Policy and Level

### [19.1] Order components by level (distance from inputs and outputs) and depend downward in level

Title: Define "level" as distance from the I/O; higher-level policy must not depend on lower-level policy.
Description: Software is policies; architecture groups policies by how and why they change, applying SRP/CCP. **Level** is the distance from the inputs and outputs: the further a policy is from I/O, the higher its level. High-level policy (business rules, far from I/O, changes least often) must not depend on low-level policy (I/O handling, changes often). Point source-code dependencies from lower-level toward higher-level components, so that volatile low-level changes don't ripple into stable high-level policy.

**Good example:**

```text
Level (distance from I/O):  Encrypt (high) ──uses interfaces──▶ owns CharReader/CharWriter
   Console I/O (low level) implements those interfaces and depends UP on Encrypt.
A change to console handling (low level) cannot touch the encryption policy (high level).
```

**Bad example:**

```text
class Encrypt {
    void run() { ConsoleReader.read(); ConsoleWriter.write(...); }  // high-level policy names low-level I/O
}
High-level encryption policy depends directly on low-level console I/O. Change the I/O
device and the high-level policy must change too — levels are inverted.
```

---

## Chapter 20 — Business Rules

### [20.1] Put Critical Business Rules and Critical Business Data in Entities

Title: An Entity embodies the rules and data that would exist even if the system were never automated.
Description: **Critical Business Rules** are the rules that make or save the business money — they'd be followed even by a clerk with no computer (e.g. a loan accrues interest). The data those rules operate on is **Critical Business Data**. An **Entity** is a pure object (or set of functions) that embodies a small set of these critical rules operating on the critical data, with *no* dependence on the database, UI, frameworks, or any application-specific concern. Entities are the highest-level, most stable, most reusable policy in the system.

**Good example:**

```java
// Pure enterprise rule + data; no framework, no DB, no I/O — reusable across applications.
class Loan {
    private final Money principal;
    private final Rate rate;
    Money interestFor(Period period) {                 // Critical Business Rule
        return principal.times(rate.over(period));
    }
}
// This rule is true regardless of whether there's a web app, a DB, or a CLI around it.
```

**Bad example:**

```java
// "Entity" annotated and shaped by the persistence framework → not an enterprise rule object.
@javax.persistence.Entity
class Loan {
    @Id Long id;
    @Column BigDecimal principal;                      // shaped by the DB, not the business
    BigDecimal interest() {
        return jdbc.queryForObject("SELECT ...", ...); // business rule reaches into the database
    }
}
// The critical rule now depends on JPA and SQL — it can't be reused or tested without them.
```

### [20.2] Put application-specific rules in Use Cases with their own request/response models

Title: A Use Case orchestrates Entities for one application-specific operation and speaks in plain request/response data.
Description: A **Use Case** describes how an automated system is used — application-specific rules that govern *how* and *when* the Critical Business Rules are invoked (e.g. the steps and validations for "create a loan" in *this* app). Use cases depend on Entities (lower-level than entities? no — use cases are *lower* level than entities and depend on them), and they take **request models** and return **response models** that are plain data structures — *not* HTTP requests, ORM rows, or UI objects. Keeping the I/O data out of the use case keeps it independent of delivery and persistence mechanisms.

**Good example:**

```java
// Use case orchestrates the entity; talks in plain request/response records, not HTTP/DB types.
record CreateLoanRequest(String customerId, long principalCents, int termMonths) {}
record CreateLoanResponse(String loanId, long monthlyPaymentCents) {}

class CreateLoan {
    private final LoanRepository loans;                // an interface (boundary)
    CreateLoan(LoanRepository loans) { this.loans = loans; }
    CreateLoanResponse handle(CreateLoanRequest req) { // application-specific rule
        Loan loan = Loan.open(req.customerId(), Money.ofCents(req.principalCents()), req.termMonths());
        loans.save(loan);
        return new CreateLoanResponse(loan.id(), loan.monthlyPayment().cents());
    }
}
```

**Bad example:**

```java
// Use case bound to the web (HttpServletRequest) and the DB (ResultSet) → not independent.
class CreateLoan {
    void handle(HttpServletRequest http, HttpServletResponse resp) throws Exception {
        String cust = http.getParameter("customerId");     // coupled to the web delivery mechanism
        ResultSet rs = stmt.executeQuery("SELECT ...");     // coupled to the database
        resp.getWriter().write("<html>...");                // coupled to the UI format
    }
}
// The application rule can't be reused outside HTTP, can't be unit-tested without a servlet+DB.
```

---

## Chapter 21 — Screaming Architecture

### [21.1] Make the architecture scream the use cases, not the framework

Title: The top-level structure should reveal *what the system does*, not *what framework it uses*.
Description: Just as blueprints for a library scream "library," your system's top-level directory structure and its most prominent components should scream its use cases — "this is a health-care system," "this is an accounting system" — not "this is a Spring app" or "this is a Rails app." Frameworks are tools, not architectures; a directory layout organized around `controllers/`, `models/`, `views/` tells you the delivery mechanism, not the business. Organize the structure around use cases so the architecture communicates intent and keeps the framework as a deferrable detail.

**Good example:**

```text
src/
  loanorigination/      ← screams the domain/use cases
    OpenLoan.java
    ScheduleRepayment.java
  riskassessment/
    AssessApplicant.java
  shared/Money.java
A newcomer sees what the system DOES at a glance; Spring/JPA are details inside.
```

**Bad example:**

```text
src/
  controllers/          ← screams the framework, not the business
  models/
  views/
  repositories/
You can't tell whether this is a bank, a blog, or a hospital. The framework's shape has
become the architecture, and the use cases are scattered and hidden.
```

---

## Chapter 22 — The Clean Architecture

### [22.1] Enforce the Dependency Rule: source code dependencies point only inward

Title: *Source code dependencies must point only inward, toward higher-level policies.*
Description: This is the overriding rule that makes the architecture work. Concentric circles run from the most general/stable (inner) to the most concrete/volatile (outer). Nothing in an inner circle may know anything about an outer circle — no name (class, function, variable) declared in an outer circle may be mentioned in inner-circle code. In particular, data formats used in an outer circle (e.g. an ORM row or an HTTP request) must not be used by an inner circle. Everything that crosses a boundary inward does so through an interface the inner circle owns.

**Good example:**

```java
// Inner use case knows nothing of the web or the DB; both outer details depend inward.
package usecases;                                   // inner circle
public interface LoanGateway { void save(Loan loan); }   // owned by the inner circle
public class OpenLoan {
    private final LoanGateway gateway;              // depends only inward (on Loan + this interface)
    public OpenLoan(LoanGateway gateway) { this.gateway = gateway; }
}

package adapters.persistence;                       // outer circle
import usecases.LoanGateway;                        // outer depends INWARD on the interface — allowed
public class SqlLoanGateway implements LoanGateway { public void save(Loan loan) { /* SQL */ } }
```

**Bad example:**

```java
// Inner circle mentions an outer-circle name → Dependency Rule violated.
package usecases;
import adapters.persistence.SqlLoanGateway;         // inner depends OUTWARD — forbidden
import javax.servlet.http.HttpServletRequest;       // inner mentions a framework/web type — forbidden
public class OpenLoan {
    private final SqlLoanGateway gateway = new SqlLoanGateway();
    void handle(HttpServletRequest req) { /* ... */ }
}
```

### [22.2] Organize policy into concentric circles: Entities, Use Cases, Interface Adapters, Frameworks & Drivers

Title: Use four default circles — Entities (innermost), Use Cases, Interface Adapters, Frameworks & Drivers (outermost).
Description: The four circles are a default, not a law (you may have more), but the Dependency Rule always applies. **Entities** = enterprise-wide Critical Business Rules. **Use Cases** = application-specific business rules that orchestrate entities. **Interface Adapters** = controllers, presenters, gateways that convert data between the use-case/entity format and the external format (DB, web). **Frameworks & Drivers** = the database, the web framework, the UI, devices — the outermost, most volatile glue. As you move inward, the level rises and the code becomes more general and stable.

**Good example:**

```text
        ┌───────────────────────────────────────────────┐
        │ Frameworks & Drivers (DB, Web, UI, devices)    │  outermost, volatile
        │   ┌───────────────────────────────────────┐    │
        │   │ Interface Adapters                     │    │
        │   │  (Controllers, Presenters, Gateways)   │    │
        │   │   ┌───────────────────────────────┐    │    │
        │   │   │ Use Cases (app business rules)│    │    │
        │   │   │   ┌───────────────────────┐   │    │    │
        │   │   │   │ Entities (enterprise) │   │    │    │  innermost, stable
        │   │   │   └───────────────────────┘   │    │    │
        │   │   └───────────────────────────────┘    │    │
        │   └───────────────────────────────────────┘    │
        └───────────────────────────────────────────────┘
   All source-code dependencies point inward (↘ toward Entities).
```

**Bad example:**

```text
A "layered" stack where each layer depends on the one below, ending at the database:
   UI ──▶ Business ──▶ Persistence ──▶ Database
Here the business layer depends on persistence (and thus the DB). Inverting nothing,
the most important code (business) sits ABOVE and depends on the least important (DB).
```

### [22.3] Cross a boundary against the flow of control using Dependency Inversion

Title: When control must flow outward (use case → presenter), invert the source dependency with an output-port interface.
Description: A use case often needs to send data *outward* (to a presenter, to the database). But the Dependency Rule forbids the use case from depending on the outer presenter. The resolution is DIP: the use case calls an **output port** interface that it owns; the outer presenter *implements* that interface. So at runtime control flows outward (use case → presenter), while the source-code dependency points inward (presenter → use case's output port). The same technique handles every "the inner circle needs to talk to the outer circle" situation.

**Good example:**

```java
// Use case sends output through a port it owns; the presenter (outer) implements it.
package usecases;
public interface OpenLoanOutputPort { void present(OpenLoanResponse response); }  // inner-owned port
public class OpenLoan {
    private final OpenLoanOutputPort output;
    public OpenLoan(OpenLoanOutputPort output) { this.output = output; }
    void handle(OpenLoanRequest req) { /* ... */ output.present(new OpenLoanResponse(/*...*/)); }
}
package adapters;
import usecases.OpenLoanOutputPort;                                 // outer depends inward — correct
public class LoanPresenter implements OpenLoanOutputPort {
    public void present(OpenLoanResponse r) { /* build view model */ }
}
```

**Bad example:**

```java
// Use case depends directly on the concrete presenter → control flow and source dependency
// both point outward, violating the Dependency Rule.
package usecases;
import adapters.LoanPresenter;                                      // inner → outer, forbidden
public class OpenLoan {
    private final LoanPresenter presenter = new LoanPresenter();
    void handle(OpenLoanRequest req) { presenter.showHtml("<html>..."); }  // also leaks HTML format inward
}
```

---

## Chapter 23 — Presenters and Humble Objects

### [23.1] Split hard-to-test behavior from testable behavior with the Humble Object pattern

Title: Separate the hard-to-test part (the view) from the easy-to-test part (the presenter/view model) at a boundary.
Description: The **Humble Object** pattern splits behaviors into two: the **Humble** part contains only the code that is hard to test (e.g. the GUI's actual rendering) and is kept as dumb as possible, and the **testable** part contains everything else. At the presentation boundary: the **Presenter** (testable) takes the use-case response and builds a **View Model** — a plain data structure with every formatting decision already made (strings, flags, colors as data). The **View** (humble) does nothing but move the View Model's fields onto the screen. Now nearly all presentation logic is unit-testable, and the untestable view is trivial. The pattern recurs at every boundary (database gateways, etc.).

**Good example:**

```java
// Presenter (testable) makes ALL decisions and emits a plain View Model.
record LoanViewModel(String formattedPrincipal, String dueDate, boolean overdueFlag) {}
class LoanPresenter implements OpenLoanOutputPort {
    private LoanViewModel vm;
    public void present(OpenLoanResponse r) {
        vm = new LoanViewModel(
            Money.ofCents(r.principalCents()).format(),     // formatting decided here, unit-testable
            r.dueDate().format(ISO_DATE),
            r.dueDate().isBefore(today()));
    }
    LoanViewModel viewModel() { return vm; }
}
// View (humble): no logic, just moves fields to widgets — almost nothing to test.
class LoanView {
    void render(LoanViewModel vm) {
        principalLabel.setText(vm.formattedPrincipal());
        dueLabel.setText(vm.dueDate());
        dueLabel.setColor(vm.overdueFlag() ? RED : BLACK);
    }
}
```

**Bad example:**

```java
// Formatting and decisions buried inside the untestable view → nothing can be unit-tested.
class LoanView {
    void render(OpenLoanResponse r) {
        principalLabel.setText("$" + (r.principalCents()/100.0));      // formatting logic in the GUI
        dueLabel.setText(r.dueDate().format(ISO_DATE));
        if (r.dueDate().isBefore(LocalDate.now())) dueLabel.setColor(RED);  // business-ish decision in the GUI
    }
}
// To test the "overdue turns red" rule you must drive the GUI — fragile and slow.
```

---

## Chapter 24 — Partial Boundaries

### [24.1] Build a partial boundary when a full boundary costs more than it's currently worth

Title: When a full architectural boundary is too expensive, use a cheaper partial boundary you can complete later.
Description: A full boundary (reciprocal interfaces, separate components, input/output data structures) is expensive to build and maintain. When you suspect you'll need a boundary but aren't sure, use a **partial boundary**: (1) build the components but keep them in a single deployable (skip the independent-deployment cost); or (2) use a *one-directional* boundary — a single interface anticipating future separation; or (3) use a **Facade** — no dependency inversion, just a class that hides the subsystem. Each leaves a seam you can promote to a full boundary if the need materializes, without paying full cost up front.

**Good example:**

```java
// One-directional partial boundary: the interface exists, future separation is cheap,
// but you haven't yet paid for reciprocal data structures or a separate deployable.
interface PaymentService { Receipt pay(Money amount); }     // the seam
class PaymentServiceImpl implements PaymentService { /* lives in the same jar for now */ }
// If a real axis of change appears, promote this to a full boundary with little rework.
```

**Bad example:**

```text
Two equally bad extremes:
 (a) Full boundary everywhere "just in case": reciprocal interfaces + separate jars for a
     subsystem with one implementation → permanent cost, no benefit.
 (b) No seam at all: PaymentServiceImpl's concrete methods called directly everywhere →
     when you DO need the boundary, there's no seam and it's a massive retrofit.
A partial boundary is the middle path; choosing an extreme is the mistake.
```

---

## Chapter 25 — Layers and Boundaries

### [25.1] Decide boundaries by watching axes of change — neither over- nor under-engineer

Title: Boundaries are costly; implement the ones the system needs, ignore the ones it doesn't, and monitor over time.
Description: Every boundary is expensive (more interfaces, more data structures, more indirection) and also expensive to *omit* if it turns out to be needed (a painful retrofit). The architect must weigh the cost against the benefit *continuously*, because the right answer changes as the system evolves — and the decision is hard precisely because it's about anticipating change. The discipline: watch where the system actually changes, draw boundaries there, leave partial or no boundaries elsewhere, and be willing to add or remove a boundary as new information arrives. Over-engineering (boundaries everywhere) and under-engineering (none) are both failures.

**Good example:**

```text
The team tracks change: the "notifications" subsystem is rewritten constantly (email→SMS→push),
so they invest in a full boundary there. The "audit log" never changes, so it stays a plain
in-process call with no boundary. Effort follows the actual axes of change.
```

**Bad example:**

```text
Either: a hexagonal boundary, port, and adapter around EVERY class (the codebase is 70%
plumbing) — or: one giant module with no internal boundaries at all, so the volatile
notification code is welded to stable business rules. Both ignore where change really happens.
```

---

## Chapter 26 — The Main Component

### [26.1] Make Main the dirtiest, lowest-level component — the ultimate plugin

Title: `Main` creates and wires the concrete objects, then hands control to the higher-level policy — and depends on everything.
Description: `Main` is the initial entry point — the lowest-level, *dirtiest* component, at the very outside of the architecture. Its job is to create all the factories, strategies, and other global concrete objects, wire them together, and then pass control inward to the high-level policy. `Main` is the one place allowed to know about everything concrete; it depends on the inner circles but nothing depends on it. Think of `Main` as a *plugin* to the application that sets up the initial conditions and configuration — you could have a different `Main` per deployment (dev/test/prod, or per country) without touching the core.

**Good example:**

```java
// Main: the dirty outer plugin — constructs concretes, injects them, hands off control.
public final class Main {
    public static void main(String[] args) {
        LoanGateway gateway     = new SqlLoanGateway(dataSource(args));   // pick concretes here
        OpenLoanOutputPort out  = new LoanPresenter();
        OpenLoan useCase        = new OpenLoan(gateway, out);             // wire the graph
        new WebServer(useCase).start();                                  // hand control to policy
    }
}
// The core (OpenLoan, gateways) never names a concrete class; only Main does.
```

**Bad example:**

```java
// Object construction and wiring smeared through the business code instead of localized in Main.
class OpenLoan {
    private final LoanGateway gateway = new SqlLoanGateway(new HikariDataSource(readEnv()));  // wiring inside policy
    private final LoanPresenter out   = new LoanPresenter();
}
// Configuration and concrete choices leak into the core; you can't vary deployment without
// editing business rules, and there's no single place that owns the object graph.
```

---

## Chapter 27 — Services: Great and Small

### [27.1] Don't assume a service boundary is an architectural boundary

Title: Services decouple at the deployment/operations level, but they are not automatically a clean architecture.
Description: Two seductive but false beliefs: that services are *strongly decoupled* (the **decoupling fallacy** — services that share data formats or behavior are still tightly coupled across the wire), and that services are *independently developable/deployable* (only partly true). A system of services can be just as coupled as a monolith if a single feature change forces edits across many services (a cross-cutting concern). Services are a *deployment* and *scaling* mechanism; the real architectural boundaries are still defined by the Dependency Rule and SOLID/component principles *inside* and *across* the services. Draw clean boundaries first; choose services as a delivery option second.

**Good example:**

```text
Inside each service: Entities + Use Cases + an internal plugin structure obeying the
Dependency Rule. A new "feature" is added by extending services via polymorphic plugins,
not by editing every service. The services are an operational concern layered on top of a
sound component architecture.
```

**Bad example:**

```text
"We're microservices, so we're decoupled." Yet adding one field to an order forces edits to
the order-service, the billing-service, the shipping-service, and the notification-service,
all redeployed together. The cross-cutting change reveals they were never architecturally
decoupled — just distributed. (The decoupling fallacy.)
```

---

## Chapter 28 — The Test Boundary

### [28.1] Treat tests as the outermost circle and design a testing API to avoid Fragile Tests

Title: Tests are part of the system and obey the Dependency Rule; insulate them from volatile details with a testing API.
Description: Tests are the outermost circle — they depend inward on the system, and nothing depends on them; they are the ultimate detail. The danger is the **Fragile Tests problem**: when tests are coupled to volatile structure (the exact GUI, the exact schema, the exact API surface), a small production change breaks thousands of tests, and developers start avoiding changes to keep tests green — the tests have inverted the dependency and made the system *rigid*. The fix is a **testing API**: a superset API created specifically for tests that hides the system's structure from the tests, so the structure can change without breaking them.

**Good example:**

```java
// Tests talk to a stable testing API, not to volatile UI/DB structure.
interface LoanTestApi {                       // designed for tests; insulates them from structure
    String openLoan(String customer, long cents);
    long balanceOf(String loanId);
}
@Test void interest_accrues_monthly() {
    String id = api.openLoan("alice", 100_00);   // no HTTP, no SQL, no widget paths
    api.advanceClock(Period.ofMonths(1));
    assertThat(api.balanceOf(id)).isGreaterThan(100_00);
}
// The web layer or schema can be rebuilt without touching this test.
```

**Bad example:**

```java
// Test wired to the volatile GUI and exact SQL → one layout/schema change breaks it.
@Test void interest_accrues() {
    driver.findElement(By.id("customer")).sendKeys("alice");   // coupled to GUI structure
    driver.findElement(By.cssSelector(".btn-primary")).click();
    ResultSet rs = stmt.executeQuery("SELECT balance FROM loans WHERE ...");  // coupled to schema
    assertEquals(10000, rs.getLong("balance"));
}
// Rename a CSS class or a column → thousands of such tests fail; the team stops refactoring.
```

---

## Chapter 29 — Clean Embedded Architecture

### [29.1] Separate firmware from software with a hardware abstraction layer

Title: Don't let hardware details leak into your code — put a HAL between software and firmware so the hardware is a detail.
Description: Embedded code rots when application logic is tangled with hardware access (registers, ports, timing) — it becomes *firmware* that can never move to new hardware. Even if it runs on a processor, code is "firmware" if it depends on hardware details. Insert a **Hardware Abstraction Layer (HAL)** that presents a hardware-independent interface to the software above and hides the device specifics below; the processor, the OS, and the hardware then become *details* on the far side of a boundary. The line of the OSI/HAL boundary means the same Dependency Rule applies: software depends on the HAL interface, the HAL implementation depends on the hardware.

**Good example:**

```c
/* HAL interface — hardware-independent; the app depends only on this. */
typedef struct { void (*set)(bool on); bool (*is_on)(void); } Led;
void blink(const Led* led, int times) {            /* pure software, portable */
    for (int i = 0; i < times; i++) { led->set(true); delay(); led->set(false); delay(); }
}
/* Driver (firmware) implements the HAL for a specific board; depends UP on the Led interface. */
static void gpio_set(bool on) { *GPIO_PORTB = on ? 0x01 : 0x00; }
```

**Bad example:**

```c
/* Application logic pokes hardware registers directly → it IS firmware, locked to this chip. */
void blink(int times) {
    for (int i = 0; i < times; i++) {
        *((volatile uint32_t*)0x40020000) = 0x01;  /* magic register address in the business logic */
        delay();
        *((volatile uint32_t*)0x40020000) = 0x00;
        delay();
    }
}
/* Port to a new board → rewrite the application. The hardware detail leaked into policy. */
```

---

## Part VI — Details

## Chapter 30 — The Database Is a Detail

### [30.1] Keep the data model central but treat the database technology as a detail behind a boundary

Title: The *data model* matters to the business; the *database* (RDBMS, schema, ORM) is a detail you keep outside the boundary.
Description: Distinguish the **data model** (the structure and relationships your business rules need — important) from the **database** (the particular technology that stores it: Oracle, Postgres, Mongo, a flat file — a detail). The database is just a utility for moving bytes to and from disk; your business rules should not know it exists. Access it through gateway interfaces the use cases own, return plain data structures (not ORM rows or `ResultSet`s) inward, and you keep the freedom to change or defer the database choice. Don't let the database's tabular shape or query language dictate your architecture.

**Good example:**

```java
// Business rules depend on a gateway abstraction; the DB technology is swappable/deferrable.
interface CustomerGateway { Optional<Customer> find(CustomerId id); void save(Customer c); }
// Implementations are details: InMemoryCustomerGateway (tests), PostgresCustomerGateway (prod),
// MongoCustomerGateway (later) — none of which the use cases or entities ever name.
```

**Bad example:**

```java
// Business logic written directly against the ORM/SQL → the database IS the architecture.
class CustomerService {
    Customer find(long id) {
        return entityManager.find(CustomerEntity.class, id).toDomain();  // bound to JPA
    }
    List<Customer> overdue() {
        return jdbc.query("SELECT * FROM customers WHERE balance < 0 ...", mapper);  // bound to SQL/schema
    }
}
// Changing or deferring the database is impossible; tests need a real DB; the schema drives the design.
```

---

## Chapter 31 — The Web Is a Detail

### [31.1] Treat the web/UI as an I/O detail behind the use case boundary

Title: The web is just today's I/O channel — keep business rules ignorant of it, behind a use-case boundary.
Description: The web (like the GUI, the console, or any delivery mechanism) is a detail — an I/O device. The pendulum of computing has swung between central and distributed UIs for decades; whatever is fashionable now will change. Abstract the delivery mechanism away so the business rules don't know whether input arrives via HTTP, a rich client, or a CLI. The controller converts the web request into a plain use-case request model; the use case returns a response model; the presenter formats it for whatever delivery mechanism is in play. The use case is reusable across all of them.

**Good example:**

```java
// Thin controller adapts HTTP to the use case; the use case knows nothing about the web.
@RestController
class LoanController {
    private final OpenLoan openLoan;                     // pure use case
    LoanController(OpenLoan openLoan) { this.openLoan = openLoan; }
    @PostMapping("/loans")
    ResponseEntity<?> open(@RequestBody OpenLoanForm form) {
        var request = new OpenLoanRequest(form.customerId(), form.cents(), form.term());  // web → plain model
        openLoan.handle(request);                        // use case is delivery-agnostic
        return ResponseEntity.accepted().build();
    }
}
```

**Bad example:**

```java
// Business rules embedded in the web handler → the web is the architecture.
@PostMapping("/loans")
ResponseEntity<?> open(@RequestBody Map<String,Object> body) {
    long cents = ((Number) body.get("cents")).longValue();
    if (cents <= 0) return badRequest().body("bad amount");   // business rule trapped in the controller
    jdbc.update("INSERT INTO loans ...");                     // and the DB detail too
    return ok("<html>Loan opened</html>");                    // and the view format
}
// None of this logic survives a switch from web to CLI or rich client; nothing is reusable or testable.
```

---

## Chapter 32 — Frameworks Are Details

### [32.1] Keep frameworks at arm's length — don't let them into your core

Title: Use frameworks, but don't marry them; depend on them from the outside, never from your business rules.
Description: A framework is a tool, not an architecture, and the framework author's interests are not yours — frameworks evolve, break compatibility, and demand you couple to them (base classes to extend, annotations to scatter, lifecycles to obey). Treat a framework as a detail in the outermost circle: let your `Main` and adapters use it, but keep your Entities and Use Cases free of `import framework.*`. Where you must integrate, do it behind an interface you own (a proxy/adapter), so a framework change — or a future framework swap — touches the outer ring only. The asymmetry is real: you risk everything by coupling to the framework; the framework risks nothing by being coupled to.

**Good example:**

```java
// Core is framework-free; the framework appears only in the outer adapter ring.
package usecases;                                  // NO framework imports here
public class OpenLoan { /* plain Java, depends only on interfaces it owns */ }

package adapters.web;                              // framework lives out here
import org.springframework.web.bind.annotation.*;  // Spring is a detail, confined to adapters
@RestController class LoanController { /* delegates to OpenLoan */ }
```

**Bad example:**

```java
// The framework has infiltrated the business rules: base class, annotations, lifecycle.
package usecases;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
@Service
public class OpenLoan extends SpringBeanBase {           // married to Spring's type hierarchy
    @Autowired private JpaLoanRepo repo;                 // and to JPA
    @Transactional public void handle(...) { /* business rule entangled with framework lifecycle */ }
}
// A Spring/JPA upgrade or swap now reaches straight into the enterprise rules.
```

---

## Chapter 33 — Case Study: Video Sales

### [33.1] Partition first by actor/use case, then by layer

Title: Apply SRP/CCP to find the actors and use cases, then split each into the architectural layers within a boundary.
Description: The worked case study (a video-sales site) shows the method in practice. First identify the **actors** (viewer, purchaser, author, administrator) and the **use cases** each drives — this is SRP/CCP at work, partitioning by reason-to-change. Then, within that partition, split each use case into the components/layers (view, presenter, interactor, controller, gateway) connected by the Dependency Rule. The result can be organized either by component (deployable units) or by layer, and you can defer the by-component split (partial boundaries) until you actually need independent deployment. The takeaway: actors and use cases drive the top-level partition; layers and the Dependency Rule structure the inside.

**Good example:**

```text
By actor/use case (top-level partition, SRP/CCP):
   Viewer       → ViewCatalog, WatchVideo
   Purchaser    → PurchaseVideo
   Author       → AddVideo, EditVideo
   Administrator→ ManageUsers
Within each use case (Dependency Rule):
   Controller → Interactor → Entities ;  Interactor → OutputPort ◀ Presenter ◀ View
Gateways are interfaces the interactors own; the DB/web are plugins.
```

**Bad example:**

```text
Top-level partition by technology only:
   controllers/ , services/ , repositories/ , entities/
Every actor's logic is smeared across all four folders. A change for the Author actor and a
change for the Purchaser actor both churn the same fat `services/` and `repositories/`,
recreating the SRP violation at the architecture scale.
```

---

## Chapter 34 — The Missing Chapter

### [34.1] Choose a package structure (layer / feature / ports-and-adapters / component) and watch for frameworks breaking encapsulation

Title: How you organize packages matters; prefer structures that enforce the boundary, and beware public-access leaks.
Description: Simon Brown's chapter surveys four package strategies. **Package by layer** (web/service/data) — the traditional horizontal slice; simple but groups unrelated features and exposes layers. **Package by feature** — vertical slices by domain concept; the architecture screams the domain. **Ports and adapters** — a domain/core package with no outward dependencies, surrounded by adapter packages; enforces the Dependency Rule. **Package by component** — coarse-grained components with a public interface and hidden internals. Two cross-cutting lessons: (1) *organization is not encapsulation* — package-by-layer leaves classes `public` so the boundary is unenforced; use the language's access modifiers (package-private) to actually hide internals; (2) frameworks and ORMs often *force* classes to be public (for injection, mapping, reflection), quietly breaking your encapsulation — resist or contain that. The devil is in the implementation details.

**Good example:**

```java
// Package by component with REAL encapsulation: only the interface is public; impl is hidden.
package com.shop.orders;                       // a component
public interface Orders { OrderId place(NewOrder order); }   // the ONLY public type
class OrdersImpl implements Orders { /* package-private — invisible outside the component */ }
class OrderRepository { /* package-private — internals truly hidden */ }
// Other components can only reach the Orders interface; the boundary is compiler-enforced.
```

**Bad example:**

```java
// "Package by layer" with everything public → organization without encapsulation.
package com.shop.web;        public class OrderController { /* ... */ }
package com.shop.service;    public class OrderService { /* ... */ }     // public: any layer can call it
package com.shop.data;       public class OrderRepository { /* ... */ }  // public: the web can skip the
                                                                          // service and hit the DB directly
// Nothing stops a dependency from jumping layers; the boundary exists only in the diagram.
// (And the ORM demanded these be public/annotated, so the framework broke encapsulation too.)
```

---

## Part VII — Appendix

## Appendix A — Architecture Archaeology

### [A.1] Recognize that the rules of good architecture are timeless and language-independent

Title: The same principles — boundaries, dependency direction, decoupling I/O from policy — recur across every era and technology.
Description: Uncle Bob's tour through decades of real projects (from punch-card accounting systems and tape-based pipelines to embedded systems and the web) shows that the rules of good architecture do not depend on the language, the framework, or the hardware of the day. The same lessons appear again and again: separate the business rules from the I/O and devices, point dependencies toward the stable policy, draw boundaries so details can change without disturbing the core. The technologies churn; the principles endure. Treat new frameworks and platforms as the latest details to be held at arm's length, not as new architectures.

**Good example:**

```text
1970s tape system, 1990s desktop app, 2010s microservice, 2020s serverless function:
in every case the winning move was the same — isolate business rules from the I/O/device
behind a boundary, point dependencies toward the stable policy. The principle outlived the tech.
```

**Bad example:**

```text
"This time it's different — <new framework/platform> is our architecture."
Every generation re-learns the hard way that welding business rules to the platform of the
day produces the same rigid, unmaintainable system, just with newer keywords.
```
