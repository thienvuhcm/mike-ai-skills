# Refactoring.Guru — Refactoring, Code Smells & Techniques (supplement)

## Role

You are a Senior software engineer improving the design of existing code. This reference supplements the design-pattern material with refactoring.guru's **refactoring catalog**: what refactoring and clean code are, the **code smells** that signal trouble (5 groups), and the **refactoring techniques** that fix them (6 groups). Patterns are often the *destination* of a refactoring; smells are the *trigger*. Source: https://refactoring.guru/refactoring (Alexander Shvets / refactoring.guru), which mirrors Martin Fowler's *Refactoring* catalog.

## Goal

Head First teaches the patterns themselves; this file gives the practitioner the **why-and-when of changing code safely**:

- Recognize a **code smell**, then choose the **technique** (and sometimes the **pattern**) that removes it.
- Refactor in **small, verified steps** without changing observable behavior.
- Pay down **technical debt** deliberately rather than letting it compound.

Use it with `head-first-design-pattern-book.md` and `refactoring-guru-design-patterns.md`: several smells are resolved by introducing a pattern (e.g., *Switch Statements* → Strategy/State/Polymorphism; *Large Class* → Extract Class / Composite; *Conditional Complexity* → State/Strategy; *Middle Man* → Remove Middle Man vs. Proxy/Decorator intent).

## Concepts

### What is refactoring?

- **Refactoring** = a *controlled technique for improving the design of existing code* by applying small, behavior-preserving transformations. Its main purpose is to **fight technical debt**: it "transforms a mess into clean code and simple design."
- Refactoring is **not** rewriting from scratch and **not** adding features — it changes internal structure while keeping external behavior the same.

### Clean code (the target)

Clean code is:
- **Obvious to other programmers** — clear naming, no bloated classes, no magic numbers.
- **Free of duplication** — duplication raises cognitive load and the cost of change.
- **Minimal** — the fewest classes and moving parts that do the job (less code = less to maintain and break).
- **Passing all tests** — code with poor test coverage can't be trusted or safely refactored.
- **Easier and cheaper to maintain.**

### Technical debt (what refactoring repays)

Ward Cunningham's metaphor: shipping quick-and-dirty code is like taking a loan — it speeds you up now but you pay **interest** (slower future work) until you repay the **principal** (clean it up). Common causes:
- **Business pressure** (ship before it's clean), **lack of understanding of consequences** (debt's interest is invisible to management), **tightly-coupled / monolithic components**, **lack of tests** (encourages risky quick fixes), **missing documentation**, **poor communication**, **long-lived branches**, **delayed refactoring**, **no standards/compliance monitoring**, and **lack of skill**.

### When to refactor

- **Rule of Three:** first time, just do it; second time (similar), wince but repeat; **third time, refactor**.
- **When adding a feature** — clean the surrounding code first so the change is easier (and you leave it better for the next person).
- **When fixing a bug** — bugs hide in messy code; cleaning it tends to surface them.
- **During code review** — the last chance to tidy before the code ships; pair review helps.

### How to refactor (do it right)

- **The code is cleaner afterward.** If a refactoring didn't make the code cleaner, it wasn't worth it (often a sign you bundled too many changes).
- **No new functionality during refactoring.** Don't mix refactoring with feature work; keep them in separate commits.
- **All existing tests pass.** If tests break, either fix the refactoring or fix overly low-level tests.
- **Small incremental steps.** "Refactoring should be done as a series of small changes, each of which makes the existing code slightly better while still leaving the program in working order." Solid test coverage is the safety net.

---

## Code Smells

Smells are surface indications that usually correspond to deeper problems. Five groups. Each entry contains: **signs** (when to recognize it), **why to refactor** (verbatim from refactoring.guru), **treatments** (exact refactoring technique names), and **payoff**. Pattern destinations are noted where a pattern is the natural endpoint of the fix.

### Bloaters — *code, methods, and classes that have grown to unwieldy proportions*

#### Long Method
- **Signs:** A method contains too many lines; generally any method longer than ten lines should prompt questions.
- **Why:** Code continuously accumulates without removal, making methods difficult to understand and maintain.
- **Treatment:** Extract Method · Replace Temp with Query · Introduce Parameter Object · Preserve Whole Object · Replace Method with Method Object · Decompose Conditional
- **Payoff:** "Classes with short methods live longest." Shorter methods reduce duplication and enable genuine performance optimization.

