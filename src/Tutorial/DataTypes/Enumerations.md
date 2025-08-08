# Enumerations

```idris
module Tutorial.DataTypes.Enumerations
```

Let's start with a data type for the days of the week as an example.

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

The declaration above defines a new *type* (`Weekday`) and several new *values* (`Monday` to `Sunday`) of the given type. Go ahead, and verify this at the REPL:

```repl
Tutorial.DataTypes> :t Monday
Tutorial.DataTypes.Monday : Weekday
Tutorial.DataTypes> :t Weekday
Tutorial.DataTypes.Weekday : Type
```

So, `Monday` is of type `Weekday`, while `Weekday` itself is of type `Type`.

It is important to note that a value of type `Weekday` can only ever be one of the values listed above. It is a *type error* to use anything else where a `Weekday` is expected.

## Pattern Matching

In order to use our new data type as a function argument, we need to learn about an important concept in functional programming languages: Pattern matching. Let's implement a function which calculates the successor of a weekday:

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

In order to inspect a `Weekday` argument, we match on the different possible values and return a result for each of them. This is a very powerful concept, as it allows us to match on and extract values from deeply nested data structures. The different cases in a pattern match are inspected from top to bottom, each being compared against the current function argument. Once a matching pattern is found, the computation on the right hand side of this pattern is evaluated. Later patterns are then ignored.

For instance, if we invoke `next` with argument `Thursday`, the first three patterns (`Monday`, `Tuesday`, and `Wednesday`) will be checked against the argument, but they do not match. The fourth pattern is a match, and result `Friday` is being returned. Later patterns are then ignored, even if they would also match the input (this becomes relevant with catch-all patterns, which we will talk about in a moment).

The function above is provably total. Idris knows about the possible values of type `Weekday`, and can therefore figure out that our pattern match covers all possible cases. We can therefore annotate the function with the `total` keyword, and Idris will answer with a type error if it can't verify the function's totality. (Go ahead, and try removing one of the clauses in `next` to get an idea about how an error message from the coverage checker looks like.)

Please remember that these are very strong guarantees from the type checker: Given enough resources, a provably total function will *always* return a result of the given type in a finite amount of time (*resources* here meaning computational resources like memory or, in case of recursive functions, stack space).

## Catch-all Patterns

Sometimes, it is convenient to only match on a subset of the possible values and collect the remaining possibilities in a catch-all clause:

```idris
export
total
isWeekend : Weekday -> Bool
isWeekend Saturday = True
isWeekend Sunday   = True
isWeekend _        = False
```

The final line with the catch-all pattern is only invoked if the argument is not equal to `Saturday` or `Sunday`. Remember: Patterns in a pattern match are matched against the input from top to bottom, and the first match decides which path on the right hand side will be taken.

We can use catch-all patterns to implement an equality test for `Weekday` (we will not yet use the `==` operator for this; this will have to wait until we learn about *interfaces*):

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

Data types like `Weekday` consisting of a finite set of values are sometimes called *enumerations*. The Idris *Prelude* defines some common enumerations for us: for instance, `Bool` and `Ordering`. As with `Weekday`, we can use pattern matching when implementing functions on these types:

```idris
-- this is how `not` is implemented in the *Prelude*
total
negate : Bool -> Bool
negate False = True
negate True  = False
```

The `Ordering` data type describes an ordering relation between two values. For instance:

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

Sometimes we need to perform a computation with one of the arguments and want to pattern match on the result of this computation. We can use *case expressions* in this situation:

```idris
-- returns the larger of the two arguments
total
maxBits8 : Bits8 -> Bits8 -> Bits8
maxBits8 x y =
  case compare x y of
    LT => y
    _  => x
```

The first line of the case expression (`case compare x y of`) will invoke function `compare` with arguments `x` and `y`. On the following (indented) lines, we pattern match on the result of this computation. This is of type `Ordering`, so we expect one of the three constructors `LT`, `EQ`, or `GT` as the result. On the first line, we handle the `LT` case explicitly, while the other two cases are handled with an underscore as a catch-all pattern.

Note that indentation matters here: The case block as a whole must be indented (if it starts on a new line), and the different cases must also be indented by the same amount of whitespace.

Function `compare` is overloaded for many data types. We will learn how this works when we talk about interfaces.

### If Then Else

When working with `Bool`, there is an alternative to pattern matching common to most programming languages:

```idris
total
maxBits8' : Bits8 -> Bits8 -> Bits8
maxBits8' x y = if compare x y == LT then y else x
```

Note that the `if then else` expression always returns a value and, therefore, the `else` branch cannot be dropped. This is different from the behavior in typical imperative languages, where `if` is a statement with possible side effects.

## Naming Conventions: Identifiers

While we are free to use lower-case and upper-case identifiers for function names, type- and data constructors must be given upper-case identifiers in order not to confuse Idris (operators are also fine). For instance, the following data definition is not valid, and Idris will complain that it expected upper-case identifiers:

```repl
data foo = bar | baz
```

The same goes for similar data definitions like records and sum types (both will be explained below):

```repl
-- not valid Idris
record Foo where
  constructor mkfoo
```

On the other hand, we typically use lower-case identifiers for function names, unless we plan to use them mostly during type checking (more on this later). This is not enforced by Idris, however, so if you are working in a domain where upper-case identifiers are preferable, feel free to use those:

```idris
foo : Bits32 -> Bits32
foo = (* 2)

Bar : Bits32 -> Bits32
Bar = foo
```

<!-- vi: filetype=idris2:syntax=markdown
-->
