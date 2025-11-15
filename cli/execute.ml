(*
 * Huitr - a purely functional programming language.
 * Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)
open Huitr_interpreter

let execute_file (filename: string) (debug: bool) =
  let code_fp = open_in filename in
  let code = really_input_string code_fp (in_channel_length code_fp) in
  let syntax_tree = Parse_huitr.parse_huitr code in
  let ast = Ast.ast_of_syntax_tree syntax_tree in
  let _ = Interpreter.wrapper ast in
  if debug then print_endline "debug" else ()
