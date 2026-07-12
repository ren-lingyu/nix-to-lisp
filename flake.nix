{
  
  description = "A Nix library for generating Lisp S-expressions";
  
  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs?ref=refs/heads/nixos-unstable&shallow=1";
    };
  };
  
  outputs = { self, ... }@inputs : let
    
    forAllSystems = inputs.nixpkgs.lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed;
    
  in {
    
    lib = import ./lib;
    
    checks = forAllSystems (system : import ./tests {
      pkgs = import inputs.nixpkgs { inherit system; };
      lib = self.lib;
    });
    
  };
  
}
