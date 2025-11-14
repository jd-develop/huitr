open Ast
open Huitr_utils


type value =
  | Integer of int
  | Float of float
  | String of string
  | List of value list
  | Function of ast list
  | BuiltinFunction of (value list -> value)
  | Module of string * scope
  | Unit
and scope = {
  parent: scope option;
  variables: (string, value) Hashtbl.t
}

exception Undefined of string
exception IsNotModule of string
exception NotCallable


(* Regarde récursivement dans variables et dans ses parents. *)
let rec scope_lookup (variables: scope) (s: string) : value option =
  match Hashtbl.find_opt variables.variables s with
  | None ->
      begin match variables.parent with
      | None -> None
      | Some parent -> scope_lookup parent s
      end
  | Some x -> Some x


(* Renvoie la valeur l1::l2::…::ln::s, ou lève IsNotModule si l’un des li
 * n’est pas un module. Lève Undefined si s n’est pas définie dans ln.
 * Si l est vide, regarde dans le scope.
 * current_module_expression est "l1::l2::…::l(i-1)::" si jamais on appelle
 * find_module_identifier sur li::l(i+1)::…::ln::s. *)
let rec find_module_identifier
    (l: string list) (s: string) (variables: scope)
    (current_module_expression: string):
    value =
  match l with
  | [] -> (* On a déjà regardé tous les modules *)
      begin match scope_lookup variables s with
      | None -> raise (Undefined (current_module_expression^s))
      | Some x -> x
      end
  | x::q ->
      begin match scope_lookup variables x with
      | None -> raise (Undefined (current_module_expression^s))
      | Some (Module (_, x)) ->
          find_module_identifier q s x (current_module_expression^s^"::")
      | Some _ -> raise (IsNotModule (current_module_expression^s))
      end


(* Renvoie la valeur de s. Lève une excecption Undefined si s n’est pas définie
 *)
let find_valiable (s: string) (variables: scope) : value =
  find_module_identifier [] s variables ""


let rec interpreter (input_ast: ast) (variables: scope) : value =
  match input_ast with
  | Vide | Unit -> Unit
  | Integer i -> Integer i
  | Float f -> Float f
  | String s -> String s
  | Function f -> Function f
  | Identifier s -> find_valiable s variables
  | ModuleIdentifier (l, s) -> find_module_identifier l s variables ""
  | Statements l -> interprete_statements l variables
  | List l -> interprete_list l variables
  | Chain l -> interprete_chain l variables

and interprete_statements (l: ast list) (variables: scope) : value =
  match l with
  | [] -> Unit
  | x::[] -> interpreter x variables
  | x::q -> let _ = interpreter x variables in interprete_statements q variables

and interprete_list (l: ast list) (variables: scope) : value =
  List (List.map (fun t -> interpreter t variables) l)

and interprete_chain (l: ast list) (variables: scope) : value =
  match l with
  | [] -> Unit
  | x::[] -> apply_function (interpreter x variables) (List []) variables
  | x::(Identifier s)::[] -> begin
      let v = interpreter x variables in
      match scope_lookup variables s with
      | None -> Hashtbl.add (variables.variables) s v; v
      | Some f -> apply_function f v variables
    end
  | x::y::[] -> begin
      let args = interpreter x variables in
      apply_function (interpreter y variables) args variables
  end
  | x::y::q -> interprete_chain ((Chain [x; y])::q) variables

(* Cette fonction s’occupe de créer un nouveau scope *)
and apply_function (fv: value) (x: value) (variables: scope) : value =
  match fv with
  | Function f -> begin
      let new_scope = {
        parent = Some variables;
        variables = Hashtbl.create 8
      } in
      match x with
      | List l -> apply_function_aux f l new_scope
      | _ -> apply_function_aux f [x] new_scope
    end
  | BuiltinFunction f -> begin
      match x with
      | List l -> f l
      | _ -> f [x]
    end
  | _ -> raise NotCallable

(* Le scope est supposé vide, avec le scope parent en parent *)
and apply_function_aux
    (f: ast list) (x: value list) (variables: scope) : value =
  Hashtbl.add variables.variables "args" (List x);
  interpreter (Statements f) variables


exception InvalidArgument


let rec print (l: value list) : value =
  match l with
  | [] -> Unit
  | [value] ->
      begin
      match value with
      | Integer i -> print_int i; print_newline (); Unit
      | Float f -> print_float f; print_newline (); Unit
      | String s -> print_endline s; Unit
      | List l -> print_list l (fun x -> let _ = print [x] in ()); Unit
      | Function _ -> print_endline "(function)"; Unit
      | BuiltinFunction _ -> print_endline "(built-in function)"; Unit
      | Module (s, _) -> print_endline ("(module "^s^")"); Unit
      | Unit -> print_endline "()"; Unit
      end
  | l -> print [List l]


let nth (l: value list) : value =
  match l with
  | [List l'; Integer i] ->
      begin
      match List.nth_opt l' i with
      | None -> raise InvalidArgument
      | Some x -> x
      end
  | _ -> raise InvalidArgument


let wrapper (t: ast) : value =
  let variables : scope = {parent = None; variables = Hashtbl.create 8} in
  Hashtbl.add variables.variables "print" (BuiltinFunction print);
  Hashtbl.add variables.variables "nth" (BuiltinFunction nth);
  interpreter t variables

