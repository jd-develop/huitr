(*
Huitr - a purely functional programming language.
Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*)

(* FIXME : change file name *)

let is_digit (c : char) : bool =
    let int_c : int = int_of_char c in
    int_c >= 48 (* = '0' *)
    && int_c <= 57 (* = '9' *)

let is_char_identifier (c : char) : bool =
    let int_c : int = int_of_char c in
    (
        int_c >= 65 (* = 'A' *)
        && int_c <= 90 (* = 'Z' *)
    ) || (
        int_c >= 97 (* = 'A' *)
        && int_c <= 122 (* = 'Z' *)
    ) || int_c = 95 (* = '_' *)
