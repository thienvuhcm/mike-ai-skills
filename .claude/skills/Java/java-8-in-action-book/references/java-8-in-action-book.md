# Java 8 in Action — Lambdas, Streams, and Functional-Style Programming

## Role

You are a Senior software engineer with extensive experience in Java software development. You apply the lessons of *Java 8 in Action* (Urma, Fusco, Mycroft; Manning, 2015) to review, refactor, and write idiomatic, functional-style Java 8+.

## Goal

This reference synthesizes *Java 8 in Action* into concrete, applicable practices, organized into the book's chapters. Each practice states a best practice with a short rationale, a **Good example**, and a **Bad example**. Use it to:

- Review pre-Java-8 code (external iteration, anonymous classes, null returns, blocking `Future`s, mutable `Date`/`Calendar`) and modernize it.
- Guide refactoring toward behavior parameterization, lambdas, method references, the Streams API, collectors, `Optional`, `CompletableFuture`, the `java.time` API, default methods, and a functional, side-effect-free style.
- Teach the canonical Java 8 idioms with faithful Good/Bad contrasts.

Practices are numbered by chapter (e.g. "5.4 Flatten nested streams with flatMap"). When you apply one, cite it by chapter section and title.

## Constraints

Before applying refactorings derived from these practices, ensure the project compiles and tests pass. Many changes alter iteration style, laziness, threading, nullness contracts, and date/time handling and can change observable behavior.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying changes.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; do not claim success until the build and tests pass.
- **PREREQUISITE**: Project must compile successfully before any refactoring is applied; target Java 8 or later.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **PRESERVE BEHAVIOR**: Stream laziness, short-circuiting, parallelism, `Optional` contracts, and immutable `java.time` semantics must preserve observable behavior unless the user explicitly asks to change a contract.
- **CONCURRENCY SAFETY**: Never introduce shared mutable state into parallel streams or `forEach`; verify thread pools and `CompletableFuture` executors are sized and shut down correctly.
- **INCREMENTAL**: Apply one practice at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the relevant chapter section below for the Good/Bad examples and rationale.

## Examples

### Table of contents

**Part 1 — Fundamentals**

**Chapter 1 — Java 8: Why Should You Care?**

- 1.1 Pass behavior as a first-class value instead of wrapping it in a boilerplate object
- 1.2 Avoid duplicating a method just to vary one condition
- 1.3 Prefer a Predicate over a Function returning Boolean
- 1.4 Describe computations with Streams instead of iterating collections by hand
- 1.5 Write side-effect-free behavior so parallelism stays correct
- 1.6 Evolve published interfaces with default methods, not breaking changes
- 1.7 Use Optional to signal an absent value instead of returning null

**Chapter 2 — Passing Code with Behavior Parameterization**

- 2.1 Parameterize behavior, not values
- 2.2 Never use a boolean flag to pick which attribute a method filters on
- 2.3 Model selection criteria as a predicate interface (Strategy pattern)
- 2.4 Prefer lambda expressions over anonymous classes for one-off behavior
- 2.5 Abstract over the element type with generics
- 2.6 Parameterize standard JDK APIs (Comparator, Runnable, EventHandler) with lambdas

**Chapter 3 — Lambda Expressions**

- 3.1 Replace verbose anonymous classes with lambda expressions
- 3.2 Choose the right lambda body form: expression vs. block
- 3.3 Use lambdas only where a functional interface is expected
- 3.4 Mark single-abstract-method interfaces with @FunctionalInterface
- 3.5 Apply the execute-around pattern to parameterize resource processing
- 3.6 Reuse the built-in functional interfaces from java.util.function
- 3.7 Use primitive specializations to avoid autoboxing
- 3.8 Let the compiler infer parameter types via target typing
- 3.9 Capture only effectively final local variables
- 3.10 Prefer method references over lambdas that just call one method
- 3.11 Use constructor references to pass constructors as factories
- 3.12 Compose lambdas with default methods instead of writing complex ones by hand

**Part 2 — Functional-Style Data Processing**

**Chapter 4 — Introducing Streams**

- 4.1 Prefer declarative stream pipelines over imperative loops
- 4.2 Let streams iterate internally instead of iterating externally
- 4.3 Treat a stream as traversable only once
- 4.4 Build the pipeline from lazy intermediate operations, triggered by one terminal operation
- 4.5 Rely on short-circuiting and loop fusion rather than hand-tuned single passes
- 4.6 Reach for a stream when values can be computed on demand

**Chapter 5 — Working with Streams**

- 5.1 Filter with a predicate, and add distinct to drop duplicates
- 5.2 Slice a stream with the complementary limit and skip
- 5.3 Transform and extract data with map
- 5.4 Flatten nested streams with flatMap, not nested map
- 5.5 Find and match with short-circuiting terminal operations
- 5.6 Combine elements into a single value with reduce
- 5.7 Use primitive streams to avoid boxing in numeric reductions
- 5.8 Build streams from many sources, including infinite generators

**Chapter 6 — Collecting Data with Streams**

- 6.1 Use predefined Collectors instead of imperative grouping loops
- 6.2 Count, max, and min with counting / maxBy / minBy
- 6.3 Summarize numeric fields with summingInt / averagingInt / summarizingInt
- 6.4 Join strings with Collectors.joining(", ")
- 6.5 Prefer specialized collectors (or primitive streams) over generalized reducing
- 6.6 Build multilevel groupings by nesting groupingBy
- 6.7 Apply a downstream collector to each subgroup
- 6.8 Adapt subgroup results with collectingAndThen
- 6.9 Partition with a predicate using partitioningBy
- 6.10 Implement a custom Collector for cases the factories cannot cover

**Chapter 7 — Parallel Data Processing and Performance**

- 7.1 Measure before going parallel — parallel is not automatically faster
- 7.2 Avoid shared mutable state in parallel streams
- 7.3 Prefer primitive streams and splittable sources; avoid boxing and iterate
- 7.4 Use the fork/join framework via RecursiveTask, calling fork/compute/join correctly
- 7.5 Favor many small fork/join tasks to benefit from work stealing
- 7.6 Implement a custom Spliterator to control how a source splits

**Part 3 — Effective Java 8 Programming**

**Chapter 8 — Refactoring, Testing, and Debugging**

- 8.1 Refactor anonymous classes implementing a single method to lambda expressions
- 8.2 Refactor imperative iterator-based collection processing to the Streams API
- 8.3 Refactor lambda expressions to method references and built-in collectors
- 8.4 Replace boilerplate-heavy OO design patterns with lambdas
- 8.5 Implement the Factory pattern with a Map<String, Supplier<T>> of constructor references
- 8.6 Test lambdas by testing the behavior of the method that uses them
- 8.7 Debug stream pipelines with peek() instead of consuming the stream with forEach

**Chapter 9 — Default Methods**

- 9.1 Evolve published interfaces with default methods to preserve backward compatibility
- 9.2 Use default methods as optional methods to remove empty boilerplate implementations
- 9.3 Compose minimal, orthogonal interfaces for multiple inheritance of behavior
- 9.4 Apply the three resolution rules and X.super.method() to disambiguate conflicting defaults
- 9.5 Keep default methods minimal and prefer delegation over inheritance for code reuse

**Chapter 10 — Using Optional as a Better Alternative to null**

- 10.1 Model the structural absence of a value with Optional<T> instead of null
- 10.2 Create Optionals with empty(), of(), and ofNullable() according to the source value
- 10.3 Extract and chain values with map and flatMap instead of nested null checks
- 10.4 Reject unwanted values with filter and act with ifPresent
- 10.5 Choose the right default/throw strategy and never call get() without checking presence
- 10.6 Combine two Optionals with flatMap and map instead of isPresent/get
- 10.7 Wrap exception-throwing and null-returning legacy APIs in helper methods that return Optional
- 10.8 Do not use Optional for fields, method parameters, or collections — and avoid primitive Optionals

**Chapter 11 — CompletableFuture: Composable Asynchronous Programming**

- 11.1 Replace plain Future with CompletableFuture for composable async work
- 11.2 Create asynchronous computations with supplyAsync / runAsync
- 11.3 Propagate failures through the future, do not let them die in the worker thread
- 11.4 Don't block on get() sequentially — launch independent calls then collect
- 11.5 Supply a custom Executor sized for I/O instead of relying on the common pool
- 11.6 Pipeline dependent tasks with thenApply and thenCompose
- 11.7 Combine two independent futures with thenCombine
- 11.8 React to completion with thenAccept and coordinate with allOf / anyOf

**Chapter 12 — New Date and Time API**

- 12.1 Use immutable java.time types instead of mutable Date/Calendar
- 12.2 Create with of/parse and read fields with getters or ChronoField
- 12.3 Use Instant for machine time and Duration/Period for amounts of time
- 12.4 Manipulate dates immutably with plus/with and TemporalAdjusters
- 12.5 Format and parse with thread-safe DateTimeFormatter, not SimpleDateFormat
- 12.6 Handle time zones with ZoneId/ZonedDateTime, not java.util.TimeZone

**Part 4 — Beyond Java 8**

**Chapter 13 — Thinking Functionally**

- 13.1 Write side-effect-free, pure functions
- 13.2 Avoid shared mutable data structures
- 13.3 Program declaratively, not imperatively
- 13.4 Prefer immutable objects and final fields
- 13.5 Signal failure with Optional instead of exceptions
- 13.6 Replace mutating iteration with streams or recursion

**Chapter 14 — Functional Programming Techniques**

- 14.1 Treat functions as first-class values
- 14.2 Write higher-order functions
- 14.3 Curry functions to specialize and reuse logic
- 14.4 Use persistent data structures instead of destructive updates
- 14.5 Functionally update trees by re-creating only the path
- 14.6 Build lazy lists with Supplier-backed tails for infinite sequences
- 14.7 Defer computation with Supplier-based lazy evaluation
- 14.8 Emulate pattern matching with lambdas instead of instanceof chains

**Chapter 15 — Blending OOP and FP: Java 8 and Scala**

- 15.1 Use stream/collection operations to express queries concisely
- 15.2 Default the design to immutable, persistent collections
- 15.3 Use Optional/Option chaining instead of null checks
- 15.4 Add shared behavior with default methods on interfaces

**Chapter 16 — Conclusions and Where Next for Java**

- 16.1 Parameterize behavior with lambdas and method references
- 16.2 Pipeline data transformations with Streams
- 16.3 Compose asynchronous work with CompletableFuture
- 16.4 Represent missing values with Optional, never the null pointer

**Appendix B — Miscellaneous Library Updates**

- B.1 Read map values with getOrDefault
- B.2 Implement caching with computeIfAbsent
- B.3 Mutate collections in place with removeIf, replaceAll, and forEach
- B.4 Update map values atomically with merge
- B.5 Use overflow-checked Math operations and parallel array methods

---

## Chapter 1 — Java 8: Why Should You Care?

### [1.1] Pass behavior as a first-class value instead of wrapping it in a boilerplate object

Title: Use method references and lambdas to pass code directly to methods.
Description: Before Java 8, the only way to hand a piece of behavior to an API was to wrap it inside an object that implemented some interface, producing opaque, verbose code. Java 8 makes methods and lambdas first-class values, so you can pass the behavior itself. The resulting code reads closer to the problem statement and removes the ceremony of declaring and instantiating a one-off class.

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
Description: When two methods differ only in a single condition, copy-and-paste creates a maintenance trap—a bug fix or update applied to one variant is easily forgotten in the other. Java 8 lets you pass the varying condition as a `Predicate`, so a single filter method serves every selection criterion. This is shorter, clearer, and less error prone than maintaining parallel methods.

**Good example:**

```java
static List<Apple> filterApples(List<Apple> inventory, Predicate<Apple> p) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (p.test(apple)) {
            result.add(apple);
        }
    }
    return result;
}

// Both criteria reuse the same method:
List<Apple> green = filterApples(inventory, Apple::isGreenApple);
List<Apple> heavy = filterApples(inventory, Apple::isHeavyApple);
```

**Bad example:**

```java
static List<Apple> filterGreenApples(List<Apple> inventory) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if ("green".equals(apple.getColor())) {   // only this line differs
            result.add(apple);
        }
    }
    return result;
}

static List<Apple> filterHeavyApples(List<Apple> inventory) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (apple.getWeight() > 150) {            // ...from this one
            result.add(apple);
        }
    }
    return result;
}
```

### [1.3] Prefer a Predicate over a Function returning Boolean

Title: Model boolean selection criteria with `Predicate<T>`, not `Function<T, Boolean>`.
Description: A predicate is a function-like thing that takes a value and returns true or false. Java 8 could express this as `Function<Apple, Boolean>`, but `Predicate<Apple>` is the standard, intention-revealing choice. It is also slightly more efficient because it works with the primitive `boolean` and avoids boxing it into a `Boolean`.

**Good example:**

```java
Predicate<Apple> isGreen = apple -> "green".equals(apple.getColor());
List<Apple> greens = filterApples(inventory, isGreen);
```

**Bad example:**

```java
Function<Apple, Boolean> isGreen = apple -> "green".equals(apple.getColor());
// works, but obscures intent and boxes boolean -> Boolean on every call
```

### [1.4] Describe computations with Streams instead of iterating collections by hand

Title: Replace external iteration and nested control flow with a declarative Stream pipeline.
Description: Processing collections with explicit `for-each` loops and nested control-flow statements produces boilerplate that is hard to understand at a glance—you manage the iteration yourself (external iteration). The Streams API moves the iteration inside the library (internal iteration), letting you express *what* you want—filter, then collect—at a higher level of abstraction, much like a database query. As a bonus, switching `stream()` to `parallelStream()` lets the library partition the work across CPU cores almost for free.

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

### [1.5] Write side-effect-free behavior so parallelism stays correct

Title: Keep the code you pass to stream operations free of shared mutable state.
Description: "Parallelism almost for free" holds only when the behavior passed to a stream can run independently on different pieces of the input. That means avoiding access to shared mutable data—writing pure, stateless functions whose result depends solely on their arguments. Reaching for `synchronized` to share a mutable variable across cores fights the abstraction: it forces sequential execution and is often far more expensive than expected.

**Good example:**

```java
// Pure: depends only on its argument, mutates nothing shared
long count = inventory.parallelStream()
                      .filter(apple -> apple.getWeight() > 150)
                      .count();
```

**Bad example:**

```java
int[] total = {0};
inventory.parallelStream().forEach(apple -> {
    synchronized (total) {          // shared mutable state forced under a lock
        total[0] += apple.getWeight();
    }
});
```

### [1.6] Evolve published interfaces with default methods, not breaking changes

Title: Add new behavior to an interface via a `default` method so existing implementers keep compiling.
Description: Adding an abstract method to a published interface forces every implementing class—including ones you do not control—to provide an implementation or fail to compile. Java 8 default methods let an interface designer ship a method body inside the interface itself, enlarging the API without disrupting existing code. This is exactly how `List.sort` was added without breaking the countless classes that implement `List`.

**Good example:**

```java
public interface Sortable<E> {
    Comparator<? super E> naturalComparator();

    // New capability ships with a body — no implementer is forced to change
    default void sortInPlace(List<E> items) {
        items.sort(naturalComparator());
    }
}
```

**Bad example:**

```java
public interface Sortable<E> {
    Comparator<? super E> naturalComparator();
    void sortInPlace(List<E> items);   // abstract: breaks every existing implementer
}
```

### [1.7] Use Optional to signal an absent value instead of returning null

Title: Express "a value that may be missing" with `Optional<T>` rather than a bare nullable reference.
Description: The null reference forces callers to remember defensive checks and is a notorious source of `NullPointerException`. Java 8's `Optional<T>` is a container that may or may not hold a value and uses the type system to make the possible absence explicit. Callers are guided toward handling the empty case deliberately rather than discovering it at runtime.

**Good example:**

```java
public Optional<Apple> findHeaviest(List<Apple> inventory) {
    return inventory.stream()
                    .max(Comparator.comparingInt(Apple::getWeight));
}

String label = findHeaviest(inventory)
        .map(Apple::getColor)
        .orElse("no apples");
```

**Bad example:**

```java
public Apple findHeaviest(List<Apple> inventory) {
    Apple heaviest = null;
    for (Apple apple : inventory) {
        if (heaviest == null || apple.getWeight() > heaviest.getWeight()) {
            heaviest = apple;
        }
    }
    return heaviest;   // caller must remember it might be null
}
```

## Chapter 2 — Passing Code with Behavior Parameterization

### [2.1] Parameterize behavior, not values

Title: When a value parameter cannot capture the requirement, pass the selection behavior instead.
Description: Adding value parameters (a color string, a weight threshold) copes with simple, well-defined variation, but it cannot express richer or combined criteria such as "green *and* heavy." The better level of abstraction is to model the whole selection criterion as a behavior and pass it in. The method then separates the fixed logic of iterating the collection from the varying logic applied to each element.

**Good example:**

```java
public interface ApplePredicate {
    boolean test(Apple apple);
}

public static List<Apple> filter(List<Apple> inventory, ApplePredicate p) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (p.test(apple)) {
            result.add(apple);
        }
    }
    return result;
}
```

**Bad example:**

```java
// Value parameterization that cannot express combined criteria
public static List<Apple> filterApplesByColor(List<Apple> inventory, String color) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (apple.getColor().equals(color)) {
            result.add(apple);
        }
    }
    return result;
}
```

### [2.2] Never use a boolean flag to pick which attribute a method filters on

Title: Avoid flag parameters that merge unrelated behaviors into one cryptic signature.
Description: Folding several queries into one method gated by a `boolean` flag produces call sites where `true` and `false` are meaningless to a reader, and it scales terribly: every new attribute means another flag or another giant, complex method. The flag is a symptom that the method is trying to do more than one thing. Modeling the criterion as a behavior eliminates the flag entirely.

**Good example:**

```java
List<Apple> heavyApples = filter(inventory, apple -> apple.getWeight() > 150);
List<Apple> greenApples = filter(inventory, apple -> "green".equals(apple.getColor()));
```

**Bad example:**

```java
public static List<Apple> filterApples(List<Apple> inventory, String color,
                                        int weight, boolean flag) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if ((flag && apple.getColor().equals(color)) ||
            (!flag && apple.getWeight() > weight)) {
            result.add(apple);
        }
    }
    return result;
}

// What do these arguments even mean at the call site?
List<Apple> heavyApples = filterApples(inventory, "", 150, false);
```

### [2.3] Model selection criteria as a predicate interface (Strategy pattern)

Title: Encapsulate each algorithm behind a common interface so a strategy can be chosen at run-time.
Description: Defining a `ApplePredicate` interface and a family of implementations applies the strategy design pattern: the interface is the family of algorithms and each implementing class is one interchangeable strategy. The filter method depends only on the abstraction, so a brand-new requirement—red and heavy apples—is satisfied by adding a class, not by editing the method. This keeps the iterating logic and the per-element behavior cleanly separated.

**Good example:**

```java
public class AppleRedAndHeavyPredicate implements ApplePredicate {
    public boolean test(Apple apple) {
        return "red".equals(apple.getColor()) && apple.getWeight() > 150;
    }
}

List<Apple> redAndHeavy = filter(inventory, new AppleRedAndHeavyPredicate());
```

**Bad example:**

```java
// Hard-coded condition: a new requirement means editing or copying this method
public static List<Apple> filterRedAndHeavyApples(List<Apple> inventory) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if ("red".equals(apple.getColor()) && apple.getWeight() > 150) {
            result.add(apple);
        }
    }
    return result;
}
```

