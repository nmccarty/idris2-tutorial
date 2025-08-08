# IO: Programming with Side Effects

So far, all our examples and exercises dealt with pure, total functions. We didn't read or write content from or to files, nor did we write any messages to the standard output. It is time to change that and learn, how we can write effectful programs in Idris.

```idris hide
module Tutorial.IO

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->
