# learning-loop

**A learning OS for Claude Code — an agentic second brain that forces retention, not just capture.**

Most AI-assisted learning setups are great at *capturing* knowledge and terrible at
making it stick. This template closes the loop: every concept you learn is written as
study material you can re-learn from, quizzed to set how much you trust it, indexed for
retrieval, tracked on a roadmap, re-tested until it holds, and — when it comes from an
outside course — promoted into your permanent vault. The parts humans forget are enforced by deterministic hooks, not
willpower.

```
 TEACH      the professor explains, you drive the keyboard
   ↓
 CAPTURE    "add to my notes" → quiz sets the status → atomic note in the vault
   ↓
 INDEX      hook auto-regenerates INDEX.md + _coverage.md on every note write
   ↓
 PLAN       the advisor keeps learning-path.md — your roadmap — in sync
   ↓
 REVIEW     "quiz me" → the queue is generated from note frontmatter; a pass promotes
   ↓
 PROMOTE    course spokes → "promote to my vault" → durable concepts go canonical
   ↓
 HARVEST    "harvest this session" → nothing falls through when you close the terminal
```

## The ideas underneath

- **Force-learning.** A project — or a course — isn't *done* until its learnings are
  captured as concept notes. Implemented-but-unwritten knowledge is invisible to your
  future self. The advisor audits for this; the harvest ritual enforces it session by
  session.
- **The quiz sets a note's status, never whether it exists.** A short active-recall
  quiz (Recall / Application / Edge) marks the note `stable` or `wip` — but the note is
  written either way, because the concept you got wrong is the one you most need
  something to read.
- **The note carries its own review state; the queue is generated.** `status: wip` means
  due, `review: when deploying X` defers to a moment, `stable` is terminal. `INDEX.md`
  derives the review queue from those two fields, so there is no second file to keep in
  sync — and a queue entry pointing at a note that doesn't hold the concept is
  structurally impossible rather than something to detect afterwards.
- **`wip` is for what's worth deepening, not everything you got wrong.** A forgotten flag
  name belongs *in* the note; a clarifying question you asked isn't a gap at all. The
  queue stays a list of understanding worth going further on.
- **Notes are study material, not a transcript.** Every note carries the mechanism from
  the ground up, a worked example with real output from your own machine, the
  misconception it corrects, and what you can run to prove it. If a note can't re-teach
  you the concept months later, it isn't finished.
- **Point-of-use review.** For ops/procedural topics the quiz is deferred to the moment
  you next *deploy* the thing — carried as a `review:` trigger in the note's own
  frontmatter so it actually resurfaces. The note is still written now, as a runbook you
  can follow unaided.
- **Nothing truncates silently.** Session-start context is injected whole; when a section
  outgrows its threshold the hooks *say so* at both ends — the session that writes it and
  the session that pays to read it — instead of quietly cutting the tail off.
- **The roadmap can't bloat.** `learning-path.md` answers three questions — what's covered,
  how it connects to a goal, what's missing that a goal needs — under per-section line caps
  a hook enforces on every write. Its `## State of play` is a fixed ~2000-word working memory
  the advisor *folds* new information into rather than appending to, so the plan stays a map
  instead of decaying into a journal. Displaced text moves to an archive; nothing is deleted.
- **Atomic vault, metadata-first.** One concept per file, filename = concept name,
  a `summary` in frontmatter as the retrieval payload — written as long as the concept
  needs, and clipped only when `INDEX.md` emits the map. Agents scan the generated
  index, not 300 notes, then open the one note that matters. Plain Markdown, Obsidian-compatible, no
  lock-in — a local model can read it offline.
- **Two projections, one walk.** The same frontmatter scan emits `INDEX.md` (with
  summaries, for *which note do I want*) and `_coverage.md` (without them, for *does a
  note exist at all*). Coverage is a set-difference question, so the advisor enumerates
  the complete roster rather than retrieving a similar-looking subset — a sample can
  never prove a note is missing. Dropping the summaries makes reading all of it cheap.
