# Conclusion

Interface `Traversable` and its main function `traverse` are incredibly powerful forms of abstraction - even more so, because both `Applicative` and `Traversable` are closed under composition. If you are interested in additional use cases, the publication, which introduced `Traversable` to Haskell, is a highly recommended read: [The Essence of the Iterator Pattern](https://www.cs.ox.ac.uk/jeremy.gibbons/publications/iterator.pdf)

The *base* library provides an extended version of the state monad in module `Control.Monad.State`. We will look at this in more detail when we talk about monad transformers. Please note also, that `IO` itself is implemented as a simple state monad over an abstract, primitive state type: `%World`.

Here's a short summary of what we learned in this chapter:

- Function `traverse` is used to run effectful computations over container types without affecting their size or shape.
- We can use `IORef` as mutable references in stateful computations running in `IO`.
- For referentially transparent computations with "mutable" state, the `State` monad is extremely useful.
- Applicative functors are closed under composition, so we can run several effectful computations in a single traversal.
- Traversables are also closed under composition, so we can use `traverse` to operate on a nesting of containers.

For now, this concludes our introduction of the *Prelude*'s higher-kinded interfaces, which started with the introduction of `Functor`, `Applicative`, and `Monad`, before moving on to `Foldable`, and - last but definitely not least - `Traversable`. There's one still missing - `Alternative` - but this will have to wait a bit longer, because we need to first make our brains smoke with some more type-level wizardry.
