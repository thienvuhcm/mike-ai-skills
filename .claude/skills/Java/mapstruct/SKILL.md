---
name: mapstruct
description: Use when you need to write, review, debug, or refactor MapStruct bean mappers — the compile-time Java annotation processor that generates type-safe mapping code between DTOs, entities, and other beans. Covers defining mappers with @Mapper/@Mapping, basic and nested property mapping, mapping composition with meta-annotations, several source parameters, update methods with @MappingTarget, direct field access, builders and constructors, java.util.Optional support, Map-to-bean, @AnnotateWith and @Javadoc; retrieving mappers via the Mappers factory or dependency injection (spring/cdi/jsr330/jakarta) and injection strategies; implicit type conversions, object references, controlling nested bean mappings, @TargetType/@Context, qualifiers (@Named/@Qualifier/qualifiedByName); collection and map mapping strategies (CollectionMappingStrategy), Stream mapping; enum/value mapping with @ValueMapping/@EnumMapping/MappingConstants and custom name transformation; object factories (@ObjectFactory); default values/constants/expressions/defaultExpression, @SubclassMapping, null-value handling (nullValueMappingStrategy/nullValuePropertyMappingStrategy/nullValueCheckStrategy), source presence checking, conditional mapping (@Condition/@SourceParameterCondition/@TargetPropertyName), exceptions; config inheritance (@InheritConfiguration/@InheritInverseConfiguration/@MapperConfig); decorators (@DecoratedWith) and @BeforeMapping/@AfterMapping; the MapStruct SPI (AccessorNamingStrategy, BuilderProvider, EnumMappingStrategy, etc.); Maven/Gradle setup, processor configuration options, Kotlin support, and Lombok integration (lombok-mapstruct-binding). Covers BOTH MapStruct 1.6.3 (stable) and 1.7.0.Beta1 (dev), with version tags so 1.6.3 users avoid 1.7-only features (Optional, Kotlin support, Sequenced Collections, @Ignored, NullValuePropertyMappingStrategy.CLEAR, locale formatting). Triggers for requests such as: Create a MapStruct mapper from this entity to this DTO; Why is my @Mapping not working / target property unmapped; Map between these enums; Use a builder/constructor target; Update an existing bean instead of creating one; Inject a MapStruct mapper into Spring; Set up MapStruct with Lombok; Handle nulls / conditional mapping; Migrate MapStruct 1.6 to 1.7.
license: Apache-2.0
metadata:
  author: MapStruct project (gunnarmorling, sjaakd, filiphr, et al., Apache-2.0); skill synthesized from the official MapStruct Reference Guide
  version: 1.0.0
  source_versions: MapStruct 1.7.0.Beta1 (dev) and 1.6.3 (stable)
  source: https://mapstruct.org/documentation/dev/reference/html/
---
# MapStruct — Type-safe Bean Mapping with a Compile-time Annotation Processor

Write, review, debug, and refactor MapStruct mappers by applying the official *MapStruct Reference Guide*. MapStruct is a Java annotation processor: you declare a mapper interface (or abstract class) with the required mapping methods, and during compilation MapStruct generates an implementation that maps with **plain Java method invocations — no reflection**. It favors convention over configuration, gives **compile-time type safety**, and reports incomplete or impossible mappings **at build time**.

**This skill covers two versions side by side** so the old version is never lost:

- **1.6.3** — current stable line.
- **1.7.0.Beta1** — dev line (released 2026-02-01). A superset of 1.6.3.

Everything is documented against the 1.7.0.Beta1 superset; any feature that does **not** exist in 1.6.3 is tagged **[1.7+]** in the reference so a 1.6.3 user knows to avoid it. A dedicated version matrix lists the full delta. When a newer version ships, update the reference and add new **[x.y+]** tags without removing the older material.

