#!/usr/bin/env bash
set -euo pipefail

active_window=""
active_pane=""
line=0
current_window=""
current_orientation="-v"
current_pane=1 # depends on the numbering in my config
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
    [[ -z "$third" || "$third" == "horizontal" || "$third" == "vertical" ]] || { echo "Error: layout must be either horizontal or vertical, line $line"; exit 1; }

    # Maybe update active window
    [[ "$first" == *"*" ]] && active_window=$second

    # Maybe update current_orientation
    if [[ "$third" == "horizontal" ]]; then
      current_orientation="-v"
    else
      current_orientation="-h"
    fi

    # Add a window
    echo "window command >>> tmux new-window -a -t $session -n $second -c $PWD"

    # Set current window and reset pane count
    current_window="$second"
    current_pane=1
  elif [[ "$first" == "pane"* ]]; then
    # Update active pane if required
    [[ "$first" == *"*" ]] && active_pane=$current_pane

    # Add a pane
    echo "pane command >>> tmux split-window -t $current_orientation \"$session\":\"$current_window\""

    current_pane=$((current_pane + 1))
  else
    echo "Error: invalid input, line $line"
    exit 1
  fi
done < "$PWD"/test.tmux
