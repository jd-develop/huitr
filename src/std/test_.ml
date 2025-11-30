open Value_and_errors

let if_ (l: value list) (pos: int) : value =
  (* TODO: error msg *)
  match l with
  | [Boolean true, _; v; _]
  | [Boolean false, _; _; v] -> v
  | _ -> raise (InvalidArgument(
      "std::tests::if", Some (List l),
      "paramètres attendus : condition, valeur_vrai, valeur_faux", pos
    ))

let create_module_test () : value =
  let test = Hashtbl.create 8 in
  Hashtbl.add test "if" (BuiltinFunction if_, 0);
  Module("test", test), 0

