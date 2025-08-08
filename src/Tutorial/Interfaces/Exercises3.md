# Exercises part 3

These exercises are meant to make you comfortable with
implementing interfaces for your own data types, as you
will have to do so regularly when writing Idris code.

While it is immediately clear why interfaces like
`Eq`, `Ord`, or `Num` are useful, the usability of
`Semigroup` and `Monoid` may be harder to appreciate at first.
Therefore, there are several exercises where you'll implement
different instances for these.

1. Define a record type `Complex` for complex numbers, by pairing
   two values of type `Double`.
   Implement interfaces `Eq`, `Num`, `Neg`, and `Fractional` for `Complex`.

2. Implement interface `Show` for `Complex`. Have a look at data type `Prec`
   and function `showPrec` and how these are used in the
   *Prelude* to implement instances for `Either` and `Maybe`.

   Verify the correct behavior of your implementation by wrapping
   a value of type `Complex` in a `Just` and `show` the result at
   the REPL.

3. Consider the following wrapper for optional values:

   ```idris
   record First a where
     constructor MkFirst
     value : Maybe a
   ```

   Implement interfaces `Eq`, `Ord`, `Show`, `FromString`, `FromChar`, `FromDouble`,
   `Num`, `Neg`, `Integral`, and `Fractional` for `First a`. All of these will require
   corresponding constraints on type parameter `a`. Consider implementing and
   using the following utility functions where they make sense:

   ```idris
   pureFirst : a -> First a

   mapFirst : (a -> b) -> First a -> First b

   mapFirst2 : (a -> b -> c) -> First a -> First b -> First c
   ```

4. Implement interfaces `Semigroup` and `Monoid` for `First a` in such a way,
   that `(<+>)` will return the first non-nothing argument and `neutral` is
   the corresponding neutral element. There must be no constraints on type
   parameter `a` in these implementations.

5. Repeat exercises 3 and 4 for record `Last`. The `Semigroup` implementation
   should return the last non-nothing value.

   ```idris
   record Last a where
     constructor MkLast
     value : Maybe a
   ```

6. Function `foldMap` allows us to map a function returning a `Monoid` over
   a list of values and accumulate the result using `(<+>)` at the same time.
   This is a very powerful way to accumulate the values stored in a list.
   Use `foldMap` and `Last` to extract the last element (if any) from a list.

   Note, that the type of `foldMap` is more general and not specialized
   to lists only. It works also for `Maybe`, `Either` and other container
   types we haven't looked at so far. We will learn about
   interface `Foldable` in a later section.

7. Consider record wrappers `Any` and `All` for boolean values:

   ```idris
   record Any where
     constructor MkAny
     any : Bool

   record All where
     constructor MkAll
     all : Bool
   ```

   Implement `Semigroup` and `Monoid` for `Any`, so that the result of
   `(<+>)` is `True`, if and only if at least one of the arguments is `True`.
   Make sure that `neutral` is indeed the neutral element for this operation.

   Likewise, implement `Semigroup` and `Monoid` for `All`, so that the result of
   `(<+>)` is `True`, if and only if both of the arguments are `True`.
   Make sure that `neutral` is indeed the neutral element for this operation.

8. Implement functions `anyElem` and `allElems` using `foldMap` and
   `Any` or `All`, respectively:

   ```idris
   -- True, if the predicate holds for at least one element
   anyElem : (a -> Bool) -> List a -> Bool

   -- True, if the predicate holds for all elements
   allElems : (a -> Bool) -> List a -> Bool
   ```

9. Record wrappers `Sum` and `Product` are mainly used to hold
   numeric types.

   ```idris
   record Sum a where
     constructor MkSum
     value : a

   record Product a where
     constructor MkProduct
     value : a
   ```

   Given an implementation of `Num a`, implement `Semigroup (Sum a)`
   and `Monoid (Sum a)`, so that `(<+>)` corresponds to addition.

   Likewise, implement `Semigroup (Product a)` and `Monoid (Product a)`,
   so that `(<+>)` corresponds to multiplication.

   When implementing `neutral`, remember that you can use integer
   literals when working with numeric types.

10. Implement `sumList` and `productList` by using `foldMap` together
    with the wrappers from Exercise 9:

    ```idris
    sumList : Num a => List a -> a

    productList : Num a => List a -> a
    ```

11. To appreciate the power and versatility of `foldMap`, after
    solving exercises 6 to 10 (or by loading `Solutions.Inderfaces`
    in a REPL session), run the following at the REPL, which will -
    in a single list traversal! - calculate the first and last
    element of the list as well as the sum and product of all values.

    ```repl
    > foldMap (\x => (pureFirst x, pureLast x, MkSum x, MkProduct x)) [3,7,4,12]
    (MkFirst (Just 3), (MkLast (Just 12), (MkSum 26, MkProduct 1008)))
    ```

    Note, that there are also `Semigroup` implementations for
    types with an `Ord` implementation, which will return
    the smaller or larger of two values. In case of types
    with an absolute minimum or maximum (for instance, 0 for
    natural numbers, or 0 and 255 for `Bits8`), these can even
    be extended to `Monoid`.

12. In an earlier exercise, you implemented a data type representing
    chemical elements and wrote a function for calculating their
    atomic masses. Define a new single field record type for
    representing atomic masses, and implement interfaces
    `Eq`, `Ord`, `Show`, `FromDouble`, `Semigroup`, and `Monoid` for this.

13. Use the new data type from exercise 12 to calculate the atomic
    mass of an element and compute the molecular mass
    of a molecule given by its formula.

    Hint: With a suitable utility function, you can use `foldMap`
    once again for this.

Final notes: If you are new to functional programming, make sure
to give your implementations of exercises 6 to 10 a try at the REPL.
Note, how we can implement all of these functions with a minimal amount
of code and how, as shown in exercise 11, these behaviors can be
combined in a single list traversal.
