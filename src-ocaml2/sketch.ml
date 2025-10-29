let grammar_fp = open_in "/home/jddev/Documents/GitHub/huitr/huitr.grammar"

let test_grammar = really_input_string grammar_fp (in_channel_length grammar_fp)

let token_rules, rules = parse_grammar test_grammar

let automaton = construit_automate_LR1 rules "STATEMENTS" "EOF"

let code_fp = open_in "/home/jddev/Documents/GitHub/huitr/examples/fizzbuzz.8tr"

let code = really_input_string code_fp (in_channel_length code_fp)

let tokens_with_comments = tokenize token_rules "EOF" code |> List.filter (fun t -> not (t.token_type = "whitespace"))
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
let tokens = filter_tokens tokens_with_comments false false []

let result = parse automaton "EOF" tokens "STATEMENTS"
