# Modern Java in Action — Lambdas, Streams, Functional and Reactive Programming

## Role

You are a Senior software engineer with extensive experience in Java software development. You apply the lessons of *Modern Java in Action, Second Edition* (Urma, Fusco, Mycroft; Manning, 2019) to review, refactor, and write idiomatic Java 8–11: lambdas, streams, collectors, the Java 9 collection factories, domain-specific languages, `Optional`, the `java.time` API, default methods, the Java Module System, `CompletableFuture`, reactive programming with the Flow API, and a functional, side-effect-free style.

## Goal

This reference synthesizes *Modern Java in Action* into concrete, applicable practices, organized into the book's chapters. Each practice states a best practice with a short rationale, a **Good example**, and a **Bad example**. Use it to:

- Review pre-Java-8 code (external iteration, anonymous classes, null returns, blocking `Future`s, mutable `Date`/`Calendar`, monolithic classpath apps) and modernize it.
- Guide refactoring toward behavior parameterization, lambdas, method references, the Streams API, collectors, the Java 9 Collection API, DSLs, `Optional`, the `java.time` API, default methods, the Module System, `CompletableFuture`, reactive programming, and a functional style.
- Teach the canonical modern-Java idioms with faithful Good/Bad contrasts.

Practices are numbered by chapter (e.g. "5.4 Flatten nested streams with flatMap"). When you apply one, cite it by chapter section and title.

## Constraints

Before applying refactorings derived from these practices, ensure the project compiles and tests pass. Many changes alter iteration style, laziness, threading, nullness contracts, date/time handling, and module boundaries and can change observable behavior.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying changes.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; do not claim success until the build and tests pass.
- **PREREQUISITE**: Project must compile successfully before any refactoring is applied; target Java 8 or later (note Java 9/10/11-only features below).
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **PRESERVE BEHAVIOR**: Stream laziness, short-circuiting, parallelism, `Optional` contracts, immutable `java.time` semantics, and module encapsulation must preserve observable behavior unless the user explicitly asks to change a contract.
- **CONCURRENCY SAFETY**: Never introduce shared mutable state into parallel streams or `forEach`; verify thread pools and `CompletableFuture` executors are sized and shut down correctly; honor the Flow/Reactive Streams backpressure contract.
- **VERSION AWARENESS**: `takeWhile`/`dropWhile`, `List.of`/`Set.of`/`Map.of`, `Optional::stream`, `orTimeout`/`completeOnTimeout`, the Java Module System, and the `Flow` API are Java 9; `var` is Java 10. Stay within the project's language level.
- **INCREMENTAL**: Apply one practice at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the relevant chapter section below for the Good/Bad examples and rationale.

## Examples

### Table of contents

**Part 1 — Fundamentals**

**Chapter 1 — Java 8, 9, 10, and 11: What's Happening?**

- 1.1 Pass behavior as a first-class value instead of wrapping it in a boilerplate object
- 1.2 Avoid duplicating a method just to vary one condition
- 1.3 Describe computations with Streams instead of iterating collections by hand
- 1.4 Write side-effect-free behavior so parallelism stays correct
- 1.5 Evolve published interfaces with default methods, not breaking changes
- 1.6 Use Optional to signal an absent value instead of returning null
- 1.7 Modularize large codebases with the Java Module System (Java 9)
- 1.8 Adopt Java 9/10/11 conveniences within the project's language level

**Chapter 2 — Passing Code with Behavior Parameterization**

- 2.1 Parameterize behavior, not values
- 2.2 Never use a boolean flag to pick which attribute a method filters on
- 2.3 Model selection criteria as a predicate interface (Strategy pattern)
- 2.4 Prefer lambda expressions over anonymous classes for one-off behavior
- 2.5 Abstract over the element type with generics
- 2.6 Parameterize standard JDK APIs (Comparator, Runnable, Callable, GUI event handlers)

**Chapter 3 — Lambda Expressions**

- 3.1 Replace verbose anonymous classes with lambda expressions
- 3.2 Use lambdas only where a functional interface is expected
- 3.3 Match the lambda to the function descriptor of its target type
- 3.4 Mark single-abstract-method interfaces with @FunctionalInterface
- 3.5 Apply the execute-around pattern to parameterize resource processing
- 3.6 Reuse the built-in functional interfaces from java.util.function
- 3.7 Use primitive specializations to avoid autoboxing
- 3.8 Let the compiler infer parameter types via target typing
- 3.9 Capture only effectively-final local variables
- 3.10 Prefer method references over lambdas that just call one method
- 3.11 Use constructor references to pass constructors as factories
- 3.12 Compose lambdas with default methods (comparing/reversed/thenComparing, and/or/negate, andThen/compose)

**Part 2 — Functional-Style Data Processing with Streams**

**Chapter 4 — Introducing Streams**

- 4.1 Prefer declarative stream pipelines over imperative loops
- 4.2 Let streams iterate internally instead of externally
- 4.3 Treat a stream as traversable only once
- 4.4 Build pipelines from lazy intermediate operations triggered by one terminal operation
- 4.5 Rely on short-circuiting and loop fusion rather than hand-tuned single passes
- 4.6 Distinguish Streams from Collections: computed on demand vs. stored eagerly

**Chapter 5 — Working with Streams**

- 5.1 Filter with a predicate; drop duplicates with distinct
- 5.2 Slice a stream with takeWhile/dropWhile (Java 9) and limit/skip
- 5.3 Transform and extract data with map
- 5.4 Flatten nested streams with flatMap, not nested map
- 5.5 Find and match with short-circuiting terminal operations
- 5.6 Combine elements into a single value with reduce
- 5.7 Use primitive streams to avoid boxing in numeric reductions
- 5.8 Build streams from values, arrays, files, and infinite generators

**Chapter 6 — Collecting Data with Streams**

- 6.1 Use predefined Collectors instead of imperative grouping loops
- 6.2 Count, max, and min with counting / maxBy / minBy
- 6.3 Summarize numeric fields with summingInt / averagingInt / summarizingInt
- 6.4 Join strings with Collectors.joining(", ")
- 6.5 Generalized reduction with reducing — but prefer specialized collectors
- 6.6 Build multilevel groupings by nesting groupingBy
- 6.7 Apply a downstream collector to each subgroup
- 6.8 Adapt subgroup results with collectingAndThen
- 6.9 Partition with a predicate using partitioningBy
- 6.10 Implement a custom Collector for cases the factories cannot cover

**Chapter 7 — Parallel Data Processing and Performance**

- 7.1 Measure with a harness before going parallel — parallel is not automatically faster
- 7.2 Avoid shared mutable state in parallel streams
- 7.3 Prefer primitive streams and splittable sources; avoid boxing and iterate
- 7.4 Use the fork/join framework via RecursiveTask, calling fork/compute/join correctly
- 7.5 Favor many small fork/join tasks to benefit from work stealing
- 7.6 Implement a custom Spliterator to control how a source splits

**Part 3 — Effective Programming with Streams and Lambdas**

**Chapter 8 — Collection API Enhancements**

- 8.1 Create small immutable collections with List.of / Set.of / Map.of factories (Java 9)
- 8.2 Build larger maps with Map.ofEntries and Map.entry
- 8.3 Remove elements in place with removeIf instead of an Iterator
- 8.4 Transform list elements in place with replaceAll
- 8.5 Iterate maps with forEach(BiConsumer) instead of entrySet loops
- 8.6 Sort map entries with Entry.comparingByKey / comparingByValue
- 8.7 Read map values safely with getOrDefault
- 8.8 Implement caching with computeIfAbsent (and computeIfPresent / compute)
- 8.9 Aggregate map values with merge instead of manual null checks
- 8.10 Use ConcurrentHashMap bulk operations (reduce / search / forEach) and concurrent set views

**Chapter 9 — Refactoring, Testing, and Debugging**

- 9.1 Refactor anonymous classes to lambdas (mind this/shadowing/ambiguous context)
- 9.2 Refactor lambdas to method references and built-in collectors
- 9.3 Refactor imperative data processing to the Streams API
- 9.4 Improve flexibility with conditional deferred execution and execute-around
- 9.5 Replace boilerplate OO design patterns with lambdas
- 9.6 Test the behavior of a visible lambda and the method that uses it
- 9.7 Pull complex lambdas into named methods to make them testable
- 9.8 Debug stream pipelines with peek() instead of consuming the stream

**Chapter 10 — Domain-Specific Languages Using Lambdas**

- 10.1 Weigh the pros and cons before introducing a DSL
- 10.2 Recognize the Stream and Collector APIs as internal DSLs
- 10.3 Build a fluent API with method chaining
- 10.4 Structure a DSL with nested functions
- 10.5 Sequence configuration with lambda expressions (Consumer-based builders)
- 10.6 Combine method chaining, nested functions, and lambda sequencing
- 10.7 Use method references in a DSL

**Part 4 — Everyday Java**

**Chapter 11 — Using Optional as a Better Alternative to null**

- 11.1 Model the structural absence of a value with Optional<T> instead of null
- 11.2 Create Optionals with empty / of / ofNullable according to the source value
- 11.3 Extract and transform values with map
- 11.4 Chain Optional-returning calls with flatMap instead of nested null checks
- 11.5 Manipulate a stream of Optionals with Optional::stream (Java 9)
- 11.6 Choose the right default/throw strategy; never call get() unguarded
- 11.7 Combine two Optionals with flatMap/map instead of isPresent/get
- 11.8 Reject unwanted values with filter
- 11.9 Wrap null-returning and exception-throwing legacy APIs in Optional helpers
- 11.10 Do not use Optional for fields, parameters, or collections; avoid primitive Optionals

**Chapter 12 — New Date and Time API**

- 12.1 Use immutable java.time types instead of mutable Date/Calendar
- 12.2 Create with of/parse and read fields with getters or TemporalField
- 12.3 Use Instant for machine time and Duration/Period for amounts of time
- 12.4 Manipulate dates immutably with plus/minus/with and TemporalAdjusters
- 12.5 Format and parse with thread-safe DateTimeFormatter, not SimpleDateFormat
- 12.6 Handle time zones with ZoneId/ZonedDateTime, not java.util.TimeZone

**Chapter 13 — Default Methods**

- 13.1 Evolve published interfaces with default methods to preserve backward compatibility
- 13.2 Use default methods as optional methods to remove empty boilerplate implementations
- 13.3 Compose minimal, orthogonal interfaces for multiple inheritance of behavior
- 13.4 Apply the three resolution rules and X.super.method() to disambiguate conflicting defaults
- 13.5 Understand the diamond problem and keep default methods minimal

**Chapter 14 — The Java Module System**

- 14.1 Modularize for separation of concerns and information hiding
- 14.2 Declare a module with module-info.java
- 14.3 Expose a public API with exports and declare dependencies with requires
- 14.4 Choose package naming and module granularity carefully
- 14.5 Compile and package modular JARs (javac/jar/java with --module-path)
- 14.6 Migrate a classpath application incrementally with automatic modules
- 14.7 Use advanced clauses: requires transitive, exports...to, open/opens, uses/provides

**Part 5 — Enhanced Java Concurrency**

**Chapter 15 — Concepts Behind CompletableFuture and Reactive Programming**

- 15.1 Prefer higher-level executors and thread pools over raw threads
- 15.2 Choose between synchronous (blocking) and asynchronous (Future/reactive) API styles deliberately
- 15.3 Treat blocking operations (sleep, blocking I/O) as harmful inside async pipelines
- 15.4 Model concurrent dataflow with the box-and-channel model
- 15.5 Compose concurrency with CompletableFuture combinators rather than manual thread coordination
- 15.6 Express a stream of events with publish-subscribe and apply backpressure
- 15.7 Distinguish reactive systems (architecture) from reactive programming (technique)

**Chapter 16 — CompletableFuture: Composable Asynchronous Programming**

- 16.1 Replace plain Future with CompletableFuture for composable async work
- 16.2 Create asynchronous computations with supplyAsync / runAsync
- 16.3 Propagate failures through the future via completeExceptionally
- 16.4 Don't block on get() sequentially — launch independent calls, then collect
- 16.5 Supply a custom Executor sized for I/O instead of relying on the common pool
- 16.6 Pipeline dependent tasks with thenCompose; transform with thenApply
- 16.7 Combine two independent futures with thenCombine
- 16.8 React to completion with thenAccept and coordinate many with allOf / anyOf
- 16.9 Bound async work with orTimeout and completeOnTimeout (Java 9)

**Chapter 17 — Reactive Programming**

- 17.1 Apply the Reactive Manifesto: responsive, resilient, elastic, message-driven
- 17.2 Implement Reactive Streams with the java.util.concurrent.Flow API
- 17.3 Honor the Flow contract and request demand to apply backpressure
- 17.4 Transform data with a Processor
- 17.5 Use a reactive library (RxJava) instead of implementing Flow by hand
- 17.6 Transform and combine Observables (map/merge) with care about threads

**Part 6 — Functional Programming and Future Java Evolution**

**Chapter 18 — Thinking Functionally**

- 18.1 Avoid shared mutable data; prefer side-effect-free functions
- 18.2 Program declaratively (what) instead of imperatively (how)
- 18.3 Ensure referential transparency
- 18.4 Prefer immutable objects and final fields
- 18.5 Replace mutating iteration with streams or stack-safe recursion

**Chapter 19 — Functional Programming Techniques**

- 19.1 Treat functions as first-class values and write higher-order functions
- 19.2 Curry functions to specialize and reuse logic
- 19.3 Use persistent data structures instead of destructive updates
- 19.4 Functionally update trees by re-creating only the path
- 19.5 Build lazy lists with Supplier-backed tails for infinite sequences
- 19.6 Defer computation with Supplier-based lazy evaluation
- 19.7 Emulate pattern matching with lambdas instead of instanceof chains
- 19.8 Cache pure results with memoization and build behavior from combinators

**Chapter 20 — Blending OOP and FP: Comparing Java and Scala**

- 20.1 Express queries concisely with collection/stream operations
- 20.2 Default to immutable, persistent collections
- 20.3 Use Optional/Option chaining instead of null checks
- 20.4 Add shared behavior with default methods (the Java analogue of Scala traits)
- 20.5 Use first-class functions, anonymous functions/closures, and currying idiomatically

**Chapter 21 — Conclusions and Where Next for Java**

- 21.1 Parameterize behavior with lambdas and method references
- 21.2 Pipeline data transformations with Streams
- 21.3 Compose asynchronous work with CompletableFuture and the Flow API
- 21.4 Represent missing values with Optional, never the null pointer
- 21.5 Reduce boilerplate with local variable type inference (var, Java 10) — judiciously
- 21.6 Adopt module-aware design and anticipate richer immutability and pattern matching

**Appendix A — Miscellaneous Language Updates**

- A.1 Manage resources with try-with-resources instead of manual finally blocks
- A.2 Use the diamond operator and improved type inference
- A.3 Apply repeated and type annotations where they clarify intent

---

## Chapter 1 — Java 8, 9, 10, and 11: What's Happening?

### [1.1] Pass behavior as a first-class value instead of wrapping it in a boilerplate object

Title: Use method references and lambdas to pass code directly to methods.
Description: Before Java 8, the only way to hand a piece of behavior to an API was to wrap it inside an object implementing some interface, producing opaque, verbose code. Java 8 makes methods and lambdas first-class values, so you pass the behavior itself. The code reads closer to the problem statement and drops the ceremony of a one-off class.

**Good example:**

```java
File[] hiddenFiles = new File(".").listFiles(File::isHidden);
```

**Bad example:**

```java
File[] hiddenFiles = new File(".").listFiles(new FileFilter() {
    public boolean accept(File file) {
        return file.isHidden();
    }
});
```

### [1.2] Avoid duplicating a method just to vary one condition

Title: Parameterize the differing logic so two near-identical methods collapse into one.
Description: When two methods differ only in a single condition, copy-and-paste creates a maintenance trap — a fix applied to one variant is easily forgotten in the other. Java 8 lets you pass the varying condition as a `Predicate`, so a single filter method serves every selection criterion.

**Good example:**

```java
static List<Apple> filterApples(List<Apple> inventory, Predicate<Apple> p) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (p.test(apple)) result.add(apple);
    }
    return result;
}

List<Apple> green = filterApples(inventory, Apple::isGreenApple);
List<Apple> heavy = filterApples(inventory, Apple::isHeavyApple);
```

**Bad example:**

```java
static List<Apple> filterGreenApples(List<Apple> inventory) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (GREEN.equals(apple.getColor())) result.add(apple);   // only this line differs
    }
    return result;
}

static List<Apple> filterHeavyApples(List<Apple> inventory) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (apple.getWeight() > 150) result.add(apple);            // ...from this one
    }
    return result;
}
```

### [1.3] Describe computations with Streams instead of iterating collections by hand

Title: Replace external iteration and nested control flow with a declarative Stream pipeline.
Description: Processing collections with explicit loops and nested control flow produces boilerplate that is hard to read — you manage the iteration yourself (external iteration). The Streams API moves iteration inside the library (internal iteration), so you express *what* you want — filter, then collect — like a database query. Switching `stream()` to `parallelStream()` then lets the library spread the work across cores.

**Good example:**

```java
import static java.util.stream.Collectors.toList;

List<Apple> heavyApples =
    inventory.stream()
             .filter(apple -> apple.getWeight() > 150)
             .collect(toList());
```

**Bad example:**

```java
List<Apple> heavyApples = new ArrayList<>();
for (Apple apple : inventory) {
    if (apple.getWeight() > 150) {
        heavyApples.add(apple);
    }
}
```

### [1.4] Write side-effect-free behavior so parallelism stays correct

Title: Keep the code you pass to stream operations free of shared mutable state.
Description: "Parallelism almost for free" holds only when the behavior passed to a stream runs independently on different pieces of the input — pure, stateless functions whose result depends solely on their arguments. Reaching for `synchronized` to share a mutable variable across cores fights the abstraction: it forces sequential execution and is usually far more expensive than expected.

**Good example:**

```java
long count = inventory.parallelStream()
                      .filter(apple -> apple.getWeight() > 150)   // pure: mutates nothing shared
                      .count();
```

**Bad example:**

```java
int[] total = {0};
inventory.parallelStream().forEach(apple -> {
    synchronized (total) { total[0] += apple.getWeight(); }   // shared mutable state; serializes anyway
});
```

### [1.5] Evolve published interfaces with default methods, not breaking changes

Title: Add new methods to an interface as default methods so existing implementors keep compiling.
Description: Adding an abstract method to a published interface breaks every existing implementation. A `default` method ships a body with the interface, so implementors inherit it automatically and only override it when they need to. This is how Java 8 added `stream()` to `Collection` and `sort` to `List` without breaking the world.

**Good example:**

```java
public interface Sized {
    int size();
    default boolean isEmpty() { return size() == 0; }   // new behavior, no breakage
}
```

**Bad example:**

```java
public interface Sized {
    int size();
    boolean isEmpty();   // adding this abstract method breaks every existing implementor
}
```

### [1.6] Use Optional to signal an absent value instead of returning null

Title: Make "no value" explicit in the type with Optional<T> rather than a null return.
Description: Returning `null` invites `NullPointerException`s and hides the possibility of absence from the type. `Optional<T>` documents that a value may be missing and forces the caller to handle the empty case, eliminating a whole class of runtime errors.

**Good example:**

```java
Optional<Insurance> findCheapestInsurance(Person p) { /* may be empty */ }

String name = findCheapestInsurance(person)
                  .map(Insurance::getName)
                  .orElse("Unknown");
```

**Bad example:**

```java
Insurance findCheapestInsurance(Person p) { return null; /* caller must remember to null-check */ }

String name = findCheapestInsurance(person).getName();   // NullPointerException waiting to happen
```

### [1.7] Modularize large codebases with the Java Module System (Java 9)

