{ pkgs, lib } : let

  source_ = import ./source.nix {
    inherit lib;
  };

in (
  pkgs.runCommand "nix-to-lisp-examples" {
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
    "touch \"$out\""
  ])
)
