# CLAUDE.md

@AGENTS.md

> **Identity, preferences, modes, and how the notes are organized live in
> `AGENTS.md`** (portable, tool-agnostic — read it first). This file holds
> **Claude-Code-specific wiring only**: spoke routing, skills, subagents, hooks.

## Memory / second brain
- **Durable preferences + ways of working** → `AGENTS.md`
- **Knowledge** → the vault `notes/` (atomic notes + generated `INDEX.md`)
- **Roadmap + coverage** → `notes/learning-path.md` (advisor-maintained)
- **Retention layer** → `_understanding-log.md` (vault root + per course folder)

## Spokes
This workspace is a hub. Each **course folder** under `notes/` has its own
`CLAUDE.md` that **takes precedence** when Claude Code is started inside it →
Course Tutor role (canonical template: `.claude/templates/course-CLAUDE.md` —
edit THERE, then re-copy). The professor role (`AGENTS.md`) applies everywhere
else in the workspace.

## Session start (learning sessions)
The **SessionStart hook** injects the learning dashboard automatically:
recommended next, open learning hooks, and the review queues. Beyond that, read
`notes/My Goals.md` when goals context matters. **Always grep `notes/INDEX.md`
for the relevant topic section, never read it whole** once it grows — then open
only the notes you need.

## Magic words → skills

| User says | Where | What happens |
|---|---|---|
| "set up my learning environment" | Hub | `setup`: one-time bootstrap interview |
| "add to my notes" | Hub | `add-to-notes`: comprehension check (🟡/❌ → understanding log) → **scribe** writes the atomic note → **advisor** updates the path |
| "quiz me (on X)" | Hub | `review`: retention quiz over vault notes + log re-tests |
| "harvest this session" / "wrap up" | Hub | `harvest`: end-of-session sweep |
| "enrich my notes (on X)" / "fill my gaps" | Hub or spoke | `enrich-notes`: **enricher**, log-first rule |
| "start a course" | Hub | `new-course`: scaffold a course spoke + register with the **advisor** |
| "what should I study next?" | Hub | **advisor** re-reads everything, updates the recommendation |
| "update my goals" | Hub | Goals flow below — confirmation-gated |
| "quiz me" | Course spoke | Course Tutor quiz mode (spoke-owned) |
| "promote to my vault" | Course spoke | Course Tutor → **scribe** writes the concept as an atomic vault note |

## Agents
- **scribe** (`.claude/agents/scribe.md`) — writes atomic notes (one concept per
  file; filename = concept; frontmatter per `AGENTS.md`; tags from `notes/_tags.md`;
  validates `[[wikilinks]]`). May create a new topic folder when a concept fits
  none (deliberately — and announces it). Handles **promotions** from course spokes.
- **advisor** (`.claude/agents/advisor.md`) — maintains `notes/learning-path.md`
  incl. the **Courses** section and promotion candidates; runs after the scribe, on
  "what should I study next?", after `My Goals.md` changes, and when a course is
  added. Applies the **force-learning** lens to projects AND courses.
- **enricher** (`.claude/agents/enricher.md`) — fact-checks + appends verified
  resources; works `_understanding-log.md` open gaps first (log-first rule).

## Hooks (`.claude/settings.json` → `.claude/hooks/`)
- **SessionStart** (`learning-dashboard.sh`) — injects the learning dashboard at
  hub session start; inside a course spoke shows that course's open gaps instead.
- **PostToolUse** on Write|Edit (`regen-index.sh`) — auto-regenerates
  `notes/INDEX.md` whenever a vault note is written. Nobody regenerates the index
  by hand (manual fallback: `python3 generate_index.py` from `notes/`).

## Updating goals
When the user says "update my goals": read `notes/My Goals.md`, propose edits in
chat, wait for confirmation, then write — and re-run the advisor so the plan stays
in sync. Never edit `My Goals.md` without explicit confirmation.

## Git
This workspace is one git repo (keep it **private** — the vault lives here).
After writing or changing notes, commit with a descriptive message and push.
