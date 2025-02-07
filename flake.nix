{
  description = "For use with nix profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages."aarch64-darwin";
  in
  {
    packages."aarch64-darwin".default = pkgs.buildEnv {
      name = "dotfile-nix-profile";
      paths = with pkgs; [
        # BASICS
        git
        vim
        stow
        # TERMINAL, PROMPT, EDITOR, CLI TOOLS
        wezterm
        starship
        neovim
        fzf
        lazygit
        ripgrep
        fd
        yazi
        jq
        # JAVASCRIPT
        nodejs_22
        nodePackages.nodemon
        vscode-langservers-extracted
        nodePackages.typescript-language-server
        nodePackages.eslint
        prettierd
        # LUA
        lua-language-server
        stylua
        # NIX
        nixd
        alejandra
      ];
    };
  };
}
