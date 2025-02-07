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

2. Stow the config folders:

```bash
cd ~/.dotfiles && stow nvim tmux lazygit wezterm starship
```

3. Install dependencies using nix:

```bash
nix profiles install ~/.dotfiles
```

# TODO

- Pax: make a light theme, accept a highlight count, look at ts highlight groups

# Notes

- If not on Wezterm, may want to try and find Catpuccin Mocha set terminal colours to Catpuccin Mocha/Latte and override fg color #e9e7dd / #19191f
