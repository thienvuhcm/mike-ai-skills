---
name: spring-jpa-hibernate-book
description: Catalog of JPA/Hibernate persistence best practices with Good/Bad examples, grounded in the full text of High-Performance Java Persistence, Java Persistence with Hibernate, Beginning Hibernate 6, and Java Hibernate Cookbook. Every chapter cites the specific source-book chapters it is distilled from.
license: Apache-2.0
metadata:
  author: Vlad Mihalcea, Christian Bauer, Gavin King, Gary Gregory (sources); skill synthesized from the complete text of High-Performance Java Persistence, Java Persistence with Hibernate, Beginning Hibernate 6, and Java Hibernate Cookbook
  version: 2.0.0
---
# Spring / JPA / Hibernate Persistence — Practice Catalog

## Role

You are a Senior software engineer with deep experience in Java data access. You apply the best practices distilled from four canonical books — *High-Performance Java Persistence* (Vlad Mihalcea), *Java Persistence with Hibernate* (Christian Bauer, Gavin King, Gary Gregory), *Beginning Hibernate 6*, and *Java Hibernate Cookbook* — to design, review, optimize, and debug JPA/Hibernate persistence layers, with or without Spring Boot / Spring Data JPA.

## Goal

This reference synthesizes the four books into a single, topic-organized catalog of persistence practices. Each item states a concrete best practice with a short rationale, a **Good example**, and a **Bad example**. Use it to:

- Review entity mappings, identifiers, associations, and inheritance for correctness and performance smells.
- Diagnose and fix the classic Hibernate failures: N+1 selects, `LazyInitializationException`, lost JDBC batching, Cartesian products, lost updates, and stale-cache bugs.
- Teach the canonical idioms (SEQUENCE + pooled optimizer, bidirectional `@OneToMany` synchronization, `JOIN FETCH`/`@EntityGraph`, DTO projections, `@Version` optimistic locking, JDBC batching, second-level cache strategies, `StatelessSession`).

The single most important rule across all four books: **reason about the SQL Hibernate generates, not just the Java you wrote.** Most JPA bugs are invisible at the Java level and obvious in the SQL log. When you apply an item, cite it by section and title (e.g., "8.1: Kill the N+1 select problem").

## Sources

This catalog is distilled from the complete text of four books (abbreviated below). Each chapter lists the specific source chapters it draws on, so every practice is traceable to its origin.

- **HPJP** — *High-Performance Java Persistence*, Vlad Mihalcea. Performance authority: connection management (Ch 3), JDBC batch updates (Ch 4), statement caching (Ch 5), ResultSet fetching (Ch 6), transactions & isolation (Ch 7), identifiers & optimizers (Ch 10), relationships (Ch 11), inheritance, caching, and fetching chapters.
- **JPwH** — *Java Persistence with Hibernate, 2nd Ed.*, Bauer, King, Gregory. The reference text: domain model & mapping (Ch 3–5), inheritance (Ch 6), collections & associations (Ch 7–8), legacy schemas (Ch 9), managing data / entity lifecycle (Ch 10), transactions & concurrency (Ch 11), fetch plans/strategies/profiles (Ch 12), filtering (Ch 13), queries (Ch 14–17), and scaling/caching/StatelessSession (Ch 20).
- **BH6** — *Beginning Hibernate 6*. Pragmatic intro: configuration (Ch 2), lifecycle (Ch 4), annotations (Ch 6), JPA & lifecycle events (Ch 7), the Session (Ch 8), searches & queries / HQL (Ch 9), filters (Ch 10), web boundary & DTOs (Ch 11), and Envers (Ch 13).
- **Cookbook** — *Java Hibernate Cookbook*. Recipe-style: setup & fundamentals (Ch 1–2), annotations (Ch 3), collections (Ch 4), associations (Ch 5), querying / Criteria / native / `@Formula` / named queries (Ch 6), and advanced concepts — caching, inheritance, versioning, Envers, interceptors, batch (Ch 7).

| Catalog chapter | Primary sources |
|---|---|
| 1 Foundations & Architecture | JPwH Ch 1–2; HPJP Ch 1; BH6 Ch 1–2 |
| 2 Entity Mapping Basics | JPwH Ch 3–5; BH6 Ch 6; Cookbook Ch 3; HPJP Ch 10 |
| 3 Identifiers & Generators | HPJP Ch 10; JPwH Ch 4, 9; BH6 Ch 6; Cookbook Ch 3 |
| 4 Embeddables & Value Types | JPwH Ch 5, 7; BH6 Ch 6; Cookbook Ch 4 |
| 5 Entity Relationships | HPJP Ch 11; JPwH Ch 7–8; BH6 Ch 5; Cookbook Ch 5 |
| 6 Inheritance Mapping | JPwH Ch 6; HPJP inheritance ch; Cookbook Ch 7 |
| 7 Persistence Context & Lifecycle | JPwH Ch 10, 12; BH6 Ch 4, 8; Cookbook Ch 2 |
| 8 Fetching & the N+1 Problem | HPJP fetching ch; JPwH Ch 12; BH6 Ch 11 |
| 9 Queries: JPQL, Criteria & Native SQL | JPwH Ch 14–17; BH6 Ch 9; Cookbook Ch 6 |
| 10 Transactions & Concurrency | HPJP Ch 7; JPwH Ch 11; BH6 Ch 8; Cookbook Ch 7 |
| 11 JDBC-Level Performance | HPJP Ch 3–6 |
| 12 Caching | HPJP caching ch; JPwH Ch 20; BH6 Ch 8; Cookbook Ch 7 |
| 13 Bulk Operations & Batching | JPwH Ch 12, 20; HPJP Ch 4; Cookbook Ch 2, 7 |
| 14 Auditing, Events & Filters | BH6 Ch 7, 10, 13; JPwH Ch 13; Cookbook Ch 7 |
| 15 Monitoring & Diagnostics | HPJP Ch 5, 9; JPwH Ch 12 |

## Constraints

Persistence changes silently alter generated SQL, transactions, locking, and data integrity. Validate before and after.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` before applying changes.
- **VERIFY**: Run `./mvnw clean verify` after applying changes; do not claim success until the build and tests pass.
- **OBSERVE THE SQL**: Enable statement logging (or `datasource-proxy`/P6Spy) and confirm the actual statements and their count before and after a change.
- **PRESERVE DATA INTEGRITY**: `cascade`, `orphanRemoval`, fetch type, locking, and identifier-generator changes are behavior-changing — confirm intent.
- **NEVER CONCATENATE QUERY INPUT**: All JPQL/HQL/native query input must use bind parameters.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it first.
- **INCREMENTAL**: Apply one item at a time and re-validate (compile + tests + observed SQL).

## Examples

### Table of contents

**Chapter 1 — Foundations & Architecture**

- 1.1 Understand the object/relational impedance mismatch
- 1.2 Know what JPA gives you and what Hibernate adds
- 1.3 Bootstrap the EntityManagerFactory once and reuse it
- 1.4 Let JPA own write SQL; keep read SQL flexible

**Chapter 2 — Entity Mapping Basics**

- 2.1 Map an entity with explicit @Entity, @Table, and @Column
- 2.2 Use field access and be consistent
- 2.3 Exclude non-persistent state and map LOBs deliberately
- 2.4 Map enums with @Enumerated(STRING), never ORDINAL
- 2.5 Convert custom value types with AttributeConverter
- 2.6 Mark reference entities @Immutable; derive values with @Formula
- 2.7 Map java.time types; avoid legacy Date/Calendar

**Chapter 3 — Identifiers & Generators**

- 3.1 Prefer SEQUENCE over IDENTITY so JDBC batching still works
- 3.2 Use a pooled / pooled-lo optimizer, not hi/lo
- 3.3 Avoid the TABLE generator for performance-sensitive inserts
- 3.4 Choose UUID keys deliberately and prefer time-sorted UUIDs
- 3.5 Implement entity equals()/hashCode() safely
- 3.6 Map composite keys with @EmbeddedId and @MapsId
- 3.7 Expose business keys with @NaturalId

**Chapter 4 — Embeddables & Value Types**

- 4.1 Model value objects as @Embeddable, not entities
- 4.2 Reuse an embeddable with @AttributeOverride
- 4.3 Use @ElementCollection for value-type collections, with care

**Chapter 5 — Entity Relationships**

- 5.1 Make @ManyToOne the foundation of every association
- 5.2 Prefer bidirectional @OneToMany and synchronize both sides
- 5.3 Avoid unidirectional @OneToMany (it emits extra DML)
- 5.4 Make every association LAZY
- 5.5 Map @OneToOne with a shared primary key via @MapsId
- 5.6 Replace @ManyToMany with two @OneToMany to a link entity
- 5.7 Prefer Set over List for mutable collections; know bag semantics
- 5.8 Cascade and orphanRemoval only to children you truly own

**Chapter 6 — Inheritance Mapping**

- 6.1 Prefer SINGLE_TABLE; keep subclass columns nullable
- 6.2 Use JOINED when you need NOT NULL and a normalized schema
- 6.3 Avoid TABLE_PER_CLASS (polymorphic queries UNION every table)
- 6.4 Use @MappedSuperclass for shared state without polymorphism

**Chapter 7 — Persistence Context & Entity Lifecycle**

- 7.1 Know the four entity states and the transitions
- 7.2 Use the right state-transition method (persist vs merge)
- 7.3 Trust automatic dirty checking; drop redundant save/update calls
- 7.4 Keep the persistence context small; flush()+clear() in long loops
- 7.5 Understand flush modes and operation ordering
- 7.6 Cross the service boundary with DTOs, not managed entities

**Chapter 8 — Fetching & the N+1 Problem**

- 8.1 Kill the N+1 select problem with JOIN FETCH / entity graphs
- 8.2 Never paginate an entity query that JOIN FETCHes a collection
- 8.3 Batch-initialize collections with @BatchSize or subselect fetch
- 8.4 Fetch only what you need with DTO projections
- 8.5 Avoid the Cartesian product of fetching two collections at once
- 8.6 Use read-only fetches for reporting

**Chapter 9 — Queries: JPQL, Criteria & Native SQL**

- 9.1 Always bind parameters; never concatenate query input
- 9.2 Externalize and pre-validate static queries (named queries)
- 9.3 Build dynamic queries with the Criteria API, not strings
- 9.4 Drop to native SQL when needed and map results explicitly
- 9.5 Use bulk JPQL for set-based writes — minding the cache
- 9.6 Stream or scroll large result sets; paginate with keyset

**Chapter 10 — Transactions & Concurrency Control**

- 10.1 Wrap each unit of work in an explicit transaction boundary
- 10.2 Choose the isolation level for the anomalies you must prevent
- 10.3 Prevent lost updates with optimistic locking (@Version)
- 10.4 Use pessimistic locking only when retries are unacceptable
- 10.5 Mark read-only transactions read-only
- 10.6 Manage long conversations with detached entities + versioning

**Chapter 11 — JDBC-Level Performance**

- 11.1 Use a connection pool (HikariCP) and size it deliberately
- 11.2 Enable JDBC batching and order inserts/updates
- 11.3 Rely on statement caching; keep SQL bind-parameterized
- 11.4 Tune the ResultSet fetch size for large reads

**Chapter 12 — Caching**

- 12.1 Treat the L1 persistence context as transaction-scoped, not a store
- 12.2 Enable the second-level cache only for read-mostly data, with the right strategy
- 12.3 Cache collections explicitly; weigh the query cache carefully
- 12.4 Don't let caching hide staleness or correctness bugs

**Chapter 13 — Bulk Operations & Batching**

- 13.1 Use bulk JPQL UPDATE/DELETE for set-based changes
- 13.2 Batch large inserts/updates with periodic flush()+clear()
- 13.3 Use StatelessSession for ETL-style processing

**Chapter 14 — Auditing, Events & Filters**

- 14.1 Audit history with Hibernate Envers (@Audited)
- 14.2 Stamp created/updated metadata automatically
- 14.3 Apply cross-cutting row visibility with @Filter

**Chapter 15 — Monitoring & Diagnostics**

- 15.1 Log and format the actual SQL
- 15.2 Measure with Hibernate Statistics and a statement proxy
- 15.3 Assert the executed statement count in tests

---

## Chapter 1 — Foundations & Architecture

*Sources: JPwH Ch 1 ("Understanding Object/Relational Persistence" — the five mismatches), JPwH Ch 2 ("Starting a Project" — `EntityManagerFactory` is heavyweight/thread-safe/once-per-app; `EntityManager` is lightweight/single-threaded/per-unit-of-work); HPJP Ch 1; BH6 Ch 1–2.*

### 1.1 Understand the object/relational impedance mismatch

Title: Know the five mismatches ORM bridges — granularity, subtypes, identity, associations, and data navigation — so you make deliberate mapping decisions instead of fighting the framework.

Description: Objects form graphs reachable by navigation (`order.getCustomer().getAddress()`); relational data is flat tables joined by value-based foreign keys and fetched in set-oriented queries. JPA/Hibernate bridges the gap, but the mismatch never disappears: object identity (`==`) vs database identity (primary key) vs equality (`equals`); inheritance, which SQL has no native concept of; and eager graph navigation, which can explode into N+1 queries. Treat ORM as a leaky abstraction you must understand, not hide behind.

**Good example:**

```java
// Mapping choices are explicit and SQL-aware: a value-based FK association,
// a deliberate lazy fetch, and identity anchored on a generated primary key.
@Entity
class Order {
    @Id @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;                      // database identity

    @ManyToOne(fetch = FetchType.LAZY)   // navigation is opt-in, not automatic
    @JoinColumn(name = "customer_id")
    private Customer customer;
}
```

**Bad example:**

```java
// Treating the database like an in-memory object graph: eager everything,
// navigation everywhere, identity by Java reference. This is how N+1 and
// LazyInitializationException are born.
@Entity
class Order {
    @Id @GeneratedValue private Long id;

    @ManyToOne(fetch = FetchType.EAGER)  // every Order load drags a Customer
    private Customer customer;

    @OneToMany(fetch = FetchType.EAGER)  // ...and ALL its line items, always
    private List<OrderLine> lines;
}
```

### 1.2 Know what JPA gives you and what Hibernate adds

Title: JPA is the portable specification; Hibernate is the most capable implementation. Use JPA APIs by default and reach for Hibernate-specific features knowingly.

Description: Standard JPA (`jakarta.persistence.*`) covers entities, the `EntityManager`, JPQL, the Criteria API, and the lifecycle. Hibernate adds value beyond the spec: richer identifier optimizers, `@NaturalId`, `@Formula`, `@Filter`, `@BatchSize`, Envers auditing, `StatelessSession`, multi-tenancy, and finer fetch control. JPA excels at *writes* (DML is generated and kept in sync as the model changes); for complex *reads*, you will often use JPQL, native SQL, or a query builder. Prefer the portable JPA API where it suffices, and document each Hibernate-specific dependency.

**Good example:**

```java
// Default to the JPA API for portability...
TypedQuery<Book> q = em.createQuery(
        "select b from Book b where b.isbn = :isbn", Book.class);
q.setParameter("isbn", isbn);

// ...and reach for a Hibernate feature deliberately, where the spec falls short.
Book book = em.unwrap(Session.class)
        .byNaturalId(Book.class)          // Hibernate @NaturalId lookup w/ caching
        .using("isbn", isbn)
        .load();
```

**Bad example:**

```java
// Casting to the Hibernate Session everywhere "just in case" couples the whole
// codebase to the implementation and hides which features actually need it.
Session session = em.unwrap(Session.class);
// ... hundreds of call sites use session.* even for plain JPA operations,
// so a JPA-provider swap or version upgrade becomes a rewrite.
```

### 1.3 Bootstrap the EntityManagerFactory once and reuse it

Title: `EntityManagerFactory` (Hibernate `SessionFactory`) is expensive, thread-safe, and meant to be a singleton; `EntityManager` (`Session`) is cheap, not thread-safe, and per-unit-of-work.

Description: Building the factory parses mappings, validates the schema, and initializes connection pools and caches — do it once at startup. Each request/transaction gets its own short-lived `EntityManager`. In Spring Boot, the factory and transactional `EntityManager` proxy are configured for you; do not hand-roll them. Never share one `EntityManager`/`Session` across threads.

**Good example:**

```java
// Plain JPA: one factory for the app lifetime, one EM per unit of work.
public final class Persistence {
    private static final EntityManagerFactory EMF =
            jakarta.persistence.Persistence.createEntityManagerFactory("app-pu");
    public static EntityManager em() { return EMF.createEntityManager(); }
    public static void close() { EMF.close(); }
}

