# Contributor Quickstart Guide

## What this repo is

`mike-ai-skills` is a **Claude Code knowledge repo (skills factory)** — it ships agents,
skills, slash commands, and coding rules that get loaded by Claude Code, either globally
(`~/.claude/`) or copied into a target project's `.claude/`.

It is **not** a code project: no build, no tests, no package manager, no source tree.

## Tech stack

- **Content format:** Markdown + YAML frontmatter (`SKILL.md`, agent `.md`, command `.md`)
- **Tooling:** Git, Bash (`scripts/sync-claude-md.sh`), PowerShell hooks in `settings.json`
- **Runtime:** Claude Code (agents, skills, slash commands, hooks)
- **Target stacks the content covers:**
  - Java 25 / Maven (`./mvnw`) — Spring Boot **4.0.x**, Quarkus **3.x**, Micronaut **4.x**
  - Data: SQL, MongoDB, Flyway, Mongock, JPA/Hibernate, MyBatis
  - Front-end: TypeScript, React, Vue 3, Tailwind, HTML/CSS
  - Cross-cutting: OpenAPI, Docker, Kafka, WireMock, hexagonal architecture, EU regulations

## Layout

| Path | Contents | Edit? |
|------|----------|-------|
| `.claude/skills/` | 171 skills in 7 categories (`java`, `claude-java`, `architecture&design`, `database`, `design-pattern`, `front-end`, `general`) | WRITE |
| `.claude/commands/` | 16 slash commands (`/create-spec`, `/implement-issue`, `/profile`, …) | WRITE |
| `.claude/agents/` | Empty — the 9 `robot-*` agents now live in `~/.claude/agents/` (global) | see note |
| `.claude/rules/` | Language/framework coding rules loaded via `CLAUDE.md` | WRITE |
| `CLAUDE.md` | Global instructions, synced to `~/.claude/CLAUDE.md` by `scripts/sync-claude-md.sh` | WRITE |
| `CLAUDE.local.md` | Machine-local operating notes (routing table, current inventory) | WRITE |
| `settings.json` | Shared Claude Code settings (permissions, hooks) | WRITE |
| `.claude/settings.local.json` | Machine-local settings — gitignored, never share | no |
| `OLD-CLAUDE(deprecated).md` | Historical reference | READ only |

**Agents note:** the `robot-*` agents were promoted to `~/.claude/agents/` so every project
sees them. The project-local copies under `.claude/agents/` are deleted on purpose — do not
restore them unless a project needs an override.

## Agent team

Nine agents, coordinator-led; the coordinator never writes application code itself.

| Agent | Role |
|-------|------|
| `robot-tech-lead` | Coordinator — plans/OpenSpec changes, delegates implementation |
| `robot-architect` | ADRs, diagrams, design exploration, OpenSpec specs |
| `robot-business-analyst` | Issues (GitHub/Jira), read-only alignment reviews |
| `robot-java-coder` | Plain Java / Maven implementation |
| `robot-java-spring-boot-coder` | Spring Boot 4.x |
| `robot-java-quarkus-coder` | Quarkus 3.x |
| `robot-java-micronaut-coder` | Micronaut 4.x |
| `robot-java-performance` | Profiling/benchmarks — delegates fixes, never implements |
| `robot-no-java` | Fallback for non-JVM work |

## Command → agent routing

| Command | Owner | Delegates to |
|---------|-------|--------------|
| `/create-issue`, `/update-issue`, `/review-alignment` | `robot-business-analyst` | — |
| `/create-adr`, `/create-diagram`, `/explore-design`, `/create-spec`, `/close-spec` | `robot-architect` | — |
| `/create-plan`, `/create-feature-branch`, `/create-worktree` | `robot-tech-lead` | — |
| `/implement-issue`, `/implement-spec` | `robot-tech-lead` | java / spring-boot / quarkus / micronaut / no-java coder |
| `/benchmark`, `/profile` | `robot-java-performance` | coder agents (performance agent never edits app code) |
| `/kill-port` | — | utility |

## Skill numbering (`.claude/skills/java/`)

Skills are ordered by lifecycle so agents can reference them by number:

| Range | Topic |
|-------|-------|
| `001–005` | Inventories and installation of commands/agents |
| `012–014` | Agile: epic, feature, user story |
| `030–034` | Architecture: ADRs, diagrams, design exploration |
| `041–045` | Planning: plan mode, OpenSpec, GitHub Issues, Jira, Azure DevOps |
| `051–057` | Design techniques: TDD, parallel change, feature toggles, … |
| `110–114` | Maven |
| `121–128` | Java design, secure coding, concurrency, exceptions, generics |
| `130–133` | Testing strategies |
| `141–145` | Modern Java, functional, data-oriented, performance refactoring |
| `151–164` | Performance (JMeter, Gatling) and profiling |
| `170–183` | Documentation and observability (logging, Micrometer, OpenTelemetry) |
| `300–323` | Spring Boot |
| `400–423` | Quarkus |
| `500–523` | Micronaut |
| `701–707` | Technologies: OpenAPI, WireMock, fuzzing, SQL, MongoDB, Docker, hexagonal |
| `801–813` | EU regulations and ISO 42001 |

Book-derived skills (`effective-java-book`, `modern-java-in-action-book`, `spring-in-action`, …)
sit alongside the numbered ones without a prefix.

## Working rules

- **Skills:** one directory per skill containing `SKILL.md` with `name` + `description`
  frontmatter. The `description` is the only thing Claude sees before loading — write it as
  trigger phrases, not a summary.
- **Commands:** one `.md` per command; state Purpose, Usage, Owning Agent, and delegation
  targets so routing stays explicit.
- **Rules:** `.claude/rules/*.md` are referenced from `CLAUDE.md`; keep them in English.
- **Global sync:** after editing `CLAUDE.md`, run `bash scripts/sync-claude-md.sh` to push it
  to `~/.claude/CLAUDE.md` (it backs up the previous version).
- **Validation:** there is no build. "Verify" means: valid YAML frontmatter, unique skill
  `name`, working relative links, and the skill actually triggering in a real session.

## Git workflow

Conventional Commits — `type(scope): description`.

| Type | Use |
|------|-----|
| `feat` | New skill, agent, or command |
| `fix` | Correct a broken skill/rule/link |
| `docs` | Documentation only |
| `refactor` | Reorganize content, same behavior |
| `chore` | Tooling, settings, maintenance |

## Boundaries

- ✅ **Always:** keep skill `description` fields trigger-oriented; keep `CLAUDE.md` and the
  global copy in sync; document new commands with an owning agent.
- ⚠️ **Ask first:** promoting/demoting agents between `~/.claude/agents/` and `.claude/agents/`;
  renaming skill number ranges; changing `settings.json` hooks or permissions.
- 🚫 **Never:** run `openspec init` here (knowledge repo, not a code project — stray
  `openspec-*/` dirs are gitignored); commit `.claude/settings.local.json` or secrets; edit
  `OLD-CLAUDE(deprecated).md` as if it were current.
