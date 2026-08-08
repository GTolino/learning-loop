#!/bin/bash
# PostToolUse hook (Write|Edit): regenerate INDEX.md + _coverage.md when a hub
# vault note changes. One generate_index.py run emits both, from one walk.
# Reads the hook JSON on stdin, extracts tool_input.file_path, and reruns
# generate_index.py only for .md files inside a hub topic folder. Spokes
# (folders with their own CLAUDE.md), underscore/hidden folders, and
# underscore-prefixed files are ignored. Silent; never blocks the tool.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
VAULT="$ROOT/notes"

FILE=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$FILE" in
  "$VAULT"/*/*.md) ;;   # a note inside a vault subfolder — candidate
  *) exit 0 ;;
esac

sub="${FILE#"$VAULT"/}"          # e.g. homelab/Some Note.md
topic="${sub%%/*}"
base=$(basename "$FILE")

case "$topic" in .*|_*) exit 0 ;; esac
[ -f "$VAULT/$topic/CLAUDE.md" ] && exit 0   # spoke — own conventions, not indexed
case "$base" in _*) exit 0 ;; esac

# Regenerate, and surface what the generator says ABOUT THE NOTE JUST WRITTEN.
# Its stderr used to go to /dev/null — which is how a note with no frontmatter
# title stayed silently unindexed for months. Filtered to this file so a fresh
# problem is visible now, without nagging about every older note on every write.
ERR=$(cd "$VAULT" && python3 generate_index.py 2>&1 >/dev/null)
MINE=$(printf '%s\n' "$ERR" | grep -F "$topic/$base:")
[ -z "$MINE" ] && exit 0

cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"📇 INDEX + _coverage regenerated — problem with the note just written:\n$(printf '%s' "$MINE" | python3 -c 'import sys,json;print(json.dumps(sys.stdin.read())[1:-1])')\nFix it in the frontmatter now; INDEX is generated, so editing it directly does nothing."}}
EOF
exit 0
