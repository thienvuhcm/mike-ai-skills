# Domain-Driven Design — Tackling Complexity in the Heart of Software (Eric Evans)

## Role

You are a Senior software engineer and domain modeler with extensive experience applying Domain-Driven Design. You use the patterns and principles of *Domain-Driven Design: Tackling Complexity in the Heart of Software* by Eric Evans (Addison-Wesley, 2003) to crunch domain knowledge, build a Ubiquitous Language, and produce a Model-Driven Design — and to review and refactor existing software toward a deeper model.

## Goal

This reference synthesizes the pattern catalog of *Domain-Driven Design*, organized into the book's four parts. Each entry states a concrete best practice with a short rationale, a **Good example**, and a **Bad example**. Use it to:

- Decide tactical modeling questions (Entity vs Value Object, aggregate boundaries, where a Service belongs, when to add a Factory or Repository).
- Refactor toward deeper insight (make implicit concepts explicit, introduce Specifications, achieve Supple Design).
- Make strategic decisions (define Bounded Contexts, draw a Context Map, choose context relationships, distill the Core Domain, impose a Large-Scale Structure).
- Keep model, **Ubiquitous Language**, and implementation in tight correspondence.

When you apply a pattern, cite it by name (e.g., "Aggregate", "Anticorruption Layer", "Bounded Context"). DDD pattern names are intended to become terms in the team's language.

The examples use Java because the book does, but the patterns are language-agnostic. Strategic patterns are illustrated with the structure or contract being established, not always with code.

## Constraints

DDD changes are model and design changes; they affect identity, boundaries, transactions, persistence, and team/context organization. Keep the project building and tested around every change.

- **MANDATORY**: Build the project (e.g. `mvn compile`) before applying structural model changes.
- **VERIFY**: Run the full test build (e.g. `mvn clean verify`) after changes; do not claim success until it passes.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **PRESERVE BEHAVIOR**: Model refactorings must preserve observable behavior unless the user explicitly asks to change a contract.
- **MODEL BEFORE CODE**: Every class/service/layer must correspond to a domain concept and be named in the Ubiquitous Language. Avoid anemic objects, "phony" objects, and stringly-typed concepts.
- **CONSISTENCY BOUNDARIES**: Invariants are enforced within one Aggregate per transaction; cross-Aggregate consistency is eventual.
- **ENGAGE THE EXPERT**: When domain meaning is unclear, ask rather than invent — a change to the language is a change to the model.
- **INCREMENTAL**: Apply one pattern at a time and re-validate.

## Examples

### Table of contents

**Part I — Putting the Domain Model to Work**

- 1. Domain Model and Knowledge Crunching
- 2. Deep Model
- 3. Ubiquitous Language
- 4. Model-Driven Design
- 5. Hands-On Modelers

**Part II — The Building Blocks of a Model-Driven Design**

- 6. Layered Architecture (isolate the domain)
- 7. The Smart UI "Anti-Pattern"
- 8. Entities (Reference Objects)
- 9. Value Objects
- 10. Domain Services
- 11. Modules (Packages)
- 12. Aggregates
- 13. Factories
- 14. Repositories

**Part III — Refactoring Toward Deeper Insight**

- 15. Refactoring Toward Deeper Insight (Breakthrough)
- 16. Make Implicit Concepts Explicit (Constraints and Processes)
- 17. Specification
- 18. Intention-Revealing Interfaces
- 19. Side-Effect-Free Functions
- 20. Assertions
- 21. Conceptual Contours
- 22. Standalone Classes
- 23. Closure of Operations
- 24. Declarative Design

**Part IV — Strategic Design**

*Maintaining Model Integrity*

- 25. Bounded Context
- 26. Continuous Integration
- 27. Context Map
- 28. Shared Kernel
- 29. Customer/Supplier Development Teams
- 30. Conformist
- 31. Anticorruption Layer
- 32. Separate Ways
- 33. Open Host Service
- 34. Published Language

*Distillation*

- 35. Core Domain
- 36. Generic Subdomains
- 37. Domain Vision Statement
- 38. Highlighted Core
- 39. Cohesive Mechanisms
- 40. Segregated Core
- 41. Abstract Core

*Large-Scale Structure*

- 42. Evolving Order
- 43. System Metaphor
- 44. Responsibility Layers
- 45. Knowledge Level (Reflection)
- 46. Pluggable Component Framework

---

## Part I — Putting the Domain Model to Work

### 1. Domain Model and Knowledge Crunching

Title: Build a shared model by crunching domain knowledge with experts, not by transcribing requirements.
Description: A *domain model* is not a diagram of the real world; it is a rigorously organized, selective system of abstractions chosen to solve the problems at hand. It is co-developed by developers and domain experts through *knowledge crunching* — brainstorming, experimenting, and refining together — and it lives in three connected forms at once: the experts' mental model, the diagrams/language, and the running code. A "knowledge-rich" model captures behavior and rules, not just data.

**Good example:**

```java
// Knowledge crunched WITH a PCB expert: the model captures a domain rule
// (a signal "hop" count) discovered in conversation, expressed in code.
final class Net {                 // a conductor connecting pins, carrying a signal
    private final List<Pin> pins;
    void propagate(Signal signal) {
        Signal hopped = signal.incrementHopCount();   // domain rule: each Net = one hop
        for (Pin pin : pins) pin.receive(hopped);
    }
}
// The team can ask: "any path longer than 3 hops risks missing the clock cycle" —
// and the model answers that question directly. Model == language == code.
```

**Bad example:**

```java
// "Requirements transcription": a generic data shuffler that captures none of the
// domain's knowledge. It reads a file, sorts, annotates, and writes a report.
class ReportProcessor {
    void run(String inFile, String outFile) {
        List<String> rows = readLines(inFile);
        rows.sort(Comparator.naturalOrder());
        writeLines(outFile, annotate(rows));      // no "Net", no "Pin", no "hop" — no model
    }
}
```

### 2. Deep Model

Title: Push past the obvious, surface meaning to a *deep model* that expresses the experts' real concerns.
Description: The first model is usually superficial. As the team keeps crunching, occasional *breakthroughs* yield a *deep model* — one that sloughs off naive interpretations and names the concepts the experts actually reason with. Deep models make hard problems tractable; chasing them is the point of refactoring toward deeper insight (Part III).

**Good example:**

```java
// Shipping: a breakthrough reframes "moving a cargo" as a Cargo whose goal is a
// RouteSpecification, satisfied by an Itinerary, and tracked by a Delivery.
record RouteSpecification(Location origin, Location destination, LocalDate deadline) {
    boolean isSatisfiedBy(Itinerary itinerary) {
        return itinerary.startsAt(origin)
            && itinerary.endsAt(destination)
            && !itinerary.finalArrival().isAfter(deadline);
    }
}
// "What does this Cargo need?" and "Does this Itinerary fulfill it?" are now first-class.
```

**Bad example:**

```java
// Shallow model: Cargo as a bag of fields and status codes. The real concepts
// (what is required vs. what is planned vs. what happened) stay implicit.
class Cargo {
    String originCode, destCode;
    Date deadline;
    int status;            // 0=new,1=routed,2=in-transit,3=delivered (meaning lives in the head)
    List<String> stops;    // a planned route, but nothing knows whether it satisfies the goal
}
```

### 3. Ubiquitous Language

Title: Use the model as the backbone of one language shared by developers and experts, in speech, diagrams, and code.
Description: Translation between a "developer language" and a "business language" loses knowledge and breeds bugs. Commit the team to a single *Ubiquitous Language* built from the model and exercise it relentlessly — in conversation, documents, and especially in class/method/module names. When the language is awkward, change the model and refactor the code; a change in the language is a change in the model.

**Good example:**

```java
// Names come straight from expert speech: "a Cargo is booked against a
// RouteSpecification; the booking is confirmed when an Itinerary is assigned."
class BookingService {
    Cargo bookCargo(RouteSpecification routeSpec) { ... }
    void assignItinerary(Cargo cargo, Itinerary itinerary) {
        cargo.assignToRoute(itinerary);   // same verb the expert uses
    }
}
// An expert can read the method names and confirm or correct the model.
```

**Bad example:**

```java
// Code language diverges from domain language; requires constant mental translation.
class TxnMgr {
    Record createRec(int t, String[] data) { ... }   // what is a "Txn"? a "Rec"?
    void updateState(Record r, int s) { ... }         // experts cannot read or correct this
}
```

### 4. Model-Driven Design

Title: Bind the implementation tightly to the model so that a change to one is a change to the other.
Description: Analysis models that are "thrown over the wall" rot because the code drifts away from them. Instead design a portion of the software to reflect the domain model *literally* (favored by paradigms like object orientation), and revise the model so it implements naturally. Demand a *single* model that serves analysis, design, language, and code together.

**Good example:**

