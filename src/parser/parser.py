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
from src.parser.nodes import IdentifierNode, FuncDefNode


class Parser:
    def __init__(self, tokens: list[Token]):
        self.tokens = tokens
        self.tokens_index = 0
        self.current_token = tokens[0]
        self.advance_count = 0

    def advance(self, return_old_token: bool = False):
        old_tok = self.current_token
        if self.current_token is None or self.current_token.is_eof():
            self.tokens_index = -1
            self.current_token = None
        else:
            self.tokens_index += 1
            self.advance_count += 1
            self.current_token = self.tokens[self.tokens_index]
        
        if return_old_token:
            return old_tok
        return self.current_token
    
    def reverse(self):
        """Reverse `self.advance_count` times. Resets `self.advance_count`"""
        self.tokens_index -= self.advance_count
        self.current_token = self.tokens[self.tokens_index]
        self.reset_advance_count()
        return self.current_token
    
    def reset_advance_count(self):
        self.advance_count = 0

    def parse(self) -> tuple[Node, None] | tuple[None, Error]:
        return self.statements()

    def statements(self, stop: list[str] | None = None, first_statement: Node | None = None) -> tuple[Node, None] | tuple[None, Error]:
        """Register statements, stops at any token listed in `stop` (don’t forget EOF)"""
        if stop is None:
            stop = ["EOF"]

        statements_list: list[Node] = []
        should_look_for_semicolon = False
        if first_statement is not None:
            statements_list.append(first_statement)
            should_look_for_semicolon = True

        while self.current_token is not None:
            if should_look_for_semicolon and self.current_token.type not in stop + ["SEMICOLON"]:
                return None, SyntaxError("expected semicolon to finish the line", self.current_token.start_pos, self.current_token.end_pos)
            elif should_look_for_semicolon:
                should_look_for_semicolon = False
            
            while self.current_token.type == "SEMICOLON":
                self.advance()
            if self.current_token.type in stop:
                break

            node, err = self.statement()
            if err is not None:
                return None, err
            assert node is not None
            statements_list.append(node)

            if self.current_token.type not in stop + ["SEMICOLON"]:
                return None, SyntaxError("expected semicolon to finish the line", self.current_token.start_pos, self.current_token.end_pos)
            
            while self.current_token.type == "SEMICOLON":
                self.advance()
            
            if self.current_token.type in stop:
                break
            
        if len(statements_list) == 0:
            return NoNode(), None
        return ListNode(statements_list, statements_list[0].pos_start, statements_list[-1].pos_end), None

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
            chain.append(ListNode([], self.current_token.start_pos, self.current_token.start_pos))
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
            return self.list(ChainNode(chain, chain[0].pos_start, chain[-1].pos_end))
            
        return ChainNode(chain, chain[0].pos_start, chain[-1].pos_end), None

    def list(self, first_element: Node | None = None) -> tuple[Node, None] | tuple[None, Error]:
        """assuming current token is the first element of the list"""
        list_: list[Node] = []

        if first_element is not None:
            if isinstance(first_element, ChainNode) and len(first_element.chain) == 1:
                list_.append(first_element.chain[0])
            else:
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
            return self.chain(ListNode(list_, list_[0].pos_start, list_[-1].pos_end))

        return ListNode(list_, list_[0].pos_start, list_[-1].pos_end), None
    
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
        elif self.current_token.type == "LPAREN":
            pos = (self.current_token.start_pos, self.current_token.end_pos)
            self.advance()
            statement, err = self.statement()
            if err is not None:
                return None, err
            assert statement is not None

            rparen = self.advance(True)
            if rparen is None or rparen.type != "RPAREN":
                return None, SyntaxError("unmatched '('", *pos)
            return statement, None
        elif self.current_token.type in ["NAMESP", "IDENTIFIER"]:
            return self.identifier()
        elif self.current_token.type == "LSQUARE":
            return self.function()
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

        should_check_for_unnecessary_namesp = False
        while new_token is not None and new_token.type == "NAMESP":
            self.advance()
            if self.current_token.type != "IDENTIFIER":
                if len(identifiers_list) == 1 and identifiers_list[0].value == "reg" and self.current_token.type == "INT":
                    identifiers_list.append(self.current_token)
                    new_token = self.advance()
                    should_check_for_unnecessary_namesp = True
                    break
                if lib_identifier:
                    identifiers_list.append(new_token)
                    break
                return None, SyntaxError("expected identifier", self.current_token.start_pos, self.current_token.end_pos)
            identifiers_list.append(self.current_token)
            new_token = self.advance()
        
        if should_check_for_unnecessary_namesp and new_token is not None and new_token.type == "NAMESP":
            return None, SyntaxError("didn’t except '::' here", self.current_token.start_pos, self.current_token.end_pos)

        if lib_identifier:
            return LibIdentifierNode(identifiers_list, pos_start, identifiers_list[-1].end_pos), None
        return IdentifierNode(identifiers_list), None

    def function(self) -> tuple[Node, None] | tuple[None, Error]:
        assert self.current_token is not None
        pos = (self.current_token.start_pos, self.current_token.end_pos)
        self.advance()  # LSQUARE
        self.reset_advance_count()

        # we check for pipe only
        if self.current_token.type == "PIPE":
            self.advance()
            header = NoNode()
            first_statement = None
        else:
            # we check for statement then pipe
            header, err = self.statement()
            if err is not None:
                return None, err
            assert header is not None

            first_statement = None
            # There is no pipe: let’s reverse
            if self.current_token.type != "PIPE":
                first_statement = header
                header = None
            else:  # There is a pipe: we can now register statements
                self.advance()
        
        body, err = self.statements(["RSQUARE", "EOF"], first_statement)
        if err is not None:
            return None, err
        if self.current_token.type != "RSQUARE":
            return None, SyntaxError("unmatched '['", *pos)
        pos_end = self.current_token.end_pos
        self.advance()

        assert body is not None
        return FuncDefNode(body, pos[0], pos_end, header), None
