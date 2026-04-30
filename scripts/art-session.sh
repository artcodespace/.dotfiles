#!/usr/bin/env bash
set -euo pipefail

tmux_switch_or_attach() {
  local session="$1"
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

ext=".tmux"
config="${1:-}"

# Exit with `Usage` if no config argument passed, if incorrect extension, or error if file not found.
[[ -n "$config" ]] || { echo "Usage: $(basename "$0") <layout-file>"; exit 1;}
[[ "$config" == *"$ext" ]] || { echo "Usage: config file must use .tmux extension"; exit 1;}
[[ -f "$config" ]] || { echo "Error: unable to find file $config"; exit 1;}

# Session name is (optional) second arg, defaulting to config with extension stripped.
session=${2:-$(basename "$config" "$ext" | tr . -)}

if tmux has-session -t "$session" 2>/dev/null; then
  tmux_switch_or_attach "$session"
  exit 0
else
  tmux new-session -s "$session" -d
fi

while read -r thing; do
  echo "$thing"
done < "$config"


echo "$session"
echo "$config"
