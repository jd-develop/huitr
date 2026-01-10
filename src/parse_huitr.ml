open Tipe.Grammar_grammar
open Tipe.Parser
open Tipe.Lexer

let huitr_grammar = {|
# Même format de fichier que https://github.com/MP2I-Fermat/tipe-spe-jd-mylo/
# L'axiome de cette grammaire est STATEMENTS

ident := [A-Za-z_][A-Za-z0-9_]*

integer_literal := -?([0-9]+|(0[xX][0-9A-Fa-f]+)|(0[oO][0-7]+)|(0[bB][0-1]+))
float_literal := -?[0-9]+(.[0-9]*)?([eE][\+-]?[0-9]+)?

# caractères supportés : àâçéèêëîïôöùûüÿæœÀÂÇÉÈÊËÎÏÔÖÙÛÜŸÆŒ’ + espace insécable + espace fine insécable
string_literal := "([ !$-\[\]-~\u00e0\u00e2\u00e7\u00e9\u00e8\u00ea\u00eb\u00ee\u00ef\u00f4\u00f6\u00f9\u00fb\u00fc\u00ff\u00e6\u0153\u00c0\u00c2\u00c7\u00c9\u00c8\u00ca\u00cb\u00ce\u00cf\u00d4\u00d6\u00d9\u00db\u00dc\u0178\u00c6\u0152\u2019\u00a0\u202f]|(\\[\\"ntbr])|(\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]))*"
multiline_string_literal := """(("|"")?([ !$-\[\]-~\n\u00e0\u00e2\u00e7\u00e9\u00e8\u00ea\u00eb\u00ee\u00ef\u00f4\u00f6\u00f9\u00fb\u00fc\u00ff\u00e6\u0153\u00c0\u00c2\u00c7\u00c9\u00c8\u00ca\u00cb\u00ce\u00cf\u00d4\u00d6\u00d9\u00db\u00dc\u0178\u00c6\u0152\u2019\u00a0\u202f]|(\\[\\"ntbr])|(\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))*"""

whitespace := ( |\t)+

simple_comment_start := .
multi_comment_start := ..

newline := \n
semicolon := ;
comma := ,
lparen := \(
rparen := \)
lsquare := \[
rsquare := \]
chainop := >
namesp := ::

NEWLINE -> newline
NEWLINE -> semicolon

STATEMENTS -> NEWLINE
STATEMENTS -> NEWLINE STATEMENTS
STATEMENTS -> CHAIN NEWLINE STATEMENTS
STATEMENTS -> CHAIN NEWLINE
STATEMENTS -> CHAIN
STATEMENTS -> LIST NEWLINE STATEMENTS
STATEMENTS -> LIST NEWLINE
STATEMENTS -> LIST

ANY_AMOUNT_OF_NEWLINE -> NEWLINE
ANY_AMOUNT_OF_NEWLINE -> NEWLINE ANY_AMOUNT_OF_NEWLINE

LIST -> CHAIN comma ATOM
LIST -> LIST comma ATOM
LIST -> CHAIN comma ANY_AMOUNT_OF_NEWLINE ATOM
LIST -> LIST comma ANY_AMOUNT_OF_NEWLINE ATOM

CHAINOPATOM -> chainop ATOM
CHAINOPATOM -> chainop ATOM CHAINOPATOM

CHAIN -> CHAINOPATOM
CHAIN -> LIST CHAINOPATOM
CHAIN -> ATOM CHAINOPATOM
CHAIN -> ATOM

ATOM -> string_literal
ATOM -> multiline_string_literal
ATOM -> integer_literal
ATOM -> float_literal
ATOM -> IDENTIFIER
ATOM -> FUNCTION
ATOM -> lparen CHAIN rparen
ATOM -> lparen LIST rparen
ATOM -> lparen ANY_AMOUNT_OF_NEWLINE CHAIN rparen
ATOM -> lparen ANY_AMOUNT_OF_NEWLINE LIST rparen
ATOM -> lparen CHAIN ANY_AMOUNT_OF_NEWLINE rparen
ATOM -> lparen LIST ANY_AMOUNT_OF_NEWLINE rparen
ATOM -> lparen ANY_AMOUNT_OF_NEWLINE CHAIN ANY_AMOUNT_OF_NEWLINE rparen
ATOM -> lparen ANY_AMOUNT_OF_NEWLINE LIST ANY_AMOUNT_OF_NEWLINE rparen
ATOM -> UNIT

NAMESPIDENT -> namesp ident
NAMESPIDENT -> namesp ident NAMESPIDENT

IDENTIFIER -> ident
IDENTIFIER -> ident NAMESPIDENT

FUNCTION -> lsquare STATEMENTS rsquare
FUNCTION -> lsquare rsquare

UNIT -> lparen rparen
UNIT -> lparen ANY_AMOUNT_OF_NEWLINE rparen
|}

let token_rules, rules = parse_grammar huitr_grammar

let automaton = construit_automate_LR1 rules "STATEMENTS" "EOF"

let parse_huitr (code: string): (string, string) syntax_tree =
  let tokens_with_comments =
    tokenize token_rules "EOF" "unrecognizable" code
    |> List.filter (fun t -> not (t.token_type = "whitespace")) in
  let rec filter_tokens l (in_simple_comment: bool) (in_multi_comment: bool) accu =
    let in_comment = in_simple_comment || in_multi_comment in
    match l with
    | [] ->
        begin match accu with
        | [] -> [{token_type="newline"; value="\n"; start=0; length=1};
                 {token_type="EOF"; value=""; start=1; length=0}]
        | t::q when t.token_type <> "EOF" ->
            List.rev (
              {token_type="EOF"; value=""; start=t.start+1; length=0}::accu
            )
        | _ -> List.rev accu
        end
    | t::q when t.token_type = "simple_comment_start" && not in_comment ->
        filter_tokens q true false accu
    | t::q when t.token_type = "newline" && in_simple_comment ->
        filter_tokens q false false (t::accu)
    | t::q when t.token_type = "multi_comment_start" && not in_comment ->
        filter_tokens q false true accu
    | t::q when t.token_type = "multi_comment_start" && in_multi_comment ->
        filter_tokens q false false accu
    | t::q ->
        if in_comment then
          filter_tokens q in_simple_comment in_multi_comment accu
        else
          filter_tokens q false false (t::accu)
  in
  let tokens = filter_tokens tokens_with_comments false false [] in
  parse automaton "EOF" tokens "STATEMENTS"

