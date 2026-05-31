# Refactoring.Guru — Design Patterns Catalog (supplement)

## Role

You are a Senior software engineer choosing and applying Gang-of-Four design patterns. This reference supplements the Head First reference with the **decision-making angle** from refactoring.guru: for each of the 22 GoF patterns it gives the **Intent**, **Applicability** ("use it when…"), condensed **implementation steps**, **Pros/Cons** trade-offs, and **Relations with other patterns**. Source: https://refactoring.guru/design-patterns (Alexander Shvets / refactoring.guru).

## Goal

Head First teaches *how each pattern works* with Good/Bad code. This file answers the next questions a practitioner asks: **When should I use it? What does it cost? Which patterns does it combine with or compete against?** Use it together with `head-first-design-pattern-book.md`:

- Confirm a pattern is warranted by matching the situation to its **Applicability** bullets.
- Weigh the **Cons** before introducing indirection (respect "don't force a pattern").
- Use **Relations** to pick between look-alikes (Strategy vs State vs Bridge; Adapter vs Decorator vs Proxy; Factory Method vs Abstract Factory) and to find natural combinations (Composite + Iterator/Visitor, Command + Memento, Abstract Factory + Bridge).

## What is a design pattern? (concepts)

- **Definition:** "Design patterns are typical solutions to commonly occurring problems in software design. They are like pre-made blueprints that you can customize to solve a recurring design problem in your code."
- **Pattern vs. algorithm:** an algorithm is a precise recipe (exact steps); a pattern is a higher-level blueprint — it describes the desired result and structure but leaves the concrete implementation to you, so the same pattern yields different code in different programs.
- **A pattern description usually contains:** *Intent* (the problem + solution in brief), *Motivation* (deeper explanation), *Structure* (classes and relationships), *Code example*; many catalogs add *Applicability*, *Implementation steps*, and *Relations to other patterns*.
- **Classification by intent:**
  - **Creational** — "provide object creation mechanisms that increase flexibility and reuse of existing code" (Factory Method, Abstract Factory, Builder, Prototype, Singleton).
  - **Structural** — "explain how to assemble objects and classes into larger structures, while keeping these structures flexible and efficient" (Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy).
  - **Behavioral** — "take care of effective communication and the assignment of responsibilities between objects" (Chain of Responsibility, Command, Iterator, Mediator, Memento, Observer, State, Strategy, Template Method, Visitor).
  - Patterns also span a complexity range: **idioms** are the most basic, low-level (often language-specific); **architectural patterns** are the most universal, high-level (used to design whole applications).
- **A brief history:**
  - **Christopher Alexander** introduced the concept of patterns in architecture (*A Pattern Language: Towns, Buildings, Construction*), describing a "language" of urban design patterns.
  - **The Gang of Four** — Erich Gamma, Richard Helm, Ralph Johnson, and John Vlissides — adapted the idea for software. In **1994** they published *Design Patterns: Elements of Reusable Object-Oriented Software* (the "GoF book") with 23 patterns. It became a bestseller and the foundation of the discipline.
  - Since 1994, "dozens of other object-oriented patterns have been discovered," and the pattern idea spread beyond OO to other programming paradigms and other fields.

