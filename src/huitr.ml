open Parse_huitr
open Ast
open Interpreter
open Value_and_errors


let wrapper (code: string) =
  let syntax_tree = parse_huitr code in
  let ast = ast_of_syntax_tree syntax_tree in
  let _ = interpreter ast (create_scope ()) in
  ()

let wrapper_for_console (code: string) (variables: scope) =
  let syntax_tree = parse_huitr code in
  let ast = ast_of_syntax_tree syntax_tree in
  let _ = interpreter ast variables in
  ()

