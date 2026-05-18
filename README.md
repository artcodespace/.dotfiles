# Cross platform dotfiles for use with GNU stow

This repo is designed to be used anywhere by:

- cloning the repo
- installing the dependencies using:
  - [EITHER nix](https://determinate.systems/nix-installer/)
  - [OR homebrew](https://brew.sh/)
- symlinking (stowing) the dotfiles to the correct location

# Tooling configuration steps

1. Clone .dotfiles at the top level `~/.dotfiles`, recursive because we use submodules

```bash
cd && git clone --recurse-submodules https://github.com/artcodespace/.dotfiles.git
```

2a. Install nix then use that for dependencies:

```bash
nix profile add ~/.dotfiles
```

2b. Install Homebrew then use that for dependencies:

```bash
brew bundle --file=~/.dotfiles/Brewfile
```

3. Stow the config folders:

```bash
cd ~/.dotfiles && stow aerospace tmux ghostty [nix | mise] nvim [zsh | bash]
```

4a. Expose nix applications to spotlight (macOS only):

```bash
art-spotlight-nix-applications
```

4b. Install Mise dependencies if using brew:

```bash
mise install
```

Note that the shellrc files are designed to read local system spec from a sibling `.shellrc.local` file for local configuration mutations (to handle things like nvm, brew etc.).

They also assume secrets are kept in `~/.secrets` in the form `export SECRET=VALUE`.

# TODO

- Tmux:
  - figure out worktree workflow
  - move fzf to f binding for consistency

- General:
  - Align the resizing controls between nvim, tmux, aerospace