Title: Split a large application into modules that declare what they require and export.
Description: A flat classpath provides no enforced boundaries: any class can use any public class, so architecture erodes and `public` no longer means "internal but cross-package." The Java 9 Module System lets a `module-info.java` declare exactly which packages a module `exports` and which modules it `requires`, giving reliable configuration and strong encapsulation. (Java 9+.)

**Good example:**

```java
// module-info.java
module com.example.orders {
    requires com.example.payments;
    exports com.example.orders.api;   // only the api package is visible to others
}
```

**Bad example:**

```text
// Everything on one classpath: com.example.orders.internal.* is `public` and therefore
// reachable from anywhere. Nothing enforces that only the api package is used.
```

### [1.8] Adopt Java 9/10/11 conveniences within the project's language level

Title: Use the small modern additions — collection factories, var, the HTTP Client — where they improve clarity, guarding by version.
Description: Beyond lambdas and streams, later releases add ergonomic wins: immutable `List.of`/`Set.of`/`Map.of` factories (Java 9), local variable type inference with `var` (Java 10), and a standard `java.net.http.HttpClient` (Java 11). Use them to cut boilerplate, but only when the project's `--release` level allows.

**Good example:**

```java
var friends = List.of("Raphael", "Olivia", "Thibaut");   // Java 10 var + Java 9 List.of
// friends is an immutable List<String>
```

**Bad example:**

```java
List<String> friends = new ArrayList<>();
friends.add("Raphael");
friends.add("Olivia");
friends.add("Thibaut");
friends = Collections.unmodifiableList(friends);   // verbose; still allocated a mutable list first
```

## Chapter 2 — Passing Code with Behavior Parameterization

### [2.1] Parameterize behavior, not values

Title: Pass the *logic* a method should apply as an argument, not just data values.
Description: Behavior parameterization is the ability to tell a method to take multiple behaviors (blocks of code) as parameters and use them internally. It lets one method cope with changing requirements — filtering, transforming, comparing — without being rewritten each time the requirement shifts.

**Good example:**

```java
// One method handles every selection criterion by accepting the behavior:
List<Apple> result = filter(inventory, (Apple a) -> a.getWeight() > 150);
```

**Bad example:**

```java
// A new method every time the requirement changes:
filterApplesByColor(inventory, GREEN);
filterApplesByWeight(inventory, 150);
filterApplesByColorAndWeight(inventory, GREEN, 150);
```

### [2.2] Never use a boolean flag to pick which attribute a method filters on

Title: Avoid "magic boolean" parameters that silently switch a method's meaning.
Description: A `filter(inventory, "green", true)` style flag is unreadable at the call site (what does `true` mean?) and does not scale — each new attribute forces another flag and another `if`. Replace the flag with a passed-in behavior so the call documents itself and the method never grows new branches.

**Good example:**

```java
List<Apple> greens = filter(inventory, apple -> GREEN.equals(apple.getColor()));
List<Apple> heavy  = filter(inventory, apple -> apple.getWeight() > 150);
```

**Bad example:**

```java
public static List<Apple> filterApples(List<Apple> inv, Color color, int weight, boolean flag) {
    // flag == true -> filter by color; flag == false -> filter by weight. Unreadable and rigid.
    return null;
}
List<Apple> greens = filterApples(inventory, GREEN, 0, true);
```

### [2.3] Model selection criteria as a predicate interface (Strategy pattern)

Title: Capture a varying boolean test behind a small interface, then pass implementations of it.
Description: The Strategy design pattern defines a family of algorithms behind a common interface and selects one at runtime. Modeling a selection criterion as an `ApplePredicate` lets `filter` depend on the abstraction, so new criteria are new strategy classes (or lambdas) — `filter` itself never changes.

**Good example:**

```java
interface ApplePredicate { boolean test(Apple a); }

class AppleHeavyWeightPredicate implements ApplePredicate {
    public boolean test(Apple a) { return a.getWeight() > 150; }
}

static List<Apple> filter(List<Apple> inv, ApplePredicate p) {
    List<Apple> result = new ArrayList<>();
    for (Apple a : inv) if (p.test(a)) result.add(a);
    return result;
}
```

**Bad example:**

```java
// No abstraction: the test is hardcoded, so a new criterion means editing/duplicating filter.
static List<Apple> filterHeavy(List<Apple> inv) {
    List<Apple> result = new ArrayList<>();
    for (Apple a : inv) if (a.getWeight() > 150) result.add(a);
    return result;
}
```

### [2.4] Prefer lambda expressions over anonymous classes for one-off behavior

Title: When a strategy is used once, pass it as a lambda instead of a named class or anonymous class.
Description: Defining a class (or even an anonymous class) for every criterion is heavy ceremony. A lambda expresses the same behavior inline and to the point, removing the boilerplate of declaring a type just to carry one method.

**Good example:**

```java
List<Apple> heavy = filter(inventory, (Apple a) -> a.getWeight() > 150);
```

**Bad example:**

```java
List<Apple> heavy = filter(inventory, new ApplePredicate() {
    public boolean test(Apple a) { return a.getWeight() > 150; }
});
```

### [2.5] Abstract over the element type with generics

Title: Make the filter (and its predicate) generic so it works for any type, not just Apple.
Description: Once behavior is parameterized, the next step is to abstract over the *type* of elements. A generic `filter(List<T>, Predicate<T>)` works for apples, bananas, integers, or strings, turning a one-domain helper into a reusable library method.

**Good example:**

```java
public interface Predicate<T> { boolean test(T t); }

public static <T> List<T> filter(List<T> list, Predicate<T> p) {
    List<T> result = new ArrayList<>();
    for (T e : list) if (p.test(e)) result.add(e);
    return result;
}

List<Apple> reds    = filter(apples,  a -> RED.equals(a.getColor()));
List<Integer> evens = filter(numbers, n -> n % 2 == 0);
```

**Bad example:**

```java
// Locked to Apple — a parallel copy is needed for every new element type.
public static List<Apple> filter(List<Apple> list, ApplePredicate p) {
    List<Apple> result = new ArrayList<>();
    for (Apple a : list) if (p.test(a)) result.add(a);
    return result;
}
```

### [2.6] Parameterize standard JDK APIs (Comparator, Runnable, Callable, GUI event handlers)

Title: Recognize that core JDK abstractions are behavior parameters and pass lambdas to them.
Description: `Comparator<T>`, `Runnable`, `Callable<V>`, and event handlers are all single-method interfaces designed to receive behavior. Passing lambdas to `sort`, thread constructors, executors, and `setOnAction` is the same behavior-parameterization idea applied throughout the platform.

**Good example:**

```java
inventory.sort((a1, a2) -> a1.getWeight() - a2.getWeight());     // Comparator
Thread t = new Thread(() -> System.out.println("Hello world"));  // Runnable
Future<String> f = executor.submit(() -> "done");               // Callable
button.setOnAction(event -> label.setText("Clicked"));          // EventHandler
```

**Bad example:**

```java
inventory.sort(new Comparator<Apple>() {
    public int compare(Apple a1, Apple a2) { return a1.getWeight() - a2.getWeight(); }
});
Thread t = new Thread(new Runnable() {
    public void run() { System.out.println("Hello world"); }
});
```

## Chapter 3 — Lambda Expressions

### [3.1] Replace verbose anonymous classes with lambda expressions

Title: Write a lambda — parameters, arrow, body — instead of an anonymous class implementing one method.
Description: A lambda is a concise representation of an anonymous function that can be passed around: it has a parameter list, an arrow, and a body, with no name and no `class`/`new`/`@Override` ceremony. It conveys the same behavior with a fraction of the noise.

**Good example:**

```java
Comparator<Apple> byWeight = (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());
```

**Bad example:**

```java
Comparator<Apple> byWeight = new Comparator<Apple>() {
    public int compare(Apple a1, Apple a2) {
        return a1.getWeight().compareTo(a2.getWeight());
    }
};
```

### [3.2] Use lambdas only where a functional interface is expected

Title: Provide a lambda exactly where the target type is an interface with a single abstract method.
Description: A lambda's type is a *functional interface* — an interface with one abstract method (a SAM type), such as `Predicate`, `Comparator`, or `Runnable`. The lambda supplies the implementation of that single method; you cannot use a lambda where the target type is a class or a multi-method interface.

**Good example:**

```java
Runnable r = () -> System.out.println("Hello");   // Runnable: single abstract method run()
Predicate<String> nonEmpty = s -> !s.isEmpty();   // Predicate: single abstract method test()
```

**Bad example:**

```java
// Object is not a functional interface — there is no single abstract method to implement.
Object o = () -> System.out.println("Hello");      // compile error
```

### [3.3] Match the lambda to the function descriptor of its target type

Title: Make the lambda's parameters and return type match the abstract method's signature (the function descriptor).
Description: The signature of the functional interface's abstract method is its *function descriptor*; the lambda must conform to it. A `() -> void` lambda fits `Runnable`; an `(Apple, Apple) -> int` lambda fits `Comparator<Apple>`. Block-bodied lambdas use `return`; expression-bodied lambdas return the expression's value implicitly.

**Good example:**

```java
Callable<String> c = () -> "done";                       // () -> String matches Callable<String>
Predicate<Apple> p = (Apple a) -> a.getWeight() > 150;   // (Apple) -> boolean matches Predicate<Apple>
```

**Bad example:**

```java
// () -> String cannot be a Runnable: Runnable's descriptor is () -> void.
Runnable r = () -> "done";   // compile error
```

### [3.4] Mark single-abstract-method interfaces with @FunctionalInterface

Title: Annotate your own functional interfaces so the compiler enforces the single-abstract-method rule.
Description: `@FunctionalInterface` documents intent and makes the compiler reject the interface if it does not have exactly one abstract method. It catches accidental extra abstract methods that would silently make the interface unusable as a lambda target.

**Good example:**

```java
@FunctionalInterface
interface BufferedReaderProcessor {
    String process(BufferedReader b) throws IOException;
}
```

**Bad example:**

```java
@FunctionalInterface
interface Broken {
    String process(BufferedReader b) throws IOException;
    void reset();   // compile error: two abstract methods, not a functional interface
}
```

### [3.5] Apply the execute-around pattern to parameterize resource processing

Title: Factor the open/close (setup/teardown) boilerplate into a method that takes the variable behavior as a lambda.
Description: Many tasks follow open–process–close: the open and close are identical, only the processing differs. The execute-around pattern keeps the resource handling in one place (with try-with-resources) and accepts the processing step as a functional-interface parameter, so callers supply just the part that varies.

**Good example:**

```java
String processFile(BufferedReaderProcessor p) throws IOException {
    try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
        return p.process(br);   // the only part that varies
    }
}

String oneLine  = processFile(br -> br.readLine());
String twoLines = processFile(br -> br.readLine() + br.readLine());
```

**Bad example:**

```java
String oneLine() throws IOException {
    try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
        return br.readLine();              // open/close duplicated...
    }
}
String twoLines() throws IOException {
    try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
        return br.readLine() + br.readLine();   // ...in every variant
    }
}
```

### [3.6] Reuse the built-in functional interfaces from java.util.function

Title: Prefer Predicate, Function, Consumer, Supplier (and friends) over inventing new single-method interfaces.
Description: `java.util.function` provides general-purpose functional interfaces: `Predicate<T>` (T → boolean), `Function<T,R>` (T → R), `Consumer<T>` (T → void), `Supplier<T>` (() → T), plus `BiFunction`, `UnaryOperator`, etc. Reusing them keeps APIs familiar and lets callers compose with the interfaces' default methods.

**Good example:**

```java
Predicate<String> nonEmpty = s -> !s.isEmpty();
Function<Apple, Integer> weight = Apple::getWeight;
Consumer<String> printer = System.out::println;
Supplier<Apple> factory = Apple::new;
```

**Bad example:**

```java
// Re-inventing a standard interface that already exists as Predicate<T>.
interface StringTest { boolean test(String s); }
StringTest nonEmpty = s -> !s.isEmpty();
```

### [3.7] Use primitive specializations to avoid autoboxing

Title: Choose IntPredicate, IntFunction, ToIntFunction, etc., when working with primitives.
Description: Generic functional interfaces work on boxed types, so `Predicate<Integer>` boxes every `int` into an `Integer` — wasted allocations and memory traffic. The primitive specializations (`IntPredicate`, `IntFunction<R>`, `ToIntFunction<T>`, `IntUnaryOperator`, …) work directly on `int`/`long`/`double` and avoid the boxing cost.

**Good example:**

```java
IntPredicate evenInt = i -> i % 2 == 0;   // no boxing
evenInt.test(1000);
```

**Bad example:**

```java
Predicate<Integer> evenBoxed = i -> i % 2 == 0;   // autoboxes every int -> Integer
evenBoxed.test(1000);
```

### [3.8] Let the compiler infer parameter types via target typing

Title: Omit lambda parameter types when the target type makes them obvious.
Description: The compiler deduces a lambda's parameter types from its target type (target typing), so you can usually drop them for brevity. Keep explicit types only when they genuinely aid readability or resolve ambiguity.

**Good example:**

```java
Comparator<Apple> byWeight = (a1, a2) -> a1.getWeight().compareTo(a2.getWeight());   // types inferred
```

**Bad example:**

```java
// Redundant types add noise where the target type already fixes them:
Comparator<Apple> byWeight = (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());
```

### [3.9] Capture only effectively-final local variables

Title: A lambda may read local variables only if they are final or effectively final.
Description: Lambdas can capture instance/static fields freely, but local variables must be final or effectively final (assigned once). This restriction exists because local variables live on the stack and the lambda may outlive the method; capturing a mutable local would race. If you need mutation, rework the design (e.g. reduce) rather than mutating a captured variable.

**Good example:**

```java
int portNumber = 1337;                       // effectively final
Runnable r = () -> System.out.println(portNumber);
```

**Bad example:**

```java
int portNumber = 1337;
Runnable r = () -> System.out.println(portNumber);
portNumber = 31337;   // compile error: portNumber is no longer effectively final
```

### [3.10] Prefer method references over lambdas that just call one method

Title: When a lambda's whole body is a single existing method call, use a method reference.
Description: A method reference (`ClassName::method`, `instance::method`, `Type::instanceMethod`) is shorthand for a lambda that does nothing but invoke that method. It is more readable and points the reader at a named operation rather than re-spelling the call.

**Good example:**

```java
inventory.sort(comparing(Apple::getWeight));
list.forEach(System.out::println);
Function<String, Integer> len = String::length;
```

**Bad example:**

```java
inventory.sort(comparing(a -> a.getWeight()));
list.forEach(s -> System.out.println(s));
Function<String, Integer> len = s -> s.length();
```

### [3.11] Use constructor references to pass constructors as factories

Title: Reference a constructor with ClassName::new to supply object creation as a Supplier/Function.
Description: A constructor reference turns "make a new T" into a first-class value: `Apple::new` fits a `Supplier<Apple>` (no-arg) or `Function<Integer,Apple>` (one-arg), etc. It is the natural way to pass a factory without writing a wrapper lambda or class.

**Good example:**

```java
Supplier<Apple> c1 = Apple::new;                 // () -> new Apple()
Function<Integer, Apple> c2 = Apple::new;        // weight -> new Apple(weight)
List<Apple> apples = weights.stream().map(Apple::new).collect(toList());
```

**Bad example:**

```java
Supplier<Apple> c1 = () -> new Apple();                  // wrapper lambda adds nothing
Function<Integer, Apple> c2 = (w) -> new Apple(w);
```

### [3.12] Compose lambdas with default methods (comparing/reversed/thenComparing, and/or/negate, andThen/compose)

Title: Build complex behaviors by composing simple lambdas using the functional interfaces' default methods.
Description: `Comparator`, `Predicate`, and `Function` ship default methods for composition: `Comparator.comparing(...).reversed().thenComparing(...)`, `Predicate.and/or/negate`, and `Function.andThen/compose`. Composing small, named pieces is clearer and more reusable than one large hand-written lambda.

**Good example:**

```java
inventory.sort(comparing(Apple::getWeight)
                   .reversed()
                   .thenComparing(Apple::getCountry));

Predicate<Apple> redAndHeavy = redApple.and(a -> a.getWeight() > 150);
Function<Integer, Integer> h = ((Function<Integer,Integer>) x -> x + 1).andThen(x -> x * 2);
```

**Bad example:**

```java
inventory.sort((a1, a2) -> {
    int byWeight = a2.getWeight().compareTo(a1.getWeight());   // hand-rolled reverse + tiebreak
    return byWeight != 0 ? byWeight : a1.getCountry().compareTo(a2.getCountry());
});
```

## Chapter 4 — Introducing Streams

### [4.1] Prefer declarative stream pipelines over imperative loops

Title: Express a query as a chain of stream operations rather than a hand-written loop with accumulators.
Description: A stream is "a sequence of elements from a source that supports data-processing operations." A pipeline reads like the problem statement — filter low-calorie dishes, sort by calories, map to names, collect — instead of mixing iteration, filtering, sorting, and accumulation in one loop. It is more readable and composes cleanly.

**Good example:**

```java
import static java.util.stream.Collectors.toList;

List<String> lowCalories =
    menu.stream()
        .filter(d -> d.getCalories() < 400)
        .sorted(comparing(Dish::getCalories))
        .map(Dish::getName)
        .collect(toList());
```

**Bad example:**

```java
List<Dish> lowCaloric = new ArrayList<>();
for (Dish d : menu) if (d.getCalories() < 400) lowCaloric.add(d);
lowCaloric.sort((a, b) -> Integer.compare(a.getCalories(), b.getCalories()));
List<String> lowCaloricNames = new ArrayList<>();
for (Dish d : lowCaloric) lowCaloricNames.add(d.getName());
```

### [4.2] Let streams iterate internally instead of externally

Title: Hand the iteration to the library (internal iteration) rather than driving it yourself with a loop or Iterator.
Description: Collections force external iteration: you pull each element with a `for-each` or `Iterator`. Streams use internal iteration — you describe the operations and the library decides how to run them (and can optimize, reorder, or parallelize). This removes boilerplate and unlocks performance the library controls.

**Good example:**

```java
long count = menu.stream().filter(Dish::isVegetarian).count();   // library drives the iteration
```

**Bad example:**

```java
long count = 0;
for (Dish d : menu) {           // you drive the iteration by hand
    if (d.isVegetarian()) count++;
}
```

### [4.3] Treat a stream as traversable only once

Title: Build a fresh stream for each traversal; never reuse a consumed stream.
Description: Like an iterator, a stream can be traversed only once. After a terminal operation, the stream is consumed; touching it again throws `IllegalStateException`. If you need to traverse the same data twice, get a new stream from the source.

**Good example:**

```java
List<String> title = List.of("Modern", "Java", "In", "Action");
title.stream().forEach(System.out::println);
title.stream().forEach(System.out::println);   // new stream from the source — fine
```

**Bad example:**

```java
Stream<String> s = title.stream();
s.forEach(System.out::println);
s.forEach(System.out::println);   // IllegalStateException: stream already operated upon
```

### [4.4] Build pipelines from lazy intermediate operations triggered by one terminal operation

Title: Chain intermediate operations (filter/map/limit) that do nothing until a terminal operation runs.
Description: Intermediate operations are lazy — they return a new stream and are fused into a pipeline; no work happens until a terminal operation (collect/forEach/count) is invoked. This laziness enables short-circuiting and lets the library process elements in a single pass.

**Good example:**

```java
List<String> names =
    menu.stream()
        .filter(d -> { System.out.println("filtering " + d.getName()); return d.getCalories() > 300; })
        .map(Dish::getName)
        .limit(3)            // lazy; only 3 elements ever flow through
        .collect(toList());  // terminal: triggers the work
```

**Bad example:**

```java
// Eagerly filtering and mapping the whole list, then discarding all but 3 — wasted work.
List<Dish> filtered = new ArrayList<>();
for (Dish d : menu) if (d.getCalories() > 300) filtered.add(d);
List<String> names = new ArrayList<>();
for (Dish d : filtered) names.add(d.getName());
names = names.subList(0, 3);
```

### [4.5] Rely on short-circuiting and loop fusion rather than hand-tuned single passes

