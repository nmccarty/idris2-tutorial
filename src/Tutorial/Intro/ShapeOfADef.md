# The Shape of an Idris Definition

```idris
module Tutorial.Intro.ShapeOfADef
```

Now that we have executed our first Idris program, lets talk a bit more about the code we had to write to define it.

A typical top level function in Idris consists of three things:

1. The function's name (`main` in our case)
2. Its type (`IO ()`)
3. Its implementation (`putStrLn "Hello World"`)

Lets explore these parts through a couple of examples, starting out by defining a constant for the largest unsigned 8 bit integer:

```idris
maxBits8 : Bits8
maxBits8 = 255
```

The first line can be read as:

> We'd like to declare a (nullary, or zero argument) function `maxBits8`. It is of type `Bits8`.

This is called the *function declaration*, we declare that there shall be a function of the given name and type.

The second line reads:

> The result of invoking `maxBits8` should be `255`. (As you can see, we can use integer literals for other integral types and not just `Integer`.)

This is called the *function definition*, the function `maxBits8` should behave as described here when being evaluated.

We can inspect this at the REPL, load this source file into an Idris REPL (as described in the previous section, this time using `src/Tutorial/Intro/ShapeOfADef.md` as the source file), and try running the following tests:

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

We previously described `maxBits8` as a *nullary function*, which is just a fancy word for a *constant*. Let's write and test our first *real* function:

```idris
distanceToMax : Bits8 -> Bits8
distanceToMax n = maxBits8 - n
```

This introduces some new syntax and a new kind of type: Function types.

`distanceToMax : Bits8 -> Bits8` can be read as:

> `distanceToMax` is a function of one argument, with type `Bits8`, which returns a result of type `Bits8`.

In the implementation, the argument is given a local identifier (a fancy term for "name") `n`, which is then used in the calculation on the right hand side. Go ahead and try this function at the REPL:

```repl
Tutorial.Intro> distanceToMax 12
243
Tutorial.Intro> :t distanceToMax
Tutorial.Intro.distanceToMax : Bits8 -> Bits8
Tutorial.Intro> :t distanceToMax 12
distanceToMax 12 : Bits8
```

As a final example, let's implement a function that calculates the square of an integer:

```idris
square : Integer -> Integer
square n = n * n
```

We now learn a very important aspect of programming in Idris: Idris is a *statically typed* programming language. We are not allowed to freely mix types as we please, doing so will result in an error message from the type checker (which is part of Idris's compilation process). For instance, if we try the following at the REPL, we will get a type error:

```repl
Tutorial.Intro> square maxBits8
Error: ...
```

This is because `square` expects an argument of type `Integer`, but `maxBits8` is of type `Bits8`. Many primitive types can be converted back and forth between each other (sometimes with the risk of loss of precision) using function `cast` (we will cover `cast` in further detail in the section on Interfaces in the Prelude):

```repl
Tutorial.Intro> square (cast maxBits8)
65025
```

Notice that the above result is much larger than `maxBits8`. This is because `maxBits8` is first converted to an `Integer` of the same value, which is then squared. If we instead squared `maxBits8` directly, the result would be truncated to still fit in the range of valid `Bits8`s:

```repl
Tutorial.Intro> maxBits8 * maxBits8
1
```

<!-- vi: filetype=idris2:syntax=markdown
-->
