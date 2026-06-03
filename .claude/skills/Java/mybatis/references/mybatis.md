# MyBatis 3 — SQL Mapping for Java with Full Control of the SQL

## Role

You are a Senior Java engineer who applies MyBatis 3 idiomatically. You write hand-crafted SQL and let MyBatis bind parameters and map result sets — you do not let SQL become invisible. You reason about the *actual SQL that runs* and the *exact column→property mapping*, you bind every user value with `#{}`, you keep `SqlSession` lifecycle correct, and you know the traps (N+1 from nested `select`, `${}` injection, generated keys, local-cache mutation, `mapUnderscoreToCamelCase`).

## Goal

This reference synthesizes the official MyBatis 3 Reference Documentation — *Getting Started*, *Configuration XML*, *Mapper XML Files*, *Dynamic SQL*, and *Java API* — into concrete, applicable practices organized by area. Each practice states what to do with a short rationale and shows code; where useful it shows the **generated SQL** or the **mapped result**, and a **Pitfall** line calling out a real misuse. Practices are numbered by chapter (e.g. "4.3 Map a one-to-many with `<collection>`"). When you apply one, cite it by chapter section and title.

## Version covered

- Target: **MyBatis 3.5.x** — `groupId:artifactId` = `org.mybatis:mybatis`. Documentation snapshot **3.5.19** (last published 2025-01-02).
- Many features carry a **Since** note (e.g. `${name:default}` since 3.4.2, `defaultEnumTypeHandler` since 3.4.5, named constructor args since 3.4.3, repeatable `@Result`/`@Arg` since 3.5.4, `defaultSqlProviderType` since 3.5.6, `shrinkWhitespacesInSql` since 3.5.5, `nullableOnForEach` since 3.5.9, `argNameBasedConstructorAutoMapping` since 3.5.10). See **Appendix C** for the table. MyBatis is strongly backward compatible within the 3.5.x line.
- Companion modules (not part of the 5 core docs, but commonly used): **`mybatis-spring`** and **`mybatis-spring-boot-starter`** integrate MyBatis into Spring's transaction and DI model. See **Appendix D**.

## Constraints

MyBatis executes the SQL you write against a real database. The build, the running query (visible via SQL logging), and the schema are the sources of truth.

- **MANDATORY**: After changes, compile (`./mvnw compile` / `./gradlew compileJava`). XML parsing errors, unknown statement ids, and result-mapping errors surface at SqlSessionFactory build or first statement execution.
- **`#{}` FOR VALUES, `${}` ONLY FOR TRUSTED IDENTIFIERS**: `#{}` becomes a `?` placeholder bound safely; `${}` is raw text substitution. User input via `${}` = SQL injection. See 3.3.
- **SESSION LIFECYCLE**: `SqlSession` is not thread-safe — request/method scope, try-with-resources, never a field. `SqlSessionFactory` is an application singleton. See 1.6. In Spring, let `mybatis-spring` own sessions/transactions.
- **READ THE SQL**: Turn on `logImpl`/the framework logger to see the exact statement and bound parameters before debugging a mapping.
- **VERSION AWARENESS**: Gate newer settings/features on the project's version (Appendix C).
- **N+1**: Nested `select` in `<association>`/`<collection>` runs one query per parent. Prefer nested results (join) for always-needed relations; `fetchType="lazy"` for rarely-needed ones. See 4.3, 4.4.
- **GENERATED KEYS**: `useGeneratedKeys` + `keyProperty` (auto-increment) or `<selectKey>` (sequence/identity) write the key back into the parameter bean. See 3.2.
- **DON'T MUTATE RESULTS**: Default local cache (`SESSION`) and read/write 2nd-level cache may return shared references. Treat results as read-only. See 6.4, 4.6.
- **BEFORE APPLYING**: Read the relevant chapter section for attributes, defaults, and the pitfall.

## Examples

### Table of contents

**Chapter 1 — Setup & core objects (Getting Started)**
- 1.1 Add MyBatis as a dependency
- 1.2 Build a `SqlSessionFactory` from `mybatis-config.xml`
- 1.3 Build a `SqlSessionFactory` without XML (Java `Configuration`)
- 1.4 Open and use a `SqlSession` with try-with-resources
- 1.5 Map SQL with an XML mapper or with annotations
- 1.6 Respect scope & lifecycle (Builder/Factory/Session/Mapper)

**Chapter 2 — Configuration XML (`mybatis-config.xml`)**
- 2.1 Order the top-level elements correctly
- 2.2 Externalize values with `<properties>` (+ `${name:default}`)
- 2.3 Tune behavior with `<settings>`
- 2.4 Shorten class names with `<typeAliases>`
- 2.5 Convert types with `<typeHandlers>` (incl. enums)
- 2.6 Customize instantiation with `<objectFactory>`
- 2.7 Intercept the engine with `<plugins>`/`Interceptor`
- 2.8 Configure `<environments>` (transaction manager + data source)
- 2.9 Branch by vendor with `<databaseIdProvider>`
- 2.10 Register mappers four ways with `<mappers>`

**Chapter 3 — Mapper XML: statements & parameters**
- 3.1 Write a `<select>` and control its attributes
- 3.2 Write `<insert>`/`<update>`/`<delete>` and return generated keys
- 3.3 Use `#{}` for values and `${}` only for trusted identifiers
- 3.4 Reuse SQL fragments with `<sql>`/`<include>`

**Chapter 4 — Mapper XML: result maps & caching**
- 4.1 Map columns to a type with `resultType` / `<resultMap>` (auto-mapping)
- 4.2 Map immutable types with `<constructor>`
- 4.3 Map a one-to-one with `<association>`
- 4.4 Map a one-to-many with `<collection>`
- 4.5 Switch mapping by a column with `<discriminator>` and `extends`
- 4.6 Cache a namespace with `<cache>` / `<cache-ref>`

**Chapter 5 — Dynamic SQL**
- 5.1 Conditionally include SQL with `<if>`
- 5.2 Pick one branch with `<choose>`/`<when>`/`<otherwise>`
- 5.3 Build a safe `WHERE` with `<where>`
- 5.4 Build a safe `UPDATE` `SET` with `<set>`
- 5.5 Take full control with `<trim>`
- 5.6 Iterate a collection with `<foreach>` (IN clauses, batch insert)
- 5.7 Pre-compute a variable with `<bind>`
- 5.8 Target a database vendor with `_databaseId`
- 5.9 Use dynamic SQL in annotations (`<script>`) and pluggable languages

**Chapter 6 — Java API: SqlSession & mapper interfaces**
- 6.1 Build the factory and open sessions (`ExecutorType`, autoCommit, isolation)
- 6.2 Run statements with the `SqlSession` methods (`RowBounds`, `ResultHandler`, `Cursor`)
- 6.3 Batch writes with `ExecutorType.BATCH` and `flushStatements()`
- 6.4 Control transactions and the local cache
- 6.5 Prefer mapper interfaces; name parameters with `@Param`

**Chapter 7 — Annotation-based mappers**
- 7.1 Statement annotations + `@Options`
- 7.2 Result mapping with `@Results`/`@Result`/`@One`/`@Many` (and `@ConstructorArgs`)
- 7.3 Keys, maps, flush, and reuse: `@SelectKey`/`@MapKey`/`@Flush`/`@ResultMap`
- 7.4 Build SQL dynamically with providers (`@SelectProvider` + the `SQL` class)

**Appendix A — `settings` keys reference**
**Appendix B — Built-in type aliases & type handlers**
**Appendix C — Feature → since-version table**
**Appendix D — Setup snippets (Maven/Gradle/Spring Boot) & common pitfalls**

---

## Chapter 1 — Setup & core objects (Getting Started)

### [1.1] Add MyBatis as a dependency

Title: Put `org.mybatis:mybatis` on the classpath (plus your JDBC driver).
Description: MyBatis is a single runtime jar; you also need the JDBC driver for your database. In Spring Boot, prefer the starter (Appendix D) which pulls MyBatis transitively and auto-configures the factory.

**Maven:**

```xml
<dependency>
  <groupId>org.mybatis</groupId>
  <artifactId>mybatis</artifactId>
  <version>3.5.19</version>
</dependency>
```

**Gradle:**

```gradle
implementation 'org.mybatis:mybatis:3.5.19'
runtimeOnly 'org.postgresql:postgresql' // your JDBC driver
```

**Pitfall:** Forgetting the JDBC driver yields a runtime "No suitable driver" failure at `openSession()`, not at build time.

### [1.2] Build a `SqlSessionFactory` from `mybatis-config.xml`

Title: Read the XML config through `Resources` and build the factory once.
Description: The `SqlSessionFactory` is the core object. The XML route is the most common: a `mybatis-config.xml` declares the environment (transaction manager + data source) and the mappers. Build it **once** at startup.

**With MyBatis (Java):**

```java
String resource = "org/mybatis/example/mybatis-config.xml";
InputStream inputStream = Resources.getResourceAsStream(resource);
SqlSessionFactory sqlSessionFactory =
  new SqlSessionFactoryBuilder().build(inputStream);
```

**Minimal `mybatis-config.xml`:**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
  PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
  "https://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC"/>
      <dataSource type="POOLED">
        <property name="driver" value="${driver}"/>
        <property name="url" value="${url}"/>
        <property name="username" value="${username}"/>
        <property name="password" value="${password}"/>
      </dataSource>
    </environment>
  </environments>
  <mappers>
    <mapper resource="org/mybatis/example/BlogMapper.xml"/>
  </mappers>
