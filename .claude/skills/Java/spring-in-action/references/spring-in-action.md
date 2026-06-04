# Spring in Action, 6th Edition — Patterns and Guidelines

## Role

You are a Senior software engineer with extensive experience building Spring Boot applications, guiding implementation and review according to the patterns taught in Manning's *Spring in Action, 6th Edition* (Craig Walls), as demonstrated through the book's "Taco Cloud" application.

## Goal

Apply the end-to-end Spring patterns from *Spring in Action, 6th Edition*: bootstrap projects with the Spring Initializr; build Spring MVC controllers with Thymeleaf views and validated form binding; persist data with Spring Data JDBC/JPA and nonrelational stores (Cassandra, MongoDB); secure applications with Spring Security; externalize configuration with `@ConfigurationProperties` and profiles; expose and consume REST APIs (including Spring Data REST and HATEOAS); secure REST with OAuth2/JWT; integrate asynchronous messaging (JMS, RabbitMQ, Kafka); compose Spring Integration flows; program reactively with Project Reactor and Spring WebFlux; persist reactively with R2DBC and reactive Mongo/Cassandra; expose RSocket endpoints; monitor with Spring Boot Actuator, Spring Boot Admin, and JMX; and deploy as executable JARs, WARs, or container images to Kubernetes.

The book follows one continuous example, the Taco Cloud online taco-ordering application, layering each chapter's concepts onto the same domain (`Ingredient`, `Taco`, `TacoOrder`, `User`). The guidance below uses that domain and the book's actual APIs and idioms.

## Constraints

Before applying any recommendation, ensure the project is in a valid state and that changes match the chapter being applied.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` before applying any change
- **SAFETY**: If compilation fails, stop immediately — compilation failure is a blocking condition
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying improvements
- **FIDELITY**: Use the book's APIs and idioms. The 6th edition targets Spring Boot 2.5/2.6 and Java 11, so it uses `javax.validation`, `javax.persistence`, and `javax.jms` (not the later `jakarta.*` rename), and configures Spring Security with a `SecurityFilterChain` bean and the lambda DSL. Keep imports consistent with the chapter in use; mention newer equivalents only when explicitly asked.
- **INFRASTRUCTURE**: Messaging, data, container, and Kubernetes examples require the corresponding broker/database/Docker/cluster. If missing, report it and offer setup guidance rather than guessing.
- **TACO CLOUD DOMAIN**: Reuse the book's domain types and naming when scaffolding so examples remain consistent across chapters.

## Examples

### Table of contents

**Part 1 — Foundational Spring**

- Example 1: Bootstrap class with @SpringBootApplication (Ch 1)
- Example 2: A Spring MVC controller and Thymeleaf view (Ch 1–2)
- Example 3: Model attributes and request handling for a multi-step form (Ch 2)
- Example 4: Validating form input (Ch 2)
- Example 5: Spring Data JDBC repository over JdbcTemplate (Ch 3)
- Example 6: Spring Data JPA entities and repositories (Ch 3)
- Example 7: Nonrelational persistence with Cassandra and MongoDB (Ch 4)
- Example 8: Configuring Spring Security with a SecurityFilterChain (Ch 5)
- Example 9: Custom UserDetailsService and the authenticated principal (Ch 5)
- Example 10: Configuration properties and profiles (Ch 6)
- Example 11: REST controllers with proper HTTP semantics (Ch 7)
- Example 12: Spring Data REST and HATEOAS (Ch 7)

**Part 2 — Integrated Spring**

- Example 13: OAuth2 resource server with JWT (Ch 8)
- Example 14: Asynchronous messaging with JMS (Ch 9)
- Example 15: Messaging with RabbitMQ/AMQP and Kafka (Ch 9)
- Example 16: Spring Integration flows (Ch 10)

**Part 3 — Reactive Spring**

- Example 17: Project Reactor — Flux/Mono and StepVerifier (Ch 11)
- Example 18: Reactive controllers with Spring WebFlux (Ch 12)
- Example 19: Functional WebFlux with RouterFunction (Ch 12)
- Example 20: Reactive persistence (R2DBC, reactive Mongo/Cassandra) (Ch 13)
- Example 21: RSocket communication models (Ch 14)

**Part 4 — Deployed Spring**

- Example 22: Spring Boot Actuator endpoints and customization (Ch 15)
- Example 23: Spring Boot Admin and JMX MBeans (Ch 16–17)
- Example 24: Deploying — executable JAR, WAR, container image, Kubernetes (Ch 18)

### Example 1: Bootstrap class with @SpringBootApplication (Ch 1)

Title: Keep the bootstrap class minimal; let @SpringBootApplication do the work
Description: Every Taco Cloud module begins with a single class annotated `@SpringBootApplication` (which composes `@SpringBootConfiguration`, `@EnableAutoConfiguration`, and `@ComponentScan`) and a `main` method that calls `SpringApplication.run`. Generate the project from the Spring Initializr (`start.spring.io`, an IDE wizard, `curl https://start.spring.io/starter.zip`, or `spring init`) and keep business logic out of the bootstrap class.

**Good example:**

```java
package tacos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TacoCloudApplication {

  public static void main(String[] args) {
    SpringApplication.run(TacoCloudApplication.class, args);
  }
}
```

**Bad example:**

```java
package tacos;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

// Hand-wiring the context loses Boot autoconfiguration, the embedded server,
// component scanning, and externalized configuration.
public class TacoCloudApplication {

  public static void main(String[] args) {
    var context = new AnnotationConfigApplicationContext();
    context.scan("tacos");
    context.refresh();
    new OrderService().processBacklog(); // business logic in main — untestable, runs before the app is ready
  }
}
```

### Example 2: A Spring MVC controller and Thymeleaf view (Ch 1–2)

Title: Annotate controllers, return logical view names, render with Thymeleaf
Description: Use `@Controller` with request-mapping annotations (`@GetMapping`, `@PostMapping`, …). A view-returning method returns a logical view name that Thymeleaf resolves to `src/main/resources/templates/<name>.html`. For trivial mappings with no logic, register a view controller instead of writing an empty method. Test slices with `@WebMvcTest` and `MockMvc`.

**Good example:**

```java
package tacos.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

  @GetMapping("/")
  public String home() {
    return "home"; // resolves to templates/home.html
  }
}

// For pure view mappings, prefer a WebMvcConfigurer over an empty controller method:
package tacos.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
  @Override
  public void addViewControllers(ViewControllerRegistry registry) {
    registry.addViewController("/").setViewName("home");
  }
}
```

```html
<!-- templates/home.html -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
  <head><title>Taco Cloud</title></head>
  <body>
    <h1>Welcome to...</h1>
    <img th:src="@{/images/TacoCloud.png}"/>
  </body>
</html>
```

