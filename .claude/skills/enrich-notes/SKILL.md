---
name: enrich-notes
description: Invoked when the user says "enrich my notes" OR "fill my gaps" — or asks to improve, fact-check, fill gaps in, or add resources to notes. One skill, two entry points sharing a log-first rule; the enricher subagent does the work. Default scope is the most recently active course folder; the hub vault (and its generated review queue in INDEX.md) when the user says "my vault" or names a vault note.
---

# Enrich notes / fill my gaps

Triggers: **"enrich my notes"** (optionally "…on [topic]" or an explicit
path/note name) and **"fill my gaps"**. Both route here — they are the same
action with different emphasis, governed by the **log-first rule**.

## Scope resolution

- Explicit note/path/topic named → that target, wherever it is.
- "my vault" / a hub note named / said at the hub about hub content → the hub
  vault; the gap source is `INDEX.md` → `## Review queue` (generated from note
  frontmatter — read only).
- Nothing specified → the **most recently active course folder**: among
  `notes/*/` folders containing a `_course.md`, the one most recently
  modified. (Do not hardcode a folder — courses come and go.)

## Log-first rule

1. If the resolved scope has **open gaps**, those come first — the hub's generated
   `## Review queue`, or a course folder's `_understanding-log.md`. The enricher
   writes each answer into the most relevant note. This is what "fill my gaps" means.
   ⚠ **Filling a gap never promotes a note.** Only a passing re-test ("quiz me")
   flips `wip` → `stable`, so an enriched note stays queued until it is re-tested.
2. Only after the log is clear (or if it doesn't exist) does general
   enrichment run: improve flow, fact-check, append curated resources.
   A plain "enrich my notes on X" with an empty log goes straight here.

## Steps

1. **Invoke the enricher subagent** (Agent tool, `subagent_type: enricher`).
   Pass: the resolved scope, which trigger fired, and the log-first rule
   outcome (open gap entries to work, if any).
2. **Relay the enricher's summary**: which note(s) changed, gaps filled and
   moved to Resolved, corrections flagged inline, resources added.

## Rules

- The enricher owns the editing — do not edit notes yourself.
- Never write outside the vault unless the user explicitly names an external
  path.
- Hub atomic notes keep the hub frontmatter schema; course notes keep course
  conventions. The enricher must not convert one into the other.
