# clean-code-java

## Table of Contents

1. [Introduction](#introduction)
2. [Chapter 2: Meaningful Names](#chapter-2-meaningful-names)
3. [Chapter 3: Functions](#chapter-3-functions)
4. [Chapter 4: Comments](#chapter-4-comments)
5. [Chapter 5: Formatting](#chapter-5-formatting)
6. [Chapter 6: Objects and Data Structures](#chapter-6-objects-and-data-structures)
7. [Chapter 7: Error Handling](#chapter-7-error-handling)
8. [Chapter 8: Boundaries](#chapter-8-boundaries)
9. [Chapter 9: Unit Tests](#chapter-9-unit-tests)
10. [Chapter 10: Classes](#chapter-10-classes)
11. [Chapter 11: Systems](#chapter-11-systems)
12. [Chapter 13: Concurrency](#chapter-13-concurrency)

## Introduction

Software engineering principles, from Robert C. Martin's book
[_Clean Code: A Handbook of Agile Software Craftsmanship_](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882).
This is a guide to producing readable, reusable, and refactorable Java software.

> "Writing clean code is what you must do in order to call yourself a professional.
> There is no reasonable excuse for doing anything less than your best."
> — Robert C. Martin

One more thing: knowing these won't immediately make you a better software
developer, and working with them for many years doesn't mean you won't make
mistakes. Every piece of code starts as a first draft, like wet clay getting
shaped into its final form. Finally, we chisel away the imperfections when
we review it with our peers. Don't beat yourself up for first drafts that need
improvement. Beat up the code instead!

---

## **Chapter 2: Meaningful Names**

### Use intention-revealing names

The name of a variable, function, or class should answer why it exists, what it
does, and how it is used. If a name requires a comment, it does not reveal intent.

**Bad:**

```java
int d; // elapsed time in days
```

**Good:**

```java
int elapsedTimeInDays;
int daysSinceCreation;
int daysSinceModification;
int fileAgeInDays;
```

**[⬆ back to top](#table-of-contents)**

### Reveal intent through names — not structure (Listing 2-1 vs Listing 2-2)

**Bad:**

```java
public List<int[]> getThem() {
    List<int[]> list1 = new ArrayList<int[]>();
    for (int[] x : theList)
        if (x[0] == 4)
            list1.add(x);
    return list1;
}
```

**Good:**

```java
public List<Cell> getFlaggedCells() {
    List<Cell> flaggedCells = new ArrayList<Cell>();
    for (Cell cell : gameBoard)
        if (cell.isFlagged())
            flaggedCells.add(cell);
    return flaggedCells;
}
```

**[⬆ back to top](#table-of-contents)**

### Use pronounceable names

**Bad:**

```java
class DtaRcrd102 {
    private Date genymdhms;
    private Date modymdhms;
    private final String pszqint = "102";
    /* ... */
}
```

**Good:**

```java
class Customer {
    private Date generationTimestamp;
    private Date modificationTimestamp;
    private final String recordId = "102";
    /* ... */
}
```

**[⬆ back to top](#table-of-contents)**

### Use searchable names

Single-letter names and numeric constants are not searchable. Give constants meaningful names.

**Bad:**

```java
for (int j = 0; j < 34; j++) {
    s += (t[j] * 4) / 5;
}
```

**Good:**

```java
int realDaysPerIdealDay = 4;
final int WORK_DAYS_PER_WEEK = 5;
int sum = 0;
for (int j = 0; j < NUMBER_OF_TASKS; j++) {
    int realTaskDays = taskEstimate[j] * realDaysPerIdealDay;
    int realTaskWeeks = realTaskDays / WORK_DAYS_PER_WEEK;
    sum += realTaskWeeks;
}
```

**[⬆ back to top](#table-of-contents)**

### Avoid encodings — member prefixes

Modern Java IDEs highlight member variables. The `m_` prefix is unneeded noise.

**Bad:**

```java
public class Part {
    private String m_dsc; // The textual description

    void setName(String name) {
        m_dsc = name;
    }
}
```

**Good:**

```java
public class Part {
    private String description;

    void setDescription(String description) {
        this.description = description;
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Avoid encodings — interfaces and implementations

Prefer leaving interfaces unadorned. If you must encode, encode the implementation.

**Bad:**

```java
interface IShapeFactory { /* ... */ }
class ShapeFactory implements IShapeFactory { /* ... */ }
```

**Good:**

```java
interface ShapeFactory { /* ... */ }
class ShapeFactoryImpl implements ShapeFactory { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Avoid mental mapping

Explicit is better than implicit. A single-letter name forces readers to mentally translate it.

**Bad:**

```java
List<String> locations = Arrays.asList("Austin", "New York", "San Francisco");
locations.forEach(l -> {
    doStuff();
    doSomeOtherStuff();
    // ...
    // Wait, what is `l` for again?
    dispatch(l);
});
```

**Good:**

```java
List<String> locations = Arrays.asList("Austin", "New York", "San Francisco");
locations.forEach(location -> {
    doStuff();
    doSomeOtherStuff();
    // ...
    dispatch(location);
});
```

**[⬆ back to top](#table-of-contents)**

### Class names should be nouns, method names should be verbs

Class names: `Customer`, `WikiPage`, `Account`, `AddressParser` — not `Manager`, `Processor`, `Data`.
Method names: `postPayment`, `deletePage`, `save`. Accessors prefixed with `get`/`set`/`is`.

**Bad:**

```java
class DataManager { /* ... */ }
void process() { /* ... */ }
```

**Good:**

```java
class Customer { /* ... */ }
void postPayment() { /* ... */ }
String getName() { /* ... */ }
void setName(String name) { /* ... */ }
boolean isPosted() { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Add meaningful context (Listing 2-1 vs Listing 2-2)

Variables `firstName`, `lastName`, `street`, `city`, `state` tell a story together.
Alone, `state` means nothing. A class named `Address` provides context.

**Bad:**

```java
private void printGuessStatistics(char candidate, int count) {
    String number;
    String verb;
    String pluralModifier;
    if (count == 0) {
        number = "no";
        verb = "are";
        pluralModifier = "s";
    } else if (count == 1) {
        number = "1";
        verb = "is";
        pluralModifier = "";
    } else {
        number = Integer.toString(count);
        verb = "are";
        pluralModifier = "s";
    }
    String guessMessage = String.format(
        "There %s %s %s%s", verb, number, candidate, pluralModifier);
    print(guessMessage);
}
```

**Good:**

```java
public class GuessStatisticsMessage {
    private String number;
    private String verb;
    private String pluralModifier;

    public String make(char candidate, int count) {
        createPluralDependentMessageParts(count);
        return String.format(
            "There %s %s %s%s", verb, number, candidate, pluralModifier);
    }

    private void createPluralDependentMessageParts(int count) {
        if (count == 0)       thereAreNoLetters();
        else if (count == 1)  thereIsOneLetter();
        else                  thereAreManyLetters(count);
    }

    private void thereAreManyLetters(int count) {
        number = Integer.toString(count); verb = "are"; pluralModifier = "s";
    }
    private void thereIsOneLetter() {
        number = "1"; verb = "is"; pluralModifier = "";
    }
    private void thereAreNoLetters() {
        number = "no"; verb = "are"; pluralModifier = "s";
    }
}
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 3: Functions**

### Functions should be small

The first rule of functions is that they should be small. The second rule is that
they should be smaller than that. Functions should hardly ever be 20 lines long.
Blocks within `if`, `else`, `while` should be one line — a function call.

**[⬆ back to top](#table-of-contents)**

### Do one thing (Listing 3-1 vs Listing 3-3)

**Bad:**

```java
public static String testableHtml(PageData pageData, boolean includeSuiteSetup)
        throws Exception {
    WikiPage wikiPage = pageData.getWikiPage();
    StringBuffer buffer = new StringBuffer();
    if (pageData.hasAttribute("Test")) {
        if (includeSuiteSetup) {
            WikiPage suiteSetup = PageCrawlerImpl.getInheritedPage(
                SuiteResponder.SUITE_SETUP_NAME, wikiPage);
            if (suiteSetup != null) {
                WikiPagePath pagePath =
                    suiteSetup.getPageCrawler().getFullPath(suiteSetup);
                String pagePathName = PathParser.render(pagePath);
                buffer.append("!include -setup .")
                      .append(pagePathName)
                      .append("\n");
            }
        }
        // ... many more lines of deeply nested logic
    }
    buffer.append(pageData.getContent());
    pageData.setContent(buffer.toString());
    return pageData.getHtml();
}
```

**Good:**

```java
public static String renderPageWithSetupsAndTeardowns(
        PageData pageData, boolean isSuite) throws Exception {
    if (isTestPage(pageData))
        includeSetupAndTeardownPages(pageData, isSuite);
    return pageData.getHtml();
}
```

**[⬆ back to top](#table-of-contents)**

### One level of abstraction per function

Mixing levels of abstraction within a function is always confusing.

**Bad:**

```java
public String renderPage(PageData pageData) {
    StringBuffer buffer = new StringBuffer();
    // High-level: deciding what to do
    if (pageData.hasAttribute("Test")) {
        // Low-level: string manipulation
        buffer.append("!include -setup .");
        buffer.append(PathParser.render(
            pageData.getWikiPage().getPageCrawler()
                    .getFullPath(pageData.getWikiPage())));
        buffer.append("\n");
    }
    // Mid-level: page content
    buffer.append(pageData.getContent());
    return pageData.getHtml();
}
```

**Good:**

```java
public String renderPage(PageData pageData) throws Exception {
    includeSetupPages(pageData);
    includePageContent(pageData);
    return pageData.getHtml();
}

private void includeSetupPages(PageData pageData) throws Exception { /* ... */ }
private void includePageContent(PageData pageData) { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Switch statements — use polymorphism (Listing 3-4 vs Listing 3-5)

Switch statements are hard to keep small and always do N things. Bury them inside
an Abstract Factory and never let anyone see them.

**Bad:**

```java
// Listing 3-4: Payroll.java
public Money calculatePay(Employee e) throws InvalidEmployeeType {
    switch (e.type) {
        case COMMISSIONED: return calculateCommissionedPay(e);
        case HOURLY:       return calculateHourlyPay(e);
        case SALARIED:     return calculateSalariedPay(e);
        default: throw new InvalidEmployeeType(e.type);
    }
}
```

**Good:**

```java
// Listing 3-5: Employee and Factory
public abstract class Employee {
    public abstract boolean isPayday();
    public abstract Money calculatePay();
    public abstract void deliverPay(Money pay);
}

public interface EmployeeFactory {
    Employee makeEmployee(EmployeeRecord r) throws InvalidEmployeeType;
}

public class EmployeeFactoryImpl implements EmployeeFactory {
    public Employee makeEmployee(EmployeeRecord r) throws InvalidEmployeeType {
        switch (r.type) {
            case COMMISSIONED: return new CommissionedEmployee(r);
            case HOURLY:       return new HourlyEmployee(r);
            case SALARIED:     return new SalariedEmployee(r);
            default: throw new InvalidEmployeeType(r.type);
        }
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Function arguments (2 or fewer ideally)

The ideal number is zero (niladic), then one (monadic), then two (dyadic).
Three or more require very special justification. Consolidate into a parameter object.

**Bad:**

```java
Circle makeCircle(double x, double y, double radius);
```

**Good:**

```java
Circle makeCircle(Point center, double radius);
```

**[⬆ back to top](#table-of-contents)**

### Flag arguments are ugly

Passing a boolean into a function is a terrible practice. It immediately complicates the
signature and loudly proclaims that this function does more than one thing.

**Bad:**

```java
void render(boolean isSuite) { /* ... */ }
```

**Good:**

```java
void renderForSuite() { /* ... */ }
void renderForSingleTest() { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Have no side effects (Listing 3-6)

Side effects are lies. Your function promises to do one thing but also does hidden things.

**Bad:**

```java
public class UserValidator {
    private Cryptographer cryptographer;

    public boolean checkPassword(String userName, String password) {
        User user = UserGateway.findByName(userName);
        if (user != User.NULL) {
            String codedPhrase = user.getPhraseEncodedByPassword();
            String phrase = cryptographer.decrypt(codedPhrase, password);
            if ("Valid Password".equals(phrase)) {
                Session.initialize(); // SIDE EFFECT: hidden state mutation
                return true;
            }
        }
        return false;
    }
}
```

**Good:**

```java
public class UserValidator {
    private Cryptographer cryptographer;

    public boolean checkPassword(String userName, String password) {
        User user = UserGateway.findByName(userName);
        if (user != User.NULL) {
            String codedPhrase = user.getPhraseEncodedByPassword();
            String phrase = cryptographer.decrypt(codedPhrase, password);
            return "Valid Password".equals(phrase);
        }
        return false;
    }
}

// Caller handles session initialization separately — intent is explicit
if (validator.checkPassword(userName, password)) {
    Session.initialize();
}
```

**[⬆ back to top](#table-of-contents)**

### Command query separation

Functions should either do something or answer something — not both.

**Bad:**

```java
// Is this setting the attribute, or checking if it was already set?
if (set("username", "unclebob")) { /* ... */ }
```

**Good:**

```java
if (attributeExists("username")) {
    setAttribute("username", "unclebob");
    // ...
}
```

**[⬆ back to top](#table-of-contents)**

### Prefer exceptions to returning error codes

Returning error codes leads to deeply nested structures. The caller must deal with
the error immediately. Exceptions separate the happy path from the error path.

**Bad:**

```java
if (deletePage(page) == E_OK) {
    if (registry.deleteReference(page.name) == E_OK) {
        if (configKeys.deleteKey(page.name.makeKey()) == E_OK) {
            logger.log("page deleted");
        } else {
            logger.log("configKey not deleted");
        }
    } else {
        logger.log("deleteReference from registry failed");
    }
} else {
    logger.log("delete failed");
    return E_ERROR;
}
```

**Good:**

```java
public void delete(Page page) {
    try {
        deletePageAndAllReferences(page);
    } catch (Exception e) {
        logError(e);
    }
}

private void deletePageAndAllReferences(Page page) throws Exception {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}

private void logError(Exception e) {
    logger.log(e.getMessage());
}
```

**[⬆ back to top](#table-of-contents)**

### Don't repeat yourself

Duplication is the root of all evil in software. Every time you see duplication you see
a missed opportunity for abstraction.

**Bad:**

```java
public void showDeveloperList(List<Developer> developers) {
    for (Developer developer : developers) {
        String expectedSalary = developer.calculateExpectedSalary();
        String experience = developer.getExperience();
        String githubLink = developer.getGithubLink();
        render(expectedSalary, experience, githubLink);
    }
}

public void showManagerList(List<Manager> managers) {
    for (Manager manager : managers) {
        String expectedSalary = manager.calculateExpectedSalary();
        String experience = manager.getExperience();
        String portfolio = manager.getMBAProjects();
        render(expectedSalary, experience, portfolio);
    }
}
```

**Good:**

```java
public void showEmployeeList(List<Employee> employees) {
    for (Employee employee : employees) {
        String expectedSalary = employee.calculateExpectedSalary();
        String experience = employee.getExperience();
        String extra = (employee.type == EmployeeType.MANAGER)
            ? employee.getMBAProjects()
            : employee.getGithubLink();
        render(expectedSalary, experience, extra);
    }
}
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 4: Comments**

### Comments do not make up for bad code

Clear and expressive code with few comments is far superior to cluttered and
complex code with lots of comments.

**Bad:**

```java
// Check to see if the employee is eligible for full benefits
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65))
```

**Good:**

```java
if (employee.isEligibleForFullBenefits())
```

**[⬆ back to top](#table-of-contents)**

### Redundant comments make things worse (Listing 4-1)

A comment is redundant if it describes something the code already says clearly.

**Bad:**

```java
// Utility method that returns when this.closed is true. Throws an exception
// if the timeout is reached.
public synchronized void waitForClose(final long timeoutMillis) throws Exception {
    if (!closed) {
        wait(timeoutMillis);
        if (!closed)
            throw new Exception("MockResponseSender could not be closed");
    }
}
```

**Good:**

```java
// No comment needed — the code is self-explanatory
public synchronized void waitForClose(final long timeoutMillis) throws Exception {
    if (!closed) {
        wait(timeoutMillis);
        if (!closed)
            throw new Exception("MockResponseSender could not be closed");
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Good comments: warning of consequences

**Good:**

```java
// Don't run unless you have some time to kill.
public void _testWithReallyBigFile() {
    writeLinesToFile(10000000);
    response.setBody(testFile);
    response.readyToSend(this);
    String responseString = output.toString();
    assertSubString("Content-Length: 1000000000", responseString);
    assertTrue(bytesSent > 1000000000);
}
```

**[⬆ back to top](#table-of-contents)**

### Good comments: TODO comments

TODOs are jobs that the programmer thinks should be done but can't do right now.
Scan through them regularly and eliminate the ones you can.

**Good:**

```java
// TODO: implement real authentication once the security module is available
public boolean authenticate(String user, String password) {
    return true;
}
```

**[⬆ back to top](#table-of-contents)**

### Self-documenting code beats over-commented code (Listing 4-7 vs Listing 4-8)

**Bad:**

```java
// Listing 4-7: over-commented
public static int[] generatePrimes(int maxValue) {
    if (maxValue >= 2) {
        int s = maxValue + 1; // size of array
        boolean[] f = new boolean[s];
        int i;
        // initialize array to true
        for (i = 0; i < s; i++) f[i] = true;
        // get rid of known non-primes
        f[0] = f[1] = false;
        // sieve
        int j;
        for (i = 2; i < Math.sqrt(s) + 1; i++) {
            if (f[i]) { // if i is uncrossed, cross its multiples
                for (j = 2 * i; j < s; j += i)
                    f[j] = false; // multiple is not prime
            }
        }
    }
    // ...
}
```

**Good:**

```java
// Listing 4-8: self-documenting (only one non-obvious comment remains)
public class PrimeGenerator {
    private static boolean[] crossedOut;
    private static int[]     result;

    public static int[] generatePrimes(int maxValue) {
        if (maxValue < 2) return new int[0];
        uncrossIntegersUpTo(maxValue);
        crossOutMultiples();
        putUncrossedIntegersIntoResult();
        return result;
    }

    private static void uncrossIntegersUpTo(int maxValue) {
        crossedOut = new boolean[maxValue + 1];
        for (int i = 2; i < crossedOut.length; i++)
            crossedOut[i] = false;
    }

    private static void crossOutMultiples() {
        int limit = determineIterationLimit();
        for (int i = 2; i <= limit; i++)
            if (notCrossed(i)) crossOutMultiplesOf(i);
    }

    private static int determineIterationLimit() {
        // Every composite has a prime factor <= sqrt of array size,
        // so we don't need to cross multiples beyond that root.
        return (int) Math.sqrt(crossedOut.length);
    }

    private static void crossOutMultiplesOf(int i) {
        for (int multiple = 2 * i; multiple < crossedOut.length; multiple += i)
            crossedOut[multiple] = true;
    }

    private static boolean notCrossed(int i) { return !crossedOut[i]; }

    private static void putUncrossedIntegersIntoResult() {
        result = new int[numberOfUncrossedIntegers()];
        for (int j = 0, i = 2; i < crossedOut.length; i++)
            if (notCrossed(i)) result[j++] = i;
    }

    private static int numberOfUncrossedIntegers() {
        int count = 0;
        for (int i = 2; i < crossedOut.length; i++)
            if (notCrossed(i)) count++;
        return count;
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Don't leave commented-out code

Others who see commented-out code are afraid to delete it. Don't commit commented-out code — version control holds the history.

**Bad:**

```java
InputStreamResponse response = new InputStreamResponse();
response.setBody(formatter.getResultStream(), formatter.getByteCount());
// InputStream resultsStream = formatter.getResultStream();
// StreamReader reader = new StreamReader(resultsStream);
// response.setContent(reader.read(formatter.getByteCount()));
```

**Good:**

```java
InputStreamResponse response = new InputStreamResponse();
response.setBody(formatter.getResultStream(), formatter.getByteCount());
```

**[⬆ back to top](#table-of-contents)**

### Don't have journal comments

Version control is a better journal. There is no need for diary entries in code.

**Bad:**

```java
/**
 * 2016-12-20: Removed monads, didn't understand them (RM)
 * 2016-10-01: Improved using special monads (JP)
 * 2016-02-03: Removed type-checking (LI)
 * 2015-03-14: Added combine with type-checking (JR)
 */
public int combine(int a, int b) {
    return a + b;
}
```

**Good:**

```java
public int combine(int a, int b) {
    return a + b;
}
```

**[⬆ back to top](#table-of-contents)**

### Avoid position markers

They usually just add noise. Let structure and indentation give visual organization.

**Bad:**

```java
// Actions //////////////////////////////////
public void doSomething() { /* ... */ }
public void doSomethingElse() { /* ... */ }

// Private Helpers //////////////////////////
private void helper() { /* ... */ }
```

**Good:**

```java
public void doSomething() { /* ... */ }
public void doSomethingElse() { /* ... */ }

private void helper() { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 5: Formatting**

The purpose of formatting is communication. It is so important that it must not
be ignored. Use a team-agreed formatter (Checkstyle, Spotless, IDE) to automate it.

### Vertical openness between concepts (Listing 5-1 vs Listing 5-2)

Each blank line is a visual cue identifying a new and separate concept.

**Bad:**

```java
package fitnesse.wikitext.widgets;
import java.util.regex.*;
public class BoldWidget extends ParentWidget {
  public static final String REGEXP = "'''.+?'''";
  private static final Pattern pattern = Pattern.compile("'''(.+?)'''",
    Pattern.MULTILINE + Pattern.DOTALL);
  public BoldWidget(ParentWidget parent, String text) throws Exception {
    super(parent);
    Matcher match = pattern.matcher(text);
    match.find();
    addChildWidgets(match.group(1));}
  public String render() throws Exception {
    StringBuffer html = new StringBuffer("<b>");
    html.append(childHtml()).append("</b>");
    return html.toString();}}
```

**Good:**

```java
package fitnesse.wikitext.widgets;

import java.util.regex.*;

public class BoldWidget extends ParentWidget {
    public static final String REGEXP = "'''.+?'''";
    private static final Pattern pattern = Pattern.compile("'''(.+?)'''",
        Pattern.MULTILINE + Pattern.DOTALL
    );

    public BoldWidget(ParentWidget parent, String text) throws Exception {
        super(parent);
        Matcher match = pattern.matcher(text);
        match.find();
        addChildWidgets(match.group(1));
    }

    public String render() throws Exception {
        StringBuffer html = new StringBuffer("<b>");
        html.append(childHtml()).append("</b>");
        return html.toString();
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Vertical density — noise comments break association (Listing 5-3 vs Listing 5-4)

Useless comments scatter closely related lines and require more eye movement.

**Bad:**

```java
public class ReporterConfig {
    /**
     * The class name of the reporter listener
     */
    private String m_className;

    /**
     * The properties of the reporter listener
     */
    private List<Property> m_properties = new ArrayList<Property>();

    public void addProperty(Property property) {
        m_properties.add(property);
    }
}
```

**Good:**

```java
public class ReporterConfig {
    private String m_className;
    private List<Property> m_properties = new ArrayList<Property>();

    public void addProperty(Property property) {
        m_properties.add(property);
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Vertical ordering — callers above callees (Stepdown Rule)

We want the code to read like a top-down narrative. Caller functions should be
above the functions they call.

**Bad:**

```java
public class PerformanceReview {
    private List<Employee> lookupPeers() {
        return db.lookup(employee, "peers");
    }

    private Employee lookupManager() {
        return db.lookup(employee, "manager");
    }

    private void getPeerReviews() {
        List<Employee> peers = lookupPeers(); // ...
    }

    public void perfReview() {        // entry point buried in the middle
        getPeerReviews();
        getManagerReview();
        getSelfReview();
    }

    private void getManagerReview() {
        Employee manager = lookupManager();
    }
}
```

**Good:**

```java
public class PerformanceReview {
    public void perfReview() {        // entry point at the top
        getPeerReviews();
        getManagerReview();
        getSelfReview();
    }

    private void getPeerReviews() {
        List<Employee> peers = lookupPeers(); // ...
    }

    private List<Employee> lookupPeers() {
        return db.lookup(employee, "peers");
    }

    private void getManagerReview() {
        Employee manager = lookupManager();
    }

    private Employee lookupManager() {
        return db.lookup(employee, "manager");
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Never collapse scopes onto one line

**Bad:**

```java
public class CommentWidget extends TextWidget {
public static final String REGEXP = "^#[^\r\n]*(?:(?:\r\n)|\n|\r)?";
public CommentWidget(ParentWidget parent, String text){super(parent, text);}
public String render() throws Exception {return ""; }
}
```

**Good:**

```java
public class CommentWidget extends TextWidget {
    public static final String REGEXP = "^#[^\r\n]*(?:(?:\r\n)|\n|\r)?";

    public CommentWidget(ParentWidget parent, String text) {
        super(parent, text);
    }

    public String render() throws Exception {
        return "";
    }
}
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 6: Objects and Data Structures**

### Data abstraction (Listing 6-1 vs Listing 6-2)

Hiding implementation is not just about putting a layer of functions between variables.
It is about abstractions. A class should expose abstract interfaces that allow users
to manipulate the *essence* of the data, without knowing the implementation.

**Bad:**

```java
// Concrete Point — exposes implementation details
public class Point {
    public double x;
    public double y;
}
```

**Good:**

```java
// Abstract Point — hides whether rectangular or polar
public interface Point {
    double getX();
    double getY();
    void setCartesian(double x, double y);
    double getR();
    double getTheta();
    void setPolar(double r, double theta);
}
```

**[⬆ back to top](#table-of-contents)**

### Data/object anti-symmetry (Listing 6-5 vs Listing 6-6)

Objects hide their data behind abstractions and expose functions that operate on that data.
Data structures expose their data and have no meaningful functions.

**Bad (when you need to add new shapes frequently):**

```java
// Listing 6-5: Procedural — must modify Geometry for every new shape
public class Square   { public Point topLeft; public double side; }
public class Rectangle{ public Point topLeft; public double height; public double width; }
public class Circle   { public Point center;  public double radius; }

public class Geometry {
    public double area(Object shape) throws NoSuchShapeException {
        if (shape instanceof Square) {
            Square s = (Square) shape;
            return s.side * s.side;
        } else if (shape instanceof Rectangle) {
            Rectangle r = (Rectangle) shape;
            return r.height * r.width;
        } else if (shape instanceof Circle) {
            Circle c = (Circle) shape;
            return Math.PI * c.radius * c.radius;
        }
        throw new NoSuchShapeException();
    }
}
```

**Good (when you need to add new shapes frequently):**

```java
// Listing 6-6: Polymorphic — add new shapes without touching existing code
public class Square implements Shape {
    private Point topLeft;
    private double side;
    public double area() { return side * side; }
}

public class Rectangle implements Shape {
    private Point topLeft;
    private double height;
    private double width;
    public double area() { return height * width; }
}

public class Circle implements Shape {
    private Point center;
    private double radius;
    public double area() { return Math.PI * radius * radius; }
}
```

**[⬆ back to top](#table-of-contents)**

### The Law of Demeter — avoid train wrecks

A method `f` of class `C` should only call methods of: `C` itself, objects created
by `f`, objects passed as arguments to `f`, or objects held in an instance variable.
Don't talk to strangers.

**Bad:**

```java
// Train wreck — navigates through multiple objects
final String outputDir = ctxt.getOptions().getScratchDir().getAbsolutePath();
```

**Good:**

```java
// Tell ctxt what to do instead of asking it to reveal its internals
BufferedOutputStream bos = ctxt.createScratchFileStream(classFileName);
```

**[⬆ back to top](#table-of-contents)**

### Data Transfer Objects (DTOs)

The quintessential data structure is a class with public variables and no functions (a DTO).
Do not add business logic to DTOs. Keep business rules in separate objects.

**Bad:**

```java
public class UserRecord {
    public String name;
    public String email;
    public int purchaseCount;

    // Business logic mixed into data structure
    public boolean isEligibleForDiscount() {
        return this.purchaseCount > 10;
    }
}
```

**Good:**

```java
public class UserRecord {
    public String name;
    public String email;
    public int purchaseCount;
}

public class DiscountService {
    public boolean isEligibleForDiscount(UserRecord user) {
        return user.purchaseCount > 10;
    }
}
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 7: Error Handling**

### Use exceptions rather than return codes (Listing 7-1 vs Listing 7-2)

**Bad:**

```java
// Listing 7-1: DeviceController.java
public class DeviceController {
    public void sendShutDown() {
        DeviceHandle handle = getHandle(DEV1);
        if (handle != DeviceHandle.INVALID) {
            retrieveDeviceRecord(handle);
            if (record.getStatus() != DEVICE_SUSPENDED) {
                pauseDevice(handle);
                clearDeviceWorkQueue(handle);
                closeDevice(handle);
            } else {
                logger.log("Device suspended.  Unable to shut down");
            }
        } else {
            logger.log("Invalid handle for: " + DEV1.toString());
        }
    }
}
```

**Good:**

```java
// Listing 7-2: DeviceController.java (with exceptions)
public class DeviceController {
    public void sendShutDown() {
        try {
            tryToShutDown();
        } catch (DeviceShutDownError e) {
            logger.log(e);
        }
    }

    private void tryToShutDown() throws DeviceShutDownError {
        DeviceHandle handle = getHandle(DEV1);
        DeviceRecord record = retrieveDeviceRecord(handle);
        pauseDevice(handle);
        clearDeviceWorkQueue(handle);
        closeDevice(handle);
    }

    private DeviceHandle getHandle(DeviceID id) {
        // ...
        throw new DeviceShutDownError("Invalid handle for: " + id.toString());
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Prefer unchecked exceptions

Checked exceptions violate the Open/Closed Principle. A change at a low level forces
signature changes on all levels above it, breaking encapsulation across the call stack.

**Bad:**

```java
public void sendShutDown() throws DeviceShutDownError {       // propagates up
    tryToShutDown();
}
private void tryToShutDown() throws DeviceShutDownError {     // and up
    DeviceHandle handle = getHandle(DEV1);
}
private DeviceHandle getHandle(DeviceID id) throws DeviceShutDownError { // source
    throw new DeviceShutDownError("...");
}
```

**Good:**

```java
// DeviceShutDownError extends RuntimeException — no throws clauses needed
public void sendShutDown() {
    try {
        tryToShutDown();
    } catch (DeviceShutDownError e) {
        logger.log(e);
    }
}
private void tryToShutDown() {
    DeviceHandle handle = getHandle(DEV1);
    // ...
}
```

**[⬆ back to top](#table-of-contents)**

### Define exception classes in terms of the caller's needs

Wrap third-party APIs into your own exception types. It minimises dependencies
on vendor choices and makes your call sites clean.

**Bad:**

```java
ACMEPort port = new ACMEPort(12);
try {
    port.open();
} catch (DeviceResponseException e) {
    reportPortError(e);
    logger.log("Device response exception", e);
} catch (ATM1212UnlockedException e) {
    reportPortError(e);
    logger.log("Unlock exception", e);
} catch (GMXError e) {
    reportPortError(e);
    logger.log("Device response exception");
} finally { /* ... */ }
```

**Good:**

```java
// Wrapper hides third-party API specifics
public class LocalPort {
    private ACMEPort innerPort;

    public LocalPort(int portNumber) {
        innerPort = new ACMEPort(portNumber);
    }

    public void open() {
        try {
            innerPort.open();
        } catch (DeviceResponseException | ATM1212UnlockedException | GMXError e) {
            throw new PortDeviceFailure(e);
        }
    }
}

// Call site is now clean
LocalPort port = new LocalPort(12);
try {
    port.open();
} catch (PortDeviceFailure e) {
    reportError(e);
    logger.log(e.getMessage(), e);
} finally { /* ... */ }
```

**[⬆ back to top](#table-of-contents)**

### Don't return null

When we return null, we are essentially creating work for ourselves and inviting errors.
Return an empty collection or `Optional` instead.

**Bad:**

```java
List<Employee> employees = getEmployees();
if (employees != null) {               // easy to forget this check
    for (Employee e : employees)
        totalPay += e.getPay();
}
```

**Good:**

```java
public List<Employee> getEmployees() {
    if (/* no employees */)
        return Collections.emptyList();
    // ...
}

// No null check needed at the call site
for (Employee e : getEmployees())
    totalPay += e.getPay();
```

**[⬆ back to top](#table-of-contents)**

### Don't pass null

Passing null into methods is worse than returning it. Forbid it at the method boundary.

**Bad:**

```java
public double calculatePay(Employee employee, Date payDate) {
    // forced to guard against caller mistakes
    if (employee == null || payDate == null)
        throw new NullPointerException("...");
    // ...
}

calculatePay(null, null); // compiles — blows up at runtime
```

**Good:**

```java
public double calculatePay(@NonNull Employee employee, @NonNull Date payDate) {
    // precondition enforced by annotation or Objects.requireNonNull at system boundary
    Objects.requireNonNull(employee, "employee");
    Objects.requireNonNull(payDate,  "payDate");
    // ...
}
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 8: Boundaries**

### Wrap third-party code

Third-party code is outside your control. Wrapping it creates a single point to adapt
when the library changes, and decouples your design decisions from theirs.

**Bad:**

```java
// Map is used everywhere — its interface is exposed throughout the codebase
Map sensors = new HashMap();
Sensor s = (Sensor) sensors.get(sensorId);
```

**Good:**

```java
public class Sensors {
    private Map<String, Sensor> sensors = new HashMap<>();

    public Sensor getById(String id) {
        return sensors.get(id);
    }
    // ... the interface is tailored and constrained to our needs
}

Sensor s = sensors.getById(sensorId);
```

**[⬆ back to top](#table-of-contents)**

### Write learning tests to understand third-party code

Learning tests call the third-party API exactly as you plan to use it.
They verify your understanding and immediately flag breaking API changes.

**Good:**

```java
// Listing 8-1: LogTest.java — learning tests for log4j
public class LogTest {
    private Logger logger;

    @Before
    public void initialize() {
        logger = Logger.getLogger("logger");
        logger.removeAllAppenders();
        Logger.getRootLogger().addAppender(new ConsoleAppender(
            new PatternLayout("%p %t %m%n"), ConsoleAppender.SYSTEM_OUT));
    }

    @Test
    public void basicLogger() {
        logger.info("basicLogger");
    }

    @Test
    public void addAppenderWithStream() {
        logger.addAppender(new ConsoleAppender(
            new PatternLayout("%p %t %m%n"), ConsoleAppender.SYSTEM_OUT));
        logger.info("addAppenderWithStream");
    }
}
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 9: Unit Tests**

### The three laws of TDD

1. You may not write production code until you have written a failing unit test.
2. You may not write more of a unit test than is sufficient to fail.
3. You may not write more production code than is sufficient to pass the currently failing test.

### Keep tests clean — BUILD-OPERATE-CHECK (Listing 9-1 vs Listing 9-2)

Test code is just as important as production code. It requires thought, design, and care.

**Bad:**

```java
// Listing 9-1: Noise obscures intent
public void testGetPageHieratchyAsXml() throws Exception {
    crawler.addPage(root, PathParser.parse("PageOne"));
    crawler.addPage(root, PathParser.parse("PageOne.ChildOne"));
    crawler.addPage(root, PathParser.parse("PageTwo"));
    request.setResource("root");
    request.addInput("type", "pages");
    Responder responder = new SerializedPageResponder();
    SimpleResponse response =
        (SimpleResponse) responder.makeResponse(
            new FitNesseContext(root), request);
    String xml = response.getContent();
    assertEquals("text/xml", response.getContentType());
    assertSubString("<name>PageOne</name>", xml);
    assertSubString("<name>PageTwo</name>", xml);
    assertSubString("<name>ChildOne</name>", xml);
}
```

**Good:**

```java
// Listing 9-2: BUILD-OPERATE-CHECK pattern
public void testGetPageHierarchyAsXml() throws Exception {
    // BUILD
    makePages("PageOne", "PageOne.ChildOne", "PageTwo");

    // OPERATE
    submitRequest("root", "type:pages");

    // CHECK
    assertResponseIsXML();
    assertResponseContains(
        "<name>PageOne</name>", "<name>PageTwo</name>", "<name>ChildOne</name>"
    );
}
```

**[⬆ back to top](#table-of-contents)**

### Single concept per test (Listing 9-8)

Test just one concept per test function. Multiple asserts are fine as long as they all
test a single concept.

**Bad:**

```java
// Listing 9-8: tests three separate concepts in one function
public void testAddMonths() {
    SerialDate d1 = SerialDate.createInstance(31, 5, 2004);

    SerialDate d2 = SerialDate.addMonths(1, d1);
    assertEquals(30, d2.getDayOfMonth()); // concept 1: 30-day end-of-month
    assertEquals(6, d2.getMonth());

    SerialDate d3 = SerialDate.addMonths(2, d1);
    assertEquals(31, d3.getDayOfMonth()); // concept 2: 31-day month lands on 31st
    assertEquals(7, d3.getMonth());

    SerialDate d4 = SerialDate.addMonths(1, SerialDate.addMonths(1, d1));
    assertEquals(30, d4.getDayOfMonth()); // concept 3: second add still respects shorter month
    assertEquals(7, d4.getMonth());
}
```

**Good:**

```java
@Test
public void addMonthToEndOf30DayMonth_clampsThat30() {
    SerialDate d = SerialDate.addMonths(1, SerialDate.createInstance(31, 5, 2004));
    assertEquals(30, d.getDayOfMonth());
    assertEquals(6,  d.getMonth());
}

@Test
public void addTwoMonthsToEndOf31DayMonth_landsOn31() {
    SerialDate d = SerialDate.addMonths(2, SerialDate.createInstance(31, 5, 2004));
    assertEquals(31, d.getDayOfMonth());
    assertEquals(7,  d.getMonth());
}

@Test
public void addOneMonthTwiceFromEndOf31DayMonth_respectsShorterSecondMonth() {
    SerialDate d = SerialDate.addMonths(1,
                       SerialDate.addMonths(1, SerialDate.createInstance(31, 5, 2004)));
    assertEquals(30, d.getDayOfMonth());
    assertEquals(7,  d.getMonth());
}
```

**[⬆ back to top](#table-of-contents)**

### F.I.R.S.T.

Clean tests follow five rules:

- **Fast** — tests run quickly. Slow tests don't get run, so problems go undetected.
- **Independent** — tests don't depend on each other; run any subset in any order.
- **Repeatable** — tests produce the same result in every environment: dev, CI, offline.
- **Self-Validating** — tests have a boolean outcome (pass/fail); no manual log inspection.
- **Timely** — tests are written just before the production code that makes them pass.

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 10: Classes**

### Classes should be small — one reason to change (Listing 10-2 vs Listing 10-3)

Count *responsibilities*, not lines. If you can't describe a class in 25 words without
"and", "or", "if", or "but", it has too many responsibilities.

**Bad:**

```java
// Listing 10-2: SuperDashboard has two reasons to change
public class SuperDashboard extends JFrame implements MetaDataUser {
    public Component getLastFocusedComponent() { ... }
    public void setLastFocused(Component lastFocused) { ... }
    // Version tracking — reason 1 to change
    public int getMajorVersionNumber() { ... }
    public int getMinorVersionNumber() { ... }
    public int getBuildNumber() { ... }
}
```

**Good:**

```java
// Listing 10-3: Version extracted — single responsibility
public class Version {
    public int getMajorVersionNumber() { ... }
    public int getMinorVersionNumber() { ... }
    public int getBuildNumber() { ... }
}

public class SuperDashboard extends JFrame implements MetaDataUser {
    private Version version = new Version();
    public Component getLastFocusedComponent() { ... }
    public void setLastFocused(Component lastFocused) { ... }
}
```

**[⬆ back to top](#table-of-contents)**

### Cohesion — keep methods and variables together (Listing 10-4)

A class in which each variable is used by each method is maximally cohesive.
When you see methods that use only a subset of variables, split the class.

**Good:**

```java
// Listing 10-4: Stack.java — high cohesion
public class Stack {
    private int topOfStack = 0;
    private List<Integer> elements = new LinkedList<>();

    public int size() {
        return topOfStack;
    }

    public void push(int element) {
        topOfStack++;
        elements.add(element);
    }

    public int pop() throws PoppedWhenEmpty {
        if (topOfStack == 0)
            throw new PoppedWhenEmpty();
        int element = elements.get(--topOfStack);
        elements.remove(topOfStack);
        return element;
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Organizing for change — Open/Closed Principle (Listing 10-9 vs Listing 10-10)

**Bad:**

```java
// Listing 10-9: Sql — must be opened and modified to add new statement types
public class Sql {
    public Sql(String table, Column[] columns) { ... }
    public String create()  { ... }
    public String insert(Object[] fields) { ... }
    public String selectAll() { ... }
    public String findByKey(String keyColumn, String keyValue) { ... }
    public String select(Column column, String pattern) { ... }
    public String preparedInsert() { ... }
    private String columnList(Column[] columns) { ... }
    private String valuesList(Object[] fields, Column[] columns) { ... }
    private String selectWithCriteria(String criteria) { ... }
    private String placeholderList(Column[] columns) { ... }
}
```

**Good:**

```java
// Listing 10-10: Each SQL type is its own class — add new types without touching others
abstract public class Sql {
    public Sql(String table, Column[] columns) { ... }
    abstract public String generate();
}

public class CreateSql extends Sql {
    public CreateSql(String table, Column[] columns) { ... }
    @Override public String generate() { ... }
}

public class SelectSql extends Sql {
    public SelectSql(String table, Column[] columns) { ... }
    @Override public String generate() { ... }
}

public class InsertSql extends Sql {
    public InsertSql(String table, Column[] columns, Object[] fields) { ... }
    @Override public String generate() { ... }
    private String valuesList(Object[] fields, Column[] columns) { ... }
}

// Adding UpdateSql requires zero changes to any existing class
public class UpdateSql extends Sql {
    @Override public String generate() { ... }
}
```

**[⬆ back to top](#table-of-contents)**

### Isolating from change — Dependency Inversion Principle

Depend on abstractions, not concrete details. This makes classes testable
and decoupled from implementation specifics.

**Bad:**

```java
// Portfolio directly coupled to TokyoStockExchange — impossible to test in isolation
public class Portfolio {
    private TokyoStockExchange exchange = new TokyoStockExchange();
    // Tests give different answers every 5 minutes
}
```

**Good:**

```java
public interface StockExchange {
    Money currentPrice(String symbol);
}

public class Portfolio {
    private StockExchange exchange;

    public Portfolio(StockExchange exchange) {
        this.exchange = exchange; // injected — easy to substitute in tests
    }
}

// Test with a stub
public class PortfolioTest {
    @Before
    public void setUp() {
        FixedStockExchangeStub exchange = new FixedStockExchangeStub();
        exchange.fix("MSFT", 100);
        portfolio = new Portfolio(exchange);
    }

    @Test
    public void GivenFiveMSFTTotalShouldBe500() throws Exception {
        portfolio.add(5, "MSFT");
        assertEquals(500, portfolio.value());
    }
}
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 11: Systems**

### Separate constructing a system from using it

Software systems should separate the startup process (constructing the object graph)
from the runtime logic. Main and its factories should do the construction; applications
should only use the objects handed to them.

**Bad:**

```java
public class MyService {
    private MyServiceImpl service;

    public MyService() {
        // Hard-coded construction inside application logic
        this.service = new MyServiceImpl(new Dependencies(...));
    }

    public void doWork() {
        service.work();
    }
}
```

**Good:**

```java
// main() builds the full object graph
public class Main {
    public static void main(String[] args) {
        Dependencies dep = new Dependencies();
        MyService service = new MyServiceImpl(dep);
        Application app = new Application(service);
        app.run();
    }
}

// Application only uses what it's given
public class Application {
    private final MyService service;

    public Application(MyService service) {
        this.service = service;
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Use dependency injection

Dependency Injection (DI) is the most powerful mechanism for separating construction
from use. DI inverts the control of dependency management: the class makes no direct
provision for resolving its dependencies — it delegates that to the container.

**Bad:**

```java
public class InventoryTracker {
    private InventoryRequester requester;

    public InventoryTracker(List<String> items) {
        this.items = items;
        // BAD: hard-coded dependency — coupled to one specific implementation
        this.requester = new InventoryRequester();
    }
}
```

**Good:**

```java
public class InventoryTracker {
    private final List<String> items;
    private final ItemRequester requester;

    public InventoryTracker(List<String> items, ItemRequester requester) {
        this.items = items;
        this.requester = requester; // injected by caller
    }

    public void requestItems() {
        items.forEach(requester::requestItem);
    }
}

// Caller wires the graph
InventoryTracker tracker = new InventoryTracker(
    Arrays.asList("apples", "bananas"),
    new WebSocketItemRequester()
);
```

**[⬆ back to top](#table-of-contents)**

---

## **Chapter 13: Concurrency**

### Concurrency defense — single responsibility principle

Concurrency design is complex enough to deserve its own right to be changed.
Keep concurrency-related code separate from other code.

**Bad:**

```java
public class RequestProcessor {
    // mixes business logic with thread-safety concerns
    public synchronized void process(Request request) {
        validateRequest(request);    // no shared state here
        counter++;                   // shared state
        generateResponse(request);   // no shared state here
    }
}
```

**Good:**

```java
public class RequestProcessor {
    private final AtomicInteger counter = new AtomicInteger();

    public void process(Request request) {
        validateRequest(request);
        counter.incrementAndGet();   // thread-safe; no lock held over the full method
        generateResponse(request);
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Use thread-safe collections

**Bad:**

```java
// HashMap is not thread-safe — concurrent puts cause data corruption
Map<String, Session> sessions = new HashMap<>();
```

**Good:**

```java
// ConcurrentHashMap handles concurrent access safely
Map<String, Session> sessions = new ConcurrentHashMap<>();
```

**[⬆ back to top](#table-of-contents)**

### Keep synchronized sections small

Locks are expensive. Only lock the minimum critical section.

**Bad:**

```java
// Entire method locked — all threads serialized including unrelated work
public synchronized void processItem(Item item) {
    validate(item);            // no shared state
    sharedList.add(item);      // shared state
    generateReport(item);      // no shared state
}
```

**Good:**

```java
public void processItem(Item item) {
    validate(item);
    synchronized (sharedList) {
        sharedList.add(item);  // only the critical section is locked
    }
    generateReport(item);
}
```

**[⬆ back to top](#table-of-contents)**

### Prefer `AtomicInteger`, `CopyOnWriteArrayList`, etc. to `synchronized`

**Bad:**

```java
public class Counter {
    private int count = 0;

    public synchronized int getNextId() {
        return ++count; // correct, but heavyweight
    }
}
```

**Good:**

```java
public class Counter {
    private final AtomicInteger count = new AtomicInteger(0);

    public int getNextId() {
        return count.incrementAndGet(); // lock-free, faster
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Shared mutable state is the root of concurrency bugs

**Bad:**

```java
public class X {
    private int lastIdUsed; // shared mutable state

    // Two threads calling this concurrently with lastIdUsed=42
    // could BOTH get 43 — 12,870 possible execution paths, some wrong
    public int getNextId() {
        return ++lastIdUsed;
    }
}
```

**Good:**

```java
public class X {
    private final AtomicInteger lastIdUsed = new AtomicInteger(0);

    public int getNextId() {
        return lastIdUsed.incrementAndGet();
    }
}
```

**[⬆ back to top](#table-of-contents)**

### Instrument code to force failures during testing

Thread bugs are rare and timing-dependent. Inserting `Thread.yield()` or
`Thread.sleep()` at critical points forces different execution orderings,
dramatically increasing the chance of exposing race conditions.

**Good (for testing only):**

```java
public synchronized String nextUrlOrNull() {
    if (hasNext()) {
        String url = urlGenerator.next();
        Thread.yield(); // inserted to force context switches during tests
        updateHasNext();
        return url;
    }
    return null;
}
```

**[⬆ back to top](#table-of-contents)**
