# Higher-order Functions

```idris
module Tutorial.Functions1.HigherOrder

import Tutorial.Functions1.FunctionComposition
```

Functions can take other functions as arguments. This is an incredibly powerful concept and we can go crazy with this very easily. But for sanity's sake, we'll start slowly:

```idris
isEven : Integer -> Bool
isEven n = mod n 2 == 0

testSquare : (Integer -> Bool) -> Integer -> Bool
testSquare fun n = fun (square n)
```

First `isEven` uses the `mod` function to check, whether an integer is divisible by two. But the interesting function is `testSquare`. It takes two arguments: The first argument is of type *function from `Integer` to `Bool`*, and the second of type `Integer`. This second argument is squared before being passed to the first argument. Again, give this a go at the REPL:

```repl
Tutorial.Functions1> testSquare isEven 12
True
```

Take your time to understand what's going on here. We pass function `isEven` as an argument to `testSquare`. The second argument is an integer, which will first be squared and then passed to `isEven`. While this is not very interesting, we will see lots of use cases for passing functions as arguments to other functions.

I said above, we could go crazy pretty easily. Consider for instance the following example:

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

You might be surprised about this behavior, so we'll try and break it down. The following two expressions are identical in their behavior:

```idris
expr1 : Integer -> Integer
expr1 = (twice . twice . twice . twice) square

expr2 : Integer -> Integer
expr2 = twice (twice (twice (twice square)))
```

So, `square` raises its argument to the 2nd power, `twice square` raises it to its 4th power (by invoking `square` twice in succession), `twice (twice square)` raises it to its 16th power (by invoking `twice square` twice in succession), and so on, until `twice (twice (twice (twice square)))` raises it to its 65536th power resulting in an impressively huge result.

<!-- vi: filetype=idris2:syntax=markdown
-->
