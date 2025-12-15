open Value_and_errors
open Huitr_utils

let to_string (l: value list) (pos: int) =
  match l with
  | [v] ->
      String(string_of_value v), pos
  | _ ->
    raise (InterpretationError(InvalidArgument (
      "std::string::to_string", None,
      "un argument attendu",
      pos, None
    )))


let to_int (l: value list) (pos: int) =
  match l with
  | [String s, s_pos] ->
      begin match int_of_string_opt s with
      | None ->
        raise (InterpretationError(InvalidArgument (
          "std::string::to_int", None,
          "pas un littéral d’entier valide",
          s_pos, None
        )))
      | Some i -> Integer(i), pos
      end
  | [v, v_pos] ->
    raise (InterpretationError(InvalidArgument (
      "std::string::to_int", Some v,
      "chaîne de caractères attendue",
      v_pos, None
    )))
  | _ ->
    raise (InterpretationError(InvalidArgument (
      "std::string::to_int", None,
      "un argument attendu",
      pos, None
    )))

let to_float (l: value list) (pos: int) =
  match l with
  | [String s, s_pos] ->
      begin match float_of_string_opt s with
      | None ->
        raise (InterpretationError(InvalidArgument (
          "std::string::to_float", None,
          "pas un littéral de flottant valide",
          s_pos, None
        )))
      | Some i -> Float(i), pos
      end
  | [v, v_pos] ->
    raise (InterpretationError(InvalidArgument (
      "std::string::to_float", Some v,
      "chaîne de caractères attendue",
      v_pos, None
    )))
  | _ ->
    raise (InterpretationError(InvalidArgument (
      "std::string::to_float", None,
      "un argument attendu",
      pos, None
    )))


let create_module_conv () : value =
  let conv = Hashtbl.create 8 in
  Hashtbl.add conv "to_string" (BuiltinFunction to_string, 0);
  Hashtbl.add conv "to_int" (BuiltinFunction to_int, 0);
  Hashtbl.add conv "to_float" (BuiltinFunction to_float, 0);

  Module("conv", conv), 0

