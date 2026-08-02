#!/bin/bash
# SessionStart hook: inject the current learning state so the professor (or
# Course Tutor) starts with context instead of manual file reads.
#
# ⚠ NOTHING HERE TRUNCATES. Sections are injected whole. The old version cut the
# hooks list at 50 lines and the review queue at 8 rows — silently — which meant
# the Recommended-next item could name a hook the same injection had just hidden.
# Size is governed in ONE place now: the thresholds in thresholds.sh. If a section
# is over budget this hook says so at the bottom, so the session that pays the
# context cost is the one that gets asked to trim it.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
VAULT="$ROOT/notes"
PLAN="$VAULT/learning-path.md"

# shellcheck source=thresholds.sh
. "$(dirname "$0")/thresholds.sh"

[ -d "$VAULT" ] || exit 0

# Inside a spoke (course folder): show only that spoke's state. Reached because
# each spoke carries its own .claude/settings.json pointing back at this script.
case "$PWD" in
  "$VAULT"/*)
    sub="${PWD#"$VAULT"/}"
    top="${sub%%/*}"
    if [ -n "$top" ] && [ -f "$VAULT/$top/CLAUDE.md" ]; then
      LOG="$VAULT/$top/_understanding-log.md"
      if [ -f "$LOG" ]; then
        GAPS=$(awk '/^## Open gaps/{f=1;next} /^## /{f=0} f' "$LOG" | grep '^| [0-9]')
        echo "## Course dashboard — $top (auto-injected)"
        echo
        echo "Open gaps in _understanding-log.md (re-test or fill):"
        if [ -n "$GAPS" ]; then printf '%s\n' "$GAPS"; else echo "_Empty — nothing due._"; fi
        echo
        echo "_Magic words here: quiz me · fill my gaps · promote to my vault_"
      fi
      exit 0
    fi
    ;;
esac

# Hub session — the learning dashboard.
echo "## Learning dashboard (auto-injected at session start)"
echo

# A fresh clone has no roadmap yet — the setup interview writes it. Say so once
# instead of letting every plan-driven section fail against a missing file.
if [ ! -f "$PLAN" ]; then
  echo "_No \`notes/learning-path.md\` yet — say **\"set up my learning environment\"** to"
  echo "run the bootstrap interview and have the advisor build your roadmap._"
  echo
fi

if [ -f "$PLAN" ]; then
echo "### Recommended next — from learning-path.md"
awk '/^## Recommended next/{f=1;next} /^## /{f=0} f' "$PLAN"
echo
DRIFT=$(awk '/^## Goal drift/{f=1;next} /^## /{f=0} f' "$PLAN" | grep -v '^[[:space:]]*$')
if [ -n "$DRIFT" ]; then
  echo "### ⚠ Goal drift — \`My Goals.md\` disagrees with the plan"
  printf '%s\n' "$DRIFT"
  echo
  echo "_Say **\"update my goals\"** to review these. Nothing edits that file without you._"
  echo
fi

echo "### Learning hooks — weave in when the project step arrives"
awk '/^## Learning hooks/{f=1;next} /^## /{f=0} f' "$PLAN"
echo
fi

# Review queue — GENERATED into INDEX.md from note frontmatter, never maintained
# by hand. The blockquote in that section explains the mechanism to a reader of
# the file; strip it here, the professor already knows the rules.
echo "### Vault review queue — generated from note frontmatter"
awk '/^## Review queue/{f=1;next} /^## /{f=0} f' "$VAULT/INDEX.md" | grep -v '^>'
echo

for LOG in "$VAULT"/*/_understanding-log.md; do
  [ -f "$LOG" ] || continue
  N=$(awk '/^## Open gaps/{f=1;next} /^## /{f=0} f' "$LOG" | grep -c '^| [0-9]')
  [ "$N" -gt 0 ] && echo "- Course \`$(basename "$(dirname "$LOG")")\`: $N open gap(s) — quiz or fill in that spoke"
done
echo

# Read-time size nag. The write-time hook fires in whichever session wrote the
# file — often not this one. This tells the session actually carrying the weight.
OVER=""
[ -f "$PLAN" ] && OVER=$(over_threshold "$PLAN")
if [ -n "$OVER" ]; then
  echo "### 📏 Over review threshold — everything above was injected in full"
  printf '%s\n' "$OVER"
  echo
  echo "_Ask the **advisor** to review these sections: what groups, what shrinks, what"
  echo "archives to \`learning-path-archive.md\` — and what earns its place and stays._"
  echo
fi

echo "_Magic words: quiz me · add to my notes · harvest this session · fill my gaps · enrich my notes · start a course · what should I study next?_"
exit 0
