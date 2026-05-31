---
name: modern-java-in-action-book
description: Use when you need to review, refactor, or write idiomatic Java (8 through 11) guided by Modern Java in Action, 2nd Edition (Urma, Fusco, Mycroft) — covering behavior parameterization and the Strategy pattern, lambda expressions and method/constructor references, functional interfaces and the execute-around pattern, the Streams API (filter/map/flatMap/reduce, slicing with takeWhile/dropWhile, primitive streams, building streams), collectors (groupingBy/partitioningBy/joining/summarizing and custom collectors), parallel streams, the fork/join framework and Spliterator, the Java 9 Collection API enhancements (List.of/Set.of/Map.of factories, removeIf/replaceAll, getOrDefault/computeIfAbsent/merge, ConcurrentHashMap bulk ops), refactoring OO design patterns with lambdas, domain-specific languages with lambdas (method chaining, nested functions, lambda sequencing), Optional instead of null (with Optional::stream), the immutable java.time Date/Time API, default methods and the diamond resolution rules, the Java 9 Module System (module-info.java, requires/exports/opens/provides), CompletableFuture for composable async, reactive programming with the Flow API and RxJava, functional-programming techniques (pure functions, immutability, currying, persistent data structures, lazy evaluation, pattern matching), and Java 10 local variable type inference (var). This should trigger for requests such as Modernize this pre-Java-8 code; Replace anonymous classes with lambdas; Convert this loop to a stream; Use the Java 9 collection factories; Build a DSL with lambdas; Use Optional instead of null; Modularize this app with module-info.java; Make this async with CompletableFuture; Add reactive backpressure with the Flow API; Migrate Date/Calendar to java.time. Distilled from Modern Java in Action, Second Edition (Manning, 2019).
license: Apache-2.0
metadata:
  author: Raoul-Gabriel Urma, Mario Fusco, Alan Mycroft (source); skill synthesized from Modern Java in Action, 2nd Edition (Manning, 2019)
  version: 1.0.0
---
# Modern Java in Action — Lambdas, Streams, Functional and Reactive Programming

Review, refactor, and write idiomatic Java (versions 8–11) by applying the practices of *Modern Java in Action, Second Edition* by Raoul-Gabriel Urma, Mario Fusco, and Alan Mycroft. This is the successor to *Java 8 in Action*, extended with Java 9, 10, and 11 (collection factories, the Module System, the reactive Flow API, `var`, and more).

**What is covered in this Skill?**

- **Behavior parameterization** (Ch 2): pass code as a value, model selection criteria with a predicate interface (Strategy pattern), avoid boolean-flag parameters, abstract over the element type with generics, parameterize JDK APIs (`Comparator`, `Runnable`, `Callable`, event handlers)
- **Lambda expressions** (Ch 3): lambdas over anonymous classes, target typing and the function descriptor, `@FunctionalInterface`, the execute-around pattern, the `java.util.function` interfaces and their primitive specializations, effectively-final capture, method/constructor references, composing with `comparing`/`andThen`/`and`/`or`
- **Streams** (Ch 4–5): declarative pipelines over external iteration, traverse-once semantics, lazy intermediate vs. eager terminal operations, short-circuiting and loop fusion; `filter`/`distinct`/`takeWhile`/`dropWhile` (Java 9)/`limit`/`skip`/`map`/`flatMap`, matching/finding, `reduce`, primitive streams, building streams from values/arrays/files/`iterate`/`generate`
- **Collectors** (Ch 6): predefined collectors over manual loops; `counting`/`maxBy`/`summingInt`/`summarizingInt`/`joining`, multilevel and downstream `groupingBy`, `collectingAndThen`, `partitioningBy`, and custom `Collector` implementations
- **Parallelism** (Ch 7): measure before going parallel, no shared mutable state, splittable primitive sources, the fork/join framework via `RecursiveTask`, work stealing, custom `Spliterator`
- **Collection API enhancements** (Ch 8, Java 9): `List.of`/`Set.of`/`Map.of`/`Map.ofEntries` immutable factories, `removeIf`/`replaceAll`, map `forEach`/`getOrDefault`/`computeIfAbsent`/`computeIfPresent`/`merge`, `ConcurrentHashMap` reduce/search/forEach and concurrent set views
- **Refactoring, testing, debugging** (Ch 9): anonymous classes → lambdas → method references; loops → streams; lambda-based Strategy/Template-Method/Observer/Chain/Factory; testing lambdas; debugging with `peek`
- **Domain-specific languages** (Ch 10): the Stream/Collector APIs as internal DSLs; method chaining, nested functions, lambda (Consumer) sequencing, and method references to build fluent, readable DSLs
- **Optional** (Ch 11): model absence with `Optional<T>`, `empty`/`of`/`ofNullable`, `map`/`flatMap`/`filter`/`ifPresent`, `Optional::stream` (Java 9), `orElse`/`orElseGet`/`orElseThrow`, combining optionals, wrapping legacy APIs, and what *not* to do
- **Date and Time API** (Ch 12): immutable `LocalDate`/`LocalTime`/`Instant`/`Duration`/`Period`, `of`/`parse`, `TemporalAdjusters`, thread-safe `DateTimeFormatter`, `ZoneId`/`ZonedDateTime`
- **Default methods** (Ch 13): non-breaking API evolution, optional methods, multiple inheritance of behavior, the three resolution rules, `X.super.method()`, the diamond problem
- **The Java Module System** (Ch 14, Java 9): `module-info.java`, `requires`/`exports`, naming and granularity, compiling/packaging modular JARs, automatic modules, `requires transitive`/`exports…to`/`open`/`opens`/`uses`/`provides`
- **CompletableFuture & concurrency concepts** (Ch 15–16): executors and thread pools, sync vs. async APIs, the box-and-channel model, `supplyAsync`/`runAsync`, exception propagation, non-blocking pipelines, custom executors, `thenApply`/`thenCompose`/`thenCombine`, `allOf`/`anyOf`, `orTimeout`/`completeOnTimeout` (Java 9)
- **Reactive programming** (Ch 17): the Reactive Manifesto, Reactive Streams and the `java.util.concurrent.Flow` API (`Publisher`/`Subscriber`/`Subscription`/`Processor`), backpressure, and RxJava `Observable`
- **Functional thinking & techniques** (Ch 18–20): pure functions, referential transparency, immutability, declarative style, higher-order functions, currying, persistent data structures, lazy lists/evaluation, lambda-based pattern matching, memoization, and Java/Scala comparisons
- **Conclusions & where next** (Ch 21, App A): Java 10 local variable type inference (`var`), try-with-resources, the diamond operator, repeated/type annotations, and where Java is heading

