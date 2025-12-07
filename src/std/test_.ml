open Value_and_errors

let if_ (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [Boolean true, _; v; _]
  | [Boolean false, _; _; v] -> v
  | [v, v_pos; _; _; _] ->
      raise (InterpretationError(InvalidArgument(
        "std::test::if", Some v, "booléen attendu ici", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::test::if", None,
        "paramètres attendus : condition, valeur_vrai, valeur_faux", pos, None
      )))

let create_module_test () : value =
  let test = Hashtbl.create 8 in
  Hashtbl.add test "if" (BuiltinFunction if_, 0);
  Module("test", test), 0