```java
// Slice test — no full context, no running server.
@WebMvcTest(HomeController.class)
class HomeControllerTest {
  @Autowired private MockMvc mockMvc;

  @Test
  void testHomePage() throws Exception {
    mockMvc.perform(get("/"))
        .andExpect(status().isOk())
        .andExpect(view().name("home"))
        .andExpect(content().string(containsString("Welcome to...")));
  }
}
```

**Bad example:**

```java
@Controller
public class HomeController {

  // Returning raw HTML from a controller bypasses the view layer and Thymeleaf,
  // mixing presentation into Java and defeating template reuse and i18n.
  @GetMapping(value = "/", produces = "text/html")
  @ResponseBody
  public String home() {
    return "<html><body><h1>Welcome to...</h1></body></html>";
  }
}
```

### Example 3: Model attributes and request handling for a multi-step form (Ch 2)

Title: Populate the model with @ModelAttribute methods; carry conversation state with @SessionAttributes
Description: The taco-design page needs ingredient lists grouped by type. Populate them once with `@ModelAttribute` methods so every handler in the controller sees them. Because building a taco and submitting an order span multiple requests, hold the in-progress `TacoOrder` in the session with `@SessionAttributes`, add the new `Taco` to it on POST, and clear the session with `SessionStatus.setComplete()` when the order is placed.

**Good example:**

```java
package tacos.web;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.support.SessionStatus;
import javax.validation.Valid;
import tacos.Ingredient;
import tacos.Ingredient.Type;
import tacos.Taco;
import tacos.TacoOrder;

@Slf4j
@Controller
@RequestMapping("/design")
@SessionAttributes("tacoOrder")
public class DesignTacoController {

  @ModelAttribute
  public void addIngredientsToModel(Model model) {
    List<Ingredient> ingredients = Arrays.asList(
        new Ingredient("FLTO", "Flour Tortilla", Type.WRAP),
        new Ingredient("GRBF", "Ground Beef", Type.PROTEIN),
        new Ingredient("CHED", "Cheddar", Type.CHEESE));
    Type[] types = Ingredient.Type.values();
    for (Type type : types) {
      model.addAttribute(type.toString().toLowerCase(),
          filterByType(ingredients, type));
    }
  }

  @ModelAttribute(name = "tacoOrder")
  public TacoOrder order() { return new TacoOrder(); }

  @ModelAttribute(name = "taco")
  public Taco taco() { return new Taco(); }

  @GetMapping
  public String showDesignForm() { return "design"; }

  @PostMapping
  public String processTaco(
      @Valid Taco taco, Errors errors,
      @ModelAttribute TacoOrder tacoOrder) {
    if (errors.hasErrors()) { return "design"; }
    tacoOrder.addTaco(taco);
    return "redirect:/orders/current";
  }

  private Iterable<Ingredient> filterByType(List<Ingredient> ingredients, Type type) {
    return ingredients.stream().filter(x -> x.getType().equals(type)).collect(Collectors.toList());
  }
}

// OrderController completes the conversation and clears the session:
@PostMapping
public String processOrder(@Valid TacoOrder order, Errors errors, SessionStatus sessionStatus) {
  if (errors.hasErrors()) { return "orderForm"; }
  orderRepo.save(order);
  sessionStatus.setComplete(); // clears the session-scoped tacoOrder
  return "redirect:/";
}
```

**Bad example:**

```java
@Controller
@RequestMapping("/design")
public class DesignTacoController {

  // No @SessionAttributes: the in-progress order cannot survive across the
  // design → order requests, so each POST starts from an empty order.
  // Re-querying ingredients inside every handler duplicates work the model
  // attribute method should do once.
  @PostMapping
  public String processTaco(Taco taco, Model model) { // no @Valid, no Errors → invalid tacos slip through
    model.addAttribute("ingredients", loadIngredientsAgain());
    TacoOrder order = new TacoOrder();   // fresh order every time — previous tacos are lost
    order.addTaco(taco);
    return "redirect:/orders/current";
  }
}
```

### Example 4: Validating form input (Ch 2)

Title: Declare Java Bean Validation constraints on the command object and check Errors in the handler
Description: Annotate domain/command fields with `javax.validation` constraints (`@NotNull`, `@Size`, `@Pattern`, `@Digits`) and Hibernate's `@CreditCardNumber`. In the handler, add `@Valid` before the bound object and an immediately-following `Errors` parameter; if `errors.hasErrors()` redisplay the form. Surface messages in Thymeleaf with `th:errors`.

**Good example:**

```java
package tacos;

import java.util.List;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import lombok.Data;

@Data
public class Taco {
  @NotNull
  @Size(min = 5, message = "Name must be at least 5 characters long")
  private String name;

  @NotNull
  @Size(min = 1, message = "You must choose at least 1 ingredient")
  private List<Ingredient> ingredients;
}

package tacos;

import javax.validation.constraints.Digits;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import org.hibernate.validator.constraints.CreditCardNumber;
import lombok.Data;

@Data
public class TacoOrder {
  @NotBlank(message = "Delivery name is required")
  private String deliveryName;

  @CreditCardNumber(message = "Not a valid credit card number")
  private String ccNumber;

  @Pattern(regexp = "^(0[1-9]|1[0-2])([\\/])([2-9][0-9])$", message = "Must be formatted MM/YY")
  private String ccExpiration;

  @Digits(integer = 3, fraction = 0, message = "Invalid CVV")
  private String ccCVV;
}
```

```html
<!-- design.html: show validation errors next to the field -->
<span class="validationError"
      th:if="${#fields.hasErrors('ccNumber')}"
      th:errors="*{ccNumber}">CC Num Error</span>
```

**Bad example:**

```java
@PostMapping
public String processOrder(TacoOrder order) {
  // Manual, ad-hoc validation: incomplete, duplicated across handlers,
  // produces no field-bound error messages for the view, and easy to forget.
  if (order.getDeliveryName() == null || order.getDeliveryName().isEmpty()) {
    return "orderForm";
  }
  if (!order.getCcNumber().matches("\\d{16}")) { // naive, wrong for real card formats
    return "orderForm";
  }
  orderRepo.save(order);
  return "redirect:/";
}
```

### Example 5: Spring Data JDBC repository over JdbcTemplate (Ch 3)

Title: Prefer Spring Data repositories; use JdbcTemplate with parameterized SQL when you need explicit control
Description: For most CRUD, declare a `CrudRepository` and let Spring Data generate the implementation; annotate persistent types with `@Table`, `@Id`, and `@Column`. When you hand-write SQL with `JdbcTemplate`, always parameterize queries (never concatenate input), map rows with a `RowMapper`, and capture generated keys with a `GeneratedKeyHolder` rather than guessing IDs.

**Good example:**

