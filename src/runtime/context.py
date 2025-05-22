#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024-2025  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Global python imports
from typing import TYPE_CHECKING
# Huitr API imports
if TYPE_CHECKING:
    from src.runtime.value import Value


class SymbolTable():
    def __init__(self):
        self.parent: SymbolTable | None = None
        self.symbols: dict[str, Value] = dict()


class Context():
    def __init__(self):
        self.parent: Context | None = None
        self.symbol_table: SymbolTable = SymbolTable()

