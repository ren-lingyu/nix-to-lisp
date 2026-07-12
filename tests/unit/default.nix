{ pkgs, lib } : (
  pkgs.runCommand "nix-to-lisp-unit" {} (builtins.concatStringsSep "\n" [
    "test \"${import ./assertions.nix { inherit lib; }}\" = ok"
    "touch \"$out\""
  ])
)
