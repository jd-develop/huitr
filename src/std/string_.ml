open Value_and_errors
open Huitr_utils

let nth (l: value list) (pos: int) : value =
  match l with
  | [(String s, _); (Integer i, i_pos)]
  | [(Integer i, i_pos); (String s, _)] ->
      begin try
        String(string_of_char (String.get s i)), pos
      with
      | Invalid_argument(_) -> raise (InterpretationError(InvalidArgument(
          "std::string::nth", Some (Integer i), "indice invalide", i_pos, None
        )))
      end
  | [(String _, _); (v, v_pos)]
  | [(v, v_pos); (String _, _)] ->
      raise (InterpretationError(InvalidArgument(
        "std::string::nth", Some v, "entier attendu ici.", v_pos, None
      )))
  | [(Integer _, _); (v, v_pos)]
  | [(v, v_pos); (Integer _, _)] ->
      raise (InterpretationError(InvalidArgument(
        "std::string::nth", Some v, "chaîne de caractère attendue ici.", v_pos,
        None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::string::nth", None,
        "deux arguments requis : une chaîne et un entier", pos, None
      )))


let len (l: value list) (pos: int) : value =
  match l with
  | [(String s, _)] -> Integer (String.length s), pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::string::len", Some v, "chaîne attendue", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::string::len", None,
        "merci de donner une chaîne de caractères en argument",
        pos, None
      )))


let is_empty (l: value list) (pos: int) : value =
  match l with
  | [(String "", _)] -> Boolean true, pos
  | [(String _, _)] -> Boolean false, pos
  | [v, v_pos] ->
      raise (InterpretationError(InvalidArgument(
        "std::string::is_empty", Some v, "chaîne attendue", v_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument(
        "std::string::is_empty", Some (List l),
        "merci de donner une chaîne de caractères en argument",
        pos, None
      )))


let concat_strings (l: value list) (pos: int) : value =
  let rec concat_strings_accu (l': value list) (accu: string) : value =
    match l' with
    | [] -> String accu, pos
    | (String s, _)::q -> concat_strings_accu q (accu^s)
    | (v, v_pos)::q -> raise (InterpretationError(InvalidArgument(
        "std::string::concat_strings", Some v,
        "la liste ne doit contenir que des chaînes de caractères", v_pos,
        None
      )))
  in
  match l with
  | [(List l', _)]
  | l' -> concat_strings_accu l' ""


let split_on_char (l: value list) (pos: int) : value =
  match l with
  | [(String s, _); (String c, char_pos)] ->
    if String.length c <> 1 then
      raise (InterpretationError(InvalidArgument(
        "std::string::split_on_char", Some (String c),
        "le caractère sur lequel couper doit être une chaîne de longueur 1",
        char_pos, None
      )));
    let splitted = String.split_on_char c.[0] s in
    List (List.map (fun s -> String s, pos) splitted), pos
  | [(String s, _); (v, char_pos)] ->
      raise (InterpretationError(InvalidArgument (
        "std::string::split_on_char", Some v,
        ("le second argument doit être un caractère (i.e. une chaîne de "^
         "longueur 1)"),
        char_pos, None
      )))
  | [(v, s_pos); _] ->
      raise (InterpretationError(InvalidArgument (
        "std::string::split_on_char", Some v,
        "le premier argument doit être une chaîne de caractères",
        s_pos, None
      )))
  | _ ->
      raise (InterpretationError(InvalidArgument (
        "std::string::split_on_char", None,
        "merci de donner deux arguments",
        pos, None
      )))


let sub (l: value list) (pos: int) : value =
  match l with
  | [(String s, _); (Integer debut, deb_pos); (Integer len, len_pos)]
  | [(Integer debut, deb_pos); (Integer len, len_pos); (String s, _)] ->
      let n = String.length s in
      if debut < 0 then
        raise (InterpretationError(InvalidArgument (
          "std::string::sub", Some (Integer debut),
          "l’indice de début est invalide",
          deb_pos, None
        )));
      if len < 0 then
        raise (InterpretationError(InvalidArgument (
          "std::string::sub", Some (Integer len),
          "la longueur est invalide",
          len_pos, None
        )));
      if debut+len > n then
        raise (InterpretationError(InvalidArgument (
          "std::string::sub", Some (Integer len),
          ("l’indice de fin (qui vaut " ^
           (string_of_int (debut+len)) ^
           ") est invalide. Pour rappel, il faut fourir l’indice de début et " ^
           "la longueur."),
          len_pos, None
        )));
      String (String.sub s debut len), pos
  | [(String _, _); (Integer _, _); (v, bad_pos)]
  | [(String _, _); (v, bad_pos); _]
  | [(Integer _, _); (Integer _, _); (v, bad_pos)]
  | [(Integer _, _); (v, bad_pos); _]
  | [(v, bad_pos); _; _] ->
    raise (InterpretationError(InvalidArgument (
      "std::string::sub", Some v,
      "arguments attendus : chaîne, début, longueur ou début, longueur, chaîne",
      bad_pos, None
    )))
  | _ ->
    raise (InterpretationError(InvalidArgument (
      "std::string::sub", None,
      "trois arguments attendus",
      pos, None
    )))


let create_module_string () : value =
  let string = Hashtbl.create 8 in
  Hashtbl.add string "nth" (BuiltinFunction nth, 0);
  Hashtbl.add string "len" (BuiltinFunction len, 0);
  Hashtbl.add string "is_empty" (BuiltinFunction is_empty, 0);
  Hashtbl.add string "concat_strings" (BuiltinFunction concat_strings, 0);
  Hashtbl.add string "split_on_char" (BuiltinFunction split_on_char, 0);
  Hashtbl.add string "sub" (BuiltinFunction sub, 0);

  (* CONSTANTES *)
  Hashtbl.add string "empty" (String "", 0);
  Module("string", string), 0

