{
  description = "For use with nix profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let
    # Define some variables to make handling platform specifics easier.
    linux = {
      displayName = "linux";
      architecture = "x86_64-linux";
    };
    mac = {
      displayName = "mac";
      architecture = "aarch64-darwin";
    };

    # Helper function. Call it with one of the above objects.
    # It will call the system specific`buildEnv` function with a name
    # reflecting the profile being built and system specific packages.
    buildPackage = {
      displayName,
      architecture,
    } @ platform: let
      pkgs = inputs.nixpkgs.legacyPackages.${architecture};
      unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${architecture};
    in {
      default = pkgs.buildEnv {
        name = "dotfile-nix-profile-" + displayName;
        paths = with pkgs;
          [
            # COMMON
            stow
            wezterm
            tmux
            starship
            # EXPERIMENTAL - escape neovim to use unstable branch for 0.11
            (unstablePkgs.neovim)
            fzf
            lazygit
            ripgrep
            fd
            yazi
            jq
            nodejs_22
            typescript
            nodePackages.nodemon
            vscode-langservers-extracted
            nodePackages.typescript-language-server
            nodePackages.eslint
            prettierd
            lua-language-server
            stylua
            nixd
            alejandra
          ]
          ++ (
            # NOTE there is pkgs.stdenv.isDarwin
            if platform == mac
            then
              # MAC SPECIFIC
              [aerospace]
            else []
          )
          ++ (
            # NOTE there is pkgs.stdenv.isLinux
            if platform == linux
            then
              # LINUX SPECIFIC
              []
            else []
          );
      };
    };
  in {
    packages = {
      ${linux.architecture} = buildPackage linux;
      ${mac.architecture} = buildPackage mac;
    };
  };
}
