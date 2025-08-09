# Function Composition

```idris
module Tutorial.Functions1.FunctionComposition
```

Functions can be combined in several ways, the most direct probably being the dot (`.`) operator:

```idris
export
square : Integer -> Integer
square n = n * n

times2 : Integer -> Integer
times2 n = 2 * n

squareTimes2 : Integer -> Integer
squareTimes2 = times2 . square
```

Give this a try at the REPL! Does it do what you'd expect?

We could have implemented `squareTimes2` without using the dot operator as follows:

```idris
squareTimes2' : Integer -> Integer
squareTimes2' n = times2 (square n)
```

To get a better insight into how the dot operator works, let's implement our own version of it, instead called `<.>` to avoid name collision with the built-in dot operator:

```idris
private infixr 9 <.>
(<.>) : (b -> c) -> (a -> b) -> a -> c
f <.> g = \x => (f (g x))
```

We'll cover more about functions that take other functions as arguments in the next section, but for now, it suffices to know that our `<.>` is identical to the built-in `.`, and can be used the same way:

```idris
squareTimes2'' : Integer -> Integer
squareTimes2'' = times2 <.> square
```

It is important to note that functions chained by the dot operator are invoked from right to left: `times2 . square` is the same as `\n => times2 (square n)` and not `\n => square (times2 n)`. This can be seen in our definition of `<.>`.

We can conveniently chain several functions using the dot operator to write more complex functions:

```idris
dotChain : Integer -> String
dotChain = reverse . show . square . square . times2 . times2
```

This will first multiply the argument by four, then square it twice before converting it to a string (`show`) and reversing the resulting `String` (functions `show` and `reverse` are part of the Idris *Prelude* and as such are available in every Idris program).

<!-- vi: filetype=idris2:syntax=markdown
-->
