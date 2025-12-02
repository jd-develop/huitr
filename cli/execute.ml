(*
 * Huitr - a purely functional programming language.
 * Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen, Erwan FB
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)
open Huitr_interpreter

let console (options: Huitr.interpreter_options) =
  if options.debug then print_endline "debug" else ();
  let scope = Interpreter.create_scope () in
  try
    while true do
      print_string "huitr> ";
      let line = read_line () in
      Huitr.wrapper line (Some scope) options
    done
  with
  | End_of_file -> print_endline "EOF"


let execute_file (filename: string) (options: Huitr.interpreter_options) :
    unit =
  if filename = "-" then
    console options
  else
    let code_fp = open_in filename in
    let code = really_input_string code_fp (in_channel_length code_fp) in
    Huitr.wrapper code None options

