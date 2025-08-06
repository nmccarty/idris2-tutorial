# Anonymous Functions

```idris
module Tutorial.Functions1.Lambdas
```

Sometimes we'd like to pass a small custom function to a higher-order function
without bothering to write a top level definition. For instance, in the
following example, function `someTest` is very specific and probably not very
useful in general, but we'd still like to pass it to higher-order function
`testSquare`:

```idris
someTest : Integer -> Bool
someTest n = n >= 3 || n <= 10
```

Here's, how to pass it to `testSquare`:

```repl
Tutorial.Functions1> testSquare someTest 100
True
```

Instead of defining and using `someTest`, we can use an anonymous function:

```repl
Tutorial.Functions1> testSquare (\n => n >= 3 || n <= 10) 100
True
```

Anonymous functions are sometimes also called *lambdas* (from [lambda
calculus](https://en.wikipedia.org/wiki/Lambda_calculus)), and the backslash is
chosen since it resembles the Greek letter *lambda*. The `\n =>` syntax
introduces a new anonymous function of one argument called `n`, the
implementation of which is on the right hand side of the function arrow.  Like
other top level functions, lambdas can have more than one arguments, separated
by commas: `\x,y => x * x + y`.  When we pass lambdas as arguments to
higher-order functions, they typically need to be wrapped in parentheses or
separated by the dollar operator `($)` (see the next section about this).

Note that, in a lambda, arguments are not annotated with types, so Idris has to
be able to infer them from the current context.

<!-- vi: filetype=idris2:syntax=markdown
-->
