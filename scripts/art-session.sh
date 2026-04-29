#!/usr/bin/env bash
set -euo pipefail

ext=".tmux"

# Look in pwd or home for <name>.tmux files.
for file in "$PWD"/*"$ext" "$HOME"/*"$ext"; do
  test -f "$file" && config=$file && break
done

# Exit if we can't find any valid file.
[[ -f "${config:-}" ]] || { echo "No $ext files found"; exit 1; }

# Session name first arg or the config file name with extension stripped.
session=${1:-$(basename "$config" "$ext")}

if tmux has-session -t "$session" 2>/dev/null; then
  echo "$session already exists"
  tmux attach -t "$session"
  exit 0
fi


echo "$session"
echo "$config"