### [2.4] Prefer lambda expressions over anonymous classes for one-off behavior

Title: Replace bulky anonymous-class implementations with concise lambdas.
Description: Anonymous classes let you declare and instantiate a behavior at once, but they remain bulky—they consume space, obscure the single line that actually matters, and trip programmers with subtle scoping rules (for example, `this` inside an anonymous `Runnable` refers to the `Runnable`, not the enclosing class). A lambda passes just the boolean expression, so the code reads close to the problem statement. Reach for a method reference instead when a lambda grows beyond a few lines and a descriptive name would aid clarity.

**Good example:**

```java
List<Apple> result =
    filter(inventory, (Apple apple) -> "red".equals(apple.getColor()));
```

**Bad example:**

```java
List<Apple> result = filter(inventory, new ApplePredicate() {
    public boolean test(Apple apple) {
        return "red".equals(apple.getColor());
    }
});
```

### [2.5] Abstract over the element type with generics

Title: Make the behavior-parameterized method generic so it works beyond a single domain type.
Description: A filter that accepts only `List<Apple>` is tied to one problem domain. Introducing a type parameter `<T>` and a `Predicate<T>` lets the very same method filter bananas, oranges, integers, or strings. Combining generics with lambdas hits the sweet spot between flexibility and conciseness that was impossible before Java 8.

**Good example:**

```java
public static <T> List<T> filter(List<T> list, Predicate<T> p) {
    List<T> result = new ArrayList<>();
    for (T element : list) {
        if (p.test(element)) {
            result.add(element);
        }
    }
    return result;
}

List<Apple> redApples   = filter(inventory, apple -> "red".equals(apple.getColor()));
List<Integer> evens     = filter(numbers, i -> i % 2 == 0);
```

**Bad example:**

```java
// Locked to Apple — needs a near-identical copy for every other type
public static List<Apple> filter(List<Apple> inventory, ApplePredicate p) {
    List<Apple> result = new ArrayList<>();
    for (Apple apple : inventory) {
        if (p.test(apple)) {
            result.add(apple);
        }
    }
    return result;
}
```

### [2.6] Parameterize standard JDK APIs (Comparator, Runnable, EventHandler) with lambdas

Title: Pass behavior to built-in APIs like sorting, threads, and GUI handlers using lambdas.
Description: Many JDK methods already follow behavior parameterization—`List.sort` takes a `Comparator`, `Thread` takes a `Runnable`, and JavaFX `setOnAction` takes an `EventHandler`. Historically these were supplied as bulky anonymous classes. Because each of these is a single-abstract-method interface, a lambda expresses the same behavior far more concisely while keeping the internal mechanics (sorting algorithm, thread scheduling, event dispatch) abstracted away.

**Good example:**

```java
// Sorting
inventory.sort((Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight()));

// Thread body
Thread t = new Thread(() -> System.out.println("Hello world"));

// GUI event handling (JavaFX)
button.setOnAction((ActionEvent event) -> label.setText("Sent!!"));
```

**Bad example:**

```java
inventory.sort(new Comparator<Apple>() {
    public int compare(Apple a1, Apple a2) {
        return a1.getWeight().compareTo(a2.getWeight());
    }
});

Thread t = new Thread(new Runnable() {
    public void run() {
        System.out.println("Hello world");
    }
});

button.setOnAction(new EventHandler<ActionEvent>() {
    public void handle(ActionEvent event) {
        label.setText("Sent!!");
    }
});
```

## Chapter 3 — Lambda Expressions

### [3.1] Replace verbose anonymous classes with lambda expressions

Title: Use a lambda expression instead of an anonymous class to pass behavior.
Description: An anonymous class forces you to write the interface name, the method signature, and ceremony braces just to pass a single block of code. A lambda expression captures only the parameters, an arrow, and the body — the code that's really needed. The result reads like the problem statement ("compare two apples by weight") and encourages behavior parameterization in practice.

**Good example:**

```java
Comparator<Apple> byWeight =
    (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());
```

**Bad example:**

```java
Comparator<Apple> byWeight = new Comparator<Apple>() {
    public int compare(Apple a1, Apple a2) {
        return a1.getWeight().compareTo(a2.getWeight());
    }
};
```

### [3.2] Choose the right lambda body form: expression vs. block

Title: Use an expression body for a single result and a block body (with `return`) only when you need statements.
Description: A lambda is either `(parameters) -> expression` or `(parameters) -> { statements; }`. An expression body needs no braces, no semicolon, and no `return` — its value is the return value. The block form is required when the body has control-flow statements, and inside it `return` and semicolons are mandatory. Mixing the two (a bare expression inside braces, or a `return` without braces) does not compile.

**Good example:**

```java
// expression body — value is returned implicitly
Supplier<String> hero = () -> "Mario";

// block body — statements require braces and explicit return
Function<Integer, String> greet = (Integer i) -> { return "Alan" + i; };
```

**Bad example:**

```java
// invalid: "return" is a statement but there are no braces
Function<Integer, String> greet = (Integer i) -> return "Alan" + i;

// invalid: "Iron Man" is an expression, not a statement, inside braces
Function<String, String> wrong = (String s) -> { "Iron Man"; };
```

### [3.3] Use lambdas only where a functional interface is expected

Title: Provide a lambda whose signature matches the single abstract method of the target functional interface.
Description: A lambda has no type of its own; its type is inferred from the target type — the functional interface expected in that context (a method parameter, a variable assignment, or a cast). The lambda's parameters, return type, and thrown exceptions must match that interface's one abstract method. Trying to use a lambda where the target is not a functional interface, or where the signature does not match, is a compile error.

**Good example:**

```java
// Predicate<Apple>: (Apple) -> boolean — matches the lambda
List<Apple> greenApples =
    filter(inventory, (Apple a) -> "green".equals(a.getColor()));

// Runnable: () -> void — matches
public void process(Runnable r) { r.run(); }
process(() -> System.out.println("This is awesome!!"));
```

**Bad example:**

```java
// Object is not a functional interface — won't compile
Object o = () -> System.out.println("Tricky example");

// Predicate's test returns boolean, but this lambda returns Integer — won't compile
Predicate<Apple> p = (Apple a) -> a.getWeight();
```

### [3.4] Mark single-abstract-method interfaces with @FunctionalInterface

Title: Annotate intentional functional interfaces with `@FunctionalInterface`, keeping exactly one abstract method.
Description: A functional interface declares exactly one abstract method (default methods do not count against it). Adding `@FunctionalInterface` makes the intent explicit and lets the compiler reject the interface with a clear error — for example "Multiple non-overriding abstract methods found" — if a second abstract method sneaks in. It is the design-by-contract analogue of `@Override`: not mandatory, but good practice for interfaces meant to back lambdas.

**Good example:**

```java
@FunctionalInterface
public interface BufferedReaderProcessor {
    String process(BufferedReader b) throws IOException;
}
```

**Bad example:**

```java
// Intended as functional but has two abstract methods (add(double) plus
// inherited add(int)) — no annotation guards against the mistake, so a lambda
// for it silently fails to compile with a confusing error.
public interface SmartAdder {
    int add(int a, int b);
    int add(double a, double b);
}
```

### [3.5] Apply the execute-around pattern to parameterize resource processing

Title: Factor setup/cleanup into one method and pass the processing step as a lambda.
Description: Resource handling (files, databases) repeats the same open/cleanup ceremony around a small, varying action. Define a functional interface for the action, accept it as a parameter, and invoke it between the boilerplate — so callers reuse the setup/teardown and supply only the behavior. This keeps `try-with-resources` in one place while making the method flexible enough to read one line, two lines, or anything else.

**Good example:**

```java
@FunctionalInterface
public interface BufferedReaderProcessor {
    String process(BufferedReader b) throws IOException;
}

public static String processFile(BufferedReaderProcessor p) throws IOException {
    try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
        return p.process(br);            // the parameterized action
    }
}

// Callers pass different behaviors; setup/cleanup is reused:
String oneLine  = processFile(br -> br.readLine());
String twoLines = processFile(br -> br.readLine() + br.readLine());
```

**Bad example:**

```java
// Behavior is hardcoded; reading two lines requires copy-pasting all the
// open/close boilerplate into a second nearly identical method.
public static String processFile() throws IOException {
    try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
        return br.readLine();            // can only ever read the first line
    }
}
```

### [3.6] Reuse the built-in functional interfaces from java.util.function

Title: Prefer `Predicate<T>`, `Consumer<T>`, `Function<T,R>`, and `Supplier<T>` over hand-rolled interfaces.
Description: Java 8 ships a starter kit of functional interfaces so you rarely need to declare your own: `Predicate<T>` (`T -> boolean`) for boolean tests, `Consumer<T>` (`T -> void`) for side effects, `Function<T,R>` (`T -> R`) for transformations, and `Supplier<T>` (`() -> T`) for factories. Reusing them keeps signatures familiar and lets your code interoperate with the rest of the standard library (especially the Streams API).

**Good example:**

```java
Predicate<String>          nonEmpty  = s -> !s.isEmpty();
Consumer<Apple>            printIt   = a -> System.out.println(a.getWeight());
Function<String, Integer>  toLength  = s -> s.length();
Supplier<Apple>            newApple  = () -> new Apple(10);
```

**Bad example:**

```java
// Reinventing interfaces that already exist in java.util.function — extra
// boilerplate and no interoperability with the standard library.
@FunctionalInterface interface StringTest   { boolean test(String s); }
@FunctionalInterface interface AppleAction  { void run(Apple a); }
@FunctionalInterface interface LengthMapper { int map(String s); }

StringTest   nonEmpty = s -> !s.isEmpty();
AppleAction  printIt  = a -> System.out.println(a.getWeight());
LengthMapper toLength = s -> s.length();
```

### [3.7] Use primitive specializations to avoid autoboxing

Title: Choose `IntPredicate`, `IntFunction`, `ToIntFunction`, etc. when working with primitives.
Description: Generic type parameters bind only to reference types, so `Predicate<Integer>` boxes every primitive argument into an `Integer` — a heap allocation plus a memory lookup to unwrap it. Java 8 provides specialized variants (`IntPredicate`, `IntConsumer`, `IntFunction<R>`, `ToIntFunction<T>`, and the `Long`/`Double` equivalents) that operate directly on primitives. Use them in performance-sensitive code to eliminate needless boxing.

**Good example:**

```java
// No boxing: 1000 is passed as a primitive int
IntPredicate evenInt = i -> i % 2 == 0;
boolean result = evenInt.test(1000);
```

**Bad example:**

```java
// Autoboxes 1000 into an Integer on the heap on every call
Predicate<Integer> evenBoxed = i -> i % 2 == 0;
boolean result = evenBoxed.test(1000);
```

### [3.8] Let the compiler infer parameter types via target typing

Title: Omit lambda parameter types (and parentheses for a single inferred parameter) when the target type makes them clear.
Description: Because the target type already supplies the function descriptor, the compiler can infer each lambda parameter's type — so you can drop the explicit type annotations. With a single inferred parameter you may also drop the surrounding parentheses. The gain is most visible on multi-parameter lambdas. There is no hard rule; sometimes explicit types aid readability, but inference removes noise that duplicates information the compiler already has.

**Good example:**

```java
// Parameter types inferred from Comparator<Apple>
Comparator<Apple> byWeight =
    (a1, a2) -> a1.getWeight().compareTo(a2.getWeight());

// Single inferred parameter: parentheses omitted
Consumer<String> printIt = s -> System.out.println(s);
```

**Bad example:**

```java
// Redundant: the types are already knowable from the target type
Comparator<Apple> byWeight =
    (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());

Consumer<String> printIt = (String s) -> System.out.println(s);
```

### [3.9] Capture only effectively final local variables

Title: Do not mutate local variables you reference inside a lambda; capture values, not changing variables.
Description: A lambda may freely read instance and static variables, but a captured local variable must be `final` or effectively final — assigned exactly once. Local variables live on the stack and are confined to their thread; the lambda closes over a copy, so allowing reassignment would be thread-unsafe and meaningless. This restriction also steers you away from imperative outer-variable mutation that blocks easy parallelization. If you need a running result, redesign rather than reassign.

**Good example:**

```java
int portNumber = 1337;                       // effectively final
Runnable r = () -> System.out.println(portNumber);
r.run();
```

**Bad example:**

```java
int portNumber = 1337;
Runnable r = () -> System.out.println(portNumber);
portNumber = 31337;                          // second assignment — won't compile:
                                             // captured local must be effectively final
```

### [3.10] Prefer method references over lambdas that just call one method

Title: Replace a lambda that does nothing but invoke an existing method with a `::` method reference.
Description: When a lambda's whole body is a single call to an existing method, refer to that method by name instead of describing how to call it. The three forms are: static methods (`Integer::parseInt`), instance methods of an arbitrary type whose receiver is supplied as a parameter (`String::length`), and instance methods bound to a specific existing object (`expensiveTransaction::getValue`). Method references read more naturally and make intent obvious; the compiler type-checks them against the target descriptor exactly as it does lambdas.

**Good example:**

```java
Function<String, Integer> toInt   = Integer::parseInt;           // static
List<String> words = new ArrayList<>(List.of("a","b","A","B"));
words.sort(String::compareToIgnoreCase);                          // arbitrary-type instance
BiPredicate<List<String>, String> has = List::contains;           // arbitrary-type instance
Runnable dump = Thread.currentThread()::dumpStack;                // bound instance
```

**Bad example:**

```java
Function<String, Integer> toInt = (String s) -> Integer.parseInt(s);
words.sort((s1, s2) -> s1.compareToIgnoreCase(s2));
BiPredicate<List<String>, String> has = (list, element) -> list.contains(element);
Runnable dump = () -> Thread.currentThread().dumpStack();
```

### [3.11] Use constructor references to pass constructors as factories

Title: Write `ClassName::new` instead of a lambda that only instantiates an object.
Description: A constructor reference `ClassName::new` lets you treat a constructor as a factory and match it to a functional interface by arity: a no-arg constructor fits `Supplier<T>`, a one-arg constructor fits `Function<T,R>`, and a two-arg constructor fits `BiFunction<T,U,R>`. This avoids hand-written lambdas, enables data-driven object creation (e.g. mapping a list of weights to apples), and keeps the code concise. For arities beyond the built-ins, define a small matching interface such as `TriFunction`.

**Good example:**

```java
Supplier<Apple>          emptyApple = Apple::new;          // () -> new Apple()
Function<Integer, Apple> byWeight   = Apple::new;          // w  -> new Apple(w)
BiFunction<String, Integer, Apple> byColorWeight = Apple::new; // (c, w) -> new Apple(c, w)

List<Apple> apples = Stream.of(7, 3, 10)
    .map(Apple::new)                                       // each weight -> new Apple(weight)
    .collect(Collectors.toList());
```

**Bad example:**

```java
Supplier<Apple>          emptyApple = () -> new Apple();
Function<Integer, Apple> byWeight   = (Integer w) -> new Apple(w);
BiFunction<String, Integer, Apple> byColorWeight =
    (String c, Integer w) -> new Apple(c, w);

List<Apple> apples = Stream.of(7, 3, 10)
    .map(w -> new Apple(w))
    .collect(Collectors.toList());
```

### [3.12] Compose lambdas with default methods instead of writing complex ones by hand

Title: Build complex behavior from simple lambdas using `Comparator.comparing/reversed/thenComparing`, `Predicate.and/or/negate`, and `Function.andThen/compose`.
Description: Functional interfaces in the API expose default methods for composition, so you assemble complicated behavior from small, readable pieces. Chain comparators with `comparing(...).reversed().thenComparing(...)`; combine predicates with `negate`, `and`, `or` (evaluated left-to-right, so `a.or(b).and(c)` means `(a || b) && c`); and pipeline functions with `andThen` (apply this, then the next) or `compose` (apply the argument first, then this). The composed result still reads like the problem statement.

**Good example:**

```java
// Comparator: by weight descending, then by country to break ties
inventory.sort(comparing(Apple::getWeight)
        .reversed()
        .thenComparing(Apple::getCountry));

// Predicate: red and heavy, or green
Predicate<Apple> redAndHeavyOrGreen =
    redApple.and(a -> a.getWeight() > 150).or(a -> "green".equals(a.getColor()));

// Function: header -> spell-check -> footer
Function<String, String> pipeline =
    ((Function<String, String>) Letter::addHeader)
        .andThen(Letter::checkSpelling)
        .andThen(Letter::addFooter);
```

**Bad example:**

```java
// Hand-rolled comparator re-implementing reverse + tie-break logic
inventory.sort((a1, a2) -> {
    int byWeight = a2.getWeight().compareTo(a1.getWeight());   // manual reverse
    return byWeight != 0 ? byWeight : a1.getCountry().compareTo(a2.getCountry());
});

// One sprawling predicate instead of composed parts
Predicate<Apple> redAndHeavyOrGreen = a ->
    ("red".equals(a.getColor()) && a.getWeight() > 150) || "green".equals(a.getColor());

// Manually nested calls instead of a readable pipeline
Function<String, String> pipeline =
    text -> Letter.addFooter(Letter.checkSpelling(Letter.addHeader(text)));
```

## Chapter 4 — Introducing Streams

### [4.1] Prefer declarative stream pipelines over imperative loops

Title: Express *what* you want with a stream pipeline instead of coding *how* to iterate.
Description: Pre-Java-8 collection processing forces you to spell out control flow — loops, `if` conditions, and a throwaway "garbage variable" used only as an intermediate container. A stream pipeline chains high-level building blocks (`filter`, `sorted`, `map`, `collect`) so you state the query and let the library decide how to run it. The result is more concise, more readable, and adaptable to changing requirements without copy-pasting loop scaffolding.

**Good example:**

```java
import static java.util.stream.Collectors.toList;
import static java.util.Comparator.comparing;

List<String> lowCaloricDishesName =
        menu.stream()
            .filter(d -> d.getCalories() < 400)
            .sorted(comparing(Dish::getCalories))
            .map(Dish::getName)
            .collect(toList());
```

**Bad example:**

```java
// Java 7: imperative, with a throwaway "garbage variable"
List<Dish> lowCaloricDishes = new ArrayList<>();
for (Dish d : menu) {
    if (d.getCalories() < 400) {
        lowCaloricDishes.add(d);
    }
}
Collections.sort(lowCaloricDishes, new Comparator<Dish>() {
    public int compare(Dish d1, Dish d2) {
        return Integer.compare(d1.getCalories(), d2.getCalories());
    }
});
List<String> lowCaloricDishesName = new ArrayList<>();
for (Dish d : lowCaloricDishes) {
    lowCaloricDishesName.add(d.getName());
}
```

### [4.2] Let streams iterate internally instead of iterating externally

Title: Provide a function describing the work and let the Streams library drive the iteration.
Description: With the Collection API you iterate explicitly (external iteration) using `for-each`, which is just syntactic sugar over an `Iterator` — you pull out and process items one by one and commit yourself to single-threaded, sequential traversal. Streams use internal iteration: you say what to do and the library handles pulling elements, choosing the data representation, and optionally running in parallel or in a more optimized order. This is the core reason streams exist.

**Good example:**

```java
// Internal iteration: the Streams library controls traversal
List<String> names =
        menu.stream()
            .map(Dish::getName)
            .collect(toList());
```

**Bad example:**

```java
// External iteration: you manage the loop yourself (for-each hides an Iterator)
List<String> names = new ArrayList<>();
for (Dish d : menu) {
    names.add(d.getName());
}
// Equivalent uglier form the for-each desugars into:
Iterator<Dish> it = menu.iterator();
while (it.hasNext()) {
    Dish d = it.next();
    names.add(d.getName());
}
```

