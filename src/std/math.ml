open Value_and_errors

let add (l: value list) (pos: int) : value =
  let rec add_accu (l': value list) (accu: value_without_pos) : value =
    match l', accu with
    | [(Unit, _)], _
    | [], _ -> accu, pos
    | (Integer x, _)::q, (Integer y) -> add_accu q (Integer (x+y))
    | (Integer x, _)::q, (Float y)
    | (Float y, _)::q, (Integer x) -> add_accu q (Float ((float_of_int x) +. y))
    | (Float x, _)::q, (Float y) -> add_accu q (Float (x+.y))
    | x::_, _ -> raise (InvalidArgument(
        "std::math::add", Some (fst x), "entier ou flottant attendu", snd x
      ))
  in
  match l with
  | [(List l', _)]
  | l' -> add_accu l' (Integer 0)


let prod (l: value list) (pos: int) : value =
  let rec prod_accu (l': value list) (accu: value_without_pos) : value =
    match l', accu with
    | [(Unit, _)], _
    | [], _ -> accu, pos
    | (Integer x, _)::q, (Integer y) -> prod_accu q (Integer (x*y))
    | (Integer x, _)::q, (Float y)
    | (Float y, _)::q, (Integer x) -> prod_accu q (Float ((float_of_int x) *. y))
    | (Float x, _)::q, (Float y) -> prod_accu q (Float (x*.y))
    | x::_, _ -> raise (InvalidArgument(
        "std::math::prod", Some (fst x), "entier ou flottant attendu", snd x
      ))
  in
  match l with
  | [(List l', _)]
  | l' -> prod_accu l' (Integer 1)


let minus (l: value list) (pos: int) : value =
  match List.map fst l with
  | [Integer i; Integer j] -> Integer (i-j), pos
  | [Integer i; Float j] -> Float ((float_of_int i) -. j), pos
  | [Float i; Integer j] -> Float (i -. (float_of_int) j), pos
  | [Float i; Float j] -> Float (i -. j), pos
  | _ -> raise (InvalidArgument(
      "std::math::minus", Some (List l), "deux nombres attendus", pos
    ))

(* modulo mathématique (toujours positif) *)
let (%) a b = ((a mod b) + b) mod b


let mod_ (l: value list) (pos: int) : value =
  match l with
  | (Integer a, _)::(Integer b, _)::[] -> Integer (a % b), pos
  | _ -> raise (InvalidArgument(
      "std::math::mod", None, "deux nombres entiers attendus", pos
    ))


let create_module_math () : value =
  let math = Hashtbl.create 8 in
  Hashtbl.add math "add" (BuiltinFunction add, 0);
  Hashtbl.add math "prod" (BuiltinFunction prod, 0);
  Hashtbl.add math "minus" (BuiltinFunction minus, 0);
  Hashtbl.add math "mod" (BuiltinFunction mod_, 0);
  Module("math", math), 0

