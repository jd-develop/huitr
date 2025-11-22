open Value_and_errors
open Huitr_utils


let rec print_no_newline (l: value list) (pos: int) : value =
  match l with
  | [] -> Unit, pos
  | [value] -> begin
      let () = (match fst value with
        | Integer i -> print_int i
        | Float f -> print_float f
        | String s -> print_string s
        | Boolean b -> print_string (if b then "true" else "false")
        | List l -> print_list l (fun x -> let _ = print_no_newline [x] pos in ())
        | Function _ -> print_string "(function)"
        | BuiltinFunction _ -> print_string "(built-in function)"
        | Module (s, _) -> print_string ("(module "^s^")")
        | Unit -> print_string "()") in
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


let create_module_io () : value =
  let io = Hashtbl.create 8 in
  Hashtbl.add io "print" (BuiltinFunction print, 0);
  Hashtbl.add io "print_no_newline" (BuiltinFunction print_no_newline, 0);
  Hashtbl.add io "input" (BuiltinFunction input, 0);
  Module("io", io), 0

