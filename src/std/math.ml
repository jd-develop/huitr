open Value_and_errors

let add (l: value list) (pos: int) : value =
  let rec add_accu (l': value list) (accu: value_without_pos) : value =
    match l', accu with
    | [], _ -> accu, pos
    | (Integer x, _)::q, (Integer y) -> add_accu q (Integer (x+y))
    | (Integer x, _)::q, (Float y)
    | (Float y, _)::q, (Integer x) -> add_accu q (Float ((float_of_int x) +. y))
    | (Float x, _)::q, (Float y) -> add_accu q (Float (x+.y))
    | (x, x_pos)::_, _ -> raise (InterpretationError(InvalidArgument(
        "std::math::add", Some x, "entier ou flottant attendu", x_pos,
        None
      )))
  in
  match l with
  | [(List l', _)]
  | l' -> add_accu l' (Integer 0)


let prod (l: value list) (pos: int) : value =
  let rec prod_accu (l': value list) (accu: value_without_pos) : value =
    match l', accu with
    | [], _ -> accu, pos
    | (Integer x, _)::q, (Integer y) -> prod_accu q (Integer (x*y))
    | (Integer x, _)::q, (Float y)
    | (Float y, _)::q, (Integer x) -> prod_accu q (Float ((float_of_int x) *. y))
    | (Float x, _)::q, (Float y) -> prod_accu q (Float (x*.y))
    | (x, x_pos)::_, _ -> raise (InterpretationError(InvalidArgument(
        "std::math::prod", Some x, "entier ou flottant attendu", x_pos,
        None
      )))
  in
  match l with
  | [(List l', _)]
  | l' -> prod_accu l' (Integer 1)


let minus (l: value list) (pos: int) : value =
  match l with
  | [Integer i, _; Integer j, _] -> Integer (i-j), pos
  | [Integer i, _; Float j, _] -> Float ((float_of_int i) -. j), pos
  | [Float i, _; Integer j, _] -> Float (i -. (float_of_int) j), pos
  | [Float i, _; Float j, _] -> Float (i -. j), pos
  | [Integer _, _; v, v_pos]
  | [Float _, _; v, v_pos]
  | [v, v_pos; _] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::minus", Some v, "entier ou flottant attendu", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::minus", None, "deux arguments attendus", pos, None
      )))


let div (l: value list) (pos: int) : value =
  match l with
  | [Integer i, _; Integer j, _] ->
      Float (float_of_int i /. float_of_int j), pos
  | [Integer i, _; Float j, _] -> Float ((float_of_int i) /. j), pos
  | [Float i, _; Integer j, _] -> Float (i /. (float_of_int) j), pos
  | [Float i, _; Float j, _] -> Float (i /. j), pos
  | [Integer _, _; v, v_pos]
  | [Float _, _; v, v_pos]
  | [v, v_pos; _] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::div", Some v, "entier ou flottant attendu", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::div", None, "deux arguments attendus", pos, None
      )))


let (//) a b =
  let res = a/b in
  if res*b > a then res-1
  else res


let floordiv (l: value list) (pos: int) : value =
  match l with
  | [Integer i, _; Integer j, j_pos] ->
      if j = 0 then
        raise (InterpretationError(DivisionByZero (j_pos, None)));
      Integer (i // j), pos
  | [Integer _, _; v, v_pos]
  | [v, v_pos; _] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::floordiv", Some v, "entier attendu", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::floordiv", None, "deux arguments attendus", pos, None
      )))


(* modulo mathématique (toujours positif) *)
let (%) a b = ((a mod b) + b) mod b


let mod_ (l: value list) (pos: int) : value =
  match l with
  | (Integer a, _)::(Integer b, _)::[] -> Integer (a % b), pos
  | [Integer _, _; v, v_pos]
  | [v, v_pos; _] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::mod", Some v, "entier attendu", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::mod", None, "deux arguments attendus", pos, None
      )))


let create_module_math () : value =
  let math = Hashtbl.create 8 in
  Hashtbl.add math "add" (BuiltinFunction add, 0);
  Hashtbl.add math "prod" (BuiltinFunction prod, 0);
  Hashtbl.add math "minus" (BuiltinFunction minus, 0);
  Hashtbl.add math "div" (BuiltinFunction div, 0);
  Hashtbl.add math "floordiv" (BuiltinFunction floordiv, 0);
  Hashtbl.add math "mod" (BuiltinFunction mod_, 0);
  Hashtbl.add math "tau" (Float 6.283185307179586, 0);
  Hashtbl.add math "e" (Float (exp 1.0), 0);
  Module("math", math), 0

