{ lib } : let
  
  sexp = lib.sexp;
  elisp = lib.elisp;

in (elisp.renderForms [
  
  (sexp.form "add-to-list" [
    (elisp.quote (sexp.symbol "load-path"))
    ./lisp
  ])

  (sexp.form "require" [
    (elisp.quote (sexp.symbol "context-feature"))
  ])
  
])