```java
// Spring Data JDBC: declare the interface, get the implementation for free.
package tacos.data;

import org.springframework.data.repository.CrudRepository;
import tacos.TacoOrder;

public interface OrderRepository extends CrudRepository<TacoOrder, Long> {
}

package tacos;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Table("Taco_Order")
public class TacoOrder {
  @Id
  private Long id;
  @Column("delivery_Name")
  private String deliveryName;
  // ...
}

// JdbcTemplate when you need explicit SQL: parameterized + RowMapper + key holder.
@Override
public Ingredient findById(String id) {
  return jdbcTemplate.queryForObject(
      "select id, name, type from Ingredient where id=?",
      this::mapRowToIngredient, id);
}

private Ingredient mapRowToIngredient(ResultSet row, int rowNum) throws SQLException {
  return new Ingredient(row.getString("id"), row.getString("name"),
      Ingredient.Type.valueOf(row.getString("type")));
}
```

**Bad example:**

```java
@Override
public Ingredient findById(String id) {
  // String-concatenated SQL is open to injection and defeats statement caching.
  return jdbcTemplate.queryForObject(
      "select id, name, type from Ingredient where id='" + id + "'",
      this::mapRowToIngredient);
}

@Override
public TacoOrder save(TacoOrder order) {
  jdbcTemplate.update("insert into Taco_Order (delivery_name) values (?)", order.getDeliveryName());
  // Guessing the new id instead of capturing the generated key — wrong under concurrency.
  Long id = jdbcTemplate.queryForObject("select max(id) from Taco_Order", Long.class);
  order.setId(id);
  return order;
}
```

### Example 6: Spring Data JPA entities and repositories (Ch 3)

Title: Map entities with javax.persistence and let derived query methods express intent
Description: With Spring Data JPA, annotate entities with `@Entity` and `@Id @GeneratedValue`, model relationships (`@ManyToMany`, `@OneToMany`), and use a lifecycle hook (`@PrePersist`) for timestamps. Extend `CrudRepository`; let Spring Data derive queries from method names (`findByDeliveryZip`, `readOrdersByDeliveryZipAndPlacedAtBetween`) and fall back to `@Query` only when a name cannot express the query.

**Good example:**

```java
package tacos;

import java.util.Date;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.PrePersist;
import lombok.Data;

@Data
@Entity
public class TacoOrder {
  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private Long id;
  private Date placedAt;

  @PrePersist
  void placedAt() { this.placedAt = new Date(); }
}

package tacos.data;

import java.util.Date;
import java.util.List;
import org.springframework.data.repository.CrudRepository;
import tacos.TacoOrder;

public interface OrderRepository extends CrudRepository<TacoOrder, Long> {
  List<TacoOrder> findByDeliveryZip(String deliveryZip);
  List<TacoOrder> readOrdersByDeliveryZipAndPlacedAtBetween(String deliveryZip, Date startDate, Date endDate);
}
```

**Bad example:**

```java
// Re-implementing CRUD by hand with an EntityManager throws away everything
// Spring Data JPA provides and reintroduces transaction/boilerplate bugs.
@Repository
public class JpaOrderRepository {
  @PersistenceContext private EntityManager em;

  public TacoOrder save(TacoOrder order) {
    if (order.getId() == null) {
      em.persist(order);       // forgot @Transactional → may fail outside a tx
    } else {
      em.merge(order);
    }
    return order;
  }
  // No derived queries; every lookup becomes another hand-written JPQL string.
}
```

### Example 7: Nonrelational persistence with Cassandra and MongoDB (Ch 4)

Title: Model documents/tables for the store you chose; extend the store-specific repository
Description: Cassandra and MongoDB are not relational — design around query patterns. For Cassandra, annotate with `@Table`, declare a composite `@PrimaryKeyColumn` (partition + clustering keys), use `@Column` and user-defined types (`@UserDefinedType`), and extend `CassandraRepository`. For MongoDB, annotate with `@Document`, mark the `@Id`, and extend `MongoRepository`.

**Good example:**

```java
// Cassandra
package tacos;

import java.util.UUID;
import org.springframework.data.cassandra.core.cql.Ordering;
import org.springframework.data.cassandra.core.cql.PrimaryKeyType;
import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.PrimaryKeyColumn;
import org.springframework.data.cassandra.core.mapping.Table;
import com.datastax.oss.driver.api.core.uuid.Uuids;

@Table("tacoorders")
public class TacoOrder {
  @PrimaryKeyColumn(type = PrimaryKeyType.PARTITIONED)
  private UUID id = Uuids.timeBased();

  @PrimaryKeyColumn(type = PrimaryKeyType.CLUSTERED, ordering = Ordering.DESCENDING)
  private Date placedAt = new Date();

  @Column("deliveryName")
  private String deliveryName;
}

public interface OrderRepository extends org.springframework.data.cassandra.repository.CassandraRepository<TacoOrder, UUID> { }

// MongoDB
package tacos;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Document
public class Ingredient {
  @Id
  private final String id;
  @Field("desc")
  private final String name;
  private final Type type;
}

public interface IngredientRepository extends org.springframework.data.mongodb.repository.MongoRepository<Ingredient, String> { }
```

**Bad example:**

```java
// Reusing JPA mappings and a relational mindset on Cassandra: no partition key
// design, expecting joins/foreign keys, and treating it like an RDBMS leads to
// hot partitions and queries Cassandra cannot serve efficiently.
@Entity                       // wrong annotation family for a Cassandra table
public class TacoOrder {
  @Id @GeneratedValue Long id; // Cassandra has no auto-increment; needs a partition key strategy
  @OneToMany List<Taco> tacos; // modeling relationships instead of denormalizing for read patterns
}
```

### Example 8: Configuring Spring Security with a SecurityFilterChain (Ch 5)

Title: Define authorization, login, and logout in a SecurityFilterChain bean; encode passwords
Description: Add `spring-boot-starter-security`, then expose a `SecurityFilterChain` bean using the lambda DSL: restrict `/design` and `/orders` to authenticated users, permit everything else, and configure a custom login page and logout. Expose a `PasswordEncoder` bean (BCrypt) so credentials are never stored in plain text.

**Good example:**

```java
package tacos.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .authorizeRequests(authz -> authz
            .antMatchers("/design", "/orders").hasRole("USER")
            .antMatchers("/", "/**").permitAll())
        .formLogin(form -> form.loginPage("/login"))
        .logout(logout -> logout.logoutSuccessUrl("/"))
        .build();
  }
}
```

**Bad example:**

```java
@Configuration
public class SecurityConfig {

  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .authorizeRequests(authz -> authz.anyRequest().permitAll()) // everything open
        .csrf(csrf -> csrf.disable())  // CSRF off for a form app with no justification
        .build();
  }

  @Bean
  public PasswordEncoder passwordEncoder() {
    return org.springframework.security.crypto.password.NoOpPasswordEncoder.getInstance(); // plain-text passwords
  }
}
```

