#!/bin/sh
set -eu
git branch --list --format='%(refname:short)' | fzf --layout=reverse