</configuration>
```

**Pitfall:** Use `Resources.getResourceAsStream` (classpath) — a bare `new FileInputStream("mybatis-config.xml")` breaks once packaged in a jar.

### [1.3] Build a `SqlSessionFactory` without XML (Java `Configuration`)

Title: Assemble `Environment` + `Configuration` programmatically when you prefer code over XML.
Description: Everything the XML expresses is available on the `Configuration` object. Construct a `DataSource`, a `TransactionFactory`, an `Environment`, then a `Configuration`, register mappers, and build.

**With MyBatis:**

```java
DataSource dataSource = BlogDataSourceFactory.getBlogDataSource();
TransactionFactory transactionFactory = new JdbcTransactionFactory();
Environment environment =
  new Environment("development", transactionFactory, dataSource);
Configuration configuration = new Configuration(environment);
configuration.addMapper(BlogMapper.class);          // annotation/interface mapper
SqlSessionFactory sqlSessionFactory =
  new SqlSessionFactoryBuilder().build(configuration);
```

**Pitfall:** When you build from a `Configuration`, MyBatis does **not** parse a `mybatis-config.xml` — every setting, alias, type handler, and mapper must be registered on the object (`configuration.setMapUnderscoreToCamelCase(true)`, `configuration.getTypeHandlerRegistry().register(...)`, `configuration.addMapper(...)`).

### [1.4] Open and use a `SqlSession` with try-with-resources

Title: Acquire a `SqlSession` from the factory, run statements, and always close it.
Description: The `SqlSession` runs SQL and manages a connection + transaction. Use it through a mapper interface (preferred, type-safe) or via the statement-id string (legacy). Always close it — try-with-resources is the idiom.

**Preferred — mapper interface:**

```java
try (SqlSession session = sqlSessionFactory.openSession()) {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  Blog blog = mapper.selectBlog(101);
}
```

**Legacy — statement id string:**

```java
try (SqlSession session = sqlSessionFactory.openSession()) {
  Blog blog = session.selectOne(
    "org.mybatis.example.BlogMapper.selectBlog", 101);
}
```

**Pitfall:** `openSession()` (no args) starts a transaction with **autocommit off** — you must call `session.commit()` after writes or the changes roll back on close. `openSession(true)` autocommits each statement. See 6.4.

### [1.5] Map SQL with an XML mapper or with annotations

Title: Declare each mapped statement in an XML mapper (`namespace` = the interface FQN) or with annotations on the interface.
Description: The two styles are interchangeable per method. XML is best for complex/dynamic SQL and result maps; annotations are concise for short static statements. The XML `namespace` must equal the mapper interface's fully-qualified name, and statement `id` must match the method name.

**XML mapper (`BlogMapper.xml`):**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
  PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="org.mybatis.example.BlogMapper">
  <select id="selectBlog" resultType="Blog">
    select * from Blog where id = #{id}
  </select>
</mapper>
```

**Annotation mapper (same interface):**

```java
package org.mybatis.example;
public interface BlogMapper {
  @Select("SELECT * FROM Blog WHERE id = #{id}")
  Blog selectBlog(int id);
}
```

**Pitfall:** Defining the **same** statement id both in XML and via an annotation on the interface throws a "mapped statement collision" at startup. Pick one style per method.

### [1.6] Respect scope & lifecycle (Builder/Factory/Session/Mapper)

Title: Builder = method scope; Factory = application singleton; Session = request/method; Mapper = method scope.
Description: Getting lifecycle wrong is the most common production bug. Official guidance:

- **`SqlSessionFactoryBuilder`** — method scope. Instantiate locally, build the factory, discard.
- **`SqlSessionFactory`** — application scope (singleton). Build once and reuse for the app's lifetime; rebuilding repeatedly is a smell.
- **`SqlSession`** — request/method scope, **not thread-safe**. Never store it static or in an instance field; never share across threads. Always close (try-with-resources).
- **Mapper instances** — method scope. Get them from the session where used and discard; they need no explicit close.

**Correct lifecycle:**

```java
// Application startup — build ONCE, keep the reference (singleton/bean)
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(inputStream);

// Per request/unit of work
try (SqlSession session = factory.openSession()) {
  MyMapper mapper = session.getMapper(MyMapper.class);   // method-scoped
  mapper.doWork();
  session.commit();
}
```

**Pitfall:** A `SqlSession` (or a mapper obtained from it) cached in a field and shared between threads causes connection corruption and intermittent errors. In Spring, never `openSession()` by hand in a `@Service` — inject the mapper and let `mybatis-spring` bind a thread-safe session to the current transaction (Appendix D).

## Chapter 2 — Configuration XML (`mybatis-config.xml`)

### [2.1] Order the top-level elements correctly

Title: The config DTD enforces a strict element order — follow it or parsing fails.
Description: Elements must appear in this order (each optional except none is required): `properties`, `settings`, `typeAliases`, `typeHandlers`, `objectFactory`, `plugins`, `environments`, `databaseIdProvider`, `mappers`.

```xml
<configuration>
  <properties .../>
  <settings> ... </settings>
  <typeAliases> ... </typeAliases>
  <typeHandlers> ... </typeHandlers>
  <objectFactory .../>
  <plugins> ... </plugins>
  <environments default="..."> ... </environments>
  <databaseIdProvider .../>
  <mappers> ... </mappers>
</configuration>
```

**Pitfall:** Putting `<settings>` after `<typeAliases>`, or `<mappers>` before `<environments>`, is a DTD validation error at build — the message ("element X not allowed here") points at the misordering, not a typo.

### [2.2] Externalize values with `<properties>` (+ `${name:default}`)

Title: Load DB credentials and tunables from a `.properties` file (or inline), then reference them with `${name}`.
Description: `<properties resource="..."/>` or `url="..."` loads external files; inline `<property>` children provide defaults. Resolution priority (highest first): values passed to `SqlSessionFactoryBuilder.build(..., props)` → `resource`/`url` file → inline `<property>`.

```xml
<properties resource="org/mybatis/example/config.properties">
  <property name="username" value="dev_user"/>   <!-- fallback if absent in file -->
  <property name="password" value="F2Fa3!33TYyg"/>
</properties>
```

**Default values inside placeholders (since 3.4.2):** enable, then use `${name:default}`:

```xml
<properties resource="org/mybatis/example/config.properties">
  <property name="org.apache.ibatis.parsing.PropertyParser.enable-default-value" value="true"/>
  <!-- optional: change the separator from ':' to '?:' -->
  <property name="org.apache.ibatis.parsing.PropertyParser.default-value-separator" value="?:"/>
</properties>
...
<dataSource type="POOLED">
  <property name="url" value="${db.url:jdbc:h2:mem:test}"/>
</dataSource>
```

**Pitfall:** Without enabling `enable-default-value`, `${db.url:jdbc:...}` is treated literally — the `:default` is part of the value, not a fallback.

### [2.3] Tune behavior with `<settings>`

Title: Set the handful of settings that change correctness/behavior; leave the rest at defaults.
Description: `settings` are global switches. The ones that matter most in practice: `mapUnderscoreToCamelCase` (DB `snake_case` → Java `camelCase`), `useGeneratedKeys`, `cacheEnabled`, `lazyLoadingEnabled`, `defaultExecutorType`, `autoMappingBehavior`, `callSettersOnNulls`, `jdbcTypeForNull`, `logImpl`. Full table in **Appendix A**.

```xml
<settings>
  <setting name="mapUnderscoreToCamelCase" value="true"/>
  <setting name="useGeneratedKeys" value="true"/>
  <setting name="cacheEnabled" value="true"/>
  <setting name="lazyLoadingEnabled" value="true"/>
  <setting name="defaultExecutorType" value="SIMPLE"/>
  <setting name="autoMappingBehavior" value="PARTIAL"/>
  <setting name="logImpl" value="SLF4J"/>
</settings>
```

**Pitfall:** `mapUnderscoreToCamelCase` only affects **auto-mapping**; explicit `<result column="user_name" property="userName"/>` entries are unaffected. Setting `aggressiveLazyLoading=true` defeats the point of lazy loading (touching any property loads all lazy ones). `jdbcTypeForNull` defaults to `OTHER`, which some drivers (notably Oracle) reject when binding a `null` — set it to `NULL` or specify `jdbcType` per parameter.

### [2.4] Shorten class names with `<typeAliases>`

Title: Register aliases (or scan a package) so mappers can write `resultType="Blog"` instead of the FQN.
Description: Declare aliases explicitly, or scan a package (each class registers its uncapitalized simple name, or its `@Alias` value). Built-in aliases exist for primitives, wrappers, common types, and collections (Appendix B).

```xml
<typeAliases>
  <typeAlias alias="Author" type="domain.blog.Author"/>
  <package name="domain.blog"/>   <!-- registers Blog, Post, Comment, ... -->
</typeAliases>
```

```java
@Alias("author")
public class Author { ... }   // overrides the default "author" simple-name alias
```

**Pitfall:** Package scanning two classes with the same simple name in different packages collides. Aliases are **case-insensitive**; `Blog` and `blog` refer to the same alias.

### [2.5] Convert types with `<typeHandlers>` (incl. enums)

Title: Register a `TypeHandler` to bridge a Java type and a JDBC column; choose the right enum strategy.
Description: A `TypeHandler` sets a parameter on a `PreparedStatement` and reads a column from a `ResultSet`/`CallableStatement`. Extend `BaseTypeHandler<T>`, annotate the supported Java/JDBC types, and register it (explicitly or by package scan). For enums, MyBatis defaults to `EnumTypeHandler` (stores the **name**); use `EnumOrdinalTypeHandler` to store the **ordinal**.