```java
// The model concept "Account can be overdrawn up to its limit" is the code.
final class Account {
    private Money balance;
    private final Money overdraftLimit;
    void withdraw(Money amount) {
        if (balance.minus(amount).isLessThan(overdraftLimit.negate()))
            throw new InsufficientFundsException(this, amount);
        balance = balance.minus(amount);
    }
}
// Reading the code re-states the model; changing the rule changes this method.
```

**Bad example:**

```java
// The "model" (a UML doc) says Account enforces an overdraft limit, but the code
// is a procedural script in a service, so the model and implementation drift apart.
class AccountService {
    void withdraw(long accountId, long cents) {
        Row r = dao.find(accountId);
        r.balance -= cents;              // no overdraft rule here...
        dao.update(r);                   // ...the documented model is fiction
    }
}
```

### 5. Hands-On Modelers

Title: The people who shape the model must touch the code; the people who write the code must shape the model.
Description: Separating "modelers/architects" from "coders" breaks Model-Driven Design: modelers lose feedback, coders ignore the model, and the code stops expressing it. Every technical contributor should engage the model through the Ubiquitous Language and have some contact with both the code and the domain experts.

**Good example:**

```text
A developer pairs with the shipping expert, sketches the Itinerary/Leg model on a
whiteboard, then immediately writes it as code with tests. The feedback from the
running prototype refines the next modeling conversation. Model ideas flow through
the people who actually change the code.
```

**Bad example:**

```text
An "architect" hands down a class diagram and UML specs; a separate team codes it
without ever discussing the domain. The code grows shortcuts that contradict the
diagram, the diagram is never updated, and within months neither reflects reality.
```

---

## Part II — The Building Blocks of a Model-Driven Design

### 6. Layered Architecture (isolate the domain)

Title: Concentrate domain logic in one layer, isolated from UI, application, and infrastructure.
Description: When domain logic is smeared across UI and persistence code, it becomes impossible to see or evolve the model. Partition the program into layers (typically **User Interface**, **Application**, **Domain**, **Infrastructure**), each depending only on the layers below via loose coupling. The **Domain Layer** is the heart of the software; free domain objects from displaying, storing, or orchestrating themselves so they can express the model richly.

**Good example:**

```java
// Domain layer: pure model, no persistence or UI concerns.
final class Account {
    private Money balance;
    void debit(Money amount) { /* invariant-checking domain logic */ }
}
// Application layer: thin orchestration; no business rules.
class FundsTransferAppService {
    private final AccountRepository accounts;            // infrastructure behind a domain interface
    void transfer(AccountId from, AccountId to, Money amount) {
        Account src = accounts.findById(from);
        Account dst = accounts.findById(to);
        src.debit(amount); dst.credit(amount);          // rules live in the domain
        // persistence handled by repository/UoW in infrastructure
    }
}
```

**Bad example:**

```java
// Business rules tangled into a UI event handler with direct SQL.
button.addActionListener(e -> {
    long bal = jdbc.queryForLong("select balance from acct where id=?", fromId);
    if (bal - amount < 0) { showDialog("Insufficient"); return; }   // domain rule trapped in UI
    jdbc.update("update acct set balance=balance-? where id=?", amount, fromId);
    jdbc.update("update acct set balance=balance+? where id=?", amount, toId);
});
// The overdraft rule cannot be reused, tested, or evolved as part of a model.
```

### 7. The Smart UI "Anti-Pattern"

Title: Know when NOT to do DDD — the Smart UI is a legitimate choice for simple apps, and incompatible with Model-Driven Design.
Description: Putting all business logic into the UI (forms over a shared relational database, built with RAD tools) is highly productive for *simple* applications, usable by less-experienced developers, and easy to demo-and-tweak. But it cannot support a rich model: no reuse, no abstraction, no path to a deep model. Choose it deliberately when the domain is simple and unlikely to grow — and recognize that adopting it forecloses the other patterns in this book.

**Good example:**

```text
A throwaway internal CRUD tool with ~10 simple screens, no complex rules, a small
budget, and junior developers: a Smart UI (visual form builder + shared DB) ships
fast and is the right tradeoff. The decision is made consciously, knowing the limits.
```

**Bad example:**

```text
A core logistics product with intricate, evolving routing rules is built as a Smart UI
because it was "faster to start." Two years in, the same rule is copy-pasted across
40 screens, nothing can be tested in isolation, and no model can be distilled. The
anti-pattern was applied where Model-Driven Design was required.
```

### 8. Entities (Reference Objects)

Title: When an object is defined by identity and continuity over time rather than by its attributes, model it as an Entity.
Description: An *Entity* is something tracked through a thread of continuity — a Customer, an Order, an Account — that remains "the same thing" even as its attributes change, and is distinct from another with identical attributes. Give it a defined *identity* (a unique key, natural or system-generated) and keep its class focused on identity and life-cycle continuity; push descriptive attributes into Value Objects. Equality is by identity, not by field values.

**Good example:**

```java
final class Customer {                       // Entity: defined by identity
    private final CustomerId id;             // stable identity, set once
    private PersonName name;                  // mutable attribute (a Value Object)
    private Address address;                  // attributes can change over time

    Customer(CustomerId id, PersonName name) { this.id = id; this.name = name; }
    void relocate(Address newAddress) { this.address = newAddress; }

    @Override public boolean equals(Object o) {          // equality by identity only
        return o instanceof Customer c && id.equals(c.id);
    }
    @Override public int hashCode() { return id.hashCode(); }
}
```

**Bad example:**

```java
// Modeling an Entity by its attributes: two distinct customers who happen to share
// a name and address are wrongly treated as equal, and identity is lost on any edit.
class Customer {
    String name, address;
    @Override public boolean equals(Object o) {          // value equality on an Entity — WRONG
        return o instanceof Customer c && name.equals(c.name) && address.equals(c.address);
    }
}
```

### 9. Value Objects

Title: When you care only about *what* something is, not *which* one, model it as an immutable Value Object.
Description: A *Value Object* describes a characteristic — a Money, a Color, an Address, a DateRange — with no conceptual identity. Make it **immutable**, compare by attributes, and let it be freely shared, copied, and passed as a parameter. Its attributes should form a *conceptual whole*. Operations return new values rather than mutating. Treating descriptive concepts as Value Objects simplifies the design and eliminates aliasing bugs.

**Good example:**

```java
// Immutable, value-equal, self-validating, with side-effect-free operations.
public record Money(BigDecimal amount, Currency currency) {
    public Money {
        Objects.requireNonNull(currency);
        amount = amount.setScale(currency.getDefaultFractionDigits(), RoundingMode.HALF_EVEN);
    }
    public Money plus(Money other) {
        if (!currency.equals(other.currency)) throw new IllegalArgumentException("currency mismatch");
        return new Money(amount.add(other.amount), currency);   // returns a NEW value
    }
}
// records give value equality and immutability; instances are safely shared.
```

**Bad example:**

```java
// A mutable "value" with identity-style equality and shared-mutable aliasing bugs.
class Money {
    double amount;                 // float for money — also wrong (precision)
    String currency;
    void add(Money other) { this.amount += other.amount; }   // mutates in place
}
Money price = new Money();
Money total = price;               // aliased!
total.add(tax);                    // silently changed `price` too
```

### 10. Domain Services

Title: When an important operation is not a natural responsibility of any Entity or Value Object, model it as a stateless Domain Service.
Description: Some domain activities are *verbs*, not *things* — a funds transfer, a routing calculation. Forcing them onto an Entity distorts the model; making them procedural code outside the model loses them. Define a **Service**: an operation named in the Ubiquitous Language, with an interface stated in terms of other model elements, and **stateless** (any client may use any instance regardless of history). Keep Services thin and let them coordinate Entities/Value Objects. Distinguish *domain* Services (business meaning) from *application* and *infrastructure* Services (no business meaning).

**Good example:**

```java
// "Funds transfer" is a banking term involving two accounts and global rules —
// awkward on either Account, so it is a domain Service: stateless, model-typed.
interface FundsTransferService {
    TransferResult transfer(Account from, Account to, Money amount);   // domain language
}
final class FundsTransferServiceImpl implements FundsTransferService {
    public TransferResult transfer(Account from, Account to, Money amount) {
        from.debit(amount);                  // delegates real work to the Entities
        to.credit(amount);
        return TransferResult.completed(from, to, amount);
    }
}
```

**Bad example:**

```java
// Either a "phony" stateful object that represents nothing, or behavior wrongly
// jammed onto one Account so it must reach into another.
class Account {
    void transferTo(Account other, Money amount) {   // operation really spans TWO accounts
        this.balance = this.balance.minus(amount);
        other.balance = other.balance.plus(amount);   // Account now knows global transfer rules
    }
}
// The meaningful domain concept "funds transfer" is hidden inside one Entity.
```

### 11. Modules (Packages)

