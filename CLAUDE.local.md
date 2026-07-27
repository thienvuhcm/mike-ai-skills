# CLAUDE.local.md — local operating notes

Machine-local supplement to `CLAUDE.md`. Covers **how to use the agents / skills / commands
currently installed**, after the 2026-07 folder update. See `AGENTS.md` for repo structure.

## Where things live now

| Asset | Location | Scope |
|-------|----------|-------|
| 9 `robot-*` agents | `~/.claude/agents/` | global — available in every project |
| 171 skills | `.claude/skills/` (7 categories) | this repo; copy the needed subset into a target project's `.claude/skills/` |
| 16 slash commands | `.claude/commands/` | this repo |
| Coding rules | `.claude/rules/` | loaded via `CLAUDE.md` |

`.claude/agents/` in this repo is intentionally **empty** — the agents were promoted to global.
Only add a file back here to override a global agent for this repo.

## Default routing (no ceremony needed)

1. **Question about existing code** → GitNexus (`query` → `context` → `impact`).
2. **Fix / refactor existing code** → GitNexus first, then the coder agent for that stack.
3. **New feature in a real code project** → `/create-spec` (OpenSpec) → approval → `/implement-spec`.
4. **New feature, no `openspec/`** → Plan Mode + `robot-architect`, then a coder agent.
5. **This repo (knowledge repo)** → edit Markdown directly. No OpenSpec, no GitNexus, no build.

## Agent teams

Enabled already — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` + `teammateMode: in-process` in
both `settings.json` and `~/.claude/settings.json`. Nothing to switch on.

Because the 9 `robot-*` agents are a coordinator-led team (not one mega-agent), the normal
shape is: **spawn `robot-tech-lead`, let it delegate.** Don't hand-assemble the roster.

- `robot-tech-lead` is the entry point for anything spanning design → code.
- It spawns `robot-architect` / `robot-business-analyst` / a coder / `robot-java-performance`
  as needed, and each runs in its own context.
- Use `SendMessage` to continue a teammate that is already running — a fresh `Agent` call
  starts cold and re-derives everything.
- Only spawn a coder directly when the task is a single-stack implementation with an approved
  spec or plan already in hand.

Teams cost a cold start per agent. For a question you can answer by reading two files, don't
spawn anything.

## Picking the coder agent

| Target project | Agent | Skill families to load |
|----------------|-------|------------------------|
| Plain Java / Maven | `robot-java-coder` | `110–114`, `121–128`, `130–133`, `141–145` |
| Spring Boot 4.x | `robot-java-spring-boot-coder` | `300–323` + Java families above |
| Quarkus 3.x | `robot-java-quarkus-coder` | `400–423` + Java families above |
| Micronaut 4.x | `robot-java-micronaut-coder` | `500–523` + Java families above |
| TS / React / Vue / CSS | `robot-no-java` | `.claude/rules/{typescript,react,vue,css,html}.md`, `front-end/` skills |
| Perf work (any stack) | `robot-java-performance` | `151–164` — it profiles and delegates, never edits app code |

Datastore / messaging skills are additive, not part of a framework family:
`313`/`413`/`513` (Flyway), `315`/`415`/`515` (MongoDB), `314`/`414`/`514` (Kafka),
`704` (SQL), `705` (MongoDB), plus `database/` category skills.

## Slash commands worth reaching for

```text
/create-issue        → robot-business-analyst   backlog item from a request
/explore-design      → robot-architect          compare design options
/create-adr          → robot-architect          record the decision
/create-diagram      → robot-architect          architecture diagram
/create-spec         → robot-architect          OpenSpec change (needs approval)
/create-plan         → robot-tech-lead          implementation plan
/create-feature-branch, /create-worktree → robot-tech-lead
/implement-spec, /implement-issue → robot-tech-lead → delegates to a coder
/profile, /benchmark → robot-java-performance
/close-spec          → robot-architect          archive a finished change
/review-alignment    → robot-business-analyst   read-only consistency check
/kill-port           → utility
```

## Editing this repo

- Adding a skill: create `.claude/skills/<category>/<name>/SKILL.md` with `name` +
  `description` frontmatter. The `description` must read as trigger phrases ("Use when …",
  "This should trigger for requests such as …") — that string is the only thing Claude sees
  before loading the skill.
- Adding a command: `.claude/commands/<name>.md` with Purpose, Usage, Owning Agent, and
  delegation targets.
- After editing `CLAUDE.md`: `bash scripts/sync-claude-md.sh` (backs up then overwrites
  `~/.claude/CLAUDE.md`).
- Nothing to build or test — verification is valid frontmatter, unique skill names, working
  relative links, and confirming the skill triggers in a live session.

## Guardrails

- Never `openspec init` here — knowledge repo, not a code project.
- Never commit `.claude/settings.local.json`.
- Don't restore `.claude/agents/*.md` copies that duplicate the global ones; that reintroduces
  two sources of truth for the same agent.
