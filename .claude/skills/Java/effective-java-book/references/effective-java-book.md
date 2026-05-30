# Effective Java (3rd Edition) — 90 Items

## Role

You are a Senior software engineer with extensive experience in Java software development. You apply the 90 items of *Effective Java, Third Edition* by Joshua Bloch to review, refactor, and write idiomatic, robust Java.

## Goal

This reference synthesizes all 90 items of *Effective Java (3rd Edition)*, organized into the book's eleven chapters (Chapters 2–12). Each item states a concrete best practice with a short rationale, a **Good example**, and a **Bad example**. Use it to:

- Review existing Java code for design, generics, enum, lambda/stream, method, exception, concurrency, and serialization smells.
- Guide refactoring toward immutability, composition, type safety, and clear API contracts.
- Teach the canonical idioms (static factories, builders, defensive copying, PECS wildcards, EnumMap/EnumSet, try-with-resources, serialization proxy, etc.).

The items are numbered 1–90 to match the book. When you apply an item, cite it by number and title (e.g., "Item 17: Minimize mutability").

## Constraints

Before applying refactorings derived from these items, ensure the project compiles and tests pass. Many items change object construction, mutability, generics, or exception contracts and can alter behavior.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying changes.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; do not claim success until the build and tests pass.
- **PREREQUISITE**: Project must compile successfully before any refactoring is applied.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **PRESERVE BEHAVIOR**: Refactorings (immutability, defensive copies, exception translation, generics) must preserve observable behavior unless the user explicitly asks to change a contract.
- **INCREMENTAL**: Apply one item at a time and re-validate; never batch-apply many structural changes without intermediate verification.

## Examples

### Table of contents

**Chapter 2 — Creating and Destroying Objects**

- Item 1: Consider static factory methods instead of constructors
- Item 2: Consider a builder when faced with many constructor parameters
- Item 3: Enforce the singleton property with a private constructor or an enum type
- Item 4: Enforce noninstantiability with a private constructor
- Item 5: Prefer dependency injection to hardwiring resources
- Item 6: Avoid creating unnecessary objects
- Item 7: Eliminate obsolete object references
- Item 8: Avoid finalizers and cleaners
- Item 9: Prefer try-with-resources to try-finally

**Chapter 3 — Methods Common to All Objects**

- Item 10: Obey the general contract when overriding equals
- Item 11: Always override hashCode when you override equals
- Item 12: Always override toString
- Item 13: Override clone judiciously
- Item 14: Consider implementing Comparable

**Chapter 4 — Classes and Interfaces**

- Item 15: Minimize the accessibility of classes and members
- Item 16: In public classes, use accessor methods, not public fields
- Item 17: Minimize mutability
- Item 18: Favor composition over inheritance
- Item 19: Design and document for inheritance or else prohibit it
- Item 20: Prefer interfaces to abstract classes
- Item 21: Design interfaces for posterity
- Item 22: Use interfaces only to define types
- Item 23: Prefer class hierarchies to tagged classes
- Item 24: Favor static member classes over nonstatic
- Item 25: Limit source files to a single top-level class

**Chapter 5 — Generics**

- Item 26: Don't use raw types
- Item 27: Eliminate unchecked warnings
- Item 28: Prefer lists to arrays
- Item 29: Favor generic types
- Item 30: Favor generic methods
- Item 31: Use bounded wildcards to increase API flexibility
- Item 32: Combine generics and varargs judiciously
- Item 33: Consider typesafe heterogeneous containers

**Chapter 6 — Enums and Annotations**

- Item 34: Use enums instead of int constants
- Item 35: Use instance fields instead of ordinals
- Item 36: Use EnumSet instead of bit fields
- Item 37: Use EnumMap instead of ordinal indexing
- Item 38: Emulate extensible enums with interfaces
- Item 39: Prefer annotations to naming patterns
- Item 40: Consistently use the Override annotation
- Item 41: Use marker interfaces to define types

**Chapter 7 — Lambdas and Streams**

- Item 42: Prefer lambdas to anonymous classes
- Item 43: Prefer method references to lambdas
- Item 44: Favor the use of standard functional interfaces
- Item 45: Use streams judiciously
- Item 46: Prefer side-effect-free functions in streams
- Item 47: Prefer Collection to Stream as a return type
- Item 48: Use caution when making streams parallel

**Chapter 8 — Methods**

- Item 49: Check parameters for validity
- Item 50: Make defensive copies when needed
- Item 51: Design method signatures carefully
- Item 52: Use overloading judiciously
- Item 53: Use varargs judiciously
- Item 54: Return empty collections or arrays, not nulls
- Item 55: Return optionals judiciously
- Item 56: Write doc comments for all exposed API elements

**Chapter 9 — General Programming**

- Item 57: Minimize the scope of local variables
- Item 58: Prefer for-each loops to traditional for loops
- Item 59: Know and use the libraries
- Item 60: Avoid float and double if exact answers are required
- Item 61: Prefer primitive types to boxed primitives
- Item 62: Avoid strings where other types are more appropriate
- Item 63: Beware the performance of string concatenation
- Item 64: Refer to objects by their interfaces
- Item 65: Prefer interfaces to reflection
- Item 66: Use native methods judiciously
- Item 67: Optimize judiciously
- Item 68: Adhere to generally accepted naming conventions

**Chapter 10 — Exceptions**

- Item 69: Use exceptions only for exceptional conditions
- Item 70: Use checked exceptions for recoverable conditions and runtime exceptions for programming errors
- Item 71: Avoid unnecessary use of checked exceptions
- Item 72: Favor the use of standard exceptions
- Item 73: Throw exceptions appropriate to the abstraction
- Item 74: Document all exceptions thrown by each method
- Item 75: Include failure-capture information in detail messages
- Item 76: Strive for failure atomicity
- Item 77: Don't ignore exceptions

**Chapter 11 — Concurrency**

- Item 78: Synchronize access to shared mutable data
- Item 79: Avoid excessive synchronization
- Item 80: Prefer executors, tasks, and streams to threads
- Item 81: Prefer concurrency utilities to wait and notify
- Item 82: Document thread safety
- Item 83: Use lazy initialization judiciously
- Item 84: Don't depend on the thread scheduler

**Chapter 12 — Serialization**

- Item 85: Prefer alternatives to Java serialization
- Item 86: Implement Serializable with great caution
- Item 87: Consider using a custom serialized form
- Item 88: Write readObject methods defensively
- Item 89: For instance control, prefer enum types to readResolve
- Item 90: Consider serialization proxies instead of serialized instances

---

## Chapter 2 — Creating and Destroying Objects

### Item 1: Consider static factory methods instead of constructors

Title: Provide static factories that have descriptive names, can cache instances, and can return subtypes.
Description: Unlike constructors, static factory methods have names (clarifying intent), are not required to create a new object on each call (enabling instance control / caching), and can return any subtype of their return type (enabling flexible, implementation-hiding APIs such as service-provider frameworks). Common names: `from`, `of`, `valueOf`, `instance`, `getInstance`, `create`, `newInstance`.

**Good example:**

```java
public static Boolean valueOf(boolean b) {
    return b ? Boolean.TRUE : Boolean.FALSE; // never allocates a new Boolean
}

// Descriptive name conveys intent; can return a cached or subtype instance
public static BigInteger probablePrime(int bitLength, Random rnd) { ... }
```

**Bad example:**

```java
// Constructor name says nothing about what kind of object you get,
// and is forced to allocate a new instance on every call.
Boolean b = new Boolean(true);  // deprecated, wasteful
```

### Item 2: Consider a builder when faced with many constructor parameters

Title: Use the Builder pattern for classes with many optional parameters.
Description: Telescoping constructors are hard to read and write; the JavaBeans pattern leaves objects in inconsistent, mutable states. A builder simulates named optional parameters, is readable, and can build immutable objects. Validate invariants in `build()`.

**Good example:**

```java
public class NutritionFacts {
    private final int servingSize, servings, calories, fat, sodium, carbohydrate;

    public static class Builder {
        private final int servingSize, servings;            // required
        private int calories = 0, fat = 0, sodium = 0, carbohydrate = 0; // optional

        public Builder(int servingSize, int servings) {
            this.servingSize = servingSize; this.servings = servings;
        }
        public Builder calories(int v)      { calories = v;     return this; }
        public Builder fat(int v)           { fat = v;          return this; }
        public Builder sodium(int v)        { sodium = v;       return this; }
        public Builder carbohydrate(int v)  { carbohydrate = v; return this; }
        public NutritionFacts build()       { return new NutritionFacts(this); }
    }
    private NutritionFacts(Builder b) {
        servingSize = b.servingSize; servings = b.servings; calories = b.calories;
        fat = b.fat; sodium = b.sodium; carbohydrate = b.carbohydrate;
    }
}

NutritionFacts cola = new NutritionFacts.Builder(240, 8)
        .calories(100).sodium(35).carbohydrate(27).build();
```

**Bad example:**

```java
// Telescoping constructors: unreadable at the call site, easy to transpose arguments.
NutritionFacts cola = new NutritionFacts(240, 8, 100, 0, 35, 27);
```

### Item 3: Enforce the singleton property with a private constructor or an enum type

Title: A single-element enum is the best way to implement a singleton.
Description: Enum singletons are concise, provide serialization for free, and guarantee against multiple instantiation, even in the face of reflection or serialization attacks.

**Good example:**

```java
public enum Elvis {
    INSTANCE;
    public void leaveTheBuilding() { ... }
}
```

**Bad example:**

```java
// public static final field or static factory — vulnerable to reflection
// (setAccessible) and requires readResolve plus transient fields to keep
// the singleton property across serialization (Item 89).
public class Elvis {
    public static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
}
```

### Item 4: Enforce noninstantiability with a private constructor

Title: Make utility classes noninstantiable with a private constructor that throws.
Description: A class of static methods/fields should never be instantiated. An explicit private constructor (that throws) prevents both external instantiation and accidental subclassing.

**Good example:**

```java
public class UtilityClass {
    // Suppress default constructor for noninstantiability
    private UtilityClass() {
        throw new AssertionError();
    }
    public static int sum(int a, int b) { return a + b; }
}
```

**Bad example:**

```java
public class UtilityClass {
    // No constructor → the compiler supplies a public default one;
    // the class can be instantiated and subclassed.
    public static int sum(int a, int b) { return a + b; }
}
```

### Item 5: Prefer dependency injection to hardwiring resources

Title: Pass resources into the constructor instead of hardwiring them.
Description: Classes that depend on configurable resources should not create or specify those resources themselves. Inject the dependency, which improves flexibility, reusability, and testability.

**Good example:**

```java
public class SpellChecker {
    private final Lexicon dictionary;
    public SpellChecker(Lexicon dictionary) {           // injected
        this.dictionary = Objects.requireNonNull(dictionary);
    }
    public boolean isValid(String word) { ... }
}
```

**Bad example:**

```java
// Hardwired single dictionary; cannot swap for tests or other languages.
public class SpellChecker {
    private static final Lexicon dictionary = new KoreanDictionary();
    private SpellChecker() {}
    public static boolean isValid(String word) { ... }
}
```

### Item 6: Avoid creating unnecessary objects