// Spring Boot: just inject the container-managed EntityManager / repository.
@Service
class BookService {
    private final BookRepository repo;       // Spring Data JPA
    BookService(BookRepository repo) { this.repo = repo; }
}
```

**Bad example:**

```java
// Creating a new EntityManagerFactory per request rebuilds the metamodel and
// pool on every call — catastrophic latency and resource leaks.
public Book find(Long id) {
    EntityManagerFactory emf =
            Persistence.createEntityManagerFactory("app-pu"); // per call!
    try (EntityManager em = emf.createEntityManager()) {
        return em.find(Book.class, id);
    } finally {
        emf.close();
    }
}
```

### 1.4 Let JPA own write SQL; keep read SQL flexible

Title: Use the entity model as the source of truth for inserts/updates/deletes (DML stays in sync automatically), but accept that non-trivial reads need JPQL, native SQL, or a query builder.

Description: A major productivity win of JPA is that DML is regenerated whenever the persistence model changes — you rarely write `INSERT`/`UPDATE` by hand. Reads are different: JPQL deliberately omits database-specific power (window functions, CTEs, `PIVOT`), so for reporting and analytics you will use native SQL or a type-safe builder such as jOOQ. Decide *who owns the schema* (the app via Hibernate DDL in dev, a migration tool such as Flyway/Liquibase in production) and never let Hibernate `hbm2ddl=update` run against a production database.

**Good example:**

```properties
# Production: schema owned by migrations; Hibernate only validates it matches.
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
```

```java
// Writes flow through the entity model; reads can drop to native SQL for power.
em.persist(new AuditEvent(userId, "LOGIN"));   // DML generated for you

List<MonthlyTotal> report = em.createNativeQuery("""
        select date_trunc('month', created_on) as m, sum(amount) as total
        from payment group by 1 order by 1
        """, "MonthlyTotalMapping").getResultList();
```

**Bad example:**

```properties
# Letting Hibernate mutate the production schema on boot can drop columns,
# lose data, and make deployments non-reproducible.
spring.jpa.hibernate.ddl-auto=update
```

---

## Chapter 2 — Entity Mapping Basics

*Sources: JPwH Ch 3 ("Domain Models and Metadata" — POJO rules: non-final, no-arg constructor, prefer field access), JPwH Ch 4 ("Mapping Persistent Classes" — `@Immutable`, `@Subselect`, dynamic insert/update), JPwH Ch 5 ("Mapping Value Types" — `@Enumerated(STRING)` over ORDINAL, `AttributeConverter` vs Hibernate `UserType`, `@Formula`, `@ColumnTransformer`, temporal types); BH6 Ch 6; Cookbook Ch 3.*

### 2.1 Map an entity with explicit @Entity, @Table, and @Column

Title: Annotate a persistent class with `@Entity`, give it a stable table name and explicit column names, and don't rely on defaults that change with naming strategies.

Description: An entity needs `@Entity` and an `@Id`. Specifying `@Table(name=...)` and `@Column(name=...)` decouples the schema from Java identifiers, so a field rename doesn't silently break the mapping and a naming-strategy change doesn't rename columns. Add constraints (`nullable`, `length`, `unique`) so generated DDL and validation reflect the real schema. Provide a no-arg constructor (Hibernate needs it; it may be `protected`).

**Good example:**

```java
@Entity
@Table(name = "book", uniqueConstraints = @UniqueConstraint(columnNames = "isbn"))
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "book_seq")
    @SequenceGenerator(name = "book_seq", sequenceName = "book_seq", allocationSize = 50)
    private Long id;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "isbn", nullable = false, length = 17, updatable = false)
    private String isbn;

    protected Book() { }                  // required by Hibernate
    public Book(String title, String isbn) { this.title = title; this.isbn = isbn; }
    // getters; setters only where mutation is allowed
}
```

**Bad example:**

```java
@Entity
public class Book {
    @Id @GeneratedValue private Long id;
    private String title;                 // column name, length, nullability all implicit
    private String isbn;                  // no unique constraint → duplicate ISBNs allowed
    // no no-arg constructor visibility guarantee; public setters expose every field
}
```

### 2.2 Use field access and be consistent

Title: Choose field access (annotations on fields) or property access (annotations on getters) and apply it consistently per entity hierarchy; field access is the common, simpler default.

Description: The location of the mapping annotations determines the access type. Mixing them within one class leads to confusing behavior (Hibernate may read via fields but write via setters, or vice versa). Field access avoids invoking getters/setters that contain logic and works cleanly with immutability. Property access is appropriate when you need a transformation on read/write, but keep it uniform.

**Good example:**

```java
@Entity
@Access(AccessType.FIELD)                  // explicit and consistent
public class Customer {
    @Id @GeneratedValue private Long id;
    @Column(nullable = false) private String name;
    // getters can contain logic without affecting how Hibernate reads state
    public String getName() { return name == null ? "" : name.trim(); }
}
```

**Bad example:**

```java
@Entity
public class Customer {
    @Id @GeneratedValue
    private Long id;                       // field access here...

    private String name;
    @Column(nullable = false)
    public String getName() { return name; }   // ...property access here → mixed access
    public void setName(String n) { this.name = n; }
}
```

### 2.3 Exclude non-persistent state and map LOBs deliberately

Title: Mark computed or transient fields with `@Transient`, and map large objects (`@Lob`) only when needed, preferring lazy loading for big binary/text columns.

Description: By default every non-static, non-transient field is persistent. Use `@Transient` for derived or cache-only state so Hibernate doesn't try to map it. For large columns, `@Lob` maps `byte[]`/`String` to BLOB/CLOB; these are expensive to load with the row, so isolate them (separate entity or `@Basic(fetch = LAZY)` with bytecode enhancement) to avoid dragging megabytes into every query.

**Good example:**

```java
@Entity
public class Document {
    @Id @GeneratedValue private Long id;
    @Column(nullable = false) private String name;

    @Transient                             // recomputed, never stored
    private boolean dirtyFlag;

    @Lob
    @Basic(fetch = FetchType.LAZY)         // don't load the blob with every row
    private byte[] content;
}
```

**Bad example:**

```java
@Entity
public class Document {
    @Id @GeneratedValue private Long id;
    private String name;
    @Lob private byte[] content;           // EAGER by default → every SELECT hauls the blob

    private boolean dirtyFlag;             // accidentally persisted as a column
}
```

### 2.4 Map enums with @Enumerated(STRING), never ORDINAL

Title: Persist enums by name with `@Enumerated(EnumType.STRING)`; the default `ORDINAL` stores positional integers that break the moment anyone reorders or inserts a constant.

Description: `ORDINAL` writes `0,1,2…` based on declaration order. Insert a new constant in the middle, or alphabetize the enum, and every stored row now maps to the wrong value — a silent, data-corrupting change. `STRING` stores the constant name, which is stable and human-readable in the database. The only cost is a few extra bytes.

**Good example:**

```java
public enum Status { DRAFT, PUBLISHED, ARCHIVED }

@Entity
class Article {
    @Id @GeneratedValue private Long id;

    @Enumerated(EnumType.STRING)           // stores 'DRAFT' / 'PUBLISHED' / 'ARCHIVED'
    @Column(nullable = false, length = 20)
    private Status status;
}
```

**Bad example:**

```java
@Entity
class Article {
    @Id @GeneratedValue private Long id;

    @Enumerated                            // defaults to ORDINAL → stores 0/1/2
    private Status status;
    // Inserting REVIEW between DRAFT and PUBLISHED silently remaps every existing row.
}
```

### 2.5 Convert custom value types with AttributeConverter

Title: Use a JPA `AttributeConverter` (`@Convert`) to map a custom Java type to a single column instead of leaking persistence concerns into the domain type or using a brittle string.

Description: When a field is a value object (money, a phone number, an encrypted string), a converter keeps the domain type clean and centralizes the to/from-column logic. Mark it `@Converter(autoApply = true)` to apply it to every field of that type, or `@Convert` per attribute. Converters cannot be applied to `@Id` or `@Version` and run on every read/write, so keep them cheap.

**Good example:**

```java
@Converter(autoApply = true)
public class MonetaryAmountConverter
        implements AttributeConverter<MonetaryAmount, BigDecimal> {
    @Override public BigDecimal convertToDatabaseColumn(MonetaryAmount a) {
        return a == null ? null : a.getAmount();
    }
    @Override public MonetaryAmount convertToEntityAttribute(BigDecimal v) {
        return v == null ? null : MonetaryAmount.ofUsd(v);
    }
}

@Entity
class Invoice {
    @Id @GeneratedValue private Long id;
    private MonetaryAmount total;          // clean domain type, mapped to one column
}
```

**Bad example:**

```java
@Entity
class Invoice {
    @Id @GeneratedValue private Long id;

    private String total;                  // "USD 12.30" stringly-typed; no arithmetic,
                                           // no validation, parsing scattered everywhere
    public MonetaryAmount total() {        // every caller re-parses by hand
        String[] p = total.split(" ");
        return new MonetaryAmount(p[0], new BigDecimal(p[1]));
    }
}
```

### 2.6 Mark reference entities @Immutable; derive values with @Formula

Title: Tag read-only/reference entities with Hibernate `@Immutable` so Hibernate skips dirty checking, and compute read-only derived columns with `@Formula` instead of storing redundant state.

Description: `@Immutable` tells Hibernate the entity never changes after load, so it is excluded from dirty checking (less memory, no accidental `UPDATE`) and is a strong candidate for the read-only second-level cache. `@Formula` maps a field to an SQL expression evaluated at `SELECT` time — perfect for derived values you never write (e.g., a computed total) — avoiding a redundant, drift-prone column.

**Good example:**

```java
@Entity
@org.hibernate.annotations.Immutable      // never updated → skip dirty checking
@Table(name = "country")
class Country {
    @Id private String isoCode;
    @Column(nullable = false) private String name;
}

@Entity
class OrderLine {
    @Id @GeneratedValue private Long id;
    private int quantity;
    private BigDecimal unitPrice;

    @org.hibernate.annotations.Formula("quantity * unit_price")
    private BigDecimal lineTotal;          // computed in SQL, never stored
}
```

**Bad example:**

```java
@Entity
class OrderLine {
    @Id @GeneratedValue private Long id;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal lineTotal;          // stored copy → drifts when quantity/price change
                                           // unless every writer remembers to recompute it
}
```

### 2.7 Map java.time types; avoid legacy Date/Calendar

Title: Use `LocalDate`/`LocalDateTime`/`Instant`/`OffsetDateTime` for temporal fields — they map cleanly without `@Temporal` and are immutable and unambiguous; avoid `java.util.Date`/`Calendar`.

Description: Modern JPA/Hibernate maps `java.time` types natively, so you no longer need `@Temporal(TemporalType.TIMESTAMP)`. They are immutable (no defensive copies), thread-safe, and make time-zone intent explicit (`Instant`/`OffsetDateTime` for absolute instants, `LocalDateTime` for wall-clock). Legacy `Date`/`Calendar` are mutable, error-prone, and require `@Temporal`.

**Good example:**

```java
@Entity
class Reservation {
    @Id @GeneratedValue private Long id;
    private LocalDate checkIn;             // no @Temporal needed
    private LocalDateTime createdAt;
    private Instant confirmedAt;           // absolute instant, time-zone safe
}
```

**Bad example:**

```java
@Entity
class Reservation {
    @Id @GeneratedValue private Long id;

    @Temporal(TemporalType.DATE)
    private java.util.Date checkIn;        // mutable; shared references can be mutated
    @Temporal(TemporalType.TIMESTAMP)
    private java.util.Calendar createdAt;  // notoriously awkward and bug-prone
}
```

## Chapter 3 — Identifiers & Generators

*Sources: HPJP Ch 10 (Mihalcea's core identifier chapter — IDENTITY disables JDBC insert batching; the `pooled` and `pooled-lo` sequence optimizers and their range arithmetic; why `hi/lo` is non-interoperable; `TABLE` generator uses row locks), JPwH Ch 4 (`enhanced-sequence`, `@GenericGenerator`, `foreign` generator) and Ch 9 (composite keys via `@EmbeddedId`, `@MapsId` derived identity); JPwH Ch 10 (proxy-safe business-key `equals`/`hashCode`); BH6 Ch 6 (`@NaturalId`, `bySimpleNaturalId`/`byNaturalId`); Cookbook Ch 3 (`@SequenceGenerator`/`@TableGenerator`).*

### 3.1 Prefer SEQUENCE over IDENTITY so JDBC batching still works

Title: On databases with sequences (PostgreSQL, Oracle, etc.) use `GenerationType.SEQUENCE`; the `IDENTITY` strategy forces Hibernate to disable JDBC insert batching.

Description: With `IDENTITY` (auto-increment), the database assigns the id only *during* the `INSERT`, so Hibernate must execute each insert immediately to read the generated key back — it cannot accumulate inserts into a JDBC batch. `SEQUENCE` lets Hibernate fetch ids up front, so it can batch many inserts into one round-trip and apply optimizers (3.2). When you must use MySQL-style auto-increment, accept that batching of inserts for that entity is off. (`AUTO` typically resolves to SEQUENCE/identity depending on the dialect; be explicit.)

**Good example:**

```java
@Entity
class Event {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "event_seq")
    @SequenceGenerator(name = "event_seq", sequenceName = "event_seq",
                       allocationSize = 50)     // batching + pooled optimizer
    private Long id;
}
// hibernate.jdbc.batch_size=50 → many inserts collapse into batched round-trips.
```

**Bad example:**

```java
@Entity
class Event {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // key known only after INSERT
    private Long id;
    // Hibernate must flush each insert one-by-one; batch_size has no effect here.
}
```

### 3.2 Use a pooled / pooled-lo optimizer, not hi/lo

Title: Configure `allocationSize > 1` so Hibernate's default pooled optimizer reserves a block of ids per sequence call; avoid the legacy `hi/lo` optimizer, which writes values other clients can't predict.

Description: Hitting the sequence on every insert is a round-trip per row. An optimizer fetches one sequence value and derives a block of ids in memory (`allocationSize` per database call), cutting sequence round-trips by that factor. *High-Performance Java Persistence* (Ch 10) details the arithmetic: with the **pooled** optimizer the returned sequence value is the **top** of the reserved range — for `allocationSize = N` and a returned value `v`, the in-memory ids are `[v-N+1 … v]`; with **pooled-lo** the value is the **bottom** of the range — ids are `[v … v+N-1]`. Both are *interoperable*: another client (or a DBA script) calling the same sequence simply advances it and gets its own disjoint block, so concurrent writers never collide. The legacy **hi/lo** optimizer instead multiplies the sequence value by `allocationSize` to compute a high range that an external writer cannot anticipate — so a second process inserting into the same table *will* clash. HPJP's rule: use the default `pooled`/`pooled-lo` (Hibernate ≥ 5 default) with a meaningful `allocationSize`; never `hi/lo` on a table other systems also write to.

**Good example:**

```java
@Entity
class LogLine {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "log_seq")
    @SequenceGenerator(name = "log_seq", sequenceName = "log_seq",
                       allocationSize = 100)   // 1 sequence call → 100 ids in memory
    private Long id;
}
```

**Bad example:**

```java
@Entity
class LogLine {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "log_seq")
    @SequenceGenerator(name = "log_seq", sequenceName = "log_seq",
                       allocationSize = 1)     // a sequence round-trip on EVERY insert
    private Long id;
}
// Or worse: forcing the legacy hi/lo optimizer, whose ids collide with any other
// process (legacy app, DBA script) writing to the same table.
```

### 3.3 Avoid the TABLE generator for performance-sensitive inserts

Title: Don't use `GenerationType.TABLE`; it emulates a sequence with a separate table guarded by row locks, serializing id generation and hurting concurrency.

Description: The `TABLE` strategy stores the next id in a dedicated table and `SELECT ... FOR UPDATE`s it on each allocation, which becomes a contention point and a separate transaction concern. It exists for databases without sequences and for portability, but it is the slowest option. Prefer `SEQUENCE` (or `IDENTITY` where sequences are unavailable). If you must use `TABLE`, at least set a large `allocationSize`.

**Good example:**

```java
@Entity
class Ticket {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ticket_seq")
    @SequenceGenerator(name = "ticket_seq", sequenceName = "ticket_seq",
                       allocationSize = 50)
    private Long id;                        // fast, non-blocking id allocation
}
```

**Bad example:**

```java
@Entity
class Ticket {
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "ticket_tbl")
    @TableGenerator(name = "ticket_tbl", table = "id_gen", allocationSize = 1)
    private Long id;                        // row-locked id table; serializes inserts
}
```

### 3.4 Choose UUID keys deliberately and prefer time-sorted UUIDs

Title: Use a numeric sequence id by default; reach for UUIDs only when you need client-side or cross-system id generation, and then prefer a time-ordered UUID to avoid index fragmentation.

Description: UUIDs let you assign ids before insert (offline, distributed, no round-trip) and avoid leaking row counts. The cost: 16 bytes vs 8, larger indexes, and — for random UUIDv4 — terrible B-tree locality, because each insert lands in a random index page, fragmenting the clustered index and thrashing the buffer pool. If you need UUIDs, prefer a time-sorted variant (UUIDv7 / Hibernate's `@UuidGenerator(style = TIME)`) so inserts stay append-mostly.

**Good example:**

```java
@Entity
class Document {
    @Id
    @org.hibernate.annotations.UuidGenerator(
            style = org.hibernate.annotations.UuidGenerator.Style.TIME)  // time-sorted
    private UUID id;                        // monotonic-ish → good index locality
}
```

**Bad example:**

```java
@Entity
class Document {
    @Id
    @GeneratedValue                        // random UUIDv4
    private UUID id;
    // Random keys scatter inserts across the index, fragmenting it and
    // inflating page splits — measurably slower writes at scale.
}
```

### 3.5 Implement entity equals()/hashCode() safely

Title: Base `equals`/`hashCode` on a stable business/natural key when one exists; if you must use the generated id, return a constant `hashCode` and guard for the pre-persist null id — never use a mutable auto-generated id naively.

Description: A generated id is `null` until the entity is persisted, so an id-based `hashCode` changes after insert — if the entity was added to a `HashSet` while transient, it becomes unfindable. Bauer/King and Mihalcea both recommend: prefer an immutable natural key (e.g., ISBN, UUID assigned at construction); otherwise use the id in `equals` (null-safe, type-checked) and a *constant* `hashCode` so the hash never changes across the lifecycle. JPwH (Ch 10, "Implementing equals() and hashCode()") adds two non-obvious **proxy-safety** rules that matter whenever entities are compared across persistence contexts: (1) test type with `instanceof`, **never** `getClass()`, because the `other` argument may be a Hibernate-generated proxy subclass whose `getClass()` is *not* your entity class; and (2) read the other object's state through its **getter methods**, not its fields directly, because a proxy's fields are uninitialized until a getter triggers loading. Don't use Lombok `@Data`/`@EqualsAndHashCode` on entities — it includes associations and mutable fields and triggers lazy loading.

**Good example:**

```java
@Entity
class Book {
    @Id @GeneratedValue private Long id;
    @NaturalId @Column(nullable = false, updatable = false) private String isbn; // immutable key

