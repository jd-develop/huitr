#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024-2025  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# __future__ imports (must be first)
from __future__ import annotations
# Huitr API imports
from src.lexer.token import Token as _Token
from src.lexer.position import Position as _Position


class Node:
    pos_start: _Position
    pos_end: _Position

    def pos_eq(self, other: Node) -> bool:
        return self.pos_start == other.pos_end

    def __eq__(self, _: object) -> bool:
        return False

    def __str__(self):
        return repr(self)


class ChainNode(Node):
    def __init__(self, chain: list[Node], pos_start: _Position, pos_end: _Position):
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
    def __init__(self, list_: list[Node], pos_start: _Position, pos_end: _Position):
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
    def __init__(self, string_token: _Token):
        self.string_token = string_token
        self.pos_start = string_token.start_pos
        self.pos_end = string_token.end_pos

    def __repr__(self):
        return repr(self.string_token)


class IntNode(Node):
    def __init__(self, int_token: _Token):
        self.int_token = int_token
        self.pos_start = int_token.start_pos
        self.pos_end = int_token.end_pos

    def __repr__(self):
        return repr(self.int_token)


class FloatNode(Node):
    def __init__(self, float_token: _Token):
        self.float_token = float_token
        self.pos_start = float_token.start_pos
        self.pos_end = float_token.end_pos

    def __repr__(self):
        return repr(self.float_token)


class NoNode(Node):
    def __repr__(self):
        return "NoNode"


class IdentifierNode(Node):
    def __init__(self, identifiers_list: list[_Token]):
        self.identifiers_list = identifiers_list
        self.pos_start = identifiers_list[0].start_pos
        self.pos_end = identifiers_list[-1].end_pos

    def __repr__(self):
        return "i[" + "::".join(str(i.value) for i in self.identifiers_list) + "]"


class LibIdentifierNode(Node):
    def __init__(self, identifiers_list: list[_Token], pos_start: _Position, pos_end: _Position):
        self.identifiers_list = identifiers_list
        self.pos_start = pos_start
        self.pos_end = pos_end

    def __repr__(self):
        return "l[" + "::".join(str(i.value) for i in self.identifiers_list) + "]"


class FuncDefNode(Node):
    def __init__(self, body_node: Node, pos_start: _Position, pos_end: _Position, header: Node | None = None):
        self.body_node = body_node
        self.header = header
        if isinstance(header, NoNode):
            header.pos_start = pos_start.copy()
            header.pos_end = body_node.pos_start.copy()

        self.pos_start = pos_start
        self.pos_end = pos_end

    def __repr__(self):
        if self.header is not None:
            return "f[" + str(self.header) + " | " + str(self.body_node) + "]"
        return "f[" + str(self.body_node) + "]"


class UnitNode(Node):
    def __init__(self, pos_start: _Position, pos_end: _Position):
        self.pos_start = pos_start
        self.pos_end = pos_end

    def __repr__(self):
        return "()"
