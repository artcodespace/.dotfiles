#!/usr/bin/env bash
set -euo pipefail

# Look in pwd or home for <name>.tmux files.
for FILE in "$PWD"/*.tmux "$HOME"/*.tmux; do
  test -f "$FILE" && LAYOUT=$FILE && break
done

# Exit if we can't find anything
[[ ! -f "${LAYOUT:-}" ]] || { echo "No .tmux files found"; exit 1; }

echo "$LAYOUT"
