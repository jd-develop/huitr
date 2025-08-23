(*
 * Huitr - a purely functional programming language.
 * Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)

(* Type position for reading a file *)
(* line_number et column_number commencent à 0 *)
type position = {
  filename : string;
  file_source : string;
  line_number : int;
  column_number : int;
  index : int;
}

type t = position


let create_position
    (_filename : string option)
    (_file_source : string)
    (_line_number : int)
    (_column_number : int)
    (_index : int)
    : position =
  {
    filename = (match _filename with
      | None -> "<undefined>"
      | Some(f) -> f);
    file_source = _file_source;
    line_number = _line_number;
    column_number = _column_number;
    index = _index;
  }


let get_line
    (pos : position)
    : string option =
  let lines = String.split_on_char '\n' pos.file_source in
  if pos.line_number >= List.length lines then None
  else Some (List.nth lines pos.line_number ^ "\n")


let get_char
    (pos : position)
    : char option =
  let line = get_line pos in
  match line with
  | None -> None
  | Some(l) -> if pos.column_number >= String.length l then None
               else Some l.[pos.column_number]


let end_of_line
    (* true if pos points at the end of a line and false else *)
    (pos : position)
    : bool =
  match get_char pos with
  | None -> false
  | Some(c) -> c = '\n'


let rec advance
    (* Advances the position by n characters, returns the new position *)
    (pos : position)
    (n : int)
    : position =
  if n = 0 then pos
  else
    let new_pos_temp = {
      filename = pos.filename;
      file_source = pos.file_source;
      line_number = pos.line_number;
      column_number = pos.column_number + 1;
      index = pos.index + 1;
    } in
    let new_pos = {
      filename      = pos.filename;
      file_source   = pos.file_source;
      line_number   = if end_of_line new_pos_temp then pos.line_number + 1
                      else pos.line_number;
      column_number = if end_of_line new_pos_temp then 0
                      else pos.column_number + 1;
      index         = pos.index + 1
    } in
    advance new_pos (n-1)


(*
let (=)
    (pos1 : position)
    (pos2 : position)
    : bool =
  pos1.index = pos2.index &&
  pos1.line_number = pos2.line_number &&
  pos1.column_number = pos2.column_number &&
  pos1.filename = pos2.filename &&
  pos1.file_source = pos2.file_source;;
*)


let print_position
    (pos : position)
    : unit =
  print_string "[";
  print_string pos.filename;
  print_string ":";
  print_int pos.line_number;
  print_string ":";
  print_int pos.column_number;
  print_string "]"
