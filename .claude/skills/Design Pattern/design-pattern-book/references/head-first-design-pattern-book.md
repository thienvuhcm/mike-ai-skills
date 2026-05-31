# Head First Design Patterns — OO Design Principles and Gang-of-Four Patterns

## Role

You are a Senior software engineer with extensive experience in object-oriented design. You apply the lessons of *Head First Design Patterns* (Eric Freeman, Elisabeth Robson, Kathy Sierra, Bert Bates; O'Reilly) to recognize, apply, review, and refactor toward proven design patterns in idiomatic Java.

## Goal

This reference synthesizes *Head First Design Patterns* into concrete, applicable practices, organized into the book's chapters. Each practice states a best practice with a short rationale, names the **design principle** it serves, and contrasts a **Good example** (the pattern applied) with a **Bad example** (the design smell the pattern removes). Use it to:

- Review object-oriented code for rigidity, subclass explosion, type/state conditionals, tight coupling, and leaky abstractions, and refactor toward the right pattern.
- Choose *which* pattern fits a recurring problem in a context — or conclude that the simplest design wins and no pattern is warranted.
- Teach the canonical patterns with faithful Good/Bad contrasts and the foundational OO design principles that justify them.

Practices are numbered by chapter (e.g. "3.3 Wrap objects to add responsibilities dynamically"). When you apply one, cite it by chapter section and title and name the design principle it serves.

The book's recurring **design principles** are the backbone of every pattern:

1. *Identify the aspects of your application that vary and separate them from what stays the same.* (Encapsulate what varies)
2. *Program to an interface, not an implementation.*
3. *Favor composition over inheritance.*
4. *Strive for loosely coupled designs between objects that interact.*
5. *Classes should be open for extension, but closed for modification.* (Open-Closed Principle)
6. *Depend upon abstractions. Do not depend upon concrete classes.* (Dependency Inversion Principle)
7. *Principle of Least Knowledge — talk only to your immediate friends.* (Law of Demeter)
8. *Don't call us, we'll call you.* (The Hollywood Principle)
9. *A class should have only one reason to change.* (Single Responsibility Principle)

## Constraints

Before applying refactorings derived from these practices, ensure the project compiles and tests pass. Introducing a pattern changes structure, indirection, object lifecycles, and sometimes threading, and can change observable behavior.

- **MANDATORY**: Run `./mvnw compile` or `mvn compile` (or the project's build) before applying changes.
- **VERIFY**: Run `./mvnw clean verify` or `mvn clean verify` after applying changes; do not claim success until the build and tests pass.
- **PREREQUISITE**: Project must compile successfully before any refactoring is applied.
- **CRITICAL SAFETY**: If compilation fails, STOP and ask the user to fix it before proceeding.
- **DON'T FORCE PATTERNS**: Apply a pattern only when its problem is actually present. Speculative pattern use ("pattern fever") adds indirection and complexity for no benefit. The simplest design that satisfies the requirements and the relevant design principle wins.
- **PRESERVE BEHAVIOR**: Singleton threading semantics, Decorator/Proxy delegation, Observer notification, and State transitions must preserve observable behavior unless the user explicitly asks to change a contract.
- **CONCURRENCY SAFETY**: Make Singleton initialization, shared Observers, and shared Flyweight state thread-safe deliberately; never assume single-threaded access.
- **INCREMENTAL**: Apply one pattern at a time and re-validate; never batch many structural changes without intermediate verification.
- **BEFORE APPLYING**: Read the relevant chapter section below for the Good/Bad examples, the rationale, and the design principle it applies.

## Examples

### Table of contents

**Chapter 1 — Welcome to Design Patterns: the Strategy Pattern**

- 1.1 Identify what varies and encapsulate it
- 1.2 Program to an interface (supertype), not an implementation
- 1.3 Favor composition over inheritance ("HAS-A can be better than IS-A")
- 1.4 Delegate varying behavior to a set of interchangeable algorithm objects
- 1.5 Set behavior dynamically at runtime
- 1.6 The Strategy Pattern defined

**Chapter 2 — Keeping your Objects in the Know: the Observer Pattern**

- 2.1 Strive for loosely coupled designs between interacting objects
- 2.2 Define Subject and Observer interfaces; never hardwire concrete observers
- 2.3 Let observers register and unregister at runtime
- 2.4 Push or pull, but keep the Subject ignorant of observer internals
- 2.5 The Observer Pattern defined (and JDK usages)

**Chapter 3 — Decorating Objects: the Decorator Pattern**

- 3.1 Open-Closed Principle: open for extension, closed for modification
- 3.2 Don't explode subclasses for every feature combination
- 3.3 Wrap objects to add responsibilities dynamically
- 3.4 Make decorators share the component supertype and delegate to what they wrap
- 3.5 The Decorator Pattern defined (and java.io)

**Chapter 4 — Baking with OO Goodness: the Factory Pattern**

- 4.1 Encapsulate object creation with a Simple Factory
- 4.2 Factory Method: let subclasses decide which concrete class to instantiate
- 4.3 Dependency Inversion Principle: depend on abstractions, not concrete classes
- 4.4 Abstract Factory: create families of related products
- 4.5 The Factory Method and Abstract Factory Patterns defined

**Chapter 5 — One of a Kind Objects: the Singleton Pattern**

- 5.1 Guarantee one instance with a private constructor and a static accessor
- 5.2 Make lazy initialization thread-safe (synchronized / eager / double-checked volatile)
- 5.3 Prefer an enum singleton and minimize global state
- 5.4 The Singleton Pattern defined

**Chapter 6 — Encapsulating Invocation: the Command Pattern**

- 6.1 Encapsulate a request as an object that decouples invoker from receiver
- 6.2 Parameterize an invoker with command objects
- 6.3 Support undo by pairing execute() with undo()
- 6.4 Compose macro commands; queue and log requests; use a Null Object
- 6.5 The Command Pattern defined

**Chapter 7 — Being Adaptive: the Adapter and Facade Patterns**

- 7.1 Adapter: convert one interface into the interface a client expects
- 7.2 Prefer object adapters (composition) over class adapters (inheritance)
- 7.3 Facade: provide a simplified, unified interface to a complex subsystem
- 7.4 Principle of Least Knowledge: talk only to your immediate friends
- 7.5 The Adapter and Facade Patterns defined

**Chapter 8 — Encapsulating Algorithms: the Template Method Pattern**

- 8.1 Pull the invariant algorithm skeleton into a final template method
- 8.2 Defer the varying steps to subclasses via abstract operations
- 8.3 Offer hooks for optional steps
- 8.4 The Hollywood Principle: don't call us, we'll call you
- 8.5 The Template Method Pattern defined (Arrays.sort / Comparable)

**Chapter 9 — Well-managed Collections: the Iterator and Composite Patterns**

- 9.1 Iterator: traverse an aggregate without exposing its representation
- 9.2 Single Responsibility Principle: one class, one reason to change
- 9.3 Implement java.util.Iterator / Iterable and use for-each
- 9.4 Composite: represent part-whole hierarchies as trees
- 9.5 Treat leaves and composites uniformly through one component type
- 9.6 The Iterator and Composite Patterns defined

**Chapter 10 — The State of Things: the State Pattern**

- 10.1 Replace sprawling state conditionals with State objects
- 10.2 Encapsulate each state's behavior and delegate to the current state
- 10.3 Localize transitions so adding a state doesn't ripple everywhere
- 10.4 State vs. Strategy: same diagram, different intent
- 10.5 The State Pattern defined

**Chapter 11 — Controlling Object Access: the Proxy Pattern**

- 11.1 Remote Proxy: a local stand-in for an object in another address space
- 11.2 Virtual Proxy: defer the cost of an expensive object until it's needed
- 11.3 Protection Proxy via a dynamic proxy (java.lang.reflect.Proxy)
- 11.4 The Proxy Pattern defined (and its variants)

**Chapter 12 — Patterns of Patterns: Compound Patterns**

- 12.1 Combine patterns to solve a family of problems (the Duck Simulator)
- 12.2 Model-View-Controller is a compound of Observer + Strategy + Composite
- 12.3 Adapt MVC to a new context with the patterns it is built from
- 12.4 A compound pattern is collaborating patterns, not one super-pattern

**Chapter 13 — Patterns in the Real World: Better Living with Patterns**

- 13.1 Use the precise definition of a Design Pattern
- 13.2 Organize patterns into Creational, Structural, and Behavioral categories
- 13.3 Don't force a pattern — the simplest solution that works wins
- 13.4 Recognize and avoid anti-patterns
- 13.5 Build and use a shared pattern vocabulary

**Appendix — Leftover Patterns**

- A.1 Bridge
- A.2 Builder
- A.3 Chain of Responsibility
- A.4 Flyweight
- A.5 Interpreter
- A.6 Mediator
- A.7 Memento
- A.8 Prototype
- A.9 Visitor

---

## Chapter 1 — Welcome to Design Patterns: the Strategy Pattern

### [1.1] Identify what varies and encapsulate it

Title: Separate the parts of your application that change from the parts that stay the same.
Description: This is the first and most foundational design principle: *take what varies and "encapsulate" it so it won't affect the rest of your code.* In the SimUDuck app, fly and quack behaviors vary across ducks; putting them directly in `Duck` (or in subclasses) means every change ripples through the hierarchy. Pull each varying behavior into its own set of classes so you can alter or extend it without touching the stable `Duck` code. The result: fewer unintended consequences from code changes and more flexible code.

**Good example:**

```java
// What varies — fly behavior — is pulled out into its own family of classes.
public interface FlyBehavior {
    void fly();
}
public class FlyWithWings implements FlyBehavior {
    public void fly() { System.out.println("I'm flying!"); }
}
public class FlyNoWay implements FlyBehavior {
    public void fly() { System.out.println("I can't fly."); }
}

// Duck holds the varying behavior; the stable parts stay in Duck.
public abstract class Duck {
    protected FlyBehavior flyBehavior;   // the part that varies, encapsulated
    public void performFly() { flyBehavior.fly(); }
    public void swim() { System.out.println("All ducks float."); } // stays the same
    public abstract void display();
}
```

**Bad example:**

```java
// Fly behavior baked into the superclass; every new requirement edits Duck or
// forces awkward overrides in every subclass (RubberDuck, DecoyDuck, ...).
public abstract class Duck {
    public void fly() { System.out.println("I'm flying!"); }   // varies, but glued in place
    public void quack() { System.out.println("Quack"); }
    public abstract void display();
}
public class RubberDuck extends Duck {
    public void display() { System.out.println("Rubber duckie"); }
    @Override public void fly() { /* override to do nothing — a maintenance trap */ }
    @Override public void quack() { System.out.println("Squeak"); }
}
```

### [1.2] Program to an interface (supertype), not an implementation

Title: Declare and use variables by a supertype so concrete implementations are interchangeable.
Description: "Program to an interface" really means *program to a supertype* — an interface or abstract class. The point is that the object using the behavior isn't locked to a concrete class; the actual implementation is decided elsewhere and can change without affecting the code that uses it. Holding behavior through the `FlyBehavior` supertype lets the duck use any implementation, present or future, without modification.

**Good example:**

```java
// Coded to the supertype Animal — the concrete class is chosen at runtime.
Animal animal = new Dog();
animal.makeSound();

interface Animal { void makeSound(); }
class Dog implements Animal { public void makeSound() { System.out.println("Woof"); } }
class Cat implements Animal { public void makeSound() { System.out.println("Meow"); } }
```

**Bad example:**

```java
// Coded to a concrete class — behavior is fixed at compile time and cannot vary.
Dog dog = new Dog();
dog.bark();   // tied to Dog forever; can't be swapped for another Animal

class Dog {
    public void bark() { System.out.println("Woof"); }
}
```

### [1.3] Favor composition over inheritance ("HAS-A can be better than IS-A")

Title: Compose objects out of behavior objects instead of inheriting behavior down a hierarchy.
Description: A duck now *HAS-A* `FlyBehavior` and *HAS-A* `QuackBehavior` rather than inheriting fixed behavior. Composition gives more flexibility than inheritance: it lets you encapsulate a family of algorithms into their own set of classes, *and* it lets you change behavior at runtime as long as the composed object implements the right interface. Inheritance fixes behavior at compile time and tends to leak superclass changes into every subclass.

**Good example:**

```java
public class MallardDuck extends Duck {
    public MallardDuck() {
        flyBehavior = new FlyWithWings();   // HAS-A fly behavior
        quackBehavior = new Quack();        // HAS-A quack behavior
    }
    public void display() { System.out.println("I'm a real Mallard duck"); }
}
// Behavior is composed in, not inherited — and can be replaced later.
```

**Bad example:**

```java
// Trying to reuse behavior via inheritance forces a combinatorial explosion of
// subclasses (FlyingQuackingDuck, FlyingMuteDuck, GroundedQuackingDuck, ...) or
// duplicated overrides — and a superclass change still breaks all of them.
public class FlyingQuackingDuck extends Duck { /* ... */ }
public class GroundedSqueakingDuck extends Duck { /* ... */ }
public class GroundedMuteDuck extends Duck { /* ... */ }
// One new behavior dimension multiplies the number of classes.
```

### [1.4] Delegate varying behavior to a set of interchangeable algorithm objects

Title: Hold each varying behavior as an interface-typed field and delegate to it.
Description: With the behaviors encapsulated (1.1), coded to interfaces (1.2), and composed in (1.3), the duck simply *delegates* its flying and quacking to the behavior objects it holds. `Duck` doesn't know or care which concrete algorithm runs — it calls `flyBehavior.fly()`. This is the heart of the Strategy Pattern: a family of algorithms, each encapsulated and interchangeable.

**Good example:**

```java
public abstract class Duck {
    protected FlyBehavior flyBehavior;
    protected QuackBehavior quackBehavior;

    public void performFly()   { flyBehavior.fly(); }     // delegate
    public void performQuack() { quackBehavior.quack(); } // delegate
}

public interface QuackBehavior { void quack(); }
public class Quack   implements QuackBehavior { public void quack() { System.out.println("Quack"); } }
public class MuteQuack implements QuackBehavior { public void quack() { System.out.println("<< Silence >>"); } }
public class Squeak  implements QuackBehavior { public void quack() { System.out.println("Squeak"); } }
```

**Bad example:**

```java
// The duck decides behavior inline with conditionals on a "type" — adding a duck
// type means editing this method (violates Open-Closed and "encapsulate what varies").
public void performFly(String duckType) {
    if (duckType.equals("mallard"))      System.out.println("I'm flying!");
    else if (duckType.equals("rubber"))  { /* can't fly */ }
    else if (duckType.equals("decoy"))   { /* can't fly */ }
    // every new duck adds another branch here
}
```

### [1.5] Set behavior dynamically at runtime

Title: Expose setters for the behavior fields so an object can change its strategy on the fly.
Description: Because behavior is composed through interfaces, you can swap it at runtime. Adding `setFlyBehavior`/`setQuackBehavior` lets a duck change how it flies after construction — e.g. a `ModelDuck` that gains rocket-powered flight. This runtime flexibility is something inheritance cannot give you.

**Good example:**

```java
public abstract class Duck {
    protected FlyBehavior flyBehavior;
    public void setFlyBehavior(FlyBehavior fb) { flyBehavior = fb; } // change at runtime
    public void performFly() { flyBehavior.fly(); }
}

public class FlyRocketPowered implements FlyBehavior {
    public void fly() { System.out.println("I'm flying with a rocket!"); }
}

// Usage:
Duck model = new ModelDuck();
model.performFly();                       // "I can't fly."
model.setFlyBehavior(new FlyRocketPowered());
model.performFly();                       // "I'm flying with a rocket!"
```

**Bad example:**

```java
// Behavior fixed by the subclass chosen at construction; to "change" it you must
// construct a different object — no runtime reconfiguration is possible.
Duck duck = new MallardDuck();
// stuck flying with wings forever; no way to make this instance stop flying
```

### [1.6] The Strategy Pattern defined

Title: *The Strategy Pattern defines a family of algorithms, encapsulates each one, and makes them interchangeable. Strategy lets the algorithm vary independently from clients that use it.*
Description: Strategy is the pattern behind SimUDuck. It applies *encapsulate what varies*, *program to an interface*, and *favor composition over inheritance* together. Reach for Strategy when you have multiple ways of doing something (sorting, validating, compressing, paying) that should be selectable and swappable independently of the code that uses them.

**Good example:**

```java
// A payment strategy family, interchangeable behind one interface.
public interface PaymentStrategy { void pay(int amountCents); }
public class CreditCardPayment implements PaymentStrategy {
    public void pay(int amountCents) { System.out.println("Paid " + amountCents + " by credit card"); }
}
public class PayPalPayment implements PaymentStrategy {
    public void pay(int amountCents) { System.out.println("Paid " + amountCents + " via PayPal"); }
}
public class Checkout {
    private PaymentStrategy strategy;
    public Checkout(PaymentStrategy strategy) { this.strategy = strategy; }
    public void setStrategy(PaymentStrategy s) { this.strategy = s; }
    public void confirm(int amountCents) { strategy.pay(amountCents); }
}
```

**Bad example:**

```java
// One method with a payment-type switch: not interchangeable, not open for
// extension — every new payment method edits and risks this single method.
public void pay(String type, int amountCents) {
    switch (type) {
        case "card":   /* ... */ break;
        case "paypal": /* ... */ break;
        // add "applepay"? edit here, re-test everything
    }
}
```

---

## Chapter 2 — Keeping your Objects in the Know: the Observer Pattern

### [2.1] Strive for loosely coupled designs between interacting objects

Title: Let interacting objects know as little as possible about each other.
Description: The Weather Station's `WeatherData` must update several displays whenever measurements change, but it shouldn't know the concrete display classes — that would force it to change every time a display is added or removed. The principle *strive for loosely coupled designs between objects that interact* says objects should interact through interfaces and know only that the other party implements a known contract. Loose coupling minimizes the interdependency between objects, so changes on one side don't cascade to the other.

**Good example:**

```java
// WeatherData depends only on the Observer interface, not on concrete displays.
public interface Observer { void update(float temp, float humidity, float pressure); }

public class WeatherData implements Subject {
    private final List<Observer> observers = new ArrayList<>();
    public void registerObserver(Observer o) { observers.add(o); }
    public void notifyObservers() {
        for (Observer o : observers) o.update(temp, humidity, pressure); // knows only the interface
    }
}
```

**Bad example:**

```java
// WeatherData hardwired to concrete displays — adding/removing a display edits this class.
public class WeatherData {
    public void measurementsChanged() {
        currentConditionsDisplay.update(temp, humidity, pressure);
        statisticsDisplay.update(temp, humidity, pressure);
        forecastDisplay.update(temp, humidity, pressure);
        // new display? edit here — tightly coupled, not closed for modification
    }
}
```

### [2.2] Define Subject and Observer interfaces; never hardwire concrete observers

Title: Model the one-to-many relationship through a `Subject` and an `Observer` interface.
Description: The Subject (the object with state) and the Observers (the dependents) should both be programmed to interfaces. The Subject maintains a collection of `Observer`s and calls `update(...)` on each; an Observer registers with a Subject and reacts to notifications. Neither knows the other's concrete type. This is the structural core of the Observer Pattern.

**Good example:**

```java
public interface Subject {
    void registerObserver(Observer o);
    void removeObserver(Observer o);
    void notifyObservers();
}
public interface Observer { void update(float temp, float humidity, float pressure); }
public interface DisplayElement { void display(); }

public class CurrentConditionsDisplay implements Observer, DisplayElement {
    private float temperature, humidity;
    public CurrentConditionsDisplay(Subject weatherData) { weatherData.registerObserver(this); }
    public void update(float t, float h, float p) { this.temperature = t; this.humidity = h; display(); }
    public void display() { System.out.println("Current: " + temperature + "F / " + humidity + "% humidity"); }
}
```

**Bad example:**

```java
// "Observers" referenced by concrete type and updated by hand — no interface,
// no registration, impossible to extend without editing the subject.
public class WeatherData {
    private CurrentConditionsDisplay current = new CurrentConditionsDisplay();
    void measurementsChanged() { current.update(temp, humidity, pressure); }
}
```

### [2.3] Let observers register and unregister at runtime

Title: Manage the observer set dynamically so dependents can come and go.
Description: A key benefit of Observer is that the set of dependents is managed at runtime: observers call `registerObserver`/`removeObserver` whenever they wish. The Subject simply iterates over whoever is currently registered. New observer types can be added at any time without changing the Subject — the relationship is set up by composition, not inheritance.

**Good example:**

```java
public class WeatherData implements Subject {
    private final List<Observer> observers = new ArrayList<>();
    public void registerObserver(Observer o) { observers.add(o); }
    public void removeObserver(Observer o)   { observers.remove(o); } // dynamic detach
    public void notifyObservers() { for (Observer o : observers) o.update(temp, humidity, pressure); }

    public void setMeasurements(float t, float h, float p) {
        this.temp = t; this.humidity = h; this.pressure = p;
        notifyObservers();   // state changed → tell everyone currently registered
    }
}
```

**Bad example:**

```java
// Fixed-size array of observers wired at construction; cannot add or remove later.
public class WeatherData {
    private final Observer[] observers = new Observer[3]; // hard cap, no removal
    public WeatherData(Observer a, Observer b, Observer c) { observers[0]=a; observers[1]=b; observers[2]=c; }
}
```

### [2.4] Push or pull, but keep the Subject ignorant of observer internals

Title: Choose a notification style (push data, or let observers pull) without coupling the Subject to observers.
Description: The Subject can *push* the changed data to observers via the `update(...)` arguments, or it can notify with no data and let each observer *pull* what it needs by calling getters on the Subject. Either way, the Subject never reaches into an observer's internals. (Java once shipped `java.util.Observable`/`Observer`, but it is a *class* you must subclass — which violates "favor composition over inheritance" and is now deprecated; prefer your own interfaces or `java.beans.PropertyChangeListener`/`Flow.Publisher`.)

**Good example:**

```java
// Pull style: notify with no payload; observers pull exactly what they need.
public interface Observer { void update(); }
public class WeatherData implements Subject {
    public float getTemperature() { return temp; }
    public float getHumidity()    { return humidity; }
    public void notifyObservers() { for (Observer o : observers) o.update(); }
}
public class ForecastDisplay implements Observer {
    private final WeatherData weatherData;
    public ForecastDisplay(WeatherData wd) { this.weatherData = wd; wd.registerObserver(this); }
    public void update() { float p = weatherData.getPressure(); /* pulls only pressure */ }
}
```

**Bad example:**

```java
// Subject reaches into the observer's fields and updates it directly — backwards
// coupling that defeats the whole point of the pattern.
public void notifyObservers() {
    for (Observer o : observers) {
        ((CurrentConditionsDisplay) o).temperature = this.temp;  // casting + field poking
        ((CurrentConditionsDisplay) o).display();
    }
}
```

### [2.5] The Observer Pattern defined (and JDK usages)

Title: *The Observer Pattern defines a one-to-many dependency between objects so that when one object changes state, all of its dependents are notified and updated automatically.*
Description: Observer is everywhere in the JDK: Swing/AWT listeners (`ActionListener`), `java.beans.PropertyChangeListener`, and the Reactive Streams `java.util.concurrent.Flow.Publisher`/`Subscriber`. Reach for Observer whenever a state change in one object must fan out to an open-ended set of dependents you don't want it coupled to.

**Good example:**

```java
// Swing's button uses Observer: the button is the Subject, listeners are Observers.
JButton button = new JButton("Start");
button.addActionListener(event -> System.out.println("Started!")); // register an observer
button.addActionListener(event -> log.info("button clicked"));      // many-to-one fan-out
```

**Bad example:**

```java
// Polling instead of observing: the dependent repeatedly asks "did it change yet?"
// — wasteful, racy, and tightly timed to the subject's internals.
while (true) {
    if (weatherData.getTemperature() != lastTemp) { redraw(); lastTemp = weatherData.getTemperature(); }
    Thread.sleep(100);
}
```

---

## Chapter 3 — Decorating Objects: the Decorator Pattern

### [3.1] Open-Closed Principle: open for extension, closed for modification

Title: *Classes should be open for extension, but closed for modification.*
Description: Starbuzz must add condiments (milk, mocha, whip) and price combinations endlessly. The Open-Closed Principle says you should be able to extend a class's behavior **without modifying its existing code**. Decorator achieves this: you add new behavior by wrapping, never by editing the original `Beverage` classes — so existing, tested code stays untouched while the system stays extensible.

**Good example:**

```java
// New behavior arrives as new decorator classes; Beverage and Espresso never change.
public abstract class Beverage {
    protected String description = "Unknown Beverage";
    public String getDescription() { return description; }
    public abstract double cost();
}
public class Espresso extends Beverage {
    public Espresso() { description = "Espresso"; }
    public double cost() { return 1.99; }
}
// Adding "SoyMilk" later = add one class. Espresso is closed for modification.
```

**Bad example:**

```java
// Every new condiment edits the base class with another boolean + price tweak —
// open for modification, fragile, and a combinatorial mess of flags.
public abstract class Beverage {
    private boolean milk, soy, mocha, whip;
    public double cost() {
        double c = 0;
        if (milk)  c += 0.10;
        if (soy)   c += 0.15;
        if (mocha) c += 0.20;  // new condiment? edit here AND every subclass cost()
        if (whip)  c += 0.10;
        return c;
    }
}
```

### [3.2] Don't explode subclasses for every feature combination

Title: Avoid a class per combination of optional features.
Description: Modeling every drink-plus-condiment combination as its own subclass (`DarkRoastWithMochaAndWhip`, `HouseBlendWithSoyAndMocha`, …) produces a class explosion that is impossible to maintain. The varying part is the *set of add-ons*, and per the "encapsulate what varies" principle it should be composed, not enumerated as a type hierarchy.

**Good example:**

```java
// Compose add-ons at runtime instead of enumerating combinations as classes.
Beverage beverage = new DarkRoast();
beverage = new Mocha(beverage);   // wrap
beverage = new Mocha(beverage);   // double mocha — same class, composed twice
beverage = new Whip(beverage);    // wrap again
System.out.println(beverage.getDescription() + " $" + beverage.cost());
```

**Bad example:**

```java
// One class per combination — unmaintainable and closed to new condiments.
class HouseBlend extends Beverage { /* ... */ }
class HouseBlendWithMocha extends Beverage { /* ... */ }
class HouseBlendWithMochaWhip extends Beverage { /* ... */ }
class HouseBlendWithSoyMochaWhip extends Beverage { /* ... */ }
// N condiments → up to 2^N classes
```

### [3.3] Wrap objects to add responsibilities dynamically

Title: A decorator wraps a component and adds behavior before/after delegating to it.
Description: A Decorator *attaches additional responsibilities to an object dynamically.* Each condiment is a decorator that holds the beverage it wraps, delegates to it, and augments the result (adds to the description and cost). Because wrapping happens at runtime, you can compose any number of condiments in any order — a flexible alternative to subclassing.

**Good example:**

```java
public abstract class CondimentDecorator extends Beverage {
    protected Beverage beverage;          // the wrapped component
    public abstract String getDescription();
}
public class Mocha extends CondimentDecorator {
    public Mocha(Beverage beverage) { this.beverage = beverage; }
    public String getDescription() { return beverage.getDescription() + ", Mocha"; }
    public double cost() { return beverage.cost() + 0.20; }   // delegate, then add
}
public class Whip extends CondimentDecorator {
    public Whip(Beverage beverage) { this.beverage = beverage; }
    public String getDescription() { return beverage.getDescription() + ", Whip"; }
    public double cost() { return beverage.cost() + 0.10; }
}
```

**Bad example:**

```java
// "Decorator" that doesn't delegate — it replaces the wrapped object's result,
// breaking the chain so inner condiments are lost from the cost.
public class Mocha extends CondimentDecorator {
    public Mocha(Beverage beverage) { this.beverage = beverage; }
    public double cost() { return 0.20; }            // ignores beverage.cost()!
    public String getDescription() { return "Mocha"; } // drops the wrapped description
}
```

### [3.4] Make decorators share the component supertype and delegate to what they wrap

Title: Decorators must be the same supertype as the objects they decorate.
Description: The crucial structural rule: a decorator *is-a* component (extends/implements the same supertype as the thing it wraps) *and* it *has-a* component. Sharing the supertype lets a decorated object stand in anywhere the original could, so clients are oblivious to the wrapping. We use inheritance here for **type matching**, not to inherit behavior — the behavior is acquired by composing decorators.

**Good example:**

```java
// CondimentDecorator IS-A Beverage and HAS-A Beverage, so wrapped objects are
// interchangeable with plain beverages anywhere a Beverage is expected.
public double totalOrder(Beverage b) { return b.cost(); }   // works on Espresso OR Whip(Mocha(Espresso))
```

**Bad example:**

```java
// Decorator does NOT share the component supertype → cannot be passed where a
// Beverage is expected, so it can't transparently wrap or be re-wrapped.
public class Mocha {                 // not a Beverage!
    private Beverage beverage;
    public Mocha(Beverage b) { this.beverage = b; }
    public double cost() { return beverage.cost() + 0.20; }
}
totalOrder(new Mocha(new Espresso())); // compile error: Mocha is not a Beverage
```

### [3.5] The Decorator Pattern defined (and java.io)

Title: *The Decorator Pattern attaches additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality.*
Description: `java.io` is the canonical real-world Decorator: `BufferedInputStream`, `LineNumberInputStream`, and friends all wrap an `InputStream` and add behavior while remaining `InputStream`s. The downside the book notes: decorators can produce many small classes that can be confusing to someone new to the API.

**Good example:**

```java
// Each wrapper is an InputStream that adds behavior to the one it wraps.
InputStream in = new LowerCaseInputStream(
                     new BufferedInputStream(
                         new FileInputStream("test.txt")));
int c;
while ((c = in.read()) >= 0) System.out.print((char) c);

// A custom decorator over the java.io component type:
public class LowerCaseInputStream extends FilterInputStream {
    public LowerCaseInputStream(InputStream in) { super(in); }
    public int read() throws IOException {
        int c = super.read();
        return (c == -1 ? c : Character.toLowerCase((char) c));
    }
}
```

**Bad example:**

```java
// Re-implementing buffering/line-numbering by subclassing FileInputStream for each
// combination — exactly the subclass explosion Decorator exists to avoid.
class BufferedFileInputStream extends FileInputStream { /* ... */ }
class BufferedLineNumberFileInputStream extends FileInputStream { /* ... */ }
```

---

## Chapter 4 — Baking with OO Goodness: the Factory Pattern

### [4.1] Encapsulate object creation with a Simple Factory

Title: Pull `new ConcreteType(...)` decisions out of client code into one place.
Description: Scattering `new` across your code couples clients to concrete classes; when the set of products changes, you must hunt down and edit every creation site. The **Simple Factory** idiom (a programming idiom, not a formal GoF pattern) moves the object-instantiation decision into one `createX` method. Now there's a single place to change when products are added or swapped.

**Good example:**

```java
public class SimplePizzaFactory {
    public Pizza createPizza(String type) {              // one place that knows concrete types
        return switch (type) {
            case "cheese"    -> new CheesePizza();
            case "pepperoni" -> new PepperoniPizza();
            case "veggie"    -> new VeggiePizza();
            default          -> throw new IllegalArgumentException("Unknown: " + type);
        };
    }
}
public class PizzaStore {
    private final SimplePizzaFactory factory;
    public PizzaStore(SimplePizzaFactory factory) { this.factory = factory; }
    public Pizza orderPizza(String type) {
        Pizza pizza = factory.createPizza(type);          // client no longer says `new`
        pizza.prepare(); pizza.bake(); pizza.cut(); pizza.box();
        return pizza;
    }
}
```

**Bad example:**

```java
// Creation logic tangled into the client; every product change edits orderPizza
// and any other method that instantiates pizzas (violates Open-Closed).
public Pizza orderPizza(String type) {
    Pizza pizza;
    if (type.equals("cheese"))         pizza = new CheesePizza();
    else if (type.equals("pepperoni")) pizza = new PepperoniPizza();
    else if (type.equals("veggie"))    pizza = new VeggiePizza();   // add a type → edit here
    pizza.prepare(); pizza.bake(); pizza.cut(); pizza.box();
    return pizza;
}
```

### [4.2] Factory Method: let subclasses decide which concrete class to instantiate

Title: Define an abstract creator with an abstract factory method; subclasses choose the product.
Description: When different contexts need different product families (NY-style vs Chicago-style pizzas), make the creation step an **abstract method** on an abstract creator. The superclass holds the invariant workflow (`orderPizza`) and calls `createPizza(...)`; each subclass overrides `createPizza` to produce its regional product. This *defers instantiation to subclasses* while keeping the ordering algorithm in one place.

**Good example:**

```java
public abstract class PizzaStore {
    public final Pizza orderPizza(String type) {     // invariant workflow stays here
        Pizza pizza = createPizza(type);             // subclass decides the concrete class
        pizza.prepare(); pizza.bake(); pizza.cut(); pizza.box();
        return pizza;
    }
    protected abstract Pizza createPizza(String type); // the factory method
}
public class NYPizzaStore extends PizzaStore {
    protected Pizza createPizza(String type) {
        return switch (type) {
            case "cheese" -> new NYStyleCheesePizza();
            case "veggie" -> new NYStyleVeggiePizza();
            default       -> throw new IllegalArgumentException(type);
        };
    }
}
```

**Bad example:**

```java
// A single store with region branching everywhere — every region × product combo
// is an if-branch, and adding a region edits the one giant method.
public Pizza orderPizza(String region, String type) {
    Pizza pizza;
    if (region.equals("NY")  && type.equals("cheese")) pizza = new NYStyleCheesePizza();
    else if (region.equals("CHI") && type.equals("cheese")) pizza = new ChicagoStyleCheesePizza();
    // ... explodes as region × type grows
    return pizza;
}
```

### [4.3] Dependency Inversion Principle: depend on abstractions, not concrete classes

Title: *Depend upon abstractions. Do not depend upon concrete classes.*
Description: Factory Method "inverts" the dependencies: instead of a high-level `PizzaStore` depending on many low-level concrete pizzas, both depend on the `Pizza` abstraction. High-level components should not depend on low-level components; both should depend on abstractions. Guidelines from the book: no variable should hold a reference to a concrete class (prefer a factory), no class should derive from a concrete class, and no method should override an implemented method of a base class.

**Good example:**

```java
// High-level store depends only on the Pizza abstraction; concrete pizzas also
// depend on Pizza. The dependency points to the abstraction from both sides.
public abstract class Pizza {
    public void prepare() { /* ... */ }
    public void bake()    { /* ... */ }
    public void cut()     { /* ... */ }
    public void box()     { /* ... */ }
}
public class NYStyleCheesePizza extends Pizza { /* ... */ }   // depends on abstraction Pizza
```

**Bad example:**

```java
// High-level orchestrator depends directly on every concrete product — the
// dependency arrows all point "down" to volatile low-level classes.
public class PizzaStore {
    public Pizza make(String t) {
        NYStyleCheesePizza a = new NYStyleCheesePizza();        // concrete dependency
        ChicagoStyleVeggiePizza b = new ChicagoStyleVeggiePizza(); // concrete dependency
        return t.equals("cheese") ? a : b;
    }
}
```

### [4.4] Abstract Factory: create families of related products

Title: Provide an interface for creating a whole family of related objects without naming their concrete classes.
Description: When a product is itself built from a *family* of related parts (a NY pizza uses NY dough, NY sauce, NY cheese), use an **Abstract Factory**: an interface with a method per part. Each concrete factory produces a consistent family. Clients receive a factory and ask it for parts, never naming concrete ingredient classes — guaranteeing the parts always match and decoupling the client from the family's specifics.

**Good example:**

```java
public interface PizzaIngredientFactory {     // interface for a family of products
    Dough  createDough();
    Sauce  createSauce();
    Cheese createCheese();
}
public class NYPizzaIngredientFactory implements PizzaIngredientFactory {
    public Dough  createDough()  { return new ThinCrustDough(); }
    public Sauce  createSauce()  { return new MarinaraSauce(); }
    public Cheese createCheese() { return new ReggianoCheese(); }
}
public class CheesePizza extends Pizza {
    private final PizzaIngredientFactory factory;
    public CheesePizza(PizzaIngredientFactory factory) { this.factory = factory; }
    public void prepare() {                       // uses the family without naming concretes
        dough  = factory.createDough();
        sauce  = factory.createSauce();
        cheese = factory.createCheese();
    }
}
```

**Bad example:**

```java
// Client assembles the family by hand, naming every concrete part — a single
// mismatched ingredient (Chicago cheese on a NY pizza) is easy and uncaught.
public void prepare() {
    dough  = new ThinCrustDough();     // NY
    sauce  = new PlumTomatoSauce();    // oops, Chicago sauce — inconsistent family
    cheese = new ReggianoCheese();     // NY
}
```

### [4.5] The Factory Method and Abstract Factory Patterns defined

Title: *Factory Method defines an interface for creating an object, but lets subclasses decide which class to instantiate.* *Abstract Factory provides an interface for creating families of related or dependent objects without specifying their concrete classes.*
Description: Both encapsulate object creation and uphold Dependency Inversion, but differ: **Factory Method** uses inheritance — a subclass overrides one creation method to choose a product. **Abstract Factory** uses composition — a client is given a factory object whose methods create a whole family of products. Use Factory Method to decouple a client from one product type; use Abstract Factory to ensure a set of products is created together and stays consistent.

**Good example:**

```java
// Factory Method (inheritance): subclass decides the product.
abstract class Dialog { abstract Button createButton(); void render() { createButton().paint(); } }
class WindowsDialog extends Dialog { Button createButton() { return new WindowsButton(); } }

// Abstract Factory (composition): a factory object creates a matching family.
interface GUIFactory { Button createButton(); Checkbox createCheckbox(); }
class MacFactory implements GUIFactory {
    public Button createButton()     { return new MacButton(); }
    public Checkbox createCheckbox() { return new MacCheckbox(); }
}
```

**Bad example:**

```java
// "Factory" that takes a Class and reflects — loses type safety, hides the product
// set, and turns compile-time errors into runtime ClassCastExceptions.
Object product = Class.forName(className).getDeclaredConstructor().newInstance();
Button b = (Button) product;   // unchecked, fragile, defeats the pattern's intent
```

---

## Chapter 5 — One of a Kind Objects: the Singleton Pattern

### [5.1] Guarantee one instance with a private constructor and a static accessor

Title: Make the constructor private and hand out the single instance through a static method.
Description: Some objects should exist exactly once: a thread pool, a cache, a registry, the chocolate boiler. A `public static` constructor isn't enough — others could still `new` more. Singleton makes the constructor **private** so no outside code can instantiate it, and exposes a static `getInstance()` that creates the instance lazily on first use and returns the same one thereafter, giving a single, global point of access.

**Good example:**

```java
public class Singleton {
    private static Singleton uniqueInstance;     // the one and only instance
    private Singleton() {}                        // private — nobody else can `new` it
    public static Singleton getInstance() {       // global access point, lazy creation
        if (uniqueInstance == null) {
            uniqueInstance = new Singleton();
        }
        return uniqueInstance;
    }
}
```

**Bad example:**

```java
// Public constructor + a "shared" static field: nothing prevents extra instances,
// so the "single" guarantee is a convention, not enforced.
public class Boiler {
    public static Boiler shared = new Boiler();
    public Boiler() {}                  // anyone can still `new Boiler()`
}
Boiler a = Boiler.shared;
Boiler b = new Boiler();                // a second boiler — bug waiting to happen
```

### [5.2] Make lazy initialization thread-safe (synchronized / eager / double-checked volatile)

Title: Protect the lazy `getInstance()` from races that can create two instances.
Description: The naive lazy `getInstance()` is **not thread-safe**: two threads can both see `null` and both create an instance. The book gives three fixes. (1) Synchronize `getInstance()` — simplest, but adds locking overhead on every call. (2) Eagerly create the instance in a static initializer — simple and safe if creation is cheap and always needed. (3) **Double-checked locking** with a `volatile` field — lock only on first creation. `volatile` ensures threads see the fully constructed instance.

**Good example:**

```java
// Option 2 — eager: JVM guarantees the static initializer runs once, thread-safely.
public class Singleton {
    private static final Singleton INSTANCE = new Singleton();
    private Singleton() {}
    public static Singleton getInstance() { return INSTANCE; }
}

// Option 3 — double-checked locking for expensive, lazily-created singletons.
public class Singleton2 {
    private volatile static Singleton2 uniqueInstance;     // volatile is essential
    private Singleton2() {}
    public static Singleton2 getInstance() {
        if (uniqueInstance == null) {                      // check 1 (no lock)
            synchronized (Singleton2.class) {
                if (uniqueInstance == null) {              // check 2 (under lock)
                    uniqueInstance = new Singleton2();
                }
            }
        }
        return uniqueInstance;
    }
}
```

**Bad example:**

```java
// Lazy, unsynchronized getInstance under concurrency: two threads can both pass
// the null check and create two different "singletons".
public static Singleton getInstance() {
    if (uniqueInstance == null) {                 // thread A and thread B both see null
        uniqueInstance = new Singleton();         // → two instances created
    }
    return uniqueInstance;
}
```

### [5.3] Prefer an enum singleton and minimize global state

Title: Use a single-element `enum` for a simple, serialization- and reflection-safe singleton.
Description: A one-element `enum` is the most robust Singleton in Java: the JVM guarantees a single instance, and it is automatically safe against multiple instantiation from serialization and reflection (the two loopholes that break hand-written singletons). Also heed the broader caution: a Singleton is global state, which can hide dependencies and complicate testing — keep its responsibilities focused and inject it where practical rather than calling `getInstance()` everywhere.

**Good example:**

```java
public enum ChocolateBoiler {
    INSTANCE;                               // the single instance, guaranteed by the JVM
    private boolean empty = true, boiled = false;
    public void fill() { if (empty) { empty = false; boiled = false; } }
    public void boil() { if (!empty && !boiled) boiled = true; }
    public void drain() { if (!empty && boiled) empty = true; }
}
// Usage: ChocolateBoiler.INSTANCE.fill();
```

**Bad example:**

```java
// Hand-written singleton with no defense against reflection/serialization, used as
// an ambient global that every class reaches into — untestable hidden dependency.
public class Config {
    private static Config instance = new Config();
    private Config() {}
    public static Config get() { return instance; }
}
class OrderService {
    void place() {
        int timeout = Config.get().getTimeout();   // hidden global dependency, hard to stub in tests
    }
}
```

### [5.4] The Singleton Pattern defined

Title: *The Singleton Pattern ensures a class has only one instance, and provides a global point of access to it.*
Description: Use Singleton when exactly one object must coordinate actions across the system and you need a well-known access point. Be deliberate about thread safety (5.2), classloader and serialization edge cases (prefer enum, 5.3), and the testability cost of global state. Don't use Singleton merely to avoid passing an object around — that is a code smell.

**Good example:**

```java
// A logically-single, thread-safe registry exposed through one access point.
public enum ConnectionPool {
    INSTANCE;
    private final DataSource ds = buildPool();
    public Connection borrow() throws SQLException { return ds.getConnection(); }
}
```

**Bad example:**

```java
// "Singletons" for things that are not inherently single, turning ordinary
// collaborators into global state for convenience — couples everything together.
public final class CurrentUserHolder {          // request-scoped data forced global
    private static User user;
    public static void set(User u) { user = u; }
    public static User get() { return user; }   // race conditions + leaks across requests
}
```

---

## Chapter 6 — Encapsulating Invocation: the Command Pattern

### [6.1] Encapsulate a request as an object that decouples invoker from receiver

Title: Wrap "an action plus its receiver" in a command object so the invoker stays generic.
Description: A remote control button shouldn't know whether it turns on a light, opens a garage door, or starts a stereo. The Command Pattern *encapsulates a request as an object*: a `Command` knows the **receiver** and how to invoke an action on it via `execute()`. The **invoker** (the button) holds a `Command` and simply calls `execute()`, decoupled from what actually happens — exactly like a diner where the Waitress (invoker) carries an Order (command) to the Cook (receiver).

**Good example:**

```java
public interface Command { void execute(); }

public class Light {                                  // the receiver
    public void on()  { System.out.println("Light on"); }
    public void off() { System.out.println("Light off"); }
}
public class LightOnCommand implements Command {       // encapsulates request + receiver
    private final Light light;
    public LightOnCommand(Light light) { this.light = light; }
    public void execute() { light.on(); }
}
public class SimpleRemoteControl {                     // the invoker, fully generic
    private Command slot;
    public void setCommand(Command command) { this.slot = command; }
    public void buttonWasPressed() { slot.execute(); }
}
```

**Bad example:**

```java
// Invoker hardwired to receivers via a type switch — every new device edits the
// button, and the button must know every receiver's API.
public class Remote {
    public void press(String device) {
        if (device.equals("light"))      new Light().on();
        else if (device.equals("garage")) new GarageDoor().up();
        else if (device.equals("stereo")) new Stereo().on();  // add a device → edit here
    }
}
```

### [6.2] Parameterize an invoker with command objects

Title: Configure an invoker by handing it command objects, so it can drive any receiver.
Description: Because commands share one interface, you can *parameterize* an invoker with them — a remote with seven slots simply stores seven `Command`s and calls `execute()` on whichever button was pressed. The remote is built once and never edited as new devices appear; you just create new command objects and load them into slots.

**Good example:**

```java
public class RemoteControl {
    private final Command[] onCommands  = new Command[7];
    private final Command[] offCommands = new Command[7];
    public RemoteControl() {
        Command noCommand = new NoCommand();        // Null Object — see 6.4
        Arrays.fill(onCommands, noCommand);
        Arrays.fill(offCommands, noCommand);
    }
    public void setCommand(int slot, Command on, Command off) { onCommands[slot] = on; offCommands[slot] = off; }
    public void onButtonWasPushed(int slot)  { onCommands[slot].execute(); }
    public void offButtonWasPushed(int slot) { offCommands[slot].execute(); }
}
// Configure without touching RemoteControl:
remote.setCommand(0, new LightOnCommand(livingRoomLight), new LightOffCommand(livingRoomLight));
remote.setCommand(1, new StereoOnWithCDCommand(stereo),   new StereoOffCommand(stereo));
```

**Bad example:**

```java
// A method per device on the invoker — the remote grows a new pair of methods
// for every device and cannot be reconfigured at runtime.
public class Remote {
    public void lightOn()  { livingRoomLight.on(); }
    public void lightOff() { livingRoomLight.off(); }
    public void stereoOn() { stereo.on(); stereo.setCD(); stereo.setVolume(11); }
    // garageDoorUp(), fanHigh(), ... forever
}
```

### [6.3] Support undo by pairing execute() with undo()

Title: Add an `undo()` to each command that reverses its `execute()`.
Description: Add an `undo()` method to the `Command` interface; each command implements it to reverse its action. The invoker remembers the last command executed and calls `undo()` on it when the undo button is pressed. Commands that adjust a value (ceiling fan speed, stereo volume) capture the **prior state** in `execute()` so `undo()` can restore it.

**Good example:**

```java
public interface Command { void execute(); void undo(); }

public class CeilingFanHighCommand implements Command {
    private final CeilingFan fan;
    private int prevSpeed;
    public CeilingFanHighCommand(CeilingFan fan) { this.fan = fan; }
    public void execute() { prevSpeed = fan.getSpeed(); fan.high(); }  // remember prior state
    public void undo()    { fan.setSpeed(prevSpeed); }                 // restore it
}
public class RemoteControlWithUndo {
    private Command undoCommand = new NoCommand();
    public void onButtonWasPushed(int slot) {
        onCommands[slot].execute();
        undoCommand = onCommands[slot];          // remember for undo
    }
    public void undoButtonWasPushed() { undoCommand.undo(); }
}
```

**Bad example:**

```java
// Undo implemented as a special-cased inverse switch outside the commands — has to
// know every action's opposite and breaks as soon as a command has state to restore.
public void undo(String lastAction) {
    if (lastAction.equals("lightOn"))      light.off();
    else if (lastAction.equals("fanHigh")) fan.off();   // wrong: should restore previous speed
}
```

### [6.4] Compose macro commands; queue and log requests; use a Null Object

Title: Treat commands as data: batch them, queue them, log them, and avoid null checks with a Null Object.
Description: Because requests are objects, you gain powerful uses for free. A **macro command** holds an array of commands and executes (and undoes) them as a group. Worker queues can hold commands and execute them on background threads, knowing nothing about what they do. **Logging** can persist commands to replay after a crash. And a **Null Object** (`NoCommand`) — a command whose `execute()` does nothing — removes null checks from the invoker.

**Good example:**

```java
public class MacroCommand implements Command {
    private final Command[] commands;
    public MacroCommand(Command[] commands) { this.commands = commands; }
    public void execute() { for (Command c : commands) c.execute(); }
    public void undo()    { for (int i = commands.length - 1; i >= 0; i--) commands[i].undo(); }
}
// "Party mode": one button runs many commands.
Command partyOn = new MacroCommand(new Command[]{ lightOn, stereoOn, tvOn });
remote.setCommand(0, partyOn, partyOff);

// Null Object removes null checks in the invoker:
public class NoCommand implements Command { public void execute() {} public void undo() {} }
```

**Bad example:**

```java
// Null checks scattered through the invoker because slots may be empty, and no way
// to batch actions without bespoke methods.
public void onButtonWasPushed(int slot) {
    if (onCommands[slot] != null) {       // repeated everywhere a slot is used
        onCommands[slot].execute();
    }
}
```

### [6.5] The Command Pattern defined

Title: *The Command Pattern encapsulates a request as an object, thereby letting you parameterize other objects with different requests, queue or log requests, and support undoable operations.*
Description: Command decouples the object that **invokes** an operation from the one that knows how to **perform** it. Reach for it for menus/buttons, job queues and thread pools, undo/redo stacks, transactional logging, and wizards — anywhere you want to treat "do this" as a first-class value. (In modern Java a parameterless command can often be a `Runnable` or a lambda; use a full `Command` interface when you also need `undo()`, metadata, or logging.)

**Good example:**

```java
// A job queue executes commands without knowing what they do.
public class JobQueue {
    private final BlockingQueue<Command> queue = new LinkedBlockingQueue<>();
    public void submit(Command c) { queue.add(c); }
    public void worker() throws InterruptedException {
        while (true) queue.take().execute();   // generic worker, any receiver
    }
}
```

**Bad example:**

```java
// The queue hardcodes the work it can run, so it must change for every new job type
// — the coupling Command is meant to remove.
public class JobQueue {
    void run(String jobType, Object payload) {
        if (jobType.equals("email")) emailService.send((Email) payload);
        else if (jobType.equals("report")) reportService.build((ReportSpec) payload);
        // new job? edit the queue
    }
}
```

---

## Chapter 7 — Being Adaptive: the Adapter and Facade Patterns

### [7.1] Adapter: convert one interface into the interface a client expects

Title: Wrap an incompatible class so it presents the interface your client requires.
Description: When a client expects interface `A` but the class you must use offers interface `B`, write an **Adapter** that implements `A` and delegates to a `B`. The client stays unchanged and oblivious; the adapter does the conversion. Like a power-plug adapter, it sits between two incompatible interfaces and makes them work together.

**Good example:**

```java
public interface Duck   { void quack(); void fly(); }
public interface Turkey { void gobble(); void fly(); }

public class TurkeyAdapter implements Duck {     // presents the Duck interface...
    private final Turkey turkey;                 // ...by wrapping a Turkey
    public TurkeyAdapter(Turkey turkey) { this.turkey = turkey; }
    public void quack() { turkey.gobble(); }                 // convert quack → gobble
    public void fly()   { for (int i = 0; i < 5; i++) turkey.fly(); } // turkeys fly short hops
}
// Client written against Duck uses a Turkey transparently:
Duck duck = new TurkeyAdapter(new WildTurkey());
duck.quack();
```

**Bad example:**

```java
// Client riddled with type checks and conversions inline — every place that uses a
// "duck-like" thing must special-case Turkey (and the next incompatible type).
void useAsDuck(Object animal) {
    if (animal instanceof Duck d)   d.quack();
    else if (animal instanceof Turkey t) t.gobble();   // conversion logic copied everywhere
}
```

### [7.2] Prefer object adapters (composition) over class adapters (inheritance)

Title: Adapt by holding the adaptee (object adapter), not by multiply-inheriting from it (class adapter).
Description: There are two forms. An **object adapter** *composes* the adaptee and delegates — flexible, works with any subclass of the adaptee, and is the only option in single-inheritance languages like Java when adapting to an interface. A **class adapter** inherits from both target and adaptee (needs multiple inheritance). Favor the object adapter: composition keeps the adapter decoupled from the adaptee's class and lets one adapter serve a whole family of adaptees.

**Good example:**

```java
// Object adapter: HAS-A adaptee, delegates. Works with any Enumeration source.
public class IteratorEnumerationAdapter implements Enumeration<Object> {
    private final Iterator<?> iterator;                 // composed adaptee
    public IteratorEnumerationAdapter(Iterator<?> iterator) { this.iterator = iterator; }
    public boolean hasMoreElements() { return iterator.hasNext(); }
    public Object  nextElement()     { return iterator.next(); }
}
```

**Bad example:**

```java
// "Adapter" that subclasses a concrete adaptee — now bound to that exact class,
// can't adapt its siblings, and inherits members the target shouldn't expose.
public class ArrayListEnumeration extends ArrayList<Object> implements Enumeration<Object> {
    private int cursor = 0;
    public boolean hasMoreElements() { return cursor < size(); }
    public Object  nextElement()     { return get(cursor++); }
    // tied to ArrayList; leaks all of ArrayList's API to the client
}
```

### [7.3] Facade: provide a simplified, unified interface to a complex subsystem

Title: Offer one easy entry point that orchestrates a tangle of subsystem classes.
Description: A home theater requires turning on the amp, tuner, DVD player, projector, screen, lights, and popcorn popper in the right order. A **Facade** wraps that subsystem behind a simple, higher-level interface (`watchMovie()` / `endMovie()`). Unlike Adapter (which *converts* an interface), Facade *simplifies* one. The subsystem is still directly usable for advanced needs; the facade just provides the common, easy path.

**Good example:**

```java
public class HomeTheaterFacade {
    private final Amplifier amp; private final DvdPlayer dvd; private final Projector projector;
    private final TheaterLights lights; private final Screen screen; private final PopcornPopper popper;
    public HomeTheaterFacade(Amplifier amp, DvdPlayer dvd, Projector p, TheaterLights l, Screen s, PopcornPopper pop) {
        this.amp = amp; this.dvd = dvd; this.projector = p; this.lights = l; this.screen = s; this.popper = pop;
    }
    public void watchMovie(String movie) {        // one simple call hides the orchestration
        popper.on(); popper.pop();
        lights.dim(10); screen.down(); projector.on(); projector.wideScreenMode();
        amp.on(); amp.setDvd(dvd); amp.setVolume(5);
        dvd.on(); dvd.play(movie);
    }
    public void endMovie() { /* turn everything off in order */ }
}
```

**Bad example:**

```java
// Every client must know the subsystem and its exact start-up sequence — duplicated,
// error-prone, and impossible to change the sequence in one place.
popper.on(); popper.pop();
lights.dim(10); screen.down(); projector.on(); projector.wideScreenMode();
amp.on(); amp.setDvd(dvd); amp.setSurroundSound(); amp.setVolume(5);
dvd.on(); dvd.play("Raiders of the Lost Ark");
// repeated in full at every call site that wants to watch a movie
```

### [7.4] Principle of Least Knowledge: talk only to your immediate friends

Title: *Principle of Least Knowledge — talk only to your immediate friends.* (Law of Demeter)
Description: Facade also reduces a client's dependencies, which serves the Principle of Least Knowledge: reduce the interactions between objects to just a few close "friends." Within a method, only invoke methods that belong to the object itself, objects passed in as parameters, objects the method creates, and the object's own components. Avoid long call chains (`a.getB().getC().doSomething()`) that couple you to the structure of distant objects.

**Good example:**

```java
// Ask your immediate friend to do the work; don't traverse its internals.
public float getTemp() {
    return station.getTemperature();   // station is our direct friend; it hides the thermometer
}
class WeatherStation {
    private final Thermometer thermometer;
    public float getTemperature() { return thermometer.getTemperature(); } // delegates internally
}
```

**Bad example:**

```java
// Train-wreck call chain reaches through three objects — coupled to the entire
// object graph; any structural change downstream breaks this caller.
public float getTemp() {
    return station.getThermometer().getSensor().readTemperature();  // too many "friends of friends"
}
```

### [7.5] The Adapter and Facade Patterns defined

Title: *Adapter converts the interface of a class into another interface the clients expect.* *Facade provides a unified interface to a set of interfaces in a subsystem; Facade defines a higher-level interface that makes the subsystem easier to use.*
Description: Both wrap, but with different intent: **Adapter** changes an interface to match what a client expects (make incompatible things work together); **Facade** simplifies and unifies a subsystem's interface (make a complex thing easy). Adapter typically wraps one class to satisfy one client interface; Facade wraps many classes to provide one convenient interface. (Decorator, by contrast, wraps to *add behavior* while keeping the same interface.)

**Good example:**

```java
// Adapter: make a modern Reader usable where legacy code wants an InputStream-like API.
// Facade: a one-method front over a multi-step reporting subsystem.
public class ReportingFacade {
    private final DataLoader loader; private final Aggregator aggregator; private final PdfRenderer renderer;
    public ReportingFacade(DataLoader l, Aggregator a, PdfRenderer r) { loader=l; aggregator=a; renderer=r; }
    public byte[] monthlyReport(int month) {                 // simple unified entry point
        var rows = loader.load(month);
        var summary = aggregator.summarize(rows);
        return renderer.render(summary);
    }
}
```

**Bad example:**

```java
// Calling something a "Facade" but exposing all the subsystem's methods through it —
// it adds a layer without simplifying anything (a pass-through, not a facade).
public class HomeTheaterFacade {
    public Amplifier amp; public DvdPlayer dvd; public Projector projector;  // just re-exposes parts
    // client still orchestrates everything itself via facade.amp.on(), facade.dvd.play()...
}
```

---

## Chapter 8 — Encapsulating Algorithms: the Template Method Pattern

### [8.1] Pull the invariant algorithm skeleton into a final template method

Title: Capture the fixed sequence of steps once in a method that subclasses don't override.
Description: Coffee and Tea are made by nearly the same recipe: boil water, brew/steep, pour, add condiments. The **Template Method** defines that *skeleton of an algorithm* in one method in the superclass, calling step methods in a fixed order. Making the template method `final` protects the algorithm's structure so subclasses can vary steps but not the sequence. This removes duplicated control flow across subclasses.

**Good example:**

```java
public abstract class CaffeineBeverage {
    public final void prepareRecipe() {   // the template method — the fixed skeleton
        boilWater();
        brew();                            // varies
        pourInCup();
        addCondiments();                   // varies
    }
    private void boilWater()  { System.out.println("Boiling water"); }   // invariant, shared
    private void pourInCup()  { System.out.println("Pouring into cup"); }
    protected abstract void brew();
    protected abstract void addCondiments();
}
```

**Bad example:**

```java
// Two classes duplicate the same control flow; the shared steps and the ordering
// are copy-pasted, so a fix to "boil water" must be made in both (and stays in sync by luck).
public class Coffee {
    public void prepareRecipe() { boilWater(); brewCoffeeGrinds(); pourInCup(); addSugarAndMilk(); }
    void boilWater() { /* duplicated */ } void pourInCup() { /* duplicated */ }
}
public class Tea {
    public void prepareRecipe() { boilWater(); steepTeaBag(); pourInCup(); addLemon(); }
    void boilWater() { /* duplicated */ } void pourInCup() { /* duplicated */ }
}
```

### [8.2] Defer the varying steps to subclasses via abstract operations

Title: Express each varying step as an abstract method the subclass must implement.
Description: The steps that differ between Coffee and Tea (`brew`, `addCondiments`) are declared **abstract** in the superclass and implemented by each subclass. The template method calls them polymorphically. This is the division of labor at the heart of the pattern: the superclass owns *when* steps run (and the invariant ones), the subclass owns *how* the variable steps work.

**Good example:**

```java
public class Tea extends CaffeineBeverage {
    protected void brew()          { System.out.println("Steeping the tea"); }
    protected void addCondiments() { System.out.println("Adding lemon"); }
}
public class Coffee extends CaffeineBeverage {
    protected void brew()          { System.out.println("Dripping coffee through filter"); }
    protected void addCondiments() { System.out.println("Adding sugar and milk"); }
}
```

**Bad example:**

```java
// Subclass overrides the whole template instead of just the varying steps —
// duplicating and risking divergence from the canonical algorithm structure.
public class Tea extends CaffeineBeverage {
    @Override public void prepareRecipe() {       // re-implements the entire recipe
        boilWater(); steep(); pourInCup(); addLemon();   // order can silently drift from the parent
    }
}
```

### [8.3] Offer hooks for optional steps

Title: Provide hook methods with default (often empty) bodies that subclasses may override to influence the algorithm.
Description: A **hook** is a method declared in the superclass with a default or empty implementation; subclasses *may* override it but don't have to. Hooks let subclasses optionally extend the algorithm or conditionally enable a step — e.g. `customerWantsCondiments()` returning `true` by default, which a subclass can override to ask the user. Use abstract methods when a subclass *must* supply a step; use hooks when the step is optional.

**Good example:**

```java
public abstract class CaffeineBeverageWithHook {
    public final void prepareRecipe() {
        boilWater();
        brew();
        pourInCup();
        if (customerWantsCondiments()) {   // hook controls an optional step
            addCondiments();
        }
    }
    protected boolean customerWantsCondiments() { return true; } // hook: default, overridable
    protected abstract void brew();
    protected abstract void addCondiments();
    private void boilWater() {} private void pourInCup() {}
}
public class CoffeeWithHook extends CaffeineBeverageWithHook {
    protected void brew() { /* ... */ } protected void addCondiments() { /* ... */ }
    @Override protected boolean customerWantsCondiments() { return askYesNo("Milk and sugar?"); }
}
```

**Bad example:**

```java
// Forcing every subclass to implement a step it doesn't care about (abstract where a
// hook belonged), so subclasses are littered with empty/boilerplate overrides.
protected abstract boolean customerWantsCondiments();   // should have been a hook
public class TeaNoChoice extends CaffeineBeverage {
    protected boolean customerWantsCondiments() { return true; } // meaningless required boilerplate
}
```

### [8.4] The Hollywood Principle: don't call us, we'll call you

Title: *Don't call us, we'll call you* — let the high-level template invoke the low-level steps, not the reverse.
Description: The Hollywood Principle prevents "dependency rot": low-level components (subclass steps) should not call into high-level components. With Template Method, a subclass never calls the superclass to run the algorithm — the superclass's template method **calls down** into the subclass's step methods when appropriate. Subclasses plug in steps but don't control the flow, which keeps dependencies pointing in one direction.

**Good example:**

```java
// High-level CaffeineBeverage calls the low-level subclass steps. The subclass
// provides brew()/addCondiments() and is "called", it never "calls up".
CaffeineBeverage tea = new Tea();
tea.prepareRecipe();   // the superclass orchestrates; Tea's steps are invoked by it
```

**Bad example:**

```java
// Low-level subclass reaches back up to drive the algorithm — circular, fragile
// dependencies where the parent and child each call into the other.
public class Tea extends CaffeineBeverage {
    public void make() {
        super.boilWater();          // child calling up to orchestrate
        steep();
        super.pourInCup();          // child deciding the high-level flow
        addLemon();
    }
}
```

### [8.5] The Template Method Pattern defined (Arrays.sort / Comparable)

Title: *The Template Method Pattern defines the skeleton of an algorithm in a method, deferring some steps to subclasses. Template Method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure.*
Description: The JDK is full of template methods. `Arrays.sort(...)` (and `Collections.sort`) own the sorting algorithm but call back to your `compareTo`/`Comparator.compare` for the one varying step — the comparison. `InputStream.read(byte[])` calls the abstract `read()`. `AbstractList`/`AbstractMap` implement most operations in terms of a few primitive ones you supply. Reach for Template Method when several algorithms share a structure but differ in specific steps.

**Good example:**

```java
// Arrays.sort is the template method; you supply the varying "compare" step.
record Duck(String name, int weight) {}
Duck[] ducks = { new Duck("Daffy", 8), new Duck("Dewey", 2), new Duck("Howard", 7) };
Arrays.sort(ducks, Comparator.comparingInt(Duck::weight));   // sort algorithm fixed; compare varies
```

**Bad example:**

```java
// Re-implementing a full bubble sort just to customize comparison — duplicating the
// algorithm Template Method already provides in the library.
for (int i = 0; i < ducks.length; i++)
    for (int j = 0; j < ducks.length - 1; j++)
        if (ducks[j].weight() > ducks[j+1].weight()) { /* manual swap */ }
```

---

## Chapter 9 — Well-managed Collections: the Iterator and Composite Patterns

### [9.1] Iterator: traverse an aggregate without exposing its representation

Title: Provide a uniform way to step through a collection's elements without revealing whether it's an array, list, or map.
Description: Two menus, one backed by an `ArrayList` and one by an array, force client code to know each internal structure and loop differently. The **Iterator Pattern** gives each aggregate a `createIterator()` that returns an object with `hasNext()`/`next()`. The client iterates uniformly and never sees the underlying representation, so the menus can change their storage without breaking the client.

**Good example:**

```java
public interface Iterator<T> { boolean hasNext(); T next(); }

public class DinerMenu {
    private final MenuItem[] items;            // backed by an array
    private int count;
    public Iterator<MenuItem> createIterator() { return new DinerMenuIterator(items, count); }
}
public class DinerMenuIterator implements Iterator<MenuItem> {
    private final MenuItem[] items; private final int count; private int position = 0;
    public DinerMenuIterator(MenuItem[] items, int count) { this.items = items; this.count = count; }
    public boolean hasNext() { return position < count; }
    public MenuItem next()   { return items[position++]; }
}
// Client iterates uniformly, ignorant of array-vs-list:
public void printMenu(Iterator<MenuItem> it) { while (it.hasNext()) System.out.println(it.next().getName()); }
```

**Bad example:**

```java
// Client must know each menu's internal structure and write a different loop for each.
MenuItem[] dinerItems = dinerMenu.getItems();             // leaks the array
for (int i = 0; i < dinerItems.length; i++) print(dinerItems[i]);

List<MenuItem> pancakeItems = pancakeMenu.getMenuItems(); // leaks the list
for (int i = 0; i < pancakeItems.size(); i++) print(pancakeItems.get(i));
// add a third menu backed by a Map → add yet another loop everywhere
```

### [9.2] Single Responsibility Principle: one class, one reason to change

Title: *A class should have only one reason to change.*
Description: Iterator also upholds the Single Responsibility Principle. A collection's job is to *manage* its elements; *traversing* them is a separate responsibility. If the aggregate also implemented iteration, it would have two reasons to change (storage changes and traversal changes). Extracting traversal into an Iterator gives each class a single, cohesive responsibility. High **cohesion** — a class focused on one area — is the goal; a class doing too many unrelated things is a smell.

**Good example:**

```java
// Menu manages items; the Iterator handles traversal. Two responsibilities, two classes.
public class PancakeHouseMenu {
    private final List<MenuItem> items = new ArrayList<>();
    public void addItem(String name, double price) { items.add(new MenuItem(name, price)); } // manage
    public Iterator<MenuItem> createIterator() { return items.iterator(); }                  // delegate traversal
}
```

**Bad example:**

```java
// One class manages items AND owns traversal state AND formats output — three
// reasons to change tangled together (low cohesion).
public class Menu {
    private MenuItem[] items; private int cursor;          // storage + traversal state
    public void add(MenuItem i) { /* manage */ }
    public boolean hasNext() { return cursor < items.length; } // traversal
    public MenuItem next() { return items[cursor++]; }         // traversal
    public String render() { /* formatting */ return ""; }     // presentation
}
```

### [9.3] Implement java.util.Iterator / Iterable and use for-each

Title: Use the JDK's `Iterator`/`Iterable` so collections work with the enhanced for loop and the Collections framework.
Description: Java bakes Iterator into the language. Implement `java.util.Iterator` rather than rolling your own interface, and make aggregates implement `java.lang.Iterable` so they can be used directly in the **enhanced for loop** (`for (X x : aggregate)`) and with library utilities. `java.util.Collection` already provides `iterator()` for you — prefer the standard collections and their iterators over hand-built traversal.

**Good example:**

```java
public class Menu implements Iterable<MenuItem> {
    private final List<MenuItem> items = new ArrayList<>();
    public void add(MenuItem item) { items.add(item); }
    @Override public Iterator<MenuItem> iterator() { return items.iterator(); } // standard contract
}
// Works with for-each automatically:
Menu menu = new Menu();
for (MenuItem item : menu) {        // no explicit hasNext()/next()
    System.out.println(item.getName());
}
```

**Bad example:**

```java
// A custom, non-standard iterator interface that can't be used with for-each or any
// JDK API, and reinvents what java.util.Iterator already specifies.
public interface MyIterator { boolean more(); Object getNext(); }   // incompatible with the language
```

### [9.4] Composite: represent part-whole hierarchies as trees

Title: Compose objects into trees so a group of objects can be treated like a single object.
Description: Menus now contain menu items *and submenus* (a dessert submenu inside the diner menu) — an arbitrarily deep tree. The **Composite Pattern** lets you build *tree structures of part-whole hierarchies* and treat individual objects (leaves) and compositions (nodes) uniformly. Define one component supertype; both `MenuItem` (leaf) and `Menu` (composite) extend it, so clients work with the whole tree through one interface.

**Good example:**

```java
public abstract class MenuComponent {
    public void add(MenuComponent c)    { throw new UnsupportedOperationException(); }
    public void remove(MenuComponent c) { throw new UnsupportedOperationException(); }
    public String getName()  { throw new UnsupportedOperationException(); }
    public void print()      { throw new UnsupportedOperationException(); }
}
public class MenuItem extends MenuComponent {          // leaf
    private final String name; private final double price;
    public MenuItem(String name, double price) { this.name = name; this.price = price; }
    @Override public String getName() { return name; }
    @Override public void print() { System.out.println("  " + name + ", $" + price); }
}
public class Menu extends MenuComponent {              // composite
    private final List<MenuComponent> children = new ArrayList<>();
    private final String name;
    public Menu(String name) { this.name = name; }
    @Override public void add(MenuComponent c) { children.add(c); }
    @Override public void print() {                    // recurse over children uniformly
        System.out.println("\n" + name + "\n----------------------");
        for (MenuComponent c : children) c.print();    // a child may be a leaf OR a submenu
    }
}
```

**Bad example:**

```java
// Client must distinguish items from submenus everywhere and recurse by hand,
// duplicating tree-walking logic and breaking when nesting deepens.
void printMenu(Object node) {
    if (node instanceof MenuItem mi) System.out.println(mi.getName());
    else if (node instanceof Menu m) {
        for (Object child : m.getChildren()) printMenu(child);  // manual recursion + type checks everywhere
    }
}
```

### [9.5] Treat leaves and composites uniformly through one component type

Title: Give leaves and composites the same operations so clients never type-check the node.
Description: The power of Composite is **transparency**: because `MenuItem` and `Menu` share the `MenuComponent` interface, a client can call `print()` on any node without knowing if it's a leaf or a whole subtree. The book accepts a deliberate trade-off: putting child-management methods (`add`/`remove`) on the component means leaves inherit operations that don't apply, which they handle by throwing or no-op. This sacrifices a little safety for a lot of transparency — a conscious design choice.

**Good example:**

```java
// One call works on a single item or the entire menu tree — no instanceof needed.
MenuComponent allMenus = new Menu("ALL MENUS");
allMenus.add(dinerMenu);                 // a composite
allMenus.add(new MenuItem("Coffee", 1.99)); // a leaf
allMenus.print();                        // prints the whole tree uniformly
```

**Bad example:**

```java
// Separate APIs for leaf vs composite force the client to branch on type before
// every operation — the uniformity Composite provides is lost.
if (component.isComposite()) ((Menu) component).printAll();
else                         ((MenuItem) component).printOne();
```

### [9.6] The Iterator and Composite Patterns defined

Title: *The Iterator Pattern provides a way to access the elements of an aggregate object sequentially without exposing its underlying representation.* *The Composite Pattern allows you to compose objects into tree structures to represent part-whole hierarchies; Composite lets clients treat individual objects and compositions of objects uniformly.*
Description: They pair naturally: a Composite often supplies an Iterator (even a recursive one) to traverse the whole tree. Use Iterator whenever clients should walk a collection without depending on its internals; use Composite whenever data forms a part-whole tree (file systems, GUI component trees, org charts, menus) and you want clients to treat nodes and leaves the same way.

**Good example:**

```java
// A composite exposes an iterator that recursively walks the tree (CompositeIterator),
// so a client can traverse the entire structure with a single uniform loop.
public Iterator<MenuComponent> createIterator() {
    return new CompositeIterator(children.iterator());   // recurses into submenus
}
```

**Bad example:**

```java
// Exposing the internal child list and requiring the client to flatten/recurse the
// tree itself — couples the client to the structure and duplicates traversal.
List<MenuComponent> raw = menu.getChildren();   // leaks structure; client must recurse manually
```

---

## Chapter 10 — The State of Things: the State Pattern

### [10.1] Replace sprawling state conditionals with State objects

Title: Turn a pile of `if (state == ...)` checks into a set of state classes.
Description: A gumball machine has states (No Quarter, Has Quarter, Sold, Sold Out) and actions (insert quarter, eject quarter, turn crank, dispense). Implemented with integer state constants and conditionals in every method, the logic is fragile and not closed for modification — adding a "Winner" state means editing every method. The **State Pattern** puts each state's behavior in its own class, eliminating the giant conditionals.

**Good example:**

```java
public interface State {
    void insertQuarter();
    void ejectQuarter();
    void turnCrank();
    void dispense();
}
// Each state encapsulates the behavior for all actions while in that state.
public class NoQuarterState implements State {
    private final GumballMachine machine;
    public NoQuarterState(GumballMachine machine) { this.machine = machine; }
    public void insertQuarter() { System.out.println("You inserted a quarter");
                                   machine.setState(machine.getHasQuarterState()); } // transition
    public void ejectQuarter()  { System.out.println("You haven't inserted a quarter"); }
    public void turnCrank()     { System.out.println("You turned, but there's no quarter"); }
    public void dispense()      { System.out.println("You need to pay first"); }
}
```

**Bad example:**

```java
// State as ints + the same conditional structure copy-pasted into every action.
final int SOLD_OUT=0, NO_QUARTER=1, HAS_QUARTER=2, SOLD=3;
int state = SOLD_OUT;
public void insertQuarter() {
    if (state == HAS_QUARTER)   System.out.println("You can't insert another quarter");
    else if (state == NO_QUARTER) { state = HAS_QUARTER; System.out.println("You inserted a quarter"); }
    else if (state == SOLD_OUT)  System.out.println("Sold out");
    else if (state == SOLD)      System.out.println("Please wait");
}
public void turnCrank() { /* the same 4-way if-else, again */ }   // duplicated in every method
```

### [10.2] Encapsulate each state's behavior and delegate to the current state

Title: Have the context hold a current `State` and delegate every action to it.
Description: The context (the `GumballMachine`) holds a reference to the **current state object** and delegates each action to it: `insertQuarter()` simply calls `state.insertQuarter()`. The behavior changes automatically as the current state changes — the machine "appears to change its class." Each state is closed for modification; new states are new classes.

**Good example:**

```java
public class GumballMachine {
    private final State soldOutState, noQuarterState, hasQuarterState, soldState;
    private State state;       // the current state object
    private int count;
    public GumballMachine(int count) {
        soldOutState   = new SoldOutState(this);
        noQuarterState = new NoQuarterState(this);
        hasQuarterState= new HasQuarterState(this);
        soldState      = new SoldState(this);
        this.count = count;
        state = count > 0 ? noQuarterState : soldOutState;
    }
    public void insertQuarter() { state.insertQuarter(); }   // delegate to current state
    public void ejectQuarter()  { state.ejectQuarter(); }
    public void turnCrank()     { state.turnCrank(); state.dispense(); }
    public void setState(State s) { this.state = s; }
    public State getNoQuarterState() { return noQuarterState; }
    public State getHasQuarterState(){ return hasQuarterState; }
    /* getters for the other states... */
}
```

**Bad example:**

```java
// Context keeps doing the branching itself instead of delegating — the State classes
// exist but the conditional logic was never actually removed.
public void insertQuarter() {
    if (state instanceof NoQuarterState)   { /* logic here */ }
    else if (state instanceof HasQuarterState) { /* logic here */ }   // still type-switching
}
```

### [10.3] Localize transitions so adding a state doesn't ripple everywhere

Title: Let each state decide its own transitions, so new states are isolated additions.
Description: In the State Pattern, the logic for "what happens next" lives inside the state classes. Each state knows which state to transition to in response to an action and tells the context via `setState(...)`. To add a "Winner" state (10% chance of two gumballs), you write one new class and adjust the few states that can transition into it — you don't touch every method of the context. (Where transitions live — context vs states — is a design choice; putting them in states keeps the context simple but couples states to each other.)

**Good example:**

```java
public class HasQuarterState implements State {
    private final Random random = new Random();
    private final GumballMachine machine;
    public HasQuarterState(GumballMachine machine) { this.machine = machine; }
    public void turnCrank() {
        int winner = random.nextInt(10);
        if (winner == 0 && machine.getCount() > 1) machine.setState(machine.getWinnerState()); // new transition
        else                                       machine.setState(machine.getSoldState());
    }
    /* other actions... */
}
// Adding WinnerState = one new class + this small change, not edits across the whole machine.
```

**Bad example:**

```java
// Adding a "winner" outcome to the int-based version means touching turnCrank(),
// dispense(), and the state-constant list — a change that ripples across the class.
public void dispense() {
    if (state == SOLD) {
        releaseBall();
        if (/* winner */ true) { releaseBall(); }   // bolted onto the giant conditional
        // plus new constant WINNER, plus edits in turnCrank()...
    }
}
```

### [10.4] State vs. Strategy: same diagram, different intent

Title: Distinguish State (object changes its own behavior as internal state changes) from Strategy (client picks an algorithm).
Description: State and Strategy share an identical class diagram — a context delegating to an interface with interchangeable implementations — but their *intent* differs. With **Strategy**, the client typically configures the context with a chosen algorithm and it stays put. With **State**, the set of behaviors is fixed by the pattern, transitions happen internally as a function of the context's state, and the context (or states) change which implementation is active over its lifetime. Choose based on intent: selecting an algorithm (Strategy) vs. modeling a state machine (State).

**Good example:**

```java
// State: the active behavior changes over time as a consequence of internal events.
machine.insertQuarter();   // → HasQuarterState
machine.turnCrank();       // → SoldState → dispenses → back to NoQuarterState (or SoldOut)
// The client never chooses the state; the machine evolves through them.
```

**Bad example:**

```java
// Treating a true state machine as a Strategy the client must drive — the client is
// forced to know and set the next state, leaking the state logic out of the object.
machine.setBehavior(new HasQuarterBehavior());  // client manually sequencing states = wrong intent
machine.act();
machine.setBehavior(new SoldBehavior());        // the machine should manage this itself
```

### [10.5] The State Pattern defined

Title: *The State Pattern allows an object to alter its behavior when its internal state changes. The object will appear to change its class.*
Description: Reach for State when an object's behavior depends on its state and it must change behavior at runtime as that state changes — and especially when you're tempted to write large multi-branch conditionals on a state field in many methods. The number of classes grows (one per state), but each is small, cohesive, and closed for modification, and the overall logic is far easier to follow and extend than a sprawling state machine in conditionals.

**Good example:**

```java
// An order whose allowed operations depend on its state, modeled with State objects.
interface OrderState { void ship(OrderContext ctx); void cancel(OrderContext ctx); }
class PaidState implements OrderState {
    public void ship(OrderContext ctx)   { ctx.setState(new ShippedState()); }
    public void cancel(OrderContext ctx) { ctx.setState(new CancelledState()); }
}
class ShippedState implements OrderState {
    public void ship(OrderContext ctx)   { System.out.println("Already shipped"); }
    public void cancel(OrderContext ctx) { System.out.println("Too late to cancel"); }
}
```

**Bad example:**

```java
// Behavior gated by status strings checked in every method — the classic smell State removes.
class Order {
    String status; // "NEW","PAID","SHIPPED","CANCELLED"
    void ship()   { if (status.equals("PAID")) status = "SHIPPED"; else throw new IllegalStateException(); }
    void cancel() { if (status.equals("PAID") || status.equals("NEW")) status = "CANCELLED"; else /* ... */ ; }
    // every new status edits every method
}
```

---

## Chapter 11 — Controlling Object Access: the Proxy Pattern

### [11.1] Remote Proxy: a local stand-in for an object in another address space

Title: Give the client a local proxy that forwards calls to a remote object.
Description: A **Remote Proxy** is a local representative for an object living in a different JVM/machine. The client calls methods on the proxy as if it were the real object; the proxy handles the network communication (marshalling arguments, sending the request, returning the result). The Gumball monitor talks to a local proxy that forwards to the real machine over the network (the book uses Java RMI, where the stub is the proxy and the skeleton is the server-side helper).

**Good example:**

```java
// Remote interface — the contract shared by proxy (stub) and real subject.
public interface GumballMachineRemote extends Remote {
    int getCount()    throws RemoteException;
    String getLocation() throws RemoteException;
    State getState()  throws RemoteException;
}
// Client uses a local proxy obtained from the registry; calls look local.
GumballMachineRemote machine =
    (GumballMachineRemote) Naming.lookup("rmi://santafe.mightygumball.com/gumballmachine");
System.out.println(machine.getLocation() + ": " + machine.getCount() + " gumballs"); // forwarded over the network
```

**Bad example:**

```java
// Client hand-codes the network protocol everywhere it needs the remote object —
// no transparency, networking concerns leak into business code.
Socket socket = new Socket(host, port);
out.writeUTF("getCount");
int count = in.readInt();        // manual marshalling at every call site
```

### [11.2] Virtual Proxy: defer the cost of an expensive object until it's needed

Title: Stand in for an expensive-to-create object and create the real one lazily.
Description: A **Virtual Proxy** acts as a placeholder for an object that is costly to create. It defers the object's creation until it's actually needed, and can provide interim behavior in the meantime (e.g. display "Loading..." while an album cover downloads on a background thread). Once ready, the proxy delegates to the real object. The client is unaware it isn't talking to the real subject the whole time.

**Good example:**

```java
public class ImageProxy implements Icon {
    private volatile ImageIcon imageIcon;        // the real, expensive subject (lazily loaded)
    private final URL imageURL;
    public ImageProxy(URL url) { this.imageURL = url; }
    public int getIconWidth()  { return imageIcon != null ? imageIcon.getIconWidth()  : 800; }
    public int getIconHeight() { return imageIcon != null ? imageIcon.getIconHeight() : 600; }
    public void paintIcon(Component c, Graphics g, int x, int y) {
        if (imageIcon != null) {
            imageIcon.paintIcon(c, g, x, y);     // delegate once loaded
        } else {
            g.drawString("Loading album cover, please wait...", x + 300, y + 190);
            loadInBackground(c);                 // create the real object lazily, off the UI thread
        }
    }
}
```

**Bad example:**

```java
// Eagerly load every full-resolution image up front, freezing the UI and wasting
// memory on objects that may never be viewed.
for (URL url : allAlbumCovers) {
    ImageIcon icon = new ImageIcon(url);   // blocking network/disk load for each, immediately
    panel.add(new JLabel(icon));
}
```

### [11.3] Protection Proxy via a dynamic proxy (java.lang.reflect.Proxy)

Title: Control which methods a caller may invoke by routing calls through an access-checking proxy.
Description: A **Protection Proxy** controls access to a subject based on the caller's rights. Java's built-in **dynamic proxy** (`java.lang.reflect.Proxy` + `InvocationHandler`) creates the proxy class at runtime: you supply an `InvocationHandler` that intercepts every method call and decides whether to forward it. The dating-service example uses two handlers — one lets a person set their own data but not their "hot or not" rating; the other lets others rate but not edit.

**Good example:**

```java
public class OwnerInvocationHandler implements InvocationHandler {
    private final PersonBean person;
    public OwnerInvocationHandler(PersonBean person) { this.person = person; }
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        if (method.getName().startsWith("get"))      return method.invoke(person, args);
        if (method.getName().equals("setHotOrNotRating"))
            throw new IllegalAccessException();      // owner may NOT rate themselves
        if (method.getName().startsWith("set"))      return method.invoke(person, args);
        return null;
    }
}
PersonBean ownerProxy = (PersonBean) Proxy.newProxyInstance(
    person.getClass().getClassLoader(),
    person.getClass().getInterfaces(),
    new OwnerInvocationHandler(person));   // runtime-generated protection proxy
```

**Bad example:**

```java
// Access checks copied into every method of the real subject — mixes authorization
// with domain logic and must be edited whenever the rules change.
public void setHotOrNotRating(int rating) {
    if (currentUser.equals(this.owner)) throw new IllegalAccessException(); // check duplicated everywhere
    this.rating = rating;
}
```

### [11.4] The Proxy Pattern defined (and its variants)

Title: *The Proxy Pattern provides a surrogate or placeholder for another object to control access to it.*
Description: All proxies share the structure: the proxy implements the **same interface** as the real subject and holds a reference to it, so clients can't tell them apart, and the proxy controls access — creating, securing, or reaching the subject. Variants include Remote, Virtual, and Protection proxies, plus others the book mentions (caching, firewall, smart reference, copy-on-write). Proxy differs from Decorator (which *adds behavior*) and Adapter (which *changes the interface*): Proxy *controls access* while presenting the same interface.

**Good example:**

```java
// A caching proxy: same interface, controls access by serving cached results.
public class CachingQuoteService implements QuoteService {
    private final QuoteService delegate;                       // the real subject
    private final Map<String, Quote> cache = new ConcurrentHashMap<>();
    public CachingQuoteService(QuoteService delegate) { this.delegate = delegate; }
    public Quote getQuote(String symbol) {
        return cache.computeIfAbsent(symbol, delegate::getQuote); // control access via cache
    }
}
```

**Bad example:**

```java
// A "proxy" that exposes a different interface (that's an Adapter) or adds new
// responsibilities (that's a Decorator) — misnaming muddies the intent.
public class QuoteProxy {
    private final QuoteService real;
    public QuoteProxy(QuoteService real) { this.real = real; }
    public String getFormattedQuoteHtml(String symbol) {  // different interface + extra behavior
        return "<b>" + real.getQuote(symbol).price() + "</b>";   // not a proxy at all
    }
}
```

---

## Chapter 12 — Patterns of Patterns: Compound Patterns

### [12.1] Combine patterns to solve a family of problems (the Duck Simulator)

Title: Let several patterns collaborate; a compound pattern is patterns working together.
Description: A **compound pattern** combines two or more patterns into a solution that solves a recurring problem. The Duck Simulator stacks many: a `Quackable` interface (Strategy-like behavior), an `Adapter` so a `Goose` can be a `Quackable`, a `Decorator` (`QuackCounter`) to count quacks, an `Abstract Factory` to ensure every duck is created wrapped in a counter, a `Composite` (`Flock`) to treat groups of ducks as one, and `Observer` so a `Quackologist` is notified whenever any duck quacks. Each pattern keeps its own intent; together they form a flexible whole.

**Good example:**

```java
public interface Quackable extends QuackObservable { void quack(); }

// Adapter: a Goose becomes a Quackable.
public class GooseAdapter implements Quackable {
    private final Goose goose; private final Observable observable;
    public GooseAdapter(Goose goose) { this.goose = goose; this.observable = new Observable(this); }
    public void quack() { goose.honk(); observable.notifyObservers(); }
    public void registerObserver(Observer o) { observable.registerObserver(o); }
    public void notifyObservers() { observable.notifyObservers(); }
}
// Decorator: count quacks without changing the ducks.
public class QuackCounter implements Quackable {
    private final Quackable duck; private static int numberOfQuacks;
    public QuackCounter(Quackable duck) { this.duck = duck; }
    public void quack() { duck.quack(); numberOfQuacks++; }
    public static int getQuacks() { return numberOfQuacks; }
    /* observer delegation... */
}
// Composite: a flock is itself a Quackable made of Quackables.
public class Flock implements Quackable {
    private final List<Quackable> quackers = new ArrayList<>();
    public void add(Quackable q) { quackers.add(q); }
    public void quack() { for (Quackable q : quackers) q.quack(); }   // treat group as one
    /* observer delegation... */
}
```

**Bad example:**

```java
// One monolithic Duck class that hardcodes counting, grouping, goose-handling, and
// notification with flags and conditionals — none of it reusable or independently testable.
public class MegaDuck {
    boolean isGoose, countQuacks, notify; List<MegaDuck> flock;
    void quack() {
        if (isGoose) honk(); else realQuack();
        if (countQuacks) total++;
        if (notify) tellObservers();
        if (flock != null) for (MegaDuck d : flock) d.quack();   // everything tangled in one method
    }
}
```

### [12.2] Model-View-Controller is a compound of Observer + Strategy + Composite

Title: Recognize MVC as collaborating patterns, not a monolith.
Description: MVC is the most famous compound pattern. The **Model** holds data and state and uses **Observer** to keep views and controllers notified of changes without coupling to them. The **View** presents the model and is typically a **Composite** of nested UI components. The **Controller** is the view's **Strategy** — an interchangeable object that defines how the view responds to user input. Understanding MVC as Observer + Strategy + Composite makes it far easier to reason about and adapt.

**Good example:**

```java
// Model is the Subject (Observer); it never references concrete views.
public interface BeatModelInterface {
    void registerObserver(BeatObserver o);     // Observer
    void setBPM(int bpm);
    int  getBPM();
}
// Controller is the View's Strategy — swap it to change input handling.
public interface ControllerInterface {         // Strategy
    void increaseBPM();
    void decreaseBPM();
    void setBPM(int bpm);
}
public class DJView implements BeatObserver, BPMObserver {
    private final ControllerInterface controller;     // the strategy
    private final BeatModelInterface model;            // the subject it observes
    public DJView(ControllerInterface c, BeatModelInterface m) { controller = c; model = m; m.registerObserver(this); }
    public void updateBPM() { /* re-render when the model notifies us */ }
}
```

**Bad example:**

```java
// "MVC" where the view reads the database, computes business rules, and handles input
// directly — no Observer, no Strategy, no separation; just a class labeled "View".
public class OrderView extends JPanel {
    void onSubmit() {
        var rows = jdbc.query("SELECT ...");     // model logic in the view
        if (total > creditLimit) showError();    // business rule in the view
        jdbc.update("INSERT ...");               // persistence in the view
        repaint();
    }
}
```

### [12.3] Adapt MVC to a new context with the patterns it is built from

Title: Reuse a model with a new view/controller by leaning on Observer and Strategy.
Description: Because MVC is built from patterns, you can adapt it. The book reuses the `BeatModel` with an entirely different "heartbeat" view by writing an **Adapter** that makes a `HeartModel` look like a `BeatModel`, then attaching a new view and controller. Observer lets the new view subscribe to the model; Strategy lets you give it a different controller. The compound structure is what makes this reuse cheap.

**Good example:**

```java
// Adapter lets a HeartModel drive the existing BPM view unchanged.
public class HeartAdapter implements BeatModelInterface {
    private final HeartModelInterface heart;
    public HeartAdapter(HeartModelInterface heart) { this.heart = heart; }
    public int  getBPM() { return heart.getHeartRate(); }   // convert heart rate → "BPM"
    public void setBPM(int bpm) { /* no-op: can't set a heartbeat */ }
    public void registerObserver(BeatObserver o) { /* delegate to heart's observers */ }
}
// Existing DJView + a new HeartController now visualize a heart rate with no view changes.
```

**Bad example:**

```java
// Copy-paste the entire view and controller to retarget a new model, duplicating UI
// and input logic instead of adapting through the patterns MVC already provides.
public class HeartView extends JPanel { /* duplicated DJView code, lightly edited */ }
public class HeartController { /* duplicated BeatController code */ }
```

### [12.4] A compound pattern is collaborating patterns, not one super-pattern

Title: Don't confuse a compound pattern with a single mega-pattern; keep each pattern's identity.
Description: A compound pattern is a *set of patterns used together to solve a recurring problem* — it is not a brand-new pattern that absorbs the others. Each constituent pattern still carries its own intent and can be reasoned about independently. Treat MVC and similar combinations as named collaborations; understanding the parts is what lets you apply, debug, and adapt the whole.

**Good example:**

```java
// Each pattern is identifiable and independently testable within the compound.
class Model     { /* Observer subject — tested as an observable */ }
class View      { /* Composite of widgets + Observer of the model — tested for rendering */ }
class Controller{ /* Strategy for the view — tested for input handling */ }
```

**Bad example:**

```java
// Collapsing the collaboration into one class labeled "MVC" loses every pattern's
// boundary, so nothing can be reused, swapped, or tested in isolation.
class MvcEverything { /* model + view + controller fused; no seams */ }
```

---

## Chapter 13 — Patterns in the Real World: Better Living with Patterns

### [13.1] Use the precise definition of a Design Pattern

Title: A pattern is a named solution to a recurring problem in a context.
Description: The book adopts the classic definition: *a pattern is a solution to a problem in a context.* The **context** is the recurring situation, the **problem** is the goal (and its constraints/forces) in that context, and the **solution** is a general design that resolves the forces. Naming patterns gives you a shared vocabulary and lets you communicate designs at a higher level. Don't reduce a pattern to its class diagram — the intent and the forces it balances are what matter.

**Good example:**

```text
Context : objects must be notified of another object's state changes, but you don't
          want them tightly coupled.
Problem : keep a dynamic set of dependents up to date without the subject knowing
          their concrete types.
Solution: the Observer Pattern — Subject/Observer interfaces, register/notify.
// Stating context + problem + solution makes the pattern choice justifiable and communicable.
```

**Bad example:**

```text
"We used the Observer Pattern because it has a Subject and Observer interface."
// Cargo-culting the structure without the problem/context — the diagram copied,
// the reason missing. This leads to patterns applied where they don't belong.
```

### [13.2] Organize patterns into Creational, Structural, and Behavioral categories

Title: Classify patterns by purpose to find and discuss them.
Description: The Gang of Four classify patterns by purpose. **Creational** patterns concern object instantiation (Singleton, Factory Method, Abstract Factory, Builder, Prototype). **Structural** patterns compose classes/objects into larger structures (Decorator, Adapter, Facade, Composite, Proxy, Bridge, Flyweight). **Behavioral** patterns concern how objects interact and distribute responsibility (Strategy, Observer, Command, Template Method, Iterator, State, Chain of Responsibility, Mediator, Memento, Visitor, Interpreter). (Patterns can also be classified as class vs object patterns.) Categories help you locate a candidate pattern and reason about alternatives.

**Good example:**

```text
Need to create objects flexibly?      → look in Creational (Factory Method, Abstract Factory, Builder)
Need to compose/wrap structures?      → look in Structural  (Decorator, Composite, Proxy, Adapter, Facade)
Need to manage algorithms/interaction?→ look in Behavioral  (Strategy, State, Observer, Command, Template Method)
```

**Bad example:**

```text
Reaching for the first pattern you remember regardless of its category or intent,
e.g. "make it a Singleton" for a problem that is really about creating a family of
products (Abstract Factory) — wrong category, wrong tool.
```

### [13.3] Don't force a pattern — the simplest solution that works wins

Title: Apply a pattern only when it earns its complexity; otherwise keep it simple.
Description: Patterns introduce indirection and abstraction, which cost complexity. Use a pattern only when you have a real, recurring problem that the pattern's flexibility addresses — not because patterns are "good practice." Premature or speculative pattern use ("**Pattern Fever**") makes code harder to read for no benefit. *You don't need a pattern until you do.* Refactor *to* patterns when the need emerges, and refactor *away* from them if requirements simplify.

**Good example:**

```java
// No strategy/factory needed yet — one obvious implementation, so just write it.
public int area(int width, int height) { return width * height; }
// Introduce a pattern later, if and when multiple area algorithms or shape families appear.
```

**Bad example:**

```java
// "Pattern fever": an AbstractAreaCalculatorFactoryStrategyProvider for a single,
// never-varying calculation — all ceremony, no benefit, harder to read.
AreaStrategyFactory factory = AreaStrategyFactory.getInstance();
AreaStrategy strategy = factory.createStrategy("rectangle");
int area = strategy.calculate(new RectangleParams(width, height));
```

### [13.4] Recognize and avoid anti-patterns

Title: Document bad solutions that look attractive, and the better alternative.
Description: An **anti-pattern** describes a commonly recurring *bad* solution to a problem, plus why it's tempting, why it's bad, and what to do instead. Naming anti-patterns ("Golden Hammer" — using one favorite tool for everything; "God Object"; speculative generality) helps teams recognize and avoid them. Just as patterns share good solutions, anti-patterns share cautionary ones.

**Good example:**

```text
Anti-pattern: "Golden Hammer" — forcing every problem into your favorite technology/pattern.
Why tempting: deep familiarity with one tool.
Why bad     : poor fit, accidental complexity, missed simpler solutions.
Better       : choose the tool/pattern that fits the problem's context and forces.
```

**Bad example:**

```java
// God Object anti-pattern: one class that knows and does everything, so every change
// touches it and nothing can be reused or tested in isolation.
class ApplicationManager {
    void parseInput() {} void validate() {} void computeTax() {} void render() {}
    void persist() {}    void sendEmail() {} void schedule() {} void authorize() {}
    // 5,000 lines, the center of every dependency
}
```

### [13.5] Build and use a shared pattern vocabulary

Title: Talk in patterns so designs are communicated and shared concisely.
Description: The biggest day-to-day payoff of patterns is a **shared vocabulary**. Saying "let's make the report renderer a Decorator over the base renderer" conveys structure, intent, and trade-offs in one phrase the whole team understands. Patterns also keep design discussions at a higher level and embed best practices. Use the names — in design talks, code reviews, comments, and documentation — but always tie the name back to the problem it solves (13.1).

**Good example:**

```java
/**
 * GzipResponseWriter is a Decorator over ResponseWriter: it adds gzip compression
 * while preserving the ResponseWriter interface, so it can wrap any writer.
 */
public class GzipResponseWriter implements ResponseWriter { /* ... */ }
// One sentence (and one pattern name) tells a reviewer exactly what this is and why.
```

**Bad example:**

```java
// Opaque naming and no shared vocabulary — a reviewer must reverse-engineer the design
// instead of recognizing a named pattern.
public class Writer2 implements ResponseWriter { /* what is this? a wrapper? a replacement? */ }
```

---

## Appendix — Leftover Patterns

These are the remaining Gang-of-Four patterns the book summarizes but doesn't cover in depth. Each entry gives the book's usage guidance and a faithful sketch.

### [A.1] Bridge

Title: *Use the Bridge Pattern to vary not only your implementations, but also your abstractions.*
Description: Bridge decouples an abstraction from its implementation so the two can vary independently, by composing the implementation rather than inheriting it. It avoids a class explosion when both the abstraction (e.g. a remote control for various TVs) and the implementation (the TV models) have multiple dimensions of variation.

**Good example:**

```java
// Abstraction holds a reference to an implementation interface — both sides vary freely.
public interface Device { void on(); void off(); void setChannel(int n); }   // implementor
public abstract class RemoteControl {                                        // abstraction
    protected final Device device;                                           // the "bridge"
    protected RemoteControl(Device device) { this.device = device; }
    public void togglePower() { /* ... */ }
}
public class AdvancedRemote extends RemoteControl {        // refined abstraction
    public AdvancedRemote(Device device) { super(device); }
    public void mute() { device.setChannel(0); }
}
class Tv  implements Device { /* ... */ }                  // concrete implementor
class Dvd implements Device { /* ... */ }
// 2 remotes × 2 devices = 4 combinations with 0 extra classes (vs 4 subclasses without Bridge).
```

**Bad example:**

```java
// Inheriting implementation into the abstraction forces one subclass per
// (abstraction × implementation) pair — the explosion Bridge prevents.
class BasicTvRemote extends RemoteControl {}
class AdvancedTvRemote extends RemoteControl {}
class BasicDvdRemote extends RemoteControl {}
class AdvancedDvdRemote extends RemoteControl {}   // grows multiplicatively
```

### [A.2] Builder

Title: *Use the Builder Pattern to encapsulate the construction of a product and allow it to be constructed in steps.*
Description: Builder separates the construction of a complex object from its representation, so the same construction process can create different representations. It's ideal when an object has many optional parts or requires a multi-step assembly, replacing telescoping constructors with readable, stepwise building.

**Good example:**

```java
public class VacationPlanner {
    private final List<String> hotels = new ArrayList<>();
    private final List<String> tickets = new ArrayList<>();
    public VacationPlanner addHotel(String name)  { hotels.add(name);  return this; } // step
    public VacationPlanner addTickets(String show) { tickets.add(show); return this; } // step
    public Vacation build() { return new Vacation(hotels, tickets); }                  // get product
}
Vacation v = new VacationPlanner()
        .addHotel("Grand Facadian")
        .addTickets("Patterns on Ice")
        .build();
```

**Bad example:**

```java
// Telescoping constructors: unreadable call sites and a combinatorial set of overloads
// for every optional-parameter combination.
Vacation v = new Vacation("Grand Facadian", null, "Patterns on Ice", null, 3, true, null);
// which arg is which? add an option → another constructor overload
```

### [A.3] Chain of Responsibility

Title: *Use the Chain of Responsibility Pattern when you want to give more than one object a chance to handle a request.*
Description: Chain of Responsibility passes a request along a chain of handlers; each handler either handles it or forwards it to the next. It decouples the sender from the receiver and lets you add or reorder handlers without changing the sender. Email spam filters and event handling pipelines are classic uses.

**Good example:**

```java
public abstract class Handler {
    protected Handler next;
    public Handler setNext(Handler next) { this.next = next; return next; }
    public void handle(Request r) {
        if (canHandle(r)) process(r);
        else if (next != null) next.handle(r);     // pass it on
    }
    protected abstract boolean canHandle(Request r);
    protected abstract void process(Request r);
}
// spamFilter.setNext(fanMail).setNext(complaints);   // build/reorder the chain freely
```

**Bad example:**

```java
// One method with a giant if/else deciding who handles what — sender coupled to every
// handler, and adding a handler edits this method.
void handle(Request r) {
    if (isSpam(r)) drop(r);
    else if (isFanMail(r)) forwardToCeo(r);
    else if (isComplaint(r)) forwardToSupport(r);   // grows without bound
}
```

### [A.4] Flyweight

Title: *Use the Flyweight Pattern when one instance of a class can be used to provide many "virtual instances."*
Description: Flyweight shares one instance to represent many fine-grained objects, separating **intrinsic** state (shared, stored in the flyweight) from **extrinsic** state (passed in by the client per use). It slashes memory when you'd otherwise create huge numbers of nearly identical objects — e.g. thousands of trees in a landscape sharing one `TreeType` while each position is passed in.

**Good example:**

```java
// Shared intrinsic state (the tree species); extrinsic state (x, y) supplied per call.
public final class TreeType {                       // flyweight — shared
    private final String name; private final String texture;
    public TreeType(String name, String texture) { this.name = name; this.texture = texture; }
    public void draw(Canvas c, int x, int y) { /* uses x,y (extrinsic) + texture (intrinsic) */ }
}
public class TreeFactory {                           // ensures sharing
    private final Map<String, TreeType> cache = new HashMap<>();
    public TreeType get(String name, String texture) {
        return cache.computeIfAbsent(name, n -> new TreeType(n, texture));   // reuse instances
    }
}
// 1,000,000 trees → a handful of TreeType objects + lightweight (x,y) per tree.
```

**Bad example:**

```java
// A full heavyweight object per tree — millions of near-identical instances blow the heap.
class Tree { String name; String texture; int x; int y; /* duplicated texture in every one */ }
List<Tree> forest = new ArrayList<>();
for (int i = 0; i < 1_000_000; i++) forest.add(new Tree("Oak", oakTexture, rndX(), rndY()));
```

### [A.5] Interpreter

Title: *Use the Interpreter Pattern to build an interpreter for a language.*
Description: Interpreter defines a class-based representation for a (usually simple) grammar along with an interpreter that uses the representation to evaluate sentences in the language. Each grammar rule becomes a class with an `interpret(context)` method. Use it for small, well-defined languages (query filters, rule expressions, calculators); for complex grammars, prefer a parser generator.

**Good example:**

```java
public interface Expression { boolean interpret(String context); }
public class TerminalExpression implements Expression {        // a grammar rule
    private final String word;
    public TerminalExpression(String word) { this.word = word; }
    public boolean interpret(String context) { return context.contains(word); }
}
public class OrExpression implements Expression {              // a composite rule
    private final Expression a, b;
    public OrExpression(Expression a, Expression b) { this.a = a; this.b = b; }
    public boolean interpret(String context) { return a.interpret(context) || b.interpret(context); }
}
Expression rule = new OrExpression(new TerminalExpression("java"), new TerminalExpression("kotlin"));
boolean matches = rule.interpret("I love java");   // true
```

**Bad example:**

```java
// Ad hoc string parsing scattered across the code with no grammar representation —
// impossible to compose or extend the language safely.
boolean matches(String input, String rule) {
    String[] words = rule.split(" OR ");
    for (String w : words) if (input.contains(w)) return true;  // breaks on AND, NOT, parentheses...
    return false;
}
```

### [A.6] Mediator

Title: *Use the Mediator Pattern to centralize complex communications and control between related objects.*
Description: Mediator introduces an object that encapsulates how a set of objects interact, so they no longer refer to each other directly. It turns a tangle of many-to-many object references into a hub-and-spoke design, reducing coupling and making interaction logic easy to change in one place (e.g. the controller coordinating widgets in a dialog, or smart-home devices coordinating through a hub).

**Good example:**

```java
public interface Mediator { void notify(Component sender, String event); }
public class DialogMediator implements Mediator {
    private CheckBox guestCheckbox; private TextField nameField;
    public void notify(Component sender, String event) {       // all interaction logic, centralized
        if (sender == guestCheckbox && event.equals("checked")) nameField.setEnabled(false);
    }
}
// Components talk to the mediator, never to each other.
public abstract class Component {
    protected final Mediator mediator;
    protected Component(Mediator m) { this.mediator = m; }
}
```

**Bad example:**

```java
// Every widget holds references to every other widget and updates them directly —
// an unmaintainable many-to-many web of dependencies.
class GuestCheckbox {
    NameField nameField; PhoneField phoneField; SubmitButton submit;   // knows everyone
    void onCheck() { nameField.disable(); phoneField.disable(); submit.enable(); }
}
```

### [A.7] Memento

Title: *Use the Memento Pattern when you need to be able to return an object to one of its previous states; for instance, if your user requests an "undo."*
Description: Memento captures and externalizes an object's internal state — without violating encapsulation — so the object can be restored to that state later. The *originator* creates a memento of its state; a *caretaker* stores mementos and hands one back to restore. It underpins undo/save-point features (e.g. saving a game's state).

**Good example:**

```java
public class GameState {                                   // originator
    private int level, score;
    public Memento save()             { return new Memento(level, score); }   // capture
    public void restore(Memento m)    { this.level = m.level; this.score = m.score; } // restore
    public static final class Memento {                    // opaque snapshot
        private final int level, score;
        private Memento(int level, int score) { this.level = level; this.score = score; }
    }
}
// Caretaker keeps snapshots without seeing inside them:
Deque<GameState.Memento> history = new ArrayDeque<>();
history.push(game.save());      // checkpoint
// later: game.restore(history.pop());   // undo
```

**Bad example:**

```java
// Exposing every field publicly and snapshotting them by hand — breaks encapsulation
// and the caretaker becomes coupled to the originator's internal structure.
class Game { public int level; public int score; public int[] inventory; }
int savedLevel = game.level; int savedScore = game.score;   // restore logic copied everywhere
```

### [A.8] Prototype

Title: *Use the Prototype Pattern when creating an instance of a given class is either expensive or complicated.*
Description: Prototype creates new objects by **copying an existing instance** (a prototype) rather than instantiating from scratch. It's useful when construction is costly (heavy initialization, database/network setup) or when the concrete type should be decided at runtime — you clone a configured exemplar instead of rebuilding it.

**Good example:**

```java
public interface Monster extends Cloneable { Monster cloneMonster(); }
public class Dragon implements Monster {
    private int hitPoints; private String[] loadout;          // expensive to set up
    public Dragon configure() { /* costly initialization */ return this; }
    public Monster cloneMonster() {
        Dragon copy = new Dragon();
        copy.hitPoints = this.hitPoints;
        copy.loadout   = this.loadout.clone();                // copy from the prototype
        return copy;
    }
}
Dragon prototype = new Dragon().configure();   // build once
Monster a = prototype.cloneMonster();          // cheap copies thereafter
Monster b = prototype.cloneMonster();
```

**Bad example:**

```java
// Re-running expensive construction for every instance when a clone of a prepared
// prototype would do — slow and repetitive.
for (int i = 0; i < 1000; i++) {
    Dragon d = new Dragon();
    d.loadFromDatabase();      // costly setup repeated 1000 times
    spawn(d);
}
```

### [A.9] Visitor

Title: *Use the Visitor Pattern when you want to add capabilities to a composite of objects and encapsulation is not important.*
Description: Visitor lets you add new operations to a hierarchy of element classes without modifying those classes, by moving the operation into a separate *visitor* object. Each element accepts a visitor and calls back the visit method for its type (double dispatch). It's ideal when the element hierarchy is stable but you frequently add new operations over it (e.g. computing nutrition or generating reports over a menu Composite); the trade-off is that adding a new element type forces changes to every visitor.

**Good example:**

```java
public interface Visitor {
    void visit(MenuItem item);
    void visit(Menu menu);
}
public interface Visitable { void accept(Visitor visitor); }
public class MenuItem implements Visitable {
    public void accept(Visitor visitor) { visitor.visit(this); }   // double dispatch
}
public class NutritionVisitor implements Visitor {                 // a new operation, added externally
    public void visit(MenuItem item) { /* sum calories */ }
    public void visit(Menu menu)     { /* recurse */ }
}
// Add a CostVisitor, AllergenVisitor, ... without touching MenuItem/Menu.
```

**Bad example:**

```java
// Adding each new operation by editing every element class — the element hierarchy
// bloats with unrelated responsibilities (nutrition, cost, allergens, export...).
class MenuItem {
    int calories() { /* ... */ }
    double cost()  { /* ... */ }
    String toHtml(){ /* ... */ }
    boolean hasAllergens() { /* ... */ }   // every new report edits this class
}
```
