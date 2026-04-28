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
nix profile add ~/.dotfiles
```

3. Stow the config folders:

```bash
cd ~/.dotfiles && stow nvim tmux wezterm ghostty nix direnv [zsh | bash]
```

Note that the shellrc files are designed to read local system spec from a sibling `.shellrc.local` file for local configuration mutations (to handle things like nvm, brew etc.).

They also assume secrets are kept in `~/.secrets` in the form `export SECRET=VALUE`.

# TODO

- Aerospace:
  - setup for general work/admin split
- Nix:
  - look at dir env integration for dev shell investigation work
- Tmux:
  - figure out worktree workflow