Title: Reuse expensive immutable objects; beware autoboxing.
Description: Don't create a new object when an equivalent one can be reused. Hoist costly creations (e.g., a compiled `Pattern`) into a constant. Prefer primitives over boxed primitives to avoid hidden allocations.

**Good example:**

```java
public class RomanNumerals {
    private static final Pattern ROMAN = Pattern.compile(
        "^(?=.)M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");
    static boolean isRomanNumeral(String s) { return ROMAN.matcher(s).matches(); }
}
```

**Bad example:**

```java
static boolean isRomanNumeral(String s) {
    // Recompiles the Pattern on every call; also String.matches is costly.
    return s.matches("^(?=.)M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");
}

// Autoboxing: sum is Long, so 2^31 needless Long instances are created.
Long sum = 0L;
for (long i = 0; i <= Integer.MAX_VALUE; i++) sum += i;
```

### Item 7: Eliminate obsolete object references

Title: Null out references that are no longer needed to prevent memory leaks.
Description: A class that manages its own memory (e.g., a stack, cache, or listener registry) can leak objects whose references it retains. Null out obsolete references; prefer scoping a variable so it falls out of scope, or use `WeakHashMap` for caches keyed by lifetime.

**Good example:**

```java
public Object pop() {
    if (size == 0) throw new EmptyStackException();
    Object result = elements[--size];
    elements[size] = null; // Eliminate obsolete reference
    return result;
}
```

**Bad example:**

```java
public Object pop() {
    if (size == 0) throw new EmptyStackException();
    return elements[--size]; // elements[size] still holds the popped object → leak
}
```

### Item 8: Avoid finalizers and cleaners

Title: Don't rely on finalizers or cleaners; use `AutoCloseable`.
Description: Finalizers are unpredictable, dangerous, and slow; cleaners are better but still unpredictable. Make resource-holding classes implement `AutoCloseable` and require clients to `close()` (ideally via try-with-resources). A cleaner may serve only as a safety net or for native peers.

**Good example:**

```java
public class Room implements AutoCloseable {
    private static final Cleaner cleaner = Cleaner.create();
    private static class State implements Runnable {
        int numJunkPiles;
        State(int n) { numJunkPiles = n; }
        @Override public void run() { numJunkPiles = 0; } // cleanup action
    }
    private final State state;
    private final Cleaner.Cleanable cleanable;
    public Room(int n) { state = new State(n); cleanable = cleaner.register(this, state); }
    @Override public void close() { cleanable.clean(); } // deterministic cleanup
}
```

**Bad example:**

```java
public class FileResource {
    @Override protected void finalize() throws Throwable {
        // May never run, runs on an unspecified thread, hurts performance,
        // and can resurrect objects. Never rely on this.
        closeTheFile();
    }
}
```

### Item 9: Prefer try-with-resources to try-finally

Title: Use try-with-resources for any `AutoCloseable` resource.
Description: Nested try-finally blocks are verbose and can hide the original exception when `close()` also throws. Try-with-resources is shorter, closes resources automatically, and suppresses (rather than masks) secondary exceptions.

**Good example:**

```java
static String firstLineOfFile(String path) throws IOException {
    try (BufferedReader br = new BufferedReader(new FileReader(path))) {
        return br.readLine();
    }
}
```

**Bad example:**

```java
static String firstLineOfFile(String path) throws IOException {
    BufferedReader br = new BufferedReader(new FileReader(path));
    try {
        return br.readLine(); // if this throws AND close() throws, close()'s
    } finally {              // exception masks the readLine() exception
        br.close();
    }
}
```

---

## Chapter 3 — Methods Common to All Objects

### Item 10: Obey the general contract when overriding equals

Title: `equals` must be reflexive, symmetric, transitive, consistent, and non-null.
Description: Override `equals` only when a class has a notion of logical equality not already provided. Follow the recipe: `==` self-check, `instanceof` type-check, cast, then compare significant fields. There is no way to extend an instantiable class with a value component and preserve the `equals` contract — favor composition (Item 18).

**Good example:**

```java
@Override public boolean equals(Object o) {
    if (o == this) return true;
    if (!(o instanceof PhoneNumber)) return false;
    PhoneNumber pn = (PhoneNumber) o;
    return pn.lineNum == lineNum && pn.prefix == prefix && pn.areaCode == areaCode;
}
```

**Bad example:**

```java
// Breaks symmetry: a CaseInsensitiveString equals a String, but not vice versa.
@Override public boolean equals(Object o) {
    if (o instanceof CaseInsensitiveString)
        return s.equalsIgnoreCase(((CaseInsensitiveString) o).s);
    if (o instanceof String)                       // one-way interoperability!
        return s.equalsIgnoreCase((String) o);
    return false;
}
```

### Item 11: Always override hashCode when you override equals

Title: Equal objects must have equal hash codes.
Description: Failing to override `hashCode` breaks hash-based collections (`HashMap`, `HashSet`). Use the recipe: start with a significant field's hash, then `result = 31 * result + c` for each remaining significant field. Don't exclude significant fields; don't use a constant.

**Good example:**

```java
@Override public int hashCode() {
    int result = Short.hashCode(areaCode);
    result = 31 * result + Short.hashCode(prefix);
    result = 31 * result + Short.hashCode(lineNum);
    return result;
}
// Or, when performance is non-critical:
@Override public int hashCode() { return Objects.hash(areaCode, prefix, lineNum); }
```

**Bad example:**

```java
@Override public int hashCode() { return 42; } // legal but disastrous:
// every object hashes to the same bucket → HashMap degrades to O(n).
```

### Item 12: Always override toString

Title: Provide a good, informative `toString`.
Description: A useful `toString` makes a class pleasant to use and eases debugging/logging. Return all interesting info, document the format (or document that it may change), and provide programmatic accessors for the data in the string so callers don't parse it.

**Good example:**

```java
@Override public String toString() {
    return String.format("%03d-%03d-%04d", areaCode, prefix, lineNum);
}
public short getAreaCode() { return areaCode; } // accessor, so callers don't parse toString
```

**Bad example:**

```java
// Default Object.toString: "PhoneNumber@163b91" — useless in logs and assertions.
// (i.e., no override at all)
```

### Item 13: Override clone judiciously

Title: Prefer copy constructors/factories to `Cloneable`.
Description: `Cloneable` is broken: it creates objects without calling a constructor, and proper deep-copy clones are tricky (recursively clone mutable internals; never let `clone` rely on overridable methods). Prefer a copy constructor or copy factory instead.

**Good example:**

```java
// Copy constructor: simpler, type-safe, no checked exceptions, no Cloneable.
public Yum(Yum yum) { ... }
// Conversion constructor for an interface-based copy:
public TreeSet(Collection<? extends E> c) { ... }
```

**Bad example:**

```java
@Override public Stack clone() {
    try {
        Stack result = (Stack) super.clone();
        // FORGOT to deep-copy: result.elements shares the array with the original!
        return result;
    } catch (CloneNotSupportedException e) { throw new AssertionError(); }
}
```

### Item 14: Consider implementing Comparable

Title: Implement `Comparable` for value classes with a natural ordering.
Description: Implementing `Comparable` lets instances work with sorting, searching, and ordered collections. Honor the contract (sign-symmetric, transitive, consistent; recommended consistent with `equals`). Use `Comparator` construction methods or compare integral fields with `Integer.compare`; never use subtraction-based comparators (overflow).

**Good example:**

```java
private static final Comparator<PhoneNumber> COMPARATOR =
    comparingInt((PhoneNumber pn) -> pn.areaCode)
        .thenComparingInt(pn -> pn.prefix)
        .thenComparingInt(pn -> pn.lineNum);

@Override public int compareTo(PhoneNumber pn) { return COMPARATOR.compare(this, pn); }
```

**Bad example:**

```java
// Subtraction-based comparator: integer overflow can flip the sign → broken order.
static Comparator<Object> hashCodeOrder = (o1, o2) -> o1.hashCode() - o2.hashCode();
```

---

## Chapter 4 — Classes and Interfaces

### Item 15: Minimize the accessibility of classes and members

Title: Make each class and member as inaccessible as possible.
Description: Information hiding decouples components. Use the most restrictive access modifier that works. Instance fields of public classes should rarely be public; never expose a public mutable field or a public `static final` array (return a copy or an unmodifiable list instead).

**Good example:**

```java
private static final Thing[] PRIVATE_VALUES = { ... };
public static final List<Thing> VALUES =
    Collections.unmodifiableList(Arrays.asList(PRIVATE_VALUES)); // safe, immutable view
```

**Bad example:**

```java
// A public mutable array constant: any client can replace its contents → security hole.
public static final Thing[] VALUES = { ... };
```

### Item 16: In public classes, use accessor methods, not public fields

Title: Public classes should expose private fields through accessors.
Description: Exposing public fields forecloses changing the representation, enforcing invariants, or taking action on access. Package-private or private nested classes may expose fields if it simplifies code, since their representation can still change freely.

**Good example:**

```java
public class Point {
    private double x, y;
    public Point(double x, double y) { this.x = x; this.y = y; }
    public double getX() { return x; } public double getY() { return y; }
    public void setX(double x) { this.x = x; } public void setY(double y) { this.y = y; }
}
```

**Bad example:**

```java
public class Point { public double x; public double y; } // representation locked forever
```

### Item 17: Minimize mutability

Title: Make classes immutable unless there is a good reason not to.
Description: Immutable objects are simple, thread-safe, and freely shareable. Rules: no mutators; the class is final (or use static factories with a private constructor); all fields `private final`; ensure exclusive access to mutable components (defensive copies). Return new instances from operations (functional approach).

**Good example:**

```java
public final class Complex {
    private final double re, im;
    public Complex(double re, double im) { this.re = re; this.im = im; }
    public Complex plus(Complex c) { return new Complex(re + c.re, im + c.im); } // returns new
    public double realPart() { return re; }
}
```

**Bad example:**

```java
public final class Complex {
    private double re, im;
    public void addInPlace(Complex c) { re += c.re; im += c.im; } // mutates → not shareable/thread-safe
}
```

### Item 18: Favor composition over inheritance

Title: Prefer composition + forwarding to implementation inheritance.
Description: Inheritance across package boundaries is fragile: subclasses depend on superclass implementation details (e.g., self-use), which can break across releases. Wrap the original class in a forwarding class (decorator) instead.

**Good example:**

```java
public class InstrumentedSet<E> extends ForwardingSet<E> { // composition via forwarding
    private int addCount = 0;
    public InstrumentedSet(Set<E> s) { super(s); }
    @Override public boolean add(E e) { addCount++; return super.add(e); }
    @Override public boolean addAll(Collection<? extends E> c) { addCount += c.size(); return super.addAll(c); }
    public int getAddCount() { return addCount; }
}
public class ForwardingSet<E> implements Set<E> {
    private final Set<E> s;
    public ForwardingSet(Set<E> s) { this.s = s; }
    public boolean add(E e) { return s.add(e); }
    public boolean addAll(Collection<? extends E> c) { return s.addAll(c); }
    // ... forward all other Set methods to s
}
```

**Bad example:**

```java
// Inheriting from HashSet: addAll() self-calls add(), so addCount is double-counted.
public class InstrumentedHashSet<E> extends HashSet<E> {
    private int addCount = 0;
    @Override public boolean add(E e) { addCount++; return super.add(e); }
    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size(); return super.addAll(c); // super.addAll calls add → counts twice
    }
}
```

