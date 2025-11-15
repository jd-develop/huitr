open Value_and_errors

let not_ (l: value list) : value =
  match l with
  | [Boolean b] -> Boolean (not b)
  | _ -> raise(InvalidArgument("std::bool::not", None, ""))

let create_module_bool () : value =
  let bool_ = Hashtbl.create 8 in
  Hashtbl.add bool_ "true" (Boolean true);
  Hashtbl.add bool_ "false" (Boolean false);
  Hashtbl.add bool_ "not" (BuiltinFunction not_);
  Module("bool", bool_)

