open Value_and_errors

let partial_apply (l: value list) (pos: int) : value =
  match l with
  | [Function (f, scope, cur_list), func_pos ; v] ->
      Function (f, scope, v::cur_list), func_pos
  | [BuiltinFunction (f, cur_list), func_pos ; v] ->
      BuiltinFunction (f, v::cur_list), func_pos
  | [BuiltinFunctionInterpreter (f, cur_list), func_pos ; v] ->
      BuiltinFunctionInterpreter (f, v::cur_list), func_pos
  | [v, v_pos ; _] ->
    raise (InterpretationError(InvalidArgument (
      "std::fun::partial_apply", Some v,
      "fonction attenue",
      v_pos, None
    )))
  | _ ->
    raise (InterpretationError(InvalidArgument (
      "std::fun::partial_apply", None,
      "deux aurguments attendus : fonction et paramètre",
      pos, None
    )))


let create_module_fun () : value =
  let fun_ = Hashtbl.create 8 in
  Hashtbl.add fun_ "partial_apply" (BuiltinFunction (partial_apply, []), 0);
  Module("fun", fun_), 0

