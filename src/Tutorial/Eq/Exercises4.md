# Exercises part 4

1. Implement `plusSuccRightSucc` yourself.

2. Proof that `minus n n` equals zero for all natural numbers `n`.

3. Proof that `minus n 0` equals n for all natural numbers `n`

4. Proof that `n * 1 = n` and `1 * n = n` for all natural numbers `n`.

5. Proof that addition of natural numbers is commutative.

6. Implement a tail-recursive version of `map` for vectors.

7. Proof the following proposition:

   ```idris
   mapAppend :  (f : a -> b)
             -> (xs : List a)
             -> (ys : List a)
             -> map f (xs ++ ys) = map f xs ++ map f ys
   ```

8. Use the proof from exercise 7 to implement again a function for zipping two `Table`s, this time using a rewrite rule plus `Data.HList.(++)` instead of custom function `appRows`.
