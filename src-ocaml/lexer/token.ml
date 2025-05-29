(*
Huitr - a purely functional programming language.
Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*)

type token_type =
    | Lparen (* ( *)
    | Rparen (* ) *)
    | Lsquare (* [ *)
    | Rsquare (* ] *)
    | Chainop (*  *)
    | Comma (* , *)
    | Semicolon (* ; *)
    | String_token
    | Int_token
    | Float_token
    | Identifier
    | Namesp (* :: *)
    | Eof


type huitr_value =
    | S of string
    | I of int
    | F of float
    | None

(*
let (=)
    (val1 : huitr_value)
    (val2 : huitr_value)
    : bool =
    match (val1, val2) with
    | S(str1), S(str2) -> str1 = str2
    | I(int1), I(int2) -> int1 = int2
    | F(float1), F(float2) -> float1 = float2
    | None, None -> true
    | _ -> false;;
*)


type token = {
    own_type : token_type;
    value : huitr_value;
    start_pos : Position.position;
    end_pos : Position.position;
}

let matches
    (t : token)
    (tt : token_type)
    (v : huitr_value)
    : bool =
    t.own_type = tt && t.value = v

let print_token
    (t : token)
    : unit =
    print_string (match t.own_type with
        | Lparen -> "LPAREN"
        | Rparen -> "RPAREN"
        | Lsquare -> "LSQUARE"
        | Rsquare -> "RSQUARE"
        | Chainop -> "CHAINOP"
        | Comma -> "COMMA"
        | Semicolon -> "SEMICOLON"
        | String_token -> "STRING"
        | Int_token -> "INT"
        | Float_token -> "FLOAT"
        | Identifier -> "IDENTIFIER"
        | Namesp -> "NAMESP"
        | Eof -> "EOF");
    match t.value with
    | S(s) -> print_string (":" ^ s)
    | I(i) -> print_string ":"; print_int i
    | F(f) -> print_string ":"; print_float f
    | None -> ()