**Custom handler:**

```java
@MappedTypes(String.class)
@MappedJdbcTypes(JdbcType.VARCHAR)
public class ExampleTypeHandler extends BaseTypeHandler<String> {
  @Override
  public void setNonNullParameter(PreparedStatement ps, int i,
      String parameter, JdbcType jdbcType) throws SQLException {
    ps.setString(i, parameter);
  }
  @Override
  public String getNullableResult(ResultSet rs, String columnName) throws SQLException {
    return rs.getString(columnName);
  }
  @Override
  public String getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
    return rs.getString(columnIndex);
  }
  @Override
  public String getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
    return cs.getString(columnIndex);
  }
}
```

**Registration & enum strategy:**

```xml
<typeHandlers>
  <typeHandler handler="org.mybatis.example.ExampleTypeHandler"/>
  <!-- store this enum by ordinal instead of name -->
  <typeHandler handler="org.apache.ibatis.type.EnumOrdinalTypeHandler"
               javaType="java.math.RoundingMode"/>
  <package name="org.mybatis.handlers"/>   <!-- scan for @MappedTypes handlers -->
</typeHandlers>
```

To change the **global** default enum handler (since 3.4.5): `<setting name="defaultEnumTypeHandler" value="org.apache.ibatis.type.EnumOrdinalTypeHandler"/>`.

**Pitfall:** `EnumOrdinalTypeHandler` ties stored integers to declaration order — **reordering or inserting enum constants silently corrupts existing data**. Prefer the default name-based handler (or a custom handler mapping an explicit `code` column) for persisted enums.

### [2.6] Customize instantiation with `<objectFactory>`

Title: Override how MyBatis instantiates result objects only when you need special construction.
Description: The default `ObjectFactory` uses the default or an arg constructor. Subclass `DefaultObjectFactory` to customize. Rarely needed.

```java
public class ExampleObjectFactory extends DefaultObjectFactory {
  @Override public <T> T create(Class<T> type) { return super.create(type); }
  @Override public void setProperties(Properties properties) { super.setProperties(properties); }
}
```

```xml
<objectFactory type="org.mybatis.example.ExampleObjectFactory">
  <property name="someProperty" value="100"/>
</objectFactory>
```

**Pitfall:** Most "I need a custom ObjectFactory" cases are better solved with `<constructor>` mapping (4.2) or a `TypeHandler` (2.5).

### [2.7] Intercept the engine with `<plugins>`/`Interceptor`

Title: Use a plugin to weave cross-cutting behavior (paging, auditing, sharding) into the four core components.
Description: Plugins intercept methods of `Executor`, `ParameterHandler`, `ResultSetHandler`, `StatementHandler`. Declare the join point with `@Intercepts`/`@Signature` and call `invocation.proceed()`.

```java
@Intercepts({@Signature(
    type = Executor.class,
    method = "update",
    args = {MappedStatement.class, Object.class})})
public class ExamplePlugin implements Interceptor {
  private Properties properties = new Properties();
  @Override
  public Object intercept(Invocation invocation) throws Throwable {
    // pre-processing
    Object returnObject = invocation.proceed();
    // post-processing
    return returnObject;
  }
  @Override public void setProperties(Properties properties) { this.properties = properties; }
}
```

```xml
<plugins>
  <plugin interceptor="org.mybatis.example.ExamplePlugin">
    <property name="someProperty" value="100"/>
  </plugin>
</plugins>
```

Interceptable methods: **Executor** (`update`, `query`, `flushStatements`, `commit`, `rollback`, `getTransaction`, `close`, `isClosed`); **ParameterHandler** (`getParameterObject`, `setParameters`); **ResultSetHandler** (`handleResultSets`, `handleOutputParameters`); **StatementHandler** (`prepare`, `parameterize`, `batch`, `update`, `query`).

**Pitfall:** Plugins override deep MyBatis behavior — a bug here breaks every statement. Prefer a battle-tested plugin (e.g. PageHelper for paging) over a hand-rolled one, and keep the signature as narrow as possible.

### [2.8] Configure `<environments>` (transaction manager + data source)

Title: Each environment pairs a `transactionManager` (JDBC/MANAGED) with a `dataSource` (UNPOOLED/POOLED/JNDI); one factory per environment.
Description: `transactionManager type="JDBC"` uses the connection's own `commit`/`rollback`; `MANAGED` defers to a container (and by default closes the connection — set `closeConnection=false` if the container expects to). `dataSource type="POOLED"` is the built-in connection pool; `UNPOOLED` opens/closes per use; `JNDI` looks up a container datasource.

```xml
<environments default="development">
  <environment id="development">
    <transactionManager type="JDBC">
      <property name="skipSetAutoCommitOnClose" value="true"/>   <!-- since 3.5.10 -->
    </transactionManager>
    <dataSource type="POOLED">
      <property name="driver" value="${driver}"/>
      <property name="url" value="${url}"/>
      <property name="username" value="${username}"/>
      <property name="password" value="${password}"/>
      <property name="poolMaximumActiveConnections" value="10"/>
      <property name="poolMaximumIdleConnections" value="5"/>
      <property name="poolPingEnabled" value="true"/>
      <property name="poolPingQuery" value="SELECT 1"/>
    </dataSource>
  </environment>
</environments>
```

Key `POOLED` properties (defaults): `poolMaximumActiveConnections` (10), `poolMaximumIdleConnections`, `poolMaximumCheckoutTime` (20000ms), `poolTimeToWait` (20000ms), `poolMaximumLocalBadConnectionTolerance` (3, since 3.4.5), `poolPingQuery`, `poolPingEnabled` (false), `poolPingConnectionsNotUsedFor` (0). `UNPOOLED` adds `defaultTransactionIsolationLevel`, `defaultNetworkTimeout`, and `driver.*`-prefixed driver properties.

**Pitfall:** With `transactionManager type="MANAGED"` inside a non-container app, nothing commits/rolls back — your writes vanish. Use `JDBC` for standalone apps. In **Spring**, you do *not* configure `<environments>` at all — `mybatis-spring` provides a Spring-managed `DataSourceTransactionManager` (Appendix D). For production pooling outside Spring, many teams replace the built-in `POOLED` with HikariCP via a custom `DataSourceFactory`.

### [2.9] Branch by vendor with `<databaseIdProvider>`

Title: Register a `databaseIdProvider` so statements can target a specific database; reference it via `databaseId` and `_databaseId`.
Description: `type="DB_VENDOR"` reads `DatabaseMetaData.getDatabaseProductName()`; map raw product names to short ids via `<property>`. Statements with a matching `databaseId` win; a statement with no `databaseId` is the fallback.

```xml
<databaseIdProvider type="DB_VENDOR">
  <property name="SQL Server" value="sqlserver"/>
  <property name="DB2"        value="db2"/>
  <property name="Oracle"     value="oracle"/>
  <property name="PostgreSQL" value="postgres"/>
</databaseIdProvider>
```

**Pitfall:** Without `<property>` mappings, the databaseId is the full product name (e.g. `"PostgreSQL 16.2"`), which rarely matches your `databaseId="postgres"`. Always map the names you target. See 5.8 for `_databaseId` in dynamic SQL.

### [2.10] Register mappers four ways with `<mappers>`

Title: Point MyBatis at your mapped statements via classpath resource, URL, interface class, or package scan.
Description: Four equivalent registration styles. For interface mappers whose XML sits beside the `.class` (same package + same base name), `class`/`package` scanning loads both.

```xml
<mappers>
  <!-- 1. classpath XML resource -->
  <mapper resource="org/mybatis/builder/BlogMapper.xml"/>
  <!-- 2. absolute URL -->
  <mapper url="file:///var/mappers/AuthorMapper.xml"/>
  <!-- 3. mapper interface class (loads BlogMapper.xml beside it, if present) -->
  <mapper class="org.mybatis.builder.PostMapper"/>
  <!-- 4. scan a package for all interfaces -->
  <package name="org.mybatis.builder"/>
</mappers>
```

**Pitfall:** With `class`/`package` registration, the XML mapper must be in the **same package** as the interface and named `<Interface>.xml`. If Maven doesn't copy `*.xml` from `src/main/java`, add a `<resource>` include (Appendix D) or the XML is silently absent → "Invalid bound statement (not found)".

## Chapter 3 — Mapper XML: statements & parameters

### [3.1] Write a `<select>` and control its attributes

Title: A `<select>` maps a query to `resultType`/`resultMap`; tune caching and fetching via attributes.
Description: Common attributes: `id` (required, matches the method), `parameterType` (usually inferred), `resultType` **or** `resultMap` (not both), `useCache` (default `true`), `flushCache` (default `false` for selects), `timeout`, `fetchSize`, `statementType` (`PREPARED` default; `CALLABLE` for stored procs), `resultSetType`, `databaseId`.

```xml
<select id="selectPerson" parameterType="int" resultType="hashmap"
        useCache="true" timeout="10" fetchSize="256">
  SELECT id, first_name, last_name FROM person WHERE id = #{id}
</select>
```

**Pitfall:** Setting both `resultType` and `resultMap` is an error. `resultType="hashmap"` returns a `Map<String,Object>` keyed by column label — handy for ad-hoc queries but loses type safety; prefer a POJO/record `resultType` or a `resultMap` for real code.

### [3.2] Write `<insert>`/`<update>`/`<delete>` and return generated keys

