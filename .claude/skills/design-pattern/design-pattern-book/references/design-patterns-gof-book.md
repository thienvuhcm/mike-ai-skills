# Design Patterns: Elements of Reusable Object-Oriented Software (Gang of Four) — The Canonical Catalog (supplement)

## Role

You are a Senior software engineer applying the original, authoritative source of the design-pattern movement: *Design Patterns: Elements of Reusable Object-Oriented Software* by Erich Gamma, Richard Helm, Ralph Johnson, and John Vlissides (the "Gang of Four"; Addison-Wesley, 1994). This reference supplements the Head First and refactoring.guru material with the **canonical** definitions, the **classification**, the **design philosophy**, and — most importantly — the **Consequences** (trade-offs) and **Related Patterns** that the GoF document for each of the 23 patterns.

## Goal

The other two files in this skill teach *how a pattern works* (Head First) and help you *decide whether/which* to use (refactoring.guru). This file gives you the **authoritative source of truth**:

- The **verbatim GoF Intent** of all 23 patterns — the precise one- or two-sentence definition every other source paraphrases.
- The **two organizing axes** — *purpose* (creational / structural / behavioral) × *scope* (class / object) — and what each cell means.
- The **design philosophy of Chapter 1**: the two maxims that originate here (*program to an interface, not an implementation*; *favor object composition over class inheritance*), the reuse mechanisms (white-box vs black-box reuse, delegation, parameterized types, aggregation vs acquaintance), and the **eight common causes of redesign** each mapped to the patterns that address them.
- The **Consequences** (the trade-offs you accept) and **Related Patterns** (how to navigate between look-alikes and combinations) for every pattern — the GoF's deepest, most-cited contributions.
- The **Lexi case study** (Chapter 2): seven real design problems, each resolved by a pattern.

When you cite this file, quote the **Intent verbatim**, give the **classification**, and use the **Consequences** and **Related Patterns** to justify and navigate the choice.

## Constraints

- **CANONICAL WORDING**: The Intent statements in this file are quoted verbatim from the GoF book. Prefer them when defining a pattern precisely; the Head First and refactoring.guru phrasings are friendly paraphrases of these.
- **CLASS vs OBJECT SCOPE MATTERS**: Several patterns have two forms (notably Adapter: a *class* adapter via multiple inheritance vs an *object* adapter via composition). Always note which scope you mean; the trade-offs differ.
- **CONSEQUENCES ARE THE POINT**: A pattern is a *trade-off*, not a free win. Always weigh the Consequences listed here before applying one; the GoF deliberately documents the costs alongside the benefits.
- **DON'T FORCE A PATTERN**: The GoF warn explicitly that patterns should not be applied speculatively. Apply one only when the problem in its Applicability section is actually present.
- **BUILD/TEST DISCIPLINE**: As with the other files, run the project build/tests before and after any pattern-driven refactoring; preserve observable behavior.

## Concepts (Chapter 1 — Introduction)

### What is a design pattern? — the four essential elements

A design pattern names, abstracts, and identifies the key aspects of a common design structure that make it useful for creating reusable object-oriented design. The GoF say a pattern has **four essential elements**:

1. **Pattern name** — a handle, one or two words, that raises the level of design vocabulary ("let's use a Strategy here").
2. **Problem** — when to apply the pattern: the context, the problem, and sometimes a list of conditions (preconditions) that must hold.
3. **Solution** — the elements (classes/objects), their relationships, responsibilities, and collaborations — described abstractly, *not* a concrete implementation; a pattern is a *template*.
4. **Consequences** — the results and trade-offs of applying it (impact on flexibility, extensibility, portability, and often the language/implementation costs). Critical for evaluating alternatives.

A design pattern is a *description of communicating objects and classes customized to solve a general design problem in a particular context*. It is **not** a finished design you paste in, and **not** as low-level as a data structure or as high-level as a whole architecture — it sits at the level of *design*.

### The GoF template (how each pattern is documented in the catalog)

Every one of the 23 catalog entries uses the same 13-section template. Knowing it lets you read any pattern fast and write your own:

`Pattern Name and Classification · Intent · Also Known As · Motivation · Applicability · Structure · Participants · Collaborations · Consequences · Implementation · Sample Code · Known Uses · Related Patterns`

### The two maxims that originate here

The GoF state the two principles the rest of the field repeats:

- **"Program to an interface, not an implementation."** Manipulate objects only through an interface defined by an abstract class, so clients remain unaware of the specific types they use and of the classes that implement those objects — they know only the abstract interface. This is the chief benefit of creating objects through abstract factories/builders/etc.: it eliminates dependence on concrete classes.
- **"Favor object composition over class inheritance."** Class inheritance is *white-box reuse* — it exposes a parent's internals to subclasses, is defined statically at compile time, and breaks encapsulation. Object composition is *black-box reuse* — objects are accessed only through interfaces, it's defined dynamically at run time, and it keeps each class focused on one task. Composition keeps classes encapsulated and small; the disadvantage is more objects and more indirection.

### Reuse mechanisms

