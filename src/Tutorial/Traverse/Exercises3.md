# Exercises part 3

The *Prelude* provides three additional interfaces for container types parameterized over *two* type parameters such as `Either` or `Pair`: `Bifunctor`, `Bifoldable`, and `Bitraversable`. In the following exercises we get some hands-one experience working with these. You are supposed to look up what functions they provide and how to implement and use them yourself.

1. Assume we'd like to not only interpret CSV content but also the optional comment tags in our CSV files. For this, we could use a data type such as `Tagged`:

   ```idris
   data Tagged : (tag, value : Type) -> Type where
     Tag  : tag -> value -> Tagged tag value
     Pure : value -> Tagged tag value
   ```

   Implement interfaces `Functor`, `Foldable`, and `Traversable` but also `Bifunctor`, `Bifoldable`, and `Bitraversable` for `Tagged`.

2. Show that the composition of a bifunctor with two functors such as `Either (List a) (Maybe b)` is again a bifunctor by defining a dedicated wrapper type for such compositions and writing a corresponding implementation of `Bifunctor`. Likewise for `Bifoldable`/`Foldable` and `Bitraversable`/`Traversable`.

3. Show that the composition of a functor with a bifunctor such as `List (Either a b)` is again a bifunctor by defining a dedicated wrapper type for such compositions and writing a corresponding implementation of `Bifunctor`. Likewise for `Bifoldable`/`Foldable` and `Bitraversable`/`Traversable`.

4. We are now going to adjust `readCSV` in such a way that it decodes comment tags and CSV content in a single traversal. We need a new error type to include invalid tags for this:

   ```idris
   data TagError : Type where
     CE         : CSVError -> TagError
     InvalidTag : (line : Nat) -> (tag : String) -> TagError
     Append     : TagError -> TagError -> TagError

   Semigroup TagError where (<+>) = Append
   ```

   For testing, we also define a simple data type for color tags:

   ```idris
   data Color = Red | Green | Blue
   ```

   You should now implement the following functions, but please note that while `readColor` will need to access the current line number in case of an error, it must *not* increase it, as otherwise line numbers will be wrong in the invocation of `tagAndDecodeTE`.

   ```idris
   readColor : String -> State Nat (Validated TagError Color)

   readTaggedLine : String -> Tagged String String

   tagAndDecodeTE :  (0 ts : List Type)
                  -> CSVLine (HList ts)
                  => String
                  -> State Nat (Validated TagError (HList ts))
   ```

   Finally, implement `readTagged` by using the wrapper type from exercise 3 as well as `readColor` and `tagAndDecodeTE` in a call to `bitraverse`. The implementation will look very similar to `readCSV` but with some additional wrapping and unwrapping at the right places.

   ```idris
   readTagged :  (0 ts : List Type)
              -> CSVLine (HList ts)
              => String
              -> Validated TagError (List $ Tagged Color $ HList ts)
   ```

   Test your implementation with some example strings at the REPL.

You can find more examples for functor/bifunctor compositions in Haskell's [bifunctors](https://hackage.haskell.org/package/bifunctors) package.
