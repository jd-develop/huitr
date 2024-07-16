from src.lexer.position import Position


class Token:
    def __init__(
        self,
        token_type: str,
        value: str | None,
        start_pos: Position,
        end_pos: Position,
    ) -> None:
        self.type = token_type
        self.value = value
        self.start_pos = start_pos
        self.end_pos = end_pos

    def __repr__(self) -> str:
        if self.value is not None:
            if self.type == "STRING":
                return f'{self.type}:"{self.value}"'
            return f"{self.type}:{self.value}"
        return f"{self.type}"

    def __str__(self):
        return repr(self)
