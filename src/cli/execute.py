#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2025  Hugo Vangilluwen

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.*

# Global Python imports
import os

# Huitr API imports
from src.lexer.lexer import Lexer
from src.parser.parser import Parser
from src.runtime.interpreter import visit
from src.runtime.context import Context


def execute_file(filename: str, debug: bool):
    if not os.path.exists(filename):
        print(f"File {filename} not found")
        return

    with open(filename, "r") as file_source:
        file_lexer = Lexer(file_source.read(), filename)
        file_tokens = file_lexer.tokenize()
        if file_tokens[1] is None:
            file_parser = Parser(file_tokens[0])
            file_output = file_parser.parse()
            if file_output[0] is None:
                print(file_output[1])
            else:
                if debug:
                    print(file_output[0])
                print(visit(file_output[0], Context()))
        else:
            print(file_tokens[1])
