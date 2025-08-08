# Dependent Types

The ability to calculate types from values, pass them as arguments to functions, and return them as results from functions - in short, being a dependently typed language - is one of the most distinguishing features of Idris. Many of the more advanced type level extensions of languages like Haskell (and quite a bit more) can be treated in one fell swoop with dependent types.

```idris
module Tutorial.Dependent

%default total
```

Consider the following functions:

```idris
bogusMapList : (a -> b) -> List a -> List b
bogusMapList _ _ = []

bogusZipList : (a -> b -> c) -> List a -> List b -> List c
bogusZipList _ _ _ = []
```

The implementations type check, and still, they are obviously not what users of our library would expect. In the first example, we'd expect the implementation to apply the function argument to all values stored in the list, without dropping any of them or changing their order. The second is trickier: The two list arguments might be of different length. What are we supposed to do when that's the case? Return a list of the same length as the smaller of the two? Return an empty list? Or shouldn't we in most use cases expect the two lists to be of the same length? How could we even describe such a precondition?

<!-- vi: filetype=idris2:syntax=markdown
-->
