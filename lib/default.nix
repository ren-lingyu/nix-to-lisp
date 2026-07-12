rec {

  sexp = rec {

    symbol = name_ : (
      if builtins.isString name_
      then {
        __sexpType = "symbol";
        value = name_;
      }
      else builtins.throw "sexp.symbol: expected string, got '${builtins.typeOf name_}'"
    );

    cons = car_ : cdr_ : {
      __sexpType = "cons";
      car = car_;
      cdr = cdr_;
    };

    form = name_ : arguments_ : (
      if !(builtins.isString name_)
      then builtins.throw "sexp.form: expected form name string, got '${builtins.typeOf name_}'"
      else (
        if !(builtins.isList arguments_)
        then builtins.throw "sexp.form: expected argument list, got '${builtins.typeOf arguments_}'"
        else [ (symbol name_) ] ++ arguments_
      )
    );

  };

  elisp = let

    concatMap_ = function_ : values_ : (builtins.concatLists (builtins.map function_ values_));

    isSexpNode_ = value_ : ((builtins.isAttrs value_) && (builtins.hasAttr "__sexpType" value_));

    isElispNode_ = value_ : ((builtins.isAttrs value_) && (builtins.hasAttr "__elispType" value_));

    needsLeadingEscape_ = name_ : (
      builtins.elem (builtins.substring 0 1 name_) [
        "0"
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "."
        "+"
        "-"
        "?"
      ]
    );

    escapeSymbolChars_ = name_ : (builtins.replaceStrings
      [
        "\\"
        " "
        "\n"
        "\r"
        "\t"
        "("
        ")"
        "["
        "]"
        "\""
        "'"
        "`"
        ","
        "#"
        ";"
      ]
      [
        "\\\\"
        "\\ "
        "\\\n"
        "\\\r"
        "\\\t"
        "\\("
        "\\)"
        "\\["
        "\\]"
        "\\\""
        "\\'"
        "\\`"
        "\\,"
        "\\#"
        "\\;"
      ]
      name_
    );

    escapeSymbol_ = name_ : (
      if name_ == ""
      then builtins.throw "elisp.escapeSymbol: empty symbol names are not supported"
      else let
        escaped_ = escapeSymbolChars_ name_;
      in (
        if needsLeadingEscape_ name_
        then "\\${escaped_}"
        else escaped_
      )
    );

    escapeString_ = value_ : (builtins.replaceStrings
      [
        "\\"
        "\""
        "\n"
        "\r"
        "\t"
      ]
      [
        "\\\\"
        "\\\""
        "\\n"
        "\\r"
        "\\t"
      ]
      value_
    );

    renderFloat_ = value_ : let
      rendered_ = builtins.toString value_;
    in (
      if builtins.match ".*[.eE].*" rendered_ != null
      then rendered_
      else "${rendered_}.0"
    );

    renderSexpNode_ = value_ : (
      if value_.__sexpType == "symbol"
      then (
        if !(builtins.hasAttr "value" value_)
        then builtins.throw "elisp.render: symbol node missing 'value'"
        else (
          if !(builtins.isString value_.value)
          then builtins.throw "elisp.render: expected symbol value string, got '${builtins.typeOf value_.value}'"
          else escapeSymbol_ value_.value
        )
      )
      else (
        if value_.__sexpType == "cons"
        then (
          if !(builtins.hasAttr "car" value_)
          then builtins.throw "elisp.render: cons node missing 'car'"
          else (
            if !(builtins.hasAttr "cdr" value_)
            then builtins.throw "elisp.render: cons node missing 'cdr'"
            else "(${render_ value_.car} . ${render_ value_.cdr})"
          )
        )
        else builtins.throw "elisp.render: unsupported sexp node type '${value_.__sexpType}'"
      )
    );

    renderElispNode_ = value_ : (
      if value_.__elispType == "vector"
      then (
        if !(builtins.hasAttr "values" value_)
        then builtins.throw "elisp.render: vector node missing 'values'"
        else (
          if !(builtins.isList value_.values)
          then builtins.throw "elisp.render: expected vector values list, got '${builtins.typeOf value_.values}'"
          else "[" + builtins.concatStringsSep " " (builtins.map render_ value_.values) + "]"
        )
      )
      else (
        if value_.__elispType == "raw"
        then (
          if !(builtins.hasAttr "value" value_)
          then builtins.throw "elisp.render: raw node missing 'value'"
          else (
            if !(builtins.isString value_.value)
            then builtins.throw "elisp.render: expected raw value string, got '${builtins.typeOf value_.value}'"
            else value_.value
          )
        )
        else builtins.throw "elisp.render: unsupported elisp node type '${value_.__elispType}'"
      )
    );

    renderList_ = values_ : (
      "(" + builtins.concatStringsSep " " (builtins.map render_ values_) + ")"
    );

    renderAttrs_ = value_ : (
      if isSexpNode_ value_
      then renderSexpNode_ value_
      else (
        if isElispNode_ value_
        then renderElispNode_ value_
        else builtins.throw "elisp.render: plain attrsets are unsupported; use plist/alist builders explicitly"
      )
    );

    render_ = value_ : let
      type_ = builtins.typeOf value_;
    in (
      if type_ == "null"
      then "nil"
      else (
        if type_ == "bool"
        then (
          if value_
          then "t"
          else "nil"
        )
        else (
          if type_ == "int"
          then builtins.toString value_
          else (
            if type_ == "float"
            then renderFloat_ value_
            else (
              if type_ == "string"
              then "\"${escapeString_ value_}\""
              else (
                if type_ == "path"
                then "\"${escapeString_ (builtins.toString value_)}\""
                else (
                  if type_ == "list"
                  then renderList_ value_
                  else (
                    if type_ == "set"
                    then renderAttrs_ value_
                    else builtins.throw "elisp.render: unsupported value type '${type_}'"
                  )
                )
              )
            )
          )
        )
      )
    );

    renderForms_ = forms_ : (
      if builtins.isList forms_
      then builtins.concatStringsSep "\n\n" (builtins.map render_ forms_)
      else builtins.throw "elisp.renderForms: expected list, got '${builtins.typeOf forms_}'"
    );

    plistEntryToValues_ = entry_ : (
      if !(builtins.isAttrs entry_)
      then builtins.throw "elisp.plist: expected entry attrset, got '${builtins.typeOf entry_}'"
      else (
        if !(builtins.hasAttr "key" entry_)
        then builtins.throw "elisp.plist: entry missing 'key'"
        else (
          if !(builtins.hasAttr "value" entry_)
          then builtins.throw "elisp.plist: entry missing 'value'"
          else (
            if !(builtins.isString entry_.key)
            then builtins.throw "elisp.plist: expected entry key string, got '${builtins.typeOf entry_.key}'"
            else [
              (sexp.symbol ":${entry_.key}")
              entry_.value
            ]
          )
        )
      )
    );

    alistEntryToValue_ = entry_ : (
      if !(builtins.isAttrs entry_)
      then builtins.throw "elisp.alist: expected entry attrset, got '${builtins.typeOf entry_}'"
      else (
        if !(builtins.hasAttr "key" entry_)
        then builtins.throw "elisp.alist: entry missing 'key'"
        else (
          if !(builtins.hasAttr "value" entry_)
          then builtins.throw "elisp.alist: entry missing 'value'"
          else sexp.cons entry_.key entry_.value
        )
      )
    );

    plist_ = entries_ : (
      if builtins.isList entries_
      then concatMap_ plistEntryToValues_ entries_
      else builtins.throw "elisp.plist: expected entry list, got '${builtins.typeOf entries_}'"
    );

    alist_ = entries_ : (
      if builtins.isList entries_
      then builtins.map alistEntryToValue_ entries_
      else builtins.throw "elisp.alist: expected entry list, got '${builtins.typeOf entries_}'"
    );

  in {

    symbol = sexp.symbol;

    cons = sexp.cons;

    form = sexp.form;

    vector = values_ : (
      if builtins.isList values_
      then {
        __elispType = "vector";
        values = values_;
      }
      else builtins.throw "elisp.vector: expected list, got '${builtins.typeOf values_}'"
    );

    raw = value_ : (
      if builtins.isString value_
      then {
        __elispType = "raw";
        value = value_;
      }
      else builtins.throw "elisp.raw: expected string, got '${builtins.typeOf value_}'"
    );

    quote = value_ : (sexp.form "quote" [
      value_
    ]);

    function = value_ : (sexp.form "function" [
      value_
    ]);

    backquote = value_ : (sexp.form "backquote" [
      value_
    ]);

    unquote = value_ : [
      (sexp.symbol ",")
      value_
    ];

    unquoteSplicing = value_ : [
      (sexp.symbol ",@")
      value_
    ];

    plist = plist_;

    plistFromAttrs = attrs_ : (
      if builtins.isAttrs attrs_
      then plist_ (builtins.map (name_ : {
        key = name_;
        value = builtins.getAttr name_ attrs_;
      }) (builtins.attrNames attrs_))
      else builtins.throw "elisp.plistFromAttrs: expected attrset, got '${builtins.typeOf attrs_}'"
    );

    alist = alist_;

    alistFromAttrs = attrs_ : (
      if builtins.isAttrs attrs_
      then alist_ (builtins.map (name_ : {
        key = sexp.symbol name_;
        value = builtins.getAttr name_ attrs_;
      }) (builtins.attrNames attrs_))
      else builtins.throw "elisp.alistFromAttrs: expected attrset, got '${builtins.typeOf attrs_}'"
    );

    render = render_;

    renderForms = renderForms_;

  };

}