#### Large Class
- **Signs:** A class has so many fields, methods, or lines that it's trying to do too much.
- **Why:** "Classes usually start small. But over time, they get bloated as the program grows." Developers add features to existing classes rather than creating new ones.
- **Treatment:** Extract Class · Extract Subclass · Extract Interface · Duplicate Observed Data
- **Payoff:** "Spares developers from needing to remember a large number of attributes for a class." Frequently prevents duplication. → *Pattern destinations: Composite, Strategy, Decorator can absorb extracted responsibilities.*

#### Primitive Obsession
- **Signs:** Primitives used instead of small objects for domain concepts (money, ranges, phone numbers); constants for type codes; string keys into data arrays.
- **Why:** "Creating a primitive field is so much easier than making a whole new class" — convenience leads to large, unwieldy classes and scattered operations.
- **Treatment:** Replace Data Value with Object · Introduce Parameter Object · Preserve Whole Object · Replace Type Code with Class · Replace Type Code with Subclasses · Replace Type Code with State/Strategy · Replace Array with Object
- **Payoff:** "Code becomes more flexible thanks to use of objects instead of primitives." Operations on data stay in one place; duplicate code becomes easier to spot.

#### Long Parameter List
- **Signs:** More than three or four parameters on a method.
- **Why:** "It's hard to understand such lists, which become contradictory and hard to use as they grow longer."
- **Treatment:** Replace Parameter with Method Call · Preserve Whole Object · Introduce Parameter Object
- **Payoff:** "More readable, shorter code." Refactoring may reveal previously unnoticed duplicate code.

#### Data Clumps
- **Signs:** The same group of variables (e.g., DB host/port/username) appears together in multiple places.
- **Why:** "Different parts of the code contain identical groups of variables." Usually results from poor structure or copied code.
- **Treatment:** Extract Class · Introduce Parameter Object · Preserve Whole Object
- **Payoff:** "Operations on particular data are now gathered in a single place" instead of scattered. Reduces overall code size.

### Object-Orientation Abusers — *incomplete or incorrect use of OO principles*

#### Switch Statements
- **Signs:** A complex `switch` operator or sequence of `if`s selects behavior based on a type or state value.
- **Why:** "Relatively rare use of `switch` and `case` operators is one of the hallmarks of object-oriented code." Switch logic often gets duplicated throughout the program.
- **Treatment:** Extract Method + Move Method · Replace Type Code with Subclasses · Replace Type Code with State/Strategy · Replace Conditional with Polymorphism · Replace Parameter with Explicit Methods · Introduce Null Object
- **Payoff:** "Improved code organization." → *Pattern destinations: Strategy, State, Command, Factory Method.*

#### Temporary Field
- **Signs:** Fields that have values (and meaning) only under certain circumstances; outside those cases they're empty.
- **Why:** Objects are expected to need all their fields. "This makes code difficult to understand."
- **Treatment:** Extract Class · Replace Method with Method Object · Introduce Null Object
- **Payoff:** "Better code clarity and organization."

#### Refused Bequest
- **Signs:** A subclass uses only some inherited methods and properties; the hierarchy is off-kilter.
- **Why:** Unneeded methods may go unused or throw; the hierarchy no longer reflects reality.
- **Treatment:** Replace Inheritance with Delegation · Extract Superclass
- **Payoff:** "Improves code clarity and organization. You will no longer have to wonder why the `Dog` class is inherited from the `Chair` class (even though they both have 4 legs)."

#### Alternative Classes with Different Interfaces
- **Signs:** Two classes perform identical functions but have different method names.
- **Why:** Programmers may be unaware that equivalent functionality already exists elsewhere, leading to inadvertent duplication.
- **Treatment:** Rename Method · Move Method · Add Parameter · Parameterize Method · Extract Superclass
- **Payoff:** "You get rid of unnecessary duplicated code, making the resulting code less bulky."

### Change Preventers — *one change forces many edits elsewhere*

#### Divergent Change
- **Signs:** Many unrelated methods must be changed when you make a single change to a class (multiple reasons to change — a Single Responsibility violation).
- **Why:** "Divergent Change is when many changes are made to a single class." Poor program structure forces modifications across unrelated methods.
- **Treatment:** Extract Class · Extract Superclass · Extract Subclass
- **Payoff:** "Improves code organization. Reduces code duplication. Simplifies support."

