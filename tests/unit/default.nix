{ pkgs, lib } : (
  pkgs.runCommand "nix-to-lisp-unit" {} (builtins.concatStringsSep "\n" [
    "test \"${import ./assertions.nix { inherit pkgs lib; }}\" = ok"
    "touch \"$out\""
  ])
)
