---
name: thymeleaf
description: Use when you need to write, review, debug, configure, or refactor server-side templates that use Thymeleaf — the natural-templating engine for Spring MVC / Spring Boot that renders HTML, XML, text, JavaScript, and CSS from a context model. Covers the five Standard Expression types (variable ${...}, selection *{...}, message #{...}, link @{...}, fragment ~{...}), content & attributes (th:text vs th:utext and XSS, th:attr and the th:href/th:src/th:value/th:class shortcuts, th:classappend/th:styleappend, boolean attributes th:checked/th:disabled), iteration & conditionals (th:each + status variable, th:if/th:unless, th:switch/th:case), fragments & layouts (th:fragment, th:insert vs th:replace, parameterizable fragments, fragment expressions ~{::selector}/~{this::...}/~{}, th:remove, decorator layouts and the layout dialect), local variables (th:with), utility/expression objects (#strings, #numbers, #temporals/#dates, #lists/#maps/#aggregates, #bools, #objects, #messages, #ids, #conversions, #fields, #mvc, #themes), inlining ([[...]]/[(...)], th:inline="javascript"/"css"), preprocessing __${...}__, and the full Spring integration: @Controller → view, Model/@ModelAttribute, form binding (th:object + th:field), validation errors (th:errors, th:errorclass, #fields.hasErrors/errors/globalErrors/detailedErrors), the conversion service (${{...}}, *{{...}}, #conversions), RequestDataValueProcessor + automatic CSRF hidden fields, and Spring Security tags (thymeleaf-extras-springsecurity6: sec:authorize, sec:authentication). Targets Thymeleaf 3.1.x (current stable 3.1.5.RELEASE) with the thymeleaf-spring6 / thymeleaf-spring5 split and the Thymeleaf 3.1 breaking changes (removal of #request/#response/#session/#servletContext/#httpServletRequest/#httpSession, the java.*/javax.*/jakarta.* class-access restriction, th:include removal, mandatory ~{...} fragment-expression wrapping) and real pitfalls (XSS via th:utext, expression injection, th:field inside th:each needing __${stat.index}__, validation re-render vs redirect, dev cache, template resolution errors). Triggers for requests such as: Add a Thymeleaf view / convert this JSP to Thymeleaf; Why is my th:text empty / template not found (TemplateInputException); Build a reusable header/footer fragment or a layout/decorator; Bind and validate a Spring form (th:object/th:field/th:errors); Show validation errors / field error CSS; Add CSRF to a Thymeleaf form; Hide a menu item with Spring Security (sec:authorize); Format dates/money in a template; Inline model data into JavaScript; Migrate Thymeleaf 3.0 → 3.1 (request/session removed); Configure spring.thymeleaf.* (cache, prefix, mode); Set up Thymeleaf in Spring Boot.
license: Apache-2.0
metadata:
  author: The Thymeleaf Team (thymeleaf.org, Apache-2.0); skill synthesized from the official Thymeleaf documentation (Using Thymeleaf, Thymeleaf + Spring, What's new in 3.1)
  version: 1.0.0
  source_version: Thymeleaf 3.1.x (current stable 3.1.5.RELEASE, 2026-04)
  source: https://www.thymeleaf.org/documentation.html
---
# Thymeleaf — Natural Server-Side Templates for HTML, XML, Text, JS & CSS

Write, review, debug, and refactor server-side templates that use Thymeleaf by applying the official Thymeleaf documentation. Thymeleaf is a **server-side template engine**: it processes a template (a valid HTML/XML/text document carrying `th:*` attributes) against a request-scoped context model and emits the final markup. Templates are *natural* — because `th:*` attributes are inert in a browser, the raw `.html` opens as a coherent design prototype, so designers and engineers share one file. With Spring, the SpringStandard dialect evaluates expressions as **SpEL** and adds form binding, validation, conversion, CSRF, and security tags.

**Target version:** Thymeleaf **3.1.x** (current stable **3.1.5.RELEASE**, 2026-04). Core `org.thymeleaf:thymeleaf`; Spring integration `org.thymeleaf:thymeleaf-spring6` (Spring 6 / Boot 3, JDK 17+) or `thymeleaf-spring5` (Spring 5 / Boot 2); security tags `org.thymeleaf.extras:thymeleaf-extras-springsecurity6`. **3.1 is a behavioral break from 3.0** (removed web-context objects, class-access restriction, `th:include` removal, mandatory `~{...}` fragment wrapping) — see the reference's Chapter 8 and Appendix C.

**What is covered in this Skill?** (organized by the reference's 8 chapters)

- **Setup & model** (Ch 1): `spring-boot-starter-thymeleaf`; template resolution (`prefix`+view+`suffix`), template modes (HTML/XML/TEXT/JAVASCRIPT/CSS/RAW), natural templating; the Standard vs SpringStandard dialect (SpEL, bean access, `#mvc`/`#themes`)
- **Standard Expressions** (Ch 2): variable `${...}`, selection `*{...}` + `th:object`, message `#{...}`, link `@{...}`, fragment `~{...}`; literals, operators, ternary/elvis, no-op `_`
- **Content & attributes** (Ch 3): `th:text` vs `th:utext` (escaping/XSS), `th:attr` and the typed shortcuts (`th:href`/`th:src`/`th:value`/`th:class`/`th:id`…), `th:classappend`/`th:styleappend`, boolean attributes, `th:object`/`th:field`
- **Iteration & conditionals** (Ch 4): `th:each` + status variable (`index`/`count`/`size`/`even`/`odd`/`first`/`last`), `th:if`/`th:unless`, `th:switch`/`th:case`
- **Fragments, composition & layouts** (Ch 5): `th:fragment` + `th:insert`/`th:replace`, parameterizable fragments, fragment expressions (`~{::selector}`, `~{this::...}`, `~{}`), decorator layouts (pure Thymeleaf + the layout dialect), `th:remove`
- **Local variables, utilities & inlining** (Ch 6): `th:with`; utility objects (`#strings`/`#numbers`/`#temporals`/`#dates`/`#lists`/`#maps`/`#aggregates`/`#bools`/`#objects`/`#messages`/`#ids`/`#conversions`); inlining `[[...]]`/`[(...)]` and `th:inline="javascript"/"css"`; preprocessing `__${...}__`
- **Spring integration** (Ch 7): `@Controller` → view + `Model`/`@ModelAttribute`; form binding + validation (`th:object`/`th:field`/`th:errors`/`th:errorclass`/`#fields`); conversion service (`${{...}}`/`*{{...}}`/`#conversions`); `RequestDataValueProcessor` + automatic CSRF; Spring Security tags (`sec:authorize`/`sec:authentication`)
- **Configuration, 3.1 changes & security** (Ch 8): `spring.thymeleaf.*` (cache/prefix/suffix/mode/encoding); dev cache vs reload; migrating off the removed 3.1 web-context objects; non-HTML modes & decoupled template logic; escaping, expression injection, and the 3.1 class restriction

## Constraints

Thymeleaf renders at request time. The rendered HTML (browser "view source", or a `MockMvc`/`WebTestClient` body), the resolved template path, and the bound model are the sources of truth.

- **MANDATORY**: After template/controller changes, run the app (or a `@WebMvcTest`/MockMvc slice) and inspect the **rendered output**, not the source template — silent empty `th:text`, unresolved fragments, and wrong escaping only appear at render time.
- **TEMPLATE RESOLUTION**: A view name resolves to `prefix + viewName + suffix` (Boot default `classpath:/templates/` + `.html`). `TemplateInputException: Error resolving template` ⇒ the file isn't on that path or the name/suffix is wrong. Check `spring.thymeleaf.prefix`/`suffix` and the actual file location.
- **CACHE IN DEV**: Templates are cached by default. Set `spring.thymeleaf.cache=false` (or use spring-boot-devtools) while iterating; keep cache **on** in production.
- **ESCAPE BY DEFAULT**: Use `th:text` (escaped). Reserve `th:utext`/`[(...)]` for **trusted/sanitized** markup only — `th:utext` of user input is stored XSS. Never build SpEL/`#{}` keys from user input (expression injection).
- **3.1 WEB-CONTEXT REMOVALS**: `#request`/`#response`/`#session`/`#servletContext`/`#httpServletRequest`/`#httpSession` are **gone** in 3.1. Put what the template needs into the **model** at the controller; `${param.x}` and `${session.x}` (maps) remain.
- **FRAGMENTS**: Wrap fragment expressions — `th:replace="~{footer :: copy}"`, not the deprecated `th:replace="footer :: copy"`. `th:include` is removed; use `th:insert`/`th:replace`.
- **`th:field`**: Needs a form-backing object in the model under `th:object`; inside `th:each`, index with preprocessing — `*{rows[__${st.index}__].prop}`. On validation failure **return the view** (re-render) — never redirect, or the `BindingResult`/errors vanish.
- **`@Controller`, NOT `@RestController`**: views render only from `@Controller` methods returning a view name; `@RestController`/`@ResponseBody` serializes the string instead.
- **VERSION AWARENESS**: Match `thymeleaf-spring6` vs `…spring5` and `…springsecurity6` vs `…5` to the project's Spring/Spring Security major version; `#temporals` needs the java8time extras (bundled with the Spring 6 starter).
- **BEFORE APPLYING**: Read the relevant chapter section in the reference for the expression/attribute, the rendered output, and the pitfall.

## When to use this skill

- Add or refactor a Thymeleaf view (text/attributes, iteration, conditionals, URLs, i18n) or convert a JSP to Thymeleaf
- Diagnose "template not found" (`TemplateInputException`), empty `th:text`, unresolved fragment, or wrong escaping
- Build reusable fragments (header/footer/nav) and decorator **layouts** (pure Thymeleaf or the layout dialect)
- Bind and validate a Spring **form** — `th:object`/`th:field`, show errors with `th:errors`/`th:errorclass`/`#fields`, re-render on failure
- Add **CSRF** to a form, format with the conversion service (`${{...}}`), or inline model data into JavaScript
- Guard markup with **Spring Security** (`sec:authorize`/`sec:authentication`) — knowing it's render-only, not endpoint security
- Configure `spring.thymeleaf.*` (cache, prefix, mode) or set up Thymeleaf in Spring Boot
- **Migrate Thymeleaf 3.0 → 3.1** (removed request/session objects, class-access restriction, `th:include`, fragment wrapping)

## Workflow

1. **Confirm the versions and that the app/template resolves**

   Determine the Thymeleaf line (3.1.x) and the Spring integration module (`thymeleaf-spring6` vs `…spring5`) and Security extras (`…springsecurity6` vs `…5`). Confirm the template path matches `spring.thymeleaf.prefix`+`suffix`. Gate every recommendation on whether the feature/behavior exists in that version (especially the 3.1 changes — Appendix C).

2. **Read the reference and analyze the template + controller**

   Read `references/thymeleaf.md`. Map each requirement or smell to a specific practice by chapter section and title (e.g. "5.3 Build a layout (decorator) with a parameterizable base fragment", "7.2 Handle a form: binding, validation errors, `#fields`, `th:errors`"). Inspect both the template and the controller/model that feeds it.

3. **Apply the idiomatic Thymeleaf solution**

   Prefer the smallest expression/attribute that expresses intent; escape by default (`th:text`), wrap fragment expressions (`~{...}`), keep logic minimal in templates and data-prep in the controller. Watch the XSS, 3.1 web-context, `th:field`-in-loop, and validation-redirect pitfalls. Cite the practice you applied by chapter section and title.

4. **Render, inspect output, and verify**

   Run the app (cache off in dev) or a `@WebMvcTest` + MockMvc slice and inspect the **rendered HTML** — confirm content, escaping, resolved URLs/fragments, form `id`/`name`/`value`, and error display. Resolve i18n `??key??` markers and silent-empty expressions rather than ignoring them. Re-verify before declaring done.

## Reference

For all features across the 8 chapters — with rationale, idiomatic template (and controller/config) examples, rendered output, pitfalls, the utility-objects table, the full `spring.thymeleaf.*` properties table, and the 3.0→3.1 migration notes & version cheat-sheet — see [references/thymeleaf.md](references/thymeleaf.md).
