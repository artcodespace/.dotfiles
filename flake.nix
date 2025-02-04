{
  description = "home manager dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    conform-nvim = {
      url = "github:stevearc/conform.nvim?ref=363243c03102a531a8203311d4f2ae704c620d9b";
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
      url = "github:kylechui/nvim-surround?ref=ae298105122c87bbe0a36b1ad20b06d417c0433e";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter?ref=4d94c24d6cb9985347bdf0692c1fd81088c6c8b2";
      flake = false;
    };
    pax = {
      url = "github:artcodespace/pax?ref=c587d74a02da26a2f9e04f8ac9426ac4c4a004bb";
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
    home-manager,
    ...
  } @ inputs :
  let
    # get plugins as an attribute set
    pinnedPlugins = {inherit(inputs) conform-nvim fzf-lua nvim-lspconfig nvim-surround nvim-treesitter pax vim-tmux-navigator;};

    # helper function for the overlay
    overlay = final: prev:
      {
        nvimPlugins = builtins.mapAttrs (name: value:
	  prev.pkgs.vimUtils.buildVimPlugin {
	    pname = name;
	    version = value.lastModifiedDate;
	    src = value;
	  }) pinnedPlugins;
      };

    darwinPackages = import nixpkgs {
      system = "aarch64-darwin";
      overlays = [ overlay ];
      config = { };
    };

    linuxPackages = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ overlay ];
      config = { };
    };
  in
  {
    overlays.default = overlay;
    homeConfigurations = {
      "art@maria" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPackages;
        modules = [./home.nix];
        extraSpecialArgs = {inputs = inputs;};
      };
      "art@angharad" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPackages;
        modules = [./home.nix];
        extraSpecialArgs = {inputs = inputs;};
      };
    };
  };
}
