# MapStruct — Type-safe Bean Mapping with a Compile-time Annotation Processor

## Role

You are a Senior Java engineer with deep experience in bean mapping. You apply the official *MapStruct Reference Guide* to write, review, debug, and refactor MapStruct mappers. You generate code that "looks as much as possible as if you had written it yourself by hand", you prefer declarative annotations over hand-written loops, and you always verify against the compiler and the generated `*Impl`.

## Goal

This reference synthesizes the official MapStruct Reference Guide into concrete, applicable practices, organized into the guide's 14 chapters. Each practice states a best practice with a short rationale, a **Good example**, and a **Bad example** (or, for feature/reference material, a **Mapper → Generated** pair). Use it to:

- Define bean mappers (`@Mapper`/`@Mapping`) for DTO↔entity and any bean-to-bean mapping, including renamed/nested/flattened properties, builders, constructors, and updates.
- Diagnose build-time errors (unmapped target property, ambiguous mapping method, no implementation generated) and fix them explicitly.
- Apply enums/value mapping, collections/maps/streams, null-handling, conditional mapping, configuration reuse, decorators, lifecycle callbacks, and the SPI.
- Set up MapStruct in Maven/Gradle, integrate Lombok and Kotlin, and migrate between versions.

Practices are numbered by chapter (e.g. "10.8 Keep existing target values on update with `NullValuePropertyMappingStrategy.IGNORE`"). When you apply one, cite it by chapter section and title.

## Versions covered and how to read the version tags

This reference documents **two MapStruct versions** so neither is lost:

| Line | Version | Status | Docs |
|------|---------|--------|------|
| Stable | **1.6.3** (2024-11-09) | current stable | `https://mapstruct.org/documentation/stable/reference/html/` |
| Dev | **1.7.0.Beta1** (2026-02-01) | pre-release; superset of 1.6.3 | `https://mapstruct.org/documentation/dev/reference/html/` |

`groupId` is `org.mapstruct` for both; artifacts are `mapstruct` (runtime) and `mapstruct-processor` (annotation processor). Both lines require **Java 8+** to run the processor (Java 9+ only when using the Java Module System); **1.7 did not raise the minimum JDK**.

**Tag legend used throughout this reference:**

- *(untagged)* — present in **both** 1.6.3 and 1.7.0.Beta1.
- **[1.7+]** — exists **only in 1.7.0.Beta1**; do **not** use it on a 1.6.3 project.
- **[1.6+]** — added in the 1.6.0 line (so present in 1.6.3 and 1.7); shown where it matters for migrating *from* 1.5.x.

> ⚠️ The `/documentation/stable/` URL tracks whatever is current stable; there is **no permanent `/documentation/1.6/` path** (the site only pins versions up to 1.5). While 1.6.3 is stable, `/stable/` = 1.6.3. Once 1.7 becomes stable, pin a snapshot if long-term 1.6 fidelity is needed.

## Version matrix — 1.6.3 ↔ 1.7.0.Beta1 delta

**New in 1.7.0.Beta1 (NOT available in 1.6.3) — tagged [1.7+] below:**

| Feature | Where | Notes |
|---------|-------|-------|
| **Kotlin support** | §2.7 | new setup section; add `org.jetbrains.kotlin:kotlin-metadata-jvm` processor path; sealed-class subclass exhaustiveness |
| **`java.util.Optional` mapping** | §3.10, §5.1 | Optional as source/target/property; presence check via `isEmpty()`; `Optional` targets initialized to `Optional.empty()` (not `null`); no null check done for `Optional` properties |
| **Java 21 Sequenced Collections** | §6.3 | `SequencedSet`→`LinkedHashSet`, `SequencedMap`→`LinkedHashMap` |
| **`@Ignored`** | §5.3, §10 | ignore several target properties at once |
| **`NullValuePropertyMappingStrategy.CLEAR`** | §10.8 | clears `Collection`/`Map` target on update when source is null |
| **`locale` for `numberFormat`/`dateFormat`** | §5.1 | locale-aware number/date formatting |
| **Builder detection without a factory method** | §3.8 | inner class ending in `Builder` with a parameterized constructor is a candidate (static builder methods still take precedence) |
| **`@AnnotateWith` on decorators** | §12.1 | annotation now applicable to decorators |
| **Custom exception for non-exhaustive `@SubclassMapping`** | §10.4 | configurable on `@BeanMapping`/`@Mapper`/`@MapperConfig` |
| **`mapstruct.disableLifecycleOverloadDeduplicateSelector`** | §2.4 | opt out of overloaded-lifecycle-method de-duplication |
| **`String`→`Number` reported as lossy** | §5.1 | warning governed by `typeConversionPolicy` (like `long`→`int`) |
| **Warnings**: target with no target properties; redundant `ignoreUnmappedSourceProperties` | — | governed by `unmappedSourcePolicy` |

**Added in the 1.6.0 line (present in BOTH 1.6.3 and 1.7 — relevant only if migrating from 1.5.x):** conditional mapping for **source parameters** via `@SourceParameterCondition` / `@Condition(appliesTo = ConditionStrategy.SOURCE_PARAMETERS)` *(breaking vs 1.5: a plain `@Condition` on the source parameter no longer works)*; `@SourcePropertyName`; `@TargetPropertyName`; `@AnnotateWith` + `@AnnotateWith.Element`; `@Javadoc`; global `mapstruct.nullValueIterableMappingStrategy` / `mapstruct.nullValueMapMappingStrategy`; qualifiers on `@SubclassMapping`; the `AdditionalSupportedOptionsProvider` SPI (§13.6); conversions `Enum`↔`Integer`, `Locale`↔`String`, `LocalDate`↔`LocalDateTime`; `@ValueMapping` meta-annotations (§8.4); `InjectionStrategy.SETTER`; `BeanMapping#unmappedSourcePolicy`; `Iterable`→`Collection`. 1.6.1/1.6.2/1.6.3 were bug-fix releases (no new features). See **Appendix C** for migration notes.

## Constraints

MapStruct generates code at **compile time**. Recompiling validates almost every change, so the build — not assumption — is the source of truth.

- **MANDATORY**: Compile after every change (`./gradlew compileJava` / `mvn compile`). Unmapped-property and impossible-mapping diagnostics appear only during annotation processing.
- **VERIFY**: Run tests after changes; report compiler/test failures honestly; do not claim success until the build and tests pass.
- **READ THE GENERATED CODE**: Open the generated `*Impl` (`target/generated-sources/annotations/…` or `build/generated/sources/annotationProcessor/…`) — it is plain Java and the fastest confirmation of behavior.
- **VERSION AWARENESS**: Gate every recommendation on the project's MapStruct version. Never use a **[1.7+]** feature on 1.6.3.
- **PROCESSOR ON THE PATH**: `mapstruct-processor` must be on the annotation-processor path, correctly ordered relative to Lombok and `lombok-mapstruct-binding`.
- **`-parameters`**: Constructor-parameter-name mapping requires `-parameters` (or `@ConstructorProperties`).
- **NEVER hand-edit generated files** — change the mapper/annotations instead.
- **PRESERVE BEHAVIOR**: Null/collection/update strategies change observable behavior; change deliberately and re-verify.
- **BEFORE APPLYING**: Read the relevant chapter section below for exact attributes and the generated-code expectation.

## Examples

### Table of contents

**Chapter 1 — Introduction**
- 1.1 Generate mappers at compile time instead of mapping by reflection or by hand

**Chapter 2 — Set up**
- 2.1 Put `mapstruct-processor` on the annotation processor path (Maven)
- 2.2 Configure MapStruct in Gradle with `annotationProcessor`
- 2.3 Configure MapStruct in Ant
- 2.4 Configure the generator with annotation processor options
- 2.5 Enable `@Generated` under the Java Module System
- 2.6 Install the IDE plugin for completion and navigation
- 2.7 Add `kotlin-metadata-jvm` for Kotlin support **[1.7+]**

**Chapter 3 — Defining a mapper**
- 3.1 Declare an `@Mapper` interface and map same-named properties implicitly
- 3.2 Bundle repeated `@Mapping`s into a meta-annotation (mapping composition)
- 3.3 Add hand-written mappings as `default` methods or abstract-class methods
- 3.4 Combine several source parameters into one target
- 3.5 Flatten or merge a nested bean with `target = "."`
- 3.6 Update an existing instance with `@MappingTarget`
- 3.7 Map `public` fields directly when there are no getters/setters
- 3.8 Map to immutable types through their builder
- 3.9 Map to immutable types through their constructor
- 3.10 Map `java.util.Optional` sources and targets **[1.7+]**
- 3.11 Map a `Map<String, ?>` into a bean
- 3.12 Add framework annotations to the generated mapper with `@AnnotateWith`
- 3.13 Generate Javadoc on the mapper with `@Javadoc`

**Chapter 4 — Retrieving a mapper**
- 4.1 Obtain a stateless mapper from the `Mappers` factory via an `INSTANCE` field
- 4.2 Generate an injectable mapper with `componentModel`
- 4.3 Prefer constructor injection (and use setter injection for cycles/decorators)

**Chapter 5 — Data type conversions**
- 5.1 Rely on built-in implicit conversions; control formatting with `numberFormat`/`dateFormat`
- 5.2 Map referenced beans by declaring a method for the referenced type
- 5.3 Correct, ignore, flatten, and unflatten nested properties with dot notation
- 5.4 Compute a target property from the whole source via a custom method
- 5.5 Reuse mapping logic from other classes with `uses`
- 5.6 Resolve a generic target type with a `@TargetType` parameter
- 5.7 Thread context/state through with `@Context`
- 5.8 Let MapStruct pick the most specific mapping method
- 5.9 Disambiguate equal-signature methods with qualifiers (`@Qualifier`/`@Named`)
- 5.10 Make a qualified default value go through the right method

**Chapter 6 — Mapping collections**
- 6.1 Map `Map` types and format keys/values with `@MapMapping`
- 6.2 Choose a `CollectionMappingStrategy` (adder vs setter) for the target's API
- 6.3 Know which implementation type is created for an interface return type

**Chapter 7 — Mapping Streams**
- 7.1 Map to/from `java.util.Stream` like collections (and beware consumption)

**Chapter 8 — Mapping values (enums)**
- 8.1 Map enum-to-enum and handle the remainder with `MappingConstants`
- 8.2 Map enum↔`String`
- 8.3 Transform enum names with `@EnumMapping` instead of listing every constant
- 8.4 Bundle `@ValueMapping`s into a reusable meta-annotation

**Chapter 9 — Object factories**
- 9.1 Obtain target instances from a factory with `@ObjectFactory`

**Chapter 10 — Advanced mapping options**
- 10.1 Supply `defaultValue` and `constant`
- 10.2 Embed Java with `expression` (and declare `imports`)
- 10.3 Compute a fallback only when the source is null with `defaultExpression`
- 10.4 Map a type hierarchy with `@SubclassMapping`
- 10.5 Pick among result subtypes with `resultType`
- 10.6 Return an empty result for a null argument with `nullValueMappingStrategy`
- 10.7 Control null collection/map arguments separately
- 10.8 Keep, null, default, or clear target properties on update
- 10.9 Tune when a null check is generated with `nullValueCheckStrategy`
- 10.10 Let a `hasXyz()` presence checker drive the null check
- 10.11 Decide per-property/per-parameter mapping with conditional methods
- 10.12 Declare and propagate exceptions from mapping methods

**Chapter 11 — Reusing mapping configurations**
- 11.1 Reuse a method's config with `@InheritConfiguration`
- 11.2 Derive the reverse mapping with `@InheritInverseConfiguration`
- 11.3 Centralize settings in a `@MapperConfig` interface

**Chapter 12 — Customizing mappings**
- 12.1 Customize specific methods with a decorator (`@DecoratedWith`)
- 12.2 Hook into the lifecycle with `@BeforeMapping`/`@AfterMapping`

**Chapter 13 — Using the MapStruct SPI**
- 13.1 Teach MapStruct your accessors with a custom `AccessorNamingStrategy`
- 13.2 Exclude types from auto sub-mapping with `MappingExclusionProvider`
- 13.3 Replace builder detection with a custom `BuilderProvider`
- 13.4 Customize enum constant naming with `EnumMappingStrategy`
- 13.5 Add an enum name transformation with `EnumTransformationStrategy`
- 13.6 Pass custom processor options to your SPI with `AdditionalSupportedOptionsProvider`

**Chapter 14 — Third-party API integration**
- 14.1 Let MapStruct recognize third-party annotations by name
- 14.2 Use MapStruct together with Lombok

**Appendix A — Configuration options reference**
**Appendix B — Implicit type conversions reference**
**Appendix C — Version history & migration notes (1.5 → 1.6 → 1.7)**

---

## Chapter 1 — Introduction

### [1.1] Generate mappers at compile time instead of mapping by reflection or by hand

Title: Declare a mapper interface and let MapStruct generate the implementation during compilation.
Description: MapStruct is a Java annotation processor. You define an interface (or abstract class) annotated with `@Mapper` that declares the mapping methods; at build time MapStruct generates an implementation that copies each readable source property into the corresponding target property using **plain Java method invocations — no reflection**. Compared with hand-written code it removes tedious, error-prone boilerplate; compared with dynamic/reflection-based mappers it gives **fast execution**, **compile-time type safety** (you cannot accidentally map an order into a customer), and **clear error reports at build time** when a mapping is incomplete or impossible. It follows convention over configuration: sensible defaults, with annotations only where you need to override.

**Good example:**

```java
// You write only the contract:
@Mapper
public interface CarMapper {
    CarDto carToCarDto(Car car);
}
// MapStruct generates CarMapperImpl at compile time — plain getters/setters, type-safe, no reflection.
```

**Bad example:**

```java
// Reflection-based mapping at runtime: no compile-time safety, slower, fails late.
CarDto dto = (CarDto) BeanUtils.copyProperties(car, CarDto.class); // typos/mismatches blow up at runtime
```

## Chapter 2 — Set up

