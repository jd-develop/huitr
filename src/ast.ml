open Tipe.Parser
open Tipe.Lexer
open Huitr_utils

type ast =
  | Statements of ast list
  | List of ast list
  | Chain of ast list
  | Function of ast list
  | ModuleIdentifier of string list * string
  | Identifier of string
  | Integer of int
  | Float of float
  | String of string
  | Unit
  | Vide


let rec statements (t: (string, string) syntax_tree)
    : ast list =
  match t with
  | Node("STATEMENTS", [Leaf {token_type = "newline"}]) -> []
  | Node("STATEMENTS", [Leaf {token_type = "newline"}; st]) ->
      statements st
  | Node("STATEMENTS", [ch_or_list; Leaf {token_type = "newline"}; st]) ->
      ast_of_syntax_tree ch_or_list :: (statements st)
  | Node("STATEMENTS", ch_or_list::_) ->
      [ast_of_syntax_tree ch_or_list]
  | _ -> failwith "Pas un nœud STATEMENTS"


and list (t: (string, string) syntax_tree) : ast list =
  match t with
  | Node("LIST", [Node ("CHAIN", _) as ch; Leaf {token_type = "comma"}; at])
  | Node("LIST", [Node ("CHAIN", _) as ch; Leaf {token_type = "comma"};
                  Node ("ANY_AMOUNT_OF_NEWLINE", _); at]) ->
      [ast_of_syntax_tree ch; ast_of_syntax_tree at]
  | Node("LIST", [Node ("LIST", _) as l; Leaf {token_type = "comma"}; at])
  | Node("LIST", [Node ("LIST", _) as l; Leaf {token_type = "comma"};
                  Node ("ANY_AMOUNT_OF_NEWLINE", _); at]) ->
      (list l)@[ast_of_syntax_tree at]
  | _ -> failwith "Pas un nœud LIST"


and chainopatom (t: (string, string) syntax_tree) : ast list =
  match t with
  | Node("CHAINOPATOM", [Leaf {token_type = "chainop"}; at]) ->
      [ast_of_syntax_tree at]
  | Node("CHAINOPATOM", [Leaf {token_type = "chainop"}; at;
                         Node("CHAINOPATOM", _) as chopat]) ->
      ast_of_syntax_tree at :: (chainopatom chopat)
  | Node("CHAINOPATOM", _) -> failwith "Meh"
  | _ -> failwith "Pas un nœud CHAINOPATOM"

and chain (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("CHAIN", [Node("CHAINOPATOM", _) as chopat]) ->
      Chain (Unit :: chainopatom chopat)
  | Node("CHAIN", [Node("LIST", _) as f; Node("CHAINOPATOM", _) as chopat])
  | Node("CHAIN", [Node("ATOM", _) as f; Node("CHAINOPATOM", _) as chopat]) ->
      Chain ((ast_of_syntax_tree f)::(chainopatom chopat))
  | Node("CHAIN", [Node("ATOM", _) as a]) -> ast_of_syntax_tree a
  | _ -> failwith "Pas un nœud CHAIN"


and atom (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("ATOM", [Leaf {token_type = "string_literal"; value}]) ->
      String (remove_first_and_last_char value)
  | Node("ATOM", [Leaf {token_type = "integer_literal"; value}]) ->
      Integer (int_of_string value)
  | Node("ATOM", [Leaf {token_type = "float_literal"; value}]) ->
      Float (float_of_string value)
  | Node("ATOM", [Node("IDENTIFIER", _) as id]) ->
      identifier id
  | Node("ATOM", [Node("FUNCTION", _) as f]) ->
      function_ f
  | Node("ATOM", [Leaf {token_type = "lparen"};
                  ch_or_list;
                  Leaf {token_type = "rparen"}]) ->
      ast_of_syntax_tree ch_or_list
  | Node("ATOM", [Node("UNIT", _)]) -> Unit
  | _ -> failwith "Pas un nœud ATOM"


and namespident (t: (string, string) syntax_tree) : string list * string =
  match t with
  | Node("NAMESPIDENT", [Leaf {token_type = "namesp"};
                         Leaf {token_type = "ident"; value}]) ->
      [], value
  | Node("NAMESPIDENT", [Leaf {token_type = "namesp"};
                         Leaf {token_type = "ident"; value};
                         Node("NAMESPIDENT", _) as suite]) ->
      let l, s = namespident suite in
      value::l, s
  | _ -> failwith "Pas un nœud NAMESPIDENT"

and identifier (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("IDENTIFIER", [Leaf {token_type = "ident"; value}]) ->
      Identifier value
  | Node("IDENTIFIER", [Leaf {token_type = "ident"; value};
                        Node("NAMESPIDENT", _) as namespident_suite]) ->
      let l, s = namespident namespident_suite in
      ModuleIdentifier (value::l, s)
  | _ -> failwith "Pas un nœud IDENTIFIER"


and function_ (t: (string, string) syntax_tree) : ast =
  match t with
  | Node("FUNCTION", [Leaf {token_type = "lsquare"};
                      Node("STATEMENTS", _) as st;
                      Leaf {token_type = "rsquare"}]) ->
      Function (statements st)
  | Node("FUNCTION", [Leaf {token_type = "lsquare"};
                      Leaf {token_type = "rsquare"}]) ->
      Function []
  | _ -> failwith "Pas un nœud FUNCTION"

and ast_of_syntax_tree (t: (string, string) syntax_tree) : ast =
  match t with
  | Leaf t ->
      begin match t.token_type with
      | "ident" -> Identifier t.value
      | "integer_literal" -> Integer (int_of_string t.value)
      | "float_literal" -> Float (float_of_string t.value)
      | "string_literal" -> String (remove_first_and_last_char t.value)
      | "newline" -> Vide
      | _ -> failwith "Invalid token"
      end
  | Node("STATEMENTS", _) ->
      Statements (statements t)
  | Node("LIST", _) ->
      List (list t)
  | Node("CHAIN", _) ->
      chain t
  | Node("ATOM", _) ->
      atom t
  | Node("IDENTIFIER", _) ->
      identifier t
  | Node("FUNCTION", _) ->
      function_ t
  | Node("UNIT", _) ->
      Unit
  | Node(_, _) -> failwith "Unimplemented"
