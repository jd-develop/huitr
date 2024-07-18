#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2024  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Huitr API imports
from src.lexer.token import Token
from src.error.error import Error, SyntaxError
from src.parser.nodes import Node, ChainNode, ListNode, StringNode, IntNode, FloatNode, NoNode, LibIdentifierNode
from src.parser.nodes import IdentifierNode


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
        return self.current_token

    def parse(self) -> tuple[Node, None] | tuple[None, Error]:
        return self.statements()

    def statements(self) -> tuple[Node, None] | tuple[None, Error]:
        statements_list: list[Node] = []
        while self.current_token is not None:
            while self.current_token.type == "SEMICOLON":
                self.advance()
            if self.current_token.type == "EOF":
                break

            node, err = self.statement()
            if err is not None:
                return None, err
            assert node is not None
            statements_list.append(node)

            if self.current_token.type not in ["EOF", "SEMICOLON"]:
                return None, SyntaxError("expected semicolon to finish the line", self.current_token.start_pos, self.current_token.end_pos)
            self.advance()
            while self.current_token.type == "SEMICOLON":
                self.advance()
            if self.current_token.type == "EOF":
                break
            
        if len(statements_list) == 0:
            return NoNode(), None
        return ListNode(statements_list[0].pos_start, statements_list[-1].pos_end, statements_list), None

    def statement(self) -> tuple[Node, None] | tuple[None, Error]:
        node, err = self.chain()
        if err is not None:
            return None, err
        assert node is not None
        return node, None

    def chain(self, first_element: Node | None = None) -> tuple[Node, None] | tuple[None, Error]:
        # this is a messy draft
        chain: list[Node] = []

        if first_element is not None:
            chain.append(first_element)
        elif self.current_token is not None and self.current_token.type == "CHAINOP":
            chain.append(ListNode(self.current_token.start_pos, self.current_token.start_pos, []))
            self.advance()
        
        node, err = self.atom()
        if err is not None:
            return None, err
        assert node is not None
        chain.append(node)

        while self.current_token is not None and self.current_token.type == "CHAINOP":
            self.advance()
            node, err = self.atom()
            if err is not None:
                return None, err
            assert node is not None
            chain.append(node)
        
        if self.current_token is not None and self.current_token.type == "COMMA":
            self.advance()
            return self.list(ChainNode(chain[0].pos_start, chain[-1].pos_end, chain))
            
        return ChainNode(chain[0].pos_start, chain[-1].pos_end, chain), None

    def list(self, first_element: Node | None = None) -> tuple[Node, None] | tuple[None, Error]:
        """assuming current token is the first element of the list"""
        list_: list[Node] = []

        if first_element is not None:
            list_.append(first_element)
        
        node, err = self.atom()
        if err is not None:
            return None, err
        assert node is not None
        list_.append(node)

        while self.current_token is not None and self.current_token.type == "COMMA":
            self.advance()
            node, err = self.atom()
            if err is not None:
                return None, err
            assert node is not None
            list_.append(node)
        
        if self.current_token is not None and self.current_token.type == "CHAINOP":
            self.advance()
            return self.chain(ListNode(list_[0].pos_start, list_[-1].pos_end, list_))

        return ListNode(list_[0].pos_start, list_[-1].pos_end, list_), None
    
    def atom(self) -> tuple[Node, None] | tuple[None, Error]:
        if self.current_token is None:
            return None, SyntaxError("expected valid expression", self.tokens[-1].end_pos)
        elif self.current_token.type == "STRING":
            token = self.current_token
            self.advance()
            return StringNode(token), None
        elif self.current_token.type == "INT":
            token = self.current_token
            self.advance()
            return IntNode(token), None
        elif self.current_token.type == "FLOAT":
            token = self.current_token
            self.advance()
            return FloatNode(token), None
        elif self.current_token.type in ["NAMESP", "IDENTIFIER"]:
            return self.identifier()
        else:
            return None, SyntaxError("expected valid expression", self.current_token.start_pos, self.current_token.end_pos)

    def identifier(self) -> tuple[Node, None] | tuple[None, Error]:
        assert self.current_token is not None

        lib_identifier = False
        pos_start = self.current_token.start_pos
        if self.current_token.type == "NAMESP":
            self.advance()
            lib_identifier = True
        
        identifiers_list: list[Token] = []
        if self.current_token.type != "IDENTIFIER":
            return None, SyntaxError("expected identifier", self.current_token.start_pos, self.current_token.end_pos)
        
        identifiers_list.append(self.current_token)
        new_token = self.advance()

        while new_token is not None and new_token.type == "NAMESP":
            self.advance()
            if self.current_token.type != "IDENTIFIER":
                if lib_identifier:
                    identifiers_list.append(new_token)
                    break
                return None, SyntaxError("expected identifier", self.current_token.start_pos, self.current_token.end_pos)
            identifiers_list.append(self.current_token)
            new_token = self.advance()
        
        if lib_identifier:
            return LibIdentifierNode(identifiers_list, pos_start, identifiers_list[-1].end_pos), None
        return IdentifierNode(identifiers_list), None
