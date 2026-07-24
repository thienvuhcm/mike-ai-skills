## Workflow rules (always do)

- Short greeting → reply directly, no tools/agents/skills/GitNexus/OpenSpec. Overrides all other rules. (Hook-level token usage from UserPromptSubmit can't be disabled via CLAUDE.md — only via hook config or CLAUDE_TOOLCHECK=off.)
Session start (non-greeting messages): load /prompt-master first.
GitNexus before editing any symbol: gitnexus_query (find flow) → gitnexus_context (callers/callees) → gitnexus_impact (blast radius) → gitnexus_detect_changes (pre-commit check).
- Task routing:
 	- Maintain/fix/refactor existing code → GitNexus-first, always run impact before touching a symbol.
	- New feature → OpenSpec (if openspec/ exists): propose → spec (Given/When/Then) → tasks → approval → implement. No openspec/ → Plan Mode + 905-agent-architect.
	- GitNexus is always the safety layer, even during feature work; detect_changes before every commit.
- OpenSpec only in real buildable code repos (never in docs/skills/notes repos). Requires approval before implementation. Validate via openspec validate.
- OpenSpec + GitNexus combined: OpenSpec = plan layer (what/why), GitNexus = safety layer (safe edits) — used together, not either/or.
- OpenSpec bilingual: docs (proposal/design/tasks/specs) written VI+EN, English is canonical. DSL tokens (## ADDED/MODIFIED Requirements, ### Requirement:, #### Scenario:, **WHEN**/**THEN**, SHALL/MUST, - [ ] N.N checkboxes) must stay untranslated/unchanged — validate after edits.
- RTK: dev commands auto-rewritten via hook to save tokens (see @RTK.md).
- Tool availability check: check-tools.ps1 hook warns if GitNexus/OpenSpec CLI missing or not initialized; silent when fine; disable via CLAUDE_TOOLCHECK=off

## Model Assignment Rules
- Architecture decisions and reviews: Use Opus (Opus 4.8 - claude-opus-4-8) 
- Implementation tasks (new features, refactors): Use Sonnet (Sonnet 5 - claude-sonnet-5) 
- Simple edits, formatting, renaming: Use Haiku (Haiku 4.5 - claude-haiku-4-5)
- Security-sensitive changes: Always escalate to Opus (Opus 4.8 - claude-opus-4-8)
 for review
Never use old version model. Always use the newest version.

# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. I'm always open to ideas on better ways to do things. Please don't hesitate to suggest a better way, or one that has long lasting impact over a tactical change. (as a few examples)"
---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

@RTK.md
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