Title: Choose Modules that tell the story of the system and contain a cohesive set of concepts; name them in the Ubiquitous Language.
Description: *Modules* (packages) carry meaning, not just code organization. Partition the model so each Module is a cohesive concept understandable independently, with low coupling between Modules. Don't split by technical layer (all "controllers", all "daos") in a way that fragments a single concept; group by domain concept. Module names become part of the language ("the *billing* module"). Refactor the model and the Modules together — model-focused boundaries beat incidental ones.

**Good example:**

```text
com.shipping.cargo        // Cargo, RouteSpecification, Itinerary, Leg, Delivery
com.shipping.location     // Location, UnLocode
com.shipping.handling     // HandlingEvent, HandlingHistory
com.shipping.voyage       // Voyage, CarrierMovement, Schedule
// Each package is a cohesive domain concept you can reason about and name in speech.
```

**Bad example:**

```text
com.app.entities          // ALL entities from every concept, dumped together
com.app.services          // ALL services
com.app.daos              // ALL data access
// "Cargo" is now smeared across 3 packages by mechanical layer; concepts are not
// cohesive, coupling is high, and no package name tells a domain story.
```

### 12. Aggregates

Title: Cluster Entities and Value Objects into Aggregates with a single root and a clear boundary; enforce invariants within the boundary in one transaction.
Description: Without boundaries, object graphs become impossible to keep consistent. An *Aggregate* is a cluster treated as a unit for data changes. Designate one Entity as the **Aggregate root**: the only member outsiders may hold a reference to. Rules:
- The root has global identity and is responsible for checking invariants.
- Entities inside have only *local* identity, unique within the Aggregate.
- Nothing outside may reference internal members; the root may hand out *transient* references or *copies of Value Objects*.
- Only roots are obtained directly by database queries; internals are reached by traversal.
- One transaction commits changes to one Aggregate, keeping its invariants true; cross-Aggregate consistency is eventual.

**Good example:**

```java
final class Order {                          // Aggregate ROOT (global identity)
    private final OrderId id;
    private final List<OrderLine> lines = new ArrayList<>();   // internal Entities (local identity)
    private Money total = Money.zero(USD);

    void addLine(Product product, int qty) {        // all changes go THROUGH the root
        lines.add(new OrderLine(nextLineId(), product.sku(), qty, product.price()));
        recalculateTotal();
        enforceInvariant();                          // root guards the invariant
    }
    private void enforceInvariant() {
        if (total.isGreaterThan(creditLimit)) throw new CreditLimitExceeded(id, total);
    }
    List<OrderLine> lines() { return List.copyOf(lines); }   // hand out copies, not internals
}
// Repositories exist only for Order (the root), not for OrderLine.
```

**Bad example:**

```java
// No boundary: outsiders mutate internals directly, so no one can guarantee the
// order total / credit-limit invariant, and OrderLine gets its own repository.
class Order { public List<OrderLine> lines = new ArrayList<>(); public Money total; }
class OrderLineRepository { OrderLine findById(long id) { ... } }   // querying an internal!

order.lines.add(new OrderLine(...));     // bypasses the root; total now stale
someLine.setQuantity(9999);              // invariant silently violated
```

### 13. Factories

Title: Encapsulate complex creation of Aggregates and Value Objects in a Factory that produces a valid whole and hides concrete types.
Description: When constructing an object or whole Aggregate is complex enough to leak assembly logic onto clients (or onto the object itself), shift creation to a *Factory*. The Factory provides an interface in the client's terms, hides concrete classes, and creates the entire Aggregate atomically with its invariants enforced — so the object is *valid the moment it exists*. A Factory has no domain responsibility beyond creation but is part of the domain design. (Plain constructors are fine when construction is simple and the type is concrete.)

**Good example:**

```java
// Factory creates a whole, valid Cargo Aggregate; clients don't touch internals.
final class CargoFactory {
    Cargo newCargo(TrackingId id, RouteSpecification routeSpec) {
        Cargo cargo = new Cargo(id, routeSpec);
        cargo.deriveInitialDelivery();          // invariants established at birth
        return cargo;                            // returned ready and consistent
    }
    // Reconstitution factory (e.g., from persistence) preserves identity, skips
    // "new object" rules but still re-establishes invariants.
    Cargo reconstitute(CargoSnapshot s) { ... }
}
```

**Bad example:**

```java
// Clients hand-assemble an Aggregate piece by piece, so it passes through invalid
// intermediate states and every call site duplicates the assembly knowledge.
Cargo c = new Cargo();
c.setTrackingId(id);
c.setOrigin(origin);                 // momentarily: cargo with origin but no spec
c.setRouteSpec(routeSpec);
c.setDelivery(new Delivery());       // forgot deriveInitialDelivery() — inconsistent
```

### 14. Repositories

Title: Provide collection-like access to Aggregate roots through a Repository that hides the data store; provide Repositories only for roots.
Description: Clients should obtain persistent objects without touching SQL, ORMs, or query mechanics — otherwise the domain focus is lost and Aggregate boundaries are bypassed. A *Repository* gives the illusion of an in-memory collection of all objects of an Aggregate-root type: methods to add/remove, and methods that select by criteria and return fully reconstituted Aggregates. Provide Repositories **only for Aggregate roots** that truly need global access; reach everything else by traversal. Keep query/storage tech behind the Repository interface (which lives in the domain layer; implementation in infrastructure).

**Good example:**

```java
// Domain-layer interface in the Ubiquitous Language; infra provides the impl.
public interface CargoRepository {
    Cargo find(TrackingId trackingId);          // returns a fully reconstituted Aggregate
    List<Cargo> findCargosOnVoyage(VoyageNumber voyage);
    void store(Cargo cargo);                     // collection-like add/update
    TrackingId nextTrackingId();
}
// Client stays in the model:
Cargo cargo = cargoRepository.find(trackingId);
cargo.assignToRoute(itinerary);
cargoRepository.store(cargo);
```

**Bad example:**

```java
// Query logic leaks into the application/domain; and a Repository is exposed for a
// non-root internal Entity, letting callers fetch parts and break the Aggregate.
class CargoService {
    Cargo find(String id) {
        ResultSet rs = jdbc.executeQuery("select * from cargo where tracking_id='" + id + "'"); // SQL + injection
        return mapRow(rs);                                   // hand-mapping in the service
    }
}
class LegRepository { Leg findById(long legId) { ... } }      // Leg is internal to the Itinerary — no root!
```

---

## Part III — Refactoring Toward Deeper Insight

### 15. Refactoring Toward Deeper Insight (Breakthrough)

Title: Continuously refactor not just for clean code, but toward a deeper model — and expect occasional breakthroughs.
Description: Beyond technical refactoring (patterns from Fowler), DDD adds *refactoring toward deeper insight*: changing the model itself as understanding grows. Progress is gradual, punctuated by *breakthroughs* where a sudden reframing collapses complexity. Triggers to refactor the model: the code is awkward to talk about in the Ubiquitous Language; a new requirement forces unexpectedly broad changes (poor model fit); or experts reveal a concept the model lacks. Breakthroughs require a foundation of supple design and a habit of relentless refactoring; they cannot be scheduled, only enabled.

**Good example:**

```java
// BEFORE: an Account holds a tangle of overdraft/fee logic in if-branches.
// AFTER a breakthrough: the implicit concept "Overdraft Policy" becomes explicit,
// and the model reads like the experts' explanation.
interface OverdraftPolicy {                       // newly surfaced domain concept
    Money feeFor(Money requested, Account account);
    boolean allows(Money requested, Account account);
}
final class Account {
    private final OverdraftPolicy policy;          // composition over conditionals
    void withdraw(Money amount) {
        if (!policy.allows(amount, this)) throw new InsufficientFundsException(this, amount);
        balance = balance.minus(amount).minus(policy.feeFor(amount, this));
    }
}
```

**Bad example:**

```java
// "It compiles, ship it": the team never refactors the model. The awkward concept
// stays implicit, conditionals multiply, and small new rules force shotgun edits.
class Account {
    void withdraw(Money amount, int accountType, boolean vip, boolean promo) {
        if (accountType == 2 && !vip) { ... }      // meaning buried in flags
        else if (accountType == 2 && vip && promo) { ... }
        else if (accountType == 3) { ... }          // each new rule adds a branch
    }
}
```

### 16. Make Implicit Concepts Explicit (Constraints and Processes)

Title: Listen for concepts the experts use but the model lacks — especially Constraints and Processes — and give them their own model elements.
Description: A concept essential to understanding the model but never named is an *implicit concept*. Make it explicit as a class, interface, or Value Object so it can be discussed and reasoned about. Two broad categories hide especially often:
- **Constraints**: invariants buried inside method bodies. Extract a Constraint into its own method/object so it is named and testable, and so a developer sees it without reverse-engineering an `if`.
- **Processes**: domain procedures expressed as ad-hoc code. Model the *important* ones explicitly (often as a Service or a Specification), but only those the experts actually talk about — don't reify every loop.

