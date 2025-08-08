# Exercises part 1

1. Write your own implementations of `Functor'` for `Maybe`, `List`, `List1`, `Vect n`, `Either e`, and `Pair a`.

2. Write a named implementation of `Functor` for pairs of functors (similar to the one implemented for `Product`).

3. Implement `Functor` for data type `Identity` (which is available from `Control.Monad.Identity` in *base*):

   ```idris
   record Identity a where
     constructor Id
     value : a
   ```

4. Here is a curious one: Implement `Functor` for `Const e` (which is also available from `Control.Applicative.Const` in *base*). You might be confused about the fact that the second type parameter has absolutely no relevance at runtime, as there is no value of that type. Such types are sometimes called *phantom types*. They can be quite useful for tagging values with additional typing information.

   Don't let the above confuse you: There is only one possible implementation. As usual, use holes and let the compiler guide you if you get lost.

   ```idris
   record Const (e,a : Type) where
     constructor MkConst
     value : e
   ```

5. Here is a sum type for describing CRUD operations (Create, Read, Update, and Delete) in a data store:

   ```idris
   data Crud : (i : Type) -> (a : Type) -> Type where
     Create : (value : a) -> Crud i a
     Update : (id : i) -> (value : a) -> Crud i a
     Read   : (id : i) -> Crud i a
     Delete : (id : i) -> Crud i a
   ```

   Implement `Functor` for `Crud i`.

6. Here is a sum type for describing responses from a data server:

   ```idris
   data Response : (e, i, a : Type) -> Type where
     Created : (id : i) -> (value : a) -> Response e i a
     Updated : (id : i) -> (value : a) -> Response e i a
     Found   : (values : List a) -> Response e i a
     Deleted : (id : i) -> Response e i a
     Error   : (err : e) -> Response e i a
   ```

   Implement `Functor` for `Repsonse e i`.

7. Implement `Functor` for `Validated e`:

   ```idris
   data Validated : (e,a : Type) -> Type where
     Invalid : (err : e) -> Validated e a
     Valid   : (val : a) -> Validated e a
   ```
