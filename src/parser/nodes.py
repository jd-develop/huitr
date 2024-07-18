#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# __future__ imports (must be first)
from __future__ import annotations
# Huitr API imports
from src.lexer.token import Token
from src.lexer.position import Position


class Node:
    pos_start: Position
    pos_end: Position

    def pos_eq(self, other: Node) -> bool:
        return self.pos_start == other.pos_end

    def __eq__(self, other: object) -> bool:
        return False
    
    def __str__(self):
        return repr(self)


class ChainNode(Node):
    def __init__(self, pos_start: Position, pos_end: Position, chain: list[Node]):
        self.chain = chain
        self.pos_start = pos_start
        self.pos_end = pos_end

    def __eq__(self, other: object) -> bool:
        return (
            isinstance(other, ChainNode) and
            self.pos_eq(other) and
            self.chain == other.chain
        )
    
    def __repr__(self):
        if len(self.chain) == 1:
            return f"c({self.chain[0]})"
        return " > ".join(map(str, self.chain))


class ListNode(Node):
    def __init__(self, pos_start: Position, pos_end: Position, list_: list[Node]):
        self.list = list_
        self.pos_start = pos_start
        self.pos_end = pos_end

    def __eq__(self, other: object) -> bool:
        return (
            isinstance(other, ListNode) and
            self.pos_eq(other) and
            self.list == other.list
        )
    
    def __repr__(self):
        return "[" + ", ".join(map(str, self.list)) + "]"
    

class StringNode(Node):
    def __init__(self, string_token: Token):
        self.string_token = string_token
        self.pos_start = string_token.start_pos
        self.pos_end = string_token.end_pos

    def __repr__(self):
        return repr(self.string_token)
    

class IntNode(Node):
    def __init__(self, int_token: Token):
        self.int_token = int_token
        self.pos_start = int_token.start_pos
        self.pos_end = int_token.end_pos

    def __repr__(self):
        return repr(self.int_token)
    

class FloatNode(Node):
    def __init__(self, float_token: Token):
        self.float_token = float_token
        self.pos_start = float_token.start_pos
        self.pos_end = float_token.end_pos

    def __repr__(self):
        return repr(self.float_token)


class NoNode(Node):
    def __repr__(self):
        return "NoNode"