    @Override public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Book other)) return false;
        return isbn != null && isbn.equals(other.isbn);   // stable business key
    }
    @Override public int hashCode() { return isbn != null ? isbn.hashCode() : 31; }
}

// If no natural key exists, use the id null-safely with a CONSTANT hashCode:
@Override public int hashCode() { return getClass().hashCode(); }   // never changes
```

**Bad example:**

```java
@Entity
class Book {
    @Id @GeneratedValue private Long id;

    @Override public boolean equals(Object o) {
        return o instanceof Book b && Objects.equals(id, b.id); // id null before persist
    }
    @Override public int hashCode() { return Objects.hash(id); } // changes after insert!
    // Add a transient Book to a HashSet, persist it, and you can no longer find it.
}
```

### 3.6 Map composite keys with @EmbeddedId and @MapsId

Title: Express a multi-column primary key as an `@Embeddable` id class referenced by `@EmbeddedId`; for keys that include a foreign key, derive it with `@MapsId` instead of duplicating the column.

Description: When the natural key spans columns (e.g., a link table's `(order_id, product_id)`), model it as an immutable `@Embeddable` with proper `equals`/`hashCode` and reference it via `@EmbeddedId`. `@IdClass` is the alternative (separate id class, fields duplicated) but is more error-prone. For an id that *is* (or contains) a foreign key, use `@MapsId` so the association and the key column stay in sync and you don't map the same column twice.

**Good example:**

```java
@Embeddable
class OrderItemId implements Serializable {
    private Long orderId;
    private Long productId;
    // protected ctor, equals/hashCode over both fields, immutable
}

@Entity
class OrderItem {
    @EmbeddedId
    private OrderItemId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("orderId")                     // reuses id.orderId as the FK; no duplicate column
    @JoinColumn(name = "order_id")
    private Order order;
}
```

**Bad example:**

```java
@Entity
@IdClass(OrderItemId.class)
class OrderItem {
    @Id private Long orderId;              // FK column duplicated as a raw scalar
    @Id private Long productId;

    @ManyToOne                             // EAGER by default; maps order_id AGAIN
    @JoinColumn(name = "orderId", insertable = false, updatable = false)
    private Order order;                   // brittle: two mappings for one column
}
```

### 3.7 Expose business keys with @NaturalId

Title: Annotate the immutable business identifier (ISBN, SKU, username) with Hibernate `@NaturalId` to document intent, enable `byNaturalId` lookups, and get an efficient natural-id cache.

Description: Many entities have both a surrogate key (the generated `@Id`, good for joins and FKs) and a natural key (meaningful to the business). `@NaturalId` marks the latter, lets you load by it (`session.byNaturalId(...)`), and — with the second-level cache — caches the natural-id → primary-id resolution so repeated lookups skip the database. Mark it `@NaturalId(mutable = false)` (the default) and non-updatable.

**Good example:**

```java
@Entity
class Product {
    @Id @GeneratedValue private Long id;                 // surrogate key for FKs/joins

    @NaturalId
    @Column(nullable = false, unique = true, updatable = false)
    private String sku;                                  // immutable business key
}

// Efficient, cache-friendly lookup by the business key:
Product p = session.byNaturalId(Product.class).using("sku", sku).load();
```

**Bad example:**

```java
@Entity
class Product {
    @Id @GeneratedValue private Long id;
    @Column private String sku;            // just another column; no intent, no cache
}
// Callers write `where sku = :sku` everywhere, re-hitting the DB even for hot lookups,
// and nothing documents that sku is the stable business identity.
```

## Chapter 4 — Embeddables & Value Types

*Sources: JPwH Ch 5 ("Mapping Value Types" — `@Embeddable` composition, `@AttributeOverride` incl. nested dot-paths, `@Parent` back-pointer, implement `equals`/`hashCode` by value) and Ch 7 (`@ElementCollection`, `@CollectionTable`, Set vs bag vs `@OrderColumn` list semantics); BH6 Ch 6; Cookbook Ch 4 (List/Set/Map/array element collections).*

### 4.1 Model value objects as @Embeddable, not entities

Title: A composite value with no identity of its own (an address, a money amount, a date range) belongs in an `@Embeddable` mapped into the owner's table — not as a separate entity with its own row and lifecycle.

Description: Value types are defined by their attributes, not by an id; they live and die with their owner. Embedding flattens the value's columns into the owner table, so there is no join, no extra primary key, and no separate lifecycle to manage. Reserve `@Entity` for things with independent identity and lifecycle. Embeddables also make the domain model richer (an `Address` type instead of five loose `String`s).

**Good example:**

```java
@Embeddable
class Address {
    @Column(name = "street", nullable = false) private String street;
    @Column(name = "city",   nullable = false) private String city;
    @Column(name = "zip",    nullable = false) private String zip;
    protected Address() { }
    public Address(String street, String city, String zip) { /* ... */ }
}

@Entity
class Customer {
    @Id @GeneratedValue private Long id;
    @Embedded
    private Address address;               // street/city/zip columns in the customer table
}
```

**Bad example:**

```java
@Entity                                    // an Address has no independent identity!
class Address {
    @Id @GeneratedValue private Long id;   // pointless surrogate key
    private String street, city, zip;
}
@Entity
class Customer {
    @Id @GeneratedValue private Long id;
    @OneToOne(cascade = CascadeType.ALL)   // a join + extra row + lifecycle for a value
    private Address address;
}
```

### 4.2 Reuse an embeddable with @AttributeOverride

Title: When an owner needs the same embeddable twice (billing and shipping address), disambiguate the columns with `@AttributeOverride` rather than duplicating the value class.

Description: One embeddable type can map into the same table multiple times; without overrides, both copies would target the same column names and clash. `@AttributeOverride` (and `@AttributeOverrides`) remap each embedded attribute's column per usage, so you keep a single `Address` type and still get distinct `billing_*`/`shipping_*` columns.

**Good example:**

```java
@Entity
class Order {
    @Id @GeneratedValue private Long id;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "street", column = @Column(name = "billing_street")),
        @AttributeOverride(name = "city",   column = @Column(name = "billing_city")),
        @AttributeOverride(name = "zip",    column = @Column(name = "billing_zip"))
    })
    private Address billingAddress;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "street", column = @Column(name = "shipping_street")),
        @AttributeOverride(name = "city",   column = @Column(name = "shipping_city")),
        @AttributeOverride(name = "zip",    column = @Column(name = "shipping_zip"))
    })
    private Address shippingAddress;
}
```

**Bad example:**

```java
@Entity
class Order {
    @Id @GeneratedValue private Long id;
    @Embedded private Address billingAddress;
    @Embedded private Address shippingAddress; // both map street/city/zip → column clash
    // Either fails to start, or you copy-paste a second BillingAddress class to dodge it.
}
```

### 4.3 Use @ElementCollection for value-type collections, with care

Title: Map a collection of value types (tags, phone numbers, embeddables) with `@ElementCollection` to a side table; remember the whole collection is owned by the parent and Hibernate often deletes-and-reinserts it on change.

Description: `@ElementCollection` stores a `Set`/`List` of basics or embeddables in a separate table keyed by the owner's id — no entity, no independent identity. It is the right tool for small, fully-owned value collections. Beware the performance model: modifying a `List`-based element collection can make Hibernate delete all rows and reinsert them. Add `@OrderColumn` for stable list ordering, prefer a `Set` when order doesn't matter, and if the collection is large or independently queried, model it as a child entity instead.

**Good example:**

```java
@Entity
class Contact {
    @Id @GeneratedValue private Long id;

    @ElementCollection
    @CollectionTable(name = "contact_phone",
                     joinColumns = @JoinColumn(name = "contact_id"))
    @Column(name = "phone_number")
    private Set<String> phoneNumbers = new HashSet<>();   // small, owned, unordered
}
```

**Bad example:**

```java
@Entity
class Contact {
    @Id @GeneratedValue private Long id;

    @ElementCollection                     // a LIST with no @OrderColumn
    private List<String> phoneNumbers = new ArrayList<>();
    // Adding one number can trigger DELETE of all rows + bulk re-INSERT.
    // If this list is large or queried on its own, it should be a child entity.
}
```

## Chapter 5 — Entity Relationships

*Sources: HPJP Ch 11 ("Relationships" — `@ManyToOne` is the only association that maps directly to a FK; unidirectional `@OneToMany` emits extra DML; the bidirectional parent-side `@OneToOne` always triggers a secondary SELECT; `@MapsId` for shared-key one-to-one; `@ManyToMany` should become a junction entity with `@EmbeddedId` + two `@ManyToOne @MapsId`); JPwH Ch 7–8 (collections, `mappedBy`, cascade types, `orphanRemoval`, Set/bag/list, `foreign` generator, join-table one-to-one); BH6 Ch 5; Cookbook Ch 5.*

### 5.1 Make @ManyToOne the foundation of every association

Title: Model the "many" side with `@ManyToOne` — it owns the foreign key, generates exactly one FK column, and is the most efficient association in JPA. Build every other relationship around it.

Description: A `@ManyToOne` maps directly to a foreign key column on the child row, which is precisely how relational schemas express relationships. It needs no join table, no extra DML, and updates in one statement. Mihalcea's guidance: prefer `@ManyToOne` (and bidirectional `@OneToMany` built on top of it) and avoid associations that don't map cleanly to a FK. Always set it `LAZY` (5.4) and specify the `@JoinColumn`.

**Good example:**

```java
@Entity
class OrderLine {
    @Id @GeneratedValue private Long id;

    @ManyToOne(fetch = FetchType.LAZY)     // FK column order_id on this row
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;
}
```

**Bad example:**

```java
@Entity
class OrderLine {
    @Id @GeneratedValue private Long id;

    @ManyToOne                             // EAGER by default → joins Order on every load
    private Order order;                   // implicit join column name, nullable FK
}
```

### 5.2 Prefer bidirectional @OneToMany and synchronize both sides

Title: When you need a navigable collection, make it a bidirectional `@OneToMany(mappedBy = ...)` whose owning side is the child's `@ManyToOne`, and provide add/remove helper methods that set both ends.

Description: In a bidirectional association the child's `@ManyToOne` owns the FK; the parent's `@OneToMany(mappedBy="…")` is the inverse, read-only view. This produces clean, single-statement DML. The classic trap: changing only one side. If you `parent.getChildren().add(child)` but never `child.setParent(parent)`, the FK column is never written (or worse, set null). Always mutate the collection through synchronization helpers so the object graph and the database agree.

**Good example:**

```java
@Entity
class Post {
    @Id @GeneratedValue private Long id;

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Comment> comments = new ArrayList<>();

    public void addComment(Comment c) {    // keep BOTH sides in sync
        comments.add(c);
        c.setPost(this);
    }
    public void removeComment(Comment c) {
        comments.remove(c);
        c.setPost(null);
    }
}

@Entity
class Comment {
    @Id @GeneratedValue private Long id;
    @ManyToOne(fetch = FetchType.LAZY)     // owning side: holds post_id FK
    @JoinColumn(name = "post_id")
    private Post post;
    public void setPost(Post p) { this.post = p; }
}
```

**Bad example:**

```java
@Entity
class Post {
    @Id @GeneratedValue private Long id;
    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL)
    private List<Comment> comments = new ArrayList<>();
}
// Caller mutates only the collection; the owning FK is never set:
post.getComments().add(new Comment("nice")); // comment.post == null → FK not written
```

### 5.3 Avoid unidirectional @OneToMany (it emits extra DML)

Title: A unidirectional `@OneToMany` (a parent collection with no `@ManyToOne` on the child) makes Hibernate manage the FK from the wrong side, generating extra `INSERT`/`UPDATE`/`DELETE` statements — convert it to bidirectional, or at least add `@JoinColumn`.

Description: Without a child-owned FK, a plain unidirectional `@OneToMany` defaults to a *join table* (an extra table for a one-to-many!) or, with `@JoinColumn`, to a pattern where Hibernate inserts children first with a null FK and then issues separate `UPDATE`s to set it. Removing a child can delete and reinsert siblings. The fix is almost always the bidirectional mapping of 5.2.

**Good example:**

```java
// Bidirectional: child owns the FK; one INSERT per child, no extra UPDATEs.
@Entity class Post {
    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Comment> comments = new ArrayList<>();
    // + addComment/removeComment helpers (5.2)
}
@Entity class Comment {
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "post_id")
    private Post post;
}
```

**Bad example:**

```java
@Entity class Post {
    @Id @GeneratedValue private Long id;
    @OneToMany(cascade = CascadeType.ALL)  // no mappedBy, no child @ManyToOne
    private List<Comment> comments = new ArrayList<>();
}
// Hibernate creates a post_comment JOIN TABLE for a one-to-many, and persisting
// a Post with N comments emits N inserts + N join-table inserts (+ updates on change).
```

### 5.4 Make every association LAZY

Title: Set `fetch = FetchType.LAZY` on every association — including `@ManyToOne` and `@OneToOne`, which default to `EAGER`. Decide *per query* what to fetch, not globally in the mapping.

Description: EAGER associations are loaded on *every* retrieval of the owner, even when you don't need them, silently adding joins or extra selects and feeding the N+1 problem. LAZY defers loading until accessed, and you opt into fetching exactly where needed via `JOIN FETCH` / entity graphs (Chapter 8). `@OneToMany`/`@ManyToMany` are LAZY by default; the dangerous defaults are `@ManyToOne` and `@OneToOne`, which you must override.

**Good example:**

```java
@Entity
class Invoice {
    @ManyToOne(fetch = FetchType.LAZY)     // override the EAGER default
    private Customer customer;
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    private InvoicePdf pdf;                 // big payload, fetched only when needed
}
// Fetch explicitly where the use case needs it:
em.createQuery("select i from Invoice i join fetch i.customer where i.id = :id", Invoice.class);
```

**Bad example:**

```java
@Entity
class Invoice {
    @ManyToOne private Customer customer;  // EAGER → joined on every Invoice load
    @OneToOne  private InvoicePdf pdf;     // EAGER → big PDF loaded even for a list view
}
// A "select i from Invoice i" list page now also loads every customer and every PDF.
```

### 5.5 Map @OneToOne with a shared primary key via @MapsId

Title: For a true one-to-one (a row that extends another, like `User`↔`UserProfile`), share the primary key with `@MapsId` instead of a separate nullable FK, and make the parent side lazy-safe.

Description: A `@MapsId` `@OneToOne` makes the child's primary key *be* the parent's primary key (same value), so there's no extra FK column and the relationship is enforced by the PK itself. *High-Performance Java Persistence* (Ch 11) explains the subtle trap on the **inverse/parent side** of a bidirectional `@OneToOne` (the `mappedBy` side that does **not** hold the FK): even when you declare it `FetchType.LAZY`, Hibernate *cannot* return a proxy, because it does not know whether a child row exists — it must decide between `null` and an instance — so it always fires a **secondary SELECT** on the parent load, defeating laziness (the only true cure is bytecode enhancement with `@LazyToOne(NO_PROXY)`). The `@MapsId` pattern avoids the whole problem: drive the relationship from the **child (owning) side**, where the child shares and is found by the parent's primary key, so there is no phantom extra select and no nullable FK column.

**Good example:**

```java
@Entity
class User {
    @Id @GeneratedValue private Long id;
    private String username;
}

@Entity
class UserProfile {
    @Id private Long id;                   // same value as the User's id

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId                                // PK == FK == user.id; no extra column
    @JoinColumn(name = "id")
    private User user;
    private String bio;
}
```

**Bad example:**

```java
@Entity
class UserProfile {
    @Id @GeneratedValue private Long id;   // independent PK + a separate FK column

