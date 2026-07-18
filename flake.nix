{

  description = "A Nix library for generating Lisp S-expressions";

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs?ref=refs/heads/nixos-unstable&shallow=1";
    };
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
    };
  };

  outputs = { self, ... }@inputs : inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    systems = inputs.nixpkgs.lib.systems.flakeExposed;

    flake = {

      lib = import ./lib;

    };

    perSystem = { config, pkgs, ... } : {

      checks = import ./tests {
        inherit pkgs;
        lib = self.lib;
      };

    };

  };

}
