---
title: Atomic Notes — One Concept Per File
topic: example-topic
tags: [fundamentals]
created: 2026-07-05
summary: Each note holds exactly one concept and its filename IS the concept name, so [[wikilinks]] resolve and the one-line summary powers fast retrieval via INDEX.md.
related: []
status: stable
---

## Atomic Notes — One Concept Per File

**Mechanism.** A note's filename is its address. `generate_index.py` walks every
topic folder, reads each file's frontmatter, and emits `INDEX.md` as one line per
note — `title · summary · tags`, grouped by `topic`. Nothing else is indexed, so
the `summary` field *is* the retrieval payload: an agent scans a few hundred
summary lines instead of a few hundred full notes, then opens only what it needs.
`[[wikilinks]]` resolve by filename match, which is why the filename must be the
concept name and not a description of it. A link to a note that doesn't exist yet
isn't an error — the index collects those as the **Gaps** section, which is how
"things I've referenced but never written down" becomes a visible to-do list.

**Worked example.** This note is a working instance of the schema, and it will be
deleted by the setup interview. Regenerate the index and watch it appear:

```bash
cd notes && python3 generate_index.py
grep -A2 "example-topic" INDEX.md
```

The `summary:` line above is what lands in `INDEX.md` — not the body.

**The misconception it corrects.** *"Atomic means short."* It doesn't. A note can
run several screens and still be atomic; what makes it atomic is having **one
addressable subject**. The failure mode is the opposite one — a "Docker" note
holding images, volumes, networking and Compose. Nothing can link to *the volumes
part of it*, a quiz can't target it, and its one-line summary has to be so vague
it stops discriminating in search. Length is not the test; **can something else
link to exactly this idea** is the test.

**Prove it yourself.** Write one note covering two concepts, then try to write the
`summary:` line for it. If the summary needs an "and", the note needed splitting —
and the index entry it produces will be the one you skip past when scanning.

**Related:** —
