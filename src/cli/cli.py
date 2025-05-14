#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2025  Hugo Vangilluwen

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Global Python imports
import argparse

# Huitr API imports
from src.cli.execute import execute_file


def main_cli():
    arg_parser = argparse.ArgumentParser(
        prog="Huitr file executor",
        description="Execute a Huitr program written in a file",
        epilog="""Huitr – a purely functional programming language."
                “Huitr” stands for “Huitr is tough to read”."""
        )
    arg_parser.add_argument(
        'filename',
        type=str,
        help="File where the Huitr program is"
        )
    arg_parser.add_argument(
        "-d",
        "--debug",
        action="store_true",
        help="print tokens structure"
        )

    args = arg_parser.parse_args()

    execute_file(args.filename, args.debug)
