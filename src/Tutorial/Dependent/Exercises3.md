# Exercises part 3

1. Here is a function declaration for flattening a `List` of `List`s:

   ```idris
   flattenList : List (List a) -> List a
   ```

   Implement `flattenList` and declare and implement a similar function `flattenVect` for flattening vectors of vectors.

2. Implement functions `take'` and `splitAt'` like in the exercises of the previous section but using the technique shown for `drop'`.

3. Implement function `transpose` for converting an `m x n`-matrix (represented as a `Vect m (Vect n a)`) to an `n x m`-matrix.

   Note: This might be a challenging exercise, but make sure to give it a try. As usual, make use of holes if you get stuck!

   Here is an example how this should work in action:

   ```repl
   Solutions.Dependent> transpose [[1,2,3],[4,5,6]]
   [[1, 4], [2, 5], [3, 6]]
   ```