**Good example:**

```java
// The constraint "a Bucket cannot exceed its capacity" is named and isolated.
final class Bucket {
    private double contents;
    private final double capacity;
    void add(double amount) {
        if (wouldOverflow(amount)) throw new BucketOverflowException(this, amount);
        contents += amount;
    }
    private boolean wouldOverflow(double amount) {     // explicit, testable constraint
        return contents + amount > capacity;
    }
}
```

**Bad example:**

```java
// The same constraint is an anonymous, unexplained branch — implicit knowledge.
class Bucket {
    double contents, capacity;
    void add(double amount) {
        if (contents + amount > capacity) return;      // silently drops? throws? unclear
        contents += amount;                            // the rule has no name and no test
    }
}
```

### 17. Specification

Title: Express a business rule, selection criterion, or condition as a predicate-like Value Object — a Specification — that can test any candidate object.
Description: Rules like "is this invoice *delinquent*?" or "does this product match the customer's *preferences*?" often get scattered or buried. A *Specification* is a Value Object whose job is to answer `isSatisfiedBy(candidate)`. It cleanly separates the statement of a rule from the object it constrains, and specifications **compose** with `and`/`or`/`not`. Specifications serve three roles: **validation** (does this object meet the criteria?), **selection/querying** (find objects that match), and **construction-to-order** (build an object satisfying the spec).

**Good example:**

```java
interface Specification<T> {
    boolean isSatisfiedBy(T candidate);
    default Specification<T> and(Specification<T> other) {
        return c -> this.isSatisfiedBy(c) && other.isSatisfiedBy(c);
    }
    default Specification<T> not() { return c -> !this.isSatisfiedBy(c); }
}
final class DelinquentInvoiceSpecification implements Specification<Invoice> {
    private final LocalDate asOf;
    DelinquentInvoiceSpecification(LocalDate asOf) { this.asOf = asOf; }
    public boolean isSatisfiedBy(Invoice invoice) {
        return invoice.dueDate().isBefore(asOf) && !invoice.isPaid();
    }
}
// Validation, selection, and composition all reuse the same rule object:
Specification<Invoice> overdueAndLarge =
    new DelinquentInvoiceSpecification(today).and(inv -> inv.amount().isGreaterThan(threshold));
List<Invoice> toChase = invoices.stream().filter(overdueAndLarge::isSatisfiedBy).toList();
```

**Bad example:**

```java
// The "delinquent" rule is copy-pasted into every place that needs it; the concept
// has no home, so the three uses drift apart and a rule change misses some sites.
boolean a = inv.getDueDate().before(now) && inv.getStatus() != PAID;      // in the report
boolean b = inv.dueDate().isBefore(now) && !inv.paid;                     // in the dunning job (subtly different!)
if (i.due < System.currentTimeMillis() && i.bal > 0) { ... }              // in the UI
```

### 18. Intention-Revealing Interfaces