### Example 9: Custom UserDetailsService and the authenticated principal (Ch 5)

Title: Back authentication with a UserDetailsService; inject the principal with @AuthenticationPrincipal
Description: Persist users in a `UserRepository`, have the domain `User` implement `UserDetails`, and provide a `UserDetailsService` bean that loads users by username (throwing `UsernameNotFoundException` when absent). In controllers, obtain the current user with `@AuthenticationPrincipal User user` rather than reaching into the security context manually.

**Good example:**

```java
package tacos.security;

import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import tacos.data.UserRepository;

@Configuration
public class SecurityConfig {
  @Bean
  public UserDetailsService userDetailsService(UserRepository userRepo) {
    return username -> {
      User user = userRepo.findByUsername(username);
      if (user != null) return user;
      throw new UsernameNotFoundException("User '" + username + "' not found");
    };
  }
}

// Use the principal in a controller:
@PostMapping
public String processOrder(@Valid TacoOrder order, Errors errors,
    SessionStatus sessionStatus, @AuthenticationPrincipal User user) {
  if (errors.hasErrors()) { return "orderForm"; }
  order.setUser(user);
  orderRepo.save(order);
  sessionStatus.setComplete();
  return "redirect:/";
}
```

**Bad example:**

```java
@PostMapping
public String processOrder(@Valid TacoOrder order, Errors errors) {
  // Reaching into the static SecurityContextHolder is harder to test and
  // bypasses the clean @AuthenticationPrincipal injection the framework offers.
  Authentication auth = SecurityContextHolder.getContext().getAuthentication();
  User user = (User) auth.getPrincipal(); // unchecked cast, NPE risk if anonymous
  order.setUser(user);
  orderRepo.save(order);
  return "redirect:/";
}
```

### Example 10: Configuration properties and profiles (Ch 6)

Title: Bind related settings with @ConfigurationProperties; vary by profile, never branch on the environment in code
Description: Replace scattered `@Value` injections with a `@ConfigurationProperties`-bound holder (optionally `@Validated`), grouping related keys under one prefix. Externalize values in `application.yml`. Use Spring profiles — profile-specific property files or `spring.config.activate.on-profile` documents, plus `@Profile` on beans — to vary configuration per environment.

**Good example:**

```java
package tacos.web;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;
import lombok.Data;

@Component
@ConfigurationProperties(prefix = "taco.orders")
@Validated
@Data
public class OrderProps {
  @Min(value = 5, message = "must be between 5 and 25")
  @Max(value = 25, message = "must be between 5 and 25")
  private int pageSize = 20;
}
```

```yaml
# application.yml
taco:
  orders:
    pageSize: 10

spring:
  profiles:
    active: prod
---
spring:
  config:
    activate:
      on-profile: prod
  datasource:
    url: jdbc:mysql://localhost/tacocloud
logging:
  level:
    tacos: WARN
```

```java
// Profile-conditional bean: only created when the "dev" profile is active.
@Bean
@Profile("dev")
public CommandLineRunner dataLoader(IngredientRepository repo) {
  return args -> { /* seed dev data */ };
}
```

**Bad example:**

```java
@Component
public class OrderProps {
  @Value("${taco.orders.pageSize}") private int pageSize; // one @Value per key, scattered, no grouping/validation

  // Branching on the active profile in business code instead of using @Profile / property files.
  @Value("${spring.profiles.active:}") private String profile;

  public String datasourceUrl() {
    if ("prod".equals(profile)) return "jdbc:mysql://localhost/tacocloud";
    return "jdbc:h2:mem:tacos"; // environment logic baked into Java
  }
}
```

### Example 11: REST controllers with proper HTTP semantics (Ch 7)

Title: Use @RestController with the right verbs, status codes, and ResponseEntity
Description: Annotate REST endpoints with `@RestController` and a `produces` media type. Map verbs to intent: `@GetMapping` reads; `@PostMapping` with `@ResponseStatus(HttpStatus.CREATED)` creates; `@PutMapping` replaces; `@PatchMapping` partially updates; `@DeleteMapping` with `204 No Content` removes. Return `ResponseEntity` (or `Optional`) so "not found" maps to `404`, not an empty `200`.

**Good example:**

```java
package tacos.web.api;

import java.util.Optional;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import tacos.Taco;
import tacos.data.TacoRepository;

@RestController
@RequestMapping(path = "/api/tacos", produces = "application/json")
@CrossOrigin(origins = "http://tacocloud.com")
public class TacoController {

  private final TacoRepository tacoRepo;
  public TacoController(TacoRepository tacoRepo) { this.tacoRepo = tacoRepo; }

  @GetMapping("/{id}")
  public ResponseEntity<Taco> tacoById(@PathVariable("id") Long id) {
    Optional<Taco> optTaco = tacoRepo.findById(id);
    return optTaco
        .map(taco -> new ResponseEntity<>(taco, HttpStatus.OK))
        .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }

  @PostMapping(consumes = "application/json")
  @ResponseStatus(HttpStatus.CREATED)
  public Taco postTaco(@RequestBody Taco taco) {
    return tacoRepo.save(taco);
  }

  @DeleteMapping("/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteTaco(@PathVariable("id") Long id) {
    try { tacoRepo.deleteById(id); }
    catch (EmptyResultDataAccessException e) { /* already gone */ }
  }
}
```

**Bad example:**

```java
@RestController
@RequestMapping("/api/tacos")
public class TacoController {

  // GET that mutates state, always 200 even when missing, and a POST that
  // returns 200 instead of 201 — none of which match REST/HTTP semantics.
  @GetMapping("/delete/{id}")
  public String deleteViaGet(@PathVariable Long id) {
    tacoRepo.deleteById(id);
    return "deleted";
  }

  @GetMapping("/{id}")
  public Taco byId(@PathVariable Long id) {
    return tacoRepo.findById(id).orElse(null); // null body with 200 OK — client cannot tell it is missing
  }
}
```

### Example 12: Spring Data REST and HATEOAS (Ch 7)

Title: Expose repositories automatically with Spring Data REST; enrich responses with hypermedia links
Description: Adding `spring-boot-starter-data-rest` publishes CRUD REST endpoints for your Spring Data repositories with no controller code; set a base path and customize relations with `@RestResource`. When hand-writing controllers, return hypermedia (Spring HATEOAS `EntityModel`/`CollectionModel` with links) so clients navigate by links rather than hardcoded URLs.

**Good example:**

```yaml
# application.yml — mount all repository endpoints under /data-api
spring:
  data:
    rest:
      base-path: /data-api
```

