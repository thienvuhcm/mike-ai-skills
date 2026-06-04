---
name: spring-in-action
description: Use when you need to review, improve, or build Spring Boot applications end to end based on Manning's "Spring in Action, 6th Edition" — including project bootstrapping (Spring Initializr), Spring MVC controllers and Thymeleaf views, form binding and validation, Spring Data (JDBC, JPA, Cassandra, MongoDB), Spring Security (servlet and reactive, in-memory/JDBC/custom user details), configuration properties and profiles, REST services and Spring Data REST, consuming REST with RestTemplate/WebClient/Traverson, OAuth2 (authorization server, resource server, client) and JWT, asynchronous messaging (JMS/JmsTemplate, RabbitMQ/AMQP/RabbitTemplate, Kafka/KafkaTemplate and listeners), Spring Integration flows, Project Reactor (Mono/Flux) and Spring WebFlux (annotated and functional), reactive persistence (R2DBC, reactive Mongo, reactive Cassandra), RSocket, Spring Boot Actuator, Spring Boot Admin, JMX/MBeans, and deployment (executable JAR, WAR, container images, Kubernetes liveness/readiness, graceful shutdown). This should trigger for requests such as Build a Spring Boot feature following Spring in Action; Review Java code against Spring in Action patterns; Show me how the Taco Cloud book implements X. Synthesized from the book — not framework cursor-rules.
license: Apache-2.0
metadata:
  author: mike-ai-skills
  version: 0.1.0
  source: "Manning — Spring in Action, 6th Edition (Craig Walls, 2022)"
---
# Spring in Action (6th Edition) Guidelines

Apply the patterns taught throughout Manning's *Spring in Action, 6th Edition* — the full Taco Cloud journey from a freshly bootstrapped project to a deployed, monitored application.

**What is covered in this Skill?**

- Bootstrapping projects with the Spring Initializr (`start.spring.io`, IDEs, `curl`, Spring Boot CLI) and the `@SpringBootApplication` bootstrap class
- Spring MVC: `@Controller`/`@RestController`, request mapping, model attributes, Thymeleaf views, form binding, and validation with Jakarta/Java Bean Validation
- Working with data: Spring Data JDBC (`JdbcTemplate`, repositories), Spring Data JPA (`@Entity`, repositories, derived queries), and nonrelational stores (Cassandra `@Table`, MongoDB `@Document`)
- Spring Security: filter-chain configuration, in-memory / JDBC / custom `UserDetailsService`, password encoding, method and request authorization, CSRF, and login/logout
- Configuration: `application.yml`/`application.properties`, `@ConfigurationProperties`, profiles (`@Profile`, profile-specific properties), and autoconfiguration
- REST: `@RestController` with HTTP semantics, `@RepositoryRestResource` (Spring Data REST), HATEOAS, and consuming APIs with `RestTemplate`, `WebClient`, and Traverson
- Security for REST: OAuth2 authorization server, resource server (JWT validation), and OAuth2 client / login
- Asynchronous messaging: JMS (`JmsTemplate`, `@JmsListener`), RabbitMQ/AMQP (`RabbitTemplate`, `@RabbitListener`), Kafka (`KafkaTemplate`, `@KafkaListener`)
- Spring Integration: integration flows, gateways, channels, transformers, routers, splitters, service activators, and channel adapters
- Reactive programming: Project Reactor `Mono`/`Flux` operators and `StepVerifier`; Spring WebFlux annotated and functional (`RouterFunction`) controllers; `WebTestClient`
- Reactive persistence: R2DBC, reactive MongoDB, and reactive Cassandra repositories
- RSocket: the four communication models over the reactive protocol
- Spring Boot Actuator: endpoints, customization (`HealthIndicator`, `InfoContributor`, custom metrics and `@Endpoint`), and securing endpoints
- Spring Boot Admin and JMX/MBeans (`@ManagedResource`, `NotificationPublisher`)
- Deployment: executable JAR, traditional WAR (`SpringBootServletInitializer`), container images (Dockerfile and `spring-boot:build-image`), Kubernetes manifests, graceful shutdown, and liveness/readiness probes

**Scope:** Apply recommendations based on the reference's chapter-organized rules and good/bad code examples drawn directly from the book.

## Constraints

Before applying any change, ensure the project compiles. If compilation fails, stop immediately. After applying improvements, run full verification.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` before applying any change
- **SAFETY**: If compilation fails, stop immediately — compilation failure is a blocking condition
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying improvements
- **BEFORE APPLYING**: Read the reference for detailed rules, good/bad patterns, and constraints
- **FIDELITY**: Follow the book's patterns and APIs; do not invent APIs that are not in *Spring in Action, 6th Edition*. When the book uses an older API (e.g., `javax.*` for JMS/JPA, `WebSecurityConfigurerAdapter`-free lambda DSL with `SecurityFilterChain`), keep it consistent with the chapter being applied and note any newer equivalent only when the user asks
- **EDGE CASE**: If request scope is ambiguous, stop and ask a clarifying question before applying changes
- **EDGE CASE**: If required inputs, files, or tooling (a database, broker, Docker, or Kubernetes cluster) are missing, report what is missing and ask whether to proceed with setup guidance

## When to use this skill

- Build a Spring Boot feature the way *Spring in Action* (Taco Cloud) does it
- Review Java code against the book's patterns for MVC, data, security, messaging, reactive, or deployment
- Explain or scaffold a chapter topic (e.g., "add an OAuth2 resource server", "make this repository reactive", "containerize and deploy to Kubernetes")

## Workflow

1. **Read reference and assess project context**

Read `references/spring-in-action.md`, locate the chapter/topic that matches the request, and inspect the current project setup before proposing changes.

2. **Gather scope and decide target improvements**

Identify the requested outcome, the matching book pattern, constraints, and the minimum safe set of changes to apply.

3. **Apply book-aligned changes**

Implement or refactor following the reference's good examples and the project's conventions; avoid the documented bad patterns.

4. **Run verification and report results**

Execute the appropriate build/tests and summarize what changed, what was verified, and any follow-up actions (e.g., broker or database setup).

## Reference

For detailed guidance, examples, and constraints organized by the book's four parts and 18 chapters, see [references/spring-in-action.md](references/spring-in-action.md).