- **Deterministic where it matters.** Session-start context injection and index
  regeneration are shell hooks, not prose instructions the model might skip.

## Quickstart

1. **Use this template** → create your own repo — **make it private** (your notes
   will live in it) — and clone it. Or just clone and re-`git init`.
2. Install [Claude Code](https://claude.com/claude-code) and open the repo root.
3. Say: **"set up my learning environment"** — a short interview personalizes
   `AGENTS.md`, writes `notes/My Goals.md`, and has the advisor build your
   `learning-path.md` from scratch.
4. Start learning: ask about anything. When a concept lands, say
   **"add to my notes"**.

## Magic words

| You say | Where | What happens |
|---|---|---|
| "set up my learning environment" | root | one-time bootstrap interview |
| "add to my notes" | root | quiz sets the status → scribe writes the atomic note → advisor updates the roadmap |
| "quiz me (on X)" | root | retention quiz over your vault; a pass promotes `wip` → `stable` |
| "harvest this session" / "wrap up" | root | end-of-session sweep — capture, log, or defer everything covered |
| "enrich my notes" / "fill my gaps" | anywhere | enricher fact-checks, fills logged gaps, adds vetted resources |
| "what should I study next?" | root | advisor re-reads everything and recommends |
| "update my goals" | root | confirmation-gated goals edit + advisor re-run |
| "start a course" | root | scaffolds a course spoke for an outside course (MOOC, university program, …) |
| "quiz me" | course folder | Course Tutor quiz mode against that course's notes |
| "promote to my vault" | course folder | a proven course concept becomes a permanent vault note |

## What's inside

```
AGENTS.md                  portable core — who you are, how you learn (open agents.md format)
CLAUDE.md                  Claude Code wiring — spokes, skills, agents, hooks
.claude/
  agents/                  scribe (writes notes) · advisor (keeps the roadmap) · enricher (fact-checks)
  skills/                  setup · add-to-notes · review · harvest · enrich-notes · new-course
  hooks/                   learning-dashboard.sh (SessionStart) · regen-index.sh (auto-INDEX)
                           state-file-review.sh + thresholds.sh (roadmap size review)
  templates/               Course Tutor file + spoke settings (copied into each course folder)
notes/                     your vault — atomic notes, generated INDEX.md + _coverage.md,
                           learning-path.md
```

## Portability

`AGENTS.md` uses the open [agents.md](https://agents.md) convention and travels to
any agent that reads it. The vault is plain Markdown — readable by anything,
including a self-hosted local model, offline. The orchestration (skills, subagents,
hooks) is Claude Code-specific; porting it to another harness means reimplementing
that thin layer, not your knowledge.

## Cost & privacy

Designed to run entirely **plan-billed** (no metered API keys) and local-first:
your notes never leave your machine except to *your* git remote. Nothing phones
home. Keep the repo private; share the empty template, never the vault.

## Honest limitations

- Review scheduling is priority-based (the generated queue first, then oldest/related
  notes) — not a spaced-repetition algorithm like SM-2. No retention metrics yet.
- A `review:` trigger is prose ("when deploying X"), so nothing detects that its moment
  has passed — you spot it in the queue the hook prints each session.
- The index regenerates on tool use, not on session start: notes edited outside Claude
  Code (in Obsidian, say) don't refresh it until the next write from inside.
- Hooks are macOS/Linux shell scripts; Windows needs WSL.
- One learner per vault by design.

## Credits & lineage

Standing on well-trodden ground: Zettelkasten (atomic notes), active recall and
spaced repetition, *Building a Second Brain* (Forte), and the pattern-sharing
spirit of [Fabric](https://github.com/danielmiessler/fabric). The assembly — a
quiz-gated, hook-enforced capture→review→promote loop for an agentic harness — is
what this template adds. Built with Claude Code, iteratively, by using it to learn.

## License

MIT — see [LICENSE](LICENSE).