### Item 19: Design and document for inheritance or else prohibit it

Title: Document self-use and beware of overridable methods in constructors; otherwise make the class final.
Description: A class designed for inheritance must document its self-use of overridable methods (`@implSpec`), provide judiciously chosen hooks, and never call an overridable method from its constructor (the override runs before the subclass is initialized). If not designed for inheritance, prohibit it (final, or private constructor + static factories).

**Good example:**

```java
public final class Sub { ... } // prohibits inheritance entirely

// Or: a constructor that calls only private/final/static methods is safe for subclassing.
public class Super {
    public Super() { /* no calls to overridable methods */ }
}
```

**Bad example:**

```java
public class Super {
    public Super() { overrideMe(); }       // calls overridable method from constructor
    public void overrideMe() { }
}
public final class Sub extends Super {
    private final Instant instant;
    Sub() { instant = Instant.now(); }
    @Override public void overrideMe() { System.out.println(instant); } // prints null!
}
```

### Item 20: Prefer interfaces to abstract classes

Title: Use interfaces (with default methods + a skeletal implementation) over abstract classes.
Description: Interfaces allow mixins and multiple inheritance of type, and let existing classes be retrofitted. Combine an interface with an `AbstractInterface` skeletal implementation (Template Method) to get the best of both: flexible type + reusable implementation.

**Good example:**

```java
public abstract class AbstractMapEntry<K,V> implements Map.Entry<K,V> {
    @Override public V setValue(V value) { throw new UnsupportedOperationException(); }
    @Override public boolean equals(Object o) {
        if (o == this) return true;
        if (!(o instanceof Map.Entry)) return false;
        Map.Entry<?,?> e = (Map.Entry<?,?>) o;
        return Objects.equals(e.getKey(), getKey()) && Objects.equals(e.getValue(), getValue());
    }
    @Override public int hashCode() {
        return Objects.hashCode(getKey()) ^ Objects.hashCode(getValue());
    }
}
```

**Bad example:**

```java
// Forcing all implementations to extend a single abstract class:
// a class that already has a superclass cannot use it (single inheritance).
public abstract class Collection<E> { /* should be an interface */ }
```

### Item 21: Design interfaces for posterity

Title: Don't rely on default methods to retrofit risky behavior into existing implementations.
Description: Default methods are injected into all existing implementations without their authors' knowledge; they may break invariants of classes that didn't expect them. Design interfaces carefully up front and test with multiple implementations before release.

**Good example:**

```java
// A default method that is genuinely safe across all reasonable implementations.
default boolean isEmpty() { return size() == 0; }
```

**Bad example:**

```java
// Collection.removeIf default broke SynchronizedCollection (Apache Commons):
// it iterates without holding the lock the wrapper expects → concurrent-modification bugs.
default boolean removeIf(Predicate<? super E> filter) {
    boolean removed = false;
    for (Iterator<E> it = iterator(); it.hasNext(); ) {
        if (filter.test(it.next())) { it.remove(); removed = true; }
    }
    return removed; // ignores subclass synchronization → unsafe for SynchronizedCollection
}
```

### Item 22: Use interfaces only to define types

Title: Don't use the constant interface antipattern.
Description: An interface should say what a client can do with instances of an implementing class. A "constant interface" (only `static final` fields) leaks an implementation detail into the type. Put constants in the relevant class, an enum, or a noninstantiable utility class.

**Good example:**

```java
public final class PhysicalConstants {
    private PhysicalConstants() {}
    public static final double AVOGADROS_NUMBER = 6.022_140_857e23;
    public static final double BOLTZMANN_CONST  = 1.380_648_52e-23;
}
// Usage: PhysicalConstants.AVOGADROS_NUMBER  (or static import)
```

**Bad example:**

```java
public interface PhysicalConstants {          // constant interface antipattern
    static final double AVOGADROS_NUMBER = 6.022_140_857e23;
}
// "implements PhysicalConstants" pollutes the class's exported API with constants.
```

### Item 23: Prefer class hierarchies to tagged classes

Title: Replace a tagged class with a class hierarchy.
Description: A "tagged" class with a `switch` on a type tag field is verbose, error-prone, and inefficient. Replace it with an abstract superclass and a subclass per flavor; the compiler enforces that each subclass supplies all data and behavior.

**Good example:**

```java
abstract class Figure { abstract double area(); }
class Circle extends Figure {
    final double radius;
    Circle(double radius) { this.radius = radius; }
    @Override double area() { return Math.PI * radius * radius; }
}
class Rectangle extends Figure {
    final double length, width;
    Rectangle(double length, double width) { this.length = length; this.width = width; }
    @Override double area() { return length * width; }
}
```

**Bad example:**

```java
class Figure {
    enum Shape { RECTANGLE, CIRCLE }
    final Shape shape;          // the tag
    double length, width;       // used only for RECTANGLE
    double radius;              // used only for CIRCLE
    double area() {
        switch (shape) {        // boilerplate switch, fields irrelevant to one shape
            case RECTANGLE: return length * width;
            case CIRCLE:    return Math.PI * radius * radius;
            default:        throw new AssertionError(shape);
        }
    }
}
```

### Item 24: Favor static member classes over nonstatic

Title: If a member class doesn't need an enclosing instance, make it `static`.
Description: A nonstatic member class holds a hidden reference to its enclosing instance (memory cost, possible leaks). Use a static member class unless each instance genuinely needs access to its enclosing instance (e.g., an adapter/view like `keySet`).

**Good example:**

```java
public class MyMap<K,V> {
    private static class Node<K,V> { K key; V value; Node<K,V> next; } // no enclosing ref needed
}
```

**Bad example:**

```java
public class MyMap<K,V> {
    private class Node { K key; V value; Node next; } // nonstatic: each Node pins a MyMap → leak/cost
}
```

### Item 25: Limit source files to a single top-level class

Title: One top-level class or interface per source file.
Description: Multiple top-level classes in one file makes behavior depend on compilation order and risks duplicate-definition errors. Keep one top-level type per file; use static member classes if you want to group helpers.

**Good example:**

```java
// Utensil.java
class Utensil { static final String NAME = "pan"; }
// Dessert.java
class Dessert { static final String NAME = "cake"; }
```

**Bad example:**

```java
// Two top-level classes in BOTH Main.java and Utensil.java → which definition wins
// depends on the order javac sees the files. Brittle and confusing.
// Utensil.java:
class Utensil { static final String NAME = "pan"; }
class Dessert { static final String NAME = "cake"; }
```

---

## Chapter 5 — Generics

### Item 26: Don't use raw types

Title: Use parameterized types, not raw types.
Description: Raw types (e.g., `List`) bypass generic type checking and defer `ClassCastException` to runtime. Use parameterized types for safety. Use `List<Object>` when you mean "any type," and unbounded wildcards `List<?>` when you don't care about the element type but want type safety.

**Good example:**

```java
private final Collection<Stamp> stamps = ...;   // compiler enforces Stamp elements
// Unbounded wildcard when the element type is unknown but safety matters:
static int numElementsInCommon(Set<?> s1, Set<?> s2) { ... }
```

**Bad example:**

```java
private final Collection stamps = ...;  // raw type
stamps.add(new Coin());                 // compiles! fails later with ClassCastException
```

### Item 27: Eliminate unchecked warnings

Title: Eliminate every unchecked warning you can; suppress the rest with a comment.
Description: Unchecked warnings flag potential `ClassCastException`s. Eliminate them where possible. When you can prove the code is typesafe, suppress with `@SuppressWarnings("unchecked")` on the **smallest possible scope**, and add a comment explaining why it's safe.

**Good example:**

```java
public <T> T[] toArray(T[] a) {
    if (a.length < size) {
        // This cast is correct because the array we create is of type T[]:
        @SuppressWarnings("unchecked")
        T[] result = (T[]) Arrays.copyOf(elements, size, a.getClass());
        return result;
    }
    ...
}
```

**Bad example:**

```java
@SuppressWarnings("unchecked")     // suppressing on the whole method hides future warnings
public Object doEverything() {
    List list = new ArrayList();    // raw type, the real problem, now silenced
    ...
}
```

### Item 28: Prefer lists to arrays

Title: Prefer generic lists to arrays.
Description: Arrays are covariant and reified; generics are invariant and erased. Mixing them yields warnings and runtime failures (`ArrayStoreException`). Lists give compile-time type safety. You cannot create `new E[]` — use `(E[]) new Object[]` with a justified suppression, or better, a `List<E>`.

**Good example:**

```java
public class Chooser<T> {
    private final List<T> choiceList;
    public Chooser(Collection<T> choices) { choiceList = new ArrayList<>(choices); }
    public T choose() { return choiceList.get(ThreadLocalRandom.current().nextInt(choiceList.size())); }
}
```

**Bad example:**

```java
// Covariant arrays defer type errors to runtime:
Object[] objs = new Long[1];
objs[0] = "I don't fit in"; // compiles, throws ArrayStoreException at runtime
```

### Item 29: Favor generic types

Title: Generify your own types instead of requiring casts in client code.
Description: Make classes generic so clients get type safety without casts. The internal `(E[]) new Object[]` cast is a common, justifiable idiom when the array is purely internal and never returned to clients.

**Good example:**

```java
public class Stack<E> {
    private E[] elements;
    private int size = 0;
    @SuppressWarnings("unchecked") // elements is internal-only; only Es are stored
    public Stack() { elements = (E[]) new Object[16]; }
    public void push(E e) { ensureCapacity(); elements[size++] = e; }
    public E pop() {
        if (size == 0) throw new EmptyStackException();
        E result = elements[--size];
        elements[size] = null;
        return result;
    }
}
```

**Bad example:**

```java
public class Stack {                 // works on Object → clients must cast on pop()
    private Object[] elements;
    public Object pop() { ... }      // (String) stack.pop() risks ClassCastException
}
```

### Item 30: Favor generic methods

Title: Write generic methods; use recursive type bounds where needed.
Description: Generic methods provide type safety and eliminate casts. Use the explicit type-parameter list before the return type. A generic singleton factory and recursive type bounds (`<E extends Comparable<E>>`) are common idioms.

**Good example:**

```java
public static <E> Set<E> union(Set<E> s1, Set<E> s2) {
    Set<E> result = new HashSet<>(s1);
    result.addAll(s2);
    return result;
}
// Recursive type bound:
public static <E extends Comparable<E>> E max(Collection<E> c) { ... }
```

**Bad example:**

```java
public static Set union(Set s1, Set s2) {   // raw types → unchecked warnings, no safety
    Set result = new HashSet(s1);
    result.addAll(s2);
    return result;
}
```

### Item 31: Use bounded wildcards to increase API flexibility

Title: PECS — Producer-Extends, Consumer-Super.
Description: Use `<? extends E>` for a parameter that **produces** E values, and `<? super E>` for a parameter that **consumes** E values. This makes APIs maximally flexible. Never use a wildcard as a return type. If a type parameter appears only once, replace it with a wildcard.

**Good example:**

```java
public void pushAll(Iterable<? extends E> src)      { for (E e : src) push(e); } // src produces E
public void popAll(Collection<? super E> dst)       { while (!isEmpty()) dst.add(pop()); } // dst consumes E
public static <E extends Comparable<? super E>> E max(List<? extends E> list) { ... }
```