```java
// Customize the exported resource path/relation.
@RestResource(rel = "tacos", path = "tacos")
public interface TacoRepository extends CrudRepository<Taco, Long> {
}

// Hand-written hypermedia response with Spring HATEOAS:
@GetMapping("/recent")
public CollectionModel<EntityModel<Taco>> recentTacos() {
  List<Taco> tacos = tacoRepo.findAll(PageRequest.of(0, 12, Sort.by("createdAt").descending())).getContent();
  CollectionModel<EntityModel<Taco>> models = CollectionModel.wrap(tacos);
  models.add(linkTo(methodOn(TacoController.class).recentTacos()).withRel("recents"));
  return models;
}
```

**Bad example:**

```java
// Re-implementing by hand exactly what Spring Data REST would expose for free,
// then returning bare entities with no links so every client hardcodes URLs.
@RestController
@RequestMapping("/api/ingredients")
public class IngredientController {
  @GetMapping public Iterable<Ingredient> all() { return repo.findAll(); }
  @GetMapping("/{id}") public Ingredient one(@PathVariable String id) { return repo.findById(id).get(); }
  @PostMapping public Ingredient add(@RequestBody Ingredient i) { return repo.save(i); }
  // No hypermedia, no paging conventions, duplicating Spring Data REST.
}
```

### Example 13: OAuth2 resource server with JWT (Ch 8)

Title: Protect REST APIs as an OAuth2 resource server validating JWT access tokens by scope
Description: Add `spring-boot-starter-oauth2-resource-server`, point it at the authorization server's JWK set, and configure the security filter chain to require a bearer token and the appropriate `SCOPE_*` authorities per endpoint. The authorization server (Spring Authorization Server) registers clients via a `RegisteredClientRepository` and issues tokens; the resource server only validates them.

**Good example:**

```yaml
# Resource server: where to fetch keys for validating JWTs
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          jwk-set-uri: http://localhost:9000/oauth2/jwks
```

```java
@Configuration
public class ResourceServerSecurityConfig {

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
        .authorizeRequests(authz -> authz
            .mvcMatchers(HttpMethod.POST, "/api/ingredients").hasAuthority("SCOPE_writeIngredients")
            .mvcMatchers(HttpMethod.DELETE, "/api/ingredients/**").hasAuthority("SCOPE_deleteIngredients")
            .anyRequest().permitAll())
        .oauth2ResourceServer(oauth2 -> oauth2.jwt())  // validate incoming JWT access tokens
        .csrf(csrf -> csrf.ignoringAntMatchers("/api/**"))
        .build();
  }
}
```

**Bad example:**

```java
@Configuration
public class ResourceServerSecurityConfig {

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
        // Accepting any authenticated request without checking scopes lets a
        // read-only token perform writes. Token validation without authorization is not security.
        .authorizeRequests(authz -> authz.anyRequest().authenticated())
        .oauth2ResourceServer(oauth2 -> oauth2.jwt())
        .build();
  }
}
```

### Example 14: Asynchronous messaging with JMS (Ch 9)

Title: Send with JmsTemplate (and a MessageConverter); receive with @JmsListener
Description: Add a JMS starter (`spring-boot-starter-artemis`). Send messages with `JmsTemplate.convertAndSend`, relying on a configured `MessageConverter` (e.g., `MappingJackson2MessageConverter`) to serialize domain objects, and use a post-processor to set headers. Prefer message-driven `@JmsListener` methods over blocking `jmsTemplate.receive()` pulls.

**Good example:**

```java
package tacos.messaging;

import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Service;
import tacos.TacoOrder;

@Service
public class JmsOrderMessagingService implements OrderMessagingService {

  private final JmsTemplate jms;
  public JmsOrderMessagingService(JmsTemplate jms) { this.jms = jms; }

  @Override
  public void sendOrder(TacoOrder order) {
    jms.convertAndSend("tacocloud.order.queue", order, message -> {
      message.setStringProperty("X_ORDER_SOURCE", "WEB");
      return message;
    });
  }
}

// Message-driven receiver:
@Component
public class OrderListener {
  private final KitchenUI ui;
  public OrderListener(KitchenUI ui) { this.ui = ui; }

  @JmsListener(destination = "tacocloud.order.queue")
  public void receiveOrder(TacoOrder order) {
    ui.displayOrder(order);
  }
}

// Configure the converter so domain objects serialize as JSON:
@Bean
public MappingJackson2MessageConverter messageConverter() {
  MappingJackson2MessageConverter converter = new MappingJackson2MessageConverter();
  converter.setTypeIdPropertyName("_typeId");
  return converter;
}
```

**Bad example:**

```java
@Service
public class JmsOrderMessagingService {

  private final JmsTemplate jms;

  // Blocking pull-based receive in a request thread stalls the caller and
  // does not scale; serializing with raw Java serialization is brittle and unsafe.
  public TacoOrder pullNextOrderBlocking() {
    return (TacoOrder) jms.receiveAndConvert("tacocloud.order.queue"); // blocks until a message arrives
  }
}
```

### Example 15: Messaging with RabbitMQ/AMQP and Kafka (Ch 9)

Title: Use RabbitTemplate/@RabbitListener for AMQP and KafkaTemplate/@KafkaListener for Kafka
Description: RabbitMQ routes through an exchange: send with `RabbitTemplate.convertAndSend(exchange, routingKey, payload)` and receive with `@RabbitListener`. Kafka is topic-based and partition-ordered: send with `KafkaTemplate.send(topic, payload)` and consume with `@KafkaListener(topics = …)`, accepting a `ConsumerRecord` (or the payload directly) — set `spring.kafka.bootstrap-servers`.

**Good example:**

```java
// RabbitMQ / AMQP
@Service
public class RabbitOrderMessagingService implements OrderMessagingService {
  private final RabbitTemplate rabbit;
  public RabbitOrderMessagingService(RabbitTemplate rabbit) { this.rabbit = rabbit; }

  @Override
  public void sendOrder(TacoOrder order) {
    rabbit.convertAndSend("tacocloud.order", "kitchens.central", order, message -> {
      message.getMessageProperties().setHeader("X_ORDER_SOURCE", "WEB");
      return message;
    });
  }
}

@Component
public class OrderListener {
  @RabbitListener(queues = "tacocloud.order")
  public void receiveOrder(TacoOrder order) { /* handle */ }
}

// Kafka
@Service
public class KafkaOrderMessagingService implements OrderMessagingService {
  private final KafkaTemplate<String, TacoOrder> kafkaTemplate;
  public KafkaOrderMessagingService(KafkaTemplate<String, TacoOrder> kafkaTemplate) {
    this.kafkaTemplate = kafkaTemplate;
  }
  @Override
  public void sendOrder(TacoOrder order) {
    kafkaTemplate.send("tacocloud.orders.topic", order);
  }
}

@Component
public class OrderListener {
  @KafkaListener(topics = "tacocloud.orders.topic")
  public void handle(TacoOrder order, ConsumerRecord<String, TacoOrder> record) {
    log.info("Received from partition {} offset {}", record.partition(), record.offset());
  }
}
```

