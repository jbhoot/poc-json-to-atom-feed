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

As long as the build artifacts are ignored, Scala 3.5.0 provides a literally seamless set of tools.

The feedback loop driven development was very enjoyable.

Official Scala docs already had recommende libraries for this task - os-lib, uPickle. I add another - Scalatags. Thanks to Scala 3.5.0's inline dependency management for single-file scripts, dep management was next to nothing.

```
$ time scala main.sc
real    0m0.529s
user    0m0.306s
sys     0m0.061s
```