**Bad example:**

```java
public void pushAll(Iterable<E> src) { ... }
// Stack<Number> s; Iterable<Integer> ints; s.pushAll(ints); // FAILS to compile
// even though Integer is a Number — invariance bites without the wildcard.
```

### Item 32: Combine generics and varargs judiciously

Title: Annotate safe generic varargs methods with `@SafeVarargs`; never store into or expose the array.
Description: Generic varargs create a parameterized array internally, risking heap pollution. A method is safe only if it doesn't store anything into the varargs array and doesn't let a reference to it escape. Mark such methods `@SafeVarargs`.

**Good example:**

```java
@SafeVarargs
static <T> List<T> flatten(List<? extends T>... lists) {
    List<T> result = new ArrayList<>();
    for (List<? extends T> list : lists) result.addAll(list); // only reads the array
    return result;
}
```

**Bad example:**

```java
static <T> T[] toArray(T... args) { return args; } // returns the varargs array → heap pollution
static <T> T[] pickTwo(T a, T b, T c) {
    switch (ThreadLocalRandom.current().nextInt(3)) {
        case 0: return toArray(a, b);  // returns Object[] disguised as T[]
    }
    throw new AssertionError();
}
// String[] attrs = pickTwo("a","b","c"); → ClassCastException at the call site
```

### Item 33: Consider typesafe heterogeneous containers

Title: Parameterize the key, not the container, for typesafe heterogeneous storage.
Description: When you need a container holding values of many different types safely, key the map on `Class<T>` (a type token) and use `type.cast(...)` to keep it type-safe at retrieval. Use `Class.asSubclass` for bounded type tokens.

**Good example:**

```java
public class Favorites {
    private Map<Class<?>, Object> favorites = new HashMap<>();
    public <T> void putFavorite(Class<T> type, T instance) {
        favorites.put(Objects.requireNonNull(type), type.cast(instance)); // dynamic safety
    }
    public <T> T getFavorite(Class<T> type) { return type.cast(favorites.get(type)); }
}
Favorites f = new Favorites();
f.putFavorite(String.class, "Java");
f.putFavorite(Integer.class, 42);
String s = f.getFavorite(String.class);   // no cast at call site, fully typesafe
```

**Bad example:**

```java
Map<String, Object> props = new HashMap<>();
props.put("count", 42);
String c = (String) props.get("count");   // unchecked cast → ClassCastException at runtime
```

---

## Chapter 6 — Enums and Annotations

### Item 34: Use enums instead of int constants

Title: Replace `int` constant groups with enum types.
Description: The `int` enum pattern is unsafe and unprintable. Real enums are typesafe, namespaced, printable, and can carry data and behavior (constant-specific method implementations). Use a `switch`-free, per-constant-method strategy for behavior that varies by constant.

**Good example:**

```java
public enum Operation {
    PLUS("+")  { public double apply(double x, double y) { return x + y; } },
    MINUS("-") { public double apply(double x, double y) { return x - y; } },
    TIMES("*") { public double apply(double x, double y) { return x * y; } },
    DIVIDE("/"){ public double apply(double x, double y) { return x / y; } };
    private final String symbol;
    Operation(String symbol) { this.symbol = symbol; }
    public abstract double apply(double x, double y);
    @Override public String toString() { return symbol; }
}
```

**Bad example:**

```java
public static final int APPLE_FUJI = 0;     // int enum pattern: no type safety,
public static final int ORANGE_NAVEL = 0;   // APPLE_FUJI == ORANGE_NAVEL compiles and is true,
// and prints as a meaningless 0.
```

### Item 35: Use instance fields instead of ordinals

Title: Never derive a value from `ordinal()`.
Description: `ordinal()` is meant for `EnumSet`/`EnumMap`, not for client logic. Deriving values from it breaks if constants are reordered or a gap is needed. Store the value in an instance field.

**Good example:**

```java
public enum Ensemble {
    SOLO(1), DUET(2), TRIO(3), QUARTET(4), QUINTET(5);
    private final int numberOfMusicians;
    Ensemble(int size) { this.numberOfMusicians = size; }
    public int numberOfMusicians() { return numberOfMusicians; }
}
```

**Bad example:**

```java
public enum Ensemble {
    SOLO, DUET, TRIO, QUARTET, QUINTET;
    public int numberOfMusicians() { return ordinal() + 1; } // breaks on reorder / gaps
}
```

### Item 36: Use EnumSet instead of bit fields

Title: Use `EnumSet` instead of `int` bit-flag fields.
Description: Bit fields have all the problems of int enums plus poor printability and awkward iteration. `EnumSet` is compact (a single long internally for ≤64 constants), typesafe, and expressive.

**Good example:**

```java
public class Text {
    public enum Style { BOLD, ITALIC, UNDERLINE, STRIKETHROUGH }
    public void applyStyles(Set<Style> styles) { ... } // accept Set for flexibility
}
text.applyStyles(EnumSet.of(Style.BOLD, Style.ITALIC));
```

**Bad example:**

```java
public class Text {
    public static final int STYLE_BOLD = 1 << 0;
    public static final int STYLE_ITALIC = 1 << 1;
    public void applyStyles(int styles) { ... } // bitwise OR, unprintable, untyped
}
text.applyStyles(STYLE_BOLD | STYLE_ITALIC);
```

### Item 37: Use EnumMap instead of ordinal indexing

Title: Use `EnumMap` to associate data with enum constants.
Description: Indexing arrays by `ordinal()` is unsafe, requires unchecked casts, and risks `ArrayIndexOutOfBounds`. `EnumMap` gives the same performance with type safety and clarity. Use nested `EnumMap`s for two-dimensional relationships.

**Good example:**

```java
Map<Plant.LifeCycle, Set<Plant>> plantsByLifeCycle = new EnumMap<>(Plant.LifeCycle.class);
for (Plant.LifeCycle lc : Plant.LifeCycle.values())
    plantsByLifeCycle.put(lc, new HashSet<>());
for (Plant p : garden) plantsByLifeCycle.get(p.lifeCycle).add(p);
```

**Bad example:**

```java
@SuppressWarnings("unchecked")
Set<Plant>[] plantsByLifeCycle = (Set<Plant>[]) new Set[Plant.LifeCycle.values().length];
for (Plant p : garden) plantsByLifeCycle[p.lifeCycle.ordinal()].add(p); // unsafe ordinal index
```

### Item 38: Emulate extensible enums with interfaces

Title: Make enums implement an interface to allow client-defined extensions.
Description: Enums can't be extended, but you can let users write their own enum that implements a shared interface, so all "operations" (built-in and custom) are interoperable through the interface type.

**Good example:**

```java
public interface Operation { double apply(double x, double y); }
public enum BasicOperation implements Operation {
    PLUS { public double apply(double x, double y) { return x + y; } },
    MINUS { public double apply(double x, double y) { return x - y; } };
}
// Clients add their own:
public enum ExtendedOperation implements Operation {
    EXP { public double apply(double x, double y) { return Math.pow(x, y); } };
}
```

**Bad example:**

```java
// Trying to "extend" an enum directly is illegal:
public enum ExtendedOperation extends BasicOperation { ... } // does not compile
```

### Item 39: Prefer annotations to naming patterns

Title: Use annotations instead of naming conventions to mark program elements.
Description: Naming patterns (e.g., methods that start with `test`) are fragile: typos silently disable behavior, and they can't carry parameters or be limited to the right element. Annotations are typesafe and toolable.

**Good example:**

```java
@Retention(RetentionPolicy.RUNTIME) @Target(ElementType.METHOD)
public @interface Test { }

public class Sample {
    @Test public static void m1() { } // explicitly marked; a typo is a compile error
}
// A test runner uses reflection: method.isAnnotationPresent(Test.class)
```

**Bad example:**

```java
public class Sample {
    public static void tsetSafetyOverride() { } // typo: "tset" → silently never run by a
                                                // name-pattern runner expecting "test*"
}
```

### Item 40: Consistently use the Override annotation

Title: Put `@Override` on every method that overrides a supertype method.
Description: `@Override` lets the compiler catch the common mistake of accidentally *overloading* instead of overriding (wrong parameter type/signature). Use it everywhere except when overriding an abstract method (where the compiler already enforces it).

**Good example:**

```java
@Override public boolean equals(Object o) {        // correct signature, compiler-checked
    if (!(o instanceof Bigram)) return false;
    Bigram b = (Bigram) o;
    return b.first == first && b.second == second;
}
```

**Bad example:**

```java
public boolean equals(Bigram b) {   // overloads Object.equals, doesn't override it!
    return b.first == first && b.second == second; // Set<Bigram> behaves wrong; @Override would have caught it
}
```

### Item 41: Use marker interfaces to define types

Title: Prefer marker interfaces to marker annotations when you want to define a type.
Description: A marker interface (e.g., `Serializable`) defines a type implemented by marked classes, enabling compile-time checking and method signatures that require the marker. Use a marker annotation when marking non-class elements or when working in an annotation-heavy framework.

**Good example:**

```java
public interface Serializable { } // marker interface → defines a type
// A method can require the marker at compile time:
public static <T extends Serializable> void writeObject(T obj) { ... }
```

**Bad example:**

```java
@interface MySerializable { }     // marker annotation: cannot be used as a type bound,
                                  // so the compiler can't enforce "only marked types here".
public static void writeObject(Object obj) { ... } // type safety lost
```

---

## Chapter 7 — Lambdas and Streams

### Item 42: Prefer lambdas to anonymous classes

Title: Use lambdas for function objects; reserve anonymous classes for when you need `this` or state.
Description: Lambdas are far more concise than anonymous classes for functional interfaces. Keep them short (one to three lines) and self-documenting. A lambda's `this` refers to the enclosing instance; an anonymous class's `this` refers to the anonymous instance. Lambdas can't replace abstract classes or interfaces with multiple abstract methods.

**Good example:**

```java
Collections.sort(words, (s1, s2) -> Integer.compare(s1.length(), s2.length()));
// Even better with a comparator construction method (Item 43):
words.sort(comparingInt(String::length));
```

**Bad example:**

```java
Collections.sort(words, new Comparator<String>() {   // verbose boilerplate
    public int compare(String s1, String s2) {
        return Integer.compare(s1.length(), s2.length());
    }
});
```

### Item 43: Prefer method references to lambdas

Title: Use a method reference where it is clearer than the equivalent lambda.
Description: Method references are usually more succinct than lambdas. The five kinds: static (`Integer::parseInt`), bound (`instance::method`), unbound (`String::toLowerCase`), class constructor (`TreeMap::new`), and array constructor (`int[]::new`). But keep a lambda if it's clearer (e.g., when the method name is long or the lambda's parameters document intent).

**Good example:**

```java
map.merge(key, 1, Integer::sum);                    // method reference, clear
List<String> upper = strings.stream().map(String::toUpperCase).collect(toList());
```

**Bad example:**

```java
map.merge(key, 1, (count, incr) -> count + incr);   // lambda is noisier than Integer::sum
// (Method reference is preferred here; but prefer the lambda when it reads better.)
```

### Item 44: Favor the use of standard functional interfaces

