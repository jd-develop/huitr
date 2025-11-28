open Ast
open Huitr_utils
open Value_and_errors
open Math
open Comp
open Bool
open Tests_
open Io
open List_
open String_

(* Renvoie la valeur l1::l2::…::ln::s, ou lève IsNotModule si l’un des li
 * n’est pas un module. Lève Undefined si s n’est pas définie dans ln.
 * Si l est vide, regarde dans le scope.
 * current_module_expression est "l1::l2::…::l(i-1)::" si jamais on appelle
 * find_module_identifier sur li::l(i+1)::…::ln::s. *)
let rec find_module_identifier
    (l: string list) (s: string) (variables: scope)
    (current_module_expression: string) (pos: int):
    value =
  match l with
  | [] -> (* On a déjà regardé tous les modules *)
      begin match scope_lookup variables s with
      | None -> raise (Undefined (current_module_expression^s, pos))
      | Some x -> fst x, pos
      end
  | x::q ->
      begin match scope_lookup variables x with
      | None -> raise (Undefined (current_module_expression^x, pos))
      | Some (Module (_, v), _) ->
          let new_scope = {parent = None; variables = v} in
          let new_module_expr = current_module_expression^x^"::" in
          find_module_identifier q s new_scope new_module_expr pos
      | Some v -> raise (IsNotModule (current_module_expression^x, v, pos))
      end


(* Renvoie la valeur de s. Lève une excecption Undefined si s n’est pas définie
 *)
let find_variable (s: string) (variables: scope) (pos: int) : value =
  find_module_identifier [] s variables "" pos


let rec interpreter_was_list (input_ast: ast) (variables: scope)
    (recursion_depth: int) : value * bool =
  match input_ast with
  | Vide(p) | Unit(p) -> (Unit, p), false
  | Integer(i, p) -> (Integer i, p), false
  | Float(f, p) -> (Float f, p), false
  | String(s, p) -> (String s, p), false
  | Function(f, p) -> (Function (f, variables), p), false
  | Identifier(s, p) -> (find_variable s variables p), false
  | ModuleIdentifier (l, s, p) ->
      (find_module_identifier l s variables "" p), false
  | Statements(l, p) -> (interprete_statements l variables p recursion_depth), false
  | List(l, p) -> (interprete_list l variables p recursion_depth), true
  | Chain(l, p) -> interprete_chain l variables p recursion_depth, false
  | InsideParenthesis(a, p) -> interpreter a variables recursion_depth, false


and interpreter (input_ast: ast) (variables: scope) (recursion_depth: int)
    : value =
  fst (interpreter_was_list input_ast variables recursion_depth)

and interprete_statements (l: ast list) (variables: scope)
    (pos: int) (recursion_depth: int) : value =
  match l with
  | [] -> Unit, pos
  | x::[] -> interpreter x variables recursion_depth
  | x::q ->
      let _ = interpreter x variables recursion_depth in
      interprete_statements q variables pos recursion_depth

and interprete_list (l: ast list) (variables: scope) (pos: int)
    (recursion_depth: int): value =
  List (List.map (fun t -> interpreter t variables recursion_depth) l), pos

and interprete_chain (l: ast list) (variables: scope) (pos: int)
    (recursion_depth: int) : value =
  match l with
  | [] -> Unit, pos
  | x::[] ->
      apply_function
        (interpreter x variables recursion_depth) (List [], pos) variables true
        (recursion_depth+1)
  | Vide(v_pos)::(Identifier(s, id_pos))::[] -> begin
      match scope_lookup variables s with
      | None -> raise (Undefined(s, id_pos))
      | Some f -> apply_function (fst f, id_pos) (List [], v_pos) variables
                                 true (recursion_depth+1)
    end
  | x::(Identifier(s, id_pos))::[] -> begin
      let v, was_list = interpreter_was_list x variables recursion_depth in
      match scope_lookup variables s with
      | None -> Hashtbl.add (variables.variables) s v; v
      | Some f -> apply_function (fst f, id_pos) v variables was_list
                                 (recursion_depth+1)
    end
  | Vide(v_pos)::y::[] ->
      apply_function
        (fst (interpreter y variables recursion_depth), pos_start y)
        (List [], v_pos) variables true (recursion_depth+1)
  | x::y::[] ->
      let args, was_list = interpreter_was_list x variables recursion_depth in
      apply_function
        (fst (interpreter y variables recursion_depth), pos_start y) args
        variables was_list (recursion_depth+1)
  | x::y::q -> interprete_chain ((Chain([x; y], pos))::q) variables pos
               recursion_depth

(* Cette fonction s’occupe de créer un nouveau scope. recursion_depth est la
 * profondeur de *cet appel*. *)
and apply_function (fv: value) (x: value) (variables: scope) (was_list: bool)
    (recursion_depth: int) : value =
  if recursion_depth = 60000 then
    raise(RecursionDepthExceeded (snd fv));
  match fv with
  | Function (f, outer_scope), f_pos -> begin
      let new_scope = {
        parent = Some outer_scope;
        variables = Hashtbl.create 8
      } in
      match x with
      | List l, list_pos ->
          apply_function_aux
            f (if was_list then l else [List l, list_pos])
            new_scope f_pos list_pos recursion_depth
      | _, args_pos -> apply_function_aux f [x] new_scope f_pos args_pos
                                          recursion_depth
    end
  | BuiltinFunction f, f_pos -> begin
      match x with
      | List l, list_pos -> f (if was_list then l else [List l, list_pos]) f_pos
      | _ -> f [x] f_pos
    end
  | _, f_pos -> raise (NotCallable(fv, f_pos))

(* Le scope est supposé vide, avec le scope parent en parent. recursion_depth
 * est la profondeur de *cet appel*. *)
and apply_function_aux
    (f: ast list) (x: value list) (variables: scope) (fun_pos: int)
    (args_pos: int) (recursion_depth: int) : value =
  Hashtbl.add variables.variables "args" (List x, args_pos);
  interpreter (Statements(f, fun_pos)) variables recursion_depth


let create_scope () : scope =
  let variables : scope = {parent = None; variables = Hashtbl.create 8} in
  let std = Hashtbl.create 8 in
  Hashtbl.add std "math" (create_module_math ());
  Hashtbl.add std "comp" (create_module_comp ());
  Hashtbl.add std "bool" (create_module_bool ());
  Hashtbl.add std "tests" (create_module_tests ());
  Hashtbl.add std "io" (create_module_io ());
  Hashtbl.add std "list" (create_module_list ());
  Hashtbl.add std "string" (create_module_string ());
  Hashtbl.add variables.variables "std" (Module ("std", std), 0);
  variables

