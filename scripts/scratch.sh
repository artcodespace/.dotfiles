#!/usr/bin/env bash
set -euo pipefail

active_window=""
active_pane=""
line=0

# first: window(*)
# - second: window-name
# - third?: horizontal | vertical
# first: pane(*)
# - second?: command
while read -r first second third; do
  line=$((line + 1))
  # Ignore comments and empty lines
  [[ -z "$first" || "$first" == "#"* ]] && continue

  if [[ "$first" == "window"* ]]; then
    # Validate the required input
    [[ -n "$second" ]] || { echo "Usage: window <window-name>, line $line"; exit 1; }
    echo "window >>> $first $second $third"
  elif [[ "$first" == "pane"* ]]; then
    echo "pane >>> $first $second $third"
  else
    echo "can not parse"
  fi
done < "$PWD"/test.tmux
