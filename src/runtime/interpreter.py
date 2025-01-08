#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.parser.nodes import *


def visit_chain_node(node: ChainNode):
    ...


def visit_list_node(node: ListNode):
    ...


def visit(node: Node):
    """Visit (execute) a node"""
    if isinstance(node, ChainNode):
        return visit_chain_node(node)
    elif isinstance(node, ListNode):
        return visit_list_node(node)
    else:
        return NotImplemented

