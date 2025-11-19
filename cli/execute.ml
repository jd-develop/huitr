(*
 * Huitr - a purely functional programming language.
 * Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)
open Huitr_interpreter
open Tipe

let console (debug: bool) =
  if debug then print_endline "debug" else ();
  let scope = Interpreter.create_scope () in
  try
    while true do
      try
        print_string "huitr> ";
        let code = read_line () in
        let syntax_tree = Parse_huitr.parse_huitr code in
        let ast = Ast.ast_of_syntax_tree syntax_tree in
        let _ = Interpreter.wrapper_for_console scope ast in
        ()
      with
      | Lexer.Tokenize_failure({current_pos=n}) ->
          print_endline ("Error while tokenizing! "^(string_of_int n))
    done
  with
  | End_of_file -> ()


let execute_file (filename: string) (debug: bool) =
  if filename = "stdin" then
    console debug
  else
    let code_fp = open_in filename in
    let code = really_input_string code_fp (in_channel_length code_fp) in
    let syntax_tree = Parse_huitr.parse_huitr code in
    let ast = Ast.ast_of_syntax_tree syntax_tree in
    let _ = Interpreter.wrapper ast in
    if debug then print_endline "debug" else ()

