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

type interpreter_state = {recursion_depth : int; call_stack : (int * int) list;}

let create_state () : interpreter_state =
  {recursion_depth = 0; call_stack = []}

let stack_call (idx' : int) (current_state : interpreter_state) : interpreter_state =
  let next_call_stack = 
    match current_state.call_stack with
    | (x, n)::q -> if x = idx' then (x, n+1)::q else (idx', 1)::current_state.call_stack
    | [] -> [(idx', 1)]
  in
  {
    recursion_depth = current_state.recursion_depth + 1;
    call_stack = next_call_stack
  }

let rec string_of_value (v: value) : string =
  match fst v with
  | Integer i -> string_of_int i
  | Float f -> string_of_float f
  | String s -> ("\"" ^ (String.escaped s) ^ "\"")
  | Boolean b -> if b then "true" else "false"
  | List l -> string_of_list l string_of_value
  | Function _ -> "(function)"
  | BuiltinFunction _ -> "(built-in function)"
  | Module (s, _) -> "(module "^s^")"
  | Unit -> "()"


(* Affiche les str sans guillemets ni escape chars, mais lors d’appels
 * récursifs (listes, …), affiche et les guillemets et les escape chars *)
let string_of_value_for_printing (v: value) : string =
  match fst v with
  | String s -> s
  | _ -> string_of_value v


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
exception RecursionDepthExceeded of int
exception SysError of string * int
exception DivisionByZero of int

(*
 * Nom de la fonction, valeur renvoyée, message d’erreur, indice dans le texte
 *)
exception InvalidArgument of (string * value_without_pos option * string * int)

type interpretation_error =
| Undefined of string * int * interpreter_state
| IsNotModule of string * value * int * interpreter_state
| NotCallable of value * int * interpreter_state
| RecursionDepthExceeded of int * interpreter_state
| SysError of string * int * interpreter_state
| DivisionByZero of int * interpreter_state
| InvalidArgument of (string * value_without_pos option * string * int * interpreter_state)

exception InterpretationError of interpretation_error

(* affiche l'entièreté de l'arbre d'appel (sauf le dernier pour éviter la redondance) *)
let print_call_tree (code : string) (error_state: interpreter_state) : unit =
  let rec print_call_tree_aux (tree : (int*int) list) : unit =
    match tree with
    | (index, times_called)::q ->
      let line, idx_in_line, line_number = get_line_from_idx code index in
      Printf.eprintf "Dans \"%s\", ligne %d\n" line line_number;
      if times_called > 1 then
        Printf.eprintf "    ... %d fois de plus\n" (times_called-1);
      print_call_tree_aux q
    | _ -> ()
  in
  print_call_tree_aux (List.rev error_state.call_stack)

let print_error
    (error_name: string)
    (error_message: string)
    (index: int)
    (code: string)
    (return_state : interpreter_state option) : unit =
  let line, idx_in_line, line_number = get_line_from_idx code index in
  let error_state = 
    match return_state with
    | None -> create_state ()
    | Some s -> s
  in
  print_call_tree code error_state;
  Printf.eprintf "Erreur à la ligne %d :\n" line_number;
  Printf.eprintf "%s%s\n" (String.make 4 ' ') line;
  Printf.eprintf "%s%s\n" (String.make (4+idx_in_line) ' ') "^";
  (* Note : %! sert à flush *)
  Printf.eprintf "%s : %s (%d)\n%!" error_name error_message index;