    @OneToOne                              // EAGER, parent side, nullable FK
    private User user;
    // Two columns where one would do; and the EAGER one-to-one triggers an extra
    // secondary SELECT to decide whether to use a proxy or null.
}
```

### 5.6 Replace @ManyToMany with two @OneToMany to a link entity

Title: Model many-to-many relationships as an explicit link entity with two `@ManyToOne`s; reserve raw `@ManyToMany` for the rare case of a pure join table you never add columns to and never modify a large side of.

Description: `@ManyToMany` hides a join table you can't put attributes on (no `addedAt`, no `quantity`), and Hibernate's collection-maintenance for it can delete and reinsert all join rows on a single change — especially with a `List`. Promoting the join table to an entity (`StudentCourse` with `@ManyToOne Student`, `@ManyToOne Course`, plus any extra columns) gives you control, attributes, and efficient single-row DML. When you do keep `@ManyToMany`, use a `Set` and synchronize both sides.

**Good example:**

```java
@Entity
class Enrollment {                         // the join table as a first-class entity
    @EmbeddedId private EnrollmentId id;
    @ManyToOne(fetch = FetchType.LAZY) @MapsId("studentId") private Student student;
    @ManyToOne(fetch = FetchType.LAZY) @MapsId("courseId")  private Course  course;
    private LocalDate enrolledOn;          // attribute the join table can now carry
    private String grade;
}

@Entity class Student {
    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Enrollment> enrollments = new HashSet<>();
}
```

**Bad example:**

```java
@Entity
class Student {
    @Id @GeneratedValue private Long id;

    @ManyToMany                            // EAGER-ish pitfalls + opaque join table
    private List<Course> courses = new ArrayList<>();  // List → delete-all + reinsert on change
}
// You can never store enrolledOn/grade, and removing one course can re-write every join row.
```

### 5.7 Prefer Set over List for mutable collections; know bag semantics

Title: For an association collection you add to and remove from, use a `Set` (no duplicates, no positional semantics); use a `List` only with `@OrderColumn` when order is meaningful — a plain `List` is a "bag" and triggers inefficient collection maintenance.

Description: Hibernate treats an unordered `List` as a *bag*: it cannot identify which element changed, so an add/remove can delete the whole collection and reinsert it. A `Set` is identity-based and supports efficient single-row deletes (especially with `@OneToMany` owned by the child FK). When position matters, an ordered `List` with `@OrderColumn` persists the index, but accept the extra index maintenance. For `@ManyToMany`, a `Set` is strongly preferred for the delete-and-reinsert reasons above.

**Good example:**

```java
@Entity
class Post {
    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Comment> comments = new HashSet<>();   // efficient single-row removes
}
```

**Bad example:**

```java
@Entity
class Post {
    @ManyToMany
    private List<Tag> tags = new ArrayList<>();        // bag semantics on a many-to-many
    // Removing one tag can DELETE every join row for this post and re-INSERT the rest.
}
```

### 5.8 Cascade and orphanRemoval only to children you truly own

Title: Apply `cascade`/`orphanRemoval` only from a parent to lifecycle-dependent children (a composition); never cascade `REMOVE` to a shared reference, and never cascade across aggregate roots.

Description: Cascading propagates lifecycle operations (`persist`, `remove`, `merge`) from parent to child. It is correct for owned children (an `Order` and its `OrderLine`s) and dangerous for shared references: cascading `REMOVE` from `OrderLine` to `Product` would delete the catalog product when a line is removed. `orphanRemoval = true` deletes a child when it leaves the collection — perfect for owned composition, catastrophic if the child is referenced elsewhere. Cascade `@ManyToOne`/`@ManyToMany` references essentially never; cascade `@OneToMany`/`@OneToOne` compositions deliberately.

**Good example:**

```java
@Entity
class Order {                              // aggregate root owns its lines
    @OneToMany(mappedBy = "order",
               cascade = CascadeType.ALL,  // persist/remove lines with the order
               orphanRemoval = true)       // removing a line from the set deletes its row
    private Set<OrderLine> lines = new HashSet<>();
}

@Entity
class OrderLine {
    @ManyToOne(fetch = FetchType.LAZY)     // NO cascade to the shared catalog product
    private Product product;
}
```

**Bad example:**

```java
@Entity
class OrderLine {
    @ManyToOne(cascade = CascadeType.ALL)  // cascading to a SHARED reference!
    private Product product;
}
// em.remove(orderLine) now also deletes the Product from the catalog,
// breaking every other order that references it.
```

## Chapter 6 — Inheritance Mapping

*Sources: JPwH Ch 6 ("Mapping Inheritance" — the four strategies and exactly when to choose each: `TABLE_PER_CLASS`/UNION if polymorphism is needed but columns are mostly optional, `SINGLE_TABLE` for best polymorphic read performance with a `@DiscriminatorColumn`, `JOINED` when subclasses have many non-optional columns, `@MappedSuperclass` for shared mapping without polymorphism; warning that SINGLE_TABLE cannot enforce `NOT NULL` on subclass columns); HPJP inheritance chapter (per-strategy cost analysis); Cookbook Ch 7.*

### 6.1 Prefer SINGLE_TABLE; keep subclass columns nullable

Title: Default to `InheritanceType.SINGLE_TABLE` — all subclasses in one table with a discriminator column. It needs no joins and gives the fastest polymorphic queries; the trade-off is that subclass-specific columns must be nullable.

Description: `SINGLE_TABLE` is the highest-performance strategy: a `SELECT` over the hierarchy hits one table with no joins, inserts/updates touch one row, and the discriminator column says which subtype each row is. The cost is that you can't put `NOT NULL` on a column that only some subclasses use (the other subtypes store null). For most hierarchies that's acceptable; enforce required-by-subtype constraints in the application or with partial/`CHECK` constraints if the database supports them.

**Good example:**

```java
@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "payment_type")
abstract class Payment {
    @Id @GeneratedValue private Long id;
    private BigDecimal amount;
}

@Entity @DiscriminatorValue("CARD")
class CardPayment extends Payment {
    private String last4;                  // nullable for non-card rows — accepted
}

@Entity @DiscriminatorValue("WIRE")
class WirePayment extends Payment {
    private String iban;
}
// "select p from Payment p" → ONE table scan, no joins.
```

**Bad example:**

```java
@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
abstract class Payment {
    @Id @GeneratedValue private Long id;
}
@Entity
class CardPayment extends Payment {
    @Column(nullable = false)              // NOT NULL on a single-table subclass column!
    private String last4;                  // schema generation fails or every WirePayment
                                           // insert violates the constraint
}
```

### 6.2 Use JOINED when you need NOT NULL and a normalized schema

Title: Choose `InheritanceType.JOINED` when subclass columns must be `NOT NULL` or the schema must be normalized — each class gets its own table and polymorphic reads join them; accept the join cost.

Description: `JOINED` stores common fields in a base table and subclass fields in per-subclass tables linked by a shared PK. This lets every column have proper constraints and avoids wide sparse tables, at the cost of a join per subclass on polymorphic queries and an extra insert per level. It's the right call when data integrity (real `NOT NULL`/FK constraints) outweighs raw read speed.

**Good example:**

```java
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
abstract class Account {
    @Id @GeneratedValue private Long id;
    @Column(nullable = false) private String owner;
}

@Entity @Table(name = "checking_account")
class CheckingAccount extends Account {
    @Column(nullable = false) private BigDecimal overdraftLimit;  // real NOT NULL
}

@Entity @Table(name = "savings_account")
class SavingsAccount extends Account {
    @Column(nullable = false) private BigDecimal interestRate;
}
// Reads join account + subclass table; constraints are enforced by the DB.
```

**Bad example:**

```java
// Forcing JOINED when the hierarchy is read-heavy and never needs strict per-column
// NOT NULL: every polymorphic "select a from Account a" pays a multi-table join,
// and inserting a CheckingAccount writes two rows in two tables — slower for no gain.
// (Here SINGLE_TABLE would have been the better default.)
```

### 6.3 Avoid TABLE_PER_CLASS (polymorphic queries UNION every table)

Title: Avoid `InheritanceType.TABLE_PER_CLASS`: each concrete class is a standalone table with duplicated base columns, so a query against the base type `UNION ALL`s every subclass table and the strategy can't use `IDENTITY` ids.

Description: With table-per-class there's no shared base table, so `select a from Account a` becomes a `UNION ALL` across all concrete tables — slow and unindexable as the hierarchy grows. Foreign keys *to* the base type are impossible (no single table to reference), and the `IDENTITY` generator can't be used because ids must be unique across the union. Reserve it for hierarchies that are essentially never queried polymorphically; otherwise prefer `SINGLE_TABLE` (6.1) or `JOINED` (6.2).

**Good example:**

```java
// Prefer SINGLE_TABLE (or JOINED) so polymorphic queries hit one table (or a join),
// not a UNION across every concrete table.
@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
abstract class Vehicle { @Id @GeneratedValue private Long id; }
```

**Bad example:**

```java
@Entity
@Inheritance(strategy = InheritanceType.TABLE_PER_CLASS)
abstract class Vehicle {
    @Id @GeneratedValue(strategy = GenerationType.TABLE)  // IDENTITY unavailable here
    private Long id;
}
@Entity class Car extends Vehicle { }
@Entity class Truck extends Vehicle { }
// "select v from Vehicle v" → SELECT ... FROM car UNION ALL SELECT ... FROM truck ...
// and you cannot have a @ManyToOne Vehicle FK pointing at a single base table.
```

### 6.4 Use @MappedSuperclass for shared state without polymorphism

Title: When subclasses share columns/fields but you never query them polymorphically, use `@MappedSuperclass` (not `@Inheritance`) so each entity gets its own complete table with the inherited columns and no discriminator or union machinery.

Description: `@MappedSuperclass` is not an entity — it contributes mappings (id, audit columns, `@Version`) to each subclass's own table without creating an inheritance relationship in the database. You cannot write `select b from BaseEntity b` (it isn't an entity), and there's no polymorphic association to it — which is exactly right when the base is just reusable mapping, like a common `AbstractAuditable` with `createdAt`/`updatedAt`/`version`.

**Good example:**

```java
@MappedSuperclass
abstract class AbstractAuditable {
    @Id @GeneratedValue private Long id;
    @CreationTimestamp private Instant createdAt;
    @UpdateTimestamp  private Instant updatedAt;
    @Version private long version;
}

@Entity                                    // own table: product(id, created_at, ..., name)
class Product extends AbstractAuditable { private String name; }
@Entity                                    // own table: customer(id, created_at, ..., email)
class Customer extends AbstractAuditable { private String email; }
// No discriminator, no union, no polymorphic query — just shared mapping reuse.
```

**Bad example:**

```java
@Entity                                    // making the shared base a real @Entity...
@Inheritance(strategy = InheritanceType.TABLE_PER_CLASS)
abstract class AbstractAuditable {
    @Id @GeneratedValue private Long id;
    @Version private long version;
}
@Entity class Product  extends AbstractAuditable { private String name; }
@Entity class Customer extends AbstractAuditable { private String email; }
// Now "select a from AbstractAuditable a" unions product + customer — a meaningless,
// expensive query you never wanted, just to reuse a couple of columns.
```

## Chapter 7 — Persistence Context & Entity Lifecycle

*Sources: JPwH Ch 10 ("Managing Data" — the four states transient/persistent/removed/detached; `persist`/`find`/`getReference`/`merge`/`remove`/`refresh` semantics; `merge()` returns a new managed instance and leaves the argument detached; the context never shrinks → flush/clear in loops; after any EM exception the context is corrupt and must be discarded) and Ch 12 (`em.getReference()` returns a proxy with no SELECT — ideal for FK-only linking); BH6 Ch 4, 8 (`get` vs `load`, `evict`/`clear`, flush modes); Cookbook Ch 2.*

### 7.1 Know the four entity states and the transitions

Title: Master the entity lifecycle — *transient* (new), *managed/persistent* (tracked by the persistence context), *detached* (was managed, context closed), *removed* (scheduled for delete) — because every persistence bug is a state confusion.

Description: A *transient* object is a plain Java object Hibernate knows nothing about. `persist()` makes it *managed*: it joins the persistence context (the first-level cache / identity map), gets an id, and is dirty-checked. When the context closes (transaction ends), managed entities become *detached* — still in memory, no longer tracked, so changes are not flushed. `remove()` schedules a *removed* entity for deletion. `merge()` copies a detached entity's state onto a managed instance. Knowing which state you hold tells you exactly what `setX()` will (or won't) persist.

**Good example:**

```java
@Transactional
public Long createBook(String title) {
    Book book = new Book(title);     // TRANSIENT — not tracked, no id
    em.persist(book);                // → MANAGED — tracked, id assigned, dirty-checked
    book.setTitle(title.trim());     // change auto-flushed at commit (no save() needed)
    return book.getId();
}                                    // tx ends → book becomes DETACHED
```

**Bad example:**

```java
public Long createBook(String title) {   // no transaction / context
    Book book = new Book(title);          // TRANSIENT
    em.persist(book);                     // persist outside a tx → nothing flushed
    book.setTitle("changed");             // change is on a soon-detached object
    return book.getId();                  // id may be null; no INSERT ever ran
}
```

### 7.2 Use the right state-transition method (persist vs merge)

Title: Call `persist()` on transient (new) entities and `merge()` on detached ones; don't `merge()` a brand-new entity to "save" it, and don't `persist()` a detached entity.

Description: `persist()` is for new entities — it makes the passed instance managed. `merge()` is for detached entities coming back from outside the context (e.g., from a web request): it returns a *new managed copy* with the detached state applied, and the original argument stays detached. Using `merge()` to insert new entities works but issues an extra `SELECT` and can mis-handle generated ids; using `persist()` on a detached entity throws. In Spring Data, `repository.save()` chooses for you based on whether the id is set — understand which path it takes.

**Good example:**

```java
@Transactional
public Book update(BookDto dto) {
    Book detached = new Book(dto.id(), dto.title());   // reconstructed, detached
    Book managed = em.merge(detached);                 // returns a MANAGED copy
    managed.setTitle(dto.title());                      // mutate the returned instance
    return managed;                                     // NOT 'detached'
}

@Transactional
public void create(Book newBook) {                      // newBook is transient (id null)
    em.persist(newBook);                                // correct path for inserts
}
```

**Bad example:**

```java
@Transactional
public void create(Book newBook) {       // transient
    Book managed = em.merge(newBook);    // works, but runs a needless SELECT first
    // ...and callers keep mutating `newBook`, which is still detached → lost updates
}

@Transactional
public void update(Book detached) {
    em.persist(detached);                // throws PersistenceException for a detached entity
}
```

### 7.3 Trust automatic dirty checking; drop redundant save/update calls

Title: A managed entity's field changes are detected and flushed automatically at commit — you do not need to call `save()`/`update()`/`merge()` after mutating a managed entity. Redundant "save" calls add noise and sometimes extra queries.

Description: Hibernate snapshots managed entities and, at flush time, compares current state to the snapshot, generating `UPDATE`s only for changed entities (and only changed columns with dynamic update). Calling `repository.save(managedEntity)` after a setter is unnecessary; on a managed instance it's a no-op-ish round-trip, and on a detached one it's a `merge` you may not intend. Load → mutate → let the transaction flush.

**Good example:**

```java
@Transactional
public void rename(Long id, String newName) {
    Product p = em.find(Product.class, id);   // MANAGED
    p.setName(newName);                        // dirty-checked
}                                              // UPDATE flushed at commit — done
```

**Bad example:**

```java
@Transactional
public void rename(Long id, String newName) {
    Product p = productRepository.findById(id).orElseThrow();  // MANAGED
    p.setName(newName);
    productRepository.save(p);                  // redundant: p is already managed
}
```

### 7.4 Keep the persistence context small; flush()+clear() in long loops

Title: The persistence context holds a reference to every entity it manages; processing thousands of entities in one transaction bloats memory and slows dirty checking. Periodically `flush()` then `clear()` to detach the processed batch.

Description: Because the context is an identity map, a loop that persists 100k entities keeps all 100k in memory and re-scans all of them on every flush — quadratic-ish cost and eventual `OutOfMemoryError`. Flushing pushes pending DML to the database; clearing detaches everything so it can be garbage-collected. Combine with JDBC batching (Chapter 11) and a batch size that matches `hibernate.jdbc.batch_size`. For pure inserts/reads, also consider `StatelessSession` (13.3).

**Good example:**

```java
@Transactional
public void importRows(List<Row> rows) {
    int batch = 50;                            // == hibernate.jdbc.batch_size
    for (int i = 0; i < rows.size(); i++) {
        em.persist(new Record(rows.get(i)));
        if (i > 0 && i % batch == 0) {
            em.flush();                        // push the batch to the DB
            em.clear();                        // detach it → free memory
        }
    }
}
```

**Bad example:**

```java
@Transactional
public void importRows(List<Row> rows) {
    for (Row r : rows) {
        em.persist(new Record(r));             // 100k managed entities pile up
    }                                          // single huge flush; dirty checking thrashes;
}                                              // memory grows until OOM
```

### 7.5 Understand flush modes and operation ordering

Title: Know that Hibernate flushes automatically before queries and at commit (FlushModeType.AUTO), reorders DML for batching/constraints, and may run statements in an order different from your code — don't depend on call order for correctness.

Description: With the default `AUTO` flush mode, Hibernate flushes pending changes before executing a query that might be affected, and always at commit. At flush time it orders operations by type (inserts, then updates, then deletes) and by dependency, partly to enable batching (`order_inserts`/`order_updates`) and to satisfy FK constraints. So the SQL order won't match your Java order. Avoid `FlushModeType.COMMIT` unless you understand the read-your-writes implications, and never rely on a manual `flush()` for business logic — use it only for batching control or to surface constraint errors early.

**Good example:**

```java
@Transactional
public void transfer(Long fromId, Long toId, BigDecimal amount) {
    Account from = em.find(Account.class, fromId);
    Account to   = em.find(Account.class, toId);
    from.withdraw(amount);                     // dirty
    to.deposit(amount);                        // dirty
    // No manual flush; Hibernate flushes both UPDATEs atomically at commit,
    // ordering them for batching/constraints. Correctness doesn't depend on order.
}
```

**Bad example:**

```java
@Transactional
public void process(Order o) {
    em.persist(o.firstLine());
    em.flush();                                // manual flush to "force order"
    em.persist(o.secondLine());
    // Relying on flush() to control statement order is brittle: Hibernate may still
    // reorder within a flush, and the extra flush defeats insert batching.
}
```

### 7.6 Cross the service boundary with DTOs, not managed entities

Title: Return DTOs (or projections) from `@Transactional` service methods; don't hand managed/lazy entities to a controller or view that runs after the persistence context has closed (the classic `LazyInitializationException`).

Description: A managed entity becomes detached when the transaction ends. If the web/view layer then touches a lazy association, Hibernate has no open session to load it — `LazyInitializationException`. Patterns like Open-Session-In-View paper over this but cause N+1 in the view and blur transaction boundaries. The robust fix: inside the transaction, project exactly the data the caller needs into a DTO (or fetch the needed graph explicitly), and return that. The view then works on plain data with no persistence coupling.

**Good example:**

```java
public record OrderSummary(Long id, String customerName, int lineCount) { }

