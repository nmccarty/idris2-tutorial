# Exercises part 2

01. Implement `Applicative'` for `Either e` and `Identity`.

02. Implement `Applicative'` for `Vect n`. Note: In order to implement `pure`, the length must be known at runtime. This can be done by passing it as an unerased implicit to the interface implementation:

    ```idris
    implementation {n : _} -> Applicative' (Vect n) where
    ```

03. Implement `Applicative'` for `Pair e`, with `e` having a `Monoid` constraint.

04. Implement `Applicative` for `Const e`, with `e` having a `Monoid` constraint.

05. Implement `Applicative` for `Validated e`, with `e` having a `Semigroup` constraint. This will allow us to use `(<+>)` to accumulate errors in case of two `Invalid` values in the implementation of *apply*.

06. Add an additional data constructor of type `CSVError -> CSVError -> CSVError` to `CSVError` and use this to implement `Semigroup` for `CSVError`.

07. Refactor our CSV-parsers and all related functions so that they return `Validated` instead of `Either`. This will only work, if you solved exercise 6.

    Two things to note: You will have to adjust very little of the existing code, as we can still use applicative syntax with `Validated`. Also, with this change, we enhanced our CSV-parsers with the ability of error accumulation. Here are some examples from a REPL session:

    ```repl
    Solutions.Functor> hdecode [Bool,Nat,Gender] 1 "t,12,f"
    Valid [True, 12, Female]
    Solutions.Functor> hdecode [Bool,Nat,Gender] 1 "o,-12,f"
    Invalid (App (FieldError 1 1 "o") (FieldError 1 2 "-12"))
    Solutions.Functor> hdecode [Bool,Nat,Gender] 1 "o,-12,foo"
    Invalid (App (FieldError 1 1 "o")
      (App (FieldError 1 2 "-12") (FieldError 1 3 "foo")))
    ```

    Behold the power of applicative functors and heterogeneous lists: With only a few lines of code we wrote a pure, type-safe, and total parser with error accumulation for lines in CSV-files, which is very convenient to use at the same time!

08. Since we introduced heterogeneous lists in this chapter, it would be a pity not to experiment with them a little.

    This exercise is meant to sharpen your skills in type wizardry. It therefore comes with very few hints. Try to decide yourself what behavior you'd expect from a given function, how to express this in the types, and how to implement it afterwards. If your types are correct and precise enough, the implementations will almost come for free. Don't give up too early if you get stuck. Only if you truly run out of ideas should you have a glance at the solutions (and then, only at the types at first!)

    1. Implement `head` for `HList`.

    2. Implement `tail` for `HList`.

    3. Implement `(++)` for `HList`.

    4. Implement `index` for `HList`. This might be harder than the other three. Go back and look how we implemented `indexList` in an earlier exercise and start from there.

    5. Package *contrib*, which is part of the Idris project, provides `Data.HVect.HVect`, a data type for heterogeneous vectors. The only difference to our own `HList` is, that `HVect` is indexed over a vector of types instead of a list of types. This makes it easier to express certain operations at the type level.

       Write your own implementation of `HVect` together with functions `head`, `tail`, `(++)`, and `index`.

    6. For a real challenge, try implementing a function for transposing a `Vect m (HVect ts)`. You'll first have to be creative about how to even express this in the types.

       Note: In order to implement this, you'll need to pattern match on an erased argument in at least one case to help Idris with type inference. Pattern matching on erased arguments is forbidden (they are erased after all, so we can't inspect them at runtime), *unless* the structure of the value being matched on can be derived from another, un-erased argument.

       Also, don't worry if you get stuck on this one. It took me several tries to figure it out. But I enjoyed the experience, so I just *had* to include it here. :-)

       Note, however, that such a function might be useful when working with CSV-files, as it allows us to convert a table represented as rows (a vector of tuples) to one represented as columns (a tuple of vectors).

09. Show, that the composition of two applicative functors is again an applicative functor by implementing `Applicative` for `Comp f g`.

10. Show, that the product of two applicative functors is again an applicative functor by implementing `Applicative` for `Prod f g`.
