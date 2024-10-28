{
  config,
  pkgs,
  inputs,
  ...
}: {
  # HOME
  home = {
    username = "art";
    homeDirectory = "/Users/art";
    # Do not change this value, even if you update Home Manager.
    stateVersion = "24.05";
    packages = [
      pkgs.nodejs_22
      pkgs.nodePackages.nodemon
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # How to put a file into <user>/.config/
  xdg.configFile = {
    "wezterm/wezterm.lua" = config.lib.file.mkOutOfStoreSymlink ./wezterm/.config/wezterm/wezterm.lua;
    "nvim/colors/pax.lua".text = "require('pax').load()";
  };

  # PROGRAMS
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # See "Conjoined Rectangles of Success"
  # Git
  programs.git = {
    enable = true;
    userName = "art";
    userEmail = "56027671+artcodespace@users.noreply.github.com";
  };

  # Terminal
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # Shell - may be worth going over to bash for better `nix develop` experience
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    envExtra = ''
      eval "$(starship init zsh)"
    '';
  };

  # Multiplexer
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    sensibleOnTop = false;
    terminal = "tmux-256color";
    extraConfig = builtins.readFile ./config/tmux/tmux.conf;
  };

  # Prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      format = "[󰇥](yellow) $directory$git_branch$git_status\n$character";
    };
  };

  # Editor
  programs.neovim = let
    # Helpers to let us load lua config in via the plugin sets
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    plugins = [
      {
        plugin = pkgs.vimPlugins.conform-nvim;
        config = toLuaFile ./config/nvim/plugins/conform.lua;
      }
      {
        plugin = pkgs.vimPlugins.fzf-lua;
        config = toLuaFile ./config/nvim/plugins/fzf-lua.lua;
      }
      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        config = toLuaFile ./config/nvim/plugins/nvim-lspconfig.lua;
      }
      {
        plugin = pkgs.vimPlugins.nvim-surround;
        config = toLua "require('nvim-surround').setup()";
      }
      {
        plugin = pkgs.vimPlugins.vim-tmux-navigator;
        config = toLua "vim.g.tmux_navigator_no_wrap = 1";
      }
      {
        plugin = pkgs.vimPlugins.nvim-treesitter;
        config = toLuaFile ./config/nvim/plugins/nvim-treesitter.lua;
      }
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.tree-sitter-bash
        p.tree-sitter-comment
        p.tree-sitter-css
        p.tree-sitter-javascript
        p.tree-sitter-json
        p.tree-sitter-lua
        p.tree-sitter-nix
        p.tree-sitter-tsx
        p.tree-sitter-typescript
        p.tree-sitter-vim
        p.tree-sitter-vimdoc
      ]))
    ];
    extraPackages = [
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.eslint
      pkgs.prettierd
      pkgs.nixd
      pkgs.alejandra
      pkgs.vscode-langservers-extracted
    ];
    extraLuaConfig = builtins.readFile ./config/nvim/init.lua;
  };

  # COMMAND LINE TOOLS
  programs.lazygit = {
    enable = true;
    settings = {
      gui.border = "double";
      gui.theme.selectedLineBgColor = ["reverse"];
    };
  };
  programs.yazi = {
    enable = true;
    # TODO >>> get to grips with this new tool and configure
  };
  programs.ripgrep = {
    enable = true;
  };
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    fileWidgetCommand = "fd --type f";
  };
  programs.fd = {
    enable = true;
  };
}
