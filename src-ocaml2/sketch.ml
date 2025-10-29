let grammar_fp = open_in "/home/jddev/Documents/GitHub/huitr/huitr.grammar"

let test_grammar = really_input_string grammar_fp (in_channel_length grammar_fp)

let token_rules, rules = parse_grammar test_grammar

let automaton = construit_automate_LR1 rules "STATEMENTS" "EOF"

let code_fp = open_in "/home/jddev/Documents/GitHub/huitr/examples/fizzbuzz.8tr"

let code = really_input_string code_fp (in_channel_length code_fp)

let tokens = tokenize token_rules "EOF" code |> List.filter (fun t -> not (t.token_type = "whitespace"))

let result = parse automaton "EOF" tokens "STATEMENTS"