Title: Write statements that return affected-row counts; capture an auto-generated PK with `useGeneratedKeys` or `<selectKey>`.
Description: `insert`/`update`/`delete` default to `flushCache="true"`. To read a database-generated id back into the parameter bean, use `useGeneratedKeys="true" keyProperty="id"` (auto-increment columns; MySQL/SQL Server/PostgreSQL). For sequences or DBs without `getGeneratedKeys`, use `<selectKey>` — `order="BEFORE"` (fetch the next sequence value, then insert) or `order="AFTER"` (insert, then read the identity).

**Auto-increment:**

```xml
<insert id="insertAuthor" useGeneratedKeys="true" keyProperty="id">
  insert into Author (username, password, email, bio)
  values (#{username}, #{password}, #{email}, #{bio})
</insert>
```

**Sequence (`order="BEFORE"`):**

```xml
<insert id="insertAuthor">
  <selectKey keyProperty="id" resultType="int" order="BEFORE">
    select seq_author.nextval from dual
  </selectKey>
  insert into Author (id, username, password, email, bio)
  values (#{id}, #{username}, #{password}, #{email}, #{bio})
</insert>
```

**Multi-row insert with keys:**

```xml
<insert id="insertAuthors" useGeneratedKeys="true" keyProperty="id">
  insert into Author (username, password, email) values
  <foreach item="item" collection="list" separator=",">
    (#{item.username}, #{item.password}, #{item.email})
  </foreach>
</insert>
```

`<selectKey>` attributes: `keyProperty` (target, comma-separated for composite), `keyColumn`, `resultType`, `order` (BEFORE/AFTER), `statementType`.

**Pitfall:** After `insert(...)`, the **return value is the row count**, not the id — read the generated key from the parameter object (`author.getId()`). It only works if the parameter is a mutable bean with the `keyProperty` setter; a primitive/`String` parameter has nowhere to write the key. With `order="BEFORE"` you must include the key column in the `INSERT` (`#{id}`); with `order="AFTER"` you must not.

### [3.3] Use `#{}` for values and `${}` only for trusted identifiers

Title: `#{}` is a bound `PreparedStatement` parameter (safe); `${}` is raw string substitution (injection risk).
Description: `#{value}` compiles to a `?` placeholder and binds the value safely — use it for **every** user-supplied value. `${value}` splices the literal text into the SQL before execution — use it **only** for structural fragments you fully control (table names, column names, sort direction), never for user input. Inside `#{}` you can add `javaType`, `jdbcType`, `typeHandler`, `numericScale`, and `mode` (for stored procedures).

**Safe value binding:**

```xml
<select id="findUser" resultType="User">
  SELECT * FROM users WHERE id = #{id}
</select>
<!-- generated: SELECT * FROM users WHERE id = ?    (id bound) -->
```

**Trusted identifier via `${}` (validated against an allow-list in Java):**

```xml
<select id="findUsersSorted" resultType="User">
  SELECT * FROM users ORDER BY ${orderColumn} ${direction}
</select>
```

**Stored-proc OUT parameter via `mode`:**

```xml
#{department, mode=OUT, jdbcType=CURSOR, javaType=ResultSet, resultMap=deptResultMap}
```

**Pitfall:** `WHERE name = '${name}'` with user input is a textbook SQL-injection hole (`name = "x' OR '1'='1"`). The only safe uses of `${}` are identifiers you validate against a fixed allow-list (e.g. `Set.of("created_at","name").contains(orderColumn)`), never free-form values.

### [3.4] Reuse SQL fragments with `<sql>`/`<include>`

Title: Factor repeated column lists or clauses into a `<sql>` fragment and pull it in with `<include>` (parameterizable via `<property>`).
Description: `<sql id="...">` defines a reusable fragment; `<include refid="...">` inserts it. `<property name="..." value="..."/>` children pass values that the fragment references with `${...}`. Fragment ids can themselves be parameterized.

```xml
<sql id="userColumns"> ${alias}.id, ${alias}.username, ${alias}.password </sql>

<select id="selectUsers" resultType="map">
  select
    <include refid="userColumns"><property name="alias" value="t1"/></include>,
    <include refid="userColumns"><property name="alias" value="t2"/></include>
  from some_table t1 cross join some_table t2
</select>
```

**Pitfall:** Because fragment `${}` substitution is string-based, never feed user input into an `<include>` property. Cross-namespace include needs the fully-qualified `refid` (`otherNamespace.userColumns`).

## Chapter 4 — Mapper XML: result maps & caching

### [4.1] Map columns to a type with `resultType` / `<resultMap>` (auto-mapping)

Title: Let auto-mapping handle simple column→property matches; declare a `<resultMap>` when names differ or relations are involved.
Description: With `resultType`, MyBatis auto-maps each column to the same-named property (case-insensitive; underscores handled if `mapUnderscoreToCamelCase=true`). When column and property names diverge, either alias the columns in SQL **or** declare a `<resultMap>` with explicit `<id>`/`<result>` entries. Always mark the primary key with `<id>` (it drives identity and nested-result grouping). `autoMappingBehavior`: `NONE`, `PARTIAL` (default — auto-maps top level but not nested), `FULL`.

**Auto-mapping by column alias:**

```xml
<select id="selectUsers" resultType="User">
  select user_id as "id", user_name as "userName", hashed_password as "hashedPassword"
  from some_table where id = #{id}
</select>
```

**Explicit `<resultMap>`:**

```xml
<resultMap id="userResultMap" type="User">
  <id     property="id"       column="user_id"/>
  <result property="username" column="user_name"/>
  <result property="password" column="hashed_password"/>
</resultMap>

<select id="selectUsers" resultMap="userResultMap">
  select user_id, user_name, hashed_password from some_table where id = #{id}
</select>
```

`<id>`/`<result>` attributes: `property`, `column`, `javaType`, `jdbcType`, `typeHandler`. `<resultMap>` attributes: `id`, `type`, `autoMapping`, `extends`.

**Pitfall:** `autoMappingBehavior=FULL` on a join can map a joined column to the wrong same-named property (e.g. both tables have `name`). Keep it `PARTIAL` and map relations explicitly. A missing `<id>` makes nested-result de-duplication (4.4) fail — duplicate child rows.

### [4.2] Map immutable types with `<constructor>`

Title: Use `<constructor>` (`<idArg>`/`<arg>`) to build records or constructor-only types from result columns.
Description: For immutable types (Java `record`, constructor-injected classes), map columns to constructor arguments. Mark the key arg with `<idArg>`. Order matters unless you supply `name` (since 3.4.3) to match by parameter name (compile with `-parameters`, or rely on `argNameBasedConstructorAutoMapping` since 3.5.10).

```xml
<resultMap id="userMap" type="User">
  <constructor>
    <idArg column="id"       javaType="int"    name="id"/>
    <arg    column="user_name" javaType="String" name="username"/>
    <arg    column="age"     javaType="_int"   name="age"/>
  </constructor>
</resultMap>
```

```java
public record User(int id, String username, int age) {}
```

**Pitfall:** Without `name` (or `-parameters`), args bind **by position** — reordering the constructor silently misassigns columns. Note `javaType="int"` (boxed `Integer`) vs `javaType="_int"` (primitive `int`); pick the alias matching the constructor signature (Appendix B).

### [4.3] Map a one-to-one with `<association>`

Title: Map a has-one relation either by a join (nested results) or by a second query (nested select); prefer the join for data you always need.
Description: `<association property="author" javaType="Author">` maps an embedded object. Two strategies:

**Nested results (single join query — no N+1):**

```xml
<select id="selectBlog" resultMap="blogResult">
  select B.id as blog_id, B.title as blog_title,
         A.id as author_id, A.username as author_username
  from Blog B left outer join Author A on B.author_id = A.id
  where B.id = #{id}
</select>

<resultMap id="blogResult" type="Blog">
  <id     property="id"    column="blog_id"/>
  <result property="title" column="blog_title"/>
  <association property="author" javaType="Author">
    <id     property="id"       column="author_id"/>
    <result property="username" column="author_username"/>
  </association>
</resultMap>
```

**Nested select (a second query per row — N+1, lazy-capable):**

```xml
<resultMap id="blogResult" type="Blog">
  <association property="author" column="author_id" javaType="Author"
              select="selectAuthor" fetchType="lazy"/>
</resultMap>
<select id="selectAuthor" resultType="Author">
  SELECT * FROM Author WHERE id = #{id}
</select>
```

Nested-results attributes: `resultMap`, `columnPrefix` (reuse a result map under a prefix), `notNullColumn`, `autoMapping`. Nested-select attributes: `column` (passed to the child; composite `column="{id=author_id,k=other}"`), `select`, `fetchType` (`lazy`/`eager`, overrides the global setting).

**Pitfall:** Nested `select` runs one extra query per parent row (N+1). For a relation you always read, use the **join** form. `fetchType="lazy"` requires `lazyLoadingEnabled=true` and a proxy library (Javassist by default); touching any property may trigger the load (tune `lazyLoadTriggerMethods`).

### [4.4] Map a one-to-many with `<collection>`

Title: Map a has-many relation; prefer nested results (one join, grouped by `<id>`) and be deliberate about N+1.
Description: `<collection property="posts" ofType="Post">` maps a `List`/`Set`. Same two strategies as `<association>`. Nested results groups child rows under each parent **using the parent's `<id>`** — so a correct `<id>` is mandatory.

**Nested results:**

