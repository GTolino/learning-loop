#!/bin/bash
# PostToolUse hook (Write|Edit): regenerate INDEX.md when a vault note changes.
# Reads the hook JSON on stdin, extracts tool_input.file_path, and reruns
# generate_index.py only for .md files inside a vault topic folder. Spokes
# (folders with their own CLAUDE.md), underscore/hidden folders, and
# underscore-prefixed files are ignored. Silent; never blocks the tool.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
VAULT="$ROOT/notes"

FILE=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$FILE" in
  "$VAULT"/*/*.md) ;;   # a note inside a vault subfolder — candidate
  *) exit 0 ;;
esac

sub="${FILE#"$VAULT"/}"          # e.g. topic/Some Note.md
topic="${sub%%/*}"
base=$(basename "$FILE")

case "$topic" in .*|_*) exit 0 ;; esac
[ -f "$VAULT/$topic/CLAUDE.md" ] && exit 0   # spoke — own conventions, not indexed
case "$base" in _*) exit 0 ;; esac

cd "$VAULT" && python3 generate_index.py >/dev/null 2>&1
exit 0
