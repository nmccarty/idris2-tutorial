# Interfaces in the *Prelude*

```idris
module Tutorial.Interfaces.Prelude
```

The Idris *Prelude* provides several interfaces plus implementations that are useful in almost every non-trivial program. I'll introduce the basic ones here. The more advanced ones will be discussed in later chapters.

Most of these interfaces come with associated mathematical laws, and implementations are assumed to adhere to these laws. These laws will be given here as well.

`Eq`

Probably the most often used interface, `Eq` corresponds to interface `Equals` we used above as an example. Instead of `eq` and `neq`, `Eq` provides two operators `(==)` and `(/=)` for comparing two values of the same type for being equal or not. Most of the data types defined in the *Prelude* come with an implementation of `Eq`, and whenever programmers define their own data types, `Eq` is typically one of the first interfaces they implement.

`Eq` Laws

We expect the following laws to hold for all implementations of `Eq`:

- `(==)` is *reflexive*: `x == x = True` for all `x`. This means, that every value is equal to itself.

- `(==)` is *symmetric*: `x == y = y == x` for all `x` and `y`. This means, that the order of arguments passed to `(==)` does not matter.

- `(==)` is *transitive*: From `x == y = True` and `y == z = True` follows `x == z = True`.

- `(/=)` is the negation of `(==)`: `x == y = not (x /= y)` for all `x` and `y`.

In theory, Idris has the power to verify these laws at compile time for many non-primitive types. However, out of pragmatism this is not required when implementing `Eq`, since writing such proofs can be quite involved.

`Ord`

The pendant to `Comp` in the *Prelude* is interface `Ord`. In addition to `compare`, which is identical to our own `comp` it provides comparison operators `(>=)`, `(>)`, `(<=)`, and `(<)`, as well as utility functions `max` and `min`. Unlike `Comp`, `Ord` extends `Eq`, so whenever there is an `Ord` constraint, we also have access to operators `(==)` and `(/=)` and related functions.

`Ord` Laws

We expect the following laws to hold for all implementations of `Ord`:

- `(<=)` is *reflexive* and *transitive*.
- `(<=)` is *antisymmetric*: From `x <= y = True` and `y <= x = True` follows `x == y = True`.
- `x <= y = y >= x`.
- `x < y = not (y <= x)`
- `x > y = not (y >= x)`
- `compare x y = EQ` => `x == y = True`
- `compare x y == GT = x > y`
- `compare x y == LT = x < y`

`Semigroup` and `Monoid`

`Semigroup` is the pendant to our example interface `Concat`, with operator `(<+>)` (also called *append*) corresponding to function `concat`.

Likewise, `Monoid` corresponds to `Empty`, with `neutral` corresponding to `empty`.

These are incredibly important interfaces, which can be used to combine two or more values of a data type into a single value of the same type. Examples include but are not limited to addition or multiplication of numeric types, concatenation of sequences of data, or sequencing of computations.

As an example, consider a data type for representing distances in a geometric application. We could just use `Double` for this, but that's not very type safe. It would be better to use a single field record wrapping values type `Double`, to give such values clear semantics:

```idris
record Distance where
  constructor MkDistance
  meters : Double
```

There is a natural way for combining two distances: We sum up the values they hold. This immediately leads to an implementation of `Semigroup`:

```idris
Semigroup Distance where
  x <+> y = MkDistance $ x.meters + y.meters
```

It is also immediately clear, that zero is the neutral element of this operation: Adding zero to any value does not affect the value at all. This allows us to implement `Monoid` as well:

```idris
Monoid Distance where
  neutral = MkDistance 0
```

`Semigroup` and `Monoid` Laws

We expect the following laws to hold for all implementations of `Semigroup` and `Monoid`:

- `(<+>)` is *associative*: `x <+> (y <+> z) = (x <+> y) <+> z`, for all values `x`, `y`, and `z`.
- `neutral` is the *neutral element* with relation to `(<+>)`: `neutral <+> x = x <+> neutral = x`, for all `x`.

