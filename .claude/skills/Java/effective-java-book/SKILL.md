---
name: effective-java-book
description: Use when you need to review, refactor, or write idiomatic Java guided by the 90 items of Effective Java (3rd Edition) by Joshua Bloch — covering object creation (static factories, builders, singletons), methods common to all objects (equals/hashCode/toString/clone/Comparable), classes and interfaces (immutability, composition over inheritance), generics (PECS wildcards, typesafe heterogeneous containers), enums and annotations (EnumMap/EnumSet, @Override), lambdas and streams, method design (defensive copies, validation, optionals), general programming, exceptions, concurrency (synchronization, executors, lazy init), and serialization (proxy pattern, defensive readObject). This should trigger for requests such as Review this Java code against Effective Java; Apply Effective Java best practices; Make this class immutable / thread-safe / serializable correctly; Refactor to a builder; Fix equals/hashCode. Distilled from Effective Java, Third Edition.
license: Apache-2.0
metadata:
  author: Joshua Bloch (source); skill synthesized from Effective Java, 3rd Edition
  version: 1.0.0
---
# Effective Java (3rd Edition)

Review, refactor, and write idiomatic Java by applying the 90 items of *Effective Java, Third Edition* by Joshua Bloch.

**What is covered in this Skill?**

- **Creating and destroying objects** (Items 1–9): static factories, builders, enum singletons, noninstantiable utility classes, dependency injection, avoiding unnecessary objects, eliminating obsolete references, avoiding finalizers/cleaners, try-with-resources
- **Methods common to all objects** (Items 10–14): the `equals` contract, the `hashCode` recipe (`31 * result + c`), informative `toString`, copy constructors over `clone`, `Comparable`
- **Classes and interfaces** (Items 15–25): minimize accessibility, accessor methods, minimize mutability, composition + forwarding over inheritance, design-for-inheritance or prohibit it, interfaces over abstract classes, class hierarchies over tagged classes, static member classes
- **Generics** (Items 26–33): no raw types, eliminate unchecked warnings, lists over arrays, generic types/methods, PECS bounded wildcards, `@SafeVarargs`, typesafe heterogeneous containers
- **Enums and annotations** (Items 34–41): enums over int constants, instance fields over ordinals, `EnumSet`/`EnumMap`, extensible enums via interfaces, annotations over naming patterns, `@Override`, marker interfaces
- **Lambdas and streams** (Items 42–48): lambdas over anonymous classes, method references, standard functional interfaces, judicious streams, side-effect-free functions, `Collection` return types, cautious parallelism
- **Methods** (Items 49–56): validate parameters, defensive copies, careful signatures, judicious overloading/varargs, return empty (not null), `Optional`, doc comments
- **General programming** (Items 57–68): minimize variable scope, for-each, know the libraries, `BigDecimal` for money, primitives over boxed, avoid stringly-typed code, `StringBuilder`, refer to objects by interfaces, avoid reflection/native code, optimize judiciously, naming conventions
- **Exceptions** (Items 69–77): exceptions only for exceptional conditions, checked vs runtime, avoid unnecessary checked exceptions, standard exceptions, exception translation/chaining, document exceptions, failure-capture detail messages, failure atomicity, don't ignore exceptions
- **Concurrency** (Items 78–84): synchronize shared mutable data, avoid excessive synchronization (open calls), executors over threads, concurrency utilities over wait/notify, document thread safety, lazy-init idioms, don't depend on the scheduler
- **Serialization** (Items 85–90): prefer alternatives (JSON/Protobuf), implement `Serializable` with caution, custom serialized forms, defensive `readObject`, enums over `readResolve`, serialization proxy pattern

## Constraints

Before applying refactorings derived from these items, ensure the project compiles and tests pass. Many items change object construction, mutability, generics, exception contracts, or thread-safety and can alter behavior.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying any change.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; report failures honestly and do not claim success until the build and tests pass.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **PRESERVE BEHAVIOR**: Immutability, defensive copies, exception translation, and generics changes must preserve observable behavior unless the user explicitly asks to change a contract.
- **SECURITY**: Never recommend deserializing untrusted data with Java serialization (Item 85) — flag it and propose JSON/Protobuf or object-input filtering.
- **INCREMENTAL**: Apply one item at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full 90 items with good/bad examples and rationale.

## When to use this skill

- Review this Java code against Effective Java best practices
- Apply Effective Java to improve a class or method
- Make this class immutable / thread-safe / correctly serializable
- Refactor to a builder; favor composition over inheritance
- Fix `equals`/`hashCode`/`compareTo` or add a good `toString`
- Tighten generics with PECS wildcards or a typesafe heterogeneous container
- Replace int constants / bit fields with enums, `EnumSet`, `EnumMap`

## Workflow

1. **Validate the project before recommendations**

Run `./mvnw compile` or `mvn compile` and stop if compilation fails.

2. **Read the reference and analyze the code**

Read `references/effective-java-book.md`, then inspect the target code and map each smell to a specific item by number and title.

3. **Categorize and prioritize findings**

Group by impact (CRITICAL correctness/security, MAINTAINABILITY, PERFORMANCE, READABILITY) and by chapter. Order remediation: quick wins (defensive copies, `@Override`, standard exceptions, try-with-resources) before structural refactorings (builder, composition, serialization proxy).

4. **Apply improvements incrementally and verify**

Apply one item at a time, preserving behavior, and re-run `./mvnw clean verify` after each substantive change. Cite each applied item by number and title.

## Reference

For the full 90 items with rationale and Good/Bad examples, see [references/effective-java-book.md](references/effective-java-book.md).
