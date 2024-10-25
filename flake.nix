{
  description = "dotfiles for use with nix";

  inputs = {
    conform-nvim = {
      url = "github:stevearc/conform.nvim?ref=1a99fdc1d3aa9ccdf3021e67982a679a8c5c740c";
      flake = false;
    };
    fzf-lua = {
      url = "github:ibhagwan/fzf-lua?ref=f513524561060f2b9e3bd6d36ff046bfa03ca114";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig?ref=eb36e0185ad4b92b0999fb698428f2966334d2c1";
      flake = false;
    };
    nvim-surround = {
      url = "github:kylechui/nvim-surround?ref=ec2dc7671067e0086cdf29c2f5df2dd909d5f71f";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter?ref=4d94c24d6cb9985347bdf0692c1fd81088c6c8b2";
      flake = false;
    };
    pax = {
      url = "github:alunturner/pax?ref=26fcb99d9bd0e27b2b0b9fe6586181258463481f";
      flake = false;
    };
    vim-tmux-navigator = {
      url = "github:christoomey/vim-tmux-navigator?ref=a9b52e7d36114d40350099f254b5f299a35df978";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # https://github.com/LongerHV/neovim-plugins-overlay/blob/master/flake.nix
    # https://github.com/Misterio77/nix-starter-configs/issues/64
    forAllSystems = nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"];
    overlay = final: prev: let
      mkPlugin = name: value:
        prev.pkgs.vimUtils.buildVimPlugin {
          pname = name;
          version = value.lastModifiedDate;
          src = value;
        };
      plugins = prev.lib.filterAttrs (name: _: name != "self" && name != "nixpkgs") inputs;
    in {nvimPlugins = builtins.mapAttrs mkPlugin plugins;};
  in {
    legacyPackages = forAllSystems (
      system:
        import inputs.nixpkgs {
          system = system;
          overlays = [overlay];
        }
    );
    overlays.default = overlay;
  };
}
