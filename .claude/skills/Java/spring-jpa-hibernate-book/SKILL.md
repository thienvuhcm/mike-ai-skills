---
name: spring-jpa-hibernate-book
description: Use when you need to design, review, optimize, or debug a JPA/Hibernate persistence layer (with or without Spring Boot / Spring Data JPA) — synthesized from High-Performance Java Persistence (Vlad Mihalcea), Java Persistence with Hibernate (Bauer, King, Gregory), Beginning Hibernate 6, and Java Hibernate Cookbook. Covers entity mapping (@Entity, @Column, embeddables, @Convert converters, @Immutable, derived/formula properties), identifiers and sequence optimizers (IDENTITY vs SEQUENCE vs TABLE, hi/lo, pooled, pooled-lo, UUID, @NaturalId, composite keys @IdClass/@EmbeddedId, equals/hashCode), associations (@ManyToOne, bidirectional @OneToMany synchronization, @JoinColumn vs join table, @OneToOne shared PK, @ManyToMany → link entity, Set vs bag), inheritance (SINGLE_TABLE / JOINED / TABLE_PER_CLASS / @MappedSuperclass), the persistence context and entity lifecycle (transient/managed/detached/removed, persist/merge/remove/refresh/find, flush modes, automatic dirty checking, cascade, orphanRemoval), fetching and the N+1 problem (LAZY vs EAGER, proxies, JOIN FETCH, @EntityGraph, @BatchSize, subselect fetch, DTO projections, Cartesian product), JPQL/HQL, Criteria API and native queries (parameter binding, named queries, @SqlResultSetMapping, stored procedures, streaming, keyset pagination), transactions and concurrency control (ACID, isolation levels and phenomena, declarative @Transactional, @Version optimistic locking, pessimistic LockModeType, lost updates, application-level conversations, read-only), JDBC-level performance (HikariCP connection pooling, JDBC statement batching with order_inserts/order_updates/batch_size, statement caching, fetch size), first/second-level and query caching (READ_ONLY/NONSTRICT_READ_WRITE/READ_WRITE/TRANSACTIONAL, @Cache, collection cache), bulk operations and StatelessSession, auditing with Hibernate Envers and lifecycle callbacks, dynamic @Filter, and monitoring (statement logging, Hibernate statistics, datasource-proxy / P6Spy, asserting statement counts in tests). This should trigger for requests such as Review/optimize my JPA/Hibernate entities; Fix N+1 select queries; Why is Hibernate slow / generating too many queries; Map this relationship or inheritance hierarchy; Add optimistic/pessimistic locking; Configure JDBC batching or the second-level cache; Fix LazyInitializationException; Choose an identifier generator. Distilled from High-Performance Java Persistence, Java Persistence with Hibernate, Beginning Hibernate 6, and Java Hibernate Cookbook.
license: Apache-2.0
metadata:
  author: Vlad Mihalcea, Christian Bauer, Gavin King, Gary Gregory (sources); skill synthesized from the complete text of High-Performance Java Persistence, Java Persistence with Hibernate, Beginning Hibernate 6, and Java Hibernate Cookbook
  version: 2.0.0
---
# Spring / JPA / Hibernate Persistence

Design, review, optimize, and debug a JPA/Hibernate data-access layer by applying the best practices distilled from four canonical books: *High-Performance Java Persistence* (Vlad Mihalcea), *Java Persistence with Hibernate* (Bauer, King, Gregory), *Beginning Hibernate 6*, and *Java Hibernate Cookbook*.

**What is covered in this Skill?**

