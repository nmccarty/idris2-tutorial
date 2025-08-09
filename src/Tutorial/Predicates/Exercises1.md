# Exercises part 1

In these exercises, you'll have to implement several functions making use of auto implicits, to constrain the values accepted as function arguments. The results should be *pure*, that is, not wrapped in a failure type like `Maybe`.

1. Implement `tail` for lists.

2. Implement `concat1` and `foldMap1` for lists. These should work like `concat` and `foldMap`, but taking only a `Semigroup` constraint on the element type.

3. Implement functions for returning the largest and smallest element in a list.

4. Define a predicate for strictly positive natural numbers and use it to implement a safe and provably total division function on natural numbers.

5. Define a predicate for a non-empty `Maybe` and use it to safely extract the value stored in a `Just`. Show that this predicate is decidable by implementing a corresponding conversion function.

6. Define and implement functions for safely extracting values from a `Left` and a `Right` by using suitable predicates. Show again that these predicates are decidable.

The predicates you implemented in these exercises are already available in the *base* library: `Data.List.NonEmpty`, `Data.Maybe.IsJust`, `Data.Either.IsLeft`, `Data.Either.IsRight`, and `Data.Nat.IsSucc`.
