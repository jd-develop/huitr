#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Global Python imports
from typing import Any

# Huitr API imports
from src.parser.nodes import *


def visit_chain_node(node: ChainNode):
    # stack = []
    # for n in node.chain:
    #     if isinstance(n, FuncDefNode):
    #         return NotImplemented
    #     elif isinstance(n, UnitNode):
    #         stack = []
    #     else:
    #         stack.append(visit(n))

    # if len(stack) == 0:
    #     return None
    # elif len(stack) == 1:
    #     return stack[0]
    # else:
    #     return stack
    ...


# def visit_list_node(node: ListNode) -> Any | list[Any]:
#     if len(node.list) == 1:
#         return visit(node.list[0])
#     else:
#         return [visit(n) for n in node.list]


# def visit_string_node(node: ListNode) -> str:
#     return node.string_token.value


# def visit_int_node(node: IntNode) -> int:
#     return node.int_token.value


# def visit_float_node(node: FloatNode) -> float:
#     return node.float_token.value


# def visit_no_node(node: NoNode) -> None:
#     return None


# def visit_identifier_node(node: IdentifierNode):
#     pass


# def visit_libidentifier_node(node: LibIdentifierNode):
#     pass


# def visit_funcdef_node(node: FuncDefNode):
#     pass


# def visit_unit_node(node: UnitNode):
#     pass


def visit(node: Node):
    """Visit (execute) a node"""
    if isinstance(node, ChainNode):
        return visit_chain_node(node)
    # elif isinstance(node, ListNode):
    #     return visit_list_node(node)
    # elif isinstance(node, StringNode):
    #     return visit_string_node(node)
    # elif isinstance(node, IntNode):
    #     return visit_int_node(node)
    # elif isinstance(node, FloatNode):
    #     return visit_float_node(node)
    # elif isinstance(node, NoNode):
    #     return visit_no_node(node)
    # elif isinstance(node, IdentifierNode):
    #     return visit_identifier_node(node)
    # elif isinstance(node, LibIdentifierNode):
    #     return visit_libidentifier_node(node)
    # elif isinstance(node, FuncDefNode):
    #     return visit_funcdef_node(node)
    # elif isinstance(node, UnitNode):
    #     return visit_unit_node(node)
    else:
        return NotImplemented

