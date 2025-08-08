(*
 * Huitr - a purely functional programming language.
 * Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)

(*
 * Cette fonction transforme une chaîne de caractères en liste de caractères.
 * C’est l’exact opposé de `implode`.
 *)
let explode (s: string) : char list =
  List.of_seq (String.to_seq s)


(*
 * Cette fonction transforme une liste de caractères en chaîne de caractères.
 * C’est l’exact opposé de `explode`.
 *)
let implode (l: char list) =
  String.of_seq (List.to_seq l)


type unfinished_or_finished_token =
  | Unfinished of char list
  | Finished of Token.t


(* Continue de traiter un lexème en cours de traitement.
 * Traite le caractère `current_char` sachant que le lexème courant est
 * de type `current_tok_type` et que pour l’instant, le lexème est
 * `current_tok` (dans l’ordre inverse)
 * Renvoie un token (fini ou non) et la nouvelle position courante.
 *)
let continue_token
    (current_char: char)
    (current_tok_type: Token.token_type)
    (current_tok: char list)
    (start_pos: Position.t)
    (current_pos: Position.t)
    : (unfinished_or_finished_token * Position.t) =
  match current_tok_type with
  | String (* TODO *)
  | Int (* TODO *)
  | Float (* TODO *)
  | Identifier (* TODO *)
  | Namesp (* TODO *)
  | _ -> Finished {
           own_type = current_tok_type;
           value = None;
           start_pos = start_pos;
           end_pos = current_pos;
         }, current_pos


(* Créée une liste de lexèmes à partir d’une liste de caractères d’entrée.
 * * `source` est la liste de caractères d’entrée. Elle pert son premier
 *   élément à chaque appel récursif au fur et à mesure de l’analyse lexicale
 * * `source_string` est l’entrée sous forme de chaîne de caractères. C’est une
 *   constante utilisée pour construire des Position.t
 * * `already_tokenize` est la liste des lexèmes créés. Note : cette liste est
 *   dans l’ordre inverse
 * * `currently_registering` est à true si l’état de l’analyseur est « en train
 *   d’analyser un lexème » et à false dans l’état « attente de nouveau lexème »
 * * `current_tok_type` est le type du lexème courant (si
 *   `currently_registering` est à true)
 *   note : EOF signifie qu’on est en train de lire une espace insécable
 * * `current_tok` est le lexème courant (si `currently_registering` est à true)
 *   Note : cette liste est dans l’ordre inverse
 *
 * Notes : dans le doute pour `current_tok_type`, on choisira le type le + large
 * (int au lieu de float, identifier au lieu de keyword), et on ajuste dès
 * qu’on a assez d’information pour déterminer dans quel cas on se situe.
 *)
