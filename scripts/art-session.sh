#!/usr/bin/env bash
set -euo pipefail

# Look in pwd or home for <name>.tmux files.
for FILE in "$PWD"/*.tmux "$HOME"/*.tmux; do
  test -f "$FILE" && LAYOUT=$FILE && break
done

if [[ ! -f "$LAYOUT" ]]; then
  echo "unable to find any files"
  exit 1
fi

echo "$LAYOUT"
