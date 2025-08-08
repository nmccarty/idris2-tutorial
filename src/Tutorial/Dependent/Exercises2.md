# Exercises part 2

1. Implement function `update`, which, given a function of type `a -> a`, updates the value in a`Vect n a` at position `k < n`.

2. Implement function `insert`, which inserts a value of type `a` at position `k <= n` in a `Vect n a`. Note, that `k` is the index of the freshly inserted value, so that the following holds:

   ```repl
   index k (insert k v vs) = v
   ```

3. Implement function `delete`, which deletes a value from a vector at the given index.

   This is trickier than Exercises 1 and 2, as we have to properly encode in the types that the vector is getting one element shorter.

4. We can use `Fin` to implement safe indexing into `List`s as well. Try to come up with a type and implementation for `safeIndexList`.

   Note: If you don't know how to start, look at the type of `fromList` for some inspiration. You might also need give the arguments in a different order than for `index`.

5. Implement function `finToNat`, which converts a `Fin n` to the corresponding natural number, and use this to declare and implement function `take` for splitting of the first `k` elements of a `Vect n a` with `k <= n`.

6. Implement function `minus` for subtracting a value `k` from a natural number `n` with `k <= n`.

7. Use `minus` from Exercise 6 to declare and implement function `drop`, for dropping the first `k` values from a `Vect n a`, with `k <= n`.

8. Implement function `splitAt` for splitting a `Vect n a` at position `k <= n`, returning the prefix and suffix of the vector wrapped in a pair.

   Hint: Use `take` and `drop` in your implementation.

Hint: Since `Fin n` consists of the values strictly smaller than `n`, `Fin (S n)` consists of the values smaller than or equal to `n`.

Note: Functions `take`, `drop`, and `splitAt`, while correct and provably total, are rather cumbersome to type. There is an alternative way to declare their types, as we will see in the next section.
