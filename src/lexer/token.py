#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.lexer.position import Position


class Token:
    def __init__(
        self,
        token_type: str,
        value: str | int | float | None,
        start_pos: Position,
        end_pos: Position,
    ):
        self.type = token_type
        self.value = value
        self.start_pos = start_pos
        self.end_pos = end_pos

    def __repr__(self) -> str:
        if self.value is not None:
            if self.type == "STRING":
                return f'{self.type}:"{self.value}"'
            return f"{self.type}:{self.value}"
        return f"{self.type}"

    def __str__(self):
        return repr(self)
    
    def is_eof(self):
        return self.type == "EOF"
    
    def matches(self, type: str, value: str | int | float | None):
        return self.type == type and self.value == value
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Token):
            return False
        return (
            self.start_pos == other.start_pos and
            self.end_pos == other.end_pos and
            self.matches(other.type, other.value)
        )
