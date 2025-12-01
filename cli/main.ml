(*
 * Huitr - a purely functional programming language.
 * Copyright (C) 2024-2025  3fxcf9, jd-develop, Hugo Vangilluwen
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)

(* let () = Huitr_interpreter.Lexer.tokenize *)


open Cmdliner


let filename =
  Arg.(
    required &
    pos 0 (some string) None &
    info []
    ~doc:"File where the Huitr program is (stdin for standard input)"
    ~docv:"FILENAME"
  )

let debug =
  Arg.(
    value &
    flag &
    info ["d"; "debug"]
    ~doc:"print tokens structure"
  )

let backtrace =
  Arg.(
    value &
    flag &
    info ["b"; "backtrace"]
    ~doc:"prints backtrace on error"
  )

let command =
  let version = "0.1.0" in
  let doc = "Huitr file interpreter" in
  let man = [
    `S Manpage.s_description;
    `P "Execute a Huitr program written in a file";
    `S Manpage.s_see_also;
    `P "Huitr – a purely functional programming language.";
    `P "“Huitr” stands for “Huitr is tough to read”."
  ] in

  Cmd.v
    (Cmd.info "huitr" ~version ~doc ~man)
    Term.(const Execute.execute_file $ filename $ debug $ backtrace)

let main () = Cmd.eval command
let () = if !Sys.interactive then () else exit (main ())
