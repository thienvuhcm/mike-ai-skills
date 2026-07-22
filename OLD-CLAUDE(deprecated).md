# Global Claude Code Instructions

<!--
User-scope memory (~/.claude/CLAUDE.md): personal preferences + workflow, loaded
in FULL every session, every project. Keep under ~200 lines (docs: longer files
reduce adherence). Skills/agents auto-activate, nên full catalog sống ở
~/.claude/CATALOG.md (không auto-load), KHÔNG để inline ở đây.
HTML comment này bị strip khỏi context — chỉ là note cho người maintain.
-->

Personal preferences cho mọi project. Viết tiếng Việt, giữ technical terms tiếng Anh.

- **Feedback song ngữ** — khi đưa feedback (nhận xét, review, đánh giá code/approach/kết quả), LUÔN viết song ngữ: đoạn tiếng Việt trước, kèm bản tiếng Anh ngay sau (không chỉ tiếng Việt). Áp dụng cho nội dung feedback, không phải toàn bộ response.

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

## Sub-agents (task đơn, tuần tự)

Gọi: `"Dùng <agent> để …"`.

| Domain | Sub-agent |
|--------|-----------|
| Java / Spring Boot / API / domain | `901-agent-backend` |
| Angular / React / UI | `900-agent-frontend` |
| PostgreSQL / MySQL / Oracle | `902-agent-dba` |
| Tests / QA / coverage | `903-agent-qa` |
| Epics / stories / ADRs / sprint | `904-agent-manager` |
| System design / architecture | `905-agent-architect` |

## Agent teams (task phức tạp, song song)

Enabled qua `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Dùng khi việc span nhiều domain (FE+BE+DB+tests), review song song nhiều góc nhìn, hoặc debug nhiều hypothesis cùng lúc.

- **Khởi động** — yêu cầu lead spawn các teammate cần thiết; để `905-agent-architect` approve plan trước khi backend bắt đầu code.
- **Điều hướng** — `Shift+Down` cycle teammates, `Ctrl+T` toggle task list, nhắn trực tiếp teammate bất kỳ lúc nào.
- **Cleanup** — nói `"clean up the team"` với lead (không nói với teammate).
- **Giới hạn (experimental)** — 1 team/session; không resume in-process teammates sau `/resume`; teammate không spawn team con; split-pane cần tmux (Windows → dùng in-process).

### Team protocol — agents làm việc như 1 team (LUÔN trao đổi)

Áp mỗi khi >1 agent cùng 1 task:

- **Lead điều phối** — lead (orchestrator) giao việc theo scope; `905-agent-architect` duyệt plan trước khi code. Không agent nào tự ý làm ngoài scope.
- **Handoff có cấu trúc** theo chuỗi BA → 905 → 904 → 901/900: brief gồm *việc gì · file · acceptance/verify · GitNexus impact note · blocked-by*.
- **Hỏi thẳng, đừng đoán** — cần API contract / schema / spec của agent khác thì nhắn **trực tiếp** agent đó; gặp cross-cutting → báo lead + agent liên quan **ngay**.
- **Report khi xong** — mỗi agent gửi lead: *đã làm gì · file đổi · specs/tasks thoả · `gitnexus_detect_changes` scope · blockers*.
- **Không giẫm chân** — không sửa file do agent khác sở hữu; xung đột → lead xử.
- **Retro cuối mỗi task** — what worked + 1 cải tiến; lead fold lesson vào CLAUDE.md (project).

## Skills & agents

- **Skills** — 329 skills global tại `~/.claude/skills/`, tự kích hoạt theo context hoặc gọi `Skill("name")` / gõ `/name`.
- **Plugin skills** — bộ ECC (`everything-claude-code:*` — tdd-workflow, coding-standards, *-patterns, *-testing, eval-harness, deep-research, …), `superpowers:*`, `document-skills:*`, `anthropic-skills:*` dùng **trực tiếp từ plugin** (gõ `/tdd-workflow` hoặc prefix đầy đủ khi trùng tên). KHÔNG copy về `~/.claude/skills/` — bản copy local đã gỡ 2026-06-10 (backup: `~/.claude/backups/dedup-20260610/`).
- **Agency roles** — 200+ specialized agents (engineering, design, product, marketing, testing, …) trong cùng library.
- Full index theo category (skills + agency roles) ở `~/.claude/CATALOG.md` — **không auto-load**, mở khi cần tra cứu.
- **Harness audit** — `harness-monitor` (Java 25 TUI, source `D:\tools\ai-agent-harness-monitor-cli`, chạy trên jbang JDK 25) để audit + security-scan skills · rules · CLAUDE.md · AGENTS.md · MCPs. Chạy thủ công, **không** cắm runtime. Plain console: `harness-monitor --no-ui --yes --internal-analysis`. Config: `audit-config.json` cạnh jar.
- **Rules dedup** — `~/.claude/rules/*.md` (52 file, ~40k+ token/session) đã gỡ 2026-07-01 vì trùng nội dung với Skills tương ứng trong `~/.claude/skills/` (backup: `~/.claude/backups/rules-dedup-20260701/`). TUYỆT ĐỐI không tạo lại `~/.claude/rules/` — mọi Java/Spring Boot rule đã có Skill số hiệu tương ứng (xem `CATALOG.md` mục "☕ Java Core" / "🌱 Spring Boot"), gọi qua `Skill("<name>")` khi cần, không hard-code nội dung vào CLAUDE.md.

## Directory map

| Path | Mục đích |
|------|----------|
| `~/.claude/skills/` | SSoT cho 329 skills tự quản — **không** tạo skill ở nơi khác; skill có sẵn trong plugin thì dùng bản plugin, không copy về |
| `~/.claude/agents/` | Active sub-agents (file `.md` top-level) |
| `~/.claude/CATALOG.md` | Index đầy đủ skills + agency roles (không auto-load) |
| `.claude/agents/` (project) | Project-only agents, ưu tiên hơn global |
| `.claude/commands/` | Slash commands `/name` |

## Thêm sub-agent / skill

- **Sub-agent** — tạo `~/.claude/agents/<name>.md` với frontmatter `name` / `description` (Claude Code dùng để auto-select) / `tools`. Tool theo role: reviewer/auditor → `Read, Grep, Glob`; researcher → thêm `WebFetch, WebSearch`; code writer → `Read, Write, Edit, Bash, Glob, Grep`.
- **Skill** — tạo folder `~/.claude/skills/<name>/` + `SKILL.md`. SSoT policy: không tạo file skill ở chỗ khác.

@RTK.md
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
