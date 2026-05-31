---
name: head-first-design-pattern-book
description: Use when you need to recognize, apply, review, or refactor toward Gang-of-Four design patterns in object-oriented code guided by Head First Design Patterns (Freeman, Robson, Sierra, Bates) and the refactoring.guru catalog — covering the foundational OO design principles (encapsulate what varies, program to an interface not an implementation, favor composition over inheritance, loose coupling, Open-Closed, Dependency Inversion, Least Knowledge/Demeter, Hollywood Principle, Single Responsibility); the patterns Strategy, Observer, Decorator, Factory Method, Abstract Factory, Singleton, Command, Adapter, Facade, Template Method, Iterator, Composite, State, Proxy, Compound patterns/MVC, plus Bridge, Builder, Chain of Responsibility, Flyweight, Interpreter, Mediator, Memento, Prototype, and Visitor — including each pattern's applicability ("use it when"), implementation steps, pros/cons trade-offs, and relations to other patterns; AND the refactoring side: what refactoring and clean code are, technical debt, when/how to refactor, the code smells (Long Method, Large Class, Primitive Obsession, Long Parameter List, Data Clumps, Switch Statements, Temporary Field, Refused Bequest, Divergent Change, Shotgun Surgery, Parallel Inheritance Hierarchies, Comments, Duplicate Code, Lazy Class, Data Class, Dead Code, Speculative Generality, Feature Envy, Inappropriate Intimacy, Message Chains, Middle Man), and the refactoring techniques (Composing Methods, Moving Features Between Objects, Organizing Data, Simplifying Conditional Expressions, Simplifying Method Calls, Dealing with Generalization). This should trigger for requests such as Which design pattern fits this problem; When should I use the X pattern and what are its trade-offs; What's the difference between Strategy and State (or Adapter vs Decorator vs Proxy); Refactor this subclass explosion with the Decorator pattern; Replace these if/else type checks with a pattern; Decouple this class from concrete dependencies; Remove this sprawling state conditional with the State pattern; Encapsulate object creation with a factory; Make this request undoable with the Command pattern; Add behavior to an object without subclassing; Apply MVC; Identify the code smell here and how to fix it; Refactor this long method / large class / long parameter list; or Identify the pattern/anti-pattern in this code. Distilled from Head First Design Patterns (O'Reilly) and refactoring.guru.
license: Apache-2.0
metadata:
  author: Eric Freeman, Elisabeth Robson, Kathy Sierra, Bert Bates (Head First Design Patterns, O'Reilly); Alexander Shvets / refactoring.guru (pattern catalog and refactoring/code-smell catalog). Skill synthesized from both sources.
  version: 1.1.0
---
# Head First Design Patterns — OO Design Principles and Gang-of-Four Patterns

Recognize, apply, review, and refactor toward proven object-oriented design patterns by following the practices of *Head First Design Patterns* by Eric Freeman, Elisabeth Robson, Kathy Sierra, and Bert Bates.

**What is covered in this Skill?**

- **OO design principles** (woven through every chapter): *Encapsulate what varies*; *Program to an interface, not an implementation*; *Favor composition over inheritance*; *Strive for loosely coupled designs between objects that interact*; the *Open-Closed Principle* (open for extension, closed for modification); the *Dependency Inversion Principle* (depend on abstractions, not concrete classes); the *Principle of Least Knowledge* (talk only to your immediate friends); the *Hollywood Principle* (don't call us, we'll call you); and the *Single Responsibility Principle* (a class should have only one reason to change)
- **Strategy** (Ch 1): encapsulate a family of interchangeable algorithms behind an interface and delegate to them; SimUDuck `FlyBehavior`/`QuackBehavior`, set behavior at runtime
- **Observer** (Ch 2): one-to-many dependency; `Subject`/`Observer` interfaces, register/remove/notify, push vs pull, the JDK's listener APIs
- **Decorator** (Ch 3): attach responsibilities dynamically by wrapping; the Starbuzz `Beverage`/`CondimentDecorator` hierarchy; how `java.io` uses it
- **Factory** (Ch 4): the Simple Factory idiom, **Factory Method** (subclasses decide the concrete class), and **Abstract Factory** (families of related products); the Pizza Store
- **Singleton** (Ch 5): one instance + a global access point; lazy vs eager vs synchronized vs double-checked `volatile` vs enum
- **Command** (Ch 6): encapsulate a request as an object; invoker/receiver decoupling, undo, macro commands, queuing, logging, Null Object
- **Adapter & Facade** (Ch 7): convert an interface to the one a client expects (object vs class adapter); provide a simplified unified subsystem interface; Least Knowledge
- **Template Method** (Ch 8): define an algorithm skeleton in a final method, defer steps to subclasses; hooks; the Hollywood Principle; `Arrays.sort`/`Comparable`
- **Iterator & Composite** (Ch 9): traverse an aggregate without exposing its representation (`java.util.Iterator`/`Iterable`); represent part-whole tree hierarchies and treat leaves and nodes uniformly; Single Responsibility
- **State** (Ch 10): localize per-state behavior in `State` objects and delegate; replace sprawling conditionals; State vs Strategy
- **Proxy** (Ch 11): a surrogate that controls access — Remote, Virtual, Protection, and dynamic proxies (`java.lang.reflect.Proxy`)
- **Compound patterns & MVC** (Ch 12): combine patterns (the Duck Simulator); Model-View-Controller as Observer + Strategy + Composite
- **Patterns in the real world** (Ch 13): the precise definition of a pattern, the Creational/Structural/Behavioral categories, anti-patterns, avoiding "pattern fever", and building a shared vocabulary
- **Leftover patterns** (Appendix): Bridge, Builder, Chain of Responsibility, Flyweight, Interpreter, Mediator, Memento, Prototype, Visitor
- **refactoring.guru pattern catalog** (supplement): the decision-making angle for all 22 GoF patterns — **Intent**, **Applicability** ("use it when…"), condensed **implementation steps**, **Pros/Cons** trade-offs, **Relations with other patterns** (to pick between look-alikes and find combinations), plus pattern concepts and classification (Creational/Structural/Behavioral) and the standard criticisms of patterns
- **refactoring.guru refactoring catalog** (supplement, *not in Head First*): what refactoring and clean code are, technical debt, when/how to refactor safely; the **code smells** in 5 groups (Bloaters, Object-Orientation Abusers, Change Preventers, Dispensables, Couplers); the **refactoring techniques** in 6 groups (Composing Methods, Moving Features Between Objects, Organizing Data, Simplifying Conditional Expressions, Simplifying Method Calls, Dealing with Generalization); and a **smell → technique → pattern** map

## Constraints

Before applying a pattern-driven refactoring, ensure the project compiles and its tests pass. Introducing a pattern changes structure, indirection, object lifecycles, and sometimes threading, and can alter behavior if done carelessly.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying any change.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; report failures honestly and do not claim success until the build and tests pass.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **DON'T FORCE PATTERNS**: A pattern is a solution to a *recurring problem in a context*. If the problem is not present, the simplest design wins — applying a pattern speculatively is the "pattern fever" anti-pattern. Justify each pattern by the design principle it serves and the change it makes easy.
- **PRESERVE BEHAVIOR**: Refactoring toward a pattern must preserve observable behavior unless the user explicitly asks to change a contract. Watch Singleton threading semantics, Decorator/Proxy delegation, Observer notification order, and State transition logic.
- **CONCURRENCY SAFETY**: Singleton initialization, shared Observers, and mutable Flyweight intrinsic state must be made thread-safe deliberately; never assume single-threaded access.
- **INCREMENTAL**: Introduce one pattern at a time and re-validate; never batch several structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full set of practices with Good/Bad examples and the design principle each one applies.

## When to use this skill

- Decide *which* pattern (if any) fits a problem, and name the design principle it serves
- Refactor a **subclass explosion** (every feature combination is a class) toward Decorator, Strategy, or composition
- Replace **`if`/`else` or `switch` on a type/state field** with Strategy, State, or polymorphism
- **Decouple** a class from concrete collaborators (Factory Method / Abstract Factory, Dependency Inversion, Observer, Adapter)
- Add behavior to an object **without modifying it** (Open-Closed via Decorator/Proxy)
- Make a request **undoable, queueable, or loggable** (Command); make an object **uniquely instantiated** (Singleton)
- **Simplify a complex subsystem** behind one entry point (Facade); **adapt** a third-party interface (Adapter)
- Traverse a collection without exposing it (Iterator); model **part-whole trees** (Composite)
- Apply **MVC** or combine multiple patterns (Compound patterns)
- Identify a **pattern or anti-pattern** already present in unfamiliar code
- Decide **when** a pattern is worth its cost and **which look-alike** to use (Strategy vs State vs Bridge; Adapter vs Decorator vs Proxy; Factory Method vs Abstract Factory) using applicability, pros/cons, and pattern relations
- Spot a **code smell** (long method, large class, primitive obsession, switch statements, feature envy, message chains, …) and pick the **refactoring technique** — and sometimes the pattern — that removes it
- Refactor **safely in small, behavior-preserving steps** and pay down technical debt

## Workflow

1. **Validate the project before recommendations**

   Run `./mvnw compile` or `mvn compile` and stop if compilation fails.

2. **Read the reference(s) and analyze the design**

   Read `references/head-first-design-pattern-book.md` for how patterns work and the design principles. For "should I / which one / what does it cost" questions, also read `references/refactoring-guru-design-patterns.md` (applicability, pros/cons, relations). For smell-driven cleanup, read `references/refactoring-guru-refactoring.md` (code smells + techniques). Then inspect the target code and map each design smell to a specific principle, pattern, or refactoring (e.g. "3.2 Don't explode subclasses for every feature combination", or "Switch Statements → Replace Conditional with Polymorphism → Strategy/State").

3. **Name the principle, then choose the pattern**

   Identify what varies, where coupling hurts, and which axis of change the design must absorb. Choose the pattern that makes that change easy — or conclude that no pattern is warranted. Categorize the intent (Creational / Structural / Behavioral).

4. **Apply incrementally and verify**

   Introduce one pattern at a time, preserving behavior, and re-run `./mvnw clean verify` after each substantive change. Cite the applied practice by chapter section and title, and state the design principle it serves.

## Reference

This skill ships three reference files — read the one(s) relevant to the request:

1. **[references/head-first-design-pattern-book.md](references/head-first-design-pattern-book.md)** — the core. The full set of practices across the 14 chapters (Strategy through Compound Patterns, plus the leftover-patterns appendix) with rationale, the design principle each one applies, and Good/Bad Java examples. Use this to learn/teach *how each pattern works* and to refactor toward it.
2. **[references/refactoring-guru-design-patterns.md](references/refactoring-guru-design-patterns.md)** — supplement (refactoring.guru). For each of the 22 GoF patterns: Intent, Applicability ("use it when"), implementation steps, Pros/Cons, and Relations with other patterns, plus pattern concepts/classification and a "which pattern when" selector. Use this to *decide whether/which* pattern to apply and to choose between look-alikes.
3. **[references/refactoring-guru-refactoring.md](references/refactoring-guru-refactoring.md)** — supplement (refactoring.guru). Refactoring & clean-code concepts, technical debt, when/how to refactor, the code-smells catalog (5 groups), the refactoring-techniques catalog (6 groups), and a smell → technique → pattern map. Use this to *recognize a smell and pick the fix*.

When applying a recommendation, cite the source: a Head First practice by chapter section and title and the design principle it serves; a refactoring.guru pattern by its Applicability/Relations; a code smell by name and the technique (and pattern, if any) that removes it.