@Transactional(readOnly = true)
public OrderSummary getSummary(Long id) {
    return em.createQuery("""
            select new com.app.OrderSummary(o.id, o.customer.name, size(o.lines))
            from Order o where o.id = :id
            """, OrderSummary.class)
            .setParameter("id", id)
            .getSingleResult();                // plain data, no lazy proxies escape
}
```

**Bad example:**

```java
@Transactional(readOnly = true)
public Order getOrder(Long id) {
    return em.find(Order.class, id);           // returns a MANAGED entity...
}
// ...the controller later calls order.getLines().size() AFTER the tx closed:
//   org.hibernate.LazyInitializationException: could not initialize proxy - no Session
```

## Chapter 8 — Fetching & the N+1 Problem

*Sources: HPJP fetching chapter (the N+1 and Cartesian-product problems; why collection `JOIN FETCH` + pagination forces in-memory paging; DTO projections for reads); JPwH Ch 12 ("Fetch Plans, Strategies, and Profiles" — lazy-by-default plan, `em.getReference()` for FK-only links, `@LazyCollection(EXTRA)` for `size()`/`contains()` without loading, batch/subselect fetching, entity graphs and fetch profiles); BH6 Ch 11 (don't return lazy entities past the open session — use DTOs).*

### 8.1 Kill the N+1 select problem with JOIN FETCH / entity graphs

Title: When a use case iterates a collection or association across many parents, fetch the association *in the query* with `JOIN FETCH` or an `@EntityGraph` — don't let lazy loading fire one extra `SELECT` per parent (1 + N queries).

Description: The N+1 problem: you run one query for N parents, then accessing a lazy association on each parent triggers N additional queries. It's the single most common Hibernate performance bug, and it's invisible unless you watch the SQL log. The fix is to declare the fetch for the specific use case: `JOIN FETCH` in JPQL, an `@EntityGraph` (JPA standard, reusable, works with Spring Data repositories), or — for collections — batch/subselect fetching (8.3). Keep the mapping LAZY (5.4) and fetch per query.

**Good example:**

```java
// One query loads posts AND their comments together.
List<Post> posts = em.createQuery("""
        select distinct p from Post p
        left join fetch p.comments
        where p.published = true
        """, Post.class).getResultList();

// Or, declaratively, with a JPA entity graph (great with Spring Data):
@EntityGraph(attributePaths = "comments")
List<Post> findByPublishedTrue();
```

**Bad example:**

```java
List<Post> posts = em.createQuery(
        "select p from Post p where p.published = true", Post.class).getResultList();
for (Post p : posts) {
    p.getComments().size();   // each iteration fires: select * from comment where post_id=?
}
// 1 query for posts + N queries for comments = N+1. The log shows it; the Java doesn't.
```

### 8.2 Never paginate an entity query that JOIN FETCHes a collection

Title: Combining `JOIN FETCH` of a *collection* with `setFirstResult/setMaxResults` forces Hibernate to fetch the entire joined result into memory and paginate in Java (with a warning) — paginate the parent ids first, or fetch the collection in a second query.

Description: A collection `JOIN FETCH` multiplies rows (one row per parent×child), so the database `LIMIT` can't express "N parents." Hibernate detects this, pulls *all* matching rows, and applies the limit in memory — `HHH000104: firstResult/maxResults specified with collection fetch; applying in memory` — which can load millions of rows for "page 1." The correct patterns: (a) paginate parent ids with a normal query, then load that page's entities with a `JOIN FETCH ... where id in (:ids)`; or (b) page the parents lazily and use `@BatchSize`/subselect (8.3) for the collection.

**Good example:**

```java
// 1) Page the parent IDs (DB does real LIMIT/OFFSET, no row multiplication):
List<Long> ids = em.createQuery(
        "select p.id from Post p order by p.createdAt desc", Long.class)
        .setFirstResult(0).setMaxResults(20).getResultList();

// 2) Fetch exactly those parents WITH their collection in one query:
List<Post> page = em.createQuery("""
        select distinct p from Post p
        left join fetch p.comments
        where p.id in :ids order by p.createdAt desc
        """, Post.class).setParameter("ids", ids).getResultList();
```

**Bad example:**

```java
List<Post> page = em.createQuery("""
        select distinct p from Post p left join fetch p.comments
        order by p.createdAt desc
        """, Post.class)
        .setFirstResult(0).setMaxResults(20)   // HHH000104: pagination done IN MEMORY
        .getResultList();
// Hibernate loads every post×comment row, then keeps 20 — huge fetch for "page 1".
```

### 8.3 Batch-initialize collections with @BatchSize or subselect fetch

Title: When you must initialize lazy collections on many parents (and a `JOIN FETCH` is unsuitable, e.g., because of pagination), use `@BatchSize` or `@Fetch(SUBSELECT)` to load them in a few `IN (...)`/subselect queries instead of N.

Description: `@BatchSize(size = n)` makes Hibernate initialize lazy proxies in batches of `n` using `where post_id in (?, ?, …)`, turning N collection loads into N/n queries. `@Fetch(FetchMode.SUBSELECT)` loads all the collections for the original query's parents with one subselect (`where post_id in (select id from post where …)`). Both keep pagination correct (no row multiplication) while collapsing the N+1 into a small constant number of queries. Choose `@BatchSize` for general use, `SUBSELECT` when the parent query is reused. Separately, JPwH Ch 12 describes `@LazyCollection(LazyCollectionOption.EXTRA)`: it lets `size()`, `isEmpty()`, `contains()`, and `get(index)` run a targeted `SELECT COUNT`/existence query **without** initializing the whole collection — valuable when you only need the count of a large collection. (Note `@LazyCollection` is deprecated in newer Hibernate; prefer querying the count via JPQL/DTO, but the technique and its intent remain instructive.)

**Good example:**

```java
@Entity
class Post {
    @OneToMany(mappedBy = "post")
    @org.hibernate.annotations.BatchSize(size = 25)   // load comments 25 parents at a time
    private Set<Comment> comments = new HashSet<>();
}
// Iterating 100 posts' comments → ~4 queries (100/25), not 100. Pagination still correct.
```

**Bad example:**

```java
@Entity
class Post {
    @OneToMany(mappedBy = "post")          // plain lazy, no batching hint
    private Set<Comment> comments = new HashSet<>();
}
// for (Post p : pageOf100) p.getComments().size(); → 100 separate SELECTs (N+1),
// and you can't JOIN FETCH because the page used setMaxResults (8.2).
```

### 8.4 Fetch only what you need with DTO projections

Title: For read-only screens and APIs, query a DTO/projection with exactly the columns required — don't load full entity graphs (with all their columns, associations, and dirty-checking overhead) just to read three fields.

Description: Loading entities for reads pays for the persistence context (identity map, dirty-check snapshots), every mapped column, and lazy-proxy machinery. A `select new Dto(...)` (JPQL constructor expression), a Spring Data interface/record projection, or a Criteria/`@SqlResultSetMapping` query fetches only the needed scalars — smaller result sets, no entity overhead, no accidental N+1, and the result is detached plain data by construction. Reserve entity loading for write use cases that mutate state.

**Good example:**

```java
public record CustomerCard(Long id, String name, String email) { }

@Transactional(readOnly = true)
public List<CustomerCard> directory() {
    return em.createQuery("""
            select new com.app.CustomerCard(c.id, c.name, c.email)
            from Customer c order by c.name
            """, CustomerCard.class).getResultList();   // 3 columns, no entity overhead
}

// Spring Data projection equivalent:
interface CustomerCardView { Long getId(); String getName(); String getEmail(); }
List<CustomerCardView> findAllBy();
```

**Bad example:**

```java
@Transactional(readOnly = true)
public List<CustomerCard> directory() {
    return em.createQuery("select c from Customer c order by c.name", Customer.class)
            .getResultList().stream()
            .map(c -> new CustomerCard(c.getId(), c.getName(), c.getEmail()))
            .toList();
    // Loads every column of every Customer, builds dirty-check snapshots, risks N+1
    // on any lazy field someone later touches — all to read three fields.
}
```

### 8.5 Avoid the Cartesian product of fetching two collections at once

Title: Do not `JOIN FETCH` two (or more) sibling collections in one query — the result is a Cartesian product (rows = children₁ × children₂), exploding the row count and corrupting the in-memory collections. Fetch one collection per query.

Description: Each collection `JOIN FETCH` multiplies rows; fetching `post.comments` *and* `post.tags` together yields `comments × tags` duplicate rows per post, wasting bandwidth and (with `List`s) duplicating elements. Hibernate even throws `MultipleBagFetchException` for two `List`s. Solutions: fetch the most important collection with `JOIN FETCH` and the others with `@BatchSize`/subselect (8.3), or split into separate queries against the same parents. Use `Set` collections to avoid duplicate elements either way.

**Good example:**

```java
// Fetch ONE collection per query against the same parents:
List<Post> posts = em.createQuery("""
        select distinct p from Post p left join fetch p.comments where p.id in :ids
        """, Post.class).setParameter("ids", ids).getResultList();

// Second collection via @BatchSize/subselect — no Cartesian product:
posts.forEach(p -> p.getTags().size());   // @BatchSize(25) on tags → a couple of IN queries
```

**Bad example:**

```java
List<Post> posts = em.createQuery("""
        select distinct p from Post p
        left join fetch p.comments
        left join fetch p.tags            // two collection fetches → Cartesian product
        """, Post.class).getResultList();
// rows = comments × tags per post (and MultipleBagFetchException if both are List bags).
```

### 8.6 Use read-only fetches for reporting

Title: For queries you only read from, mark them read-only (`setHint(HINT_READ_ONLY, true)` / `@Transactional(readOnly = true)` / Spring Data read-only) so Hibernate skips dirty-check snapshots and the result entities use less memory.

Description: By default Hibernate keeps a hydrated-state snapshot of every loaded entity for dirty checking — pure overhead when you never modify them. A read-only query (or read-only session/transaction) tells Hibernate not to take snapshots and not to flush these entities, cutting memory and CPU for large reads. Combine with DTO projections (8.4) for the leanest reads; use read-only entity fetches when you still want managed entities but won't mutate them.

**Good example:**

```java
@Transactional(readOnly = true)
public List<Account> activeAccounts() {
    return em.createQuery("select a from Account a where a.active = true", Account.class)
            .setHint(org.hibernate.jpa.QueryHints.HINT_READONLY, true)  // no dirty snapshots
            .getResultList();
}
```

**Bad example:**

```java
@Transactional
public List<Account> activeAccounts() {
    return em.createQuery("select a from Account a where a.active = true", Account.class)
            .getResultList();
    // Read-write tx + default fetch: Hibernate snapshots every account for dirty checking
    // and may flush on the way out — overhead for data you only display.
}
```

## Chapter 9 — Queries: JPQL, Criteria & Native SQL

*Sources: JPwH Ch 14–17 (creating queries, JPQL/HQL, the Criteria API, customizing SQL — `@SqlResultSetMapping`, `@NamedQuery`/`@NamedNativeQuery`, bulk `UPDATE`/`DELETE`, `INSERT … SELECT`, scrolling, keyset pagination); BH6 Ch 9 ("Searches and Queries" — HQL's optional SELECT, typed queries, `setFirstResult`/`setMaxResults`, DTO constructor projections, always use named parameters); Cookbook Ch 6 (Criteria/`Restrictions`/`Projections`/`DetachedCriteria` subqueries — note legacy Criteria is deprecated, prefer JPA `CriteriaQuery` — native SQL with `addScalar`/`addEntity`, `@Formula`, `@NamedQuery`).*

### 9.1 Always bind parameters; never concatenate query input

Title: Pass user/runtime values as bind parameters (`:name` / `?1`), never by string-concatenating them into the query — concatenation is a SQL-injection vulnerability and defeats statement caching.

Description: Bind parameters separate the query *text* from its *values*. This makes the query immune to injection (the value can never change the parsed statement) and lets the database and driver reuse one cached execution plan / `PreparedStatement` across calls (Chapter 11). Concatenation produces a unique query string per value — unsafe and un-cacheable. This applies equally to JPQL, HQL, native SQL, and the Criteria API.

**Good example:**

```java
List<User> users = em.createQuery(
        "select u from User u where u.email = :email and u.active = :active", User.class)
    .setParameter("email", email)        // bound — safe and plan-cacheable
    .setParameter("active", true)
    .getResultList();

// Native SQL: bind there too.
em.createNativeQuery("select * from app_user where email = ?1", User.class)
    .setParameter(1, email);
```

**Bad example:**

```java
List<User> users = em.createQuery(
        "select u from User u where u.email = '" + email + "'", User.class)  // INJECTION
    .getResultList();
// email = "x' or '1'='1" leaks every row; and every distinct email yields a new
// query string the DB must re-parse and re-plan.
```

### 9.2 Externalize and pre-validate static queries (named queries)

Title: Define static JPQL/HQL as `@NamedQuery` (or named native queries) so Hibernate validates them at startup and parses them once, rather than scattering string literals across the codebase that fail only at runtime.

Description: A `@NamedQuery` is compiled/validated when the persistence unit boots — a typo or invalid path fails fast at startup, not on the first user request in production. It's also parsed once and reused. Keep dynamic queries in the Criteria API (9.3); keep stable queries as named queries (or Spring Data derived/`@Query` methods, which are likewise validated and centralized). This improves both safety and discoverability.

**Good example:**

```java
@Entity
@NamedQuery(name = "Book.byIsbn",
            query = "select b from Book b where b.isbn = :isbn")
class Book { /* ... */ }

Book book = em.createNamedQuery("Book.byIsbn", Book.class)
              .setParameter("isbn", isbn)
              .getSingleResult();

// Spring Data equivalent — validated, centralized:
interface BookRepository extends JpaRepository<Book, Long> {
    @Query("select b from Book b where b.isbn = :isbn")
    Optional<Book> findByIsbn(String isbn);
}
```

**Bad example:**

```java
// The same query text re-typed inline at dozens of call sites; a typo in any one
// is only discovered when that path runs in production.
Book book = em.createQuery(
        "select b from Book b wher b.isbn = :isbn", Book.class)   // 'wher' typo
        .setParameter("isbn", isbn)
        .getSingleResult();
```

### 9.3 Build dynamic queries with the Criteria API, not strings

Title: For queries whose shape varies at runtime (optional filters, dynamic sorting), use the type-safe Criteria API instead of concatenating JPQL fragments — it's injection-safe, refactor-safe, and composes optional predicates cleanly.

Description: Dynamic JPQL built by string concatenation is fragile (spacing, `and`/`where` placement), unsafe (injection if values leak in), and breaks silently when fields are renamed. The Criteria API builds the query from typed objects, so optional predicates are just conditional `add`s to a list, parameters are bound automatically, and a renamed field is a compile error (with the static metamodel). Use it for search forms and report builders; keep simple static queries as named queries (9.2).

**Good example:**

```java
CriteriaBuilder cb = em.getCriteriaBuilder();
CriteriaQuery<Book> cq = cb.createQuery(Book.class);
Root<Book> book = cq.from(Book.class);