Title: Use the standard `java.util.function` interfaces instead of writing your own.
Description: The 43 standard functional interfaces cover most needs. The six basic ones: `UnaryOperator<T>`, `BinaryOperator<T>`, `Predicate<T>`, `Function<T,R>`, `Supplier<T>`, `Consumer<T>`. Use primitive specializations (`IntPredicate`, etc.) to avoid boxing. Write a custom functional interface only when none fits and it earns its keep (with `@FunctionalInterface`).

**Good example:**

```java
// Standard interface fits exactly — don't reinvent it.
Map<K,V> cache = new LinkedHashMap<>() {
    @Override protected boolean removeEldestEntry(Map.Entry<K,V> eldest) {
        return size() > 100;
    }
};
// A genuinely custom contract (descriptive name, can't be confused with BiPredicate):
@FunctionalInterface interface EldestEntryRemovalFunction<K,V> {
    boolean remove(Map<K,V> map, Map.Entry<K,V> eldest);
}
```

**Bad example:**

```java
// Re-declaring something that already exists as Predicate<String>:
@FunctionalInterface interface StringChecker { boolean check(String s); } // needless
```

### Item 45: Use streams judiciously

Title: Use streams where they clarify, not everywhere.
Description: Streams shine for transformation pipelines but obscure code when overused. Avoid overlong pipelines; use helper methods and good lambda parameter names. Some things lambdas can't do that loop code can: read/modify local variables, `break`/`continue`/`return`, throw checked exceptions. Refactor to streams only when the result is more readable.

**Good example:**

```java
// Readable pipeline with a helper for the key.
Map<String, List<String>> groups = words.stream()
        .collect(groupingBy(word -> alphabetize(word)));
groups.values().stream()
        .filter(group -> group.size() >= minGroupSize)
        .forEach(g -> System.out.println(g.size() + ": " + g));
```

**Bad example:**

```java
// "Stream golf": one giant pipeline doing char arithmetic inline — unreadable.
words.collect(groupingBy(word -> word.chars().sorted()
        .collect(StringBuilder::new, (sb,c)->sb.append((char)c), StringBuilder::append).toString()))
     .values().stream().filter(g -> g.size() >= minGroupSize).map(g -> g.size()+": "+g)
     .forEach(System.out::println);
```

### Item 46: Prefer side-effect-free functions in streams

Title: A stream pipeline's function objects should be pure; do work in collectors, not `forEach`.
Description: Use `forEach` only to report results, never to mutate state — that's not functional and defeats the streams paradigm. Express computation with collectors: `toList`, `toSet`, `toMap`, `groupingBy`, `joining`, `counting`, etc.

**Good example:**

```java
Map<String, Long> freq = words.stream()
        .collect(groupingBy(String::toLowerCase, counting())); // pure, declarative
```

**Bad example:**

```java
Map<String, Long> freq = new HashMap<>();
words.forEach(word ->                       // forEach mutating external state = a for-loop in disguise
    freq.merge(word.toLowerCase(), 1L, Long::sum));
```

### Item 47: Prefer Collection to Stream as a return type

Title: Return `Collection` (or a subtype) for a public sequence-returning method.
Description: `Stream` doesn't extend `Iterable`, so a `Stream`-returning method is awkward for for-each users; a `Collection`-returning method serves both stream and iteration clients. For large/infinite sequences, return a custom `AbstractList` (e.g., a power set) rather than materializing everything.

**Good example:**

```java
// Returns a Collection so callers can both iterate and stream.
public static List<String> getLines(Path path) throws IOException {
    return Files.readAllLines(path);
}
```

**Bad example:**

```java
public static Stream<String> getLines(Path path) throws IOException {
    return Files.lines(path);            // for-each users must adapt: (Iterable<String>) s::iterator
}
```

### Item 48: Use caution when making streams parallel

Title: Parallelize a stream only when measurement proves it helps.
Description: `parallel()` can cause liveness/safety failures and is rarely beneficial. It helps mostly for `ArrayList`, `HashMap`, arrays, and `int`/`long` ranges (easily splittable, good locality) with cheap-to-combine terminal ops (`reduce`, `count`, `anyMatch`). Never parallelize without a performance test on the target hardware.

**Good example:**

```java
// CPU-bound, splittable source, associative reduction — measure, then parallelize.
static long pi(long n) {
    return LongStream.rangeClosed(2, n).parallel()
            .mapToObj(BigInteger::valueOf).filter(i -> i.isProbablePrime(50)).count();
}
```

**Bad example:**

```java
// Parallelizing an iterate()/limit() pipeline: not splittable → can run slower or hang.
Stream.iterate(TWO, BigInteger::nextProbablePrime).parallel().limit(20).forEach(System.out::println);
```

---

## Chapter 8 — Methods

### Item 49: Check parameters for validity

Title: Validate parameters at the start of a method and document the constraints.
Description: Fail fast and cleanly. Document parameter restrictions with `@throws` and enforce them with explicit checks. Use `Objects.requireNonNull` for null checks, and `Objects.checkIndex`/`checkFromIndexSize` for ranges. For private methods, use assertions.

**Good example:**

```java
/**
 * @param m the modulus, which must be positive
 * @throws ArithmeticException if m <= 0
 */
public BigInteger mod(BigInteger m) {
    if (m.signum() <= 0) throw new ArithmeticException("Modulus <= 0: " + m);
    ...
}
this.strategy = Objects.requireNonNull(strategy, "strategy"); // null check + message
```

**Bad example:**

```java
public BigInteger mod(BigInteger m) {
    return this.remainder(m); // no check: a bad m fails deep inside with a confusing exception
}
```

### Item 50: Make defensive copies when needed

Title: Copy mutable parameters and return values to preserve invariants.
Description: If a class holds mutable components supplied by or returned to clients, copy them. Copy parameters **before** validating (to thwart TOCTOU attacks), and don't use `clone` on a type that can be subclassed maliciously. Return copies from accessors of mutable internals.

**Good example:**

```java
public Period(Date start, Date end) {
    this.start = new Date(start.getTime());   // defensive copy BEFORE the check
    this.end   = new Date(end.getTime());
    if (this.start.compareTo(this.end) > 0)
        throw new IllegalArgumentException(this.start + " after " + this.end);
}
public Date start() { return new Date(start.getTime()); } // copy on the way out
```

**Bad example:**

```java
public Period(Date start, Date end) {
    this.start = start;   // stores the caller's mutable Date directly
    this.end   = end;     // caller can later call end.setYear(...) and break the invariant
}
public Date end() { return end; } // hands out the internal mutable Date
```

### Item 51: Design method signatures carefully

Title: Choose method names well; avoid long parameter lists; prefer interfaces and enums for parameter types.
Description: Follow naming conventions; don't go overboard adding convenience methods. Keep parameter lists short (≤ 4); shorten via helper types, builders, or splitting methods. Prefer interface types (e.g., `Map`) over classes (`HashMap`) for parameters, and two-element enums over `boolean` when it aids readability.

**Good example:**

```java
public void process(Map<String, Integer> counts) { ... }  // interface parameter type
public enum TemperatureScale { FAHRENHEIT, CELSIUS }
Thermometer.newInstance(TemperatureScale.CELSIUS);        // clearer than a boolean
```

**Bad example:**

```java
public void process(HashMap<String, Integer> counts) { } // ties callers to HashMap
Thermometer.newInstance(true);                           // what does "true" mean?
```

### Item 52: Use overloading judiciously

Title: Overloading is resolved at compile time by static type; avoid confusing overloads.
Description: Selection among overloadings is static (unlike overriding, which is dynamic). Avoid two overloadings with the same parameter count where an argument could belong to either. When in doubt, give methods different names (e.g., `readInt`, `readLong`).

**Good example:**

```java
// Distinct names eliminate ambiguity entirely.
public void writeBoolean(boolean b) { ... }
public void writeInt(int i)         { ... }
public void writeLong(long l)       { ... }
```

**Bad example:**

```java
public static String classify(Set<?> s)        { return "Set"; }
public static String classify(List<?> s)       { return "List"; }
public static String classify(Collection<?> s) { return "Unknown Collection"; }
// For Collection<?>[] of {HashSet, ArrayList, HashMap.values()} this prints
// "Unknown Collection" THREE times — overload chosen by compile-time type, not runtime.
```

### Item 53: Use varargs judiciously

Title: Use varargs for variable-arity methods, but guard required arguments and watch performance.
Description: For methods needing ≥1 argument, take the first argument explicitly plus a varargs for the rest, so an empty call is a compile error rather than a runtime failure. Since every varargs call allocates an array, provide fixed-arity overloads for the common small cases if performance matters.

**Good example:**

```java
static int min(int firstArg, int... remainingArgs) {  // requires at least one arg, compile-checked
    int min = firstArg;
    for (int arg : remainingArgs) if (arg < min) min = arg;
    return min;
}
```

**Bad example:**

```java
static int min(int... args) {
    if (args.length == 0) throw new IllegalArgumentException("Too few"); // fails at RUNTIME
    int min = args[0];
    for (int i = 1; i < args.length; i++) if (args[i] < min) min = args[i];
    return min;
}
```

### Item 54: Return empty collections or arrays, not nulls

Title: Never return `null` in place of an empty collection or array.
Description: Returning `null` forces every caller to add special-case handling and invites NPEs. Return an empty collection/array. Reuse an immutable empty collection (`Collections.emptyList()`) or a shared zero-length array to avoid allocation.

**Good example:**

```java
private static final Cheese[] EMPTY_CHEESE_ARRAY = new Cheese[0];
public Cheese[] getCheeses() {
    return cheesesInStock.toArray(EMPTY_CHEESE_ARRAY); // never null; reuses empty array
}
public List<Cheese> getCheeseList() {
    return cheesesInStock.isEmpty() ? Collections.emptyList() : new ArrayList<>(cheesesInStock);
}
```

**Bad example:**

```java
public Cheese[] getCheeses() {
    return cheesesInStock.isEmpty() ? null : cheesesInStock.toArray(new Cheese[0]);
}
// Every caller must now write: if (cheeses != null && Arrays.asList(cheeses).contains(STILTON)) ...
```

### Item 55: Return optionals judiciously

Title: Use `Optional<T>` for methods that may have nothing to return — but not for collections, and never return `null` from one.
Description: `Optional` clearly signals "possibly absent" and forces the caller to consider it. Use `orElse`, `orElseGet`, `orElseThrow`, `isPresent`/`ifPresent`. Don't wrap collections/arrays/maps in optionals (return empty instead). Don't use `Optional` for boxed primitives (use `OptionalInt`, etc.), and rarely as a field, parameter, or map value.

**Good example:**

```java
public static <E extends Comparable<E>> Optional<E> max(Collection<E> c) {
    if (c.isEmpty()) return Optional.empty();
    E result = null;
    for (E e : c) if (result == null || e.compareTo(result) > 0) result = e;
    return Optional.of(result);
}
String best = max(words).orElse("No words"); // caller can't forget the empty case
```

**Bad example:**

```java
public Optional<List<String>> getRecords() { ... } // double-optional: return an empty List instead
Optional<E> max = ...;
E e = max.get();   // throws NoSuchElementException if empty → no safer than returning null
```

### Item 56: Write doc comments for all exposed API elements

