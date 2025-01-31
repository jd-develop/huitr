#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.lexer.position import Position

TAB_WIDTH = 4


class Error:
    def __init__(
        self,
        error_type: str,
        error_message: str,
        start_pos: Position,
        end_pos: Position | None = None,
    ) -> None:
        self.type = error_type
        self.message = error_message
        self.start_pos = start_pos
        if end_pos is not None:
            self.end_pos = end_pos
        else:
            self.end_pos = self.start_pos

    def __repr__(self) -> str:
        error_text = f"In file {self.start_pos.filename}, line {self.start_pos.line_number + 1}:\n"

        error_line = self.start_pos.get_line()

        if error_line is not None:
            # Replace tabs by TAB_WIDTH number of spaces and update the error position
            before_tab_count = error_line[: self.start_pos.column].count("\t")
            start_offset = before_tab_count * (TAB_WIDTH - 1)  # \t was removed

            error_tab_count = error_line[
                self.start_pos.column : self.end_pos.column + 1
            ].count("\t")
            end_offset = error_tab_count * (TAB_WIDTH - 1)  # \t was removed

            error_line = error_line.expandtabs(4)

            error_text += f"  {error_line}"
            error_text += f"  {' ' * (self.start_pos.column + start_offset)}{'^' * (self.end_pos.column - self.start_pos.column + 1 + end_offset)}\n"

        error_text += f"{self.type}: {self.message}"

        return error_text

    def __str__(self):
        return repr(self)


class SyntaxError(Error):
    def __init__(
        self,
        error_message: str,
        start_pos: Position,
        end_pos: Position | None = None,
    ):
        super().__init__("SyntaxError", error_message, start_pos, end_pos)


class ReferenceError(Error):
    def __init__(
        self,
        error_message: str,
        start_pos: Position,
        end_pos: Position | None = None,
    ):
        super().__init__("ReferenceError", error_message, start_pos, end_pos)


class ModuleNotFoundError(Error):
    def __init__(
        self,
        error_message: str,
        start_pos: Position,
        end_pos: Position | None = None,
    ):
        super().__init__("ModuleNotFoundError", error_message, start_pos, end_pos)