```xml
<select id="selectBlog" resultMap="blogResult">
  select B.id as blog_id, B.title as blog_title,
         P.id as post_id, P.subject as post_subject, P.body as post_body
  from Blog B left outer join Post P on B.id = P.blog_id
  where B.id = #{id}
</select>

<resultMap id="blogResult" type="Blog">
  <id     property="id"    column="blog_id"/>
  <result property="title" column="blog_title"/>
  <collection property="posts" ofType="Post">
    <id     property="id"      column="post_id"/>
    <result property="subject" column="post_subject"/>
    <result property="body"    column="post_body"/>
  </collection>
</resultMap>
```

**Nested select (lazy):**

```xml
<resultMap id="blogResult" type="Blog">
  <collection property="posts" javaType="ArrayList" column="id" ofType="Post"
              select="selectPostsForBlog" fetchType="lazy"/>
</resultMap>
<select id="selectPostsForBlog" resultType="Post">
  SELECT * FROM Post WHERE blog_id = #{id}
</select>
```

**Pitfall:** With nested results and **no `<id>`**, MyBatis cannot tell which rows belong to the same parent — you get duplicate or merged collections. Nested-result joins multiply rows (one Blog × N Posts), so combining two collections in one join is a cartesian explosion — use separate queries or nested `select` there. `RowBounds` paging over a nested-result collection paginates the flattened rows, not the parents.

### [4.5] Switch mapping by a column with `<discriminator>` and `extends`

Title: Choose a sub-mapping based on a column value (`<discriminator>`/`<case>`), and share common columns with `extends`.
Description: A `<discriminator>` inspects a column and picks a `<case>` → a `resultMap` (often `extends`-ing a base map) or an inline result type. Useful for single-table inheritance.

```xml
<resultMap id="vehicleResult" type="Vehicle">
  <id     property="id"  column="id"/>
  <result property="vin" column="vin"/>
  <discriminator javaType="int" column="vehicle_type">
    <case value="1" resultMap="carResult"/>
    <case value="2" resultMap="truckResult"/>
  </discriminator>
</resultMap>

<resultMap id="carResult" type="Car" extends="vehicleResult">
  <result property="doorCount" column="door_count"/>
</resultMap>
```

**Pitfall:** Each `<case>`'s result map must map the discriminator-specific columns; columns absent for a given type stay null. `extends` must reference a map in the **same namespace** (or fully-qualified).

### [4.6] Cache a namespace with `<cache>` / `<cache-ref>`

Title: Add `<cache/>` to enable a per-namespace second-level cache; tune eviction/size/readOnly; share with `<cache-ref>`.
Description: A bare `<cache/>` enables an LRU, no-time-flush, 1024-entry, read/write cache: selects are cached; any insert/update/delete in the namespace flushes it. Tune via attributes. `readOnly="true"` returns **shared** instances (fast, but callers must not mutate); `readOnly="false"` (default) returns serialized copies (safe to mutate, requires `Serializable` results). `<cache-ref>` shares one cache across namespaces.

```xml
<cache eviction="LRU" flushInterval="60000" size="512" readOnly="false" blocking="false"/>
<!-- or share another namespace's cache -->
<cache-ref namespace="com.example.SomeMapper"/>
```

`<cache>` attributes (defaults): `eviction` (LRU; also FIFO/SOFT/WEAK), `flushInterval` (none), `size` (1024), `readOnly` (false), `blocking` (false), `type` (custom `org.apache.ibatis.cache.Cache`).

**Pitfall:** The second-level cache requires `cacheEnabled=true` (global, default true) **and** `<cache/>` in the namespace. It only caches within one `SqlSessionFactory` and only flushes on writes **through MyBatis in the same namespace** — external writes or writes via another namespace produce stale reads. With `readOnly=true`, mutating a returned object corrupts the cache for all callers. In Spring, the default `SESSION` local cache is per-session; the cross-request 2nd-level cache is what `<cache/>` controls.

## Chapter 5 — Dynamic SQL

### [5.1] Conditionally include SQL with `<if>`

Title: Append a clause only when a test (OGNL) is true.
Description: `<if test="...">` includes its body when the OGNL expression evaluates true. The canonical use is optional filters.

```xml
<select id="findActiveBlogLike" resultType="Blog">
  SELECT * FROM Blog WHERE state = 'ACTIVE'
  <if test="title != null">
    AND title like #{title}
  </if>
  <if test="author != null and author.name != null">
    AND author_name like #{author.name}
  </if>
</select>
```

**Pitfall:** Hard-coding a leading real condition (`WHERE state = 'ACTIVE'`) just so each `<if>` can prepend `AND` is brittle — prefer `<where>` (5.3) which manages the leading `AND`/`OR`. OGNL string equality uses `==`; for char-vs-string surprises, compare with `.toString()` or `'Y'.equals(flag)`-style helpers.

### [5.2] Pick one branch with `<choose>`/`<when>`/`<otherwise>`

Title: Use `<choose>` for mutually-exclusive branches (switch/case semantics).
Description: MyBatis evaluates `<when>` blocks in order, includes the **first** true one, and falls back to `<otherwise>` if none match.

```xml
<select id="findActiveBlogLike" resultType="Blog">
  SELECT * FROM Blog WHERE state = 'ACTIVE'
  <choose>
    <when test="title != null">           AND title like #{title}              </when>
    <when test="author != null and author.name != null"> AND author_name like #{author.name} </when>
    <otherwise>                            AND featured = 1                      </otherwise>
  </choose>
</select>
```

**Pitfall:** `<choose>` includes **only one** branch — if you actually want several optional filters at once, use multiple `<if>`s, not `<choose>`.

### [5.3] Build a safe `WHERE` with `<where>`

Title: Wrap conditions in `<where>`; it inserts `WHERE` only when something matches and strips a leading `AND`/`OR`.
Description: `<where>` emits the `WHERE` keyword only if at least one child produces output, and trims a leading `AND ` or `OR ` — so every `<if>` can start with `AND` uniformly.

```xml
<select id="findActiveBlogLike" resultType="Blog">
  SELECT * FROM Blog
  <where>
    <if test="state != null">  state = #{state}                </if>
    <if test="title != null">  AND title like #{title}         </if>
    <if test="author != null and author.name != null"> AND author_name like #{author.name} </if>
  </where>
</select>
```

**Pitfall:** `<where>` only strips a **leading** `AND`/`OR`, not trailing ones. For a custom prefix/override use `<trim>` (5.5).

### [5.4] Build a safe `UPDATE` `SET` with `<set>`

Title: Wrap assignments in `<set>`; it inserts `SET` and strips the trailing comma.
Description: `<set>` emits `SET` and removes a trailing `,` so each optional `<if>` can end with a comma.

```xml
<update id="updateAuthorIfNecessary">
  update Author
  <set>
    <if test="username != null">username=#{username},</if>
    <if test="password != null">password=#{password},</if>
    <if test="email != null">email=#{email},</if>
    <if test="bio != null">bio=#{bio}</if>
  </set>
  where id=#{id}
</update>
```

**Pitfall:** If **every** `<if>` is false, `<set>` produces an empty body → `update Author where id=?`, a syntax error. Guard the call so at least one field is non-null, or include a non-optional assignment.

### [5.5] Take full control with `<trim>`

Title: Use `<trim>` when `<where>`/`<set>` don't fit — set `prefix`, `prefixOverrides`, `suffix`, `suffixOverrides`.
Description: `<where>` and `<set>` are specializations of `<trim>`. `prefixOverrides`/`suffixOverrides` are `|`-separated tokens stripped from the start/end before the prefix/suffix is added.

```xml
<!-- equivalent to <where> -->
<trim prefix="WHERE" prefixOverrides="AND |OR ">
  ...
</trim>
<!-- equivalent to <set> -->
<trim prefix="SET" suffixOverrides=",">
  ...
</trim>
```

**Pitfall:** Note the **trailing spaces** in `prefixOverrides="AND |OR "` — `"AND"` without the space would also strip the `AND` inside a column name like `BRAND`. Keep the space.

### [5.6] Iterate a collection with `<foreach>` (IN clauses, batch insert)

Title: Loop over a `List`/array/`Map` with `<foreach>` to build `IN (...)` lists, multi-row `VALUES`, or batch conditions.
Description: `collection` names the parameter (`list` for a bare `List`, `array` for an array, `collection` for a `Collection`, or the `@Param` name); `item` is the element, `index` the position (or the key for a `Map`); `open`/`close`/`separator` wrap the output. `nullable="true"` (since 3.5.9; default via `nullableOnForEach`) tolerates a null collection.

**IN clause:**

```xml
<select id="selectPostIn" resultType="domain.blog.Post">
  SELECT * FROM Post P
  <where>
    <foreach item="item" index="index" collection="list"
             open="ID in (" separator="," close=")" nullable="true">
      #{item}
    </foreach>
  </where>
</select>
```

**Multi-row insert:**

```xml
<insert id="insertAuthors">
  insert into Author (username, email) values
  <foreach item="a" collection="list" separator=",">
    (#{a.username}, #{a.email})
  </foreach>
</insert>
```

