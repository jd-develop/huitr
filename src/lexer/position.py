#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# IMPORTS
# no imports

class Position:
    def __init__(
        self, line_number: int, index: int, column: int, filename: str | None = None
    ):
        self.line_number = line_number
        self.index = index
        self.column = column
        self.filename = filename

        self.end_of_line = False

    def init(self, current_char: str):
        if current_char == "\n":
            self.end_of_line = True

    def advance(self, current_char: str | None = None):
        self.index += 1
        self.column += 1

        if self.end_of_line:  # Last char was \n
            self.line_number += 1
            self.column = 0
            self.end_of_line = False
        if current_char == "\n":  # Previous if will be executed next char
            self.end_of_line = True

    def __repr__(self) -> str:
        if self.filename:
            return f"[{self.filename} {self.line_number}:{self.column}]"
        return f"[{self.line_number}:{self.column}]"

    def __str__(self):
        return repr(self)

    def copy(self):
        return Position(self.line_number, self.index, self.column, self.filename)
