open Value_and_errors

let not_ (l: value list) (pos: int) : value =
  match l with
  | [(Boolean b, _)] -> Boolean (not b), pos
  | [(v, v_pos)] ->
      raise(InterpretationError(InvalidArgument(
        "std::bool::not", Some v, "l’argument doit être booléen", v_pos, None
      )))
  | _ ->
      raise(InterpretationError(InvalidArgument(
        "std::bool::not", None, "merci de donner un argument", pos, None
      )))

let and_ (l: value list) (pos: int) : value =
  match l with
  | [(Boolean b1, _); (Boolean b2, _)] -> Boolean (b1 && b2), pos
  (* TODO: error msg *)
  | _ -> raise(InterpretationError(InvalidArgument(
      "std::bool::and", None, "please provide 2 booleans", pos, None
    )))

let or_ (l: value list) (pos: int) : value =
  match l with
  | [(Boolean b1, _); (Boolean b2, _)] -> Boolean (b1 || b2), pos
  (* TODO: error msg *)
  | _ -> raise(InterpretationError(InvalidArgument(
      "std::bool::or", None, "please provide 2 booleans", pos, None
    )))

let create_module_bool () : value =
  let bool_ = Hashtbl.create 8 in
  Hashtbl.add bool_ "true" (Boolean true, 0);
  Hashtbl.add bool_ "false" (Boolean false, 0);
  Hashtbl.add bool_ "not" (BuiltinFunction not_, 0);
  Hashtbl.add bool_ "and" (BuiltinFunction and_, 0);
  Hashtbl.add bool_ "or" (BuiltinFunction or_, 0);
  Module("bool", bool_), 0