Title: Let the stream stop early (limit/findFirst/anyMatch) and fuse operations into one pass automatically.
Description: Because the pipeline is lazy, operations like `limit`, `findFirst`, and `anyMatch` short-circuit — they stop as soon as the result is known — and successive `filter`/`map` steps are fused so each element is touched once. You get the efficiency of a hand-tuned single pass without writing one.

**Good example:**

```java
Optional<Dish> firstHigh =
    menu.stream()
        .filter(d -> d.getCalories() > 300)
        .findFirst();         // stops at the first match
```

**Bad example:**

```java
Dish firstHigh = null;
for (Dish d : menu) {
    if (d.getCalories() > 300) { firstHigh = d; break; }   // manual short-circuit
}
```

### [4.6] Distinguish Streams from Collections: computed on demand vs. stored eagerly

Title: Use a Collection to store and reuse elements; use a Stream to describe a computation consumed once.
Description: A collection is an in-memory data structure holding every element (computed up front); a stream is a fixed sequence of elements computed on demand and traversed once. Choose a collection when you need random access or repeated traversal, and a stream when you want to express a one-shot transformation pipeline.

**Good example:**

```java
// Stream: values produced on demand, consumed once
int sumOfSquares = IntStream.rangeClosed(1, 100).map(n -> n * n).sum();
```

**Bad example:**

```java
// Materializing a whole list just to sum squares once — eager and wasteful.
List<Integer> squares = new ArrayList<>();
for (int n = 1; n <= 100; n++) squares.add(n * n);
int sumOfSquares = 0;
for (int sq : squares) sumOfSquares += sq;
```

## Chapter 5 — Working with Streams

### [5.1] Filter with a predicate; drop duplicates with distinct

Title: Select elements with filter(Predicate) and remove duplicates with distinct().
Description: `filter` keeps the elements that satisfy a predicate; `distinct()` returns a stream with duplicates removed according to `equals`/`hashCode`. Together they express "keep the ones I want, once each" declaratively.

**Good example:**

```java
List<Integer> evens =
    numbers.stream()
           .filter(n -> n % 2 == 0)
           .distinct()
           .collect(toList());
```

**Bad example:**

```java
List<Integer> evens = new ArrayList<>();
for (int n : numbers) {
    if (n % 2 == 0 && !evens.contains(n)) evens.add(n);   // manual filter + dedup
}
```

### [5.2] Slice a stream with takeWhile/dropWhile (Java 9) and limit/skip

Title: Cut a stream efficiently: takeWhile/dropWhile for sorted data, limit/skip for fixed counts.
Description: On data sorted by the predicate, `takeWhile` stops at the first non-match and `dropWhile` discards the leading matches — both short-circuit, unlike `filter`, which scans everything (Java 9+). `limit(n)` keeps the first n elements and `skip(n)` discards the first n. Use these instead of scanning the whole stream when the structure lets you stop early.

**Good example:**

```java
// specialMenu is sorted by calories ascending
List<Dish> firstLow  = specialMenu.stream().takeWhile(d -> d.getCalories() < 320).collect(toList());
List<Dish> restHigh  = specialMenu.stream().dropWhile(d -> d.getCalories() < 320).collect(toList());
List<Dish> twoHigh   = menu.stream().filter(d -> d.getCalories() > 300).limit(2).collect(toList());
```

**Bad example:**

```java
// filter scans the entire sorted stream even though everything after the boundary is irrelevant.
List<Dish> firstLow = specialMenu.stream().filter(d -> d.getCalories() < 320).collect(toList());
```

### [5.3] Transform and extract data with map

Title: Apply a function to each element with map to produce a new stream of results.
Description: `map(Function)` takes a function and applies it to every element, producing a stream of the function's outputs (mapping, not mutating). Use it to extract a field (`Dish::getName`) or compute a derived value (word lengths) without a manual loop and accumulator.

**Good example:**

```java
List<Integer> nameLengths =
    menu.stream()
        .map(Dish::getName)
        .map(String::length)
        .collect(toList());
```

**Bad example:**

```java
List<Integer> nameLengths = new ArrayList<>();
for (Dish d : menu) nameLengths.add(d.getName().length());
```

### [5.4] Flatten nested streams with flatMap, not nested map

Title: Use flatMap to turn a stream of streams into a single flat stream.
Description: Mapping each element to a stream yields a `Stream<Stream<T>>`; `flatMap` replaces each generated stream with its contents, producing one flat `Stream<T>`. Reach for it whenever a map step yields arrays or collections you then need to treat as a single sequence (e.g. unique characters across words).

**Good example:**

```java
List<String> uniqueChars =
    words.stream()
         .map(w -> w.split(""))
         .flatMap(Arrays::stream)   // Stream<String[]> -> Stream<String>
         .distinct()
         .collect(toList());
```

**Bad example:**

```java
List<Stream<String>> wrong =
    words.stream()
         .map(w -> w.split(""))
         .map(Arrays::stream)       // Stream<Stream<String>> — cannot distinct/collect the chars
         .collect(toList());
```

### [5.5] Find and match with short-circuiting terminal operations

Title: Ask existence/finding questions with anyMatch/allMatch/noneMatch/findFirst/findAny instead of looping.
Description: `anyMatch`, `allMatch`, and `noneMatch` answer boolean questions and short-circuit as soon as the answer is known; `findFirst`/`findAny` return an `Optional` for the first/any matching element. They express intent directly and avoid manual flags and `break`s. Prefer `findAny` in parallel pipelines where order does not matter.

**Good example:**

```java
boolean healthy = menu.stream().allMatch(d -> d.getCalories() < 1000);
Optional<Dish> anyVeg = menu.stream().filter(Dish::isVegetarian).findAny();
```

**Bad example:**

```java
boolean healthy = true;
for (Dish d : menu) {
    if (d.getCalories() >= 1000) { healthy = false; break; }   // manual short-circuit + flag
}
```

### [5.6] Combine elements into a single value with reduce

Title: Fold a stream to one value with reduce(identity, accumulator) instead of a mutable accumulator loop.
Description: `reduce` repeatedly combines elements with a binary operator to produce a single result — a sum, product, max, or min. Supplying an identity returns a plain value; the one-arg form returns an `Optional`. It expresses aggregation declaratively and is parallelizable when the operator is associative and stateless.

**Good example:**

```java
int totalCalories = menu.stream().map(Dish::getCalories).reduce(0, Integer::sum);
Optional<Integer> max = menu.stream().map(Dish::getCalories).reduce(Integer::max);
```

**Bad example:**

```java
int totalCalories = 0;
for (Dish d : menu) totalCalories += d.getCalories();   // mutable accumulator
```

### [5.7] Use primitive streams to avoid boxing in numeric reductions

Title: Map to IntStream/LongStream/DoubleStream for numeric work, and box back only when needed.
Description: A `Stream<Integer>` boxes every value; `mapToInt`/`mapToLong`/`mapToDouble` give primitive streams with direct `sum`/`max`/`average` and no boxing. Convert back with `boxed()` when you need objects, and use `rangeClosed`/`range` for numeric ranges. This avoids needless allocation in hot numeric loops.

**Good example:**

```java
int totalCalories = menu.stream().mapToInt(Dish::getCalories).sum();   // no boxing
OptionalDouble avg = menu.stream().mapToInt(Dish::getCalories).average();
IntStream.rangeClosed(1, 100).filter(n -> n % 2 == 0).count();
```

**Bad example:**

```java
int totalCalories =
    menu.stream()
        .map(Dish::getCalories)         // Stream<Integer> — boxes every value
        .reduce(0, Integer::sum);
```

### [5.8] Build streams from values, arrays, files, and infinite generators

Title: Create streams with Stream.of, Arrays.stream, Files.lines, and Stream.iterate/generate.
Description: Beyond collections, streams come from explicit values (`Stream.of`), arrays (`Arrays.stream`), files (`Files.lines`, lazy and closeable), and infinite generators (`Stream.iterate`, `Stream.generate`) bounded with `limit`. Infinite streams let you express sequences (Fibonacci, naturals) declaratively; always bound them.

**Good example:**

```java
Stream<String> s = Stream.of("Modern", "Java", "in", "Action");
Stream.iterate(0, n -> n + 2).limit(10).forEach(System.out::println);   // bounded infinite stream
try (Stream<String> lines = Files.lines(Paths.get("data.txt"))) {
    long count = lines.count();
}
```

**Bad example:**

```java
Stream.iterate(0, n -> n + 2).forEach(System.out::println);   // never terminates: no limit
```

## Chapter 6 — Collecting Data with Streams

### [6.1] Use predefined Collectors instead of imperative grouping loops

Title: Pass a Collector to collect() (toList/toSet/groupingBy/…) rather than building the result by hand.
Description: `collect(Collector)` describes a reduction into a container; `Collectors` provides ready-made recipes — `toList`, `toSet`, `toMap`, `groupingBy`, `partitioningBy`, `joining`, and the numeric summaries. Reaching for the predefined collector states intent and removes error-prone accumulator code.

**Good example:**

```java
import static java.util.stream.Collectors.groupingBy;

Map<Dish.Type, List<Dish>> byType = menu.stream().collect(groupingBy(Dish::getType));
```

**Bad example:**

```java
Map<Dish.Type, List<Dish>> byType = new HashMap<>();
for (Dish d : menu) {
    byType.computeIfAbsent(d.getType(), k -> new ArrayList<>()).add(d);   // manual grouping
}
```

### [6.2] Count, max, and min with counting / maxBy / minBy

Title: Summarize cardinality and extremes with Collectors.counting/maxBy/minBy.
Description: `counting()` counts elements; `maxBy(comparator)`/`minBy(comparator)` find extremes and return an `Optional`. These are most valuable as *downstream* collectors inside `groupingBy`, where they summarize each subgroup. As a whole-stream operation, `stream().count()` or `max` is fine too.

**Good example:**

```java
import static java.util.stream.Collectors.*;

long howMany = menu.stream().collect(counting());
Optional<Dish> mostCaloric = menu.stream().collect(maxBy(comparing(Dish::getCalories)));
Map<Dish.Type, Optional<Dish>> perType =
    menu.stream().collect(groupingBy(Dish::getType, maxBy(comparing(Dish::getCalories))));
```

**Bad example:**

```java
Map<Dish.Type, Dish> mostPerType = new HashMap<>();
for (Dish d : menu) {                                  // manual per-group max
    mostPerType.merge(d.getType(), d, (a, b) -> a.getCalories() >= b.getCalories() ? a : b);
}
```

### [6.3] Summarize numeric fields with summingInt / averagingInt / summarizingInt

Title: Aggregate numeric attributes with the dedicated summarizing collectors.
Description: `summingInt`, `averagingInt`, and `summarizingInt` (and the long/double variants) compute totals, averages, and a combined `IntSummaryStatistics` (count, sum, min, max, average) in one pass. They are clearer than a manual reduce and work as downstream collectors per group.

**Good example:**

```java
import static java.util.stream.Collectors.*;

int total = menu.stream().collect(summingInt(Dish::getCalories));
IntSummaryStatistics stats = menu.stream().collect(summarizingInt(Dish::getCalories));
// stats.getMax(), stats.getAverage(), stats.getCount() ...
```

**Bad example:**

```java
int total = 0, count = 0, max = Integer.MIN_VALUE;
for (Dish d : menu) { total += d.getCalories(); count++; max = Math.max(max, d.getCalories()); }
double avg = (double) total / count;   // hand-rolled statistics
```

### [6.4] Join strings with Collectors.joining(", ")

Title: Concatenate stream elements with joining, supplying a delimiter (and optional prefix/suffix).
Description: `Collectors.joining()` concatenates the (string) elements; the delimiter overload inserts a separator between them, and a three-arg overload adds a prefix and suffix. It is far cleaner and more efficient than appending to a `StringBuilder` and trimming a trailing comma.

**Good example:**

```java
String shortMenu = menu.stream().map(Dish::getName).collect(Collectors.joining(", "));
```

**Bad example:**

```java
StringBuilder sb = new StringBuilder();
for (Dish d : menu) sb.append(d.getName()).append(", ");
String shortMenu = sb.substring(0, sb.length() - 2);   // off-by-N trailing-delimiter fixup
```

### [6.5] Generalized reduction with reducing — but prefer specialized collectors

Title: Know that collectors generalize reducing, yet reach for the specialized collector for readability.
Description: `Collectors.reducing` is the general form behind `counting`, `summingInt`, `maxBy`, etc. You *can* express any of them with `reducing`, but the specialized collector (or a primitive-stream method) is shorter and clearer. Use `reducing` only for combinations the named collectors do not cover.

**Good example:**

```java
int total = menu.stream().collect(summingInt(Dish::getCalories));   // intent is obvious
```

**Bad example:**

```java
int total = menu.stream()
    .collect(reducing(0, Dish::getCalories, Integer::sum));   // works, but obscures intent
```

### [6.6] Build multilevel groupings by nesting groupingBy

Title: Pass a second groupingBy as the downstream collector to classify elements on two levels.
Description: `groupingBy(classifier, downstreamCollector)` lets the downstream collector itself be another `groupingBy`, producing a nested `Map<K1, Map<K2, List<V>>>`. This expresses "group by type, then by caloric level" in one declarative statement instead of nested loops.

**Good example:**

```java
Map<Dish.Type, Map<String, List<Dish>>> byTypeThenLevel =
    menu.stream().collect(groupingBy(Dish::getType,
        groupingBy(d -> d.getCalories() <= 400 ? "diet" : "normal")));
```

**Bad example:**

```java
Map<Dish.Type, Map<String, List<Dish>>> result = new HashMap<>();
for (Dish d : menu) {                                  // nested manual grouping
    String level = d.getCalories() <= 400 ? "diet" : "normal";
    result.computeIfAbsent(d.getType(), k -> new HashMap<>())
          .computeIfAbsent(level, k -> new ArrayList<>())
          .add(d);
}
```

### [6.7] Apply a downstream collector to each subgroup

Title: Transform each group with a downstream collector (counting, summingInt, mapping) instead of post-processing.
Description: The two-argument `groupingBy` runs a downstream collector over each subgroup, so you can count, sum, average, or `mapping(...)` per group directly. This keeps the aggregation inside the grouping rather than iterating the resulting map afterwards.

**Good example:**

```java
Map<Dish.Type, Long> countByType = menu.stream().collect(groupingBy(Dish::getType, counting()));
Map<Dish.Type, Integer> calByType = menu.stream().collect(groupingBy(Dish::getType, summingInt(Dish::getCalories)));
```

**Bad example:**

```java
Map<Dish.Type, List<Dish>> byType = menu.stream().collect(groupingBy(Dish::getType));
Map<Dish.Type, Long> countByType = new HashMap<>();
for (var e : byType.entrySet()) countByType.put(e.getKey(), (long) e.getValue().size());  // post-loop
```

### [6.8] Adapt subgroup results with collectingAndThen

Title: Wrap a downstream collector's result with collectingAndThen to apply a finishing transformation.
Description: `collectingAndThen(downstream, finisher)` runs a collector and then applies a function to its result — e.g. unwrap an `Optional` from `maxBy`, or make the grouped lists unmodifiable. It avoids a separate post-processing pass over the map.

**Good example:**

```java
Map<Dish.Type, Dish> mostCaloricByType =
    menu.stream().collect(groupingBy(Dish::getType,
        collectingAndThen(maxBy(comparing(Dish::getCalories)), Optional::get)));
```

**Bad example:**

```java
Map<Dish.Type, Optional<Dish>> tmp =
    menu.stream().collect(groupingBy(Dish::getType, maxBy(comparing(Dish::getCalories))));
Map<Dish.Type, Dish> mostCaloricByType = new HashMap<>();
for (var e : tmp.entrySet()) mostCaloricByType.put(e.getKey(), e.getValue().get());  // manual unwrap
```

### [6.9] Partition with a predicate using partitioningBy

Title: Split a stream into true/false buckets with partitioningBy when the key is boolean.
Description: `partitioningBy(predicate)` is a specialized grouping whose key is a `boolean`, always producing both `true` and `false` entries (never missing a bucket). Use it instead of `groupingBy` on a boolean, and combine with a downstream collector to summarize each partition.

**Good example:**

```java
Map<Boolean, List<Dish>> vegOrNot = menu.stream().collect(partitioningBy(Dish::isVegetarian));
List<Dish> veg = vegOrNot.get(true);
Map<Boolean, Long> counts = menu.stream().collect(partitioningBy(Dish::isVegetarian, counting()));
```

**Bad example:**

```java
List<Dish> veg = new ArrayList<>(), nonVeg = new ArrayList<>();
for (Dish d : menu) (d.isVegetarian() ? veg : nonVeg).add(d);   // manual two-bucket split
```

### [6.10] Implement a custom Collector for cases the factories cannot cover

Title: Implement Collector (supplier/accumulator/combiner/finisher/characteristics) when no factory fits.
Description: When the built-in collectors cannot express a reduction (e.g. partitioning primes with a tailored algorithm), implement the `Collector` interface: `supplier` makes the result container, `accumulator` folds an element in, `combiner` merges partial results for parallelism, `finisher` produces the final value, and `characteristics` declares properties (UNORDERED, CONCURRENT, IDENTITY_FINISH). Get the combiner right or parallel collection will be wrong.

**Good example:**

```java
public class ToListCollector<T> implements Collector<T, List<T>, List<T>> {
    public Supplier<List<T>> supplier()            { return ArrayList::new; }
    public BiConsumer<List<T>, T> accumulator()    { return List::add; }
    public BinaryOperator<List<T>> combiner()      { return (a, b) -> { a.addAll(b); return a; }; }
    public Function<List<T>, List<T>> finisher()   { return Function.identity(); }
    public Set<Characteristics> characteristics()  {
        return Set.of(Characteristics.IDENTITY_FINISH, Characteristics.CONCURRENT);
    }
}
```

**Bad example:**

```java
// A custom collector with no combiner / wrong combiner silently corrupts results under parallel use.
public BinaryOperator<List<T>> combiner() { return (a, b) -> a; }   // drops b's elements
```

## Chapter 7 — Parallel Data Processing and Performance

### [7.1] Measure with a harness before going parallel — parallel is not automatically faster

Title: Benchmark sequential vs. parallel (e.g. with JMH) before assuming parallelStream() helps.
Description: `parallelStream()` splits work across the common fork/join pool, but splitting, merging, and boxing have overhead that can make a parallel pipeline slower than sequential — sometimes dramatically (e.g. `Stream.iterate`-based sums). Always measure with a proper harness like JMH on representative data before committing to parallel.

**Good example:**

```java
// Benchmark both; switch to parallel only if measurements justify it.
public long sequentialSum(long n) {
    return LongStream.rangeClosed(1, n).sum();
}
public long parallelSum(long n) {
    return LongStream.rangeClosed(1, n).parallel().sum();   // measured to be faster for large n
}
```

**Bad example:**

```java
// Assuming parallel is faster — iterate doesn't split well and boxes, so this is often slower.
public long parallelSum(long n) {
    return Stream.iterate(1L, i -> i + 1).limit(n).parallel().reduce(0L, Long::sum);
}
```

### [7.2] Avoid shared mutable state in parallel streams

Title: Never mutate shared state from a parallel pipeline; reduce into a result instead.
Description: A lambda that writes to shared mutable state (a field, an array slot, an accumulator object) races when run in parallel, producing wrong, non-deterministic results — and `synchronized` "fixes" it by destroying the parallelism. Use a proper reduction (`sum`, `reduce`, a collector) so each thread works on its own partial result that is then merged.

**Good example:**

```java
long sum = LongStream.rangeClosed(1, n).parallel().sum();   // no shared state; correct in parallel
```

**Bad example:**

```java
class Accumulator { long total = 0; void add(long v) { total += v; } }
Accumulator acc = new Accumulator();
LongStream.rangeClosed(1, n).parallel().forEach(acc::add);   // data race: total is corrupted
```

