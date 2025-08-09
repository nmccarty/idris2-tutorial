# Higher-order Functions

```idris
module Tutorial.Functions1.HigherOrder

import Tutorial.Functions1.FunctionComposition
```

Functions can take other functions as arguments. This is an incredibly powerful concept which can be taken to an extreme very easily, but to keep things simple, we'll start slowly:

```idris
isEven : Integer -> Bool
isEven n = mod n 2 == 0

testSquare : (Integer -> Bool) -> Integer -> Bool
testSquare fun n = fun (square n)
```

In the above definition, `isEven` uses the `mod` function to check if an integer is divisible by two, and is defined in the same straightforward manor as the other functions we have defined so far.

`testSquare`, however, is more interesting. It takes two arguments, the first argument having the type of a *function from `Integer` to `Bool`*, and the second having type `Integer`. The second argument is squared before being passed to the first argument.

Let's give this a go at the REPL:

```repl
Tutorial.Functions1> testSquare isEven 12
True
```

Take your time to understand what's going on here. We pass the function `isEven` as the first argument to `testSquare`. The second argument is an integer, which will first be squared and then passed to `isEven`. While this particular example is not very interesting, we will cover lots of use cases for passing functions as arguments to other functions as we continue.

As noted earlier, things can go to an extreme pretty easily. Consider the following example:

```idris
twice : (Integer -> Integer) -> Integer -> Integer
twice f n = f (f n)
```

And at the REPL:

```repl
Tutorial.Functions1> twice square 2
16
Tutorial.Functions1> (twice . twice) square 2
65536
Tutorial.Functions1> (twice . twice . twice . twice) square 2
*** huge number ***
```

You might be surprised about this behavior, so let's break it down. The following two expressions are identical in their behavior:

```idris
expr1 : Integer -> Integer
expr1 = (twice . twice . twice . twice) square

expr2 : Integer -> Integer
expr2 = twice (twice (twice (twice square)))
```

Let's walk through this:

- `square` raises its argument to the 2nd power
- `twice square` applies `square` twice, raising its argument to the 4th power
- `twice (twice square)` raises it to the 16th power, by invoking `twice square` twice
- And so on until `twice (twice (twice (twice square)))`, which raises it's argument to the 65536th power, giving an impressively huge result

<!-- vi: filetype=idris2:syntax=markdown
-->
