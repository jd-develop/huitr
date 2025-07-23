(*
 * Huitr - a purely functional programming language.
 * Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)

let tab_width = 4

type huitr_error = {
    error_type : string;
    error_message : string;
    start_pos : Position.position;
    end_pos : Position.position;
}

type t = huitr_error

let create_error
    (_error_type : string)
    (_error_message : string)
    (_start_pos : Position.position)
    (_end_pos : Position.position option)
    : huitr_error =
    {
        error_type = _error_type;
        error_message = _error_message;
        start_pos = _start_pos;
        end_pos = match _end_pos with
            | None -> _start_pos
            | Some(pos) -> pos;
    }

let print_error
    (e : huitr_error)
    : unit =
    print_string ("In file " ^ e.start_pos.filename ^ ", line ");
    print_int (e.start_pos.line_number + 1);
    print_endline ":";

    match Position.get_line e.start_pos with
    | None -> ()
    | Some(line) ->
        let tab_before_count = ref 0 in
        while line.[!tab_before_count] = '\t' do
            incr tab_before_count
        done;
        let start_offset = !tab_before_count * (tab_width - 1) in


        let tab_error_count = ref 0 in
        while line.[!tab_error_count] = '\t' do
            incr tab_error_count
        done;
        let end_offset = !tab_error_count * (tab_width - 1) in

        let rec repeat_string (s:string) (n:int) : string =
            if n = 0
                then ""
                else s ^ (repeat_string s (n - 1) )
        in

        print_string ("  " ^ line);
        print_string (repeat_string " " (e.start_pos.column_number + start_offset + 2) );
        print_string (repeat_string "^" (e.end_pos.column_number - e.start_pos.column_number + 1 + end_offset) );

        print_endline (e.error_type ^ ":" ^e.error_message)

let huitr_syntax_error
    ?(_end_pos : Position.position option = None)
    (_error_message : string)
    (_start_pos : Position.position)
    : huitr_error =
    create_error "SyntaxError" _error_message _start_pos _end_pos

let huitr_reference_error
    ?(_end_pos : Position.position option = None)
    (_error_message : string)
    (_start_pos : Position.position)
    : huitr_error =
    create_error "ReferenceError" _error_message _start_pos _end_pos

let huitr_modulenotfound_error
    ?(_end_pos : Position.position option = None)
    (_error_message : string)
    (_start_pos : Position.position)
    : huitr_error =
    create_error "ModuleNotFoundError" _error_message _start_pos _end_pos

(*
let huitr_unimplemented_error
    ?(_end_pos : Position.position option = None)
    (_error_message : string)
    (_start_pos : Position.position)
    : huitr_error =
    create_error "UnimplementedError" (_error_message ^" is not implemented yet") _start_pos _end_pos
*)
