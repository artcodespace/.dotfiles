#!/usr/bin/env bash
set -euo pipefail

# first: window(*)
# - second: window-name
# - third?: horizontal | vertical
# first: pane(*)
# - second?: command
while read -r first second third; do
  # Ignore comments and empty lines
  [[ -z "$first" || "$first" == "#"* ]] && continue
  echo "$first $second $third"
done < "$PWD"/test.tmux
