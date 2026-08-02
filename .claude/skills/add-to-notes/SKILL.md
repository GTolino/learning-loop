---
name: add-to-notes
description: Invoked when the user says "add to my notes" — or otherwise signals that a concept just covered has fully landed and should be logged/captured/saved. Hands the concept to the scribe subagent to write into the Obsidian vault and push to git, then runs the course advisor to update the learning plan. Only for complete concepts, never mid-explanation.
---

# Add to notes

Trigger: the user says **"add to my notes"** (or asks to log / capture / save
the concept just covered). Only fire when a topic is complete — never
mid-explanation. The user decides when something is ready.

## Steps

0. **Comprehension check FIRST — it sets the note's `status`, it never gates the
   note** (full policy in `AGENTS.md`). Run 3–5 active-recall questions (Recall /
   Application / Edge), grade them, clear up gaps — then go to the scribe **either
   way**. A failed check means the user needs the note *more*, not less.
   - **Passed** → `status: stable`.
   - **Shaky (🟡/❌), or bypassed** ("skip the check" / "just log it") →
     `status: wip`, and give the scribe **the misconception stated impersonally**
     — the wrong model and what would settle it, never who answered what.
   - **Ops/infra with the review deferred** → `status: reference` plus a
     **`review:` trigger** (e.g. `review: when deploying <the service>`): a runbook the
     user can follow unaided (exact commands, why each step, what breaks if
     skipped). Don't force a quiz right after a procedure.
   - **The concept already has a `status: stable` note** → this is **review, not
     capture**. Don't re-check, don't demote. Hand the scribe what's *new* so it
     expands that note, and say that's what you did.
   **Check for an existing note by grepping `INDEX.md`** — every line carries its
   note's `status`, so one grep answers both "does this exist?" and "is it stable?".

1. **Invoke the scribe subagent** (Agent tool, `subagent_type: scribe`).
   Do **not** summarize the concept first — pass the raw context. The scribe is
   forbidden from inventing a worked example, so it can only write one if **you
   hand it the real material**:
   - The topic or concept just covered, and the mechanism as explained
   - ⚠ **The actual commands run and the actual output they printed**, verbatim
     from this session — this is the note's worked example and cannot be
     reconstructed later
   - The misconception, if the check surfaced one (stated impersonally)
   - What it connects to from existing notes
2. **Relay the scribe's result** to the user: what was written, which file,
   and the commit message it used.
3. **Nothing else to log — the note's frontmatter IS the queue entry.** A `wip`
   status queues it; a `review:` trigger defers it to a moment. There is no second
   file to update, so there is no way for a queue entry to point at nothing.
   Sanity-check only that the `status` you asked for matches the deepening filter
   (`AGENTS.md`): leave it `wip` only if closing it changes how the user reasons
   about the concept **as a class** — a missed flag name or path goes *into* the
   note and the note is `stable`.
4. **Invoke the course advisor ONCE — after the LAST note of this session's
   capture, never after each one.** Capture typically happens at session end and
   often covers several concepts; the advisor re-reads goals, `INDEX.md` and the
   plan and then rewrites it, so running it per note repeats that whole cycle for
   one session's worth of change.
   - More concepts still to capture → **scribe them all first**, then one advisor
     run covering the batch.
   - Last (or only) concept → invoke `subagent_type: advisor` now, brief it with
     **every** concept captured this session, and relay its "recommended next".
   - ⚠ **Skip entirely when running under `harvest`** — harvest owns the single
     advisor run in its own final step.
   - Already ran the advisor this session and nothing was scribed since? Don't
     run it again. It has nothing new to read.

## Rules
- Run the comprehension check (step 0) before the scribe unless the user
  bypasses it. Verify understanding, don't just capture.
- An explicit "add to my notes" **is** the user's call to capture — write it.
  The goal-relevance filter (`AGENTS.md`) governs the harvest sweep, not this.
- Do not write notes yourself — the scribe owns the vault.
- One concept per invocation, unless the user logged several at once.
- Both subagents own their files; you only orchestrate and relay.