**Bad example:**

```java
@Service
public class RabbitOrderMessagingService {
  private final RabbitTemplate rabbit;

  // Sending to the default exchange with the queue name as routing key works by
  // accident but ignores AMQP's exchange/binding model and breaks once real
  // routing (topic/fanout) is introduced.
  public void sendOrder(TacoOrder order) {
    rabbit.convertAndSend("tacocloud.order.queue", order); // no exchange/routing-key design
  }
}
```

### Example 16: Spring Integration flows (Ch 10)

Title: Compose integration as a declarative flow of channels, transformers, and handlers behind a gateway
Description: Define an `IntegrationFlow` bean using the fluent builder: start from a gateway-fed channel, apply `transform`, route/filter/split as needed, and end at a `handle` (e.g., a file outbound channel adapter). Expose the entry point as a `@MessagingGateway` interface so application code calls a plain method and Spring Integration takes over.

**Good example:**

```java
package tacos.integration;

import java.io.File;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.dsl.IntegrationFlow;
import org.springframework.integration.dsl.IntegrationFlows;
import org.springframework.integration.file.dsl.Files;
import org.springframework.integration.file.FileHeaders;
import org.springframework.messaging.MessageHandler;

@Configuration
public class FileWriterIntegrationConfig {

  @Bean
  public IntegrationFlow fileWriterFlow() {
    return IntegrationFlows
        .from(MessageChannels.direct("textInChannel"))
        .<String, String>transform(String::toUpperCase)
        .handle(Files.outboundAdapter(new File("/tmp/sia/files"))
            .fileExistsMode(FileExistsMode.APPEND)
            .appendNewLine(true))
        .get();
  }
}

@MessagingGateway(defaultRequestChannel = "textInChannel")
public interface FileWriterGateway {
  void writeToFile(@Header(FileHeaders.FILENAME) String filename, String data);
}
```

**Bad example:**

```java
// Hand-coding the integration imperatively scatters channel/transform/handler
// concerns, loses the composability and testability of a declared flow, and
// couples the caller directly to file I/O.
@Service
public class FileWriterService {
  public void writeToFile(String filename, String data) throws IOException {
    String upper = data.toUpperCase();                 // transform inlined
    Files.write(Paths.get("/tmp/sia/files", filename),  // handler inlined
        (upper + "\n").getBytes(), StandardOpenOption.CREATE, StandardOpenOption.APPEND);
    // No channels, no gateway, no way to insert routing/filtering later.
  }
}
```

### Example 17: Project Reactor — Flux/Mono and StepVerifier (Ch 11)

Title: Build pipelines with reactive operators; verify them with StepVerifier
Description: Model async, possibly-multi-element data as `Flux<T>` and 0-or-1 as `Mono<T>`. Compose with operators (`map`, `flatMap`, `filter`, `zip`, `buffer`, `collectList`) instead of imperative loops, and remember a reactive pipeline does nothing until subscribed. Test reactive types with `StepVerifier` rather than blocking.

**Good example:**

```java
import reactor.core.publisher.Flux;
import reactor.test.StepVerifier;

Flux<String> fruitFlux = Flux.just("Apple", "Orange", "Grape", "Banana")
    .map(String::toUpperCase);

StepVerifier.create(fruitFlux)
    .expectNext("APPLE")
    .expectNext("ORANGE")
    .expectNext("GRAPE")
    .expectNext("BANANA")
    .verifyComplete();

// flatMap for async, possibly out-of-order mapping; zip to combine streams.
Flux<Player> players = nameFlux.flatMap(n ->
    Mono.just(n).map(this::lookupPlayer).subscribeOn(Schedulers.parallel()));

Flux<String> zipped = Flux.zip(characterFlux, foodFlux, (c, f) -> c + " eats " + f);
```

**Bad example:**

```java
// Blocking inside a reactive pipeline (.block()) defeats the point of Reactor:
// it ties up a thread and serializes work that should be non-blocking.
List<String> fruits = Flux.just("Apple", "Orange")
    .map(String::toUpperCase)
    .collectList()
    .block();                 // blocks the calling thread

// Subscribing is also forgotten elsewhere, so the pipeline never executes:
Flux.just("Apple").map(String::toUpperCase); // no subscription → nothing happens
```

### Example 18: Reactive controllers with Spring WebFlux (Ch 12)

Title: Return Mono/Flux from controllers and keep the whole request path non-blocking
Description: With Spring WebFlux, annotated controllers look like MVC controllers but return `Mono<T>`/`Flux<T>` and call reactive repositories. Do not call `block()` or blocking JDBC inside a reactive handler. Test with `WebTestClient`, which works against a mock or a live reactive server.

**Good example:**

```java
@RestController
@RequestMapping(path = "/api/tacos", produces = "application/json")
public class TacoController {

  private final ReactiveTacoRepository tacoRepo;
  public TacoController(ReactiveTacoRepository tacoRepo) { this.tacoRepo = tacoRepo; }

  @GetMapping(params = "recent")
  public Flux<Taco> recentTacos() {
    return tacoRepo.findAll().take(12);
  }

  @PostMapping(consumes = "application/json")
  @ResponseStatus(HttpStatus.CREATED)
  public Mono<Taco> postTaco(@RequestBody Mono<Taco> tacoMono) {
    return tacoMono.flatMap(tacoRepo::save);
  }
}

// WebTestClient verifies without a running server:
@Test
void shouldReturnRecentTacos() {
  WebTestClient testClient = WebTestClient.bindToController(
      new TacoController(reactiveTacoRepo)).build();
  testClient.get().uri("/api/tacos?recent")
      .exchange()
      .expectStatus().isOk()
      .expectBody()
      .jsonPath("$").isArray()
      .jsonPath("$[0].id").isEqualTo("taco1");
}
```

**Bad example:**

```java
@RestController
public class TacoController {
  private final TacoRepository blockingRepo; // a blocking JDBC repository

  // Blocking persistence on a WebFlux event-loop thread starves the small
  // Netty thread pool and destroys reactive scalability.
  @GetMapping("/api/tacos")
  public Flux<Taco> recent() {
    List<Taco> tacos = blockingRepo.findAll();  // blocking call on a reactive thread
    return Flux.fromIterable(tacos);
  }
}
```

### Example 19: Functional WebFlux with RouterFunction (Ch 12)

Title: Define routes and handlers functionally with RouterFunction when you prefer programmatic routing
Description: As an alternative to annotations, declare a `RouterFunction<ServerResponse>` bean mapping `RequestPredicate`s to handler functions that take a `ServerRequest` and return a `Mono<ServerResponse>`. This keeps routing in one place and is fully reactive end to end.

**Good example:**

