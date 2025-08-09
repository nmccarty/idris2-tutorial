# Conclusion

- Dependent types allow us to calculate types from values. This makes it possible to encode properties of values at the type-level and verify these properties at compile time.

- Length-indexed lists (vectors) let us rule out certain implementation errors, by forcing us to be precise about the lengths of input and output vectors.

- We can use patterns in type signatures, for instance to express that the length of a vector is non-zero and therefore, the vector is non-empty.

- When creating values of a type family, the values of the indices need to be known at compile time, or they need to be passed as arguments to the function creating the values, where we can pattern match on them to figure out, which constructors to use.

- We can use `Fin n`, the type of natural numbers strictly smaller than `n`, to safely index into a vector of length `n`.

- Sometimes, it is convenient to pass inferable arguments as non-erased implicits, in which case we can still inspect them by pattern matching or pass them to other functions, while Idris will try and fill in the values for us.

Note, that data type `Vect` together with many of the functions we implemented here is available from module `Data.Vect` from the *base* library. Likewise, `Fin` is available from `Data.Fin` from *base*.

## What's next

In the next section, it is time to learn how to write effectful programs and how to do this while still staying *pure*.
