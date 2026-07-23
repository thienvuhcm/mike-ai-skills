## Workflow rules (always do)

- **Greeting ngắn = trả lời thẳng, TUYỆT ĐỐI không tốn token** — khi message chỉ là lời chào/câu ngắn không mang task (vd "hi", "hello", "chào", "yo", ping test) → trả lời trực tiếp 1 câu, KHÔNG gọi bất kỳ thứ gì tốn token: MCP, Tools, Agent, Skills, sub-agents, agent teams, `/prompt-master`, GitNexus, OpenSpec, ToolSearch cho deferred tools. Rule này **override mọi rule khác bên dưới** khi message chỉ là greeting — kể cả rule "Session start" load `/prompt-master` ngay sau đây. Chỉ kích hoạt các flow bên dưới khi message có nội dung task thật sự.
  - **Giới hạn thực tế**: hook UserPromptSubmit (prompt-master, check-tools.ps1) chạy ở tầng harness trước khi tôi đọc message — CLAUDE.md không tắt được hook đó, chỉ kiểm soát được hành động tôi chủ động thực hiện sau khi thấy message (không tự invoke Skill, không tự gọi tool, không tự spawn agent). Muốn tắt hẳn context/token do hook bơm vào thì phải sửa hook hoặc set biến env tương ứng (vd `CLAUDE_TOOLCHECK=off`), không phải sửa CLAUDE.md.
- **Session start** (bỏ qua nếu message đầu là greeting ngắn — xem rule trên) — load `/prompt-master` để tối ưu system prompt theo context.
- **GitNexus TRƯỚC khi sửa code** — trước khi đổi bất kỳ function/class/method nào:
  - `gitnexus_query({query})` — tìm flow theo concept
  - `gitnexus_context({name})` — callers, callees, flows (360°)
  - `gitnexus_impact({target, direction})` — blast radius
  - `gitnexus_detect_changes()` — pre-commit scope check
- **Phân loại task → chọn flow** (sau prompt-master, mọi project):
  - **MAINTAIN code cũ** (fix / refactor / optimize) → **GitNexus-first** (rule trên): chạy `gitnexus_impact` trước khi đụng bất kỳ symbol nào.
  - **Tính năng MỚI** → **OpenSpec** nếu repo có `openspec/` (dự án code thật): `openspec` propose → specs (Given/When/Then) → tasks → **DUYỆT** → implement. Repo code chưa có `openspec/` → fallback **Plan Mode** (`Ctrl+Shift+P`) + `905-agent-architect` thiết kế → backend/frontend đồng thuận → code.
  - **GitNexus là lớp safety LUÔN-LUÔN**: kể cả khi làm feature mới, hễ sửa code cũ vẫn chạy `gitnexus_impact`; `gitnexus_detect_changes()` trước mỗi commit.
- **OpenSpec (spec-driven, theo điều kiện)** — CHỈ khi repo có thư mục `openspec/`: theo flow spec-driven — `openspec list` xem change/specs → đề xuất change (spec) & được duyệt trước khi code → `openspec validate` → `openspec archive` khi xong. Repo chưa có mà muốn dùng → `openspec init` (tạo `openspec/` + `AGENTS.md` riêng cho project đó). **⚠️ Guardrail** — OpenSpec CHỈ cho **dự án code thật** (có source build được); TUYỆT ĐỐI không `init`/gen trong repo kiến thức/skills/docs/notes (vd `mike-ai-skills`, `~/.claude`). Feature mới trong dự án code: proposal/spec **phải được duyệt** trước khi implement (đúng flow propose → duyệt → code).
- **OpenSpec × GitNexus = dùng CHUNG, không chọn 1** — OpenSpec là lớp **PLAN** (proposal/design/tasks/specs — *làm gì & tại sao*); GitNexus là lớp **SAFETY** (call-graph, impact — *sửa an toàn*). Lúc PLAN: dùng `gitnexus_impact`/`context` để scope `design.md`/`tasks.md` sát code thật. Lúc BUILD: theo `tasks.md`, mỗi symbol cũ đụng vào chạy `gitnexus_impact`, pre-commit `gitnexus_detect_changes()`. Commit xong → PostToolUse hook re-`analyze` → index tươi cho change kế. (Maintain code cũ → chỉ cần GitNexus.)
- **OpenSpec song ngữ** — mọi artifact OpenSpec (`proposal.md`, `design.md`, `tasks.md`, `specs/**/spec.md`) viết song ngữ Việt + English cho phần nội dung mô tả (heading, prose, task description, câu SHALL/MUST, nội dung WHEN/THEN) — tiếng Anh giữ nguyên là bản chính, tiếng Việt thêm ngay sau (không xoá/thay tiếng Anh). **TUYỆT ĐỐI giữ nguyên, không dịch** các token DSL mà `openspec` CLI parse: `## ADDED/MODIFIED/REMOVED/RENAMED Requirements`, `### Requirement: <name>`, `#### Scenario: <name>` (giữ đúng 4 dấu `#` và tên tiếng Anh), `**WHEN**`/`**THEN**`, `SHALL`/`MUST`, và prefix checkbox `- [ ] N.N` trong `tasks.md` (apply-tracking parse theo prefix này) — sau khi sửa, chạy `openspec validate` để xác nhận không vỡ schema.
- **RTK** — dev commands tự động rewrite qua hook để tiết kiệm token; reference đầy đủ ở cuối file (@RTK.md).
- **Tool availability** — hook `~/.claude/hooks/check-tools.ps1` (UserPromptSubmit) tự cảnh báo nếu GitNexus/OpenSpec CLI chưa cài, hoặc repo chưa `gitnexus analyze` / chưa `openspec init`. Im lặng khi đủ; tắt bằng `set CLAUDE_TOOLCHECK=off`.

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
