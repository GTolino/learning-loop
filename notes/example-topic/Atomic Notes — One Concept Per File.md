---
title: Atomic Notes — One Concept Per File
topic: example-topic
tags: [fundamentals]
created: 2026-07-05
summary: Each note holds exactly one concept and its filename IS the concept name, so [[wikilinks]] resolve and the one-line summary powers fast retrieval via INDEX.md.
related: []
status: reference
---

## Atomic Notes — One Concept Per File

**What it is:**
This note is a working example of the vault schema — and it will be deleted by
the setup interview. One concept per file; the filename is the concept name so
`[[wikilinks]]` to it resolve; the frontmatter `summary` is the retrieval
payload that appears in the generated `INDEX.md`.

**Why it matters:**
Agents (and future you) retrieve by scanning INDEX summaries, not by reading
every note. A note that bundles five concepts can't be linked to, quizzed on,
or retrieved precisely.

**Key commands or terms:**
```bash
# regenerate the index manually (normally the hook does this)
cd notes && python3 generate_index.py
```

**Related:** —

**Source:** Template example — 2026-07-05
