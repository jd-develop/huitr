# Huitr

>[!Warning]
> This is a WIP.

Huitr – a purely functional programming language.

“Huitr” stands for “Huitr is tough to read”.

### Execute

```bash
./main.py path_to_your_file
```

### Grammar

[Here](src-ocaml/grammar.txt)

### OCaml

This branch aims to translate the Python code into OCaml.

To build:
```bash
dune build
```

To run:
```bash
dune exec -- huitr [OPTION]… FILENAME
```

To see specific information for Debian-based distros, read
[debian.md](debian.md).