let rec tokenize_aux
    (source: char list)
    (source_string: string)
    (already_tokenized: Token.t list)
    (currently_registering: bool)
    (current_tok_type: Token.token_type option)
    (current_tok: char list)
    (current_tok_start_pos_option: Position.t option)
    (current_pos: Position.t)
    : (Token.t list, Huitr_error.t) Result.t =

  match source with
  | [] -> Ok(already_tokenized)
  | x::q ->

    if currently_registering then

      match current_tok_type with
      | Some tt ->
        let current_tok_start_pos = (
          match current_tok_start_pos_option with
          | Some pos -> pos
          | None -> failwith (
              "Tokenize: erreur : currently_registering est à true mais " ^
              "current_tok_start_pos_option est à None"
            )
        ) in
        let tok_result, new_pos =
          continue_token x tt current_tok current_tok_start_pos current_pos
        in
        begin match tok_result with
        | Finished t ->
            tokenize_aux q source_string (t::already_tokenized) false None []
                         None new_pos
        | Unfinished l ->
            tokenize_aux q source_string already_tokenized true current_tok_type
                         l (Some current_tok_start_pos) new_pos
        end
      | None -> failwith (
          "Tokenize : erreur : currently_registering est à true mais " ^
          "current_tok_type est à None"
        )

    else
      (* TODO *)
      failwith "not implemented"
      (*
      let new_tok: Token.t = {
        own_type = Identifier;
        value = S (String.make 1 x);
        start_pos = Position.create_position None source_string 0 0 0;
        end_pos = Position.create_position None source_string 0 0 0
      }
      in tokenize_aux q source_string (new_tok::already_tokenized) false None [] None current_pos
      *)
      (* else if x = ' ' || x = '\n' || x = '\t' then
        tokenize_aux q source_string already_tokenized false None []
      else if x = '\194' then (* nbsp *)
        tokenize_aux q source_string already_tokenized true (Some EOF) ['\194']
      else if (
        x = '\160' &&
        currently_registering = true &&
        current_tok_type = Some EOF &&
        current_tok = ['\194']
      ) then (* nbsp second char *)
        tokenize_aux q source_string already_tokenized false None []
      else if x = '\226' then (* nnbsp *)
        tokenize_aux q source_string already_tokenized true (Some EOF) ['\226']
      else if (
        x = '\128' &&
        currently_registering = true &&
        current_tok_type = Some EOF &&
        current_tok = ['\226']
      ) then (* nnbsp second char *)
        tokenize_aux q source_string already_tokenized true (Some EOF) ['\226'; '\128']
      else if (
        x = '\175' &&
        currently_registering = true &&
        current_tok_type = Some EOF &&
        current_tok = ['\226'; '\128']
      ) then (* nnbsp third char *)
        tokenize_aux q source_string already_tokenized false None [] *)


let tokenize (source : string) : (Token.token list, Huitr_error.t) Result.t =
  let pos = Position.create_position (Some "TODO filename") source 0 0 0 in
  match tokenize_aux (explode source) source [] false None [] None pos with
  | Ok(l) -> Ok(List.rev l)
  | Error(e) -> Error(e)


