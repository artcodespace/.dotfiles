# Cross platform dotfiles for use with GNU stow

This repo is designed to be used anywhere by:

- cloning the repo
- using the flake to install dependencies with nix
- symlinking (stowing) the dotfiles to the correct location

# Tooling configuration steps

1. Clone .dotfiles at the top level `~/.dotfiles`, recursive because we use submodules

```bash
cd && git clone --recurse-submodules https://github.com/artcodespace/.dotfiles.git
```

2. Install dependencies using nix:

```bash
nix profile install ~/.dotfiles
```

3. Stow the config folders:

```bash
cd ~/.dotfiles && stow nvim tmux wezterm starship direnv zsh
```

Note that `.zshrc` will attempt to read from `.zshrc.local`. Use the local file to store system specific shell stuff.

# TODO

- Aerospace:
  - setup for general work/admin split
- Nix:
  - look at dir env integration for dev shell investigation work
- Tmux:
  - figure out worktree workflow
