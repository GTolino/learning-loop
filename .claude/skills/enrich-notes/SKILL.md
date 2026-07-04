---
name: enrich-notes
description: Invoked when the user says "enrich my notes" OR "fill my gaps" — or asks to improve, fact-check, fill gaps in, or add resources to notes. One skill, two entry points sharing a log-first rule; the enricher subagent does the work. Default scope is the most recently active course folder; the main vault (and notes/_understanding-log.md) when the user says "my vault" or names a vault note.
---

# Enrich notes / fill my gaps

Triggers: **"enrich my notes"** (optionally "…on [topic]" or an explicit
path/note name) and **"fill my gaps"**. Both route here — the same action with
different emphasis, governed by the **log-first rule**.

## Scope resolution

- Explicit note/path/topic named → that target, wherever it is.
- "my vault" / a vault note named → the main vault; gap source
  `notes/_understanding-log.md`.
- Nothing specified → the **most recently active course folder**: among
  `notes/*/` folders containing a `_course.md`, the one most recently modified.

## Log-first rule

1. If the resolved scope has an `_understanding-log.md` with **open gaps**,
   those come first: the enricher writes each answer into the most relevant
   note and moves the entry to Resolved. This is what "fill my gaps" means.
2. Only after the log is clear (or absent) does general enrichment run:
   improve flow, fact-check, append curated resources.

## Steps

1. **Invoke the enricher subagent** (Agent tool, `subagent_type: enricher`).
   Pass: the resolved scope, which trigger fired, and any open gap entries.
2. **Relay the enricher's summary**: notes changed, gaps filled and resolved,
   corrections flagged inline, resources added.

## Rules

- The enricher owns the editing — do not edit notes yourself.
- Never write outside the vault unless the user explicitly names an external path.
- Vault notes keep the vault frontmatter schema; course notes keep course
  conventions. Never convert one into the other.
