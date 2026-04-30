#!/usr/bin/env bash
set -euo pipefail

# first: window(*)
# - second: window-name
# - third?: horizontal | vertical
# first: pane(*)
# - second?: command
while read -r first second third; do
  echo "$second $first $third"
done < "$PWD"/test.tmux
