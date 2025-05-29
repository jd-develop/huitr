(*
Huitr - a purely functional programming language.
Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*)

type lexer_type = {
    source : string;
    mutable cursor_pos : Position.position;
    mutable tokens : Token.token list;
}

let create_lexer
    (_filename : string option)
    (_source : string)
    : lexer_type =
    {
        source = _source;
        cursor_pos = Position.create_position
            _filename
            _source
            0
            0
            0
        ;
        tokens = [];
    }

let current_char
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
    Arguments:
        token_type: type of the new token
        token_value (optional): the token value
        index_start (optional): the index in the line at which the token begins. Defaults to self.cursor_pos if ommited.
        index_end (optional): the index in the line at which the token ends. Defaults to self.cursor_pos if ommited.
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
                then new_token lexer Float_token ?token_value:(Some (F (float_of_string !number))) ?start_index:(Some (Some start_pos))
                else new_token lexer Int_token ?token_value:(Some (I (int_of_string !number))) ?start_index:(Some (Some start_pos))

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
