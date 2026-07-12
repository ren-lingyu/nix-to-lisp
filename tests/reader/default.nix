{ pkgs, lib } : let

  source_ = import ./source.nix {
    inherit lib;
  };

  assertions_ = builtins.readFile ./lisp/assertions.el;

in (
  pkgs.runCommand "nix-to-lisp-reader" {
    nativeBuildInputs = [
      pkgs.emacs-nox
    ];
  } (builtins.concatStringsSep "\n" [
    "cat > generated.el <<'EOF'"
    "${source_}"
    "EOF"
    "${pkgs.lib.getExe' pkgs.emacs-nox "emacs"} --batch -Q --eval '${builtins.concatStringsSep "\n" [
      "(with-temp-buffer"
      "  (insert-file-contents \"generated.el\")"
      "  (goto-char (point-min))"
      "  (condition-case nil"
      "      (while t"
      "        (read (current-buffer)))"
      "    (end-of-file nil)))"
    ]}'"
    "cat > assertions.el <<'EOF'"
    "${assertions_}"
    "EOF"
    "${pkgs.lib.getExe' pkgs.emacs-nox "emacs"} --batch -Q --load assertions.el"
    "touch \"$out\""
  ])
)
