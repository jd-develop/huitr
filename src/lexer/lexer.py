import string

DIGITS = "0123456789"
LETTERS = string.ascii_letters
LETTERS_DIGITS = LETTERS + DIGITS
IDENTIFIERS_LEGAL_CHARS = LETTERS + "_"

TOKEN_TYPES = [
    "LPAREN",
    "RPAREN",
    "LSQUARE",
    "RSQUARE",
    "CHAINOP",  # >
    "COMMA",
    "SEMICOLON",
    "STRING",
    "INT",
    "FLOAT",
    "IDENTIFIER",
    "LIBPATH",  # ::std::math for example
]

WHITESPACES = " \N{NBSP}\N{NNBSP}\t"


class Token:
    def __init__(
        self,
        token_type: str,
        value: str | None,
        line: int,
        start_index: int,
        end_index: int,
    ) -> None:
        self.type = token_type
        self.value = value
        self.line = line
        self.start_index = start_index
        self.end_index = end_index

    def __repr__(self) -> str:
        if self.value is not None:
            if self.type == "STRING":
                return f'[{self.line}:{self.start_index}-{self.end_index}]{self.type}:"{self.value}"'
            return f"[{self.line}:{self.start_index}-{self.end_index}]{self.type}:{self.value}"
        return f"[{self.line}:{self.start_index}-{self.end_index}]{self.type}"

    def __str__(self):
        return repr(self)


class Lexer:
    def __init__(self, source: str) -> None:
        self.source = source
        self.cursor_pos = 0
        self.cursor_pos_in_line = 0
        self.current_line = 0
        self.end_of_line = False

        # Init self.current
        if len(self.source) < 1:
            self.current = None
        else:
            self.current = self.source[0]
        if self.current == "\n":
            self.current_line += 1

        # if all([c in WHITESPACES for c in source]):
        #     self.current = None
        self.tokens = []
        self.error = None

    def next(self, n=1):
        for _ in range(n):  # Not to skip \n when n>1
            self.cursor_pos += 1
            self.cursor_pos_in_line += 1
            if self.cursor_pos >= len(self.source):
                self.current = None
            else:
                self.current = self.source[self.cursor_pos]

            if self.end_of_line:  # Last char was \n
                self.current_line += 1
                self.cursor_pos_in_line = 0
                self.end_of_line = False
            if self.current == "\n":  # Previous if will be executed next char
                self.end_of_line = True

    def get_next(self, n=1):
        if self.cursor_pos + n >= len(self.source):
            return None
        return self.source[self.cursor_pos + n]

    def newToken(
        self, token_type: str, value: str | None = None, line=None, start=None, end=None
    ):
        """
        Arguments:
            token_type: element of TOKEN_TYPES
            value (optional): the token value
            start (optional): the index in the line at which the token begins. Defaults to self.cursor_pos_in_line if ommited.
            end (optional): the index in the line at which the token ends. Defaults to self.cursor_pos_in_line if ommited.
            line (optional): the line number in code at which the token starts (first is 0). Defaults to self.current_line if ommited.
        """
        if token_type not in TOKEN_TYPES:
            raise "Undefined token type"
        self.tokens.append(
            Token(
                token_type,
                value,
                line if line is not None else self.current_line,
                start if start is not None else self.cursor_pos_in_line,
                end if end is not None else self.cursor_pos_in_line,
            )
        )

    def tokenize(self):
        while self.current is not None and self.error is None:
            match self.current:
                case "\n":
                    pass
                case "(":
                    self.newToken("LPAREN")
                case ")":
                    self.newToken("RPAREN")
                case "[":
                    self.newToken("LSQUARE")
                case "]":
                    self.newToken("RSQUARE")
                case ">":
                    self.newToken("CHAINOP")
                case ",":
                    self.newToken("COMMA")
                case ";":
                    self.newToken("SEMICOLON")
                case ".":  # Comments
                    self.next()
                    if self.current == ".":
                        while not self.current == self.get_next() == ".":
                            self.next()
                        self.next()  # Multi-line comments ends with .. (double dot)
                    else:
                        while not self.current == "\n":
                            self.next()
                case ":":
                    if not self.get_next() == ":":
                        self.error = "Syntax error: incorrect use of :"
                        break

                    start_index = self.cursor_pos_in_line

                    libpath = self.current
                    while (
                        self.get_next()
                        and self.get_next() in IDENTIFIERS_LEGAL_CHARS + ":"
                    ):
                        self.next()
                        libpath += self.current

                    self.newToken(
                        "LIBPATH",
                        libpath,
                        start=start_index,
                    )

                case _:  # multi-char
                    start_index = self.cursor_pos_in_line
                    if self.current in DIGITS:  # INT
                        number = self.current
                        while self.get_next() and self.get_next() in DIGITS:
                            self.next()
                            number += self.current
                        self.newToken("INT", number, start=start_index)

                    # Identifier (no reserved keywords in this language)
                    elif self.current in IDENTIFIERS_LEGAL_CHARS + ":":
                        identifier = self.current
                        while (
                            self.get_next()
                            and self.get_next() in IDENTIFIERS_LEGAL_CHARS
                        ):
                            self.next()
                            identifier += self.current
                        self.newToken("IDENTIFIER", identifier, start=start_index)

            self.next()

        return self.tokens, self.error
