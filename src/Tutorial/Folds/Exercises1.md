# Exercises part 1

In these exercises you are going to implement several recursive functions. Make sure to use tail recursion whenever possible and quickly verify the correct behavior of all functions at the REPL.

1. Implement functions `anyList` and `allList`, which return `True` if any element (or all elements in case of `allList`) in a list fulfills the given predicate:

   ```idris
   anyList : (a -> Bool) -> List a -> Bool

   allList : (a -> Bool) -> List a -> Bool
   ```

2. Implement function `findList`, which returns the first value (if any) fulfilling the given predicate:

   ```idris
   findList : (a -> Bool) -> List a -> Maybe a
   ```

3. Implement function `collectList`, which returns the first value (if any), for which the given function returns a `Just`:

   ```idris
   collectList : (a -> Maybe b) -> List a -> Maybe b
   ```

   Implement `lookupList` in terms of `collectList`:

   ```idris
   lookupList : Eq a => a -> List (a,b) -> Maybe b
   ```

4. For functions like `map` or `filter`, which must loop over a list without affecting the order of elements, it is harder to write a tail recursive implementation. The safest way to do so is by using a `SnocList` (a *reverse* kind of list that's built from head to tail instead of from tail to head) to accumulate intermediate results. Its two constructors are `Lin` and `(:<)` (called the *snoc* operator). Module `Data.SnocList` exports two tail recursive operators called *fish* and *chips* (`(<><)` and `(<>>)`) for going from `SnocList` to `List` and vice versa. Have a look at the types of all new data constructors and operators before continuing with the exercise.

   Implement a tail recursive version of `map` for `List` by using a `SnocList` to reassemble the mapped list. Use then the *chips* operator with a `Nil` argument to in the end convert the `SnocList` back to a `List`.

   ```idris
   mapTR : (a -> b) -> List a -> List b
   ```

5. Implement a tail recursive version of `filter`, which only keeps those values in a list, which fulfill the given predicate. Use the same technique as described in exercise 4.

   ```idris
   filterTR : (a -> Bool) -> List a -> List a
   ```

6. Implement a tail recursive version of `mapMaybe`, which only keeps those values in a list, for which the given function argument returns a `Just`:

   ```idris
   mapMaybeTR : (a -> Maybe b) -> List a -> List b
   ```

   Implement `catMaybesTR` in terms of `mapMaybeTR`:

   ```idris
   catMaybesTR : List (Maybe a) -> List a
   ```

7. Implement a tail recursive version of list concatenation:

   ```idris
   concatTR : List a -> List a -> List a
   ```

8. Implement tail recursive versions of *bind* and `join` for `List`:

   ```idris
   bindTR : List a -> (a -> List b) -> List b

   joinTR : List (List a) -> List a
   ```
