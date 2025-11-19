open Value_and_errors
open Io

let nth (l: value list) : value =
  match l with
  | [List l'; Integer i]
  | [Integer i; List l'] ->
      begin
      match List.nth_opt l' i with
      | None -> raise (InvalidArgument("nth", Some (Integer i), "invalid index"))
      | Some x -> x
      end
  | _ -> raise (InvalidArgument("nth", Some (List l), "not a list"))


let len (l: value list) : value =
  Integer (List.length l)


let is_empty (l: value list) : value =
  match l with
  | [] -> Boolean true
  | _ -> Boolean false


(* construire *)
let cons (l: value list) : value =
  match l with
  | [v; List l'] -> List (v::l')
  | _ -> raise (InvalidArgument("cons", Some (List l), "second arg should be list"))


let head (l: value list) : value =
  match l with
  | [] -> raise (InvalidArgument("head", Some (List []), "empty list"))
  | x::q -> x


let tail (l: value list) : value =
  match l with
  | x::q -> List q
  | [] -> raise (InvalidArgument("tail", Some (List []), "empty list"))


let create_module_list () : value =
  let list = Hashtbl.create 8 in
  Hashtbl.add list "nth" (BuiltinFunction nth);
  Hashtbl.add list "len" (BuiltinFunction len);
  Hashtbl.add list "is_empty" (BuiltinFunction is_empty);
  Hashtbl.add list "cons" (BuiltinFunction cons);
  Hashtbl.add list "head" (BuiltinFunction head);
  Hashtbl.add list "tail" (BuiltinFunction tail);

  (* CONSTANTES *)
  Hashtbl.add list "empty" (List []);
  Module("list", list)