#### Shotgun Surgery
- **Signs:** Any single conceptual change forces small edits scattered across many different classes.
- **Why:** "A single responsibility has been split up among a large number of classes," requiring many small modifications for any change.
- **Treatment:** Move Method · Move Field · Inline Class
- **Payoff:** "Better organization," reduced code duplication, and "easier maintenance."

#### Parallel Inheritance Hierarchies
- **Signs:** Every time you create a subclass for a class, you must create a subclass for another class too.
- **Why:** "Whenever you create a subclass for a class, you find yourself needing to create a subclass for another class." As hierarchies expand, maintenance multiplies.
- **Treatment:** Move Method · Move Field (to collapse the duplicated hierarchy onto one)
- **Payoff:** "Reduces code duplication" and improves code organization.

### Dispensables — *pointless things whose absence makes code cleaner*

#### Comments
- **Signs:** A method is filled with explanatory comments compensating for opaque code.
- **Why:** "Comments are usually created with the best of intentions, when the author realizes that his or her code isn't intuitive or obvious." They mask structural problems.
- **Treatment:** Extract Variable · Extract Method · Rename Method · Introduce Assertion
- **Payoff:** "Code becomes more intuitive and obvious."

#### Duplicate Code
- **Signs:** Two or more code fragments look almost identical.
- **Why:** Programmers working in parallel create overlapping code; time pressure leads to copy-paste instead of proper reuse.
- **Treatment:** Extract Method · Pull Up Field · Pull Up Constructor Body · Form Template Method · Substitute Algorithm · Extract Superclass · Extract Class · Consolidate Conditional Expression · Consolidate Duplicate Conditional Fragments
- **Payoff:** "Merging duplicate code simplifies the structure of your code and makes it shorter. Simplification + shortness = code that's easier to simplify and cheaper to support." → *Pattern destination: Template Method (for subclasses with similar step-based algorithms).*

#### Lazy Class
- **Signs:** A class doesn't do enough to earn its maintenance cost.
- **Why:** "Understanding and maintaining classes always costs time and money. So if a class doesn't do enough to earn your attention, it should be deleted."
- **Treatment:** Inline Class · Collapse Hierarchy
- **Payoff:** "Reduced code size. Easier maintenance."

#### Data Class
- **Signs:** A class contains only fields plus getters/setters and no real behavior.
- **Why:** "These simple containers lack independent functionality," failing to leverage the power of OO design.
- **Treatment:** Encapsulate Field · Encapsulate Collection · Move Method · Extract Method · Remove Setting Method · Hide Method
- **Payoff:** "Operations on particular data are now gathered in a single place, instead of haphazardly throughout the code."

#### Dead Code
- **Signs:** A variable, parameter, field, method, or class is no longer used.
- **Why:** "When requirements for the software have changed or corrections have been made, nobody had time to clean up the old code."
- **Treatment:** Delete the unused element; Inline Class · Collapse Hierarchy · Remove Parameter as applicable
- **Payoff:** "Reduced code size. Simpler support."

#### Speculative Generality
- **Signs:** Unused classes, methods, fields, or parameters built "just in case" for anticipated future features that never arrived.
- **Why:** "Code is created 'just in case' to support anticipated future features," making code harder to understand and maintain.
- **Treatment:** Collapse Hierarchy · Inline Class · Inline Method · Remove Parameter · (delete unused fields)
- **Payoff:** "Slimmer code. Easier support."

### Couplers — *smells that cause excessive coupling between classes*

#### Feature Envy
- **Signs:** A method accesses the data of another object more than its own.
- **Why:** "Data and the functions that use that data should be kept together." This smell indicates a method that belongs elsewhere.
- **Treatment:** Move Method · Extract Method (then Move Method to put the fragment where the data lives)
- **Payoff:** "Less code duplication (if the data handling code is put in a central place). Better code organization (methods for handling data are next to the actual data)."

#### Inappropriate Intimacy
- **Signs:** One class uses the internal fields and methods of another class.
- **Why:** "Good classes should know as little about each other as possible. Such classes are easier to maintain and reuse."
- **Treatment:** Move Method · Move Field · Extract Class · Hide Delegate · Change Bidirectional Association to Unidirectional · Replace Delegation with Inheritance
- **Payoff:** "Improves code organization. Simplifies support and code reuse."