Title: Name classes and operations for their effect and purpose, never for their mechanism, and conform names to the Ubiquitous Language.
Description: If a client developer must read the implementation to use a class, encapsulation has failed and bugs follow. *Intention-Revealing Interfaces* state *what* a thing does and *why* it matters — not *how*. Type names, method names, and argument names together reveal intent. Writing the test (client's view) before the implementation forces intention-first thinking.

**Good example:**

```java
// The interface poses the question; the means are hidden.
final class PigmentColor {
    PigmentColor mixedWith(PigmentColor other, double ratio) { ... }   // intent: "mix paint"
}
// A client reads "mixedWith" and knows exactly what they get, without internals.
```

**Bad example:**

```java
// Method names leak the algorithm and force readers into the implementation.
final class PigmentColor {
    PigmentColor convolveRGBChannels(PigmentColor o, double r) { ... }  // means, not intent
    void recomputeYUVAfterClamp() { ... }                              // client must understand internals
}
```

### 19. Side-Effect-Free Functions

Title: Put as much logic as possible into functions that return results with no observable side effects; isolate state-changing commands into simple operations.
Description: Operations split into *commands* (change state) and *queries/functions* (compute and return without side effects). Side effects make combinations dangerous and reasoning hard. Prefer *functions*, especially on immutable Value Objects, so results can be combined safely and an `Intention-Revealing Interface` can be used without studying internals. Move complex calculation into Value Objects (which can be created freely) and keep commands few and simple, returning no domain data.

**Good example:**

```java
// Mixing returns a NEW color; nothing observable changes. Safe to combine/chain.
public record PigmentColor(int red, int yellow, int blue) {
    public PigmentColor mixedWith(PigmentColor other, double ratio) {
        return new PigmentColor(                 // pure function, no mutation
            blend(red,    other.red,    ratio),
            blend(yellow, other.yellow, ratio),
            blend(blue,   other.blue,   ratio));
    }
}
PigmentColor result = base.mixedWith(tint, 0.3).mixedWith(shade, 0.1);   // composes cleanly
```

**Bad example:**

```java
// A "function" that secretly mutates its receiver and its argument: combining it
// corrupts shared state and the result depends on call order.
class PaintColor {
    int r, y, b;
    PaintColor mix(PaintColor other, double ratio) {
        this.r = blend(r, other.r, ratio);       // mutates `this`
        other.r = 0;                             // and the argument!
        return this;
    }
}
```

### 20. Assertions

Title: Make the post-conditions of operations and the invariants of classes and Aggregates explicit, so behavior is known without reading procedural code.
Description: As behavior is delegated across objects, it becomes hard to anticipate the result of a call. *Assertions* state the *correct state* — post-conditions and invariants — independent of *how* they are achieved. Where the language lacks built-in assertion/contract support, encode them as **automated unit tests** (easy to write because assertions are about states: arrange pre-conditions, act, assert post-conditions) and in documentation. Seek models whose coherent concepts let developers *infer* the intended assertions.

**Good example:**

```java
final class Stack<E> {
    // Invariant: size() >= 0; Post-condition of push: size() increased by 1, top()==pushed.
    private final Deque<E> items = new ArrayDeque<>();
    void push(E item) { items.push(item); }
    E top() { return items.peek(); }
    int size() { return items.size(); }
}
// Assertions captured as tests:
@Test void push_increasesSizeByOneAndSetsTop() {
    Stack<String> s = new Stack<>();
    s.push("a");
    assertEquals(1, s.size());          // post-condition
    assertEquals("a", s.top());         // post-condition
}
```

**Bad example:**

```java
// No stated invariants or post-conditions; correctness lives only in the reader's
// head, and delegated calls make the resulting state unknowable without tracing.
class Stack<E> {
    Deque<E> items = new ArrayDeque<>();
    void push(E item) { if (item != null) items.push(item); }   // silently ignores null? unclear
    // What is true after push()? Nobody states it; no test pins it down.
}
```

### 21. Conceptual Contours

Title: Decompose design elements along the natural fault lines (axes of change and stability) of the domain, not arbitrarily.
Description: Repeated refactoring reveals *shearing patterns* — what changes together and what stays stable. The underlying *Conceptual Contours* are the domain's real joints. Align operations, interfaces, classes, and Aggregates with these contours so that a typical change stays localized. Neither monolithic clumps nor over-fragmented primitives fit; the goal is a small set of interfaces that combine to make sensible statements in the Ubiquitous Language. Contours emerge from refactoring toward insight, rarely from up-front design.

**Good example:**

```java
// Domain truth: a "rate" and a "term" vary independently. Splitting along that
// contour means a change to one rarely disturbs the other.
record InterestRate(BigDecimal annualPercent) { /* stable concept */ }
record LoanTerm(int months) { /* varies on a different axis */ }
final class Loan {
    Money monthlyPayment(InterestRate rate, LoanTerm term) { ... }   // combines along contours
}
// Adding a new rate type or term option is a localized change.
```

**Bad example:**

```java
// One god-method couples unrelated axes; any change to rate rules forces edits that
// risk term logic, and vice versa, because the split ignores the domain's contours.
class Loan {
    Money compute(int rateCode, int termCode, int promoCode, boolean compounding, int dayCount) {
        // rate, term, promotion, compounding all entangled in one body
    }
}
```

### 22. Standalone Classes

Title: Minimize dependencies; aim for classes that can be understood and tested in near isolation, especially for the most intricate computations.
Description: Every association, parameter type, and return type is a dependency, and dependencies multiply the conceptual load. Modules and Aggregates limit the *web* of interdependencies, but within them, drive the most complex logic into *Standalone Classes* — low-coupling Value Objects that the connected classes hold and that can be studied and tested alone. Don't "dumb down" to primitives to achieve this; eliminate only the *non-fundamental* dependencies.

**Good example:**

```java
// The heavy computation lives in PigmentColor, which depends on nothing domain-
// specific and can be tested entirely on its own.
public record PigmentColor(int red, int yellow, int blue) {     // standalone, low coupling
    public PigmentColor mixedWith(PigmentColor o, double ratio) { ... }   // all the hard math here
}
final class Paint {                       // the connected class holds a standalone Value Object
    private PigmentColor color;
}
// PigmentColorTest needs no database, no Paint, no other domain class.
```

**Bad example:**

```java
// The intricate color math is tangled into Paint, which drags in Inventory, Store,
// and Pricing, so the computation can't be reasoned about or tested without all of them.
class Paint {
    Inventory inventory; Store store; PricingService pricing;
    Paint mix(Paint other, double ratio) {
        // color math interleaved with inventory/store/pricing lookups...
    }
}
```

### 23. Closure of Operations

Title: Where it fits, define an operation whose return type is the same as the type of its argument(s) — closed under that type.
Description: An operation *closed* under a type takes arguments of that type and returns that type, introducing no dependency on any other concept and reading at a high level (think integer multiplication: int × int → int). Such operations chain and combine naturally. Most opportunities are in Value Objects (you can freely create new ones); Entities are usually not the result of a computation. An operation may be closed under an abstract type with concrete arguments.

**Good example:**

```java
// Closed under Money: combining Money yields Money, with no foreign dependencies.
public record Money(BigDecimal amount, Currency currency) {
    public Money plus(Money other)  { return new Money(amount.add(other.amount), currency); }   // Money×Money→Money
    public Money times(int factor)  { return new Money(amount.multiply(valueOf(factor)), currency); }
}
Money total = lineTotal.plus(tax).plus(shipping);    // chains cleanly, all Money
```

**Bad example:**

```java
// The "add" returns a foreign type and pulls in unrelated concepts, so results
// can't be combined and the interface leaks dependencies.
class Money {
    LedgerEntry add(Money other, AccountingPeriod period, TaxTable taxes) { ... }  // not closed
}
// Money + Money no longer yields Money; you can't chain, and Money now depends on
// LedgerEntry, AccountingPeriod, and TaxTable.
```

### 24. Declarative Design

Title: Aim for a declarative style — describe the desired properties/rules and let the model execute them — built on supple design (especially composable Specifications).
Description: *Declarative design* lets a precise description of *what* should hold actually control the software (an "executable specification"), rather than spelling out *how*. True declarative frameworks are powerful but risky (rigidity, leaky abstractions). The pragmatic path in DDD is a *declarative style*: combine Side-Effect-Free Functions, Assertions, and composable **Specifications** so clients state intent and the supple model carries it out.

**Good example:**

```java
// A declarative style: state the rule by composing Specifications; the model runs it.
Specification<Container> safeStorage =
    ventilated.and(notTooHeavyFor(shelf)).and(notNextTo(explosives));

List<Container> placeable = candidates.stream()
    .filter(safeStorage::isSatisfiedBy)      // describe WHAT is wanted; HOW is encapsulated
    .toList();
// Adding a rule = composing another Specification, not editing imperative loops.
```

**Bad example:**

```java
// Imperative, hard-coded checks: the "what" is buried in nested procedural logic
// that must be rewritten whenever the rules change.
for (Container c : candidates) {
    if (c.isVentilated()) {
        if (c.weight() <= shelf.capacity()) {
            if (!isNextTo(c, explosives)) {
                placeable.add(c);            // rule meaning lost in control flow
            }
        }
    }
}
```

---

## Part IV — Strategic Design

Strategic patterns govern large parts of a system and must be decided at the team level. They fall into three groups: **Maintaining Model Integrity** (managing multiple models and contexts), **Distillation** (focusing effort on what matters), and **Large-Scale Structure** (giving the whole system a comprehensible shape).

### Maintaining Model Integrity

### 25. Bounded Context

Title: Explicitly define the boundary within which a particular model applies and keep that model strictly consistent inside it.
Description: A single unified model across a large system is unattainable; attempts produce a blurry, internally contradictory model. Instead, *explicitly* bound each model — in terms of team organization, the parts of the application it covers, and physical artifacts (codebases, schemas). Inside a *Bounded Context*, keep the model logically unified and the Ubiquitous Language precise; outside, other models apply. A term like "Customer" can mean different things in different contexts, and that is fine *as long as the boundary is explicit*.

**Good example:**

```text
Sales Context:    "Customer" = a prospect/account with leads, opportunities, a sales rep.
Support Context:  "Customer" = an entity with tickets, entitlements, an SLA tier.

Each is a separate Bounded Context with its own model and code. Inside Sales, the
model is kept rigorously consistent; the team does NOT try to make its Customer also
satisfy Support's needs. The boundary is named, owned, and reflected in separate
modules/services and schemas.
```

**Bad example:**

```text
One "Customer" class is forced to serve Sales, Support, Billing, and Shipping at once.
It accretes leadScore, slaTier, taxId, dockDoorPreference... Every team's change risks
the others; the meaning of fields is ambiguous; nobody can keep the model consistent.
The model has no boundary, so it has no integrity.
```

### 26. Continuous Integration

Title: Within a Bounded Context, merge all work frequently with automated tests so model fragmentation is caught immediately.
Description: Even inside one context, separate developers' understandings drift apart and "splinter" the model. *Continuous Integration* means merging code and other artifacts frequently, backed by automated tests that flag fragmentation fast, **and** relentlessly exercising the Ubiquitous Language so a shared view of evolving concepts is hammered out. Scope it to a single Bounded Context — integration *across* contexts (with translation) need not happen at the same pace.

**Good example:**

```text
Within the Booking context: every developer integrates to mainline several times a day;
a CI pipeline runs the model's unit/acceptance tests on each merge; the team meets the
moment two people model the same concept differently and reconciles it in language and code.
Concept drift is caught in hours, not months.
```

**Bad example:**

```text
Developers work on long-lived branches for weeks. Two of them independently evolve
"Itinerary" in incompatible directions. The eventual big-bang merge surfaces a fractured
model with contradictory rules that no test caught, and the Ubiquitous Language has
quietly split into two dialects.
```

### 27. Context Map

Title: Map the Bounded Contexts in play and the actual relationships and translations between them; name each context in the Ubiquitous Language.
Description: People work in multiple contexts without realizing it and lose track of where one model ends and another begins. A *Context Map* identifies each model in play (including implicit models in legacy/non-OO subsystems), names each Bounded Context, and describes the points of contact — translations, sharing, and the *relationship type* (Shared Kernel, Customer/Supplier, Conformist, Anticorruption Layer, Separate Ways, Open Host Service, Published Language). Map the *existing* terrain honestly first; plan transformations later.

**Good example:**

```text
CONTEXT MAP (current reality)

  [Booking Context] --Customer/Supplier--> [Routing Context (Open Host Service)]
  [Booking Context] --Anticorruption Layer--> [Legacy Mainframe Tracking]
  [Booking Context] --Shared Kernel--------- [Billing Context]
  [Reporting Context] --Separate Ways (no integration)

Each box is a named context that appears in team speech ("the Routing context").
Each arrow states the real relationship and how models translate across it.
```

**Bad example:**

```text
"We have a microservices architecture" — but no one can say where one model stops and
another begins, which terms mean the same thing across services, or how data is
translated. Services silently share a database and an aspirational "canonical model"
that each interprets differently. There is no map, so integration is guesswork.
```

### 28. Shared Kernel

Title: Two closely cooperating teams may share an explicitly agreed subset of the model (and its code/schema), changed only by consultation.
Description: When full Continuous Integration across two contexts is too costly but the duplication/translation overhead of total separation is high, designate a *Shared Kernel*: a deliberately small, explicitly agreed subset of the domain model — with its code and database design — shared by both teams. The kernel has special status: neither team changes it unilaterally. Integrate the shared part frequently (but a bit less often than each team's internal CI), running *both* teams' tests on every kernel change.

**Good example:**

```text
Booking and Billing both depend on a small, agreed Shared Kernel: { Money, Currency,
CustomerId, Address }. It lives in one shared module with one test suite. Changing
Money requires sign-off from both teams, and both teams' CI runs against it. The kernel
is kept intentionally tiny so the coupling is bounded.
```

**Bad example:**

```text
Two teams "share" half of a sprawling model through a 200-class common library that
either team edits at will. A unilateral change to "Order" by the Billing team breaks
Booking overnight. The "shared kernel" is too large and ungoverned, so it has the
coupling of one model with none of the integration discipline.
```

### 29. Customer/Supplier Development Teams

Title: When one context (downstream) consumes another (upstream), establish a clear customer/supplier relationship with negotiated, test-backed obligations.
Description: If the downstream team depends on the upstream team's model but they are separate, formalize it: the downstream team plays *customer* in the upstream team's planning, downstream requirements are negotiated and budgeted, and *jointly developed automated acceptance tests* pin the interface. Those tests join the upstream team's CI, freeing the upstream to change internals without breaking the downstream.

**Good example:**

```text
Shipping (downstream) needs Routing (upstream) to return itineraries in a stable shape.
In joint planning, Shipping's needs are scheduled as upstream backlog items. Together
they write acceptance tests for the Routing interface; those tests run in Routing's CI.
Routing can now refactor freely as long as the agreed tests stay green.
```

**Bad example:**

```text
The downstream team is at the mercy of an upstream team that changes its output format
without notice and treats downstream requests as charity. No shared tests guard the
interface, so every upstream release randomly breaks the downstream — an unmanaged
dependency masquerading as a relationship.
```

### 30. Conformist

Title: When the upstream model is good enough and the supplier has no motivation to serve you, eliminate translation by adhering slavishly to the upstream model.
Description: If you depend on an upstream team that won't accommodate your needs (no Customer/Supplier leverage), you have three options: build an Anticorruption Layer (costly), Separate Ways (lose the integration), or *Conformist* — adopt the upstream model wholesale for the integrated subset. Conformity removes translation complexity and gives you a shared Ubiquitous Language with the supplier, at the cost of binding you to the upstream model's quality and limiting you to additive enhancements. Choose it only when the upstream model is reasonably good and compatible.

**Good example:**

```text
Your app integrates with a well-designed industry-standard fulfillment platform whose
model is clean and stable, and the vendor won't customize for you. You CONFORM: your
integrated subset uses their Address, Shipment, and Status types directly, sharing their
language. No translation layer to maintain; you ride their model.
```

**Bad example:**

```text
Conforming to a messy, ill-fitting legacy model and letting its bad abstractions leak
into your Core Domain. Your rich pricing model is now contorted to match the legacy
system's flat "AMOUNT1..AMOUNT9" fields. Here Conformist was the wrong call — this is
exactly the case that needed an Anticorruption Layer.
```

### 31. Anticorruption Layer

Title: Insulate your model from a foreign or legacy model by building a translation layer that lets your clients work purely in their own terms.
Description: Connecting to another system (legacy or external) risks corrupting your model with its concepts. An *Anticorruption Layer* (ACL) is an isolating layer that exposes the other system's functionality in terms of *your* model, talking to it through its existing interface and translating in both directions. Implement it with **Facades** (a clean interface to the subsystem), **Adapters** (conform the foreign interface to what you need), and **translators** (convert concepts/data). The ACL is not merely a messaging mechanism — its job is *conceptual* translation.

**Good example:**

```java
// Your domain talks only to a domain-shaped interface; the ACL hides the legacy.
public interface CustomerLookup {                 // YOUR model's terms
    Customer findCustomer(CustomerId id);
}
// ACL: facade + adapter + translator around a crusty legacy API.
final class LegacyCustomerAnticorruptionLayer implements CustomerLookup {
    private final LegacyCrmGateway legacy;          // facade over the foreign system
    public Customer findCustomer(CustomerId id) {
        LegacyCustRecord rec = legacy.getCUST(id.value());        // foreign call
        return translate(rec);                                    // convert to YOUR model
    }
    private Customer translate(LegacyCustRecord rec) {            // conceptual translation
        return new Customer(new CustomerId(rec.CUSTNO),
                            PersonName.parse(rec.NM1 + " " + rec.NM2),
                            Address.of(rec.ADDR1, rec.CITY, rec.ZIP));
    }
}
```

**Bad example:**

```java
// The legacy model bleeds straight into the domain: your code now depends on
// LegacyCustRecord and its cryptic fields, corrupting your model.
class OrderService {
    void place(LegacyCustRecord cust, ...) {        // foreign type in domain logic
        if (cust.STATUS_CD == 'A' && cust.FLG3 == 'Y') { ... }   // legacy semantics everywhere
    }
}
```

### 32. Separate Ways

Title: If two sets of functionality have no essential relationship, declare their contexts entirely separate and let each be simple within its small scope.
Description: Integration is expensive. If a careful analysis shows two features do not truly need to call each other, share objects, or share data during operation, *Separate Ways* declares the Bounded Contexts to have **no connection at all**, freeing each team to find a simple, specialized solution. (Features can still be juxtaposed in the UI.) The cost is losing any automatic integration between them — so be sure the relationship really is inessential before choosing it.

**Good example:**

```text
An insurance app's "claims processing" and "employee expense reimbursement" share no
domain logic and no operational data flow, despite both being "the insurance system."
They are split into Separate Ways: two small, focused models, each simple within its
scope, optionally linked only by a shared portal navigation menu.
```

**Bad example:**

```text
Two genuinely interdependent contexts — Booking and Routing, which must exchange
itineraries constantly — are forced into Separate Ways "to keep them simple." Now every
interaction requires manual data re-entry and reconciliation. Separate Ways was applied
where integration was essential.
```

### 33. Open Host Service

Title: When a subsystem must integrate with many others, define a shared protocol of Services that gives open access to it.
Description: Building a bespoke translation layer for *each* consumer of a subsystem doesn't scale. Instead, define an *Open Host Service*: expose the subsystem's resources as a coherent set of Services over an open protocol that any consumer may use. Enhance the shared protocol for new integration needs in general; for a single consumer's idiosyncratic need, use a one-off translator rather than bloating the shared protocol. Consumers couple to the host's model/dialect, so keep the protocol simple and coherent (often paired with a **Published Language**).

**Good example:**

```text
A geocoding subsystem is consumed by booking, billing, and reporting. Rather than three
custom adapters, it publishes an Open Host Service: a small, documented set of Services
(LookupByAddress, LookupByCoordinates, ValidateRegion) over HTTP/JSON that all consumers
share. A rare special need from reporting is met by a one-off translator, keeping the
shared protocol clean.
```

**Bad example:**

```text
The geocoding subsystem has a different, undocumented integration hack for each of its
six consumers. Every new consumer means reverse-engineering and a new bespoke layer;
a change to the subsystem must be coordinated across six idiosyncratic interfaces. There
is no open, shared protocol.
```

### 34. Published Language

Title: Use a well-documented shared language as the common medium for communication between contexts, translating into and out of it.
Description: When models must be combined or many parties must exchange information, a *Published Language* is a documented, shared interchange language (often an industry standard — e.g. XML schemas for chemical formulae, genetic codes, or business documents) used as the common medium; each context translates to/from it. It avoids coupling everyone to one party's internal model and gives integration a stable, documented contract. It need not be invented from scratch — adopt an existing standard where one fits.

**Good example:**

```text
A logistics integration adopts an industry-standard EDI/XML Published Language for
"shipment instructions." Booking translates its model INTO the published schema; each
carrier translates OUT of it into their own. No party is coupled to another's internal
model; the schema is documented and versioned as the contract of record.
```

**Bad example:**

```text
Integration "language" = whatever one dominant system happens to emit, undocumented and
ever-changing. Every other party reverse-engineers its quirks and couples to its internal
representation. When that system refactors, all integrations break. There is no published,
neutral contract.
```

### Distillation

### 35. Core Domain

Title: Find the part of the model that is the reason the system exists, make it small and sharp, and apply your best talent there.
Description: Not all of a large model is equally valuable. The *Core Domain* is the distinctive part, central to users' goals, that differentiates the application and justifies building it rather than buying. *Boil the model down*: distinguish the Core sharply from supporting code, bring the most valuable, specialized concepts into relief, and keep the Core **small**. Assign top talent (not whoever is free) to the Core, invest in a deep model and supple design there, and minimize effort on the rest.

**Good example:**

```text
For a logistics company, the CORE DOMAIN is cargo routing optimization — the model and
algorithms that win customers. It is distilled into a small, clearly marked module, given
the strongest developers, and continuously refined toward a deep model. Authentication,
notifications, and reporting are explicitly NOT core and are kept lean.
```

**Bad example:**

```text
The team pours its best people and most modeling effort into a generic user-management
and reporting subsystem (because it was "interesting"), while the routing engine — the
actual differentiator — is a neglected tangle. Undistilled, the Core is buried in supporting
code, and the project's real value never gets a deep model.
```

### 36. Generic Subdomains

Title: Factor cohesive but non-differentiating subdomains out of the Core into separate modules; deprioritize them or buy/adopt off-the-shelf solutions.
Description: The Core is obscured when entangled with generic concerns (e.g., a generic calendar, money/currency, organization charts). Identify cohesive subdomains that are *not the motivation* for the project, factor them into separate Modules with no trace of your specialties, give them lower priority than the Core, and keep core developers off them (little domain knowledge to gain). Strongly consider off-the-shelf products or published models for these *Generic Subdomains*.

**Good example:**

```text
A shipping app needs a "time zone / business calendar" capability. Recognizing it as a
GENERIC SUBDOMAIN (every logistics app needs it; it doesn't differentiate), the team
extracts it into its own module and adopts a well-known library/published model instead
of hand-crafting it. Core developers stay focused on routing.
```

**Bad example:**

```text
The team lovingly builds a bespoke, highly clever calendar/scheduling engine entangled
with the routing Core. It adds no competitive value, consumes the best developers' time,
and couples generic date logic into the Core, making the differentiator harder to see and
evolve.
```

### 37. Domain Vision Statement

Title: Write a short, narrow statement of the Core Domain and the value it brings, to align the team's distillation effort.
Description: Teams lose a shared sense of *what makes this system special*. A *Domain Vision Statement* is a brief (~one page) description of the Core Domain and its "value proposition," written early and revised as insight grows. It ignores aspects that don't distinguish this model from others and shows how the model serves and balances diverse interests. It is a guidepost for ongoing distillation — not a design spec.

**Good example:**

```text
DOMAIN VISION STATEMENT (Cargo Routing System)
"The system finds and continuously revises optimal multi-leg routes for cargo against
customer route specifications and changing voyage schedules, minimizing cost and delay.
Its value lies in the routing model's ability to re-plan in response to disruptions faster
and more cheaply than manual planning. Booking, billing, and tracking exist to serve this."
(One page, focused on the differentiator, revised as the model deepens.)
```

**Bad example:**

```text
A 60-page requirements document that lists every screen and field with equal weight and
never says which part is the differentiator. The team cannot tell the Core from the
supporting cast, so distillation never happens and effort spreads evenly across everything.
```

### 38. Highlighted Core

Title: Make the Core Domain effortlessly visible within the model — via a short distillation document and/or by flagging core elements in the code/repository.
Description: A Domain Vision Statement says *what* the Core is but doesn't help you *find* it in a large model. *Highlight* the Core in one of two complementary ways: (1) a **Distillation Document** — a very brief (3–7 sparse pages) description of the Core concepts and their primary interactions, pointing into the code; and/or (2) a **Flagged Core** — mark core elements directly in the primary model repository (annotations, naming, tooling) so any developer can see at a glance what is in or out of the Core, with low maintenance.

**Good example:**

```java
// Flagged Core: a marker makes core membership effortless to see in the code.
@CoreDomain
public final class RouteSpecification { ... }
@CoreDomain
public final class Itinerary { ... }

// Plus a 4-page Distillation Document: "The Core is the Cargo–RouteSpecification–
// Itinerary–Delivery cluster and the RoutingService that satisfies specs against
// Voyage schedules," with pointers to those classes.
```

**Bad example:**

```text
A 500-class model with no indication of what matters. New developers spend weeks
guessing which parts are the differentiator. The "design doc" is an auto-generated UML
dump of all classes — comprehensive, unmaintained, and useless for finding the Core.
```

### 39. Cohesive Mechanisms

Title: Extract a conceptually complex computational mechanism into a separate, intention-revealing framework, leaving the Core to express *what*, not *how*.
Description: A Core obscured by intricate algorithmic machinery (a graph solver, a constraint engine) is hard to read. Partition a *Cohesive Mechanism* into a lightweight framework with an **Intention-Revealing Interface** — especially watch for known formalisms (graph theory, well-categorized algorithms). The Core then expresses the *problem* ("what") and delegates the *solution* ("how") to the mechanism. (Distinct from a Generic Subdomain, which models part of the *domain*; a Cohesive Mechanism provides a *method of solving*, not a domain concept.)

**Good example:**

```java
// Core states the problem in domain terms; a cohesive graph-routing mechanism solves it.
interface RouteFinder {                                  // intention-revealing interface
    Itinerary shortestRoute(Location from, Location to, LocalDate by);
}
// The Core uses it without knowing the graph algorithm inside:
final class RoutingService {
    private final RouteFinder routeFinder;               // cohesive mechanism (Dijkstra/A* inside)
    Itinerary route(RouteSpecification spec) {
        return routeFinder.shortestRoute(spec.origin(), spec.destination(), spec.deadline());
    }
}
```

**Bad example:**

```java
// Priority queues, relaxation loops, and visited-sets are interleaved with cargo and
// voyage concepts, so the Core reads as graph plumbing instead of domain intent.
final class RoutingService {
    Itinerary route(RouteSpecification spec) {
        PriorityQueue<Node> open = new PriorityQueue<>(...);   // algorithm machinery...
        Map<Node,Double> dist = new HashMap<>();
        while (!open.isEmpty()) { /* 80 lines of Dijkstra entangled with Cargo/Voyage */ }
    }
}
```

### 40. Segregated Core

Title: Refactor to pull the Core into its own cohesive, low-coupling module, separating it from supporting players — even ill-defined ones.
Description: When the Core is entangled with supporting elements, *segregate* it: refactor the model to move all generic/supporting elements into other objects and packages, strengthen the Core's internal cohesion, and reduce its coupling to the rest — even if this means breaking apart highly coupled elements. (This is the mirror image of factoring out Generic Subdomains, applied from the Core's side.) The result is a Core module you can hold in your head and evolve aggressively.

**Good example:**

```text
BEFORE: package com.shipping.cargo mixes RouteSpecification (core), Itinerary (core),
Address validation (generic), and PDF label rendering (supporting).

AFTER (Segregated Core):
  com.shipping.routing.core   -> RouteSpecification, Itinerary, Delivery, RoutingService
  com.shipping.location       -> Address, validation        (supporting)
  com.shipping.labeling       -> label rendering            (supporting)
The Core package is now small, cohesive, and weakly coupled to the rest.
```

**Bad example:**

```text
The Core classes stay scattered across general-purpose packages next to utilities,
DTOs, and rendering code. To understand the routing model you must read ten packages
and mentally filter out the noise. Nothing is segregated, so the Core can't be reasoned
about or evolved as a unit.
```

### 41. Abstract Core

Title: Lift the most fundamental concepts and interactions into an abstract model in its own module, with specialized implementations in subdomain modules.
Description: When even the Segregated Core is large, and interactions *between* subdomains are mostly between their most fundamental concepts, distill an *Abstract Core*: factor the deepest concepts into abstract classes/interfaces that express most cross-component interaction, and place this abstract model in its own Module. Specialized, detailed implementations live in their own subdomain Modules and reference the Abstract Core but not each other — decoupling the subdomains while giving a succinct overview of the main concepts.

**Good example:**

```java
// Abstract Core module: the fundamental concepts and their interactions.
package com.shipping.core;                     // ABSTRACT CORE
public interface RoutingGoal { boolean satisfiedBy(TransportPlan plan); }
public interface TransportPlan { Location start(); Location end(); }

// Subdomain modules depend on the Abstract Core, not on each other:
package com.shipping.cargo;                    // references com.shipping.core
final class RouteSpecification implements RoutingGoal { ... }
package com.shipping.voyage;                   // references com.shipping.core
final class VoyageItinerary implements TransportPlan { ... }
```

**Bad example:**

```text
Every subdomain module imports every other subdomain module directly to reach concrete
classes. cargo -> voyage -> handling -> cargo (cyclic). There is no abstract overview;
to grasp the main concepts you must read all the concrete detail, and any change ripples
across all subdomains.
```

### Large-Scale Structure

### 42. Evolving Order

Title: Let the large-scale structure evolve with the application; do not freeze a structure up front or over-constrain detailed design.
Description: A premature, rigid system-wide structure forces unnatural designs on the parts and rots as understanding grows. *Evolving Order* means a conceptual large-scale structure is allowed to change — even to a completely different *kind* of structure — as the application evolves, and it must not over-constrain detailed model decisions. Favor manageability of the whole over locally optimal structuring of each part, but keep the rules loose enough that they *help* rather than obstruct. Often it is best to add a large-scale structure only when one is genuinely needed.

**Good example:**

```text
A system starts with no imposed global structure. As it grows, a "responsibility layers"
structure emerges naturally and is adopted. A year later the team recognizes it no longer
fits and refactors to a different structure. The structure serves the application and is
revised as understanding deepens — it is never treated as immovable.
```

**Bad example:**

```text
On day one, an architect mandates a rigid 7-layer global structure and forbids deviation.
Two years in, half the modules contort themselves to fit slots that don't match their
natural shape, and no one may change the structure. It obstructs rather than guides, and
the parts are all suboptimal to satisfy a frozen whole.
```

### 43. System Metaphor

Title: When a concrete analogy captures the team's imagination and usefully guides design, adopt it as a large-scale structure and fold it into the Ubiquitous Language.
Description: A *System Metaphor* (from Extreme Programming) is a vivid analogy for the whole system ("the system is a *pipeline*", "a *layered cake*", "a *firewall*") that shapes thinking and communication. Adopt one only when it genuinely emerges and leads thinking in a useful direction; organize the design around it and absorb it into the language. Because all metaphors are inexact, keep re-examining it for over-extension and drop it if it starts to mislead.

**Good example:**

```text
A streaming-data system adopts the "assembly line" metaphor: stages (stations) transform
units (workpieces) and pass them downstream; back-pressure is a "jam." The metaphor enters
the Ubiquitous Language and guides module boundaries and naming, improving communication.
The team watches for places the analogy breaks (e.g., branching) and refines or limits it.
```

**Bad example:**

```text
A metaphor is imposed top-down ("everything is a document") and clung to even where it's a
poor fit, so a real-time control loop is awkwardly modeled as "editing a document." The
metaphor misleads design rather than guiding it, and no one is willing to abandon it.
```

### 44. Responsibility Layers

Title: Cast the natural strata of the domain — identified by differing rates and sources of change — as broad abstract responsibility layers, and fit each model element into one.
Description: A common large-scale structure: look at the conceptual dependencies and the *axes/rates of change* in the domain, and where you find natural strata, name them as broad abstract *responsibilities* that tell the high-level story of the system (e.g., for a logistics/operations system: **Potential → Operations → Decision/Policy → Commitment**). Refactor so each object, Aggregate, and Module fits neatly within one layer's responsibility, with dependencies flowing in one direction. The layers are about *responsibility*, not technical tiers.

**Good example:**

```text
RESPONSIBILITY LAYERS (shipping operations), each changing at a different rate/source:

  Decision Support   -> routing policy, what-if analysis        (changes with strategy)
  Operations         -> Cargo, Itinerary, HandlingEvent         (changes with daily work)
  Capability/Potential -> Voyage schedules, Locations, fleet    (changes with infrastructure)

Each domain element is assigned to exactly one layer; higher layers depend on lower ones.
The layer names tell the system's story.
```

**Bad example:**

```text
"Layers" are the usual technical tiers (controller/service/dao) relabeled as domain
structure. They say nothing about domain responsibility or rates of change, objects are
assigned by mechanical convenience, and dependencies criss-cross. The structure conveys
no domain story and provides no real guidance.
```

### 45. Knowledge Level (Reflection)

Title: When users/superusers must customize the structure and behavior of the basic model, split it into two levels — a concrete operational level and a Knowledge Level that describes and constrains it.
Description: Some domains require the model itself to be configurable (e.g., an org defines its own employee types and rules). Rather than a fully generic reflective framework, create a *Knowledge Level*: a distinct set of objects that *describe and constrain* the structure and behavior of the basic (operational) model. Keep the two levels separate — one very concrete, one reflecting rules a user/superuser can customize. Use sparingly: it removes complexity by freeing operational objects from being jacks-of-all-trades, but the indirection adds some obscurity back.

**Good example:**

```java
// KNOWLEDGE LEVEL: describes/configures what an account type is and what it allows.
final class AccountType {                         // a "superuser-editable" descriptor
    private final String name;
    private final Money overdraftLimit;
    private final InterestRate rate;
    boolean allowsOverdraft(Money requested, Money balance) {
        return balance.minus(requested).isGreaterThanOrEqual(overdraftLimit.negate());
    }
}
// OPERATIONAL LEVEL: concrete instances governed by their AccountType.
final class Account {
    private final AccountType type;               // points UP to the knowledge level
    private Money balance;
    void withdraw(Money amount) {
        if (!type.allowsOverdraft(amount, balance)) throw new InsufficientFundsException(this, amount);
        balance = balance.minus(amount);
    }
}
// A superuser configures AccountTypes without code changes; Accounts just obey them.
```

**Bad example:**

```java
// To support "customizable account behavior", a fully generic reflective rule engine is
// built where rules are arbitrary strings interpreted at runtime. Operational objects and
// their configuration are fused, the model is unreadable, and the power is intoxicating
// but the indirection hides all domain meaning.
class Account {
    Map<String,Object> attributes;
    List<String> ruleScripts;       // eval'd at runtime — no explicit knowledge level, no clarity
}
```

### 46. Pluggable Component Framework

Title: When many applications must interoperate over a mature, distilled Abstract Core, expose that core as interfaces and let diverse implementations plug in.
Description: A late-stage strategic option (high commitment, requires a deep, stable Abstract Core): distill an **Abstract Core** of interfaces and interactions and build a framework that lets diverse implementations of those interfaces be freely substituted, and lets any application use the components so long as it operates strictly through the Abstract Core's interfaces. High-level abstractions are shared system-wide; specialization happens in pluggable Modules. Apply only when the domain is well understood and you have multiple applications/components to integrate.

**Good example:**

```java
// Abstract Core published as interfaces; vendors/teams plug in implementations.
package org.openshipping.spi;                 // shared Abstract Core
public interface CarrierMovement { Schedule schedule(); }
public interface RoutingStrategy { Itinerary route(RouteSpecification spec, Network net); }

// Independent components plug in without knowing each other:
class AirCarrierMovement implements CarrierMovement { ... }      // one pluggable component
class SeaCarrierMovement implements CarrierMovement { ... }      // another
class CostMinimizingRouting implements RoutingStrategy { ... }   // swappable strategy
// Any application uses these strictly through the spi interfaces.
```

**Bad example:**

```text
A team imposes a heavyweight pluggable-component framework on a single application with a
shallow, still-changing model. The abstract interfaces are guesses; every new requirement
breaks them; the framework's machinery (registries, lifecycles, classloaders) dwarfs the
domain logic. The pattern was applied before the model was deep or shared enough to justify it.
```

## Output Format

When you apply this skill to a user's domain or code, structure your response as follows:

- **ANALYZE** the domain and supplied code: identify the model concepts and the language in use, and which DDD patterns apply or are violated, citing each by name (e.g., "Aggregate", "Value Object", "Bounded Context", "Anticorruption Layer").
- **CATEGORIZE** findings by scope — **Tactical** (Entities, Value Objects, Domain Services, Modules, Aggregates, Factories, Repositories, Supple Design) vs **Strategic** (Bounded Contexts, Context Map, Distillation, Large-Scale Structure) — and by impact (CRITICAL model/consistency integrity, MAINTAINABILITY, EXPRESSIVENESS, STRATEGIC alignment).
- **EXPLAIN** for each finding the relevant pattern's rationale and show the targeted Good vs. Bad contrast as it applies to the user's domain, always anchoring names in the Ubiquitous Language.
- **APPLY** the most valuable, lowest-risk improvements first — typically: align names with the language, isolate the domain layer, make a concept an explicit Entity/Value Object, set an Aggregate boundary, introduce a Repository/Factory, extract a Specification — before large strategic restructuring.
- **PRIORITIZE** a short, ordered plan (tactical clarifications and supple-design refactorings → Aggregate/Repository/Factory structure → Bounded Context boundaries, Context Map relationships, and Core distillation).
- **VALIDATE** that all changes compile and tests pass before reporting success; treat any aggregate-boundary, identity, or context change as behavior-sensitive.

## Safeguards

- **BLOCKING SAFETY CHECK**: Run the project build (e.g. `mvn compile`) before applying ANY structural model change — compilation failure is a HARD STOP.
- **CRITICAL VALIDATION**: Run the full test build (e.g. `mvn clean verify`) after applying changes; report failures honestly with the actual output.
- **BEHAVIOR PRESERVATION**: Extracting Value Objects, changing Aggregate boundaries, introducing Repositories/Factories, and adding translation layers must preserve observable behavior unless the user explicitly authorizes a contract change.
- **CONSISTENCY BOUNDARIES**: Never let an invariant span Aggregates within a single transaction; enforce invariants inside one Aggregate per transaction and make cross-Aggregate consistency explicitly eventual.
- **MODEL INTEGRITY**: Do not silently unify models across Bounded Contexts — translate at the boundary (Anticorruption Layer / Open Host Service / Published Language) and keep each context's Ubiquitous Language internally consistent.
- **NO ANEMIC OR PHONY OBJECTS**: Every class, Service, and layer must correspond to a domain concept named in the Ubiquitous Language; reject data-bag objects with logic elsewhere and "phony" objects that represent nothing.
- **ENGAGE THE EXPERT**: When domain meaning is ambiguous, surface it and ask rather than inventing terminology — a change to the language is a change to the model.
- **STRATEGY IS A TEAM DECISION**: Bounded Context boundaries, context relationships, Core Domain choice, and Large-Scale Structure affect the whole project — flag them as team-level decisions, not unilateral refactorings.
- **INCREMENTAL SAFETY**: Apply one pattern at a time and re-validate; do not batch many structural or strategic changes without intermediate verification.
- **NO OVER-APPLICATION**: These are patterns, not mandates — the Smart UI, Conformist, and Separate Ways are sometimes the right call. Note where a pattern legitimately does not apply rather than forcing it, and prefer the simplest design that expresses the model faithfully.

