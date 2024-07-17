#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.lexer.position import Position


class Node:
    pos_start: Position
    pos_end: Position

    def __eq__(self, other: object) -> bool:
        return False
    
    def __ne__(self, other: object) -> bool:
        return not self == other
