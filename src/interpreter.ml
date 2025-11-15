open Ast
open Huitr_utils
open Value_and_errors
open Math
open Comp
open Bool
open Tests_
open Io
open List_

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
      | None -> raise (Undefined (current_module_expression^x))
      | Some (Module (_, v)) ->
          let new_scope = {parent = None; variables = v} in
          let new_module_expr = current_module_expression^x^"::" in
          find_module_identifier q s new_scope new_module_expr
      | Some _ -> raise (IsNotModule (current_module_expression^x))
      end


(* Renvoie la valeur de s. Lève une excecption Undefined si s n’est pas définie
 *)
let find_variable (s: string) (variables: scope) : value =
  find_module_identifier [] s variables ""


let rec interpreter (input_ast: ast) (variables: scope) : value =
  match input_ast with
  | Vide | Unit -> Unit
  | Integer i -> Integer i
  | Float f -> Float f
  | String s -> String s
  | Function f -> Function (f, variables)
  | Identifier s -> find_variable s variables
  | ModuleIdentifier (l, s) ->
      find_module_identifier l s variables ""
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
  | Function (f, outer_scope) -> begin
      let new_scope = {
        parent = Some outer_scope;
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
  | _ -> raise (NotCallable(fv))

(* Le scope est supposé vide, avec le scope parent en parent *)
and apply_function_aux
    (f: ast list) (x: value list) (variables: scope) : value =
  Hashtbl.add variables.variables "args" (List x);
  interpreter (Statements f) variables


let wrapper (t: ast) : value =
  let variables : scope = {parent = None; variables = Hashtbl.create 8} in
  let std = Hashtbl.create 8 in
  Hashtbl.add std "math" (create_module_math ());
  Hashtbl.add std "comp" (create_module_comp ());
  Hashtbl.add std "bool" (create_module_bool ());
  Hashtbl.add std "tests" (create_module_tests ());
  Hashtbl.add std "io" (create_module_io ());
  Hashtbl.add std "list" (create_module_list ());
  Hashtbl.add variables.variables "std" (Module ("std", std));
  try
  interpreter t variables
  with
  | NotCallable(f) -> print_string "not callable : "; print [f]
  | InvalidArgument(func, value, errmsg) ->
      print_endline ("invalid argument in function "^func^", with message "^errmsg);
      Unit

