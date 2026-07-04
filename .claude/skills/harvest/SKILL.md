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

2. **Present the harvest table** (concept · class · suggested action). Keep it
   scannable — a checklist, not a summary essay.

3. **Act on the user's picks:**
   - Landed + confirmed → run the **add-to-notes** flow per concept (its
     comprehension check still applies unless bypassed).
   - Half-landed → append a row to `notes/_understanding-log.md` → Open gaps
     (`trigger: next review`).
   - Ops/procedural → append a row with the point-of-use trigger.

4. **Learning hooks check.** If the session touched a project step with an open
   hook in `learning-path.md` → `## Learning hooks`, say whether the hook was
   covered or remains open.

## Rules

- **Never pressure.** Suggest; the user decides what gets captured. Skipped
  concepts simply don't appear in any log.
- Don't re-teach during harvest — if something needs re-explaining it's
  half-landed by definition: log it.
- If nothing worth capturing happened, say so in one line and stop. An empty
  harvest is a valid harvest.
