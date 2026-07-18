{ lib } : let

  sexp = lib.sexp;
  elisp = lib.elisp;

in (elisp.renderForms [

  (sexp.form "eval-and-compile" [
    (sexp.form "add-to-list" [
      (elisp.quote (sexp.symbol "load-path"))
      "/nix/store/example-source/lisp/module-a"
    ])
    (sexp.form "add-to-list" [
      (elisp.quote (sexp.symbol "load-path"))
      "/nix/store/example-source/lisp/module-b"
    ])
  ])

  (sexp.form "require" [
    (elisp.quote (sexp.symbol "example-module"))
  ])

  (sexp.form "advice-add" [
    (elisp.quote (sexp.symbol "startup--load-user-init-file"))
    (sexp.symbol ":around")
    (sexp.form "example/load-user-init-file" [
      "/nix/store/example-source/early-init.el"
      (elisp.quote (sexp.symbol "example-shared"))
    ])
  ])

  (sexp.form "let" [
    [
      [
        (sexp.symbol "min-version")
        "31.0"
      ]
    ]
    (sexp.form "when" [
      (sexp.form "version<" [
        (sexp.symbol "emacs-version")
        (sexp.symbol "min-version")
      ])
      (sexp.form "display-warning" [
        (elisp.quote (sexp.symbol "example"))
        (sexp.form "format" [
          "This configuration expects Emacs %s or newer; current Emacs is %s."
          (sexp.symbol "min-version")
          (sexp.symbol "emacs-version")
        ])
        (sexp.symbol ":warning")
      ])
    ])
  ])

  (sexp.form "setq" [
    (sexp.symbol "default-frame-alist")
    (elisp.quote [
      (sexp.cons (sexp.symbol "background-color") "gray10")
      (sexp.cons (sexp.symbol "foreground-color") "gray90")
      (sexp.cons (sexp.symbol "fullscreen") (sexp.symbol "maximized"))
      (sexp.cons (sexp.symbol "vertical-scroll-bars") null)
      (sexp.cons (sexp.symbol "menu-bar-lines") 0)
      (sexp.cons (sexp.symbol "tool-bar-lines") 0)
    ])
  ])

  (sexp.form "use-package" [
    (sexp.symbol "example-package")
    (sexp.symbol ":demand")
    true
    (sexp.symbol ":straight")
    (elisp.backquote [
      (sexp.symbol "example-package")
      (sexp.symbol ":fork")
      [
        (sexp.symbol ":host")
        null
        (sexp.symbol ":repo")
        "https://example.invalid/example-package.git"
        (sexp.symbol ":branch")
        "main"
        (sexp.symbol ":remote")
        "upstream"
      ]
      (sexp.symbol ":files")
      [
        (sexp.symbol ":defaults")
        "etc"
      ]
      (sexp.symbol ":build")
      true
      (sexp.symbol ":pre-build")
      (sexp.form "with-temp-file" [
        "example-version.el"
        (sexp.form "require" [
          (elisp.quote (sexp.symbol "lisp-mnt"))
        ])
        (sexp.form "let" [
          [
            [
              (sexp.symbol "version")
              (sexp.form "with-temp-buffer" [
                (sexp.form "insert-file-contents" [
                  "lisp/example.el"
                ])
                (sexp.form "lm-header" [
                  "version"
                ])
              ])
            ]
            [
              (sexp.symbol "git-version")
              (sexp.form "string-trim" [
                (sexp.form "with-temp-buffer" [
                  (sexp.form "call-process" [
                    "git"
                    null
                    true
                    null
                    "rev-parse"
                    "--short"
                    "HEAD"
                  ])
                  (sexp.form "buffer-string" [])
                ])
              ])
            ]
          ]
          (sexp.form "insert" [
            (sexp.form "format" [
              "(defun example-release () \"The release version.\" %S)\n"
              (sexp.symbol "version")
            ])
            (sexp.form "format" [
              "(defun example-git-version () \"The git commit hash.\" %S)\n"
              (sexp.symbol "git-version")
            ])
            "(provide 'example-version)\n"
          ])
        ])
      ])
      (sexp.symbol ":pin")
      null
    ])
    (sexp.symbol ":init")
    (sexp.form "setq" [
      (sexp.symbol "example-directory")
      (sexp.form "expand-file-name" [
        "~/example/"
      ])
    ])
    (sexp.symbol ":config")
    (sexp.form "setq" [
      (sexp.symbol "example-export-processors")
      (elisp.quote [
        [
          (sexp.symbol "latex")
          (sexp.symbol "bibtex")
        ]
        [
          (sexp.symbol "html")
          (sexp.symbol "csl")
        ]
        [
          true
          (sexp.symbol "basic")
        ]
      ])
    ])
  ])

  (sexp.form "use-package" [
    (sexp.symbol "snippet-package")
    (sexp.symbol ":straight")
    [
      (sexp.symbol ":host")
      (sexp.symbol "github")
      (sexp.symbol ":repo")
      "example/snippet-package"
    ]
    (sexp.symbol ":hook")
    (sexp.cons (sexp.symbol "text-mode") (sexp.symbol "snippet-package-mode"))
    (sexp.symbol ":config")
    (sexp.form "define-snippets" [
      (elisp.quote (sexp.symbol "text-mode"))
      ";eq"
      (sexp.form "lambda" [
        []
        (sexp.form "interactive" [])
        (sexp.form "insert" [
          "\\(  \\)"
        ])
        (sexp.form "forward-char" [
          (- 3)
        ])
      ])
      ";block"
      (sexp.form "lambda" [
        []
        (sexp.form "interactive" [])
        (sexp.form "insert" [
          "\\begin{example}\n\n\\end{example}\n"
        ])
        (sexp.form "forward-line" [
          (- 2)
        ])
      ])
    ])
  ])

  (sexp.form "defun" [
    (sexp.symbol "example/load-current-theme")
    []
    "Load the current theme."
    (sexp.form "mapc" [
      (elisp.function (sexp.symbol "disable-theme"))
      (sexp.symbol "custom-enabled-themes")
    ])
    (sexp.form "let*" [
      [
        [
          (sexp.symbol "group")
          (sexp.form "nth" [
            (sexp.symbol "example/group-index")
            (sexp.symbol "example/theme-groups")
          ])
        ]
        [
          (sexp.symbol "group-name")
          (sexp.form "car" [
            (sexp.symbol "group")
          ])
        ]
        [
          (sexp.symbol "theme")
          (sexp.form "nth" [
            (sexp.form "1+" [
              (sexp.symbol "example/theme-index")
            ])
            (sexp.symbol "group")
          ])
        ]
      ]
      (sexp.form "cond" [
        [
          (sexp.form "eq" [
            (sexp.symbol "group-name")
            (elisp.quote (sexp.symbol "light"))
          ])
          (sexp.form "setq" [
            (sexp.symbol "example/current-flavor")
            (sexp.symbol "theme")
          ])
          (sexp.form "load-theme" [
            (elisp.quote (sexp.symbol "example-light"))
            true
          ])
          (sexp.form "message" [
            "Loaded light flavor: %s"
            (sexp.symbol "theme")
          ])
        ]
        [
          true
          (sexp.form "load-theme" [
            (sexp.symbol "theme")
            true
          ])
          (sexp.form "message" [
            "Loaded theme: %s"
            (sexp.symbol "theme")
          ])
        ]
      ])
    ])
  ])

  (sexp.form "global-set-key" [
    (sexp.form "kbd" [
      "<f4>"
    ])
    (elisp.function (sexp.symbol "example/toggle-theme-group"))
  ])

  (sexp.form "defun" [
    (sexp.symbol "example/update-date")
    [
      (sexp.symbol "path")
      (sexp.symbol "time-string")
      (sexp.symbol "insert-p")
    ]
    "Update a date keyword for files under PATH."
    (sexp.form "when" [
      (sexp.form "and" [
        (sexp.form "eq" [
          (sexp.symbol "major-mode")
          (elisp.quote (sexp.symbol "text-mode"))
        ])
        (sexp.form "buffer-file-name" [])
        (sexp.form "file-directory-p" [
          (sexp.symbol "path")
        ])
        (sexp.form "file-in-directory-p" [
          (sexp.form "buffer-file-name" [])
          (sexp.symbol "path")
        ])
        (sexp.form "stringp" [
          (sexp.symbol "time-string")
        ])
        (sexp.form "booleanp" [
          (sexp.symbol "insert-p")
        ])
      ])
      (sexp.form "save-excursion" [
        (sexp.form "goto-char" [
          (sexp.form "point-min" [])
        ])
        (sexp.form "let*" [
          [
            [
              (sexp.symbol "now")
              (sexp.form "format-time-string" [
                (sexp.symbol "time-string")
              ])
            ]
          ]
          (sexp.form "if" [
            (sexp.form "re-search-forward" [
              "^#\\+DATE:"
              null
              true
            ])
            (sexp.form "progn" [
              (sexp.form "delete-region" [
                (sexp.form "point" [])
                (sexp.form "line-end-position" [])
              ])
              (sexp.form "insert" [
                " "
                (sexp.symbol "now")
              ])
            ])
            (sexp.form "when" [
              (sexp.symbol "insert-p")
              (sexp.form "insert" [
                "#+DATE: "
                (sexp.symbol "now")
                "\n"
              ])
            ])
          ])
        ])
      ])
    ])
  ])

])