- **Foundations & architecture** — the object/relational impedance mismatch, JPA vs Hibernate, `EntityManagerFactory`/`SessionFactory`, bootstrap with `persistence.xml` and with Spring Boot / Spring Data JPA, schema ownership, and the persistence-layer skill stack
- **Entity mapping basics** — `@Entity`, `@Table`, `@Column`, `@Basic`, `@Transient`, field vs property access, naming strategies, `@Immutable`, `@Formula`/derived properties, temporal types, enums, and JPA `AttributeConverter` (`@Convert`)
- **Identifiers & generators** — `@Id`, `@GeneratedValue` strategies (IDENTITY vs SEQUENCE vs TABLE vs AUTO), why IDENTITY disables JDBC insert batching, sequence optimizers (hi/lo, pooled, pooled-lo), UUID keys, `@NaturalId`, composite keys (`@IdClass`, `@EmbeddedId`), and correct `equals`/`hashCode`
- **Embeddables & value types** — `@Embeddable`/`@Embedded`, `@AttributeOverride`, nested embeddables, and `@ElementCollection`
- **Entity relationships** — `@ManyToOne` (the foundation), bidirectional `@OneToMany` with synchronization helpers, unidirectional `@OneToMany` pitfalls, `@JoinColumn` vs join table, `@OneToOne` (shared primary key, `@MapsId`), modeling `@ManyToMany` as a link entity, and `Set` vs `List`/bag semantics
- **Inheritance mapping** — `SINGLE_TABLE`, `JOINED`, `TABLE_PER_CLASS`, `@MappedSuperclass`, discriminator columns, polymorphic queries, and how to choose
- **Persistence context & entity lifecycle** — entity states (transient, managed, detached, removed), `persist`/`merge`/`remove`/`refresh`/`find`, automatic dirty checking, flush modes, the first-level cache / identity map, `cascade`, and `orphanRemoval`
- **Fetching & the N+1 problem** — LAZY vs EAGER, proxies and `LazyInitializationException`, the N+1 selects and Cartesian-product problems, `JOIN FETCH`, `@EntityGraph`, `@BatchSize`, subselect fetching, DTO projections, and pagination of fetched collections
- **Queries** — JPQL/HQL, the Criteria API, native SQL with `@SqlResultSetMapping`, parameter binding (never string concatenation), named queries, stored procedures, result streaming, and keyset vs offset pagination
- **Transactions & concurrency control** — ACID, isolation levels and anomalies (dirty/non-repeatable/phantom reads, lost update, write skew), declarative `@Transactional` boundaries, optimistic locking with `@Version`, pessimistic locking with `LockModeType`, application-level (extended) conversations, and read-only transactions
- **JDBC-level performance** — connection pooling (HikariCP), JDBC statement batching (`order_inserts`, `order_updates`, `batch_size`), server-side and client-side statement caching, and `ResultSet` fetch size
- **Caching** — first-level (persistence context), the second-level cache and its concurrency strategies (READ_ONLY, NONSTRICT_READ_WRITE, READ_WRITE, TRANSACTIONAL), `@Cache`, collection cache, the query cache, and cache pitfalls
- **Bulk operations & batching** — bulk JPQL `UPDATE`/`DELETE`, batched insert/update loops with periodic `flush()`+`clear()`, and `StatelessSession`
- **Auditing, events & filters** — Hibernate Envers (`@Audited`), JPA lifecycle callbacks and entity listeners, `@CreationTimestamp`/`@UpdateTimestamp`, and dynamic `@Filter`
- **Monitoring & diagnostics** — SQL statement logging, Hibernate `Statistics`, `datasource-proxy`/P6Spy, and asserting executed-statement counts in integration tests

## Constraints

Persistence-layer changes can silently alter generated SQL, transaction behavior, locking, and data integrity. Validate before and after every change.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying any change.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; report failures honestly with the real output and do not claim success until the build and tests pass.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **OBSERVE THE SQL**: Reason about the SQL Hibernate generates, not just the Java. Enable statement logging (or `datasource-proxy`/P6Spy) and confirm the actual `SELECT`/`INSERT`/`UPDATE`/`DELETE` statements and their count before and after a change — many JPA bugs (N+1, accidental EAGER, lost batching) are invisible at the Java level.
- **PRESERVE DATA INTEGRITY**: Changes to cascading, `orphanRemoval`, fetch type, locking, or identifier generators can delete data, deadlock, or corrupt state. Treat them as behavior-changing and confirm intent.
- **NEVER CONCATENATE QUERY INPUT**: All JPQL/HQL/native query input must use bind parameters; never build queries by string concatenation of user input (SQL-injection risk).
- **TRANSACTION BOUNDARIES**: Lazy loading, dirty checking, and flushing only work inside an open persistence context/transaction. Keep service-method boundaries explicit and do not leak entities to a view rendered after the context closes.
- **INCREMENTAL**: Apply one change at a time and re-validate (compile + tests + observed SQL); never batch many mapping/fetch/locking changes without intermediate verification.
- **BEFORE APPLYING**: Read the reference for the full catalog of practices with Good/Bad examples and rationale.

## When to use this skill

- Review or optimize JPA/Hibernate entity mappings, associations, or inheritance
- Diagnose and fix N+1 select queries, Cartesian products, or `LazyInitializationException`
- Explain why Hibernate is slow or emits unexpected/too many SQL statements
- Choose an identifier generator (and recover JDBC batching lost to IDENTITY)
- Add optimistic (`@Version`) or pessimistic (`LockModeType`) locking and fix lost updates
- Configure JDBC batching, the second-level / query cache, or connection pooling
- Write efficient JPQL, Criteria, native, or DTO-projection queries and pagination
- Bootstrap or audit a Spring Data JPA / Hibernate persistence layer

## Workflow

1. **Validate the project before recommendations**

   Run `./mvnw compile` or `mvn compile` and stop if compilation fails.

2. **Read the reference, see the SQL, and analyze the mappings**

   Read `references/spring-jpa-hibernate-book.md`. Enable SQL statement logging (and ideally `datasource-proxy`/P6Spy with statement counts), then inspect the target entities, repositories/DAOs, and the actual generated SQL. Map each smell to a specific practice in the reference.

3. **Categorize and prioritize findings**

   Group by impact (CRITICAL correctness/data-integrity/security, PERFORMANCE, MAINTAINABILITY, READABILITY) and by topic (mapping, identifiers, associations, inheritance, lifecycle, fetching, queries, transactions, JDBC performance, caching). Order remediation: quick, low-risk wins (bind parameters, LAZY associations, DTO projections, `@BatchSize`) before structural changes (identifier-generator swaps, inheritance restructuring, second-level cache).

4. **Apply improvements incrementally and verify**

   Apply one practice at a time, preserving observable behavior and data integrity, and re-run `./mvnw clean verify` plus confirm the generated SQL after each change. Cite each applied practice by its section and title.

## Reference

For the full catalog of practices with rationale and Good/Bad examples, see [references/spring-jpa-hibernate-book.md](references/spring-jpa-hibernate-book.md).
