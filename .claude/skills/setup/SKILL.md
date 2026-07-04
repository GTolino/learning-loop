---
name: setup
description: Invoked when the user says "set up my learning environment" — the one-time bootstrap after cloning the template. Interviews the user, personalizes AGENTS.md, writes notes/My Goals.md, seeds the tag registry, has the advisor build learning-path.md from scratch, and cleans up the example note.
---

# Setup — bootstrap the learning environment

Trigger: **"set up my learning environment"** (first run after cloning).

## Steps

1. **Interview — short, one question at a time.** Collect:
   - Name (for `AGENTS.md`'s title).
   - What they're building/learning and the north star (2–4 sentences).
   - 2–5 concrete goals, and any active projects.
   - Learning-style preferences worth encoding (pace, tone, cost constraints,
     anything they want the professor to always/never do).
   - Whether they're currently taking any outside course (if yes, offer to run
     "start a course" at the end).

2. **Personalize `AGENTS.md`:** replace every `<PLACEHOLDER>` with their
   answers. Keep the rest of the file intact — it's the methodology.

3. **Write `notes/My Goals.md`:** their goals in their own words, structured
   with headings (What I am building / Goals / How I'm learning / Projects /
   Notes to myself). This file is theirs — tell them to edit it freely and say
   "update my goals" when it changes.

4. **Seed `notes/_tags.md`:** propose 6–10 starter tags from their topics; get
   a quick confirm.

5. **Clean up:** delete `notes/example-topic/` (the schema demo), then run
   `python3 generate_index.py` from `notes/` to produce a fresh INDEX.

6. **Invoke the advisor** (Agent tool, `subagent_type: advisor`) to build
   `notes/learning-path.md` from scratch (it has first-run instructions).
   Relay the advisor's recommended starting point.

7. **Close:** commit everything (`setup: personalized learning environment`),
   remind them the repo should be **private**, and show the magic-words table
   from the README. Suggest the first session: "just ask me about something
   you're curious about — when it lands, say *add to my notes*."

## Rules
- One question at a time; keep the whole interview under ~5 minutes.
- Don't invent goals or pad their answers — write what they said.
- If AGENTS.md has no placeholders left (already set up), say so and offer
  "update my goals" instead.
