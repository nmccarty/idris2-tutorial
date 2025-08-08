# Exercises part 3

In these exercises, you are going to implement `Foldable` for different data types. Make sure to try and manually implement all six functions of the interface.

1. Implement `Foldable` for `Crud i`:

   ```idris
   data Crud : (i : Type) -> (a : Type) -> Type where
     Create : (value : a) -> Crud i a
     Update : (id : i) -> (value : a) -> Crud i a
     Read   : (id : i) -> Crud i a
     Delete : (id : i) -> Crud i a
   ```

2. Implement `Foldable` for `Response e i`:

   ```idris
   data Response : (e, i, a : Type) -> Type where
     Created : (id : i) -> (value : a) -> Response e i a
     Updated : (id : i) -> (value : a) -> Response e i a
     Found   : (values : List a) -> Response e i a
     Deleted : (id : i) -> Response e i a
     Error   : (err : e) -> Response e i a
   ```

3. Implement `Foldable` for `List01`. Use tail recursion in the implementations of `toList`, `foldMap`, and `foldl`.

   ```idris
   data List01 : (nonEmpty : Bool) -> Type -> Type where
     Nil  : List01 False a
     (::) : a -> List01 False a -> List01 ne a
   ```

4. Implement `Foldable` for `Tree`. There is no need to use tail recursion in your implementations, but your functions must be accepted by the totality checker, and you are not allowed to cheat by using `assert_smaller` or `assert_total`.

   Hint: You can test the correct behavior of your implementations by running the same folds on the result of `treeToVect` and verify that the outcome is the same.

5. Like `Functor` and `Applicative`, `Foldable` composes: The product and composition of two foldable container types are again foldable container types. Proof this by implementing `Foldable` for `Comp` and `Product`:

   ```idris
   record Comp (f,g : Type -> Type) (a : Type) where
     constructor MkComp
     unComp  : f (g a)

   record Product (f,g : Type -> Type) (a : Type) where
     constructor MkProduct
     fst : f a
     snd : g a
   ```