### [2.1] Put `mapstruct-processor` on the annotation processor path (Maven)

Title: Add the `mapstruct` runtime dependency and register `mapstruct-processor` via `annotationProcessorPaths`.
Description: Declare the version once as a property, add `org.mapstruct:mapstruct` as a normal dependency, and register `org.mapstruct:mapstruct-processor` on the `maven-compiler-plugin`'s `annotationProcessorPaths`. Using `annotationProcessorPaths` (rather than putting the processor on the compile classpath) keeps the processor out of your runtime classpath. The same shape works for both 1.6.3 and 1.7.0.Beta1 — only the version property changes.

**Good example:**

```xml
<properties>
    <org.mapstruct.version>1.7.0.Beta1</org.mapstruct.version> <!-- or 1.6.3 -->
</properties>

<dependencies>
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>${org.mapstruct.version}</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.14.1</version>
            <configuration>
                <annotationProcessorPaths>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>${org.mapstruct.version}</version>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

**Bad example:**

```xml
<!-- Only the runtime artifact, no processor registered: MapStruct generates nothing,
     and at runtime CarMapperImpl does not exist. -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.7.0.Beta1</version>
</dependency>
<!-- mapstruct-processor missing from annotationProcessorPaths -->
```

### [2.2] Configure MapStruct in Gradle with `annotationProcessor`

Title: Use `implementation` for the runtime jar and `annotationProcessor` (and `testAnnotationProcessor`) for the processor.
Description: In Gradle, add `mapstruct` to `implementation` and `mapstruct-processor` to `annotationProcessor`; add `testAnnotationProcessor` too if mappers are defined in test code. For Eclipse, the `com.diffplug.eclipse.apt` plugin wires APT into the IDE. The shape is identical across 1.6.3 and 1.7.

**Good example:**

```gradle
plugins {
    id "com.diffplug.eclipse.apt" version "3.26.0" // only for Eclipse
}

dependencies {
    implementation "org.mapstruct:mapstruct:${mapstructVersion}"
    annotationProcessor "org.mapstruct:mapstruct-processor:${mapstructVersion}"
    // If mappers are used in test code:
    testAnnotationProcessor "org.mapstruct:mapstruct-processor:${mapstructVersion}"
}
```

**Bad example:**

```gradle
dependencies {
    implementation "org.mapstruct:mapstruct:${mapstructVersion}"
    // Putting the processor on 'implementation' leaks it onto the runtime classpath,
    // and may not be picked up as a processor at all depending on config.
    implementation "org.mapstruct:mapstruct-processor:${mapstructVersion}"
}
```

### [2.3] Configure MapStruct in Ant

Title: Pass the processor via `-processorpath` and the generated-sources dir via `-s` on the `javac` task.
Description: For Ant builds, put the `mapstruct` jar on the `javac` classpath and the `mapstruct-processor` jar on `-processorpath`, and direct generated sources somewhere with `-s`. Adjust paths to your layout.

**Good example:**

```xml
<javac
    srcdir="src/main/java"
    destdir="target/classes"
    classpath="path/to/mapstruct-1.7.0.Beta1.jar">
    <compilerarg line="-processorpath path/to/mapstruct-processor-1.7.0.Beta1.jar"/>
    <compilerarg line="-s target/generated-sources"/>
</javac>
```

**Bad example:**

```xml
<!-- Processor on the regular classpath, no -processorpath, no -s for generated sources:
     generation is unreliable and the output location is undefined. -->
<javac srcdir="src/main/java" destdir="target/classes"
       classpath="path/to/mapstruct.jar;path/to/mapstruct-processor.jar"/>
```

### [2.4] Configure the generator with annotation processor options

Title: Pass `-Amapstruct.*` options via `compilerArgs` (Maven) / `options.compilerArgs` (Gradle) to set project-wide defaults.
Description: The code generator is configured with annotation processor options (`-Akey=value`). Set them once at the build level instead of repeating attributes on every `@Mapper`. Common options: suppress the timestamp/version comment for reproducible builds, raise `unmappedTargetPolicy` to `ERROR` to fail fast on forgotten properties, set a `defaultComponentModel`, and enable `verbose`. See **Appendix A** for the full table. Annotation-level attributes always override these global options.

**Good example:**

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.14.1</version>
    <configuration>
        <annotationProcessorPaths>
            <path>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct-processor</artifactId>
                <version>${org.mapstruct.version}</version>
            </path>
        </annotationProcessorPaths>
        <showWarnings>true</showWarnings>
        <compilerArgs>
            <arg>-Amapstruct.suppressGeneratorTimestamp=true</arg>
            <arg>-Amapstruct.suppressGeneratorVersionInfoComment=true</arg>
            <arg>-Amapstruct.defaultComponentModel=spring</arg>
            <arg>-Amapstruct.unmappedTargetPolicy=ERROR</arg>
            <arg>-Amapstruct.verbose=true</arg>
        </compilerArgs>
    </configuration>
</plugin>
```

```gradle
// Gradle equivalent
compileJava {
    options.compilerArgs += [
        '-Amapstruct.suppressGeneratorTimestamp=true',
        '-Amapstruct.defaultComponentModel=spring',
        '-Amapstruct.unmappedTargetPolicy=ERROR'
    ]
}
```

**Bad example:**

```java
// Repeating the same component model on every mapper instead of setting it once globally.
@Mapper(componentModel = "spring") interface AMapper { /* ... */ }
@Mapper(componentModel = "spring") interface BMapper { /* ... */ }
@Mapper(componentModel = "spring") interface CMapper { /* ... */ }
// Prefer -Amapstruct.defaultComponentModel=spring (override per-mapper only where needed).
```

> Note: for `mapstruct.verbose` under Maven you must also set `<showWarnings>true</showWarnings>` due to a maven-compiler-plugin limitation. **[1.7+]** adds `mapstruct.disableLifecycleOverloadDeduplicateSelector`.

### [2.5] Enable `@Generated` under the Java Module System

Title: When using JPMS (Java 9+), allow `java.annotation.processing.Generated` by requiring `java.compiler`.
Description: MapStruct works with Java 9 and higher. The generated mappers carry the `@Generated` annotation (`java.annotation.processing.Generated`), which lives in the `java.compiler` module — make sure it is available to your module.

**Good example:**

```java
// module-info.java
module com.acme.app {
    requires java.compiler;     // provides java.annotation.processing.Generated used by generated mappers
    requires org.mapstruct;     // mapstruct runtime (annotations like @Mapper)
    // ...
}
```

**Bad example:**

```java
// Using mapstruct annotations under JPMS without making the @Generated source module available
// can lead to the generated @Generated reference being unresolved.
module com.acme.app {
    requires org.mapstruct;
    // missing: requires java.compiler;
}
```

### [2.6] Install the IDE plugin for completion and navigation

Title: Add the IntelliJ IDEA or Eclipse MapStruct plugin for completion, go-to-declaration, find-usages, and quick fixes.
Description: Optional IDE plugins make `target`/`source`/`expression` properties first-class: code completion of property names, navigation to the underlying getters/setters, find-usages, refactoring support, and quick fixes for common errors. They do not change generation — they make authoring `@Mapping`s far less error-prone.

**Good example:**

```text
IntelliJ IDEA → Settings → Plugins → "MapStruct Support" (JetBrains Marketplace).
Eclipse → Marketplace → "MapStruct Eclipse Plugin".
Now @Mapping(target = "…", source = "…") offers property completion and flags typos.
```

**Bad example:**

```java
// Without the plugin, a typo in a property name is only caught at compile time:
@Mapping(target = "seatCnt", source = "numberOfSeats") // 'seatCnt' has no setter -> build error later
CarDto carToCarDto(Car car);
```

### [2.7] Add `kotlin-metadata-jvm` for Kotlin support **[1.7+]**

Title: On 1.7+, add `org.jetbrains.kotlin:kotlin-metadata-jvm` to the processor path for proper Kotlin interop.
Description: MapStruct 1.7.0.Beta1 introduces improved Kotlin/Java interoperability (single-field data classes, primary-constructor detection, data classes with multiple/all-default-parameter constructors, and subclass-exhaustiveness for Kotlin **sealed classes**). Adding `kotlin-metadata-jvm` to the annotation processor path is optional but **highly recommended** so MapStruct can introspect Kotlin metadata. This section and dependency do **not exist in 1.6.3**.

**Good example:**

```xml
<!-- [1.7+] Maven: alongside mapstruct-processor -->
<annotationProcessorPaths>
    <path>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct-processor</artifactId>
        <version>${org.mapstruct.version}</version>
    </path>
    <path>
        <groupId>org.jetbrains.kotlin</groupId>
        <artifactId>kotlin-metadata-jvm</artifactId>
        <version>${kotlin.version}</version>
    </path>
</annotationProcessorPaths>
```

```gradle
// [1.7+] Gradle
dependencies {
    implementation "org.mapstruct:mapstruct:${mapstructVersion}"
    annotationProcessor "org.mapstruct:mapstruct-processor:${mapstructVersion}"
    annotationProcessor "org.jetbrains.kotlin:kotlin-metadata-jvm:${kotlinVersion}"
}
```

**Bad example:**

```text
Targeting MapStruct 1.6.3 and expecting Kotlin metadata introspection / sealed-class
exhaustiveness — this support does not exist before 1.7. Upgrade to 1.7+ first.
```

## Chapter 3 — Defining a mapper

### [3.1] Declare an `@Mapper` interface and map same-named properties implicitly

Title: Annotate the interface with `@Mapper`; map matching property names automatically and rename the rest with `@Mapping`.
Description: All readable properties of the source are copied into the same-named target properties automatically (per the JavaBeans convention — `getSeatCount()`/`setSeatCount()` ⇒ property `seatCount`). When a name differs, add `@Mapping(target = "...", source = "...")`. Multiple `@Mapping`s can be stacked directly on the method (repeatable) or grouped in `@Mappings`. Fluent setters (setters returning the bean type) are supported. The generated code reads "as if hand-written". To require every mapping to be explicit and silence unmapped-target warnings, use `@BeanMapping(ignoreByDefault = true)`.

**Good example:**

```java
@Mapper
public interface CarMapper {
    CarMapper INSTANCE = Mappers.getMapper( CarMapper.class );

    @Mapping(target = "manufacturer", source = "make")     // renamed
    @Mapping(target = "seatCount", source = "numberOfSeats")
    CarDto carToCarDto(Car car);                            // other same-named props map implicitly
}
```

```java
// GENERATED (excerpt) — plain getters/setters, null-aware, recursive into referenced beans:
carDto.setManufacturer( car.getMake() );
carDto.setSeatCount( car.getNumberOfSeats() );
carDto.setDriver( personToPersonDto( car.getDriver() ) );
```

**Bad example:**

```java
// Hand-written, repetitive, and silently drifts when a field is added/renamed:
public CarDto carToCarDto(Car car) {
    CarDto dto = new CarDto();
    dto.setManufacturer(car.getMake());
    dto.setSeatCount(car.getNumberOfSeats());
    // forgot dto.setDriver(...) — no compiler help, no warning
    return dto;
}
```

### [3.2] Bundle repeated `@Mapping`s into a meta-annotation (mapping composition)

Title: Move a recurring set of `@Mapping` rules onto a custom annotation and reuse it across methods.
Description: Because `@Mapping` targets `METHOD` **and** `ANNOTATION_TYPE`, you can put a set of `@Mapping`s on your own `@interface` (retention `CLASS`) and apply that annotation to several mapper methods, then add method-specific `@Mapping`s alongside. This removes duplication for "duck-typed" targets that share property semantics but no common base type.

**Good example:**

```java
@Retention(RetentionPolicy.CLASS)
@Mapping(target = "id", ignore = true)
@Mapping(target = "creationDate", expression = "java(new java.util.Date())")
@Mapping(target = "name", source = "groupName")
public @interface ToEntity { }

@Mapper
public interface StorageMapper {
    @ToEntity @Mapping(target = "weightLimit", source = "maxWeight")
    ShelveEntity map(ShelveDto source);

    @ToEntity @Mapping(target = "label", source = "designation")
    BoxEntity map(BoxDto source);
}
```

**Bad example:**

```java
// Same four rules copy-pasted onto every method; change one and you must change all.
@Mapper
public interface StorageMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "creationDate", expression = "java(new java.util.Date())")
    @Mapping(target = "name", source = "groupName")
    @Mapping(target = "weightLimit", source = "maxWeight")
    ShelveEntity map(ShelveDto source);
    // ...repeat the first three rules again for BoxEntity...
}
```

> Caveat: error messages are reported as if the composed `@Mapping`s were written directly on the method. For a fully type-safe alternative, use base types + `@InheritConfiguration` (§11.1).

### [3.3] Add hand-written mappings as `default` methods or abstract-class methods

Title: When MapStruct cannot generate a mapping, implement it as a `default` method (interface) or a concrete method (abstract-class mapper).
Description: For logic MapStruct cannot derive, hand-write it. In an interface, add a `default` method; MapStruct calls it wherever its argument/return types match. Alternatively declare the mapper as an `abstract class` and implement concrete methods — this additionally lets you declare fields in the mapper.

**Good example:**

```java
@Mapper
public interface CarMapper {
    CarDto carToCarDto(Car car);                 // generated; calls personToPersonDto for the driver

    default PersonDto personToPersonDto(Person p) {
        // hand-written logic MapStruct can't infer
        return p == null ? null : new PersonDto(p.getFirstName() + " " + p.getLastName());
    }
}
```

**Bad example:**

```java
// Forcing the custom logic into an expression string — unreadable, untestable, no IDE help:
@Mapper
public interface CarMapper {
    @Mapping(target = "driver",
        expression = "java(car.getDriver()==null?null:new PersonDto(car.getDriver().getFirstName()+\" \"+car.getDriver().getLastName()))")
    CarDto carToCarDto(Car car);
}
```

### [3.4] Combine several source parameters into one target