Title: Document every exported class, interface, constructor, method, and field with Javadoc.
Description: Precede every exported API element with a doc comment. Method comments state the contract: a summary, `@param` for each parameter, `@return`, and `@throws` for each exception (checked and unchecked preconditions). Use `{@code}`, `{@literal}`, `{@implSpec}` for self-use, and `{@index}` as appropriate.

**Good example:**

```java
/**
 * Returns the element at the specified position in this list.
 *
 * @param index index of element to return; must be
 *        non-negative and less than the size of this list
 * @return the element at the specified position in this list
 * @throws IndexOutOfBoundsException if the index is out of range
 *         ({@code index < 0 || index >= this.size()})
 */
E get(int index);
```

**Bad example:**

```java
// gets a thing
E get(int index); // no @param/@return/@throws; says nothing about preconditions or failure modes
```

---

## Chapter 9 — General Programming

### Item 57: Minimize the scope of local variables

Title: Declare each local variable where it is first used, with an initializer.
Description: Narrow scope improves readability and reduces bugs. Declare variables at first use, prefer `for` loops over `while` (the loop variable's scope is the loop), and keep methods small and focused.

**Good example:**

```java
for (Iterator<Element> i = c.iterator(); i.hasNext(); ) {
    Element e = i.next();   // e is scoped to one iteration
    ...
}
```

**Bad example:**

```java
Iterator<Element> i = c.iterator();
while (i.hasNext()) { doSomething(i.next()); }
Iterator<Element> i2 = c2.iterator();
while (i.hasNext()) { doSomethingElse(i2.next()); } // copy-paste bug: reused i instead of i2
```

### Item 58: Prefer for-each loops to traditional for loops

Title: Use the for-each loop wherever you can.
Description: For-each (`for (E e : collection)`) eliminates index/iterator clutter and the bugs that come with them, with no performance penalty. It also handles nested iteration cleanly. You can't use it when you need to remove/replace elements via the iterator, or to traverse multiple collections in parallel by index.

**Good example:**

```java
for (Suit suit : suits)
    for (Rank rank : ranks)
        deck.add(new Card(suit, rank)); // correct nested iteration, no index bugs
```

**Bad example:**

```java
for (Iterator<Suit> i = suits.iterator(); i.hasNext(); )
    for (Iterator<Rank> j = ranks.iterator(); j.hasNext(); )
        deck.add(new Card(i.next(), j.next())); // i.next() called too often → NoSuchElementException
```

### Item 59: Know and use the libraries

Title: Use the standard libraries instead of reinventing them.
Description: Library code is written by experts, tested by the world, improves over time, and keeps your code concise. For example, use `ThreadLocalRandom` (or `SecureRandom`) instead of hand-rolled randomness; use `Files`, `Collections`, `Math`, `Arrays`, etc.

**Good example:**

```java
int random = ThreadLocalRandom.current().nextInt(n); // correct, fast, no bias
```

**Bad example:**

```java
static int random(int n) {           // common homegrown method, subtly broken
    return Math.abs(rnd.nextInt()) % n; // biased; and Math.abs(Integer.MIN_VALUE) is negative!
}
```

### Item 60: Avoid float and double if exact answers are required

Title: Use `BigDecimal`, `int`, or `long` for monetary and exact calculations.
Description: `float`/`double` are binary floating-point and can't represent decimal fractions exactly (e.g., `1.03 - 0.42 != 0.61`). For money, use `BigDecimal` (with an explicit rounding mode), or scale to the smallest unit and use `int`/`long`.

**Good example:**

```java
final BigDecimal TEN_CENTS = new BigDecimal(".10");
BigDecimal funds = new BigDecimal("1.00");
int itemsBought = 0;
for (BigDecimal price = TEN_CENTS; funds.compareTo(price) >= 0; price = price.add(TEN_CENTS)) {
    funds = funds.subtract(price); itemsBought++;
}
// itemsBought == 4, change == 0.00  (exact)
```

**Bad example:**

```java
double funds = 1.00;
for (double price = 0.10; funds >= price; price += 0.10) { funds -= price; }
// rounding errors leave funds = 0.3999999999999999 → wrong item count and leftover "change"
```

### Item 61: Prefer primitive types to boxed primitives

Title: Use primitives unless you need a boxed type; never mix them carelessly.
Description: `==` on boxed primitives compares identity, not value; auto-unboxing a `null` throws NPE; and boxing creates needless objects. Use boxed types only where required (collection elements, type parameters, reflection).

**Good example:**

```java
Comparator<Integer> cmp = (i, j) -> (i < j) ? -1 : (i == j ? 0 : 1);
// Even simpler and correct: Comparator.naturalOrder()
int i = first, j = second;            // unbox once, compare values
```

**Bad example:**

```java
Comparator<Integer> cmp = (i, j) -> (i < j) ? -1 : (i == j ? 0 : 1);
// When i and j are different Integer objects with equal values, i == j is FALSE
// (identity comparison) → cmp.compare(new Integer(42), new Integer(42)) returns 1.
```

### Item 62: Avoid strings where other types are more appropriate

Title: Don't overuse `String`; use the right type.
Description: Strings are poor substitutes for value types, enums, aggregates, and capabilities. Parsing and validating "stringly typed" data is slow and error-prone. Use proper types: numeric types for numbers, enums for fixed sets, classes/records for aggregates, and unforgeable key objects for capabilities.

**Good example:**

```java
public final class ThreadLocal<T> {   // typesafe capability, not a shared string namespace
    public ThreadLocal() { }
    public void set(T value) { ... }
    public T get() { ... }
}
```

**Bad example:**

```java
public class ThreadLocal {
    public static void set(String key, Object value); // string keys share a global namespace:
    public static Object get(String key);             // two clients picking "context" collide.
}
```

### Item 63: Beware the performance of string concatenation

Title: Use `StringBuilder` (or `String.join`/streams) for repeated concatenation.
Description: Repeated `+` concatenation is O(n²) because strings are immutable and copied each time. Use `StringBuilder.append` in loops (preallocate capacity when known).

**Good example:**

```java
public String statement() {
    StringBuilder b = new StringBuilder(numItems() * LINE_WIDTH);
    for (int i = 0; i < numItems(); i++) b.append(lineForItem(i));
    return b.toString();   // linear time
}
```

**Bad example:**

```java
public String statement() {
    String result = "";
    for (int i = 0; i < numItems(); i++) result += lineForItem(i); // quadratic time
    return result;
}
```

### Item 64: Refer to objects by their interfaces

Title: Declare parameters, return types, variables, and fields with interface types when one exists.
Description: Using interface types makes programs flexible: you can swap implementations by changing only the constructor call. Use a class type only when no suitable interface exists (value classes like `String`/`BigInteger`, class-based frameworks, or classes with needed extra methods).

**Good example:**

```java
Set<Son> sonSet = new LinkedHashSet<>();  // declared as the Set interface
// Switching implementation is a one-line change:
// Set<Son> sonSet = new TreeSet<>();
```

**Bad example:**

```java
LinkedHashSet<Son> sonSet = new LinkedHashSet<>(); // ties all surrounding code to LinkedHashSet
```

### Item 65: Prefer interfaces to reflection

Title: Avoid reflection; if you must instantiate unknown classes, do it reflectively but use them via an interface.
Description: `java.lang.reflect` loses compile-time type checking, is verbose, and is slow. When you must work with classes unknown at compile time, create instances reflectively but access them through a known interface or superclass.

**Good example:**

```java
Class<? extends Set<String>> cl = (Class<? extends Set<String>>) Class.forName(args[0]);
Constructor<? extends Set<String>> cons = cl.getDeclaredConstructor();
Set<String> s = cons.newInstance();  // created reflectively...
s.addAll(Arrays.asList(args).subList(1, args.length)); // ...used through the Set interface
```

**Bad example:**

```java
Object o = Class.forName(name).getDeclaredConstructor().newInstance();
Method m = o.getClass().getMethod("addAll", Collection.class);
m.invoke(o, list);  // clumsy, unchecked, slow, throws six possible reflective exceptions
```

### Item 66: Use native methods judiciously

Title: Rarely use JNI/native methods; the costs usually outweigh the benefits.
Description: Native methods sacrifice safety (memory corruption), portability, and debuggability, and add error-prone glue code. Modern JVMs are fast; native code is seldom worth it for performance. Use native methods only for unavoidable platform/library access, and keep them minimal.

**Good example:**

```java
// Prefer the platform: the Process API (Java 9+) replaces native OS-process access.
ProcessHandle.current().pid();
```

**Bad example:**

```java
public class Fast {
    static { System.loadLibrary("fast"); }
    private static native int add(int a, int b); // native code just to add two ints — not worth the risk
}
```

### Item 67: Optimize judiciously

Title: Write good programs, not fast ones; measure before and after optimizing.
Description: Premature optimization is the root of much evil. Strive for clean architecture and good API design (mutability/inheritance decisions limit future performance). Don't sacrifice sound design for speed. When you must optimize, measure with a profiler/`jmh`, change one thing, and measure again.

**Good example:**

```java
// Good API design that doesn't foreclose performance: immutable, returns primitives.
public final class Dimension {
    private final int width, height;
    public int width()  { return width; }
    public int height() { return height; }
}
```

**Bad example:**

```java
// Mutable return type forces a new allocation on every call and can't be cached.
public Dimension getSize() { return new Dimension(w, h); } // (java.awt.Component's historic mistake)
```

### Item 68: Adhere to generally accepted naming conventions

Title: Follow the standard typographical and grammatical naming conventions.
Description: Packages lowercase reverse-domain; classes/interfaces/enums `PascalCase`; methods/fields `camelCase`; constants `UPPER_SNAKE_CASE`; type parameters single letters (`T`, `E`, `K`, `V`, `R`, `X`). Grammatically: classes are nouns, methods that do things are verbs, `boolean` accessors start with `is`/`has`, converters are `toType`/`asType`, factories are `from`/`of`/`valueOf`/`instance`.

**Good example:**

```java
package com.example.util;
public final class HttpUrl {                 // PascalCase, acronym only first-letter capitalized
    public static final int DEFAULT_PORT = 80; // constant
    private int lineNum;                       // camelCase field
    public boolean isEmpty() { ... }           // boolean accessor
}
```

**Bad example:**

```java
package com.example.Util;     // package should be lowercase
public final class HTTPURL {  // hard to read; prefer HttpUrl
    public static final int defaultPort = 80; // constant should be DEFAULT_PORT
    public boolean Empty() { } // boolean accessor should be isEmpty()
}
```

---

## Chapter 10 — Exceptions

### Item 69: Use exceptions only for exceptional conditions

Title: Never use exceptions for ordinary control flow.
Description: Exceptions are for exceptional conditions, not loops or normal flow. Exception-based control flow is slow, obscure, and can mask real bugs. Provide a state-testing method (e.g., `hasNext`) or a distinguished/optional return value instead of forcing clients to catch exceptions.

**Good example:**

```java
for (Iterator<Foo> i = collection.iterator(); i.hasNext(); ) { // state-testing method
    Foo foo = i.next();
    ...
}
```

**Bad example:**

```java
try {
    int i = 0;
    while (true) range[i++].climb();   // "loop" that ends by catching an exception
} catch (ArrayIndexOutOfBoundsException e) { } // slower, obscure, hides unrelated bugs
```

### Item 70: Use checked exceptions for recoverable conditions and runtime exceptions for programming errors

Title: Checked for recoverable, runtime for precondition violations; don't subclass `Error`.
Description: Throw a checked exception when the caller can reasonably recover (forces handling). Throw an unchecked `RuntimeException` for programming errors (precondition violations like a bad index). Reserve `Error` for the JVM. Provide accessor methods on checked exceptions to aid recovery.

**Good example:**

```java
public class InsufficientFundsException extends Exception { // recoverable → checked
    private final BigDecimal shortfall;
    public InsufficientFundsException(BigDecimal shortfall) { this.shortfall = shortfall; }
    public BigDecimal getShortfall() { return shortfall; }  // helps caller recover
}
```

**Bad example:**

```java
// Programming error modeled as a checked exception forces pointless catch blocks:
public void setAge(int age) throws BadAgeException {
    if (age < 0) throw new BadAgeException(); // should be IllegalArgumentException (unchecked)
}
```

### Item 71: Avoid unnecessary use of checked exceptions

Title: Don't overuse checked exceptions; prefer optionals or state-testing where reasonable.
Description: Checked exceptions burden callers (mandatory try/catch, unusable directly in streams). If the caller can't recover or won't, use an unchecked exception. Sometimes return an `Optional` (no detail on failure) or split into a state-testing method + an action method.

**Good example:**

```java
// State-testing method turns a checked exception into a clean conditional:
if (obj.actionPermitted(args)) obj.action(args);
else { /* handle */ }
```

**Bad example:**

```java
try {
    obj.action(args);
} catch (TheCheckedException e) {
    throw new AssertionError("Can't happen"); // if catch can only do this, the checked exception was unnecessary
}
```

### Item 72: Favor the use of standard exceptions

Title: Reuse the standard JDK exceptions.
Description: Standard exceptions make APIs familiar and readable. Common choices: `IllegalArgumentException` (bad arg value), `IllegalStateException` (bad object state), `NullPointerException` (null where prohibited), `IndexOutOfBoundsException`, `ConcurrentModificationException`, `UnsupportedOperationException`. Don't reuse `Exception`, `RuntimeException`, `Throwable`, or `Error` directly.

**Good example:**

```java
public void repeat(int count) {
    if (count < 0) throw new IllegalArgumentException("count < 0: " + count); // standard, expected
    ...
}
```

**Bad example:**

```java
public void repeat(int count) {
    if (count < 0) throw new BadCountException(); // needless custom class duplicating IllegalArgumentException
}
```

### Item 73: Throw exceptions appropriate to the abstraction

Title: Use exception translation (and chaining) to keep exceptions at the right level.
Description: Don't let low-level exceptions leak through a higher-level API. Catch them and throw an exception explained in terms of the higher abstraction (exception translation). When the cause aids debugging, use exception chaining (pass the cause to a chaining-aware constructor). Better still, prevent lower-level exceptions when possible.

**Good example:**

```java
try {
    ... // use lower-level abstraction
} catch (LowerLevelException cause) {
    throw new HigherLevelException(cause); // exception chaining preserves the root cause
}
class HigherLevelException extends Exception {
    HigherLevelException(Throwable cause) { super(cause); }
}
```

**Bad example:**

```java
public E get(int index) {
    return listIterator(index).next(); // lets NoSuchElementException (low-level) propagate
}                                       // caller of a List sees the wrong abstraction's exception
```

### Item 74: Document all exceptions thrown by each method

Title: Declare and document every exception, checked and unchecked.
Description: Use the Javadoc `@throws` tag to document each exception and the precise conditions that cause it. Declare checked exceptions individually (never `throws Exception`). Document unchecked exceptions with `@throws` but do **not** list them in the `throws` clause — the distinction signals the caller's responsibility.

**Good example:**

```java
/**
 * @throws IndexOutOfBoundsException if {@code index < 0 || index >= size()}
 * @throws NullPointerException if {@code element} is null
 */
public void set(int index, E element) { ... }
```

**Bad example:**

```java
/** Sets an element. */
public void set(int index, E element) throws Exception { ... } // hides which exceptions; undocumented
```

### Item 75: Include failure-capture information in detail messages

Title: A thrown exception's detail message should capture all relevant state.
Description: To diagnose failures from logs alone, include the values of all parameters and fields that contributed to the failure in the exception's detail message (but never sensitive data like passwords/keys). Consider capturing the data in fields with accessors for programmatic recovery.

**Good example:**

```java
public IndexOutOfBoundsException(int lowerBound, int upperBound, int index) {
    super(String.format("Lower bound: %d, Upper bound: %d, Index: %d",
            lowerBound, upperBound, index));     // all contributing values captured
    this.lowerBound = lowerBound; this.upperBound = upperBound; this.index = index;
}
```

**Bad example:**

```java
throw new IndexOutOfBoundsException(); // empty message: the log shows nothing useful to debug with
```

### Item 76: Strive for failure atomicity

Title: A failed method invocation should leave the object in its pre-invocation state.
Description: Achieve failure atomicity by: using immutable objects; checking parameters before mutating state; ordering computation so failure-prone parts run first; doing work on a temporary copy; or recovering via rollback. Document any unavoidable deviation.

**Good example:**

```java
public Object pop() {
    if (size == 0) throw new EmptyStackException(); // check BEFORE mutating size
    Object result = elements[--size];
    elements[size] = null;
    return result;
}
```

**Bad example:**

```java
public Object pop() {
    Object result = elements[--size]; // decrements size even when empty → corrupts the stack
    elements[size] = null;            // (size becomes -1) before the implicit ArrayIndexOutOfBounds
    return result;
}
```

### Item 77: Don't ignore exceptions

Title: Never leave a catch block empty.
Description: An empty catch defeats the purpose of exceptions and hides failures. At minimum, log the exception. If you genuinely intend to ignore it, name the variable `ignored` and add a comment explaining why it's safe.

**Good example:**

```java
Future<Integer> f = exec.submit(planarMap::chromaticNumber);
int numColors = 4; // default; guaranteed sufficient for any planar map
try {
    numColors = f.get(1L, TimeUnit.SECONDS);
} catch (TimeoutException | ExecutionException ignored) {
    // Use default: it is fine if the computation didn't finish in time.
}
```

**Bad example:**

```java
try {
    numColors = f.get(1L, TimeUnit.SECONDS);
} catch (TimeoutException | ExecutionException e) {
}  // swallows failures silently → bugs surface far from their cause
```

---

## Chapter 11 — Concurrency

### Item 78: Synchronize access to shared mutable data

Title: Both reads and writes of shared mutable data must be synchronized.
Description: Synchronization provides mutual exclusion **and** inter-thread visibility. Without it, one thread may never see another's writes (the JMM allows hoisting). `volatile` guarantees visibility (but not atomicity for compound actions like `++`). Prefer not sharing mutable data: confine it to one thread, share immutables, or use `java.util.concurrent.atomic`.

**Good example:**

```java
private static volatile boolean stopRequested;          // visibility guaranteed
public static void main(String[] args) throws InterruptedException {
    Thread bg = new Thread(() -> { int i = 0; while (!stopRequested) i++; });
    bg.start();
    TimeUnit.SECONDS.sleep(1);
    stopRequested = true;                                // change becomes visible to bg
}
// For a unique serial number, use atomics (atomicity + visibility):
private static final AtomicLong nextSerialNum = new AtomicLong();
public static long generateSerialNumber() { return nextSerialNum.getAndIncrement(); }
```

**Bad example:**

```java
private static boolean stopRequested;                   // NOT synchronized/volatile
public static void main(String[] args) throws InterruptedException {
    Thread bg = new Thread(() -> { int i = 0; while (!stopRequested) i++; });
    bg.start();                                         // VM may hoist the check → loops forever
    TimeUnit.SECONDS.sleep(1);
    stopRequested = true;
}
```

### Item 79: Avoid excessive synchronization

Title: Never cede control to an alien method from within a synchronized region; keep locked regions small.
Description: Calling an overridable or client-supplied method while holding a lock invites deadlock, data corruption, and `ConcurrentModificationException`. Move alien calls outside the lock ("open calls"), e.g., by snapshotting, or use `CopyOnWriteArrayList` for observer lists. Do as little as possible inside synchronized regions.

**Good example:**

```java
private final List<SetObserver<E>> observers = new CopyOnWriteArrayList<>();
private void notifyElementAdded(E element) {
    for (SetObserver<E> observer : observers)   // no lock needed; iteration is snapshot-safe
        observer.added(this, element);          // alien call made outside any synchronized block
}
```

**Bad example:**

```java
private void notifyElementAdded(E element) {
    synchronized (observers) {                  // holds the lock while...
        for (SetObserver<E> observer : observers)
            observer.added(this, element);      // ...calling an alien method → deadlock / CME
    }
}
```

### Item 80: Prefer executors, tasks, and streams to threads

Title: Use the Executor Framework instead of working with threads directly.
Description: Don't hand-roll work queues or manage `Thread` objects. Submit `Runnable`/`Callable` tasks to an `ExecutorService`; choose the right pool (`newFixedThreadPool` for loaded servers, `newCachedThreadPool` for light loads). For parallelism, prefer parallel streams or fork-join where appropriate.

**Good example:**

```java
ExecutorService exec = Executors.newFixedThreadPool(N);
exec.execute(runnable);
// ... later, shut down gracefully:
exec.shutdown();
```

**Bad example:**

```java
// Manually creating and managing threads as both work unit and execution mechanism.
Thread worker = new Thread(() -> processQueue());
worker.start();   // no pooling, no lifecycle management, no backpressure → fragile, leak-prone
```

### Item 81: Prefer concurrency utilities to wait and notify

Title: Use `java.util.concurrent` (executors, concurrent collections, synchronizers) instead of `wait`/`notify`.
Description: `wait`/`notify` are low-level and error-prone. Prefer `ConcurrentHashMap`, `BlockingQueue`, and synchronizers like `CountDownLatch`/`Semaphore`. If you must use `wait`, always call it in a `while` loop that rechecks the condition; prefer `notifyAll` over `notify`.

**Good example:**

```java
public static long time(Executor executor, int concurrency, Runnable action)
        throws InterruptedException {
    CountDownLatch ready = new CountDownLatch(concurrency);
    CountDownLatch start = new CountDownLatch(1);
    CountDownLatch done  = new CountDownLatch(concurrency);
    for (int i = 0; i < concurrency; i++) {
        executor.execute(() -> {
            ready.countDown();
            try { start.await(); action.run(); }
            catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            finally { done.countDown(); }
        });
    }
    ready.await();
    long startNanos = System.nanoTime();
    start.countDown();
    done.await();
    return System.nanoTime() - startNanos;
}
```

**Bad example:**

```java
synchronized (obj) {
    if (!conditionHolds()) obj.wait(); // 'if' instead of 'while': spurious wakeups / missed signals
    doAction();                         // may run when the condition does NOT hold → safety failure
}
```

### Item 82: Document thread safety

Title: Clearly document each class's level of thread safety.
Description: The presence of `synchronized` is an implementation detail, not API. Document the level: immutable, unconditionally thread-safe, conditionally thread-safe (and which sequences need external locking), not thread-safe, or thread-hostile. For unconditionally thread-safe classes, consider a private lock object to prevent denial-of-service via the public lock.

**Good example:**

```java
// Private lock object idiom — clients/subclasses can't interfere with synchronization.
public class SafeCounter {
    private final Object lock = new Object();  // always final
    private long value;
    public void increment() { synchronized (lock) { value++; } }
}
```

**Bad example:**

```java
public class Counter {
    public synchronized void increment() { value++; } // uses the public lock:
    // a hostile client can `synchronized (counter) { while (true) {} }` → DoS
}
```

### Item 83: Use lazy initialization judiciously

Title: Initialize normally; lazy-init only when measurement justifies it, using the right idiom.
Description: Lazy initialization trades cheaper construction for costlier access and adds concurrency hazards. Use it only when needed. For static fields use the **lazy initialization holder class** idiom; for instance fields use the **double-check** idiom (field must be `volatile`).

**Good example:**

```java
// Static field: holder class idiom — no synchronization on the hot path.
private static class FieldHolder { static final FieldType field = computeFieldValue(); }
private static FieldType getField() { return FieldHolder.field; }

// Instance field: double-check idiom.
private volatile FieldType field;
private FieldType getInstanceField() {
    FieldType result = field;
    if (result == null) {                 // first check (no locking)
        synchronized (this) {
            if (field == null) field = result = computeFieldValue(); // second check (locked)
        }
    }
    return result;
}
```

**Bad example:**

```java
// Double-check WITHOUT volatile → another thread can see a partially constructed object.
private FieldType field;                   // missing 'volatile'
private FieldType getField() {
    if (field == null) synchronized (this) { if (field == null) field = compute(); }
    return field;                          // broken under the Java Memory Model
}
```

### Item 84: Don't depend on the thread scheduler

Title: Correctness must not depend on the thread scheduler, `Thread.yield`, or thread priorities.
Description: Scheduling policy varies across platforms, so scheduler-dependent programs are nonportable. Keep the number of runnable threads near the processor count; have threads do useful work and then wait. Never busy-wait, and don't "fix" liveness with `Thread.yield` or priorities (they're hints with no testable semantics).

