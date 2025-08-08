# More About Interfaces

```idris
module Tutorial.Interfaces.More

import Tutorial.Interfaces.Basics
```

In the last section, we learned about the very basics of interfaces: Why they
are useful and how to define and implement them.  In this section, we will learn
about some slightly advanced concepts: Extending interfaces, interfaces with
constraints, and default implementations.

## Extending Interfaces

Some interfaces form a kind of hierarchy. For instance, for the `Concat`
interface used in exercise 4, there might be a child interface called `Empty`,
for those types, which have a neutral element with relation to concatenation.
In such a case, we make an implementation of `Concat` a prerequisite for
implementing `Empty`:

```idris
interface Concat a where
  concat : a -> a -> a

implementation Concat String where
  concat = (++)

interface Concat a => Empty a where
  empty : a

implementation Empty String where
  empty = ""
```

`Concat a => Empty a` should be read as: "An implementation of `Concat` for type
`a` is a *prerequisite* for there being an implementation of `Empty` for `a`."
But this also means that, whenever we have an implementation of interface
`Empty`, we *must* also have an implementation of `Concat` and can invoke the
corresponding functions:

```idris
concatListE : Empty a => List a -> a
concatListE []        = empty
concatListE (x :: xs) = concat x (concatListE xs)
```

Note, how in the type of `concatListE` we only used an `Empty` constraint, and
how in the implementation we were still able to invoke both `empty` and
`concat`.

## Constrained Implementations

Sometimes, it is only possible to implement an interface for a generic type, if
its type parameters implement this interface as well. For instance, implementing
interface `Comp` for `Maybe a` makes sense only if type `a` itself implements
`Comp`. We can constrain interface implementations with the same syntax we use
for constrained functions:

```idris
implementation Comp a => Comp (Maybe a) where
  comp Nothing  Nothing  = EQ
  comp (Just _) Nothing  = GT
  comp Nothing  (Just _) = LT
  comp (Just x) (Just y) = comp x y
```

This is not the same as extending an interface, although the syntax looks very
similar. Here, the constraint lies on a *type parameter* instead of the full
type.  The last line in the implementation of `Comp (Maybe a)` compares the
values stored in the two `Just`s. This is only possible, if there is a `Comp`
implementation for these values as well. Go ahead, and remove the `Comp a`
constraint from the above implementation. Learning to read and understand Idris'
type errors is important for fixing them.

The good thing is, that Idris will solve all these constraints for us:

```idris
maxTest : Maybe Bits8 -> Ordering
maxTest = comp (Just 12)
```

Here, Idris tries to find an implementation for `Comp (Maybe Bits8)`.  In order
to do so, it needs an implementation for `Comp Bits8`.  Go ahead, and replace
`Bits8` in the type of `maxTest` with `Bits64`, and have a look at the error
message Idris produces.

## Default Implementations

Sometimes, we'd like to pack several related functions in an interface to allow
programmers to implement each in the most efficient way, although they *could*
be implemented in terms of each other. For instance, consider an interface
`Equals` for comparing two values for equality, with functions `eq` returning
`True` if two values are equal and `neq` returning `True` if they are not.
Surely, we can implement `neq` in terms of `eq`, so most of the time when
implementing `Equals`, we will only implement the latter.  In this case, we can
give an implementation for `neq` already in the definition of `Equals`:

```idris
interface Equals a where
  eq : a -> a -> Bool

  neq : a -> a -> Bool
  neq a1 a2 = not (eq a1 a2)
```

If in an implementation of `Equals` we only implement `eq`, Idris will use the
default implementation for `neq` as shown above:

```idris
Equals String where
  eq = (==)
```

If on the other hand we'd like to provide explicit implementations for both
functions, we can do so as well:

```idris
Equals Bool where
  eq True True   = True
  eq False False = True
  eq _ _         = False

  neq True  False = True
  neq False True  = True
  neq _ _         = False
```

<!-- vi: filetype=idris2:syntax=markdown
-->
