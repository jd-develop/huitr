open Value_and_errors

let nth (l: value list) (pos: int) : value =
  match l with
  | [(List l', _); (Integer i, i_pos)]
  | [(Integer i, i_pos); (List l', _)] ->
      begin
      match List.nth_opt l' i with
      | None -> raise (InvalidArgument(
          "std::list::nth", Some (Integer i), "invalid index", i_pos
        ))
      | Some x -> x
      end
  | _ -> raise (InvalidArgument(
      "std::list::nth", Some (List l), "the given argument is not a list",
      pos
    ))


let len (l: value list) (pos: int) : value =
  Integer (List.length l), pos


let is_empty (l: value list) (pos: int) : value =
  match l with
  | [] -> Boolean true, pos
  | _ -> Boolean false, pos


(* construire *)
let cons (l: value list) (pos: int) : value =
  match l with
  | [v; (List l', list_pos)] -> List (v::l'), pos
  | _ -> raise (InvalidArgument(
      "std::list::cons", Some (List l), "second arg should be list", pos
    ))


let head (l: value list) (pos: int) : value =
  match l with
  | [] -> raise (InvalidArgument(
      "std::list::head", Some (List []), "empty list", pos
    ))
  | x::q -> x


let tail (l: value list) (pos: int) : value =
  match l with
  | x::q -> List q, pos
  | [] -> raise (InvalidArgument(
      "std::list::tail", Some (List []), "empty list", pos
    ))


let create_module_list () : value =
  let list = Hashtbl.create 8 in
  Hashtbl.add list "nth" (BuiltinFunction nth, 0);
  Hashtbl.add list "len" (BuiltinFunction len, 0);
  Hashtbl.add list "is_empty" (BuiltinFunction is_empty, 0);
  Hashtbl.add list "cons" (BuiltinFunction cons, 0);
  Hashtbl.add list "head" (BuiltinFunction head, 0);
  Hashtbl.add list "tail" (BuiltinFunction tail, 0);

  (* CONSTANTES *)
  Hashtbl.add list "empty" (List [], 0);
  Module("list", list), 0