List<Predicate> where = new ArrayList<>();
if (title != null)  where.add(cb.like(book.get("title"), "%" + "%"));   // value bound by JPA
if (author != null) where.add(cb.equal(book.get("author"), author));
cq.select(book).where(where.toArray(Predicate[]::new));

List<Book> result = em.createQuery(cq).getResultList();   // type-safe, injection-safe
```

**Bad example:**

```java
StringBuilder jpql = new StringBuilder("select b from Book b where 1=1");
if (title != null)  jpql.append(" and b.title like '%").append(title).append("%'"); // injection
if (author != null) jpql.append(" and b.author = '").append(author).append("'");
List<Book> result = em.createQuery(jpql.toString(), Book.class).getResultList();
// Unsafe, un-cacheable (new string each time), and a field rename compiles fine but
// blows up at runtime.
```

### 9.4 Drop to native SQL when needed and map results explicitly

Title: When JPQL can't express it (window functions, CTEs, vendor features, complex reporting), use a native query — but map the result with `@SqlResultSetMapping` / a result class rather than juggling raw `Object[]`.

Description: JPQL is intentionally a subset of SQL; native queries unlock the full database. The risk is loose typing: a native query returning `Object[]` forces positional casts that break when the `SELECT` list changes. Define a `@SqlResultSetMapping` (to entities and/or scalars) or a constructor/record mapping so results are strongly typed and self-documenting. Still bind parameters (9.1). For heavy, type-safe native querying, a builder like jOOQ is worth considering (per *High-Performance Java Persistence*).

**Good example:**

```java
@SqlResultSetMapping(name = "TopSellerMapping",
    classes = @ConstructorResult(targetClass = TopSeller.class, columns = {
        @ColumnResult(name = "product_id", type = Long.class),
        @ColumnResult(name = "units",      type = Long.class)
    }))
@Entity class Sale { /* ... */ }

public record TopSeller(Long productId, Long units) { }

List<TopSeller> top = em.createNativeQuery("""
        select product_id, sum(quantity) as units
        from sale where sold_on >= ?1
        group by product_id order by units desc fetch first 10 rows only
        """, "TopSellerMapping")
    .setParameter(1, since)
    .getResultList();
```

**Bad example:**

```java
List<Object[]> rows = em.createNativeQuery(
        "select product_id, sum(quantity) from sale group by product_id")
    .getResultList();
for (Object[] r : rows) {
    Long id = ((Number) r[0]).longValue();      // positional, untyped casts
    Long units = ((Number) r[1]).longValue();   // reorder the SELECT → silent breakage
}
```

### 9.5 Use bulk JPQL for set-based writes — minding the cache

Title: To change or delete many rows by a predicate, run a single bulk JPQL `UPDATE`/`DELETE` instead of loading entities and mutating them one by one — but remember bulk DML bypasses the persistence context and second-level cache, so clear/evict afterward.

Description: Loading 100k rows to flip a flag means 100k snapshots and 100k `UPDATE`s; a bulk `update Foo f set f.flag = true where …` does it in one statement. The catch (also why it needs care): bulk operations run directly against the database and do **not** update managed entities already in the persistence context or invalidate the second-level cache, so stale copies can linger. Run bulk DML early in the transaction, or `em.clear()` and evict affected cache regions, and never mix it carelessly with entities you've already loaded.

**Good example:**

```java
@Transactional
public int archiveOldOrders(LocalDate cutoff) {
    int updated = em.createQuery(
            "update Order o set o.status = :s where o.createdOn < :cutoff")
        .setParameter("s", Status.ARCHIVED)
        .setParameter("cutoff", cutoff)
        .executeUpdate();                  // one set-based UPDATE
    em.clear();                            // drop now-stale managed copies
    return updated;
}
```

**Bad example:**

```java
@Transactional
public void archiveOldOrders(LocalDate cutoff) {
    em.createQuery("select o from Order o where o.createdOn < :cutoff", Order.class)
        .setParameter("cutoff", cutoff)
        .getResultList()
        .forEach(o -> o.setStatus(Status.ARCHIVED));  // N entities, N snapshots, N UPDATEs
    // Loads potentially millions of rows just to issue per-row updates.
}
```

### 9.6 Stream or scroll large result sets; paginate with keyset

Title: Don't materialize a huge result into a `List` (it loads every row into memory at once); stream/scroll it, and for deep pagination prefer keyset (seek) pagination over `OFFSET`, which scans and discards skipped rows.

Description: `getResultList()` buffers the whole result; for large exports use `getResultStream()` (or Hibernate `ScrollableResults`) with an appropriate fetch size (11.4) so rows are processed incrementally, plus `flush()`/`clear()` if you also write. For pagination, `OFFSET n` makes the database read and throw away `n` rows — fine for early pages, painful for deep ones. Keyset pagination (`where (created_on, id) < (:lastCreated, :lastId) order by … limit k`) seeks directly to the next page using the last row's key, staying fast at any depth.

**Good example:**

```java
// Stream a large export incrementally instead of buffering all rows:
try (Stream<Invoice> stream = em.createQuery(
        "select i from Invoice i where i.year = :y", Invoice.class)
        .setParameter("y", year)
        .setHint(org.hibernate.jpa.QueryHints.HINT_FETCH_SIZE, 200)
        .getResultStream()) {
    stream.forEach(this::writeToCsv);
}

// Keyset pagination — fast at any depth:
em.createQuery("""
        select o from Order o
        where (o.createdOn, o.id) < (:lastCreated, :lastId)
        order by o.createdOn desc, o.id desc
        """, Order.class)
    .setParameter("lastCreated", lastCreated).setParameter("lastId", lastId)
    .setMaxResults(20).getResultList();
```

**Bad example:**

```java
// Buffer a million rows into memory:
List<Invoice> all = em.createQuery(
        "select i from Invoice i where i.year = :y", Invoice.class)
    .setParameter("y", year).getResultList();   // OutOfMemoryError waiting to happen

// Deep OFFSET pagination re-scans everything before the page:
em.createQuery("select o from Order o order by o.createdOn desc", Order.class)
    .setFirstResult(100_000).setMaxResults(20)  // DB reads 100,020 rows to return 20
    .getResultList();
```

## Chapter 10 — Transactions & Concurrency Control

*Sources: HPJP Ch 7 ("Transactions" — ACID, the read phenomena, and the fact that each database ships a different default isolation level: Oracle and PostgreSQL default to READ COMMITTED, MySQL/InnoDB to REPEATABLE READ, SQL Server to READ COMMITTED; higher isolation alone does not stop the application-level lost update across think-time); JPwH Ch 11 ("Transactions and Concurrency" — `@Version` numeric counters preferred over timestamps; `LockModeType.OPTIMISTIC`, `OPTIMISTIC_FORCE_INCREMENT` to version-bump an aggregate root when a child changes, `PESSIMISTIC_READ`/`WRITE`/`FORCE_INCREMENT`; `jakarta.persistence.lock.timeout`; `LockTimeoutException` is recoverable, most others are fatal); BH6 Ch 8; Cookbook Ch 7 (`@Version`).*

### 10.1 Wrap each unit of work in an explicit transaction boundary

Title: Run every persistence operation inside a clear transaction (declarative `@Transactional` at the service layer, or explicit `begin/commit/rollback`); never rely on auto-commit-per-statement, which splits a logical unit of work into many uncoordinated transactions.

Description: A unit of work must be atomic — all of it commits or none of it does. Declarative `@Transactional` on a service method opens one transaction for the whole method, so a failure rolls back every change; it also defines the persistence-context lifetime that lazy loading and dirty checking depend on (7.6). Auto-commit (no explicit transaction) commits each statement separately, so a multi-step operation can half-complete and corrupt data. Keep boundaries at the use-case (service) layer, not in repositories or controllers, and keep them short.

**Good example:**

```java
@Service
class TransferService {
    @Transactional                          // one atomic unit of work
    public void transfer(Long fromId, Long toId, BigDecimal amount) {
        Account from = repo.findById(fromId).orElseThrow();
        Account to   = repo.findById(toId).orElseThrow();
        from.withdraw(amount);
        to.deposit(amount);
    }                                        // both UPDATEs commit together, or both roll back
}
```

**Bad example:**

```java
class TransferService {
    public void transfer(Long fromId, Long toId, BigDecimal amount) {  // no @Transactional
        accountRepo.decrement(fromId, amount);   // commits immediately (auto-commit)
        if (somethingFails()) throw new IllegalStateException();
        accountRepo.increment(toId, amount);     // never runs → money vanished
    }
}
```

### 10.2 Choose the isolation level for the anomalies you must prevent

Title: Understand the read phenomena (dirty read, non-repeatable read, phantom read) and the lost-update/write-skew anomalies, then pick the lowest isolation level that prevents the ones your use case cannot tolerate — don't blindly raise it to SERIALIZABLE.

Description: Isolation trades correctness for concurrency. *Read Committed* prevents dirty reads but allows non-repeatable and phantom reads. *Repeatable Read* additionally stabilizes rows you've read (but, depending on the engine, may still allow phantoms or write skew). *Serializable* prevents all of them but serializes conflicting transactions, hurting throughput and risking more deadlocks. A key HPJP (Ch 7) point: **the default isolation level is not the same across databases** — Oracle and PostgreSQL default to *Read Committed*, MySQL/InnoDB to *Repeatable Read*, SQL Server to *Read Committed* — so code that "works" on one engine can exhibit different anomalies on another; set the level explicitly when it matters rather than assuming a default. Crucially, higher isolation does **not** by itself prevent the *lost update* across think-time — that needs optimistic/pessimistic locking (10.3/10.4). Match the level to the data: financial postings may need more; a comment feed needs less.

**Good example:**

```java
// Default to Read Committed and prevent lost updates with @Version (10.3);
// raise isolation only for the specific operation that needs it.
@Transactional(isolation = Isolation.REPEATABLE_READ)   // this report must see a stable snapshot
public Report generateConsistentReport() { /* multiple reads must agree */ }
```

**Bad example:**

```java
// Cranking everything to SERIALIZABLE "to be safe" serializes the whole workload,
// tanks throughput, and multiplies deadlocks/serialization failures — while STILL
// not protecting an edit-form lost update that spans user think-time.
@Transactional(isolation = Isolation.SERIALIZABLE)
public void everyMethodInTheApp() { /* ... */ }
```

### 10.3 Prevent lost updates with optimistic locking (@Version)

Title: Add a `@Version` field to entities edited concurrently; Hibernate appends `where version = ?` to every `UPDATE` and throws `OptimisticLockException` if another transaction changed the row first — the standard, scalable defense against the lost-update anomaly.

Description: The lost update: two users load the same row, both edit, both save — the second silently overwrites the first. A `@Version` column (int/long/timestamp) is checked and incremented on every update: `update … set …, version = version + 1 where id = ? and version = ?`. If the version no longer matches, the update affects zero rows and Hibernate raises `OptimisticLockException`, letting you reload/merge/retry. It needs no database locks (high concurrency) and works across detached conversations (10.6). JPwH (Ch 11) prefers **numeric** counters over timestamps (timestamps suffer JVM-clock inaccuracy and multi-node skew). It also covers the aggregate-root case: when you add or remove a *child* row and need that to register as a concurrent change on the parent, request `LockModeType.OPTIMISTIC_FORCE_INCREMENT` (e.g., `em.find(Item.class, id, LockModeType.OPTIMISTIC_FORCE_INCREMENT)`), which bumps the parent's version even though the parent's own columns didn't change — and `@OptimisticLocking(type = OptimisticLockType.ALL/DIRTY)` with `@DynamicUpdate` provides version-free optimistic locking by putting old column values in the `WHERE` clause when you cannot add a version column. This is the default recommendation in all four books for interactive edits.

**Good example:**

```java
@Entity
class Product {
    @Id @GeneratedValue private Long id;
    @Version private long version;          // optimistic-lock column
    private BigDecimal price;
}

@Transactional
public void reprice(Long id, BigDecimal newPrice) {
    Product p = em.find(Product.class, id);
    p.setPrice(newPrice);
}   // UPDATE ... set price=?, version=version+1 where id=? and version=? ;
    // if another tx bumped version first → OptimisticLockException (no lost update)
```

**Bad example:**

```java
@Entity
class Product {
    @Id @GeneratedValue private Long id;
    private BigDecimal price;               // no @Version
}
// Two concurrent reprice() calls both succeed; the later commit overwrites the earlier.
// The first user's change is silently lost with zero error.
```

### 10.4 Use pessimistic locking only when retries are unacceptable

Title: When a conflict must block rather than fail-and-retry (e.g., decrementing scarce inventory under heavy contention), acquire a database lock with `LockModeType.PESSIMISTIC_WRITE`; otherwise prefer optimistic locking (10.3), because pessimistic locks reduce concurrency and risk deadlocks.

Description: Pessimistic locking issues `SELECT … FOR UPDATE`, blocking other writers (and, with `PESSIMISTIC_READ`, sometimes readers) until you commit. It guarantees no conflict but serializes access to the locked rows, cuts throughput, and can deadlock if transactions lock rows in different orders. Use it for short, hot, must-not-retry critical sections — and set a lock timeout. Always lock rows in a consistent order to avoid deadlocks, and keep the locked section as small as possible. For most interactive edits, optimistic locking scales far better.

**Good example:**

```java
@Transactional
public void reserveStock(Long productId, int qty) {
    Product p = em.find(Product.class, productId,
            LockModeType.PESSIMISTIC_WRITE,                 // SELECT ... FOR UPDATE
            Map.of("jakarta.persistence.lock.timeout", 3000));  // fail fast, don't hang
    if (p.getStock() < qty) throw new InsufficientStockException();
    p.setStock(p.getStock() - qty);
}   // lock released at commit; concurrent reservers block briefly instead of conflicting
```

**Bad example:**

```java
@Transactional
public void reserveStock(Long productId, int qty) {
    Product p = em.find(Product.class, productId,
            LockModeType.PESSIMISTIC_WRITE);   // no timeout → can block indefinitely
    longRunningCallToPaymentGateway();         // holding a row lock across a network call!
    p.setStock(p.getStock() - qty);
    // Other transactions queue behind this lock for the whole gateway round-trip;
    // inconsistent lock ordering elsewhere can deadlock.
}
```

### 10.5 Mark read-only transactions read-only

Title: Annotate query-only service methods `@Transactional(readOnly = true)`; it sets the Hibernate flush mode to MANUAL (no dirty-check flush), can hint the driver/connection pool, and documents intent.

Description: A read-only transaction tells Hibernate it won't write, so it skips the automatic flush before queries and at commit and avoids taking dirty-check snapshots overhead where applicable (pair with read-only fetches, 8.6). It can also route to read replicas and let the driver optimize. Beyond performance, it documents that the method is a pure read — a useful guardrail. Don't mark a method read-only if it persists anything (the flush is suppressed and changes silently won't be saved).

**Good example:**

```java
@Transactional(readOnly = true)            // no flush, lighter, intent-documenting
public List<OrderView> recentOrders() {
    return em.createQuery("""
            select new com.app.OrderView(o.id, o.total) from Order o
            order by o.createdOn desc
            """, OrderView.class).setMaxResults(50).getResultList();
}
```

**Bad example:**

```java
@Transactional                              // read-write tx for a pure read
public List<OrderView> recentOrders() {     // Hibernate snapshots + may flush on exit
    return em.createQuery(/* ... */, OrderView.class).getResultList();
}
// Or the opposite mistake: readOnly=true on a method that also persists — the write
// is never flushed and silently disappears.
```

### 10.6 Manage long conversations with detached entities + versioning

Title: For a multi-request workflow (a wizard, an edit-then-confirm flow), don't hold a persistence context (or database transaction) open across user think-time; detach the entity between requests and reattach with `merge()`, relying on `@Version` to detect concurrent edits at the end.

Description: An application-level transaction (conversation) spans several HTTP requests with user thinking in between — far longer than a database transaction should ever be held. Keeping a session/transaction open across requests pins a connection and locks, killing scalability. Instead: load and detach in request 1, carry the detached entity (or a DTO) in the conversation, and `merge()` it back in the final request inside a short database transaction. The `@Version` field, carried through detachment, makes the final update detect any concurrent change (10.3) and reject the stale write.

**Good example:**

```java
// Request 1: load + detach (entity carries its @Version)
@Transactional(readOnly = true)
public ProductForm startEdit(Long id) {
    Product p = em.find(Product.class, id);
    return ProductForm.from(p);            // includes id AND version
}

