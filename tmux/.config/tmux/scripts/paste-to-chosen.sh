#!/bin/sh
# Usage: <picker> | paste-to-picked.sh
set -eu
CONTENT=$(cat)
[ -n "$CONTENT" ] || exit 0
tmux set-buffer "$CONTENT"
tmux choose-tree -Z -F '#{session_name}:#{window_index}.#{pane_index}' 'paste-buffer -p -t %%'
