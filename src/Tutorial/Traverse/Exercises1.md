# Exercises part 1

1. It is interesting that `Traversable` has a `Functor` constraint. Proof that every `Traversable` is automatically a `Functor` by implementing `map` in terms of `traverse`.

   Hint: Remember `Control.Monad.Identity`.

2. Likewise, proof that every `Traversable` is a `Foldable` by implementing `foldMap` in terms of `Traverse`.

   Hint: Remember `Control.Applicative.Const`.

3. To gain some routine, implement `Traversable'` for `List1`, `Either e`, and `Maybe`.

4. Implement `Traversable` for `List01 ne`:

   ```idris
   data List01 : (nonEmpty : Bool) -> Type -> Type where
     Nil  : List01 False a
     (::) : a -> List01 False a -> List01 ne a
   ```

5. Implement `Traversable` for rose trees. Try to satisfy the totality checker without cheating.

   ```idris
   record Tree a where
     constructor Node
     value  : a
     forest : List (Tree a)
   ```

6. Implement `Traversable` for `Crud i`:

   ```idris
   data Crud : (i : Type) -> (a : Type) -> Type where
     Create : (value : a) -> Crud i a
     Update : (id : i) -> (value : a) -> Crud i a
     Read   : (id : i) -> Crud i a
     Delete : (id : i) -> Crud i a
   ```

7. Implement `Traversable` for `Response e i`:

   ```idris
   data Response : (e, i, a : Type) -> Type where
     Created : (id : i) -> (value : a) -> Response e i a
     Updated : (id : i) -> (value : a) -> Response e i a
     Found   : (values : List a) -> Response e i a
     Deleted : (id : i) -> Response e i a
     Error   : (err : e) -> Response e i a
   ```

8. Like `Functor`, `Applicative` and `Foldable`, `Traversable` is closed under composition. Proof this by implementing `Traversable` for `Comp` and `Product`:

   ```idris
   record Comp (f,g : Type -> Type) (a : Type) where
     constructor MkComp
     unComp  : f (g a)

   record Product (f,g : Type -> Type) (a : Type) where
     constructor MkProduct
     fst : f a
     snd : g a
   ```
