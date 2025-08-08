# Exercises part 3

1. Show that there can be no non-empty vector of `Void` by writing a corresponding implementation of uninhabited

2. Generalize exercise 1 for all uninhabited element types.

3. Show that if `a = b` cannot hold, then `b = a` cannot hold either.

4. Show that if `a = b` holds, and `b = c` cannot hold, then `a = c` cannot hold either.

5. Implement `Uninhabited` for `Crud i a`. Try to be as general as possible.

   ```idris
   data Crud : (i : Type) -> (a : Type) -> Type where
     Create : (value : a) -> Crud i a
     Update : (id : i) -> (value : a) -> Crud i a
     Read   : (id : i) -> Crud i a
     Delete : (id : i) -> Crud i a
   ```

6. Implement `DecEq` for `ColType`.

7. Implementations such as the one from exercise 6 are cumbersome to write as they require a quadratic number of pattern matches with relation to the number of data constructors. Here is a trick how to make this more bearable.

   1. Implement a function `ctNat`, which assigns every value of type `ColType` a unique natural number.

   2. Proof that `ctNat` is injective. Hint: You will need to pattern match on the `ColType` values, but four matches should be enough to satisfy the coverage checker.

   3. In your implementation of `DecEq` for `ColType`, use `decEq` on the result of applying both column types to `ctNat`, thus reducing it to only two lines of code.

   We will later talk about `with` rules: Special forms of dependent pattern matches, that allow us to learn something about the shape of function arguments by performing computations on them. These will allow us to use a similar technique as shown here to implement `DecEq` requiring only `n` pattern matches for arbitrary sum types with `n` data constructors.
