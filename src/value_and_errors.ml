open Ast
open Huitr_utils

type value_without_pos =
  | Integer of int
  | Float of float
  | String of string
  | Boolean of bool
  | List of value list
  | Function of (ast list * scope)
  | BuiltinFunction of (value list -> int -> value)  (* start pos *)
  | Module of string * (string, value) Hashtbl.t
  | Unit
and value = value_without_pos * int
and scope = {
  parent: scope option;
  variables: (string, value) Hashtbl.t
}


let rec string_of_value (v: value) : string =
  match fst v with
  | Integer i -> string_of_int i
  | Float f -> string_of_float f
  | String s -> s
  | Boolean b -> if b then "true" else "false"
  | List l -> string_of_list l string_of_value
  | Function _ -> "(function)"
  | BuiltinFunction _ -> "(built-in function)"
  | Module (s, _) -> "(module "^s^")"
  | Unit -> "()"


(* Regarde récursivement dans variables et dans ses parents. *)
let rec scope_lookup (variables: scope) (s: string) : value option =
  match Hashtbl.find_opt variables.variables s with
  | None ->
      begin match variables.parent with
      | None -> None
      | Some parent -> scope_lookup parent s
      end
  | Some x -> Some x


(* Copie un scope (i.e. garde le même parent et copie la hashtable) *)
let scope_copy (s: scope) : scope =
  {parent = s.parent; variables = Hashtbl.copy s.variables}


exception Undefined of string * int
exception IsNotModule of string * value * int
exception NotCallable of value * int

(*
 * Nom de la fonction, valeur renvoyée, message d’erreur, indice dans le texte
 *)
exception InvalidArgument of (string * value_without_pos option * string * int)

let print_error
    (error_name: string)
    (error_message: string)
    (index: int)
    (code: string) : unit =
  let line, idx_in_line, line_number = get_line_from_idx code index in
  Printf.eprintf "Erreur à la ligne %d :\n" line_number;
  Printf.eprintf "%s%s\n" (String.make 4 ' ') line;
  Printf.eprintf "%s%s\n" (String.make (4+idx_in_line) ' ') "^";
  (* Note : %! sert à flush *)
  Printf.eprintf "%s : %s (%d)\n%!" error_name error_message index;