```java
import static org.springframework.web.reactive.function.server.RequestPredicates.*;
import static org.springframework.web.reactive.function.server.RouterFunctions.route;
import org.springframework.web.reactive.function.server.*;

@Configuration
public class RouterFunctionConfig {

  @Bean
  public RouterFunction<ServerResponse> helloRouterFunction() {
    return route(GET("/hello"),
            request -> ServerResponse.ok().body(Mono.just("Hello!"), String.class))
        .andRoute(GET("/bye"),
            request -> ServerResponse.ok().body(Mono.just("See ya!"), String.class));
  }
}
```

**Bad example:**

```java
@Bean
public RouterFunction<ServerResponse> routerFunction() {
  return route(GET("/orders"), request -> {
    // Blocking the reactive handler to build the body negates the functional/reactive model.
    List<TacoOrder> orders = blockingOrderRepo.findAll(); // blocking inside a handler function
    return ServerResponse.ok().bodyValue(orders);
  });
}
```

### Example 20: Reactive persistence (R2DBC, reactive Mongo/Cassandra) (Ch 13)

Title: Use reactive repositories so the data layer is non-blocking too
Description: A reactive web layer needs a reactive data layer. Use R2DBC (`ReactiveCrudRepository`, `@Table`/`@Id`) for relational data, `ReactiveMongoRepository` for MongoDB, and `ReactiveCassandraRepository` for Cassandra. Repository methods return `Mono`/`Flux`; use `R2dbcEntityTemplate` for operations Spring Data does not derive.

**Good example:**

```java
// R2DBC
package tacos.data;

import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import tacos.Taco;

public interface TacoRepository extends ReactiveCrudRepository<Taco, Long> {
  Flux<Taco> findByOrderId(Long orderId);
}

// Reactive MongoDB
public interface IngredientRepository
    extends org.springframework.data.mongodb.repository.ReactiveMongoRepository<Ingredient, String> { }

// Reactive Cassandra
public interface OrderRepository
    extends org.springframework.data.cassandra.repository.ReactiveCassandraRepository<TacoOrder, UUID> { }
```

**Bad example:**

```java
// Bridging a blocking repository into a reactive service by wrapping each call
// in Flux/Mono does NOT make it reactive — the blocking call still ties up a
// thread under the hood.
@Service
public class OrderService {
  private final OrderRepository blockingRepo; // extends CrudRepository (blocking)

  public Flux<TacoOrder> all() {
    return Flux.fromIterable(blockingRepo.findAll()); // blocking findAll() hidden behind Flux
  }
}
```

### Example 21: RSocket communication models (Ch 14)

Title: Choose the RSocket interaction model that fits — request/response, request/stream, fire-and-forget, channel
Description: RSocket supports four models over a reactive, bidirectional protocol. Implement server endpoints with `@MessageMapping`, returning `Mono<T>` for request/response, `Flux<T>` for request/stream, `Mono<Void>` for fire-and-forget, and accepting a `Flux<T>` parameter (returning `Flux<T>`) for a channel. Clients use `RSocketRequester`.

**Good example:**

```java
@Controller
public class RSocketController {

  // Request/Response
  @MessageMapping("greeting")
  public Mono<String> handleGreeting(Mono<String> greetingMono) {
    return greetingMono.map(greeting -> "Hello back: " + greeting);
  }

  // Request/Stream
  @MessageMapping("counter")
  public Flux<Integer> counter() {
    return Flux.interval(Duration.ofSeconds(1)).map(Long::intValue).take(10);
  }

  // Fire-and-Forget
  @MessageMapping("alert")
  public Mono<Void> alert(Mono<Alert> alertMono) {
    return alertMono.doOnNext(this::record).then();
  }

  // Channel (bidirectional stream)
  @MessageMapping("channel")
  public Flux<String> channel(Flux<Duration> settings) {
    return settings.map(d -> "interval: " + d.getSeconds() + "s");
  }
}
```

**Bad example:**

```java
@Controller
public class RSocketController {

  // Returning a plain (non-reactive) type from an RSocket request/stream
  // endpoint collapses the stream into a single payload and discards the
  // streaming nature of the interaction.
  @MessageMapping("counter")
  public List<Integer> counter() {            // should be Flux<Integer>
    return List.of(1, 2, 3, 4, 5);            // no streaming, no backpressure
  }
}
```

### Example 22: Spring Boot Actuator endpoints and customization (Ch 15)

Title: Enable and secure Actuator endpoints; extend health, info, metrics, and add custom endpoints
Description: Add `spring-boot-starter-actuator` and expose the endpoints you need with `management.endpoints.web.exposure.include`. Customize `/health` with a `HealthIndicator`, `/info` with an `InfoContributor` (and build/git info plugins), record custom metrics through `MeterRegistry`, and create new endpoints with `@Endpoint`/`@ReadOperation`. Restrict Actuator with `EndpointRequest` in the security filter chain.

**Good example:**

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,loggers,conditions
  endpoint:
    health:
      show-details: always
  info:
    git:
      mode: full
```

```java
// Custom health indicator
@Component
public class TacoHealthIndicator implements HealthIndicator {
  @Override
  public Health health() {
    return isKitchenUp()
        ? Health.up().withDetail("kitchen", "operational").build()
        : Health.down().withDetail("kitchen", "offline").build();
  }
}

// Custom info contributor
@Component
public class TacoCountInfoContributor implements InfoContributor {
  private final TacoRepository tacoRepo;
  public TacoCountInfoContributor(TacoRepository tacoRepo) { this.tacoRepo = tacoRepo; }
  @Override
  public void contribute(Info.Builder builder) {
    builder.withDetail("taco-stats", Map.of("count", tacoRepo.count()));
  }
}

// Custom Actuator endpoint
@Component
@Endpoint(id = "notes", enableByDefault = true)
public class NotesEndpoint {
  private final List<Note> notes = new ArrayList<>();
  @ReadOperation public List<Note> notes() { return notes; }
  @WriteOperation public List<Note> addNote(String text) { notes.add(new Note(text)); return notes; }
  @DeleteOperation public List<Note> deleteNote(int index) { if (index < notes.size()) notes.remove(index); return notes; }
}

// Secure Actuator endpoints
@Bean
public SecurityFilterChain actuatorSecurity(HttpSecurity http) throws Exception {
  return http
      .requestMatcher(EndpointRequest.toAnyEndpoint())
      .authorizeRequests(authz -> authz.anyRequest().hasRole("ADMIN"))
      .httpBasic(Customizer.withDefaults())
      .build();
}
```

**Bad example:**

```yaml
# Exposing every endpoint (including shutdown/env/heapdump) over the web with
# no security leaks configuration, allows remote shutdown, and is a serious
# production risk.
management:
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    shutdown:
      enabled: true
