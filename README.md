# Cross platform dotfiles for use with GNU stow

This repo is designed to be used anywhere by:

- cloning the repo
- manually installing any required dependencies
- symlinking (stowing) the dotfiles to the correct location

This repo _may_ also be used in the nix configurations that are being worked on for [darwin](https://github.com/alunturner/nix-darwin-config) and [home-manager](https://github.com/alunturner/home-manager).

The idea behind this is that I can maintain a single source of truth for the dotfiles (here) that can be used by other people who aren't on nix, or by me in situations where nix isn't an option. In all honesty I also think this might simplify neovim dependency management too, which I feel is quite fragile and I just want to always be pinned (handled using git submodules).

# Tooling configuration steps

1. Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install Brew packages (node, ripgrep, fzf, fd, jq, stow, neovim, lua formatter and lang server, tmux, starship)

```bash
brew install node ripgrep fzf fd jq stow neovim stylua lua-language-server tmux starship
```

3. Install Wezterm

```bash
brew install --cask wezterm
```

4. Install npm packages (TypeScript stuff, ESLint, language servers, daemons)

```bash
npm i -g typescript typescript-language-server eslint vscode-langservers-extracted nodemon @fsouza/prettierd
```

5. Clone .dotfiles at the top level `~/.dotfiles`, recursive because we use submodules

```bash
cd && git clone --recurse-submodules https://github.com/artcodespace/.dotfiles.git
```

6. Stow the config folders:

```bash
cd ~/.dotfiles && stow nvim tmux lazygit wezterm starship
```

7. If not on Wezterm, set terminal colours to Catpuccin Mocha/Latte and override fg color #e9e7dd / #19191f

# TODO

- Pax: make a light theme, accept a highlight count, look at ts highlight groups
- Add a Brewfile for all of the above