Title: Accept multiple source parameters and qualify each `source` with the parameter name when names collide.
Description: A mapping method may take several sources (e.g. combine `Person` + `Address` into a `DeliveryAddressDto`). Qualify ambiguous properties as `parameterName.property`. You can also map a whole (non-bean) parameter to a target property by referencing the parameter name directly. The method returns `null` only when **all** source parameters are `null`.

**Good example:**

```java
@Mapper
public interface AddressMapper {
    @Mapping(target = "description", source = "person.description")
    @Mapping(target = "houseNumber", source = "address.houseNo")
    DeliveryAddressDto toDeliveryAddress(Person person, Address address);

    // referring directly to a parameter:
    @Mapping(target = "houseNumber", source = "hn")
    DeliveryAddressDto toDeliveryAddress(Person person, Integer hn);
}
```

**Bad example:**

```java
// Leaving an ambiguous property unqualified when both parameters expose 'description'
// -> compile error: MapStruct can't tell which source to use.
@Mapping(target = "description", source = "description") // ambiguous: person AND address have it
DeliveryAddressDto toDeliveryAddress(Person person, Address address);
```

### [3.5] Flatten or merge a nested bean with `target = "."`

Title: Use `target = "."` ("target this") to map every property of a source bean into the current target.
Description: Instead of listing each property of a nested source, map the whole bean with `@Mapping(target = ".", source = "record")`. This is ideal for hierarchical→flat mapping (and the reverse with `@InheritInverseConfiguration`). Resolve name clashes across the merged sources with explicit `@Mapping`s.

**Good example:**

```java
@Mapper
public interface CustomerMapper {
    @Mapping(target = "name", source = "record.name")  // resolve clash between record & account
    @Mapping(target = ".", source = "record")
    @Mapping(target = ".", source = "account")
    Customer customerDtoToCustomer(CustomerDto customerDto);
}
```

**Bad example:**

```java
// Enumerating every nested property by hand — verbose and fragile as the source grows:
@Mapping(target = "name",    source = "record.name")
@Mapping(target = "street",  source = "record.street")
@Mapping(target = "city",    source = "record.city")
@Mapping(target = "zip",     source = "record.zip")
// ...one line per field forever...
Customer customerDtoToCustomer(CustomerDto customerDto);
```

### [3.6] Update an existing instance with `@MappingTarget`

Title: Add a `@MappingTarget` parameter to update an existing bean in place instead of creating a new one.
Description: Mark the target parameter with `@MappingTarget`; the generated code updates that instance. Only one parameter may be the mapping target. Return `void`, or return the target type to allow fluent chaining. For collection/map properties, behavior depends on `CollectionMappingStrategy`: with `ACCESSOR_ONLY` the target collection is cleared then refilled; with `ADDER_PREFERRED`/`TARGET_IMMUTABLE` it is not cleared. See also §10.8 for null-property handling on updates.

**Good example:**

```java
@Mapper
public interface CarMapper {
    void updateCarFromDto(CarDto dto, @MappingTarget Car car);   // updates 'car' in place
    Car updateAndReturn(CarDto dto, @MappingTarget Car car);     // same, but fluent
}
```

**Bad example:**

```java
// Creating a fresh Car when the caller needed the managed/attached instance updated:
@Mapper
public interface CarMapper {
    Car carDtoToCar(CarDto dto); // returns a NEW Car; caller's existing entity is untouched
}
```

### [3.7] Map `public` fields directly when there are no getters/setters

Title: MapStruct uses `public` fields as accessors when no getter/setter exists.
Description: A `public` (or `public final`) field is a read accessor; a `public`, non-`final`, non-`static` field is a write accessor. So you can map beans that expose fields directly, mixing field access on one side with getters/setters on the other. `static` fields are never accessors.

**Good example:**

```java
public class CustomerDto { public Long id; public String customerName; } // public fields

@Mapper
public interface CustomerMapper {
    @Mapping(target = "name", source = "customerName")
    Customer toCustomer(CustomerDto dto);          // reads dto.id / dto.customerName directly
    @InheritInverseConfiguration
    CustomerDto fromCustomer(Customer c);
}
```

**Bad example:**

```java
// Adding pointless boilerplate getters/setters just to satisfy a mapper that already
// supports field access — unnecessary on MapStruct.
public class CustomerDto {
    public Long id;
    public Long getId(){return id;} public void setId(Long v){id=v;} // redundant
}
```

### [3.8] Map to immutable types through their builder

Title: Let MapStruct detect and use the target's builder; finish with the build method.
Description: When the target has a builder (Lombok `@Builder`, AutoValue, Immutables, FreeBuilder, or a hand-written one), MapStruct maps into the builder via its setters and calls the build method to finish. By default the `BuilderProvider` SPI looks for a parameterless `public static` builder-creation method **or** a `public static` inner class named `*Builder`; the build method must be a parameterless public method returning the built type (if several exist, MapStruct prefers one named `build`, else errors). Pick a specific build method with `@Builder` (on `@BeanMapping`/`@Mapper`/`@MapperConfig`). Disable builders with `@Builder(disableBuilder = true)` or `-Amapstruct.disableBuilders=true`. **[1.7+]**: a `*Builder` inner class with a *parameterized* constructor is also detected (static builder-creation methods still take precedence).

**Good example:**

```java
public class Person {                       // immutable, built via builder
    private final String name;
    private Person(Builder b) { this.name = b.name; }
    public static Builder builder() { return new Builder(); }
    public static class Builder {
        private String name;
        public Builder name(String n) { this.name = n; return this; }
        public Person create() { return new Person(this); }   // single build method -> used
    }
}

@Mapper public interface PersonMapper { Person map(PersonDto dto); }
```

```java
// GENERATED:
Person.Builder builder = Person.builder();
builder.name( dto.getName() );
return builder.create();
```

**Bad example:**

```java
// Disabling builders and then failing to map an immutable type that has no usable setters/constructor:
@Mapper(disableBuilders = true) // now MapStruct falls back to getters/setters that don't exist
public interface PersonMapper { Person map(PersonDto dto); } // -> unmapped/uninstantiable target
```

### [3.9] Map to immutable types through their constructor

Title: Let MapStruct call the target constructor; resolve constructor ambiguity with `@Default` and expose names via `-parameters`.
Description: MapStruct can construct the target via a constructor, matching constructor parameter names to target properties (a property covered by a constructor parameter is **not** also set via a setter). Selection order: (1) a constructor annotated `@Default` (from any package); (2) a single `public` constructor; (3) a parameterless constructor; (4) otherwise a compile error — annotate the intended one with `@Default`. Parameter names come from bytecode compiled with `-parameters`, or from `@ConstructorProperties`. An object factory / `@ObjectFactory` method takes precedence over any constructor.

**Good example:**

```java
public class Truck {
    public Truck() {}
    @Default                                  // disambiguates: use this constructor
    public Truck(String make, String color) { /* ... */ }
}
// Compile with -parameters (or use @ConstructorProperties) so 'make'/'color' map by name.
```

```java
// GENERATED for a 2-arg-constructor target:
String name = dto.getName();
String surname = dto.getSurname();
Person person = new Person( name, surname );
```

**Bad example:**

```java
// Two eligible constructors, none marked @Default, compiled without -parameters:
public class Van {
    public Van(String make) {}
    public Van(String make, String color) {}   // -> compile error: MapStruct can't pick a constructor
}
```

### [3.10] Map `java.util.Optional` sources and targets **[1.7+]**

Title: On 1.7+, use `Optional` directly as source/target/property; MapStruct presence-checks and wraps/unwraps for you.
Description: MapStruct 1.7.0.Beta1 adds native `java.util.Optional` support across all scenarios — `Optional`→`Optional`, `Optional`→non-`Optional`, non-`Optional`→`Optional`, `Optional` properties, update methods, builders, and constructors. For an `Optional` **source**, MapStruct uses a presence check (`isPresent()`/`isEmpty()`) instead of a null check and unwraps with `get()`. For an `Optional` **target**, an absent source yields `Optional.empty()` (not `null`) and a present value is wrapped with `Optional.of(...)`. This does **not exist in 1.6.3** — there you must unwrap `Optional` yourself in custom methods. (See §5.1 for `Optional`/`OptionalInt`/`OptionalLong`/`OptionalDouble` in implicit conversions, and §10.8 for how null-property strategies treat empty `Optional`s.)

**Good example:**

```java
// [1.7+]
@Mapper
public interface ProductMapper {
    Optional<ProductDto> map(Optional<Product> product);  // Optional -> Optional
    ProductDto unwrap(Optional<Product> product);         // Optional -> plain (empty => null)
    Optional<ProductDto> wrap(Product product);           // plain -> Optional (null => Optional.empty())
}
```

```java
// GENERATED for map(Optional<Product>):
if ( product.isEmpty() ) { return Optional.empty(); }
Product productValue = product.get();
ProductDto productDto = new ProductDto();
productDto.setName( productValue.getName() );
return Optional.of( productDto );
```

**Bad example:**

```java
// On 1.6.3 there is no Optional support — declaring Optional types just produces
// unmapped/incorrect mappings. Unwrap by hand instead (pre-1.7):
default ProductDto unwrap(Optional<Product> p) {
    return p.map(this::map).orElse(null);   // explicit, because the engine won't do it on 1.6.3
}
```

### [3.11] Map a `Map<String, ?>` into a bean

Title: Map a `Map<String, ?>` into a bean using target property names (or `@Mapping(source = "<key>")`), with conversions applied per value.
Description: MapStruct can populate a bean from a `Map`, using each target property name as the key (or a key named via `@Mapping#source`). Normal type-conversion rules and `uses` mappers apply per value (e.g. `Map<String, Integer>` converts each `Integer` to the property type). The generated code uses `containsKey`/`get`. A raw map, or a map whose key is not `String`, produces a warning (unless the map is mapped directly into a target property as-is).

**Good example:**

```java
@Mapper
public interface CustomerMapper {
    @Mapping(target = "name", source = "customerName")   // value comes from key "customerName"
    Customer toCustomer(Map<String, String> map);
}
```

```java
// GENERATED:
if ( map.containsKey( "id" ) )           { customer.setId( Integer.parseInt( map.get( "id" ) ) ); }
if ( map.containsKey( "customerName" ) ) { customer.setName( map.get( "customerName" ) ); }
```

**Bad example:**

```java
// Manually pulling keys and converting by hand — exactly the boilerplate MapStruct removes:
Customer c = new Customer();
c.setId(Long.valueOf(map.get("id")));
c.setName(map.get("customerName"));
```

### [3.12] Add framework annotations to the generated mapper with `@AnnotateWith` **[1.6+]**

Title: Use `@AnnotateWith` to place a required framework annotation on the generated class or method.
Description: Some frameworks detect classes/methods by annotation. `@AnnotateWith(value = X.class, elements = @AnnotateWith.Element(...))` adds annotation `X` (with members) to the generated mapper type or a method. `@Deprecated` is copied automatically. Added in 1.6.0; **[1.7+]** also allows `@AnnotateWith` on decorators.

**Good example:**

```java
@Mapper
@AnnotateWith(value = Converter.class,
    elements = @AnnotateWith.Element(name = "generateBulkLoader", booleans = true))
public interface MyConverter {
    @AnnotateWith(Converter.class)
    DomainObject map(DtoObject dto);
}
// GENERATED: @Converter(generateBulkLoader = true) public class MyConverterImpl ... { @Converter ... }
```

**Bad example:**

```java
// Subclassing the generated *Impl just to slap a framework annotation on it — brittle,
// and the subclass is not what MapStruct/DI wires up.
@Converter
public class MyConverterImplAnnotated extends MyConverterImpl {}
```

### [3.13] Generate Javadoc on the mapper with `@Javadoc` **[1.6+]**

Title: Attach Javadoc to the generated implementation with `@Javadoc` (added in 1.6.0).
Description: Use `@Javadoc` to emit Javadoc on the generated `*Impl` — useful where Javadoc standards/validation are enforced. Provide structured attributes (`value`, `authors`, `deprecated`, `since`) or the whole block as a concatenated string / text block.

**Good example:**

```java
@Mapper
@Javadoc(value = "This is the description",
         authors = { "author1", "author2" },
         deprecated = "Use {@link OtherMapper} instead",
         since = "0.1")
public interface MyAnnotatedWithJavadocMapper { /* ... */ }
```

**Bad example:**

```java
// Writing Javadoc on the interface and expecting it to land on the generated *Impl — it won't;
// use @Javadoc so the generated class carries it.
/** Important contract notes... */     // stays on the interface only
@Mapper public interface MyMapper { /* ... */ }
```

## Chapter 4 — Retrieving a mapper

### [4.1] Obtain a stateless mapper from the `Mappers` factory via an `INSTANCE` field

Title: Without DI, get the mapper from `Mappers.getMapper(...)` and cache it in a public `INSTANCE` field.
Description: When you are not using a DI framework, retrieve a mapper with `org.mapstruct.factory.Mappers.getMapper(CarMapper.class)`. By convention the mapper declares a public static `INSTANCE` field holding the singleton. Generated mappers are **stateless and thread-safe**, so a single instance can be shared across threads.

**Good example:**

```java
@Mapper
public interface CarMapper {
    CarMapper INSTANCE = Mappers.getMapper( CarMapper.class );
    CarDto carToCarDto(Car car);
}
// usage: CarDto dto = CarMapper.INSTANCE.carToCarDto(car);
```

**Bad example:**

```java
// Calling the reflective factory on every use (needless lookups) — they are stateless singletons:
CarDto dto = Mappers.getMapper(CarMapper.class).carToCarDto(car); // do this once into INSTANCE instead
```

### [4.2] Generate an injectable mapper with `componentModel`

Title: Set `componentModel` (or `mapstruct.defaultComponentModel`) so the mapper is a managed bean you `@Inject`/`@Autowired`.
Description: With a DI container, set `@Mapper(componentModel = ...)` and inject the mapper instead of using `Mappers`. Supported values (in `MappingConstants.ComponentModel`): `default` (use the `Mappers` factory), `spring` (singleton Spring bean, `@Autowired`), `cdi` (`@ApplicationScoped`, `@Inject`), `jsr330` (`@Named`+`@Inject`, javax), `jakarta` (`@Named`+`@Inject`, jakarta), `jakarta-cdi` (jakarta `@ApplicationScoped`). A mapper that `uses` other mappers will resolve them via the same component model — so referenced mappers must also be managed beans.