### [7.3] Prefer primitive streams and splittable sources; avoid boxing and iterate

Title: Feed parallel pipelines from cheaply-splittable, primitive sources like ranges, not iterate.
Description: Parallel performance depends on how well the source splits and whether it boxes. `LongStream.rangeClosed` produces unboxed values and splits evenly, so it parallelizes well; `Stream.iterate` is inherently sequential (each value depends on the previous) and boxes, so it parallelizes badly. Pick the source with parallel-friendliness in mind.

**Good example:**

```java
long sum = LongStream.rangeClosed(1, n).parallel().sum();   // splittable + unboxed
```

**Bad example:**

```java
long sum = Stream.iterate(1L, i -> i + 1).limit(n)
                 .parallel()                  // cannot split effectively; boxes Long
                 .reduce(0L, Long::sum);
```

### [7.4] Use the fork/join framework via RecursiveTask, calling fork/compute/join correctly

Title: Split a task into subtasks with RecursiveTask, forking one branch and computing the other before joining.
Description: The fork/join framework recursively splits a task until subtasks are small enough to run directly, then combines results. The idiom: `fork()` one subtask (queue it for another thread), `compute()` the other in the current thread, then `join()` the forked one. Forking both and joining both immediately wastes a thread; never call `join()` before you have started the other branch.

**Good example:**

```java
class ForkJoinSumCalculator extends RecursiveTask<Long> {
    protected Long compute() {
        if (length <= THRESHOLD) return computeSequentially();
        ForkJoinSumCalculator left  = new ForkJoinSumCalculator(numbers, start, start + length / 2);
        left.fork();                                  // run left asynchronously
        ForkJoinSumCalculator right = new ForkJoinSumCalculator(numbers, start + length / 2, end);
        Long rightResult = right.compute();           // run right in this thread
        Long leftResult  = left.join();               // then join left
        return leftResult + rightResult;
    }
}
```

**Bad example:**

```java
left.fork();
right.fork();              // forking both...
return left.join() + right.join();   // ...then blocking on both wastes the current thread
```

### [7.5] Favor many small fork/join tasks to benefit from work stealing

Title: Choose a threshold that yields more subtasks than cores so idle workers can steal pending tasks.
Description: Fork/join workers each keep a deque of tasks and *steal* from busy workers' deques when idle, balancing load. If tasks are too coarse (fewer than cores) some workers sit idle; if reasonably fine-grained, stealing keeps every core busy. Tune the splitting threshold to produce enough subtasks without making them so tiny that overhead dominates.

**Good example:**

```java
// THRESHOLD chosen so the work splits into many more subtasks than CPU cores -> good stealing.
public static final long THRESHOLD = 10_000;
```

**Bad example:**

```java
// One giant task (or two) — no work to steal; most cores idle.
public static final long THRESHOLD = Long.MAX_VALUE;   // never splits
```

### [7.6] Implement a custom Spliterator to control how a source splits

Title: Provide a Spliterator (tryAdvance/trySplit/estimateSize/characteristics) to parallelize a source that doesn't split naturally.
Description: A `Spliterator` defines how a stream traverses and partitions its source. For sources that the default cannot split well (e.g. counting words in a string by scanning characters), a custom `Spliterator` defines `trySplit` to break the data at safe boundaries, enabling correct parallel processing. Get the split points and characteristics right or parallel results will be wrong.

**Good example:**

```java
class WordCounterSpliterator implements Spliterator<Character> {
    public boolean tryAdvance(Consumer<? super Character> action) { /* feed next char */ return true; }
    public Spliterator<Character> trySplit() {
        // split only at a space so words are never cut in half
        return /* left half ending at a boundary */ null;
    }
    public long estimateSize() { return /* remaining */ 0; }
    public int characteristics() { return ORDERED | SIZED | SUBSIZED | NONNULL | IMMUTABLE; }
}
```

**Bad example:**

```java
// Splitting in the middle of a word miscounts when run in parallel.
public Spliterator<Character> trySplit() {
    return new WordCounterSpliterator(/* split at length/2 regardless of word boundaries */);
}
```

## Chapter 8 — Collection API Enhancements

### [8.1] Create small immutable collections with List.of / Set.of / Map.of factories (Java 9)

Title: Build fixed, immutable collections with the of factory methods instead of constructing and populating mutable ones.
Description: Java 9 added `List.of`, `Set.of`, and `Map.of` for creating small immutable collections in one expression. The result rejects mutation (`add`/`set`/`put` throw `UnsupportedOperationException`) and disallows null elements, protecting you from accidental modification. Prefer them over `new ArrayList<>()` + repeated `add` or `Arrays.asList` when the contents are fixed. (Java 9+.)

**Good example:**

```java
List<String> friends = List.of("Raphael", "Olivia", "Thibaut");
Set<String> uniqueFriends = Set.of("Raphael", "Olivia");
Map<String, Integer> ages = Map.of("Raphael", 30, "Olivia", 25);
```

**Bad example:**

```java
List<String> friends = new ArrayList<>();
friends.add("Raphael");
friends.add("Olivia");
friends.add("Thibaut");   // verbose, and the list stays mutable
```

### [8.2] Build larger maps with Map.ofEntries and Map.entry

Title: Use Map.ofEntries(Map.entry(...), ...) when a map has more entries than the fixed Map.of overloads support.
Description: `Map.of` has overloads only up to ten key–value pairs. For larger immutable maps, `Map.ofEntries` takes any number of `Map.entry(k, v)` objects, keeping the key/value pairing explicit and readable. It still produces an immutable, null-hostile map. (Java 9+.)

**Good example:**

```java
import static java.util.Map.entry;

Map<String, Integer> ageOfFriends = Map.ofEntries(
    entry("Raphael", 30),
    entry("Olivia", 25),
    entry("Thibaut", 26));
```

**Bad example:**

```java
Map<String, Integer> ageOfFriends = new HashMap<>();
ageOfFriends.put("Raphael", 30);
ageOfFriends.put("Olivia", 25);
ageOfFriends.put("Thibaut", 26);   // mutable, verbose, pairing buried in statements
```

### [8.3] Remove elements in place with removeIf instead of an Iterator

Title: Delete matching elements with collection.removeIf(predicate) rather than a manual Iterator loop.
Description: Removing elements from a collection while iterating with a `for-each` throws `ConcurrentModificationException`; the classic fix is a verbose explicit `Iterator` with `it.remove()`. `removeIf(Predicate)` does exactly this safely and declaratively in one line. (Java 8+.)

**Good example:**

```java
transactions.removeIf(t -> Character.isDigit(t.getReferenceCode().charAt(0)));
```

**Bad example:**

```java
for (Transaction t : transactions) {
    if (Character.isDigit(t.getReferenceCode().charAt(0))) {
        transactions.remove(t);   // ConcurrentModificationException
    }
}
```

### [8.4] Transform list elements in place with replaceAll

Title: Update every element of a List with list.replaceAll(UnaryOperator) instead of a ListIterator set loop.
Description: To replace each element with a transformed value *in place*, `List.replaceAll(UnaryOperator)` applies the function to every slot. A stream `map` produces a *new* list; `replaceAll` mutates the existing one without an explicit `ListIterator`. (Java 8+.)

**Good example:**

```java
List<String> codes = new ArrayList<>(List.of("a12", "C14", "b13"));
codes.replaceAll(code -> Character.toUpperCase(code.charAt(0)) + code.substring(1));
```

**Bad example:**

```java
for (ListIterator<String> it = codes.listIterator(); it.hasNext(); ) {
    String code = it.next();
    it.set(Character.toUpperCase(code.charAt(0)) + code.substring(1));   // verbose ListIterator
}
```

### [8.5] Iterate maps with forEach(BiConsumer) instead of entrySet loops

Title: Walk a map's entries with map.forEach((k, v) -> ...) rather than looping over entrySet().
Description: `Map.forEach` takes a `BiConsumer` of key and value, expressing "do this for each entry" without the `Map.Entry` boilerplate of an `entrySet` loop. It is shorter and reads as the intent. (Java 8+.)

**Good example:**

```java
ageOfFriends.forEach((friend, age) -> System.out.println(friend + " is " + age));
```

**Bad example:**

```java
for (Map.Entry<String, Integer> e : ageOfFriends.entrySet()) {
    System.out.println(e.getKey() + " is " + e.getValue());   // Entry boilerplate
}
```

### [8.6] Sort map entries with Entry.comparingByKey / comparingByValue

Title: Stream a map's entrySet and sort with the ready-made Entry comparators.
Description: `Entry.comparingByKey()` and `Entry.comparingByValue()` provide comparators for sorting map entries, so you can produce an ordered view (e.g. a `LinkedHashMap` or a sorted printout) without writing a custom `Comparator` over `Map.Entry`. (Java 8+.)

**Good example:**

```java
favouriteMovies.entrySet().stream()
    .sorted(Entry.comparingByKey())
    .forEachOrdered(System.out::println);
```

**Bad example:**

```java
List<Map.Entry<String, String>> entries = new ArrayList<>(favouriteMovies.entrySet());
entries.sort(new Comparator<Map.Entry<String, String>>() {
    public int compare(Map.Entry<String, String> a, Map.Entry<String, String> b) {
        return a.getKey().compareTo(b.getKey());   // hand-rolled entry comparator
    }
});
```

### [8.7] Read map values safely with getOrDefault

Title: Use getOrDefault to supply a fallback when a key is absent, instead of a manual containsKey/get check.
Description: `getOrDefault(key, default)` returns the mapped value, or the supplied default when the key is missing — collapsing the classic `containsKey`-then-`get` idiom into one call. Note it still returns a stored `null` if the key maps to `null`. (Java 8+.)

**Good example:**

```java
Map<String, String> movies = Map.of("Raphael", "Star Wars", "Olivia", "James Bond");
String forCarmen = movies.getOrDefault("Carmen", "Matrix");   // "Matrix"
```

**Bad example:**

```java
String forCarmen = movies.containsKey("Carmen") ? movies.get("Carmen") : "Matrix";
```

### [8.8] Implement caching with computeIfAbsent (and computeIfPresent / compute)

Title: Populate-on-demand and cache with computeIfAbsent rather than a get/null-check/put dance.
Description: `computeIfAbsent(key, k -> value)` computes and stores a value only when the key is missing (or maps to null), returning the present-or-new value — perfect for caches and for "map of lists" accumulation. `computeIfPresent` updates only when present; `compute` recomputes unconditionally. They replace error-prone manual checks. (Java 8+.)

**Good example:**

```java
Map<String, List<String>> friendsToMovies = new HashMap<>();
friendsToMovies.computeIfAbsent("Raphael", name -> new ArrayList<>())
               .add("Star Wars");

Map<String, byte[]> cache = new HashMap<>();
byte[] hash = cache.computeIfAbsent(key, this::calculateDigest);   // cache miss computes once
```

**Bad example:**

```java
if (!friendsToMovies.containsKey("Raphael")) {
    friendsToMovies.put("Raphael", new ArrayList<>());   // get/check/put boilerplate
}
friendsToMovies.get("Raphael").add("Star Wars");
```

### [8.9] Aggregate map values with merge instead of manual null checks

Title: Combine an existing value with a new one using map.merge(key, value, remapping) — handling the absent case for you.
Description: `merge(key, value, BiFunction)` stores `value` if the key is absent, otherwise applies the remapping function to the old and new values. It cleanly expresses counters and accumulations (word counts, running totals) without separate "first time vs. subsequent" branches. (Java 8+.)

**Good example:**

```java
Map<String, Long> wordCount = new HashMap<>();
for (String word : words) {
    wordCount.merge(word, 1L, Long::sum);   // initialize to 1, else add 1
}
```

**Bad example:**

```java
Map<String, Long> wordCount = new HashMap<>();
for (String word : words) {
    Long n = wordCount.get(word);
    if (n == null) wordCount.put(word, 1L);
    else wordCount.put(word, n + 1L);       // manual first-time/else branch
}
```

### [8.10] Use ConcurrentHashMap bulk operations (reduce / search / forEach) and concurrent set views

Title: Aggregate a ConcurrentHashMap with forEach/reduce/search and obtain a concurrent set with newKeySet.
Description: `ConcurrentHashMap` adds parallel-friendly bulk operations — `forEach`, `reduce`, and `search` (each with key/value/entry variants and a parallelism threshold) — that operate without locking the whole map. `keySet`/`newKeySet` give a concurrent `Set` view. Use these for concurrent aggregation; choose the threshold to control when work goes parallel. (Java 8+.)

**Good example:**

```java
ConcurrentHashMap<String, Long> map = new ConcurrentHashMap<>();
long parallelismThreshold = 1;
Optional<Long> maxValue = Optional.ofNullable(
    map.reduceValues(parallelismThreshold, Long::max));

Set<String> concurrentSet = ConcurrentHashMap.newKeySet();   // concurrent Set
```

**Bad example:**

```java
// Manually locking and iterating defeats ConcurrentHashMap's design and serializes access.
long max = Long.MIN_VALUE;
synchronized (map) {
    for (Long v : map.values()) max = Math.max(max, v);
}
```

## Chapter 9 — Refactoring, Testing, and Debugging

### [9.1] Refactor anonymous classes to lambdas (mind this/shadowing/ambiguous context)

Title: Convert single-method anonymous classes to lambdas, but watch the semantic differences.
Description: Anonymous classes implementing one method become lambdas, removing boilerplate. Beware three differences: in an anonymous class `this` refers to the anonymous instance, in a lambda it refers to the enclosing instance; an anonymous class can shadow enclosing variables while a lambda cannot; and a lambda's type is resolved by context, so an explicit cast may be needed where overloads make the target type ambiguous.

**Good example:**

```java
Runnable r = () -> System.out.println("Hello");
// where overloads make the target type ambiguous, disambiguate with a cast:
execute((Task) () -> System.out.println("Danger danger!!"));
```

**Bad example:**

```java
Runnable r = new Runnable() {
    public void run() { System.out.println("Hello"); }   // boilerplate single-method class
};
```

### [9.2] Refactor lambdas to method references and built-in collectors

Title: Promote a lambda that just names an operation to a method reference, and reuse helper methods/collectors.
Description: When a lambda merely calls one method or extracts a field, a method reference reads better and signals reuse; pushing comparison/extraction logic into a named helper or a built-in collector (`groupingBy`, `summingInt`) removes hand-rolled accumulation. The result is shorter and states intent.

**Good example:**

```java
Map<CaloricLevel, List<Dish>> byLevel =
    menu.stream().collect(groupingBy(Dish::getCaloricLevel));   // method ref + collector
inventory.sort(comparing(Apple::getWeight));
```

**Bad example:**

```java
Map<CaloricLevel, List<Dish>> byLevel =
    menu.stream().collect(groupingBy(dish -> {           // inlined classification + manual feel
        if (dish.getCalories() <= 400) return CaloricLevel.DIET;
        else if (dish.getCalories() <= 700) return CaloricLevel.NORMAL;
        else return CaloricLevel.FAT;
    }));
```

### [9.3] Refactor imperative data processing to the Streams API

Title: Replace filter+accumulate loops with a stream pipeline that states the query.
Description: Imperative collection processing interleaves filtering, transformation, and accumulation, obscuring intent and resisting parallelization. Rewriting as a stream pipeline (`filter`/`map`/`sorted`/`collect`) makes the query obvious and lets the library optimize and optionally parallelize it.

**Good example:**

```java
List<String> dishNames =
    menu.parallelStream()
        .filter(d -> d.getCalories() > 300)
        .map(Dish::getName)
        .collect(toList());
```

**Bad example:**

```java
List<String> dishNames = new ArrayList<>();
for (Dish dish : menu) {
    if (dish.getCalories() > 300) dishNames.add(dish.getName());   // intent buried in control flow
}
```

### [9.4] Improve flexibility with conditional deferred execution and execute-around

Title: Pass behavior as a lambda so callers defer or customize work (conditional deferred execution, execute-around).
Description: Two flexibility patterns fall out of behavior parameterization. *Conditional deferred execution* passes a `Supplier` so an expensive message is built only when needed (e.g. a logger that checks the level first). *Execute-around* wraps shared setup/teardown around a lambda. Both keep callers from being exposed to internal state or duplicated boilerplate.

**Good example:**

```java
// Logger only builds the message if FINER is enabled:
logger.log(Level.FINER, () -> "Problem: " + generateDiagnostic());
```

**Bad example:**

```java
if (logger.isLoggable(Level.FINER)) {                 // caller must know the level machinery
    logger.log(Level.FINER, "Problem: " + generateDiagnostic());   // and message built eagerly otherwise
}
```

### [9.5] Replace boilerplate OO design patterns with lambdas

Title: Implement Strategy, Template Method, Observer, Chain of Responsibility, and Factory with lambdas instead of class hierarchies.
Description: Many Gang-of-Four patterns exist to inject behavior — exactly what lambdas provide. A Strategy becomes a passed `Predicate`/`Function`; a Factory becomes a `Map<String, Supplier<T>>` of constructor references; Chain of Responsibility becomes `Function.andThen` composition. The intent survives with far less ceremony.

**Good example:**

```java
// Factory with a map of constructor references instead of a switch + subclasses:
Map<String, Supplier<Product>> map = Map.of(
    "loan", Loan::new,
    "stock", Stock::new,
    "bond", Bond::new);

Product createProduct(String name) {
    Supplier<Product> p = map.get(name);
    if (p != null) return p.get();
    throw new IllegalArgumentException("No such product " + name);
}
```

**Bad example:**

```java
Product createProduct(String name) {
    switch (name) {                       // grows with every new product; no reuse
        case "loan":  return new Loan();
        case "stock": return new Stock();
        case "bond":  return new Bond();
        default: throw new IllegalArgumentException("No such product " + name);
    }
}
```

### [9.6] Test the behavior of a visible lambda and the method that uses it

Title: Unit-test a lambda by assigning it to an accessible field, or by testing the method that consumes it.
Description: A lambda has no name, so you cannot call it directly in a test. If the lambda is stored in a static/visible field (e.g. a `Comparator` constant), test it through that reference; otherwise test the *behavior* of the method that uses the lambda, treating the lambda as an implementation detail.

**Good example:**

```java
// Lambda exposed as a constant — test it directly:
public static final Comparator<Point> COMPARE_BY_X = comparing(Point::getX);

@Test
void testComparingTwoPoints() {
    int result = Point.COMPARE_BY_X.compare(new Point(10, 15), new Point(20, 25));
    assertTrue(result < 0);
}
```

**Bad example:**

```java
@Test
void testLambda() {
    // Trying to reach an inline lambda that lives inside moveAllPointsRightBy(...) — not addressable.
    // (You cannot reference an anonymous inline lambda from the test.)
}
```

### [9.7] Pull complex lambdas into named methods to make them testable

Title: Extract a non-trivial lambda body into a method reference so it can be tested and reused.
Description: Long or complex lambdas are hard to read and impossible to test in isolation. Move the body into a named method and pass it as a method reference; the logic is now unit-testable on its own and the pipeline reads as a sequence of named steps.

**Good example:**

```java
public static boolean isExpensive(Dish d) { return d.getCalories() > 700; }   // testable

List<Dish> expensive = menu.stream().filter(Dish::isExpensive).collect(toList());
```

**Bad example:**

```java
List<Dish> expensive = menu.stream()
    .filter(d -> { /* many lines of logic */ return d.getCalories() > 700; })  // untestable inline
    .collect(toList());
```

### [9.8] Debug stream pipelines with peek() instead of consuming the stream

Title: Inspect elements flowing through a pipeline with peek(), keeping the stream intact for the terminal op.
Description: You cannot set a breakpoint "inside" a fused pipeline easily, and adding a `forEach(System.out::println)` consumes the stream so later operations fail. `peek` performs a side effect (logging) on each element as it flows through *without* consuming it, letting you watch every stage while the pipeline still terminates normally. Remove `peek` calls before shipping.

**Good example:**

