# Thymeleaf — Natural Server-Side Templates for HTML, XML, Text, JS & CSS

## Role

You are a Senior Java/Spring engineer who applies Thymeleaf idiomatically. You know the five Standard-Expression types, what each `th:*` processor does to the DOM at render time, how the Spring dialect wires forms/validation/conversion/CSRF, and where the foot-guns are (XSS via `th:utext`, the Thymeleaf 3.1 web-context removals, fragment-expression wrapping, `th:field` inside `th:each`). You always reason about the *rendered output* — Thymeleaf is a **server-side template engine** that processes a template (a valid HTML/XML/text document) against a context model and emits the final markup. Templates are *natural*: a designer can open the raw `.html` in a browser and see a coherent prototype, because `th:*` attributes are inert until the engine runs.

## Goal

This reference synthesizes the official Thymeleaf documentation (the **Using Thymeleaf** and **Thymeleaf + Spring** tutorials, plus the *What's new in 3.1* article) into concrete, applicable practices, organized by feature area. Each practice states what the feature does with a short rationale and shows the idiomatic form:

- **Template (idiomatic)** — the recommended `th:*` / expression usage (the "do this").
- where useful, the **Controller / config** side that feeds it, and the **Renders** output so you can verify what the engine produces.

Plus, where relevant, a **Pitfall** line calling out a real misuse to avoid. Practices are numbered by chapter (e.g. "5.1 Compose templates with `th:insert`/`th:replace`"). When you apply one, cite it by chapter section and title.

## Version covered

- Target: **Thymeleaf 3.1.x** — the current stable line. Examples are verified against **3.1.5.RELEASE** (2026-04-22).
- `groupId:artifactId` = `org.thymeleaf:thymeleaf` (core) + the Spring integration module.
- **Spring split:** `org.thymeleaf:thymeleaf-spring6` for Spring Framework 6 / Spring Boot 3 (requires **JDK 17+**); `org.thymeleaf:thymeleaf-spring5` for Spring 5 / Spring Boot 2. Security extras: `org.thymeleaf.extras:thymeleaf-extras-springsecurity6` (or `…springsecurity5`).
- **Core minimum:** JDK 8 (JDK 17 when used with Spring 6).
- **3.1 is a behavioral break from 3.0** — the web-context expression objects (`#request`, `#response`, `#session`, `#servletContext`, `#httpServletRequest`, `#httpSession`) are **removed**, and a class-access restriction now forbids most `java.*`/`javax.*`/`jakarta.*`/`jdk.*` calls from expressions. See Chapter 8 and **Appendix C** before touching a template that reaches into the request/session.

> **Spring Boot users:** add `spring-boot-starter-thymeleaf` and Boot auto-configures the resolver, engine, and view resolver. You rarely write the `@Bean`s in Chapter 7 by hand — but you must know them to debug resolution and to tune `spring.thymeleaf.*` (Appendix B).

## Constraints

Thymeleaf renders at request time. The rendered HTML (view source in the browser, or a `MockMvc`/`WebTestClient` body), the resolved template path, and the bound model are the sources of truth.

- **MANDATORY**: After template/controller changes, run the app (or a slice test) and inspect the **rendered output**, not just the source template. Most Thymeleaf bugs (silent empty `th:text`, unresolved fragment, wrong escaping) only show at render time.
- **TEMPLATE RESOLUTION**: A view name maps to `prefix + viewName + suffix` (Boot default `classpath:/templates/` + `.html`). A 500 `TemplateInputException: Error resolving template` means the file is not on that path or the name/suffix is wrong — check `spring.thymeleaf.prefix`/`suffix` and the actual file location.
- **CACHE IN DEV**: Templates are cached by default (`spring.thymeleaf.cache=true`). Set `spring.thymeleaf.cache=false` (or use DevTools) while iterating, or edits won't show. Keep cache **on** in production.
- **ESCAPE BY DEFAULT**: Use `th:text` (escaped). Reserve `th:utext` for **trusted** markup only — `th:utext` of user input is a stored-XSS hole. Never build SpEL/OGNL from user input either (expression injection).
- **3.1 WEB-CONTEXT REMOVALS**: Do not use `#request`/`#session`/`#servletContext`/`#response` or `${request.…}`/`${session.…object navigation…}` patterns that assumed 3.0 — they are gone in 3.1. Put what the template needs into the **model** at the controller. `${param.x}` (request params) and `${session.x}` (session attributes, when an `IWebContext` is present) remain available as maps. See 8.3 / Appendix C.
- **FRAGMENT EXPRESSIONS MUST BE WRAPPED**: In 3.1, `th:insert`/`th:replace` take a fragment expression — write `th:replace="~{footer :: copy}"`, not the deprecated unwrapped `th:replace="footer :: copy"`. `th:include` is removed; use `th:insert`/`th:replace`.
- **`th:field` NEEDS A BOUND OBJECT**: `th:field="*{prop}"` only works under a `th:object="${cmd}"` whose `cmd` is a Spring form-backing bean (in the model). Inside `th:each`, index it with preprocessing — `*{rows[__${stat.index}__].prop}` — because SpEL doesn't evaluate variables inside array brackets.
- **VERSION AWARENESS**: Gate Spring-6/Security-6 extras and 3.1-only behavior on the project's actual versions. Confirm `thymeleaf-spring6` vs `…spring5`, and the matching `springsecurity6`/`5` extras.
- **BEFORE APPLYING**: Read the relevant chapter section below for the expression/attribute, the rendered output, and the pitfall.

## Examples

### Table of contents

**Chapter 1 — Setup & how Thymeleaf works**
- 1.1 Add Thymeleaf to a Spring Boot app
- 1.2 Understand template resolution, modes, and natural templating
- 1.3 The Standard/SpringStandard dialect and the `th:` namespace

**Chapter 2 — Standard Expressions**
- 2.1 Read the model with variable expressions `${...}`
- 2.2 Select on an object with `*{...}` and `th:object`
- 2.3 Externalize text with message expressions `#{...}`
- 2.4 Build URLs with link expressions `@{...}`
- 2.5 Reference markup with fragment expressions `~{...}`
- 2.6 Literals, operators, conditional/elvis, and the no-op `_`

**Chapter 3 — Setting content & attributes**
- 3.1 Set escaped text with `th:text` (and unescaped `th:utext` — XSS)
- 3.2 Set attributes with `th:attr` and the attribute shortcuts
- 3.3 Append with `th:classappend`/`th:styleappend`; boolean attributes
- 3.4 Bind form fields with `th:object`/`th:field`

**Chapter 4 — Iteration & conditionals**
- 4.1 Iterate with `th:each` and the status variable
- 4.2 Branch with `th:if`/`th:unless`
- 4.3 Multi-branch with `th:switch`/`th:case`

**Chapter 5 — Fragments, composition & layouts**
- 5.1 Define and include fragments with `th:fragment` + `th:insert`/`th:replace`
- 5.2 Parameterize fragments and pass markup with `~{...}`
- 5.3 Build a layout (decorator) with a parameterizable base fragment
- 5.4 Strip prototype markup with `th:remove`

**Chapter 6 — Local variables, utilities & inlining**
- 6.1 Declare local variables with `th:with`
- 6.2 Use the utility/expression objects (`#strings`, `#temporals`, `#lists`, …)
- 6.3 Inline with `[[...]]`/`[(...)]` and `th:inline="javascript"`
- 6.4 Preprocess with `__${...}__`

**Chapter 7 — Spring integration**
- 7.1 Return a view from a `@Controller` and pass the model
- 7.2 Handle a form: binding, validation errors, `#fields`, `th:errors`
- 7.3 Format with the conversion service: `${{...}}` and `#conversions`
- 7.4 Auto-include CSRF/hidden fields via `RequestDataValueProcessor`
- 7.5 Guard markup with Spring Security (`sec:authorize`, `sec:authentication`)

**Chapter 8 — Configuration, 3.1 changes & security**
- 8.1 Configure with `spring.thymeleaf.*`
- 8.2 Cache vs live reload
- 8.3 Migrate off the removed 3.1 web-context objects
- 8.4 Non-HTML modes & decoupled template logic
- 8.5 Security: escaping, expression injection, restricted evaluation

**Appendix A — Expression utility objects reference**
**Appendix B — `spring.thymeleaf.*` properties reference**
**Appendix C — Thymeleaf 3.0 → 3.1 migration notes & version table**

---

## Chapter 1 — Setup & how Thymeleaf works

### [1.1] Add Thymeleaf to a Spring Boot app

Title: Depend on `spring-boot-starter-thymeleaf`; let Boot auto-configure the engine.
Description: The starter pulls in `thymeleaf`, `thymeleaf-spring6`, and Boot's `ThymeleafAutoConfiguration`, which registers a `SpringResourceTemplateResolver` (→ `classpath:/templates/`, `.html`, HTML mode), a `SpringTemplateEngine`, and a `ThymeleafViewResolver`. You write templates under `src/main/resources/templates/` and return their view names from controllers. No XML, no manual `@Bean`s for the common case.

**Maven:**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
<!-- Security tags (optional): -->
<dependency>
    <groupId>org.thymeleaf.extras</groupId>
    <artifactId>thymeleaf-extras-springsecurity6</artifactId>
</dependency>
```

**Project layout:**

```
src/main/resources/
  templates/
    index.html
    fragments/layout.html
  application.yml
```

Pitfall: The starter for **Spring Boot 3** brings `thymeleaf-spring6` (Spring 6, JDK 17+). On Boot 2 it is `thymeleaf-spring5`. Mixing a `…spring5` extras module with a Boot-3 app (or vice-versa) yields `NoClassDefFoundError`/dialect-not-found at startup — keep the major versions aligned.

### [1.2] Understand template resolution, modes, and natural templating

Title: A view name resolves to a file via prefix+suffix; the template mode decides parsing; raw templates stay browser-openable.
Description: Returning `"index"` resolves to `classpath:/templates/index.html` (Boot defaults). The **template mode** controls the parser: `HTML` (default, lenient — no XML well-formedness required), `XML`, and the textual modes `TEXT`, `JAVASCRIPT`, `CSS`, plus `RAW` (no processing). Because `th:*` attributes are ordinary custom attributes that browsers ignore, the un-rendered template is a valid, displayable HTML *prototype* (natural templating) — designers can keep working in the same file.

**Template (natural prototype + live values):**

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<body>
  <!-- "Jane Doe" shows when opened raw; replaced at render with ${user.name} -->
  <h1 th:text="${user.name}">Jane Doe</h1>
</body>
</html>
```

Pitfall: The `xmlns:th` declaration is only there to satisfy XML/IDE validators in HTML mode — it is not required for processing and never appears in output. Don't rely on XML well-formedness in HTML mode (unclosed `<br>`/`<img>` are fine); switch to `XML` mode only when you truly need strict parsing.

### [1.3] The Standard/SpringStandard dialect and the `th:` namespace

Title: `th:*` attributes come from the Standard Dialect; with Spring, the SpringStandard Dialect swaps OGNL for SpEL and adds form/`#mvc`/`#themes` support.
Description: Core Thymeleaf ships the **Standard Dialect** (`th:` prefix, OGNL expressions). The Spring module's **SpringStandard Dialect** evaluates `${...}`/`*{...}` with **Spring EL (SpEL)** instead, enables bean access (`${@myBean.method()}`), adds form processors (`th:field`, `th:errors`, `th:errorclass`), and the `#mvc.uri(...)` / `#themes.code(...)` expression objects. `SpringTemplateEngine` registers this dialect for you.

**Template (SpEL bean call, Spring-only):**

```html
<span th:text="${@greetingService.greet(user.name)}">Hi</span>
```

Pitfall: SpEL ≠ OGNL. Some OGNL-isms from non-Spring Thymeleaf tutorials (e.g. certain projection/selection syntaxes) don't translate. When in a Spring app, write SpEL.

---

## Chapter 2 — Standard Expressions

### [2.1] Read the model with variable expressions `${...}`

Title: `${...}` evaluates a SpEL/OGNL expression against the context (model + request params + a few base objects).
Description: This is the workhorse. `${user.name}` navigates the `user` model attribute; `${user.roles[0]}`, `${map['key']}`, method calls, and the base objects `${#locale}`, `${#ctx}`, `${#vars}` all work. With Spring it's SpEL, so `?.` safe-navigation and elvis are available.

```html
<p th:text="${user.email}">e@x.com</p>
<p th:text="${order.total} + ' USD'">0 USD</p>
<p th:text="${user.address?.city} ?: 'N/A'">N/A</p>   <!-- null-safe -->
```

Pitfall: An unresolvable property doesn't throw by default — it renders empty (or null), so a typo in `${usr.name}` silently blanks the element. Verify the rendered output, and prefer `?:`/`?.` for genuinely nullable paths rather than relying on silent blanks.

### [2.2] Select on an object with `*{...}` and `th:object`

Title: `th:object="${obj}"` selects a base object; inside it, `*{prop}` is shorthand for `${obj.prop}`.
Description: Selection expressions reduce repetition and are the basis of form binding (3.4 / 7.2). Within an element bearing `th:object`, every `*{...}` resolves against that object.

```html
<div th:object="${user}">
  <span th:text="*{firstName}">First</span>
  <span th:text="*{lastName}">Last</span>
  <span th:text="*{email}">e@x.com</span>
</div>
```

Pitfall: You cannot nest `th:object`, and `th:object` must be a plain variable expression naming a single model attribute (no property navigation like `th:object="${user.address}"` for form binding). Outside any `th:object`, `*{...}` evaluates against the whole context root, not a selected object.

### [2.3] Externalize text with message expressions `#{...}`

Title: `#{key}` pulls a translation from `messages.properties` (locale-resolved); parameters and the `#{${dynamicKey}}` form are supported.
Description: Keeps copy out of templates and enables i18n. Boot's `MessageSource` reads `messages[_xx].properties`. Pass params positionally.

`messages.properties` / `messages_es.properties`:

```properties
home.welcome=Welcome, {0}!
```

```html
<h1 th:text="#{home.welcome(${user.name})}">Welcome, user!</h1>
<!-- key chosen dynamically (preprocessing, see 6.4): -->
<span th:text="#{__${msgKey}__}">…</span>
```

Pitfall: A missing key renders as `??home.welcome_en??` (a visible marker), not an exception — easy to ship. Grep templates for `#{` against your `.properties` keys, and add a CI check if i18n matters.

### [2.4] Build URLs with link expressions `@{...}`

Title: `@{/path}` builds context-relative URLs, encodes query/path params, and is the hook for CSRF/URL-rewriting.
Description: Always build app URLs with `@{...}` rather than hand-concatenating: it prepends the servlet context path, URL-encodes parameters, and lets `RequestDataValueProcessor` (7.4) post-process the URL. Path variables use `{name}`.

```html
<a th:href="@{/users/{id}(id=${user.id})}">profile</a>
<a th:href="@{/search(q=${query},page=${page})}">next</a>   <!-- ?q=…&page=… -->
<link th:href="@{/css/app.css}" rel="stylesheet"/>
<script th:src="@{/js/app.js}"></script>
```

Pitfall: Don't string-build URLs (`th:href="'/users/' + ${id}"`) — you lose context-path prefixing, encoding, and security post-processing. Server-side `@{...}` is for *server* URLs; it does not rewrite hashes for client-side SPA routers.

### [2.5] Reference markup with fragment expressions `~{...}`

Title: `~{template :: fragment}` is a first-class value: pass it into `th:insert`/`th:replace`, into fragment parameters, or hold it in a variable.
Description: 3.x makes fragments expressions. Forms: `~{tpl :: fragName}` (named), `~{tpl :: #cssId}` / `~{tpl :: selector}` (markup selector), `~{:: selector}` (a fragment of the *current* template), `~{this :: frag}`, and `~{}` (the empty fragment — renders nothing). This powers parameterizable layouts (5.2/5.3).

```html
<div th:replace="~{fragments/layout :: header}">…</div>
<div th:insert="~{:: #localPart}">…</div>            <!-- from this template -->
<div th:replace="${showAside} ? ~{:: aside} : ~{}">…</div>  <!-- conditional, empty -->
```

Pitfall: In 3.1 the wrapping `~{…}` is required — bare `th:replace="fragments/layout :: header"` is the deprecated 3.0 form. Always wrap.

### [2.6] Literals, operators, conditional/elvis, and the no-op `_`

Title: Combine text literals, arithmetic/boolean/comparison operators, the ternary `?:`, the elvis default `?:`, and `_` (do nothing) inside any expression.
Description: Useful for small in-template logic without a helper. Truthiness for `th:if`: non-null, boolean `true`, non-zero number, and strings that aren't `"false"/"off"/"no"` are *true*. The no-op `_` means "leave the prototype value" — handy for natural templating.

```html
<p th:text="'Total: ' + ${order.total} + ' USD'">…</p>
<p th:text="${count > 0} ? 'In stock' : 'Sold out'">…</p>
<p th:text="${user.nickname} ?: 'Anonymous'">…</p>
<span th:text="${user.vip} ? 'VIP' : _">regular</span>   <!-- false → keep "regular" -->
```

Pitfall: `?:` is overloaded — `a ? b : c` (ternary) vs `a ?: b` (elvis). The elvis default fires on **null**, not on empty string or `false`; use `${#strings.isEmpty(x)} ? d : x` when you also want to default on blank.

---

## Chapter 3 — Setting content & attributes

### [3.1] Set escaped text with `th:text` (and unescaped `th:utext` — XSS)

Title: `th:text` sets the element body **HTML-escaped** (safe default); `th:utext` sets it **raw** — only for trusted markup.
Description: `th:text="${bio}"` turns `<b>` into `&lt;b&gt;` — exactly what you want for user data. `th:utext` injects the value verbatim; use it solely for content you control or have sanitized (e.g. server-rendered Markdown you trust).

```html
<p th:text="${comment.body}">escaped &amp; safe</p>
<div th:utext="${trustedHtmlSnippet}">raw &lt;b&gt;markup&lt;/b&gt;</div>
```

Pitfall: `th:utext="${userInput}"` is a classic stored-XSS vector. If you must render user HTML, sanitize server-side (e.g. OWASP Java HTML Sanitizer) **before** putting it in the model, and document why `th:utext` is safe there.

### [3.2] Set attributes with `th:attr` and the attribute shortcuts

Title: Prefer the typed shortcuts (`th:href`, `th:src`, `th:value`, `th:class`, `th:id`, `th:title`, `th:alt`…) over the generic `th:attr`.
Description: Each shortcut sets one HTML attribute from an expression and (for URL/value attributes) participates in security post-processing. `th:attr="a=…,b=…"` sets arbitrary/multiple attributes when no shortcut exists.

```html
<img th:src="@{/img/{f}(f=${file})}" th:alt="${caption}" />
<input th:value="${user.email}" th:title="#{email.hint}" />
<a th:href="@{/p/{id}(id=${p.id})}" th:class="${p.featured} ? 'card hot' : 'card'">…</a>
<!-- generic, rare: -->
<svg th:attr="data-x=${x},aria-label=#{chart.label}">…</svg>
```

Pitfall: Use `th:value` (not `value`) so the conversion service and `RequestDataValueProcessor` apply. Hand-written `value="${x}"` is treated as a literal string `"${x}"` — Thymeleaf only processes `th:*` attributes, never plain ones.

### [3.3] Append with `th:classappend`/`th:styleappend`; boolean attributes

Title: `th:classappend` adds to an existing static `class` without replacing it; boolean attributes (`th:checked`, `th:disabled`, `th:selected`, `th:readonly`) emit the attribute only when the expression is truthy.
Description: Lets you keep base classes in plain HTML (still visible in the prototype) and add state classes dynamically. Boolean attributes render `checked="checked"` when true and **omit** the attribute entirely when false — the correct HTML semantics.

```html
<div class="card" th:classappend="${p.featured} ? ' featured'">…</div>
<input type="checkbox" th:checked="${user.subscribed}" />
<button th:disabled="${!form.valid}">Save</button>
<option th:selected="${o.id == selectedId}">…</option>
```

Pitfall: Don't set `th:class` *and* keep a conflicting static `class` — `th:class` overwrites. Use `th:classappend` to augment, `th:class` to replace.

### [3.4] Bind form fields with `th:object`/`th:field`

Title: Under `th:object="${cmd}"`, `th:field="*{prop}"` auto-generates matching `id`, `name`, and `value` and applies the conversion service.
Description: `th:field` is the backbone of Spring form binding (full detail in 7.2). It reads/writes the form-backing bean and keeps `id`/`name` consistent with the property path so binding round-trips on submit.

```html
<form th:object="${userForm}" th:action="@{/users}" method="post">
  <input type="text"     th:field="*{firstName}" />   <!-- id=name="firstName" -->
  <input type="email"    th:field="*{email}" />
  <input type="checkbox" th:field="*{subscribed}" />
  <button type="submit">Create</button>
</form>
```

Pitfall: `th:field` requires the backing object in the model (e.g. `@ModelAttribute` / `model.addAttribute("userForm", new UserForm())`) — otherwise you get a binding/`BindingResult`-missing error. Inside `th:each`, you must index with preprocessing: `th:field="*{rows[__${st.index}__].qty}"` (see 6.4 / 7.2), because SpEL won't evaluate a variable inside `[ ]`.

---

## Chapter 4 — Iteration & conditionals

### [4.1] Iterate with `th:each` and the status variable

Title: `th:each="item : ${items}"` repeats the host element per element; add a status var for `index`/`count`/`size`/`even`/`odd`/`first`/`last`/`current`.
Description: Works over `Iterable`, arrays, `Map` (yields `Map.Entry`), and `Stream`. The status variable is declared as the second name; if omitted, Thymeleaf provides `${itemStat}` (the iter var name + `Stat`).

```html
<tr th:each="p, stat : ${products}"
    th:class="${stat.odd} ? 'row-odd' : 'row-even'">
  <td th:text="${stat.count}">1</td>
  <td th:text="${p.name}">Name</td>
  <td th:text="${#numbers.formatCurrency(p.price)}">$0</td>
</tr>
<p th:if="${#lists.isEmpty(products)}">No products.</p>
```

Pitfall: `index` is **0-based**, `count` is **1-based** — mixing them up off-by-ones your numbering. For empty collections the loop simply renders nothing (no error); add an explicit empty-state with `th:if="${#lists.isEmpty(...)}"`.

### [4.2] Branch with `th:if`/`th:unless`

Title: `th:if` keeps the element (and its `th:*`) when truthy; `th:unless` is its negation — clearer than `th:if="${!…}"`.
Description: When false, the element and its subtree are removed from the output entirely. Truthiness rules per 2.6. Pair `th:if`/`th:unless` for an either/or without duplicating the condition.

```html
<span th:if="${user.admin}" class="badge">Admin</span>
<a th:unless="${user.admin}" th:href="@{/upgrade}">Upgrade</a>
```

Pitfall: `th:if` removes the node — it is *not* `display:none`; the markup is gone from the response (good for security, but client JS can't toggle it). For mutually exclusive branches prefer `th:switch` (4.3) over stacked `th:if`s.

### [4.3] Multi-branch with `th:switch`/`th:case`

Title: `th:switch="${expr}"` + `th:case="…"` renders the first matching case; `th:case="*"` is the default.
Description: Cleaner than a ladder of `th:if`s when dispatching on one value. Exactly one case renders.

```html
<div th:switch="${user.role}">
  <span th:case="'ADMIN'">Administrator</span>
  <span th:case="'EDITOR'">Editor</span>
  <span th:case="*">Member</span>
</div>
```

Pitfall: Only the **first** matching `th:case` is shown; order matters and `th:case="*"` should be last. String cases need quotes (`'ADMIN'`) — `th:case="ADMIN"` is a variable expression, usually not what you want.

---

## Chapter 5 — Fragments, composition & layouts

### [5.1] Define and include fragments with `th:fragment` + `th:insert`/`th:replace`

Title: Mark reusable markup with `th:fragment="name"`; pull it in with `th:insert` (keeps host tag, nests fragment inside) or `th:replace` (host tag is replaced by the fragment).
Description: The core composition mechanism. `th:replace` is usually what you want for headers/footers/nav (no extra wrapper); `th:insert` when you want the host element to remain as a container. `th:include` (insert *contents only*) is **removed in 3.1** — use `th:insert`/`th:replace`.

`templates/fragments/layout.html`:

```html
<header th:fragment="siteHeader">
  <nav>…</nav>
</header>
```

Using it:

```html
<body>
  <div th:replace="~{fragments/layout :: siteHeader}">prototype header</div>
  <!-- vs keep the <div> wrapper: -->
  <div th:insert="~{fragments/layout :: siteHeader}">…</div>
</body>
```

Pitfall: `th:insert` vs `th:replace` differ by one wrapper element — picking the wrong one yields a stray/missing `<div>`. And remember the 3.1 wrapping: `~{fragments/layout :: siteHeader}`, not `fragments/layout :: siteHeader`.

### [5.2] Parameterize fragments and pass markup with `~{...}`

Title: Declare `th:fragment="card(title, body)"` and call it with values **or with fragment expressions** so you can inject markup, not just strings.
Description: Parameters make fragments composable. Passing `~{::someSelector}` lets the caller hand a *chunk of its own markup* to the fragment — the foundation of layout/decorator patterns (5.3).

`fragments/ui.html`:

```html
<div th:fragment="card(title, content)" class="card">
  <h3 th:text="${title}">Title</h3>
  <div th:replace="${content}">content slot</div>
</div>
```

Caller:

```html
<div th:replace="~{fragments/ui :: card('Stats', ~{:: #statsBody})}">…</div>
<section id="statsBody"> … caller-owned markup … </section>
```

Pitfall: A fragment parameter that is a *fragment expression* must be inserted with `th:replace`/`th:insert` (`th:replace="${content}"`), not printed with `th:text`. Passing a plain string where the fragment expects markup (or vice-versa) renders the literal or fails.

### [5.3] Build a layout (decorator) with a parameterizable base fragment

Title: Put the page skeleton in a base fragment with slots; each page calls it, passing its `title`/`content`/`scripts` as fragment expressions. (Or add the **Thymeleaf Layout Dialect** for `layout:decorate`.)
Description: Two idioms. **(A) Pure Thymeleaf** — a `layout(title, content)` fragment; pages `th:replace` it with `~{:: title}` / `~{:: content}`. **(B) Layout Dialect** (`nz.net.ultraq.thymeleaf:thymeleaf-layout-dialect`) — pages `layout:decorate="~{base}"` and override `layout:fragment` blocks; more ergonomic for deep hierarchies.

Base (idiom A), `templates/base.html`:

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" th:fragment="page(title, content)">
<head><title th:replace="${title}">T</title></head>
<body>
  <div th:replace="~{fragments/layout :: siteHeader}">…</div>
  <main th:replace="${content}">page content</main>
</body>
</html>
```

Page:

```html
<html xmlns:th="http://www.thymeleaf.org"
      th:replace="~{base :: page(~{:: title}, ~{:: main})}">
<head><title>Dashboard</title></head>
<body><main>…dashboard…</main></body>
</html>
```

Pitfall: The Layout Dialect is a separate dependency and dialect — don't write `layout:decorate` without adding it (you'll get "unknown attribute"). For one or two simple pages, idiom A avoids the extra dependency.

### [5.4] Strip prototype markup with `th:remove`

Title: `th:remove` deletes parts of the template at render: `all` (tag+body), `body`, `tag` (unwrap — keep children), `all-but-first`, `none`.
Description: Lets you keep multiple sample rows in the static prototype (so designers see a realistic table) while emitting only the data-driven ones. `all-but-first` on a repeated container keeps one prototype example and drops the rest.

```html
<table>
  <tr th:each="p : ${products}"><td th:text="${p.name}">Real row</td></tr>
  <tr th:remove="all"><td>Prototype-only sample row</td></tr>
</table>

<ul th:remove="all-but-first">
  <li>kept as prototype</li>
  <li>dropped at render</li>
</ul>
```

Pitfall: `th:remove="tag"` *unwraps* (removes the element but keeps its children) — handy to avoid an extra `<div>`, but easy to confuse with `all` (which removes children too). Read the value carefully.

---

## Chapter 6 — Local variables, utilities & inlining

### [6.1] Declare local variables with `th:with`

Title: `th:with="x=${expr}, y=${other}"` defines variables scoped to the element subtree — compute once, reuse, and keep templates readable.
Description: Avoids recomputing an expression and names intermediate values. Later vars in the same `th:with` can reference earlier ones.

```html
<div th:with="total=${order.subtotal + order.tax}, hasItems=${!#lists.isEmpty(order.items)}">
  <p th:if="${hasItems}" th:text="${#numbers.formatCurrency(total)}">$0</p>
</div>
```

Pitfall: `th:with` variables are scoped to the declaring element — they don't leak to siblings. For a value needed across the whole page, prefer adding it to the model in the controller.

### [6.2] Use the utility/expression objects (`#strings`, `#temporals`, `#lists`, …)

Title: The `#`-prefixed objects provide null-safe helpers: `#strings`, `#numbers`, `#temporals` (java.time) / `#dates` (legacy `Date`), `#lists`/`#sets`/`#maps`/`#arrays`/`#aggregates`, `#bools`, `#objects`, `#messages`, `#ids`, `#uris`, `#execInfo`, `#conversions`.
Description: Use them for formatting and collection checks instead of inlining Java — and because 3.1 forbids most direct `java.*`/`jakarta.*` calls (8.5), these are often the *only* sanctioned way. `#temporals` requires the `thymeleaf-extras-java8time` module (bundled with the Spring 6 starter).

```html
<span th:text="${#strings.abbreviate(post.body, 120)}">…</span>
<span th:text="${#temporals.format(order.createdAt, 'dd MMM yyyy HH:mm')}">…</span>
<span th:text="${#numbers.formatDecimal(p.rating, 1, 1)}">0.0</span>
<p th:if="${#lists.isEmpty(cart.items)}">Empty cart</p>
<label th:for="${#ids.next('opt')}">…</label>   <!-- unique ids in loops -->
```

Pitfall: Use `#temporals` for `java.time` types and `#dates` for legacy `java.util.Date` — calling the wrong one throws. And in 3.1, `${someString.toUpperCase()}` may be blocked by the class restriction; prefer `${#strings.toUpperCase(someString)}`.

### [6.3] Inline with `[[...]]`/`[(...)]` and `th:inline="javascript"`

Title: Outside attributes, print model values in text with `[[${x}]]` (escaped) / `[(${x})]` (unescaped); in `<script>`/`<style>`, enable `th:inline="javascript"`/`"css"` to safely serialize model data.
Description: Inlining avoids wrapper `<span th:text>`s in flowing text. For JS, `th:inline="javascript"` serializes the value as a valid JS literal (objects → JSON, strings quoted/escaped) — far safer than string-concatenating into a script.

```html
<p>Hello, [[${user.name}]]! You have [[${count}]] messages.</p>

<script th:inline="javascript">
  const user = /*[[${user}]]*/ {};        // → const user = {"id":1,"name":"Jane"};
  const csrf = /*[[${_csrf.token}]]*/ '';
</script>
```

Pitfall: `[[...]]`/`[(...)]` are *text* inlining and must be **outside** tags/attributes — inside an attribute use `th:*`. The `/*[[…]]*/ default` comment trick keeps the script valid when opened as a static prototype; don't drop the trailing default literal.

### [6.4] Preprocess with `__${...}__`

Title: `__${expr}__` is evaluated **before** the surrounding expression — use it to build dynamic message keys, dynamic property paths, and (critically) array indices for `th:field` in loops.
Description: Spring EL won't evaluate a variable inside `[ ]`, so binding a list of form rows requires preprocessing the index. Also used for locale-dependent message keys.

```html
<!-- form rows bound to a List<Row> on the command object -->
<tr th:each="row, st : *{rows}">
  <td><input th:field="*{rows[__${st.index}__].quantity}" /></td>
</tr>

<!-- dynamic i18n key -->
<span th:text="#{__${'label.' + status}__}">…</span>
```

Pitfall: Preprocessing runs once, early — don't put side-effecting or request-dependent logic in it. The double underscores must hug the expression: `__${x}__`, not `__ ${x} __`.

---

## Chapter 7 — Spring integration

### [7.1] Return a view from a `@Controller` and pass the model

Title: A `@Controller` method returns the **view name** (a String) and contributes data via `Model`/`@ModelAttribute`; `@RestController` does **not** render views.
Description: Thymeleaf is for server-rendered pages, so use `@Controller`. Add attributes to `Model`; they become `${…}` in the template. Returning `"users/list"` resolves to `templates/users/list.html`. You can also return a **fragment** directly: `return "users/list :: rows";` (or with a markup selector `:: #rows`).

```java
@Controller
@RequestMapping("/users")
class UserController {
    private final UserService users;
    UserController(UserService users) { this.users = users; }

    @GetMapping
    String list(Model model) {
        model.addAttribute("products", users.findAll());
        return "users/list";                 // → templates/users/list.html
    }

    @GetMapping("/table")
    String rows(Model model) {
        model.addAttribute("products", users.findAll());
        return "users/list :: #rows";        // render only the #rows fragment (e.g. for htmx/AJAX)
    }
}
```

Pitfall: `@RestController` (or `@ResponseBody`) serializes the return value as JSON — returning `"index"` then literally writes the string `index`. Use plain `@Controller`. For nullable model values, add an empty default so the template branches cleanly rather than NPE-ing in an expression.

### [7.2] Handle a form: binding, validation errors, `#fields`, `th:errors`

Title: Bind with `th:object`+`th:field`; validate with `@Valid` + `BindingResult`; surface errors with `th:errors="*{field}"`, `th:errorclass`, and the `#fields` object (`hasErrors`, `errors`, `globalErrors`, `detailedErrors`).
Description: The end-to-end Spring form flow. The GET seeds an empty command bean; the POST validates and, on error, returns the same view (the populated command + `BindingResult` are already in the model, so errors render). `th:errorclass` adds a CSS class to a field only when it has errors; `#fields.hasErrors('*')` checks all fields, `'global'` checks object-level errors.

Controller:

```java
@GetMapping("/new")
String form(Model model) {
    model.addAttribute("userForm", new UserForm());
    return "users/form";
}

@PostMapping
String create(@Valid @ModelAttribute("userForm") UserForm form,
              BindingResult binding, Model model) {
    if (binding.hasErrors()) return "users/form";   // re-render with errors
    users.create(form);
    return "redirect:/users";
}
```

Template `users/form.html`:

```html
<form th:object="${userForm}" th:action="@{/users}" method="post">
  <div>
    <input type="text" th:field="*{firstName}" th:errorclass="is-invalid"/>
    <span class="error" th:if="${#fields.hasErrors('firstName')}"
          th:errors="*{firstName}">name error</span>
  </div>
  <input type="email" th:field="*{email}" th:errorclass="is-invalid"/>
  <span th:errors="*{email}"></span>

  <ul th:if="${#fields.hasErrors('global')}">
    <li th:each="e : ${#fields.errors('global')}" th:text="${e}">global error</li>
  </ul>
  <button type="submit">Save</button>
</form>
```

Pitfall: On validation failure you must **return the view** (re-render), not redirect — a redirect drops the `BindingResult` and the errors vanish. The `@ModelAttribute` name (`"userForm"`) must match `th:object="${userForm}"` exactly, or binding silently fails.

### [7.3] Format with the conversion service: `${{...}}` and `#conversions`

Title: Double braces `${{value}}` / `*{{value}}` apply the registered Spring `ConversionService`/`Formatter`s; `th:field` applies it automatically; `#conversions.convert(x, T)` converts on demand.
Description: Centralize formatting (dates, money, domain types) in `Formatter` beans and render with `${{…}}` so output and form round-tripping stay consistent. Every `th:field` already runs the conversion service.

Config + template:

```java
@Override public void addFormatters(FormatterRegistry reg) {
    reg.addFormatter(new MoneyFormatter());
    reg.addFormatter(new IsoDateFormatter());
}
```

```html
<p th:text="${order.total}">1234567.5</p>      <!-- raw -->
<p th:text="${{order.total}}">$1,234,567.50</p> <!-- via MoneyFormatter -->
<span th:text="${#conversions.convert(order.placedAt, 'String')}">…</span>
```

Pitfall: `${{x}}` (conversion) ≠ `${x}` (raw `toString`). Forgetting the inner braces shows unformatted values; adding them where no formatter is registered just falls back to `toString`. Keep the *parse* side (form submit) and *print* side using the same formatter so values round-trip.

### [7.4] Auto-include CSRF/hidden fields via `RequestDataValueProcessor`

Title: When you build forms/URLs with `th:action`/`th:href`/`th:src`/`th:field`, Thymeleaf calls Spring's `RequestDataValueProcessor` — which is how Spring Security transparently injects the CSRF hidden field and token.
Description: With Spring Security on the classpath, a `<form th:action="@{/x}" method="post">` automatically gets `<input type="hidden" name="_csrf" .../>` appended after the opening tag — no manual token wiring. `th:href`/`th:src` get `processUrl`; `th:value` gets `processFormFieldValue` (unless `th:field` already handles it).

```html
<!-- CSRF hidden input is auto-added because th:action is used -->
<form th:action="@{/account/delete}" method="post">
  <button>Delete</button>
</form>
```

Pitfall: The auto-CSRF only fires when the form uses `th:action` (so the processor runs). A plain `<form action="/x" method="post">` with no `th:action` gets **no** token → 403. For AJAX, expose the token via inlining (`/*[[${_csrf.token}]]*/`) and send the header.

### [7.5] Guard markup with Spring Security (`sec:authorize`, `sec:authentication`)

Title: With `thymeleaf-extras-springsecurity6`, use `sec:authorize="hasRole('ADMIN')"` to conditionally render and `sec:authentication="name"` to read the principal.
Description: Declarative authorization in the view. `sec:authorize` accepts SpEL web-security expressions (`hasRole`, `hasAuthority`, `isAuthenticated()`, `#authorization.expression(...)`); `sec:authentication` exposes `Authentication` properties (`name`, `principal.username`, `authorities`).

```html
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<body>
  <p>Signed in as <span sec:authentication="name">user</span></p>
  <a sec:authorize="hasRole('ADMIN')" th:href="@{/admin}">Admin panel</a>
  <form sec:authorize="isAuthenticated()" th:action="@{/logout}" method="post">
    <button>Log out</button>
  </form>
</body>
</html>
```

Pitfall: `sec:authorize` controls **rendering only** — it is *not* a substitute for server-side endpoint authorization (`@PreAuthorize`/`SecurityFilterChain`). Hiding a link doesn't protect the route. Match the extras major version to your stack: `…springsecurity6` for Spring Security 6, `…5` for 5.

---

## Chapter 8 — Configuration, 3.1 changes & security

### [8.1] Configure with `spring.thymeleaf.*`

Title: Tune resolution and rendering through `spring.thymeleaf.*` in `application.yml` rather than redefining beans.
Description: The common knobs: `prefix`/`suffix` (resolution), `mode` (HTML/XML/TEXT/…), `encoding`, `cache`, and `check-template-location`. See Appendix B for the full list.

```yaml
spring:
  thymeleaf:
    prefix: classpath:/templates/
    suffix: .html
    mode: HTML
    encoding: UTF-8
    cache: true          # false in dev
```

Pitfall: Changing `prefix`/`suffix` changes how every view name resolves — a wrong value yields `TemplateInputException` for all pages. If templates live outside `classpath:/templates/`, set `prefix` accordingly (and keep the trailing slash).

### [8.2] Cache vs live reload

Title: Keep `spring.thymeleaf.cache=true` in prod; set `false` (or rely on spring-boot-devtools) in dev so template edits show without a restart.
Description: With cache on, the parsed template tree is reused — fast, but edits are ignored until restart. DevTools sets `cache=false` automatically and triggers reloads.

```yaml
# application-dev.yml
spring:
  thymeleaf:
    cache: false
```

Pitfall: Shipping `cache=false` to production re-parses every template on every request — a real throughput hit. Scope `cache: false` to the `dev` profile only.

### [8.3] Migrate off the removed 3.1 web-context objects

Title: Thymeleaf 3.1 **removed** `#request`, `#response`, `#session`, `#servletContext`, `#httpServletRequest`, `#httpSession`. Move the data the template needs into the **model** at the controller; `${param.x}` and `${session.x}` (as maps) remain.
Description: This is the single biggest 3.0→3.1 break. Templates that did `${#httpServletRequest.requestURI}` or `${#session.getAttribute('x')}` will fail. The sanctioned fix is to add exactly the values you need to the model. Request parameters are still readable via `${param.name}`; session attributes via `${session.name}` when an `IWebContext` is active. The new web API abstracts servlet vs reactive behind `IWebExchange`/`IWebRequest`/`IWebSession` (for custom integrations).

Before (3.0) → After (3.1):

```html
<!-- 3.0 (broken in 3.1): -->
<p th:text="${#httpServletRequest.requestURI}">/x</p>

<!-- 3.1: controller adds it -->
<!-- model.addAttribute("currentUri", request.getRequestURI()); -->
<p th:text="${currentUri}">/x</p>

<!-- still fine in 3.1: request params & session map -->
<p th:text="${param.q}">query</p>
<p th:text="${session.cartCount}">0</p>
```

Pitfall: Don't try to re-enable the old objects — they're gone by design (decoupling core from the Servlet API). Audit templates for `#request`/`#session`/`#servletContext`/`#httpServletRequest` when upgrading, and push those reads up into the controller/model.

### [8.4] Non-HTML modes & decoupled template logic

Title: Use `TEXT`/`JAVASCRIPT`/`CSS` modes for non-markup output (emails-as-text, generated JS/CSS), and **decoupled template logic** (`.th.xml`) to keep `th:*` out of pristine HTML.
Description: Textual modes use a special `[# th:…]` syntax instead of attributes. Decoupled logic puts the processing instructions in a sibling `name.th.xml` (matched by `th:ref`/selectors), so the `.html` stays 100% clean for designers. Enable with `setDecoupledTemplateLogicEnabled(true)` (or Boot's resolver setting).

Decoupled — `home.html` (no `th:*`) + `home.th.xml`:

```xml
<!-- home.th.xml -->
<thlogic>
  <attr sel="#greeting" th:text="${user.name}"/>
</thlogic>
```

Pitfall: Decoupled logic and textual modes have sharper edges (selector matching, special syntax) and modest overhead — reach for them only when the clean-HTML or non-HTML requirement is real; the default HTML-attribute mode is simpler.

### [8.5] Security: escaping, expression injection, restricted evaluation

Title: Escape by default (`th:text`), never feed user input into expressions, and know that 3.1 forbids most `java.*`/`javax.*`/`jakarta.*`/`jdk.*` calls from templates.
Description: Three layered defenses. (1) **Output**: `th:text` escapes; treat `th:utext`/`[(...)]` as XSS-sensitive and sanitize trusted-only input. (2) **Expressions**: don't construct `${...}`/`#{...}` from request data (SpEL/expression injection) — pass data as *parameters*, not concatenated into the expression string. (3) **3.1 class restriction**: calling `someString.getClass()`, `T(java.lang.Runtime)`, etc. is blocked — only whitelisted basic types/collections/utilities are allowed, which closes a SpEL-RCE class of bugs. Use the `#`-utility objects (6.2) instead of raw Java.

```html
<p th:text="${comment.body}">escaped</p>                 <!-- safe -->
<span th:text="#{label.greeting(${user.name})}">…</span>  <!-- param, not concatenated -->
```

Pitfall: `th:utext` + user input = stored XSS; `#{${userControlledKey}}` or `${someExprFromUser}` = expression injection. Keep user data in *parameters/values*, never in the *expression grammar*, and prefer `#strings`/`#numbers`/`#temporals` over `java.*` calls (which 3.1 may block outright).

---

## Appendix A — Expression utility objects reference

| Object | Purpose | Example |
|--------|---------|---------|
| `#ctx`, `#vars`, `#locale` | Context, variables map, current `Locale` | `${#locale.language}` |
| `#execInfo` | Template execution info (name, now) | `${#execInfo.templateName}` |
| `#messages` | Programmatic i18n lookup | `${#messages.msg('home.welcome', user.name)}` |
| `#uris` | URL/URI escaping helpers | `${#uris.escapePathSegment(seg)}` |
| `#conversions` | Apply the conversion service | `${#conversions.convert(x,'String')}` |
| `#dates` | Legacy `java.util.Date` format/extract | `${#dates.format(d,'yyyy-MM-dd')}` |
| `#calendars` | Legacy `java.util.Calendar` | `${#calendars.format(c)}` |
| `#temporals` | `java.time` (needs java8time extras) | `${#temporals.format(ldt,'dd MMM yyyy')}` |
| `#numbers` | Number/percent/currency formatting | `${#numbers.formatDecimal(n,1,2)}` |
| `#strings` | Null-safe string ops | `${#strings.abbreviate(s,80)}` |
| `#objects` | Null-default helpers | `${#objects.nullSafe(o,'-')}` |
| `#bools` | Boolean evaluation | `${#bools.isTrue(b)}` |
| `#arrays`, `#lists`, `#sets`, `#maps` | Collection helpers | `${#lists.isEmpty(xs)}`, `${#maps.containsKey(m,'k')}` |
| `#aggregates` | sum/avg over collections | `${#aggregates.sum(prices)}` |
| `#ids` | Unique `id` generation in loops | `${#ids.next('row')}` / `${#ids.prev('row')}` |
| **Spring-only** | | |
| `#fields` | Form binding errors | `${#fields.hasErrors('email')}` |
| `#themes` | `spring:theme` equivalent | `${#themes.code('css.path')}` |
| `#mvc` | Build URLs from controller methods | `${(#mvc.uri('UC#m').build())}` |
| `#authentication`, `#authorization` | Security (via extras) | `${#authorization.expression('hasRole(''ADMIN'')')}` |

> **3.1 note:** request/response/session/servletContext objects (`#request`, `#response`, `#session`, `#servletContext`, `#httpServletRequest`, `#httpSession`) are **removed** — see 8.3.

## Appendix B — `spring.thymeleaf.*` properties reference

| Property | Default | Meaning |
|----------|---------|---------|
| `spring.thymeleaf.prefix` | `classpath:/templates/` | View-name prefix for resolution |
| `spring.thymeleaf.suffix` | `.html` | View-name suffix |
| `spring.thymeleaf.mode` | `HTML` | Template mode (`HTML`/`XML`/`TEXT`/`JAVASCRIPT`/`CSS`/`RAW`) |
| `spring.thymeleaf.encoding` | `UTF-8` | Template/charset encoding |
| `spring.thymeleaf.cache` | `true` | Cache parsed templates (set `false` in dev) |
| `spring.thymeleaf.check-template` | `true` | Verify a template exists before rendering |
| `spring.thymeleaf.check-template-location` | `true` | Verify the templates location exists at startup |
| `spring.thymeleaf.servlet.content-type` | `text/html` | Response content type |
| `spring.thymeleaf.enabled` | `true` | Enable Thymeleaf MVC auto-config |
| `spring.thymeleaf.view-names` | (all) | Comma-list of view names this resolver handles |
| `spring.thymeleaf.excluded-view-names` | (none) | View names to exclude |
| `spring.thymeleaf.template-resolver-order` | (last) | Order vs other view resolvers |
| `spring.thymeleaf.reactive.max-chunk-size` | `0` | (WebFlux) response chunk size |

## Appendix C — Thymeleaf 3.0 → 3.1 migration notes & version table

**Breaking / notable changes in 3.1:**

- **Web-context objects removed**: `#request`, `#response`, `#session`, `#servletContext`, `#httpServletRequest`, `#httpSession` no longer exist in expressions. Move needed values into the **model**; `${param.*}` and `${session.*}` (maps) remain. (8.3)
- **Class-access restriction**: expressions may no longer freely call into `java.*`, `javax.*`, `jakarta.*`, `jdk.*` and similar core packages (method calls and `T(...)` static refs). Only a whitelist of basic types/collections/common utilities is permitted — use the `#`-utility objects instead (8.5). This hardens against SpEL/OGNL RCE.
- **New servlet-agnostic web API**: `IWebApplication`, `IWebExchange`, `IWebRequest`, `IWebSession` abstract over `javax.*` and `jakarta.*` (and reactive), so core no longer depends on the Servlet API.
- **Spring/JDK split**: `thymeleaf-spring6` (Spring 6, JDK 17+) and `thymeleaf-spring5` (Spring 5); security extras `…springsecurity6` / `…springsecurity5`. Support for Spring < 5 dropped.
- **`th:include` removed**: use `th:insert`/`th:replace`.
- **Unwrapped fragment selectors deprecated**: write `th:replace="~{tpl :: frag}"`, not `th:replace="tpl :: frag"`.

**Version cheat-sheet:**

| You are on | Use |
|------------|-----|
| Spring Boot 3 / Spring 6 / JDK 17+ | `thymeleaf-spring6` + `thymeleaf-extras-springsecurity6` (Thymeleaf 3.1.x) |
| Spring Boot 2 / Spring 5 | `thymeleaf-spring5` + `thymeleaf-extras-springsecurity5` (Thymeleaf 3.0.x/3.1.x) |
| `java.time` formatting (`#temporals`) | `thymeleaf-extras-java8time` (bundled with the Spring 6 starter) |
| `layout:decorate` layouts | add `nz.net.ultraq.thymeleaf:thymeleaf-layout-dialect` |

**Current stable:** Thymeleaf **3.1.5.RELEASE** (2026-04-22). Prefer it for new work; pin the matching Spring/Security extras to your framework major version.