**Pitfall:** An **empty** collection produces `ID in ()` — invalid SQL. Guard with an `<if test="list != null and !list.isEmpty()">` around the `<foreach>`, or skip the clause. Very large `IN` lists hit driver/DB limits (e.g. Oracle's 1000); chunk them. For thousands of rows, prefer `ExecutorType.BATCH` (6.3) over one giant multi-row insert.

### [5.7] Pre-compute a variable with `<bind>`

Title: Use `<bind>` to compute an OGNL value once and reference it as a `#{}` parameter — e.g. a safe LIKE pattern.
Description: `<bind name="..." value="OGNL"/>` creates a variable in the statement scope. The classic use is building a `LIKE` pattern without database-specific concatenation and without `${}`.

```xml
<select id="selectBlogsLike" resultType="Blog">
  <bind name="pattern" value="'%' + _parameter.getTitle() + '%'"/>
  SELECT * FROM Blog WHERE title LIKE #{pattern}
</select>
```

**Pitfall:** `<bind>` builds the value in Java/OGNL and binds it via `#{}` (safe) — don't fall back to `WHERE title LIKE '%${title}%'`, which is injectable. `_parameter` is the whole parameter object; with `@Param` use the named property instead.

### [5.8] Target a database vendor with `_databaseId`

Title: Branch SQL on the configured `_databaseId` for portable mappers.
Description: When a `<databaseIdProvider>` (2.9) is configured, the `_databaseId` variable is available in dynamic SQL (and statements can carry a `databaseId` attribute).

```xml
<insert id="insert">
  <selectKey keyProperty="id" resultType="int" order="BEFORE">
    <if test="_databaseId == 'oracle'">select seq_users.nextval from dual</if>
    <if test="_databaseId == 'db2'">select nextval for seq_users from sysibm.sysdummy1</if>
  </selectKey>
  insert into users values (#{id}, #{name})
</insert>
```

**Pitfall:** `_databaseId` is `null` unless a `databaseIdProvider` is registered and maps the running DB's product name — otherwise every `<if test="_databaseId == ...">` is false and you get the fallback (or nothing).

### [5.9] Use dynamic SQL in annotations (`<script>`) and pluggable languages

Title: Wrap dynamic SQL in `<script>` inside an annotation; swap the scripting language with a `LanguageDriver`/`@Lang` when needed.
Description: Annotation mappers can use the same dynamic tags by wrapping the SQL in `<script>...</script>`. For non-XML templating you can implement `LanguageDriver`, set it globally (`defaultScriptingLanguage`), per-XML-statement (`lang="..."`), or per-annotation (`@Lang`).

**Dynamic SQL in an annotation:**

```java
@Update({"<script>",
  "update Author",
  "  <set>",
  "    <if test='username != null'>username=#{username},</if>",
  "    <if test='email != null'>email=#{email}</if>",
  "  </set>",
  "where id=#{id}",
  "</script>"})
int updateAuthorValues(Author author);
```

**Per-statement language:**

```java
public interface Mapper {
  @Lang(MyLanguageDriver.class)
  @Select("SELECT * FROM Blog")
  List<Blog> selectBlog();
}
```

`LanguageDriver` interface:

```java
public interface LanguageDriver {
  ParameterHandler createParameterHandler(MappedStatement ms, Object parameterObject, BoundSql boundSql);
  SqlSource createSqlSource(Configuration configuration, XNode script, Class<?> parameterType);
  SqlSource createSqlSource(Configuration configuration, String script, Class<?> parameterType);
}
```

**Pitfall:** Inside `@Update({...})` use **single quotes** for OGNL string literals (`test='username != null'`) — double quotes collide with Java's. Long `<script>` blocks in annotations are hard to read; for anything non-trivial, prefer an XML mapper. The default driver is `org.apache.ibatis.scripting.xmltags.XMLLanguageDriver` (alias `xml`).

## Chapter 6 — Java API: SqlSession & mapper interfaces

### [6.1] Build the factory and open sessions (`ExecutorType`, autoCommit, isolation)

Title: Use the right `openSession(...)` overload for your transaction and executor needs.
Description: `SqlSessionFactoryBuilder.build(...)` has overloads taking an `InputStream` (+`environment`/`Properties`) or a `Configuration`. `SqlSessionFactory.openSession(...)` overloads control autocommit, an externally-supplied `Connection`, the `TransactionIsolationLevel`, and the `ExecutorType` (`SIMPLE` — new `PreparedStatement` each time; `REUSE` — reuse statements; `BATCH` — batch updates).

```java
// build (once)
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(inputStream);

// open variants
try (SqlSession s1 = factory.openSession()) { /* autocommit off */ }
try (SqlSession s2 = factory.openSession(true)) { /* autocommit on */ }
try (SqlSession s3 = factory.openSession(ExecutorType.BATCH)) { /* batched writes */ }
try (SqlSession s4 = factory.openSession(TransactionIsolationLevel.READ_COMMITTED)) { }
```

`openSession` signatures: `openSession()`, `(boolean autoCommit)`, `(Connection)`, `(TransactionIsolationLevel)`, `(ExecutorType)`, `(ExecutorType, boolean)`, `(ExecutorType, TransactionIsolationLevel)`, `(ExecutorType, Connection)`; plus `getConfiguration()`.

**Pitfall:** `openSession(true)` (autocommit) makes every statement commit immediately — you lose atomicity across multiple writes. For a unit of work, open without autocommit and call `commit()` once at the end (6.4).

### [6.2] Run statements with the `SqlSession` methods (`RowBounds`, `ResultHandler`, `Cursor`)

Title: Know the full `SqlSession` surface; use `Cursor`/`ResultHandler` for large result sets and `RowBounds` for in-memory paging.
Description: Core methods: `selectOne` (0/1 row — throws if >1), `selectList`, `selectMap` (list → `Map` keyed by a property), `selectCursor` (lazy `Iterator`, stream big results), `select(..., ResultHandler)` (row callback), `insert`/`update`/`delete` (row counts), and `getMapper`. `RowBounds(offset, limit)` paginates **in memory** (the DB still returns all rows up to the window). `ResultHandler` processes rows without buffering.

```java
// single / list
Author a = session.selectOne("AuthorMapper.selectAuthor", 5);
List<Author> all = session.selectList("AuthorMapper.selectAuthors");

// keyed map
Map<Integer,Author> byId = session.selectMap("AuthorMapper.selectAuthors", "id");

// large result via Cursor (lazy)
try (Cursor<MyEntity> rows = session.selectCursor("MyMapper.streamAll")) {
  for (MyEntity e : rows) { process(e); }
}

// in-memory paging
List<Author> page = session.selectList("AuthorMapper.selectAuthors", null, new RowBounds(100, 25));
```

**Pitfall:** `selectOne` throws `TooManyResultsException` if the query returns more than one row — use `selectList` when 0..N is possible. `RowBounds` is **not** DB-level paging (no `LIMIT/OFFSET`); for big tables write `LIMIT`/`OFFSET` (or use a paging plugin). A `ResultHandler` disables result caching and may leave nested associations/collections unfilled.

### [6.3] Batch writes with `ExecutorType.BATCH` and `flushStatements()`

Title: For many inserts/updates, open a BATCH session and flush — far fewer round-trips than per-row execution.
Description: A `BATCH` executor queues identical statements and sends them together. Call `flushStatements()` (or `commit()`) to execute the batch and get `List<BatchResult>` with per-statement update counts.

```java
try (SqlSession session = factory.openSession(ExecutorType.BATCH)) {
  AuthorMapper mapper = session.getMapper(AuthorMapper.class);
  for (Author a : authors) {
    mapper.insertAuthor(a);
  }
  List<BatchResult> results = session.flushStatements();
  session.commit();
}
```

**Pitfall:** In `BATCH` mode an `insert` returns an **unreliable** row count (often `-2147482646`/`Integer.MIN_VALUE+...`) until the batch flushes, and **`useGeneratedKeys` keys are not populated until after `flushStatements()`** — read ids only after the flush. Interleaving a `select` between batched writes forces a flush (and can defeat batching). Don't switch `ExecutorType` mid-session.

### [6.4] Control transactions and the local cache

Title: Commit/rollback explicitly (non-autocommit sessions); understand the per-session local cache and don't mutate returned objects.
Description: A non-autocommit `SqlSession` buffers writes until `commit()`; `rollback()` discards them; `close()` without `commit()` rolls back. MyBatis skips an empty commit unless a write happened (or a `select` with `affectData`) — use `commit(true)`/`rollback(true)` to force. Each session has a **local (first-level) cache**: repeated identical queries return the cached result; it clears on any update/commit/rollback/close. `localCacheScope=SESSION` (default) caches across statements in the session; `STATEMENT` clears after each statement.

```java
try (SqlSession session = factory.openSession()) {
  session.insert("...", obj);
  session.update("...", obj);
  session.commit();        // persist both
} // close without commit would have rolled back

session.clearCache();      // drop the local cache manually if needed
```

**Pitfall:** Forgetting `commit()` on a non-autocommit session silently discards writes on close — the #1 "my insert didn't save" bug. Because of `SESSION` local caching, **mutating an object returned by a query mutates the cached copy** — treat results as read-only. Long-lived sessions accumulate a growing local cache; keep sessions short.

### [6.5] Prefer mapper interfaces; name parameters with `@Param`

Title: Call typed mapper methods instead of statement-id strings; annotate multiple parameters with `@Param`.
Description: A mapper interface method maps to a statement of the same `id` in the namespace = the interface FQN. With **multiple** parameters, name them with `@Param("...")` and reference them in SQL as `#{name}` (otherwise they are `#{param1}`, `#{param2}`, or `#{arg0}`...). A single bean/`Map` parameter exposes its properties directly.

```java
public interface UserMapper {
  User selectById(int id);                                   // single param
  List<User> search(@Param("name") String name,
                    @Param("status") String status);          // multi-param
  @MapKey("id")
  Map<Integer, User> mapById();                               // List -> Map
}
```

```xml
<select id="search" resultType="User">
  SELECT * FROM users
  <where>
    <if test="name != null">   AND name   like #{name}   </if>
    <if test="status != null"> AND status =    #{status} </if>
  </where>
</select>
```

**Pitfall:** "Parameter 'name' not found. Available parameters are [arg0, arg1, param1, param2]" means you used `#{name}` without `@Param("name")` (and `useActualParamName` couldn't recover the name — it needs `-parameters` at compile time). Add `@Param`. `mapper interfaces do not need to implement any interface or extend any class`.

## Chapter 7 — Annotation-based mappers

### [7.1] Statement annotations + `@Options`

Title: Use `@Select`/`@Insert`/`@Update`/`@Delete` for the SQL and `@Options` for statement attributes (generated keys, caching, fetch size, timeout).
Description: The statement annotations carry the SQL (a `String` or `String[]`). `@Options` sets what XML expresses as statement attributes: `useGeneratedKeys`, `keyProperty`, `keyColumn`, `useCache`, `flushCache`, `fetchSize`, `timeout`, `statementType`, `resultSetType`, `databaseId` (since 3.5.5).

```java
public interface AuthorMapper {
  @Select("SELECT id, username, email FROM Author WHERE id = #{id}")
  Author selectAuthor(int id);

  @Insert("INSERT INTO Author (username, email) VALUES (#{username}, #{email})")
  @Options(useGeneratedKeys = true, keyProperty = "id", keyColumn = "id")
  int insertAuthor(Author author);

  @Update("UPDATE Author SET email = #{email} WHERE id = #{id}")
  int updateEmail(@Param("id") int id, @Param("email") String email);

  @Delete("DELETE FROM Author WHERE id = #{id}")
  int deleteAuthor(int id);
}
```

**Pitfall:** `@Options` has primitive defaults and no concept of "unset" — every attribute you omit takes its hard default (`useCache=true`, `flushCache=DEFAULT`, `fetchSize=-1`, `timeout=-1`, `statementType=PREPARED`). Generated keys need both `@Options(useGeneratedKeys=true, keyProperty="id")` **and** a mutable bean parameter.

### [7.2] Result mapping with `@Results`/`@Result`/`@One`/`@Many` (and `@ConstructorArgs`)

Title: Map columns to properties with `@Results`+`@Result`; map relations with `@One` (has-one) / `@Many` (has-many); build immutables with `@ConstructorArgs`+`@Arg`.
Description: `@Results(id="...", value={@Result(...), ...})` is the annotation form of `<resultMap>`; name it via `id` to reuse with `@ResultMap`. `@Result` maps one column (`@Result(property=..., column=..., id=true)` for the key). `@One(select=...)`/`@Many(select=...)` are the nested-**select** forms of `<association>`/`<collection>` — the annotation API does **not** support join-based nested results. `@ConstructorArgs`+`@Arg` map to a constructor.

```java
@Results(id = "authorResult", value = {
  @Result(property = "id",        column = "id", id = true),
  @Result(property = "username",  column = "user_name"),
  @Result(property = "posts",     column = "id",
          many = @Many(select = "com.example.PostMapper.selectByAuthor", fetchType = FetchType.LAZY))
})
@Select("SELECT id, user_name FROM Author WHERE id = #{id}")
Author selectAuthor(int id);
```

`@Result` attributes: `id`, `column`, `property`, `javaType`, `jdbcType`, `typeHandler`, `one`, `many`. `@One`/`@Many`: `select` (fully-qualified statement), `fetchType`, `resultMap` (since 3.5.5), `columnPrefix` (since 3.5.5).

**Pitfall:** "join mapping is not supported via the Annotations API" — `@One`/`@Many` always do a **separate query** (N+1). For a join-based one-to-many, use an **XML** `<collection>` (4.4) and reference it with `@ResultMap`. `@Result`/`@Arg` are repeatable only since 3.5.4; on older versions you must nest them inside `@Results`/`@ConstructorArgs`.

### [7.3] Keys, maps, flush, and reuse: `@SelectKey`/`@MapKey`/`@Flush`/`@ResultMap`

Title: `@SelectKey` for non-auto-increment keys; `@MapKey` to return a keyed `Map`; `@Flush` for batch flush; `@ResultMap` to reuse an XML/`@Results` map.
Description: `@SelectKey` is the annotation form of `<selectKey>` (`before=true/false`). `@MapKey("prop")` turns a `List` return into a `Map` keyed by a property. `@Flush` on a (mapper) method calls `flushStatements()` and returns `List<BatchResult>` (since 3.3). `@ResultMap("namespace.id")` reuses an existing result map and overrides any `@Results`/`@ConstructorArgs` on the method.

```java
@Insert("insert into table3 (id, name) values(#{nameId}, #{name})")
@SelectKey(statement = "call next value for TestSequence",
           keyProperty = "nameId", before = true, resultType = int.class)
int insertTable3(Name name);

@Flush
List<BatchResult> flush();

@Select("SELECT * FROM users WHERE id = #{id}")
@ResultMap("com.example.UserMapper.userResultMap")   // reuse XML <resultMap>
User getUser(int id);
```

**Pitfall:** `@SelectKey` **overrides** `@Options(useGeneratedKeys=...)` — don't combine them. `@MapKey` requires the keyed property to be unique across rows, or later rows overwrite earlier ones.

### [7.4] Build SQL dynamically with providers (`@SelectProvider` + the `SQL` class)

Title: When dynamic SQL outgrows `<script>`, generate it in Java with a provider class and the `org.apache.ibatis.jdbc.SQL` builder.
Description: `@SelectProvider(type=..., method=...)` (and `@Insert/@Update/@DeleteProvider`) delegate SQL construction to a class method that returns a `String`/`CharSequence`. The `SQL` DSL builds well-formed, readable SQL. Since 3.5.1 you can omit `method` if the provider implements `ProviderMethodResolver` (matches by method name); since 3.5.6 you can omit `type` too by setting a global `defaultSqlProviderType`. A provider method may take a `ProviderContext` (since 3.4.5) to inspect the mapper type/method.

```java
public interface UserMapper {
  @SelectProvider(type = UserSqlBuilder.class, method = "buildGetUsersByName")
  List<User> getUsersByName(@Param("name") String name,
                            @Param("orderByColumn") String orderByColumn);
}

class UserSqlBuilder {
  public static String buildGetUsersByName(@Param("orderByColumn") final String orderByColumn) {
    return new SQL() {{
      SELECT("*");
      FROM("users");
      WHERE("name like #{name} || '%'");
      ORDER_BY(orderByColumn);     // trusted identifier, validate upstream
    }}.toString();
  }
}
```

**`ProviderMethodResolver` (omit `method`, since 3.5.1):**

```java
@SelectProvider(UserSqlProvider.class)
List<User> getUsersByName(String name);

class UserSqlProvider implements ProviderMethodResolver {
  public static String getUsersByName(final String name) {
    return new SQL() {{
      SELECT("*"); FROM("users");
      if (name != null) WHERE("name like #{value} || '%'");
      ORDER_BY("id");
    }}.toString();
  }
}
```

**Pitfall:** Values must still be `#{...}` placeholders inside the built SQL — interpolating a method argument straight into the string (string concatenation) reintroduces SQL injection; only structural identifiers (like `ORDER_BY(column)`) may be Java-side, and only after allow-list validation. Provider classes add indirection; reach for them only when XML/`<script>` genuinely can't express the logic.

---

## Appendix A — `settings` keys reference

Defaults in parentheses. Set inside `<settings>` in `mybatis-config.xml` (or via `Configuration` setters in code).

| Setting | Values (default) | Purpose |
|---------|------------------|---------|
| `cacheEnabled` | `true`/`false` (`true`) | Global on/off for second-level (namespace) caches. |
| `lazyLoadingEnabled` | `true`/`false` (`false`) | Lazy-load associations/collections globally (overridable per mapping via `fetchType`). |
| `aggressiveLazyLoading` | `true`/`false` (`false`) | Any method call loads **all** lazy properties (defeats laziness). |
| `multipleResultSetsEnabled` | `true`/`false` (`true`) | Deprecated; no effect. |
| `useColumnLabel` | `true`/`false` (`true`) | Use column **label** (alias) instead of name. |
| `useGeneratedKeys` | `true`/`false` (`false`) | Default `useGeneratedKeys` for inserts. |
| `autoMappingBehavior` | `NONE`/`PARTIAL`/`FULL` (`PARTIAL`) | How aggressively columns auto-map to properties. |
| `autoMappingUnknownColumnBehavior` | `NONE`/`WARNING`/`FAILING` (`NONE`) | Reaction to a column/property auto-map miss. |
| `defaultExecutorType` | `SIMPLE`/`REUSE`/`BATCH` (`SIMPLE`) | Default executor for sessions. |
| `defaultStatementTimeout` | int seconds (unset) | Default JDBC query timeout. |
| `defaultFetchSize` | int (unset) | Default driver fetch-size hint. |
| `defaultResultSetType` | `FORWARD_ONLY`/`SCROLL_SENSITIVE`/`SCROLL_INSENSITIVE`/`DEFAULT` (unset) | Default result-set scroll type (since 3.5.2). |
| `safeRowBoundsEnabled` | `true`/`false` (`false`) | Allow `RowBounds` on nested statements. |
| `safeResultHandlerEnabled` | `true`/`false` (`true`) | Allow `ResultHandler` on nested statements. |
| `mapUnderscoreToCamelCase` | `true`/`false` (`false`) | Auto-map `a_column` → `aColumn`. |
| `localCacheScope` | `SESSION`/`STATEMENT` (`SESSION`) | First-level cache lifespan. |
| `jdbcTypeForNull` | JDBC type (`OTHER`) | JDBC type used when binding `null` with no `jdbcType`. |
| `lazyLoadTriggerMethods` | method list (`equals,clone,hashCode,toString`) | Methods that trigger a lazy load. |
| `defaultScriptingLanguage` | alias/class (`XMLLanguageDriver`) | Default dynamic-SQL language. |
| `defaultEnumTypeHandler` | alias/class (`EnumTypeHandler`) | Default handler for enums (since 3.4.5). |
| `callSettersOnNulls` | `true`/`false` (`false`) | Call setters / `Map.put` even for null column values. |
| `returnInstanceForEmptyRow` | `true`/`false` (`false`) | Return an empty instance instead of `null` for an all-null row (since 3.4.2). |
| `logPrefix` | string (unset) | Prefix for logger names. |
| `logImpl` | `SLF4J`/`LOG4J2`/`JDK_LOGGING`/`COMMONS_LOGGING`/`STDOUT_LOGGING`/`NO_LOGGING`/… (autodiscovered) | Logging implementation. |
| `proxyFactory` | `CGLIB`/`JAVASSIST` (`JAVASSIST`) | Proxy lib for lazy loading. |
| `vfsImpl` | class list (unset) | Custom VFS implementations. |
| `useActualParamName` | `true`/`false` (`true`) | Allow `#{realName}` without `@Param` (needs `-parameters`) (since 3.4.1). |
| `configurationFactory` | alias/class (unset) | Class providing a `Configuration` (since 3.2.3). |
| `shrinkWhitespacesInSql` | `true`/`false` (`false`) | Collapse extra whitespace in SQL (since 3.5.5). |
| `defaultSqlProviderType` | alias/class (unset) | Default provider class for provider annotations (since 3.5.6). |
| `nullableOnForEach` | `true`/`false` (`false`) | Default `nullable` for `<foreach>` (since 3.5.9). |
| `argNameBasedConstructorAutoMapping` | `true`/`false` (`false`) | Constructor auto-mapping matches by arg name (since 3.5.10). |

## Appendix B — Built-in type aliases & type handlers

**Common built-in aliases** (case-insensitive). Primitives use a leading underscore; wrappers do not:

| Alias | Java type | | Alias | Java type |
|-------|-----------|-|-------|-----------|
| `_int`/`_integer` | `int` | | `int`/`integer` | `Integer` |
| `_long` | `long` | | `long` | `Long` |
| `_short` | `short` | | `short` | `Short` |
| `_byte` | `byte` | | `byte` | `Byte` |
| `_double` | `double` | | `double` | `Double` |
| `_float` | `float` | | `float` | `Float` |
| `_boolean` | `boolean` | | `boolean` | `Boolean` |
| `string` | `String` | | `date` | `java.util.Date` |
| `decimal`/`bigdecimal` | `BigDecimal` | | `biginteger` | `BigInteger` |
| `object` | `Object` | | `map`/`hashmap` | `Map`/`HashMap` |
| `list`/`arraylist` | `List`/`ArrayList` | | `collection`/`iterator` | `Collection`/`Iterator` |

Array variants exist (`date[]`, `decimal[]`, `object[]`, …). `char`/`character` aliases added in 3.5.10.

**Built-in type handlers** cover all the obvious types: `Boolean`, `Byte`, `Short`, `Integer`, `Long`, `Float`, `Double`, `BigDecimal`, `String` (+`Clob`/`NClob`/`NString`/`Sqlxml`), `byte[]`/`Blob`, `java.util.Date` (date/time/timestamp), `java.sql.Date`/`Time`/`Timestamp`, `Object`, enums (`EnumTypeHandler` by name / `EnumOrdinalTypeHandler` by ordinal), and the full **JSR-310** set (`Instant`, `LocalDateTime`, `LocalDate`, `LocalTime`, `OffsetDateTime`, `OffsetTime`, `ZonedDateTime`, `Year`, `Month`, `YearMonth`, `JapaneseDate`) — supported by default since **3.4.5**. Register a custom handler with `@MappedTypes`/`@MappedJdbcTypes` + `<typeHandlers>` (2.5).

## Appendix C — Feature → since-version table

MyBatis is strongly backward compatible within 3.5.x. Documentation snapshot: **3.5.19** (2025-01-02).

| Feature | Since |
|---------|-------|
| Core (XML/annotation mappers, `resultMap`, dynamic SQL, caching, `SqlSession` API) | early 3.x |
| `useActualParamName` (`#{realName}` without `@Param`) | 3.4.1 |
| `${name:default}` property defaults; `returnInstanceForEmptyRow` | 3.4.2 |
| `@Property` on `@CacheNamespace`; `@CacheNamespaceRef(name=...)` | 3.4.2 |
| Named `<constructor>`/`<idArg>`/`<arg>` (`name=`) | 3.4.3 |
| `defaultEnumTypeHandler`; JSR-310 handlers by default; `ProviderContext`; pool `localBadConnectionTolerance` | 3.4.5 |
| `@SelectProvider` method returning `CharSequence` | 3.4.6 |
| `defaultResultSetType` | 3.5.2 |
| Repeatable `@Result`/`@Arg` | 3.5.4 |
| `shrinkWhitespacesInSql`; `@One`/`@Many` `resultMap`/`columnPrefix`; `databaseId` on statement annotations & `@Options` | 3.5.5 |
| `defaultSqlProviderType` (omit provider `type`) | 3.5.6 |
| `ProviderMethodResolver` (omit provider `method`) | 3.5.1 |
| `nullableOnForEach` / `<foreach nullable>` | 3.5.9 |
| `argNameBasedConstructorAutoMapping`; `skipSetAutoCommitOnClose`; `char`/`character` aliases | 3.5.10 |
| `@Flush` annotation | 3.3 |

## Appendix D — Setup snippets (Maven/Gradle/Spring Boot) & common pitfalls

**Maven — copy XML mappers that live under `src/main/java`** (so `class`/`package` registration finds them):

```xml
<build>
  <resources>
    <resource>
      <directory>src/main/java</directory>
      <includes><include>**/*.xml</include></includes>
    </resource>
    <resource><directory>src/main/resources</directory></resource>
  </resources>
</build>
```

**Spring Boot — the idiomatic integration** (mappers as beans, Spring-managed transactions):

```xml
<dependency>
  <groupId>org.mybatis.spring.boot</groupId>
  <artifactId>mybatis-spring-boot-starter</artifactId>
  <version>3.0.x</version>   <!-- pairs MyBatis 3.5.x with mybatis-spring 3.x for Spring Boot 3 -->
</dependency>
```

```java
@SpringBootApplication
@MapperScan("com.example.mapper")   // register all mapper interfaces as beans
public class App { public static void main(String[] a) { SpringApplication.run(App.class, a); } }

@Service
class AuthorService {
  private final AuthorMapper authors;          // injected mapper (thread-safe proxy)
  AuthorService(AuthorMapper authors) { this.authors = authors; }

  @Transactional                                // Spring owns the SqlSession + tx
  public void rename(int id, String name) { authors.updateName(id, name); }
}
```

`application.yml` knobs: `mybatis.mapper-locations=classpath*:mappers/*.xml`, `mybatis.configuration.map-underscore-to-camel-case=true`, `mybatis.type-aliases-package=com.example.domain`.

**Most common pitfalls (consolidated):**
- **`${}` with user input** → SQL injection. Use `#{}` for values; `${}` only for allow-listed identifiers (3.3).
- **`SqlSession` shared/threaded or never committed** → corruption or lost writes. Request-scoped, try-with-resources, `commit()` (1.6, 6.4); in Spring, inject mappers + `@Transactional`.
- **"Invalid bound statement (not found)"** → mapper XML not on the classpath / namespace ≠ interface FQN / id ≠ method name (1.5, 2.10).
- **Generated key is null** → missing `useGeneratedKeys`+`keyProperty`, or a non-bean parameter, or (in BATCH) reading before `flushStatements()` (3.2, 6.3).
- **N+1 queries** → nested `select` in `<association>`/`<collection>`; switch to a join (nested results) or `fetchType="lazy"` (4.3, 4.4).
- **Column not mapped** → name mismatch with `mapUnderscoreToCamelCase` off, or `autoMappingBehavior` excluding nested maps; alias the column or declare a `<resultMap>` (4.1, 2.3).
- **Empty `<foreach>` / empty `<set>`** → `IN ()` or `update ... where` syntax error; guard with `<if>` (5.4, 5.6).
- **Enum data corrupted after reordering** → `EnumOrdinalTypeHandler`; prefer name-based or an explicit code column (2.5).
- **Stale 2nd-level cache** → writes via another namespace or outside MyBatis; mutating a `readOnly` cached object (4.6).

---

*Sources: MyBatis 3 official Reference Documentation — Getting Started (https://mybatis.org/mybatis-3/getting-started.html), Configuration (https://mybatis.org/mybatis-3/configuration.html), Mapper XML Files (https://mybatis.org/mybatis-3/sqlmap-xml.html), Dynamic SQL (https://mybatis.org/mybatis-3/dynamic-sql.html), and Java API (https://mybatis.org/mybatis-3/java-api.html). Documentation snapshot 3.5.19 (2025-01-02). Examples are adapted from the official pages; the Spring Boot integration in Appendix D is supplementary (mybatis-spring-boot-starter), provided because the backend stack is Spring-centric.*
