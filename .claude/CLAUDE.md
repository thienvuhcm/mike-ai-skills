# Global Claude Instructions

## Skills Repository

All AI skills are managed centrally at:
**`C:\Users\admin\IdeaProjects\mike-ai-skills`**
GitHub: https://github.com/thienvuhcm/mike-ai-skills

Skills live under `.agents/skills/` (304+ skills, organized by numeric prefix):
- `000-` system prompts
- `012-014` agile (epic, feature, user story)
- `030-033` architecture (ADRs, diagrams)
- `040` planning
- `100-199` Java (OOP, concurrency, logging, testing, Maven, security)
- `300-500` frameworks (Spring Boot, Quarkus, Micronaut)
- `200+` agency roles (academic, design, marketing, etc.)

Each project gets `.cursor/skills → mike-ai-skills` auto-linked by the setup hook.

### Sync behavior
- `UserPromptSubmit` hook runs `setup-project-skills.sh` on every conversation start.
- Git pull from GitHub happens at most once per 24 hours (see `~/.claude/last-skills-sync`).
- Sync log: `~/.claude/skills-sync.log`

## Projects

All projects live under `C:\Users\admin\IdeaProjects\`:
- `kyo-sumi` — Java Spring Boot backend (Gradle, GitLab)
- `ams-fe` — Angular frontend
- `ams-web` — Java web backend (Gradle)
- `mike-ai-skills` — AI skills source repo (do not modify project code here)

## Agent Teams

Agent teams are enabled. Use natural language to spawn a team — Claude creates the shared task list and coordinates automatically.

### Quick spawn patterns

**Full-stack feature:**
```
Create an agent team to implement [feature].
- spring-boot-engineer teammate for backend API
- angular-architect teammate for frontend UI
- qa-expert teammate for test coverage
Require plan approval before any teammate makes code changes.
```

**Code review (parallel lenses):**
```
Create an agent team to review [PR/module].
- code-reviewer teammate focused on code quality and patterns
- security-auditor teammate focused on vulnerabilities
- performance-engineer teammate focused on bottlenecks
Have them report findings and challenge each other.
```

**Bug investigation (competing hypotheses):**
```
Create an agent team to debug [issue].
- debugger teammate investigating [hypothesis A]
- debugger teammate investigating [hypothesis B]
Have them share findings and try to disprove each other.
```

**Architecture + implementation:**
```
Create an agent team to design and build [feature].
- architect or java-architect teammate to produce an ADR (plan mode only)
- spring-boot-engineer teammate to implement once plan approved
- qa-expert teammate to write tests in parallel
```

### Navigation (in-process mode)
- `Shift+Down` — cycle through teammates
- `Ctrl+T` — toggle shared task list
- `Escape` — interrupt current teammate turn
- Tell the lead: `"Wait for teammates before proceeding"` if it starts working itself
- Tell the lead: `"Clean up the team"` when done

### Activity log
All task events (created / completed) and teammate idle events are logged to:
`~/.claude/team-activity.log`

### Active agents (16)
| Domain | Agents |
|--------|--------|
| Architecture | `architect`, `java-architect`, `codebase-orchestrator` |
| Backend | `spring-boot-engineer`, `backend` |
| Frontend | `angular-architect` |
| Quality | `code-reviewer`, `debugger`, `qa-expert`, `security-auditor`, `performance-engineer` |
| Database | `postgres-pro` |
| DevOps | `devops-engineer`, `docker-expert` |
| Modernization | `legacy-modernizer`, `refactoring-specialist` |

## Preferences
- Language: Vietnamese is fine for conversation; code/comments in English.
- Framework: Spring Boot (Gradle) for Java backend projects.
- Responses: concise and direct.
