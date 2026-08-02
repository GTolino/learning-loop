---
name: harvest
description: Invoked when the user says "harvest this session" or "wrap up" at the end of a learning/working session. Sweeps the conversation for concepts covered, classifies them (landed / half-landed / defer-to-point-of-use), offers capture via add-to-notes, logs the rest to notes/_understanding-log.md, and flags learning hooks touched. The force-learning close ritual — nothing falls through when the terminal closes.
---

# Harvest — end-of-session capture sweep

Trigger: **"harvest this session"** / **"wrap up"**. A 2-minute close ritual,
not a new work phase.

## Steps

1. **Sweep the session.** List every concept genuinely covered (taught,
   debugged, discovered — not merely mentioned), each with a one-line gist.
   Classify each:
   - **Landed** — explained, applied, the user clearly got it.
   - **Half-landed** — covered but wobbly, or interrupted.
   - **Ops/procedural** — done hands-on; per the point-of-use preference the
     review belongs at deployment time, not now.
   - **Probably not worth capturing** — touched in passing, and you judge the user
     would never re-read it. **A proposal, never a decision:** put it in the table
     with that suggestion and let the user say. Never judge by whether it serves a
     *current* goal — goals retire, and the note answering a retired question is
     often the one that pays off later.

2. **Present the harvest table** (concept · class · suggested action). Keep it
   scannable — a checklist, not a summary essay.

3. **Act on the user's picks. Every captured class produces a NOTE — only the
   `status` and the review timing differ.** A log row is always *in addition to*
   a note, never instead of one.
   - **Landed** + confirmed → run the **add-to-notes** flow per concept (its
     comprehension check still applies unless bypassed) → `status: stable`.
   - **Half-landed** → scribe it as **`status: wip`**, with the note body naming
     **the misconception impersonally** — the wrong model, why it's wrong, and the
     experiment that would settle it — **plus** a row in
     `notes/_understanding-log.md` → Open gaps (`trigger: next review`) whose
     `related note` points at it.
   - **Ops/procedural** → scribe it as **`status: reference`** — a runbook the user
     can follow again unaided (exact commands, why each step, what breaks if
     skipped) — **plus** a row with the point-of-use trigger.

4. **Learning hooks check.** If the session touched a project step with an open
   hook in `learning-path.md` → `## Learning hooks`, say whether the hook was
   covered or remains open.

## Rules

- **Never pressure, and never decide.** You classify and suggest; **the user alone
  decides what gets captured.** Skipped concepts simply don't appear in any log.
- Don't re-teach during harvest — if something needs re-explaining it's
  half-landed by definition: capture it as `wip` and log it.
- ⚠ **A log row must never point at a note that doesn't contain the concept.**
  If a row has nowhere to point, the note is missing — write it. The log is a
  review *queue*, not a substitute for the material being reviewed.
- Notes are **study material, not a transcript** — the scribe owns the format
  (`AGENTS.md` sets the standard). A `wip` note is still one to learn from.
- If nothing worth capturing happened, say so in one line and stop. An empty
  harvest is a valid harvest.
