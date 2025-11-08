
(* Renvoie une nouvelle chaîne qui ne contient ni le premier ni le dernier
 * caractère. Si la chaîne a 2 caractères ou moins, renvoie une chaîne vide *)
let remove_first_and_last_char (s: string) : string =
  let n = String.length s in
  if n <= 2 then ""
  else
    String.sub s 1 (n-2)

