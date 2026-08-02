#!/bin/bash
# SessionStart hook: inject the current learning state so the professor (or
# Course Tutor) starts with context instead of manual file reads. Compact by
# design — the depth lives in the files themselves.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
VAULT="$ROOT/notes"

[ -d "$VAULT" ] || exit 0

# Inside a course spoke: show only that course's state.
case "$PWD" in
  "$VAULT"/*)
    sub="${PWD#"$VAULT"/}"
    top="${sub%%/*}"
    if [ -n "$top" ] && [ -f "$VAULT/$top/CLAUDE.md" ]; then
      LOG="$VAULT/$top/_understanding-log.md"
      if [ -f "$LOG" ]; then
        echo "## Course dashboard — $top (auto-injected)"
        echo
        echo "Open gaps in _understanding-log.md (re-test or fill):"
        awk '/^## Open gaps/{f=1;next} /^## /{f=0} f' "$LOG" | grep '^| [0-9]'
        echo
        echo "_Magic words here: quiz me · fill my gaps · promote to my vault_"
      fi
      exit 0
    fi
    ;;
esac

# Hub session — the learning dashboard.
LP="$VAULT/learning-path.md"
echo "## Learning dashboard (auto-injected at session start)"
echo
if [ -f "$LP" ]; then
  echo "### Recommended next — from learning-path.md"
  awk '/^## Recommended next/{f=1;next} /^## /{f=0} f' "$LP" | head -35
  echo
  DRIFT=$(awk '/^## Goal drift/{f=1;next} /^## /{f=0} f' "$LP" | grep -v '^[[:space:]]*$')
  if [ -n "$DRIFT" ]; then
    echo "### ⚠ Goal drift — \`My Goals.md\` disagrees with the plan"
    printf '%s\n' "$DRIFT"
    echo
    echo "_Say **\"update my goals\"** to review these. Nothing edits that file without you._"
    echo
  fi
echo "### Learning hooks — weave in when the project step arrives"
  # Cut at a hook boundary, never mid-sentence.
  awk '/^## Learning hooks/{f=1;next} /^## /{f=0} f' "$LP" \
    | awk 'BEGIN{n=0} /^[0-9]+\. /{if(n>50) exit} {print; n++}'
  echo
else
  echo "_No learning-path.md yet — say **\"set up my learning environment\"** to bootstrap._"
  echo
fi
if [ -f "$VAULT/_understanding-log.md" ]; then
  ROWS=$(awk '/^## Open gaps/{f=1;next} /^## /{f=0} f' "$VAULT/_understanding-log.md" | grep '^| [0-9]')
  OPEN=$(printf '%s\n' "$ROWS" | grep -c '^| [0-9]')
  echo "### Vault review queue — _understanding-log.md ($OPEN open)"
  if [ "$OPEN" -gt 0 ]; then
    # Overdue first: a point-of-use trigger whose moment already passed is not
    # future work, it is debt that silently stopped resurfacing.
    OVERDUE=$(printf '%s\n' "$ROWS" | grep '⏰')
    if [ -n "$OVERDUE" ]; then
      echo "**⏰ Triggers that already fired — overdue:**"
      printf '%s\n' "$OVERDUE"
      echo
    fi
    printf '%s\n' "$ROWS" | grep -v '⏰' | head -8
  else
    echo "_Empty — nothing due._"
  fi
  echo
fi
for LOG in "$VAULT"/*/_understanding-log.md; do
  [ -f "$LOG" ] || continue
  N=$(awk '/^## Open gaps/{f=1;next} /^## /{f=0} f' "$LOG" | grep -c '^| [0-9]')
  [ "$N" -gt 0 ] && echo "- Course \`$(basename "$(dirname "$LOG")")\`: $N open gap(s) — quiz or fill in that spoke"
done
echo
echo "_Magic words: quiz me · add to my notes · harvest this session · fill my gaps · enrich my notes · start a course · what should I study next?_"
exit 0
