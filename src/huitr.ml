open Tipe.Lexer
open Tipe.Parser

open Parse_huitr
open Ast
open Interpreter
open Value_and_errors


let wrapper (code: string) (variables: scope option) =
  try
    let syntax_tree = parse_huitr code in
    let ast = ast_of_syntax_tree syntax_tree in
    let _ = match variables with
    | None -> interpreter ast (create_scope ()) 0
    | Some scope -> interpreter ast scope 0
    in
    ()
  with
  | Tokenize_failure {current_pos} ->
      print_error "SyntaxError" "Syntaxe invalide." current_pos code
  | SyntaxError(message, pos) ->
      print_error "SyntaxError" message pos code
  | NotCallable(f, pos) ->
      print_error
        "NotCallable"
        ("La valeur "^(string_of_value f)^" n’est pas appelable.")
        pos code
  | Undefined(name, pos) ->
      print_error "Undefined" ("Le nom "^name^" n’est pas défini") pos
      code
  | IsNotModule(name, v, pos) ->
      print_error "IsNotModule"
      ("Le nom "^name^" n’est pas un module (il s’agit de la valeur "^
       (string_of_value v)^").")
      pos code
  | RecursionDepthExceeded(pos) ->
      print_error "RecursionDepthExceeded"
        "trop d’appels récursifs (max 60000)" pos code
  | InvalidArgument(func, value, errmsg, pos) ->
      print_error "InvalidArgument"
        begin match value with
        | Some x ->
          ("Argument « " ^ (string_of_value (x, 0)) ^
           " » invalide dans la fonction " ^ func ^ ", avec le message « " ^
           errmsg ^ " ».")
        | None ->
          ("Argument invalide dans la fonction " ^ func ^ ", avec le message " ^
           " « " ^ errmsg ^ " ».")
        end
      pos code

