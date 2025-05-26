(*
Huitr - a purely functional programming language.
Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*)

type lexer_type = {
    source : string;
    mutable cursor_pos : Position.position;
    tokens : Token.token list;
}

let create_lexer
    (_filename : string option)
    (_source : string)
    : lexer_type =
    {
        source = _source;
        cursor_pos = Position.create_position
            _filename
            _source
            0
            0
            0
        ;
        tokens = [];
    }

let current_char
    (lexer : lexer_type)
    : char option =
    Position.get_char(lexer.cursor_pos)
