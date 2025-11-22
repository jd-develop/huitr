
(* Renvoie une nouvelle chaîne qui ne contient ni le premier ni le dernier
 * caractère. Si la chaîne a 2 caractères ou moins, renvoie une chaîne vide *)
let remove_first_and_last_char (s: string) : string =
  let n = String.length s in
  if n <= 2 then ""
  else
    String.sub s 1 (n-2)

let string_of_list (l: 'a list) (string_of_'a: 'a -> string) =
  let rec print_list_aux (l': 'a list) =
    match l' with
    | [] -> ""
    | x::[] -> string_of_'a x
    | x::q -> (string_of_'a x^", "^(print_list_aux q))
  in
  ("["^(print_list_aux l)^"]")