**Good example:**

```java
@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface CarMapper { CarDto carToCarDto(Car car); }

@Service
class CarService {
    private final CarMapper carMapper;
    CarService(CarMapper carMapper) { this.carMapper = carMapper; } // injected Spring bean
}
```

**Bad example:**

```java
// componentModel = "default" but injected into Spring — Spring has no bean to inject:
@Mapper // default model: instances come from Mappers.getMapper, NOT the Spring context
public interface CarMapper { CarDto carToCarDto(Car car); }

@Autowired CarMapper carMapper; // NoSuchBeanDefinitionException at startup
```

### [4.3] Prefer constructor injection (and use setter injection for cycles/decorators)

Title: Set `injectionStrategy = InjectionStrategy.CONSTRUCTOR` for testability; fall back to `SETTER` for circular deps, abstract classes, and decorators.
Description: For annotation-based component models, choose how injected `uses` mappers are wired with `@Mapper(injectionStrategy = ...)` (or `@MapperConfig`, or the global `mapstruct.defaultInjectionStrategy`). `InjectionStrategy` supports `FIELD` (default), `CONSTRUCTOR`, and `SETTER`. Constructor injection is recommended (simplifies testing). Use `SETTER` when Spring circular dependencies break constructor wiring, and for abstract-class mappers / decorators.

**Good example:**

```java
@Mapper(componentModel = MappingConstants.ComponentModel.SPRING,
        uses = EngineMapper.class,
        injectionStrategy = InjectionStrategy.CONSTRUCTOR)   // testable, final fields
public interface CarMapper { CarDto carToCarDto(Car car); }
```

**Bad example:**

```java
// Two Spring mappers that 'use' each other with default FIELD/CONSTRUCTOR wiring -> startup cycle.
// Fix by switching to setter injection:
@Mapper(componentModel = "spring", uses = B.class, injectionStrategy = InjectionStrategy.CONSTRUCTOR)
interface A { /* needs B */ }
@Mapper(componentModel = "spring", uses = A.class, injectionStrategy = InjectionStrategy.CONSTRUCTOR)
interface B { /* needs A */ }   // BeanCurrentlyInCreationException -> use InjectionStrategy.SETTER
```

## Chapter 5 — Data type conversions

### [5.1] Rely on built-in implicit conversions; control formatting with `numberFormat`/`dateFormat`

Title: Let MapStruct convert between compatible types automatically, and pass a format string where a textual representation is involved.
Description: MapStruct performs many conversions automatically and null-aware (see **Appendix B** for the full list): primitive↔wrapper, between numeric types, any primitive/wrapper↔`String`, big numbers↔primitives/`String`, `enum`↔`String`, `enum`↔`Integer` (by ordinal) **[1.6+]**, date/time types (`Date`/`Calendar`/`XMLGregorianCalendar`/Joda/`java.time`)↔`String` and among each other, `UUID`/`URL`/`Currency`/`Locale`↔`String`, `String`↔`StringBuilder`, and more. Supply `numberFormat` (a `DecimalFormat` pattern) or `dateFormat` (a `SimpleDateFormat` pattern) on `@Mapping`/`@IterableMapping`/`@MapMapping` to control textual form. Be aware narrowing conversions (e.g. `long`→`int`) can lose data — control reporting with `typeConversionPolicy` (default `IGNORE` for backward compatibility). **[1.7+]**: a `locale` can be given for number/date formatting; `String`→`Number` is now treated as lossy (warning per `typeConversionPolicy`); and all conversions also work wrapped in `Optional`/`OptionalInt`/`OptionalLong`/`OptionalDouble`.

**Good example:**

```java
@Mapper
public interface CarMapper {
    @Mapping(source = "price", numberFormat = "$#.00")           // int -> "$..." 
    @Mapping(source = "manufacturingDate", dateFormat = "dd.MM.yyyy") // Date -> "dd.MM.yyyy"
    CarDto carToCarDto(Car car);
}
```

**Bad example:**

```java
// Re-implementing a built-in conversion with a brittle hand-written method:
@Mapper
public interface CarMapper {
    @Mapping(target = "price", expression = "java(String.valueOf(car.getPrice()))") // unnecessary
    CarDto carToCarDto(Car car);   // int->String is already a built-in conversion
}
```

### [5.2] Map referenced beans by declaring a method for the referenced type

Title: To map a nested object (e.g. `Person driver` → `PersonDto`), just declare a mapping method for that type — MapStruct chains the calls.
Description: When a property's source and target types differ, MapStruct resolves the mapping in this order: (1) **direct** copy if types match (collections are copied); (2) an existing **mapping method** taking the source type and returning the target type; (3) a **built-in conversion**; (4) **complex** combinations (method∘method, method∘conversion, conversion∘method); (5) an **auto-generated sub-mapping method**; (6) otherwise a build-time error naming the non-mappable attribute. So declaring `PersonDto personToPersonDto(Person)` is enough for `Car.driver` to be mapped. Stop auto sub-mapping generation with `@Mapper(disableSubMappingMethodsGeneration = true)`; control which mechanisms are allowed with `MappingControl` (e.g. the `@DeepClone` meta-annotation allows only direct mapping). *(MappingControl is experimental since 1.4.)*

**Good example:**

```java
@Mapper
public interface CarMapper {
    CarDto carToCarDto(Car car);
    PersonDto personToPersonDto(Person person);   // MapStruct calls this for car.getDriver()
}
```

**Bad example:**

```java
// Flattening a nested object via an expression instead of a reusable mapping method:
@Mapping(target = "driverName", expression = "java(car.getDriver().getName())") // NPE-prone, not reused
CarDto carToCarDto(Car car);
```

### [5.3] Correct, ignore, flatten, and unflatten nested properties with dot notation

Title: Use dotted `source`/`target` paths to fix deviating nested names, ignore nested properties, and reshape nesting depth.
Description: Dot notation in `@Mapping` controls nested mapping: `@Mapping(target = "fish.kind", source = "fish.type")` corrects a nested name; `@Mapping(target = "fish.name", ignore = true)` ignores one; `@Mapping(target = "ornament", source = "interior.ornament")` flattens; `@Mapping(target = "quality.report.organisation.name", source = "quality.report.organisationName")` unflattens. MapStruct null-checks each nested source level. **[1.7+]**: group several ignores with `@Ignored(targets = { ... })`. Tip: for heavy nesting, write explicit nested mapping methods to centralize and reuse the configuration.

**Good example:**

```java
@Mapper
public interface FishTankMapper {
    @Mapping(target = "fish.kind",   source = "fish.type")
    @Mapping(target = "fish.name",   ignore = true)
    @Mapping(target = "ornament",    source = "interior.ornament")        // flatten
    @Mapping(target = "quality.report.organisation.name",
             source = "quality.report.organisationName")                  // unflatten
    FishTankDto map(FishTank source);
}
```

**Bad example:**

```java
// Mapping the outer beans but forgetting the deviating nested name -> "fish.kind" unmapped warning,
// and a null source level dereferenced in hand code:
@Mapping(target = "fish", source = "fish") // 'type' vs 'kind' mismatch left unresolved
FishTankDto map(FishTank source);
```

### [5.4] Compute a target property from the whole source via a custom method

Title: Point `source` at the **parameter name** and provide a custom method that takes the whole source.
Description: When a target property is derived from several source fields, write a custom method that accepts the source object and returns the property type, then reference the parameter by name: `@Mapping(target = "volume", source = "source")` where the method is `map(FishTank source)`. MapStruct passes the entire `source` to your `mapVolume(FishTank)`.

**Good example:**

```java
@Mapper
public abstract class FishTankMapper {
    @Mapping(target = "volume", source = "source")   // 'source' is the parameter, not a property
    abstract FishTankWithVolumeDto map(FishTank source);

    VolumeDto mapVolume(FishTank s) {
        int v = s.length * s.width * s.height;
        return new VolumeDto(v, v < 100 ? "Small" : "Large");
    }
}
```

**Bad example:**

```java
// Trying to express a multi-field computation as a property path — there is no single source property:
@Mapping(target = "volume", source = "length") // can't reach width/height; wrong result
FishTankWithVolumeDto map(FishTank source);
```

### [5.5] Reuse mapping logic from other classes with `uses`

Title: Register helper/mapper classes on `@Mapper(uses = ...)` so MapStruct calls their methods where types match.
Description: `uses` lets the generated mapper call methods on other classes (generated mappers or hand-written helpers), e.g. a `DateMapper` that converts `Date`↔`String`. MapStruct finds the matching method and invokes it. Referenced mappers are obtained through the configured component model (a CDI mapper needs CDI helpers); for the default model, a hand-written helper must have a public no-args constructor.

**Good example:**

```java
public class DateMapper {                       // hand-written helper
    public String asString(Date d) { return d == null ? null : new SimpleDateFormat("yyyy-MM-dd").format(d); }
    public Date asDate(String s) { /* parse */ return null; }
}

@Mapper(uses = DateMapper.class)
public interface CarMapper { CarDto carToCarDto(Car car); } // uses asString for manufacturingDate
```

**Bad example:**

```java
// Copy-pasting the same Date<->String helper into every mapper as default methods,
// instead of one shared class referenced via uses:
@Mapper interface CarMapper { default String asString(Date d){/*...*/} /* duplicated everywhere */ }
```

### [5.6] Resolve a generic target type with a `@TargetType` parameter

Title: Add a `@TargetType Class<T>` parameter to a custom method so it can serve many target types generically.
Description: A custom method in a `uses` class can take an extra `Class` (or super-type) parameter annotated `@TargetType`; MapStruct passes the target property's `Class`. This enables generic resolution — e.g. looking up a JPA entity from a `Reference` for whatever entity type is needed.

**Good example:**

```java
public class ReferenceMapper {
    @PersistenceContext EntityManager em;
    public <T extends BaseEntity> T resolve(Reference ref, @TargetType Class<T> type) {
        return ref == null ? null : em.find(type, ref.getPk());
    }
}
@Mapper(componentModel = "cdi", uses = ReferenceMapper.class)
public interface CarMapper { Car carDtoToCar(CarDto dto); }
// GENERATED: car.setOwner( referenceMapper.resolve( dto.getOwner(), Owner.class ) );
```

**Bad example:**

```java
// One resolve method per entity type, duplicating identical logic:
public Owner resolveOwner(Reference r){ return em.find(Owner.class, r.getPk()); }
public Driver resolveDriver(Reference r){ return em.find(Driver.class, r.getPk()); } // and so on...
```

### [5.7] Thread context/state through with `@Context`

Title: Pass cross-cutting context (locale, cache, persistence context) via `@Context` parameters that MapStruct forwards everywhere.
Description: `@Context` parameters are forwarded through generated mapping methods to other mapping methods, `@ObjectFactory` methods, and `@BeforeMapping`/`@AfterMapping` methods, and are available to your custom code. For the generated code to call a method that needs `@Context` params, the calling mapping method must declare those (or assignable) `@Context` params too — MapStruct won't invent them. No null check is done before invoking lifecycle/factory methods on context values.

**Good example:**

```java
public abstract CarDto toCar(Car car, @Context Locale locale);   // locale flows down...
protected OwnerManualDto translate(OwnerManual m, @Context Locale locale) { /* uses locale */ }
// GENERATED: carDto.setOwnerManual( translate( car.getOwnerManual(), locale ) );
```

**Bad example:**

```java
// Smuggling per-call state through a mutable field on the mapper — breaks thread-safety:
@Mapper public abstract class CarMapper {
    private Locale locale;                 // shared mutable state on a stateless mapper -> race conditions
    public void setLocale(Locale l){ this.locale = l; }
    public abstract CarDto toCar(Car car);
}
```

### [5.8] Let MapStruct pick the most specific mapping method

Title: Trust method resolution (most-specific source type wins); avoid genuinely ambiguous overloads.
Description: When mapping between types, MapStruct selects the most specific applicable method declared on the mapper or in a `uses` class (factory methods too), much like Java overload resolution. If two equally specific methods match, it raises an ambiguity error — resolve with qualifiers (§5.9) or `resultType` (§10.5). For JAXB, `@XmlElementDecl` `scope`/`name` are considered when choosing a method.

**Good example:**

```java
@Mapper
public interface ShapeMapper {
    ShapeDto map(Shape shape);
    CircleDto map(Circle circle);   // more specific -> used for Circle instances
}
```

**Bad example:**

```java
// Two indistinguishable String->String methods, no qualifier -> ambiguous mapping method error:
@Mapper(uses = Titles.class) interface MovieMapper { GermanRelease toGerman(OriginalRelease m); }
class Titles { String translateEG(String t){} String translateGE(String t){} } // which one? -> error
```

### [5.9] Disambiguate equal-signature methods with qualifiers (`@Qualifier`/`@Named`)

Title: Tag candidate methods with a custom `@Qualifier` annotation (or `@Named`) and select them with `qualifiedBy`/`qualifiedByName`.
Description: When several methods share a signature but differ in behavior, mark them with a qualifier and reference it from the mapping. A type-safe qualifier is a custom annotation meta-annotated with `@Qualifier` (retention **must** be `CLASS`), selected via `@Mapping(qualifiedBy = ...)`/`@BeanMapping#qualifiedBy`. The lightweight alternative is `@Named("...")` selected via `qualifiedByName`. Note: once a method carries a qualifier, it no longer qualifies for mappings that don't request it.

**Good example:**

```java
@Named("Titles")
public class Titles {
    @Named("EnglishToGerman") public String eg(String t) { /* ... */ }
    @Named("GermanToEnglish") public String ge(String t) { /* ... */ }
}
@Mapper(uses = Titles.class)
public interface MovieMapper {
    @Mapping(target = "title", qualifiedByName = { "Titles", "EnglishToGerman" })
    GermanRelease toGerman(OriginalRelease movies);
}
```

