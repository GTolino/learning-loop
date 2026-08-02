---
name: review
description: Invoked when the user says "quiz me" or "review my notes" at the hub (outside course spokes — those have their own quiz mode). Runs an active-recall retention quiz over the vault's atomic notes, re-tests open entries in notes/_understanding-log.md, and logs misses there. Optionally scoped ("quiz me on networking").
---

# Review — vault retention quiz

Trigger: **"quiz me"** / **"review my notes"**, optionally **"on [topic]"**.
This is the vault's retention loop — captured knowledge gets re-tested, not
just stored.

## Picking questions

Build a 5–10 question set (fewer on request), drawn in this priority order:

1. **Open entries in `notes/_understanding-log.md`** — re-tests first. Include
   any entry whose `trigger` matches the current context (e.g. the user is
   deploying the thing named in a point-of-use trigger). ⚠ **Also sweep for triggers that
   already fired** — a point-of-use row whose moment has passed is overdue, not future.
2. **Scoped topic** — read that topic's section of `INDEX.md` (grep the
   section, don't read the whole file) and pick notes across ages: some recent,
   some old.
3. **No scope** — mix: 2–3 log re-tests (if any), then sample from INDEX
   weighted toward (a) notes serving the goal named in `## Recommended next` of
   `learning-path.md` and (b) older notes that likely faded.

Read a note's full content **only** for the notes you actually quiz on.

## Quiz mechanics

- **One question at a time.** Mix: **Recall** (straight from the note),
  **Application** (use the concept on a new situation), **Edge** (adjacent
  ideas the note touches but doesn't explain — surfaces unknown unknowns).
- Grade each answer out loud: ✅ solid / 🟡 shaky / ❌ didn't know.
  - ✅/🟡 → give the brief correct answer so it sticks.
  - ❌ → **don't hand over the answer.** Log it — it gets closed deliberately
    later via "fill my gaps".
- Log every 🟡 and ❌ as a row in `notes/_understanding-log.md` → Open gaps
  (`trigger: next review` unless a point-of-use moment fits better).
- **Re-tests that pass** → move the row to Resolved with
  `how closed: re-test passed YYYY-MM-DD`.
- End with a one-line scorecard: X✅ Y🟡 Z❌, N logged, M resolved.

## Rules

- You quiz and log; the **enricher** writes answers into notes ("fill my gaps").
- Never edit the atomic notes from this skill.
- Keep it short and fun — retention practice, not an exam. Celebrate streaks
  and resolved entries.
- Inside a course folder this skill does not apply — the Course Tutor's quiz
  mode owns that folder.
