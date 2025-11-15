open Value_and_errors
open Huitr_utils


let rec print (l: value list) : value =
  match l with
  | [] -> Unit
  | [value] -> begin
      let () = (match value with
        | Integer i -> print_int i; print_newline ()
        | Float f -> print_float f; print_newline ()
        | String s -> print_endline s
        | Boolean b -> print_endline (if b then "true" else "false")
        | List l -> print_list l (fun x -> let _ = print [x] in ())
        | Function _ -> print_endline "(function)"
        | BuiltinFunction _ -> print_endline "(built-in function)"
        | Module (s, _) -> print_endline ("(module "^s^")")
        | Unit -> print_endline "()") in
      value
      end
  | l -> print [List l]


let create_module_io () : value =
  let io = Hashtbl.create 8 in
  Hashtbl.add io "print" (BuiltinFunction print);
  Module("io", io)

