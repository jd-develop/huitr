open Value_and_errors

let not_ (l: value list) : value =
  match l with
  | [Boolean b] -> Boolean (not b)
  | _ -> raise(InvalidArgument("std::bool::not", None, ""))

let and_ (l: value list) : value =
  match l with
  | [Boolean b1; Boolean b2] -> Boolean (b1 && b2)
  | _ -> raise(InvalidArgument("std::bool::and", None, "please provide 2 booleans"))

let or_ (l: value list) : value =
  match l with
  | [Boolean b1; Boolean b2] -> Boolean (b1 || b2)
  | _ -> raise(InvalidArgument("std::bool::or", None, "please provide 2 booleans"))

let create_module_bool () : value =
  let bool_ = Hashtbl.create 8 in
  Hashtbl.add bool_ "true" (Boolean true);
  Hashtbl.add bool_ "false" (Boolean false);
  Hashtbl.add bool_ "not" (BuiltinFunction not_);
  Hashtbl.add bool_ "and" (BuiltinFunction and_);
  Hashtbl.add bool_ "or" (BuiltinFunction or_);
  Module("bool", bool_)