```java
List<Integer> result =
    Stream.of(2, 3, 4, 5)
          .peek(x -> System.out.println("taking from stream: " + x))
          .map(x -> x + 17)
          .peek(x -> System.out.println("after map: " + x))
          .filter(x -> x % 2 == 0)
          .collect(toList());
```

**Bad example:**

```java
Stream<Integer> s = Stream.of(2, 3, 4, 5).map(x -> x + 17);
s.forEach(System.out::println);     // consumes the stream for debugging...
s.filter(x -> x % 2 == 0).collect(toList());   // IllegalStateException: already operated upon
```

## Chapter 10 — Domain-Specific Languages Using Lambdas

### [10.1] Weigh the pros and cons before introducing a DSL

Title: Adopt an internal DSL only when readability for the domain outweighs the design and learning cost.
Description: A DSL gives a small, focused language tailored to a domain so business logic reads close to the problem statement and is harder to get subtly wrong. But DSLs cost design effort, add a learning curve, and can obscure what the code really does. Introduce one when the domain is expressed repeatedly and clarity for non-author readers matters; otherwise a plain API is fine.

**Good example:**

```java
// Reads like the domain — clear to a trader reviewing it:
Order order = forCustomer("BigBank",
    buy(t -> t.quantity(80).stock("IBM").on("NYSE").at(125.00)),
    sell(t -> t.quantity(50).stock("GOOGLE").on("NASDAQ").at(375.00)));
```

**Bad example:**

```java
// Imperative wiring: correct but noisy and easy to mis-assemble.
Order order = new Order();
order.setCustomer("BigBank");
Trade t1 = new Trade(); t1.setType(Trade.Type.BUY);
Stock s1 = new Stock(); s1.setSymbol("IBM"); s1.setMarket("NYSE");
t1.setStock(s1); t1.setPrice(125.00); t1.setQuantity(80);
order.addTrade(t1);
```

### [10.2] Recognize the Stream and Collector APIs as internal DSLs

Title: Treat fluent JDK APIs like Stream and Collectors as model internal DSLs and follow their style.
Description: The Stream API is effectively a small internal DSL for manipulating collections, and nested `Collectors` (e.g. `groupingBy` with a downstream collector) form a DSL for aggregation. Studying how they read top-to-bottom and compose is the template for designing your own fluent APIs.

**Good example:**

```java
Map<Boolean, Map<Boolean, List<Dish>>> dishes =
    menu.stream().collect(
        partitioningBy(Dish::isVegetarian,
            partitioningBy(d -> d.getCalories() > 500)));   // collectors compose like a DSL
```

**Bad example:**

```java
// Hand-rolled nested grouping — works, but throws away the fluent collector DSL.
Map<Boolean, Map<Boolean, List<Dish>>> dishes = new HashMap<>();
for (Dish d : menu) {
    dishes.computeIfAbsent(d.isVegetarian(), k -> new HashMap<>())
          .computeIfAbsent(d.getCalories() > 500, k -> new ArrayList<>())
          .add(d);
}
```

### [10.3] Build a fluent API with method chaining

Title: Return the builder (or a sub-builder) from each setter so calls chain into a readable sentence.
Description: Method chaining is the most common internal-DSL technique: each configuration method returns `this` (or a nested builder), so calls flow as one expression. It reads well and guides the user, at the cost of more builder boilerplate to write.

**Good example:**

```java
Order order = builder.forCustomer("BigBank")
    .buy(80).stock("IBM").on("NYSE").at(125.00)
    .sell(50).stock("GOOGLE").on("NASDAQ").at(375.00)
    .end();
```

**Bad example:**

```java
// void setters break the flow — the reader loses the "sentence".
builder.setCustomer("BigBank");
builder.beginBuy(80);
builder.setStock("IBM");
builder.setMarket("NYSE");
builder.setPrice(125.00);
```

### [10.4] Structure a DSL with nested functions

Title: Use static factory methods that nest as arguments to mirror the domain's structure.
Description: The nested-function technique builds the object tree with static helpers used as arguments — `forCustomer(..., buy(stock(...), at(...)), ...)`. The nesting visually reflects the hierarchy (order contains trades contains stock). It needs no builder state, though deep nesting and many parentheses can hurt readability.

**Good example:**

```java
Order order = order("BigBank",
    buy(80, stock("IBM", on("NYSE")), at(125.00)),
    sell(50, stock("GOOGLE", on("NASDAQ")), at(375.00)));
```

**Bad example:**

```java
// Flattening the hierarchy into positional args loses the structure and is order-fragile.
Order order = order("BigBank", "BUY", 80, "IBM", "NYSE", 125.00,
                              "SELL", 50, "GOOGLE", "NASDAQ", 375.00);
```

### [10.5] Sequence configuration with lambda expressions (Consumer-based builders)

Title: Accept Consumer lambdas that configure a fresh builder, so steps read as a sequence without repeating the receiver.
Description: The lambda (function-sequencing) technique passes `Consumer<Builder>` lambdas; each lambda receives a fresh builder and sets its fields. It avoids repeating the receiver and lets the structure nest naturally, though it introduces lambda/builder noise. Combine with the other techniques as appropriate.

**Good example:**

```java
Order order = LambdaOrderBuilder.order(o -> {
    o.forCustomer("BigBank");
    o.buy(t -> { t.quantity(80); t.stock("IBM"); t.on("NYSE"); t.at(125.00); });
    o.sell(t -> { t.quantity(50); t.stock("GOOGLE"); t.on("NASDAQ"); t.at(375.00); });
});
```

**Bad example:**

```java
// Repeating the receiver on every line is exactly the noise the Consumer DSL removes.
OrderBuilder o = new OrderBuilder();
o.forCustomer("BigBank");
o.buyQuantity(80); o.buyStock("IBM"); o.buyMarket("NYSE"); o.buyPrice(125.00);
```

### [10.6] Combine method chaining, nested functions, and lambda sequencing

Title: Mix DSL techniques so each part of the model uses the style that reads best.
Description: Real DSLs are rarely pure: the book's tax example combines a fluent entry point, nested functions, and lambdas. Pick the technique that makes each layer clearest — chaining for linear configuration, nesting for hierarchy, lambdas for grouped steps — rather than forcing one style everywhere.

**Good example:**

```java
double value = forCustomer("BigBank",
    buy(t -> t.quantity(80).stock("IBM").on("NYSE").at(125.00)),   // lambda inside nested function
    sell(t -> t.quantity(50).stock("GOOGLE").on("NASDAQ").at(375.00)));
```

**Bad example:**

```java
// Forcing everything through one rigid style makes some parts awkward and unreadable.
Order order = b.set("customer", "BigBank").set("trade1.type", "BUY")
               .set("trade1.qty", "80").set("trade1.stock", "IBM"); // stringly-typed, brittle
```

### [10.7] Use method references in a DSL

Title: Compose configurable behavior (e.g. tax calculators) with method references and functional combinators.
Description: Method references make a DSL's building blocks first-class and composable. The book's tax DSL toggles taxes by composing `UnaryOperator`s/`DoubleUnaryOperator`s via method references (`Tax::regional`, `Tax::surcharge`), so `with(Tax::regional).and(Tax::surcharge)` reads naturally and each tax stays an independent, testable function.

**Good example:**

```java
double value = new TaxCalculator()
    .with(Tax::regional)
    .with(Tax::surcharge)
    .calculate(order);
```

**Bad example:**

```java
// Boolean flags instead of composable functions — unreadable and not extensible.
double value = calculate(order, true, false, true);   // which flag is which tax?
```

## Chapter 11 — Using Optional as a Better Alternative to null

### [11.1] Model the structural absence of a value with Optional<T> instead of null

Title: Declare possibly-absent values and return types as Optional<T> so the type system documents absence.
Description: Replacing a nullable reference (e.g. `Car insurance`) with `Optional<Insurance>` makes "may be missing" part of the type, forcing callers to deal with the empty case and removing a class of `NullPointerException`s. Use it especially for the *optional* fields in a domain model and for return types that may legitimately produce nothing.

**Good example:**

```java
public class Person {
    private Optional<Car> car;          // a person may not own a car — made explicit
    public Optional<Car> getCar() { return car; }
}
public class Car {
    private Optional<Insurance> insurance;
    public Optional<Insurance> getInsurance() { return insurance; }
}
```

**Bad example:**

```java
public class Person {
    private Car car;                    // null means "no car" — invisible in the type
    public Car getCar() { return car; }
}
```

### [11.2] Create Optionals with empty / of / ofNullable according to the source value

Title: Pick the right factory: empty() for none, of(x) when x is non-null, ofNullable(x) when x may be null.
Description: `Optional.empty()` is the shared empty instance; `Optional.of(value)` wraps a value you know is non-null (and throws NPE immediately if it is null — a useful fail-fast); `Optional.ofNullable(value)` produces empty when the value is null. Choosing the right one expresses your assumption about the value precisely.

**Good example:**

```java
Optional<Car> emptyCar = Optional.empty();
Optional<Insurance> known = Optional.of(insurance);          // insurance is definitely non-null
Optional<String> maybe = Optional.ofNullable(map.get(key));  // map.get may return null
```

**Bad example:**

```java
Optional<String> maybe = Optional.of(map.get(key));   // throws NPE the moment get() returns null
```

### [11.3] Extract and transform values with map

Title: Apply Optional.map to read or transform the contained value without unwrapping it.
Description: `Optional.map(Function)` applies the function if a value is present and returns a new `Optional`, or stays empty otherwise — exactly like `Stream.map` over a zero-or-one element. It replaces a present-check followed by a `get` for simple field extraction.

**Good example:**

```java
Optional<Insurance> opt = Optional.ofNullable(insurance);
Optional<String> name = opt.map(Insurance::getName);   // empty stays empty
```

**Bad example:**

```java
Optional<Insurance> opt = Optional.ofNullable(insurance);
String name = opt.isPresent() ? opt.get().getName() : null;   // isPresent/get + null again
```

### [11.4] Chain Optional-returning calls with flatMap instead of nested null checks

Title: Compose Optional-returning steps with flatMap so an absent value short-circuits the whole chain.
Description: When each step itself returns an `Optional`, `map` would give you `Optional<Optional<...>>`; `flatMap` unwraps one level so the chain stays flat and short-circuits to empty if any step is absent. This collapses deeply nested null checks into one null-safe pipeline.

**Good example:**

```java
public String getCarInsuranceName(Optional<Person> person) {
    return person.flatMap(Person::getCar)
                 .flatMap(Car::getInsurance)
                 .map(Insurance::getName)
                 .orElse("Unknown");
}
```

**Bad example:**

```java
public String getCarInsuranceName(Person person) {
    if (person != null) {
        Car car = person.getCar();
        if (car != null) {
            Insurance insurance = car.getInsurance();
            if (insurance != null) return insurance.getName();
        }
    }
    return "Unknown";   // deeply nested null checks
}
```

### [11.5] Manipulate a stream of Optionals with Optional::stream (Java 9)

Title: Flatten a Stream<Optional<T>> to the present values with flatMap(Optional::stream).
Description: When a `map` step produces `Optional`s, you get a `Stream<Optional<T>>`; `Optional::stream` (Java 9) turns each into a zero-or-one element stream, so `flatMap(Optional::stream)` keeps only the present values in one idiomatic step — cleaner than `filter(Optional::isPresent).map(Optional::get)`. (Java 9+.)

**Good example:**

```java
Set<String> names = persons.stream()
    .map(Person::getCar)                    // Stream<Optional<Car>>
    .map(opt -> opt.flatMap(Car::getInsurance))
    .map(opt -> opt.map(Insurance::getName))
    .flatMap(Optional::stream)              // drop empties, unwrap present (Java 9)
    .collect(toSet());
```

**Bad example:**

```java
Set<String> names = persons.stream()
    .map(Person::getCar)
    .map(opt -> opt.flatMap(Car::getInsurance))
    .map(opt -> opt.map(Insurance::getName))
    .filter(Optional::isPresent)            // two-step unwrap
    .map(Optional::get)
    .collect(toSet());
```

### [11.6] Choose the right default/throw strategy; never call get() unguarded

Title: Unwrap with orElse / orElseGet / orElseThrow / ifPresent, not a bare get().
Description: `get()` throws `NoSuchElementException` if empty, so calling it without checking is just `null` dereferencing in disguise. Use `orElse(default)` for an eager fallback, `orElseGet(Supplier)` when the fallback is expensive or should be lazy, `orElseThrow(...)` to fail with a chosen exception, and `ifPresent`/`ifPresentOrElse` to act without returning a value.

**Good example:**

```java
String name = optInsurance.map(Insurance::getName).orElse("Unknown");
Insurance ins = optInsurance.orElseThrow(() -> new IllegalStateException("no insurance"));
optInsurance.ifPresent(System.out::println);
```

**Bad example:**

```java
String name = optInsurance.get().getName();   // NoSuchElementException if empty — unguarded get()
```

### [11.7] Combine two Optionals with flatMap/map instead of isPresent/get

Title: Combine two Optionals into one with a.flatMap(x -> b.map(y -> combine(x, y))).
Description: To produce a result only when *both* optionals are present, `flatMap` on the first and `map` on the second yields a single `Optional` that is empty if either input is empty — no explicit presence checks. This expresses "if I have both, compute; otherwise nothing" in one expression.

**Good example:**

```java
public Optional<Insurance> nullSafeFindCheapest(Optional<Person> person, Optional<Car> car) {
    return person.flatMap(p -> car.map(c -> findCheapestInsurance(p, c)));
}
```

**Bad example:**

```java
public Optional<Insurance> nullSafeFindCheapest(Optional<Person> person, Optional<Car> car) {
    if (person.isPresent() && car.isPresent()) {                 // manual double check
        return Optional.of(findCheapestInsurance(person.get(), car.get()));
    }
    return Optional.empty();
}
```

### [11.8] Reject unwanted values with filter

Title: Use Optional.filter(predicate) to keep the value only when it satisfies a condition.
Description: `filter` returns the same `Optional` if the value is present and matches the predicate, or empty otherwise. It folds a present-check plus a condition into one step — for example, "the insurance, but only if its name is Cambridge."

**Good example:**

```java
optInsurance
    .filter(ins -> "CambridgeInsurance".equals(ins.getName()))
    .ifPresent(x -> System.out.println("ok"));
```

**Bad example:**

```java
if (insurance != null && "CambridgeInsurance".equals(insurance.getName())) {
    System.out.println("ok");   // null check + condition by hand
}
```

### [11.9] Wrap null-returning and exception-throwing legacy APIs in Optional helpers

Title: Adapt APIs that return null or throw (Map.get, Integer.parseInt) into methods that return Optional.
Description: Bridge legacy APIs at the boundary: wrap a possibly-null result with `Optional.ofNullable`, and convert a checked/unchecked-throwing call (like `Integer.parseInt`) into an `Optional` with a small try/catch helper. Callers then get a uniform, null-safe `Optional` surface instead of mixed null/exception behavior.

**Good example:**

```java
public static Optional<Integer> stringToInt(String s) {
    try {
        return Optional.of(Integer.parseInt(s));
    } catch (NumberFormatException e) {
        return Optional.empty();   // empty instead of an exception for unparsable input
    }
}
```

**Bad example:**

```java
public static int stringToInt(String s) {
    return Integer.parseInt(s);   // throws NumberFormatException; callers must wrap every call
}
```

### [11.10] Do not use Optional for fields, parameters, or collections; avoid primitive Optionals

Title: Reserve Optional for return types signaling absence; do not use it for fields, parameters, or as collection element/value types, and avoid OptionalInt/Long/Double for streamy code.
Description: `Optional` is not `Serializable` and adds wrapping cost, so it is a poor choice for fields and method parameters (overload or use null/empty collections there). Never wrap a collection in `Optional` — return an empty collection instead. And `OptionalInt`/`OptionalLong`/`OptionalDouble` lack `map`/`flatMap`/`filter`, so they don't compose; prefer `Optional<Integer>` when you need those (or a primitive stream).

**Good example:**

```java
public List<String> getNames() {
    return names == null ? Collections.emptyList() : names;   // empty collection, not Optional
}
```

**Bad example:**

```java
public Optional<List<String>> getNames() { ... }   // wrapping a collection in Optional — anti-pattern
public void setCar(Optional<Car> car) { ... }       // Optional as a parameter — avoid
```

## Chapter 12 — New Date and Time API

### [12.1] Use immutable java.time types instead of mutable Date/Calendar

Title: Represent dates and times with LocalDate/LocalTime/LocalDateTime, not java.util.Date or Calendar.
Description: `java.util.Date` and `Calendar` are mutable, not thread-safe, and have error-prone APIs (0-based months, year offset from 1900). The `java.time` types are immutable and value-based, so they are safe to share and reason about. Use `LocalDate` for a date, `LocalTime` for a time, and `LocalDateTime` for both.

**Good example:**

```java
LocalDate date = LocalDate.of(2017, 9, 21);   // intuitive: month is 9, year is 2017
int year = date.getYear();
DayOfWeek dow = date.getDayOfWeek();           // THURSDAY
```

**Bad example:**

```java
Date date = new Date(117, 8, 21);   // year - 1900 = 117, month 8 = September — confusing and mutable
```

### [12.2] Create with of/parse and read fields with getters or TemporalField

Title: Build java.time values with of/parse and read them with typed getters (or get(ChronoField)).
Description: Construct values from components with `of`, or from text with `parse`; read components with intention-revealing getters (`getYear`, `getMonthValue`, `getDayOfMonth`) or generically with `get(ChronoField.…)`. This is clearer and safer than `Calendar.get(Calendar.MONTH)` with its constants and off-by-one surprises.

**Good example:**

```java
LocalDate d = LocalDate.parse("2017-09-21");
int month = d.getMonthValue();                 // 9
int dayOfYear = d.get(ChronoField.DAY_OF_YEAR);
```

**Bad example:**

```java
Calendar c = Calendar.getInstance();
int month = c.get(Calendar.MONTH) + 1;   // must remember the +1 for human month
```

### [12.3] Use Instant for machine time and Duration/Period for amounts of time

Title: Measure machine timestamps with Instant, and amounts of time with Duration (time-based) or Period (date-based).
Description: `Instant` represents a point on the machine timeline (seconds/nanos from the epoch) — use it for timestamps and elapsed measurement, not for human calendar fields. `Duration` measures a quantity of time between two `Instant`s/`LocalTime`s (hours, seconds), while `Period` measures a quantity in date terms (years, months, days). Pick the one matching the unit you mean.

**Good example:**

```java
Duration d = Duration.between(start, end);            // time-based amount
Period tenDays = Period.between(LocalDate.of(2017, 9, 11), LocalDate.of(2017, 9, 21));  // date-based
Instant now = Instant.now();
```

**Bad example:**

```java
long ms = end.getTime() - start.getTime();   // raw millis on java.util.Date — unit-unsafe and mutable
```

### [12.4] Manipulate dates immutably with plus/minus/with and TemporalAdjusters

Title: Derive new values with plus/minus/withYear and TemporalAdjusters; never mutate in place.
Description: Because `java.time` types are immutable, methods like `plusWeeks`, `minusYears`, and `withDayOfMonth` return *new* values — assign the result. For complex rules (next Sunday, last day of month), `TemporalAdjusters` provides ready-made adjusters and you can write your own. This avoids the mutate-and-forget bugs of `Calendar`.

**Good example:**

```java
import static java.time.temporal.TemporalAdjusters.*;

LocalDate date = LocalDate.of(2017, 9, 21);
LocalDate later = date.plusWeeks(1).withYear(2011).minusDays(2);   // new value each step
LocalDate nextSunday = date.with(nextOrSame(DayOfWeek.SUNDAY));
```

**Bad example:**

```java
LocalDate date = LocalDate.of(2017, 9, 21);
date.plusWeeks(1);   // result discarded — immutability means this line does nothing useful
```

### [12.5] Format and parse with thread-safe DateTimeFormatter, not SimpleDateFormat

