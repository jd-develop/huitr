(lang dune 3.16)
(name huitr)
(generate_opam_files true)

(source (github jd-develop/huitr))

(license "GPL-3.0-or-later")

(authors
 "3fxcf9"
 "jd-develop"
 "Hugo Vangilluwen")
(maintainers
 "3fxcf9"
 "jd-develop"
 "Hugo Vangilluwen")

(package
 (name huitr)
 (synopsis "Huitr - a purely functional programming language")
 (depends cmdliner))
