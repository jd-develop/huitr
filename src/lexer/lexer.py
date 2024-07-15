#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
        self.tokens: list[Token] = []
        self.error = None

    def next(self, n: int = 1):
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

    def get_next(self, n: int = 1):
        if self.cursor_pos + n >= len(self.source):
            return None
        return self.source[self.cursor_pos + n]

    def new_token(
        self,
        token_type: str,
        value: str | None = None,
        line: int | None = None,
        start: int | None = None,
        end: int | None = None
    ):
        """
        Arguments:
            token_type: element of TOKEN_TYPES
            value (optional): the token value
            start (optional): the index in the line at which the token begins. Defaults to self.cursor_pos_in_line if ommited.
            end (optional): the index in the line at which the token ends. Defaults to self.cursor_pos_in_line if ommited.
            line (optional): the line number in code at which the token starts (first is 0). Defaults to self.current_line if ommited.
        """
        assert token_type in TOKEN_TYPES, "Undefined token type"
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
            if self.current in WHITESPACES:
                self.next()
                continue
            match self.current:
                case "(":
                    self.new_token("LPAREN")
                case ")":
                    self.new_token("RPAREN")
                case "[":
                    self.new_token("LSQUARE")
                case "]":
                    self.new_token("RSQUARE")
                case ">":
                    self.new_token("CHAINOP")
                case ",":
                    self.new_token("COMMA")
                case ";":
                    self.new_token("SEMICOLON")
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
                        self.get_next() is not None
                        and self.get_next() in IDENTIFIERS_LEGAL_CHARS + ":"
                    ):
                        self.next()
                        libpath += self.current

                    self.new_token(
                        "LIBPATH",
                        libpath,
                        start=start_index,
                    )

                case _:
                    start_index = self.cursor_pos_in_line
                    
                    # Int
                    if self.current in DIGITS:
                        number = self.current
                        while self.get_next() and self.get_next() in DIGITS:
                            self.next()
                            number += self.current
                        self.new_token("INT", number, start=start_index)

                    # Identifier (no reserved keywords in this language)
                    elif self.current in IDENTIFIERS_LEGAL_CHARS + ":":
                        identifier = self.current
                        while (
                            self.get_next()
                            and self.get_next() in IDENTIFIERS_LEGAL_CHARS
                        ):
                            self.next()
                            identifier += self.current
                        self.new_token("IDENTIFIER", identifier, start=start_index)

            self.next()

        return self.tokens, self.error
