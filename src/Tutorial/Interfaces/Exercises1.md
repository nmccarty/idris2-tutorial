# Exercises Part 1

1. Implement function `anyLarger`, which should return `True`, if and only if a list of values contains at least one element larger than a given reference value. Use interface `Comp` in your implementation.

2. Implement function `allLarger`, which should return `True`, if and only if a list of values contains *only* elements larger than a given reference value. Note, that this is trivially true for the empty list. Use interface `Comp` in your implementation.

3. Implement function `maxElem`, which tries to extract the largest element from a list of values with a `Comp` implementation. Likewise for `minElem`, which tries to extract the smallest element. Note, that the possibility of the list being empty must be considered when deciding on the output type.

4. Define an interface `Concat` for values like lists or strings, which can be concatenated. Provide implementations for lists and strings.

5. Implement function `concatList` for concatenating the values in a list holding values with a `Concat` implementation. Make sure to reflect the possibility of the list being empty in your output type.
