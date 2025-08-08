# Interface Basics

```idris
module Tutorial.Interfaces.Basics
```

While function overloading as described above works well, there are use cases,
where this form of overloaded functions leads to a lot of code duplication.

As an example, consider a function `cmp` (short for *compare*, which is already
exported by the *Prelude*), for describing an ordering for the values of type
`String`:

```idris
cmp : String -> String -> Ordering
```

We'd also like to have similar functions for many other data types.  Function
overloading allows us to do just that, but `cmp` is not an isolated piece of
functionality. From it, we can derive functions like `greaterThan'`,
`lessThan'`, `minimum'`, `maximum'`, and many others:

```idris
lessThan' : String -> String -> Bool
lessThan' s1 s2 = LT == cmp s1 s2

greaterThan' : String -> String -> Bool
greaterThan' s1 s2 = GT == cmp s1 s2

minimum' : String -> String -> String
minimum' s1 s2 =
  case cmp s1 s2 of
    LT => s1
    _  => s2

maximum' : String -> String -> String
maximum' s1 s2 =
  case cmp s1 s2 of
    GT => s1
    _  => s2
```

We'd need to implement all of these again for the other types with a `cmp`
function, and most if not all of these implementations would be identical to the
ones written above. That's a lot of code repetition.

One way to solve this is to use higher-order functions.  For instance, we could
define function `minimumBy`, which takes a comparison function as its first
argument and returns the smaller of the two remaining arguments:

```idris
minimumBy : (a -> a -> Ordering) -> a -> a -> a
minimumBy f a1 a2 =
  case f a1 a2 of
    LT => a1
    _  => a2
```

This solution is another proof of how higher-order functions allow us to reduce
code duplication. However, the need to explicitly pass around the comparison
function all the time can get tedious as well.  It would be nice, if we could
teach Idris to come up with such a function on its own.

Interfaces solve exactly this issue. Here's an example:

```idris
public export
interface Comp a where
  comp : a -> a -> Ordering

export
implementation Comp Bits8 where
  comp = compare

export
implementation Comp Bits16 where
  comp = compare
```

The code above defines *interface* `Comp` providing function `comp` for
calculating the ordering for two values of a type `a`, followed by two
*implementations* of this interface for types `Bits8` and `Bits16`. Note, that
the `implementation` keyword is optional.

The `comp` implementations for `Bits8` and `Bits16` both use function `compare`,
which is part of a similar interface from the *Prelude* called `Ord`.

The next step is to look at the type of `comp` at the REPL:

```repl
Tutorial.Interfaces> :t comp
Tutorial.Interfaces.comp : Comp a => a -> a -> Ordering
```

The interesting part in the type signature of `comp` is the initial `Comp a =>`
argument. Here, `Comp` is a *constraint* on type parameter `a`. This signature
can be read as: "For any type `a`, given an implementation of interface `Comp`
for `a`, we can compare two values of type `a` and return an `Ordering` for
these."  Whenever we invoke `comp`, we expect Idris to come up with a value of
type `Comp a` on its own, hence the new `=>` arrow.  If Idris fails to do so, it
will answer with a type error.

We can now use `comp` in the implementations of related functions.  All we have
to do is to also prefix these derived functions with a `Comp` constraint:

```idris
lessThan : Comp a => a -> a -> Bool
lessThan s1 s2 = LT == comp s1 s2

greaterThan : Comp a => a -> a -> Bool
greaterThan s1 s2 = GT == comp s1 s2

minimum : Comp a => a -> a -> a
minimum s1 s2 =
  case comp s1 s2 of
    LT => s1
    _  => s2

maximum : Comp a => a -> a -> a
maximum s1 s2 =
  case comp s1 s2 of
    GT => s1
    _  => s2
```

Note, how the definition of `minimum` is almost identical to `minimumBy`. The
only difference being that in case of `minimumBy` we had to pass the comparison
function as an explicit argument, while for `minimum` it is provided as part of
the `Comp` implementation, which is passed around by Idris for us.

Thus, we have defined all these utility functions once and for all for every
type with an implementation of interface `Comp`.

<!-- vi: filetype=idris2:syntax=markdown
-->
