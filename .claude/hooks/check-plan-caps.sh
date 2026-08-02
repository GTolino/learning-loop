#!/bin/bash
# PostToolUse hook (Write|Edit): enforce the size contract on the two state files
# that otherwise grow forever — learning-path.md and _understanding-log.md.
#
# Caps live in .claude/agents/advisor.md; this hook is the deterministic half.
# It never blocks a write — it reports the violation back so the agent that just
# made it fixes it now, instead of leaving it for a cleanup that never comes.

VAULT="${CLAUDE_PROJECT_DIR:-$PWD}/notes"

FILE=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$FILE" in
  "$VAULT"/learning-path.md|"$VAULT"/_understanding-log.md) ;;
  *) exit 0 ;;
esac

OUT=""

if [ "$FILE" = "$VAULT/learning-path.md" ]; then
  # section -> line cap. Headings are matched by prefix, so the decorated
  # variants ("## Coverage map — …") still resolve.
  OUT=$(awk '
    BEGIN{
      cap["## Goals"]=30; cap["## Coverage map"]=180
      cap["## Required for future goals"]=60; cap["## Recommended next"]=40
      cap["## Learning hooks"]=150; cap["## Courses"]=30
    }
    /^## /{ if(sec!="") lines[sec]=n; sec=$0; n=0; next }
    { n++ }
    END{
      if(sec!="") lines[sec]=n
      for(s in lines) for(c in cap)
        if(index(s,c)==1 && lines[s]>cap[c])
          printf "  %s — %d lines (cap %d)\n", c, lines[s], cap[c]
    }' "$FILE")

  WORDS=$(awk '/^## State of play/{f=1;next} /^## /{f=0} f' "$FILE" | wc -w | tr -d ' ')
  if [ "${WORDS:-0}" -gt 2200 ]; then
    OUT="${OUT}
  ## State of play — ${WORDS} words (budget 2000). Fold harder before archiving."
  fi
else
  # understanding log: rows are pointers, not narratives. The concept lives in
  # the note the row points at. Measure the re-test-target CELL only — the note
  # link and trigger columns are structure, not prose, and note titles are long.
  OUT=$(awk -F' *\\| *' '/^\| [0-9]{4}-/ && length($3)>180{
      printf "  row %d: target cell %d chars — %.55s…\n", NR, length($3), $3
    }' "$FILE" | head -8)
  [ -n "$OUT" ] && OUT="${OUT}
  (a row points at a note; the misconception belongs IN the note, not here)"
fi

[ -z "$OUT" ] && exit 0

cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"⚠ Size contract violated in $(basename "$FILE") — fix it in this turn, do not defer:\n$(printf '%s' "$OUT" | python3 -c 'import sys,json;print(json.dumps(sys.stdin.read())[1:-1])')\nPrune by MOVING the excess to the matching *-archive.md (append, dated) — never delete."}}
EOF
exit 0
