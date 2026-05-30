---
name: java-8-in-action-book
description: Use when you need to review, refactor, or write idiomatic functional-style Java guided by Java 8 in Action (Urma, Fusco, Mycroft) — covering behavior parameterization and the Strategy pattern, lambda expressions and method/constructor references, functional interfaces (Predicate/Function/Consumer/Supplier) and the execute-around pattern, the Streams API (filter/map/flatMap/reduce, slicing, primitive streams, building streams), collectors (groupingBy/partitioningBy/joining/summarizing and custom collectors), parallel streams, the fork/join framework and Spliterator, refactoring OO design patterns with lambdas, default methods and the diamond resolution rules, Optional instead of null, CompletableFuture for composable async, the immutable java.time Date/Time API, and functional-programming techniques (pure functions, immutability, currying, persistent data structures, lazy evaluation). This should trigger for requests such as Modernize this pre-Java-8 code; Replace anonymous classes with lambdas; Convert this loop to a stream; Use Optional instead of null; Make this async with CompletableFuture; Migrate Date/Calendar to java.time; Refactor to behavior parameterization. Distilled from Java 8 in Action (Manning, 2015).
license: Apache-2.0
metadata:
  author: Raoul-Gabriel Urma, Mario Fusco, Alan Mycroft (source); skill synthesized from Java 8 in Action (Manning, 2015)
  version: 1.0.0
---
# Java 8 in Action — Lambdas, Streams, and Functional-Style Programming

Review, refactor, and write idiomatic, functional-style Java by applying the practices of *Java 8 in Action* by Raoul-Gabriel Urma, Mario Fusco, and Alan Mycroft.

**What is covered in this Skill?**

- **Behavior parameterization** (Ch 2): pass code as a value, model selection criteria with a predicate interface (Strategy pattern), avoid boolean-flag parameters, abstract over the element type with generics, parameterize JDK APIs (`Comparator`, `Runnable`, `EventHandler`)
- **Lambda expressions** (Ch 3): lambdas over anonymous classes, expression vs. block bodies, target typing, `@FunctionalInterface`, the execute-around pattern, the standard `java.util.function` interfaces and their primitive specializations, effectively-final capture, method references and constructor references, composing with `comparing`/`andThen`/`and`/`or`
- **Streams** (Ch 4–5): declarative pipelines over external iteration, internal iteration, traverse-once semantics, lazy intermediate vs. eager terminal operations, short-circuiting and loop fusion; `filter`/`distinct`/`limit`/`skip`/`map`/`flatMap`, `anyMatch`/`findAny`, `reduce`, primitive streams to avoid boxing, building streams from values/arrays/files/`iterate`/`generate`
- **Collectors** (Ch 6): predefined collectors over manual loops; `counting`/`maxBy`/`summingInt`/`summarizingInt`/`joining`, multilevel and downstream `groupingBy`, `collectingAndThen`, `partitioningBy`, and custom `Collector` implementations
- **Parallelism** (Ch 7): measure before going parallel, no shared mutable state, splittable primitive sources, the fork/join framework via `RecursiveTask`, work stealing, custom `Spliterator`
- **Refactoring, testing, debugging** (Ch 8): anonymous classes → lambdas → method references; loops → streams; lambda-based Strategy/Template-Method/Observer/Chain/Factory; testing lambdas via the enclosing method; debugging with `peek`
- **Default methods** (Ch 9): non-breaking API evolution, optional methods, multiple inheritance of behavior, the three resolution rules and `X.super.method()`
- **Optional** (Ch 10): model absence with `Optional<T>`, `empty`/`of`/`ofNullable`, `map`/`flatMap`/`filter`/`ifPresent`, `orElse`/`orElseGet`/`orElseThrow`, combining optionals, wrapping legacy APIs, and what *not* to do (fields, parameters, primitive optionals)
- **CompletableFuture** (Ch 11): composable async over plain `Future`, `supplyAsync`/`runAsync`, exception propagation, non-blocking pipelines, custom executors for I/O, `thenApply`/`thenCompose`/`thenCombine`, `allOf`/`anyOf`
- **Date and Time API** (Ch 12): immutable `LocalDate`/`LocalTime`/`Instant`/`Duration`/`Period`, `of`/`parse`, `TemporalAdjusters`, thread-safe `DateTimeFormatter`, `ZoneId`/`ZonedDateTime`
- **Functional thinking & techniques** (Ch 13–16, App B): pure functions, immutability, declarative style, first-class & higher-order functions, currying, persistent data structures, lazy lists and lazy evaluation, lambda-based pattern matching, and Java 8 library updates (`getOrDefault`, `computeIfAbsent`, `merge`, `removeIf`/`replaceAll`, `Math.*Exact`)

## Constraints

Before applying refactorings derived from these practices, ensure the project compiles and tests pass. Many practices change iteration style, laziness, threading, nullness contracts, or date/time handling and can alter behavior.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying any change.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; report failures honestly and do not claim success until the build and tests pass.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **TARGET VERSION**: These practices assume Java 8+. Note where a feature is newer (e.g. `takeWhile`/`dropWhile` are Java 9) and stay within the project's language level.
- **PRESERVE BEHAVIOR**: Stream laziness and short-circuiting, `Optional` contracts, and immutable `java.time` semantics must preserve observable behavior unless the user explicitly asks to change a contract.
- **CONCURRENCY SAFETY**: Never introduce shared mutable state into parallel streams or `forEach`; size and shut down `CompletableFuture` executors correctly; do not assume parallel is faster — measure.
- **INCREMENTAL**: Apply one practice at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full set of practices with Good/Bad examples and rationale.

## When to use this skill

- Modernize pre-Java-8 code (anonymous classes, external iteration, `null` returns, blocking `Future`s, `Date`/`Calendar`)
- Replace anonymous classes with lambdas or method references; refactor an OO design pattern with lambdas
- Convert imperative loops into a Stream pipeline; choose the right collector or partition/group operation
- Introduce `Optional` to remove nested null checks; design an API that signals absence
- Make blocking calls asynchronous and composable with `CompletableFuture`
- Migrate `Date`/`Calendar`/`SimpleDateFormat` to the immutable, thread-safe `java.time` API
- Parallelize a computation safely (parallel streams, fork/join, custom `Spliterator`)
- Adopt a functional, side-effect-free style (pure functions, immutability, currying, lazy evaluation)

## Workflow

1. **Validate the project before recommendations**

   Run `./mvnw compile` or `mvn compile` and stop if compilation fails.

2. **Read the reference and analyze the code**

   Read `references/java-8-in-action-book.md`, then inspect the target code and map each smell to a specific practice by chapter section and title (e.g. "5.4 Flatten nested streams with flatMap").

3. **Categorize and prioritize findings**

   Group by impact (CORRECTNESS/CONCURRENCY, MAINTAINABILITY, PERFORMANCE, READABILITY) and by chapter. Order remediation: quick wins (lambdas, method references, `Optional` returns, `getOrDefault`/`computeIfAbsent`) before larger refactorings (stream pipelines, custom collectors, `CompletableFuture` orchestration, fork/join, `Spliterator`).

4. **Apply improvements incrementally and verify**

   Apply one practice at a time, preserving behavior, and re-run `./mvnw clean verify` after each substantive change. For performance work, measure before and after rather than assuming. Cite each applied practice by chapter section and title.

## Reference

For the full set of practices (116 across 16 chapters plus Appendix B) with rationale and Good/Bad examples, see [references/java-8-in-action-book.md](references/java-8-in-action-book.md).
