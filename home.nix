{
  config,
  pkgs,
  inputs,
  conform-nvim,
  fzf-lua,
  nvim-lspconfig,
  nvim-surround,
  nvim-treesitter,
  pax,
  vim-tmux-navigator,
  ...
}: 
{
  # HOME
  home = {
    username = "alunturner";
    homeDirectory = "/Users/alunturner";
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

  # Files that go into user/.config/...
  xdg.configFile = {
    "lazygit/config.yml".source = ./lazygit/.config/lazygit/config.yml;
    nvim = {
      source = ./nvim/.config/nvim;
      recursive = true;
    };
    "starship.toml".source = ./starship/.config/starship.toml;
    "tmux/tmux.conf".source = ./tmux/.config/tmux/tmux.conf;
    "wezterm/wezterm.lua".source = ./wezterm/.config/wezterm/wezterm.lua;
  };

  # PROGRAMS
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "alunturner";
    userEmail = "56027671+artcodespace@users.noreply.github.com";
  };
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
  # Decide on whether zsh or bash is the one
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    envExtra = ''
      eval "$(starship init zsh)"
    '';
  };
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    sensibleOnTop = false;
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # Editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.vscode-langservers-extracted
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.eslint
      pkgs.prettierd
      pkgs.nixd
      pkgs.alejandra
    ];
  };

  # COMMAND LINE TOOLS
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    fileWidgetCommand = "fd --type f";
  };
  programs.lazygit.enable = true;
  programs.yazi.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
}
