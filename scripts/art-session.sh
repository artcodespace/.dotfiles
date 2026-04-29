#!/usr/bin/env bash
set -euo pipefail

ext=".tmux"

# Look in pwd or home for <name>.tmux files.
for file in "$PWD"/*"$ext" "$HOME"/*"$ext"; do
  test -f "$file" && config=$file && break
done

# Exit if we can't find any valid file.
[[ -f "${config:-}" ]] || { echo "No $ext files found"; exit 1; }

# Name is either what user passes or the <name> from the config file.
session=${1:-$(basename "$config" $ext)}
echo "$session"
echo "$config"