Title: Use the immutable, thread-safe DateTimeFormatter for printing and parsing dates.
Description: `SimpleDateFormat` is mutable and not thread-safe, so sharing one instance across threads corrupts output — a classic production bug. `DateTimeFormatter` is immutable and thread-safe, can be declared as a constant, and offers predefined and pattern-based formatters with locale support.

**Good example:**

```java
static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
String text = LocalDate.of(2017, 9, 21).format(FMT);
LocalDate date = LocalDate.parse("21/09/2017", FMT);   // safe to share FMT across threads
```

**Bad example:**

```java
static final SimpleDateFormat SDF = new SimpleDateFormat("dd/MM/yyyy");   // shared + mutable
// concurrent format()/parse() calls corrupt each other's state
```

### [12.6] Handle time zones with ZoneId/ZonedDateTime, not java.util.TimeZone

Title: Apply time zones with the immutable ZoneId and combine into ZonedDateTime/OffsetDateTime.
Description: `ZoneId` is the immutable replacement for `java.util.TimeZone`; applying it to a `LocalDate`/`LocalDateTime`/`Instant` yields a `ZonedDateTime` representing an instant in a specific region, and `ZoneOffset` handles fixed offsets from UTC. This makes zone handling explicit and immutable instead of fiddling with mutable `Calendar`/`TimeZone`.

**Good example:**

```java
ZoneId romeZone = ZoneId.of("Europe/Rome");
ZonedDateTime zdt = LocalDate.of(2017, 9, 21).atStartOfDay(romeZone);
ZonedDateTime fromInstant = Instant.now().atZone(romeZone);
```

**Bad example:**

```java
TimeZone tz = TimeZone.getTimeZone("Europe/Rome");
Calendar c = Calendar.getInstance(tz);   // mutable TimeZone + Calendar; awkward and not thread-safe
```

## Chapter 13 — Default Methods

### [13.1] Evolve published interfaces with default methods to preserve backward compatibility

Title: Add new interface methods as default methods so all existing implementors keep compiling and running.
Description: Adding an abstract method to a released interface is a binary- and source-incompatible change that breaks every implementor. A `default` method provides an implementation in the interface itself, so existing classes inherit it without modification — this is exactly how `List.sort` and `Collection.stream` were added in Java 8.

**Good example:**

```java
public interface Resizable extends Drawable {
    int getWidth();
    int getHeight();
    void setWidth(int width);
    void setHeight(int height);
    void setAbsoluteSize(int width, int height);
    default void setRelativeSize(int wFactor, int hFactor) {     // added without breaking implementors
        setAbsoluteSize(getWidth() / wFactor, getHeight() / hFactor);
    }
}
```

**Bad example:**

```java
public interface Resizable extends Drawable {
    // ... existing methods ...
    void setRelativeSize(int wFactor, int hFactor);   // new abstract method breaks every implementor
}
```

### [13.2] Use default methods as optional methods to remove empty boilerplate implementations

Title: Provide a do-nothing (or sensible) default for rarely-needed interface methods so implementors skip empty overrides.
Description: Some interface methods are seldom meaningful for a given implementor (e.g. `Iterator.remove`). A default implementation lets classes that don't need it avoid writing an empty or throwing stub, reducing boilerplate while keeping the method available to those who do.

**Good example:**

```java
public interface Iterator<T> {
    boolean hasNext();
    T next();
    default void remove() {            // optional: implementors needn't provide an empty body
        throw new UnsupportedOperationException("remove");
    }
}
```

**Bad example:**

```java
class MyIterator implements Iterator<String> {
    public boolean hasNext() { /* ... */ return false; }
    public String next() { /* ... */ return null; }
    public void remove() { }           // empty stub repeated in every implementor
}
```

### [13.3] Compose minimal, orthogonal interfaces for multiple inheritance of behavior

Title: Split behavior into small interfaces with default methods and implement several to compose capabilities.
Description: Because a class can implement many interfaces and inherit each one's default methods, you get multiple inheritance of *behavior* (not state). Designing small, orthogonal interfaces (`Rotatable`, `Moveable`, `Resizable`) lets a class pick exactly the capabilities it needs and update them in one place.

**Good example:**

```java
public interface Rotatable {
    void setRotationAngle(int angleInDegrees);
    int getRotationAngle();
    default void rotateBy(int angleInDegrees) {     // shared behavior, inherited by all implementors
        setRotationAngle((getRotationAngle() + angleInDegrees) % 360);
    }
}
class Monster implements Rotatable, Moveable, Resizable { /* gains rotateBy/moveBy/resize free */ }
```

**Bad example:**

```java
// Repeating rotateBy/moveBy logic in every shape class instead of inheriting it from interfaces.
class Monster {
    int angle;
    void rotateBy(int by) { angle = (angle + by) % 360; }   // duplicated in Sun, Hero, ...
}
```

### [13.4] Apply the three resolution rules and X.super.method() to disambiguate conflicting defaults

Title: Know that classes win over interfaces, more-specific subinterfaces win next, and otherwise you must explicitly choose with X.super.method().
Description: When multiple supertypes provide a default for the same signature, Java resolves it by three rules: (1) a method declared in a class or superclass takes priority over any default; (2) otherwise the most specific subinterface wins; (3) if still ambiguous, the class must override and pick explicitly using `X.super.method()`. Knowing these rules prevents surprising behavior and compile errors.

**Good example:**

```java
public interface A { default void hello() { System.out.println("A"); } }
public interface B { default void hello() { System.out.println("B"); } }
public class C implements A, B {
    public void hello() { B.super.hello(); }   // explicitly choose B's default (rule 3)
}
```

**Bad example:**

```java
public class C implements A, B { }   // compile error: inherits unrelated defaults A.hello and B.hello
```

### [13.5] Understand the diamond problem and keep default methods minimal

Title: Rely on the most-specific-interface rule for diamonds, and keep defaults small to avoid surprising inheritance.
Description: In a diamond (B and C both extend A; D implements B and C), if only one branch overrides the default, that most-specific one is chosen with no ambiguity; ambiguity arises only when two unrelated branches each declare a default. Keeping default methods small and focused (and preferring delegation for real logic) makes inherited behavior predictable.

**Good example:**

```java
public interface A { default void hello() { System.out.println("Hello from A"); } }
public interface B extends A { }
public interface C extends A { }
public class D implements B, C { }
new D().hello();   // unambiguous: only A provides hello -> "Hello from A"
```

**Bad example:**

```java
// Adding an unrelated default to one branch reintroduces ambiguity D must now resolve:
public interface C extends A { default void hello() { System.out.println("Hello from C"); } }
public interface B extends A { default void hello() { System.out.println("Hello from B"); } }
public class D implements B, C { }   // compile error unless D overrides hello()
```

## Chapter 14 — The Java Module System

### [14.1] Modularize for separation of concerns and information hiding

Title: Decompose a system into modules with clear responsibilities and hidden internals, not one entangled classpath.
Description: Good software favors separation of concerns (each part has one responsibility) and information hiding (internals are not exposed). The classpath enforces neither: any `public` class is reachable everywhere, so coupling grows unchecked. The Module System encodes these principles structurally — a module states what it provides and depends on, and hides everything else. (Java 9+.)

**Good example:**

```text
expenses.application   // orchestrates the app
expenses.readers       // reading abstraction
expenses.readers.http  // HTTP-specific reader (internals hidden)
expenses.readers.file  // file-specific reader (internals hidden)
// each module exposes only its API package; readers' internals are not visible to the application
```

**Bad example:**

```text
// One flat classpath: every package is visible to every other, so expenses.application
// can reach into HttpReader's internal parsing classes. Boundaries exist only by convention.
```

### [14.2] Declare a module with module-info.java

Title: Put a module-info.java at the module root declaring the module name and its directives.
Description: A module is defined by a `module-info.java` at its source root, naming the module (reverse-DNS-style) and listing its `requires`/`exports` directives. This descriptor is the single, compiler-checked source of truth for the module's dependencies and public surface. (Java 9+.)

**Good example:**

```java
// src/expenses.application/module-info.java
module com.example.expenses.application {
    requires com.example.expenses.readers;
}
```

**Bad example:**

```text
// No module-info.java: the code runs only as an unnamed module on the classpath,
// with no declared dependencies and no encapsulation — the module graph is unchecked.
```

### [14.3] Expose a public API with exports and declare dependencies with requires

Title: exports the packages that form your public API; requires the modules you depend on. Unexported packages stay encapsulated.
Description: `exports a.b.c;` makes that package's public types visible to other modules; packages you do not export remain inaccessible even though their types are `public` (strong encapsulation). `requires m;` declares a compile- and run-time dependency on module `m`. Together they make the dependency graph explicit and reliable. (Java 9+.)

**Good example:**

```java
module com.example.expenses.readers {
    exports com.example.expenses.readers;          // public API package
    requires com.fasterxml.jackson.core;           // declared dependency
    // com.example.expenses.readers.internal is NOT exported -> hidden from other modules
}
```

**Bad example:**

```java
module com.example.expenses.readers {
    exports com.example.expenses.readers;
    exports com.example.expenses.readers.internal;  // leaking internals defeats encapsulation
}
```

### [14.4] Choose package naming and module granularity carefully

Title: Name modules with a stable reverse-DNS scheme and pick a granularity that balances reuse against too many tiny modules.
Description: Module (and package) names should follow a globally unique reverse-DNS convention so they don't clash. Granularity is a design trade-off: too coarse and you lose the encapsulation/reuse benefits; too fine and the module graph becomes hard to maintain. Aim for modules that map to cohesive, independently evolvable responsibilities.

**Good example:**

```java
module com.example.expenses.readers { /* one cohesive responsibility: reading expenses */ }
```

**Bad example:**

```java
module readers { /* non-unique name, likely to clash; unclear ownership */ }
// ...or one micro-module per class, producing an unmanageable graph
```

### [14.5] Compile and package modular JARs (javac/jar/java with --module-path)

Title: Build with --module-source-path, package modular JARs, and run with --module-path and --module.
Description: Modules are compiled with `javac` using `--module-source-path`, packaged as modular JARs (a JAR containing `module-info.class`), and run with `java --module-path … --module name/MainClass`. The module path (not the classpath) is what gives reliable configuration and encapsulation at every stage. (Java 9+.)

**Good example:**

```bash
javac --module-source-path src -d out $(find src -name "*.java")
jar --create --file mods/app.jar --main-class com.example.expenses.application.ExpensesApplication \
    -C out/com.example.expenses.application .
java --module-path mods --module com.example.expenses.application/com.example.expenses.application.ExpensesApplication
```

**Bad example:**

```bash
# Putting modular JARs on the classpath ignores module-info and loses encapsulation/reliable config:
java -cp "mods/*" com.example.expenses.application.ExpensesApplication
```

### [14.6] Migrate a classpath application incrementally with automatic modules

Title: Place not-yet-modular JARs on the module path so they become automatic modules, enabling a top-down/bottom-up migration.
Description: You rarely modularize everything at once. A plain (non-modular) JAR placed on the module path becomes an *automatic module*: its name is derived from the JAR (or `Automatic-Module-Name` in the manifest), it `exports` all its packages, and it `requires` every other module. This lets you migrate gradually while still using libraries that have no `module-info`. (Java 9+.)

**Good example:**

```java
// Your module can require a library that is still a plain JAR (automatic module):
module com.example.expenses.application {
    requires com.example.expenses.readers;
    requires httpclient;   // automatic module derived from httpclient-*.jar on the module path
}
```

**Bad example:**

```text
// Refusing to start migration until every dependency ships a module-info.java —
// blocking modularization on third parties instead of using automatic modules.
```

### [14.7] Use advanced clauses: requires transitive, exports...to, open/opens, uses/provides

Title: Reach for requires transitive (implied readability), exports…to (qualified export), open/opens (reflection), and uses/provides (services) when the basic clauses are not enough.
Description: Beyond `requires`/`exports`, the module system offers: `requires transitive m` so your consumers also read `m` (implied readability for re-exposed types); `exports p to other.module` to restrict an export to named modules; `open module`/`opens p` to grant reflective access (needed by frameworks); and `uses`/`provides … with …` to declare and supply services for `ServiceLoader`. Use each only where its specific need arises. (Java 9+.)

**Good example:**

```java
module com.example.expenses.readers {
    requires transitive com.fasterxml.jackson.databind;        // consumers see databind types too
    exports com.example.expenses.readers to com.example.expenses.application;  // qualified export
    opens com.example.expenses.readers.model;                  // reflective access for a framework
    provides com.example.expenses.spi.Reader with com.example.expenses.readers.http.HttpReader;  // service
}
```

**Bad example:**

```java
module com.example.expenses.readers {
    requires com.fasterxml.jackson.databind;   // consumers that need databind types fail to compile
    exports com.example.expenses.readers;      // exported to everyone when only the app needs it
    open module ... ;                          // opening the whole module for reflection when one package suffices
}
```

## Chapter 15 — Concepts Behind CompletableFuture and Reactive Programming

### [15.1] Prefer higher-level executors and thread pools over raw threads

Title: Submit tasks to an ExecutorService thread pool instead of creating and managing Thread objects by hand.
Description: Threads are expensive OS resources; creating one per task does not scale and leaves you managing lifecycle and errors yourself. An `ExecutorService` (a thread pool) decouples task *submission* from *execution*, reuses a bounded set of worker threads, and returns `Future`s for results — the higher-level abstraction the rest of the concurrency stack builds on.

**Good example:**

```java
ExecutorService executor = Executors.newFixedThreadPool(4);
Future<Double> future = executor.submit(() -> doSomeLongComputation());
// ... do other work ...
Double result = future.get();
executor.shutdown();
```

**Bad example:**

```java
Thread t = new Thread(() -> {
    double r = doSomeLongComputation();   // result is hard to get back; thread not reused
});
t.start();
```

### [15.2] Choose between synchronous (blocking) and asynchronous (Future/reactive) API styles deliberately

Title: Decide explicitly whether a method blocks for its result or returns a Future/accepts a callback, and design the API around that choice.
Description: A synchronous (blocking) API returns the value but ties up the caller's thread until the computation finishes. An asynchronous API either returns a `Future`/`CompletableFuture` the caller can compose, or takes a callback (reactive style) invoked with results as they arrive. Choose the style that fits the workload — async for I/O-bound work you want to overlap — and make it consistent across the API.

**Good example:**

```java
// Future-style async API: caller can overlap other work and compose the result
CompletableFuture<Double> priceAsync(String product);

// Reactive-style async API: results delivered via callback
void priceReactive(String product, Consumer<Double> onPrice, Consumer<Throwable> onError);
```

**Bad example:**

```java
double price(String product) {
    return blockingHttpCall(product);   // blocks the caller's thread for the whole network round-trip
}
```

### [15.3] Treat blocking operations (sleep, blocking I/O) as harmful inside async pipelines

Title: Never call Thread.sleep or blocking I/O on a pooled/async thread; it ties up a worker that could run other tasks.
Description: A blocking call inside a task holds its worker thread idle, so a fixed pool quickly starves and throughput collapses. Prefer non-blocking alternatives, or at least schedule the resumption (e.g. a `ScheduledExecutorService`) instead of sleeping. The book's rule of thumb: "sleeping (and other blocking operations) considered harmful" in code running on shared threads.

**Good example:**

```java
ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
// schedule the continuation instead of blocking a worker with sleep:
scheduler.schedule(() -> continueWork(), 1, TimeUnit.SECONDS);
```

**Bad example:**

```java
executor.submit(() -> {
    Thread.sleep(1000);   // worker thread sits idle for a full second, blocking other tasks
    return continueWork();
});
```

### [15.4] Model concurrent dataflow with the box-and-channel model

Title: Think of a concurrent computation as boxes (operations) connected by channels (futures), composed instead of nested by hand.
Description: The box-and-channel model views each operation as a box and the data flowing between them as channels; composing boxes describes the dataflow declaratively. Coding it with explicit `Future.get()` calls forces a fixed, blocking order and prevents the system from running independent boxes concurrently — combinators (next chapter) let you wire the boxes without blocking.

**Good example:**

```java
// Declaratively wire q -> f and q -> g and combine, no manual blocking:
CompletableFuture<Integer> result =
    CompletableFuture.supplyAsync(() -> q(x))
        .thenCombine(CompletableFuture.supplyAsync(() -> g(x)), (a, b) -> f(a) + b);
```

**Bad example:**

```java
int y = q(x);          // blocks
int z = g(x);          // only starts after q finishes, though it is independent
int result = f(y) + z; // hand-wired, serial dataflow
```

### [15.5] Compose concurrency with CompletableFuture combinators rather than manual thread coordination

Title: Use thenCompose/thenCombine/allOf to connect asynchronous boxes instead of latches, joins, and shared flags.
Description: Coordinating threads with `wait`/`notify`, `CountDownLatch`, or manual `Future.get()` ordering is error-prone and serializes work. `CompletableFuture`'s combinators express the dependency graph directly — sequence with `thenCompose`, combine independents with `thenCombine`, fan-in with `allOf` — and the framework schedules them without blocking.

**Good example:**

```java
CompletableFuture<String> page =
    downloadAsync(url)
        .thenCompose(html -> renderAsync(html))   // dependent step, no blocking
        .thenApply(this::compress);
```

**Bad example:**

```java
CountDownLatch latch = new CountDownLatch(1);
final String[] html = new String[1];
executor.submit(() -> { html[0] = download(url); latch.countDown(); });
latch.await();                       // manual coordination + shared mutable slot
String page = compress(render(html[0]));
```

### [15.6] Express a stream of events with publish-subscribe and apply backpressure

Title: Model continuous event flows as a Publisher that Subscribers subscribe to, and let subscribers signal demand (backpressure).
Description: For *streams of events over time* (temperatures, ticks, UI events) the publish-subscribe (reactive) model fits: a `Publisher` emits items to `Subscriber`s. Crucially, a fast publisher can overwhelm a slow subscriber, so the subscriber signals how much it can handle via `Subscription.request(n)` — backpressure — turning an uncontrolled push into a demand-driven flow.

**Good example:**

```java
// Subscriber requests one item at a time, so the publisher never floods it (backpressure):
public void onSubscribe(Subscription subscription) {
    this.subscription = subscription;
    subscription.request(1);
}
public void onNext(TempInfo tempInfo) {
    System.out.println(tempInfo);
    subscription.request(1);   // ask for the next only when ready
}
```

**Bad example:**

```java
// Publisher pushes every event immediately with no demand signal — a slow consumer is overwhelmed
// and unbounded buffering risks OutOfMemoryError.
publisher.forEachEvent(subscriber::onNext);   // no request(n) / backpressure
```

### [15.7] Distinguish reactive systems (architecture) from reactive programming (technique)

Title: Separate "reactive systems" (responsive/resilient/elastic/message-driven architecture) from "reactive programming" (composing async data streams in code).
Description: *Reactive systems* describe an architectural goal — responsive, resilient, elastic, message-driven applications (the Reactive Manifesto). *Reactive programming* is a programming technique — composing asynchronous, backpressured data streams (Flow API, RxJava) — and is one tool used to build reactive systems. Conflating them leads to thinking a few `CompletableFuture`s make a system "reactive." Use the right term and apply each at its level.

**Good example:**

```text
System level (architecture): services communicate by messages, stay responsive under load and failure.
Program level (technique):   within a service, compose async streams with backpressure (Flow/RxJava).
```

**Bad example:**

```text
"We used CompletableFuture in one method, so our system is a reactive system."
// Confuses a local programming technique with a system-wide architectural property.
```

## Chapter 16 — CompletableFuture: Composable Asynchronous Programming

### [16.1] Replace plain Future with CompletableFuture for composable async work

Title: Use CompletableFuture so async results can be chained and combined, not just polled with get().
Description: A plain `Future` lets you start work and later block on `get()`, but you cannot express "when this finishes, do that" or "combine these two results" without blocking. `CompletableFuture` adds a rich combinator API on top of the same model, so you describe the whole async computation declaratively and only block (if at all) at the very end.

