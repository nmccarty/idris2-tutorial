# Exercises part 2

In these exercises, you are going to proof several simple properties of small functions. When writing proofs, it is even more important to use holes to figure out what Idris expects from you next. Use the tools given to you, instead of trying to find your way in the dark!

1. Proof that `map id` on an `Either e` returns the value unmodified.

2. Proof that `map id` on a list returns the list unmodified.

3. Proof that complementing a strand of a nucleobase (see the [previous chapter](DPair.md#use-case-nucleic-acids)) twice leads to the original strand.

   Hint: Proof this for single bases first, and use `cong2` from the *Prelude* in your implementation for sequences of nucleic acids.

4. Implement function `replaceVect`:

   ```idris
   replaceVect : (ix : Fin n) -> a -> Vect n a -> Vect n a
   ```

   Now proof, that after replacing an element in a vector using `replaceAt` accessing the same element using `index` will return the value we just added.

5. Implement function `insertVect`:

   ```idris
   insertVect : (ix : Fin (S n)) -> a -> Vect n a -> Vect (S n) a
   ```

   Use a similar proof as in exercise 4 to show that this behaves correctly.

Note: Functions `replaceVect` and `insertVect` are available from `Data.Vect` as `replaceAt` and `insertAt`.
