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


let sqrt_ (l: value list) (pos: int) : value =
  match l with
  | [Float a, a_pos] ->
      if a < 0. then
        raise (InterpretationError(InvalidArgument(
          "std::math::sqrt", Some (Float a),
          "valeur positive attendue", a_pos, None
        )));
      Float (sqrt a), pos
  | [Integer a, a_pos] ->
      if a < 0 then
        raise (InterpretationError(InvalidArgument(
          "std::math::sqrt", Some (Integer a),
          "valeur positive attendue", a_pos, None
        )));
      Float (sqrt (float_of_int a)), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::sqrt", Some v, "entier ou flottant attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::sqrt", None, "un argument attendu", pos, None
      )))

let loge (l: value list) (pos: int) : value =
  match l with
  | [Float a, a_pos] ->
      if a <= 0. then
        raise (InterpretationError(InvalidArgument(
          "std::math::loge", Some (Float a),
          "valeur strictement positive attendue", a_pos, None
        )));
      Float (log a), pos
  | [Integer a, a_pos] ->
      if a <= 0 then
        raise (InterpretationError(InvalidArgument(
          "std::math::loge", Some (Integer a),
          "valeur strictement positive attendue", a_pos, None
        )));
      Float (log (float_of_int a)), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::loge", Some v, "entier ou flottant attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::loge", None, "un argument attendu", pos, None
      )))

let log10_ (l: value list) (pos: int) : value =
  match l with
  | [Float a, a_pos] ->
      if a <= 0. then
        raise (InterpretationError(InvalidArgument(
          "std::math::log10", Some (Float a),
          "valeur strictement positive attendue", a_pos, None
        )));
      Float (log10 a), pos
  | [Integer a, a_pos] ->
      if a <= 0 then
        raise (InterpretationError(InvalidArgument(
          "std::math::log10", Some (Integer a),
          "valeur strictement positive attendue", a_pos, None
        )));
      Float (log10 (float_of_int a)), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::log10", Some v, "entier ou flottant attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::log10", None, "un argument attendu", pos, None
      )))

let log2_ (l: value list) (pos: int) : value =
  match l with
  | [Float a, a_pos] ->
      if a <= 0. then
        raise (InterpretationError(InvalidArgument(
          "std::math::log2", Some (Float a),
          "valeur strictement positive attendue", a_pos, None
        )));
      Float (Float.log2 a), pos
  | [Integer a, a_pos] ->
      if a <= 0 then
        raise (InterpretationError(InvalidArgument(
          "std::math::log2", Some (Integer a),
          "valeur strictement positive attendue", a_pos, None
        )));
      Float (Float.log2 (float_of_int a)), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::log2", Some v, "entier ou flottant attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::log2", None, "un argument attendu", pos, None
      )))

let exp_ (l: value list) (pos: int) : value =
  match l with
  | [Float a, _] -> Float (exp a), pos
  | [Integer a, _] -> Float (a |> float_of_int |> exp), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::exp", Some v, "entier ou flottant attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::exp", None, "un argument attendu", pos, None
      )))

let sin_ (l: value list) (pos: int) : value =
  match l with
  | [Float a, _] -> Float (sin a), pos
  | [Integer a, _] -> Float (a |> float_of_int |> sin), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::sin", Some v, "entier ou flottant attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::sin", None, "un argument attendu", pos, None
      )))

let cos_ (l: value list) (pos: int) : value =
  match l with
  | [Float a, _] -> Float (cos a), pos
  | [Integer a, _] -> Float (a |> float_of_int |> cos), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::cos", Some v, "entier ou flottant attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::cos", None, "un argument attendu", pos, None
      )))


let floor_ (l: value list) (pos: int) : value =
  match l with
  | [Float f, _] -> Integer (int_of_float @@ floor f), pos
  | [Integer i, _] -> Integer i, pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::floor", Some v, "nombre attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::floor", None, "un argument attendu", pos, None
      )))

let ceil_ (l: value list) (pos: int) : value =
  match l with
  | [Float f, _] -> Integer (int_of_float @@ ceil f), pos
  | [Integer i, _] -> Integer i, pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::math::ceil", Some v, "nombre attendu",
        v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::math::ceil", None, "un argument attendu", pos, None
      )))

let create_module_math () : value =
  let math = Hashtbl.create 8 in
  Hashtbl.add math "add" (BuiltinFunction add, 0);
  Hashtbl.add math "prod" (BuiltinFunction prod, 0);
  Hashtbl.add math "minus" (BuiltinFunction minus, 0);
  Hashtbl.add math "div" (BuiltinFunction div, 0);
  Hashtbl.add math "floordiv" (BuiltinFunction floordiv, 0);
  Hashtbl.add math "mod" (BuiltinFunction mod_, 0);
  Hashtbl.add math "sqrt" (BuiltinFunction sqrt_, 0);
  Hashtbl.add math "loge" (BuiltinFunction loge, 0);
  Hashtbl.add math "log10" (BuiltinFunction log10_, 0);
  Hashtbl.add math "log2" (BuiltinFunction log2_, 0);
  Hashtbl.add math "exp" (BuiltinFunction exp_, 0);
  Hashtbl.add math "sin" (BuiltinFunction sin_, 0);
  Hashtbl.add math "cos" (BuiltinFunction cos_, 0);
  Hashtbl.add math "floor" (BuiltinFunction floor_, 0);
  Hashtbl.add math "ceil" (BuiltinFunction ceil_, 0);

  Hashtbl.add math "tau" (Float 6.283185307179586, 0);
  Hashtbl.add math "e" (Float (exp 1.0), 0);
  Module("math", math), 0