### [4.3] Treat a stream as traversable only once

Title: Build a fresh stream from the source for each traversal — a consumed stream cannot be reused.
Description: Like an iterator, a stream can be traversed only once; after a terminal operation it is consumed and reusing it throws `IllegalStateException`. If the source is a repeatable collection you can simply obtain a new stream from it to traverse again; if the source is an I/O channel you are out of luck. Never hold a `Stream` reference expecting to run several terminal operations on it.

**Good example:**

```java
// Obtain a new stream from the repeatable source each time
List<String> title = Arrays.asList("Java8", "In", "Action");

title.stream().forEach(System.out::println);
title.stream().forEach(System.out::println); // fresh stream, fine
```

**Bad example:**

```java
// Reusing a consumed stream throws java.lang.IllegalStateException
List<String> title = Arrays.asList("Java8", "In", "Action");

Stream<String> s = title.stream();
s.forEach(System.out::println);
s.forEach(System.out::println); // stream has already been operated upon or closed
```

### [4.4] Build the pipeline from lazy intermediate operations, triggered by one terminal operation

Title: Chain intermediate operations (`filter`, `map`, `limit`, `sorted`, `distinct`) lazily; only a terminal operation runs the pipeline.
Description: Intermediate operations return another `Stream` and do nothing until a terminal operation is invoked — they are lazy and can be merged into a single pass. Terminal operations (`collect`, `forEach`, `count`) produce a non-stream result and actually execute the pipeline. Because the work is deferred, the library can fuse the steps and short-circuit, e.g. stopping as soon as `limit(3)` has found three matches rather than scanning the whole menu.

**Good example:**

```java
// One lazy pipeline; collect (terminal) runs it, fusing filter+map and stopping at 3
List<String> threeHighCaloricDishNames =
        menu.stream()
            .filter(d -> d.getCalories() > 300)
            .map(Dish::getName)
            .limit(3)
            .collect(toList());
```

**Bad example:**

```java
// Eager, multi-pass: each step builds a full intermediate list, nothing is fused,
// and the whole menu is filtered/mapped even though only 3 names are needed
List<Dish> highCaloric = new ArrayList<>();
for (Dish d : menu) {
    if (d.getCalories() > 300) {
        highCaloric.add(d);
    }
}
List<String> allNames = new ArrayList<>();
for (Dish d : highCaloric) {
    allNames.add(d.getName());
}
List<String> threeHighCaloricDishNames =
        allNames.subList(0, Math.min(3, allNames.size()));
```

### [4.5] Rely on short-circuiting and loop fusion rather than hand-tuned single passes

Title: Compose readable operations and trust the Streams library to fuse them into one short-circuiting pass.
Description: Even though `filter` and `map` are written as separate operations, the Streams library merges them into the same pass (loop fusion), and short-circuiting operations such as `limit` stop processing as soon as enough elements are produced. Adding a side-effecting print inside each lambda reveals only the first three dishes are ever filtered and mapped. You get the efficiency of a single hand-rolled loop while keeping each concern as its own declarative step.

**Good example:**

```java
// Logs show only pork, beef, chicken processed — filter+map fused, limit short-circuits
List<String> names =
        menu.stream()
            .filter(d -> {
                System.out.println("filtering:" + d.getName());
                return d.getCalories() > 300;
            })
            .map(d -> {
                System.out.println("mapping:" + d.getName());
                return d.getName();
            })
            .limit(3)
            .collect(toList());
```

**Bad example:**

```java
// Two full passes, no fusion, no short-circuit: every dish is filtered AND mapped
List<Dish> filtered = new ArrayList<>();
for (Dish d : menu) {                       // pass 1: filters ALL dishes
    System.out.println("filtering:" + d.getName());
    if (d.getCalories() > 300) filtered.add(d);
}
List<String> names = new ArrayList<>();
for (Dish d : filtered) {                   // pass 2: maps ALL filtered dishes
    System.out.println("mapping:" + d.getName());
    names.add(d.getName());
}
names = names.subList(0, Math.min(3, names.size()));
```

### [4.6] Reach for a stream when values can be computed on demand

Title: Use streams (not collections) when elements should be produced just-in-time, including unbounded sequences.
Description: A collection is an eagerly constructed, in-memory data structure: every element must be computed before it can be added, which makes it impossible to model an infinite sequence. A stream is conceptually fixed but its elements are computed on demand in a producer–consumer relationship, so consumers extract only what they need. This demand-driven nature lets you express infinite sequences (e.g. all even numbers) and bound them with `limit`, something a collection can never do.

**Good example:**

```java
// Values produced on demand; limit bounds the otherwise-infinite stream
Stream.iterate(0, n -> n + 2)
      .limit(10)
      .forEach(System.out::println);
```

**Bad example:**

```java
// Eager collection of "all even numbers" never finishes — the consumer never sees it
List<Integer> allEvens = new ArrayList<>();
int n = 0;
while (true) {            // loops forever computing and adding, never returns
    allEvens.add(n);
    n += 2;
}
// unreachable: allEvens can never be handed to a consumer
```

## Chapter 5 — Working with Streams

### [5.1] Filter with a predicate, and add `distinct` to drop duplicates

Title: Select matching elements with `filter`, and chain `distinct` when you need unique results.
Description: `filter` takes a `Predicate` (a function returning `boolean`) and returns a stream of all elements that match, replacing hand-written `if`/`add` loops. `distinct` returns a stream with duplicate elements removed according to the elements' `hashCode`/`equals`. Combining them — e.g. keep even numbers, then de-duplicate — keeps each concern as its own composable, declarative step.

**Good example:**

```java
List<Integer> numbers = Arrays.asList(1, 2, 1, 3, 3, 2, 4);
numbers.stream()
       .filter(i -> i % 2 == 0)
       .distinct()
       .forEach(System.out::println); // prints 2, 4
```

**Bad example:**

```java
// Manual filtering plus a Set to track seen values — boilerplate the library handles
List<Integer> numbers = Arrays.asList(1, 2, 1, 3, 3, 2, 4);
Set<Integer> seen = new HashSet<>();
List<Integer> result = new ArrayList<>();
for (Integer i : numbers) {
    if (i % 2 == 0 && seen.add(i)) {
        result.add(i);
    }
}
for (Integer i : result) {
    System.out.println(i);
}
```

### [5.2] Slice a stream with the complementary `limit` and `skip`

Title: Truncate with `limit(n)` and discard a prefix with `skip(n)` instead of manual counters.
Description: `limit(n)` returns a stream no longer than `n` (on an ordered source, the first `n` elements); `skip(n)` returns a stream that discards the first `n` elements, yielding an empty stream if there are fewer than `n`. They are complementary and compose cleanly with `filter`. (Note: `takeWhile`/`dropWhile` are Java 9 additions; on Java 8 use `limit`/`skip` for slicing.)

**Good example:**

```java
// First three dishes over 300 calories
List<Dish> first3 = menu.stream()
                        .filter(d -> d.getCalories() > 300)
                        .limit(3)
                        .collect(toList());

// All but the first two dishes over 300 calories
List<Dish> rest = menu.stream()
                      .filter(d -> d.getCalories() > 300)
                      .skip(2)
                      .collect(toList());
```

**Bad example:**

```java
// Imperative counter-based slicing — error-prone index arithmetic
List<Dish> first3 = new ArrayList<>();
int count = 0;
for (Dish d : menu) {
    if (d.getCalories() > 300) {
        if (count < 3) {
            first3.add(d);
        }
        count++;
    }
}
```

### [5.3] Transform and extract data with `map`

Title: Apply a function to every element with `map` to create a new, transformed stream.
Description: `map` takes a `Function`, applies it to each element, and produces a new stream of the results — ideal for extracting a field (`Dish::getName`) or computing a derived value (`String::length`). It "creates a new version of" each element rather than mutating it, and `map` calls can be chained to transform step by step. The output element type follows the function's return type (e.g. mapping with `getName` yields a `Stream<String>`).

**Good example:**

```java
// Extract each dish name, then its length, by chaining map
List<Integer> dishNameLengths =
        menu.stream()
            .map(Dish::getName)
            .map(String::length)
            .collect(toList());
```

**Bad example:**

```java
// Manual loop that mixes extraction and transformation by hand
List<Integer> dishNameLengths = new ArrayList<>();
for (Dish d : menu) {
    String name = d.getName();
    dishNameLengths.add(name.length());
}
```

### [5.4] Flatten nested streams with `flatMap`, not nested `map`

Title: Use `flatMap` to replace each element with a stream and concatenate them into one flat stream.
Description: Mapping each element to a collection/array yields a `Stream<Stream<...>>` (or `Stream<String[]>`), which is rarely what you want. `flatMap` maps each element to a stream and then amalgamates all those streams into a single flat stream — so you get a `Stream<String>` of characters instead of a stream of arrays. It is the right tool for "unique characters across words" or generating pairs of numbers from two lists.

**Good example:**

```java
// Unique characters across a list of words: one flat Stream<String>
List<String> uniqueCharacters =
        words.stream()
             .map(word -> word.split(""))   // Stream<String[]>
             .flatMap(Arrays::stream)        // flattened into Stream<String>
             .distinct()
             .collect(toList());

// All pairs (i, j) from two number lists, flattened
List<int[]> pairs =
        numbers1.stream()
                .flatMap(i -> numbers2.stream()
                                      .map(j -> new int[]{i, j}))
                .collect(toList());
```

**Bad example:**

```java
// Nested map leaves you with a Stream<Stream<String>> — never flat
List<Stream<String>> wrong =
        words.stream()
             .map(word -> Arrays.stream(word.split("")))  // Stream<Stream<String>>
             .distinct()
             .collect(toList()); // not a stream of characters at all

// Pairs via nested loops instead of flatMap
List<int[]> pairs = new ArrayList<>();
for (int i : new int[]{1, 2, 3}) {
    for (int j : new int[]{3, 4}) {
        pairs.add(new int[]{i, j});
    }
}
```

### [5.5] Find and match with short-circuiting terminal operations

Title: Answer existence and search questions with `anyMatch`/`allMatch`/`noneMatch` and `findFirst`/`findAny`.
Description: `anyMatch`, `allMatch`, and `noneMatch` return a `boolean` and short-circuit — they stop as soon as the answer is decided, mirroring Java's `&&`/`||`. `findFirst` returns the first element of an ordered stream; `findAny` returns an arbitrary element and is preferable for parallel streams because it is less constraining. Both finders return an `Optional<T>` so you must explicitly handle the absence of a value rather than risk a `null`.

**Good example:**

```java
boolean vegetarianFriendly = menu.stream().anyMatch(Dish::isVegetarian);
boolean isHealthy = menu.stream().allMatch(d -> d.getCalories() < 1000);
boolean noneTooRich = menu.stream().noneMatch(d -> d.getCalories() >= 1000);

Optional<Dish> dish =
        menu.stream()
            .filter(Dish::isVegetarian)
            .findAny();
dish.ifPresent(d -> System.out.println(d.getName()));
```

**Bad example:**

```java
// Imperative search that scans everything and returns a null-prone result
Dish found = null;
boolean vegetarianFriendly = false;
for (Dish d : menu) {
    if (d.isVegetarian()) {
        vegetarianFriendly = true;
        if (found == null) {
            found = d;       // no short-circuit; loop keeps running
        }
    }
}
System.out.println(found.getName()); // NullPointerException if no vegetarian dish
```

### [5.6] Combine elements into a single value with `reduce`

Title: Fold a stream to one value with `reduce`, supplying an identity and a `BinaryOperator`.
Description: `reduce` abstracts the "initialize an accumulator, then combine each element" pattern used for sum, product, max, and min. The two-argument form takes an identity value and a `BinaryOperator<T>` and always returns a value; the one-argument form omits the identity and returns an `Optional<T>` to handle an empty stream. Unlike a mutable accumulator variable, `reduce` uses internal iteration with no shared mutable state, so it parallelizes gracefully (the operator must be associative and stateless).

**Good example:**

```java
int sum     = numbers.stream().reduce(0, Integer::sum);
int product = numbers.stream().reduce(1, (a, b) -> a * b);

Optional<Integer> max = numbers.stream().reduce(Integer::max);
Optional<Integer> min = numbers.stream().reduce(Integer::min);
```

**Bad example:**

```java
// Mutable accumulator pattern — a dead end for parallelization (shared sum variable)
int sum = 0;
for (int x : numbers) {
    sum += x;
}

int max = Integer.MIN_VALUE;
for (int x : numbers) {
    if (x > max) max = x;
}
```

### [5.7] Use primitive streams to avoid boxing in numeric reductions

Title: Map to `IntStream`/`LongStream`/`DoubleStream` so methods like `sum`, `max`, and `average` work without boxing.
Description: A `Stream<Integer>` incurs an "insidious boxing cost" — each `Integer` must be unboxed before arithmetic — and the generic `Stream` interface offers no `sum`. `mapToInt` (and friends) produce a primitive `IntStream` that exposes `sum` (returning `0` for an empty stream), `max`, `min`, and `average` directly, with no hidden boxing. Convert back to objects with `boxed`/`mapToObj` when you need a general stream, and use `OptionalInt` for `max` where a default of `0` would be ambiguous.

**Good example:**

```java
int calories = menu.stream()
                   .mapToInt(Dish::getCalories) // IntStream — no boxing
                   .sum();

OptionalInt maxCalories = menu.stream()
                              .mapToInt(Dish::getCalories)
                              .max();
int max = maxCalories.orElse(1);

// Count even numbers in a range; rangeClosed is inclusive
long evens = IntStream.rangeClosed(1, 100)
                      .filter(n -> n % 2 == 0)
                      .count(); // 50
```

**Bad example:**

```java
// Stream<Integer> forces unboxing on every addition, and there is no sum() to call
int calories = menu.stream()
                   .map(Dish::getCalories)        // Stream<Integer>
                   .reduce(0, Integer::sum);       // each Integer unboxed behind the scenes

// max with reduce(0, ...) silently returns 0 for an empty stream — wrong/ambiguous
int max = menu.stream()
              .map(Dish::getCalories)
              .reduce(0, Integer::max);
```

### [5.8] Build streams from many sources, including infinite generators

Title: Create streams from values, arrays, files, and functions (`Stream.iterate`/`Stream.generate`) — not only from collections.
Description: Beyond `collection.stream()`, use `Stream.of` for explicit values (`Stream.empty()` for none), `Arrays.stream` for arrays, and `Files.lines` for a stream of file lines. `Stream.iterate` takes a seed and a `UnaryOperator` to produce successive values (e.g. a date and its next date), while `Stream.generate` takes a `Supplier` for independently computed values. Both yield infinite streams, so bound them with `limit`; prefer stateless, immutable functions because a stateful supplier is unsafe in parallel code.

**Good example:**

```java
// From explicit values
Stream<String> stream = Stream.of("Java 8 ", "Lambdas ", "In ", "Action");
stream.map(String::toUpperCase).forEach(System.out::println);

// Infinite stream of even numbers, bounded with limit
Stream.iterate(0, n -> n + 2)
      .limit(10)
      .forEach(System.out::println);

// Count distinct words in a file via flatMap + distinct + count
try (Stream<String> lines = Files.lines(Paths.get("data.txt"), Charset.defaultCharset())) {
    long uniqueWords = lines.flatMap(line -> Arrays.stream(line.split(" ")))
                            .distinct()
                            .count();
}
```

**Bad example:**

```java
// Reinventing a fixed collection of even numbers instead of an on-demand stream
List<Integer> evens = new ArrayList<>();
for (int i = 0; i < 10; i++) {
    evens.add(i * 2);
}
for (int e : evens) {
    System.out.println(e);
}

// Manual file/word counting with explicit reader and Set
BufferedReader reader = new BufferedReader(new FileReader("data.txt"));
Set<String> words = new HashSet<>();
String line;
while ((line = reader.readLine()) != null) {
    for (String w : line.split(" ")) {
        words.add(w);
    }
}
long uniqueWords = words.size();
```

## Chapter 6 — Collecting Data with Streams

### [6.1] Use predefined Collectors instead of imperative grouping loops

Title: Express "what" you want with a Collector, not "how" with nested loops.
Description: Grouping, partitioning, and summarizing in imperative style requires verbose, error-prone loops whose intent is hard to read. The `collect` terminal operation parameterized by a `Collector` (built from `Collectors` factory methods) lets you formulate the result declaratively. The functional version is a single readable statement and composes far better when requirements grow.

**Good example:**

```java
import static java.util.stream.Collectors.groupingBy;

Map<Currency, List<Transaction>> byCurrency =
    transactions.stream().collect(groupingBy(Transaction::getCurrency));
```

**Bad example:**

```java
Map<Currency, List<Transaction>> byCurrency = new HashMap<>();
for (Transaction t : transactions) {
    Currency currency = t.getCurrency();
    List<Transaction> bucket = byCurrency.get(currency);
    if (bucket == null) {
        bucket = new ArrayList<>();
        byCurrency.put(currency, bucket);
    }
    bucket.add(t);
}
```

### [6.2] Count, max, and min with counting / maxBy / minBy

Title: Reach for `counting()`, `maxBy`, and `minBy` rather than hand-rolling reductions.
Description: The `Collectors.counting()` collector counts elements, and `maxBy`/`minBy` take a `Comparator` (typically built with `Comparator.comparingInt`) to find extremes. These return an `Optional` because the stream may be empty. Although a single count can also be done with `Stream.count()`, the `counting()` collector becomes essential when nested inside `groupingBy`.

**Good example:**

```java
import static java.util.stream.Collectors.maxBy;
import static java.util.Comparator.comparingInt;

Optional<Dish> mostCalorieDish =
    menu.stream().collect(maxBy(comparingInt(Dish::getCalories)));
```

**Bad example:**

```java
Dish mostCalorieDish = null;
for (Dish d : menu) {
    if (mostCalorieDish == null
            || d.getCalories() > mostCalorieDish.getCalories()) {
        mostCalorieDish = d; // null when menu is empty; no Optional safety
    }
}
```

### [6.3] Summarize numeric fields with summingInt / averagingInt / summarizingInt

Title: Use summarization collectors to sum, average, or gather statistics in one pass.
Description: `summingInt`, `averagingInt` (with their `Long`/`Double` siblings) accept a function mapping each object to a numeric value and accumulate it. When you need several statistics at once, `summarizingInt` produces an `IntSummaryStatistics` holding count, sum, min, average, and max from a single traversal — instead of iterating the stream multiple times.

**Good example:**

```java
import static java.util.stream.Collectors.summarizingInt;

IntSummaryStatistics menuStatistics =
    menu.stream().collect(summarizingInt(Dish::getCalories));
// IntSummaryStatistics{count=9, sum=4300, min=120, average=477.78, max=800}
```

**Bad example:**

```java
int total = 0, max = Integer.MIN_VALUE, min = Integer.MAX_VALUE, count = 0;
for (Dish d : menu) {
    int c = d.getCalories();
    total += c;
    if (c > max) max = c;
    if (c < min) min = c;
    count++;
}
double average = count == 0 ? 0 : (double) total / count;
```

### [6.4] Join strings with Collectors.joining(", ")

Title: Concatenate with `joining` (and a delimiter) rather than a manual StringBuilder.
Description: The `joining` collector internally uses a `StringBuilder` to concatenate the `toString` of each element. Its overload accepting a delimiter produces clean, human-readable output (for example a comma-separated list) without the off-by-one delimiter bugs of manual appending.