#### Message Chains
- **Signs:** A chain of calls like `a.getB().getC().doX()` — the client must navigate a deep object graph. (This is exactly what the Principle of Least Knowledge / Law of Demeter guards against.)
- **Why:** "A message chain occurs when a client requests another object, that object requests yet another one, and so on." Any change to the chain forces a change in the client.
- **Treatment:** Hide Delegate · Extract Method (then Move Method to bring the client closer to the data)
- **Payoff:** Reduces dependencies between classes in the chain; reduces bloat.

#### Middle Man
- **Signs:** A class performs only one action — delegating to another class.
- **Why:** Excessive message-chain removal or gradual migration of functionality elsewhere can leave an empty shell that serves no purpose.
- **Treatment:** Remove Middle Man (let clients call the real object directly) · Inline Method
- **Payoff:** "Less bulky code."
- **Important caveat:** Do *not* apply this when the delegation is intentional — a **Proxy** or **Decorator** delegates on purpose to control access or add behavior. Distinguish the smell from the pattern.

---

## Refactoring Techniques

Six groups. Each entry is **problem → solution**.

### Composing Methods — *streamline methods, remove duplication, clarify*

- **Extract Method** — a fragment can be grouped → move it into a well-named method and call it.
- **Inline Method** — the body is more obvious than the method → replace calls with the body and delete the method.
- **Extract Variable** — a hard-to-read expression → store its parts in self-explanatory variables.
- **Inline Temp** — a temp just holds a simple expression's result → replace the temp with the expression.
- **Replace Temp with Query** — a temp holds an expression's result for later use → move the expression into a method and call it.
- **Split Temporary Variable** — one temp stores several intermediate values → use a separate variable per value/purpose.
- **Remove Assignments to Parameters** — a parameter is reassigned in the body → use a local variable instead.
- **Replace Method with Method Object** — a long method's locals are too tangled to Extract Method → turn the method into its own class so locals become fields.
- **Substitute Algorithm** — you want a clearer/better algorithm → replace the method body with the new algorithm.

### Moving Features Between Objects — *put responsibilities where they belong*

- **Move Method** — a method is used more by another class → move it there and redirect (or delete) the original.
- **Move Field** — a field is used more by another class → move it and update references.
- **Extract Class** — one class does the work of two → split off a new class with the related fields/methods.
- **Inline Class** — a class does almost nothing → fold its features into another class.
- **Hide Delegate** — clients call `a.getB().doX()` → add a delegating method on A so clients don't know about B.
- **Remove Middle Man** — a class only delegates → let clients call the real object directly.
- **Introduce Foreign Method** — you need a method on a class you can't change → add it to a client class taking that object as an argument.
- **Introduce Local Extension** — you need several methods on an unmodifiable class → make a subclass or wrapper that adds them.

### Organizing Data — *make data handling safer and clearer*

- **Self Encapsulate Field** — access a field directly → use a getter/setter even internally.
- **Replace Data Value with Object** — a data field needs behavior/data of its own → promote it to a class.
- **Change Value to Reference** — many identical value objects → share one reference object.
- **Change Reference to Value** — an immutable, small shared object is awkward as a reference → make it a value object.
- **Replace Array with Object** — an array holds heterogeneous elements → use an object with named fields.
- **Duplicate Observed Data** — domain data lives in GUI code → separate it into a domain class and keep it in sync (Observer).
- **Change Unidirectional Association to Bidirectional** — a class now needs the reverse link → add the missing association.
- **Change Bidirectional Association to Unidirectional** — one direction is unused → remove it to cut coupling.
- **Replace Magic Number with Symbolic Constant** — an unexplained literal → name it with a constant.
- **Encapsulate Field** — a public field → make it private with accessors.
- **Encapsulate Collection** — a getter returns a mutable collection → return read-only and add add/remove methods.
- **Replace Type Code with Class** — a numeric/string type code → a class of typed instances.
- **Replace Type Code with Subclasses** — behavior varies by type code → subclasses + polymorphism.
- **Replace Type Code with State/Strategy** — the type code changes at runtime / can't subclass → a State or Strategy object.
- **Replace Subclass with Fields** — subclasses differ only in constant-returning methods → collapse into fields on the parent.

### Simplifying Conditional Expressions — *tame complex conditionals*

