open Tipe.Grammar_grammar
open Tipe.Parser
open Tipe.Lexer

let huitr_grammar = {|
# Même format de fichier que https://github.com/MP2I-Fermat/tipe-spe-jd-mylo/
# L’axiome de cette grammaire est STATEMENTS

ident := [A-Za-z][A-Za-z0-9_]*

integer_literal := -?([0-9]+|(0[xX][0-9A-Fa-f]+)|(0[oO][0-7]+)|(0[bB][0-1]+))
float_literal := -?[0-9]+(.[0-9]*)?([eE][\+-]?[0-9]+)?

string_literal := "([ !$-~]|(\\"))*"

whitespace := ( |\t)+

simple_comment_start := .
multi_comment_start := ..

newline := ;|\n
comma := ,
lparen := \(
rparen := \)
lsquare := \[
rsquare := \]
chainop := >
namesp := ::

STATEMENTS -> newline
STATEMENTS -> newline STATEMENTS
STATEMENTS -> CHAIN newline STATEMENTS
STATEMENTS -> CHAIN newline
STATEMENTS -> CHAIN

LIST -> CHAIN comma ATOM
LIST -> LIST comma ATOM
LIST -> CHAIN comma newline ATOM
LIST -> LIST comma newline ATOM

CHAINOPATOM -> chainop ATOM
CHAINOPATOM -> chainop ATOM CHAINOPATOM

CHAIN -> CHAINOPATOM
CHAIN -> LIST CHAINOPATOM
CHAIN -> ATOM CHAINOPATOM
CHAIN -> ATOM

ATOM -> string_literal
ATOM -> integer_literal
ATOM -> float_literal
ATOM -> IDENTIFIER
ATOM -> FUNCTION
ATOM -> lparen CHAIN rparen
ATOM -> UNIT

NAMESPIDENT -> namesp ident
NAMESPIDENT -> namesp ident NAMESPIDENT

IDENTIFIER -> ident
# je crois que la ligne suivante est incorrecte, dans le doute je ne fais que
# la commenter
# IDENTIFIER -> NAMESPIDENT
IDENTIFIER -> ident NAMESPIDENT

FUNCTION -> lsquare STATEMENTS rsquare

UNIT -> lparen rparen

unrecognizable := [ -~]
|}

let token_rules, rules = parse_grammar huitr_grammar

let automaton = construit_automate_LR1 rules "STATEMENTS" "EOF"

let code_fp = open_in "/home/jddev/Documents/GitHub/huitr/examples/test.8tr"

let code = really_input_string code_fp (in_channel_length code_fp)

let parse_huitr (code: string): (string, string) syntax_tree =
  let tokens_with_comments =
    tokenize token_rules "EOF" code
    |> List.filter (fun t -> not (t.token_type = "whitespace")) in
  let rec filter_tokens l (in_simple_comment: bool) (in_multi_comment: bool) accu =
    let in_comment = in_simple_comment || in_multi_comment in
    match l with
    | [] -> List.rev accu
    | t::q when t.token_type = "simple_comment_start" && not in_comment ->
        filter_tokens q true false accu
    | t::q when t.token_type = "newline" && in_simple_comment ->
        filter_tokens q false false accu
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

