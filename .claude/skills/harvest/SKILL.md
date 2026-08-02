---
name: harvest
description: Invoked when the user says "harvest this session" or "wrap up" at the end of a hub learning/working session. Sweeps the conversation for concepts covered, classifies them (landed / half-landed / ops / already-covered), offers capture via add-to-notes, sets each note's status and review trigger, and flags learning hooks touched. The force-learning close ritual — nothing falls through when the terminal closes.
---

# Harvest — end-of-session capture sweep

Trigger: **"harvest this session"** / **"wrap up"**. A 2-minute close ritual,
not a new work phase.

## Steps

1. **Sweep the session.** List every concept genuinely covered (taught,
   debugged, discovered — not merely mentioned), each with a one-line gist.
   Classify each:
   - **Landed** — explained, applied, user clearly got it.
   - **Half-landed** — covered but wobbly, or interrupted.
   - **Ops/procedural** — done hands-on but per the point-of-use preference the
     review belongs at deployment time, not now.
   - **Review** — the concept already has a `status: stable` note. Re-covering it is
     **not debt**: no demotion. If the session added something the note doesn't have,
     the action is *expand that note*; if it didn't, the action is *nothing*.
     **Grep `INDEX.md` before classifying anything as half-landed** — each line carries
     its note's `status`, so one grep tells you whether this class applies instead.
   - **Probably not worth capturing** — touched in passing, and you judge the user
     would never re-read it. **A proposal, never a decision:** put it in the table
     with that suggestion and let the user say. Never judge by whether it serves a
     *current* goal — goals retire, and the note answering a retired question is
     often the one that pays off later.

2. **Present the harvest table** (concept · class · suggested action). Keep it
   scannable — this is a checklist, not a summary essay.

3. **Act on the user's picks. Every captured class produces a NOTE — only the
   `status` and the review timing differ.** The note's frontmatter is the whole
   record; there is no separate log to keep in sync.
   - **Landed** + user confirms → run the **add-to-notes** flow per concept
     (its comprehension check still applies unless bypassed) → `status: stable`.
   - **Half-landed** → scribe it as **`status: wip`**, with the note body naming
     **the misconception impersonally** — the wrong model, why it's wrong, and
     the experiment that would settle it. `wip` **is** the queue entry.
   - **Ops/procedural** → scribe it as **`status: reference`** with a
     **`review:` trigger** (e.g. `review: when deploying <the service>`) — a runbook the
     user can follow again unaided (exact commands, why each step, what breaks
     if skipped).
   - **Review** → hand the scribe what's new so it expands the existing note.
     **No status change.**

   `wip` is subject to the **deepening filter** (`AGENTS.md`): leave a note `wip`
   only when closing it would change how the user reasons about that class of thing.
   A session can legitimately produce four notes and leave none of them queued.

   ⚠ **Run add-to-notes' steps 0–2 per concept and SKIP its step 4** — the advisor
   runs once, in step 5 below. Invoking it per concept re-reads and rewrites
   `learning-path.md` N times for one session's worth of change.

4. **Learning hooks check.** If the session touched a project step that has an
   open hook in `learning-path.md` → `## Learning hooks`, say whether the hook
   was covered or remains open, and pass that to the advisor in step 5.

5. **Invoke the course advisor ONCE** (Agent tool, `subagent_type: advisor`) if
   anything was scribed — with every concept captured this session and the hook
   status from step 4 in a single brief. Relay its "recommended next".

## Rules

- **Never pressure, and never decide.** You classify and suggest; **the user alone
  decides what gets captured.** Skipped concepts simply don't appear in any log.
- Don't re-teach during harvest — if something needs re-explaining it's
  half-landed by definition: capture it as `wip` and log it. **Unless it already
  has a stable note** — then it's the **Review** class, and re-explaining it is
  not a debt event.
- ⚠ **There is no queue without a note** — leaving a concept `wip` requires a note to
  mark. If a concept has nowhere to live, the note is missing: write it.
- **`wip` is for what's worth deepening, not for everything that wobbled.**
  A clarifying question the user asked is not a gap; a forgotten lookup detail
  belongs in the note body with the note marked `stable`. Fewer, better queue entries.
- Notes are **study material, not a transcript** — the scribe owns the format
  (`AGENTS.md` sets the standard). A `wip` note is still one to learn from.
- If nothing worth capturing happened, say so in one line and stop. An empty
  harvest is a valid harvest.
