# The Shape of an Idris Definition

```idris
module Tutorial.Intro.ShapeOfADef
```

Now that we executed our first Idris program, we will talk a bit more about the
code we had to write to define it.

A typical top level function in Idris consists of three things: The function's
name (`main` in our case), its type (`IO ()`) plus its implementation (`putStrLn
"Hello World"`). It is easier to explain these things with a couple of simple
examples. Below, we define a top level constant for the largest unsigned eight
bit integer:

```idris
maxBits8 : Bits8
maxBits8 = 255
```

The first line can be read as: "We'd like to declare  (nullary) function
`maxBits8`. It is of type `Bits8`". This is called the *function declaration*:
we declare that there shall be a function of the given name and type. The second
line reads: "The result of invoking `maxBits8` should be `255`."  (As you can
see, we can use integer literals for other integral types than just `Integer`.)
This is called the *function definition*: Function `maxBits8` should behave as
described here when being evaluated.

We can inspect this at the REPL. Load this source file into an Idris REPL (as
described above), and run the following tests.

```repl
Tutorial.Intro> maxBits8
255
Tutorial.Intro> :t maxBits8
Tutorial.Intro.maxBits8 : Bits8
```

We can also use `maxBits8` as part of another expression:

```repl
Tutorial.Intro> maxBits8 - 100
155
```

I called `maxBits8` a *nullary function*, which is just a fancy word for
*constant*. Let's write and test our first *real* function:

```idris
distanceToMax : Bits8 -> Bits8
distanceToMax n = maxBits8 - n
```

This introduces some new syntax and a new kind of type: Function types.
`distanceToMax : Bits8 -> Bits8` can be read as follows: "`distanceToMax` is a
function of one argument of type `Bits8`, which returns a result of type
`Bits8`". In the implementation, the argument is given a local identifier `n`,
which is then used in the calculation on the right hand side. Again, go ahead
and try this function at the REPL:

```repl
Tutorial.Intro> distanceToMax 12
243
Tutorial.Intro> :t distanceToMax
Tutorial.Intro.distanceToMax : Bits8 -> Bits8
Tutorial.Intro> :t distanceToMax 12
distanceToMax 12 : Bits8
```

As a final example, let's implement a function to calculate the square of an
integer:

```idris
square : Integer -> Integer
square n = n * n
```

We now learn a very important aspect of programming in Idris: Idris is a
*statically typed* programming language. We are not allowed to freely mix types
as we please. Doing so will result in an error message from the type checker
(which is part of the compilation process of Idris).  For instance, if we try
the following at the REPL, we will get a type error:

```repl
Tutorial.Intro> square maxBits8
Error: ...
```

The reason: `square` expects an argument of type `Integer`, but `maxBits8` is of
type `Bits8`. Many primitive types are interconvertible (sometimes with the risk
of loss of precision) using function `cast` (more on the details later):

```repl
Tutorial.Intro> square (cast maxBits8)
65025
```

Note, that in the example above the result is much larger that `maxBits8`. The
reason is, that `maxBits8` is first converted to an `Integer` of the same value,
which is then squared. If on the other hand we squared `maxBits8` directly, the
result would be truncated to still fit the valid range of `Bits8`:

```repl
Tutorial.Intro> maxBits8 * maxBits8
1
```

<!-- vi: filetype=idris2:syntax=markdown
-->
