# Project Lombok — Eliminate Java Boilerplate with Compile-time Code Generation

## Role

You are a Senior Java engineer who applies Project Lombok idiomatically. You know what each annotation generates, when using it improves a class, and when it is a trap (JPA entities, inheritance, exposed locks). You always reason about the *generated* code — Lombok is a compile-time annotation processor that rewrites the AST, and the generated members behave exactly as if you had written them by hand.

## Goal

This reference synthesizes the official Project Lombok feature documentation (projectlombok.org/features and /features/experimental) into concrete, applicable practices, organized by feature area. Each practice states what the annotation does with a short rationale and shows two code blocks:

- **With Lombok** — the idiomatic, recommended form (the "do this").
- **Vanilla Java (what it generates)** — the equivalent hand-written boilerplate Lombok produces, so you understand and can verify the output.

Plus, where relevant, a **Pitfall** line calling out a real misuse to avoid. Practices are numbered by chapter (e.g. "5.2 Add elements one-by-one with `@Singular`"). When you apply one, cite it by chapter section and title.

## Version covered

- Target: **Lombok 1.18.x** — the current stable line. Examples are verified against the 1.18 line (latest release **1.18.46**, 2026-04-22, which adds JDK 26 support).
- `groupId:artifactId` = `org.projectlombok:lombok`.
- Newer features carry a **Since** note (e.g. `@Locked` since 1.18.32, `@StandardException` since 1.18.22, `@Jacksonized` since 1.18.16, `@SuperBuilder` since 1.18.2). See **Appendix B** for the full since-version table. Lombok keeps strong backward compatibility, so older 1.18.x releases support everything except the most recently added features.
- Lombok runs on a wide range of JDKs (recent releases track new JDKs through JDK 26). Confirm your toolchain's Lombok version supports your JDK if you are on a very new or very old JDK.

> **Experimental features** (Chapter 7) live in the `lombok.experimental` package. They are usable and stable in practice but may change; each notes its status (e.g. `@Delegate`/`@UtilityClass` are "negative" — unlikely to graduate). Treat them as fine to use with eyes open.

## Constraints

Lombok generates code during compilation. The build, the generated `*.class` (or `delombok` output), and your IDE's Lombok support are the sources of truth.

