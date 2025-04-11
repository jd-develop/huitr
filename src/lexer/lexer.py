#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024-2025  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Global Python imports
import string

# Huitr API imports
from src.error.error import SyntaxError
from src.lexer.position import Position
from src.lexer.token import Token

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
    "EOF"
]

WHITESPACES = " \n\N{NBSP}\N{NNBSP}\t"


class Lexer:
    def __init__(self, source: str, filename: str | None = None) -> None:
        self.source = source
        self.cursor_pos = Position(0, 0, 0, filename, self.source)

        self.tokens: list[Token] = []

        self.current = self.cursor_pos.get_char_at_pos()

    def next(self, n: int = 1):
        for _ in range(n):  # Not to skip \n when n>1
            self.current = self.cursor_pos.advance()
        return self.current

    def get_next(self, n: int = 1):
        if self.cursor_pos.index + n >= len(self.source):
            return None
        return self.source[self.cursor_pos.index + n]

    def new_token(
        self,
        token_type: str,
        value: str | int | float | None = None,
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

    def tokenize(self) -> tuple[list[Token], None | SyntaxError]:
        while self.current is not None:
            start_pos = self.cursor_pos.copy()
            if self.current in WHITESPACES:
                self.next()
                continue
            if self.current == "(":
                self.new_token("LPAREN")
            elif self.current == ")":
                self.new_token("RPAREN")
            elif self.current == "[":
                self.new_token("LSQUARE")
            elif self.current == "]":
                self.new_token("RSQUARE")
            elif self.current == ">":
                self.new_token("CHAINOP")
            elif self.current == ",":
                self.new_token("COMMA")
            elif self.current == ";":
                self.new_token("SEMICOLON")
            elif self.current == ".":  # Comments
                self.next()
                if self.current == ".":
                    while not (self.current == self.get_next() == "."):
                        n = self.next()
                        if n is None:  # end of file
                            break
                    self.next()  # Multi-line comments ends with .. (double dot)
                else:
                    while self.current != "\n":
                        n = self.next()
                        if n is None:  # end of file
                            break
            elif self.current == ":":
                if not self.get_next() == ":":
                    return [], SyntaxError("incorrect use of `:`", self.cursor_pos)

                start_pos = self.cursor_pos.copy()
                self.next()

                self.new_token(
                    "NAMESP",
                    start=start_pos,
                )

            # Float / int
            elif (self.current in DIGITS + "."):  # FIXME: Change comment symbol to make float starting with a period to work
                number = self.current
                last_was_e = False
                seen_e = False
                seen_dot = False
                next_ = self.get_next()
                while next_ is not None and (
                    next_ in DIGITS + ALLOWED_CHARS_IN_INT + "eE."
                    or (next_ == "-" and last_was_e)
                ):
                    self.next()

                    last_was_e = self.current.lower() == "e"
                    seen_e = seen_e or last_was_e
                    if self.current.lower() == ".":
                        if seen_dot:
                            return [], SyntaxError(
                                "a number can not have more than one dot", self.cursor_pos
                            )
                        if seen_e:
                            return [], SyntaxError(
                                "exponent of scientific notation should be an integer, not float", self.cursor_pos
                            )
                        seen_dot = True

                    number += self.current.lower()
                    next_ = self.get_next()

                if not any(c in number for c in [".", "e"]):
                    self.new_token("INT", int(number), start=start_pos)
                else:
                    self.new_token("FLOAT", float(number), start=start_pos)

            # Identifier (no reserved keywords in this language)
            elif self.current in IDENTIFIERS_LEGAL_CHARS:
                identifier = self.current
                next_ = self.get_next()
                while (
                    next_ is not None
                    and next_ in IDENTIFIERS_LEGAL_CHARS + DIGITS
                ):
                    self.next()
                    identifier += self.current
                    next_ = self.get_next()
                self.new_token("IDENTIFIER", identifier, start=start_pos)

            # String
            elif self.current in STRING_DELIMITERS.keys():
                delimiter = self.current
                matching_delimiter = STRING_DELIMITERS[self.current]
                string = ""
                while (
                    self.get_next() is not None
                    and not self.get_next() == matching_delimiter
                ):
                    self.next()
                    string += self.current
                if self.get_next() is None:
                    return [], SyntaxError(
                        f"`{delimiter}` was never closed",
                        self.cursor_pos
                    )
                self.next()  # Place cursor on tailing string delimiter

                self.new_token("STRING", string, start=start_pos)
            elif self.current == "»":
                return [], SyntaxError(
                    "`»` was never opened", self.cursor_pos
                )
            else:
                return [], SyntaxError(
                    f"unexpected char U+{hex(ord(self.current))[2:].upper()}",
                    self.cursor_pos,
                )

            self.next()

        self.new_token("EOF")
        return self.tokens, None
