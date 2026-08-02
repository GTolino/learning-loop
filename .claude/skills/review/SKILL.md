---
name: review
description: Invoked when the user says "quiz me" or "review my notes" at the hub (workspace root or vault, outside course spokes — spokes have their own quiz mode). Runs an active-recall retention quiz over the vault's atomic notes, re-tests what is due in the generated review queue (INDEX.md), and promotes notes from wip to stable on a pass. Optionally scoped to a topic ("quiz me on networking").
---

# Review — hub retention quiz

Trigger: **"quiz me"** / **"review my notes"**, optionally **"on [topic]"**.
This is the vault's retention loop — the same active-recall machinery the
Course Tutor uses, applied to the hub notes that otherwise never get
re-tested after capture.

## Picking questions

Build a 5–10 question set (fewer if the user asks for a quick one), drawn in
this priority order:

1. **`INDEX.md` → `## Review queue`** — re-tests first. It is **generated** from note
   frontmatter, so it is always current; awk the section, don't read the file.
   - **Due now** = `status: wip` notes. The open question is in the note's own
     "misconception it corrects" slot — that is the re-test target.
   - **Waiting on a trigger** = notes carrying a `review:` moment. Include one if its
     moment matches what the user is doing now, and ⚠ **sweep for triggers whose moment
     has already passed** — those are overdue, not future.
2. **Scoped topic** — if the user named one ("quiz me on networking"), grep that
   topic's section of `INDEX.md` (never read the whole file) and pick notes across
   ages: some recent, some old.
3. **No scope given** — mix: 2–3 from the queue (if any), then sample from
   `INDEX.md` weighted toward (a) notes serving the goal named in
   `learning-path.md` → `## Recommended next` and (b) older notes that likely faded.

**`stable` notes stay in the quiz pool.** Graduating from the *queue* is not graduating
from *recall* — spaced retention over old stable notes is the whole point of this skill.
What changes is the consequence: a miss on a `stable` note produces a **better note**, and
never sends it back to `wip` (see below).

Read a note's full content **only** for the notes you actually quiz on —
INDEX summaries are for picking, not for question-writing.

## Quiz mechanics (same as the Course Tutor)

- **One question at a time.** Mix three kinds: **Recall** (straight from the
  note), **Application** (use the concept on a new situation), **Edge**
  (adjacent ideas the note touches but doesn't explain — surfaces unknown
  unknowns).
- After each answer, grade out loud: ✅ solid / 🟡 shaky / ❌ didn't know.
  - ✅/🟡 → give the brief correct answer so it sticks.
  - ❌ → **don't hand over the answer.** Log it — the gap gets closed
    deliberately later via "fill my gaps".
- **Re-tests that pass** (✅ on a queued note) → edit that note's frontmatter:
  `status: wip` → `stable`, and delete its `review:` line if the moment has passed.
  That edit **is** the closure record — there is nothing else to update, and if you
  skip it nothing in the system does it for you. The note leaves the queue on the
  next regen, automatically.
- **A miss on a `status: stable` note never demotes it.** `stable` is terminal: give
  the right answer and offer to fold the sharper understanding into the note.
- **A miss on a concept with no note at all** → the note is missing. Offer to write
  it (via "add to my notes"); a queue needs something to point at.
- End with a one-line scorecard: X✅ Y🟡 Z❌, N promoted to `stable`, and **name any
  note you left `wip`** so a queue entry that shouldn't be there is obvious.

## Rules

- You quiz and promote; the **enricher** writes answers into notes ("fill my gaps"),
  and filling a gap does **not** promote — only a passing re-test does.
- **Allowed note edits: the `status:` and `review:` frontmatter lines only.** Nothing
  else in an atomic note is yours to touch — body changes go through the enricher or
  the scribe.
- **Never edit `INDEX.md`** — it is generated. Change the note; the index follows.
- Keep it short and fun — this is retention practice, not an exam. Celebrate
  streaks and resolved entries.
- In a course spoke this skill does not apply — the Course Tutor's quiz mode
  owns that folder.
