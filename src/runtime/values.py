#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024-2025  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.lexer.position import Position
from src.runtime.context import Context
from src.runtime.value import Value


class Int(Value):
    """Integer"""
    def __init__(self, pos_start: Position, pos_end: Position, context: Context, value: int):
        super().__init__(pos_start, pos_end, context)
        self.type: str = "int"
        self.value: int = value

    def __repr__(self):
        return str(self.value)


class Float(Value):
    """Float"""
    def __init__(self, pos_start: Position, pos_end: Position, context: Context, value: float):
        super().__init__(pos_start, pos_end, context)
        self.type: str = "float"
        self.value: float = value

    def __repr__(self):
        return str(self.value)
