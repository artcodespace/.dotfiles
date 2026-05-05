#!/usr/bin/env bash
set -euo pipefail

active_window=""          # must be set after creating all windows
active_pane=""            # must be set after creating all panes inside a window
line=0                    # used to track current line for error parsing
current_orientation="-v"  # tracked per window for pane creation
is_first_window=true      # to allow us to use the first window
current_window=""         # tracks the current window name for pane creation
is_first_pane=true        # to allow us to use the first pane
current_pane=1            # tracked to let us activate the correct pane, depends on tmux config settings
session="test"            # will be available in scope in real call

# CHECK FOR ERRORS
while read -r first second third; do
  line=$((line + 1))
  # Ignore comments and empty lines
  [[ -z "$first" || "$first" == "#"* ]] && continue

  if [[ "$first" == "window"* ]]; then
    [[ -n "$second" ]] || { echo "Usage: window <window-name>, line $line"; exit 1; }
    [[ -z "$third" || "$third" == "horizontal" || "$third" == "vertical" ]] || { echo "Error: layout must be either horizontal or vertical, line $line"; exit 1; }
  elif [[ "$first" == "pane"* ]]; then
    continue
  else
    echo "Error: invalid input, line $line"
    exit 1
  fi
done < "$PWD"/test.tmux

# PARSE VALID CONFIG
while read -r first second third; do
  # Ignore comments and empty lines
  [[ -z "$first" || "$first" == "#"* ]] && continue

  if [[ "$first" == "window"* ]]; then
    # first: window(*)
    # - second: window-name
    # - third?: horizontal | vertical

    # Maybe update active window
    [[ "$first" == *"*" ]] && active_window=$second

    # Maybe update current_orientation
    if [[ "$third" == "horizontal" ]]; then
      current_orientation="-v"
    else
      current_orientation="-h"
    fi

    # Add a window
    if [[ "$is_first_window" == true ]]; then
      echo "window command >>> tmux rename-window -t $session $second"
      is_first_window=false
    else
      echo "window command >>> tmux new-window -t $session -n $second -c $PWD"
    fi

    # Set current window and reset pane count
    current_window="$second"
    current_pane=1
  elif [[ "$first" == "pane"* ]]; then
    # first: pane(*)
    # - second?: command

    # Update active pane if required
    [[ "$first" == *"*" ]] && active_pane=$current_pane

    # Add a pane
    echo "pane command >>> tmux split-window $current_orientation -t \"$session\":\"$current_window\""

    current_pane=$((current_pane + 1))
  fi
done < "$PWD"/test.tmux
