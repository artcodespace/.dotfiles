#!/bin/sh
# Usage: <picker> | paste-to-origin.sh <pane-id>
set -eu
CONTENT=$(cat)
[ -n "$CONTENT" ] || exit 0
tmux set-buffer "$CONTENT"
tmux paste-buffer -p -t "$1"
