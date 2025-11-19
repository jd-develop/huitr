open Value_and_errors
open Huitr_utils


let rec print_no_newline (l: value list) : value =
  match l with
  | [] -> Unit
  | [value] -> begin
      let () = (match value with
        | Integer i -> print_int i
        | Float f -> print_float f
        | String s -> print_string s
        | Boolean b -> print_string (if b then "true" else "false")
        | List l -> print_list l (fun x -> let _ = print_no_newline [x] in ())
        | Function _ -> print_string "(function)"
        | BuiltinFunction _ -> print_string "(built-in function)"
        | Module (s, _) -> print_string ("(module "^s^")")
        | Unit -> print_string "()") in
      value
      end
  | l -> print_no_newline [List l]


let print (l: value list) : value =
  let value = print_no_newline l in
  let () = print_newline () in
  value


let create_module_io () : value =
  let io = Hashtbl.create 8 in
  Hashtbl.add io "print" (BuiltinFunction print);
  Hashtbl.add io "print_no_newline" (BuiltinFunction print_no_newline);
  Module("io", io)