- **Decompose Conditional** — a complex `if/else`/`switch` → extract the condition and branches into named methods.
- **Consolidate Conditional Expression** — several checks lead to the same result → merge into one expression/method.
- **Consolidate Duplicate Conditional Fragments** — identical code in every branch → move it outside the conditional.
- **Remove Control Flag** — a boolean flag drives a loop → use `break`/`continue`/`return`.
- **Replace Nested Conditional with Guard Clauses** — deep nesting hides the normal path → return early for special cases.
- **Replace Conditional with Polymorphism** — a conditional chooses behavior by type → subclasses + overridden methods. → *Pattern destinations: Strategy, State.*
- **Introduce Null Object** — repeated null checks → return a Null Object with default (do-nothing) behavior.
- **Introduce Assertion** — an assumption is implicit → state it with an assertion.

### Simplifying Method Calls — *make interfaces easier and safer to use*

- **Rename Method** — the name doesn't reveal intent → rename it.
- **Add Parameter** — a method lacks needed data → add a parameter.
- **Remove Parameter** — a parameter is unused → remove it.
- **Separate Query from Modifier** — a method both returns data and changes state → split into a query and a modifier (command-query separation).
- **Parameterize Method** — several methods differ only by an internal value → merge into one with a parameter.
- **Replace Parameter with Explicit Methods** — a parameter selects which branch runs → split into separate methods.
- **Preserve Whole Object** — you pull several values from an object to pass them → pass the whole object.
- **Replace Parameter with Method Call** — a passed argument is derivable inside → call the query in the method.
- **Introduce Parameter Object** — a recurring group of parameters → wrap them in an object.
- **Remove Setting Method** — a field should be set only at creation → drop its setter.
- **Hide Method** — a method isn't used outside its class → make it private/protected.
- **Replace Constructor with Factory Method** — a constructor does more than set fields → use a factory method. → *Pattern destination: Factory Method.*
- **Replace Error Code with Exception** — a method returns a special error value → throw an exception.
- **Replace Exception with Test** — an exception guards a condition you could test → check the condition first.

### Dealing with Generalization — *move features up/down a hierarchy; trade inheritance and delegation*

- **Pull Up Field** — subclasses share a field → move it to the superclass.
- **Pull Up Method** — subclasses share an identical method → move it to the superclass.
- **Pull Up Constructor Body** — subclass constructors share code → call a superclass constructor with the shared part.
- **Push Down Method** — a superclass method is used by only some subclasses → move it down to them.
- **Push Down Field** — a field is used by only some subclasses → move it down.
- **Extract Subclass** — features used only in some cases → put them in a new subclass.
- **Extract Superclass** — two classes share fields/methods → create a common superclass.
- **Extract Interface** — clients use the same subset of a class → extract that subset into an interface.
- **Collapse Hierarchy** — a subclass is nearly identical to its superclass → merge them.
- **Form Template Method** — subclasses run similar steps in the same order → lift the structure into a superclass template method, keep the varying steps abstract. → *Pattern destination: Template Method.*
- **Replace Inheritance with Delegation** — a subclass uses only part of its superclass → compose and delegate instead (favor composition over inheritance).
- **Replace Delegation with Inheritance** — a class has many trivial methods delegating to all of another's → inherit instead.

---

## Smell → fix → pattern quick map

| Smell | Primary techniques | Pattern destination (if any) |
|---|---|---|
| Switch Statements | Replace Conditional with Polymorphism; Replace Type Code with Subclasses/State-Strategy | Strategy, State, Command, Factory Method |
| Large Class / Divergent Change | Extract Class / Subclass / Interface | (Composite / Strategy / Decorator) |
| Duplicate Code | Extract Method; Pull Up Method; Form Template Method | Template Method |
| Long Parameter List / Data Clumps | Introduce Parameter Object; Preserve Whole Object; Extract Class | — |
| Primitive Obsession | Replace Type Code with Class/Subclasses/State-Strategy; Replace Data Value with Object | State, Strategy |
| Conditional complexity / type checks | Replace Conditional with Polymorphism; Introduce Null Object | State, Strategy, Null Object |
| Message Chains | Hide Delegate | (respects Law of Demeter / Least Knowledge) |
| Refused Bequest / Inappropriate Intimacy | Replace Inheritance with Delegation; Move Method/Field | (favor composition over inheritance) |
| Complex object construction | Replace Constructor with Factory Method; (step-by-step) | Factory Method, Builder |
| Repeated expensive object creation | — | Prototype, Flyweight, Singleton |