**Good example:**

```java
// Threads block waiting for real work via a proper synchronizer — no busy-waiting.
public void await() throws InterruptedException { latch.await(); } // CountDownLatch
```

**Bad example:**

```java
public void await() {
    while (true) {
        synchronized (this) { if (count == 0) return; } // busy-wait spins the CPU,
    }                                                   // wastes cycles, depends on the scheduler
}
```

---

## Chapter 12 — Serialization

### Item 85: Prefer alternatives to Java serialization

Title: Avoid Java serialization; use JSON/Protocol Buffers or other cross-platform formats.
Description: Java serialization is a huge attack surface: deserializing untrusted bytes can execute arbitrary code (gadget chains) and enable denial-of-service. The best defense is to never deserialize untrusted data. Prefer structured data formats (JSON, Protobuf). If stuck with Java serialization, use object-input filtering (`ObjectInputFilter`) and never deserialize untrusted streams.

**Good example:**

```java
// Cross-platform, attack-resistant: exchange data as JSON instead of serialized Java objects.
String json = objectMapper.writeValueAsString(order);   // e.g., Jackson
Order order = objectMapper.readValue(json, Order.class); // no arbitrary code execution risk
```

**Bad example:**

```java
// Deserializing untrusted bytes — a remote-code-execution / DoS vector ("billion laughs").
ObjectInputStream in = new ObjectInputStream(socket.getInputStream());
Object o = in.readObject();   // an attacker controls the byte stream → gadget chains
```

