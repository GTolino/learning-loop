# Tag registry

> The **controlled vocabulary** for note frontmatter `tags:`. The scribe may
> only use tags listed here — if a new tag is needed, it gets added here first,
> deliberately. A small, curated registry beats an organically grown mess:
> retrieval depends on tags meaning one thing.

## Tags

- `fundamentals` — foundational concepts underpinning a topic
- `how-to` — procedures and recipes executed at least once
- `gotcha` — traps, surprising behavior, hard-won debugging lessons
- `reference` — lookup material: tables, command lists, cheat sheets
- `architecture` — how pieces fit together; design decisions and patterns
- `project` — notes tied to a specific build or project

> Setup adds your topic tags (e.g. `networking`, `python`, `ml`) during the
> bootstrap interview.

## `status:` values (frontmatter)

- `stable` — comprehension verified; **terminal**, never goes back to `wip`
- `wip` — written, not yet verified (**this is what puts a note in the review queue**)
- `reference` — procedure/runbook, review deferred to point of use
- `project` — project state / planning
- `complete` — a finished body of work (e.g. a closed-out course note)

## `review:` (frontmatter, optional)

> A point-of-use moment — `review: when deploying X`. Independent of `status`: a
> `stable` note may still carry one. Absent = nothing deferred. Delete the line once
> the moment has passed. `status` and `review` together generate the review queue in
> `INDEX.md`; there is no separate log to maintain.
