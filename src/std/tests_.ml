open Value_and_errors

let if_ (l: value list) (pos: int) : value =
  match l with
  | [Boolean true, _; v; _]
  | [Boolean false, _; _; v] -> v
  | _ -> raise (InvalidArgument(
      "std::tests::if", Some (List l),
      "paramètres attendus : condition, valeur_vrai, valeur_faux", pos
    ))

let create_module_tests () : value =
  let tests = Hashtbl.create 8 in
  Hashtbl.add tests "if" (BuiltinFunction if_, 0);
  Module("tests", tests), 0

