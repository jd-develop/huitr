open Value_and_errors

let true_nth_opt (l: 'a list) (i: int) : 'a option =
  if i < 0 then None
  else List.nth_opt l i

let nth (l: value list) (pos: int) : value =
  match l with
  | [(List l', _); (Integer i, i_pos)]
  | [(Integer i, i_pos); (List l', _)] ->
      begin
      match true_nth_opt l' i with
      | None -> raise (InterpretationError(InvalidArgument(
          "std::list::nth", Some (Integer i), "indice invalide", i_pos, None
        )))
      | Some x -> x
      end
  | [(List _, _); (v, v_pos)]
  | [(v, v_pos); (List _, _)] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::nth", Some v, "entier attendu ici.", v_pos, None
      )))
  | [(Integer _, _); (v, v_pos)]
  | [(v, v_pos); (Integer _, _)] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::nth", Some v, "liste attendue ici.", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::list::nth", None,
        "deux arguments requis : une liste et un entier", pos, None
      )))


let len (l: value list) (pos: int) : value =
  match l with
  | [List l', _] -> Integer (List.length l'), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::len", Some v, "liste attendue",
        v_pos, None
      )))
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::len", None, "un seul argument attendu (liste)",
      pos, None
    )))


let is_empty (l: value list) (pos: int) : value =
  match l with
  | [List l', _] -> begin
    match l' with
    | [] -> Boolean true, pos
    | _ -> Boolean false, pos
    end
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::is_empty", Some v, "liste attendue",
        v_pos, None
      )))
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::is_empty", None, "un seul argument attendu (liste)",
      pos, None
    )))


(* construire *)
let cons (l: value list) (pos: int) : value =
  match l with
  | [v; (List l', list_pos)] -> List (v::l'), pos
  | [_; (v, v_pos)] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::cons", Some v, "liste attendue ici", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::list::cons", None, "deux arguments attendus", pos, None
      )))


let head (l: value list) (pos: int) : value =
  match l with
  | [List l', _] -> begin
    match l' with
    | [] -> raise (InterpretationError(InvalidArgument(
        "std::list::head", Some (List []), "empty list", pos, None
      )))
    | x::q -> x
    end
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::head", Some v, "liste attendue",
        v_pos, None
      )))
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::head", None, "un seul argument attendu (liste)",
      pos, None
    )))


let tail (l: value list) (pos: int) : value =
  match l with
  | [List l', _] -> begin
    match l' with
    | x::q -> List q, pos
    | [] -> raise (InterpretationError(InvalidArgument(
        "std::list::tail", Some (List []), "empty list", pos, None
      )))
    end
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::tail", Some v, "liste attendue",
        v_pos, None
      )))
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::tail", None, "un seul argument attendu (liste)",
      pos, None
    )))


let map (l: value list) (pos: int) (apply_func: value -> value -> value) :
    value =
  match l with
  | [Function f, f_pos; List l', _] ->
      List (List.map (apply_func (Function f, f_pos)) l'), pos
  | [BuiltinFunction f, f_pos; List l', _] ->
      List (List.map (Fun.flip f f_pos) (List.map (Fun.flip List.cons []) l')), pos
  | [Function _, _; v, v_pos]
  | [BuiltinFunction _, _; v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::map", Some v, "liste attendue",
        v_pos, None
      )))
  | [v, v_pos; _] ->
      raise (InterpretationError(InvalidArgument(
        "std::list::map", Some v, "fonction attendue",
        v_pos, None
      )))
  | _ -> raise (InterpretationError(InvalidArgument(
      "std::list::map", None, "deux arguments attendus (fonction et liste)",
      pos, None
    )))


let create_module_list () : value =
  let list = Hashtbl.create 8 in
  Hashtbl.add list "nth" (BuiltinFunction nth, 0);
  Hashtbl.add list "len" (BuiltinFunction len, 0);
  Hashtbl.add list "is_empty" (BuiltinFunction is_empty, 0);
  Hashtbl.add list "cons" (BuiltinFunction cons, 0);
  Hashtbl.add list "head" (BuiltinFunction head, 0);
  Hashtbl.add list "tail" (BuiltinFunction tail, 0);
  Hashtbl.add list "map" (BuiltinFunctionInterpreter map, 0);

  (* CONSTANTES *)
  Hashtbl.add list "empty" (List [], 0);
  Module("list", list), 0