### Item 86: Implement Serializable with great caution

Title: Implementing `Serializable` is a serious, permanent commitment.
Description: `Serializable` makes the byte-stream encoding part of your exported API forever (constrains future evolution), increases the bug/security surface, and complicates testing. Classes designed for inheritance, inner classes, and enums need special care (enums get serialization "for free"; don't make inner classes serializable).

**Good example:**

```java
// Make a value class serializable deliberately, with an explicit UID and (ideally) a proxy (Item 90).
public final class Money implements Serializable {
    private static final long serialVersionUID = 1L;
    private final long amount; private final String currency;
    // ... plus a serialization proxy
}
```

**Bad example:**

```java
// Casually adding 'implements Serializable' to a class whose internal representation
// you may want to change later — now the byte layout is a permanent part of the API.
public class InternalCacheKey implements Serializable { ... }
```

### Item 87: Consider using a custom serialized form

Title: Use the default serialized form only if it faithfully describes the logical state.
Description: The default form serializes the physical representation; if that differs from the logical content (e.g., a linked list, a hash table), it's fragile, oversized, and slow. Provide `writeObject`/`readObject` to serialize the logical content, mark physical fields `transient`, call `defaultWriteObject`/`defaultReadObject` first, and always declare an explicit `serialVersionUID`.

**Good example:**

```java
public final class StringList implements Serializable {
    private transient int size = 0;          // physical fields are transient
    private transient Entry head = null;
    private static class Entry { String data; Entry next; Entry previous; }
    private void writeObject(ObjectOutputStream s) throws IOException {
        s.defaultWriteObject();
        s.writeInt(size);
        for (Entry e = head; e != null; e = e.next) s.writeObject(e.data); // logical content only
    }
    private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
        s.defaultReadObject();
        int n = s.readInt();
        for (int i = 0; i < n; i++) add((String) s.readObject());
    }
    private static final long serialVersionUID = 1L;
    public void add(String s) { ... }
}
```

**Bad example:**

```java
// Default form serializes the whole linked-list node structure (next/previous pointers):
public final class StringList implements Serializable {
    private int size = 0;
    private Entry head = null;
    private static class Entry implements Serializable { String data; Entry next; Entry previous; }
    // Fragile (ties API to representation), bloated, and can StackOverflow on long lists.
}
```

### Item 88: Write readObject methods defensively

Title: Treat `readObject` as a public constructor: validate and defensively copy.
Description: `readObject` accepts an attacker-controlled byte stream. It must check invariants and make defensive copies of mutable components (copy first, then validate). Don't call overridable methods. For mutable internals, the fields can't be `final` (so the copy can be assigned). The serialization proxy (Item 90) avoids most of this.

**Good example:**

```java
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
    s.defaultReadObject();
    start = new Date(start.getTime());   // defensively copy mutable components FIRST
    end   = new Date(end.getTime());
    if (start.compareTo(end) > 0)        // THEN validate invariants
        throw new InvalidObjectException(start + " after " + end);
}
```

**Bad example:**

```java
// No defensive copy: an attacker appends "rogue references" to the internal Date fields
// and mutates the supposedly immutable Period after deserialization.
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
    s.defaultReadObject();
    if (start.compareTo(end) > 0) throw new InvalidObjectException("..."); // validation alone is insufficient
}
```

### Item 89: For instance control, prefer enum types to readResolve

Title: Use an enum to keep a serializable singleton truly single.
Description: A serializable class with a private constructor isn't instance-controlled unless you add `readResolve` and make every object-reference field `transient` (otherwise a "stealer" attack captures a second instance). A single-element enum gives ironclad instance control for free.

**Good example:**

```java
public enum Elvis {
    INSTANCE;
    private String[] favoriteSongs = { "Hound Dog", "Heartbreak Hotel" };
    public void printFavorites() { System.out.println(Arrays.toString(favoriteSongs)); }
} // serialization guarantees a single instance, no readResolve needed
```

**Bad example:**

```java
public class Elvis implements Serializable {
    public static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
    private String[] favoriteSongs = { ... };       // NON-transient object reference field
    private Object readResolve() { return INSTANCE; } // vulnerable to the ElvisStealer attack
}
```

### Item 90: Consider serialization proxies instead of serialized instances

Title: Use the serialization proxy pattern for robust, attack-resistant serialization.
Description: Give the class a private static nested `SerializationProxy` capturing its logical state, add `writeReplace` to the enclosing class (emit the proxy), a `readObject` that always throws (block direct deserialization), and a `readResolve` on the proxy that reconstructs via the public API. This keeps fields `final`, defeats byte-stream attacks, and even allows the deserialized object to be a different class (as `EnumSet` does).

**Good example:**

```java
public final class Period implements Serializable {
    private final Date start, end;
    public Period(Date start, Date end) { /* defensive copies + validation */ }

    private static class SerializationProxy implements Serializable {
        private final Date start, end;
        SerializationProxy(Period p) { this.start = p.start; this.end = p.end; }
        private Object readResolve() { return new Period(start, end); } // uses public constructor
        private static final long serialVersionUID = 234098243823485285L;
    }
    private Object writeReplace() { return new SerializationProxy(this); } // serialize the proxy
    private void readObject(ObjectInputStream s) throws InvalidObjectException {
        throw new InvalidObjectException("Proxy required");                // block direct deserialization
    }
    private static final long serialVersionUID = 1L;
}
```

**Bad example:**

```java
// Hand-rolled defensive readObject on a non-final-field class: must reason about every
// attack (bogus stream, field theft), keep fields non-final, and re-validate manually.
public final class Period implements Serializable {
    private Date start, end;  // can't be final → weaker immutability
    private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
        s.defaultReadObject();
        start = new Date(start.getTime()); end = new Date(end.getTime());
        if (start.compareTo(end) > 0) throw new InvalidObjectException("...");
    }   // works, but the proxy pattern is simpler and safer
}
```

## Output Format

When you apply this skill to a user's code, structure your response as follows:

- **ANALYZE** the supplied Java code and identify which *Effective Java* items it violates or could apply, citing each by number and title (e.g., "Item 17: Minimize mutability").
- **CATEGORIZE** findings by impact (CRITICAL correctness/security, MAINTAINABILITY, PERFORMANCE, READABILITY) and by chapter (object creation, common methods, classes/interfaces, generics, enums/annotations, lambdas/streams, methods, general programming, exceptions, concurrency, serialization).
- **EXPLAIN** for each finding the relevant item's rationale and show the targeted Good vs. Bad contrast as it applies to the user's code.
- **APPLY** the most valuable, lowest-risk improvements first (e.g., defensive copies, immutability, `@Override`, standard exceptions, try-with-resources), preserving observable behavior unless the user asks to change a contract.
- **PRIORITIZE** a short, ordered remediation plan (quick wins → structural refactorings such as builder/composition/serialization-proxy).
- **VALIDATE** that all changes compile and tests pass before reporting success.

## Safeguards

- **BLOCKING SAFETY CHECK**: Run `./mvnw compile` (or the project build) before applying ANY refactoring — compilation failure is a HARD STOP.
- **CRITICAL VALIDATION**: Run `./mvnw clean verify` (or the project's full test build) after applying changes; report failures honestly with the actual output.
- **BEHAVIOR PRESERVATION**: Immutability, defensive copying, exception translation, and generics changes must preserve behavior unless the user explicitly authorizes a contract change.
- **SECURITY**: Never recommend deserializing untrusted data with Java serialization (Item 85); flag any such code as a vulnerability and propose JSON/Protobuf or object-input filtering.
- **THREAD SAFETY**: Concurrency changes (Items 78–84) can introduce liveness/safety failures — apply incrementally and validate under realistic conditions; never depend on the thread scheduler.
- **INCREMENTAL SAFETY**: Apply one item at a time and re-validate; do not batch many structural changes without intermediate verification.
- **NO OVER-APPLICATION**: These are guidelines, not absolutes — call out the rare cases where an item legitimately does not apply rather than forcing it.
