#!/usr/bin/env bash
set -euo pipefail

active_window=""
active_pane=""
line=0
session="test" # will be available in scope in real call

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
    
    # Update active window if required
    [[ "$first" == *"*" ]] && active_window=$second

    # Add a window

    echo "window command >>> tmux new-window -a -t $session -n $second -c $PWD"
  elif [[ "$first" == "pane"* ]]; then
    echo "pane >>> $first $second $third"
  else
    echo "can not parse"
  fi
done < "$PWD"/test.tmux
