#!/usr/bin/env bash
set -euo pipefail

while read -r first second third; do
  echo "$second $first $third"
done < "$PWD"/test.tmux
