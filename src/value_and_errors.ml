open Ast

type value =
  | Integer of int
  | Float of float
  | String of string
  | Boolean of bool
  | List of value list
  | Function of (ast list * scope)
  | BuiltinFunction of (value list -> value)
  | Module of string * (string, value) Hashtbl.t
  | Unit
and scope = {
  parent: scope option;
  variables: (string, value) Hashtbl.t
}

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


exception Undefined of string
exception IsNotModule of string
exception NotCallable of value

(* Nom de la fonction, valeur renvoyée, message d’erreur *)
exception InvalidArgument of (string * value option * string)

