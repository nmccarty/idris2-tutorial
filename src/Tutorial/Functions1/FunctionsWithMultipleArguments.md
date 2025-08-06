# Functions with more than one Argument

```idris
module Tutorial.Functions1.FunctionsWithMultipleArguments
```

Let's implement a function, which checks if its three `Integer` arguments form a
[Pythagorean triple](https://en.wikipedia.org/wiki/Pythagorean_triple).  We get
to use a new operator for this: `==`, the equality operator.

```idris
export
isTriple : Integer -> Integer -> Integer -> Bool
isTriple x y z = x * x + y * y == z * z
```

Let's give this a spin at the REPL before we talk a bit about the types:

```repl
Tutorial.Functions1> isTriple 1 2 3
False
Tutorial.Functions1> isTriple 3 4 5
True
```

As can be seen from this example, the type of a function of several arguments
consists just of a sequence of argument types (also called *input types*)
chained by function arrows (`->`), which is terminated by an output type (`Bool`
in this case).

The implementation looks a bit like a mathematical equation: We list the
arguments on the left hand side of `=` and describe the computation(s) to
perform with them on the right hand side. Function implementations in functional
programming languages often have this more mathematical look compared to
implementations in imperative  languages, which often describe not *what* to
compute, but *how* to compute it by describing an algorithm as a sequence of
imperative statements. We will later see that this imperative style is also
available in Idris, but whenever possible we prefer the declarative style.

As can be seen in the REPL example, functions can be invoked by passing the
arguments separated by whitespace. No parentheses are necessary unless one of
the expressions we pass as the function's arguments contains itself additional
whitespace.  This comes in very handy when we apply functions only partially
(see later in this chapter).

Note that, unlike `Integer` or `Bits8`, `Bool` is not a primitive data type
built into the Idris language but just a custom data type that you could have
written yourself. We will learn more about declaring new data types in the next
chapter.

<!-- vi: filetype=idris2:syntax=markdown
-->
