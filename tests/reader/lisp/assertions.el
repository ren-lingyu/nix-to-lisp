(defun nix-to-lisp-test-read-one (text)
  (car (read-from-string text)))

(unless (equal (symbol-name (nix-to-lisp-test-read-one "\\1e2")) "1e2")
  (error "symbol 1e2 was not read back correctly"))

(unless (equal (symbol-name (nix-to-lisp-test-read-one "\\?a")) "?a")
  (error "symbol ?a was not read back correctly"))

(unless (equal (symbol-name (nix-to-lisp-test-read-one "\\,")) ",")
  (error "symbol , was not read back correctly"))

(unless (equal (symbol-name (nix-to-lisp-test-read-one "\\,@")) ",@")
  (error "symbol ,@ was not read back correctly"))

(unless (equal (symbol-name (nix-to-lisp-test-read-one "λ")) "λ")
  (error "unicode symbol λ was not read back correctly"))

(unless (equal (symbol-name (nix-to-lisp-test-read-one "测试")) "测试")
  (error "unicode symbol 测试 was not read back correctly"))

(unless (floatp (nix-to-lisp-test-read-one "1.0"))
  (error "1.0 was not read as float"))

(unless (floatp (nix-to-lisp-test-read-one "1.5"))
  (error "1.5 was not read as float"))