`Show`

The `Show` interface is mainly used for debugging purposes, and is supposed to display values of a given type as a string, typically closely resembling the Idris code used to create the value. This includes the proper wrapping of arguments in parentheses where necessary. For instance, experiment with the output of the following function at the REPL:

```idris
showExample : Maybe (Either String (List (Maybe Integer))) -> String
showExample = show
```

And at the REPL:

```repl
Tutorial.Interfaces> showExample (Just (Right [Just 12, Nothing]))
"Just (Right [Just 12, Nothing])"
```

We will learn how to implement instances of `Show` in an exercise.

Overloaded Literals

Literal values in Idris, such as integer literals (`12001`), string literals (`"foo bar"`), floating point literals (`12.112`), and character literals (`'$'`) can be overloaded. This means, that we can create values of types other than `String` from just a string literal. The exact workings of this has to wait for another section, but for many common cases, it is sufficient for a value to implement interfaces `FromString` (for using string literals), `FromChar` (for using character literals), or `FromDouble` (for using floating point literals). The case of integer literals is special, and will be discussed in the next section.

Here is an example of using `FromString`. Assume, we write an application where users can identify themselves with a username and password. Both consist of strings of characters, so it is pretty easy to confuse and mix up the two things, although they clearly have very different semantics. In these cases, it is advisable to come up with new types for the two, especially since getting these things wrong is a security concern.

Here are three example record types to do this:

```idris
record UserName where
  constructor MkUserName
  name : String

record Password where
  constructor MkPassword
  value : String

record User where
  constructor MkUser
  name     : UserName
  password : Password
```

In order to create a value of type `User`, even for testing, we'd have to wrap all strings using the given constructors:

```idris
hock : User
hock = MkUser (MkUserName "hock") (MkPassword "not telling")
```

This is rather cumbersome, and some people might think this to be too high a price to pay just for an increase in type safety (I'd tend to disagree). Luckily, we can get the convenience of string literals back very easily:

```idris
FromString UserName where
  fromString = MkUserName

FromString Password where
  fromString = MkPassword

hock2 : User
hock2 = MkUser "hock" "not telling"
```

Numeric Interfaces

The *Prelude* also exports several interfaces providing the usual arithmetic operations. Below is a comprehensive list of the interfaces and the functions each provides:

- `Num`

  - `(+)` : Addition
  - `(*)` : Multiplication
  - `fromInteger` : Overloaded integer literals

- `Neg`

  - `negate` : Negation
  - `(-)` : Subtraction

- `Integral`

  - `div` : Integer division
  - `mod` : Modulo operation

- `Fractional`

  - `(/)` : Division
  - `recip` : Calculates the reciprocal of a value

As you can see: We need to implement interface `Num` to use integer literals for a given type. In order to use negative integer literals like `-12`, we also have to implement interface `Neg`.

`Cast`

The last interface we will quickly discuss in this section is `Cast`. It is used to convert values of one type to values of another via function `cast`. `Cast` is special, since it is parameterized over *two* type parameters unlike the other interfaces we looked at so far, with only one type parameter.

So far, `Cast` is mainly used for interconversion between primitive types in the standard libraries, especially numeric types. When you look at the implementations exported from the *Prelude* (for instance, by invoking `:doc Cast` at the REPL), you'll see that there are dozens of implementations for most pairings of primitive types.

Although `Cast` would also be useful for other conversions (for going from `Maybe` to `List` or for going from `Either e` to `Maybe`, for instance), the *Prelude* and *base* seem not to introduce these consistently. For instance, there are `Cast` implementations from going from `SnocList` to `List` and vice versa, but not for going from `Vect n` to `List`, or for going from `List1` to `List`, although these would be just as feasible.

<!-- vi: filetype=idris2:syntax=markdown
-->