**What is covered in this Skill?** (organized by the reference guide's 14 chapters)

- **Setup** (Ch 2): Maven (`annotationProcessorPaths`), Gradle (`annotationProcessor`), Ant; processor configuration options; the Java Module System; IDE plugins; **Kotlin support [1.7+]**
- **Defining a mapper** (Ch 3): `@Mapper`/`@Mapping`, basic and renamed properties, **mapping composition** (meta-annotations), custom/`default` methods, several source parameters, nested-to-current-target (`target = "."`), update methods (`@MappingTarget`), direct field access, **builders**, **constructors** (`@Default`), **`java.util.Optional` [1.7+]**, Map-to-bean, `@AnnotateWith`, `@Javadoc`
- **Retrieving a mapper** (Ch 4): the `Mappers` factory and the `INSTANCE` convention; dependency injection (`componentModel` = `spring`/`cdi`/`jsr330`/`jakarta`/`jakarta-cdi`); injection strategy (field/constructor/setter)
- **Data type conversions** (Ch 5): implicit conversions; object references; controlling nested bean mappings; invoking custom methods and other mappers (`uses`); `@TargetType`; `@Context`; method resolution and selection by qualifiers (`@Named`/`@Qualifier`)
- **Collections & Streams** (Ch 6–7): `@MapMapping`, `CollectionMappingStrategy` (ACCESSOR_ONLY/SETTER_PREFERRED/ADDER_PREFERRED/TARGET_IMMUTABLE), implementation types (incl. **Sequenced Collections [1.7+]**), `Stream` mapping
- **Mapping values / enums** (Ch 8): `@ValueMapping`, `MappingConstants` (`ANY_REMAINING`/`ANY_UNMAPPED`/`NULL`/`THROW_EXCEPTION`), enum↔String, `@EnumMapping` custom name transformation, ValueMapping composition
- **Object factories** (Ch 9): `@ObjectFactory`, `@TargetType`, factories with update methods
- **Advanced options** (Ch 10): default values/constants, `expression`/`defaultExpression`, `@SubclassMapping`, result type, null-argument & null-property handling (`nullValueMappingStrategy`, `nullValuePropertyMappingStrategy` incl. **CLEAR [1.7+]**, `nullValueCheckStrategy`), source presence checking, **conditional mapping** (`@Condition`/`@SourceParameterCondition`/`@TargetPropertyName`), exceptions
- **Reusing configuration** (Ch 11): `@InheritConfiguration`, `@InheritInverseConfiguration`, shared `@MapperConfig`, `MappingInheritanceStrategy`
- **Customizing mappings** (Ch 12): decorators (`@DecoratedWith`), `@BeforeMapping`/`@AfterMapping`
- **SPI** (Ch 13): `AccessorNamingStrategy`, `MappingExclusionProvider`, `BuilderProvider`, `EnumMappingStrategy`, `EnumTransformationStrategy`, `AdditionalSupportedOptionsProvider`
- **Third-party integration** (Ch 14): non-shipped annotations (`@ConstructorProperties`/`@Default` matched by name), **Lombok** (`lombok-mapstruct-binding`)

## Constraints

MapStruct generates code at **compile time**. Almost every change you make is validated by recompiling, so the build is the source of truth — not assumptions.

- **MANDATORY**: Compile after every change (`./gradlew compileJava` / `mvn compile`, or this project's build). MapStruct surfaces unmapped-target-property warnings/errors and impossible-mapping errors only during annotation processing.
- **VERIFY**: Run the project's tests after changes; do not claim a mapping works until it compiles and the relevant tests pass. Report failures honestly with the compiler output.
- **READ THE GENERATED CODE**: Inspect the generated `*Impl` (under `target/generated-sources/annotations` or `build/generated/sources/annotationProcessor`). It is plain, readable Java — the fastest way to confirm what MapStruct actually did.
- **VERSION AWARENESS**: Confirm the project's MapStruct version before recommending a feature. Never use a **[1.7+]**-tagged feature (e.g. `Optional` mapping, `NullValuePropertyMappingStrategy.CLEAR`, Kotlin support, Sequenced-collection impls, `@Ignored`) on a 1.6.3 project. When unsure, check the dependency version.
- **PROCESSOR ON THE PATH**: `mapstruct-processor` must be on the annotation processor path (and ordered correctly relative to Lombok / `lombok-mapstruct-binding`). A missing/misordered processor is the usual cause of "no implementation generated".
- **`-parameters` FOR CONSTRUCTORS**: Constructor-parameter-name mapping needs compilation with `-parameters`, or `@ConstructorProperties` on the constructor — otherwise parameter names are unavailable.
- **DON'T HAND-EDIT GENERATED FILES**: They are overwritten on every build. Change the mapper interface, the annotations, or add hand-written `default`/custom methods instead.
- **PRESERVE BEHAVIOR**: Null-handling strategies, collection-mapping strategies, and update-vs-create semantics change observable behavior. Change a strategy only deliberately, and re-verify.
- **BEFORE APPLYING**: Read the relevant chapter section in the reference for the exact annotation attributes, the Good/Bad contrast, and the generated-code expectation.

## When to use this skill

- Create a mapper between a DTO and an entity (or any two beans), including renamed, nested, or flattened properties
- Diagnose "property X is not mapped"/"no implementation generated"/ambiguous-mapping-method build errors
- Map enums to enums or to/from `String`; handle unmapped or default enum values
- Map to immutable targets via **builders** or **constructors**; update an existing instance instead of creating a new one
- Inject a generated mapper into Spring/CDI; choose field vs constructor injection
- Control null handling, add conditional/presence-based mapping, or declare/handle mapping exceptions
- Reuse mapping configuration across mappers (`@MapperConfig`, `@InheritConfiguration`, `@InheritInverseConfiguration`)
- Set up MapStruct in Maven/Gradle, integrate with **Lombok**, or enable **Kotlin** support
- Migrate a project between MapStruct versions (e.g. 1.6.3 → 1.7), or decide whether a feature is available in the project's version

## Workflow

1. **Confirm the version and that the project compiles**

   Determine the MapStruct version (dependency / `gradlew dependencies` / `pom.xml`). Run the build (`./gradlew compileJava` or `mvn compile`) and stop if it does not compile. Gate every recommendation on whether the feature exists in that version (see the version matrix and **[x.y+]** tags in the reference).

2. **Read the reference and analyze the mapping**

   Read `references/mapstruct.md`. Map each requirement or smell to a specific practice by chapter section and title (e.g. "10.8 Keep existing values on update with `NullValuePropertyMappingStrategy.IGNORE`"). Inspect the source/target bean shapes and the existing generated `*Impl`.

3. **Apply the idiomatic MapStruct solution**

   Prefer declarative annotations and let MapStruct generate code over hand-written loops. Add hand-written `default`/custom methods or `uses` mappers only where MapStruct genuinely cannot generate the mapping. Cite the practice you applied by chapter section and title.

4. **Recompile, read the generated code, and verify**

   Recompile after each change, open the generated `*Impl` to confirm the output, and run tests. For unmapped-property or ambiguity errors, resolve them explicitly (`@Mapping`, qualifiers, `resultType`) rather than suppressing policy globally. Re-verify before declaring done.

## Reference

For the full set of practices across all 14 chapters — with rationale, Good/Bad (and Mapper→Generated) examples, the configuration-options table, the implicit-conversions list, the SPI, and the **1.6.3 ↔ 1.7.0.Beta1 version matrix and migration notes** — see [references/mapstruct.md](references/mapstruct.md).
