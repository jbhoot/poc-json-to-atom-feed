## Criteria

- single-file script
- as a corollary to above, inline management of any dependencies
- statically typed
- functional paradigm
- low memory usage
- low startup time
- high performance
- fast feedback loop - built-in watcher, fast whole or incremental compilation
- IDE support

## Scala

Pre-requisites:

- Scala 3.5.0
- Metals LSP
- .scalafmt.conf

Official docs exist on how to develop scripts.

Scala 3.5.0 provides a literally seamless set of tools for scripting. Only requirement is that Scala 3.5.0 itself be installed and accessible from PATH.

Inline dependency management is the best of all. Scala automatically installs and make the package available, IDE autocompletion and all, once the dependency is specified in the script using `//>` directive.

The feedback loop driven development was very enjoyable.

Official Scala docs already had recommende libraries for this task - os-lib, uPickle. I add another - Scalatags. Thanks to Scala 3.5.0's inline dependency management for single-file scripts, dep management was next to nothing.

`scala run -w main.sc`

```
$ time scala main.sc
real    0m0.529s
user    0m0.306s
sys     0m0.061s
```

## OCaml

Pre-requisites (to keep things local):
- opam
- opam local switch to keep things local
- opam install ocamlfind
- opam install ocaml-lsp
- opam install ocamlformat
- .ocamlformat file

No official docs. I had to wade through the OCaml forums.

Needs either a local or a global opam switch: `opam switch create .`.

Had to install `opam install ocamlfind` separately, which is needed to recognise and act on `#use "topfind"` directive.

Dependencies cannot be inlined in the sense of how it works in Scala. Sure, `dune` file is not needed if `#require` directive is used to declare the dependencies, but #require acts on already installed libraries. They need to be installed separatedly with opam.

LSP does not recognise #use #require directives and marks them as syntax errors. But otherwise, the LSP does its job. Actually no, not much help from IDE for complex types. ocaml-lsp needs a project to be build with dune. So, if I need IDE assistance, then say bye bye to single-file script. We need a dune file apart from the script file.

`$ ls main.ml | entr -s 'ocaml main.ml'`

Other options:

- [B0caml](https://erratique.ch/software/b0caml)
- [ocamlscript]()
- `utop scriptfile.ml`
