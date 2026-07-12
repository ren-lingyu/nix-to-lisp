{ pkgs, lib } : let

  source_ = import ./source.nix {
    inherit lib;
  };

in (
  pkgs.runCommand "nix-to-lisp-context" {
    nativeBuildInputs = [
      pkgs.emacs-nox
    ];
  } (builtins.concatStringsSep "\n" [
    "cat > generated.el <<'EOF'"
    "${source_}"
    "EOF"
    "${pkgs.lib.getExe' pkgs.emacs-nox "emacs"} --batch -Q --load generated.el"
    "touch \"$out\""
  ])
)
