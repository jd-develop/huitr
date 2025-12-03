open Value_and_errors
open Huitr_utils


let rec print_no_newline (l: value list) (pos: int) : value =
  match l with
  | [] -> print_no_newline [List [], pos] pos
  | [value] -> begin
      let () = print_string (string_of_value_for_printing value) in
      value
      end
  | (_, list_pos)::_ -> print_no_newline [List l, list_pos] pos


let print (l: value list) (pos: int) : value =
  let value = print_no_newline l pos in
  let () = print_newline () in
  value


let input (l: value list) (pos: int) : value =
  let _ = print_no_newline l pos in
  let str = read_line () in
  String str, pos


let read (l: value list) (pos: int) : value =
  match l with
  | [String file_name, file_name_pos] ->
      begin try
        let in_ch = open_in file_name in
        let result = really_input_string in_ch (in_channel_length in_ch) in
        close_in in_ch;
        String result, pos
      with
      | Sys_error s -> raise (InterpretationError(SysError(
          s, file_name_pos, None
        )))
      end
  | [v, v_pos] -> raise (InterpretationError(InvalidArgument(
      "std::io::read", Some v,
      "le premier argument doit être une chaîne (nom de fichier)", v_pos, None
    )))
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::io::read", None, "un argument attendu", pos, None
    )))


let create_module_io () : value =
  let io = Hashtbl.create 8 in
  Hashtbl.add io "print" (BuiltinFunction print, 0);
  Hashtbl.add io "print_no_newline" (BuiltinFunction print_no_newline, 0);
  Hashtbl.add io "input" (BuiltinFunction input, 0);
  Hashtbl.add io "read" (BuiltinFunction read, 0);
  Module("io", io), 0

