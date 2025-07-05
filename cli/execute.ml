(*
Huitr - a purely functional programming language.
Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*)

let execute_file filename debug =
    print_endline (match debug with
        | true -> "true"
        | false -> "false");
    print_endline filename