**Good example:**

```java
CompletableFuture<Double> future = shop.getPriceAsync("my favorite product");
// do other work meanwhile...
double price = future.join();   // or compose further without blocking
```

**Bad example:**

```java
ExecutorService ex = Executors.newCachedThreadPool();
Future<Double> future = ex.submit(() -> shop.getPrice("my favorite product"));
double price = future.get();   // can only block; cannot chain "then" steps onto it
```

### [16.2] Create asynchronous computations with supplyAsync / runAsync

Title: Wrap a value-producing task in supplyAsync (or a side-effecting one in runAsync) to run it on a pool.
Description: `CompletableFuture.supplyAsync(Supplier)` runs the supplier asynchronously (on the common pool, or a supplied `Executor`) and yields a `CompletableFuture` of its result; `runAsync(Runnable)` is the void-returning equivalent. This is the idiomatic way to turn a synchronous method into an asynchronous one without hand-managing a thread and a slot for the result.

**Good example:**

```java
public CompletableFuture<Double> getPriceAsync(String product) {
    return CompletableFuture.supplyAsync(() -> calculatePrice(product));
}
```

**Bad example:**

```java
public Future<Double> getPriceAsync(String product) {
    CompletableFuture<Double> futurePrice = new CompletableFuture<>();
    new Thread(() -> futurePrice.complete(calculatePrice(product))).start();  // manual thread + complete
    return futurePrice;
}
```

### [16.3] Propagate failures through the future via completeExceptionally

Title: When completing a future manually, route exceptions with completeExceptionally so the client sees them, not a thread that hangs forever.
Description: If a task that completes a `CompletableFuture` by hand throws, and you don't forward the exception, the client's `get()` blocks forever — the error dies silently in the worker thread. `completeExceptionally(ex)` delivers the exception to the waiting client (where `get()` throws an `ExecutionException`). With `supplyAsync` this is automatic; with manual completion you must do it.

**Good example:**

```java
new Thread(() -> {
    try {
        futurePrice.complete(calculatePrice(product));
    } catch (Exception ex) {
        futurePrice.completeExceptionally(ex);   // client's get() now throws instead of hanging
    }
}).start();
```

**Bad example:**

```java
new Thread(() -> {
    double price = calculatePrice(product);   // if this throws, the future is never completed
    futurePrice.complete(price);               // client's get() blocks forever
}).start();
```

### [16.4] Don't block on get() sequentially — launch independent calls, then collect

Title: Start all independent async calls first (e.g. with a parallel stream of CompletableFutures), then join them — never get() one before starting the next.
Description: Calling `get()`/`join()` on each future before starting the next serializes work and throws away the concurrency. Instead, fire off every independent computation as a `CompletableFuture`, collect the futures into a list, and only then join them — so all the network/CPU work overlaps. (Use a custom executor for many I/O-bound calls; see 16.5.)

**Good example:**

```java
List<CompletableFuture<String>> futures = shops.stream()
    .map(shop -> CompletableFuture.supplyAsync(() -> shop.getPrice(product), executor))
    .collect(toList());                                  // all started
return futures.stream().map(CompletableFuture::join).collect(toList());   // then collected
```

**Bad example:**

```java
List<String> prices = shops.stream()
    .map(shop -> CompletableFuture.supplyAsync(() -> shop.getPrice(product)))
    .map(CompletableFuture::join)   // joins each before starting the next -> fully sequential
    .collect(toList());
```

### [16.5] Supply a custom Executor sized for I/O instead of relying on the common pool

Title: For many blocking I/O calls, pass a purpose-sized Executor to supplyAsync rather than using the default common ForkJoinPool.
Description: The default common pool has only about as many threads as CPU cores — fine for CPU-bound work, but a bottleneck for many concurrent blocking I/O calls. Provide a custom `Executor` sized to your workload (the book caps it at e.g. 100 daemon threads), so dozens of slow remote calls can be in flight at once without starving the common pool used by the rest of the app.

**Good example:**

```java
Executor executor = Executors.newFixedThreadPool(Math.min(shops.size(), 100), r -> {
    Thread t = new Thread(r);
    t.setDaemon(true);   // don't block JVM shutdown
    return t;
});
CompletableFuture.supplyAsync(() -> shop.getPrice(product), executor);
```

**Bad example:**

```java
// 50 blocking HTTP calls on the common pool (≈ #cores threads) — most calls queue and wait.
CompletableFuture.supplyAsync(() -> shop.getPrice(product));   // no custom executor for I/O
```

### [16.6] Pipeline dependent tasks with thenCompose; transform with thenApply

Title: Chain a dependent async step with thenCompose (flattening nested futures), and apply pure transforms with thenApply.
Description: When the next step is itself asynchronous and depends on the previous result, `thenCompose` flattens the `CompletableFuture<CompletableFuture<T>>` into one future — like `flatMap` for futures — so the pipeline stays non-blocking. Use `thenApply` (like `map`) when the next step is a plain synchronous transform of the result.

**Good example:**

```java
CompletableFuture<String> quote =
    CompletableFuture.supplyAsync(() -> shop.getPrice(product), executor)
        .thenCompose(price ->
            CompletableFuture.supplyAsync(() -> applyDiscountAsyncResult(price), executor))  // dependent async
        .thenApply(Quote::format);                                                           // pure transform
```

**Bad example:**

```java
double price = CompletableFuture.supplyAsync(() -> shop.getPrice(product)).join();   // blocks
String discounted = CompletableFuture.supplyAsync(() -> applyDiscount(price)).join(); // blocks again
```

### [16.7] Combine two independent futures with thenCombine

Title: Merge the results of two independent CompletableFutures with thenCombine once both complete.
Description: When two async computations are independent and you need both results, `thenCombine(other, BiFunction)` runs them concurrently and applies the combiner when both finish — without blocking on either. This is the idiomatic way to, say, fetch a price and an exchange rate at once and multiply them.

**Good example:**

```java
CompletableFuture<Double> futurePriceInUsd =
    CompletableFuture.supplyAsync(() -> shop.getPrice(product))
        .thenCombine(
            CompletableFuture.supplyAsync(() -> exchangeService.getRate(Money.EUR, Money.USD)),
            (price, rate) -> price * rate);
```

**Bad example:**

```java
double price = CompletableFuture.supplyAsync(() -> shop.getPrice(product)).join();    // serial
double rate  = CompletableFuture.supplyAsync(() -> exchangeService.getRate(...)).join();
double usd   = price * rate;
```

### [16.8] React to completion with thenAccept and coordinate many with allOf / anyOf

Title: Process each result as it arrives with thenAccept, and wait for all/any of a set with allOf/anyOf.
Description: `thenAccept(Consumer)` registers a non-blocking action to run when a future completes — letting you display each shop's price the instant it returns. To coordinate a collection of futures, `allOf` yields a `CompletableFuture<Void>` that completes when *all* do, and `anyOf` completes when *any* one does. Together they replace manual joining loops.

**Good example:**

```java
CompletableFuture[] futures = shops.stream()
    .map(shop -> shop.getPriceAsync(product)
                     .thenAccept(price -> System.out.println(shop.getName() + " " + price)))
    .toArray(CompletableFuture[]::new);
CompletableFuture.allOf(futures).join();   // wait for every price to be printed
```

**Bad example:**

```java
List<CompletableFuture<Double>> futures = /* ... */;
for (CompletableFuture<Double> f : futures) {
    System.out.println(f.join());   // blocks on each in turn instead of reacting as they complete
}
```

### [16.9] Bound async work with orTimeout and completeOnTimeout (Java 9)

Title: Apply orTimeout to fail a stalled future and completeOnTimeout to fall back to a default after a deadline.
Description: A composed pipeline should not wait forever for a slow dependency. `orTimeout(duration)` completes the future exceptionally with a `TimeoutException` if it isn't done in time; `completeOnTimeout(value, duration)` completes it with a fallback value instead. Both make latency bounds explicit. (Java 9+.)

**Good example:**

```java
CompletableFuture<Double> priceInUsd =
    CompletableFuture.supplyAsync(() -> shop.getPrice(product))
        .thenCombine(CompletableFuture.supplyAsync(() -> exchangeService.getRate(Money.EUR, Money.USD))
                         .completeOnTimeout(DEFAULT_RATE, 1, TimeUnit.SECONDS),   // fallback rate
                     (price, rate) -> price * rate)
        .orTimeout(3, TimeUnit.SECONDS);   // overall deadline
```

**Bad example:**

```java
double usd = CompletableFuture.supplyAsync(() -> shop.getPrice(product))
    .thenCombine(CompletableFuture.supplyAsync(() -> exchangeService.getRate(...)),
                 (p, r) -> p * r)
    .join();   // no timeout: a hung exchange service blocks this caller indefinitely
```

## Chapter 17 — Reactive Programming

### [17.1] Apply the Reactive Manifesto: responsive, resilient, elastic, message-driven

Title: Design reactive applications to stay responsive under load and failure by being elastic and message-driven.
Description: The Reactive Manifesto names four properties: *responsive* (timely answers), *resilient* (stays responsive under failure, via isolation and replication), *elastic* (scales with load by adding/removing resources), and *message-driven* (components communicate with asynchronous messages, giving loose coupling and isolation). The first two are the goals; elasticity and message-driving are the means. Keep these in mind when choosing reactive techniques.

**Good example:**

```text
Order service publishes events; downstream services consume asynchronously (message-driven).
Failure of one consumer is isolated (resilient); instances scale with load (elastic);
the system keeps answering within its SLA (responsive).
```

**Bad example:**

```text
Synchronous service A directly calls B calls C and blocks the whole request thread.
One slow dependency makes the whole chain unresponsive — none of the four properties hold.
```

### [17.2] Implement Reactive Streams with the java.util.concurrent.Flow API

Title: Use the standard Flow.Publisher / Subscriber / Subscription / Processor interfaces for Reactive Streams interop.
Description: Java 9 adopts Reactive Streams as the four nested interfaces in `java.util.concurrent.Flow`: a `Publisher` produces items for `Subscriber`s; `subscribe` hands the subscriber a `Subscription`; the subscriber receives `onSubscribe`, then `onNext*`, ending with `onComplete` or `onError`. Implementing these makes your code interoperable with any Reactive Streams library. (Java 9+.)

**Good example:**

```java
private static class TempSubscriber implements Flow.Subscriber<TempInfo> {
    private Flow.Subscription subscription;
    public void onSubscribe(Flow.Subscription subscription) {
        this.subscription = subscription;
        subscription.request(1);
    }
    public void onNext(TempInfo tempInfo) {
        System.out.println(tempInfo);
        subscription.request(1);
    }
    public void onError(Throwable t)  { System.err.println(t.getMessage()); }
    public void onComplete()          { System.out.println("Done!"); }
}

Flow.Publisher<TempInfo> getTemperatures(String town) {
    return subscriber -> subscriber.onSubscribe(new TempSubscription(subscriber, town));
}
```

**Bad example:**

```java
// Inventing an ad-hoc listener interface instead of the standard Flow types — no interop,
// no defined backpressure or completion/error contract.
interface MyTempListener { void temperature(double t); }
```

### [17.3] Honor the Flow contract and request demand to apply backpressure

Title: Emit items only up to what the subscriber has requested, signal completion/error exactly once, and stop after onComplete/onError or cancel.
Description: The Flow/Reactive Streams contract is strict: a `Subscription` must send no more than `request(n)` items, must call `onComplete` or `onError` exactly once and then send nothing more, and must stop when the subscriber `cancel`s. Requesting one item at a time (and one more in `onNext`) yields demand-driven backpressure so a fast source never floods a slow consumer.

**Good example:**

```java
public void request(long n) {
    for (long i = 0L; i < n; i++) {                 // never emit more than requested
        try {
            subscriber.onNext(TempInfo.fetch(town));
        } catch (Exception e) {
            subscriber.onError(e);                  // terminal signal
            break;
        }
    }
}
```

**Bad example:**

```java
public void request(long n) {
    while (true) {                                  // ignores n: floods the subscriber
        subscriber.onNext(TempInfo.fetch(town));    // no backpressure, never terminates
    }
}
```

### [17.4] Transform data with a Processor

Title: Implement Flow.Processor to sit between a Publisher and Subscriber and transform items in the stream.
Description: A `Flow.Processor<T, R>` is both a `Subscriber<T>` and a `Publisher<R>`: it subscribes upstream, transforms each item, and republishes to downstream subscribers — the reactive analogue of `map`. The book's example converts temperatures from Fahrenheit to Celsius in a `TempProcessor`, forwarding `onSubscribe`/`onError`/`onComplete` unchanged.

**Good example:**

```java
public class TempProcessor implements Flow.Processor<TempInfo, TempInfo> {
    private Flow.Subscriber<? super TempInfo> subscriber;
    public void subscribe(Flow.Subscriber<? super TempInfo> subscriber) { this.subscriber = subscriber; }
    public void onNext(TempInfo temp) {
        subscriber.onNext(new TempInfo(temp.getTown(), (temp.getTemp() - 32) * 5 / 9));  // F -> C
    }
    public void onSubscribe(Flow.Subscription s) { subscriber.onSubscribe(s); }
    public void onError(Throwable t)             { subscriber.onError(t); }
    public void onComplete()                     { subscriber.onComplete(); }
}
```

**Bad example:**

```java
// Doing the conversion inside the final Subscriber's onNext mixes transformation with consumption,
// so the conversion can't be reused or re-composed in another pipeline.
public void onNext(TempInfo temp) {
    double celsius = (temp.getTemp() - 32) * 5 / 9;
    System.out.println(celsius);
}
```

### [17.5] Use a reactive library (RxJava) instead of implementing Flow by hand

Title: For real reactive code, build on a library like RxJava rather than hand-coding Publishers/Subscribers.
Description: The JDK ships only the `Flow` interfaces, not an implementation — you are expected to use a Reactive Streams library. RxJava's `Observable`/`Flowable` provide a large, tested operator set (creation, transformation, combination, scheduling) and handle the contract details, so you compose streams declaratively instead of re-implementing subscription bookkeeping and backpressure each time.

**Good example:**

```java
Observable<TempInfo> temps =
    Observable.create(emitter ->
        Observable.interval(1, TimeUnit.SECONDS)
                  .subscribe(i -> emitter.onNext(TempInfo.fetch("New York"))));
temps.subscribe(System.out::println, Throwable::printStackTrace);
```

**Bad example:**

```java
// Hand-rolling subscription, demand tracking, and scheduling for a simple periodic source —
// hundreds of lines re-implementing what Observable.interval(...) already provides.
class MyHandRolledPublisher implements Flow.Publisher<TempInfo> { /* ... */ }
```

### [17.6] Transform and combine Observables (map/merge) with care about threads

Title: Compose reactive streams with operators like map and merge, and use schedulers/observeOn to control threading.
Description: RxJava operators transform (`map`, `filter`) and combine (`merge`, `zip`) streams declaratively, mirroring the Stream API but over time-based event flows. Because emissions may arrive on different threads, use schedulers (`subscribeOn`/`observeOn`) deliberately, and remember an `Observable` can emit on any thread — don't assume a single calling thread when mutating shared state.

**Good example:**

```java
Observable<TempInfo> newYork = getTemperature("New York");
Observable<TempInfo> chicago = getTemperature("Chicago");
Observable<TempInfo> both = Observable.merge(newYork, chicago);   // combine two event streams
both.map(t -> (t.getTemp() - 32) * 5 / 9)                         // transform each emission
    .subscribe(System.out::println);
```

**Bad example:**

```java
// Subscribing to each Observable separately and writing to a shared, unsynchronized field —
// emissions on different threads race.
int[] last = {0};
newYork.subscribe(t -> last[0] = t.getTemp());
chicago.subscribe(t -> last[0] = t.getTemp());   // data race on last[0]
```

## Chapter 18 — Thinking Functionally

### [18.1] Avoid shared mutable data; prefer side-effect-free functions

Title: Write methods that don't mutate shared state, so callers can reason about and parallelize them safely.
Description: A side effect is any action a function does beyond returning a value — mutating a field, a shared collection, or doing I/O. Shared mutable data is the root of most concurrency bugs because it couples otherwise-independent code. Functions that touch only their arguments and local state are easy to test, compose, cache, and run in parallel.

**Good example:**

```java
static List<Integer> doubled(List<Integer> xs) {
    return xs.stream().map(x -> x * 2).collect(toList());   // input untouched; new list returned
}
```

**Bad example:**

```java
static void doubleInPlace(List<Integer> xs) {
    for (int i = 0; i < xs.size(); i++) xs.set(i, xs.get(i) * 2);   // mutates the caller's list
}
```

### [18.2] Program declaratively (what) instead of imperatively (how)

Title: Describe the result you want with stream/collection operations rather than spelling out the control flow.
Description: Imperative code says *how* to compute a result step by step (loops, indices, mutable accumulators); declarative code says *what* the result is (filter these, map those, reduce). Declarative style is closer to the problem statement, less error-prone, and lets the library choose the execution strategy (including parallelism).

**Good example:**

```java
Optional<Transaction> mostExpensive =
    transactions.stream().max(comparing(Transaction::getValue));   // "the max by value"
```

**Bad example:**

```java
Transaction mostExpensive = transactions.get(0);
for (Transaction t : transactions) {                  // how, step by step
    if (t.getValue() > mostExpensive.getValue()) mostExpensive = t;
}
```

### [18.3] Ensure referential transparency

Title: Write methods whose result depends only on their inputs and which have no observable side effects, so a call can be replaced by its value.
Description: A function is referentially transparent if, for the same arguments, it always returns the same value and changes nothing observable — so `f(x)` could be swapped for its result without changing the program. This property makes code dramatically easier to reason about, test, memoize, and parallelize. Strive for it in the core logic and push side effects to the edges.

**Good example:**

```java
static int add(int a, int b) { return a + b; }   // pure: same inputs -> same output, no side effects
```

**Bad example:**

```java
static int counter = 0;
static int addAndCount(int a, int b) { counter++; return a + b; }   // result depends on hidden state
```

### [18.4] Prefer immutable objects and final fields

Title: Make objects immutable (final fields, no setters) so they can be shared freely without defensive copying or locking.
Description: An immutable object cannot change after construction, so it is inherently thread-safe, can be shared and cached, and never surprises a caller by mutating underneath them. Mark fields `final`, omit setters, and return new instances from "modifier" methods. This eliminates a whole category of aliasing and concurrency bugs.

**Good example:**

```java
public final class Point {
    private final int x, y;
    public Point(int x, int y) { this.x = x; this.y = y; }
    public int getX() { return x; }
    public int getY() { return y; }
    public Point withX(int newX) { return new Point(newX, y); }   // returns a new value
}
```

**Bad example:**

```java
public class Point {
    public int x, y;                       // mutable, shared state
    public void setX(int x) { this.x = x; }   // any holder can change it underneath others
}
```

### [18.5] Replace mutating iteration with streams or stack-safe recursion

Title: Express iteration as a stream/recursion over immutable data, and prefer iteration (or tail-style recursion) where deep recursion would overflow the stack.
Description: A mutating loop can often be rewritten as a pure stream pipeline or a recursive definition that builds a result without side effects. Pure recursion is elegant but Java does not optimize tail calls, so deep recursion risks `StackOverflowError`; for large inputs prefer an iterative/stream form (or an explicitly tail-recursive helper) that stays stack-safe.

**Good example:**

```java
static long factorialStreams(long n) {
    return LongStream.rangeClosed(1, n).reduce(1, (a, b) -> a * b);   // no mutation, stack-safe
}
```

**Bad example:**

```java
static long factorialRecursive(long n) {
    return n == 1 ? 1 : n * factorialRecursive(n - 1);   // not tail-optimized -> StackOverflowError for big n
}
```

## Chapter 19 — Functional Programming Techniques

### [19.1] Treat functions as first-class values and write higher-order functions

