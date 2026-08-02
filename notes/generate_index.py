#!/usr/bin/env python3
"""Regenerate INDEX.md for the hub vault from note frontmatter.

Scans the hub topic folders, parses each note's YAML frontmatter, and emits a
rolled-up map grouped by topic (Map-of-Content hubs first, then the rest), plus
a Gaps section listing concepts referenced via [[wikilinks]] that have no note.

Also emits the REVIEW QUEUE, derived from each note's `status` and `review`
fields. The note is the only carrier of review state — there is no second file
to keep in sync, so a queue entry can never point at a note that doesn't hold
the concept. `status: wip` is due now; a `review:` value defers to a moment;
`stable` is terminal. The SessionStart hook injects that section.

Topic folders are AUTO-DISCOVERED: any top-level directory that is not hidden,
not underscore-prefixed, and not a spoke (spokes — e.g. course folders — carry
their own CLAUDE.md) is indexed. TOPIC_ORDER only sets display order; new
topic folders the scribe creates appear automatically.

Normally run automatically by the PostToolUse hook (`.claude/hooks/
regen-index.sh`) whenever a hub note is written. Manual fallback from the
vault root:

    python3 generate_index.py

A note is indexed only if it has YAML frontmatter with a `title`. Files missing
that are reported on stderr so they can be fixed — they are the to-do list of
notes that still need frontmatter.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

VAULT = Path(__file__).resolve().parent
INDEX = VAULT / "INDEX.md"

# Optional display order for topics; any topic folder not listed here is
# appended alphabetically. Fine to leave empty.
TOPIC_ORDER: list[str] = []

FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
# [[target]] or [[target|display]] or [[target#heading]], but not ![[embeds]]
WIKILINK_RE = re.compile(r"(?<!\!)\[\[([^\]\n]+?)\]\]")
KEY_RE = re.compile(r"^([A-Za-z_][\w-]*):\s?(.*)$")


def parse_frontmatter(text: str) -> dict[str, str] | None:
    """Minimal line-based YAML reader for the flat hub schema.

    Treats a line as a new key only when it starts at column 0 and matches
    `key:`; anything else is folded into the previous value (handles wrapped
    summaries). Good enough for the scribe-written schema; not general YAML.
    """
    m = FRONTMATTER_RE.match(text)
    if not m:
        return None
    data: dict[str, str] = {}
    key: str | None = None
    for raw in m.group(1).split("\n"):
        if not raw.strip():
            continue
        km = KEY_RE.match(raw)
        if km and not raw[0].isspace():
            key = km.group(1)
            data[key] = km.group(2).strip()
        elif key is not None:
            data[key] = (data[key] + " " + raw.strip()).strip()
    return data


def unquote(s: str) -> str:
    s = s.strip()
    if len(s) >= 2 and s[0] in "\"'" and s[-1] == s[0]:
        return s[1:-1]
    return s


def parse_list(s: str) -> list[str]:
    """Parse a frontmatter list value like ["a", "b"] or [a, b]."""
    s = s.strip()
    if s.startswith("[") and s.endswith("]"):
        inner = s[1:-1]
        out: list[str] = []
        for a, b, c in re.findall(r'"([^"]*)"|\'([^\']*)\'|([^,]+)', inner):
            v = (a or b or c).strip()
            if v:
                out.append(v)
        return out
    return [unquote(s)] if s else []


# INDEX is a SCANNING map, not a substitute for the notes. Notes carry whatever
# summary they need; the index clips at emit time so the map stays cheap to scan.
# The agent reads a clipped line, decides which note is relevant, and opens it for
# the full text. Never clip anything in a note itself.
SUMMARY_MAX = 160


def clip(s: str, n: int = SUMMARY_MAX) -> str:
    """Cut to n chars on a word boundary, marking that more lives in the note."""
    if len(s) <= n:
        return s
    return s[:n].rsplit(" ", 1)[0].rstrip(" ,;:—-") + " …"


def sort_key(title: str) -> str:
    """Case-insensitive, ignoring leading non-alphanumerics (backticks, /)."""
    return re.sub(r"^[^0-9A-Za-z]+", "", title).lower()


class Note:
    def __init__(self, path: Path, fm: dict[str, str]):
        self.stem = path.stem  # wikilink target = filename without .md
        self.title = unquote(fm.get("title", path.stem))
        self.summary = unquote(fm.get("summary", "")).strip()
        self.aliases = parse_list(fm.get("aliases", ""))
        # Review state — the note is the ONLY carrier. `status` says whether the
        # concept is verified; `review` defers it to a moment. Queue membership is
        # derived from these two, so nothing hand-maintained can drift from them.
        self.status = unquote(fm.get("status", "")).strip() or "unknown"
        self.review = unquote(fm.get("review", "")).strip()
        self.topic = path.parent.name
        s = self.summary.lower()
        self.is_hub = s.startswith("map of content") or s.startswith("map-of-content")

    @property
    def queued(self) -> bool:
        """`wip` is due now; any `review:` trigger waits. `stable` is terminal."""
        return self.status == "wip" or bool(self.review)

    def entry(self) -> str:
        marker = "🗺 " if self.is_hub else ""
        summary = clip(self.summary) if self.summary else "_(no summary)_"
        return f"- {marker}[[{self.stem}|{self.title}]] · `{self.status}` — {summary}"


def collect() -> tuple[dict[str, list[Note]], set[str], list[str], list[Path]]:
    topics: dict[str, list[Note]] = {}
    known: set[str] = set()       # lowercased stems + aliases that links can resolve to
    link_targets: list[str] = []  # every [[target]] seen, normalized
    skipped: list[Path] = []

    folders = [
        d for d in sorted(VAULT.iterdir())
        if d.is_dir()
        and not d.name.startswith((".", "_"))
        and not (d / "CLAUDE.md").exists()  # spokes keep their own conventions
    ]
    for folder in folders:
        for md in sorted(folder.glob("*.md")):
            text = md.read_text(encoding="utf-8")
            fm = parse_frontmatter(text)
            if not fm or "title" not in fm:
                skipped.append(md)
                continue
            note = Note(md, fm)
            topics.setdefault(folder.name, []).append(note)
            known.add(note.stem.lower())
            for a in note.aliases:
                known.add(a.lower())
            for tgt in WIKILINK_RE.findall(text):
                t = tgt.split("|", 1)[0].split("#", 1)[0].strip()
                if t.lower().endswith(".md"):
                    t = t[:-3].strip()  # tolerate [[note.md]] links
                t = t.lower()
                # skip empties and POSIX classes like [[:digit:]] in code blocks
                if not t or re.fullmatch(r":\w+:", t):
                    continue
                link_targets.append(t)
    return topics, known, link_targets, skipped


def build(topics, known, link_targets) -> str:
    ordered = TOPIC_ORDER + sorted(t for t in topics if t not in TOPIC_ORDER)
    total = sum(len(v) for v in topics.values())
    hubs = sum(1 for v in topics.values() for n in v if n.is_hub)

    out: list[str] = []
    out.append("# INDEX — Hub Vault Map\n")
    out.append(
        "> Auto-generated from note frontmatter. Rolled-up summaries for fast "
        "retrieval\n> and coverage review. Regenerate with `generate_index.py` "
        "after adding notes.\n"
    )
    counts: dict[str, int] = {}
    for v in topics.values():
        for n in v:
            counts[n.status] = counts.get(n.status, 0) + 1
    roll = " · ".join(f"{c} {s}" for s, c in sorted(counts.items(), key=lambda kv: -kv[1]))
    out.append(
        f"**{total} hub notes** across {len(topics)} topics. "
        f"{hubs} Map-of-Content hubs.\n"
    )
    out.append(f"**Status:** {roll}.\n")

    # Review queue — generated, never maintained. This is what the SessionStart
    # hook injects; it replaced a hand-written _understanding-log.md whose rows
    # could point at notes that did not hold the concept.
    due = sorted(
        (n for v in topics.values() for n in v if n.status == "wip" and not n.review),
        key=lambda n: sort_key(n.title),
    )
    waiting = sorted(
        (n for v in topics.values() for n in v if n.review),
        key=lambda n: (n.review.lower(), sort_key(n.title)),
    )
    out.append(f"## Review queue ({len(due) + len(waiting)})\n")
    out.append(
        "> Derived from frontmatter, not maintained by hand. **`status: wip`** is due "
        "now —\n> unverified comprehension. **`review:`** is a point-of-use moment and "
        "is independent\n> of status: a `stable` note can still say *revisit me when "
        "you next touch X*.\n> A `stable` note with no trigger is never listed — that "
        "is what terminal means.\n> Closing: flip `wip` → `stable` on a passing "
        "re-test; drop `review:` once the moment passes.\n"
    )
    out.append(f"**Due now ({len(due)})**\n")
    if due:
        out.extend(
            f"- [[{n.stem}|{n.title}]] ({n.topic}) — "
            f"{clip(n.summary) if n.summary else '_(no summary)_'}"
            for n in due
        )
    else:
        out.append("_Nothing due._")
    out.append("")
    out.append(f"**Waiting on a trigger ({len(waiting)})**\n")
    if waiting:
        out.extend(
            f"- **{n.review}** → [[{n.stem}|{n.title}]] · `{n.status}`" for n in waiting
        )
        out.append(
            "\n_A trigger whose moment has arrived: delete the note's `review:` "
            "line and it is due._"
        )
    else:
        out.append("_None deferred._")
    out.append("")

    for topic in ordered:
        notes = topics.get(topic)
        if not notes:
            continue
        notes.sort(key=lambda n: (not n.is_hub, sort_key(n.title)))
        out.append(f"## {topic} ({len(notes)})\n")
        out.extend(n.entry() for n in notes)
        out.append("")

    # Gaps: linked but never written. Resolved against stems + aliases.
    gaps: dict[str, int] = {}
    for t in link_targets:
        if t not in known:
            gaps[t] = gaps.get(t, 0) + 1
    out.append("## ⚠ Gaps — linked but not written\n")
    out.append(
        "> Concepts referenced in `[[wikilinks]]` with no matching note or "
        "alias.\n> Many are near-miss naming after the atomic-note restructure "
        "(the concept\n> exists, the title drifted) — review before treating as "
        "a real to-do.\n"
    )
    if gaps:
        for tgt, n in sorted(gaps.items(), key=lambda kv: (-kv[1], kv[0])):
            times = f" — referenced {n}×" if n > 1 else ""
            out.append(f"- [[{tgt}]]{times}")
    else:
        out.append("_None — every wikilink resolves._")
    out.append("")

    return "\n".join(out) + "\n"


def main() -> int:
    topics, known, link_targets, skipped = collect()
    if not topics:
        print("No topic folders found — run from the vault root.", file=sys.stderr)
        return 1
    INDEX.write_text(build(topics, known, link_targets), encoding="utf-8")

    total = sum(len(v) for v in topics.values())
    hubs = sum(1 for v in topics.values() for n in v if n.is_hub)
    print(f"INDEX.md written: {total} notes, {hubs} hubs, "
          f"{len(topics)} topics.", file=sys.stderr)
    # Per-note problems, reported with the path so a caller can filter to the file
    # it just wrote. These used to be swallowed by the hook's 2>/dev/null — which is
    # how a note with no title stayed unindexed for months.
    for p in skipped:
        print(f"{p.relative_to(VAULT)}: NO frontmatter title — not indexed at all",
              file=sys.stderr)
    for notes in topics.values():
        for n in notes:
            if not n.summary:
                print(f"{n.topic}/{n.stem}.md: no summary — the retrieval payload "
                      f"INDEX is built from", file=sys.stderr)
            if n.status == "unknown":
                print(f"{n.topic}/{n.stem}.md: no status — it cannot enter or leave "
                      f"the review queue", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
