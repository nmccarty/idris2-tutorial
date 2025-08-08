# Exercises part 1

In the following exercises, you are going to implement some very basic properties of equality proofs. You'll have to come up with the types of the functions yourself, as the implementations will be incredibly simple.

Note: If you can't remember what the terms "reflexive", "symmetric", and "transitive" mean, quickly read about equivalence relations [here](https://en.wikipedia.org/wiki/Equivalence_relation).

1. Show that `SameColType` is a reflexive relation.

2. Show that `SameColType` is a symmetric relation.

3. Show that `SameColType` is a transitive relation.

4. Let `f` be a function of type `ColType -> a` for an arbitrary type `a`. Show that from a value of type `SameColType c1 c2` follows that `f c1` and `f c2` are equal.

   For `(=)` the above properties are available from the *Prelude* as functions `sym`, `trans`, and `cong`. Reflexivity comes from the data constructor `Refl` itself.

5. Implement a function for verifying that two natural numbers are identical. Try using `cong` in your implementation.

6. Use the function from exercise 5 for zipping two `Table`s if they have the same number of rows.

   Hint: Use `Vect.zipWith`. You will need to implement custom function `appRows` for this, since Idris will not automatically figure out that the types unify when using `HList.(++)`:

   ```idris
   appRows : {ts1 : _} -> Row ts1 -> Row ts2 -> Row (ts1 ++ ts2)
   ```

We will later learn how to use *rewrite rules* to circumvent the need of writing custom functions like `appRows` and use `(++)` in `zipWith` directly.
