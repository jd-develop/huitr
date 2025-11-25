open Tipe.Parser
open Tipe.Lexer
open Huitr_utils

type ast =
  | Statements of ast list * int
  | List of ast list * int
  | Chain of ast list * int
  | Function of ast list * int
  | ModuleIdentifier of string list * string * int
  | Identifier of string * int
  | Integer of int * int
  | Float of float * int
  | String of string * int
  | InsideParenthesis of ast * int
  | Unit of int
  | Vide of int


let rec pos_start (t: ast) : int =
  match t with
  | Statements(_, i)
  | List(_, i)
  | Chain(_, i)
  | Function(_, i)
  | ModuleIdentifier(_, _, i)
  | Identifier(_, i)
  | Integer(_, i)
  | Float(_, i)
  | String(_, i)
  | InsideParenthesis(_, i)
  | Unit i
  | Vide i -> i


let rec statements (t: (string, string) syntax_tree)
    : ast list * int =
  match t with
  | Node("STATEMENTS", [Node("NEWLINE", [Leaf {start}])]) -> [], start
  | Node("STATEMENTS", [Node("NEWLINE", _); st]) ->
      statements st
  | Node("STATEMENTS", [ch_or_list; Node("NEWLINE", _); st]) ->
      let ast_of_ch_or_list = ast_of_syntax_tree ch_or_list in
      ast_of_ch_or_list :: (fst (statements st)),
      pos_start ast_of_ch_or_list
  | Node("STATEMENTS", ch_or_list::_) ->
      let ast_of_ch_or_list = ast_of_syntax_tree ch_or_list in
      [ast_of_ch_or_list], pos_start ast_of_ch_or_list
  | _ -> failwith "Pas un nœud STATEMENTS"


and list (t: (string, string) syntax_tree) : ast list * int =
  match t with
  | Node("LIST", [Node ("CHAIN", _) as ch; Leaf {token_type = "comma"}; at])
  | Node("LIST", [Node ("CHAIN", _) as ch; Leaf {token_type = "comma"};
                  Node ("ANY_AMOUNT_OF_NEWLINE", _); at]) ->
      let ast_ch = ast_of_syntax_tree ch in
      [ast_ch; ast_of_syntax_tree at], pos_start ast_ch
  | Node("LIST", [Node ("LIST", _) as l; Leaf {token_type = "comma"}; at])
  | Node("LIST", [Node ("LIST", _) as l; Leaf {token_type = "comma"};
                  Node ("ANY_AMOUNT_OF_NEWLINE", _); at]) ->
      let ast_l, p = list l in
      (ast_l)@[ast_of_syntax_tree at], p
  | _ -> failwith "Pas un nœud LIST"


and chainopatom (t: (string, string) syntax_tree) : ast list * int =
  match t with
  | Node("CHAINOPATOM", [Leaf {token_type = "chainop"; start}; at]) ->
      [ast_of_syntax_tree at], start
  | Node("CHAINOPATOM", [Leaf {token_type = "chainop"; start}; at;
                         Node("CHAINOPATOM", _) as chopat]) ->
      ast_of_syntax_tree at :: (fst (chainopatom chopat)), start
  | _ -> failwith "Pas un nœud CHAINOPATOM"

