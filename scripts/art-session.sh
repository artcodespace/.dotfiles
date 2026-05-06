#!/usr/bin/env bash
set -euo pipefail

ext=".tmux"
config="${1:-}"

# Exit with `Usage` if no config argument passed, if incorrect extension
# Exit with error if file not found.
[[ -n "$config" ]] || { echo "Usage: $(basename "$0") <layout-file>"; exit 1;}
[[ "$config" == *"$ext" ]] || { echo "Usage: config file must use .tmux extension"; exit 1;}
[[ -f "$config" ]] || { echo "Error: unable to find file $config"; exit 1;}

# Session name is (optional) second arg, defaulting to config with extension stripped.
session=${2:-$(basename "$config" "$ext" | tr . -)}

if tmux has-session -t "$session" 2>/dev/null; then
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
  exit 0
else
  tmux new-session -s "$session" -d
fi

# Check the validity of the config
line=0
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
done < "$PWD"/"$config"

active_window_name=""     # update when parsing, set after parsing
active_pane_num=""        # update when parsing, set on _previous_ window before creating a new one
current_orientation="-v"  # update when creating a window
is_first_window=true      # update once, after first window is set
current_window_name=""    # update after creating
is_first_pane=true        # to allow us to use the first pane
current_pane_num=1        # tracked to let us activate the correct pane, depends on tmux config settings

# PARSE VALID CONFIG
while read -r first second third; do
  # Ignore comments and empty lines
  [[ -z "$first" || "$first" == "#"* ]] && continue

  if [[ "$first" == "window"* ]]; then
    window_name=$second
    window_orientation=$third

    # Reinitialise variables
    is_first_pane=true

    # Maybe update active window
    [[ "$first" == *"*" ]] && active_window_name=$window_name

    # Maybe update current_orientation
    if [[ "$window_orientation" == "horizontal" ]]; then
      current_orientation="-v"
    else
      current_orientation="-h"
    fi

    # Maybe add a window
    if [[ "$is_first_window" == true ]]; then
      tmux rename-window -t "$session" "$window_name"
      is_first_window=false
    else
      # Maybe flush the active pane to set it on the previous window
      [[ -n "$active_pane_num" ]] && tmux select-pane -t "$session":"$current_window_name"."$active_pane_num"
      tmux new-window -t "$session" -n "$window_name" -c "$PWD"
    fi

    #  Update variables
    active_pane_num=""
    current_window_name="$window_name"
    current_pane_num=1
  elif [[ "$first" == "pane"* ]]; then
    pane_command=${second:-}
    # Update active pane if required
    [[ "$first" == *"*" ]] && active_pane_num=$current_pane_num

    # Maybe add a pane
    if [[ "$is_first_pane" == true ]]; then
      [[ -n "$pane_command" ]] && tmux send-keys -t "$session":"$current_window_name":"$current_pane_num" "$pane_command" C-m
      is_first_pane=false
    else
      if [[ -n "$pane_command" ]]; then
        tmux split-window "$current_orientation" -t "$session":"$current_window_name" -d "$pane_command"
      else
        tmux split-window "$current_orientation" -t "$session":"$current_window_name"
      fi
    fi

    current_pane_num=$((current_pane_num + 1))
  fi
done < "$PWD"/"$config"

# Maybe flush active pane for last window
[[ -n "$active_pane_num" ]] && tmux select-pane -t "$session":"$current_window_name"."$active_pane_num"

# Maybe flush active window
[[ -n "$active_window_name" ]] && tmux select-window -t "$session":"$active_window_name"
