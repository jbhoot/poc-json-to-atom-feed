In writing the Atom feed generators, I referred to the concise [Atom standard document provided by the W3C feed validation service](https://validator.w3.org/feed/check.cgi). 

The generated Atom feed is validated with the [W3C feed validation service](https://validator.w3.org/feed/check.cgi).

## Operations required from ecosystem

- OS operations to read and write files
- JSON parser to read blog index
- XML parser to create Atom feed

## Criteria

- does the stdlib provide the operations I need?
- single-file script
- as a corollary to above, inline management of any dependencies
- statically typed
- functional paradigm
- performance
  - memory usage
  - startup time
  - execution time
- developer experience, development speed
  - bootstrapping
  - editing support
  - fast feedback loop - built-in watcher, fast whole or incremental compilation

`time` results are from the "first" run, i.e., respective compilers/interpreters didn't get a chance to optimise the execution.

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
bash | ~/projects/json-to-atom-feed/scala
$ time scala main.sc
Compiling project (Scala 3.5.0, JVM (21))
Compiled project (Scala 3.5.0, JVM (21))

real    0m1.882s
user    0m0.454s
sys     0m0.115s

bash | ~/projects/json-to-atom-feed/scala
$ time scala main.sc

real    0m0.532s
user    0m0.313s
sys     0m0.063s
```

Scala CLI also informs if a dependency is out-of-date.

### Implementation log

F***ing `java.lang.NullPointerException`! And the world, instead of converging on a null-less programming language, has doubled down on `nil`s.

## OCaml

OCaml comes with both a compiler _and_ an interpreter. Pretty nifty, right? Except that there is no dependency management for a script intended to be run with the interpreter.

I chose to use the interpreter mode anyway.

Pre-requisites (to keep things local):

- opam
- opam local switch to keep things local
- opam install ocamlfind
- opam install ocaml-lsp
- opam install ocamlformat
- .ocamlformat file

No official docs on how to specify dependent modules for interpreter mode. I had to wade through the OCaml forums.

Needs either a local or a global opam switch: `opam switch create .`.

Had to install `opam install ocamlfind` separately, which is needed to recognise and act on `#use "topfind"` directive.

Dependencies cannot be inlined in the sense of how it works in Scala. Sure, `dune` file is not needed if `#require` directive is used to declare the dependencies, but #require acts on already installed libraries. They need to be installed separatedly with opam.

LSP does not recognise #use #require directives and marks them as syntax errors. But otherwise, the LSP does its job. Actually no, not much help from IDE for complex types. ocaml-lsp needs a project to be build with dune. So, if I need IDE assistance, then say bye bye to single-file script. We need a dune file apart from the script file.

`$ ls main.ml | entr -s 'ocaml main.ml'`

```
$ time ocaml main.ml

real    0m0.137s
user    0m0.096s
sys     0m0.015s


$ time ocaml main.ml

real    0m0.118s
user    0m0.104s
sys     0m0.012s
```

Other options:

- [B0caml](https://erratique.ch/software/b0caml)
- [ocamlscript]()
- `utop scriptfile.ml`

## Go

### Preface - tour of Go

I hadn't used Go before this exercise. So I went on an hour-long tour of Go first. But the tour was on the point. There were a few horrors, like, named return values, shared type declaration of arguments in a function declaration (`func ad (x, y int, z string)`), zero values, or lack of distinction between value receiver and pointer receiver of a method at a call-site which also causes a subtle but horrible inconsistency between syntaxes of a receiver argument and a "normal" argument of same value/pointer type on both the declaration site and a call site.

For a language that prides on being very simple and to the point, there are a lot of ways to declare and initialise variables – like `var` statement; `:=` statement; multiple, unfactored var statements; a factored var block – all of them with subtle syntax differences between them.

And inconsistent too, in my eyes. For example, `func add(x, y int, z string)` is ok, but `var x, y int, z string` is not. I am aware that function and variable declarations having to follow the same rules is insensible, but that adds to my point: shared type declaration of function arguments shouldn't exist in the first place.

I have to say, though, while its problems also exist in other languages, for a relatively modern language, these problems should not have existed in Go. For example, the lack of distinction between value receiver and pointer receiver of a method at a call-site is basically a ticking time bomb in a codebase. Heck, that part of the Go tour slowed my pace to a crawl. I may be over-reacting. All of these may be beginner niggles, to be gotten used to over the course of time.

On the other hand, the printers (e.g., `fmt.Println`) are cool.

### Implementation log

No packages to install! Golang's stdlib has all I need - os, file path, json, xml operations. And neatly organised too! `Getwd()` to get current working directory is rightly inside `os` package, while `Join()` to join paths is rightly resides in `path/filepath`.

Just wasted 10 minutes thanks to the lowercase-as-private field convention right away. The fields in JSON file are, of course, all in lowercase. So, that's how I named the corresponding fields in Go's struct. `Unmarshal()`, _without any error_, successfully produces empty structs. Now I understand why an explicit _export_ keyword is way better than this implicit convention. A bit of experience with Go code should alleviate this problem though.

Tagging Go struct with xml attributes was more work than its counterpart in Scala. The tagging approach also doesn't reveal the actual heirarchy of the XML document visually. Both OCaml and Scala have better (admittedly, non-stdlib) tools for that.

Also, the strongly-typed function-based approach to building XML document in OCaml and Scala trumps the stringly-typed tag-based approach to the same in Go, where I spent 10 minutes to figure out why I wasn't getting the tag structure I wanted.

I had to create two structs to represent an Entry - one for JSON, another for XML. Unlike Scala and OCaml, I couldn't find a way to reconcile the fact, within a single datatype, that an entry's url resides at top-level in JSON structure, and as an attribute in a tag `<link href=""></link>` in XML structure.

I don't really mind the OOP-like `x.method` syntax. I think its the lack of this syntax in OCaml that it has to end up using a bulkier `|>` pipe syntax. For example, moonbitlang, despite not being an OOP language, uses a `.` based syntax.

Producing an indented XML is as easy as specifying another argument in the `Marshal()` function! I didn't find one in OCaml and Scala readily.

Incorrect xml tags failed silently. For example, `xml:author>name` should have been `xml:"author>name"`. I felt a warning was warranted at least.

### Conclusion

```
bash | ~/projects/json-to-atom-feed
$ time go run go/main.go
Done

real	0m1.111s
user	0m0.120s
sys	0m0.163s

bash | ~/projects/json-to-atom-feed
$ time go run go/main.go
Done

real	0m0.203s
user	0m0.144s
sys	0m0.139s
```

I will say this: Go's abstractions felt too low-level for the kind of tasks it is advertised for.

Over all, golang excels at everything - rich stdlib, build tooling, editor tooling, single binary distribution and deployment, fast compilation - _EXCEPT_ the _lang_ part.

OCaml provides much higher-level abstractions than Go with similar performance and resource consumption profile. So its not like Go is able to be so lean because of its low-level abstractions. OCaml lags very much behind in stdlib and build tooling than Go though.

## Rust

There is a [nightly feature](https://doc.rust-lang.org/nightly/cargo/reference/unstable.html#script) that allows cargo to run single-file scripts. It needs nightly toolchain `rustup toolchain install nightly`.

Command: `cargo +nightly -Zscript script.rs`

Dependencies, or cargo manifest, can be embedded right at the top of the "script".