open Value_and_errors

let add (l: value list) : value =
  let rec add_accu (l': value list) (accu: value) : value =
    match l', accu with
    | [Unit], _
    | [], _ -> accu
    | (Integer x)::q, (Integer y) -> add_accu q (Integer (x+y))
    | (Integer x)::q, (Float y)
    | (Float y)::q, (Integer x) -> add_accu q (Float ((float_of_int) x +. y))
    | (Float x)::q, (Float y) -> add_accu q (Float (x+.y))
    | x::_, _ -> raise (InvalidArgument("std::math::add", Some x, "entier ou flottant attendu"))
  in
  add_accu l (Integer 0)


let prod (l: value list) : value =
  let rec prod_accu (l': value list) (accu: value) : value =
    match l', accu with
    | [Unit], _
    | [], _ -> accu
    | (Integer x)::q, (Integer y) -> prod_accu q (Integer (x*y))
    | (Integer x)::q, (Float y)
    | (Float y)::q, (Integer x) -> prod_accu q (Float ((float_of_int) x *. y))
    | (Float x)::q, (Float y) -> prod_accu q (Float (x*.y))
    | x::_, _ -> raise (InvalidArgument("std::math::prod", Some x, "entier ou flottant attendu"))
  in
  prod_accu l (Integer 1)


(* modulo mathématique (toujours positif) *)
let (%) a b = ((a mod b) + b) mod b


let mod_ (l: value list) : value =
  match l with
  | (Integer a)::(Integer b)::[] -> Integer (a % b)
  | _ -> raise (InvalidArgument("std::math::mod", None, ""))


let create_module_math () : value =
  let math = Hashtbl.create 8 in
  Hashtbl.add math "add" (BuiltinFunction add);
  Hashtbl.add math "prod" (BuiltinFunction prod);
  Hashtbl.add math "mod" (BuiltinFunction mod_);
  Module("math", math)

