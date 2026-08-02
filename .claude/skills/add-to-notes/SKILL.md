---
name: add-to-notes
description: Invoked when the user says "add to my notes" — or otherwise signals that a concept just covered has fully landed and should be logged/captured/saved. Hands the concept to the scribe subagent to write into the vault and push to git, then runs the advisor to update the learning plan. Only for complete concepts, never mid-explanation.
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
   - **Ops/procedural with the review deferred** → `status: reference`: a runbook
     the user can follow unaided (exact commands, why each step, what breaks if
     skipped). Don't force a quiz right after a procedure.
   - **Log every 🟡/❌**, even one cleared up on the spot, as a row in
     `notes/_understanding-log.md` → Open gaps — `trigger: next review` (or the
     point-of-use moment, e.g. `when deploying X`), `related note` pointing at the
     note just written. ⚠ **A row must never point at a note that doesn't contain
     the concept** — that is the failure this step prevents.

1. **Invoke the scribe subagent** (Agent tool, `subagent_type: scribe`).
   Do **not** summarize the concept first — pass the raw context:
   - The topic or concept just covered
   - A clear summary of what was explained
   - Key commands, terms, or tools mentioned
   - What it connects to from existing notes
2. **Relay the scribe's result**: what was written, which file, the commit.
3. **Invoke the advisor** (Agent tool, `subagent_type: advisor`) automatically
   so the learning plan stays in sync. Relay its "recommended next".

## Rules
- Run the comprehension check before the scribe unless bypassed.
- Do not write notes yourself — the scribe owns the vault.
- One concept per invocation, unless the user logged several at once.
- Both subagents own their files; you only orchestrate and relay.
