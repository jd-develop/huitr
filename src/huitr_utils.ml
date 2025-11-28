
let string_of_char (c : char) : string = String.make 1 c

(* Renvoie une nouvelle chaîne qui ne contient ni le premier ni le dernier
 * caractère. Si la chaîne a 2 caractères ou moins, renvoie une chaîne vide *)
let remove_first_and_last_char (s: string) : string =
  let n = String.length s in
  if n <= 2 then ""
  else
    String.sub s 1 (n-2)


(* Renvoie la chaîne en remplaçant les séquences d’échappement par les
 * caractères qu’elles représentent. *)
let parse_string_literal (literal: string) : string =
  let n = String.length literal in
  (* De même, mais à partir de l’indice i et en concaténant l’inverse d’accu
   * avec le résultat *)
  let rec parse_string_literal_accu (i: int) (accu: char list) : string =
    if i >= n then
      Tipe.Utils.implode (List.rev accu)
    else if literal.[i] <> '\\' then
      parse_string_literal_accu (i+1) (literal.[i]::accu)
    else
      let new_char = match literal.[i+1] with
      | '\\' -> '\\'
      | '"' -> '"'
      | 'n' -> '\n'
      | 't' -> '\t'
      | 'b' -> '\b'
      | 'r' -> '\r'
      | _   -> failwith "Pas une séquence d’échappement valide"
      in
      parse_string_literal_accu (i+2) (new_char::accu)
  in
  parse_string_literal_accu 0 []


let string_of_list (l: 'a list) (string_of_'a: 'a -> string) =
  match l with
  | [] -> "std::list::empty"
  | _ ->
    let rec print_list_aux (l': 'a list) =
      match l' with
      | [] -> ""
      | x::[] -> string_of_'a x
      | x::q -> (string_of_'a x^", "^(print_list_aux q))
    in
    ("("^(print_list_aux l)^")")

(* Étant donné un texte `text`, renvoie la ligne (i.e. la portion du texte
 * délimitée par \n) et l’indice dans la ligne correspondant au caractère
 * d’indice `idx` dans `text`, ainsi que le numéro de la ligne renvoyée *)
let get_line_from_idx (text: string) (idx: int) : string * int * int =
  let text_split = String.split_on_char '\n' text in
  let rec get_line_aux (text': string list) (idx': int) (line_nbr: int)
      : string * int * int =
    match text' with
    | [] -> "", 0, line_nbr
    | x::q -> if String.length x < idx' then
                get_line_aux q (idx'-(String.length x + 1)) (line_nbr+1)
              else
                x, idx', line_nbr
  in
  get_line_aux text_split idx 1

