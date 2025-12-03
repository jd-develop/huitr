open Value_and_errors

let true_nth_opt (l: 'a list) (i: int) : 'a option =
  if i < 0 then None
  else List.nth_opt l i

let nth (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [(List l', _); (Integer i, i_pos)]
  | [(Integer i, i_pos); (List l', _)] ->
      begin
      match true_nth_opt l' i with
      | None -> raise (InterpretationError(InvalidArgument(
          "std::list::nth", Some (Integer i), "invalid index", i_pos, None
        )))
      | Some x -> x
      end
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::nth", None, "the given argument is not a list",
      pos, None
    )))


let len (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [List l', _] -> Integer (List.length l'), pos
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::len", None, "the given argument is not a list",
      pos, None
    )))


let is_empty (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [List l', _] -> begin
    match l' with
    | [] -> Boolean true, pos
    | _ -> Boolean false, pos
    end
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::is_empty", None, "the given argument is not a list",
      pos, None
    )))

(* construire *)
let cons (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [v; (List l', list_pos)] -> List (v::l'), pos
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::cons", None, "second arg should be list", pos, None
    )))


let head (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [List l', _] -> begin
    match l' with
    | [] -> raise (InterpretationError(InvalidArgument(
        "std::list::head", Some (List []), "empty list", pos, None
      )))
    | x::q -> x
    end
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::head", None, "the given argument is not a list", pos, None
    )))


let tail (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [List l', _] -> begin
    match l' with
    | x::q -> List q, pos
    | [] -> raise (InterpretationError(InvalidArgument(
        "std::list::tail", Some (List []), "empty list", pos, None
      )))
    end
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::tail", None, "the given argument is not a list", pos, None
    )))

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

