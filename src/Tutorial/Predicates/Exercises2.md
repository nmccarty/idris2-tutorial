# Exercises part 2

1. Show that `InSchema` is decidable by changing the output type of `inSchema` to `Dec (c ** InSchema n ss c)`.

2. Declare and implement a function for modifying a field in a row based on the column name given.

3. Define a predicate to be used as a witness that one list contains only elements in the second list in the same order and use this predicate to extract several columns from a row at once.

   For instance, `[2,4,5]` contains elements from `[1,2,3,4,5,6]` in the correct order, but `[4,2,5]` does not.

4. Improve the functionality from exercise 3 by defining a new predicate, witnessing that all strings in a list correspond to column names in a schema (in arbitrary order). Use this to extract several columns from a row at once in arbitrary order.

   Hint: Make sure to include the resulting schema as an index, but search only based on the list of names and the input schema.
