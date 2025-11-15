open Value_and_errors

let if_ (l: value list) : value =
  match l with
  | [Boolean true; v; _]
  | [Boolean false; _; v] -> v
  | _ -> raise (InvalidArgument("std::tests::if", None, ""))

let create_module_tests () : value =
  let tests = Hashtbl.create 8 in
  Hashtbl.add tests "if" (BuiltinFunction if_);
  Module("tests", tests)

