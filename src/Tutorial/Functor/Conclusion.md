# Conclusion

- Interfaces `Functor`, `Applicative`, and `Monad` abstract over programming patterns that come up when working with type constructors of type `Type -> Type`. Such data types are also referred to as *values in a context*, or *effectful computations*.

- `Functor` allows us to *map* over values in a context without affecting the context's underlying structure.

- `Applicative` allows us to apply n-ary functions to n effectful computations and to lift pure values into a context.

- `Monad` allows us to chain effectful computations, where the intermediary results can affect, which computation to run further down the chain.

- Unlike `Monad`, `Functor` and `Applicative` compose: The product and composition of two functors or applicatives are again functors or applicatives, respectively.

- Idris provides syntactic sugar for working with some of the interfaces presented here: Idiom brackets for `Applicative`, *do blocks* and the bang operator for `Monad`.

## What's next?

In the [next chapter](Folds.md) we get to learn more about recursion, totality checking, and an interface for collapsing container types: `Foldable`.