**Good example:**

```java
import static java.util.stream.Collectors.joining;

String shortMenu =
    menu.stream().map(Dish::getName).collect(joining(", "));
// pork, beef, chicken, french fries, rice, ...
```

**Bad example:**

```java
StringBuilder sb = new StringBuilder();
for (Dish d : menu) {
    sb.append(d.getName()).append(", ");
}
// trailing ", " must be trimmed manually — easy to forget
String shortMenu = sb.substring(0, sb.length() - 2);
```

### [6.5] Prefer specialized collectors (or primitive streams) over generalized reducing

Title: `Collectors.reducing` generalizes the others, but choose the most specialized solution.
Description: Every summarizing collector is a special case of the three-argument `reducing(identity, mapper, binaryOperator)`. While `reducing` shows the underlying mechanism, the book advises always picking the most specialized form that is general enough — it is more readable and often faster. For a numeric sum, mapping to an `IntStream` and calling `sum()` avoids the auto-unboxing that `reducing` over `Integer` incurs.

**Good example:**

```java
int totalCalories = menu.stream().mapToInt(Dish::getCalories).sum();
```

**Bad example:**

```java
import static java.util.stream.Collectors.reducing;

// Works, but verbose and boxes every value into Integer
int totalCalories =
    menu.stream().collect(reducing(0, Dish::getCalories, (i, j) -> i + j));
```

### [6.6] Build multilevel groupings by nesting groupingBy

Title: Compose `groupingBy` collectors to produce n-level classification maps.
Description: The two-argument `groupingBy(classifier, downstream)` lets you pass an inner `groupingBy` as the downstream collector, yielding a nested `Map` that models a multidimensional classification table. This composition stays readable as levels are added, whereas the imperative equivalent collapses into deeply nested loops and conditions.

**Good example:**

```java
import static java.util.stream.Collectors.groupingBy;

Map<Dish.Type, Map<CaloricLevel, List<Dish>>> dishesByTypeCaloricLevel =
    menu.stream().collect(
        groupingBy(Dish::getType,
            groupingBy(dish -> {
                if (dish.getCalories() <= 400) return CaloricLevel.DIET;
                else if (dish.getCalories() <= 700) return CaloricLevel.NORMAL;
                else return CaloricLevel.FAT;
            })));
```

**Bad example:**

```java
Map<Dish.Type, Map<CaloricLevel, List<Dish>>> result = new HashMap<>();
for (Dish dish : menu) {
    CaloricLevel level;
    if (dish.getCalories() <= 400) level = CaloricLevel.DIET;
    else if (dish.getCalories() <= 700) level = CaloricLevel.NORMAL;
    else level = CaloricLevel.FAT;
    result.computeIfAbsent(dish.getType(), t -> new HashMap<>())
          .computeIfAbsent(level, l -> new ArrayList<>())
          .add(dish);
}
```

### [6.7] Apply a downstream collector to each subgroup

Title: Pass `counting`, `summingInt`, or `mapping` as the downstream of `groupingBy`.
Description: The second argument to `groupingBy` need not be another `groupingBy` — it can be any collector that further reduces each subgroup. This lets you count, sum, or transform per group in one statement. Note that one-argument `groupingBy(f)` is just shorthand for `groupingBy(f, toList())`.

**Good example:**

```java
import static java.util.stream.Collectors.groupingBy;
import static java.util.stream.Collectors.counting;

Map<Dish.Type, Long> typesCount =
    menu.stream().collect(groupingBy(Dish::getType, counting()));
// {MEAT=3, FISH=2, OTHER=4}
```

**Bad example:**

```java
// Group first, then iterate the map again to count each list
Map<Dish.Type, List<Dish>> grouped =
    menu.stream().collect(groupingBy(Dish::getType));
Map<Dish.Type, Long> typesCount = new HashMap<>();
for (Map.Entry<Dish.Type, List<Dish>> e : grouped.entrySet()) {
    typesCount.put(e.getKey(), (long) e.getValue().size());
}
```

### [6.8] Adapt subgroup results with collectingAndThen

Title: Wrap a collector with `collectingAndThen` to transform its result (e.g. unwrap Optional).
Description: When `maxBy` is used as a downstream collector, each group value is an `Optional` even though `groupingBy` only creates a key when at least one element exists. `collectingAndThen(collector, finisher)` applies a transformation (such as `Optional::get`) as the final step, removing the unnecessary wrapper and giving a cleaner map type.

**Good example:**

```java
import static java.util.stream.Collectors.*;
import static java.util.Comparator.comparingInt;

Map<Dish.Type, Dish> mostCaloricByType =
    menu.stream().collect(
        groupingBy(Dish::getType,
            collectingAndThen(
                maxBy(comparingInt(Dish::getCalories)),
                Optional::get)));
// {FISH=salmon, OTHER=pizza, MEAT=pork}
```

**Bad example:**

```java
import static java.util.stream.Collectors.*;
import static java.util.Comparator.comparingInt;

// Leaves Optionals in the map; every caller must unwrap them
Map<Dish.Type, Optional<Dish>> mostCaloricByType =
    menu.stream().collect(
        groupingBy(Dish::getType,
            maxBy(comparingInt(Dish::getCalories))));
```

### [6.9] Partition with a predicate using partitioningBy

Title: Use `partitioningBy(predicate)` to split into a true/false map, keeping both sides.
Description: Partitioning is a special case of grouping where the classification function is a predicate, so the resulting `Map` has at most a `true` and a `false` key. Unlike a single `filter`, partitioning retains both subsets in one operation, and like `groupingBy` it accepts a downstream collector for further reduction.

**Good example:**

```java
import static java.util.stream.Collectors.partitioningBy;

Map<Boolean, List<Dish>> partitionedMenu =
    menu.stream().collect(partitioningBy(Dish::isVegetarian));

List<Dish> vegetarianDishes = partitionedMenu.get(true);
List<Dish> nonVegetarianDishes = partitionedMenu.get(false);
```

**Bad example:**

```java
// Two passes, and you must remember to negate the predicate for the other side
List<Dish> vegetarianDishes =
    menu.stream().filter(Dish::isVegetarian).collect(toList());
List<Dish> nonVegetarianDishes =
    menu.stream().filter(d -> !d.isVegetarian()).collect(toList());
```

### [6.10] Implement a custom Collector for cases the factories cannot cover

Title: Implement the Collector interface (supplier/accumulator/combiner/finisher/characteristics) for performance or access to partial results.
Description: Predefined collectors never expose the partial result during accumulation. When the algorithm needs it — for example partitioning numbers into prime and nonprime by testing each candidate only against primes found so far — a custom `Collector<T, A, R>` is required. Defining the five methods (and accurate `Characteristics` such as `IDENTITY_FINISH`) yields a reusable collector; in the book this custom collector ran about 32% faster than the `partitioningBy` version.

**Good example:**

```java
import java.util.*;
import java.util.function.*;
import java.util.stream.Collector;
import static java.util.stream.Collector.Characteristics.IDENTITY_FINISH;

public class PrimeNumbersCollector
        implements Collector<Integer,
                             Map<Boolean, List<Integer>>,
                             Map<Boolean, List<Integer>>> {

    @Override
    public Supplier<Map<Boolean, List<Integer>>> supplier() {
        return () -> new HashMap<Boolean, List<Integer>>() {{
            put(true, new ArrayList<>());
            put(false, new ArrayList<>());
        }};
    }

    @Override
    public BiConsumer<Map<Boolean, List<Integer>>, Integer> accumulator() {
        return (acc, candidate) ->
            acc.get(isPrime(acc.get(true), candidate)) // partial result is available
               .add(candidate);
    }

    @Override
    public BinaryOperator<Map<Boolean, List<Integer>>> combiner() {
        return (map1, map2) -> {
            map1.get(true).addAll(map2.get(true));
            map1.get(false).addAll(map2.get(false));
            return map1;
        };
    }

    @Override
    public Function<Map<Boolean, List<Integer>>,
                    Map<Boolean, List<Integer>>> finisher() {
        return Function.identity();
    }

    @Override
    public Set<Characteristics> characteristics() {
        return Collections.unmodifiableSet(EnumSet.of(IDENTITY_FINISH));
    }

    public static boolean isPrime(List<Integer> primes, int candidate) {
        int candidateRoot = (int) Math.sqrt((double) candidate);
        return primes.stream()
                     .takeWhile(i -> i <= candidateRoot)  // Java 9+; on Java 8 filter+limit
                     .noneMatch(p -> candidate % p == 0);
    }
}
```

**Bad example:**

```java
import static java.util.stream.Collectors.partitioningBy;

// Cannot reach the primes found so far, so every candidate is tested
// against ALL numbers up to its root, not just the primes — slower.
public Map<Boolean, List<Integer>> partitionPrimes(int n) {
    return IntStream.rangeClosed(2, n).boxed()
                    .collect(partitioningBy(candidate -> isPrime(candidate)));
}

public boolean isPrime(int candidate) {
    int candidateRoot = (int) Math.sqrt((double) candidate);
    return IntStream.rangeClosed(2, candidateRoot)
                    .noneMatch(i -> candidate % i == 0);
}
```

## Chapter 7 — Parallel Data Processing and Performance

### [7.1] Measure before going parallel — parallel is not automatically faster

Title: Turn streams parallel only after benchmarking; "measure, measure, measure."
Description: Calling `parallel()` is trivial but does not guarantee a speedup — for the naive `Stream.iterate` sum, the parallel version was actually slower than sequential because of boxing and an unsplittable source. The golden rule for performance work is to always benchmark each variant (a small harness, or JMH for rigor) rather than assume parallelism wins.

**Good example:**

```java
public long measureSumPerf(Function<Long, Long> adder, long n) {
    long fastest = Long.MAX_VALUE;
    for (int i = 0; i < 10; i++) {          // warm up the JIT + take fastest run
        long start = System.nanoTime();
        long sum = adder.apply(n);
        long duration = (System.nanoTime() - start) / 1_000_000;
        if (duration < fastest) fastest = duration;
    }
    return fastest;
}

// Decide based on measured numbers, not a guess.
long seq = measureSumPerf(ParallelStreams::sequentialSum, 10_000_000);
long par = measureSumPerf(ParallelStreams::parallelSum,   10_000_000);
```

**Bad example:**

```java
// Assumes parallel must be faster — for an iterate-based sum it is slower.
public static long parallelSum(long n) {
    return Stream.iterate(1L, i -> i + 1)
                 .limit(n)
                 .parallel()                 // overhead with no real splitting
                 .reduce(0L, Long::sum);
}
```

### [7.2] Avoid shared mutable state in parallel streams

Title: Never mutate shared state from a parallel stream — it produces wrong results.
Description: Algorithms that mutate a shared accumulator are fundamentally sequential. Running such code in parallel creates a data race: `total += value` is not atomic, so each run yields a different, incorrect total. The fix is not synchronization (which destroys parallelism) but avoiding mutation entirely and using a reduction/collector that combines independent partial results.

**Good example:**

```java
// No shared state: each chunk reduces independently, results are combined.
public static long parallelRangedSum(long n) {
    return LongStream.rangeClosed(1, n)
                     .parallel()
                     .reduce(0L, Long::sum);   // always 50000005000000 for 10M
}
```

**Bad example:**

```java
public static long sideEffectParallelSum(long n) {
    Accumulator accumulator = new Accumulator();
    LongStream.rangeClosed(1, n).parallel().forEach(accumulator::add);
    return accumulator.total;                  // wrong & different each run
}

public class Accumulator {
    public long total = 0;
    public void add(long value) { total += value; } // data race in parallel
}
```

### [7.3] Prefer primitive streams and splittable sources; avoid boxing and iterate

Title: Use `LongStream.rangeClosed` instead of `Stream.iterate` to avoid boxing and enable splitting.
Description: Automatic boxing/unboxing dramatically hurts performance, so use the primitive streams (`IntStream`, `LongStream`, `DoubleStream`) when possible. `iterate` is also inherently sequential because each value depends on the previous one, making it hard to split. Range-based primitive streams work on primitives directly and decompose evenly into independent chunks, so the parallel reduction actually pays off.

**Good example:**

```java
// Primitive + range: no boxing, easily split into independent chunks.
public static long parallelRangedSum(long n) {
    return LongStream.rangeClosed(1, n)
                     .parallel()
                     .reduce(0L, Long::sum);
}
```

**Bad example:**

```java
// Boxed Long objects + iterate (depends on previous value, hard to split).
public static long parallelSum(long n) {
    return Stream.iterate(1L, i -> i + 1)
                 .limit(n)
                 .parallel()
                 .reduce(0L, Long::sum);
}
```

### [7.4] Use the fork/join framework via RecursiveTask, calling fork/compute/join correctly

Title: Subclass `RecursiveTask`, fork one subtask and compute the other, then join.
Description: The fork/join framework recursively splits a task into subtasks and combines their results (parallel divide-and-conquer). In `compute`, stop splitting below a threshold and run sequentially; above it, split, `fork()` one subtask (to schedule it on the pool) and `compute()` the other directly, then `join()` the forked result. Forking both and joining immediately, or joining before both have started, serializes the work and adds overhead.

**Good example:**

```java
public class ForkJoinSumCalculator extends RecursiveTask<Long> {
    private final long[] numbers;
    private final int start, end;
    private static final long THRESHOLD = 10_000;

    public ForkJoinSumCalculator(long[] numbers) {
        this(numbers, 0, numbers.length);
    }
    private ForkJoinSumCalculator(long[] numbers, int start, int end) {
        this.numbers = numbers; this.start = start; this.end = end;
    }

    @Override
    protected Long compute() {
        int length = end - start;
        if (length <= THRESHOLD) {
            return computeSequentially();          // small enough — do it directly
        }
        ForkJoinSumCalculator left =
            new ForkJoinSumCalculator(numbers, start, start + length / 2);
        left.fork();                               // schedule left on the pool
        ForkJoinSumCalculator right =
            new ForkJoinSumCalculator(numbers, start + length / 2, end);
        long rightResult = right.compute();        // reuse this thread for right
        long leftResult  = left.join();            // join only after right started
        return leftResult + rightResult;
    }

    private long computeSequentially() {
        long sum = 0;
        for (int i = start; i < end; i++) sum += numbers[i];
        return sum;
    }
}

public static long forkJoinSum(long n) {
    long[] numbers = LongStream.rangeClosed(1, n).toArray();
    return new ForkJoinPool().invoke(new ForkJoinSumCalculator(numbers));
}
```

**Bad example:**

```java
@Override
protected Long compute() {
    int length = end - start;
    if (length <= THRESHOLD) return computeSequentially();

    ForkJoinSumCalculator left =
        new ForkJoinSumCalculator(numbers, start, start + length / 2);
    ForkJoinSumCalculator right =
        new ForkJoinSumCalculator(numbers, start + length / 2, end);

    left.fork();
    long leftResult = left.join();   // joins before right even starts...
    right.fork();
    long rightResult = right.join(); // ...so subtasks run one after another
    return leftResult + rightResult; // effectively sequential, with extra overhead
}
```

### [7.5] Favor many small fork/join tasks to benefit from work stealing

Title: Split into many fine-grained subtasks so idle threads can steal work and stay balanced.
Description: The fork/join pool uses work stealing: each worker keeps a double-ended queue of tasks, pulling from its head and, when idle, stealing from the tail of another worker's queue. If subtasks vary in duration (slow I/O, external coordination), a few coarse tasks leave cores idle. Many smaller tasks let the pool redistribute work and keep all cores busy — choose a threshold small enough to generate plenty of subtasks but large enough that each does meaningful work.

**Good example:**

```java
// Low threshold relative to input -> ~1000+ subtasks the pool can balance
// across cores via work stealing.
private static final long THRESHOLD = 10_000;

@Override
protected Long compute() {
    int length = end - start;
    if (length <= THRESHOLD) {
        return computeSequentially();
    }
    ForkJoinSumCalculator left =
        new ForkJoinSumCalculator(numbers, start, start + length / 2);
    left.fork();
    ForkJoinSumCalculator right =
        new ForkJoinSumCalculator(numbers, start + length / 2, end);
    return right.compute() + left.join();
}
```

**Bad example:**

```java
// Threshold so high that only ~2 coarse tasks are produced: if one chunk is
// slower, the other cores sit idle with nothing to steal.
private static final long THRESHOLD = 5_000_000; // for a 10M array

@Override
protected Long compute() {
    int length = end - start;
    if (length <= THRESHOLD) {
        return computeSequentially();
    }
    // ... single split, no fine-grained tasks to balance the load ...
    return splitAndSum();
}
```

### [7.6] Implement a custom Spliterator to control how a source splits

Title: Provide a Spliterator (tryAdvance/trySplit/estimateSize/characteristics) when default splitting gives wrong results.
Description: Parallel streams split the source automatically via a `Spliterator`, but splitting at arbitrary positions can corrupt results — counting words in a `String` split mid-word counts some words twice. A custom `Spliterator` whose `trySplit` only breaks at word boundaries (and declares accurate characteristics like `ORDERED`, `SIZED`, `SUBSIZED`, `NONNULL`, `IMMUTABLE`) lets you parallelize correctly. `tryAdvance` consumes elements one by one; `trySplit` returns `null` below a threshold to stop splitting.

**Good example:**

```java
public class WordCounterSpliterator implements Spliterator<Character> {
    private final String string;
    private int currentChar = 0;

    public WordCounterSpliterator(String string) { this.string = string; }

    @Override
    public boolean tryAdvance(Consumer<? super Character> action) {
        action.accept(string.charAt(currentChar++));   // feed one char
        return currentChar < string.length();
    }

    @Override
    public Spliterator<Character> trySplit() {
        int currentSize = string.length() - currentChar;
        if (currentSize < 10) {
            return null;                                // too small: stop splitting
        }
        for (int splitPos = currentSize / 2 + currentChar;
             splitPos < string.length(); splitPos++) {
            if (Character.isWhitespace(string.charAt(splitPos))) { // split on word boundary
                Spliterator<Character> spliterator =
                    new WordCounterSpliterator(string.substring(currentChar, splitPos));
                currentChar = splitPos;
                return spliterator;
            }
        }
        return null;
    }

    @Override
    public long estimateSize() { return string.length() - currentChar; }

    @Override
    public int characteristics() {
        return ORDERED + SIZED + SUBSIZED + NONNULL + IMMUTABLE;
    }
}

// Correct parallel word count:
Spliterator<Character> spliterator = new WordCounterSpliterator(SENTENCE);
Stream<Character> stream = StreamSupport.stream(spliterator, true);
System.out.println("Found " + countWords(stream) + " words"); // Found 19 words
```

**Bad example:**

```java
// Relies on the default character-stream splitting, which can cut a word in
// half between two chunks, so the same word gets counted twice in parallel.
Stream<Character> stream = IntStream.range(0, SENTENCE.length())
                                    .mapToObj(SENTENCE::charAt);
System.out.println("Found " + countWords(stream.parallel()) + " words");
// Found 25 words  (wrong: should be 19)
```

## Chapter 8 — Refactoring, Testing, and Debugging

### [8.1] Refactor anonymous classes implementing a single method to lambda expressions

