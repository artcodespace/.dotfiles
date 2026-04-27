#!/usr/bin/env bash
set -euo pipefail

for SRC in "$HOME/.nix-profile/Applications"/*.app; do
  NAME=$(basename "$SRC")
  DEST="$HOME/Applications/$NAME"

  if [[ -L "$DEST" ]]; then
    echo "already linked: $NAME"
  elif [[ -e "$DEST" ]]; then
    echo "skipping: $NAME exists but is not a symlink"
  else
    ln -s "$SRC" "$DEST"
    echo "linked: $NAME"
  fi
done
