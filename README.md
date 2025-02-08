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
nix profiles install ~/.dotfiles
```

3. Stow the config folders:

```bash
cd ~/.dotfiles && stow nvim tmux lazygit wezterm starship [zsh]
```

# TODO

- Pax: make a light theme, accept a highlight count, look at ts highlight groups
- Nix:
  - look at dir env integration for dev shell investigation work
- Aerospace:
  - look at the default keybinds and compare to sway - want a consistent configuration for tiling window managers

# Notes

- If different font required, use https://www.nerdfonts.com/font-downloads
- If not on Wezterm, may want to try and find Catpuccin Mocha then set terminal colours to Catpuccin Mocha/Latte and override fg color #e9e7dd / #19191f