- **Inheritance (white-box)** vs **composition (black-box)**: inheritance reuses by extending a base class; composition reuses by assembling objects to get more complex behavior at run time. The GoF's guidance: prefer composition for flexibility.
- **Delegation** is a way of making composition as powerful for reuse as inheritance: a receiving object delegates operations to a delegate (passing *itself* so the delegate can refer back), the way a `Window` can delegate to a `Rectangle` instead of inheriting from it. Powerful but adds dynamic, harder-to-follow indirection — worth it for patterns like State, Strategy, Visitor.
- **Parameterized types (generics/templates)** are a *third* reuse mechanism: change the types a class uses without subclassing or composing. Neither inheritance nor parameterized types can change at run time; composition can.
- **Aggregation vs acquaintance**: *aggregation* means one object owns/is responsible for another (part-of, same lifetime); *acquaintance* ("association"/"using") means an object merely knows of another (it may reference it but doesn't own it). Aggregation implies a stronger, more permanent relationship; favor acquaintance where you can to reduce coupling.

### Designing for change — the eight common causes of redesign

The GoF frame patterns as answers to the things that force costly redesign. Each cause is addressed by specific patterns:

1. **Creating an object by specifying a class explicitly** (commits to a concrete class) → **Abstract Factory, Factory Method, Prototype**.
2. **Dependence on specific operations** (hard-codes how a request is satisfied) → **Chain of Responsibility, Command**.
3. **Dependence on hardware and software platform** → **Abstract Factory, Bridge**.
4. **Dependence on object representations or implementations** (clients that know how an object is represented/stored/located must change when it does) → **Abstract Factory, Bridge, Memento, Proxy**.
5. **Algorithmic dependencies** (algorithms get extended, optimized, replaced) → **Builder, Iterator, Strategy, Template Method, Visitor**.
6. **Tight coupling** (classes hard to reuse in isolation → monolithic systems) → **Abstract Factory, Bridge, Chain of Responsibility, Command, Facade, Mediator, Observer**.
7. **Extending functionality by subclassing** (every extension is a subclass; combinations explode) → **Bridge, Chain of Responsibility, Composite, Decorator, Observer, Strategy**.
8. **Inability to alter classes conveniently** (source unavailable, or a change would ripple through many subclasses) → **Adapter, Decorator, Visitor**.

### How to select and how to use a design pattern

- **Selecting**: consider how patterns solve design problems; scan Intents; study how patterns interrelate (Related Patterns); study patterns of like purpose; examine the *cause of redesign* you're trying to avoid; and consider what in your design should be able to vary *without* redesign — then find the pattern that lets that vary.
- **Using** (step by step): read the pattern for an overview (esp. Applicability and Consequences); study Structure, Participants, and Collaborations; look at Sample Code; choose participant names meaningful in your context; define the classes; define application-specific names for the operations; implement the operations.

## The Lexi case study (Chapter 2 — Designing a Document Editor)

The GoF demonstrate the catalog by designing **Lexi**, a WYSIWYG document editor, where seven design problems each fall to a pattern. This is the canonical worked example of patterns *collaborating*:

| # | Design problem | Pattern applied |
|---|----------------|-----------------|
| 1 | **Document structure** — represent text, graphics, rows, columns uniformly in a recursive tree | **Composite** (`Glyph` with leaves and a `Row`/`Column` composite) |
| 2 | **Formatting** — break a document into lines/columns; allow different linebreaking algorithms | **Strategy** (`Compositor` encapsulates the linebreaking algorithm) |
| 3 | **Embellishing the UI** — add borders and scrollbars without subclass explosion | **Decorator** (`Border`, `Scroller` wrap a `Glyph`) |
| 4 | **Supporting multiple look-and-feel standards** — Motif, Presentation Manager, … without hard-coding | **Abstract Factory** (`GUIFactory` creates matching widget families) |
| 5 | **Supporting multiple window systems** — decouple Lexi from a specific windowing API | **Bridge** (a `Window`/`WindowImp` separation) |
| 6 | **User operations** — menus and buttons that invoke commands, with undo/redo | **Command** (a `Command` object per operation, with `Execute`/`Unexecute` and a history list) |
| 7 | **Spelling checking and hyphenation** — traverse the document and analyze it without bloating glyphs | **Iterator** (traverse the structure) + **Visitor** (add analyses without changing glyph classes) |

## Classification (the Purpose × Scope catalog, Table 1.1)

Two criteria: **purpose** (what the pattern does) × **scope** (whether it applies to *classes* — relationships fixed at compile time via inheritance — or *objects* — relationships changeable at run time). *Most patterns are object scope.*

| Scope ↓ / Purpose → | **Creational** | **Structural** | **Behavioral** |
|---------------------|----------------|----------------|----------------|
| **Class**  | Factory Method | Adapter (class) | Interpreter · Template Method |
| **Object** | Abstract Factory · Builder · Prototype · Singleton | Adapter (object) · Bridge · Composite · Decorator · Facade · Flyweight · Proxy | Chain of Responsibility · Command · Iterator · Mediator · Memento · Observer · State · Strategy · Visitor |

What the scope distinction implies:
- **Creational class** patterns defer part of object creation to subclasses; **creational object** patterns defer it to another object.
- **Structural class** patterns use inheritance to compose classes; **structural object** patterns describe ways to assemble objects.
- **Behavioral class** patterns use inheritance to describe algorithms and flow of control; **behavioral object** patterns describe how a group of objects cooperate to perform a task no single object can do alone.

Other useful groupings the GoF note: some patterns are **often used together** (Composite with Iterator or Visitor); some are **alternatives** (Prototype is often an alternative to Abstract Factory); some **look alike but differ in intent** (Composite and Decorator have similar structure diagrams; so do Strategy and State).

---

## Creational Patterns

Creational patterns abstract the instantiation process; they make a system independent of how its objects are created, composed, and represented. They encapsulate knowledge about which concrete classes the system uses and hide how instances are created and put together. Two recurring themes: they all encapsulate knowledge about concrete classes, and they hide how instances are created and combined.

### Abstract Factory
- **Intent (verbatim):** *"Provide an interface for creating families of related or dependent objects without specifying their concrete classes."*
- **Also Known As:** Kit.
- **Classification:** Creational, Object scope.
- **Applicability:** A system should be independent of how its products are created and composed; it must be configured with one of multiple families of products; a family of related product objects is designed to be used together and you must enforce that constraint; you want to reveal only product interfaces, not implementations.
- **Consequences:** (+) Isolates concrete classes — clients manipulate products only through abstract interfaces. (+) Makes exchanging product families easy — swap one concrete factory. (+) Promotes consistency among products in a family. (−) **Supporting new *kinds* of products is hard** — adding a product means changing the factory interface and every concrete factory (the framework is fixed to a set of products).
- **Implementation:** Factories are usually Singletons; create the products with Factory Methods (or, for many families, a Prototype-based factory configured with prototypical instances); to add a product variant, consider a more flexible but less safe scheme that parameterizes the make operation.
- **Related Patterns:** Often implemented with **Factory Method** (or **Prototype**); a concrete factory is frequently a **Singleton**. (Contrast **Builder**: Abstract Factory builds families of products step-agnostically; Builder builds one complex product step by step.)

### Builder
- **Intent (verbatim):** *"Separate the construction of a complex object from its representation so that the same construction process can create different representations."*
- **Classification:** Creational, Object scope.
- **Applicability:** The algorithm for creating a complex object should be independent of the parts that make up the object and how they're assembled; the construction process must allow different representations of the constructed object.
- **Consequences:** (+) Lets you vary a product's internal representation — the director uses an abstract `Builder` interface. (+) Isolates code for construction and representation, improving modularity. (+) Gives finer control over the construction process (step by step) than creating the product in one shot. (−) A concrete builder per representation.
- **Implementation:** The `Director` invokes `Builder` steps; the abstract `Builder` usually gives empty (not abstract) default methods so concrete builders override only the steps they need; the product-retrieval method (`getResult`) typically lives on the concrete builder, not the abstract one, because products may not share a common interface.
- **Related Patterns:** **Abstract Factory** is similar (both create complex objects) but Builder focuses on *constructing* a complex object step by step and returns it as a final step, whereas Abstract Factory returns product families immediately. A **Composite** is often what a Builder builds.

### Factory Method
- **Intent (verbatim):** *"Define an interface for creating an object, but let subclasses decide which class to instantiate. Factory Method lets a class defer instantiation to subclasses."*
- **Also Known As:** Virtual Constructor.
- **Classification:** Creational, **Class scope** (uses inheritance — a subclass decides the product).
- **Applicability:** A class can't anticipate the class of objects it must create; a class wants its subclasses to specify the objects it creates; or you want to localize the knowledge of which helper subclass is the delegate.
- **Consequences:** (+) Eliminates the need to bind application-specific classes into your code — code deals only with the product interface. (−) **Clients may have to subclass the creator** just to create a particular concrete product. Provides hooks for subclasses; connects parallel class hierarchies.
- **Implementation:** Two variants — the creator is *abstract* (subclasses must implement the factory method) or *concrete with a default*; parameterize the factory method to create multiple products from one method; use templates/generics to avoid subclassing; be careful with naming conventions that signal a factory method.
- **Related Patterns:** **Abstract Factory** is often implemented with Factory Methods. Factory Methods are usually called within **Template Methods**. **Prototype** doesn't require subclassing the creator but often requires an Initialize on the product class.

### Prototype
- **Intent (verbatim):** *"Specify the kinds of objects to create using a prototypical instance, and create new objects by copying this prototype."*
- **Classification:** Creational, Object scope.
- **Applicability:** When a system should be independent of how its products are created/composed/represented **and** the classes to instantiate are specified at run time; or to avoid a class hierarchy of factories that parallels the product hierarchy; or when instances of a class can have one of only a few different state combinations (clone prototypes instead of building each by hand).
- **Consequences:** (+) Add/remove products at run time by registering a prototypical instance. (+) Specify new objects by varying values (compose prototypes) or by varying structure. (+) Reduces subclassing (no parallel Creator hierarchy as Factory Method needs). (+) Configure an application with classes dynamically. (−) **Each subclass must implement `Clone`** — hard when internals include objects that don't support copying or have circular references; deep vs shallow copy is a real decision.
- **Implementation:** Use a prototype manager (a registry) when the number of prototypes varies at run time; implement `Clone` carefully (deep vs shallow copy); consider initializing the clone after copying.
- **Related Patterns:** Prototype and **Abstract Factory** are competitors but can be used together (a factory may store prototypes and clone them). Designs that make heavy use of **Composite** and **Decorator** often benefit from Prototype.

### Singleton
- **Intent (verbatim):** *"Ensure a class only has one instance, and provide a global point of access to it."*
- **Classification:** Creational, Object scope.
- **Applicability:** There must be exactly one instance of a class, accessible from a well-known access point; or the sole instance should be extensible by subclassing and clients should use the extended instance without modifying their code.
- **Consequences:** (+) Controlled access to the sole instance. (+) Reduced namespace pollution vs global variables. (+) Permits refinement of operations and representation (subclass the Singleton). (+) Permits a variable number of instances if you later relax the constraint. (+) More flexible than class operations (static methods, which can't be overridden polymorphically). (−) Introduces **global state** and can hide dependencies; complicates testing; needs care under **concurrency**.
- **Implementation:** Ensure a unique instance via a static accessor that lazily creates it; to subclass the Singleton, the accessor can choose the concrete class (e.g. via a registry of singletons or an environment variable). (In modern Java, prefer a single-element `enum`, which is serialization- and reflection-safe — see the Head First file's threading discussion.)
- **Related Patterns:** Many patterns can be implemented using Singleton — **Abstract Factory**, **Builder**, and **Prototype** factories are frequently Singletons.

---

## Structural Patterns

Structural patterns are concerned with how classes and objects are composed to form larger structures. **Structural *class* patterns** use inheritance to compose interfaces or implementations (e.g. multiple inheritance to mix classes). **Structural *object* patterns** describe ways to compose objects to realize new functionality; the flexibility of object composition (changeable at run time) is impossible with static class composition.

### Adapter
- **Intent (verbatim):** *"Convert the interface of a class into another interface clients expect. Adapter lets classes work together that couldn't otherwise because of incompatible interfaces."*
- **Also Known As:** Wrapper.
- **Classification:** Structural — has **both** a *class* form (multiple inheritance) and an *object* form (composition).
- **Applicability:** You want to use an existing class but its interface doesn't match what you need; you want to create a reusable class that cooperates with unrelated or unforeseen classes; (object adapter only) you need to use several existing subclasses but can't adapt their interface by subclassing every one.
- **Consequences:** **Class adapter** (subclasses the adaptee): commits to one concrete Adaptee class, so it can't adapt a class and all its subclasses; but it can override Adaptee behavior and introduces only one object. **Object adapter** (composes the adaptee): lets a single Adapter work with many Adaptees (the adaptee and its subclasses), but makes overriding adaptee behavior harder. How much adapting is needed ranges from a simple interface rename to supporting an entirely different set of operations.
- **Implementation:** Use *pluggable adapters* (build interface adaptation into a class via abstract operations, parameterized blocks, or delegate objects) to make a class adaptable; two-way adapters can provide transparency to both clients.
- **Related Patterns:** **Bridge** has a similar structure but a different intent (Bridge separates an interface from its implementation up front so both vary independently; Adapter changes the interface of an *existing* object after the fact). **Decorator** enhances an object without changing its interface (more transparent than Adapter, supports recursive composition). **Proxy** defines a representative without changing its interface.

### Bridge
- **Intent (verbatim):** *"Decouple an abstraction from its implementation so that the two can vary independently."*
- **Also Known As:** Handle/Body.
- **Classification:** Structural, Object scope.
- **Applicability:** You want to avoid a permanent binding between an abstraction and its implementation (e.g. to switch implementations at run time); both abstraction and implementation should be extensible by subclassing independently; changes to an implementation shouldn't impact clients (no recompile); you want to hide an implementation completely; or you have a proliferating class hierarchy (a "Cartesian product" of abstractions × implementations) that you want to split into two hierarchies.
- **Consequences:** (+) Decouples interface and implementation — bind them at run time, eliminate compile-time dependencies, encourage layering. (+) Improved extensibility — extend the `Abstraction` and `Implementor` hierarchies independently. (+) Hides implementation details from clients.
- **Implementation:** Often only one Implementor (the "degenerate" Bridge still usefully isolates clients from implementation changes); decide how/when to create the right concrete implementor (often via Abstract Factory); share implementors (handle/body reference counting); use multiple inheritance in C++ to combine.
- **Related Patterns:** An **Abstract Factory** can create and configure a particular Bridge. **Adapter** is geared toward making *unrelated* classes work together after they're designed; Bridge is used up front to let abstraction and implementation vary independently.

### Composite
- **Intent (verbatim):** *"Compose objects into tree structures to represent part-whole hierarchies. Composite lets clients treat individual objects and compositions of objects uniformly."*
- **Classification:** Structural, Object scope.
- **Applicability:** You want to represent part-whole hierarchies of objects; and you want clients to be able to ignore the difference between compositions and individual objects (treat them uniformly).
- **Consequences:** (+) Defines class hierarchies of primitive (leaf) and composite objects; (+) makes the client simple — clients treat composite and leaf uniformly; (+) makes it easy to add new kinds of components. (−) **Can make a design overly general** — it's hard to restrict the components of a composite to particular types (you must use run-time checks, not the type system).
- **Implementation:** The big trade-off is **where to declare child-management operations** (`add`/`remove`/`getChild`): in the `Component` (transparency — uniform treatment, but leaves inherit meaningless operations and must handle them — *safety* is sacrificed) or only in `Composite` (safety, but clients must type-check). The GoF lean toward transparency. Other issues: whether children keep an explicit parent reference; sharing components (Flyweight); caching to improve traversal; who deletes children.
- **Related Patterns:** A component-parent link is often used with **Chain of Responsibility**. **Decorator** is often combined with Composite (they share structure). **Flyweight** lets you share components (but then they can't refer to their parents). **Iterator** and **Visitor** traverse/operate on composites.

### Decorator
- **Intent (verbatim):** *"Attach additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality."*
- **Also Known As:** Wrapper.
- **Classification:** Structural, Object scope.
- **Applicability:** Add responsibilities to individual objects dynamically and transparently (without affecting other objects); for responsibilities that can be withdrawn; or when extension by subclassing is impractical (a class explosion of independent extensions, or a class definition that is hidden/unavailable for subclassing).
- **Consequences:** (+) **More flexible than static inheritance** — add/remove responsibilities at run time and mix-and-match; (+) avoids feature-laden classes high in the hierarchy ("pay as you go"). (−) A decorator and its component are **not identical** — identity tests fail, so don't rely on object identity through a decorator. (−) **Lots of little objects** that look alike and differ only in how they're connected — hard to learn and debug.
- **Implementation:** Decorator's interface must conform to the interface of the component it decorates; keep the abstract Decorator lightweight (focused on forwarding); the component class should be lightweight (no data storage in it — push that to subclasses) so decorating stays cheap; Decorator changes the "skin" of an object whereas Strategy changes its "guts."
- **Related Patterns:** **Adapter** changes an object's interface; Decorator changes its responsibilities, not its interface. **Composite** shares structure (a Decorator is a degenerate composite with one component) but Decorator *adds responsibilities*, it isn't for aggregation. **Strategy** is the alternative when you can't (or don't want to) change the skin — change the guts instead.

### Facade
- **Intent (verbatim):** *"Provide a unified interface to a set of interfaces in a subsystem. Facade defines a higher-level interface that makes the subsystem easier to use."*
- **Classification:** Structural, Object scope.
- **Applicability:** You want a simple interface to a complex subsystem; there are many dependencies between clients and the implementation classes of an abstraction (a facade decouples them); or you want to layer your subsystems (use a facade as the entry point to each layer).
- **Consequences:** (+) Shields clients from subsystem components, reducing the number of objects clients deal with and making the subsystem easier to use; (+) **promotes weak coupling** between the subsystem and its clients, letting you vary subsystem components without affecting clients; (+) doesn't prevent applications from using subsystem classes directly if they need to (you can choose generality vs simplicity).
- **Implementation:** Reduce client-subsystem coupling further by making the Facade an abstract class (or configuring it with different subsystem objects); decide which subsystem classes are public vs private.
- **Related Patterns:** **Abstract Factory** can be used with Facade to provide an interface for creating subsystem objects in a subsystem-independent way. **Mediator** is similar (it abstracts communication between objects) but its purpose is to centralize *colleague* communication that isn't in the colleagues; a Facade just abstracts the interface to subsystem objects to make them easier to use — it doesn't add new functionality, and the subsystem doesn't know about it. A Facade is often a **Singleton**.

### Flyweight
- **Intent (verbatim):** *"Use sharing to support large numbers of fine-grained objects efficiently."*
- **Classification:** Structural, Object scope.
- **Applicability:** All of these must hold: an application uses a *large* number of objects; storage costs are high because of their sheer quantity; most object state can be made **extrinsic** (passed in, context-dependent) rather than **intrinsic** (stored, shareable); many groups of objects can be replaced by few shared objects once extrinsic state is removed; and the application doesn't depend on object identity.
- **Consequences:** (+) Dramatic **space savings** (fewer total instances, more shared intrinsic state, externalized extrinsic state). (−) **Run-time costs** of computing or transferring extrinsic state — a space/time trade-off. The savings increase with more sharing and more state moved out to extrinsic.
- **Implementation:** Separate **intrinsic** (sharable, stored in the flyweight) from **extrinsic** (computed/passed by the client) state; a **Flyweight Factory** manages a pool and ensures sharing (`getFlyweight(key)` returns an existing or new one); not all flyweights need be shared (unshared concrete flyweights are allowed); manage the extrinsic state.
- **Related Patterns:** Flyweight is often combined with **Composite** to implement a logically hierarchical structure as a graph of shared leaf nodes (but then leaves can't store a parent pointer — it must be extrinsic). **State** and **Strategy** objects are often implemented as Flyweights.

### Proxy
- **Intent (verbatim):** *"Provide a surrogate or placeholder for another object to control access to it."*
- **Also Known As:** Surrogate.
- **Classification:** Structural, Object scope.
- **Applicability — the common kinds:** **Remote proxy** (a local representative for an object in a different address space); **virtual proxy** (creates expensive objects on demand); **protection proxy** (controls access by rights); **smart reference** (a replacement for a bare pointer that does extra work — reference counting, loading a persistent object on first use, locking).
- **Consequences:** Introduces a level of indirection when accessing an object, which has different uses per kind: a remote proxy hides that the object is in another address space; a virtual proxy performs optimizations like creation on demand; protection and smart-reference proxies do housekeeping when an object is accessed. (Copy-on-write is a notable virtual-proxy optimization: defer copying a large object until it's modified.)
- **Implementation:** The proxy implements the **same interface** as the real subject so it's interchangeable; overload member access (C++ `operator->`) to do proxy work; the proxy may not always need to reference the subject by its exact type (a Subject interface suffices).
- **Related Patterns:** **Adapter** provides a *different* interface to its subject; a Proxy provides the *same* interface (a protection proxy may provide a *subset*). **Decorator** has a similar implementation (wrapping) but a different purpose — a Decorator *adds responsibilities*, a Proxy *controls access*.

---

## Behavioral Patterns

Behavioral patterns are concerned with algorithms and the assignment of responsibilities between objects — not just patterns of objects/classes but patterns of *communication*. **Behavioral *class* patterns** use inheritance to distribute behavior (Template Method, Interpreter). **Behavioral *object* patterns** use object composition to describe how groups of objects cooperate (the rest). A recurring theme is encapsulating *variation* — what varies (an algorithm, a request, a state, a traversal, an operation) is given its own object.

### Chain of Responsibility
- **Intent (verbatim):** *"Avoid coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. Chain the receiving objects and pass the request along the chain until an object handles it."*
- **Classification:** Behavioral, Object scope.
- **Applicability:** More than one object may handle a request and the handler isn't known a priori (it's determined automatically); you want to issue a request to one of several objects without specifying the receiver explicitly; or the set of objects that can handle a request should be specified dynamically.
- **Consequences:** (+) **Reduced coupling** — neither sender nor receiver knows the other; an object only knows its successor. (+) Added flexibility in assigning responsibilities (change the chain at run time). (−) **Receipt isn't guaranteed** — a request can fall off the end of the chain unhandled if no object handles it.
- **Implementation:** Implement the successor chain (a new link, or reuse existing parent links as in Composite); connect successors; represent requests (a hard-coded operation, or a single handler operation with a request code/object for flexibility).
- **Related Patterns:** Chain of Responsibility is often applied with **Composite**, where a component's parent acts as its successor.

### Command
- **Intent (verbatim):** *"Encapsulate a request as an object, thereby letting you parameterize clients with different requests, queue or log requests, and support undoable operations."*
- **Also Known As:** Action, Transaction.
- **Classification:** Behavioral, Object scope.
- **Applicability:** Parameterize objects by an action to perform (Command is the OO replacement for a callback); specify, queue, and execute requests at different times; support undo (the command stores state to reverse its effect); support logging changes so they can be reapplied after a crash; or structure a system around high-level operations built on primitives (transactions).
- **Consequences:** (+) **Decouples** the object that invokes the operation from the one that performs it. (+) Commands are first-class objects you can manipulate and extend. (+) You can assemble commands into a composite (a **macro command**). (+) **Easy to add new Commands** — you don't change existing classes (Open-Closed).
- **Implementation:** Decide how "smart" a command is (a simple binding of receiver+action, vs a command that does everything itself); support undo/redo (store enough state, use a history list, be wary of accumulating errors and aliasing); use a Memento to keep undo state encapsulated; copy a command before putting it on a history list if it can change.
- **Related Patterns:** A **Composite** can compose commands (macro commands). A **Memento** can keep the state a command needs to undo its effect. A command that must be copied before being placed on a history list acts as a **Prototype**.

### Interpreter
- **Intent (verbatim):** *"Given a language, define a represention for its grammar along with an interpreter that uses the representation to interpret sentences in the language."*
- **Classification:** Behavioral, **Class scope**.
- **Applicability:** When there is a language to interpret and you can represent statements as abstract syntax trees — and the grammar is **simple** (for complex grammars the class hierarchy becomes unmanageable; use a parser generator instead) and **efficiency is not a critical concern**.
- **Consequences:** (+) **Easy to change and extend the grammar** — grammar rules are classes, so you use inheritance to change/extend; (+) easy to implement the grammar (similar classes, often generatable). (−) **Complex grammars are hard to maintain** — at least one class per rule, so many rules → many classes. (+) Adding new ways to interpret expressions is easy (e.g. add a new operation via a Visitor instead of editing every rule class).
- **Implementation:** Create the abstract syntax tree (the Interpreter doesn't parse — assume the AST exists); define one `interpret(Context)` operation per node; share terminal symbols with **Flyweight**.
- **Related Patterns:** The abstract syntax tree is a **Composite**. **Flyweight** shows how to share terminal symbols. **Iterator** can traverse the structure. **Visitor** can maintain behavior in each node of the AST in one class (instead of spreading it across the rule classes).

### Iterator
- **Intent (verbatim):** *"Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation."*
- **Also Known As:** Cursor.
- **Classification:** Behavioral, Object scope.
- **Applicability:** Access an aggregate's contents without exposing its internal representation; support multiple simultaneous traversals of an aggregate; or provide a uniform interface for traversing different aggregate structures (polymorphic iteration).
- **Consequences:** (+) Supports **variations in traversal** (a complex aggregate can be traversed different ways by changing the iterator). (+) **Simplifies the Aggregate interface** (iteration is no longer the aggregate's job — Single Responsibility). (+) **More than one traversal can be pending** at once (each iterator keeps its own state).
- **Implementation:** **External (active) iterator** — the client drives `next()` (more flexible, supports comparison of two collections); vs **internal (passive) iterator** — the iterator applies an operation to each element (easier to use). Who defines the traversal algorithm (the iterator, or the aggregate — a "cursor"). Robustness against modification of the aggregate during traversal. A **NullIterator** (degenerate) simplifies boundary handling in Composite traversals.
- **Related Patterns:** **Composite** structures are often traversed with Iterators. **Factory Method** is used by polymorphic iterators to instantiate the right iterator subclass. An iterator can use a **Memento** to capture the state of an iteration (storing it in the memento).

### Mediator
- **Intent (verbatim):** *"Define an object that encapsulates how a set of objects interact. Mediator promotes loose coupling by keeping objects from referring to each other explicitly, and it lets you vary their interaction independently."*
- **Classification:** Behavioral, Object scope.
- **Applicability:** A set of objects communicate in well-defined but complex ways (the interdependencies are unstructured and hard to follow); reusing an object is hard because it refers to and communicates with many others; or a behavior distributed among several classes should be customizable without a lot of subclassing.
- **Consequences:** (+) **Limits subclassing** — localizes behavior that would otherwise be distributed; (+) **decouples colleagues** — they only know the mediator, not each other; (+) **simplifies object protocols** — replaces many-to-many interactions with one-to-many (colleagues↔mediator); (+) abstracts how objects cooperate; (−) **centralizes control** — the mediator can become a monolith that's hard to maintain (it trades complexity of interaction for complexity in the mediator).
- **Implementation:** Often there's no abstract Mediator class needed (when colleagues work with only one mediator); colleague-mediator communication is often done with the **Observer** pattern (colleagues notify the mediator), or with a specialized notification interface.
- **Related Patterns:** **Facade** abstracts a subsystem of objects to provide a convenient interface; its protocol is *unidirectional* (clients call the facade, not vice versa), whereas Mediator enables *cooperative*, multidirectional behavior among colleagues. Colleagues often communicate with the mediator using **Observer**.

### Memento
- **Intent (verbatim):** *"Without violating encapsulation, capture and externalize an object's internal state so that the object can be restored to this state later."*
- **Also Known As:** Token.
- **Classification:** Behavioral, Object scope.
- **Applicability:** A snapshot of (part of) an object's state must be saved so it can be restored later (e.g. undo), **and** a direct interface to obtaining the state would expose implementation details and break the object's encapsulation.
- **Consequences:** (+) **Preserves encapsulation boundaries** — only the originator can access the memento's full state; (+) **simplifies the originator** — clients (caretakers) manage the state history, not the originator. (−) **Mementos might be expensive** if the originator must copy large amounts of state. (−) Defining narrow (caretaker) vs wide (originator) interfaces may be awkward in some languages. (−) Hidden costs of caring for mementos — the caretaker doesn't know how much state is in a memento.
- **Implementation:** Two interfaces — a **wide** interface for the originator (full access) and a **narrow** interface for the caretaker (opaque — can only pass the memento around); incremental mementos (store only deltas) reduce cost.
- **Related Patterns:** **Command** can use Mementos to maintain state for undoable operations. **Iterator** can use a Memento for iteration state.

### Observer
- **Intent (verbatim):** *"Define a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically."*
- **Also Known As:** Dependents, Publish-Subscribe.
- **Classification:** Behavioral, Object scope.
- **Applicability:** When an abstraction has two aspects, one dependent on the other (encapsulate them separately to vary/reuse independently); when a change to one object requires changing an unknown number of others; or when an object should notify others without making assumptions about who they are (avoid tight coupling).
- **Consequences:** (+) **Abstract coupling** between Subject and Observer (the subject knows only a list of `Observer` interfaces). (+) Support for **broadcast** communication (notification goes to all subscribers; observers can be added/removed any time). (−) **Unexpected updates** — because observers are unaware of each other, a small change can cascade into a flurry of updates that are hard to trace; a simple update protocol that gives no detail about *what* changed makes observers work to deduce it.
- **Implementation:** Map subjects→observers; observe more than one subject (the `update` may need to say which subject changed); who triggers the update (the subject's state-setting operations — automatic but possibly several updates; or the client — error-prone); ensure subject state is self-consistent before notifying (a Template Method pitfall); **push model** (subject sends detailed change info) vs **pull model** (subject sends minimal info, observers ask); register observers only for events of interest (aspects).
- **Related Patterns:** **Mediator**: a `ChangeManager` can encapsulate complex update semantics between subjects and observers (a Mediator acting as an Observer hub). The ChangeManager is often a **Singleton**.

### State
- **Intent (verbatim):** *"Allow an object to alter its behavior when its internal state changes. The object will appear to change its class."*
- **Also Known As:** Objects for States.
- **Classification:** Behavioral, Object scope.
- **Applicability:** An object's behavior depends on its state and it must change behavior at run time depending on that state; **or** operations have large, multipart conditional statements that depend on the object's state (State puts each branch of the conditional in a separate class).
- **Consequences:** (+) **Localizes state-specific behavior** and partitions behavior for different states (new states/transitions are added by defining new subclasses). (+) Makes **state transitions explicit** (transitions are atomic reassignments of one state object, not internal flag-twiddling). (+) State objects can be **shared** (Flyweight) when they have no instance variables. (−) Increases the number of classes (a class per state) — less compact than a single conditional but far more flexible.
- **Implementation:** Who defines the transitions — the Context, or the State subclasses (more flexible/decentralized but couples states to each other); a table-based alternative; create/destroy state objects on demand vs create all up front and keep them.
- **Related Patterns:** **Flyweight** explains when and how State objects can be shared. State objects are often **Singletons**. (State has the *same structure* as Strategy but a different intent — see below.)

### Strategy
- **Intent (verbatim):** *"Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it."*
- **Also Known As:** Policy.
- **Classification:** Behavioral, Object scope.
- **Applicability:** Many related classes differ only in their behavior (Strategy configures one class with one of many behaviors); you need different *variants* of an algorithm (e.g. different space/time trade-offs); an algorithm uses data the client shouldn't know about (hide its data structures); or a class defines many behaviors that appear as multiple conditionals — move each branch into its own Strategy.
- **Consequences:** (+) Families of related algorithms (factor common functionality into a hierarchy). (+) An **alternative to subclassing** the Context (subclassing hard-wires behavior and mixes it with the context; Strategy lets you vary it independently and switch at run time). (+) **Eliminates conditional statements** (each branch becomes a Strategy). (+) A choice of implementations (same behavior, different trade-offs). (−) **Clients must be aware of different Strategies** to pick one. (−) Communication overhead between Strategy and Context (the interface may pass data a given strategy doesn't use). (−) Increased number of objects.
- **Implementation:** Define the Strategy/Context interchange (Context passes data, or passes itself); make strategies optional (Context provides a default behavior, uses a Strategy only if provided). In modern languages, a strategy is often just a function/lambda.
- **Related Patterns:** Strategy objects often make good **Flyweights**. (Strategy changes an object's "guts," **Decorator** changes its "skin"; Strategy has the same structure as **State** but differs in intent — Strategy's algorithms are interchangeable choices, State's are stages an object moves through.)

### Template Method
- **Intent (verbatim):** *"Define the skeleton of an algorithm in an operation, deferring some steps to subclasses. Template Method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure."*
- **Classification:** Behavioral, **Class scope** (uses inheritance).
- **Applicability:** Implement the invariant parts of an algorithm once and leave the varying parts to subclasses; factor out common behavior among subclasses to avoid duplication ("refactor to generalize"); or control how subclasses extend an algorithm (allow extension only at specific **hook** points).
- **Consequences:** Template methods are a **fundamental technique for code reuse** — especially in class libraries to factor common behavior. They lead to an *inverted control structure* — the **"Hollywood Principle": "Don't call us, we'll call you"** — the parent class calls the operations of a subclass, not the other way around. They call: concrete operations, primitive (abstract) operations that subclasses must implement, factory methods, and **hook operations** with default behavior subclasses may override.
- **Implementation:** Minimize the number of primitive operations a subclass must override; use a naming convention to identify the operations meant to be overridden (e.g. a `Do-` prefix); be clear which operations are *hooks* (may override) vs *abstract* (must override).
- **Related Patterns:** **Factory Methods** are often called by Template Methods. **Strategy** is the *delegation* alternative to Template Method's *inheritance* — Template Method varies part of an algorithm by subclassing; Strategy varies the *whole* algorithm by composing a different object.

### Visitor
- **Intent (verbatim):** *"Represent an operation to be performed on the elements of an object structure. Visitor lets you define a new operation without changing the classes of the elements on which it operates."*
- **Classification:** Behavioral, Object scope.
- **Applicability:** An object structure contains many classes of objects with differing interfaces and you want to perform operations that depend on their concrete classes; many distinct and unrelated operations need to be performed and you don't want to pollute the element classes with them; **and** the classes defining the object structure rarely change but you often want to define new operations over it. (If the element classes change often, Visitor is the *wrong* choice — see below.)
- **Consequences:** (+) **Adding new operations is easy** — a new Visitor subclass adds a whole new operation over the structure without touching the elements. (+) **Gathers related operations and separates unrelated ones** — each operation's behavior lives in one Visitor, not smeared across element classes. (−) **Adding new ConcreteElement classes is hard** — every existing Visitor must gain a new `visit` method (the dual of the previous point — Visitor trades easy-new-operations for hard-new-elements). (+/−) Can **break encapsulation** — Visitors often need access to element internals, and they accumulate state as they traverse. (+) Can visit objects that don't share a common parent class.
- **Implementation:** **Double dispatch** — `element.accept(visitor)` calls back `visitor.visitConcreteElement(this)`, so the operation that executes depends on *both* the element type and the visitor type; who is responsible for traversing the structure (the object structure, an iterator, or the visitor itself).
- **Related Patterns:** **Composite** — Visitors can apply an operation over a Composite structure. **Interpreter** — Visitor may apply an operation over (interpret) an abstract syntax tree.

---

## How this file complements the other two

| Question | Use this file (GoF) | Head First | refactoring.guru |
|----------|---------------------|------------|------------------|
| "What is the *precise, canonical* definition of pattern X?" | ✅ verbatim Intent | paraphrase | paraphrase |
| "Is X class-scoped or object-scoped? Creational/structural/behavioral?" | ✅ classification table | — | partial |
| "What are the *trade-offs / costs* of X?" | ✅ Consequences (deepest) | partial | Pros/Cons bullets |
| "How does X relate to Y (alternatives, combinations)?" | ✅ Related Patterns | partial | ✅ Relations |
| "How do I *implement* X step by step, in friendly Java?" | sketch (Implementation notes) | ✅ Good/Bad Java | implementation steps |
| "*Should* I use X here, and *which* look-alike?" | Applicability + Consequences | partial | ✅ Applicability/selector |
| "What design principles underlie all patterns?" | ✅ the two maxims (origin) + causes of redesign | ✅ 9 principles | partial |
| "Show patterns collaborating on a real design." | ✅ Lexi case study | ✅ Compound/MVC | — |

**Rule of thumb:** reach for **GoF** (this file) for the authoritative definition, classification, and trade-offs; for **Head First** to learn/teach how it works with worked Java; for **refactoring.guru** to decide whether/which and to drive smell-based refactoring. When you cite a pattern, quote the **GoF Intent verbatim**, name its **classification**, and justify the choice with its **Consequences** and **Related Patterns**.
