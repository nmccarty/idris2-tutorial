# Exercises part 2

1. Define a wrapper record for integral values and implement `Monoid` so that `(<+>)` corresponds to `(.&.)`.

   Hint: Have a look at the functions available from interface `Bits` to find a value suitable as the neutral element.

2. Define a wrapper record for integral values and implement `Monoid` so that `(<+>)` corresponds to `(.|.)`.

3. Use bitwise operations to implement a function, which tests if a given value of type `Bits64` is even or not.

4. Convert a value of type `Bits64` to a string in binary representation.

5. Convert a value of type `Bits64` to a string in hexadecimal representation.

   Hint: Use `shiftR` and `(.&. 15)` to access subsequent packages of four bits.
