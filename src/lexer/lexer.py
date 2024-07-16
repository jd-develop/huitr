#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# IMPORTS
# Huitr API imports
from src.lexer.position import Position
from src.lexer.token import Token
# Global Python imports
import string

DIGITS = "0123456789"
ALLOWED_CHARS_IN_INT = "_"
LETTERS = string.ascii_letters
LETTERS_DIGITS = LETTERS + DIGITS
IDENTIFIERS_LEGAL_CHARS = LETTERS + "_"

STRING_DELIMITERS = {
    "'": "'",
    '"': '"',
    "«": "»",
}

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
    "NAMESP",  # ::
]

WHITESPACES = " \n\N{NBSP}\N{NNBSP}\t"


class Lexer:
    def __init__(self, source: str, filename: str | None = None) -> None:
        self.source = source
        self.cursor_pos = Position(0, 0, 0, filename)

        # Init self.current
        if len(self.source) < 1:
            self.current = None
        else:
            self.current = self.source[0]
            self.cursor_pos.init(self.current)

        self.tokens: list[Token] = []
        self.error = None

    def next(self, n: int = 1):
        for _ in range(n):  # Not to skip \n when n>1
            if self.cursor_pos.index + 1 >= len(self.source):
                self.current = None
            else:
                self.current = self.source[self.cursor_pos.index + 1]

            self.cursor_pos.advance(self.current)

    def get_next(self, n: int = 1):
        if self.cursor_pos.index + n >= len(self.source):
            return None
        return self.source[self.cursor_pos.index + n]

    def new_token(
        self,
        token_type: str,
        value: str | None = None,
        start: Position | None = None,
        end: Position | None = None,
    ):
        """
        Arguments:
            token_type: element of TOKEN_TYPES
            value (optional): the token value
            start (optional): the index in the line at which the token begins. Defaults to self.cursor_pos if ommited.
            end (optional): the index in the line at which the token ends. Defaults to self.cursor_pos if ommited.
        """
        assert token_type in TOKEN_TYPES, "Undefined token type"

        self.tokens.append(
            Token(
                token_type,
                value,
                start if start is not None else self.cursor_pos.copy(),
                end if end is not None else self.cursor_pos.copy(),
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
                        self.error = "incorrect use of :"
                        break

                    start_pos = self.cursor_pos.copy()
                    self.next()

                    self.new_token(
                        "NAMESP",
                        start=start_pos,
                    )

                case _:
                    start_pos = self.cursor_pos.copy()

                    # Float / int
                    if (
                        self.current in DIGITS + "."
                    ):  # FIXME: Change comment symbol to make float starting with a period to work
                        number = self.current
                        last_was_e = False
                        while self.get_next() and (
                            self.get_next() in DIGITS + ALLOWED_CHARS_IN_INT + "eE."
                            or (self.get_next() == "-" and last_was_e)
                        ):
                            self.next()

                            last_was_e = False
                            if self.current.lower() == "e":
                                last_was_e = True

                            number += self.current.lower()

                        if not any(c in number for c in [".", "e"]):
                            self.new_token("INT", number, start=start_pos)
                        else:
                            self.new_token("FLOAT", number, start=start_pos)

                    # Identifier (no reserved keywords in this language)
                    elif self.current in IDENTIFIERS_LEGAL_CHARS:
                        identifier = self.current
                        while (
                            self.get_next()
                            and self.get_next() in IDENTIFIERS_LEGAL_CHARS + DIGITS
                        ):
                            self.next()
                            identifier += self.current
                        self.new_token("IDENTIFIER", identifier, start=start_pos)

                    # String
                    elif self.current in STRING_DELIMITERS.keys():
                        matching_delimiter = STRING_DELIMITERS[self.current]
                        string = ""
                        while (
                            self.get_next()
                            and not self.get_next() == matching_delimiter
                        ):
                            self.next()
                            string += self.current
                        self.next()  # Place cursor on tailing string delimiter

                        self.new_token("STRING", string, start=start_pos)

                    else:
                        self.error = f"Unexpected char at line {self.cursor_pos.line_number}, column {self.cursor_pos.column}"
                        break

            self.next()

        return self.tokens, self.error
