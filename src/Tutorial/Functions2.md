# Functions Part 2

So far, we learned about the core features of the Idris language, which it has in common with several other pure, strongly typed programming languages like Haskell: (Higher-order) Functions, algebraic data types, pattern matching, parametric polymorphism (generic types and functions), and ad hoc polymorphism (interfaces and constrained functions).

In this chapter, we start to dissect Idris functions and their types for real. We learn about implicit arguments, named arguments, as well as erasure and quantities. But first, we'll look at `let` bindings and `where` blocks, which help us implement functions too complex to fit on a single line of code. Let's get started!

```idris
module Tutorial.Functions2

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->