Title: Store functions in variables and pass/return them; write methods that take or return functions.
Description: In Java 8+, functions (as functional-interface instances/method references) are first-class values you can assign, pass, and return. A *higher-order function* takes one or more functions as arguments or returns a function — `Comparator.comparing`, `Function.andThen`, and a method that returns a configured transformer are all examples. This enables building behavior from small composable pieces.

**Good example:**

```java
Function<String, Integer> strToInt = Integer::parseInt;   // function as a value

// higher-order: returns a function
static Function<Double, Double> adder(double k) { return x -> x + k; }
Function<Double, Double> add10 = adder(10);
```

**Bad example:**

```java
// Hardcoding each variant instead of returning a function -> no reuse, no composition.
static double addTen(double x) { return x + 10; }
static double addTwenty(double x) { return x + 20; }
```

### [19.2] Curry functions to specialize and reuse logic

Title: Transform a multi-argument function into a chain of single-argument functions so you can pre-bind arguments.
Description: Currying turns `f(x, y)` into `g(x).apply(y)` — a function returning a function — so you can fix some arguments now and supply the rest later, producing specialized reusable functions. The book's example curries a unit-conversion `f * x + b` so `convertCtoF`, `convertUSDtoGBP`, etc. fall out of one general definition.

**Good example:**

```java
static DoubleUnaryOperator curriedConverter(double f, double b) {
    return x -> x * f + b;                       // pre-bind the conversion factor and baseline
}
DoubleUnaryOperator convertCtoF = curriedConverter(9.0 / 5, 32);
double fahrenheit = convertCtoF.applyAsDouble(100);   // 212
```

**Bad example:**

```java
// A separate method per conversion, each repeating the same f*x+b shape.
static double cToF(double x)   { return x * 9.0 / 5 + 32; }
static double usdToGbp(double x) { return x * 0.6 + 0; }
```

### [19.3] Use persistent data structures instead of destructive updates

Title: Return a new version of a data structure on "update," leaving existing references unchanged (no destructive mutation).
Description: A persistent data structure preserves previous versions when modified: an "update" produces a new structure sharing unchanged parts, so anyone holding the old reference still sees consistent data. Destructive in-place updates can corrupt shared state — e.g. mutating a linked list passed to another part of the program. Prefer functional updates that don't disturb existing users.

**Good example:**

```java
// append returns a new list; the original list1 is never mutated
static TrainJourney append(TrainJourney a, TrainJourney b) {
    return a == null ? b : new TrainJourney(a.price, append(a.onward, b));
}
```

**Bad example:**

```java
static TrainJourney link(TrainJourney a, TrainJourney b) {
    if (a == null) return b;
    TrainJourney t = a;
    while (t.onward != null) t = t.onward;
    t.onward = b;          // destructive: corrupts anyone else holding `a`
    return a;
}
```

### [19.4] Functionally update trees by re-creating only the path

Title: To "change" a node in an immutable tree, build new nodes along the path to it and share the rest.
Description: Updating a persistent tree functionally means returning a new tree that reuses every untouched subtree and re-creates only the nodes on the path from the root to the change. This keeps all existing references valid (no mutation) while staying efficient, since most of the structure is shared. Contrast with mutating a node in place, which is visible to every holder of the tree.

**Good example:**

```java
public static Tree fupdate(String k, int newval, Tree t) {
    return (t == null) ? new Tree(k, newval, null, null) :
        k.equals(t.key) ? new Tree(k, newval, t.left, t.right) :          // replace this node
        k.compareTo(t.key) < 0
            ? new Tree(t.key, t.val, fupdate(k, newval, t.left), t.right) // rebuild left path only
            : new Tree(t.key, t.val, t.left, fupdate(k, newval, t.right));
}
```

**Bad example:**

```java
public static void update(String k, int newval, Tree t) {
    // walk to the node and mutate it in place -> every other holder of t sees the change
    Tree node = find(k, t);
    node.val = newval;
}
```

### [19.5] Build lazy lists with Supplier-backed tails for infinite sequences

Title: Represent a potentially infinite sequence as a head plus a Supplier of the tail, computing each element on demand.
Description: A lazy list stores its head eagerly and its tail as a `Supplier` that is only evaluated when needed, so you can define infinite sequences (all primes, all naturals) and consume just a finite prefix. This is the explicit, on-demand structure behind stream laziness; it lets you express generate-and-filter algorithms (like a prime sieve) without computing the whole sequence.

**Good example:**

```java
interface MyList<T> {
    T head();
    MyList<T> tail();
    default boolean isEmpty() { return true; }
}
class LazyList<T> implements MyList<T> {
    final T head; final Supplier<MyList<T>> tail;
    LazyList(T head, Supplier<MyList<T>> tail) { this.head = head; this.tail = tail; }
    public T head() { return head; }
    public MyList<T> tail() { return tail.get(); }   // tail computed only when asked
    public boolean isEmpty() { return false; }
}
```

**Bad example:**

```java
// Eagerly materializing an "infinite" sequence never terminates / OOMs.
static List<Integer> allNumbersFrom(int n) {
    List<Integer> result = new ArrayList<>();
    for (int i = n; ; i++) result.add(i);   // infinite loop
    return result;
}
```

### [19.6] Defer computation with Supplier-based lazy evaluation

Title: Wrap an expensive value in a Supplier so it is computed only if and when it is actually needed.
Description: Passing a value directly evaluates it eagerly, even when the consumer might not use it. Passing a `Supplier<T>` defers the work until `get()` is called (and lets you memoize it), which avoids wasted computation — the same idea behind lazy logging messages and on-demand list tails.

**Good example:**

```java
void process(boolean enabled, Supplier<String> expensiveMessage) {
    if (enabled) System.out.println(expensiveMessage.get());   // only computed when enabled
}
process(false, () -> buildHugeDiagnostic());   // buildHugeDiagnostic() never runs
```

**Bad example:**

```java
void process(boolean enabled, String message) {
    if (enabled) System.out.println(message);
}
process(false, buildHugeDiagnostic());   // expensive message built even though it is never used
```

### [19.7] Emulate pattern matching with lambdas instead of instanceof chains

Title: Dispatch on the shape of data with a lambda-based matcher rather than a long if/instanceof/cast cascade.
Description: Java (pre-records/sealed pattern matching) lacks Scala-style pattern matching, but you can emulate it: give each case a handler (a `BiFunction`/lambda) keyed by type and select the matching one, avoiding the repetitive, error-prone `if (e instanceof BinOp) { ... cast ... }` chain. This isolates each case's logic and makes adding a new case localized.

**Good example:**

```java
// patternMatchExpr dispatches on Number vs BinOp via handler functions:
Integer result = patternMatchExpr(e,
    (op, l, r) -> evaluate(l) + evaluate(r),   // BinOp case
    n -> n,                                    // Number case
    () -> { throw new IllegalStateException(); });
```

**Bad example:**

```java
static int evaluate(Expr e) {
    if (e instanceof Number) {
        return ((Number) e).val;                       // cast
    } else if (e instanceof BinOp) {
        BinOp bo = (BinOp) e;                           // cast
        return evaluate(bo.left) + evaluate(bo.right);
    }
    throw new IllegalStateException();                  // brittle cascade; new case = edit here
}
```

### [19.8] Cache pure results with memoization and build behavior from combinators

Title: Wrap a pure function so repeated calls with the same argument are cached (memoization), and assemble behavior from small combinators.
Description: Because pure functions are referentially transparent, their results can be cached: memoization stores `arg -> result` so an expensive computation runs once per input. A *combinator* is a higher-order function that combines functions (`andThen`, `compose`, a `repeat(n, f)`); building behavior from combinators yields concise, reusable pipelines. (Guard shared caches for thread-safety, e.g. `ConcurrentHashMap.computeIfAbsent`.)

**Good example:**

```java
Map<Integer, Long> cache = new ConcurrentHashMap<>();
Function<Integer, Long> memoFib = n -> cache.computeIfAbsent(n, MyMath::slowFib);   // compute once per n
Function<Integer, Integer> twice = ((Function<Integer,Integer>) x -> x + 1)
        .andThen(x -> x * 2);   // combinator composition
```

**Bad example:**

```java
// Recomputing the same expensive pure result every call, with no caching.
long fib(int n) { return slowFib(n); }   // slowFib(40) recomputed in full every time
```

## Chapter 20 — Blending OOP and FP: Comparing Java and Scala

### [20.1] Express queries concisely with collection/stream operations

Title: Use stream/collection operations to write data queries as concisely in Java as in functional languages like Scala.
Description: Scala popularized writing data manipulation as chained higher-order operations; Java's Streams bring the same conciseness. Prefer a `filter`/`map`/`collect` pipeline (or `IntStream.rangeClosed(...).mapToObj(...)`) over imperative loops — the Java code ends up close to the Scala equivalent in clarity.

**Good example:**

```java
// Java, reads much like the Scala one-liner:
String result = IntStream.rangeClosed(2, 6)
    .mapToObj(n -> n + " bottles of beer")
    .collect(joining("\n"));
```

**Bad example:**

```java
StringBuilder sb = new StringBuilder();
for (int n = 2; n <= 6; n++) {
    sb.append(n).append(" bottles of beer");
    if (n < 6) sb.append("\n");          // manual loop + delimiter handling
}
String result = sb.toString();
```

### [20.2] Default to immutable, persistent collections

Title: Prefer immutable collections (List.of, unmodifiable views, persistent structures) as Scala does by default.
Description: Scala's default collections are immutable; Java is mutable-by-default, so you must opt in. Reach for `List.of`/`Set.of`/`Map.of`, `Collectors.toUnmodifiableList`, or defensive copies to get the same safety — shareable, never silently mutated, easy to reason about — rather than passing around mutable `ArrayList`s.

**Good example:**

```java
List<Integer> numbers = List.of(1, 2, 3);                 // immutable
List<Integer> doubled = numbers.stream().map(n -> n * 2)
                               .collect(toUnmodifiableList());
```

**Bad example:**

```java
List<Integer> numbers = new ArrayList<>(List.of(1, 2, 3));
helper(numbers);   // helper can clear()/add() and silently corrupt our list
```

### [20.3] Use Optional/Option chaining instead of null checks

Title: Chain Optional operations the way Scala chains Option, instead of nested null tests.
Description: Scala's `Option` and Java's `Optional` play the same role: make absence explicit and compose with `map`/`flatMap`/`getOrElse`(`orElse`). Writing Java with Optional chains mirrors idiomatic Scala and removes nested null checks (see Chapter 11).

**Good example:**

```java
String name = optPerson
    .flatMap(Person::getCar)
    .flatMap(Car::getInsurance)
    .map(Insurance::getName)
    .orElse("Unknown");          // mirrors Scala's option.map(...).getOrElse(...)
```

**Bad example:**

```java
String name = "Unknown";
if (person != null && person.getCar() != null && person.getCar().getInsurance() != null) {
    name = person.getCar().getInsurance().getName();   // nested null checks
}
```

### [20.4] Add shared behavior with default methods (the Java analogue of Scala traits)

Title: Use interfaces with default methods to mix shared behavior into classes, as Scala does with traits.
Description: Scala traits bundle method implementations (and state) that classes mix in. Java interfaces with default methods provide multiple inheritance of *behavior* (not state) — the closest analogue. Factor reusable behavior into small interfaces and implement several to compose capabilities (see Chapter 13).

**Good example:**

```java
interface Sized {
    int size();
    default boolean isEmpty() { return size() == 0; }   // mixed-in behavior, like a trait method
}
class Bag implements Sized { public int size() { return items.size(); } }
```

**Bad example:**

```java
// Copying isEmpty() into every class that has a size() instead of inheriting it from an interface.
class Bag { int size() { return items.size(); } boolean isEmpty() { return size() == 0; } }
class Box { int size() { return n; }           boolean isEmpty() { return size() == 0; } } // dup
```

### [20.5] Use first-class functions, anonymous functions/closures, and currying idiomatically

Title: Pass lambdas and method references as values, capture context in closures, and curry — Java supports all three (with effectively-final capture).
Description: Scala treats functions as values, supports anonymous functions and closures that capture surrounding variables, and currying. Java offers the same with lambdas/method references and curried `Function`-returning methods; the one notable restriction is that captured locals must be effectively final (Java closures capture values, not mutable variables).

**Good example:**

```java
int base = 10;                                   // effectively final
Function<Integer, Integer> addBase = x -> x + base;   // closure capturing base
Function<Integer, Function<Integer, Integer>> adder = a -> b -> a + b;   // curried
int sum = adder.apply(3).apply(4);               // 7
```

**Bad example:**

```java
int base = 10;
Function<Integer, Integer> addBase = x -> x + base;
base = 20;   // compile error: captured local must stay effectively final
```

## Chapter 21 — Conclusions and Where Next for Java

### [21.1] Parameterize behavior with lambdas and method references

Title: Keep reaching for lambdas/method references to pass behavior — the foundational modern-Java idiom.
Description: The single biggest shift modern Java enables is passing code as data. Whenever an API takes a single-method interface (`Comparator`, `Runnable`, `Function`, an event handler), supply a lambda or method reference rather than an anonymous class. It underpins streams, collectors, `CompletableFuture`, and DSLs.

**Good example:**

```java
inventory.sort(comparing(Apple::getWeight));
button.setOnAction(e -> handleClick());
```

**Bad example:**

```java
inventory.sort(new Comparator<Apple>() {
    public int compare(Apple a, Apple b) { return a.getWeight().compareTo(b.getWeight()); }
});
```

### [21.2] Pipeline data transformations with Streams

Title: Default to stream pipelines for data processing; switch to parallel only after measuring.
Description: Streams are the modern, declarative way to process data: `filter`/`map`/`reduce`/`collect` express the query and let the library optimize execution. They compose, short-circuit, and parallelize — but `parallelStream()` is a measured optimization, not a default.

**Good example:**

```java
Map<Currency, List<Transaction>> byCurrency =
    transactions.stream().collect(groupingBy(Transaction::getCurrency));
```

**Bad example:**

```java
Map<Currency, List<Transaction>> byCurrency = new HashMap<>();
for (Transaction t : transactions) {
    byCurrency.computeIfAbsent(t.getCurrency(), c -> new ArrayList<>()).add(t);   // manual grouping
}
```

### [21.3] Compose asynchronous work with CompletableFuture and the Flow API

Title: Use CompletableFuture for composable async results and the Flow API for backpressured event streams.
Description: Modern Java replaces hand-managed threads and blocking `Future.get()` with `CompletableFuture` combinators for one-shot async results, and the reactive `Flow` API (or a library like RxJava) for ongoing streams of events with backpressure. Choose `CompletableFuture` for "compute these and combine," reactive streams for "react to events over time."

**Good example:**

```java
CompletableFuture<Double> total =
    priceAsync(product).thenCombine(rateAsync(EUR, USD), (p, r) -> p * r);
```

**Bad example:**

```java
double price = priceAsync(product).get();   // blocking, serial
double rate  = rateAsync(EUR, USD).get();   // blocks again
double total = price * rate;
```

### [21.4] Represent missing values with Optional, never the null pointer

Title: Continue using Optional to model absence in return types, eliminating null-pointer dereferences.
Description: `Optional` makes absence explicit and composable; combined with `map`/`flatMap`/`orElse`, it removes nested null checks and the "billion-dollar mistake" of unguarded null dereferences. Keep it for return types and optional model fields, not parameters/collections (see Chapter 11).

**Good example:**

```java
Optional<Insurance> findCheapest(Person p);
String name = findCheapest(person).map(Insurance::getName).orElse("Unknown");
```

**Bad example:**

```java
Insurance findCheapest(Person p);   // may return null
String name = findCheapest(person).getName();   // NullPointerException risk
```

### [21.5] Reduce boilerplate with local variable type inference (var, Java 10) — judiciously

Title: Use var for local variables when the initializer makes the type obvious; keep explicit types where they aid readability.
Description: Java 10's `var` infers a local variable's type from its initializer, cutting redundant type names — especially for long generic types. Use it where the type is clear from the right-hand side (`new`, a well-named factory); avoid it when it hides an important or non-obvious type, and remember `var` is for locals only (not fields, parameters, or return types). (Java 10+.)

**Good example:**

```java
var byCurrency = new HashMap<Currency, List<Transaction>>();   // type obvious from initializer
var path = Paths.get("data.txt");
```

**Bad example:**

```java
var result = compute();   // what type is this? var hides a non-obvious return type
var x = 0;                // trivial type; explicit `int x = 0;` is just as short and clearer
```

### [21.6] Adopt module-aware design and anticipate richer immutability and pattern matching

Title: Structure code into modules now, and design with the immutability and data-shape style that records, sealed types, and pattern matching reward.
Description: The book closes by pointing where Java is heading: stronger immutability (`record`s, value types), sealed hierarchies, and richer pattern matching. Designing with immutable data carriers, exhaustive type hierarchies, and clear module boundaries today positions code to adopt those features cleanly. Favor small immutable types and module encapsulation over sprawling mutable classes on a flat classpath.

**Good example:**

```java
// Immutable data carrier + clear module API — ready for records/sealed/pattern matching.
public final class Point {
    private final int x, y;
    public Point(int x, int y) { this.x = x; this.y = y; }
    public int getX() { return x; } public int getY() { return y; }
}
// module-info.java exports only the api package
```

**Bad example:**

```java
public class Point {            // mutable, on a flat classpath
    public int x, y;
    public void setX(int x) { this.x = x; }   // not the immutable, encapsulated direction Java rewards
}
```

## Appendix A — Miscellaneous Language Updates

### [A.1] Manage resources with try-with-resources instead of manual finally blocks

Title: Open AutoCloseable resources in a try-with-resources header so they are closed automatically and correctly.
Description: Try-with-resources (Java 7) declares one or more `AutoCloseable` resources in the `try` header and closes them automatically when the block exits — in reverse order, even on exception, and without masking the original exception (the close exception is suppressed). It replaces verbose, error-prone `finally` blocks that often forget null checks or swallow exceptions.

**Good example:**

```java
try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
    return br.readLine();
}   // br.close() called automatically, even on exception
```

**Bad example:**

```java
BufferedReader br = null;
try {
    br = new BufferedReader(new FileReader("data.txt"));
    return br.readLine();
} finally {
    if (br != null) br.close();   // manual, easy to forget; a close exception can mask the real one
}
```

### [A.2] Use the diamond operator and improved type inference

Title: Let the compiler infer generic type arguments with <> instead of repeating them.
Description: The diamond operator `<>` (Java 7) infers the generic type arguments of a constructor from the variable's declared type, removing the redundant repetition of type parameters. Later releases extended inference (e.g. allowing `<>` with anonymous classes in Java 9). Use it to cut noise while keeping full type safety.

**Good example:**

```java
Map<String, List<Integer>> m = new HashMap<>();        // types inferred
List<String> names = new ArrayList<>();
```

**Bad example:**

```java
Map<String, List<Integer>> m = new HashMap<String, List<Integer>>();   // redundant repetition
List<String> names = new ArrayList<String>();
```

### [A.3] Apply repeated and type annotations where they clarify intent

Title: Use repeating annotations and type annotations (Java 8) to express metadata directly instead of wrapper-array workarounds.
Description: Java 8 allows the same annotation to appear more than once on a declaration (repeating annotations, via a container) and allows annotations on any use of a type (type annotations), enabling tools like pluggable type checkers (e.g. `@NonNull List<@NonNull String>`). Use them where they make constraints explicit, instead of the old single-`@…s({...})` container workaround.

**Good example:**

```java
@Schedule(dayOfMonth = "last")
@Schedule(dayOfWeek = "Fri", hour = "23")
public void doPeriodicCleanup() { }                 // repeating annotations

List<@NonNull String> names = getNames();           // type annotation
```

**Bad example:**

```java
// Pre-Java-8 workaround: wrap repeats in a container annotation by hand.
@Schedules({
    @Schedule(dayOfMonth = "last"),
    @Schedule(dayOfWeek = "Fri", hour = "23")
})
public void doPeriodicCleanup() { }
```

