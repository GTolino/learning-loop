---
name: add-to-notes
description: Invoked when the user says "add to my notes" — or otherwise signals that a concept just covered has fully landed and should be logged/captured/saved. Hands the concept to the scribe subagent to write into the vault and push to git, then runs the advisor to update the learning plan. Only for complete concepts, never mid-explanation.
---

# Add to notes

Trigger: the user says **"add to my notes"** (or asks to log / capture / save
the concept just covered). Only fire when a topic is complete — never
mid-explanation. The user decides when something is ready.

## Steps

0. **Comprehension check FIRST (gate before scribe).** Run a short active-recall
   quiz (3–5 questions, mixed Recall / Application / Edge types) to confirm the
   concept fully landed. Assess the answers, clear up any gaps, and only proceed
   to the scribe once understanding is confirmed.
   **Bypass:** skip if the user says so ("skip the check", "just log it").
   **Log what wobbled:** any 🟡/❌ answer — even one cleared up on the spot —
   gets a row in `notes/_understanding-log.md` → Open gaps
   (`trigger: next review`) so "quiz me" re-tests it later. Shaky answers are
   the review queue's input; don't discard them.
   **Point-of-use deferral (ops/procedural concepts):** don't force a quiz right
   after a procedure — if the user defers ("defer the check"), log a row with
   the point-of-use trigger (e.g. `when deploying X`) and proceed to the scribe.

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
