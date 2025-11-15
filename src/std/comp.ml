open Value_and_errors


let rec eq_ocaml_bool (l: value list) : bool =
  match l with
  | [u; v] ->
      begin match (u, v) with
      | Integer i, Integer j -> i = j
      | Float a, Float b -> a = b
      | Integer i, Float a
      | Float a, Integer i -> float_of_int i = a
      | String s, String s' -> s = s'
      | Boolean a, Boolean b -> a = b
      | List l, List l' ->
          if List.length l <> List.length l' then false
          else List.for_all2 (fun a b -> eq_ocaml_bool [a; b]) l l'
      | Function (f, _), Function (f', _) -> f = f'
      | BuiltinFunction f, BuiltinFunction f' -> f = f'
      | Module (s1, _), Module (s2, _) -> s1 = s2
      | Unit, Unit -> true
      | _ -> false
      end
  | _ -> raise (InvalidArgument("std::comp::eq", None, ""))

let eq (l: value list) : value =
  Boolean (eq_ocaml_bool l)

let ne (l: value list) : value =
  Boolean (not (eq_ocaml_bool l))


let comp_nombres
    (func_name: string)
    (comp_int: int -> int -> bool)
    (comp_float: float -> float -> bool)
    (l: value list) : value =
  match l with
  | [Integer i; Integer j] -> Boolean (comp_int i j)
  | [Float i; Float j] -> Boolean (comp_float i j)
  | [Integer i; Float j] -> Boolean (comp_float (float_of_int i) j)
  | [Float i; Integer j] -> Boolean (comp_float i (float_of_int j))
  | _ -> raise (InvalidArgument("std::comp::"^func_name, None, ""))


let create_module_comp () : value =
  let comp = Hashtbl.create 8 in
  Hashtbl.add comp "eq" (BuiltinFunction eq);
  Hashtbl.add comp "ne" (BuiltinFunction ne);
  Hashtbl.add comp "le" (BuiltinFunction (comp_nombres "le" (<=) (<=)));
  Hashtbl.add comp "lt" (BuiltinFunction (comp_nombres "lt" (<) (<)));
  Hashtbl.add comp "ge" (BuiltinFunction (comp_nombres "ge" (>=) (>=)));
  Hashtbl.add comp "gt" (BuiltinFunction (comp_nombres "gt" (>) (>)));
  Module("comp", comp)