**Bad example:**

```java
// Using a RUNTIME-retained qualifier (or none) — MapStruct can't see it; ambiguity persists:
@Qualifier @Retention(RetentionPolicy.RUNTIME)  // WRONG: must be CLASS
public @interface EnglishToGerman {}
```

### [5.10] Make a qualified default value go through the right method

Title: When you combine `qualifiedByName` with `defaultValue`, supply a method that maps the default's `String` to the target type (or use `defaultExpression`).
Description: A `defaultValue` is a `String` that must be converted to the target. If the mapping is qualified, MapStruct uses the qualified method for the default too — which may not accept a `String`. Provide an additional qualified method `String → TargetType`, or fall back to `defaultExpression`.

**Good example:**

```java
@Mapper
public interface MovieMapper {
    @Mapping(target = "category", qualifiedByName = "CategoryToString", defaultValue = "Unknown")
    GermanRelease toGerman(OriginalRelease movies);

    @Named("CategoryToString") default String fromCat(Category c) { /* ... */ }
    @Named("CategoryToString") default String fromString(String v) { return v; } // handles the default
}
```

**Bad example:**

```java
// Qualified mapping whose only qualified method takes a Category, with a String defaultValue:
@Mapping(target = "category", qualifiedByName = "CategoryToString", defaultValue = "Unknown")
GermanRelease toGerman(OriginalRelease movies);
// MapStruct calls CategoryToString(Enum.valueOf(Category.class,"Unknown")) -> not what you meant.
```

## Chapter 6 — Mapping collections

### [6.1] Map `Map` types and format keys/values with `@MapMapping`

Title: Declare a `Map`→`Map` method; convert keys/values implicitly and format with `@MapMapping`.
Description: Map-typed mapping methods work like iterable mappings: the generated code iterates entries, converts each key and value (via implicit conversion or another mapping method), and puts them into the target map. Use `@MapMapping(keyDateFormat = ..., valueDateFormat = ...)` (and the number-format equivalents) for textual key/value conversions.

**Good example:**

```java
public interface SourceTargetMapper {
    @MapMapping(valueDateFormat = "dd.MM.yyyy")
    Map<String, String> longDateMapToStringStringMap(Map<Long, Date> source);
}
// GENERATED: iterates entries, Long.toString / SimpleDateFormat("dd.MM.yyyy").format per entry.
```

**Bad example:**

```java
// Hand-iterating a map conversion that @MapMapping generates for you:
Map<String,String> out = new LinkedHashMap<>();
for (var e : source.entrySet()) out.put(e.getKey().toString(), fmt.format(e.getValue())); // boilerplate
```

### [6.2] Choose a `CollectionMappingStrategy` (adder vs setter) for the target's API

Title: Set `collectionMappingStrategy` to match how the target exposes collections — especially `ADDER_PREFERRED` for JPA entities with `addXxx`.
Description: `CollectionMappingStrategy` decides whether the target's setter, adder, or getter is used to populate a collection property: `ACCESSOR_ONLY` (default), `SETTER_PREFERRED`, `ADDER_PREFERRED`, `TARGET_IMMUTABLE`. For JPA entities that expose `addChild(child)` (to maintain the parent side of a bidirectional relation), `ADDER_PREFERRED` makes MapStruct call the adder per element. (`DEFAULT` is synonymous with `ACCESSOR_ONLY` and only meaningful to distinguish an explicit choice in `@MapperConfig`.) MapStruct matches the adder by the collection's element type, falling back to the singularized getter/setter name.

**Good example:**

```java
@Mapper(collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED)
public interface OrderMapper {
    OrderEntity map(OrderDto dto);   // calls orderEntity.addItem(item) per element, wiring the back-reference
}
```

**Bad example:**

```java
// Default ACCESSOR_ONLY on a JPA entity whose setter doesn't set the child's parent ->
// detached children / broken bidirectional relation:
@Mapper public interface OrderMapper { OrderEntity map(OrderDto dto); } // setItems(list) skips addItem()
```

### [6.3] Know which implementation type is created for an interface return type

Title: Expect a specific concrete type when a mapping method returns a collection/map interface.
Description: For interface return types MapStruct instantiates: `Iterable`/`Collection`/`List`→`ArrayList`; `Set`→`LinkedHashSet`; `SortedSet`/`NavigableSet`→`TreeSet`; `Map`→`LinkedHashMap`; `SortedMap`/`NavigableMap`→`TreeMap`; `ConcurrentMap`→`ConcurrentHashMap`; `ConcurrentNavigableMap`→`ConcurrentSkipListMap`. **[1.7+]** adds Java 21 sequenced collections: `SequencedSet`→`LinkedHashSet`, `SequencedMap`→`LinkedHashMap`.

**Good example:**

```java
List<CarDto> mapCars(List<Car> cars);     // -> new ArrayList<>()
Set<String>  tags(List<String> in);       // -> new LinkedHashSet<>()  (insertion order preserved)
```

**Bad example:**

```java
// Returning SequencedSet on a 1.6.3 project (no impl mapping) — not supported pre-1.7:
SequencedSet<String> tags(List<String> in); // [1.7+] only
```

## Chapter 7 — Mapping Streams

### [7.1] Map to/from `java.util.Stream` like collections (and beware consumption)

Title: Declare mapping methods with `Stream` source or target; MapStruct builds/collects and maps elements — but a consumed source `Stream` cannot be reused.
Description: `Stream` mapping mirrors collection mapping: MapStruct creates a `Stream` from an `Iterable`/array, or collects a `Stream` into an `Iterable`/array (using the §6.3 implementation types), applying any element mapping method/conversion inside `Stream#map`. ⚠️ Mapping a `Stream` to an `Iterable`/array **consumes** the source stream — it cannot be consumed again afterwards.

**Good example:**

```java
@Mapper
public interface CarMapper {
    List<CarDto> carsToCarDtos(Stream<Car> cars);   // collects to ArrayList, maps each Car
    CarDto carToCarDto(Car car);
}
// GENERATED: cars.map(car -> carToCarDto(car)).collect(Collectors.toCollection(ArrayList::new));
```

**Bad example:**

```java
// Reusing a stream after a mapping already consumed it:
Stream<Car> s = cars.stream();
List<CarDto> a = mapper.carsToCarDtos(s);
List<CarDto> b = mapper.carsToCarDtos(s); // IllegalStateException: stream already operated upon
```

## Chapter 8 — Mapping values (enums)

### [8.1] Map enum-to-enum and handle the remainder with `MappingConstants`

Title: Map constants by name automatically, override with `@ValueMapping`, and cover the rest with `<ANY_REMAINING>`/`<ANY_UNMAPPED>`/`<NULL>`/`<THROW_EXCEPTION>`.
Description: By default each source constant maps to the same-named target constant; unmapped source constants cause a **compile error** (and the generated `switch` throws on unrecognized runtime values). Override individual names with `@ValueMapping(source = ..., target = ...)`. For the rest, use exactly one of `MappingConstants.ANY_REMAINING` (continue name-based mapping, then fall back) or `ANY_UNMAPPED` (apply the given target directly, no name matching) — they cannot be combined. Use `MappingConstants.NULL` for null source/target, and `MappingConstants.THROW_EXCEPTION` (target only) to throw for specific values. `@InheritInverseConfiguration`/`@InheritConfiguration` work with `@ValueMappings` (the `ANY_*` rules are then ignored).

**Good example:**

```java
@Mapper
public interface OrderMapper {
    @ValueMappings({
        @ValueMapping(source = MappingConstants.NULL, target = "DEFAULT"),
        @ValueMapping(source = "STANDARD", target = MappingConstants.NULL),
        @ValueMapping(source = MappingConstants.ANY_REMAINING, target = "SPECIAL")
    })
    ExternalOrderType map(OrderType orderType);
}
```

**Bad example:**

```java
// Leaving a source constant unmapped with no ANY_* rule -> compile error;
// or using BOTH ANY_REMAINING and ANY_UNMAPPED -> not allowed.
@ValueMappings({
    @ValueMapping(source = MappingConstants.ANY_REMAINING, target = "A"),
    @ValueMapping(source = MappingConstants.ANY_UNMAPPED,  target = "B") // can't use both
})
ExternalOrderType map(OrderType orderType);
```

### [8.2] Map enum↔`String`

Title: Map enums to/from `String` the same way as enum-to-enum, remembering the asymmetries of the `ANY_*` rules.
Description: enum→`String`: undefined mappings map each constant to its same-named `String`; `<ANY_REMAINING>` works; `<ANY_UNMAPPED>` is an **error** (name similarity is meaningless for `String`); there are never unmapped values; `<THROW_EXCEPTION>` is allowed. `String`→enum: undefined mappings map a `String` to the same-named constant; you must provide `<ANY_REMAINING>` or `<ANY_UNMAPPED>` (else a warning) because `String` has unlimited values; `<THROW_EXCEPTION>` is allowed for arbitrary strings.

**Good example:**

```java
@Mapper
public interface StatusMapper {
    @ValueMapping(source = MappingConstants.ANY_REMAINING, target = "UNKNOWN")
    Status fromString(String value);   // covers arbitrary input strings
}
```

**Bad example:**

```java
// String->enum with no ANY_* fallback -> warning, and unexpected inputs are undefined:
@Mapper interface StatusMapper { Status fromString(String value); } // unlimited String domain unhandled
```

### [8.3] Transform enum names with `@EnumMapping` instead of listing every constant

Title: Apply a name transformation (`suffix`/`prefix`/`stripSuffix`/`stripPrefix`/`case`) with `@EnumMapping` rather than one `@ValueMapping` per constant.
Description: When two enums differ by a systematic naming rule, `@EnumMapping(nameTransformationStrategy = "...", configuration = "...")` transforms the source name before matching the target — e.g. `BRIE`→`BRIE_TYPE` with strategy `suffix`, config `_TYPE`. Built-in strategies: `suffix`, `stripSuffix`, `prefix`, `stripPrefix`, and `case` (configs `upper`/`lower`/`capital`). Combine with `@InheritInverseConfiguration` for the reverse. Register your own strategies via the SPI (§13.5).

**Good example:**

```java
@Mapper
public interface CheeseMapper {
    @EnumMapping(nameTransformationStrategy = "suffix", configuration = "_TYPE")
    CheeseTypeSuffixed map(CheeseType cheese);     // BRIE -> BRIE_TYPE, ROQUEFORT -> ROQUEFORT_TYPE
    @InheritInverseConfiguration
    CheeseType map(CheeseTypeSuffixed cheese);
}
```

**Bad example:**

```java
// Enumerating each constant by hand when a single suffix rule would do:
@ValueMappings({
    @ValueMapping(source = "BRIE", target = "BRIE_TYPE"),
    @ValueMapping(source = "ROQUEFORT", target = "ROQUEFORT_TYPE") // ...and every future constant
})
CheeseTypeSuffixed map(CheeseType cheese);
```

### [8.4] Bundle `@ValueMapping`s into a reusable meta-annotation **[1.6+]**

Title: Put a common set of `@ValueMapping`s on a custom annotation and apply it to multiple enum-mapping methods.
Description: Like `@Mapping` composition (§3.2), `@ValueMapping` supports `ANNOTATION_TYPE` targets (since 1.6.0), so a frequently-repeated value-mapping set can live on a custom `@interface` (retention `CLASS`) and be applied to several methods, optionally augmented with method-specific `@ValueMapping`s.

**Good example:**

```java
@Retention(RetentionPolicy.CLASS)
@ValueMapping(source = "EXTRA", target = "SPECIAL")
@ValueMapping(source = MappingConstants.ANY_REMAINING, target = "DEFAULT")
public @interface CustomValueAnnotation {}

@Mapper
public interface ValueMappingCompositionMapper {
    @CustomValueAnnotation
    ExternalOrderType orderTypeToExternalOrderType(OrderType orderType);

    @CustomValueAnnotation
    @ValueMapping(source = "STANDARD", target = "SPECIAL")   // add to the composed set
    ExternalOrderType duplicateAnnotation(OrderType orderType);
}
```

**Bad example:**

```java
// Repeating the identical ANY_REMAINING/EXTRA block on every enum method (pre-composition habit):
@ValueMappings({ @ValueMapping(source="EXTRA", target="SPECIAL"),
                 @ValueMapping(source=MappingConstants.ANY_REMAINING, target="DEFAULT") })
ExternalOrderType a(OrderType o);
@ValueMappings({ /* the same two lines again */ })
ExternalOrderType b(OrderType o);
```

## Chapter 9 — Object factories

### [9.1] Obtain target instances from a factory with `@ObjectFactory`

Title: Register factory methods on `uses` to control target instantiation (e.g. JAXB `ObjectFactory`, initialized entities, factories that see the source).
Description: By default MapStruct calls the target's default constructor. To instantiate differently, supply a factory: a parameterless method, a method with only a `@TargetType Class<T>` parameter, or a method annotated `@ObjectFactory`, registered via `@Mapper(uses = ...)`. MapStruct calls it instead of `new`. `@ObjectFactory` also lets the factory receive the mapping source(s) and `@Context`. Object factories take precedence over constructors (§3.9) and are used for builder types too. With update methods, the factory is used to create a missing nested target before updating.

**Good example:**

```java
public class EntityFactory {
    public <T extends BaseEntity> T createEntity(@TargetType Class<T> type) { /* e.g. new + init collections */ }
}
public class DtoFactory {
    @ObjectFactory public CarDto createCarDto(Car car) { /* may inspect source */ }
}
@Mapper(uses = { DtoFactory.class, EntityFactory.class })
public interface CarMapper {
    CarDto carToCarDto(Car car);     // GENERATED: dtoFactory.createCarDto(car)
    Car carDtoToCar(CarDto dto);     // GENERATED: entityFactory.createEntity(Car.class)
}
```

**Bad example:**