## Constraints

Before applying refactorings derived from these practices, ensure the project compiles and tests pass. Many practices change iteration style, laziness, threading, nullness contracts, date/time handling, or module boundaries and can alter behavior.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying any change.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; report failures honestly and do not claim success until the build and tests pass.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **TARGET VERSION**: These practices span Java 8–11. Note where a feature is newer than Java 8 (e.g. `takeWhile`/`dropWhile`, `List.of`/`Set.of`/`Map.of`, `Optional::stream`, `orTimeout`, the Module System and Flow API are Java 9; `var` is Java 10) and stay within the project's language level.
- **PRESERVE BEHAVIOR**: Stream laziness and short-circuiting, `Optional` contracts, immutable `java.time` semantics, and module encapsulation must preserve observable behavior unless the user explicitly asks to change a contract.
- **CONCURRENCY SAFETY**: Never introduce shared mutable state into parallel streams or `forEach`; size and shut down `CompletableFuture` executors correctly; honor the Reactive Streams/Flow backpressure contract; do not assume parallel is faster — measure.
- **INCREMENTAL**: Apply one practice at a time and re-validate; never batch many structural changes (especially modularization) without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full set of practices with Good/Bad examples and rationale.

## When to use this skill

- Modernize pre-Java-8 code (anonymous classes, external iteration, `null` returns, blocking `Future`s, `Date`/`Calendar`)
- Replace anonymous classes with lambdas or method references; refactor an OO design pattern with lambdas
- Convert imperative loops into a Stream pipeline; choose the right collector or partition/group operation
- Adopt the Java 9 collection factories and idiomatic `Map` operations (`getOrDefault`/`computeIfAbsent`/`merge`)
- Design a fluent, readable domain-specific language with lambdas
- Introduce `Optional` to remove nested null checks; design an API that signals absence
- Migrate `Date`/`Calendar`/`SimpleDateFormat` to the immutable, thread-safe `java.time` API
- Modularize an application with the Java Module System (`module-info.java`)
- Make blocking calls asynchronous and composable with `CompletableFuture`; add reactive backpressure with the Flow API or RxJava
- Parallelize a computation safely (parallel streams, fork/join, custom `Spliterator`)
- Adopt a functional, side-effect-free style (pure functions, immutability, currying, lazy evaluation, pattern matching)
- Reduce boilerplate with `var` (Java 10) where it improves readability

## Workflow

1. **Validate the project before recommendations**

   Run `./mvnw compile` or `mvn compile` and stop if compilation fails.

2. **Read the reference and analyze the code**

   Read `references/modern-java-in-action-book.md`, then inspect the target code and map each smell to a specific practice by chapter section and title (e.g. "5.4 Flatten nested streams with flatMap").

3. **Categorize and prioritize findings**

   Group by impact (CORRECTNESS/CONCURRENCY, MAINTAINABILITY, PERFORMANCE, READABILITY) and by chapter. Order remediation: quick wins (lambdas, method references, `Optional` returns, collection factories, `getOrDefault`/`computeIfAbsent`) before larger refactorings (stream pipelines, custom collectors, DSLs, `CompletableFuture` orchestration, reactive pipelines, fork/join, `Spliterator`, modularization).

4. **Apply improvements incrementally and verify**

   Apply one practice at a time, preserving behavior, and re-run `./mvnw clean verify` after each substantive change. For performance work, measure before and after rather than assuming. Cite each applied practice by chapter section and title.

## Reference

For the full set of practices across 21 chapters plus Appendix A (Java 8–11) with rationale and Good/Bad examples, see [references/modern-java-in-action-book.md](references/modern-java-in-action-book.md).
