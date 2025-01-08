#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.lexer.position import Position
from src.runtime.context import Context


class Value:
    """Parent class for values"""
    def __init__(self, pos_start: Position, pos_end: Position, context: Context):
        self.pos_start = pos_start
        self.pos_end = pos_end

        self.context = context
        self.type: str = "BaseValue"
        self.attributes: dict[str|int, Value] = {}
        self.call_with_module_context: bool = False
        self.module_context: Context | None = None

    def __repr__(self):
        return "BaseValue"

    def __str__(self):
        return repr(self)

    def set_pos(self, pos_start: Position, pos_end: Position):
        self.pos_start = pos_start
        self.pos_end = pos_end
        return self