```java
// Putting non-factory custom logic on a plain method and expecting MapStruct to treat it as a factory:
public class DtoFactory { public CarDto createCarDto(Car car){ /*...*/ } } // ambiguous w/ a mapping method
// Without @ObjectFactory MapStruct may treat it as a mapping method. Annotate it @ObjectFactory.
```

## Chapter 10 — Advanced mapping options

### [10.1] Supply `defaultValue` and `constant`

Title: Use `defaultValue` for "value when the source is null" and `constant` for "always this value"; both are `String`s subject to conversion.
Description: `@Mapping(..., defaultValue = "x")` sets the target when the source property is `null`; `@Mapping(target = ..., constant = "x")` always sets a fixed value and must **not** reference a source. Both are `String`s: for primitives/wrappers taken as literals, otherwise converted via built-in conversions or `uses` mappers. Date targets need `dateFormat`.

**Good example:**

```java
@Mapper(uses = StringListMapper.class)
public interface SourceTargetMapper {
    @Mapping(target = "stringProperty", source = "stringProp", defaultValue = "undefined")
    @Mapping(target = "stringConstant", constant = "Constant Value")
    @Mapping(target = "dateConstant", dateFormat = "dd-MM-yyyy", constant = "09-01-2014")
    @Mapping(target = "stringListConstants", constant = "jack-jill-tom")  // via StringListMapper
    Target sourceToTarget(Source s);
}
```

**Bad example:**

```java
// Using constant with a source reference (illegal) or post-fixing defaults in calling code:
@Mapping(target = "stringConstant", constant = "src.foo")  // 'constant' must not reference a source
Target sourceToTarget(Source s);
```

### [10.2] Embed Java with `expression` (and declare `imports`)

Title: Use `expression = "java(...)"` for small inline computations and declare types via `@Mapper(imports = ...)`.
Description: `expression` injects Java code (the only supported language); the whole source object is in scope. MapStruct does **not** validate the expression — errors only show when the generated class compiles. Avoid fully-qualified names by listing types in `@Mapper(imports = ...)`. Prefer a `default`/custom method (§3.3) for anything beyond a one-liner — it is testable and IDE-checked.

**Good example:**

```java
@Mapper(imports = TimeAndFormat.class)
public interface SourceTargetMapper {
    @Mapping(target = "timeAndFormat",
             expression = "java( new TimeAndFormat( s.getTime(), s.getFormat() ) )")
    Target sourceToTarget(Source s);
}
```

**Bad example:**

```java
// A multi-statement, hard-to-read expression with fully-qualified names and no validation:
@Mapping(target = "x",
  expression = "java( s.getA()!=null ? new com.acme.X(s.getA().trim().toUpperCase()) : com.acme.X.EMPTY )")
Target sourceToTarget(Source s);   // move this into a default method instead
```

### [10.3] Compute a fallback only when the source is null with `defaultExpression`

Title: Use `defaultExpression = "java(...)"` to compute a value only when the source property is `null`.
Description: `defaultExpression` combines `defaultValue` and `expression`: the Java code runs only if the source is absent. Same caveats as `expression` (Java only, no generation-time validation; declare `imports`).

**Good example:**

```java
@Mapper(imports = UUID.class)
public interface SourceTargetMapper {
    @Mapping(target = "id", source = "sourceId",
             defaultExpression = "java( UUID.randomUUID().toString() )")  // only if sourceId == null
    Target sourceToTarget(Source s);
}
```

**Bad example:**

```java
// Using 'expression' (always runs) where you meant 'defaultExpression' (only when null):
@Mapping(target = "id", source = "sourceId", expression = "java( UUID.randomUUID().toString() )")
Target sourceToTarget(Source s);   // overwrites a present sourceId with a random UUID
```

### [10.4] Map a type hierarchy with `@SubclassMapping`

Title: List `@SubclassMapping`s so each concrete source subtype maps to its matching target subtype instead of collapsing to the base type.
Description: When source and target share an inheritance relation, `@SubclassMapping(source = AppleDto.class, target = Apple.class)` routes each specialization correctly. An unlisted subtype maps to the base type. If the result type is abstract/interface, that is a compile error unless you set `subclassExhaustiveStrategy = SubclassExhaustiveStrategy.RUNTIME_EXCEPTION` (on `@MapperConfig`/`@Mapper`/`@BeanMapping`), which throws `IllegalArgumentException` for unknown subtypes at runtime. Subclass qualifiers (`qualifiedBy`/`qualifiedByName`) are supported **[1.6+]**. ⚠️ Not supported with update methods, `@Context`, or `@TargetType`. **[1.7+]** allows configuring a **custom exception** for the non-exhaustive case.

**Good example:**

```java
@Mapper
public interface FruitMapper {
    @SubclassMapping(source = AppleDto.class,  target = Apple.class)
    @SubclassMapping(source = BananaDto.class, target = Banana.class)
    Fruit map(FruitDto source);
}
```

**Bad example:**

```java
// Mapping an abstract Fruit without subclass mappings (or exhaustive strategy):
@Mapper public interface FruitMapper { Fruit map(FruitDto source); } // compile error: can't instantiate Fruit
```

### [10.5] Pick among result subtypes with `resultType`

Title: Use `@BeanMapping(resultType = ...)` (or `@Mapping#resultType`, `@IterableMapping#elementTargetType`, `@MapMapping#keyTargetType/valueTargetType`) to resolve which subtype to create.
Description: When result types form a hierarchy, a factory or return type may be ambiguous. `@BeanMapping(resultType = Apple.class)` selects which factory method to call, or which concrete type to instantiate. The same idea applies to single-property mapping (`@Mapping#resultType`) and to iterables/maps (element/key/value target types).

**Good example:**

```java
@Mapper(uses = FruitFactory.class)   // factory has createApple() and createBanana()
public interface FruitMapper {
    @BeanMapping(resultType = Apple.class)   // -> use createApple()
    Fruit map(FruitDto source);
}
```

**Bad example:**

```java
// Factory exposes two creators for the Fruit hierarchy, no resultType -> ambiguous; MapStruct can't choose:
@Mapper(uses = FruitFactory.class) interface FruitMapper { Fruit map(FruitDto source); }
```

### [10.6] Return an empty result for a null argument with `nullValueMappingStrategy`

Title: Set `nullValueMappingStrategy = RETURN_DEFAULT` to return an empty bean/collection/map instead of `null` when the whole source argument is null.
Description: By default a null source argument yields `null` (or `Optional.empty()` for an `Optional` return **[1.7+]**). `NullValueMappingStrategy.RETURN_DEFAULT` instead returns an "empty" result: an empty target bean (constants/expressions still applied), an empty iterable, or an empty map. Set it on `@BeanMapping`/`@IterableMapping`/`@MapMapping`, or globally on `@Mapper`/`@MapperConfig` (method-level overrides mapper-level overrides config-level).

**Good example:**

```java
@Mapper
public interface CarMapper {
    @IterableMapping(nullValueMappingStrategy = NullValueMappingStrategy.RETURN_DEFAULT)
    List<CarDto> map(List<Car> cars);   // null source -> empty list, never null
}
```

**Bad example:**

```java
// Defending against null results in every caller because the mapper returns null:
List<CarDto> dtos = mapper.map(cars);
if (dtos == null) dtos = List.of();   // push this into the mapper via RETURN_DEFAULT instead
```

### [10.7] Control null collection/map arguments separately

Title: Use the dedicated iterable/map strategies to return empty collections/maps for null arguments while beans still return null.
Description: Beyond §10.6, you can govern collections and maps independently: `Mapper#nullValueIterableMappingStrategy` / `IterableMapping#nullValueMappingStrategy` for iterables, and `Mapper#nullValueMapMappingStrategy` / `MapMapping#nullValueMappingStrategy` for maps (also as global options `mapstruct.nullValueIterableMappingStrategy` / `mapstruct.nullValueMapMappingStrategy` **[1.6+]**). The applied semantics are the same as §10.6.

**Good example:**

```java
@Mapper(nullValueIterableMappingStrategy = NullValueMappingStrategy.RETURN_DEFAULT,
        nullValueMapMappingStrategy      = NullValueMappingStrategy.RETURN_DEFAULT)
public interface CarMapper {           // collections/maps -> empty; beans still -> null
    List<CarDto> mapList(List<Car> cars);
    Map<String, CarDto> mapMap(Map<String, Car> cars);
    CarDto mapOne(Car car);
}
```

**Bad example:**

```java
// Forcing RETURN_DEFAULT on the whole mapper when you only wanted empty collections —
// now bean methods return empty beans instead of null, surprising callers:
@Mapper(nullValueMappingStrategy = NullValueMappingStrategy.RETURN_DEFAULT)
public interface CarMapper { CarDto mapOne(Car car); } // null Car -> empty CarDto (maybe unintended)
```

### [10.8] Keep, null, default, or clear target properties on update

Title: On update methods, choose `NullValuePropertyMappingStrategy` — `IGNORE` to keep, `SET_TO_NULL` (default), `SET_TO_DEFAULT`, or `CLEAR` **[1.7+]** for collections/maps.
Description: For `@MappingTarget` update methods, `nullValuePropertyMappingStrategy` decides what happens when a source property is `null` (or a presence check says "absent"): `SET_TO_NULL` (default) writes `null` (or `Optional.empty()` for `Optional` targets); `IGNORE` keeps the target's existing value; `SET_TO_DEFAULT` writes a default (`new ArrayList`/`LinkedHashMap`, empty array, `""`, `0`/`false`, or `new` for other types — default constructor required); **[1.7+]** `CLEAR` clears `Collection`/`Map` targets. Set on `@Mapping`/`@BeanMapping`/`@Mapper`/`@MapperConfig`. Note: when MapStruct uses a getter/adder for collections (per `CollectionMappingStrategy`) it always null-checks the source regardless, to avoid adding `null`. For empty `Optional` sources **[1.7+]**, the strategy applies as it does to `null`.

**Good example:**

```java
// PATCH semantics: only non-null fields update the existing entity.
@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface CarMapper {
    void updateCarFromDto(CarDto dto, @MappingTarget Car car);  // null dto fields keep existing values
}
```

**Bad example:**

```java
// Default SET_TO_NULL on a PATCH-style update wipes fields the client didn't send:
@Mapper
public interface CarMapper {
    void updateCarFromDto(CarDto dto, @MappingTarget Car car); // dto.color==null -> car.color set to null
}
```

### [10.9] Tune when a null check is generated with `nullValueCheckStrategy`

Title: Keep the default `ON_IMPLICIT_CONVERSION`, or use `ALWAYS` to null-check every non-primitive source before setting.
Description: `NullValueCheckStrategy.ON_IMPLICIT_CONVERSION` (default) generates a null check only when needed: a primitive target from a non-primitive source, before a type conversion + setter, before a chained conversion + setter, or before a mapping-method result + setter. `NullValueCheckStrategy.ALWAYS` adds a null check whenever the source is non-primitive (unless a presence checker exists). Set on `@Mapping`/`@BeanMapping`/`@Mapper`/`@MapperConfig`. (Generated mapping methods always null-check the source before mapping; hand-written methods must guard themselves.)

**Good example:**

```java
@Mapper(nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS)
public interface CarMapper {
    CarDto carToCarDto(Car car);   // every non-primitive source property is null-checked before set
}
```

**Bad example:**

```java
// Assuming a direct same-type assignment is null-guarded under the default strategy — it is not,
// so a downstream NPE surprises you. Use ALWAYS (or a presence check) if you need the guard.
```

### [10.10] Let a `hasXyz()` presence checker drive the null check

Title: Expose `hasProperty()` on the source bean and MapStruct calls it instead of a null check.
Description: If the source defines a presence checker (typically `hasXyz` for property `xyz`), MapStruct invokes it rather than doing a null check. The checker method name can be customized — or presence checking deactivated — via the SPI. See §10.11 for fully custom condition logic.

**Good example:**

```java
public class Car {
    private String owner;
    public String getOwner() { return owner; }
    public boolean hasOwner() { return owner != null && !owner.isBlank(); } // drives the mapping decision
}
// GENERATED: if ( car.hasOwner() ) { dto.setOwner( car.getOwner() ); }
```

**Bad example:**

```java
// Naming the presence checker something MapStruct won't recognize, then wondering why it's ignored:
public boolean ownerPresent() { /* ... */ }   // not 'hasOwner' -> not used (unless SPI customized)
```

### [10.11] Decide per-property/per-parameter mapping with conditional methods

Title: Annotate a `boolean` method with `@Condition` (per-property) or `@SourceParameterCondition` (per-parameter) to control whether a value is mapped.
Description: Conditional mapping generalizes presence checking: write a `boolean` method annotated `@Condition` and MapStruct calls it to decide whether to map a property; it may also receive the source parameter and, **[1.6+]**, `@TargetPropertyName`/`@SourcePropertyName` (only valid in `@Condition` methods). A custom `@Condition` takes precedence over a bean's own presence checker. To gate a **whole source parameter**, annotate `@SourceParameterCondition` (or `@Condition(appliesTo = ConditionStrategy.SOURCE_PARAMETERS)`) **[1.6+]** — this is the supported replacement for the pre-1.6 behavior where a plain `@Condition` on the source parameter worked. Select among multiple conditions with `Mapping#conditionQualifiedByName`/`conditionQualifiedBy`.

**Good example:**

```java
@Mapper
public interface CarMapper {
    CarDto carToCarDto(Car car);

    @Condition                                   // per-property gate
    default boolean isNotEmpty(String value) {
        return value != null && !value.isEmpty();
    }

    @SourceParameterCondition                    // [1.6+] whole-parameter gate
    default boolean hasCar(Car car) {
        return car != null && car.getId() != null;
    }
}
// GENERATED: if ( isNotEmpty( car.getOwner() ) ) { dto.setOwner( car.getOwner() ); }
```

**Bad example:**

```java
// Pre-1.6 habit: expecting a plain @Condition on the source parameter to gate the whole mapping.
// On 1.6+/1.7 this no longer works — it's treated as a property condition. Use @SourceParameterCondition.
@Condition default boolean hasCar(Car car) { return car != null; } // wrong on 1.6+; not a parameter gate
```

