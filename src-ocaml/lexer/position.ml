(*
Huitr - a purely functional programming language.
Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*)

(* Type position for reading a file *)
type position = {
    filename : string;
    file_source : string;
    mutable line_number : int;
    mutable column_number : int;
    mutable index : int;
};;

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
    };;

let get_line
    (pos : position)
    : string option =
    let lines = String.split_on_char '\n' pos.file_source in
    if pos.line_number >= List.length lines
        then None
        else Some((Array.of_list lines).(pos.line_number) ^ "\n");;

let get_char
    (pos : position)
    : char option =
    let line = get_line(pos) in
    match line with
    | None -> None
    | Some(l) -> if pos.column_number >= String.length l
        then None
        else Some(l.[pos.column_number]);;

let end_of_line
    (* true if pos points at the end of a line and false else *)
    (pos : position)
    : bool =
    match get_char(pos) with
    | None -> false
    | Some(c) -> c = '\n';;

let advance
    (* Advances the position by n character, return the character it landed at or None if impossible *)
    (pos : position)
    (n : int)
    : unit =
    for _ = 1 to n do
        pos.column_number <- pos.column_number + 1;
        pos.index <- pos.index + 1;

        if end_of_line(pos)
            then begin
                pos.line_number <- pos.line_number + 1;
                pos.column_number <- 0;
            end
    done;;

let copy_position
    (pos : position)
    : position =
    {
        filename = pos.filename;
        file_source = pos.file_source;
        line_number = pos.line_number;
        column_number = pos.column_number;
        index = pos.index;
    };;

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
    print_string "]";;
