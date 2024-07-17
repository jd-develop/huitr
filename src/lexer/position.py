#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


class Position:
    def __init__(
        self,
        line_number: int,
        index: int,
        column: int,
        filename: str | None = None,
        file_source: str | None = None,
        current_char: str = "",
    ):
        self.line_number = line_number
        self.index = index
        self.column = column
        self.filename = filename if filename is not None else "<undefined>"
        self.file_source = file_source

        if current_char == "\n":
            self.end_of_line = True

        self.end_of_line = False

    def set_position(
        self,
        line_number: int | None = None,
        index: int | None = None,
        column: int | None = None,
        filename: str | None = None,
        file_source: str | None = None,
        current_char: str | None = None,
    ) -> None:
        if line_number is not None:
            self.line_number = line_number
        if index is not None:
            self.index = index
        if column is not None:
            self.column = column
        if filename is not None:
            self.filename = filename
        if file_source is not None:
            self.file_source = file_source

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

    def get_line(self):
        if self.file_source is None:
            return None
        lines = self.file_source.split("\n")
        if self.line_number >= len(lines):
            return None
        return lines[self.line_number]

    def __repr__(self) -> str:
        return f"[{self.filename}:{self.line_number}:{self.column}]"

    def __str__(self):
        return repr(self)

    def copy(self):
        return Position(self.line_number, self.index, self.column, self.filename)
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Position):
            return False
        return (
            self.line_number == other.line_number and
            self.index == other.index and
            self.column == other.column and
            self.filename == other.filename and
            self.file_source == other.file_source and
            self.end_of_line == other.end_of_line
        )
