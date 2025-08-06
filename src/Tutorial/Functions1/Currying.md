# Currying

```idris
module Tutorial.Functions1.Currying

import Tutorial.Functions1.FunctionsWithMultipleArguments
```

Once we start using higher-order functions, the concept of partial function
application (also called *currying* after mathematician and logician Haskell
Curry) becomes very important.

Load this file in a REPL session and try the following:

```repl
Tutorial.Functions1> :t testSquare isEven
testSquare isEven : Integer -> Bool
Tutorial.Functions1> :t isTriple 1
isTriple 1 : Integer -> Integer -> Bool
Tutorial.Functions1> :t isTriple 1 2
isTriple 1 2 : Integer -> Bool
```

Note, how in Idris we can partially apply a function with more than one argument
and as a result get a new function back. For instance, `isTriple 1` applies
argument `1` to function `isTriple` and as a result returns a new function of
type `Integer -> Integer -> Bool`. We can even use the result of such a
partially applied function in a new top level definition:

```idris
partialExample : Integer -> Bool
partialExample = isTriple 3 4
```

And at the REPL:

```repl
Tutorial.Functions1> partialExample 5
True
```

We already used partial function application in our `twice` examples above to
get some impressive results with very little code.

<!-- vi: filetype=idris2:syntax=markdown
-->