```

### Example 23: Spring Boot Admin and JMX MBeans (Ch 16–17)

Title: Visualize Actuator data with Spring Boot Admin; expose management beans over JMX
Description: Spring Boot Admin gives a UI over Actuator: create an admin server (`spring-boot-admin-starter-server` + `@EnableAdminServer`) and register applications as clients (`spring-boot-admin-starter-client` + `spring.boot.admin.client.url`), securing the server with basic auth. For JMX, Spring auto-exposes Actuator endpoints as MBeans; export your own beans with `@ManagedResource`/`@ManagedAttribute`/`@ManagedOperation`, and push events with `NotificationPublisher`.

**Good example:**

```java
// Admin server
@SpringBootApplication
@EnableAdminServer
public class AdminServerApplication {
  public static void main(String[] args) { SpringApplication.run(AdminServerApplication.class, args); }
}
```

```yaml
# Admin server
server:
  port: 9090
# Admin client (in each monitored app)
spring:
  boot:
    admin:
      client:
        url: http://localhost:9090
```

```java
// Export a bean as an MBean and publish notifications.
@Service
@ManagedResource
public class TacoCounter extends AbstractRepositoryEventListener<Taco>
    implements NotificationPublisherAware {

  private final AtomicLong counter = new AtomicLong();
  private NotificationPublisher np;

  @Override public void setNotificationPublisher(NotificationPublisher np) { this.np = np; }

  @ManagedAttribute
  public long getTacoCount() { return counter.get(); }

  @ManagedOperation
  public long increment(long delta) {
    long before = counter.get();
    long after = counter.addAndGet(delta);
    if ((after / 100) > (before / 100)) {
      np.sendNotification(new Notification("taco.count", this, before, after + "th taco created!"));
    }
    return after;
  }
}
```

**Bad example:**

```yaml
# An Admin server exposed with no authentication shows every monitored app's
# environment, loggers, and lets operators toggle log levels — sensitive data
# and control left wide open.
server:
  port: 9090
# (no spring.security config, no admin client credentials)
```

### Example 24: Deploying — executable JAR, WAR, container image, Kubernetes (Ch 18)

Title: Choose the deployment artifact for the target; enable graceful shutdown and liveness/readiness for Kubernetes
Description: A Spring Boot app builds to an executable JAR by default (`mvnw package` → `java -jar`). For a traditional servlet container, build a WAR and extend `SpringBootServletInitializer`. For containers, use the Boot build plugin (`mvnw spring-boot:build-image`) — no Dockerfile required — and deploy with a Kubernetes `Deployment`. In Kubernetes, set `server.shutdown=graceful` and enable Actuator liveness/readiness probes wired to the deployment.

**Good example:**

```java
// WAR deployment: register DispatcherServlet via a servlet initializer.
package tacos;

import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

public class TacoCloudServletInitializer extends SpringBootServletInitializer {
  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
    return builder.sources(TacoCloudApplication.class);
  }
}
```

```yaml
# Kubernetes-friendly app settings
server:
  shutdown: graceful
management:
  health:
    probes:
      enabled: true
spring:
  lifecycle:
    timeout-per-shutdown-phase: 20s
```

```yaml
# k8s/deploy.yaml — 3 replicas with liveness/readiness probes
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taco-cloud-deploy
  labels: { app: taco-cloud }
spec:
  replicas: 3
  selector:
    matchLabels: { app: taco-cloud }
  template:
    metadata:
      labels: { app: taco-cloud }
    spec:
      containers:
      - name: taco-cloud-container
        image: tacocloud/tacocloud:latest
        livenessProbe:
          initialDelaySeconds: 2
          periodSeconds: 5
          httpGet: { path: /actuator/health/liveness, port: 8080 }
        readinessProbe:
          initialDelaySeconds: 2
          periodSeconds: 5
          httpGet: { path: /actuator/health/readiness, port: 8080 }
```

```bash
# Build a container image with the Spring Boot plugin (no Dockerfile needed)
$ mvnw spring-boot:build-image \
    -Dspring-boot.build-image.imageName=tacocloud/tacocloud:latest
$ kubectl apply -f k8s/deploy.yaml
```

**Bad example:**

```yaml
# Deploying to Kubernetes with no probes and immediate shutdown: Kubernetes
# routes traffic to a pod that is not ready and kills pods mid-request, so
# clients get errors on every rollout or restart.
# (server.shutdown left default/immediate, management.health.probes not enabled)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taco-cloud-deploy
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: taco-cloud-container
        image: tacocloud/tacocloud:latest
        # no livenessProbe, no readinessProbe
```

## Output Format

When applying this skill:

- **IDENTIFY** the chapter/topic that matches the request (MVC, data, security, configuration, REST, OAuth2, messaging, integration, reactive, RSocket, Actuator/Admin/JMX, or deployment) and read the corresponding example before changing code.
- **REUSE** the Taco Cloud domain (`Ingredient`, `Taco`, `TacoOrder`, `User`) and the book's naming so changes stay consistent across chapters.
- **APPLY** the good-example pattern for the chapter and avoid the documented bad pattern; keep imports and APIs consistent with the book's Spring Boot 2.5/2.6 + Java 11 baseline (`javax.*`, `SecurityFilterChain` lambda DSL) unless the user asks to modernize.
- **EXPLAIN** which book pattern was applied and why, calling out trade-offs (e.g., blocking vs. reactive, JAR vs. WAR vs. image, derived query vs. `@Query`).
- **VALIDATE** with `./mvnw compile` before and `./mvnw clean verify` after changes; for messaging, data, container, or Kubernetes work, note the required infrastructure and how it was (or should be) provisioned.

## Safeguards

- **BLOCKING SAFETY CHECK**: Run `./mvnw compile` or `mvn compile` before any change; stop on compilation failure.
- **CRITICAL VALIDATION**: Run `./mvnw clean verify` after applying improvements.
- **FIDELITY TO THE BOOK**: Do not invent APIs absent from *Spring in Action, 6th Edition*. Match the chapter's idioms; flag — but do not silently substitute — newer APIs.
- **SECURITY**: Never weaken security to "make it work" — keep password encoding, CSRF defaults, OAuth2 scope checks, and Actuator/Admin authentication in place; never expose all Actuator endpoints unsecured or enable the `shutdown` endpoint over the web in production.
- **REACTIVE INTEGRITY**: Never call `block()` or invoke blocking JDBC/repositories on WebFlux/Reactor threads; pair a reactive web layer with reactive persistence.
- **MESSAGING/DATA/INFRA**: Confirm the broker (Artemis/RabbitMQ/Kafka), database (relational/Cassandra/MongoDB), Docker runtime, or Kubernetes cluster is available before running examples that depend on it.
- **INCREMENTAL CHANGES**: Apply one chapter/topic at a time and verify between steps; do not mix unrelated refactors into a single change.
