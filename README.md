# learning-loop

**A learning OS for Claude Code — an agentic second brain that forces retention, not just capture.**

Most AI-assisted learning setups are great at *capturing* knowledge and terrible at
making it stick. This template closes the loop: every concept you learn is
quiz-gated before it's saved, indexed for retrieval, tracked on a roadmap, re-tested
until it holds, and — when it comes from an outside course — promoted into your
permanent vault. The parts humans forget are enforced by deterministic hooks, not
willpower.

```
 TEACH      the professor explains, you drive the keyboard
   ↓
 CAPTURE    "add to my notes" → comprehension quiz → atomic note in the vault
   ↓
 INDEX      hook auto-regenerates INDEX.md on every note write
   ↓
 PLAN       the advisor keeps learning-path.md — your roadmap — in sync
   ↓
 REVIEW     "quiz me" → misses land in the understanding log, re-tested later
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
- **Comprehension gates.** Nothing enters the vault without a short active-recall
  quiz (Recall / Application / Edge questions). Shaky answers aren't discarded — they
  become the review queue.
- **Point-of-use review.** For ops/procedural topics, the quiz is deferred to the
  moment you next *deploy* the thing — logged with a trigger so it actually resurfaces.
- **Atomic vault, metadata-first.** One concept per file, filename = concept name,
  one-line `summary` in frontmatter as the retrieval payload. Agents scan the
  generated `INDEX.md`, not 300 notes. Plain Markdown, Obsidian-compatible, no
  lock-in — a local model can read it offline.
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
| "add to my notes" | root | quiz gate → scribe writes the atomic note → advisor updates the roadmap |
| "quiz me (on X)" | root | retention quiz over your vault; misses → understanding log |
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
  templates/               canonical Course Tutor file (copied into each course folder)
notes/                     your vault — atomic notes, INDEX.md, learning-path.md, understanding log
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

- Review scheduling is priority-based (log first, then oldest/related notes) — not
  a spaced-repetition algorithm like SM-2. No retention metrics yet.
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
