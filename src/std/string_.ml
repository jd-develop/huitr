open Value_and_errors
open Huitr_utils

let nth (l: value list) (pos: int) : value =
  match l with
  | [(String s, _); (Integer i, i_pos)]
  | [(Integer i, i_pos); (String s, _)] ->
      begin try
        String(string_of_char (String.get s i)), pos
      with
      | Invalid_argument(_) -> raise (InvalidArgument(
          "std::string::nth", Some (Integer i), "indice invalide", i_pos
        ))
      end
  | _ -> raise (InvalidArgument(
      "std::string::nth", Some (List l),
      "merci de donner une chaîne de caractères en argument",
      pos
    ))


let len (l: value list) (pos: int) : value =
  match l with
  | [(String s, _)] -> Integer (String.length s), pos
  | _ -> raise (InvalidArgument(
      "std::string::len", Some (List l),
      "merci de donner une chaîne de caractères en argument",
      pos
    ))


let is_empty (l: value list) (pos: int) : value =
  match l with
  | [(String "", _)] -> Boolean true, pos
  | [(String _, _)] -> Boolean false, pos
  | _ -> raise (InvalidArgument(
      "std::string::is_empty", Some (List l),
      "merci de donner une chaîne de caractères en argument",
      pos
    ))


let concat_strings (l: value list) (pos: int) : value =
  let rec concat_strings_accu (l': value list) (accu: string) : value =
    match l' with
    | [] -> String accu, pos
    | (String s, _)::q -> concat_strings_accu q (accu^s)
    | (v, v_pos)::q -> raise (InvalidArgument(
        "std::list::concat_strings", Some v,
        "la liste ne doit contenir que des chaînes de caractères", v_pos
      ))
  in
  concat_strings_accu l ""


let create_module_string () : value =
  let string = Hashtbl.create 8 in
  Hashtbl.add string "nth" (BuiltinFunction nth, 0);
  Hashtbl.add string "len" (BuiltinFunction len, 0);
  Hashtbl.add string "is_empty" (BuiltinFunction is_empty, 0);
  Hashtbl.add string "concat_strings" (BuiltinFunction concat_strings, 0);

  (* CONSTANTES *)
  Hashtbl.add string "empty" (String "", 0);
  Module("string", string), 0

