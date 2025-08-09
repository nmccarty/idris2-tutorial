# Functions with more than one Argument

```idris
module Tutorial.Functions1.FunctionsWithMultipleArguments
```

Let's implement a function, which checks if its three `Integer` arguments form a [Pythagorean triple](https://en.wikipedia.org/wiki/Pythagorean_triple), we'll need to use a new operator for this: `==`, the equality operator.

```idris
export
isTriple : Integer -> Integer -> Integer -> Bool
isTriple x y z = x * x + y * y == z * z
```

Let's give this a spin at the REPL before we talk a about the types:

```repl
Tutorial.Functions1> isTriple 1 2 3
False
Tutorial.Functions1> isTriple 3 4 5
True
```

As this example demonstrates, the type of a function of several arguments consists of a sequence of argument types (also called *input types*) chained by function arrows (`->`), terminated by an output type (`Bool` in this case).

The implementation looks like a mathematical equation: The arguments are listed on the left hand side of the `=`, and the computation(s) to perform with them are described on the right hand side.

Function implementations in functional programming languages often have a more mathematical look compared to implementations in imperative languages, which often describe not *what* to compute, but instead *how* to compute it by describing an algorithm as a sequence of imperative statements. This imperative style is also available in Idris, and we will explore it in later chapters, but we prefer the declarative style whenever possible.

As shown in the above example, functions can be invoked by passing the arguments separated by whitespace. No parentheses are necessary, unless one of the expressions we pass as the function's arguments contains its own additional whitespace. This syntax provides for particularly ergonomic partial function application, a concept we will cover in a later section.

Note that, unlike `Integer` or `Bits8`, `Bool` is not a primitive data type built into the Idris language but just a normal data type that you could have written yourself. We will cover data type definitions in the next chapter

<!-- vi: filetype=idris2:syntax=markdown
-->
