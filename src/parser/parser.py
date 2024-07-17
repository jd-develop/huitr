#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.lexer.token import Token
from src.error.error import Error
from src.parser.nodes import Node, ChainNode, ListNode, BasicNode


class Parser:
    def __init__(self, tokens: list[Token]):
        self.tokens = tokens
        self.tokens_index = 0
        self.current_token = tokens[0]

    def advance(self):
        if self.current_token is None or self.current_token.is_eof():
            self.tokens_index = -1
            self.current_token = None
        else:
            self.tokens_index += 1
            self.current_token = self.tokens[self.tokens_index]

    def parse(self):
        ...

    def chain(self, first_element: Node | None = None) -> tuple[Node, None] | tuple[None, Error]:
        # this is a messy draft
        chain: list[Node] = []

        if first_element is not None:
            chain.append(first_element)
        elif self.current_token is not None and self.current_token.type == "CHAINOP":
            chain.append(ListNode(self.current_token.start_pos, self.current_token.start_pos, []))
            self.advance()
        
        chain.append(BasicNode(self.current_token))
        self.advance()

        while self.current_token is not None and self.current_token.type == "CHAINOP":
            self.advance()
            chain.append(BasicNode(self.current_token))
            self.advance()
        if self.current_token is not None and self.current_token.type == "COMMA":
            self.advance()
            return self.list(ChainNode(chain[0].pos_start, chain[-1].pos_end, chain))
            
        return ChainNode(chain[0].pos_start, chain[-1].pos_end, chain), None

    def list(self, first_element: Node | None = None) -> tuple[Node, None] | tuple[None, Error]:
        """assuming current token is the first element of the list"""
        list_: list[Node] = []
        if first_element is not None:
            list_.append(first_element)
        list_.append(BasicNode(self.current_token))
        self.advance()
        while self.current_token is not None and self.current_token.type == "COMMA":
            self.advance()
            list_.append(BasicNode(self.current_token))
            self.advance()
        if self.current_token is not None and self.current_token.type == "CHAINOP":
            self.advance()
            return self.chain(ListNode(list_[0].pos_start, list_[-1].pos_end, list_))
        return ListNode(list_[0].pos_start, list_[-1].pos_end, list_), None