and chain (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("CHAIN", [Node("CHAINOPATOM", _) as chopat]) ->
      let ast_chopat, pos = chainopatom chopat in
      Chain (Unit(pos) :: ast_chopat, pos)
  | Node("CHAIN", [Node("LIST", _) as f; Node("CHAINOPATOM", _) as chopat])
  | Node("CHAIN", [Node("ATOM", _) as f; Node("CHAINOPATOM", _) as chopat]) ->
      let ast_f = ast_of_syntax_tree f in
      Chain (ast_f::(fst (chainopatom chopat)), pos_start ast_f)
  | Node("CHAIN", [Node("ATOM", _) as a]) -> ast_of_syntax_tree a
  | _ -> failwith "Pas un nœud CHAIN"

and parse_string_literal (literal: string): string =
    let res_chars = ref [] in
    let i = ref 0 in
    while !i < String.length literal do
        if literal.[!i] <> '\\' then
            res_chars := literal.[!i] :: !res_chars
        else (
            incr i;
            let new_char = match literal.[!i] with
            | '\\' -> '\\'
            | '"' -> '"'
            | 'n' -> '\n'
            | 't' -> '\t'
            | 'b' -> '\b'
            | 'r' -> '\r'
            | _ -> failwith "Pas une séquence d'échappement autorisée"
            in
            res_chars := new_char :: !res_chars
        );
        incr i
    done;
    Tipe.Utils.implode (List.rev !res_chars)

and atom (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("ATOM", [Leaf {token_type = "string_literal"; value; start}]) ->
      String (parse_string_literal (remove_first_and_last_char value), start)
  | Node("ATOM", [Leaf {token_type = "integer_literal"; value; start}]) ->
      Integer (int_of_string value, start)
  | Node("ATOM", [Leaf {token_type = "float_literal"; value; start}]) ->
      Float (float_of_string value, start)
  | Node("ATOM", [Node("IDENTIFIER", _) as id]) ->
      identifier id
  | Node("ATOM", [Node("FUNCTION", _) as f]) ->
      function_ f
  | Node("ATOM", [Leaf {token_type = "lparen"; start};
                  ch_or_list;
                  Leaf {token_type = "rparen"}])
  | Node("ATOM", [Leaf {token_type = "lparen"; start};
                  Node ("ANY_AMOUNT_OF_NEWLINE", _);
                  ch_or_list;
                  Leaf {token_type = "rparen"}])
  | Node("ATOM", [Leaf {token_type = "lparen"; start};
                  ch_or_list;
                  Node ("ANY_AMOUNT_OF_NEWLINE", _);
                  Leaf {token_type = "rparen"}])
  | Node("ATOM", [Leaf {token_type = "lparen"; start};
                  Node ("ANY_AMOUNT_OF_NEWLINE", _);
                  ch_or_list;
                  Node ("ANY_AMOUNT_OF_NEWLINE", _);
                  Leaf {token_type = "rparen"}]) ->
      InsideParenthesis(ast_of_syntax_tree ch_or_list, start)
  | Node("ATOM", [Node("UNIT", Leaf {start} :: _)]) -> Unit(start)
  | _ -> failwith "Pas un nœud ATOM"


and namespident (t: (string, string) syntax_tree) : string list * string =
  match t with
  | Node("NAMESPIDENT", [Leaf {token_type = "namesp"; start};
                         Leaf {token_type = "ident"; value}]) ->
      [], value
  | Node("NAMESPIDENT", [Leaf {token_type = "namesp"; start};
                         Leaf {token_type = "ident"; value};
                         Node("NAMESPIDENT", _) as suite]) ->
      let l, s = namespident suite in
      value::l, s
  | _ -> failwith "Pas un nœud NAMESPIDENT"

and identifier (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("IDENTIFIER", [Leaf {token_type = "ident"; value; start}]) ->
      Identifier(value, start)
  | Node("IDENTIFIER", [Leaf {token_type = "ident"; value; start};
                        Node("NAMESPIDENT", _) as namespident_suite]) ->
      let l, s = namespident namespident_suite in
      ModuleIdentifier (value::l, s, start)
  | _ -> failwith "Pas un nœud IDENTIFIER"


and function_ (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("FUNCTION", [Leaf {token_type = "lsquare"; start};
                      Node("STATEMENTS", _) as st;
                      Leaf {token_type = "rsquare"}]) ->
      Function (fst (statements st), start)
  | Node("FUNCTION", [Leaf {token_type = "lsquare"; start};
                      Leaf {token_type = "rsquare"}]) ->
      Function ([], start)
  | _ -> failwith "Pas un nœud FUNCTION"

and ast_of_syntax_tree (t: (string, string) syntax_tree) : ast =
  match t with
  | Leaf t ->
      begin match t.token_type with
      | "ident" -> Identifier (t.value, t.start)
      | "integer_literal" -> Integer (int_of_string t.value, t.start)
      | "float_literal" -> Float (float_of_string t.value, t.start)
      | "string_literal" -> String (parse_string_literal (remove_first_and_last_char t.value), t.start)
      | "newline" -> Vide t.start
      | _ -> failwith "Invalid token"
      end
  | Node("STATEMENTS", _) ->
      let l, p = statements t in
      Statements(l, p)
  | Node("LIST", _) ->
      let l, p = list t in
      List(l, p)
  | Node("CHAIN", _) ->
      chain t
  | Node("ATOM", _) ->
      atom t
  | Node("IDENTIFIER", _) ->
      identifier t
  | Node("FUNCTION", _) ->
      function_ t
  | Node("UNIT", Leaf {start} :: _) ->
      Unit(start)
  | Node(_, _) -> failwith "Unimplemented"