### [10.12] Declare and propagate exceptions from mapping methods

Title: Add a `throws` clause so checked exceptions from hand-written logic propagate to the caller; undeclared checked exceptions are wrapped in a `RuntimeException`.
Description: A mapping method may declare `throws SomeException`. MapStruct delegates declared exceptions to the caller; any *other* checked exception thrown by hand-written code is wrapped in a try-catch and rethrown as an unchecked `RuntimeException`. MapStruct only null-checks where required (type conversions, constructor calls) — hand-written code must return valid non-null objects and tolerate null inputs.

**Good example:**

```java
@Mapper(uses = HandWritten.class)
public interface CarMapper {
    CarDto carToCarDto(Car car) throws GearException;  // GearException propagates to the caller
}
// GENERATED wraps an undeclared FatalException: catch (FatalException e) { throw new RuntimeException(e); }
```

**Bad example:**

```java
// Swallowing/printing exceptions in a helper instead of letting them propagate or be wrapped:
public String toGear(Integer g) { try { /*...*/ } catch (Exception e) { e.printStackTrace(); return null; } }
// hides failures and silently yields nulls; declare 'throws' on the mapping method instead
```

## Chapter 11 — Reusing mapping configurations

### [11.1] Reuse a method's config with `@InheritConfiguration`

Title: Apply `@InheritConfiguration` so a similar method (e.g. an update variant) reuses another method's `@Mapping`s.
Description: A method can inherit the method-level configuration (`@Mapping`, `@BeanMapping`, …) of another *similar* method — one whose source/result types are assignable to the corresponding types of the inheriting method. Typical use: a create method's config reused by the update method. Disambiguate with `@InheritConfiguration(name = "...")` when more than one candidate applies. Candidates must be in the same mapper, a super type, or the `@MapperConfig` interface — **not** in a `uses` mapper. You can still add/override with extra `@Mapping`s.

**Good example:**

```java
@Mapper
public interface CarMapper {
    @Mapping(target = "numberOfSeats", source = "seatCount")
    Car carDtoToCar(CarDto car);

    @InheritConfiguration                       // reuses the @Mapping above
    void carDtoIntoCar(CarDto carDto, @MappingTarget Car car);
}
```

**Bad example:**

```java
// Re-declaring identical @Mapping rules on the update method (drift risk) instead of inheriting:
@Mapping(target = "numberOfSeats", source = "seatCount")
void carDtoIntoCar(CarDto carDto, @MappingTarget Car car); // duplicate of carDtoToCar's config
```

### [11.2] Derive the reverse mapping with `@InheritInverseConfiguration`