// Request 2 (after think-time): short tx, merge, version check catches stale edits
@Transactional
public void confirmEdit(ProductForm form) {
    Product detached = form.toEntity();    // carries the original version
    em.merge(detached);                    // OptimisticLockException if version changed
}
```

**Bad example:**

```java
// Holding an extended persistence context / open transaction across user think-time:
EntityManager em = emf.createEntityManager();
em.getTransaction().begin();
Product p = em.find(Product.class, id);    // request 1
// ... return to user, who goes to lunch for an hour ...
p.setPrice(newPrice);                      // request 2
em.getTransaction().commit();              // a 1-hour DB transaction holding a connection/locks
```

## Chapter 11 — JDBC-Level Performance

*Sources: HPJP Ch 3 ("JDBC Connection Management" — pool sizing via Little's Law `L = λ × W` and the Universal Scalability Law; FlexyPool for monitoring/failover; connection release modes), HPJP Ch 4 ("Batch Updates" — `hibernate.jdbc.batch_size`, `order_inserts`/`order_updates`, `batch_versioned_data`, IDENTITY disables batching), HPJP Ch 5 ("Statement Caching" — server-side vs client-side caches, measured throughput gains, HikariCP/driver cache properties), HPJP Ch 6 ("ResultSet Fetching" — `hibernate.jdbc.fetch_size`; some drivers' tiny defaults cause excessive round-trips).*

### 11.1 Use a connection pool (HikariCP) and size it deliberately

Title: Always go through a connection pool (HikariCP is the high-performance default); acquiring a raw `DriverManager` connection per request is orders of magnitude slower, and the pool size should be small and computed, not arbitrarily large.

Description: Opening a physical database connection is expensive (TCP handshake, auth, session setup); a pool keeps a few warm connections and hands them out in microseconds. *High-Performance Java Persistence* (Ch 3) stresses that bigger pools are not better and frames sizing with **Little's Law**, `L = λ × W` (the average number of in-use connections `L` equals arrival rate `λ` times average hold time `W`) and the **Universal Scalability Law**, which shows throughput *degrading* past a point as contention and coherency costs grow — so beyond the database's CPU/IO capacity more connections only add queuing and lock contention. Start small (often ~`(2 × cores) + effective_spindle_count`, then measure), set sane timeouts, and monitor acquisition time. Mihalcea recommends **FlexyPool** to size pools from real metrics and to fail over/alert under load. Be aware of Hibernate's **connection release mode** (`hibernate.connection.handling_mode`): historically resource-local transactions held the connection until commit (`AFTER_TRANSACTION`) while JTA released it after each statement (`AFTER_STATEMENT`) — keeping connection hold time short is what lets a small pool serve high throughput. In Spring Boot, configure `spring.datasource.hikari.*`.

**Good example:**

```properties
# HikariCP: small, deliberately sized pool with fail-fast timeouts.
spring.datasource.hikari.maximum-pool-size=10        # measured, not "200 to be safe"
spring.datasource.hikari.minimum-idle=10
spring.datasource.hikari.connection-timeout=2000     # fail fast if the pool is exhausted
spring.datasource.hikari.max-lifetime=1800000
```

**Bad example:**

```java
// A fresh physical connection per call — full handshake + auth every time.
Connection c = DriverManager.getConnection(url, user, pass);   // no pool
try (c) { /* ... query ... */ }
```
```properties
# Or an absurdly large pool that overwhelms the database with concurrent sessions,
# increasing lock/latch contention and lowering throughput:
spring.datasource.hikari.maximum-pool-size=500
```

### 11.2 Enable JDBC batching and order inserts/updates

Title: Turn on JDBC statement batching (`hibernate.jdbc.batch_size`) and let Hibernate group inserts/updates by table (`order_inserts`, `order_updates`) so many DML statements travel to the database in a few round-trips instead of one per row.

Description: Without batching, persisting 1000 rows is 1000 network round-trips. With `batch_size = 50`, Hibernate sends them ~20 at a time, a massive latency win for write-heavy work. Batching only helps when consecutive statements hit the same table, so `order_inserts`/`order_updates` reorder the flush to maximize batchable runs. Remember the prerequisite: the `IDENTITY` generator disables insert batching (3.1) — use `SEQUENCE`. Pair batching with the `flush()`+`clear()` loop (7.4) so the context doesn't balloon. (Note: `@Version` batched updates with `versioned_data=true` is needed for batched optimistic-lock updates.)

**Good example:**

```properties
spring.jpa.properties.hibernate.jdbc.batch_size=50
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true
spring.jpa.properties.hibernate.jdbc.batch_versioned_data=true
```
```java
// Combined with SEQUENCE ids (3.1) and flush/clear (7.4):
for (int i = 0; i < records.size(); i++) {
    em.persist(records.get(i));
    if (i % 50 == 0) { em.flush(); em.clear(); }   // batched round-trips
}
```

**Bad example:**

```properties
# batch_size unset (defaults to no batching) AND entities use IDENTITY ids:
# every persist() is an immediate single-row INSERT round-trip.
```
```java
@Entity class Record { @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id; }
// Even if you later set batch_size=50, IDENTITY silently disables insert batching.
```

### 11.3 Rely on statement caching; keep SQL bind-parameterized

Title: Keep generated SQL parameterized (which Hibernate does by default) so the database's server-side statement cache and the driver's client-side `PreparedStatement` cache can reuse parsed/planned statements; don't inline literals that defeat the cache.

Description: Parsing and planning a SQL statement is costly; databases cache execution plans keyed by the statement *text*. Parameterized statements (`where id = ?`) share one cache entry across all values; inlining literals (`where id = 42`) produces a distinct text per value, flooding and thrashing the cache. HPJP (Ch 5) distinguishes two layers: the **server-side** statement cache inside the database (e.g., Oracle's cursor cache, SQL Server's plan cache) and the **client-side** `PreparedStatement` cache inside the JDBC driver — both only pay off when the SQL text is stable, i.e., parameterized. Mihalcea's benchmarks show meaningful throughput gains from enabling client-side caching (on the order of tens of percent — roughly +20% to +55% depending on the database/driver in his measurements). Hibernate emits bind parameters automatically, so mostly "don't fight it": avoid native queries with concatenated literals (9.1), and turn on the driver cache — for **MySQL**: `cachePrepStmts=true`, `prepStmtCacheSize=250`, `prepStmtCacheSqlLimit=2048`, `useServerPrepStmts=true`; for **PostgreSQL**: `prepareThreshold`. Be aware of bind-peeking/bind-sensitive plans on skewed data, but the default of parameterizing is right.

**Good example:**

```java
// Hibernate-generated and explicit queries both stay parameterized → one cached plan:
em.find(Account.class, id);                         // ... where id = ?
em.createQuery("select a from Account a where a.status = :s", Account.class)
  .setParameter("s", status);                       // ... where status = ?
```
```properties
# Enable the JDBC driver's client-side prepared-statement cache (PostgreSQL example):
spring.datasource.hikari.data-source-properties.prepareThreshold=1
```

**Bad example:**

```java
// Inlined literals → a new statement text (and cache entry) for every id/status:
em.createNativeQuery("select * from account where id = " + id);          // un-cacheable
em.createNativeQuery("select * from account where status = '" + s + "'"); // + injection
```

### 11.4 Tune the ResultSet fetch size for large reads

Title: For queries that return many rows, set a `fetch size` so the driver pulls rows in chunks instead of one-by-one (or all-at-once); the JDBC default (often 10) causes excessive round-trips on big result sets.

Description: The fetch size controls how many rows the driver retrieves per network round-trip while iterating a `ResultSet`. A tiny default means many round-trips for a large read; an unbounded fetch can blow up memory. A moderate value (e.g., 100–500) balances round-trips against memory and pairs well with streaming (9.6). Set it via the query hint `org.hibernate.fetchSize` / `HINT_FETCH_SIZE`, or globally with `hibernate.jdbc.fetch_size`. (Note: some drivers, e.g., PostgreSQL, only honor fetch size inside a transaction with auto-commit off.)

**Good example:**

```java
List<AuditEvent> events = em.createQuery(
        "select e from AuditEvent e where e.day = :day", AuditEvent.class)
    .setParameter("day", day)
    .setHint(org.hibernate.jpa.QueryHints.HINT_FETCH_SIZE, 200)   // chunked retrieval
    .getResultList();
```

**Bad example:**

```java
List<AuditEvent> events = em.createQuery(
        "select e from AuditEvent e where e.day = :day", AuditEvent.class)
    .setParameter("day", day)
    .getResultList();
// Default fetch size (~10) → thousands of tiny round-trips to read a large day's events.
```

## Chapter 12 — Caching

*Sources: HPJP caching chapter and JPwH Ch 20 ("Filtering data" / second-level cache — the four `CacheConcurrencyStrategy` modes and their write semantics: READ_ONLY for immutable data (mutation throws), READ_WRITE uses soft locks for safe concurrent updates, NONSTRICT_READ_WRITE has no lock and a brief staleness window, TRANSACTIONAL is JTA-only; bulk DML and external writers bypass cache invalidation); BH6 Ch 8 (`@Cache`, L1 vs L2, `CacheMode`, query cache); Cookbook Ch 7 (Ehcache provider config, `hibernate.cache.use_query_cache`, `setCacheable(true)`).*

### 12.1 Treat the L1 persistence context as transaction-scoped, not a store

Title: The first-level cache (the persistence context / identity map) exists automatically and lives only for the unit of work — use it to guarantee identity (one instance per row per context) and avoid duplicate reads within a transaction, but never treat it as an application cache.

Description: The L1 cache is not optional and not configurable: within one `EntityManager`, repeated `find()`/navigation for the same id returns the *same* instance without re-querying, and it batches your writes. It's cleared when the context closes, so it never spans requests. Don't try to make it persistent or share it across threads. Its only failure modes are the ones already covered: it can grow huge in long loops (use 7.4 flush/clear) and it can hold stale copies after bulk DML (use 9.5 clear/evict).

**Good example:**

```java
@Transactional
public void process(Long id) {
    Order a = em.find(Order.class, id);
    Order b = em.find(Order.class, id);   // SAME instance, NO second SELECT (L1 hit)
    assert a == b;                         // identity guaranteed within the context
}
```

**Bad example:**

```java
// Misusing the persistence context as a long-lived app cache across requests:
EntityManager longLivedEm = emf.createEntityManager();   // kept open "to cache entities"
// Grows without bound, serves increasingly stale data, isn't thread-safe, and pins
// resources. Use the second-level cache (12.2) for cross-transaction caching instead.
```

### 12.2 Enable the second-level cache only for read-mostly data, with the right strategy

Title: Use the second-level cache (shared across sessions) for entities that are read far more than written — reference/lookup data — and pick the concurrency strategy that matches the write pattern: READ_ONLY for immutable, READ_WRITE for occasionally updated, NONSTRICT_READ_WRITE for rarely-updated-and-tolerant, TRANSACTIONAL for JTA.

Description: The L2 cache avoids hitting the database for entities already cached, but it adds memory and a consistency burden, so it's a net loss for write-heavy entities. Enable it per entity with `@Cache`, and choose: **READ_ONLY** (fastest; immutable reference data — mutation throws), **READ_WRITE** (soft-locks entries for safe concurrent updates), **NONSTRICT_READ_WRITE** (no lock; brief staleness window acceptable), **TRANSACTIONAL** (full transactional cache, JTA only). Require explicit opt-in (`shared-cache-mode=ENABLE_SELECTIVE`) so nothing is cached by accident. Cache by id; query results need the separate query cache (12.3).

**Good example:**

```java
@Entity
@Cacheable
@org.hibernate.annotations.Cache(
    usage = org.hibernate.annotations.CacheConcurrencyStrategy.READ_ONLY)  // immutable lookup
class Currency {
    @Id private String code;
    private String name;
}
```
```properties
spring.jpa.properties.jakarta.persistence.sharedCache.mode=ENABLE_SELECTIVE  # opt-in only
spring.jpa.properties.hibernate.cache.use_second_level_cache=true
```

**Bad example:**

```java
@Entity
@Cacheable
@org.hibernate.annotations.Cache(
    usage = org.hibernate.annotations.CacheConcurrencyStrategy.READ_ONLY)
class ShoppingCart {                       // mutated on every add-to-cart!
    @Id @GeneratedValue private Long id;
    // READ_ONLY on hot-mutating data: updates fail or serve stale carts, and caching a
    // write-heavy entity just wastes memory and adds invalidation churn.
}
```

### 12.3 Cache collections explicitly; weigh the query cache carefully

Title: The second-level cache does not cache an entity's collections or query results unless you opt in — add `@Cache` on cached collections, and enable the query cache only for stable, frequently-repeated queries, knowing it must be invalidated on any change to the involved tables.

Description: Caching an entity caches its scalar state by id, not its `@OneToMany`/`@ManyToMany` collections; annotate those collections with `@Cache` too if you want them cached. The *query cache* stores query result *ids* keyed by the query + parameters; it helps only for queries run repeatedly with the same parameters over rarely-changing data, and Hibernate invalidates it whenever any table the query touches changes (tracked via update timestamps). A churning query cache can be slower than no cache. Use it surgically, measure it, and prefer DTO + application caching for hot read endpoints.

**Good example:**

```java
@Entity
@Cacheable @org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
class Country {
    @Id private String code;
    @OneToMany(mappedBy = "country")
    @org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE) // cache the collection too
    private List<Region> regions = new ArrayList<>();
}

// Query cache ONLY for a stable, hot, parameter-stable lookup over static data:
em.createQuery("select c from Country c order by c.name", Country.class)
  .setHint(org.hibernate.jpa.QueryHints.HINT_CACHEABLE, true)
  .getResultList();
```

**Bad example:**

```java
// Turning on the query cache globally for everything, including queries over
// frequently-written tables:
em.createQuery("select o from Order o where o.status = :s", Order.class)
  .setParameter("s", status)
  .setHint(org.hibernate.jpa.QueryHints.HINT_CACHEABLE, true)
  .getResultList();
