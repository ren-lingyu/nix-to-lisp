{ lib } : let
  
  sexp = lib.sexp;
  elisp = lib.elisp;

in

assert elisp.render null == "nil";
assert elisp.render false == "nil";
assert elisp.render true == "t";
assert elisp.render 1 == "1";
assert elisp.render 1.25 == "1.250000";
assert elisp.render 1.0 == "1.000000";
assert elisp.render 1.5 == "1.500000";

assert elisp.render "foo" == "\"foo\"";
assert elisp.render "a\"b" == "\"a\\\"b\"";
assert elisp.render "a\\nb" == "\"a\\\\nb\"";
assert elisp.render (builtins.concatStringsSep "\n" [
  "a"
  "b"
  ""
]) == "\"a\\nb\\n\"";
assert elisp.render ./assertions.nix == "\"${builtins.toString ./assertions.nix}\"";

assert elisp.render (sexp.symbol "foo") == "foo";
assert elisp.render (sexp.symbol "org-mode") == "org-mode";
assert elisp.render (sexp.symbol ":foo") == ":foo";
assert elisp.render (sexp.symbol "foo bar") == "foo\\ bar";
assert elisp.render (sexp.symbol ",") == "\\,";
assert elisp.render (sexp.symbol ",@") == "\\,@";
assert elisp.render (sexp.symbol "`") == "\\`";
assert elisp.render (sexp.symbol "123") == "\\123";
assert elisp.render (sexp.symbol "1e2") == "\\1e2";
assert elisp.render (sexp.symbol ".") == "\\.";
assert elisp.render (sexp.symbol ".foo") == "\\.foo";
assert elisp.render (sexp.symbol "+foo") == "\\+foo";
assert elisp.render (sexp.symbol "-foo") == "\\-foo";
assert elisp.render (sexp.symbol "?a") == "\\?a";
assert elisp.render (sexp.symbol "foo?") == "foo?";
assert elisp.render (sexp.symbol "λ") == "λ";
assert elisp.render (sexp.symbol "测试") == "测试";
assert elisp.render (sexp.symbol "a\\b") == "a\\\\b";

assert elisp.render [
  (sexp.symbol "message")
  "hello"
] == "(message \"hello\")";

assert elisp.render (sexp.cons
  (sexp.symbol "foo")
  1
) == "(foo . 1)";

assert elisp.render (elisp.vector [
  1
  (sexp.symbol "foo")
]) == "[1 foo]";

assert elisp.render (elisp.raw "(already-elisp)") == "(already-elisp)";

assert elisp.render (sexp.form "message" [
  "hello"
]) == "(message \"hello\")";

assert elisp.render (elisp.quote (sexp.symbol "foo")) == "(quote foo)";
assert elisp.render (elisp.function (sexp.symbol "foo")) == "(function foo)";
assert elisp.render (elisp.backquote [
  (sexp.symbol "a")
  (elisp.unquote (sexp.symbol "x"))
  (elisp.unquoteSplicing (sexp.symbol "xs"))
]) == "(backquote (a (\\, x) (\\,@ xs)))";

assert elisp.render (elisp.plist [
  {
    key = "foo";
    value = 1;
  }
  {
    key = "bar";
    value = true;
  }
]) == "(:foo 1 :bar t)";

assert elisp.render (elisp.plistFromAttrs {
  foo = 1;
  bar = true;
}) == "(:bar t :foo 1)";

assert elisp.render (elisp.alist [
  {
    key = sexp.symbol "foo";
    value = 1;
  }
  {
    key = sexp.symbol "bar";
    value = "baz";
  }
]) == "((foo . 1) (bar . \"baz\"))";

assert elisp.render (elisp.alistFromAttrs {
  foo = 1;
  bar = true;
}) == "((bar . t) (foo . 1))";

assert elisp.renderForms [
  (sexp.form "setq" [
    (sexp.symbol "foo")
    1
  ])
  (sexp.form "message" [
    "done"
  ])
] == "(setq foo 1)\n\n(message \"done\")";

assert (!(builtins.tryEval (elisp.render {})).success);
assert (!(builtins.tryEval (elisp.render (sexp.symbol ""))).success);
assert (!(builtins.tryEval (elisp.plist [
  {
    key = sexp.symbol "foo";
    value = 1;
  }
])).success);
assert (!(builtins.tryEval (elisp.render {
  __sexpType = "symbol";
})).success);
assert (!(builtins.tryEval (elisp.render {
  __sexpType = "symbol";
  value = 1;
})).success);
assert (!(builtins.tryEval (elisp.render {
  __sexpType = "cons";
  car = 1;
})).success);
assert (!(builtins.tryEval (elisp.render {
  __sexpType = "cons";
  cdr = 1;
})).success);
assert (!(builtins.tryEval (elisp.render {
  __elispType = "vector";
  values = "not-list";
})).success);
assert (!(builtins.tryEval (elisp.render {
  __elispType = "raw";
  value = 1;
})).success);

"ok"