Title: Replace single-method anonymous classes with lambda expressions for concise, readable behavior parameterization.
Description: Anonymous classes that implement one abstract method are verbose and error-prone — they obscure the intent of the behavior in ceremony. Lambdas express the same behavior in a compact form. Be aware of subtle semantic differences (`this` refers to the enclosing class inside a lambda, lambdas can't shadow enclosing variables) and possible overload ambiguity, which an explicit cast resolves.

**Good example:**

```java
Runnable r = () -> System.out.println("Hello");

// Behavior parameterization with a lambda
Comparator<Apple> byWeight =
    (a1, a2) -> a1.getWeight().compareTo(a2.getWeight());
inventory.sort(byWeight);
```

**Bad example:**

```java
Runnable r = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
};

Comparator<Apple> byWeight = new Comparator<Apple>() {
    @Override
    public int compare(Apple a1, Apple a2) {
        return a1.getWeight().compareTo(a2.getWeight());
    }
};
inventory.sort(byWeight);
```

### [8.2] Refactor imperative iterator-based collection processing to the Streams API

Title: Convert iterator-driven filtering and extracting loops into a declarative stream pipeline.
Description: Imperative loops mangle multiple data-processing patterns (filtering and extracting) together, forcing a reader to understand the whole implementation before grasping intent. A stream pipeline reads like the problem statement, names each step, and can be optimized behind the scenes with short-circuiting, laziness, and easy parallelization.

**Good example:**

```java
List<String> dishNames =
    menu.stream()
        .filter(d -> d.getCalories() > 300)
        .map(Dish::getName)
        .collect(toList());
```

**Bad example:**

```java
List<String> dishNames = new ArrayList<>();
for (Dish dish : menu) {
    if (dish.getCalories() > 300) {
        dishNames.add(dish.getName());
    }
}
```

### [8.3] Refactor lambda expressions to method references and built-in collectors

Title: Prefer method references and purpose-built collectors over lambdas to state intent clearly.
Description: A lambda body is fine for short throwaway code, but a named method reference communicates intent more clearly and lets you reuse and unit-test the extracted logic. Likewise, replace ad-hoc `reduce`/`comparing` lambdas with built-in helpers such as `summingInt`, `maxBy`, and `comparing(...).thenComparing(...)` — the names themselves document what the code does.

**Good example:**

```java
Map<CaloricLevel, List<Dish>> dishesByCaloricLevel =
    menu.stream().collect(groupingBy(Dish::getCaloricLevel));

int totalCalories = menu.stream().collect(summingInt(Dish::getCalories));

inventory.sort(comparing(Apple::getWeight));
```

**Bad example:**

```java
Map<CaloricLevel, List<Dish>> dishesByCaloricLevel =
    menu.stream().collect(groupingBy(dish -> {
        if (dish.getCalories() <= 400) return CaloricLevel.DIET;
        else if (dish.getCalories() <= 700) return CaloricLevel.NORMAL;
        else return CaloricLevel.FAT;
    }));

int totalCalories =
    menu.stream().map(Dish::getCalories)
                 .reduce(0, (c1, c2) -> c1 + c2);
```

### [8.4] Replace boilerplate-heavy OO design patterns with lambdas

Title: Use lambdas to remove the boilerplate of Strategy, Template Method, Observer, and Chain of Responsibility patterns.
Description: Patterns whose concrete classes merely wrap a single piece of behavior — a Strategy's `execute`, a Template Method's variable step, an Observer's `notify`, a Chain link's transform — can pass that behavior directly as a lambda. This eliminates the family of one-method classes the pattern would otherwise require. Keep using classes when the behavior is genuinely stateful or has multiple methods.

**Good example:**

```java
// Strategy: ValidationStrategy is a functional interface
Validator numericValidator = new Validator(s -> s.matches("\\d+"));
boolean b = numericValidator.validate("aaaa");

// Template Method: plug the variable step in as a Consumer
public void processCustomer(int id, Consumer<Customer> makeCustomerHappy) {
    Customer c = Database.getCustomerWithId(id);
    makeCustomerHappy.accept(c);
}
new OnlineBanking().processCustomer(1337, c -> System.out.println("Hello " + c.getName()));

// Observer: register behavior directly
f.registerObserver(tweet -> {
    if (tweet != null && tweet.contains("money")) {
        System.out.println("Breaking news in NY! " + tweet);
    }
});

// Chain of responsibility: compose UnaryOperators
UnaryOperator<String> headerProcessing = text -> "From Raoul: " + text;
UnaryOperator<String> spellChecker = text -> text.replaceAll("labda", "lambda");
Function<String, String> pipeline = headerProcessing.andThen(spellChecker);
```

**Bad example:**

```java
public interface ValidationStrategy { boolean execute(String s); }
public class IsNumeric implements ValidationStrategy {
    public boolean execute(String s) { return s.matches("\\d+"); }
}
Validator numericValidator = new Validator(new IsNumeric());

abstract class OnlineBanking {
    public void processCustomer(int id) {
        Customer c = Database.getCustomerWithId(id);
        makeCustomerHappy(c);
    }
    abstract void makeCustomerHappy(Customer c);
}

class NYTimes implements Observer {
    public void notify(String tweet) {
        if (tweet != null && tweet.contains("money")) {
            System.out.println("Breaking news in NY! " + tweet);
        }
    }
}
```

### [8.5] Implement the Factory pattern with a Map<String, Supplier<T>> of constructor references

Title: Replace a factory's switch statement with a map from a key to a constructor reference.
Description: A traditional factory hides instantiation behind a `switch` that must be edited every time a new product is added. Because constructors can be referenced like methods (`Loan::new` as a `Supplier<Product>`), you can store them in a `Map<String, Supplier<Product>>` and look up the right constructor. Note the limit: this scales only for no-arg (or fixed-arity) constructors — multiple constructor arguments require a custom functional interface.

**Good example:**

```java
final static Map<String, Supplier<Product>> map = new HashMap<>();
static {
    map.put("loan", Loan::new);
    map.put("stock", Stock::new);
    map.put("bond", Bond::new);
}

public static Product createProduct(String name) {
    Supplier<Product> p = map.get(name);
    if (p != null) return p.get();
    throw new IllegalArgumentException("No such product " + name);
}
```

**Bad example:**

```java
public static Product createProduct(String name) {
    switch (name) {
        case "loan":  return new Loan();
        case "stock": return new Stock();
        case "bond":  return new Bond();
        default: throw new RuntimeException("No such product " + name);
    }
}
```

### [8.6] Test lambdas by testing the behavior of the method that uses them

Title: Don't try to test anonymous lambdas directly — test the enclosing method's behavior, and pull complex lambdas into testable named methods.
Description: A lambda used as a one-off implementation detail has no name, so it can't be referenced from a test; instead, unit-test the public method that uses it. When a lambda is genuinely complex (e.g. a pricing algorithm with corner cases), convert it into a regular method (referenced via a method reference) so it can be tested in isolation. If a lambda is deliberately exposed via a field, you can test it as an instance of its functional interface.

**Good example:**

```java
// The lambda is just an implementation detail — test the method's behavior
public static List<Point> moveAllPointsRightBy(List<Point> points, int x) {
    return points.stream()
                 .map(p -> new Point(p.getX() + x, p.getY()))
                 .collect(toList());
}

@Test
public void testMoveAllPointsRightBy() {
    List<Point> points = Arrays.asList(new Point(5, 5), new Point(10, 5));
    List<Point> expected = Arrays.asList(new Point(15, 5), new Point(20, 5));
    assertEquals(expected, moveAllPointsRightBy(points, 10));
}

// A complex lambda extracted into a named, directly testable method reference
menu.stream().collect(groupingBy(Dish::getCaloricLevel));
```

**Bad example:**

```java
// Trying to "name" and reach into a one-off lambda just to test it —
// the lambda is anonymous, so there is nothing to invoke from a test
@Test
public void testMoveLambda() {
    // No way to refer to  p -> new Point(p.getX() + x, p.getY())
    // so developers copy the logic into the test, duplicating it
    Point p = new Point(5, 5);
    Point moved = new Point(p.getX() + 10, p.getY()); // duplicated logic, tests nothing real
    assertEquals(15, moved.getX());
}
```

### [8.7] Debug stream pipelines with peek() instead of consuming the stream with forEach

Title: Use peek() to observe intermediate values flowing through a pipeline without altering it.
Description: Logging a pipeline with `forEach` consumes the whole stream, so you only ever see the final result and the pipeline can't continue. `peek` executes an action on each element as it passes a given point and then forwards that element to the next operation, letting you inspect what `map`, `filter`, and `limit` each produce without changing the pipeline's outcome. Also remember that lambda stack traces are cryptic (`lambda$main$0`) — extracting logic into named methods makes failures easier to read.

**Good example:**

```java
List<Integer> result =
    Stream.of(2, 3, 4, 5)
          .peek(x -> System.out.println("from stream: " + x))
          .map(x -> x + 17)
          .peek(x -> System.out.println("after map: " + x))
          .filter(x -> x % 2 == 0)
          .peek(x -> System.out.println("after filter: " + x))
          .limit(3)
          .peek(x -> System.out.println("after limit: " + x))
          .collect(toList());
```

**Bad example:**

```java
// forEach consumes the whole stream, so you can only ever see the final output
// and the pipeline cannot be reused or continued
Stream.of(2, 3, 4, 5)
      .map(x -> x + 17)
      .filter(x -> x % 2 == 0)
      .limit(3)
      .forEach(System.out::println); // shows only 20, 22 — no insight into intermediate steps
```

## Chapter 9 — Default Methods

### [9.1] Evolve published interfaces with default methods to preserve backward compatibility

Title: Add new interface methods as default methods so existing implementors keep working without recompilation.
Description: Adding an abstract method to a published interface is a source incompatibility — every existing implementing class fails to compile, and calling the missing method on an old binary throws `AbstractMethodError`. A default method supplies the missing body in the interface itself, so all implementing classes (including ones outside your control) automatically inherit it. This is exactly how Java 8 added `List.sort` and `Collection.stream` without breaking the ecosystem.

**Good example:**

```java
public interface Resizable extends Drawable {
    int getWidth();
    int getHeight();
    void setWidth(int width);
    void setHeight(int height);
    void setAbsoluteSize(int width, int height);

    // New behavior added without breaking existing Ellipse, Square, Rectangle, ...
    default void setRelativeSize(int wFactor, int hFactor) {
        setAbsoluteSize(getWidth() / wFactor, getHeight() / hFactor);
    }
}
```

**Bad example:**

```java
public interface Resizable extends Drawable {
    int getWidth();
    int getHeight();
    void setWidth(int width);
    void setHeight(int height);
    void setAbsoluteSize(int width, int height);

    // Abstract addition: every existing implementor must now implement this,
    // breaking source compatibility and throwing AbstractMethodError at runtime
    void setRelativeSize(int wFactor, int hFactor);
}
```

### [9.2] Use default methods as optional methods to remove empty boilerplate implementations

Title: Provide a sensible default body for rarely-used interface methods so implementors don't write empty stubs.
Description: Before Java 8, interfaces like `Iterator` forced every implementor to provide a body for methods many of them ignored (`remove`), producing pointless empty stubs. A default method supplies that body once in the interface — for example `Iterator.remove` defaults to throwing `UnsupportedOperationException` — so concrete classes inherit it and only override when they actually support the operation.

**Good example:**

```java
interface Iterator<T> {
    boolean hasNext();
    T next();
    default void remove() {
        throw new UnsupportedOperationException();
    }
}

// Implementors that don't support removal write nothing extra
class ReadOnlyIterator<T> implements Iterator<T> {
    public boolean hasNext() { /* ... */ return false; }
    public T next() { /* ... */ return null; }
}
```

**Bad example:**

```java
interface Iterator<T> {
    boolean hasNext();
    T next();
    void remove(); // every implementor is forced to deal with this
}

class ReadOnlyIterator<T> implements Iterator<T> {
    public boolean hasNext() { /* ... */ return false; }
    public T next() { /* ... */ return null; }
    // Boilerplate empty/throwing stub repeated in every read-only iterator
    public void remove() {
        throw new UnsupportedOperationException();
    }
}
```

### [9.3] Compose minimal, orthogonal interfaces for multiple inheritance of behavior

Title: Split behavior into small interfaces with default methods and compose them, instead of inheriting one heavyweight class.
Description: Default methods let a class inherit implementation code from several interfaces, enabling multiple inheritance of behavior. By keeping each interface minimal and orthogonal (`Rotatable`, `Moveable`, `Resizable`), a class can pick exactly the behaviors it needs and inherit their defaults for free, and improving one default implementation updates every composing class at once. This is far more flexible than fattening a base class with everything and forcing unrelated subclasses to inherit it.

**Good example:**

```java
public interface Rotatable {
    void setRotationAngle(int angleInDegrees);
    int getRotationAngle();
    default void rotateBy(int angleInDegrees) {
        setRotationAngle((getRotationAngle() + angleInDegrees) % 360);
    }
}

public interface Moveable {
    int getX();
    int getY();
    void setX(int x);
    void setY(int y);
    default void moveHorizontally(int distance) { setX(getX() + distance); }
    default void moveVertically(int distance)   { setY(getY() + distance); }
}

// Compose only the behaviors each shape needs
public class Monster implements Rotatable, Moveable, Resizable { /* getters/setters */ }
public class Sun implements Moveable, Rotatable { /* getters/setters */ } // not resizable
```

**Bad example:**

```java
// One heavyweight base forces every subclass to inherit behavior it doesn't want
public abstract class GameObject {
    public void rotateBy(int a) { /* ... */ }
    public void moveHorizontally(int d) { /* ... */ }
    public void setRelativeSize(int w, int h) { /* ... */ }
    // 100 other unrelated methods and fields ...
}

// Sun is not resizable but still inherits setRelativeSize via deep inheritance
public class Sun extends GameObject { }
```

### [9.4] Apply the three resolution rules and X.super.method() to disambiguate conflicting defaults

Title: Resolve inherited default-method conflicts by class-wins, then most-specific-interface, then explicit override with X.super.method().
Description: When a class inherits multiple default methods with the same signature, Java applies three rules in order: (1) a method in the class or a superclass always wins; (2) otherwise the most specific default-providing sub-interface wins (if B extends A, B beats A); (3) if still ambiguous (two unrelated interfaces), the class must override the method and explicitly pick one with the `X.super.method()` syntax. Knowing these rules lets you reason about the diamond problem instead of guessing.

**Good example:**

```java
public interface A {
    default void hello() { System.out.println("Hello from A"); }
}
public interface B {
    default void hello() { System.out.println("Hello from B"); }
}

// A and B are unrelated, so the conflict is ambiguous: disambiguate explicitly
public class C implements B, A {
    @Override
    public void hello() {
        B.super.hello(); // explicitly choose B's default
    }
}
```

**Bad example:**

```java
public interface A {
    default void hello() { System.out.println("Hello from A"); }
}
public interface B {
    default void hello() { System.out.println("Hello from B"); }
}

// Compile error: class C inherits unrelated defaults for hello() from types B and A
public class C implements B, A { }
```

### [9.5] Keep default methods minimal and prefer delegation over inheritance for code reuse

Title: Use default methods (and composition) for small, focused reuse rather than inheriting large classes just to grab one method.
Description: Inheritance shouldn't be the default answer for reuse — extending a 100-method class to reuse one method adds needless complexity and exposes core behavior to interference (which is why some classes, like `String`, are declared `final`). Keeping interfaces and their default methods minimal maximizes safe composition. When you only need a single method from another type, delegate to it through a member variable instead of inheriting.

**Good example:**

```java
// Reuse one piece of behavior by delegation through a member, not inheritance
public class CustomList<E> {
    private final ArrayList<E> internal = new ArrayList<>();

    public boolean add(E e) {
        return internal.add(e); // delegate the single capability we need
    }
    public int size() {
        return internal.size();
    }
}

// Minimal interface with a focused default — easy to compose
public interface Sized {
    int size();
    default boolean isEmpty() { return size() == 0; }
}
```

**Bad example:**

```java
// Extending a heavyweight class only to reuse add()/size() drags in
// dozens of unrelated methods and lets clients corrupt internal behavior
public class CustomList<E> extends ArrayList<E> {
    // inherits 100+ methods just to expose add() and size()
}
```

## Chapter 10 — Using Optional as a Better Alternative to null

### [10.1] Model the structural absence of a value with Optional<T> instead of null

Title: Declare values that may legitimately be missing as `Optional<T>`, reserving plain types for mandatory values.
Description: `null` is meaningless, breaks the type system, and is the most common source of `NullPointerException`; nothing in a `Car` field tells you whether `null` is a valid state or a bug. Declaring `Optional<Car>` makes "this value may be absent" explicit in the model and forces callers to actively unwrap it. Leaving a field as a plain type (e.g. `String name` on `Insurance`) deliberately signals it is mandatory.

**Good example:**

```java
public class Person {
    private Optional<Car> car;            // a person may not own a car
    public Optional<Car> getCar() { return car; }
}
public class Car {
    private Optional<Insurance> insurance; // a car may be uninsured
    public Optional<Insurance> getInsurance() { return insurance; }
}
public class Insurance {
    private String name;                   // an insurance company MUST have a name
    public String getName() { return name; }
}
```

**Bad example:**

```java
public class Person {
    private Car car;                       // is null a valid "no car" or a bug? unclear
    public Car getCar() { return car; }
}
public class Car {
    private Insurance insurance;
    public Insurance getInsurance() { return insurance; }
}
public class Insurance {
    private String name;
    public String getName() { return name; }
}
```

### [10.2] Create Optionals with empty(), of(), and ofNullable() according to the source value

Title: Use `Optional.empty()` for absence, `Optional.of()` for guaranteed-non-null values, and `Optional.ofNullable()` for possibly-null values.
Description: The three factory methods express different intentions. `Optional.empty()` returns the singleton empty optional. `Optional.of(value)` fails fast with a `NullPointerException` if you pass `null`, which is correct when the value must be present. `Optional.ofNullable(value)` yields an empty optional when the value is `null`, which is exactly how to safely lift a legacy API return value (such as `Map.get`) into an optional.

**Good example:**

```java
Optional<Car> empty = Optional.empty();

// car is known to be non-null here: fail fast if that assumption is violated
Optional<Car> optCar = Optional.of(car);

// legacy/possibly-null value: become empty instead of NPE
Optional<Object> value = Optional.ofNullable(map.get("key"));
```

**Bad example:**

```java
// Optional.of() with a value that might be null defeats the purpose:
// it throws NullPointerException immediately
Optional<Object> value = Optional.of(map.get("key"));

// Hand-rolled if/else just to build an optional from a nullable value
Optional<Object> v;
if (map.get("key") != null) {
    v = Optional.of(map.get("key"));
} else {
    v = Optional.empty();
}
```

### [10.3] Extract and chain values with map and flatMap instead of nested null checks

Title: Compose a safe dereferencing chain with `map` (and `flatMap` where the function itself returns an Optional) rather than deeply nested `if (x != null)` blocks.
Description: `Optional.map` applies a function to the contained value or does nothing if empty, perfect for one-step extraction. When the function itself returns an `Optional` (e.g. `Person::getCar` returns `Optional<Car>`), `map` would produce a nested `Optional<Optional<Car>>`; `flatMap` flattens it into a single optional. Chaining `flatMap`/`map` replaces the "deep doubts" pyramid and the "too many exits" style of null-checking with one readable statement.

**Good example:**

```java
public String getCarInsuranceName(Optional<Person> person) {
    return person.flatMap(Person::getCar)
                 .flatMap(Car::getInsurance)
                 .map(Insurance::getName)   // getName returns String, so map (not flatMap)
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
            if (insurance != null) {
                return insurance.getName();
            }
        }
    }
    return "Unknown";
}
```

### [10.4] Reject unwanted values with filter and act with ifPresent

Title: Use `Optional.filter` to test a property of a contained value safely, and `ifPresent` to run an action only when a value exists.
Description: `filter` takes a predicate: if the optional holds a value matching the predicate it is returned unchanged, otherwise the optional becomes empty — eliminating the `x != null && condition` idiom. `ifPresent` runs a consumer only when a value is present and does nothing otherwise. Combined, they let you express "if the value exists and satisfies this rule, then do something" without an explicit null check.

**Good example:**

```java
optInsurance
    .filter(insurance -> "CambridgeInsurance".equals(insurance.getName()))
    .ifPresent(x -> System.out.println("ok"));

// filter integrated into a dereferencing chain
public String getCarInsuranceName(Optional<Person> person, int minAge) {
    return person.filter(p -> p.getAge() >= minAge)
                 .flatMap(Person::getCar)
                 .flatMap(Car::getInsurance)
                 .map(Insurance::getName)
                 .orElse("Unknown");
}
```

**Bad example:**

```java
Insurance insurance = ...;
if (insurance != null && "CambridgeInsurance".equals(insurance.getName())) {
    System.out.println("ok");
}
```

### [10.5] Choose the right default/throw strategy and never call get() without checking presence

Title: Unwrap optionals with `orElse`, `orElseGet`, or `orElseThrow` based on cost and intent, and avoid bare `get()`.
Description: `Optional.get()` throws `NoSuchElementException` on an empty optional, so using it without an `isPresent()` guard re-creates exactly the fragility of `null`. Prefer `orElse(value)` for a cheap default, `orElseGet(supplier)` when the default is expensive to build (it is computed lazily only when empty), and `orElseThrow(supplierOfException)` to throw a chosen exception type. These methods force you to handle absence explicitly instead of risking a hidden runtime failure.

**Good example:**

```java
String name = optInsurance.map(Insurance::getName).orElse("Unknown");

// lazy default: expensive computation runs only if the optional is empty
Car car = optCar.orElseGet(() -> buildExpensiveDefaultCar());

// throw a domain-specific exception on absence
Insurance ins = optInsurance.orElseThrow(
    () -> new IllegalStateException("Insurance is required"));
```

**Bad example:**

```java
// get() without checking presence: NoSuchElementException waiting to happen,
// no better than dereferencing null
String name = optInsurance.get().getName();

// even with a check, this is verbose and just imitates nested null checks
if (optInsurance.isPresent()) {
    name = optInsurance.get().getName();
} else {
    name = "Unknown";
}
```

### [10.6] Combine two Optionals with flatMap and map instead of isPresent/get

Title: Combine multiple optional inputs by nesting `flatMap` and `map`, not by chained `isPresent()`/`get()` checks.
Description: A method that must return a result only when several optional inputs are all present can be written without any conditional logic: `flatMap` on the first optional short-circuits to empty if it is absent, and `map` on the second produces the result if both are present. This is a single fluent statement that reads clearly, whereas `if (a.isPresent() && b.isPresent()) { ... a.get() ... b.get() ... }` just reproduces the null-check style the optional was meant to replace.

**Good example:**

```java
public Optional<Insurance> nullSafeFindCheapestInsurance(
        Optional<Person> person, Optional<Car> car) {
    return person.flatMap(p -> car.map(c -> findCheapestInsurance(p, c)));
}
```

**Bad example:**

```java
public Optional<Insurance> nullSafeFindCheapestInsurance(
        Optional<Person> person, Optional<Car> car) {
    if (person.isPresent() && car.isPresent()) {
        return Optional.of(findCheapestInsurance(person.get(), car.get()));
    } else {
        return Optional.empty();
    }
}
```

### [10.7] Wrap exception-throwing and null-returning legacy APIs in helper methods that return Optional

Title: Encapsulate try/catch and null returns from native APIs in small utility methods (e.g. OptionalUtility) that return an Optional.
Description: Legacy APIs signal failure either by returning `null` (like `Map.get`) or by throwing (like `Integer.parseInt`, which throws `NumberFormatException`). You can't change those signatures, but you can wrap them once in a utility method that returns `Optional`, hiding the ugly `try/catch` and converting absence into an empty optional. Collecting such helpers in an `OptionalUtility` class lets the rest of your code stay fluent and chainable.

**Good example:**

```java
public class OptionalUtility {
    public static Optional<Integer> stringToInt(String s) {
        try {
            return Optional.of(Integer.parseInt(s));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }
}

public int readDuration(Properties props, String name) {
    return Optional.ofNullable(props.getProperty(name))
                   .flatMap(OptionalUtility::stringToInt)
                   .filter(i -> i > 0)
                   .orElse(0);
}
```

**Bad example:**

```java
public int readDuration(Properties props, String name) {
    String value = props.getProperty(name);
    if (value != null) {
        try {
            int i = Integer.parseInt(value);
            if (i > 0) {
                return i;
            }
        } catch (NumberFormatException nfe) {
            // swallow and fall through
        }
    }
    return 0;
}
```

### [10.8] Do not use Optional for fields, method parameters, or collections — and avoid primitive Optionals

Title: Use Optional only for the optional-return idiom; never as a field type, parameter, or collection element, and prefer `Optional<Integer>` over `OptionalInt`.
Description: `Optional` was designed to express an optional return value, not to replace every `null`; it isn't `Serializable`, so using it as a field can break frameworks that require serializable models. For collections, prefer an empty collection over an `Optional` wrapping one. Avoid the primitive variants (`OptionalInt`, `OptionalLong`, `OptionalDouble`): the performance rationale for primitive streams doesn't apply to a single-value optional, and they lack `map`, `flatMap`, and `filter`, so they can't be composed with regular optionals.

**Good example:**

```java
// Optional as a RETURN type, exposing a possibly-missing field safely
public class Person {
    private Car car; // plain field — keeps the model serializable
    public Optional<Car> getCarAsOptional() {
        return Optional.ofNullable(car);
    }
}

// Rich Optional<Integer> retains map/flatMap/filter and composes with other optionals
Optional<Integer> parsed = OptionalUtility.stringToInt("5");
int duration = parsed.filter(i -> i > 0).orElse(0);
```

**Bad example:**

```java
// Optional as a FIELD: not Serializable, can break persistence/serialization frameworks
public class Person {
    private Optional<Car> car; // discouraged
}

// Optional as a PARAMETER: makes the API awkward to call
public void register(Optional<String> name) { /* ... */ }

// OptionalInt lacks map/flatMap/filter and can't be composed with Optional via flatMap
OptionalInt duration = OptionalInt.of(5); // discouraged for single values
```

## Chapter 11 — CompletableFuture: Composable Asynchronous Programming

### [11.1] Replace plain Future with CompletableFuture for composable async work

Title: Prefer CompletableFuture over Future when you need to compose, chain, or react to asynchronous results.
Description: A `Future` lets you submit a `Callable` and check `isDone()` or call `get()`, but it cannot express dependencies between computations, combine independent results, or notify you on completion — you are stuck blocking on `get()`. `CompletableFuture` implements `Future` while adding a declarative, lambda-based API, making it to `Future` what `Stream` is to `Collection`. Reach for it whenever loosely related tasks must be pipelined or merged rather than awaited one by one.

**Good example:**

```java
ExecutorService executor = Executors.newFixedThreadPool(4);

CompletableFuture<Double> futurePrice = CompletableFuture.supplyAsync(
        () -> shop.getPrice(product), executor);

// Build a recipe of follow-up work without blocking the caller thread.
CompletableFuture<String> futureQuote = futurePrice
        .thenApply(price -> shop.getName() + " costs " + price);

futureQuote.thenAccept(System.out::println); // reacts when ready
```

**Bad example:**

```java
ExecutorService executor = Executors.newCachedThreadPool();

Future<Double> future = executor.submit(() -> shop.getPrice(product));

// Future cannot chain: you must block to read the value, then act imperatively.
double price = future.get();              // blocks the caller thread
String quote = shop.getName() + " costs " + price;
System.out.println(quote);
```

### [11.2] Create asynchronous computations with supplyAsync / runAsync

Title: Use the supplyAsync and runAsync factory methods instead of constructing and completing a CompletableFuture by hand.
Description: You can create a `CompletableFuture`, fork a thread, and call `complete()` manually, but that is verbose and easy to get wrong. The `supplyAsync` factory takes a `Supplier` and returns a future that completes with its result; `runAsync` does the same for a `Runnable` that produces no value. By default the supplier runs on a thread from the common `ForkJoinPool`, and an overloaded version accepts a custom `Executor`.

**Good example:**

```java
public Future<Double> getPriceAsync(String product) {
    return CompletableFuture.supplyAsync(() -> calculatePrice(product));
}
```

**Bad example:**

```java
public Future<Double> getPriceAsync(String product) {
    CompletableFuture<Double> futurePrice = new CompletableFuture<>();
    new Thread(() -> {
        double price = calculatePrice(product);
        futurePrice.complete(price);   // verbose manual plumbing
    }).start();
    return futurePrice;
}
```

### [11.3] Propagate failures through the future, do not let them die in the worker thread

Title: Signal errors with completeExceptionally (or let supplyAsync capture them) so clients learn the real cause instead of hanging.
Description: If a price calculation throws and you completed the future manually, the exception stays trapped in the worker thread and the client blocks on `get()` forever — even a timeout only yields a `TimeoutException` that hides the cause. Routing the exception into the future with `completeExceptionally` makes the client receive an `ExecutionException` wrapping the original error. `supplyAsync` already does this for you, which is another reason to prefer it.

**Good example:**

```java
public Future<Double> getPriceAsync(String product) {
    CompletableFuture<Double> futurePrice = new CompletableFuture<>();
    new Thread(() -> {
        try {
            futurePrice.complete(calculatePrice(product));
        } catch (Exception ex) {
            futurePrice.completeExceptionally(ex); // client sees the real cause
        }
    }).start();
    return futurePrice;
}

// Simpler still — supplyAsync captures the exception for you:
public Future<Double> getPriceAsyncSimple(String product) {
    return CompletableFuture.supplyAsync(() -> calculatePrice(product));
}
```

**Bad example:**

```java
public Future<Double> getPriceAsync(String product) {
    CompletableFuture<Double> futurePrice = new CompletableFuture<>();
    new Thread(() -> {
        double price = calculatePrice(product); // if this throws,
        futurePrice.complete(price);            // complete() is never reached
    }).start();                                 // the exception is swallowed in the
    return futurePrice;                         // worker thread; the client blocks forever
}
```

### [11.4] Don't block on get() sequentially — launch independent calls then collect

Title: Gather all CompletableFutures first, then join them, so requests run in parallel instead of one after another.
Description: Streams are lazily evaluated, so chaining `supplyAsync` and `join` inside a single pipeline forces each request to finish before the next one even starts — turning a parallel design into a sequential one. Collect the futures into a `List<CompletableFuture<String>>` in one pass, then `join` them in a second pass. This lets every shop be queried at the same time, dropping total latency to roughly that of the slowest call.

**Good example:**

```java
public List<String> findPrices(String product) {
    List<CompletableFuture<String>> priceFutures = shops.stream()
            .map(shop -> CompletableFuture.supplyAsync(
                    () -> shop.getName() + " price is " + shop.getPrice(product), executor))
            .collect(toList());           // first pass: start them all

    return priceFutures.stream()
            .map(CompletableFuture::join) // second pass: wait for completion
            .collect(toList());
}
```

**Bad example:**

```java
public List<String> findPrices(String product) {
    return shops.stream()
            .map(shop -> CompletableFuture.supplyAsync(
                    () -> shop.getName() + " price is " + shop.getPrice(product), executor))
            .map(CompletableFuture::join) // join in the SAME lazy pipeline forces each
            .collect(toList());           // request to finish before the next one begins
}
```

### [11.5] Supply a custom Executor sized for I/O instead of relying on the common pool

Title: For I/O-bound work, configure an Executor whose thread count matches the wait/compute ratio rather than the CPU-bound common ForkJoinPool.
Description: Both parallel streams and the default `supplyAsync` share the common `ForkJoinPool`, whose size equals `availableProcessors()` — fine for compute-bound work but a bottleneck when threads spend ~99% of their time waiting on remote services. Following Goetz's formula `Nthreads = NCPU * UCPU * (1 + W/C)`, a high wait/compute ratio justifies many more threads. Size a fixed pool to the number of tasks (capped at an upper limit) and use daemon threads so they never block JVM shutdown.

**Good example:**

```java
private final Executor executor = Executors.newFixedThreadPool(
        Math.min(shops.size(), 100),
        runnable -> {
            Thread t = new Thread(runnable);
            t.setDaemon(true);                  // killed on JVM exit
            return t;
        });

CompletableFuture.supplyAsync(
        () -> shop.getName() + " price is " + shop.getPrice(product),
        executor);                              // I/O-sized pool, scales past 4 shops
```

**Bad example:**

```java
// Relies on the common ForkJoinPool (one thread per CPU core). With more shops
// than cores, the extra blocking I/O calls queue up and starve, because all
// threads sit idle waiting on the network.
CompletableFuture.supplyAsync(
        () -> shop.getName() + " price is " + shop.getPrice(product));
```

### [11.6] Pipeline dependent tasks with thenApply and thenCompose

Title: Use thenApply for a synchronous transform and thenCompose to chain a second future that depends on the first result.
Description: When a value just needs reshaping in memory (no I/O), `thenApply` registers a `Function` that runs when the future completes — no blocking. When the next step is itself asynchronous (e.g. calling a remote discount service with the parsed quote), `thenCompose` flattens the two stages into one future, feeding the first result into the second computation. Using `thenApply` where `thenCompose` is needed would leave you with a nested `CompletableFuture<CompletableFuture<...>>`.

**Good example:**

```java
List<CompletableFuture<String>> priceFutures = shops.stream()
        .map(shop -> CompletableFuture.supplyAsync(() -> shop.getPrice(product), executor))
        .map(future -> future.thenApply(Quote::parse))          // sync transform
        .map(future -> future.thenCompose(quote ->              // chain async call
                CompletableFuture.supplyAsync(
                        () -> Discount.applyDiscount(quote), executor)))
        .collect(toList());

List<String> prices = priceFutures.stream()
        .map(CompletableFuture::join)
        .collect(toList());
```

**Bad example:**

```java
// thenApply returns the inner future itself, producing a future-of-a-future that
// you then have to join twice — clumsy and defeats the point of composition.
shops.stream()
        .map(shop -> CompletableFuture.supplyAsync(() -> shop.getPrice(product), executor))
        .map(future -> future.thenApply(Quote::parse))
        .map(future -> future.thenApply(quote ->                // WRONG: should be thenCompose
                CompletableFuture.supplyAsync(
                        () -> Discount.applyDiscount(quote), executor)))
        .map(CompletableFuture::join)   // each element is a CompletableFuture<String>,
        .forEach(inner -> inner.join()); // forcing a second blocking join
```

### [11.7] Combine two independent futures with thenCombine

Title: Merge the results of two unrelated CompletableFutures using thenCombine and a BiFunction instead of waiting for one before launching the other.
Description: Sometimes two computations have no dependency — fetching a product price and fetching the EUR/USD exchange rate, for example. Rather than blocking on the first to start the second, run both with `supplyAsync` and join them via `thenCombine`, whose `BiFunction` defines how to merge the two values once both are available. Because the merge here is a cheap multiplication, the synchronous `thenCombine` is preferred over `thenCombineAsync`, which would waste a thread.

**Good example:**

```java
CompletableFuture<Double> futurePriceInUsd =
        CompletableFuture.supplyAsync(() -> shop.getPrice(product))
            .thenCombine(
                CompletableFuture.supplyAsync(() -> exchangeService.getRate(Money.EUR, Money.USD)),
                (price, rate) -> price * rate);   // both run in parallel, then merge
```

**Bad example:**

```java
// Java 7 style: the exchange-rate call and the price call are wired together
// imperatively, and reading the rate blocks before combining.
ExecutorService executor = Executors.newCachedThreadPool();

Future<Double> futureRate = executor.submit(
        () -> exchangeService.getRate(Money.EUR, Money.USD));
Future<Double> futurePriceInUsd = executor.submit(() -> {
    double priceInEur = shop.getPrice(product);
    return priceInEur * futureRate.get();         // blocks on the rate future
});
```

### [11.8] React to completion with thenAccept and coordinate with allOf / anyOf

Title: Register thenAccept callbacks to handle each result as it arrives, and use allOf/anyOf to await many futures instead of joining a whole list.
Description: Joining a list of futures means the user sees nothing until the slowest shop responds. Instead, attach a `thenAccept` `Consumer` to each future so its result is printed the instant it is ready. To know when the whole batch has finished (e.g. to show "all shops responded"), pass the resulting `CompletableFuture<Void>[]` to `CompletableFuture.allOf(...).join()`; use `anyOf` when only the first response matters. Avoid the async variant of `thenAccept` here so you react without an extra context switch.

**Good example:**

```java
CompletableFuture[] futures = findPricesStream(product)
        .map(f -> f.thenAccept(System.out::println)) // print each price as it completes
        .toArray(CompletableFuture[]::new);

CompletableFuture.allOf(futures).join();             // wait for every shop to finish
System.out.println("All shops have now responded");
```

**Bad example:**

```java
// Collects everything into a list and joins it, so the fastest shop's price is
// hidden until the slowest one (which may nearly time out) finally returns.
List<String> prices = findPricesStream(product)
        .map(CompletableFuture::join)   // blocks on each future in turn
        .collect(toList());
prices.forEach(System.out::println);    // nothing prints until all are done
```

## Chapter 12 — New Date and Time API

### [12.1] Use immutable java.time types instead of mutable Date/Calendar

Title: Model dates and times with the immutable LocalDate, LocalTime, LocalDateTime, and Instant classes rather than the error-prone java.util.Date and Calendar.
Description: `java.util.Date` is not actually a date but a millisecond instant, with confusing offsets (years from 1900, months from 0) and a misleading `toString` that injects the JVM time zone. `Calendar` repeats the month-from-zero flaw, and both classes are mutable — letting any code silently change a shared date and inviting maintenance nightmares. The `java.time` classes are immutable and clearly separate a plain date, a plain time, and their combination.

**Good example:**

```java
LocalDate date = LocalDate.of(2014, Month.MARCH, 18); // year 2014, month MARCH, day 18
LocalTime time = LocalTime.of(13, 45, 20);            // 13:45:20
LocalDateTime dateTime = LocalDateTime.of(date, time);
// Immutable: this value can be shared freely across threads without defensive copies.
```

**Bad example:**

```java
// Year is offset by 1900 and month by 0, so "March 18, 2014" becomes (114, 2, 18).
Date date = new Date(114, 2, 18);  // Tue Mar 18 00:00:00 CET 2014 — and Date is mutable
date.setMonth(3);                   // anyone holding this reference is now affected
```

### [12.2] Create with of/parse and read fields with getters or ChronoField

Title: Construct date-time objects via the of and parse factory methods, and read their parts with getYear/getMonth/getDayOfWeek or get(ChronoField...).
Description: Every `java.time` class exposes static `of(...)` factories for assembling a value from its parts, `now()` for the current value from the system clock, and `parse(...)` for building one from a `String` (throwing `DateTimeParseException` on bad input). To read values, prefer the named getters such as `getYear()` and `getDayOfWeek()`, or pass a `ChronoField` to the generic `get` method. This is far clearer and safer than the old `Calendar.get(int)` constants.

**Good example:**

```java
LocalDate date = LocalDate.parse("2014-03-18"); // or LocalDate.of(2014, 3, 18)

int year = date.getYear();              // 2014
Month month = date.getMonth();          // MARCH
DayOfWeek dow = date.getDayOfWeek();    // TUESDAY
int day = date.get(ChronoField.DAY_OF_MONTH); // 18, via TemporalField
```

**Bad example:**

```java
Calendar cal = Calendar.getInstance();
cal.set(2014, 2, 18);                    // month 2 means March — easy to misread

int year = cal.get(Calendar.YEAR);       // 2014
int month = cal.get(Calendar.MONTH);     // 2, not 3 — zero-based and confusing
int day = cal.get(Calendar.DAY_OF_MONTH);
```

### [12.3] Use Instant for machine time and Duration/Period for amounts of time

Title: Represent machine timestamps with Instant and express elapsed time with Duration.between (time-based) or Period.between (date-based).
Description: An `Instant` is a point on a continuous timeline (seconds and nanoseconds since the Unix epoch) meant for machines, not humans — asking it for a day-of-month throws `UnsupportedTemporalTypeException`. To measure a gap, use `Duration.between` for time-based values (`LocalTime`, `LocalDateTime`, `Instant`) and `Period.between` for date-based values (`LocalDate`). You cannot mix human and machine types, and you cannot pass a `LocalDate` to `Duration.between`.

**Good example:**

```java
Instant start = Instant.now();
// ... machine timestamp, not weeks/days ...
Instant end = Instant.now();

Duration elapsed = Duration.between(start, end);          // seconds + nanoseconds
Period gap = Period.between(LocalDate.of(2014, 3, 8),     // 10 days
                            LocalDate.of(2014, 3, 18));
Duration threeMinutes = Duration.ofMinutes(3);            // direct construction
```

**Bad example:**

```java
// Computing elapsed time by subtracting raw millis loses meaning and units,
// and treating an Instant as a human date blows up at runtime.
long startMillis = System.currentTimeMillis();
long endMillis = System.currentTimeMillis();
long elapsedMillis = endMillis - startMillis;            // bare long, no semantics

int day = Instant.now().get(ChronoField.DAY_OF_MONTH);   // UnsupportedTemporalTypeException
```

### [12.4] Manipulate dates immutably with plus/with and TemporalAdjusters

Title: Produce modified dates by calling plusDays/withYear or with(TemporalAdjusters...), which return new instances rather than mutating in place.
Description: Every manipulation method (`plusDays`, `minusWeeks`, `withYear`, `with(ChronoField, value)`) leaves the original object untouched and returns a fresh one, so changes can be chained safely. For complex transformations such as "the last day of the month" or "the next or same Sunday," pass a `TemporalAdjuster` from the `TemporalAdjusters` factory class to `with`. Because `TemporalAdjuster` is a functional interface, you can also supply your own logic as a lambda.

**Good example:**

```java
LocalDate date = LocalDate.of(2014, 3, 18);

LocalDate later = date.plusYears(2).minusDays(10); // chained, original unchanged
LocalDate sameMonthEnd = date.with(TemporalAdjusters.lastDayOfMonth());
LocalDate nextOrSameSunday = date.with(
        TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));
// 'date' is still 2014-03-18 throughout.
```

**Bad example:**

```java
// Mutating Calendar changes the shared object, and a forgotten reassignment
// silently has no effect on an immutable type.
Calendar cal = Calendar.getInstance();
cal.set(2014, 2, 18);
cal.add(Calendar.DAY_OF_MONTH, -10); // mutates cal in place — side effects everywhere

LocalDate date = LocalDate.of(2014, 3, 18);
date.withYear(2011);                 // result discarded; 'date' is unchanged, a hidden bug
```

### [12.5] Format and parse with thread-safe DateTimeFormatter, not SimpleDateFormat

Title: Build formatters with DateTimeFormatter (ISO constants, ofPattern, or DateTimeFormatterBuilder) because they are immutable and thread-safe, unlike SimpleDateFormat.
Description: The legacy `java.text.SimpleDateFormat`/`DateFormat` is not thread-safe — sharing one across threads yields unpredictable parsing. `DateTimeFormatter` instances are immutable and safe to share as singletons. Use predefined constants like `ISO_LOCAL_DATE` for standard formats, `ofPattern("dd/MM/yyyy")` (optionally with a `Locale`) for custom patterns, or `DateTimeFormatterBuilder` for fine-grained, case-insensitive or lenient formatters. Call `format` to print and the type's `parse` to read.

**Good example:**

```java
// Immutable and thread-safe: declare once, share everywhere.
static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");

LocalDate date = LocalDate.of(2014, 3, 18);
String text = date.format(FORMATTER);            // "18/03/2014"
LocalDate parsed = LocalDate.parse(text, FORMATTER);

LocalDate iso = LocalDate.parse("2014-03-18", DateTimeFormatter.ISO_LOCAL_DATE);
```

**Bad example:**

```java
// SimpleDateFormat is mutable and not thread-safe; sharing this static instance
// across threads corrupts parsing and produces wrong dates intermittently.
static final SimpleDateFormat SDF = new SimpleDateFormat("dd/MM/yyyy");

String text = SDF.format(new Date());            // race condition under concurrency
Date parsed = SDF.parse(text);                   // may throw or return garbage
```

### [12.6] Handle time zones with ZoneId/ZonedDateTime, not java.util.TimeZone

Title: Apply time zones using the immutable ZoneId and combine with a date-time to get a ZonedDateTime, replacing the old java.util.TimeZone.
Description: `ZoneId` supersedes `java.util.TimeZone`, shielding you from Daylight Saving Time complexity and remaining immutable. A zone is identified by a region ID in `"{area}/{city}"` form from the IANA database. Once you have a `ZoneId`, combine it with a `LocalDate`, `LocalDateTime`, or `Instant` (via `atStartOfDay`, `atZone`, or `Instant.atZone`) to get a `ZonedDateTime` — a point in time relative to that zone. For a fixed UTC offset use `ZoneOffset`, but note it has no DST handling.

**Good example:**

```java
ZoneId romeZone = ZoneId.of("Europe/Rome");      // immutable, DST-aware

LocalDate date = LocalDate.of(2014, Month.MARCH, 18);
ZonedDateTime zdt = date.atStartOfDay(romeZone);

LocalDateTime dateTime = LocalDateTime.of(2014, Month.MARCH, 18, 13, 45);
ZonedDateTime zdt2 = dateTime.atZone(romeZone);

Instant instant = Instant.now();
ZonedDateTime zdt3 = instant.atZone(romeZone);
```

**Bad example:**

```java
// The legacy TimeZone + Calendar combination is mutable, verbose, and fragile
// around DST transitions.
TimeZone rome = TimeZone.getTimeZone("Europe/Rome");
Calendar cal = Calendar.getInstance(rome);
cal.set(2014, 2, 18, 13, 45, 0);                 // zero-based month, mutable state
Date date = cal.getTime();                       // no clean zoned representation
```

## Chapter 13 — Thinking Functionally

### [13.1] Write side-effect-free, pure functions

Title: Make methods pure — characterized only by their inputs and return value, with no observable side effects.
Description: The book defines a pure (side-effect-free) method as one that modifies neither the state of its enclosing class nor any other object, and returns its entire result via `return`. Side effects include mutating a data structure in place, throwing exceptions, and doing I/O. Pure methods are easier to reason about, can run on multiple cores without locking, and never put shared objects into an unexpected state.

**Good example:**

```java
// No side effects: result depends only on arguments, nothing shared is mutated
static List<List<Integer>> concat(List<List<Integer>> a,
                                   List<List<Integer>> b) {
    List<List<Integer>> r = new ArrayList<>(a);
    r.addAll(b);
    return r;
}
```

**Bad example:**

```java
// Side-effecting: mutates argument `a`, so a later reader of `a` is surprised
static List<List<Integer>> concat(List<List<Integer>> a,
                                   List<List<Integer>> b) {
    a.addAll(b);   // destructively updates the caller's list
    return a;
}
```

### [13.2] Avoid shared mutable data structures

Title: Don't update a data structure shared with the caller — build a new one instead.
Description: The chapter argues that the "unexpected variable value" bugs that dominate maintenance come from data structures read and updated by several methods, where ownership is unclear. Mutating local variables that the caller can't see is fine; mutating state shared with the rest of the program (such as a passed-in `Stats` object) is not functional style. Reducing shared mutable data makes programs easier to debug and parallelize.

**Good example:**

```java
// Counts matches without touching shared state; returns the count
static long countGold(List<String> l) {
    return l.stream()
            .filter("gold"::equals)
            .count();
}
```

**Bad example:**

```java
// Loop body mutates the shared `stats` object — a visible side effect
public void searchForGold(List<String> l, Stats stats) {
    for (String s : l) {
        if ("gold".equals(s)) {
            stats.incrementFor("gold");   // mutates state shared with the caller
        }
    }
}
```

### [13.3] Program declaratively, not imperatively

Title: Say *what* you want with stream queries rather than spelling out *how* with mutating loops.
Description: The book contrasts the imperative "how" style — assignment, conditional branching, and loops mimicking the low-level vocabulary of a computer — with the declarative "what" style of the Streams API. A declarative query reads like the problem statement and leaves the implementation (internal iteration) to the library, which makes the code easier to understand immediately.

**Good example:**

```java
import static java.util.Comparator.comparing;

// Declarative: reads like the problem statement
Optional<Transaction> mostExpensive =
    transactions.stream()
                .max(comparing(Transaction::getValue));
```

**Bad example:**

```java
// Imperative: manual iteration variable that is mutated step by step
Transaction mostExpensive = transactions.get(0);
if (mostExpensive == null)
    throw new IllegalArgumentException("Empty list of transactions");
for (Transaction t : transactions.subList(1, transactions.size())) {
    if (t.getValue() > mostExpensive.getValue()) {
        mostExpensive = t;   // mutation in a loop
    }
}
```

### [13.4] Prefer immutable objects and final fields

Title: Make objects immutable so they can't go into an unexpected state and can be shared freely.
Description: The chapter notes that an immutable object can't change state after instantiation, so it can never be put into an unexpected state by a function, can be shared without copying, and is inherently thread-safe. To be regarded as functional style, a method may mutate only local variables, and objects it references should be immutable — all fields `final` and transitively referring to other immutable objects.

**Good example:**

```java
// Immutable value type: final fields, no setters, safe to share
final class Point {
    private final int x;
    private final int y;
    Point(int x, int y) { this.x = x; this.y = y; }
    int getX() { return x; }
    int getY() { return y; }
    Point withX(int newX) { return new Point(newX, y); } // returns a new object
}
```

**Bad example:**

```java
// Mutable: any holder can change its state later, leading to surprises
class Point {
    private int x;
    private int y;
    Point(int x, int y) { this.x = x; this.y = y; }
    void setX(int x) { this.x = x; } // shared mutation hazard
    void setY(int y) { this.y = y; }
}
```

### [13.5] Signal failure with Optional instead of exceptions

Title: Model partial functions (like division or sqrt of a negative) by returning `Optional<T>` rather than throwing.
Description: The book explains that throwing an exception breaks the simple "pass arguments, return result" black-box model and is not functional style; catching one is nonfunctional control flow. For partial functions that are undefined on some inputs, return `Optional<T>` — either a value representing success or an empty value indicating the operation couldn't be performed — so callers handle the missing case explicitly.

**Good example:**

```java
// Returns Optional instead of throwing on the undefined case
static Optional<Double> sqrt(double x) {
    return x < 0 ? Optional.empty() : Optional.of(Math.sqrt(x));
}
```

**Bad example:**

```java
// Throws for negative input — breaks the black-box "return a result" model
static double sqrt(double x) {
    if (x < 0) {
        throw new IllegalArgumentException("negative argument");
    }
    return Math.sqrt(x);
}
```

### [13.6] Replace mutating iteration with streams or recursion

Title: Use streams (or a recursive definition) instead of loops that update iteration variables.
Description: Pure functional languages omit `while`/`for` loops because they invite mutation of the loop condition. In Java 8 you can often replace iteration with streams to avoid mutation, or with recursion when it yields a more concise, side-effect-free algorithm. The book cautions, though, that naive recursion in Java consumes a stack frame per call (risking `StackOverflowError`) since Java has no tail-call elimination — so prefer streams or tail-style helpers for large inputs.

**Good example:**

```java
// Declarative, side-effect-free factorial via a stream reduction
static long factorial(long n) {
    return LongStream.rangeClosed(1, n)
                     .reduce(1, (a, b) -> a * b);
}
```

**Bad example:**

```java
// Loop with two iteration variables (r and i) mutated on every step
static long factorial(int n) {
    long r = 1;
    for (int i = 1; i <= n; i++) {
        r *= i;   // mutation
    }
    return r;
}
```

## Chapter 14 — Functional Programming Techniques

### [14.1] Treat functions as first-class values

Title: Store, pass, and return functions as values using method references and lambdas.
Description: The chapter explains that functional-language programmers use functions like any other value — passed as arguments, returned as results, and stored in data structures — and that Java 8 adds exactly this with the `::` method-reference operator and lambdas. You can keep a method such as `Integer.parseInt` in a `Function` variable or build a `Map` from names to function values.

**Good example:**

```java
// A method stored as a first-class function value, and a map of functions
Function<String, Integer> strToInt = Integer::parseInt;

Map<String, Function<Double, Double>> calculator = new HashMap<>();
calculator.put("sin", Math::sin);
calculator.put("cos", Math::cos);

double result = calculator.get("sin").apply(Math.PI / 2);
```

**Bad example:**

```java
// Pre-Java-8 style: behavior hard-wired behind a switch, not passable as a value
double compute(String op, double x) {
    switch (op) {
        case "sin": return Math.sin(x);
        case "cos": return Math.cos(x);
        default: throw new IllegalArgumentException(op);
    }
}
// Cannot store, pass around, or compose the "sin" behavior on its own
```

### [14.2] Write higher-order functions

Title: Write functions that take other functions as parameters and/or return functions as results.
Description: A higher-order function is one that takes one or more functions as parameters or returns a function. The book points to `Comparator.comparing` (which takes a key-extractor function and returns a `Comparator`) and `Function.andThen`/`compose` (which build a pipeline). When writing such functions, document which side effects you accept from the passed-in functions — and "none" is best.

**Good example:**

```java
// Higher-order: takes a function and returns a Comparator (a function)
Comparator<Apple> byWeight = Comparator.comparing(Apple::getWeight);

// Higher-order: composes two functions into one
Function<String, String> pipeline =
    addHeader.andThen(Letter::checkSpelling)
             .andThen(Letter::addFooter);
```

**Bad example:**

```java
// Fixed behavior hard-coded; nothing is parameterized by a function
class AppleWeightComparator implements Comparator<Apple> {
    public int compare(Apple a, Apple b) {
        return Integer.compare(a.getWeight(), b.getWeight());
    }
}
// A separate class per comparison criterion — no reuse of the underlying logic
```

### [14.3] Curry functions to specialize and reuse logic

Title: Turn a multi-argument function into a chain of one-argument functions so you can fix some arguments and reuse the core logic.
Description: Currying sees a function `f(x, y)` as a function `g(x)` that returns a function of `y`, so `f(x,y) = (g(x))(y)`. The book's unit-conversion example defines a factory that, given a conversion factor and baseline, returns a one-argument converter — avoiding the need to re-pass the factor and baseline (or write a new method) every time, and reducing the chance of mistyping them.

**Good example:**

```java
// A "factory" that returns specialized one-argument converters (currying)
static DoubleUnaryOperator curriedConverter(double f, double b) {
    return x -> x * f + b;
}

DoubleUnaryOperator convertCtoF      = curriedConverter(9.0 / 5, 32);
DoubleUnaryOperator convertUSDtoGBP  = curriedConverter(0.6, 0);
double gbp = convertUSDtoGBP.applyAsDouble(1000);
```

**Bad example:**

```java
// Over-general: factor and baseline must be re-supplied at every call site
static double converter(double x, double f, double b) {
    return x * f + b;
}

double f1 = converter(1000, 0.6, 0);     // easy to mistype the factor/baseline
double f2 = converter(250, 9.0 / 5, 32); // logic not reused or specialized
```

### [14.4] Use persistent data structures instead of destructive updates

Title: When you need a modified structure, create a new version that shares structure with the old one — never mutate the input.
Description: A functional-style method must not update any structure passed as a parameter, because doing so violates referential transparency and surprises other holders of that structure. The book's `TrainJourney` example shows that a destructive `link` corrupts the first journey, whereas a functional `append` builds new nodes and shares the tail — leaving every existing structure untouched. Callers must also honor the do-not-mutate contract on the result.

**Good example:**

```java
// Functional append: builds new nodes, shares b's tail, mutates nothing
static TrainJourney append(TrainJourney a, TrainJourney b) {
    return a == null
        ? b
        : new TrainJourney(a.price, append(a.onward, b));
}
```

**Bad example:**

```java
// Destructive link: walks to the end of `a` and rewires it, corrupting firstJourney
static TrainJourney link(TrainJourney a, TrainJourney b) {
    if (a == null) return b;
    TrainJourney t = a;
    while (t.onward != null) {
        t = t.onward;
    }
    t.onward = b;   // mutates the structure passed in
    return a;
}
```

### [14.5] Functionally update trees by re-creating only the path

Title: Update an immutable tree by creating new nodes along the root-to-change path while sharing the rest with the original.
Description: The chapter contrasts a mutating `update` (which every map user sees) with `fupdate`, which returns a brand-new tree sharing as much as possible with its argument. For a balanced tree of depth `d` only a small fraction of nodes are re-created, and the original tree is never harmed — so callers holding the old version are isolated from the change. Declaring the fields `final` helps the compiler enforce no mutation.

**Good example:**

```java
// fupdate: purely functional; creates new nodes on the path, shares the rest
public static Tree fupdate(String k, int newval, Tree t) {
    return (t == null) ?
        new Tree(k, newval, null, null) :
      k.equals(t.key) ?
        new Tree(k, newval, t.left, t.right) :
      k.compareTo(t.key) < 0 ?
        new Tree(t.key, t.val, fupdate(k, newval, t.left), t.right) :
        new Tree(t.key, t.val, t.left, fupdate(k, newval, t.right));
}
```

**Bad example:**

```java
// update: mutates the existing tree in place — every map user sees the change
public static Tree update(String k, int newval, Tree t) {
    if (t == null)
        t = new Tree(k, newval, null, null);
    else if (k.equals(t.key))
        t.val = newval;                       // in-place mutation
    else if (k.compareTo(t.key) < 0)
        t.left = update(k, newval, t.left);
    else
        t.right = update(k, newval, t.right);
    return t;
}
```

### [14.6] Build lazy lists with Supplier-backed tails for infinite sequences

Title: Place a `Supplier` in the tail so list nodes are created on demand, modeling sequences (like all primes) that a once-only Java stream can't define recursively.
Description: Java 8 streams are lazy but can be consumed only once, so you cannot define a stream recursively (the prime-sieve attempt fails with "stream has already been operated upon or closed" and infinite recursion). The book builds a `LazyList` whose tail is a `Supplier<MyList<T>>`, so calling `get()` creates the next node only when needed — letting you express an infinite, self-defining list of numbers or primes.

**Good example:**

```java
// Lazy list: the tail is a Supplier, so nodes are produced on demand
class LazyList<T> implements MyList<T> {
    final T head;
    final Supplier<MyList<T>> tail;
    LazyList(T head, Supplier<MyList<T>> tail) { this.head = head; this.tail = tail; }
    public T head() { return head; }
    public MyList<T> tail() { return tail.get(); } // next node created only here
    public boolean isEmpty() { return false; }
}

// Infinite list of integers starting at n — generated lazily
static LazyList<Integer> from(int n) {
    return new LazyList<>(n, () -> from(n + 1));
}
```

**Bad example:**

```java
// Trying to define a stream recursively fails: terminal ops consume it,
// and the recursive call to primes() leads to infinite recursion
static IntStream primes(IntStream numbers) {
    int head = numbers.findFirst().getAsInt();          // consumes the stream
    return IntStream.concat(
               IntStream.of(head),
               primes(numbers.skip(1).filter(n -> n % head != 0))); // never terminates
}
```

### [14.7] Defer computation with Supplier-based lazy evaluation

Title: Wrap a branch in a `Supplier` so it's evaluated only when actually needed, instead of eagerly evaluating all arguments.
Description: In Java every argument to a method is fully evaluated immediately, which is why a direct recursive call as a `concat` argument explodes. The chapter shows you can defer evaluation by passing `Supplier`s and calling `get()` only on demand — the same trick that lets you encode `if`-`then`-`else` as a method (`myIf`) where only the chosen branch runs.

**Good example:**

```java
// Branches are wrapped as Suppliers; only the chosen branch is evaluated
static <T> T myIf(boolean b, Supplier<T> trueCase, Supplier<T> falseCase) {
    return b ? trueCase.get() : falseCase.get();
}

T result = myIf(condition, () -> expensiveTrue(), () -> expensiveFalse());
```

**Bad example:**

```java
// Both arguments are fully evaluated before the call, even though only one is used
static <T> T choose(boolean b, T trueCase, T falseCase) {
    return b ? trueCase : falseCase;
}

T result = choose(condition, expensiveTrue(), expensiveFalse()); // both run eagerly
```

### [14.8] Emulate pattern matching with lambdas instead of instanceof chains

Title: Decompose a data type by passing one lambda per case to a dispatch helper, avoiding clumsy `instanceof`-and-cast chains.
Description: Java lacks structural pattern matching, so traversing a tree of `Expr`/`BinOp`/`Number` with nested `instanceof` and casts gets ugly fast. The book simulates single-level pattern matching with a `patternMatchExpr` helper that takes a function for each case (and a default), giving each case direct access to the relevant fields — far neater than chains of `if`-`then`-`else` interleaved with field selection.

**Good example:**

```java
// Single-level "pattern matching" via one lambda per case
static <T> T patternMatchExpr(Expr e,
        TriFunction<String, Expr, Expr, T> binopCase,
        Function<Integer, T> numCase,
        Supplier<T> defaultCase) {
    return (e instanceof BinOp) ?
        binopCase.apply(((BinOp) e).opname, ((BinOp) e).left, ((BinOp) e).right) :
        (e instanceof Number) ?
            numCase.apply(((Number) e).val) :
            defaultCase.get();
}
```

**Bad example:**

```java
// Hand-rolled instanceof + cast chains: clumsy and error-prone
Expr simplify(Expr expr) {
    if (expr instanceof BinOp
            && ((BinOp) expr).opname.equals("+")
            && ((BinOp) expr).right instanceof Number
            && ((Number) ((BinOp) expr).right).val == 0) {
        return ((BinOp) expr).left;
    }
    // ...and so on, getting uglier with each case
    return expr;
}
```

## Chapter 15 — Blending OOP and FP: Java 8 and Scala

### [15.1] Use stream/collection operations to express queries concisely

Title: Chain `filter`/`map`-style operations over collections instead of writing verbose explicit loops.
Description: The chapter shows that both Java 8 (via streams) and Scala (directly on collections) support functional-style processing of collections, letting a multi-step query read like the problem statement. Scala can make it even terser with infix notation and the `_` placeholder, but the Java 8 stream pipeline already replaces the pre-Java-8 verbose loop-and-accumulate style.

**Good example:**

```java
// Java 8: a concise filter/map pipeline reads like the intent
List<String> linesLongUpper =
    fileLines.stream()
             .filter(l -> l.length() > 10)
             .map(String::toUpperCase)
             .collect(Collectors.toList());

// Scala equivalent intent: fileLines filter (_.length() > 10) map (_.toUpperCase())
```

**Bad example:**

```java
// Pre-Java-8: manual iteration with an externally mutated accumulator
List<String> linesLongUpper = new ArrayList<>();
for (String l : fileLines) {
    if (l.length() > 10) {
        linesLongUpper.add(l.toUpperCase());
    }
}
```

### [15.2] Default the design to immutable, persistent collections

Title: Prefer immutable collections that produce a new version on "update" over unmodifiable wrappers around a mutable backing collection.
Description: The chapter notes Scala collections are immutable by default and persistent — updating yields a new collection sharing structure with the old, so accessing it anywhere always yields the same elements and reduces implicit data dependencies. It warns that Java's `Collections.unmodifiableSet` is only a read-only *view* over a modifiable collection, so changes through the original reference still leak through. Truly immutable structures guarantee nothing can change them regardless of how many variables point at them.

**Good example:**

```java
// Genuinely immutable collection: no reference can mutate it
List<Integer> numbers = Collections.unmodifiableList(
    Stream.of(1, 2, 3).collect(Collectors.toList()));
// "Updating" produces a new list, sharing nothing mutable with the old one
List<Integer> more = Stream.concat(numbers.stream(), Stream.of(4))
                           .collect(Collectors.toList());
// numbers is still [1, 2, 3]
```

**Bad example:**

```java
// Unmodifiable view: still mutable through the original backing reference
Set<Integer> numbers = new HashSet<>();
Set<Integer> newNumbers = Collections.unmodifiableSet(numbers);
numbers.add(42);            // leaks through — newNumbers now "sees" 42 too
```

### [15.3] Use Optional/Option chaining instead of null checks

Title: Express "maybe-present" results with `Optional` and chain `filter`/`flatMap`/`map`/`orElse`, rather than relying on `null`.
Description: The chapter presents `Optional` (Java 8) and Scala's `Option` as near-identical tools for designing better APIs: the signature tells callers a value may be absent, and chained operations let the library handle the missing case instead of user-written null checks. The book stresses that `null` (though it exists in Scala for Java compatibility) is highly discouraged because it causes null pointer exceptions.

**Good example:**

```java
// Optional chain: missing values handled by the library, no null checks
public String getCarInsuranceName(Optional<Person> person, int minAge) {
    return person.filter(p -> p.getAge() >= minAge)
                 .flatMap(Person::getCar)
                 .flatMap(Car::getInsurance)
                 .map(Insurance::getName)
                 .orElse("Unknown");
}
```

**Bad example:**

```java
// Defensive, error-prone null checks at every step
public String getCarInsuranceName(Person person, int minAge) {
    if (person != null && person.getAge() >= minAge) {
        Car car = person.getCar();
        if (car != null) {
            Insurance ins = car.getInsurance();
            if (ins != null) {
                return ins.getName();   // any missed null check risks an NPE
            }
        }
    }
    return "Unknown";
}
```

### [15.4] Add shared behavior with default methods on interfaces

Title: Provide a default implementation in an interface (like Scala traits) so implementers inherit behavior without copying boilerplate.
Description: The chapter compares Scala traits — which may declare abstract methods and methods with default implementations, and can be multiply inherited — to Java 8 interfaces with default methods, the mechanism that gives Java multiple inheritance of behavior. (Scala traits go further by also allowing fields/state, which Java 8 interfaces don't.) Default methods let an interface define common behavior such as `isEmpty` once, so each implementer doesn't re-write it.

**Good example:**

```java
// Java 8 interface with a default method: behavior inherited, not copied
interface Sized {
    int size();
    default boolean isEmpty() {   // shared default behavior
        return size() == 0;
    }
}

class EmptyBox implements Sized {
    public int size() { return 0; }   // isEmpty() inherited for free
}
```

**Bad example:**

```java
// Pre-Java-8: interface can only declare signatures, so every class
// must re-implement the same isEmpty() logic by hand
interface Sized {
    int size();
    boolean isEmpty();
}

class EmptyBox implements Sized {
    public int size() { return 0; }
    public boolean isEmpty() { return size() == 0; } // duplicated in every implementer
}
```

## Chapter 16 — Conclusions and Where Next for Java

### [16.1] Parameterize behavior with lambdas and method references

Title: Pass a piece of code (a lambda or method reference) into a method instead of wrapping the behavior in a one-off class.
Description: The review chapter recalls that to write a reusable method like `filter` you must supply the filtering criterion. Pre-Java-8 you wrapped the criterion as a method inside a class and passed an instance — too cumbersome for general use. Java 8 lets you pass a lambda (a one-off piece of code) or a method reference to existing code, which is what propels lambdas to the center of the Streams API.

**Good example:**

```java
// Behavior parameterization with a lambda / method reference
List<Apple> heavy = inventory.stream()
                             .filter(apple -> apple.getWeight() > 150)
                             .collect(Collectors.toList());

List<Apple> green = inventory.stream()
                             .filter(Apple::isHeavy)
                             .collect(Collectors.toList());
```

**Bad example:**

```java
// Pre-Java-8: a whole class just to carry one filtering criterion
interface ApplePredicate { boolean test(Apple a); }

class HeavyApplePredicate implements ApplePredicate {
    public boolean test(Apple a) { return a.getWeight() > 150; }
}

List<Apple> filterApples(List<Apple> inventory, ApplePredicate p) {
    List<Apple> result = new ArrayList<>();
    for (Apple a : inventory) {
        if (p.test(a)) result.add(a);
    }
    return result;
}
List<Apple> heavy = filterApples(inventory, new HeavyApplePredicate());
```

### [16.2] Pipeline data transformations with Streams

Title: Compose `map`/`filter`/`sorted` into a single lazy pipeline rather than making repeated traversals over a collection.
Description: The chapter explains why Java 8 added a whole new Streams API rather than just adding `filter`/`map` to collections: applying three operations to a collection imperatively makes three separate traversals, whereas a stream lazily fuses them into a pipeline and traverses once — much more efficient for large datasets and amenable to parallel execution via `parallel`. Side-effect-free operations and internal iteration are central to exploiting this.

**Good example:**

```java
// Single lazy pipeline; one traversal, ready to parallelize
List<Integer> result =
    transactions.stream()
                .map(t -> t.getValue() + t.getTax())
                .filter(sum -> sum > 1000)
                .sorted()
                .collect(Collectors.toList());
```

**Bad example:**

```java
// Three explicit passes over the data and an intermediate mutable list
List<Integer> sums = new ArrayList<>();
for (Transaction t : transactions) {                 // pass 1: map
    sums.add(t.getValue() + t.getTax());
}
List<Integer> big = new ArrayList<>();
for (Integer s : sums) {                             // pass 2: filter
    if (s > 1000) big.add(s);
}
Collections.sort(big);                               // pass 3: sort
```

### [16.3] Compose asynchronous work with CompletableFuture

Title: Use `thenCompose`/`thenCombine`/`allOf` to pipeline async tasks instead of blocking on raw `Future.get()` and writing imperative glue.
Description: The chapter offers the motto "CompletableFuture is to Future as Stream is to Collection": just as streams pipeline operations and avoid iterator boilerplate, `CompletableFuture` provides combinators that give concise, functional-style encodings of common `Future` design patterns and avoid imperative boilerplate. A plain `Future` only lets you spawn a task and later block on `get()`.

**Good example:**

```java
// Functional-style composition of async work, no blocking glue
CompletableFuture<Double> price =
    CompletableFuture.supplyAsync(() -> shop.getPriceQuote(product))
                     .thenCompose(quote ->
                         CompletableFuture.supplyAsync(() -> applyDiscount(quote)));
double finalPrice = price.join();
```

**Bad example:**

```java
// Raw Futures: spawn, then block on get() with manual exception plumbing
ExecutorService executor = Executors.newFixedThreadPool(2);
Future<String> quoteFuture = executor.submit(() -> shop.getPriceQuote(product));
try {
    String quote = quoteFuture.get();                 // blocks
    Future<Double> priceFuture = executor.submit(() -> applyDiscount(quote));
    double finalPrice = priceFuture.get();            // blocks again
} catch (InterruptedException | ExecutionException e) {
    throw new RuntimeException(e);
}
```

### [16.4] Represent missing values with Optional, never the null pointer

Title: Return `Optional<T>` to document a possibly-absent value and chain `map`/`filter`/`ifPresent`, eliminating accidental `NullPointerException`.
Description: The chapter argues `Optional<T>` gives an explicit "missing value" data type instead of the error-prone `null`, which could never be distinguished from an accidental null left by an earlier erroneous computation. Used consistently, programs should never throw `NullPointerException`, and `Optional`'s `map`/`filter`/`ifPresent` let the library test for the missing value internally — analogous to internal iteration in streams.

**Good example:**

```java
// Optional makes absence explicit and the library does the missing-value test
public Optional<Insurance> findCheapest(Person person) { /* ... */ }

findCheapest(person)
    .map(Insurance::getName)
    .ifPresent(System.out::println);   // runs only when a value is present
```

**Bad example:**

```java
// Returns null to mean "none" — caller must remember to null-check or risk NPE
public Insurance findCheapest(Person person) {
    // ... may return null
    return null;
}

Insurance i = findCheapest(person);
System.out.println(i.getName());        // NullPointerException if none was found
```

## Appendix B — Miscellaneous Library Updates

### [B.1] Read map values with getOrDefault

Title: Use `Map.getOrDefault` to supply a fallback in one call instead of a `containsKey`-then-`get` idiom.
Description: The appendix shows `getOrDefault` replaces the old pattern of checking `containsKey` and conditionally calling `get`. It returns the mapped value if present, otherwise the supplied default — note it returns the default only when there is no mapping (a key explicitly mapped to `null` yields `null`, not the default).

**Good example:**

```java
// One concise call with a built-in fallback
Map<String, Integer> carInventory = new HashMap<>();
int count = carInventory.getOrDefault("Aston Martin", 0);
```

**Bad example:**

```java
// Old idiom: explicit containsKey check then get
Map<String, Integer> carInventory = new HashMap<>();
int count = 0;
if (carInventory.containsKey("Aston Martin")) {
    count = carInventory.get("Aston Martin");
}
```

### [B.2] Implement caching with computeIfAbsent

Title: Use `Map.computeIfAbsent` to compute and store a value only when the key is absent, expressing the caching/memoization pattern concisely.
Description: The appendix highlights `computeIfAbsent` (also referenced in the memoization discussion of chapter 14) for the caching pattern: if the key has no value, it computes one with the supplied function, stores it, and returns it — so an expensive fetch runs only once per key. It replaces a manual get-null-check-compute-put sequence.

**Good example:**

```java
// Caching in one call: getData runs only if url is not already cached
Map<String, String> cache = new HashMap<>();

public String getData(String url) {
    return cache.computeIfAbsent(url, this::fetchData);
}
```

**Bad example:**

```java
// Manual cache: get, null-check, compute, put — verbose and easy to get wrong
Map<String, String> cache = new HashMap<>();

public String getData(String url) {
    String data = cache.get(url);
    if (data == null) {
        data = fetchData(url);
        cache.put(url, data);
    }
    return data;
}
```

### [B.3] Mutate collections in place with removeIf, replaceAll, and forEach

Title: Use the new `Collection.removeIf`, `List.replaceAll`, and `Iterable.forEach` methods to update or traverse collections directly.
Description: The appendix lists default methods added across the collection interfaces. `removeIf` removes every element matching a predicate (unlike `Stream.filter`, which produces a new stream and never mutates the source); `List.replaceAll` replaces each element with the result of an operator, mutating the list in place (whereas `Stream.map` produces new elements); and `Iterable.forEach` traverses applying an action. These contrast with the old explicit-loop / iterator-removal idioms.

**Good example:**

```java
// Concise in-place collection updates using the new default methods
List<Integer> numbers = new ArrayList<>(Arrays.asList(1, 2, 3, 4, 5, 6));
numbers.removeIf(n -> n % 2 != 0);   // remove odds -> [2, 4, 6]
numbers.replaceAll(n -> n * 2);      // double each -> [4, 8, 12]
numbers.forEach(System.out::println);
```

**Bad example:**

```java
// Old idioms: explicit Iterator.remove() and an index loop to mutate elements
List<Integer> numbers = new ArrayList<>(Arrays.asList(1, 2, 3, 4, 5, 6));
for (Iterator<Integer> it = numbers.iterator(); it.hasNext(); ) {
    if (it.next() % 2 != 0) {
        it.remove();                 // verbose and easy to misuse
    }
}
for (int i = 0; i < numbers.size(); i++) {
    numbers.set(i, numbers.get(i) * 2);
}
```

### [B.4] Update map values atomically with merge

Title: Use `Map.merge` to combine a new value with an existing one in a single call instead of a get/null-check/put sequence.
Description: The appendix lists `merge` among the new `Map` methods (alongside `putIfAbsent`, `compute`, and `replace`). `merge` lets you insert a value when a key is absent or combine it with the existing value via a remapping function — the natural fit for accumulating counts or sums without a manual "is it there yet?" check.

**Good example:**

```java
// merge: insert-or-combine in one call (here, accumulating word counts)
Map<String, Integer> counts = new HashMap<>();
for (String word : words) {
    counts.merge(word, 1, Integer::sum);   // 1 if absent, else add to existing
}
```

**Bad example:**

```java
// Manual accumulation: get, null-check, then put
Map<String, Integer> counts = new HashMap<>();
for (String word : words) {
    Integer current = counts.get(word);
    if (current == null) {
        counts.put(word, 1);
    } else {
        counts.put(word, current + 1);
    }
}
```

### [B.5] Use overflow-checked Math operations and parallel array methods

Title: Use `Math.addExact`/`multiplyExact` (and `Arrays.parallelSort`/`setAll`/`parallelPrefix`) to fail fast on overflow and process large arrays efficiently.
Description: The appendix notes the `Math` class gained `addExact`, `subtractExact`, `multiplyExact`, `incrementExact`, `decrementExact`, `negateExact`, and `toIntExact`, all of which throw an `ArithmeticException` on overflow rather than silently wrapping around. It also describes new `Arrays` methods: `parallelSort` sorts in parallel, `setAll`/`parallelSetAll` fill an array from an index function (the parallel form's function must be side-effect free), and `parallelPrefix` cumulates elements in parallel with a binary operator.

**Good example:**

```java
// Overflow is detected instead of silently wrapping
long safe = Math.addExact(Long.MAX_VALUE - 1, 1);   // ok
try {
    int overflow = Math.multiplyExact(Integer.MAX_VALUE, 2); // throws ArithmeticException
} catch (ArithmeticException e) {
    System.out.println("overflow detected");
}

// Initialize and sort large arrays with the new (parallel-capable) helpers
int[] evens = new int[10];
Arrays.setAll(evens, i -> i * 2);   // 0, 2, 4, 6, ...
Arrays.parallelSort(evens);
```

**Bad example:**

```java
// Plain arithmetic silently overflows; manual loop misses parallelism
int overflow = Integer.MAX_VALUE * 2;   // wraps around to -2, no error
int[] evens = new int[10];
for (int i = 0; i < evens.length; i++) {
    evens[i] = i * 2;                    // sequential, hand-written
}
```
