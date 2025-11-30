open Value_and_errors


let rec eq_ocaml_bool (l: value list) (pos: int) : bool =
  match l with
  | [u; v] ->
      begin match (fst u, fst v) with
      | Integer i, Integer j -> i = j
      | Float a, Float b -> a = b
      | Integer i, Float a
      | Float a, Integer i -> float_of_int i = a
      | String s, String s' -> s = s'
      | Boolean a, Boolean b -> a = b
      | List l, List l' ->
          if List.length l <> List.length l' then false
          else List.for_all2 (fun a b -> eq_ocaml_bool [a; b] (snd a)) l l'
      | Function (f, _), Function (f', _) -> f = f'
      | BuiltinFunction f, BuiltinFunction f' -> f = f'
      | Module (s1, _), Module (s2, _) -> s1 = s2
      | Unit, Unit -> true
      | _ -> false
      end
  | _ -> raise (InvalidArgument("std::comp::eq", None,
                                "merci de donner deux arguments", pos))

let eq (l: value list) (pos: int) : value =
  Boolean (eq_ocaml_bool l pos), pos

let ne (l: value list) (pos: int) : value =
  Boolean (not (eq_ocaml_bool l pos)), pos


let comp_nombres
    (func_name: string)
    (comp_int: int -> int -> bool)
    (comp_float: float -> float -> bool)
    (l: value list)
    (pos: int) : value =
  match l with
  | [Integer i, _; Integer j, _] -> Boolean (comp_int i j), pos
  | [Float i, _; Float j, _] -> Boolean (comp_float i j), pos
  | [Integer i, _; Float j, _] -> Boolean (comp_float (float_of_int i) j), pos
  | [Float i, _; Integer j, _] -> Boolean (comp_float i (float_of_int j)), pos
  | [Float _, _; v, v_pos]
  | [Integer _, _; v, v_pos]
  | [v, v_pos; _] -> raise (InvalidArgument(
      "std::comp::"^func_name,
      Some v,
      "merci de donner deux nombres en argument",
      v_pos
    ))
  | _ -> raise (InvalidArgument(
    "std::comp::"^func_name,
    None,
    "merci de donner deux nombres en argument",
    pos
  ))


let create_module_comp () : value =
  let comp = Hashtbl.create 8 in
  Hashtbl.add comp "eq" (BuiltinFunction eq, 0);
  Hashtbl.add comp "ne" (BuiltinFunction ne, 0);
  Hashtbl.add comp "le" (BuiltinFunction (comp_nombres "le" (<=) (<=)), 0);
  Hashtbl.add comp "lt" (BuiltinFunction (comp_nombres "lt" (<) (<)), 0);
  Hashtbl.add comp "ge" (BuiltinFunction (comp_nombres "ge" (>=) (>=)), 0);
  Hashtbl.add comp "gt" (BuiltinFunction (comp_nombres "gt" (>) (>)), 0);
  Module("comp", comp), 0