- **MANDATORY**: After changes, compile (`./gradlew compileJava` / `mvn compile`). Lombok errors (e.g. `@With` without an all-args constructor, non-exhaustive constructor selection) surface at compile time.
- **PROCESSOR ON THE PATH**: Lombok must be both a (compile-only) dependency and an **annotation processor**. Maven: `org.projectlombok:lombok` with `<scope>provided</scope>` (or `optional`). Gradle: `compileOnly` + `annotationProcessor` (and `testCompileOnly` + `testAnnotationProcessor`). Missing the processor ⇒ "cannot find symbol getX()" everywhere.
- **IDE SUPPORT**: IntelliJ IDEA has built-in Lombok support (enable annotation processing). Eclipse needs the lombok.jar installer run once. Without it the IDE shows phantom errors even though the build passes.
- **READ THE GENERATED CODE**: Use `java -jar lombok.jar delombok src -d out` (or the IDE's "delombok"/decompile) to see exactly what Lombok produced. Never guess.
- **VERSION AWARENESS**: Gate newer annotations on the project's Lombok version (Appendix B). Don't use `@Locked` on < 1.18.32, `@StandardException` on < 1.18.22, etc.
- **DON'T FIGHT THE GENERATED CODE**: If a generated member is wrong for your case, write that member by hand (Lombok skips members that already exist) or use the annotation's attributes / `lombok.config` — never decompile-and-edit.
- **ENTITY/INHERITANCE PITFALLS**: `@Data`/`@EqualsAndHashCode`/`@ToString` on JPA entities and on subclasses are the most common foot-guns (lazy-loading, bidirectional cycles, `callSuper`). See 4.2, 3.3.
- **WITH MAPSTRUCT**: When Lombok and MapStruct are both annotation processors (this project uses both), add `org.projectlombok:lombok-mapstruct-binding` and order processors `mapstruct → lombok → binding`. See 8.x and the companion `mapstruct` skill (§14.2).
- **BEFORE APPLYING**: Read the relevant chapter section below for attributes, generated output, and the pitfall.

## Examples

### Table of contents

**Chapter 1 — Setup & how Lombok works**
- 1.1 Add Lombok as a compile-only dependency and annotation processor
- 1.2 Understand that Lombok rewrites the AST at compile time

**Chapter 2 — Local variables, resources & exceptions**
- 2.1 Infer immutable locals with `val` (and mutable with `var`)
- 2.2 Generate parameter null-checks with `@NonNull`
- 2.3 Close resources safely with `@Cleanup`
- 2.4 Throw checked exceptions through narrow signatures with `@SneakyThrows`

**Chapter 3 — Accessors & object methods**
- 3.1 Generate getters/setters with `@Getter`/`@Setter`
- 3.2 Generate `toString()` with `@ToString`
- 3.3 Generate `equals()`/`hashCode()` with `@EqualsAndHashCode`
- 3.4 Cache an expensive field with `@Getter(lazy=true)`

**Chapter 4 — Constructors & aggregate annotations**
- 4.1 Generate constructors with `@NoArgsConstructor`/`@RequiredArgsConstructor`/`@AllArgsConstructor`
- 4.2 Make a mutable POJO with `@Data`
- 4.3 Make an immutable value type with `@Value`
- 4.4 Add copy-on-write "setters" with `@With`

**Chapter 5 — Builders**
- 5.1 Generate a fluent builder with `@Builder`
- 5.2 Add collection elements one-by-one with `@Singular`
- 5.3 Give builder fields defaults with `@Builder.Default` (and `toBuilder`, `@Builder.ObtainVia`)
- 5.4 Build across an inheritance hierarchy with `@SuperBuilder`
- 5.5 Make a builder Jackson-deserializable with `@Jacksonized`

**Chapter 6 — Concurrency & logging**
- 6.1 Lock on a private monitor with `@Synchronized`
- 6.2 Use `java.util.concurrent` locks with `@Locked` (+ `.Read`/`.Write`)
- 6.3 Declare a logger with `@Slf4j` and the `@Log` family

**Chapter 7 — Experimental features**
- 7.1 Fluent/chained accessors with `@Accessors`
- 7.2 Add methods to existing types with `@ExtensionMethod`
- 7.3 Set field defaults class-wide with `@FieldDefaults` (+ `@NonFinal`/`@PackagePrivate`)
- 7.4 Compose via delegation with `@Delegate`
- 7.5 Make a utility class with `@UtilityClass`
- 7.6 Methods-in-methods with `@Helper`
- 7.7 Generate field-name constants with `@FieldNameConstants`
- 7.8 Generate exception constructors with `@StandardException`
- 7.9 Un-hide a clashing method with `@Tolerate`
- 7.10 Annotate generated members with `onMethod`/`onConstructor`/`onParam`

**Chapter 8 — Configuration system (`lombok.config`)**
- 8.1 Set project-wide defaults in `lombok.config`
- 8.2 Mark the root with `config.stopBubbling` and combine with other processors

**Appendix A — `lombok.config` keys reference**
**Appendix B — Feature → since-version table**
**Appendix C — Setup snippets, delombok, and common pitfalls**

---

## Chapter 1 — Setup & how Lombok works

### [1.1] Add Lombok as a compile-only dependency and annotation processor

Title: Put Lombok on the compile classpath and the annotation-processor path; keep it off the runtime classpath.
Description: Lombok's annotations have `CLASS` retention and its processor generates code at compile time — nothing Lombok is needed at runtime. So depend on it as `provided`/`compileOnly` and register it as an annotation processor. Getting this wrong is the #1 setup problem: if the processor is missing, every `getX()`/`builder()` call fails with "cannot find symbol".

**With Lombok (Maven):**

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.46</version>
    <scope>provided</scope>
</dependency>
```

**With Lombok (Gradle):**

```gradle
dependencies {
    compileOnly 'org.projectlombok:lombok:1.18.46'
    annotationProcessor 'org.projectlombok:lombok:1.18.46'
    testCompileOnly 'org.projectlombok:lombok:1.18.46'
    testAnnotationProcessor 'org.projectlombok:lombok:1.18.46'
}
```

**Pitfall:** Bundling Lombok at runtime scope (`implementation`/`compile`) ships an unnecessary jar and can mask the missing-processor problem. Also: IntelliJ needs "Enable annotation processing" on; Eclipse needs `java -jar lombok.jar` run once. See **Appendix C** for the MapStruct co-existence ordering.

### [1.2] Understand that Lombok rewrites the AST at compile time

Title: Treat generated members as real Java — and know Lombok skips anything you wrote yourself.
Description: Lombok is not reflection or a runtime proxy: it injects methods/fields/constructors directly into your class during compilation, so the result is plain bytecode identical to hand-written code (same performance, same debuggability via `delombok`). A key rule across almost every annotation: **if a member already exists (matched by name, case-insensitive, ignoring parameter count), Lombok will not generate it** and usually stays silent. This is how you override one generated member while keeping the rest.

**With Lombok:**

```java
@Getter @Setter
public class User {
    private String name;
    // You wrote getName() yourself -> Lombok generates only setName(...) and getId-style others.
    public String getName() { return name == null ? "(anonymous)" : name; }
}
```

**Vanilla Java (what it generates):**

```java
public class User {
    private String name;
    public String getName() { return name == null ? "(anonymous)" : name; } // yours, untouched
    public void setName(String name) { this.name = name; }                   // generated
}
```

**Pitfall:** Because matching ignores parameter count, an existing `setName(String, Locale)` will *suppress* generation of `setName(String)` (with a warning). Use `@Tolerate` (7.9) to force generation in that case.

## Chapter 2 — Local variables, resources & exceptions

### [2.1] Infer immutable locals with `val` (and mutable with `var`)

Title: Use `lombok.val` for `final` type-inferred locals and `lombok.var` for non-final ones.
Description: `val` declares a local whose type is inferred from the initializer and which is made `final`. It works only on local variables and foreach loops, and the initializer is mandatory. `var` is identical but not `final` (further assignments are legal, but the type is still fixed from the initializer — you cannot later assign an incompatible type). Both are real types you import from the `lombok` package. **Since 1.18.22**, on Java 10+ `val` is emitted as `final var`.

**With Lombok:**

```java
import java.util.ArrayList;
import lombok.val;

public class ValExample {
  public String example() {
    val example = new ArrayList<String>();   // inferred ArrayList<String>, final
    example.add("Hello, World!");
    val foo = example.get(0);                 // inferred String, final
    return foo.toLowerCase();
  }
}
```

**Vanilla Java (what it generates):**

```java
import java.util.ArrayList;

public class ValExample {
  public String example() {
    final ArrayList<String> example = new ArrayList<String>();
    example.add("Hello, World!");
    final String foo = example.get(0);
    return foo.toLowerCase();
  }
}
```

**Pitfall:** For compound/ambiguous initializers the inferred type is the most common *superclass*, not a shared interface; a `null` initializer infers `java.lang.Object`. On modern projects (Java 10+), prefer the JDK's own `var` for mutable locals — Lombok's `var` exists mainly for older sources. `lombok.val.flagUsage` / `lombok.var.flagUsage` = `[warning|error]` can ban them.

### [2.2] Generate parameter null-checks with `@NonNull`

Title: Annotate a parameter, record component, or field with `lombok.NonNull` to insert a fail-fast null check.
Description: Put `@lombok.NonNull` on a method/constructor parameter and Lombok inserts `if (x == null) throw new NullPointerException("x is marked non-null but is null");` at the top of the method (right after any `this()`/`super()` for constructors). On a field, it makes Lombok-generated setters/constructors null-check that field. If an equivalent check already exists at the top, none is added.

**With Lombok:**

```java
import lombok.NonNull;

public class NonNullExample extends Something {
  private String name;

  public NonNullExample(@NonNull Person person) {
    super("Hello");
    this.name = person.getName();
  }
}
```

**Vanilla Java (what it generates):**

```java
public class NonNullExample extends Something {
  private String name;

  public NonNullExample(@NonNull Person person) {
    super("Hello");
    if (person == null) {
      throw new NullPointerException("person is marked non-null but is null");
    }
    this.name = person.getName();
  }
}
```

**Pitfall:** Only Lombok's own `@NonNull` triggers code insertion (other `@NonNull`s are merely respected on generated members). `@NonNull` on a primitive yields a warning and no check. Change the thrown type with `lombok.nonNull.exceptionType = [NullPointerException | IllegalArgumentException | JDK | Guava | Assertion]`.

### [2.3] Close resources safely with `@Cleanup`

Title: Annotate a local resource with `@Cleanup` to guarantee its `close()` (or named method) runs via try/finally.
Description: `@Cleanup` ensures a resource's cleanup method is called before the enclosing scope exits, wrapping the rest of the scope in try/finally. Defaults to calling `close()`; use `@Cleanup("dispose")` for another no-arg method. The cleanup call is skipped if the resource is `null`.

**With Lombok:**

```java
import lombok.Cleanup;
import java.io.*;

public class CleanupExample {
  public static void main(String[] args) throws IOException {
    @Cleanup InputStream in = new FileInputStream(args[0]);
    @Cleanup OutputStream out = new FileOutputStream(args[1]);
    byte[] b = new byte[10000];
    while (true) {
      int r = in.read(b);
      if (r == -1) break;
      out.write(b, 0, r);
    }
  }
}
```

**Vanilla Java (what it generates):**

```java
import java.io.*;

public class CleanupExample {
  public static void main(String[] args) throws IOException {
    InputStream in = new FileInputStream(args[0]);
    try {
      OutputStream out = new FileOutputStream(args[1]);
      try {
        byte[] b = new byte[10000];
        while (true) {
          int r = in.read(b);
          if (r == -1) break;
          out.write(b, 0, r);
        }
      } finally {
        if (out != null) out.close();
      }
    } finally {
      if (in != null) in.close();
    }
  }
}
```

**Pitfall:** If your code throws and the cleanup `close()` also throws, the cleanup exception hides the original. On modern Java, prefer the language's `try-with-resources` for `AutoCloseable` resources; reach for `@Cleanup` for non-`AutoCloseable` types or a non-`close()` cleanup method.

### [2.4] Throw checked exceptions through narrow signatures with `@SneakyThrows`

Title: Use `@SneakyThrows` to throw checked exceptions without declaring them — for "impossible" exceptions and rigid interfaces.
Description: `@SneakyThrows` lets a method throw checked exceptions not in its `throws` clause (legal at the JVM level). Two legitimate uses: implementing a fixed signature like `Runnable.run()`, and exceptions the spec guarantees can't happen (e.g. `UnsupportedEncodingException` for `"UTF-8"`). Pass specific types (`@SneakyThrows(IOException.class)`) or none (any).

**With Lombok:**

```java
import lombok.SneakyThrows;

public class SneakyThrowsExample implements Runnable {
  @SneakyThrows(UnsupportedEncodingException.class)
  public String utf8ToString(byte[] bytes) {
    return new String(bytes, "UTF-8");
  }

  @SneakyThrows
  public void run() {
    throw new Throwable();
  }
}
```

**Vanilla Java (what it generates):**

```java
import lombok.Lombok;

public class SneakyThrowsExample implements Runnable {
  public String utf8ToString(byte[] bytes) {
    try {
      return new String(bytes, "UTF-8");
    } catch (UnsupportedEncodingException e) {
      throw Lombok.sneakyThrow(e);
    }
  }

  public void run() {
    try {
      throw new Throwable();
    } catch (Throwable t) {
      throw Lombok.sneakyThrow(t);
    }
  }
}
```

**Pitfall:** You cannot `catch` a sneakily-thrown checked type directly (javac rejects a catch for an exception no call in the `try` declares). Don't use `@SneakyThrows` to routinely dodge legitimate error handling — reserve it for truly-impossible or signature-forced cases.

## Chapter 3 — Accessors & object methods

### [3.1] Generate getters/setters with `@Getter`/`@Setter`

Title: Annotate a field (or the whole class) with `@Getter`/`@Setter`; control visibility with `AccessLevel`.
Description: `@Getter`/`@Setter` generate the standard accessor(s): `getFoo()` (or `isFoo()` for `boolean`), `setFoo(T)`. On a class they apply to all non-static fields. The `value` is an `AccessLevel` (`PUBLIC` default, `PROTECTED`, `PACKAGE`, `PRIVATE`, `NONE`); `AccessLevel.NONE` suppresses generation for one field even when the class is annotated. Field Javadoc (and `-- GETTER --`/`-- SETTER --` sections) is copied to the accessor. `@Getter` works on enums; `@Setter` does not.

**With Lombok:**

```java
import lombok.AccessLevel;
import lombok.Getter;
import lombok.Setter;

public class GetterSetterExample {
  @Getter @Setter private int age = 10;
  @Setter(AccessLevel.PROTECTED) private String name;
}
```

**Vanilla Java (what it generates):**

```java
public class GetterSetterExample {
  private int age = 10;
  private String name;

  public int getAge() { return age; }
  public void setAge(int age) { this.age = age; }
  protected void setName(String name) { this.name = name; }
}
```

**Pitfall:** A `boolean` named `isRunning` keeps `isRunning()` (no double prefix). `java.lang.Boolean` uses `get`, not `is`. Use `lombok.config` keys `lombok.accessors.chain`/`fluent`/`prefix` and `lombok.getter.noIsPrefix` to change conventions globally (see 7.1, Appendix A).

### [3.2] Generate `toString()` with `@ToString`

Title: Annotate the class with `@ToString`; tune with `includeFieldNames`, `callSuper`, and `@ToString.Include`/`@ToString.Exclude`.
Description: `@ToString` generates `ClassName(field1=v1, field2=v2)`. All non-static fields are included by default; exclude with `@ToString.Exclude`, or set `onlyExplicitlyIncluded=true` and mark members with `@ToString.Include` (which can also include a no-arg method and supports `name`/`rank`). `callSuper=true` prepends `super.toString()`. Getters are used if present unless `doNotUseGetters=true`.

**With Lombok:**

```java
import lombok.ToString;

@ToString
public class ToStringExample {
  private String name;
  private Shape shape = new Square(5, 10);
  private String[] tags;
  @ToString.Exclude private int id;

  @ToString(callSuper=true, includeFieldNames=true)
  public static class Square extends Shape {
    private final int width, height;
    public Square(int width, int height) { this.width = width; this.height = height; }
  }
}
```

**Vanilla Java (what it generates):**

```java
import java.util.Arrays;

public class ToStringExample {
  // ... fields ...
  @Override public String toString() {
    return "ToStringExample(" + this.name + ", " + this.shape + ", " + Arrays.deepToString(this.tags) + ")";
  }
  public static class Square extends Shape {
    // ...
    @Override public String toString() {
      return "Square(super=" + super.toString() + ", width=" + this.width + ", height=" + this.height + ")";
    }
  }
}
```

**Pitfall:** Arrays print via `Arrays.deepToString`, so a self-referential array → `StackOverflowError`. The exact format is not guaranteed across Lombok versions — never parse it. `@ToString.Include`/`@ToString.Exclude` were added in 1.16.22 (older `of`/`exclude` are deprecated). Members named with a leading `$` are auto-excluded.

### [3.3] Generate `equals()`/`hashCode()` with `@EqualsAndHashCode`

Title: Annotate the class with `@EqualsAndHashCode`; set `callSuper` correctly for inheritance.
Description: Generates `equals`/`hashCode` from all non-static, non-transient fields (plus a `canEqual` for safe subclassing). Exclude with `@EqualsAndHashCode.Exclude`, or use `onlyExplicitlyIncluded=true` + `@EqualsAndHashCode.Include` (supports `replaces`). For a subclass you almost always want `callSuper=true`; setting it on a class that extends only `Object` is a **compile error**, and omitting it on a class that extends something else gives a **warning**.

**With Lombok:**

```java
import lombok.EqualsAndHashCode;

@EqualsAndHashCode
public class EqualsAndHashCodeExample {
  private transient int transientVar = 10;
  private String name;
  private double score;
  @EqualsAndHashCode.Exclude private Shape shape = new Square(5, 10);
  @EqualsAndHashCode.Exclude private int id;

  @EqualsAndHashCode(callSuper=true)   // includes superclass state
  public static class Square extends Shape {
    private final int width, height;
    public Square(int width, int height) { this.width = width; this.height = height; }
  }
}
```

**Vanilla Java (what it generates — abridged):**

```java
@Override public boolean equals(Object o) {
  if (o == this) return true;
  if (!(o instanceof EqualsAndHashCodeExample)) return false;
  EqualsAndHashCodeExample other = (EqualsAndHashCodeExample) o;
  if (!other.canEqual((Object) this)) return false;
  if (this.name == null ? other.name != null : !this.name.equals(other.name)) return false;
  if (Double.compare(this.score, other.score) != 0) return false;
  return true;
}
@Override public int hashCode() {
  final int PRIME = 59; int result = 1;
  final long t = Double.doubleToLongBits(this.score);
  result = result*PRIME + (this.name == null ? 43 : this.name.hashCode());
  result = result*PRIME + (int)(t ^ (t >>> 32));
  return result;
}
protected boolean canEqual(Object other) { return other instanceof EqualsAndHashCodeExample; }
// Square overrides also call super.equals(o)/super.hashCode() because callSuper=true.
```

**Pitfall (critical for JPA entities):** Default `@EqualsAndHashCode` uses *all* fields — including the `@Id` and lazy/bidirectional associations — which breaks entity identity and can trigger `StackOverflowError` or unwanted lazy loading. On entities, include only a stable business key (or the id with care) via `onlyExplicitlyIncluded`. `cacheStrategy` (since 1.18.16) caches the hash — never on mutable objects. `lombok.equalsAndHashCode.callSuper` config default is `warn`.

### [3.4] Cache an expensive field with `@Getter(lazy=true)`

Title: Compute a costly `private final` field once, on first access, with thread-safe caching.
Description: Put the expensive computation in a `private final` field's initializer and annotate `@Getter(lazy=true)`. Lombok hides the field behind an `AtomicReference` and generates a double-checked-locking getter that computes the value at most once (even a `null` result is cached). Your computation need not be thread-safe.

**With Lombok:**

```java
import lombok.Getter;

public class GetterLazyExample {
  @Getter(lazy=true)
  private final double[] cached = expensive();

  private double[] expensive() {
    double[] result = new double[1000000];
    for (int i = 0; i < result.length; i++) result[i] = Math.asin(i);
    return result;
  }
}
```

**Vanilla Java (what it generates — abridged):**

```java
private final java.util.concurrent.AtomicReference<Object> cached = new java.util.concurrent.AtomicReference<Object>();
public double[] getCached() {
  Object value = this.cached.get();
  if (value == null) {
    synchronized (this.cached) {
      value = this.cached.get();
      if (value == null) {
        final double[] actual = expensive();
        value = actual == null ? this.cached : actual;
        this.cached.set(value);
      }
    }
  }
  return (double[]) (value == this.cached ? null : value);
}
```

**Pitfall:** Always access via the generated getter — the real field's type is mangled to `AtomicReference<Object>` and hidden. Requires `private final` + initializer, not `transient`.

## Chapter 4 — Constructors & aggregate annotations

### [4.1] Generate constructors with `@NoArgsConstructor`/`@RequiredArgsConstructor`/`@AllArgsConstructor`

Title: Generate the constructor you need: none-args, one-per-required-field, or one-per-field; optionally a static factory.
Description: `@NoArgsConstructor` (errors on final fields unless `force=true`, which zero/null-inits them), `@RequiredArgsConstructor` (one param per uninitialized `final` field and per uninitialized `@NonNull` field, with null-checks), `@AllArgsConstructor` (one param per field). Common attributes: `staticName` (makes the constructor private and adds a `static` factory of that name — great for generics), `access` (`AccessLevel`), and `onConstructor` (annotate the constructor, see 7.10).

**With Lombok:**

```java
import lombok.*;

@RequiredArgsConstructor(staticName = "of")
@AllArgsConstructor(access = AccessLevel.PROTECTED)
public class ConstructorExample<T> {
  private int x, y;
  @NonNull private T description;
}
```

**Vanilla Java (what it generates):**

```java
public class ConstructorExample<T> {
  private int x, y;
  @NonNull private T description;

  private ConstructorExample(T description) {
    if (description == null) throw new NullPointerException("description");
    this.description = description;
  }
  public static <T> ConstructorExample<T> of(T description) {
    return new ConstructorExample<T>(description);
  }
  @java.beans.ConstructorProperties({"x", "y", "description"})
  protected ConstructorExample(int x, int y, T description) {
    if (description == null) throw new NullPointerException("description");
    this.x = x; this.y = y; this.description = description;
  }
}
```

**Pitfall:** A field explicitly initialized to `null` is *not* treated as "required". `@ConstructorProperties` is added by default — disable via `lombok.anyConstructor.addConstructorProperties=false` (or it's omitted automatically under some module setups). On `enum`s the generated constructor is always private.

### [4.2] Make a mutable POJO with `@Data`

Title: Use `@Data` to bundle `@Getter` (all fields) + `@Setter` (non-final) + `@ToString` + `@EqualsAndHashCode` + `@RequiredArgsConstructor`.
Description: `@Data` is the all-in-one for a mutable data class. Its only attribute is `staticConstructor` (private constructor + named static factory). Override any bundled feature by adding that annotation explicitly (e.g. `@Setter(AccessLevel.PACKAGE)` on one field, or `@EqualsAndHashCode(callSuper=true)` on the class).

**With Lombok:**

```java
import lombok.AccessLevel;
import lombok.Data;
import lombok.Setter;

@Data
public class DataExample {
  private final String name;
  @Setter(AccessLevel.PACKAGE) private int age;
  private double score;
  private String[] tags;
}
```

**Vanilla Java (what it generates — abridged):**

```java
public class DataExample {
  private final String name;
  private int age;
  private double score;
  private String[] tags;

  public DataExample(String name) { this.name = name; }     // @RequiredArgsConstructor (final field)
  public String getName() { return name; }
  void setAge(int age) { this.age = age; }                   // package-private per @Setter
  public int getAge() { return age; }
  public double getScore() { return score; }
  public void setScore(double score) { this.score = score; }
  public String[] getTags() { return tags; }
  public void setTags(String[] tags) { this.tags = tags; }
  @Override public String toString() { /* DataExample(name, age, score, [tags]) */ }
  @Override public boolean equals(Object o) { /* all fields + canEqual */ }
  @Override public int hashCode() { /* all fields */ }
  protected boolean canEqual(Object other) { return other instanceof DataExample; }
}
```

**Pitfall (JPA entities):** Avoid bare `@Data` on `@Entity` classes — the generated `equals`/`hashCode`/`toString` over *all* fields cause lazy-load triggers, bidirectional `StackOverflowError`, and broken identity. Prefer `@Getter @Setter` + a hand-tuned `@EqualsAndHashCode(onlyExplicitlyIncluded=true)` and `@ToString` excluding associations. `@Data` doesn't call `super` in equals/hashCode — use explicit `@EqualsAndHashCode(callSuper=true)` if you extend a class.

### [4.3] Make an immutable value type with `@Value`

Title: Use `@Value` for an immutable class: all fields `private final`, class `final`, getters + `toString`/`equals`/`hashCode` + all-args constructor, no setters.
Description: `@Value` is the immutable counterpart of `@Data`. It is shorthand for `final` class + `@FieldDefaults(makeFinal=true, level=PRIVATE)` + `@Getter` + `@ToString` + `@EqualsAndHashCode` + `@AllArgsConstructor`. Override defaults per element: `@NonFinal` (drop `final`), `@PackagePrivate` (raise visibility), add `@With`/`@Setter` explicitly. `staticConstructor` makes the all-args constructor private behind a factory.

**With Lombok:**

```java
import lombok.Value;

@Value
public class ValueExample {
  String name;
  int age;
  double score;
  String[] tags;
}
```

**Vanilla Java (what it generates — abridged):**

```java
public final class ValueExample {
  private final String name;
  private final int age;
  private final double score;
  private final String[] tags;

  public ValueExample(String name, int age, double score, String[] tags) { /* assign all */ }
  public String getName() { return name; }
  public int getAge() { return age; }
  public double getScore() { return score; }
  public String[] getTags() { return tags; }
  @Override public boolean equals(Object o) { /* all fields + canEqual-free, class is final */ }
  @Override public int hashCode() { /* all fields */ }
  @Override public String toString() { /* ValueExample(name=…, age=…, …) */ }
}
```

**Pitfall:** `@Value` no longer implies `@With` (since 0.11.8) — add `@With` if you want copy-with methods. Arrays/collections are still shallow-copied by reference, so true immutability requires immutable field contents. To expose one mutable field, mark it `@NonFinal` (+ `@Setter`/`@With`).

### [4.4] Add copy-on-write "setters" with `@With`

Title: Generate `withFoo(newValue)` that returns a clone with one field changed — the immutable alternative to a setter.
Description: For an immutable type, `@With` on a field generates `withField(newValue)` returning a new instance (a clone with that one field changed), returning `this` if the value is identical (`==`). **It requires an all-args constructor** (from `@AllArgsConstructor`, `@Value`, or hand-written) or it's a compile error. On a class it generates a wither per field. `value` is an `AccessLevel`.

**With Lombok:**

```java
import lombok.AccessLevel;
import lombok.NonNull;
import lombok.With;

public class WithExample {
  @With(AccessLevel.PROTECTED) @NonNull private final String name;
  @With private final int age;

  public WithExample(@NonNull String name, int age) { this.name = name; this.age = age; }
}
```

**Vanilla Java (what it generates):**

```java
public class WithExample {
  private @NonNull final String name;
  private final int age;
  public WithExample(String name, int age) {
    if (name == null) throw new NullPointerException();
    this.name = name; this.age = age;
  }
  protected WithExample withName(@NonNull String name) {
    if (name == null) throw new NullPointerException("name");
    return this.name == name ? this : new WithExample(name, age);
  }
  public WithExample withAge(int age) {
    return this.age == age ? this : new WithExample(name, age);
  }
}
```

**Pitfall:** No wither for `static` fields. `@With` was named `@Wither` before 1.18.10 (still in `lombok.experimental` historically). On an abstract class it generates an `abstract` wither. Name collisions (same name+param-count, varargs count as 0..N) suppress generation with a warning.

## Chapter 5 — Builders

### [5.1] Generate a fluent builder with `@Builder`

Title: Annotate a class, constructor, or method with `@Builder` to get `Type.builder().field(v)...build()`.
Description: `@Builder` generates a static inner `*Builder` class with a chainable setter per field, a `build()` method, a `toString()`, and a static `builder()` entry point. On a class it behaves like adding `@AllArgsConstructor(access=PACKAGE)` and building that. Useful attributes: `builderMethodName`, `buildMethodName`, `builderClassName`, `setterPrefix`, `access`, and `toBuilder=true` (adds an instance `toBuilder()` that pre-fills a builder from the current object — a shallow copy mechanism).

**With Lombok:**

```java
import lombok.Builder;
import lombok.Singular;
import java.util.Set;

@Builder
public class BuilderExample {
  @Builder.Default private long created = System.currentTimeMillis();
  private String name;
  private int age;
  @Singular private Set<String> occupations;
}
```

**Vanilla Java (what it generates — abridged):**

```java
public class BuilderExample {
  private long created; private String name; private int age; private Set<String> occupations;
  BuilderExample(String name, int age, Set<String> occupations) { /* ...defaults applied... */ }
  private static long $default$created() { return System.currentTimeMillis(); }
  public static BuilderExampleBuilder builder() { return new BuilderExampleBuilder(); }

  public static class BuilderExampleBuilder {
    private long created; private boolean created$set;
    private String name; private int age;
    private java.util.ArrayList<String> occupations;        // accumulates @Singular elements
    public BuilderExampleBuilder name(String name) { this.name = name; return this; }
    public BuilderExampleBuilder age(int age) { this.age = age; return this; }
    public BuilderExampleBuilder occupation(String occupation) { /* add one */ return this; }
    public BuilderExampleBuilder occupations(Collection<? extends String> c) { /* add all */ return this; }
    public BuilderExampleBuilder clearOccupations() { /* reset */ return this; }
    public BuilderExample build() {
      Set<String> occupations = /* compacted immutable set */;
      return new BuilderExample(created$set ? created : BuilderExample.$default$created(), name, age, occupations);
    }
  }
}
```

**Pitfall:** Put `@Builder` on a *constructor* if you also declare explicit constructors. With `@Value @Builder`, the package-private builder constructor wins. A non-star static import of `builder()` fails in javac — use a star import or none. To force a copy-only API, use `@Builder(toBuilder=true, builderMethodName="")`.

### [5.2] Add collection elements one-by-one with `@Singular`

Title: Mark a collection field/parameter `@Singular` to get add-one / add-all / clear methods and an immutable result.
Description: `@Singular` makes the builder treat a collection node specially: it generates an add-one method (named with the singularized field name), an add-all method, and a clear method — and no plain "replace" setter. On `build()` the produced collection is **immutable** and compacted; mutating the builder afterward doesn't affect already-built objects. Supports `java.util` `List`/`Set`/`SortedSet`/`Map`/`SortedMap`/etc. and Guava `Immutable*` types.

**With Lombok:**

```java
@Builder
public class Order {
  @Singular private List<String> items;            // -> item(String), items(Collection), clearItems()
  @Singular("axis") private List<Line> axes;        // explicit singular when auto-singularization is unclear
}
// usage:
Order o = Order.builder().item("a").item("b").build();   // items == immutable [a, b]
```

**Vanilla Java (what it generates — abridged):**

```java
public OrderBuilder item(String item) {
  if (this.items == null) this.items = new java.util.ArrayList<String>();
  this.items.add(item); return this;
}
public OrderBuilder items(Collection<? extends String> items) { /* addAll */ return this; }
public OrderBuilder clearItems() { if (this.items != null) this.items.clear(); return this; }
// build(): produces a compacted, unmodifiable List<String>
```

**Pitfall:** Auto-singularization assumes English plurals; if Lombok can't singularize (or it's ambiguous) it errors — pass an explicit `@Singular("name")`. Sorted collections require `Comparable` elements (no custom `Comparator`). Null collection passed to the add-all method throws NPE unless `@Singular(ignoreNullCollections=true)`. `lombok.singular.useGuava` / `lombok.singular.auto` tune behavior.

### [5.3] Give builder fields defaults with `@Builder.Default` (and `toBuilder`, `@Builder.ObtainVia`)

Title: Use `@Builder.Default` so an unset field keeps its initializer value instead of `0`/`null`/`false`.
Description: Without `@Builder.Default`, a field not set during the build session defaults to the Java zero-value, *not* its initializer. Annotate the initialized field with `@Builder.Default` (only on class-level `@Builder`) and Lombok stores the initializer in a static method, applying it when no value was supplied. `toBuilder=true` adds `obj.toBuilder()`; `@Builder.ObtainVia(method="calc")` tells `toBuilder` to source a field via a method instead of reading it directly.

**With Lombok:**

```java
@Builder
public class Config {
  @Builder.Default private long created = System.currentTimeMillis();
  @Builder.Default private int retries = 3;
  private String url;
}
// Config.builder().url("...").build()  -> retries == 3, created == now
```

**Pitfall:** A `@Builder.Default` initializer is moved into a `static` method, so it **cannot reference `this`, `super`, or instance members**. Hand-written/`@NoArgsConstructor` constructors will use the defaults, but other explicit constructors must set them (or call `this()`). Forgetting `@Builder.Default` on an initialized field is a classic bug (silent `0`/`null`); Lombok warns about this.

### [5.4] Build across an inheritance hierarchy with `@SuperBuilder`

Title: Use `@SuperBuilder` (on the class *and every superclass*) when builder fields must include inherited ones.
Description: Plain `@Builder` ignores superclass fields. `@SuperBuilder` generates builders that include inherited fields — but it works only on types, **requires every superclass to also be `@SuperBuilder`**, is not compatible with `@Builder`, and generates two inner builder classes per class (abstract `*Builder` + concrete `*BuilderImpl`) using heavy generics. Supports `@Singular`, `@Builder.Default`, `toBuilder` (all superclasses must set `toBuilder=true`), `buildMethodName`/`builderMethodName`/`setterPrefix`. **Since 1.18.2.**

**With Lombok:**

```java
import lombok.experimental.SuperBuilder;
import lombok.Getter;

@SuperBuilder @Getter
public class Parent {
  private String parentField;
}

@SuperBuilder @Getter
public class Child extends Parent {   // builder exposes BOTH childField and parentField
  private String childField;
}
// Child.builder().parentField("p").childField("c").build();
```

**Pitfall:** Mixing `@Builder` and `@SuperBuilder` in a hierarchy fails. Because of the generics, don't try to hand-write the builder headers — delombok the uncustomized version first if you must customize. The `lombok.builder.className` config must be identical across the whole hierarchy.

### [5.5] Make a builder Jackson-deserializable with `@Jacksonized`

Title: Add `@Jacksonized` next to `@Builder`/`@SuperBuilder` so Jackson deserializes through the generated builder automatically.
Description: `@Jacksonized` is an add-on (no attributes) that wires Jackson to use the generated builder: it adds `@JsonDeserialize(builder=...)`, copies Jackson config annotations (e.g. `@JsonIgnoreProperties`) from the class to the builder, and inserts `@JsonPOJOBuilder(withPrefix="")` (respecting your `setterPrefix`/`buildMethodName`). It only acts where a `@Builder`/`@SuperBuilder` (or `@Accessors(fluent=true)` on a type) exists, else warns. **Since 1.18.16.**

**With Lombok:**

```java
import lombok.Builder;
import lombok.Value;
import lombok.extern.jackson.Jacksonized;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Jacksonized @Builder @Value
@JsonIgnoreProperties(ignoreUnknown = true)
public class ApiResponse {
  String status;
  int code;
}
// Jackson can now deserialize JSON straight into the immutable @Value via its builder.
```

**Pitfall:** Without `@Jacksonized` you'd hand-write `@JsonDeserialize`/`@JsonPOJOBuilder` on the builder. It errors if `@JsonDeserialize` already exists on the class. **Since 1.18.44** choose the Jackson major version with `lombok.jacksonized.jacksonVersion` (defaults to Jackson 2 with a warning). `@Jacksonized` on fields is not supported.

## Chapter 6 — Concurrency & logging

### [6.1] Lock on a private monitor with `@Synchronized`

Title: Replace `synchronized` methods with `@Synchronized` to lock on a private field instead of `this`/the class object.
Description: `@Synchronized` (instance or static methods) locks on an auto-generated private field `$lock` (instance) or `$LOCK` (static) instead of `this`/`ClassName.class`, so external code can't acquire your monitor and cause deadlocks/races. `@Synchronized("myLock")` locks on a field you name — but then you must declare that field yourself (it is *not* auto-generated, to avoid a typo silently creating a second lock).

**With Lombok:**

```java
import lombok.Synchronized;

public class SynchronizedExample {
  private final Object readLock = new Object();

  @Synchronized public static void hello() { System.out.println("world"); }
  @Synchronized public int answerToLife() { return 42; }
  @Synchronized("readLock") public void foo() { System.out.println("bar"); }
}
```

**Vanilla Java (what it generates):**

```java
public class SynchronizedExample {
  private static final Object $LOCK = new Object[0];
  private final Object $lock = new Object[0];
  private final Object readLock = new Object();

  public static void hello() { synchronized ($LOCK) { System.out.println("world"); } }
  public int answerToLife() { synchronized ($lock) { return 42; } }
  public void foo() { synchronized (readLock) { System.out.println("bar"); } }
}
```

**Pitfall:** Lock fields are `new Object[0]` (a 0-length array) — serializable, unlike `new Object()`. Removing all `@Synchronized` removes the auto field and changes the implicit `serialVersionUID`; declare an explicit `serialVersionUID` on long-lived serializable classes. On virtual threads (Java 21+), prefer `@Locked` (6.2).

### [6.2] Use `java.util.concurrent` locks with `@Locked` (+ `.Read`/`.Write`)

Title: Use `@Locked` for `ReentrantLock`-based method locking, and `@Locked.Read`/`@Locked.Write` for a `ReadWriteLock` — virtual-thread friendly.
Description: `@Locked` wraps the method body in `lock()`/`unlock()` (try-finally) on a generated `ReentrantLock` field (`$lock`/`$LOCK`, or a named `ReentrantLock` field). `@Locked.Read` and `@Locked.Write` use a `ReentrantReadWriteLock` (read/write lock respectively). Unlike `synchronized`, these locks don't pin virtual threads, so they're recommended on Java 21+. **Since 1.18.32.**

**With Lombok:**

```java
import lombok.Locked;

public class LockedExample {
  private int value = 0;
  @Locked.Read  public int getValue() { return value; }
  @Locked.Write public void setValue(int newValue) { value = newValue; }
  @Locked("baseLock") public void foo() { System.out.println("bar"); }
}
```

**Vanilla Java (what it generates — abridged):**

```java
private final ReadWriteLock lock = new ReentrantReadWriteLock();
private final Lock baseLock = new ReentrantLock();
public int getValue() {
  this.lock.readLock().lock();
  try { return value; } finally { this.lock.readLock().unlock(); }
}
public void setValue(int newValue) {
  this.lock.writeLock().lock();
  try { value = newValue; } finally { this.lock.writeLock().unlock(); }
}
```

**Pitfall:** `@Locked` (ReentrantLock) and `@Locked.Read`/`.Write` (ReadWriteLock) use different lock types, so they **can't share the default `$lock`/`$LOCK` field** — name an explicit field if you need to combine them. Requires Lombok ≥ 1.18.32.

### [6.3] Declare a logger with `@Slf4j` and the `@Log` family

Title: Put the right `@Log`-family annotation on the class to get a ready-to-use `private static final` `log` field.
Description: Each variant generates the idiomatic logger for one framework, named `log`. Pick the one matching your stack: `@Slf4j` (SLF4J — the usual choice), `@Log4j2`, `@CommonsLog`, `@JBossLog`, `@Flogger`, `@Log` (java.util.logging), `@Log4j`, `@XSlf4j`, or `@CustomLog` (configured via `lombok.log.custom.declaration`). Customize the logger category with `topic=`.

**With Lombok:**

```java
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class OrderService {
  public void place(Order o) {
    log.info("Placing order {}", o.getId());     // 'log' field generated for you
  }
}
```

**Vanilla Java (what it generates):**

```java
public class OrderService {
  private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(OrderService.class);
  public void place(Order o) { log.info("Placing order {}", o.getId()); }
}
```

**Variant → generated field (logger type / factory):**

| Annotation | Generated `log` field |
|---|---|
| `@Slf4j` | `org.slf4j.LoggerFactory.getLogger(T.class)` |
| `@Log4j2` | `org.apache.logging.log4j.LogManager.getLogger(T.class)` |
| `@CommonsLog` | `org.apache.commons.logging.LogFactory.getLog(T.class)` |
| `@JBossLog` | `org.jboss.logging.Logger.getLogger(T.class)` |
| `@Flogger` | `com.google.common.flogger.FluentLogger.forEnclosingClass()` (since 1.18.0) |
| `@Log` | `java.util.logging.Logger.getLogger(T.class.getName())` |
| `@Log4j` | `org.apache.log4j.Logger.getLogger(T.class)` |
| `@XSlf4j` | `org.slf4j.ext.XLoggerFactory.getXLogger(T.class)` |
| `@CustomLog` | per `lombok.log.custom.declaration` (since 1.18.10) |

**Pitfall:** Don't put side-effects in logged expressions — a planned optimization may guard calls with a level check. Change the field name with `lombok.log.fieldName`, or make it non-static with `lombok.log.fieldIsStatic=false`. An existing `log` field suppresses generation (with a warning).

## Chapter 7 — Experimental features

> These live in `lombok.experimental`. Usable today, but may change; each notes its official status. Enable/ban globally with `lombok.experimental.flagUsage` or the per-feature `flagUsage` key.

### [7.1] Fluent/chained accessors with `@Accessors`

Title: Use `@Accessors(fluent=true)`/`chain=true`/`prefix=...` to break the JavaBeans naming convention deliberately.
Description: `@Accessors` (on a field or class) reshapes `@Getter`/`@Setter` output: `fluent=true` drops `get`/`set`/`is` (getter `name()`, setter `name(v)`) and implies `chain=true`; `chain=true` makes setters return `this`; `prefix={"f"}` strips a field prefix when naming accessors; `makeFinal=true` (since 1.18.24) makes them `final`. Resolution is field → enclosing type(s) → `lombok.config`. **Since 0.11.0.**

**With Lombok:**

```java
import lombok.experimental.Accessors;
import lombok.Getter; import lombok.Setter;

@Accessors(fluent = true)
public class AccessorsExample {
  @Getter @Setter private int age = 10;
}
// new AccessorsExample().age(20).age()  ->  20
```

**Vanilla Java (what it generates):**

```java
public class AccessorsExample {
  private int age = 10;
  public int age() { return this.age; }
  public AccessorsExample age(final int age) { this.age = age; return this; }
}
```

**Pitfall:** Fluent accessors aren't recognized by some bean/serialization tooling (combine with `@Jacksonized` for Jackson). Lombok discourages field `prefix`es. Set defaults globally via `lombok.accessors.fluent`/`chain`/`prefix`/`makeFinal`/`capitalization`.

### [7.2] Add methods to existing types with `@ExtensionMethod`

Title: Route calls like `foo.bar()` to `public static bar(Foo foo)` methods listed on `@ExtensionMethod`.
Description: List one or more classes of `public static` methods (each taking ≥1 non-primitive first arg); within the annotated class, `receiver.method(args)` is rewritten to `ExtClass.method(receiver, args)`. Generics are respected. Status: **hold** (won't graduate soon, but won't change/disappear).

**With Lombok:**

```java
import lombok.experimental.ExtensionMethod;

@ExtensionMethod({ java.util.Arrays.class, Extensions.class })
public class ExtensionMethodExample {
  public String test() {
    int[] a = {5, 3, 8, 2};
    a.sort();                                  // -> Arrays.sort(a)
    String s = null;
    return s.or("hELlO".toTitleCase());        // -> Extensions.or(s, Extensions.toTitleCase("hELlO"))
  }
}
class Extensions {
  public static <T> T or(T obj, T ifNull) { return obj != null ? obj : ifNull; }
  public static String toTitleCase(String in) { /* ... */ return in; }
}
```

**Pitfall:** A `null` receiver does NOT immediately NPE — it's passed as the first arg (so `s.or(...)` above is valid). The static method is *called*, not inlined, so it must be on the classpath at compile **and** runtime. Lombok ships no built-in extensions.

### [7.3] Set field defaults class-wide with `@FieldDefaults` (+ `@NonFinal`/`@PackagePrivate`)

Title: Apply `private` and/or `final` to every field in a class with `@FieldDefaults`, opting out per field.
Description: `@FieldDefaults(makeFinal=true, level=AccessLevel.PRIVATE)` makes all instance fields `final` and `private` (only fields lacking an explicit modifier get the access level). Opt a field out with `@NonFinal` (drop final) or `@PackagePrivate` (keep package-private). Status: **neutral**. Global equivalents: `lombok.fieldDefaults.defaultPrivate`/`defaultFinal` (since 1.16.8) — but those affect *every* source file, even ones with no Lombok.

**With Lombok:**

```java
import lombok.AccessLevel;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.experimental.PackagePrivate;

@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class FieldDefaultsExample {
  public final int a;
  int b;                    // -> private final int b
  @NonFinal int c;          // -> private int c
  @PackagePrivate int d;    // -> final int d (package-private)
  FieldDefaultsExample() { a = 0; b = 0; d = 0; }
}
```

**Pitfall:** Fields named with a leading `$` are skipped. The global `lombok.fieldDefaults.*` keys are "too much magic" (they rewrite files with zero Lombok annotations) — prefer the explicit annotation, or `@Value` for the common immutable case.

### [7.4] Compose via delegation with `@Delegate`

Title: Annotate a field/no-arg method with `@Delegate` to generate forwarding methods for its type's public API.
Description: `@Delegate` generates methods that forward to the annotated field (or method result), covering all public methods of its type and supertypes except `java.lang.Object`'s. Narrow the surface with `types=` (delegate only these) and `excludes=` (skip these) — typically private inner interfaces. Status: **negative** (may be dropped if javac/ecj make it hard).

**With Lombok:**

```java
import java.util.ArrayList;
import java.util.Collection;
import lombok.experimental.Delegate;

public class DelegationExample {
  private interface SimpleCollection {
    boolean add(String item);
    boolean remove(Object item);
  }
  @Delegate(types = SimpleCollection.class)
  private final Collection<String> collection = new ArrayList<String>();
}
```

**Vanilla Java (what it generates):**

```java
public boolean add(final String item)   { return this.collection.add(item); }
public boolean remove(final Object item) { return this.collection.remove(item); }
```

**Pitfall:** No generics allowed in `types`/`excludes` (work around with private inner interfaces); not allowed on `static` members; not recursive (errors if a delegated type itself uses `@Delegate`). Moved to `lombok.experimental` in 1.14 (old `lombok.Delegate` deprecated).

### [7.5] Make a utility class with `@UtilityClass`

Title: Annotate a class `@UtilityClass` to make it `final`, give it a throwing private constructor, and make all members `static`.
Description: `@UtilityClass` turns a class into a stateless namespace: it's marked `final`, gets a private constructor that throws (and explicit constructors become errors), and **all members — fields, methods, inner classes — are made `static`**. Inner utility classes are also made `static`. Status: **negative** (fundamental non-star-static-import issue).

**With Lombok:**

```java
import lombok.experimental.UtilityClass;

@UtilityClass
public class UtilityClassExample {
  private final int CONSTANT = 5;            // becomes static
  public int addSomething(int in) { return in + CONSTANT; }  // becomes static
}
```

**Vanilla Java (what it generates):**

```java
public final class UtilityClassExample {
  private static final int CONSTANT = 5;
  private UtilityClassExample() {
    throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
  }
  public static int addSomething(int in) { return in + CONSTANT; }
}
```

**Pitfall:** Non-star static imports of `@UtilityClass` members don't work in javac — use a star static import or qualify with the class name. You cannot have any instance member.

### [7.6] Methods-in-methods with `@Helper`

Title: Annotate a method-local class `@Helper` to call its methods as if they were local functions.
Description: Java has no method-local functions; `@Helper` fakes them. Annotate a local class and Lombok auto-instantiates it and rewrites unqualified calls to route through that instance, so helper methods can close over local variables. Status: experimental, **since 1.16.6**.

**With Lombok:**

```java
import lombok.experimental.Helper;

public class HelperExample {
  int someMethod(int arg1) {
    int localVar = 5;
    @Helper class Helpers {
      int helperMethod(int arg) { return arg + localVar; }
    }
    return helperMethod(10);          // -> 15
  }
}
```

**Vanilla Java (what it generates):**

```java
int someMethod(int arg1) {
  int localVar = 5;
  class Helpers { int helperMethod(int arg) { return arg + localVar; } }
  Helpers $Helpers = new Helpers();
  return $Helpers.helperMethod(10);
}
```

**Pitfall:** Helper class needs a no-arg constructor. Pre-Java 8, captured locals must be `final`. Use `ClassName.this` (not bare `this`) inside the helper.

### [7.7] Generate field-name constants with `@FieldNameConstants`

Title: Annotate a class `@FieldNameConstants` to generate an inner `Fields` type of constants for marshalling/queries.
Description: Generates an inner type (default `public static class Fields`) with one constant per field — `String` constants by default, or enum values with `asEnum=true`. Refactor-safe references to field names. Attributes: `asEnum`, `innerTypeName`, `level`, `onlyExplicitlyIncluded`; per-field `@FieldNameConstants.Include`/`.Exclude`. First added 1.16.22; **redesigned in 1.18.4** into the current form.

**With Lombok:**

```java
import lombok.experimental.FieldNameConstants;

@FieldNameConstants
public class FieldNameConstantsExample {
  private final String iAmAField;
  private final int andSoAmI;
  @FieldNameConstants.Exclude private final int asAmI;
}
// usage: FieldNameConstantsExample.Fields.iAmAField  ->  "iAmAField"
```

**Vanilla Java (what it generates):**

```java
public class FieldNameConstantsExample {
  // ... fields ...
  public static final class Fields {
    public static final String iAmAField = "iAmAField";
    public static final String andSoAmI = "andSoAmI";
  }
}
```

**Pitfall:** `static`/`$`-prefixed fields are skipped. You can't reference these constants inside other Lombok annotation params. `lombok.fieldNameConstants.uppercase=true` produces `CONSTANT_CASE` names (since 1.18.8).

### [7.8] Generate exception constructors with `@StandardException`

Title: Annotate a `Throwable` subclass `@StandardException` to generate the four standard exception constructors.
Description: Generates up to four constructors — `()`, `(String message)`, `(Throwable cause)`, `(String message, Throwable cause)` — each delegating to the full one (which calls `super(message)` then `initCause(cause)` if non-null). Any you write yourself are kept. Status: experimental, **since 1.18.22**.

**With Lombok:**

```java
import lombok.experimental.StandardException;

@StandardException
public class ExampleException extends Exception { }
```

**Vanilla Java (what it generates):**

```java
public class ExampleException extends Exception {
  public ExampleException() { this(null, null); }
  public ExampleException(String message) { this(message, null); }
  public ExampleException(Throwable cause) { this(cause != null ? cause.getMessage() : null, cause); }
  public ExampleException(String message, Throwable cause) {
    super(message);
    if (cause != null) super.initCause(cause);
  }
}
```

**Pitfall:** Behavioral nuances vs hand-rolled exceptions: the `(message, null)` form still allows a later `initCause`, and `(cause)` does **not** copy the cause's message (Lombok considers that wrong). The parent must have at least `()` and `(String)` constructors. Add `@java.beans.ConstructorProperties` via `lombok.standardException.addConstructorProperties=true`.

### [7.9] Un-hide a clashing method with `@Tolerate`

Title: Mark an existing method/constructor `@Tolerate` so Lombok ignores it and still generates the member it would otherwise skip.
Description: Lombok skips generating a member that already exists (by name, ignoring params). `@Tolerate` on your hand-written method makes Lombok act as if it isn't there, so it generates the standard one too — handy when you want both a typed convenience method and the generated one. No attributes. **Since 1.14.2.**

**With Lombok:**

```java
import lombok.Setter;
import lombok.experimental.Tolerate;

public class TolerateExample {
  @Setter private java.sql.Date date;        // generates setDate(java.sql.Date)

  @Tolerate
  public void setDate(String date) {          // ignored by Lombok -> both setters coexist
    this.date = java.sql.Date.valueOf(date);
  }
}
```

**Pitfall:** Use sparingly — it exists for genuine convenience overloads. Status experimental because it's niche and tricky with recursive delegation.

### [7.10] Annotate generated members with `onMethod`/`onConstructor`/`onParam`

Title: Forward annotations onto generated methods, constructors, or their parameters via the `on*` options.
Description: When Lombok generates a member you can't annotate directly, use `onMethod_=...` (on `@Getter`/`@Setter`/`@With` methods), `onConstructor_=...` (on generated constructors), or `onParam_=...` (on the setter/wither/equals parameter). Essential for JPA (`@Id`, `@Column`), DI (`@Inject`), and validation (`@Max`) on generated code. **Since 0.11.8.**

**With Lombok (javac 8+ / ecj syntax — note the trailing underscore):**

```java
import lombok.*;
import jakarta.persistence.*;
import jakarta.validation.constraints.Max;

@AllArgsConstructor(onConstructor_ = @Inject)
public class OnXExample {
  @Getter(onMethod_ = { @Id, @Column(name = "unique-id") })
  @Setter(onParam_ = @Max(10000))
  private long unid;
}
```

**Vanilla Java (what it generates):**

```java
public class OnXExample {
  private long unid;
  @Inject public OnXExample(long unid) { this.unid = unid; }
  @Id @Column(name = "unique-id") public long getUnid() { return unid; }
  public void setUnid(@Max(10000) long unid) { this.unid = unid; }
}
```

**Pitfall:** Syntax differs by compiler: **javac 8+/ecj** use the trailing-underscore form (`onMethod_=@A` / `onMethod_={@A,@B}`); **javac 7** uses the legacy `onMethod=@__(@A)` wrapper. The `@__` type must not otherwise exist. Not valid on type-level (`@Getter` on a class). Status: "workaround" — could break in a future javac.

## Chapter 8 — Configuration system (`lombok.config`)

### [8.1] Set project-wide defaults in `lombok.config`

Title: Put a `lombok.config` file at a directory to apply settings to all sources beneath it.
Description: `lombok.config` files configure Lombok per directory tree — a setting applies to all sources in that directory and its children, with files **closer to the source winning** (hierarchical override). Lines starting with `#` are comments. Keys take a value (`key = value`), reset to default (`clear key`), or modify a list (`key += item` / `key -= item`). `import path` (since 1.18.12) pulls in another config file. Discover all keys for your version with `java -jar lombok.jar config -g --verbose`. **The config system was added in 1.14.**

**Example `lombok.config`:**

```properties
# Mark the project root so Lombok stops looking in parent directories
config.stopBubbling = true

# Project-wide conventions
lombok.accessors.chain = true
lombok.equalsAndHashCode.callSuper = call
lombok.log.fieldName = LOGGER

# Make generated code play nice with coverage and null-analysis tools
lombok.addLombokGeneratedAnnotation = true
lombok.addNullAnnotations = jspecify

# Ban risky features in this codebase
lombok.var.flagUsage = warning
```

**Pitfall:** `lombok.fieldDefaults.defaultPrivate/defaultFinal` rewrite *every* source file beneath the config — even ones with no Lombok annotations; use deliberately. A child `lombok.config` can override or `clear` a parent value.

### [8.2] Mark the root with `config.stopBubbling` and combine with other processors

Title: Anchor the config tree with `config.stopBubbling = true`, and when other annotation processors are present, order them correctly.
Description: Put your canonical `lombok.config` at the project/workspace root with `config.stopBubbling = true` so Lombok doesn't search outside the project. When Lombok shares the annotation-processor round with other generators (notably **MapStruct**), processor ordering matters: MapStruct must see Lombok's generated accessors, which requires the `lombok-mapstruct-binding` processor.

**With Lombok + MapStruct (Maven processor order):**

```xml
<annotationProcessorPaths>
    <path><groupId>org.mapstruct</groupId><artifactId>mapstruct-processor</artifactId>
          <version>${org.mapstruct.version}</version></path>
    <path><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId>
          <version>${lombok.version}</version></path>
    <path><groupId>org.projectlombok</groupId><artifactId>lombok-mapstruct-binding</artifactId>
          <version>0.2.0</version></path>
</annotationProcessorPaths>
```

**Pitfall:** Without `lombok-mapstruct-binding` (required since Lombok 1.18.16), MapStruct can't see Lombok-generated getters/setters and reports everything as unmapped. See the companion **`mapstruct` skill (§14.2)** for the full setup. Keep Lombok at `provided`/`compileOnly` so it isn't a runtime dependency.

---

## Appendix A — `lombok.config` keys reference

Common keys (see `java -jar lombok.jar config -g --verbose` for the exhaustive, version-specific list). Every feature also has a `lombok.<feature>.flagUsage = [warning | error]` key to discourage/ban it; `lombok.experimental.flagUsage` bans all experimental features at once.

| Key | Values (default) | Purpose |
|-----|------------------|---------|
| `config.stopBubbling` | `true` (—) | Stop searching parent directories — mark the config-tree root. |
| `lombok.addLombokGeneratedAnnotation` | `true`/`false` (`false`) | Add `@lombok.Generated` to generated members (so JaCoCo/static analysis skip them). |
| `lombok.addNullAnnotations` | `jspecify`,`checkerframework`,`jakarta`,`eclipse`,`jetbrains`,`spring`,`javax`,`CUSTOM:…` (—) | Add nullity annotations to generated methods/params. (Since 1.18.12.) |
| `lombok.addSuppressWarnings` | `true`/`false` (`true`) | Whether to add `@SuppressWarnings("all")` to generated code. |
| `lombok.anyConstructor.addConstructorProperties` | `true`/`false` (`false`) | Add `@java.beans.ConstructorProperties` to generated constructors. |
| `lombok.copyableAnnotations` | FQN list (`+=`) | Annotations copied from a field to generated params/methods (nullity annotations included by default). |
| `lombok.accessors.chain` | `true`/`false` (`false`) | Setters return `this`. |
| `lombok.accessors.fluent` | `true`/`false` (`false`) | Drop `get`/`set`/`is` prefixes. |
| `lombok.accessors.prefix` | prefix list (`+=`/`-=`) | Field prefixes stripped when naming accessors. |
| `lombok.accessors.makeFinal` | `true`/`false` (`false`) | Generated accessors are `final`. (Since 1.18.24.) |
| `lombok.accessors.capitalization` | `basic`/`beanspec` (`basic`) | Capitalization for tricky names like `uShaped`. |
| `lombok.getter.noIsPrefix` | `true`/`false` (`false`) | Use `getX()` even for `boolean` instead of `isX()`. |
| `lombok.equalsAndHashCode.callSuper` | `call`/`skip`/`warn` (`warn`) | Default `callSuper` behavior. |
| `lombok.equalsAndHashCode.doNotUseGetters` | `true`/`false` (`false`) | Use fields directly, not getters. |
| `lombok.toString.includeFieldNames` | `true`/`false` (`true`) | `field=value` vs just `value`. |
| `lombok.toString.callSuper` | `call`/`skip`/`warn` (`skip`) | Default `callSuper` for `@ToString`. |
| `lombok.toString.doNotUseGetters` | `true`/`false` (`false`) | Use fields directly in `toString`. |
| `lombok.fieldDefaults.defaultPrivate` | `true`/`false` (`false`) | Make all fields `private` project-wide. (Since 1.16.8.) |
| `lombok.fieldDefaults.defaultFinal` | `true`/`false` (`false`) | Make all fields `final` project-wide. (Since 1.16.8.) |
| `lombok.nonNull.exceptionType` | `NullPointerException`/`IllegalArgumentException`/`JDK`/`Guava`/`Assertion` (`NullPointerException`) | Exception thrown by `@NonNull` checks. |
| `lombok.log.fieldName` | identifier (`log`) | Name of the generated logger field. |
| `lombok.log.fieldIsStatic` | `true`/`false` (`true`) | Logger field static vs instance. |
| `lombok.log.custom.declaration` | declaration string (—) | Defines what `@CustomLog` generates. (Since 1.18.10.) |
| `lombok.singular.auto` | `true`/`false` (`true`) | Auto-singularize `@Singular` names. |
| `lombok.singular.useGuava` | `true`/`false` (`false`) | Back `@Singular` collections with Guava `Immutable*`. |
| `lombok.builder.className` | identifier with `*` (`*Builder`) | Default generated builder class name. |
| `lombok.fieldNameConstants.uppercase` | `true`/`false` (`false`) | `CONSTANT_CASE` the generated names. (Since 1.18.8.) |
| `lombok.jacksonized.jacksonVersion` | `2`/`3` (`2`, `+=`) | Jackson annotation version for `@Jacksonized`. (Since 1.18.44.) |
| `lombok.copyJacksonAnnotationsToAccessors` | `true`/`false` (`false`) | Restore pre-1.18.40 copying of Jackson annotations to accessors. |

## Appendix B — Feature → since-version table

Lombok is strongly backward-compatible; older 1.18.x releases support everything below except entries with a later "Since". Current stable: **1.18.46** (2026-04-22).

| Feature | Since | Notes |
|---------|-------|-------|
| `@Getter`/`@Setter`, `@ToString`, `@EqualsAndHashCode`, constructors, `@Data`, `@Log` family, `@SneakyThrows`, `@Synchronized`, `@Cleanup`, `@NonNull`, `val`, `@Getter(lazy)`, `@Delegate` | early (≤ 0.10–0.11) | Core; `@Delegate` moved to `lombok.experimental` in 1.14 |
| `@Value` | 0.12.0 (exp. 0.11.4) | Promoted to main package |
| `@Builder` + `@Singular` | 1.16.0 (exp. 0.12.0) | `@Singular` clear method 1.16.8 |
| `@Accessors` | 0.11.0 | `makeFinal` + `capitalization` config 1.18.24 |
| `@ExtensionMethod` | 0.11.2 | Status: hold |
| `@FieldDefaults` | 0.11.4 | `defaultPrivate`/`defaultFinal` config 1.16.8 |
| `onX` (`onMethod`/`onConstructor`/`onParam`) | 0.11.8 | `_=` syntax for javac8+/ecj |
| `lombok.config` system | 1.14 | `import` + `addNullAnnotations` 1.18.12 |
| `@Tolerate` | 1.14.2 | |
| `@UtilityClass` | 1.16.2 | Status: negative |
| `@Helper` | 1.16.6 | |
| `@ToString.Include`/`.Exclude`, `@FieldNameConstants` (first form) | 1.16.22 | `@FieldNameConstants` redesigned 1.18.4 |
| `@EqualsAndHashCode` `onParam` | 1.14.0 | `cacheStrategy` 1.18.16 |
| `@Flogger` | 1.18.0 | |
| `@SuperBuilder` | 1.18.2 | `toBuilder` 1.18.4 |
| `@With` (rename of `@Wither`) | 1.18.10 | |
| `@CustomLog` | 1.18.10 | + `lombok.log.custom.declaration` |
| `@Jacksonized` | 1.18.16 | `@Accessors` support 1.18.40; Jackson v3 option 1.18.44 |
| `lombok-mapstruct-binding` required with MapStruct | (Lombok 1.18.16+) | binding artifact `0.2.0` |
| `@StandardException` | 1.18.22 | |
| `val` → `final var` (Java 10+) | 1.18.22 | |
| `@Locked` (+`.Read`/`.Write`) | 1.18.32 | Virtual-thread friendly |
| JDK 26 support | 1.18.46 | Continuous new-JDK support 1.18.30→1.18.46 |

## Appendix C — Setup snippets, delombok, and common pitfalls

**Maven (standalone):** `org.projectlombok:lombok` at `<scope>provided</scope>`. Modern `maven-compiler-plugin` picks up annotation processors from the classpath; for explicit control use `<annotationProcessorPaths>` (and add `lombok-mapstruct-binding` when MapStruct is present — see 8.2).

**Gradle (standalone):**
```gradle
dependencies {
    compileOnly 'org.projectlombok:lombok:1.18.46'
    annotationProcessor 'org.projectlombok:lombok:1.18.46'
    testCompileOnly 'org.projectlombok:lombok:1.18.46'
    testAnnotationProcessor 'org.projectlombok:lombok:1.18.46'
}
```

**IDE:** IntelliJ has built-in Lombok support — just enable *Settings → Build → Compiler → Annotation Processors → Enable annotation processing*. Eclipse needs `java -jar lombok.jar` run once to patch the IDE.

**delombok — see what Lombok generates:**
```bash
java -jar lombok.jar delombok src/main/java -d build/delombok
```
Use it to inspect generated code, to debug, or to ship Lombok-free sources. IDEs offer a "delombok"/decompile action too.

**Most common pitfalls (consolidated):**
- **Missing processor** → "cannot find symbol getX()/builder()". Register the annotation processor (1.1).
- **`@Data`/`@EqualsAndHashCode` on JPA entities** → broken identity, lazy-load triggers, bidirectional `StackOverflowError`. Use `onlyExplicitlyIncluded` with a stable key and exclude associations from `@ToString` (3.3, 4.2).
- **Inheritance without `callSuper`** → wrong `equals`/`hashCode`/`toString`; set `callSuper=true` (and it's a compile error on direct `Object` subclasses) (3.3).
- **`@Builder` field initializer ignored** → add `@Builder.Default` (5.3).
- **Exposed locks** → don't `synchronized(this)`; use `@Synchronized`/`@Locked` (6.1, 6.2).
- **MapStruct sees nothing** → add `lombok-mapstruct-binding`, order `mapstruct → lombok → binding` (8.2).
- **Mutating logged expressions** → avoid side effects; logging may be guarded.

---

*Sources: Project Lombok official feature documentation — https://projectlombok.org/features and https://projectlombok.org/features/experimental, the configuration guide https://projectlombok.org/features/configuration, and the changelog https://projectlombok.org/changelog (current stable 1.18.46, 2026-04-22). "With Lombok" and "Vanilla Java" samples are adapted from the official feature pages; some long generated expansions are abridged with clearly marked elisions.*