- **Criticisms (use patterns judiciously):**
  - **Kludges for a weak language** — "the need for patterns arises when people choose a programming language or a technology that lacks the necessary level of abstraction"; first-class functions can subsume Strategy/Command, etc.
  - **Inefficient solutions** — applying a pattern dogmatically "without adapting [it] to the context of their project" yields suboptimal designs.
  - **Unjustified use** — novices apply patterns everywhere, "even in situations where simpler code would do just fine." (Mirrors Head First's "don't force a pattern" / pattern fever.)

## Quick "which pattern when" selector

| You need to… | Consider |
|---|---|
| Create objects without naming concrete classes | Factory Method, Abstract Factory |
| Build a complex object step by step / avoid telescoping constructors | Builder |
| Copy pre-configured objects cheaply | Prototype |
| Guarantee a single shared instance | Singleton |
| Make incompatible interfaces work together | Adapter |
| Let an abstraction and its implementation vary independently | Bridge |
| Treat individual objects and trees of objects uniformly | Composite |
| Add responsibilities to an object at runtime without subclassing | Decorator |
| Simplify access to a complex subsystem | Facade |
| Fit a huge number of objects in RAM by sharing state | Flyweight |
| Control access to an object (lazy/remote/protected/cached) | Proxy |
| Pass a request along a chain of possible handlers | Chain of Responsibility |
| Turn a request into an object (queue, log, undo) | Command |
| Traverse a collection without exposing its structure | Iterator |
| Reduce chaotic many-to-many dependencies | Mediator |
| Snapshot and restore an object's state | Memento |
| Notify many objects of state changes | Observer |
| Change behavior as internal state changes | State |
| Select an interchangeable algorithm at runtime | Strategy |
| Fix an algorithm skeleton, vary specific steps | Template Method |
| Add operations to a class hierarchy without editing it | Visitor |

---

## Creational Patterns

### 1. Factory Method — Creational

**Intent:** "Factory Method is a creational design pattern that provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created."

**Use it when:**
- You don't know beforehand the exact types and dependencies of the objects your code will work with.
- You want to let users of your library/framework extend its internal components.
- You want to save resources by reusing existing objects instead of rebuilding them.

**Implementation (key steps):**
1. Make all products follow a common product interface.
2. Add an (initially empty) factory method in the creator returning that interface.
3. Replace direct constructor calls in creator code with calls to the factory method.
4. Add a creator subclass per product type and override the factory method in each.
5. Optionally keep a parameterized factory method (or make it abstract if the base has no default).

**Pros:** avoids tight coupling between creator and concrete products; Single Responsibility (creation in one place); Open/Closed (add product types without breaking clients).
**Cons:** can introduce many new subclasses, raising complexity.
**Relations:** designs often start with Factory Method and evolve toward Abstract Factory/Prototype/Builder; Abstract Factory is often built from Factory Methods; Factory Method is a specialization of Template Method (and can be a step within one); pairs with Iterator so subclasses return different iterators.

### 2. Abstract Factory — Creational

**Intent:** "Abstract Factory is a creational design pattern that lets you produce families of related objects without specifying their concrete classes."

**Use it when:**
- Your code must work with various families of related products without depending on their concrete classes.
- Products may be unknown beforehand or you want room for future variants.
- A class has a set of factory methods that blur its primary responsibility.

**Implementation (key steps):**
1. Map a matrix of product *types* × product *variants*.
2. Declare abstract product interfaces; have all concrete products implement them.
3. Declare the abstract factory interface with a creation method per product type.
4. Implement one concrete factory per variant.
5. Add initialization code that picks the right concrete factory (config/environment).
6. Replace direct product constructor calls with calls to the factory's creation methods.

**Pros:** guarantees products from one factory are compatible; decouples concrete products from client code; Single Responsibility; Open/Closed.
**Cons:** many new interfaces/classes can over-complicate the code.
**Relations:** often built from Factory Methods (or composed with Prototype); can be an alternative to Facade for hiding subsystem creation; pairs with Bridge when abstractions need specific implementations; factories are frequently Singletons.

### 3. Builder — Creational

**Intent:** "Builder is a creational design pattern that lets you construct complex objects step by step."

**Use it when:**
- You want to get rid of "telescoping constructors" (many optional parameters).
- You need different representations of a product via similar construction steps.
- You must construct Composite trees or other complex objects step by step.

**Implementation (key steps):**
1. Declare common construction steps in a builder interface.
2. Implement a concrete builder per representation, plus a method to fetch the result.
3. (Optional) add a Director to encapsulate reusable construction sequences.
4. Client creates a builder, passes it to the director (or drives it directly), then retrieves the product.

**Pros:** construct objects step by step / defer or recurse steps; reuse construction code across representations; isolates complex construction from business logic (SRP).
**Cons:** more classes → more overall complexity.
**Relations:** Builder vs Abstract Factory — Builder builds one complex object step by step; Abstract Factory creates families of products immediately; combine Builder with Bridge (director = abstraction, builders = implementations); builders are often Singletons; great for recursive Composite construction.

### 4. Prototype — Creational

**Intent:** "Prototype is a creational design pattern that lets you copy existing objects without making your code dependent on their classes."

**Use it when:**
- Your code shouldn't depend on the concrete classes of objects you copy.
- You want to reduce subclasses that differ only in how they initialize objects (clone a configured exemplar instead).

**Implementation (key steps):**
1. Declare a prototype interface with a `clone` method (or add it across the hierarchy).
2. Give each class a copy constructor that copies all fields from a passed instance.
3. `clone` typically just calls the copy constructor.
4. (Optional) keep a registry of frequently used prototypes.

**Pros:** clone without coupling to concrete classes; remove repeated initialization; produce complex objects conveniently; an alternative to inheritance for configuration presets.
**Cons:** cloning objects with circular references is tricky.
**Relations:** can implement Abstract Factory's creation; helps store Command copies in history; useful when designs lean on Composite/Decorator (clone complex structures); sometimes a simpler alternative to Memento.

### 5. Singleton — Creational

**Intent:** "Singleton is a creational design pattern that lets you ensure that a class has only one instance, while providing a global access point to this instance."

**Use it when:**
- A class must have just a single instance shared by all clients (e.g., one shared database object).
- You need stricter control over a global variable than a plain global gives you.

**Implementation (key steps):**
1. Add a private static field for the instance.
2. Add a public static accessor that lazily creates and returns it.
3. Make the constructor private.
4. Replace direct constructor calls in clients with the accessor.

**Pros:** guarantees a single instance; provides a global access point; initialized only on first use.
**Cons:** violates Single Responsibility (solves two problems at once); can mask bad design / hidden coupling; needs special handling in multithreaded code; hard to unit-test (private constructor, static method can't be overridden / stubbed).
**Relations:** a Facade can often become a Singleton; resembles Flyweight but a Singleton has exactly one (often mutable) instance whereas Flyweights are many and immutable; Abstract Factories/Builders/Prototypes are often implemented as Singletons.

---

## Structural Patterns

### 6. Adapter — Structural

**Intent:** "Adapter is a structural design pattern that allows objects with incompatible interfaces to collaborate."

**Use it when:**
- You want to use an existing class whose interface isn't compatible with the rest of your code.
- You want to reuse several existing subclasses that lack common functionality you can't add to the superclass.

**Implementation (key steps):**
1. Identify the incompatible service class and the client interface it must satisfy.
2. Create an adapter that implements the client interface.
3. Hold a reference to the service (usually via constructor).
4. Implement each client-interface method by delegating to the service and converting interface/data formats.

**Pros:** Single Responsibility (conversion code separated from business logic); Open/Closed (new adapters without breaking clients).
**Cons:** adds classes/interfaces; sometimes simpler to just change the service class.
**Relations:** Adapter changes an existing interface (Bridge is designed up-front); Adapter gives a *different* interface, Proxy keeps the *same* one, Decorator gives an *enhanced* one; Facade defines a *new* interface over a subsystem.

### 7. Bridge — Structural

**Intent:** "Bridge is a structural design pattern that lets you split a large class or a set of closely related classes into two separate hierarchies—abstraction and implementation—which can be developed independently of each other."

**Use it when:**
- You want to divide and organize a monolithic class that has several variants of some functionality.
- You need to extend a class along several independent (orthogonal) dimensions.
- You need to switch implementations at runtime.

**Implementation (key steps):**
1. Identify the orthogonal dimensions (abstraction vs platform, domain vs infrastructure).
2. Define the abstraction's operations; declare the platform operations in an implementation interface.
3. Implement concrete implementations of that interface.
4. Give the abstraction a reference to an implementation and delegate to it.
5. Add refined abstractions as needed; the client links an abstraction to an implementation and uses only the abstraction.

**Pros:** platform-independent classes; clients see only high-level abstractions; Open/Closed; Single Responsibility (high-level logic vs platform detail).
**Cons:** can over-complicate a highly cohesive class.
**Relations:** designed up-front (unlike Adapter); shares a composition structure with State/Strategy/Adapter but solves a different problem; pairs with Abstract Factory and with Builder (director = abstraction).

### 8. Composite — Structural

**Intent:** "Composite is a structural design pattern that lets you compose objects into tree structures and then work with these structures as if they were individual objects."

**Use it when:**
- You must implement a tree-like object structure.
- You want client code to treat simple and complex elements uniformly.

**Implementation (key steps):**
1. Confirm the model can be a tree of leaves and containers.
2. Declare the component interface with methods meaningful to both.
3. Create leaf class(es) for simple elements.
4. Create a container holding child components (typed to the interface) with add/remove methods.

**Pros:** work with complex trees via polymorphism and recursion; Open/Closed (new element types without breaking code).
**Cons:** hard to give a common interface to classes whose functionality differs a lot; the interface may become over-generalized.
**Relations:** build trees with Builder; traverse with Iterator; run operations across a tree with Visitor; shared leaves can be Flyweights; Chain of Responsibility often rides on a Composite; structurally like Decorator (Composite "sums" children, Decorator "adds" behavior); Prototype helps clone whole trees.

### 9. Decorator — Structural

**Intent:** "Decorator is a structural design pattern that lets you attach new behaviors to objects by placing these objects inside special wrapper objects that contain the behaviors."

**Use it when:**
- You must add responsibilities to objects at runtime without breaking the code that uses them.
- Extending behavior via inheritance is awkward or impossible (e.g., `final` classes).

**Implementation (key steps):**
1. Model the domain as a primary component + optional layers.
2. Extract the common methods into a component interface.
3. Create a concrete component with base behavior.
4. Create a base decorator holding a component reference (typed to the interface).
5. Concrete decorators add behavior before/after delegating to the wrapped object.

**Pros:** extend behavior without subclassing; add/remove responsibilities at runtime; combine behaviors by stacking wrappers; split a monolithic class into smaller ones (SRP).
**Cons:** hard to remove a specific wrapper from the stack; behavior can depend on stack order; configuration code can look ugly.
**Relations:** Adapter changes the interface, Decorator keeps/enhances it and supports recursive composition; like Chain of Responsibility structurally, but CoR handlers may stop the flow while decorators don't; "Decorator changes the skin, Strategy changes the guts"; Proxy manages its subject's lifecycle, a Decorator is composed by the client.

### 10. Facade — Structural

**Intent:** "Facade is a structural design pattern that provides a simplified interface to a library, a framework, or any other complex set of classes."

**Use it when:**
- You need a limited, straightforward interface to a complex subsystem.
- You want to structure a subsystem into layers (a facade per layer).

**Implementation (key steps):**
1. Check whether you can offer a simpler interface than the subsystem already provides.
2. Implement that interface in a facade that redirects to subsystem objects.
3. Route all client calls through the facade.
4. If the facade grows too big, extract a refined facade.

**Pros:** isolates client code from subsystem complexity.
**Cons:** a facade can become a "god object" coupled to all classes of the app.
**Relations:** Facade defines a new interface (Adapter reuses an existing one); can be an alternative to Abstract Factory for hiding creation; Facade represents a whole subsystem as one object (Flyweight makes many small objects); often becomes a Singleton; similar to Proxy but Proxy keeps the same interface as its subject.

### 11. Flyweight — Structural

**Intent:** "Flyweight is a structural design pattern that lets you fit more objects into the available amount of RAM by sharing common parts of state between multiple objects instead of keeping all of the data in each object."

**Use it when:**
- The app must spawn a huge number of similar objects that exhaust RAM, and those objects share duplicate state that can be extracted.

**Implementation (key steps):**
1. Split fields into **intrinsic** (shared, immutable) and **extrinsic** (contextual) state.
2. Keep intrinsic state in the flyweight; make it immutable, set only via constructor.
3. Move extrinsic state out into method parameters.
4. (Optional) add a factory that pools and reuses flyweights.
5. Store/compute extrinsic state in clients (or a separate context object).

**Pros:** saves lots of RAM when there are many similar objects.
**Cons:** trades RAM for CPU if extrinsic state must be recomputed each call; complicates the code (state separation can confuse newcomers).
**Relations:** shared Composite leaves can be Flyweights; Flyweight makes many small objects (Facade makes one subsystem object); resembles Singleton when reduced to a single shared instance, but Flyweights are multiple and immutable.

### 12. Proxy — Structural

**Intent:** "Proxy is a structural design pattern that lets you provide a substitute or placeholder for another object."

**Use it when (variants):**
- A heavyweight service wastes resources when always up → **lazy/virtual proxy**.
- Only specific clients may use the service → **protection proxy**.
- The service is on a remote server → **remote proxy**.
- You want to log requests → **logging proxy**.
- You want to cache results and manage the cache → **caching proxy**.
- You want to dismiss a heavyweight object when unused → **smart reference**.

**Implementation (key steps):**
1. Ensure a service interface exists (extract one if needed) so proxy and service are interchangeable.
2. Create the proxy with a reference to the service.
3. Implement proxy methods that do their job (cache/lazy/secure/log) then delegate.
4. (Optional) add a creation method deciding proxy vs real service; consider lazy init.

**Pros:** control the service transparently; manage its lifecycle; works even if the service isn't ready; Open/Closed (new proxies without changing service/clients).
**Cons:** more classes; response may be delayed.
**Relations:** Adapter gives a different interface, Proxy keeps the same one; similar to Facade but Proxy has the same interface as its subject; structurally like Decorator but Proxy manages lifecycle while a Decorator is client-composed.

---

## Behavioral Patterns

### 13. Chain of Responsibility — Behavioral

**Intent:** "Chain of Responsibility is a behavioral design pattern that lets you pass requests along a chain of handlers."

**Use it when:**
- Your program processes different kinds of requests in various ways, but exact types/sequences are unknown beforehand.
- You must execute several handlers in a particular order.
- The set of handlers and their order should change at runtime.

**Implementation (key steps):**
1. Declare a handler interface with a handling method (consider a request object).
2. Add an abstract base handler with the "next handler" field and default forwarding.
3. Implement concrete handlers that decide to process and/or pass along.
4. Assemble chains in client code or via a factory.
5. Trigger any handler; be ready for unhandled requests.

**Pros:** control the order of handling; decouple senders from receivers (SRP); Open/Closed (new handlers without breaking clients).
**Cons:** some requests may go unhandled.
**Relations:** CoR/Command/Mediator/Observer are different ways to connect senders and receivers; often used with Composite (pass requests up to the root); handlers can be Commands; structurally like Decorator, but CoR can stop the flow.

### 14. Command — Behavioral

**Intent:** "Command is a behavioral design pattern that turns a request into a stand-alone object that contains all information about the request."

**Use it when:**
- You want to parameterize objects with operations.
- You want to queue, schedule, or execute operations remotely.
- You want reversible operations (undo/redo).

**Implementation (key steps):**
1. Declare a command interface with a single execution method.
2. Extract requests into concrete commands storing receiver + arguments.
3. Give sender classes a command field; senders talk only to the command interface.
4. Senders execute commands instead of calling receivers directly.
5. Initialize in order: receivers → commands → senders.

**Pros:** SRP (decouple invoker from performer); Open/Closed (new commands freely); undo/redo; deferred execution; compose simple commands into complex ones.
**Cons:** adds a layer between senders and receivers (more complexity).
**Relations:** CoR/Command/Mediator/Observer connect senders and receivers differently; CoR handlers can be Commands; Command + Memento implements undo; Command resembles Strategy but with different intent; Prototype helps store command history; Visitor is "a powerful version of Command."

### 15. Iterator — Behavioral

**Intent:** "Iterator is a behavioral design pattern that lets you traverse elements of a collection without exposing its underlying representation (list, stack, tree, etc.)."

**Use it when:**
- Your collection has a complex structure you want to hide for convenience or security.
- You want to reduce duplicated traversal code.
- You want clients to traverse different/unknown structures uniformly.

**Implementation (key steps):**
1. Declare an iterator interface (at least "get next"; optionally position/has-next).
2. Declare a collection interface with a method returning that iterator type.
3. Implement concrete iterators bound to a single collection instance.
4. Implement the collection interface (pass `this` to the iterator).
5. Replace traversal code in clients with iterator usage.

**Pros:** SRP (traversal extracted); Open/Closed (new collections/iterators); parallel iteration via independent iterators; can pause/resume iteration.
**Cons:** overkill for simple collections; may be less efficient than direct access to a specialized collection.
**Relations:** traverse Composite trees; pair with Factory Method (subclasses return different iterators); pair with Memento (capture iteration state to roll back); pair with Visitor to run operations during traversal.

### 16. Mediator — Behavioral

**Intent:** "Mediator is a behavioral design pattern that lets you reduce chaotic dependencies between objects."

**Use it when:**
- Classes are hard to change because they're tightly coupled to many others.
- A component can't be reused because it depends on too many others.
- You'd be subclassing many components just to reuse basic behavior in different contexts.

**Implementation (key steps):**
1. Identify the tightly coupled classes.
2. Declare a mediator interface (the component↔mediator protocol).
3. Implement a concrete mediator holding references to all components.
4. (Optional) let the mediator own component lifecycle.
5. Components hold a mediator reference and call its notify method instead of each other.

**Pros:** SRP (communication centralized); Open/Closed (new mediators without touching components); lower coupling; more reusable components.
**Cons:** the mediator can become a god object.
**Relations:** CoR/Command/Mediator/Observer connect senders and receivers differently; Facade vs Mediator — Facade gives simplified one-way access to a subsystem, Mediator centralizes two-way communication; Mediator is often implemented with Observer (mediator = publisher, components = subscribers). Mediator eliminates mutual dependencies; Observer establishes dynamic one-way connections.

### 17. Memento — Behavioral

**Intent:** "Memento is a behavioral design pattern that lets you save and restore the previous state of an object without revealing the details of its implementation."

**Use it when:**
- You want to produce snapshots of an object's state to restore it later.
- Direct access to the object's fields/getters/setters would violate its encapsulation.

**Implementation (key steps):**
1. Pick the originator class.
2. Create a memento class mirroring the originator's state fields; make it immutable (set once via constructor).
3. Nest the memento in the originator (or expose only a narrow interface to others).
4. Originator gets a method to produce a memento and one to restore from it.
5. A caretaker stores mementos and decides when to snapshot/restore.

**Pros:** snapshot state without breaking encapsulation; simplifies the originator (caretaker keeps the history).
**Cons:** lots of RAM if snapshots are frequent; caretakers must track originator lifecycle; dynamic languages can't guarantee memento immutability.
**Relations:** Command + Memento = undo; Memento + Iterator captures iteration state; Prototype can be a simpler alternative for plain objects.

### 18. Observer — Behavioral

**Intent:** "Observer is a behavioral design pattern that lets you define a subscription mechanism to notify multiple objects about any events that happen to the object they're observing."

**Use it when:**
- A change to one object requires changing others, and the set of others is unknown/dynamic.
- Some objects must observe others only for a limited time or in specific cases (e.g., GUI events).

**Implementation (key steps):**
1. Split into publisher (core) and subscriber (dependent) roles.
2. Declare a subscriber interface (at least an `update` method).
3. Declare a publisher interface (subscribe/unsubscribe).
4. Put the subscription list + methods in an abstract base or via composition.
5. Concrete publishers notify all subscribers on events; subscribers react; client wires them up.

**Pros:** Open/Closed (new subscribers without changing the publisher); relationships established at runtime.
**Cons:** subscribers are notified in random (unspecified) order.
**Relations:** CoR/Command/Mediator/Observer connect senders and receivers differently; Observer lets receivers dynamically (un)subscribe; the Mediator/Observer distinction is subtle — Mediator removes mutual dependencies, Observer makes dynamic one-way connections.

### 19. State — Behavioral

**Intent:** "State is a behavioral design pattern that lets an object alter its behavior when its internal state changes."

**Use it when:**
- An object behaves differently by state, there are many states, and state-specific code changes often.
- A class is polluted with massive conditionals that switch behavior on field values.
- There's much duplicate code across similar states/transitions of a condition-based state machine.

**Implementation (key steps):**
1. Choose the context class.
2. Declare a state interface of the state-dependent methods.
3. Create a class per state, moving the related code in.
4. Add a state-interface field + setter to the context.
5. Replace the context's conditionals with delegation to the current state.
6. Switch state by assigning a new state instance.

**Pros:** SRP (per-state code organized into classes); Open/Closed (new states without changing existing ones); simplifies the context (no bulky state machine).
**Cons:** overkill if there are few states or they rarely change.
**Relations:** Bridge/State/Strategy share a composition structure; State can be seen as an extension of Strategy — both swap behavior via composition, but Strategy's strategies are independent while State's concrete states may know and switch each other.

### 20. Strategy — Behavioral

**Intent:** "Strategy is a behavioral design pattern that lets you define a family of algorithms, put each of them into separate classes, and make their objects interchangeable."

**Use it when:**
- You want different algorithm variants within an object and to switch them at runtime.
- You have many similar classes differing only in how they execute some behavior.
- You want to isolate business logic from algorithm implementation details.
- A class has a massive conditional that switches between algorithm variants.

**Implementation (key steps):**
1. Identify a frequently-changing algorithm (or one chosen by big conditionals).
2. Declare a strategy interface common to all variants.
3. Extract each variant into a class implementing it.
4. Give the context a strategy field + setter.
5. Clients set the context's strategy to the desired variant.

**Pros:** swap algorithms at runtime; isolate implementation from usage; replace inheritance with composition; Open/Closed (new strategies without changing the context).
**Cons:** overkill for a few rarely-changing algorithms; clients must know how strategies differ; functional languages may offer simpler (lambda) alternatives.
**Relations:** Bridge/State/Strategy share structure; Command vs Strategy — Command turns operations into objects, Strategy describes different ways to do the same thing; "Decorator changes skin, Strategy changes guts"; Template Method uses inheritance (static), Strategy uses composition (runtime); State extends Strategy with interdependent states.

### 21. Template Method — Behavioral

**Intent:** "Template Method is a behavioral design pattern that defines the skeleton of an algorithm in the superclass but lets subclasses override specific steps of the algorithm without changing its structure."

**Use it when:**
- You want clients to extend only particular steps, not the whole algorithm or its structure.
- You have several classes with almost identical algorithms differing in minor steps (a change to the algorithm forces edits across all of them).

**Implementation (key steps):**
1. Break the algorithm into steps; mark which are common and which always vary.
2. Create an abstract base with a (preferably `final`) template method calling the steps; declare abstract steps.
3. Give some steps default implementations where useful.
4. Consider adding hooks between key steps.
5. Each variant is a subclass implementing the abstract steps (and optionally overriding hooks).

**Pros:** clients override only certain parts of a large algorithm; pull duplicate code into a superclass.
**Cons:** clients may be limited by the provided skeleton; risk violating Liskov substitution by suppressing a default step; more steps → harder to maintain.
**Relations:** Factory Method is a specialization of Template Method (and can be a step in one); Template Method is inheritance-based and works at the class level (static), whereas Strategy is composition-based and works at the object level (runtime).

### 22. Visitor — Behavioral

**Intent:** "Visitor is a behavioral design pattern that lets you separate algorithms from the objects on which they operate."

**Use it when:**
- You must perform an operation on all elements of a complex object structure (e.g., an object tree).
- You want to clean auxiliary behaviors out of the core business logic.
- A behavior makes sense only in some classes of a hierarchy, not others.

**Implementation (key steps):**
1. Declare a visitor interface with a visiting method per concrete element class.
2. Declare the element interface with an `accept(visitor)` method (add to the hierarchy's base class).
3. Each concrete element's `accept` redirects to the matching visiting method (double dispatch).
4. Elements know visitors only through the visitor interface; visitors must know all element classes.
5. For each new behavior, add a concrete visitor implementing all visiting methods.
6. The client creates visitors and passes them into elements via `accept`.

**Pros:** Open/Closed (new behavior without changing element classes); SRP (consolidate versions of a behavior in one class); a visitor can accumulate state while traversing.
**Cons:** every change to the element hierarchy forces updating all visitors; visitors may lack access to elements' private members.
**Relations:** treat Visitor as a powerful Command for operations over many objects; use it to run an operation over a whole Composite tree; pair with Iterator to traverse a complex structure and operate on elements of different classes.

---

## Cross-reference to the Head First reference

Each pattern above is taught in depth — with the canonical Head First scenario and Good/Bad Java — in `head-first-design-pattern-book.md`:

| refactoring.guru pattern | Head First chapter / appendix |
|---|---|
| Strategy | Ch 1 |
| Observer | Ch 2 |
| Decorator | Ch 3 |
| Factory Method, Abstract Factory | Ch 4 |
| Singleton | Ch 5 |
| Command | Ch 6 |
| Adapter, Facade | Ch 7 |
| Template Method | Ch 8 |
| Iterator, Composite | Ch 9 |
| State | Ch 10 |
| Proxy | Ch 11 |
| Bridge, Builder, Chain of Responsibility, Flyweight, Interpreter*, Mediator, Memento, Prototype, Visitor | Appendix (Leftover Patterns) |

\* *Interpreter* is covered in the Head First appendix but is not part of refactoring.guru's 22-pattern catalog.