(*let current_char
    (lexer : lexer_type)
    : char option =
    Position.get_char lexer.cursor_pos

let next
    (lexer : lexer_type)
    : unit =
    Position.advance lexer.cursor_pos 1

let get_next_char
    (lexer : lexer_type)
    : char option =
    if lexer.cursor_pos.index + 1 >= String.length lexer.source
        then None
        else Some lexer.source.[lexer.cursor_pos.index + 1]

let new_token
    ?(token_value : Token.huitr_value = None)
    ?(start_index : Position.position option = None)
    ?(end_index : Position.position option = None)
    (lexer : lexer_type)
    (tt : Token.token_type)
    : unit =
    (*
     * Arguments:
     *  tt (token type): type of the new token
     *  token_value (optional): the token value
     *  index_start (optional): the index in the line at which the token begins.
     *                          Defaults to self.cursor_pos if ommited.
     *  index_end (optional): the index in the line at which the token ends.
     *                        Defaults to self.cursor_pos if ommited.
     *)
    lexer.tokens <- {
        own_type = tt;
        value = token_value;
        start_pos = (match start_index with
            | None -> Position.copy_position lexer.cursor_pos
            | Some(p) -> p);
        end_pos = (match end_index with
            | None -> Position.copy_position lexer.cursor_pos
            | Some(p) -> p);
    } :: lexer.tokens
*)
(*
let rec tokenize
    (lexer : lexer_type)
    : (Token.token list) * (Huitr_error.huitr_error option) =
    (* Create tokens *)
    let tokenize_error : Huitr_error.huitr_error option ref = ref None in

    match current_char lexer with
    | None -> lexer.tokens, None
    | Some(current_c) -> begin
        let start_pos = Position.copy_position lexer.cursor_pos in

        if current_c = ' ' || current_c = '\n' || current_c = '\t' then next lexer (* FIXME : add \N{NSBP} and \N{NSBP} *)
        else if current_c = '(' then new_token lexer Lparen
        else if current_c = ')' then new_token lexer Rparen
        else if current_c = '[' then new_token lexer Lsquare
        else if current_c = ']' then new_token lexer Rsquare
        else if current_c = '>' then new_token lexer Chainop
        else if current_c = ',' then new_token lexer Comma
        else if current_c = ';' then new_token lexer Semicolon

        else if current_c = '.' then begin (* Comments *)
            next lexer;
            match current_char lexer with
            | None -> ()
            | Some(current_cc) ->
                if current_cc = '.'
                then begin
                    while not (
                        let c = current_char lexer in
                        c = get_next_char lexer && c = Some('.') && !tokenize_error = None) do
                        next lexer;
                        if current_char lexer = None
                            then tokenize_error := Some(Huitr_error.huitr_syntax_error "Unclosed multi-line comment" lexer.cursor_pos)
                    done;
                    next lexer (* Multi-line comments ends with .. (double dot) *)
                end else
                    while current_char lexer <> Some('\n') do
                        next lexer;
                    done
        end

        else if current_c = ':' then
            if get_next_char lexer <> Some(':')
                then tokenize_error := Some((Huitr_error.huitr_syntax_error "incorrect use of `:`" lexer.cursor_pos))
            else begin
                let start_pos : Position.position = Position.copy_position lexer.cursor_pos in
                next lexer;
                new_token lexer Namesp ?start_index:(Some(Some start_pos))
            end

        else if (Utils.is_digit current_c) (* int / float *)
            (* FIXME: Change comment symbol to make float starting with a period to work *)
            then
            let number : string ref = ref (String.make 1 current_c) in
            let last_was_e : bool ref = ref false in
            let seen_e : bool ref = ref false in
            let seen_dot : bool ref = ref false in
            let current_cc : char ref = ref current_c in

            while ( match get_next_char lexer with
                | None -> false
                | Some(c) ->
                    current_cc := c;
                    ( Utils.is_digit c && c = 'e' )
                    || ( c = '-' && !last_was_e )
                ) do
                next lexer;

                if !current_cc = '.' then begin
                    if !seen_dot
                        then tokenize_error := Some(Huitr_error.huitr_syntax_error "a number can not have more than one dot" lexer.cursor_pos);
                    if !seen_e
                        then tokenize_error := Some(Huitr_error.huitr_syntax_error "exponent of scientific notation should be an integer, not a float" lexer.cursor_pos);
                    seen_dot := true;
                end;

                number := (!number ^ String.make 1 current_c);
                last_was_e := !current_cc = 'e' || !current_cc = 'E';
                seen_e := !seen_e || !last_was_e
            done;

            if !seen_e || !seen_dot
                then new_token lexer Float ?token_value:(Some (F (float_of_string !number))) ?start_index:(Some (Some start_pos))
                else new_token lexer Int ?token_value:(Some (I (int_of_string !number))) ?start_index:(Some (Some start_pos))

        (* Identifier (no reserved keywords in this language) *)
        else if Utils.is_char_identifier current_c
            then
            let identifier : string ref = ref (String.make 1 current_c) in
            let current_cc : char ref = ref current_c in

            while (match get_next_char lexer with
                | None -> false
                | Some(c) ->
                    current_cc := c;
                    Utils.is_char_identifier c || Utils.is_digit c
                ) do
                next lexer;
                identifier := !identifier ^ (String.make 1 !current_cc)
            done;

            new_token lexer Identifier ?token_value:(Some (S (!identifier))) ?start_index:(Some (Some start_pos))

        else if current_c = '"' (* Huitr string *)
            then
            let hstr : string ref = ref (String.make 1 current_c) in
            let current_cc : char ref = ref current_c in

            while (match get_next_char lexer with
                | None -> false
                | Some(c) ->
                    current_cc := c;
                    c <> '"'
                ) do
                next lexer;
                hstr := !hstr ^ (String.make 1 !current_cc)
            done;

            match get_next_char lexer with
            | None -> tokenize_error := Some(Huitr_error.huitr_syntax_error "\" was never closed" lexer.cursor_pos)
            | Some(_) -> next lexer

        else tokenize_error := Some(Huitr_error.huitr_syntax_error ("unexpected char" ^ String.make 1 current_c) lexer.cursor_pos);

        match !tokenize_error with
        | None -> tokenize lexer
        | Some(_) -> [], !tokenize_error
    end
*)
