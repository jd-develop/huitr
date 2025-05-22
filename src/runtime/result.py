#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Huitr - a purely functional programming language.
# Copyright (C) 2025  3fxcf9, jd-develop

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


# __future__ imports (must be first)
from __future__ import annotations
# Global Python imports
from pprint import pformat
# Huitr API imports
from src.error.error import HuitrError
from src.runtime.value import Value


class RunTimeResult:
    def __init__(self):
        self.value: Value | None = None  # result value
        self.error: HuitrError | None = None  # any error that can have been
                                              # encountered while interpreting

    def reset(self):
        self.value = None
        self.error = None

    def register(self, res: RunTimeResult):
        """Register another result in this result"""
        # we copy the attrs of other result into the self attrs
        if res.error is not None:
            self.error = res.error
        else:
            self.error = None

        return res.value

    def success(self, value: Value):
        """Success: clean up attrs, write new value and return self"""
        self.reset()
        self.value = value
        return self

    def failure(self, error: HuitrError):
        """same as self.success for self.error"""
        self.reset()
        self.error = error
        return self

    def should_return(self):
        """True if there is an error"""
        return self.error is not None

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        return "RTResult: " + pformat({
            "value": self.value,
            "error": self.error,
        })
