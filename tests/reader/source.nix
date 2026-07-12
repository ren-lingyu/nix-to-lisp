{ lib } : let
  
  sexp = lib.sexp;
  elisp = lib.elisp;

in (elisp.renderForms [
  
  (sexp.form "quote" [
    (sexp.symbol "foo")
  ])

  (sexp.form "function" [
    (sexp.symbol "foo")
  ])

  (sexp.form "backquote" [
    [
      (sexp.symbol "a")
      (elisp.unquote (sexp.symbol "x"))
      (elisp.unquoteSplicing (sexp.symbol "xs"))
    ]
  ])

  (sexp.form "list" [
    (sexp.symbol "foo\\bar")
    (sexp.symbol "foo bar")
    (sexp.symbol "123")
    (sexp.symbol "1e2")
    (sexp.symbol ".")
    (sexp.symbol ".foo")
    (sexp.symbol "+foo")
    (sexp.symbol "-foo")
    (sexp.symbol "?a")
    (sexp.symbol "foo?")
    (sexp.symbol "λ")
    (sexp.symbol "测试")
    (sexp.symbol ",")
    (sexp.symbol ",@")
    (sexp.symbol "`")
    "a\"b"
    "a\\nb"
    ''
      a
      b
    ''
  ])

  (sexp.form "vector" [
    (elisp.vector [
      1
      (sexp.symbol "foo")
      "bar"
    ])
  ])

  (sexp.form "list" [
    1.0
    1.5
  ])
  
])