Title: Annotate the reverse method with `@InheritInverseConfiguration` to auto-swap `source`/`target` from the forward method.
Description: For bidirectional mappings, the reverse method (result type = forward's source type, and vice versa) can inherit the inverse of the forward configuration — `source`/`target` are swapped automatically. Override specifics with `ignore`/`expression`/`constant`. Note: `expression`, `defaultExpression`, `defaultValue`, and `constant` are **not** inverted (silently ignored); `ignore` is applied only when `source` is also given. Use `name = "..."` to disambiguate. Candidates must be in the mapper or a super type (not a `uses` mapper). `@InheritConfiguration` wins over `@InheritInverseConfiguration` on conflict.

**Good example:**

```java
@Mapper
public interface CarMapper {
    @Mapping(target = "seatCount", source = "numberOfSeats")
    CarDto carToDto(Car car);

    @InheritInverseConfiguration                 // seatCount<->numberOfSeats swapped automatically
    @Mapping(target = "numberOfSeats", ignore = true)  // override one
    Car dtoToCar(CarDto dto);
}
```

**Bad example:**

```java
// Hand-writing the reverse rules and getting the direction wrong:
@Mapping(target = "seatCount", source = "numberOfSeats")  // copied verbatim onto the reverse method
Car dtoToCar(CarDto dto);   // wrong: on the reverse, target should be numberOfSeats
```

### [11.3] Centralize settings in a `@MapperConfig` interface

Title: Define shared `@Mapper` attributes (and prototype mapping methods) once in a `@MapperConfig` interface and reference it with `@Mapper(config = ...)`.
Description: A `@MapperConfig` interface carries the same attributes as `@Mapper`; mappers reference it via `config`. Unset `@Mapper` attributes are inherited; set ones take precedence; list attributes like `uses` are combined. The config may also declare *prototype* methods (not generated) whose method-level mapping annotations are inherited. `mappingInheritanceStrategy` controls how: `EXPLICIT` (default; only via `@InheritConfiguration`), `AUTO_INHERIT_FROM_CONFIG`, `AUTO_INHERIT_REVERSE_FROM_CONFIG`, `AUTO_INHERIT_ALL_FROM_CONFIG`.

**Good example:**

```java
@MapperConfig(uses = CommonHelpers.class, unmappedTargetPolicy = ReportingPolicy.ERROR,
              mappingInheritanceStrategy = MappingInheritanceStrategy.AUTO_INHERIT_FROM_CONFIG)
public interface CentralConfig {
    @Mapping(target = "primaryKey", source = "technicalKey")     // prototype: auto-inherited
    BaseEntity anyDtoToEntity(BaseDto dto);
}

@Mapper(config = CentralConfig.class, uses = CarHelpers.class)
public interface SourceTargetMapper {
    @Mapping(target = "numberOfSeats", source = "seatCount")     // + inherited primaryKey<-technicalKey
    Car toCar(CarDto car);
}
```

**Bad example:**

```java
// Copying unmappedTargetPolicy/uses onto every mapper instead of a shared @MapperConfig:
@Mapper(uses = CommonHelpers.class, unmappedTargetPolicy = ReportingPolicy.ERROR) interface AMapper {}
@Mapper(uses = CommonHelpers.class, unmappedTargetPolicy = ReportingPolicy.ERROR) interface BMapper {}
// one policy change now means editing N mappers
```

## Chapter 12 — Customizing mappings

### [12.1] Customize specific methods with a decorator (`@DecoratedWith`)

Title: Wrap a generated mapper in a decorator to post-process specific methods while delegating the rest.
Description: `@DecoratedWith(MyDecorator.class)` lets you customize selected methods type-safely. The decorator is a sub-type (usually an abstract class) of the mapper; implement only the methods you customize, delegating to the generated implementation for the rest. Wiring differs by component model: for `default`, give the decorator a constructor taking the delegate; for `spring`, the generated original is `@Qualifier("delegate")` and the decorator `@Primary` (inject normally); for `jsr330`, inject the original by its `@Named("...Impl_")` and select the decorator with a parameterless `@Named`. **[1.7+]** `@AnnotateWith` may be applied to decorators. For CDI, prefer CDI decorators over `@DecoratedWith`.

**Good example:**

```java
@Mapper @DecoratedWith(PersonMapperDecorator.class)
public interface PersonMapper {
    PersonMapper INSTANCE = Mappers.getMapper( PersonMapper.class );
    PersonDto personToPersonDto(Person person);
}

public abstract class PersonMapperDecorator implements PersonMapper {
    private final PersonMapper delegate;
    public PersonMapperDecorator(PersonMapper delegate) { this.delegate = delegate; }

    @Override public PersonDto personToPersonDto(Person person) {
        PersonDto dto = delegate.personToPersonDto(person);   // generated mapping
        dto.setFullName(person.getFirstName() + " " + person.getLastName()); // customization
        return dto;
    }
}
```

**Bad example:**

```java
// Re-implementing the whole mapping inside the decorator instead of delegating — defeats the purpose
// and drifts from the generated code:
public abstract class PersonMapperDecorator implements PersonMapper {
    @Override public PersonDto personToPersonDto(Person p) {
        PersonDto dto = new PersonDto();
        dto.setName(p.getName());                 // duplicates what MapStruct would generate
        dto.setFullName(p.getFirstName()+" "+p.getLastName());
        return dto;
    }
}
```

### [12.2] Hook into the lifecycle with `@BeforeMapping`/`@AfterMapping`

Title: Use `@BeforeMapping`/`@AfterMapping` callbacks (in the mapper, a `uses` type, or a `@Context` value) for cross-cutting pre/post steps.
Description: Callbacks run before/after the generated mapping. Parameters may include `@MappingTarget` (target), `@TargetType` (target type), `@Context`, and a source parameter; a callback is invoked only if its return type is assignable to the mapping method's return type and its parameters can be satisfied. A non-void `@AfterMapping` return replaces the result if non-null (useful for `entityManager.merge(entity)`). Ordering: `@BeforeMapping` without a `@MappingTarget` runs before null checks/target construction; `@BeforeMapping` with `@MappingTarget` after construction; `@AfterMapping` just before the final `return`. With builders, a `@BeforeMapping` cannot get the real target; an `@AfterMapping` must take the builder as `@MappingTarget` to modify it before `build()`.

**Good example:**

```java
@Mapper
public abstract class VehicleMapper {
    @AfterMapping
    protected void fillTank(AbstractVehicle v, @MappingTarget AbstractVehicleDto dto) {
        dto.fuelUp(new Fuel(v.getTankCapacity(), v.getFuelType()));   // applies to every subtype mapping
    }
    public abstract CarDto toCarDto(Car car);
}
// GENERATED: ... CarDto carDto = new CarDto(); /* map */ fillTank(car, carDto); return carDto;
```

**Bad example:**

```java
// Putting persistence side effects inline via expressions on each method instead of one @AfterMapping:
@Mapping(target = "x", expression = "java( em.merge(/*...*/) )") // scattered, untestable, repeated
CarDto toCarDto(Car car);
```

## Chapter 13 — Using the MapStruct SPI

> Common registration: implement the SPI in a **separate jar**, register it in `META-INF/services/<spi-interface-fqcn>` (file content = your implementation's FQCN), and put that jar on the **annotation processor path** (next to `mapstruct-processor`; also on your IDE's annotation-processor factory path).

### [13.1] Teach MapStruct your accessors with a custom `AccessorNamingStrategy`

Title: Extend `DefaultAccessorNamingStrategy` to recognize non-JavaBeans accessors (e.g. fluent `property()`/`withProperty()`).
Description: The `org.mapstruct.ap.spi.AccessorNamingStrategy` SPI controls how getters/setters are recognized and how property names are derived. Extend `DefaultAccessorNamingStrategy` and override `isGetterMethod`, `isSetterMethod`, `getPropertyName` to support APIs that don't follow `get/set`.

**Good example:**

```java
public class CustomAccessorNamingStrategy extends DefaultAccessorNamingStrategy {
    @Override public boolean isGetterMethod(ExecutableElement m) {
        String n = m.getSimpleName().toString();
        return !n.startsWith("with") && m.getReturnType().getKind() != TypeKind.VOID;
    }
    @Override public boolean isSetterMethod(ExecutableElement m) {
        String n = m.getSimpleName().toString();
        return n.startsWith("with") && n.length() > 4;
    }
    @Override public String getPropertyName(ExecutableElement m) {
        String n = m.getSimpleName().toString();
        return IntrospectorUtils.decapitalize(n.startsWith("with") ? n.substring(4) : n);
    }
}
// META-INF/services/org.mapstruct.ap.spi.AccessorNamingStrategy -> com.acme.CustomAccessorNamingStrategy
```

**Bad example:**

```java
// Implementing the SPI but forgetting the META-INF/services file or leaving the jar off the
// processor path -> MapStruct never loads it and silently uses the default strategy.
```

### [13.2] Exclude types from auto sub-mapping with `MappingExclusionProvider`

Title: Implement `MappingExclusionProvider#isExcluded(TypeElement)` to stop MapStruct auto-generating a sub-mapping for certain types.
Description: The `org.mapstruct.ap.spi.MappingExclusionProvider` SPI prevents MapStruct from generating an automatic sub-mapping method for a type (e.g. a third-party type that should be mapped only by a hand-written method). The `DefaultMappingExclusionProvider` already excludes everything under `java`/`javax`.

**Good example:**

```java
public class CustomMappingExclusionProvider implements MappingExclusionProvider {
    @Override public boolean isExcluded(TypeElement type) {
        String n = type.getQualifiedName().toString();
        return n.equals("com.acme.Target.NestedTarget");   // must be mapped by a custom method instead
    }
}
```

**Bad example:**

```java
// Excluding a type you actually want auto-mapped, then puzzling over "no mapping method" errors.
@Override public boolean isExcluded(TypeElement type) { return true; } // excludes everything -> breaks mapping
```

### [13.3] Replace builder detection with a custom `BuilderProvider`

Title: Implement `BuilderProvider#findBuilderInfo` (return `null` to disable builders) to control or switch off builder usage.
Description: The `org.mapstruct.ap.spi.BuilderProvider` SPI (default `DefaultBuilderProvider`) decides whether/how a type's builder is used. Returning `null` from `findBuilderInfo(TypeMirror)` disables builder support globally (the shipped `NoOpBuilderProvider` does exactly this); or implement custom detection for a non-standard builder convention.

**Good example:**

```java
public class NoOpBuilderProvider implements BuilderProvider {
    @Override public BuilderInfo findBuilderInfo(TypeMirror type) { return null; } // disable builders
}
// register via META-INF/services/org.mapstruct.ap.spi.BuilderProvider
```

**Bad example:**

```java
// Per-mapper @Builder(disableBuilder=true) repeated everywhere when you meant to disable globally —
// use the SPI (or -Amapstruct.disableBuilders=true) instead.
```

### [13.4] Customize enum constant naming with `EnumMappingStrategy`

Title: Extend `DefaultEnumMappingStrategy` to apply org-wide enum conventions (constant naming and the default value for a `null` source).
Description: The `org.mapstruct.ap.spi.EnumMappingStrategy` SPI lets you override `getEnumConstant(TypeElement, String)` and `getDefaultNullEnumConstant(TypeElement)` — e.g. all enums implementing a marker interface get a `CUSTOM_` prefix stripped and default to `UNSPECIFIED` when mapping from `null`.

**Good example:**

```java
public class CustomEnumMappingStrategy extends DefaultEnumMappingStrategy {
    @Override public String getDefaultNullEnumConstant(TypeElement t) {
        return isCustomEnum(t) ? "UNSPECIFIED" : super.getDefaultNullEnumConstant(t);
    }
    @Override public String getEnumConstant(TypeElement t, String c) {
        return isCustomEnum(t) ? c.replace("CUSTOM_", "") : super.getEnumConstant(t, c);
    }
    // isCustomEnum(...) checks for the marker interface
}
```

**Bad example:**

```java
// Encoding the same prefix/default logic as @ValueMapping on every enum method, across the codebase,
// instead of one SPI strategy.
```

### [13.5] Add an enum name transformation with `EnumTransformationStrategy`

Title: Implement `EnumTransformationStrategy` to register a named transformation usable from `@EnumMapping(nameTransformationStrategy = ...)`.
Description: The `org.mapstruct.ap.spi.EnumTransformationStrategy` SPI adds custom strategies beyond the built-in `suffix`/`prefix`/`case`. Implement `getStrategyName()` and `transform(String value, String configuration)`; then reference it by name in `@EnumMapping` (§8.3).

**Good example:**

```java
public class CustomEnumTransformationStrategy implements EnumTransformationStrategy {
    @Override public String getStrategyName() { return "custom"; }
    @Override public String transform(String value, String configuration) {
        return value.toLowerCase() + configuration;
    }
}
// usage: @EnumMapping(nameTransformationStrategy = "custom", configuration = "_x")
```

**Bad example:**

```java
// Hard-coding the transformation as one @ValueMapping per constant instead of a reusable strategy.
```

### [13.6] Pass custom processor options to your SPI with `AdditionalSupportedOptionsProvider` **[1.6+]**

Title: Declare extra `-Akey=value` options (not starting with `mapstruct`) so your SPI can read them via `MapStructProcessingEnvironment#getOptions()`.
Description: Added in 1.6.0, the `org.mapstruct.ap.spi.AdditionalSupportedOptionsProvider` SPI lets you declare option names that the processor should pass through; your other SPI implementations then read them in `init(...)`. Useful for configuring custom strategies from the build.

**Good example:**

```java
public class CustomAdditionalSupportedOptionsProvider implements AdditionalSupportedOptionsProvider {
    @Override public Set<String> getAdditionalSupportedOptions() {
        return Collections.singleton("myorg.custom.defaultNullEnumConstant");
    }
}
// build: -Amyorg.custom.defaultNullEnumConstant=MISSING
// in an SPI: processingEnvironment.getOptions().get("myorg.custom.defaultNullEnumConstant")
```

**Bad example:**

```java
// Naming a custom option with the reserved 'mapstruct.' prefix (not allowed for custom options):
return Collections.singleton("mapstruct.myCustomOption"); // rejected; use your own namespace
```

## Chapter 14 — Third-party API integration

### [14.1] Let MapStruct recognize third-party annotations by name

Title: MapStruct matches helper annotations like `@Default` and `@ConstructorProperties` by **name**, from any package — define your own if none fits.
Description: To avoid coupling entities to MapStruct, certain annotations are recognized by simple name regardless of package — currently `@ConstructorProperties` and `@Default` (used for constructor selection, §3.9). If no suitable third-party annotation exists (or its `@Target` doesn't fit), declare your own `@Default`.

**Good example:**

```java
package com.acme.support.mapstruct;
@Target(ElementType.CONSTRUCTOR)
@Retention(RetentionPolicy.CLASS)
public @interface Default {}            // recognized by name; use it to pick a constructor
```

**Bad example:**

```java
// Reaching for an unrelated third-party annotation whose @Target doesn't allow constructors,
// just to influence mapping — risks side effects from that library. Define your own instead.
```

### [14.2] Use MapStruct together with Lombok

Title: When Lombok is on the processor path, add `lombok-mapstruct-binding` and order the processors `mapstruct → lombok → binding`.
Description: MapStruct uses Lombok-generated getters/setters/constructors (works since MapStruct 1.2.0.Beta1 / Lombok 1.16.14). Since **Lombok 1.18.16**, you must add the `org.projectlombok:lombok-mapstruct-binding` annotation processor or MapStruct stops seeing Lombok's generated members. Keep Lombok `provided`/`compileOnly` so it doesn't leak to runtime, and order the processors correctly.

**Good example:**

```xml
<annotationProcessorPaths>
    <path><groupId>org.mapstruct</groupId><artifactId>mapstruct-processor</artifactId>
          <version>${org.mapstruct.version}</version></path>
    <path><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId>
          <version>${org.projectlombok.version}</version></path>
    <path><groupId>org.projectlombok</groupId><artifactId>lombok-mapstruct-binding</artifactId>
          <version>0.2.0</version></path>   <!-- required since Lombok 1.18.16 -->
</annotationProcessorPaths>
```

**Bad example:**

```xml
<!-- Lombok 1.18.16+ without lombok-mapstruct-binding: MapStruct can't see Lombok's getters/setters,
     so every property looks unmapped and generation breaks. -->
<annotationProcessorPaths>
    <path><groupId>org.mapstruct</groupId><artifactId>mapstruct-processor</artifactId>
          <version>${org.mapstruct.version}</version></path>
    <path><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId>
          <version>1.18.16</version></path>
    <!-- missing lombok-mapstruct-binding -->
</annotationProcessorPaths>
```

## Appendix A — Configuration options reference

Annotation processor options, passed as `-Akey=value` (Maven `compilerArgs`, Gradle `options.compilerArgs`). Annotation-level attributes (`@Mapper`, `@BeanMapping`, `@IterableMapping`, `@MapMapping`) always override the corresponding global option. Available in both 1.6.3 and 1.7.0.Beta1 unless tagged.

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `mapstruct.suppressGeneratorTimestamp` | `true`/`false` | `false` | Suppress the timestamp in the `@Generated` annotation (use for reproducible builds). |
| `mapstruct.verbose` | `true`/`false` | `false` | Log MapStruct's major decisions. Under Maven also set `<showWarnings>true</showWarnings>`. |
| `mapstruct.suppressGeneratorVersionInfoComment` | `true`/`false` | `false` | Suppress the `comment` attribute (MapStruct version + compiler info) in `@Generated`. |
| `mapstruct.defaultComponentModel` | `default`,`cdi`,`spring`,`jsr330`,`jakarta`,`jakarta-cdi` | `default` | Component model for generated mappers (DI). |
| `mapstruct.defaultInjectionStrategy` | `field`,`constructor` | `field` | Injection of `uses` mappers for annotation-based component models. *(The `InjectionStrategy` enum also has `SETTER`.)* |
| `mapstruct.unmappedTargetPolicy` | `ERROR`,`WARN`,`IGNORE` | `WARN` | Reporting when a target property is not populated. Set `ERROR` to fail the build on forgotten mappings. |
| `mapstruct.unmappedSourcePolicy` | `ERROR`,`WARN`,`IGNORE` | `IGNORE` | Reporting when a source property is not used. |
| `mapstruct.disableBuilders` | `true`/`false` | `false` | Do not use builder patterns when mapping. |
| `mapstruct.nullValueIterableMappingStrategy` | `RETURN_NULL`,`RETURN_DEFAULT` | `RETURN_NULL` | Result for a `null` source passed to an iterable mapping. *(global option [1.6+])* |
| `mapstruct.nullValueMapMappingStrategy` | `RETURN_NULL`,`RETURN_DEFAULT` | `RETURN_NULL` | Result for a `null` source passed to a map mapping. *(global option [1.6+])* |
| `mapstruct.disableLifecycleOverloadDeduplicateSelector` **[1.7+]** | `true`/`false` | `false` | Opt out of de-duplicating invocations of overloaded lifecycle methods under inheritance. |

> Also commonly set via annotations rather than options: `typeConversionPolicy` (`@Mapper`/`@MapperConfig`; default `IGNORE`) for lossy-conversion reporting (`long`→`int`; **[1.7+]** also `String`→`Number`).

## Appendix B — Implicit type conversions reference

MapStruct applies these automatically (null-aware). Apply `numberFormat` (`DecimalFormat`) / `dateFormat` (`SimpleDateFormat`) where a `String` form is involved; **[1.7+]** also a `locale`. **[1.7+]**: each conversion also works when either side is wrapped in `Optional`/`OptionalInt`/`OptionalLong`/`OptionalDouble`.

- Primitive ↔ corresponding wrapper (`int`↔`Integer`, `boolean`↔`Boolean`, …) — null check on unboxing.
- Among primitive number types and wrappers (`int`↔`long`, `byte`↔`Integer`, …). ⚠️ Narrowing (e.g. `long`→`int`) may lose precision — see `typeConversionPolicy`.
- Any primitive/wrapper ↔ `String` (`numberFormat` supported).
- `enum` ↔ `String`.
- `enum` ↔ `Integer` by `ordinal()` **[1.6+]** (from `Integer`: value must be `< enum.values().length`, else `ArrayIndexOutOfBoundsException`).
- Big numbers (`BigInteger`, `BigDecimal`) ↔ primitives/wrappers and `String` (`numberFormat` supported).
- `JAXBElement<T>` ↔ `T`; `List<JAXBElement<T>>` ↔ `List<T>`.
- `java.util.Calendar`/`Date` ↔ `XMLGregorianCalendar`.
- `java.util.Date`/`XMLGregorianCalendar` ↔ `String` (`dateFormat` supported).
- Joda `DateTime`/`LocalDateTime`/`LocalDate`/`LocalTime` ↔ `String` (`dateFormat`); Joda `DateTime` ↔ `XMLGregorianCalendar`/`Calendar`; Joda `LocalDateTime`/`LocalDate` ↔ `XMLGregorianCalendar`/`Date`.
- `java.time` `LocalDate`/`LocalDateTime` ↔ `XMLGregorianCalendar`.
- `java.time` `ZonedDateTime`/`LocalDateTime`/`LocalDate`/`LocalTime` ↔ `String` (`dateFormat`).
- `java.time` `Instant`/`Duration`/`Period` ↔ `String` (via `parse`/`toString`).
- `java.time` `ZonedDateTime` ↔ `java.util.Date` (system default zone); `LocalDateTime` ↔ `Date` (UTC); `LocalDate` ↔ `Date`/`java.sql.Date` (UTC); `Instant` ↔ `Date`; `LocalDateTime` ↔ `LocalDate` **[1.6+]**; `ZonedDateTime` ↔ `Calendar`.
- `java.sql.Date`/`Time`/`Timestamp` ↔ `java.util.Date`.
- `java.util.Currency` ↔ `String` (invalid ISO-4217 → `IllegalArgumentException`).
- `java.util.UUID` ↔ `String` (invalid → `IllegalArgumentException`).
- `String` ↔ `StringBuilder`.
- `java.net.URL` ↔ `String` (invalid → `MalformedURLException`).
- `java.util.Locale` ↔ `String` (IETF BCP 47 language tag) **[1.6+]**.

> When converting from `String` without `dateFormat`, the default locale pattern is used (except `XMLGregorianCalendar`, which parses per XML Schema lexical representation).

## Appendix C — Version history & migration notes (1.5 → 1.6 → 1.7)

**Coordinates (both lines, only the version differs):** `org.mapstruct:mapstruct` (runtime) + `org.mapstruct:mapstruct-processor` (processor). `lombok-mapstruct-binding` latest = `0.2.0`. Minimum to run the processor: **Java 8+** (Java 9+ only for JPMS) — unchanged across 1.6/1.7.

**Migrating 1.5.x → 1.6.0 (breaking changes — relevant if a project is on 1.5):**
- **Source-parameter conditions:** a plain `@Condition` method taking the source parameter no longer gates the whole parameter — annotate it `@SourceParameterCondition` (or `@Condition(appliesTo = ConditionStrategy.SOURCE_PARAMETERS)`). `@Condition` now defaults to *property* conditions.
- **Map → Bean in multi-source methods:** a `Map` is no longer used for implicit property mapping; add explicit `@Mapping(source = "map.key")`.
- **`@BeanMapping` inheritance:** all attributes except `resultType` and `ignoreUnmappedSourceProperties` now propagate consistently to generated nested methods (`ignoreByDefault` now propagates). Code relying on the old behavior may change.
- 1.6.1 / 1.6.2 / 1.6.3 are bug-fix only (no new features). 1.6.3 is the recommended stable.

**Migrating 1.6.3 → 1.7.0.Beta1 (additive — nothing removed):** 1.7 is a superset. New capabilities you may adopt (all tagged **[1.7+]** above): `java.util.Optional` mapping (§3.10, §5.1), Kotlin support (§2.7), Java 21 sequenced-collection impl types (§6.3), `@Ignored` (§5.3), `NullValuePropertyMappingStrategy.CLEAR` (§10.8), `locale` for number/date formatting (§5.1), builder detection without a factory method (§3.8), `@AnnotateWith` on decorators (§12.1), custom exception for non-exhaustive `@SubclassMapping` (§10.4), and `mapstruct.disableLifecycleOverloadDeduplicateSelector` (Appendix A). Behavior changes to expect: `Optional` targets initialize to `Optional.empty()` instead of `null`; `String`→`Number` is now reported as a lossy conversion (warning via `typeConversionPolicy`); new warnings for a target with no target properties and for redundant `ignoreUnmappedSourceProperties` entries (governed by `unmappedSourcePolicy`). No source/target code from 1.6.3 should need to change to compile on 1.7.

**When a newer version ships:** add new **[x.y+]** tags and matching entries/appendix rows; keep the older material and its tags intact so every supported version stays documented.

---

*Sources: MapStruct Reference Guide — dev (1.7.0.Beta1, `https://mapstruct.org/documentation/dev/reference/html/`) and stable (1.6.3, `https://mapstruct.org/documentation/stable/reference/html/`); MapStruct GitHub release notes for 1.6.0 and 1.7.0.Beta1. Code examples are adapted from the guide's examples and the generated-code samples it shows.*