// Every new/updated Order invalidates this cache region; you pay cache maintenance
// cost for near-zero hit rate — often slower than not caching.
```

### 12.4 Don't let caching hide staleness or correctness bugs

Title: Caching trades freshness for speed; make the staleness window explicit and never cache data whose correctness is critical and changes outside Hibernate's knowledge (e.g., updated by another app, by bulk DML, or by native SQL).

Description: The L2 cache is only consistent with the database for changes made *through Hibernate*. Bulk JPQL (9.5), native `UPDATE`s, database triggers, or a second application writing the same tables all bypass cache invalidation, leaving stale entries served indefinitely. If such writers exist, either don't cache those entities, or invalidate the affected regions explicitly (`Cache.evict`). Choose a cache provider TTL that bounds staleness, and treat the cache as an optimization that must never be the source of truth for correctness-critical reads.

**Good example:**

```java
@Transactional
public int discontinue(Long categoryId) {
    int n = em.createQuery("update Product p set p.active=false where p.category.id=:c")
        .setParameter("c", categoryId).executeUpdate();      // bulk DML bypasses L2
    em.getEntityManagerFactory().getCache().evict(Product.class);  // invalidate explicitly
    return n;
}
```

**Bad example:**

```java
@Entity
@Cacheable @org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
class Price { @Id Long id; BigDecimal value; }
// A nightly batch job updates the price table via raw SQL / another service.
// Hibernate never learns about it, so the L2 cache serves yesterday's prices all day —
// a correctness bug masquerading as a performance feature.
```

## Chapter 13 — Bulk Operations & Batching

*Sources: JPwH Ch 12 (batch processing with `flush()`+`clear()` every N — the book uses 100) and Ch 20 (`StatelessSession`: no first-level cache, no dirty checking, ignores cascade and lifecycle/events, no interaction with the second-level cache — explicit `insert`/`update`/`delete`); HPJP Ch 4 (batched DML mechanics); Cookbook Ch 2 (`openStatelessSession()`) and Ch 7 (batch loop `if (i % 50 == 0) { flush(); clear(); }`, disable L2 during batch).*

### 13.1 Use bulk JPQL UPDATE/DELETE for set-based changes

Title: For "change/delete all rows matching a predicate," issue one bulk JPQL `UPDATE`/`DELETE` rather than loading and looping — it's one set-based statement instead of N round-trips. (See 9.5 for the persistence-context/cache caveat.)

Description: This is the write-side complement to DTO projections: don't pull entities into memory just to mutate or remove them in bulk. A bulk statement runs entirely in the database. The trade-offs are important enough to repeat: bulk DML ignores cascade rules (a bulk `delete from Parent` won't cascade to children — handle children first or rely on database FK `ON DELETE CASCADE`), and it bypasses the persistence context and L2 cache (clear/evict afterward). Use it for archival, soft-delete sweeps, and mass status changes.

**Good example:**

```java
@Transactional
public int purgeExpiredTokens(Instant now) {
    return em.createQuery("delete from AuthToken t where t.expiresAt < :now")
        .setParameter("now", now)
        .executeUpdate();                  // one DELETE removes all expired tokens
}
```

**Bad example:**

```java
@Transactional
public void purgeExpiredTokens(Instant now) {
    em.createQuery("select t from AuthToken t where t.expiresAt < :now", AuthToken.class)
        .setParameter("now", now)
        .getResultList()
        .forEach(em::remove);              // load N tokens, then N DELETE statements
}
```

### 13.2 Batch large inserts/updates with periodic flush()+clear()

Title: For programmatic mass inserts/updates that must run through the entity model (cascades, listeners), combine JDBC batching (11.2), `SEQUENCE` ids (3.1), and a periodic `flush()`+`clear()` loop (7.4) sized to the batch — this is the canonical high-throughput write loop.

Description: When you genuinely need entity semantics for a large write (validation, lifecycle events, cascading), batch it correctly: set `batch_size`, use a sequence generator so inserts are batchable, and every `batch_size` iterations `flush()` (send the batch) then `clear()` (detach to free memory and keep dirty checking fast). Without the clear, memory grows and flushes slow down; without batching, every row is a round-trip; with IDENTITY ids, batching is silently off. All three must align.

**Good example:**

```java
@Transactional
public void bulkInsert(List<CustomerDto> dtos) {
    final int batchSize = 50;              // == hibernate.jdbc.batch_size
    for (int i = 0; i < dtos.size(); i++) {
        em.persist(new Customer(dtos.get(i)));   // SEQUENCE id → batchable
        if (i > 0 && i % batchSize == 0) {
            em.flush();                    // push 50 batched INSERTs
            em.clear();                    // detach → constant memory
        }
    }
}
```

**Bad example:**

```java
@Transactional
public void bulkInsert(List<CustomerDto> dtos) {
    for (CustomerDto d : dtos) {
        em.persist(new Customer(d));       // no flush/clear, no batch_size, IDENTITY id
    }
    // One giant flush, N single-row round-trips, ever-growing persistence context → OOM.
}
```

### 13.3 Use StatelessSession for ETL-style processing

Title: For pure bulk import/export with no need for dirty checking, cascade, lazy loading, or the L1/L2 cache, use Hibernate's `StatelessSession` — it bypasses the persistence context entirely, giving lower memory and overhead than even a flush/clear loop.

Description: A `StatelessSession` has no first-level cache, performs no automatic dirty checking, ignores cascade and lifecycle events, and doesn't interact with the second-level cache. You operate with explicit `insert`/`update`/`delete`. This is ideal for ETL jobs and large migrations where you want raw throughput and predictable memory and don't need ORM conveniences. The trade-off is that you give those conveniences up — so it's for data-movement code, not domain logic.

**Good example:**

```java
public void exportToWarehouse(SessionFactory sf, List<Row> rows) {
    try (StatelessSession session = sf.openStatelessSession()) {
        Transaction tx = session.beginTransaction();
        for (Row r : rows) {
            session.insert(new StagingRecord(r));   // no L1 cache, no dirty checking, low overhead
        }
        tx.commit();
    }
}
```

**Bad example:**

```java
@Transactional
public void exportToWarehouse(List<Row> rows) {
    for (Row r : rows) {
        em.persist(new StagingRecord(r));   // full persistence-context machinery for plain ETL
    }
    // Dirty-check snapshots, cascade checks, and identity map you never use — wasted
    // memory and CPU for a one-way bulk insert.
}
```

## Chapter 14 — Auditing, Events & Filters

*Sources: BH6 Ch 13 ("Hibernate Envers" — `@Audited`/`@NotAudited`, the `_AUD` + `REVINFO` tables, `AuditReaderFactory.get(session)`, `AuditReader.getRevisions`/`find`/`getRevisionDate`, the `AuditQuery` fluent API with `AuditEntity` predicates; a revision is a **global transaction-level counter**, not a per-entity one, so an entity's revision numbers have gaps; reverting means copying a historical state onto the managed entity), BH6 Ch 7 (JPA lifecycle callbacks `@PrePersist`/`@PostLoad`/etc. and external `@EntityListeners`; Bean Validation on entities), BH6 Ch 10 ("Filtering" — `@FilterDef`/`@ParamDef`, session-scoped `enableFilter(...).setParameter(...)`, filters are disabled by default and are **not** applied to bulk HQL `UPDATE`/`DELETE`); JPwH Ch 13; Cookbook Ch 7 (Envers `REVTYPE` 0=insert/1=update/2=delete, interceptor via `EmptyInterceptor`).*

### 14.1 Audit history with Hibernate Envers (@Audited)

Title: To track who-changed-what-when and reconstruct past states, use Hibernate Envers (`@Audited`) instead of hand-rolling shadow tables and update triggers — Envers transparently records a revision row per change and lets you query historical versions.

Description: Auditing/versioning of data (distinct from `@Version` optimistic locking) is a recurring requirement. Envers, annotated with `@Audited` on the entity (and `@NotAudited` to exclude a field such as a password), automatically maintains `<entity>_AUD` tables plus a global `REVINFO` table; each audit row carries a `REV` number and a `REVTYPE` (BH6 Ch 13 / Cookbook Ch 7: `0` = insert, `1` = update, `2` = delete). A crucial detail from BH6 Ch 13: a **revision is a global, transaction-level counter, not a per-entity one** — so a single entity's revisions can be `1, 3, 5` with gaps if other entities changed in the intervening transactions; never assume sequential per-row revisions. Read history through `AuditReaderFactory.get(session)`: `getRevisions(Type, id)` lists an entity's revisions, `find(Type, id, revision)` loads it as-of a revision, and the fluent `createQuery().forRevisionsOfEntity(...)` + `AuditEntity` predicates query the audit log. Envers has no built-in "revert" — to roll back, load the desired historical revision and copy its fields onto the current managed entity (which records a new revision). This is far more robust and queryable than manual audit columns and avoids scattering audit logic across the codebase.

**Good example:**

```java
@Entity
@org.hibernate.envers.Audited              // Envers maintains account_AUD + revinfo
class Account {
    @Id @GeneratedValue private Long id;
    private BigDecimal balance;
}

// Reconstruct a past state or list the change history:
AuditReader reader = AuditReaderFactory.get(em);
Account asOfRevision5 = reader.find(Account.class, accountId, 5);
List<Number> revisions = reader.getRevisions(Account.class, accountId);
```

**Bad example:**

```java
// Hand-rolled auditing smeared across every service method:
@Transactional
public void updateBalance(Long id, BigDecimal newBalance) {
    Account a = em.find(Account.class, id);
    em.persist(new AccountAuditCopy(a));   // manual shadow row, easy to forget on some path
    a.setBalance(newBalance);
    // Miss this line in one of the dozen places balance changes → audit trail has holes.
}
```

### 14.2 Stamp created/updated metadata automatically

Title: Populate `createdAt`/`updatedAt` (and created/updated-by) automatically with JPA lifecycle callbacks (`@PrePersist`/`@PreUpdate`), an `@EntityListeners` auditor, or Hibernate `@CreationTimestamp`/`@UpdateTimestamp` — don't set them by hand in every service method.

Description: Audit-metadata columns should be filled by the framework, not by developers remembering to call a setter. Hibernate's `@CreationTimestamp`/`@UpdateTimestamp` fill timestamp fields on insert/update; for richer auditing (current user), a reusable `@MappedSuperclass` with `@PrePersist`/`@PreUpdate` callbacks (or Spring Data's `@CreatedDate`/`@LastModifiedDate` + `AuditingEntityListener`) centralizes the logic. This guarantees consistency across every write path and keeps the metadata out of business code.

**Good example:**

```java
@MappedSuperclass
abstract class Auditable {
    @org.hibernate.annotations.CreationTimestamp
    @Column(updatable = false) private Instant createdAt;
    @org.hibernate.annotations.UpdateTimestamp
    private Instant updatedAt;
}

@Entity
class Article extends Auditable {          // timestamps stamped automatically on every write
    @Id @GeneratedValue private Long id;
    private String title;
}
```

**Bad example:**

```java
@Entity
class Article {
    @Id @GeneratedValue private Long id;
    private String title;
    private Instant createdAt;
    private Instant updatedAt;
}
@Transactional
public Article create(String title) {
    Article a = new Article(title);
    a.setCreatedAt(Instant.now());          // every create/update site must remember this...
    a.setUpdatedAt(Instant.now());          // ...and one that forgets leaves null/garbage
    em.persist(a);
    return a;
}
```

### 14.3 Apply cross-cutting row visibility with @Filter

Title: For cross-cutting `WHERE` conditions applied to many queries — soft delete, multi-tenancy, effective-dating — use Hibernate's `@FilterDef`/`@Filter` enabled per session, rather than appending the same predicate to every query (and inevitably forgetting one).

Description: Concerns like "never show soft-deleted rows" or "only this tenant's rows" must be enforced uniformly; a single missed `where deleted = false` is a data-leak or correctness bug. A Hibernate `@Filter` defines the condition once on the entity and is enabled (with parameters) on the session, after which Hibernate appends it to the entity's queries and collection loads automatically. It's dynamic (toggle per session, unlike a hard-coded `@Where`) and parameterized (tenant id, as-of date). Note filters apply to queries and lazy collection loads, not to direct `find()` by id — combine with care.

**Good example:**

```java
@Entity
@org.hibernate.annotations.FilterDef(name = "tenantFilter",
    parameters = @org.hibernate.annotations.ParamDef(name = "tenantId", type = Long.class))
@org.hibernate.annotations.Filter(name = "tenantFilter", condition = "tenant_id = :tenantId")
class Document {
    @Id @GeneratedValue private Long id;
    @Column(name = "tenant_id") private Long tenantId;
}

// Enable once per request; every Document query is now tenant-scoped automatically:
em.unwrap(Session.class).enableFilter("tenantFilter").setParameter("tenantId", currentTenant);
```

**Bad example:**

```java
// Re-appending the tenant predicate to every single query by hand:
em.createQuery("select d from Document d where d.tenantId = :t and d.title like :q", Document.class)
  .setParameter("t", currentTenant).setParameter("q", q);
// One query somewhere forgets `and d.tenantId = :t` → cross-tenant data leak.
```

## Chapter 15 — Monitoring & Diagnostics

*Sources: HPJP Ch 5 & 9 (the book's central discipline — measure, don't guess: `hibernate.generate_statistics`, the `Statistics` API for query counts and L2 hit ratios, and JDBC-level proxies such as datasource-proxy/P6Spy to count and time real statements with slow-query thresholds); JPwH Ch 12 (verifying fetch plans by inspecting the generated SQL); BH6 Ch 1–2 (`org.hibernate.SQL=DEBUG`, `hibernate.format_sql`, binder TRACE logging for bound parameters).*

### 15.1 Log and format the actual SQL

Title: Make the generated SQL visible during development — enable SQL logging with formatting (and, when needed, bound-parameter logging) — because you cannot evaluate fetch, batching, or N+1 behavior from the Java alone.

Description: The recurring theme of all four books: the Java code rarely tells you what hits the database. Turn on statement logging so you can count statements and inspect joins, fetches, and batch grouping. Use `hibernate.format_sql=true` for readability and a parameter-logging facility to see bound values. **Do not** enable verbose SQL/parameter logging in production (performance and PII exposure); use it in dev/test and rely on metrics in production (15.2).

**Good example:**

```properties
# Development only — see and read the real SQL:
spring.jpa.properties.hibernate.format_sql=true
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.orm.jdbc.bind=TRACE   # bound parameters (Hibernate 6)
```

**Bad example:**

```java
// "It compiles and the test passes, ship it" — without ever looking at the SQL.
List<Order> orders = repo.findAll();
orders.forEach(o -> o.getLines().size());
// The log (which nobody enabled) shows 1 + N selects; the green test hides the N+1.
```

### 15.2 Measure with Hibernate Statistics and a statement proxy

Title: In test/staging (and carefully in production), gather quantitative evidence: enable Hibernate `Statistics` (query counts, cache hit ratios, connection metrics) and/or wrap the `DataSource` with `datasource-proxy` or P6Spy to count and time the real statements.

Description: Logging shows individual statements; metrics show aggregate behavior — how many queries a request ran, the L2 cache hit ratio, slow queries, connection-acquisition time. Hibernate `Statistics` exposes these programmatically (enable `hibernate.generate_statistics`); `datasource-proxy`/P6Spy intercept at the JDBC level to log/count/time every statement with slow-query thresholds, independent of the ORM. Use these to set baselines, catch regressions, and prove an optimization actually reduced statement count or latency.

**Good example:**

```properties
spring.jpa.properties.hibernate.generate_statistics=true
```
```java
Statistics stats = em.getEntityManagerFactory()
        .unwrap(SessionFactory.class).getStatistics();
long queries = stats.getQueryExecutionCount();
double hitRatio = (double) stats.getSecondLevelCacheHitCount()
        / Math.max(1, stats.getSecondLevelCacheHitCount() + stats.getSecondLevelCacheMissCount());
// Wrap the DataSource with datasource-proxy to log slow queries + per-tx statement counts.
```

**Bad example:**

```java
// Optimizing by guesswork: change a fetch type, "feels faster," commit — with no
// before/after query count or latency number to confirm anything improved (or
// to notice a new N+1 the change introduced elsewhere).
```

### 15.3 Assert the executed statement count in tests

Title: Lock in fetch/batching behavior with integration tests that assert the *number* of SQL statements a use case runs — so an accidental EAGER, a lost `JOIN FETCH`, or a new N+1 fails the build instead of slipping into production.

Description: Performance characteristics regress silently: someone flips an association to EAGER, removes a `join fetch`, or adds a lazy access in a loop, and nothing fails — the feature still works, just with 10× the queries. A statement-count assertion (via Hibernate `Statistics`, `datasource-proxy`'s `ProxyTestDataSource`/`QueryCount`, or a counting `StatementInspector`) turns query count into a tested contract. Write these around your hot read paths and any use case where you applied a fetch optimization, asserting the expected (small) number of statements.

**Good example:**

```java
@Test
void loading_the_dashboard_runs_a_constant_number_of_queries() {
    Statistics stats = sessionFactory.getStatistics();
    stats.clear();

    dashboardService.load(userId);          // should be JOIN FETCH / entity graph

    assertThat(stats.getPrepareStatementCount())
        .as("dashboard must not regress into N+1")
        .isEqualTo(2);                      // 1 for the graph + 1 for a projection, say
}
```

**Bad example:**

```java
@Test
void loading_the_dashboard_works() {
    DashboardView v = dashboardService.load(userId);
    assertThat(v).isNotNull();              // asserts it returns SOMETHING...
    // ...but says nothing about HOW MANY queries ran. A future EAGER/lazy-in-loop change
    // silently turns 2 queries into 200 and this test stays green.
}
```


## Output Format

When you apply this skill to a user's persistence code, structure your response as follows:

- **ANALYZE** the supplied entities, repositories/DAOs, configuration, and — crucially — the generated SQL (statement log / `datasource-proxy`). Identify which practices are violated, citing each by section and title (e.g., "5.4: Make every association LAZY").
- **CATEGORIZE** findings by impact (CRITICAL correctness/data-integrity/security, PERFORMANCE, MAINTAINABILITY, READABILITY) and by topic (mapping, identifiers, associations, inheritance, lifecycle, fetching, queries, transactions, JDBC performance, caching, monitoring).
- **EXPLAIN** for each finding the rationale and show the targeted Good vs. Bad contrast as it applies to the user's code and the SQL it produces.
- **APPLY** the lowest-risk, highest-value improvements first (bind parameters, LAZY associations, DTO projections, `@BatchSize`, `@Enumerated(STRING)`) before structural changes (identifier-generator swaps, inheritance restructuring, second-level cache, locking).
- **PRIORITIZE** a short, ordered remediation plan (quick wins → structural refactorings) and note the expected change in statement count or latency.
- **VALIDATE** that changes compile, tests pass, and the observed SQL is correct before reporting success.

## Safeguards

- **BLOCKING SAFETY CHECK**: Run `./mvnw compile` (or the project build) before applying ANY change — compilation failure is a HARD STOP.
- **CRITICAL VALIDATION**: Run `./mvnw clean verify` after changes and report failures honestly with the actual output.
- **CONFIRM THE SQL**: Never declare an N+1, batching, fetch, or caching fix successful without inspecting the actual generated statements and their count.
- **DATA INTEGRITY**: `cascade`, `orphanRemoval`, fetch-type, identifier-generator, and locking changes can delete data, deadlock, or corrupt state — treat them as behavior-changing and confirm intent before applying.
- **SECURITY**: All JPQL/HQL/native query input must use bind parameters; flag any string-concatenated query as an injection vulnerability.
- **SCHEMA SAFETY**: Never recommend `hbm2ddl=update`/`create` against a production database; schema changes belong in versioned migrations (Flyway/Liquibase) with `ddl-auto=validate`.
- **TRANSACTION CORRECTNESS**: Lazy loading, dirty checking, and flushing only work inside an open persistence context — verify transaction boundaries before relying on them, and never serve lazy associations to a view after the context closes.
- **INCREMENTAL SAFETY**: Apply one item at a time and re-validate; do not batch many mapping/fetch/locking changes without intermediate verification.
- **NO OVER-APPLICATION**: These are guidelines, not absolutes — call out the rare cases where an item legitimately does not apply (e.g., IDENTITY is fine when batching is irrelevant, EAGER is fine for a small always-needed `@ManyToOne`).
