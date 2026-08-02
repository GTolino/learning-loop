#!/bin/bash
# Section review thresholds for learning-path.md — the ONE place these numbers live.
# Sourced by state-file-review.sh (nags the session that WRITES the file) and by
# learning-dashboard.sh (nags the session that READS it and pays the context cost).
#
# These are REVIEW PROMPTS, never hard limits. Nothing here truncates and nothing
# blocks a write. Crossing a threshold means: ask the advisor what to group, what to
# shrink, what to archive — and what to keep on purpose. A section may legitimately
# sit over budget; silence about that was the old bug.
#
# The spec table lives in .claude/agents/advisor.md — keep the two in sync.

STATE_OF_PLAY_WORDS=2000

# over_threshold <path to learning-path.md> -> one line per section over budget
over_threshold() {
  awk '
    BEGIN{
      cap["## Goals"]=30; cap["## Coverage map"]=180
      cap["## Required for future goals"]=60; cap["## Recommended next"]=40
      cap["## Learning hooks"]=150; cap["## Courses"]=30
      cap["## Goal drift"]=20
    }
    # Headings are matched by PREFIX, so decorated variants
    # ("## Coverage map — by goal") still resolve to their cap.
    /^## /{ if(sec!="") lines[sec]=n; sec=$0; n=0; next }
    { n++ }
    END{
      if(sec!="") lines[sec]=n
      for(s in lines) for(c in cap)
        if(index(s,c)==1 && lines[s]>cap[c])
          printf "  %s — %d lines (threshold %d)\n", c, lines[s], cap[c]
    }' "$1"

  w=$(awk '/^## State of play/{f=1;next} /^## /{f=0} f' "$1" | wc -w | tr -d ' ')
  if [ "${w:-0}" -gt "$STATE_OF_PLAY_WORDS" ]; then
    printf "  ## State of play — %d words (budget %d) — fold harder before archiving.\n" \
      "$w" "$STATE_OF_PLAY_WORDS"
  fi
  return 0
}
