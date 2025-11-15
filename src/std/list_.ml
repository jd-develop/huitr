open Value_and_errors
open Io

let nth (l: value list) : value =
  match l with
  | [List l'; Integer i] ->
      begin
      match List.nth_opt l' i with
      | None -> raise (InvalidArgument("nth", Some (Integer i), "invalid index"))
      | Some x -> x
      end
  | _ -> raise (InvalidArgument("nth", Some (List l), "not a list"))

let create_module_list () : value =
  let list = Hashtbl.create 8 in
  Hashtbl.add list "nth" (BuiltinFunction nth);
  Module("list", list)

