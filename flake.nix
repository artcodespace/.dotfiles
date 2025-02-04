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
      url = "github:ibhagwan/fzf-lua?ref=394ddb2b80c58731c09b5775ca5d05d578b1de3d";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig?ref=66bc018936c6ff76beb75f89d986af6442db4001";
      flake = false;
    };
    nvim-surround = {
      url = "github:kylechui/nvim-surround?ref=ae298105122c87bbe0a36b1ad20b06d417c0433e";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter?ref=53a6b3993f5803378d4d031bf114c0b125a52ba8";
      flake = false;
    };
    pax = {
      url = "github:artcodespace/pax?ref=c587d74a02da26a2f9e04f8ac9426ac4c4a004bb";
      flake = false;
    };
    vim-tmux-navigator = {
      url = "github:christoomey/vim-tmux-navigator?ref=d847ea942a5bb4d4fab6efebc9f30d787fd96e65";
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
