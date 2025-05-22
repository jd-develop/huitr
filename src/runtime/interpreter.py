#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024-2025  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Global Python imports
# from typing import Any

# Huitr API imports
from src.parser.nodes import *
from src.runtime.context import Context  # , SymbolTable


def visit_chain_node(node: ChainNode, ctx: Context):
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


# def visit_list_node(node: ListNode, ctx: Context) -> Any | list[Any]:
#     if len(node.list) == 1:
#         return visit(node.list[0])
#     else:
#         return [visit(n) for n in node.list]


# def visit_string_node(node: ListNode, ctx: Context) -> str:
#     return node.string_token.value


# def visit_int_node(node: IntNode, ctx: Context) -> int:
#     return node.int_token.value


# def visit_float_node(node: FloatNode, ctx: Context) -> float:
#     return node.float_token.value


# def visit_no_node(node: NoNode, ctx: Context) -> None:
#     return None


# def visit_identifier_node(node: IdentifierNode, ctx: Context):
#     pass


# def visit_libidentifier_node(node: LibIdentifierNode, ctx: Context):
#     pass


# def visit_funcdef_node(node: FuncDefNode, ctx: Context):
#     pass


# def visit_unit_node(node: UnitNode, ctx: Context):
#     pass


def visit(node: Node, ctx: Context):
    """Visit (execute) a node"""
    if isinstance(node, ChainNode):
        return visit_chain_node(node, ctx)
    # elif isinstance(node, ListNode):
    #     return visit_list_node(node, ctx)
    # elif isinstance(node, StringNode):
    #     return visit_string_node(node, ctx)
    # elif isinstance(node, IntNode):
    #     return visit_int_node(node, ctx)
    # elif isinstance(node, FloatNode):
    #     return visit_float_node(node, ctx)
    # elif isinstance(node, NoNode):
    #     return visit_no_node(node, ctx)
    # elif isinstance(node, IdentifierNode):
    #     return visit_identifier_node(node, ctx)
    # elif isinstance(node, LibIdentifierNode):
    #     return visit_libidentifier_node(node, ctx)
    # elif isinstance(node, FuncDefNode):
    #     return visit_funcdef_node(node, ctx)
    # elif isinstance(node, UnitNode):
    #     return visit_unit_node(node, ctx)
    else:
        return NotImplemented

