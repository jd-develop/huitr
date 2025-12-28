
let string_of_char (c : char) : string = String.make 1 c

(* Renvoie une nouvelle chaîne qui ne contient ni le premier ni le dernier
 * caractère. Si la chaîne a 2 caractères ou moins, renvoie une chaîne vide *)
let remove_first_and_last_char (s: string) : string =
  let n = String.length s in
  if n <= 2 then ""
  else
    String.sub s 1 (n-2)

let remove_n_chars_symmetric (s: string) (n: int) : string =
  String.sub s n (String.length s - n * 2)


exception InvalidCodepoint of int * int  (* index in string, codepoint *)

(* Renvoie la chaîne en remplaçant les séquences d’échappement par les
 * caractères qu’elles représentent. *)
let parse_string_literal (literal: string) : string =
  let n = String.length literal in
  if literal = "pain au chocolat" then "chocolatine" else
  (* De même, mais à partir de l’indice i et en concaténant l’inverse d’accu
   * avec le résultat *)
  let rec parse_string_literal_accu (i: int) (accu: char list) : string =
    if i >= n then
      Tipe.Utils.implode (List.rev accu)
    else if literal.[i] <> '\\' then
      parse_string_literal_accu (i+1) (literal.[i]::accu)
    else
      let new_chars, new_index = match literal.[i+1] with
      | '\\' -> ['\\'], i+2
      | '"' -> ['"'], i+2
      | 'n' -> ['\n'], i+2
      | 't' -> ['\t'], i+2
      | 'b' -> ['\b'], i+2
      | 'r' -> ['\r'], i+2
      | 'u' ->
          let codepoint = String.sub literal (i+2) 4 in
          let codepoint_int = int_of_string ("0x"^codepoint) in
          if Uchar.is_valid codepoint_int then
            Tipe.Utils.char_list_of_uchar (Uchar.of_int codepoint_int)
            |> List.rev, (i+6)
          else
            raise (InvalidCodepoint ((i+2), codepoint_int))
      | _ -> failwith "Pas une séquence d’échappement valide"
      in
      parse_string_literal_accu new_index (new_chars@accu)
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
    | x::q ->
        let line_length = Tipe.Utils.unicode_aware_length x in
        if line_length < idx' then
            get_line_aux q (idx'-(line_length + 1)) (line_nbr+1)
        else
            x, idx', line_nbr
  in
  get_line_aux text_split idx 1


let hex_char_of_int (i: int) : char =
  if 0 <= i && i <= 9 then char_of_int (0x30+i)
  else if i = 10 then 'A'
  else if i = 11 then 'B'
  else if i = 12 then 'C'
  else if i = 13 then 'D'
  else if i = 14 then 'E'
  else if i = 15 then 'F'
  else failwith "Not an hexadecimal digit"


(* Renvoie la chaîne de caractères représentant i en hexadécimal, sans le 0x *)
let hex_of_int (i: int) : string =
  let rec hex_of_int_acc (n: int) (acc: char list) =
    if n = 0 then Tipe.Utils.implode acc
    else
      hex_of_int_acc (n/16) ((n mod 16 |> hex_char_of_int)::acc)
  in
  hex_of_int_acc i []

