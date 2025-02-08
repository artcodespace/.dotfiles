{
  description = "For use with nix profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = inputs:
  let
    linux = { displayName= "linux"; architecture= "x86_64-linux"; };
    # mac = { displayName= "mac"; architecture= "aarch64-darwin"; };

    buildPackage = { displayName, architecture }: let
      pkgs = inputs.nixpkgs.legacyPackages.${architecture};
    in {
      default = pkgs.buildEnv {
          name = "dotfile-nix-profile-" + displayName;
          paths = with pkgs; [
            stow
            tmux
            wezterm
            starship
            neovim
            fzf
            lazygit
            ripgrep
            fd
            yazi
            jq
            nodejs_22
            nodePackages.nodemon
            vscode-langservers-extracted
            nodePackages.typescript-language-server
            nodePackages.eslint
            prettierd
            lua-language-server
            stylua
            nixd
            alejandra
            aerospace
          ];
      };
    };
  in
  {
    packages = {
      ${linux.architecture} = buildPackage linux;
    };
  };
}
