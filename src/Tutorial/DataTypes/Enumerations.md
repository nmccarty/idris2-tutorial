# Enumerations

```idris
module Tutorial.DataTypes.Enumerations
```

Enumerations, the most basic form of a more general concept known as sum types or a [tagged unions](https://en.wikipedia.org/wiki/Tagged_union) are one the two basic forms of algebraic data types. Enumerations are data types that can store one of several specified options as their values.

Lets define a basic enumeration over the days of the week as a first example. This very basic form of enumeration may be familiar to you from other languages:

```idris
public export
data Weekday = Monday
             | Tuesday
             | Wednesday
             | Thursday
             | Friday
             | Saturday
             | Sunday
```

The declaration above defines a new *type* (`Weekday`) and several new *values* (`Monday` through `Sunday`) of the given type (`Weekday`). Go ahead and try this type out this at the REPL:

> [!NOTE]
> Notice that the value `Monday` has type `Weekday`, while `Weekday` itself has type `Type`.

```repl
Tutorial.DataTypes.Enumerations> :t Monday
Tutorial.DataTypes.Enumerations.Monday : Weekday
Tutorial.DataTypes.Enumerations> :t Weekday
Tutorial.DataTypes.Enumerations.Weekday : Type
```

It is important to note that a value of type `Weekday` can only ever be one of the values listed above, it is a *type error* to use any other value where a `Weekday` is expected.

## Pattern Matching

In order to make effective use of our new data type as a function argument, we need to introduce one of the fundamental building blocks of functions in functional programming languages: Pattern matching.

Let's implement a function which calculates the successor of a weekday:

```idris
total
next : Weekday -> Weekday
next Monday    = Tuesday
next Tuesday   = Wednesday
next Wednesday = Thursday
next Thursday  = Friday
next Friday    = Saturday
next Saturday  = Sunday
next Sunday    = Monday
```

In order to inspect an argument of type `Weekday`, we need to *pattern match* on the different possible values and return a result for each of them.

This is a very powerful concept, as it allows us to match on and extract values from deeply nested data structures. The compiler works through the different cases in a pattern match from top to bottom, with each potential match being compared against the current function argument. Once a matching pattern is found, the computation on the right hand side of the matching pattern is evaluated, with any further patterns then being ignored.

For instance, if we invoke `next` with `Thursday` given as the argument, the first three patterns (`Monday`, `Tuesday`, and `Wednesday`) will be checked against the argument, but they do not match. However, the fourth pattern, `Thursday`, is a match, and as a result `Friday` is returned. The later patterns are then ignored, even if they would also match the input (this becomes relevant with catch-all patterns, which we will talk about in a moment).

Our `next` function is provably total. Since Idris knows about the possible values of type `Weekday`, it can therefore figure out that our pattern match covers all the possible cases. We can therefore annotate the function with the `total` keyword, and Idris will fail to compile with a type error if it can't verify the function's totality.

> [!NOTE]
> The totality and type checkers provide a very strong set of guarantees here. Given enough resources, a provably total function will *always* return a result of the specified type in a finite amount of time (*resources* here meaning computational resources like memory, time, or, in case of recursive functions, stack space).

Try removing one of the clauses in `next` to get a feel for what error messages from the coverage checker look like.

## Catch-all Patterns

Sometimes, it is convenient to only match on a subset of the possible values of a type, and collect the remaining possibilities in a catch-all clause:

```idris
export
total
isWeekend : Weekday -> Bool
isWeekend Saturday = True
isWeekend Sunday   = True
isWeekend _        = False
```

The final line with the catch-all pattern (here we use `_` since we want to ignore the exact value of the argument in this option, but we could also put a variable name here) is only invoked if the argument is not equal to either `Saturday` or `Sunday`. Remember: Patterns in a pattern match are matched against the input from top to bottom, and the first match decides which path on the right hand side will be taken.

We can use catch-all patterns to implement a function that tests values of `Weekday` for equality (we will use the `==` operator for this here, we will explore that in the section on interfaces). To do this, we define pattern matches for each case where the two arguments are the same `Weekday`, returning `True` in those branches, then specifying a catch-all branch at the end that returns `False`:

```idris
total
eqWeekday : Weekday -> Weekday -> Bool
eqWeekday Monday Monday        = True
eqWeekday Tuesday Tuesday      = True
eqWeekday Wednesday Wednesday  = True
eqWeekday Thursday Thursday    = True
eqWeekday Friday Friday        = True
eqWeekday Saturday Saturday    = True
eqWeekday Sunday Sunday        = True
eqWeekday _ _                  = False
```

## Enumeration Types in the Prelude

Data types like `Weekday` that consist of a finite set of values are sometimes called *enumerations*. The Idris *Prelude* defines some common enumerations for us, such as `Bool` and `Ordering`. As with `Weekday`, we can use pattern matching to implement functions over these types:

```idris
-- this is how `not` is implemented in the *Prelude*
total
negate : Bool -> Bool
negate False = True
negate True  = False
```

The `Ordering` data type describes an ordering relation (defining a notion of "less than", "equal to", and "greater than") between two values. For instance:

```idris
total
compareBool : Bool -> Bool -> Ordering
compareBool False False = EQ
compareBool False True  = LT
compareBool True True   = EQ
compareBool True False  = GT
```

Here, `LT` means that the first argument is *less than* the second, `EQ` means that the two arguments are *equal* and `GT` means, that the first argument is *greater than* the second.

## Case Expressions

Sometimes, instead of pattern matching directly on the arguments to a function, we instead want to perform some computation with them first, and then pattern match on the result of that computation. *Case expressions* provide the ability to perform pattern in such a situation:

```idris
-- returns the larger of the two arguments
total
maxBits8 : Bits8 -> Bits8 -> Bits8
maxBits8 x y =
  case compare x y of
    LT => y
    _  => x
```

The first line of the case expression (`case compare x y of`) will invoke the function `compare` with arguments `x` and `y`. On the following (indented) lines, we pattern match on the result of this computation, much as we would in the top level of our function declaration, only using `=>` to separate the pattern from the resulting expression to be evaluated instead of `=`. The value we get from calling `compare` is of type `Ordering`, so we expect one of the three constructors `LT`, `EQ`, or `GT` as the result. On the first line, we handle the `LT` case explicitly, while the other two cases are handled with an underscore as a catch-all pattern.

It is important to note that the indentation matters here, the case block as a whole must be indented (if it starts on a new line), and the each case must be indented by the same amount of whitespace as all of the other cases.

The `compare` function is overloaded for many data types, which we will explore in depth in the section on interfaces.

### If Then Else

When working with `Bool`, there is an alternative to pattern matching common to most programming languages:

```idris
total
maxBits8' : Bits8 -> Bits8 -> Bits8
maxBits8' x y = if compare x y == LT then y else x
```

Note that the `if then else` expression *always* returns a value and, unlike in typical imperative languages where a bare `if` may be desirable for executing side effects, the `else` branch cannot be dropped.

## Naming Conventions: Identifiers

While we are free to use lower-case and upper-case identifiers for function names, type and data constructors must be given upper-case identifiers in order not to confuse Idris (operators are also fine). For instance, the following data definition is not valid, and Idris will complain that it expected upper-case identifiers:

```repl
data foo = bar | baz
```

The same goes for similar data definitions like records and sum types (both will be explained below):

```repl
-- not valid Idris
record Foo where
  constructor mkfoo
```

On the other hand, we typically use lower-case identifiers for function names, unless we plan to use them mostly at the type level (which will be covered in a future section). However, this is not enforced by Idris, so if you are working in a domain where upper-case identifiers are preferable, feel free to use those:

```idris
foo : Bits32 -> Bits32
foo = (* 2)

Bar : Bits32 -> Bits32
Bar = foo
```

<!-- vi: filetype=idris2:syntax=markdown
-->
