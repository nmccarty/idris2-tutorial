# Conclusion

- Values of type `IO a` describe programs with side effects, which will eventually result in a value of type `a`.

- While we cannot safely extract a value of type `a` from an `IO a`, we can use several combinators and syntactic constructs to combine `IO` actions and build more-complex programs.

- *Do blocks* offer a convenient way to run and combine `IO` actions sequentially.

- *Do blocks* are desugared to nested applications of *bind* operators (`(>>=)`).

- *Bind* operators, and thus *do blocks*, can be overloaded to achieve custom behavior instead of the default (monadic) *bind*.

- Under the hood, `IO` actions are stateful computations operating on a symbolic `%World` state.

## What's next

Now, that we had a glimpse at *monads* and the *bind* operator, it is time to in the next chapter introduce `Monad` and some related interfaces for real.
