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
        git
        vim
        stow
      ];
    };
  };
}
