#!/bin/bash
# PostToolUse hook (Write|Edit): size review for learning-path.md, the one state
# file that still grows by hand.
#
# It used to also check row INTEGRITY in _understanding-log.md — that a row pointed
# at a note actually holding the concept. That check is gone because the failure is
# gone: review state now lives in each note's own frontmatter and the queue is
# GENERATED into INDEX.md, so there is no second copy that can drift. The class of
# bug was designed out rather than detected.
#
# Nothing here blocks a write. It makes growth visible at the moment it happens,
# while the context to fix it is still in the session.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
VAULT="$ROOT/notes"

# shellcheck source=thresholds.sh
. "$(dirname "$0")/thresholds.sh"

FILE=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[ "$FILE" = "$VAULT/learning-path.md" ] || exit 0

OUT=$(over_threshold "$FILE")
[ -z "$OUT" ] && exit 0

cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"📏 Over review threshold in learning-path.md — review now, do not defer:\n$(printf '%s' "$OUT" | python3 -c 'import sys,json;print(json.dumps(sys.stdin.read())[1:-1])')\nTry in order: GROUP related lines · SHRINK anything repeating a note summary or another section · ARCHIVE finished material (append, dated) · or KEEP it and say why. Never drop a deliverable to hit a number."}}
EOF
exit 0
