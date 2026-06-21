# effective-java

> Code-first guidelines distilled from Joshua Bloch's *Effective Java (3rd Edition)*. Each item states the rule, then contrasts a **Bad** anti-pattern with the **Good** idiomatic approach. Code samples are original illustrations of each principle, written to teach the rule rather than to reproduce the book.

## Table of Contents

- [Chapter 2: Creating and Destroying Objects](#chapter-2-creating-and-destroying-objects)
  - [Item 1: Consider static factory methods instead of constructors](#item-1-consider-static-factory-methods-instead-of-constructors)
  - [Item 2: Consider a builder when faced with many constructor parameters](#item-2-consider-a-builder-when-faced-with-many-constructor-parameters)
  - [Item 3: Enforce the singleton property with a private constructor or an enum type](#item-3-enforce-the-singleton-property-with-a-private-constructor-or-an-enum-type)
  - [Item 4: Enforce noninstantiability with a private constructor](#item-4-enforce-noninstantiability-with-a-private-constructor)
  - [Item 5: Prefer dependency injection to hardwiring resources](#item-5-prefer-dependency-injection-to-hardwiring-resources)
  - [Item 6: Avoid creating unnecessary objects](#item-6-avoid-creating-unnecessary-objects)
  - [Item 7: Eliminate obsolete object references](#item-7-eliminate-obsolete-object-references)
  - [Item 8: Avoid finalizers and cleaners](#item-8-avoid-finalizers-and-cleaners)
  - [Item 9: Prefer try-with-resources to try-finally](#item-9-prefer-try-with-resources-to-try-finally)
- [Chapter 3: Methods Common to All Objects](#chapter-3-methods-common-to-all-objects)
  - [Item 10: Obey the general contract when overriding equals](#item-10-obey-the-general-contract-when-overriding-equals)
  - [Item 11: Always override hashCode when you override equals](#item-11-always-override-hashcode-when-you-override-equals)
  - [Item 12: Always override toString](#item-12-always-override-tostring)
  - [Item 13: Override clone judiciously](#item-13-override-clone-judiciously)
  - [Item 14: Consider implementing Comparable](#item-14-consider-implementing-comparable)
- [Chapter 4: Classes and Interfaces](#chapter-4-classes-and-interfaces)
  - [Item 15: Minimize the accessibility of classes and members](#item-15-minimize-the-accessibility-of-classes-and-members)
  - [Item 16: In public classes, use accessor methods, not public fields](#item-16-in-public-classes-use-accessor-methods-not-public-fields)
  - [Item 17: Minimize mutability](#item-17-minimize-mutability)
  - [Item 18: Favor composition over inheritance](#item-18-favor-composition-over-inheritance)
  - [Item 19: Design and document for inheritance or else prohibit it](#item-19-design-and-document-for-inheritance-or-else-prohibit-it)
  - [Item 20: Prefer interfaces to abstract classes](#item-20-prefer-interfaces-to-abstract-classes)
  - [Item 21: Design interfaces for posterity](#item-21-design-interfaces-for-posterity)
  - [Item 22: Use interfaces only to define types](#item-22-use-interfaces-only-to-define-types)
  - [Item 23: Prefer class hierarchies to tagged classes](#item-23-prefer-class-hierarchies-to-tagged-classes)
  - [Item 24: Favor static member classes over nonstatic](#item-24-favor-static-member-classes-over-nonstatic)
  - [Item 25: Limit source files to a single top-level class](#item-25-limit-source-files-to-a-single-top-level-class)
- [Chapter 5: Generics](#chapter-5-generics)
  - [Item 26: Don't use raw types](#item-26-dont-use-raw-types)
  - [Item 27: Eliminate unchecked warnings](#item-27-eliminate-unchecked-warnings)
  - [Item 28: Prefer lists to arrays](#item-28-prefer-lists-to-arrays)
  - [Item 29: Favor generic types](#item-29-favor-generic-types)
  - [Item 30: Favor generic methods](#item-30-favor-generic-methods)
  - [Item 31: Use bounded wildcards to increase API flexibility](#item-31-use-bounded-wildcards-to-increase-api-flexibility)
  - [Item 32: Combine generics and varargs judiciously](#item-32-combine-generics-and-varargs-judiciously)
  - [Item 33: Consider typesafe heterogeneous containers](#item-33-consider-typesafe-heterogeneous-containers)
- [Chapter 6: Enums and Annotations](#chapter-6-enums-and-annotations)
  - [Item 34: Use enums instead of int constants](#item-34-use-enums-instead-of-int-constants)
  - [Item 35: Use instance fields instead of ordinals](#item-35-use-instance-fields-instead-of-ordinals)
  - [Item 36: Use EnumSet instead of bit fields](#item-36-use-enumset-instead-of-bit-fields)
  - [Item 37: Use EnumMap instead of ordinal indexing](#item-37-use-enummap-instead-of-ordinal-indexing)
  - [Item 38: Emulate extensible enums with interfaces](#item-38-emulate-extensible-enums-with-interfaces)
  - [Item 39: Prefer annotations to naming patterns](#item-39-prefer-annotations-to-naming-patterns)
  - [Item 40: Consistently use the Override annotation](#item-40-consistently-use-the-override-annotation)
  - [Item 41: Use marker interfaces to define types](#item-41-use-marker-interfaces-to-define-types)
- [Chapter 7: Lambdas and Streams](#chapter-7-lambdas-and-streams)
  - [Item 42: Prefer lambdas to anonymous classes](#item-42-prefer-lambdas-to-anonymous-classes)
  - [Item 43: Prefer method references to lambdas](#item-43-prefer-method-references-to-lambdas)
  - [Item 44: Favor the use of standard functional interfaces](#item-44-favor-the-use-of-standard-functional-interfaces)
  - [Item 45: Use streams judiciously](#item-45-use-streams-judiciously)
  - [Item 46: Prefer side-effect-free functions in streams](#item-46-prefer-side-effect-free-functions-in-streams)
  - [Item 47: Prefer Collection to Stream as a return type](#item-47-prefer-collection-to-stream-as-a-return-type)
  - [Item 48: Use caution when making streams parallel](#item-48-use-caution-when-making-streams-parallel)
- [Chapter 8: Methods](#chapter-8-methods)
  - [Item 49: Check parameters for validity](#item-49-check-parameters-for-validity)
  - [Item 50: Make defensive copies when needed](#item-50-make-defensive-copies-when-needed)
  - [Item 51: Design method signatures carefully](#item-51-design-method-signatures-carefully)
  - [Item 52: Use overloading judiciously](#item-52-use-overloading-judiciously)
  - [Item 53: Use varargs judiciously](#item-53-use-varargs-judiciously)
  - [Item 54: Return empty collections or arrays, not nulls](#item-54-return-empty-collections-or-arrays-not-nulls)
  - [Item 55: Return optionals judiciously](#item-55-return-optionals-judiciously)
  - [Item 56: Write doc comments for all exposed API elements](#item-56-write-doc-comments-for-all-exposed-api-elements)
- [Chapter 9: General Programming](#chapter-9-general-programming)
  - [Item 57: Minimize the scope of local variables](#item-57-minimize-the-scope-of-local-variables)
  - [Item 58: Prefer for-each loops to traditional for loops](#item-58-prefer-for-each-loops-to-traditional-for-loops)
  - [Item 59: Know and use the libraries](#item-59-know-and-use-the-libraries)
  - [Item 60: Avoid float and double if exact answers are required](#item-60-avoid-float-and-double-if-exact-answers-are-required)
  - [Item 61: Prefer primitive types to boxed primitives](#item-61-prefer-primitive-types-to-boxed-primitives)
  - [Item 62: Avoid strings where other types are more appropriate](#item-62-avoid-strings-where-other-types-are-more-appropriate)
  - [Item 63: Beware the performance of string concatenation](#item-63-beware-the-performance-of-string-concatenation)
  - [Item 64: Refer to objects by their interfaces](#item-64-refer-to-objects-by-their-interfaces)
  - [Item 65: Prefer interfaces to reflection](#item-65-prefer-interfaces-to-reflection)
  - [Item 66: Use native methods judiciously](#item-66-use-native-methods-judiciously)
  - [Item 67: Optimize judiciously](#item-67-optimize-judiciously)
  - [Item 68: Adhere to generally accepted naming conventions](#item-68-adhere-to-generally-accepted-naming-conventions)
- [Chapter 10: Exceptions](#chapter-10-exceptions)
  - [Item 69: Use exceptions only for exceptional conditions](#item-69-use-exceptions-only-for-exceptional-conditions)
  - [Item 70: Use checked exceptions for recoverable conditions and runtime exceptions for programming errors](#item-70-use-checked-exceptions-for-recoverable-conditions-and-runtime-exceptions-for-programming-errors)
  - [Item 71: Avoid unnecessary use of checked exceptions](#item-71-avoid-unnecessary-use-of-checked-exceptions)
  - [Item 72: Favor the use of standard exceptions](#item-72-favor-the-use-of-standard-exceptions)
  - [Item 73: Throw exceptions appropriate to the abstraction](#item-73-throw-exceptions-appropriate-to-the-abstraction)
  - [Item 74: Document all exceptions thrown by each method](#item-74-document-all-exceptions-thrown-by-each-method)
  - [Item 75: Include failure-capture information in detail messages](#item-75-include-failure-capture-information-in-detail-messages)
  - [Item 76: Strive for failure atomicity](#item-76-strive-for-failure-atomicity)
  - [Item 77: Don't ignore exceptions](#item-77-dont-ignore-exceptions)
- [Chapter 11: Concurrency](#chapter-11-concurrency)
  - [Item 78: Synchronize access to shared mutable data](#item-78-synchronize-access-to-shared-mutable-data)
  - [Item 79: Avoid excessive synchronization](#item-79-avoid-excessive-synchronization)
  - [Item 80: Prefer executors, tasks, and streams to threads](#item-80-prefer-executors-tasks-and-streams-to-threads)
  - [Item 81: Prefer concurrency utilities to wait and notify](#item-81-prefer-concurrency-utilities-to-wait-and-notify)
  - [Item 82: Document thread safety](#item-82-document-thread-safety)
  - [Item 83: Use lazy initialization judiciously](#item-83-use-lazy-initialization-judiciously)
  - [Item 84: Don't depend on the thread scheduler](#item-84-dont-depend-on-the-thread-scheduler)
- [Chapter 12: Serialization](#chapter-12-serialization)
  - [Item 85: Prefer alternatives to Java serialization](#item-85-prefer-alternatives-to-java-serialization)
  - [Item 86: Implement Serializable with great caution](#item-86-implement-serializable-with-great-caution)
  - [Item 87: Consider using a custom serialized form](#item-87-consider-using-a-custom-serialized-form)
  - [Item 88: Write readObject methods defensively](#item-88-write-readobject-methods-defensively)
  - [Item 89: For instance control, prefer enum types to readResolve](#item-89-for-instance-control-prefer-enum-types-to-readresolve)
  - [Item 90: Consider serialization proxies instead of serialized instances](#item-90-consider-serialization-proxies-instead-of-serialized-instances)

---

## Chapter 2: Creating and Destroying Objects

### Item 1: Consider static factory methods instead of constructors

A static factory method is a static method that returns an instance of the class. Unlike constructors, factories have descriptive names, are not required to create a new object on each call (enabling caching), can return any subtype, and can reduce verbosity. Consider them as an alternative to public constructors, not a wholesale replacement.

**Bad:**

```java
// A bare constructor gives no hint about what it produces.
public final class Color {
    public Color(int rgb) { /* ... */ }
}

Color c = new Color(0xFF0000); // RGB? a packed int? unclear at the call site
```

**Good:**

```java
// Named static factories reveal intent and can cache or return subtypes.
public final class Color {
    private Color(int rgb) { /* ... */ }

    public static Color fromRgb(int r, int g, int b) { return new Color((r << 16) | (g << 8) | b); }
    public static Color fromHex(String hex) { return new Color(Integer.parseInt(hex.substring(1), 16)); }
}

Color red = Color.fromRgb(255, 0, 0);
```

**[⬆ back to top](#table-of-contents)**

### Item 2: Consider a builder when faced with many constructor parameters

Telescoping constructors are unreadable, and the JavaBeans (setter) pattern leaves objects in inconsistent, mutable states. The Builder pattern combines the safety of constructors with readable, named parameters — ideal when many parameters are optional.

**Bad:**

```java
// Telescoping constructor: which argument is which?
public NutritionFacts(int servingSize, int servings, int calories,
                      int fat, int sodium, int carbohydrate) { /* ... */ }

NutritionFacts cola = new NutritionFacts(240, 8, 100, 0, 35, 27);
```

**Good:**

```java
// Builder: readable call site, immutable result, validation in build().
NutritionFacts cola = new NutritionFacts.Builder(240, 8)
        .calories(100)
        .sodium(35)
        .carbohydrate(27)
        .build();
```

**[⬆ back to top](#table-of-contents)**

### Item 3: Enforce the singleton property with a private constructor or an enum type

A single-element enum is the best way to implement a singleton: it is concise, provides the serialization machinery for free, and is immune to reflection and multiple-instantiation attacks.

**Bad:**

```java
// Public-field singleton: a privileged caller can break it via reflection,
// and correct serialization requires extra work (readResolve).
public class Elvis {
    public static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
}
```

**Good:**

```java
// Single-element enum: concise, serialization- and reflection-safe.
public enum Elvis {
    INSTANCE;

    public void leaveTheBuilding() { /* ... */ }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 4: Enforce noninstantiability with a private constructor

Utility classes that group static methods should never be instantiated. Making the class `abstract` does not work (it can be subclassed and the subclass instantiated). Provide a single private constructor that throws.

**Bad:**

```java
// abstract does NOT prevent instantiation — a subclass can still be created.
public abstract class StringUtils {
    public static boolean isBlank(String s) { /* ... */ return false; }
}
```

**Good:**

```java
// Private throwing constructor: uninstantiable and unsubclassable.
public final class StringUtils {
    private StringUtils() {
        throw new AssertionError("No StringUtils instances for you!");
    }
    public static boolean isBlank(String s) { /* ... */ return false; }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 5: Prefer dependency injection to hardwiring resources

When a class's behavior is parameterized by an underlying resource, do not hardwire it with a static utility or singleton. Inject the resource through the constructor; this yields flexible, reusable, testable classes.

**Bad:**

```java
// Hardwired dependency: cannot swap dictionaries, hard to test.
public class SpellChecker {
    private static final Lexicon DICTIONARY = new EnglishLexicon();
    public static boolean isValid(String word) { /* ... */ return true; }
}
```

**Good:**

```java
// Inject the resource: flexible and testable.
public class SpellChecker {
    private final Lexicon dictionary;

    public SpellChecker(Lexicon dictionary) {
        this.dictionary = Objects.requireNonNull(dictionary);
    }
    public boolean isValid(String word) { /* ... */ return true; }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 6: Avoid creating unnecessary objects

Reuse a single immutable object rather than creating functionally identical ones. Watch for hidden costs: recompiling a `Pattern` on every call, and autoboxing inside hot loops.

**Bad:**

```java
// Recompiles the regex on every call; autoboxes a billion times.
static boolean isRomanNumeral(String s) {
    return s.matches("^(?=.)M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");
}

Long sum = 0L;
for (long i = 0; i < Integer.MAX_VALUE; i++) {
    sum += i; // unboxes/boxes sum on every iteration
}
```

**Good:**

```java
// Compile the Pattern once; keep arithmetic on primitives.
private static final Pattern ROMAN =
        Pattern.compile("^(?=.)M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");

static boolean isRomanNumeral(String s) {
    return ROMAN.matcher(s).matches();
}

long sum = 0L;
for (long i = 0; i < Integer.MAX_VALUE; i++) {
    sum += i;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 7: Eliminate obsolete object references

In code that manages its own memory (e.g., a stack backed by an array), references to popped elements linger and prevent garbage collection. Null out obsolete references. Also be wary of caches and listener/callback registrations.

**Bad:**

```java
// The popped element is still referenced by the array — a memory leak.
public Object pop() {
    if (size == 0) throw new EmptyStackException();
    return elements[--size];
}
```

**Good:**

```java
// Clear the slot so the garbage collector can reclaim the object.
public Object pop() {
    if (size == 0) throw new EmptyStackException();
    Object result = elements[--size];
    elements[size] = null; // eliminate obsolete reference
    return result;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 8: Avoid finalizers and cleaners

Finalizers are unpredictable, dangerous, and slow; cleaners are less dangerous but still unpredictable. Never rely on either for time-critical cleanup or to update persistent state. Implement `AutoCloseable` and close explicitly; use a cleaner only as a safety net.

**Bad:**

```java
// Finalizer may run arbitrarily late, or never. Native resources leak.
@Override
protected void finalize() throws Throwable {
    closeNativeHandle();
}
```

**Good:**

```java
// AutoCloseable + try-with-resources gives deterministic cleanup.
public class Room implements AutoCloseable {
    @Override public void close() { releaseResource(); }
}

try (Room room = new Room()) {
    // use room; close() runs deterministically on exit
}
```

**[⬆ back to top](#table-of-contents)**

### Item 9: Prefer try-with-resources to try-finally

Nested `try-finally` blocks are verbose and, worse, an exception thrown by `close()` can mask the original exception. Try-with-resources is shorter, closes resources correctly, and suppresses (rather than hides) secondary exceptions.

**Bad:**

```java
// Verbose; if both copy and close() throw, the real cause is lost.
InputStream in = new FileInputStream(src);
try {
    OutputStream out = new FileOutputStream(dst);
    try {
        transfer(in, out);
    } finally {
        out.close();
    }
} finally {
    in.close();
}
```

**Good:**

```java
// Concise; the original exception is preserved, close() exceptions suppressed.
try (InputStream in = new FileInputStream(src);
     OutputStream out = new FileOutputStream(dst)) {
    transfer(in, out);
}
```

**[⬆ back to top](#table-of-contents)**

## Chapter 3: Methods Common to All Objects

### Item 10: Obey the general contract when overriding equals

Override `equals` only when a class has a notion of logical equality. When you do, honor the contract: it must be reflexive, symmetric, transitive, consistent, and return false for null. Follow the recipe — `==` self-check, `instanceof` test, cast, then compare significant fields.

**Bad:**

```java
// Tries to interoperate with String — breaks symmetry.
@Override public boolean equals(Object o) {
    if (o instanceof CaseInsensitiveString)
        return s.equalsIgnoreCase(((CaseInsensitiveString) o).s);
    if (o instanceof String)                 // cis.equals(str) != str.equals(cis)
        return s.equalsIgnoreCase((String) o);
    return false;
}
```

**Good:**

```java
// Compare only against the same type; the contract holds.
@Override public boolean equals(Object o) {
    if (o == this) return true;
    if (!(o instanceof CaseInsensitiveString)) return false;
    CaseInsensitiveString cis = (CaseInsensitiveString) o;
    return s.equalsIgnoreCase(cis.s);
}
```

**[⬆ back to top](#table-of-contents)**

### Item 11: Always override hashCode when you override equals

Equal objects must have equal hash codes. Omitting `hashCode` breaks every hash-based collection (`HashMap`, `HashSet`). Combine significant fields with the `31 * result + fieldHash` recipe, or use `Objects.hash` when performance is not critical.

**Bad:**

```java
// equals overridden, hashCode not — the key "vanishes" from a HashMap.
public final class PhoneNumber {
    @Override public boolean equals(Object o) { /* compares all fields */ return true; }
    // inherits Object.hashCode() → identity-based, inconsistent with equals
}
```

**Good:**

```java
@Override public int hashCode() {
    int result = Short.hashCode(areaCode);
    result = 31 * result + Short.hashCode(prefix);
    result = 31 * result + Short.hashCode(lineNum);
    return result;
    // concise alternative: return Objects.hash(areaCode, prefix, lineNum);
}
```

**[⬆ back to top](#table-of-contents)**

### Item 12: Always override toString

`Object.toString` returns something like `PhoneNumber@163b91`, which is useless in logs and debuggers. Provide a `toString` that returns all the interesting information in a readable form, and document whether the format is guaranteed.

**Bad:**

```java
// Default toString: "PhoneNumber@163b91" — no useful information.
PhoneNumber pn = new PhoneNumber(707, 867, 5309);
System.out.println(pn);
```

**Good:**

```java
@Override public String toString() {
    return String.format("%03d-%03d-%04d", areaCode, prefix, lineNum); // 707-867-5309
}
```

**[⬆ back to top](#table-of-contents)**

### Item 13: Override clone judiciously

`Cloneable` is a broken mixin: it changes `Object.clone`'s behavior without declaring a `clone` method, produces shallow copies that share mutable internals, and conflicts with final fields. Prefer a copy constructor or copy factory instead.

**Bad:**

```java
// Cloneable/clone is easy to get wrong (shallow copy, casts, final fields).
public class Stack implements Cloneable {
    @Override public Stack clone() {
        try { return (Stack) super.clone(); } // shares the elements array!
        catch (CloneNotSupportedException e) { throw new AssertionError(); }
    }
}
```

**Good:**

```java
// A copy constructor (or static copy factory) is simpler and safe.
public Stack(Stack original) {
    this.elements = original.elements.clone();
    this.size = original.size;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 14: Consider implementing Comparable

Implement `Comparable` for value classes with a natural ordering to unlock sorting, searching, and ordered collections. Obey the contract, and build comparators from `Comparator` factory methods rather than error-prone subtraction.

**Bad:**

```java
// Subtraction-based comparison can overflow and violate the contract.
Comparator<Integer> byValue = (a, b) -> a - b; // overflows for extreme values
```

**Good:**

```java
private static final Comparator<PhoneNumber> COMPARATOR =
        Comparator.comparingInt((PhoneNumber pn) -> pn.areaCode)
                  .thenComparingInt(pn -> pn.prefix)
                  .thenComparingInt(pn -> pn.lineNum);

@Override public int compareTo(PhoneNumber pn) {
    return COMPARATOR.compare(this, pn);
}
```

**[⬆ back to top](#table-of-contents)**

## Chapter 4: Classes and Interfaces

### Item 15: Minimize the accessibility of classes and members

Information hiding decouples components so they can be developed, tested, and changed independently. Make each class and member as inaccessible as the design allows: default to `private`, widen only when necessary. Never make a public class's fields public, and never expose a mutable array through a public field or accessor.

**Bad:**

```java
// A public, mutable array constant: any client can rewrite its contents.
public class Permissions {
    public static final String[] PERMITTED = { "read", "write" };
}
```

**Good:**

```java
// Keep the array private; expose an immutable view.
public class Permissions {
    private static final String[] PERMITTED = { "read", "write" };
    public static List<String> permitted() {
        return Collections.unmodifiableList(Arrays.asList(PERMITTED));
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 16: In public classes, use accessor methods, not public fields

If a class is accessible outside its package, exposing raw fields locks you into that representation forever and forbids enforcing invariants or side effects on access. Provide accessor (and where appropriate mutator) methods. Package-private or private nested classes may expose fields when convenient.

**Bad:**

```java
// Public class with public fields — no encapsulation, no invariants.
public class Point {
    public double x;
    public double y;
}
```

**Good:**

```java
// Accessors let you change the internal representation later without breaking clients.
public class Point {
    private double x, y;
    public Point(double x, double y) { this.x = x; this.y = y; }
    public double getX() { return x; }
    public double getY() { return y; }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 17: Minimize mutability

Immutable objects are simple, inherently thread-safe, and freely shareable. To make a class immutable: provide no mutators, ensure the class can't be extended (make it `final`), make all fields `private final`, and defensively copy any mutable components.

**Bad:**

```java
// Mutable value class: aliasing surprises and not thread-safe.
public class Complex {
    private double re, im;
    public void setRe(double re) { this.re = re; }
    public Complex add(Complex c) { re += c.re; im += c.im; return this; } // mutates!
}
```

**Good:**

```java
// Immutable: each operation returns a new instance; safe to share.
public final class Complex {
    private final double re, im;
    public Complex(double re, double im) { this.re = re; this.im = im; }
    public Complex plus(Complex c) { return new Complex(re + c.re, im + c.im); }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 18: Favor composition over inheritance

Inheritance across package boundaries breaks encapsulation: a subclass depends on the superclass's self-use, which can change between releases. Instead of extending, hold an instance of the existing class (composition) and forward to it.

**Bad:**

```java
// HashSet.addAll() calls add() internally, so this double-counts.
public class CountingSet<E> extends HashSet<E> {
    private int added = 0;
    @Override public boolean add(E e) { added++; return super.add(e); }
    @Override public boolean addAll(Collection<? extends E> c) {
        added += c.size();          // plus the per-element add() calls → wrong
        return super.addAll(c);
    }
}
```

**Good:**

```java
// Forwarding wrapper: independent of the wrapped Set's implementation details.
public class CountingSet<E> extends ForwardingSet<E> {
    private int added = 0;
    public CountingSet(Set<E> s) { super(s); }
    @Override public boolean add(E e) { added++; return super.add(e); }
    @Override public boolean addAll(Collection<? extends E> c) {
        added += c.size();
        return super.addAll(c);
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 19: Design and document for inheritance or else prohibit it

A class designed for inheritance must document its self-use of overridable methods and must never call an overridable method from a constructor (the override runs before the subclass is initialized). If you have not designed and documented for inheritance, prohibit it — make the class `final` or its constructors private.

**Bad:**

```java
// Constructor calls an overridable method before the subclass is initialized.
public class Super {
    public Super() { overrideMe(); }
    public void overrideMe() { }
}
public final class Sub extends Super {
    private final Instant instant = Instant.now();
    @Override public void overrideMe() { System.out.println(instant); } // prints null
}
```

**Good:**

```java
// If not engineered for subclassing, forbid it outright.
public final class Value {
    // final class → safe from fragile-base-class surprises
}
```

**[⬆ back to top](#table-of-contents)**

### Item 20: Prefer interfaces to abstract classes

Because Java permits only single inheritance, an abstract class is a heavy commitment. Interfaces let classes implement multiple types, can be retrofitted onto existing classes, and support mixins. Pair an interface with a skeletal implementation (`AbstractXxx`) to provide implementation help without claiming the inheritance slot.

**Bad:**

```java
// Forcing clients to extend an abstract class consumes their single superclass.
public abstract class AbstractSinger {
    public abstract void sing(Song s);
}
```

**Good:**

```java
// Interface (with defaults) defines the type; a skeletal class is optional help.
public interface Singer {
    void sing(Song s);
    default void warmUp() { /* shared behavior */ }
}
public abstract class AbstractSinger implements Singer { /* skeletal helpers */ }
```

**[⬆ back to top](#table-of-contents)**

### Item 21: Design interfaces for posterity

Default methods can add behavior to an existing interface, but they are forced onto every current implementation without the author's consent and may violate an implementor's invariants. Do not assume a default method suits all implementors; design defaults conservatively and test against real implementations before release.

**Bad:**

```java
// A default added to a widely implemented interface can break implementors
// that maintain extra invariants (e.g., a synchronized wrapper).
public interface Collection2<E> extends Iterable<E> {
    default boolean removeIf(Predicate<? super E> filter) {
        boolean removed = false;
        for (Iterator<E> it = iterator(); it.hasNext(); )
            if (filter.test(it.next())) { it.remove(); removed = true; }
        return removed; // unsafe if a subclass requires external locking
    }
}
```

**Good:**

```java
// Avoid adding defaults to existing interfaces unless universally safe; when
// you must, document the contract and let implementors override (as
// Collections.synchronizedCollection overrides removeIf to lock).
public interface Collection2<E> extends Iterable<E> {
    /** Implementations needing locking MUST override and synchronize. */
    default boolean removeIf(Predicate<? super E> filter) { /* documented default */ return false; }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 22: Use interfaces only to define types

An interface should define a type that tells clients what they can do with instances. The "constant interface" anti-pattern — an interface containing only `static final` fields — abuses interfaces and leaks an implementation detail into a class's exported API. Put constants in a utility class or enum.

**Bad:**

```java
// Constant interface: implementing it pollutes the class's public API forever.
public interface PhysicalConstants {
    double AVOGADRO   = 6.022_140_857e23;
    double BOLTZMANN  = 1.380_648_52e-23;
}
```

**Good:**

```java
// Noninstantiable utility class (or an enum) holds the constants.
public final class PhysicalConstants {
    private PhysicalConstants() { }
    public static final double AVOGADRO  = 6.022_140_857e23;
    public static final double BOLTZMANN = 1.380_648_52e-23;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 23: Prefer class hierarchies to tagged classes

A tagged class — one class with a "kind" field and a `switch` over it — is verbose, error-prone, and memory-inefficient (fields used by only some kinds). Replace it with a class hierarchy where each subclass models one kind and overrides the relevant methods.

**Bad:**

```java
// Tagged class: bloated, switch on the tag, fields used only for some shapes.
class Figure {
    enum Shape { RECTANGLE, CIRCLE }
    final Shape shape;
    double length, width; // rectangle only
    double radius;        // circle only
    double area() {
        switch (shape) {
            case RECTANGLE: return length * width;
            case CIRCLE:    return Math.PI * (radius * radius);
            default:        throw new AssertionError(shape);
        }
    }
}
```

**Good:**

```java
// Hierarchy: each subclass carries only its own state and behavior.
abstract class Figure { abstract double area(); }

class Rectangle extends Figure {
    final double length, width;
    Rectangle(double length, double width) { this.length = length; this.width = width; }
    @Override double area() { return length * width; }
}

class Circle extends Figure {
    final double radius;
    Circle(double radius) { this.radius = radius; }
    @Override double area() { return Math.PI * (radius * radius); }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 24: Favor static member classes over nonstatic

A nonstatic member class holds an implicit reference to its enclosing instance, which costs time and space and can prevent the enclosing instance from being garbage-collected. If a member class does not need access to the enclosing instance, always declare it `static`.

**Bad:**

```java
// Nonstatic member class pins the whole enclosing instance in memory.
public class Cache {
    private class Entry {        // implicit Cache.this reference
        Object key, value;
    }
}
```

**Good:**

```java
// Static nested class: no enclosing-instance reference.
public class Cache {
    private static class Entry {
        Object key, value;
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 25: Limit source files to a single top-level class

Defining multiple top-level classes in one source file gains nothing and risks disaster: the compiler may accept conflicting definitions and the result can depend on the order files are passed to `javac`. Keep one top-level class per file; nest with static member classes if you want to group them.

**Bad:**

```java
// File: Utensil.java — two top-level classes. Behavior depends on compile order.
class Utensil { static final String NAME = "pan"; }
class Dessert { static final String NAME = "cake"; }
```

**Good:**

```java
// File: Utensil.java — one top-level class; group helpers as static members.
public class Utensil {
    static final String NAME = "pan";
    static class Dessert { static final String NAME = "cake"; }
}
```

**[⬆ back to top](#table-of-contents)**

## Chapter 5: Generics

### Item 26: Don't use raw types

A raw type (`List`) opts out of generics entirely: you lose all compile-time type checking and invite `ClassCastException` at runtime. Use parameterized types. When the element type is unknown, use `List<?>` (unbounded wildcard); to hold arbitrary objects, use `List<Object>`.

**Bad:**

```java
// Raw type accepts anything; the error surfaces far away, at runtime.
private final List stamps = new ArrayList();
stamps.add(new Coin());                 // compiles
Stamp s = (Stamp) stamps.get(0);        // ClassCastException
```

**Good:**

```java
// Parameterized type: the compiler enforces the element type immediately.
private final List<Stamp> stamps = new ArrayList<>();
stamps.add(new Stamp());
// stamps.add(new Coin());              // won't compile — bug caught at the source
```

**[⬆ back to top](#table-of-contents)**

### Item 27: Eliminate unchecked warnings

Every unchecked warning is a potential `ClassCastException`. Eliminate all you can. When you can *prove* a cast is safe, suppress the warning with `@SuppressWarnings("unchecked")` on the narrowest possible scope, and add a comment explaining why it is safe.

**Bad:**

```java
// Suppressing on the whole method hides any future unchecked warnings too.
@SuppressWarnings("unchecked")
public <T> T[] toArray(T[] a) {
    /* much code */
    return a;
}
```

**Good:**

```java
// Suppress on a local variable only, with a justification.
public <T> T[] toArray(T[] a) {
    if (a.length < size) {
        // The created array is of type T[], matching a.getClass(), so this is safe.
        @SuppressWarnings("unchecked")
        T[] result = (T[]) Arrays.copyOf(elements, size, a.getClass());
        return result;
    }
    return a;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 28: Prefer lists to arrays

Arrays are covariant and reified; generics are invariant and erased. Mixing them yields errors that surface only at runtime. Prefer `List<E>` over `E[]`: you trade a little conciseness and speed for type safety caught at compile time.

**Bad:**

```java
// Covariant arrays compile but fail at runtime.
Object[] objects = new Long[1];
objects[0] = "I don't fit"; // ArrayStoreException
```

**Good:**

```java
// Invariant lists turn the same mistake into a compile-time error.
List<Object> objects = new ArrayList<Long>(); // does not compile — caught early
```

**[⬆ back to top](#table-of-contents)**

### Item 29: Favor generic types

Generify your own types so clients get compile-time safety and need no casts. Introduce a type parameter and replace `Object` with it; an `@SuppressWarnings`-justified cast in the constructor is the usual way to back the type with an array.

**Bad:**

```java
// Object-based container: clients must cast, risking ClassCastException.
public class Stack {
    private Object[] elements;
    public Object pop() { /* ... */ return elements[--size]; }
}
String s = (String) stack.pop();
```

**Good:**

```java
// Generic container: type-safe, no client casts.
public class Stack<E> {
    private E[] elements;
    @SuppressWarnings("unchecked") // only ever holds E instances
    public Stack() { elements = (E[]) new Object[16]; }
    public E pop() {
        E e = elements[--size];
        elements[size] = null;
        return e;
    }
}
String s = stack.pop();
```

**[⬆ back to top](#table-of-contents)**

### Item 30: Favor generic methods

Static utility methods that operate on parameterized types should themselves be generic. Declare the type parameter list before the return type so the compiler can infer types and clients avoid casts.

**Bad:**

```java
// Raw types: unsafe and forces casts on the caller.
public static Set union(Set s1, Set s2) {
    Set result = new HashSet(s1);
    result.addAll(s2);
    return result;
}
```

**Good:**

```java
// Generic method: type-safe and cast-free.
public static <E> Set<E> union(Set<E> s1, Set<E> s2) {
    Set<E> result = new HashSet<>(s1);
    result.addAll(s2);
    return result;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 31: Use bounded wildcards to increase API flexibility

Invariant parameters reject obviously safe calls. Apply PECS — *Producer-`extends`, Consumer-`super`*: use `? extends E` for a parameter that produces `E` values and `? super E` for one that consumes them.

**Bad:**

```java
// Invariant parameters: a Stack<Number> can't accept an Iterable<Integer>.
public void pushAll(Iterable<E> src) { for (E e : src) push(e); }
public void popAll(Collection<E> dst) { while (!isEmpty()) dst.add(pop()); }
```

**Good:**

```java
// PECS: producer extends, consumer super — flexible and still type-safe.
public void pushAll(Iterable<? extends E> src) { for (E e : src) push(e); }
public void popAll(Collection<? super E> dst) { while (!isEmpty()) dst.add(pop()); }
```

**[⬆ back to top](#table-of-contents)**

### Item 32: Combine generics and varargs judiciously

Generic varargs create a generic array internally, which is unsafe (heap pollution). If your method is genuinely typesafe — it only reads the array and never lets it escape — document and assert that with `@SafeVarargs`. Never store into the varargs array or return a reference to it.

**Bad:**

```java
// Returning the generic varargs array leaks an unsafe array to the caller.
static <T> T[] toArray(T... args) { return args; }
```

**Good:**

```java
// Read-only use of the varargs array, marked @SafeVarargs.
@SafeVarargs
static <T> List<T> flatten(List<? extends T>... lists) {
    List<T> result = new ArrayList<>();
    for (List<? extends T> list : lists)
        result.addAll(list); // only reads; array never escapes
    return result;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 33: Consider typesafe heterogeneous containers

When you need to store values of many different types, parameterize the *key* rather than the container. A `Class<T>` object used as a type token gives each entry its own compile-time type.

**Bad:**

```java
// A single type parameter forces Object and unchecked casts.
Map<String, Object> favorites = new HashMap<>();
favorites.put("age", 42);
Integer age = (Integer) favorites.get("age");
```

**Good:**

```java
// Class<T> keys make each entry individually typesafe.
public class Favorites {
    private final Map<Class<?>, Object> map = new HashMap<>();
    public <T> void put(Class<T> type, T instance) { map.put(type, type.cast(instance)); }
    public <T> T get(Class<T> type) { return type.cast(map.get(type)); }
}
favorites.put(Integer.class, 42);
int age = favorites.get(Integer.class); // no cast
```

**[⬆ back to top](#table-of-contents)**

## Chapter 6: Enums and Annotations

### Item 34: Use enums instead of int constants

The `int` enum pattern provides no type safety, no namespace, and prints as meaningless integers. Enum types are full-fledged classes: typesafe, namespaced, and able to carry fields and behavior.

**Bad:**

```java
// int enum pattern: no type safety; collisions are silent.
public static final int APPLE_FUJI    = 0;
public static final int ORANGE_NAVEL  = 0; // same value — bugs compile cleanly
```

**Good:**

```java
// Enum type: typesafe, with associated data and methods.
public enum Planet {
    MERCURY(3.302e23, 2.439e6), EARTH(5.975e24, 6.378e6);
    private final double mass, radius;
    Planet(double mass, double radius) { this.mass = mass; this.radius = radius; }
    double surfaceGravity() { return 6.67300e-11 * mass / (radius * radius); }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 35: Use instance fields instead of ordinals

Never derive associated values from `ordinal()` — it couples meaning to declaration order, so reordering, removing, or adding constants silently breaks the code. Store the value in an instance field instead.

**Bad:**

```java
// Fragile: depends entirely on declaration order.
public enum Ensemble {
    SOLO, DUET, TRIO, QUARTET;
    public int numberOfMusicians() { return ordinal() + 1; }
}
```

**Good:**

```java
// Robust: the value is stored explicitly.
public enum Ensemble {
    SOLO(1), DUET(2), TRIO(3), QUARTET(4);
    private final int numberOfMusicians;
    Ensemble(int size) { this.numberOfMusicians = size; }
    public int numberOfMusicians() { return numberOfMusicians; }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 36: Use EnumSet instead of bit fields

Bit fields built from `int` constants are unreadable, untypesafe, and hard to iterate. `EnumSet` gives the same compactness and performance with full type safety and a clean API.

**Bad:**

```java
// Bit fields: cryptic, untypesafe, no easy iteration.
public static final int STYLE_BOLD   = 1 << 0;
public static final int STYLE_ITALIC = 1 << 1;
void applyStyles(int styles) { /* ... */ }
applyStyles(STYLE_BOLD | STYLE_ITALIC);
```

**Good:**

```java
// EnumSet: typesafe, readable, and internally a bit vector.
public enum Style { BOLD, ITALIC, UNDERLINE }
void applyStyles(Set<Style> styles) { /* ... */ }
applyStyles(EnumSet.of(Style.BOLD, Style.ITALIC));
```

**[⬆ back to top](#table-of-contents)**

### Item 37: Use EnumMap instead of ordinal indexing

Indexing an array by `ordinal()` requires unchecked casts, gives no type safety, and breaks if constants change. `EnumMap` (or a nested `EnumMap` for two-dimensional relationships) is clearer and just as fast.

**Bad:**

```java
// Array indexed by ordinal: unchecked cast and fragile ordering coupling.
Set<Plant>[] plantsByLifeCycle = new Set[LifeCycle.values().length];
plantsByLifeCycle[plant.lifeCycle.ordinal()].add(plant);
```

**Good:**

```java
// EnumMap: typesafe and self-explanatory.
Map<LifeCycle, Set<Plant>> plantsByLifeCycle = new EnumMap<>(LifeCycle.class);
for (LifeCycle lc : LifeCycle.values()) plantsByLifeCycle.put(lc, new HashSet<>());
plantsByLifeCycle.get(plant.lifeCycle).add(plant);
```

**[⬆ back to top](#table-of-contents)**

### Item 38: Emulate extensible enums with interfaces

Enum types cannot be extended, which is usually fine — but for cases like operation codes where users should add their own constants, have the enum implement an interface. Clients program to the interface, so any enum implementing it interoperates.

**Bad:**

```java
// Enums are not extensible; you cannot add operations by subclassing.
public enum BasicOperation { PLUS, MINUS } // no way to bolt on EXP, LOG, ...
```

**Good:**

```java
// Program to an interface; multiple enums can implement it.
public interface Operation { double apply(double x, double y); }

public enum BasicOperation implements Operation {
    PLUS  { public double apply(double x, double y) { return x + y; } },
    MINUS { public double apply(double x, double y) { return x - y; } };
}
public enum ExtendedOperation implements Operation {
    EXP { public double apply(double x, double y) { return Math.pow(x, y); } };
}
```

**[⬆ back to top](#table-of-contents)**

### Item 39: Prefer annotations to naming patterns

Naming patterns (such as test methods that must start with "test") are fragile: a typo fails silently, you can't constrain where the name applies, and you can't pass parameters. Annotations are explicit, tool-checkable, and parameterizable.

**Bad:**

```java
// A misspelling like "tsetX" is silently ignored by the framework.
public void testSafetyOverride() { /* discovered only by name prefix */ }
```

**Good:**

```java
// An annotation is explicit and verifiable.
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Test { }

@Test public void safetyOverride() { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Item 40: Consistently use the Override annotation

Annotate every method intended to override a supertype declaration with `@Override`. The compiler then flags any method that fails to actually override (for example, an accidental overload), catching a whole class of subtle bugs.

**Bad:**

```java
// Intended to override equals(Object) but overloads equals(Bigram) — silent bug.
public boolean equals(Bigram b) {
    return b.first == first && b.second == second;
}
```

**Good:**

```java
// @Override turns the mistake into a compile error until the signature is right.
@Override public boolean equals(Object o) {
    if (!(o instanceof Bigram)) return false;
    Bigram b = (Bigram) o;
    return b.first == first && b.second == second;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 41: Use marker interfaces to define types

A marker interface (like `Serializable`) defines a type implemented by marked classes, so the compiler can enforce constraints at compile time. A marker *annotation* cannot do this. Use a marker interface when you want a type usable in method signatures; use a marker annotation for non-class elements or annotation-based frameworks.

**Bad:**

```java
// Marker annotation can't serve as a parameter type — checks happen at runtime.
@Retention(RetentionPolicy.RUNTIME)
public @interface MyMarker { }
void write(Object obj) { /* must reflectively verify obj is marked */ }
```

**Good:**

```java
// Marker interface defines a type, enabling compile-time enforcement.
public interface MyMarker { }
void write(MyMarker obj) { /* only marked types compile */ }
```

**[⬆ back to top](#table-of-contents)**

## Chapter 7: Lambdas and Streams

### Item 42: Prefer lambdas to anonymous classes

For instances of functional interfaces (single abstract method), lambdas are far more concise than anonymous classes and make the intent obvious. Omit parameter types unless they aid clarity, and keep lambdas short — ideally one line.

**Bad:**

```java
// Anonymous class: boilerplate drowns the one expression that matters.
Collections.sort(words, new Comparator<String>() {
    public int compare(String s1, String s2) {
        return Integer.compare(s1.length(), s2.length());
    }
});
```

**Good:**

```java
// Lambda (or a comparator construction method) — concise and readable.
Collections.sort(words, (s1, s2) -> Integer.compare(s1.length(), s2.length()));
words.sort(Comparator.comparingInt(String::length));
```

**[⬆ back to top](#table-of-contents)**

### Item 43: Prefer method references to lambdas

Where a lambda merely calls an existing method, a method reference is usually shorter and clearer. Keep the lambda when it is actually more readable (for example, when the method lives in the same class and a reference would be cryptic).

**Bad:**

```java
// Lambda that just forwards to an existing method.
map.merge(key, 1, (count, increment) -> count + increment);
```

**Good:**

```java
// Method reference says the same thing with less noise.
map.merge(key, 1, Integer::sum);
```

**[⬆ back to top](#table-of-contents)**

### Item 44: Favor the use of standard functional interfaces

The `java.util.function` package supplies 43 general-purpose interfaces (`Function`, `Predicate`, `Supplier`, `Consumer`, `UnaryOperator`, …). Prefer them over writing your own; a custom functional interface is justified only when it adds a meaningful name or contract.

**Bad:**

```java
// A bespoke interface that merely duplicates Predicate<T>.
@FunctionalInterface
interface Condition<T> { boolean test(T t); }
<T> void filter(List<T> list, Condition<T> c) { /* ... */ }
```

**Good:**

```java
// Reuse the standard interface — familiar, interoperable, less to maintain.
<T> void filter(List<T> list, Predicate<T> c) { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Item 45: Use streams judiciously

Streams can clarify a data pipeline or obscure it. Use them where they make code easier to read; do not cram everything into one stream. Extract helper methods for non-trivial mapping steps, name lambda parameters meaningfully, and avoid streams for `char` processing.

**Bad:**

```java
// One monolithic stream that no one can read or maintain.
words.collect(groupingBy(w -> w.chars().sorted()
    .collect(StringBuilder::new, (sb, c) -> sb.append((char) c), StringBuilder::append)
    .toString())).values().stream().filter(g -> g.size() >= min)
    .map(g -> g.size() + ": " + g).forEach(System.out::println);
```

**Good:**

```java
// Extract a helper; use the stream only where it clarifies.
Map<String, Set<String>> groups = words.collect(groupingBy(Anagrams::alphabetize, toSet()));
groups.values().stream()
      .filter(group -> group.size() >= min)
      .forEach(group -> System.out.println(group.size() + ": " + group));
```

**[⬆ back to top](#table-of-contents)**

### Item 46: Prefer side-effect-free functions in streams

The essence of a stream is a pipeline of pure functions. A `forEach` that mutates external state is a sign you are using streams as an imperative loop; do the work with a collector (`toList`, `toMap`, `groupingBy`, `counting`, …) instead, and reserve `forEach` for reporting results.

**Bad:**

```java
// forEach mutating an external map — imperative code wearing a stream costume.
Map<String, Long> freq = new HashMap<>();
words.forEach(w -> freq.merge(w.toLowerCase(), 1L, Long::sum));
```

**Good:**

```java
// A collector expresses the computation declaratively.
Map<String, Long> freq = words.collect(
        groupingBy(String::toLowerCase, counting()));
```

**[⬆ back to top](#table-of-contents)**

### Item 47: Prefer Collection to Stream as a return type

`Stream` does not extend `Iterable`, so a stream-returning method cannot be used in a for-each loop. When a method returns a sequence for public use, return `Collection` (or a purpose-built one) so callers can both iterate and stream. Return `Stream` only when you know callers want streams.

**Bad:**

```java
// Stream return type can't be iterated with for-each.
public Stream<E> elements() { return list.stream(); }
for (E e : elements()) { } // compile error
```

**Good:**

```java
// Collection serves both for-each and stream() clients.
public Collection<E> elements() { return Collections.unmodifiableList(list); }
for (E e : elements()) { }          // ok
elements().stream().forEach(...);   // ok
```

**[⬆ back to top](#table-of-contents)**

### Item 48: Use caution when making streams parallel

Adding `parallel()` rarely helps and can cause incorrect results, liveness failures, or slowdowns — especially with `Stream.iterate` or `limit`. Parallelize only when the source splits efficiently (arrays, `ArrayList`, `IntStream.range`), the per-element work is cheap and independent, and benchmarks prove a win.

**Bad:**

```java
// Stream.iterate doesn't split; parallel() gives no speedup and may not terminate.
Stream.iterate(BigInteger.TWO, BigInteger::nextProbablePrime)
      .parallel()
      .limit(20)
      .forEach(System.out::println);
```

**Good:**

```java
// A splittable range with cheap, independent work — and measured before shipping.
long primes = LongStream.rangeClosed(2, n)
                        .parallel()
                        .filter(MyMath::isPrime)
                        .count();
```

**[⬆ back to top](#table-of-contents)**

## Chapter 8: Methods

### Item 49: Check parameters for validity

Validate parameters at the top of each public method and document the restrictions with `@throws`. Failing fast yields clear errors instead of obscure failures (or, worse, silent corruption) later. Use `Objects.requireNonNull` for null checks; use assertions for non-public methods.

**Bad:**

```java
// No validation: an invalid modulus fails deep inside, with a confusing trace.
public BigInteger mod(BigInteger m) {
    return this.remainder(m);
}
```

**Good:**

```java
/** @throws ArithmeticException if m is less than or equal to zero */
public BigInteger mod(BigInteger m) {
    if (m.signum() <= 0)
        throw new ArithmeticException("Modulus <= 0: " + m);
    return this.remainder(m);
}

public void setName(String name) {
    this.name = Objects.requireNonNull(name, "name");
}
```

**[⬆ back to top](#table-of-contents)**

### Item 50: Make defensive copies when needed

If your class accepts or returns references to mutable objects, copy them defensively so clients can't violate your invariants. Copy parameters *before* validating them, and copy mutable internals on the way out.

**Bad:**

```java
// Stores and returns the caller's mutable Date — invariants can be broken later.
public Period(Date start, Date end) { this.start = start; this.end = end; }
public Date start() { return start; }
```

**Good:**

```java
// Copy in (before the check) and copy out.
public Period(Date start, Date end) {
    this.start = new Date(start.getTime());
    this.end   = new Date(end.getTime());
    if (this.start.compareTo(this.end) > 0)
        throw new IllegalArgumentException(start + " after " + end);
}
public Date start() { return new Date(start.getTime()); }
```

**[⬆ back to top](#table-of-contents)**

### Item 51: Design method signatures carefully

Choose method names that follow convention, avoid a glut of convenience methods, and keep parameter lists short. Long runs of same-typed parameters invite transposition bugs; prefer helper types or builders, favor interfaces over classes for parameter types, and use a two-value enum instead of a `boolean`.

**Bad:**

```java
// Long, same-typed parameter list plus an opaque boolean flag.
public Booking book(int year, int month, int day,
                    int hour, int minute, boolean refundable) { /* ... */ }
```

**Good:**

```java
// Group parameters into a meaningful type; replace the boolean with an enum.
public Booking book(LocalDateTime when, FareClass fareClass) { /* ... */ }
public enum FareClass { REFUNDABLE, NON_REFUNDABLE }
```

**[⬆ back to top](#table-of-contents)**

### Item 52: Use overloading judiciously

Which overloading is invoked is decided at compile time by the static type of the arguments, which often surprises. Avoid overloadings with the same number of parameters when a call could match more than one; when in doubt, give the methods different names.

**Bad:**

```java
// Selection by compile-time type: every element classifies as "Unknown Collection".
public static String classify(Set<?> s)  { return "Set"; }
public static String classify(List<?> l) { return "List"; }
public static String classify(Collection<?> c) { return "Unknown Collection"; }
```

**Good:**

```java
// Distinct names remove the ambiguity entirely.
public static String classifySet(Set<?> s)  { return "Set"; }
public static String classifyList(List<?> l) { return "List"; }
```

**[⬆ back to top](#table-of-contents)**

### Item 53: Use varargs judiciously

Varargs allocate an array on every call and make "at least one argument" awkward to enforce. For methods that require one or more arguments, declare a mandatory first parameter followed by varargs, so the minimum is checked by the compiler.

**Bad:**

```java
// Enforcing "at least one" at runtime — poor API, fails late.
static int min(int... args) {
    if (args.length == 0) throw new IllegalArgumentException("need at least one");
    int min = args[0];
    for (int i = 1; i < args.length; i++) if (args[i] < min) min = args[i];
    return min;
}
```

**Good:**

```java
// A mandatory first parameter makes the minimum a compile-time guarantee.
static int min(int first, int... rest) {
    int min = first;
    for (int arg : rest) if (arg < min) min = arg;
    return min;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 54: Return empty collections or arrays, not nulls

A null return value forces every caller to write special-case handling and invites `NullPointerException` when they forget. Return an empty collection or array instead; reuse a shared immutable empty instance if allocation is a concern.

**Bad:**

```java
// null means "empty" — every caller must remember to check.
public List<Cheese> getCheeses() {
    return cheesesInStock.isEmpty() ? null : new ArrayList<>(cheesesInStock);
}
```

**Good:**

```java
// Always return a (possibly empty) collection — callers iterate uniformly.
public List<Cheese> getCheeses() {
    return new ArrayList<>(cheesesInStock);
}
// Arrays: return cheesesInStock.toArray(new Cheese[0]);
```

**[⬆ back to top](#table-of-contents)**

### Item 55: Return optionals judiciously

When a method may have no result and callers must handle absence, return `Optional<T>` rather than `null` or a thrown exception. Never return a `null` optional, don't wrap collections or arrays in optionals, and avoid `Optional` for performance-critical boxed primitives (use `OptionalInt`, etc.).

**Bad:**

```java
// Returns null to mean "no value" — easy for callers to mishandle.
public static <E extends Comparable<E>> E max(Collection<E> c) {
    if (c.isEmpty()) return null;
    return Collections.max(c);
}
```

**Good:**

```java
// Optional makes absence explicit and offers clean handling.
public static <E extends Comparable<E>> Optional<E> max(Collection<E> c) {
    return c.isEmpty() ? Optional.empty() : Optional.of(Collections.max(c));
}
String best = max(words).map(Object::toString).orElse("none");
```

**[⬆ back to top](#table-of-contents)**

### Item 56: Write doc comments for all exposed API elements

Precede every exported class, interface, constructor, method, and field with a doc comment. For methods, describe the contract between the method and its client: preconditions and postconditions, every `@param`, the `@return`, and each `@throws`. The first sentence is the summary, so make it count.

**Bad:**

```java
// No documented contract — clients must read the implementation to use it.
public E get(int index) { /* ... */ }
```

**Good:**

```java
/**
 * Returns the element at the specified position in this list.
 *
 * @param index index of the element to return; must be non-negative
 *              and less than {@code size()}
 * @return the element at the specified position in this list
 * @throws IndexOutOfBoundsException if the index is out of range
 */
public E get(int index) { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

## Chapter 9: General Programming

### Item 57: Minimize the scope of local variables

Declare each local variable where it is first used, with an initializer, in the narrowest scope possible. Prefer `for` and for-each loops over `while`, because they confine the loop variable to the loop body and prevent copy-paste errors.

**Bad:**

```java
// Declared early and far from use; while-loop reuse invites a copy-paste bug.
Iterator<Element> i = c.iterator();
while (i.hasNext()) doSomething(i.next());

Iterator<Element> i2 = c2.iterator();
while (i.hasNext()) doSomethingElse(i2.next()); // used i, not i2 — silent bug
```

**Good:**

```java
// Minimal scope; for-each confines each loop variable to its loop.
for (Element e : c)  doSomething(e);
for (Element e : c2) doSomethingElse(e);
```

**[⬆ back to top](#table-of-contents)**

### Item 58: Prefer for-each loops to traditional for loops

The for-each loop (`for (E e : collection)`) eliminates index and iterator boilerplate and the bugs that come with them. Use a traditional `for` only when you need the index, must remove elements via the iterator, or iterate multiple structures in parallel.

**Bad:**

```java
// Nested iterators: i.next() is called in the inner loop, exhausting the outer.
for (Iterator<Suit> i = suits.iterator(); i.hasNext(); )
    for (Iterator<Rank> j = ranks.iterator(); j.hasNext(); )
        deck.add(new Card(i.next(), j.next()));
```

**Good:**

```java
// for-each is clear and correct.
for (Suit suit : suits)
    for (Rank rank : ranks)
        deck.add(new Card(suit, rank));
```

**[⬆ back to top](#table-of-contents)**

### Item 59: Know and use the libraries

By using a standard library you benefit from the expertise of its authors and the experience of everyone who used it before you. Library code is tested, fast, and maintained — and your own code stays focused. Reinventing it usually produces something slower and buggier.

**Bad:**

```java
// Hand-rolled "random in [0, n)" — subtly biased; can return a negative number.
static int random(int n) {
    return Math.abs(rnd.nextInt()) % n; // Math.abs(Integer.MIN_VALUE) is negative
}
```

**Good:**

```java
// The library does it correctly and efficiently.
int x = ThreadLocalRandom.current().nextInt(n);
```

**[⬆ back to top](#table-of-contents)**

### Item 60: Avoid float and double if exact answers are required

`float` and `double` are binary floating-point types and cannot represent most decimal fractions exactly, so they are wrong for monetary calculations. Use `BigDecimal`, or scaled `int`/`long` (e.g., cents), when you need exact answers.

**Bad:**

```java
// Binary floating point: the result is 0.6999999999999999, not 0.70.
double funds = 1.00;
funds -= 0.10;
funds -= 0.20;
```

**Good:**

```java
// BigDecimal (or integer cents) gives exact decimal arithmetic.
BigDecimal funds = new BigDecimal("1.00")
        .subtract(new BigDecimal("0.10"))
        .subtract(new BigDecimal("0.20")); // exactly 0.70
```

**[⬆ back to top](#table-of-contents)**

### Item 61: Prefer primitive types to boxed primitives

Boxed primitives differ from primitives in three painful ways: `==` compares identity rather than value, they can be `null` (causing `NullPointerException` on auto-unboxing), and they are slower. Use primitives by default; use boxed types only for collections, generics, and reflection.

**Bad:**

```java
// == compares object identity on boxed Integers; unboxing a null throws NPE.
Comparator<Integer> cmp = (a, b) -> a > b ? 1 : (a == b ? 0 : -1); // a == b is identity
Integer answer = null;
if (answer == 42) { } // NullPointerException on unboxing
```

**Good:**

```java
// Primitives have value semantics and never NPE on unboxing.
Comparator<Integer> cmp = (a, b) -> Integer.compare(a, b);
int answer = 0;
if (answer == 42) { }
```

**[⬆ back to top](#table-of-contents)**

### Item 62: Avoid strings where other types are more appropriate

Strings are poor substitutes for other value types. Don't use a `String` when the value is really a number, an enum, or an aggregate of several fields; doing so loses type safety and invites parsing errors. Model the value with the appropriate type.

**Bad:**

```java
// Aggregating fields into a delimited string — fragile and error-prone to parse.
String compoundKey = className + "#" + id;
```

**Good:**

```java
// A real type captures the structure and gives proper equals/hashCode.
private static class Key {
    private final String className;
    private final Object id;
    // constructor, equals, hashCode ...
}
```

**[⬆ back to top](#table-of-contents)**

### Item 63: Beware the performance of string concatenation

Using the `+` operator to concatenate `n` strings in a loop is quadratic, because strings are immutable and each step copies the whole accumulated result. Use a `StringBuilder` (sized up front when you can) to build strings in linear time.

**Bad:**

```java
// Quadratic: each += copies the entire string built so far.
String result = "";
for (int i = 0; i < numItems(); i++)
    result += lineForItem(i);
```

**Good:**

```java
// Linear: append into a StringBuilder.
StringBuilder sb = new StringBuilder(numItems() * LINE_WIDTH);
for (int i = 0; i < numItems(); i++)
    sb.append(lineForItem(i));
String result = sb.toString();
```

**[⬆ back to top](#table-of-contents)**

### Item 64: Refer to objects by their interfaces

If an appropriate interface exists, use it to declare parameters, return values, variables, and fields. Your code stays flexible: you can swap the implementation by changing a single constructor call. Use a concrete class only when no suitable interface exists or you depend on class-specific features.

**Bad:**

```java
// Pinned to a concrete implementation type.
LinkedHashMap<String, Integer> scores = new LinkedHashMap<>();
```

**Good:**

```java
// Declare the interface; the implementation becomes a one-line change.
Map<String, Integer> scores = new LinkedHashMap<>();
```

**[⬆ back to top](#table-of-contents)**

### Item 65: Prefer interfaces to reflection

Core reflection (`java.lang.reflect`) sacrifices compile-time type checking, generates verbose code, and is slow. When you must create objects whose classes are unknown at compile time, instantiate them reflectively but access them through an interface or superclass known at compile time.

**Bad:**

```java
// Invoking methods reflectively: no type checking, verbose, slow.
Method add = obj.getClass().getMethod("add", Object.class);
add.invoke(obj, element);
```

**Good:**

```java
// Reflect only to instantiate; then use the object through a known interface.
Class<? extends Set<String>> cl = (Class<? extends Set<String>>) Class.forName(name);
Set<String> s = cl.getDeclaredConstructor().newInstance();
s.add(element); // ordinary, type-checked call
```

**[⬆ back to top](#table-of-contents)**

### Item 66: Use native methods judiciously

The Java Native Interface lets Java call native code, but it is rarely justified for performance today and brings real costs: native code is not memory-safe, it is platform-dependent, harder to debug, and crossing the boundary has overhead. Use native methods only for platform-specific facilities or proven, critical native libraries.

**Bad:**

```java
// Dropping to native for arithmetic the JVM already does well — unsafe and unportable.
public native BigInteger fastMultiply(BigInteger a, BigInteger b);
```

**Good:**

```java
// Use the platform library: safe, portable, and fast enough.
BigInteger product = a.multiply(b);
```

**[⬆ back to top](#table-of-contents)**

### Item 67: Optimize judiciously

Strive to write good, clear programs rather than fast ones; speed often follows from clean structure. Don't sacrifice sound architecture for performance, and design APIs and data types that don't foreclose performance later. Most importantly, measure before and after each optimization.

**Bad:**

```java
// Contorting code for an unmeasured "optimization" that may not even help.
int total = 0;
for (int i = 0, n = list.size(); i < n; i++)
    total += list.get(i).value();
```

**Good:**

```java
// Write it clearly first; profile, then tune only the proven hot spot.
int total = list.stream().mapToInt(Item::value).sum();
```

**[⬆ back to top](#table-of-contents)**

### Item 68: Adhere to generally accepted naming conventions

Follow Java's typographical and grammatical naming conventions so your code reads the way every Java programmer expects: packages in lowercase, types in `PascalCase`, methods and fields in `camelCase`, constants in `UPPER_SNAKE_CASE`, and type parameters as single capital letters.

**Bad:**

```java
// Violates conventions on every line.
class data_record {
    static final int maxCount = 10;
    void GetValue() { }
}
```

**Good:**

```java
// Conventional names — instantly familiar.
class DataRecord {
    static final int MAX_COUNT = 10;
    int getValue() { return 0; }
}
```

**[⬆ back to top](#table-of-contents)**

## Chapter 10: Exceptions

### Item 69: Use exceptions only for exceptional conditions

Exceptions are for exceptional conditions, never ordinary control flow. Using them to terminate a loop obscures intent, performs poorly, and can mask genuine bugs. A well-designed API does not force its clients to use exceptions for control flow either — provide a state-testing method or an `Optional` return instead.

**Bad:**

```java
// Abusing an exception to end a loop — cryptic, slow, and hides real errors.
try {
    int i = 0;
    while (true) range[i++].climb(); // relies on ArrayIndexOutOfBoundsException
} catch (ArrayIndexOutOfBoundsException e) {
}
```

**Good:**

```java
// An ordinary loop states the intent plainly.
for (Mountain m : range)
    m.climb();
```

**[⬆ back to top](#table-of-contents)**

### Item 70: Use checked exceptions for recoverable conditions and runtime exceptions for programming errors

Use checked exceptions for conditions from which the caller can reasonably recover, and runtime exceptions for programming errors (precondition violations). Don't use checked exceptions for situations the caller cannot handle.

**Bad:**

```java
// A checked exception for a programming error (a bad index) burdens every caller.
public Object get(int index) throws BadIndexException { /* ... */ }
```

**Good:**

```java
// Programming errors are unchecked; genuinely recoverable conditions are checked.
public Object get(int index) { // throws unchecked IndexOutOfBoundsException
    if (index < 0 || index >= size)
        throw new IndexOutOfBoundsException("index: " + index);
    return elements[index];
}
public void withdraw(long amount) throws InsufficientFundsException { /* recoverable */ }
```

**[⬆ back to top](#table-of-contents)**

### Item 71: Avoid unnecessary use of checked exceptions

Checked exceptions force callers to handle them and prevent clean use in streams and lambdas. If the caller can do nothing better than rethrow, the checked exception is just friction. Prefer returning an `Optional`, or split the operation into a state-testing method plus an unchecked operation.

**Bad:**

```java
// A checked exception the caller can only catch and rethrow adds noise everywhere.
public void action() throws SomeCheckedException { /* ... */ }

try {
    obj.action();
} catch (SomeCheckedException e) {
    throw new AssertionError(e); // caller has nothing useful to do
}
```

**Good:**

```java
// Return an Optional (or expose a state-testing method) instead of a checked exception.
public Optional<Result> tryAction() { /* ... */ return Optional.empty(); }

obj.tryAction().ifPresent(this::use);
```

**[⬆ back to top](#table-of-contents)**

### Item 72: Favor the use of standard exceptions

Reuse the standard exceptions — `IllegalArgumentException`, `IllegalStateException`, `NullPointerException`, `IndexOutOfBoundsException`, `UnsupportedOperationException`, `ConcurrentModificationException`. They make your API easier to learn and read, and keep your class count down. Don't invent an exception that duplicates one of these.

**Bad:**

```java
// A custom exception that merely duplicates IllegalArgumentException.
public class BadArgumentException extends Exception { }
if (count < 0) throw new BadArgumentException();
```

**Good:**

```java
// Reuse the appropriate standard exception, with an informative message.
if (count < 0)
    throw new IllegalArgumentException("count must be >= 0: " + count);
```

**[⬆ back to top](#table-of-contents)**

### Item 73: Throw exceptions appropriate to the abstraction

Higher layers should catch lower-level exceptions and, in their place, throw exceptions explainable in terms of the higher-level abstraction (exception translation). Chain the underlying cause so debugging information is preserved.

**Bad:**

```java
// Leaking a low-level exception couples callers to the implementation.
public Card get(int index) {
    return database.readCard(index); // propagates SQLException to every caller
}
```

**Good:**

```java
// Translate to an abstraction-appropriate exception, preserving the cause.
public Card get(int index) {
    try {
        return database.readCard(index);
    } catch (SQLException cause) {
        throw new StorageException("Unable to read card " + index, cause); // chained
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 74: Document all exceptions thrown by each method

Declare each checked exception individually and document, with the `@throws` tag, the precise conditions under which each exception (checked and unchecked) is thrown. Documenting unchecked exceptions effectively documents the method's preconditions. Never declare a method `throws Exception` or `throws Throwable`.

**Bad:**

```java
// Lumping everything under "throws Exception" tells the caller nothing.
public void process(String path) throws Exception { /* ... */ }
```

**Good:**

```java
/**
 * @throws IOException if the file cannot be read
 * @throws IllegalArgumentException if {@code path} is empty
 */
public void process(String path) throws IOException { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Item 75: Include failure-capture information in detail messages

To make a failure diagnosable from a stack trace, an exception's detail message should include the values of all parameters and fields that contributed to it. (Do not include security-sensitive data such as passwords or keys.) Capturing this information is best done in the exception's constructor.

**Bad:**

```java
// No context — impossible to tell what went wrong from the trace.
throw new IndexOutOfBoundsException();
```

**Good:**

```java
// Capture the values that caused the failure.
throw new IndexOutOfBoundsException(
        String.format("index %d not in range [%d, %d)", index, lowerBound, upperBound));
```

**[⬆ back to top](#table-of-contents)**

### Item 76: Strive for failure atomicity

A failed method invocation should leave the object in the state it was in before the call. Achieve failure atomicity by making objects immutable, by checking parameters for validity before performing any mutation, by ordering the computation so failure-prone work precedes mutation, or by writing recovery code.

**Bad:**

```java
// Mutates size before the check — a failure leaves the object corrupted.
public Object pop() {
    Object result = elements[--size];
    if (size < 0) throw new EmptyStackException(); // too late; size already wrong
    return result;
}
```

**Good:**

```java
// Validate first; a failure leaves the object exactly as it was.
public Object pop() {
    if (size == 0) throw new EmptyStackException();
    Object result = elements[--size];
    elements[size] = null;
    return result;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 77: Don't ignore exceptions

An empty `catch` block defeats the purpose of exceptions, which is to force you to handle exceptional conditions. At a minimum, log the exception. If ignoring it is genuinely the right choice, explain why in a comment and name the caught variable `ignored`.

**Bad:**

```java
// Silently swallows the failure — the bug surfaces later, far from its cause.
try {
    doRiskyThing();
} catch (SomeException e) {
}
```

**Good:**

```java
// If ignoring is truly intended, document why and name the variable accordingly.
int numColors = 4; // default; any value is acceptable here
try {
    numColors = future.get(1L, TimeUnit.SECONDS);
} catch (TimeoutException | ExecutionException ignored) {
    // Using the default is fine if the computation is slow or fails.
}
```

**[⬆ back to top](#table-of-contents)**

## Chapter 11: Concurrency

### Item 78: Synchronize access to shared mutable data

Synchronization is required not only for mutual exclusion but for *visibility*: without it, one thread may never see another thread's writes, or may see them out of order. Synchronize every access (read and write) to shared mutable data, or use `volatile` (visibility only) or atomic types where mutual exclusion is not needed.

**Bad:**

```java
// Without synchronization the worker may never observe the updated flag — infinite loop.
private static boolean stopRequested;
// worker:  while (!stopRequested) i++;
// main:    stopRequested = true;   // write may never become visible to the worker
```

**Good:**

```java
// volatile guarantees that writes are immediately visible to other threads.
private static volatile boolean stopRequested;
// worker:  while (!stopRequested) i++;
// main:    stopRequested = true;
```

**[⬆ back to top](#table-of-contents)**

### Item 79: Avoid excessive synchronization

To avoid deadlock and data corruption, never cede control to alien code — an overridable method or a client-supplied function object — while holding a lock. Do as little work as possible inside synchronized regions: take a snapshot of shared state under the lock, then operate on it outside.

**Bad:**

```java
// Invoking observer callbacks while holding the lock — alien code can deadlock.
private void notifyElementAdded(E element) {
    synchronized (observers) {
        for (SetObserver<E> o : observers)
            o.added(this, element); // alien call under the lock
    }
}
```

**Good:**

```java
// Copy the listeners under the lock, then invoke them outside it.
private void notifyElementAdded(E element) {
    List<SetObserver<E>> snapshot;
    synchronized (observers) {
        snapshot = new ArrayList<>(observers);
    }
    for (SetObserver<E> o : snapshot)
        o.added(this, element); // safe: no lock held during the alien call
}
```

**[⬆ back to top](#table-of-contents)**

### Item 80: Prefer executors, tasks, and streams to threads

Work with the Executor Framework rather than threads directly. It cleanly separates *what* runs (a `Runnable`/`Callable` task) from *how* it runs (thread pooling, scheduling, lifecycle), and provides features — graceful shutdown, futures, scheduling — that are tedious and error-prone to build by hand.

**Bad:**

```java
// Creating and starting a thread per task — no pooling, no lifecycle control.
for (Runnable task : tasks)
    new Thread(task).start();
```

**Good:**

```java
// Submit tasks to an executor; it owns and reuses the threads.
ExecutorService exec = Executors.newFixedThreadPool(N);
for (Runnable task : tasks)
    exec.execute(task);
exec.shutdown();
```

**[⬆ back to top](#table-of-contents)**

### Item 81: Prefer concurrency utilities to wait and notify

The high-level utilities in `java.util.concurrent` — concurrent collections (`ConcurrentHashMap`), synchronizers (`CountDownLatch`, `Semaphore`), and executors — are easier to use correctly than `wait`/`notify`. Prefer them. If you must use `wait`, always call it inside a loop that re-tests the condition.

**Bad:**

```java
// Low-level wait/notify — easy to get wrong (missed signals, guarding mistakes).
synchronized (lock) {
    while (!ready) lock.wait();
}
```

**Good:**

```java
// A high-level synchronizer expresses the coordination clearly and safely.
CountDownLatch ready = new CountDownLatch(workerCount);
// each worker calls: ready.countDown();
ready.await(); // proceeds once all workers have signaled
```

**[⬆ back to top](#table-of-contents)**

### Item 82: Document thread safety

How a class behaves under concurrent use is part of its contract, so document its thread-safety level: immutable, unconditionally thread-safe, conditionally thread-safe, not thread-safe, or thread-hostile. The presence of the `synchronized` modifier is an implementation detail, not API. For unconditionally thread-safe classes, lock on a private final object so clients can't interfere.

**Bad:**

```java
// Thread safety unstated; locking on the instance lets clients hold your lock.
public synchronized void op() { /* clients can also synchronize on this */ }
```

**Good:**

```java
/** This class is unconditionally thread-safe. */
private final Object lock = new Object();
public void op() {
    synchronized (lock) { /* ... */ } // private lock — clients can't interfere
}
```

**[⬆ back to top](#table-of-contents)**

### Item 83: Use lazy initialization judiciously

Lazy initialization is an optimization with real costs, so under most circumstances initialize normally (eagerly). When you do need it, use the lazy initialization holder class idiom for static fields and the double-check idiom (with a `volatile` field) for instance fields.

**Bad:**

```java
// Synchronizing on every access just to initialize lazily — needless contention.
private FieldType field;
synchronized FieldType getField() {
    if (field == null) field = computeFieldValue();
    return field;
}
```

**Good:**

```java
// Static field: lazy holder class — thread-safe with no synchronization cost.
private static class Holder { static final FieldType FIELD = computeFieldValue(); }
static FieldType getField() { return Holder.FIELD; }

// Instance field: double-check idiom with a volatile field.
private volatile FieldType field;
FieldType getFieldInstance() {
    FieldType result = field;
    if (result == null) {                 // first check (no locking)
        synchronized (this) {
            if (field == null)            // second check (locked)
                field = result = computeFieldValue();
        }
    }
    return result;
}
```

**[⬆ back to top](#table-of-contents)**

### Item 84: Don't depend on the thread scheduler

Any program whose correctness or performance relies on the thread scheduler's policy — thread priorities, `Thread.yield`, or tuned sleeps — is non-portable. Write programs that behave well regardless of scheduling: keep the number of runnable threads near the number of processors and rely on proper synchronizers, not on scheduling tricks.

**Bad:**

```java
// Busy-waiting and yielding — wastes CPU and depends on the scheduler.
while (!done)
    Thread.yield(); // "works" on one machine, fails on another
```

**Good:**

```java
// Block on a proper synchronizer; correct on every scheduler.
latch.await(); // releases the CPU until the condition is met
```

**[⬆ back to top](#table-of-contents)**

## Chapter 12: Serialization

### Item 85: Prefer alternatives to Java serialization

Java serialization is dangerous: deserializing untrusted byte streams can lead to remote code execution through "gadget chains," and the attack surface spans the entire object graph. Avoid it. Use a cross-platform structured-data representation such as JSON or Protocol Buffers, and never deserialize untrusted data.

**Bad:**

```java
// Deserializing untrusted bytes with Java serialization — remote-code-execution risk.
ObjectInputStream in = new ObjectInputStream(untrustedStream);
Object obj = in.readObject(); // a crafted stream can execute arbitrary code
```

**Good:**

```java
// Use a safe, cross-platform format; deserialization can't execute arbitrary code.
ObjectMapper mapper = new ObjectMapper();
MyDto dto = mapper.readValue(untrustedJson, MyDto.class);
```

**[⬆ back to top](#table-of-contents)**

### Item 86: Implement Serializable with great caution

Implementing `Serializable` is a serious, long-lived commitment: it makes the class's byte-stream representation part of its exported API (constraining future change), enlarges the bug and security surface, and complicates testing. Don't implement it casually — and classes designed for inheritance should rarely do so.

**Bad:**

```java
// Implementing Serializable without thought freezes the internal representation forever.
public class Range implements Serializable {
    private int low, high; // the serialized form is now part of your public API
}
```

**Good:**

```java
// Don't implement Serializable unless required. If you must, design the serialized
// form deliberately and declare an explicit serialVersionUID.
public class Range {
    private final int low, high; // no serialization commitment
}
```

**[⬆ back to top](#table-of-contents)**

### Item 87: Consider using a custom serialized form

Accept the default serialized form only if it is a reasonable description of the object's logical state. The default form welds you to the current physical representation, bloats the stream, and can break or perform poorly. When the physical and logical forms differ, mark fields `transient` and define `writeObject`/`readObject`.

**Bad:**

```java
// Default form serializes physical linked-list nodes — brittle and wasteful.
public final class StringList implements Serializable {
    private int size;
    private Entry head;
    private static class Entry implements Serializable { String data; Entry next, prev; }
}
```

**Good:**

```java
// Mark physical fields transient; serialize the logical content yourself.
public final class StringList implements Serializable {
    private transient int size;
    private transient Entry head;

    private void writeObject(ObjectOutputStream s) throws IOException {
        s.defaultWriteObject();
        s.writeInt(size);
        for (Entry e = head; e != null; e = e.next) s.writeObject(e.data);
    }
    private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
        s.defaultReadObject();
        int n = s.readInt();
        for (int i = 0; i < n; i++) add((String) s.readObject());
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Item 88: Write readObject methods defensively

`readObject` is effectively another public constructor that accepts a byte stream, so it must be just as careful: validate all invariants and make defensive copies of mutable components. Otherwise a forged stream can create objects that violate invariants or that secretly alias attacker-controlled mutable state.

**Bad:**

```java
// Default readObject — a crafted stream can break invariants or alias internals.
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
    s.defaultReadObject(); // no copying, no validation
}
```

**Good:**

```java
// Defensively copy mutable fields, then check invariants.
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
    s.defaultReadObject();
    start = new Date(start.getTime()); // defensive copy of mutable component
    end   = new Date(end.getTime());
    if (start.compareTo(end) > 0)
        throw new InvalidObjectException(start + " after " + end);
}
```

**[⬆ back to top](#table-of-contents)**

### Item 89: For instance control, prefer enum types to readResolve

If a serializable class must control its instances (for example, a singleton), the `readResolve` approach is fragile: every instance field must be `transient` or an attacker can steal a reference during deserialization. A single-element enum guarantees instance control automatically.

**Bad:**

```java
// A serializable singleton needs readResolve AND all-transient fields to be safe.
public class Elvis implements Serializable {
    public static final Elvis INSTANCE = new Elvis();
    private String[] favoriteSongs = { "Hound Dog" }; // must be transient, or attackable
    private Object readResolve() { return INSTANCE; }
}
```

**Good:**

```java
// A single-element enum provides ironclad instance control for free.
public enum Elvis {
    INSTANCE;
    private final String[] favoriteSongs = { "Hound Dog" };
}
```

**[⬆ back to top](#table-of-contents)**

### Item 90: Consider serialization proxies instead of serialized instances

The serialization proxy pattern largely eliminates the risks of serialization. Give the class a private static nested class that captures its logical state; the enclosing class's `writeReplace` returns a proxy, its `readObject` always throws, and the proxy's `readResolve` recreates the object through its normal public constructor (so all invariants are re-checked).

**Bad:**

```java
// Serializing the real object exposes its internals to forged-stream attacks,
// forcing you to defend every invariant by hand in readObject.
public final class Period implements Serializable {
    private final Date start, end;
}
```

**Good:**

```java
// Serialization proxy: a small stand-in that reconstructs via the constructor.
public final class Period implements Serializable {
    private final Date start, end;

    private Object writeReplace() { return new SerializationProxy(this); }
    private void readObject(ObjectInputStream s) throws InvalidObjectException {
        throw new InvalidObjectException("Proxy required");
    }
    private static class SerializationProxy implements Serializable {
        private final Date start, end;
        SerializationProxy(Period p) { this.start = p.start; this.end = p.end; }
        private Object readResolve() { return new Period(start, end); } // re-checks invariants
    }
}
```

**[⬆ back to top](#table-of-contents)**
