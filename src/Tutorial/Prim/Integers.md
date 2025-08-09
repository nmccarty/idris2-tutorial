# Integers

```idris
module Tutorial.Prim.Integers

import Data.Bits
import Data.String

%default total
```

As listed at the beginning of this chapter, Idris provides different fixed-precision signed and unsigned integer types as well as `Integer`, an arbitrary precision signed integer type. All of them come with the following primitive functions (given here for `Bits8` as an example):

- `prim__add_Bits8`: Integer addition.
- `prim__sub_Bits8`: Integer subtraction.
- `prim__mul_Bits8`: Integer multiplication.
- `prim__div_Bits8`: Integer division.
- `prim__mod_Bits8`: Modulo function.
- `prim__shl_Bits8`: Bitwise left shift.
- `prim__shr_Bits8`: Bitwise right shift.
- `prim__and_Bits8`: Bitwise *and*.
- `prim__or_Bits8`: Bitwise *or*.
- `prim__xor_Bits8`: Bitwise *xor*.

Typically, you use the functions for addition and multiplication through the operators from interface `Num`, the function for subtraction through interface `Neg`, and the functions for division (`div` and `mod`) through interface `Integral`. The bitwise operations are available through interfaces `Data.Bits.Bits` and `Data.Bits.FiniteBits`.

For all integral types, the following laws are assumed to hold for numeric operations (`x`, `y`, and `z` are arbitrary value of the same primitive integral type):

- `x + y = y + x`: Addition is commutative.
- `x + (y + z) = (x + y) + z`: Addition is associative.
- `x + 0 = x`: Zero is the neutral element of addition.
- `x - x = x + (-x) = 0`: `-x` is the additive inverse of `x`.
- `x * y = y * x`: Multiplication is commutative.
- `x * (y * z) = (x * y) * z`: Multiplication is associative.
- `x * 1 = x`: One is the neutral element of multiplication.
- `x * (y + z) = x * y + x * z`: The distributive law holds.
- `` y * (x `div` y) + (x `mod` y) = x `` (for `y /= 0`).

Please note, that the officially supported backends use *Euclidian modulus* for calculating `mod`: For `y /= 0`, `` x `mod` y `` is always a non-negative value strictly smaller than `abs y`, so that the law given above does hold. If `x` or `y` are negative numbers, this is different to what many other languages do but for good reasons as explained in the following [article](https://www.microsoft.com/en-us/research/publication/division-and-modulus-for-computer-scientists/).

## Unsigned Integers

The unsigned fixed precision integer types (`Bits8`, `Bits16`, `Bits32`, and `Bits64`) come with implementations of all integral interfaces (`Num`, `Neg`, and `Integral`) and the two interfaces for bitwise operations (`Bits` and `FiniteBits`). All functions with the exception of `div` and `mod` are total. Overflows are handled by calculating the remainder modulo `2^bitsize`. For instance, for `Bits8`, all operations calculate their results modulo 256:

```repl
Main> the Bits8 255 + 1
0
Main> the Bits8 255 + 255
254
Main> the Bits8 128 * 2 + 7
7
Main> the Bits8 12 - 13
255
```

## Signed Integers

Like the unsigned integer types, the signed fixed precision integer types (`Int8`, `Int16`, `Int32`, and `Int64`) come with implementations of all integral interfaces and the two interfaces for bitwise operations (`Bits` and `FiniteBits`). Overflows are handled by calculating the remainder modulo `2^bitsize` and subtracting `2^bitsize` if the result is still out of range. For instance, for `Int8`, all operations calculate their results modulo 256, subtracting 256 if the result is still out of bounds:

```repl
Main> the Int8 2 * 127
-2
Main> the Int8 3 * 127
125
```

## Bitwise Operations

Module `Data.Bits` exports interfaces for performing bitwise operations on integral types. I'm going to show a couple of examples on unsigned 8-bit numbers (`Bits8`) to explain the concept to readers new to bitwise arithmetics. Note, that this is much easier to grasp for unsigned integer types than for the signed versions. Those have to include information about the *sign* of numbers in their bit pattern, and it is assumed that signed integers in Idris use a [two's complement representation](https://en.wikipedia.org/wiki/Two%27s_complement), about which I will not go into the details here.

An unsigned 8-bit binary number is represented internally as a sequence of eight bits (with values 0 or 1), each of which corresponds to a power of 2. For instance, the number 23 (= 16 + 4 + 2 + 1) is represented as `0001 0111`:

```repl
23 in binary:    0  0  0  1    0  1  1  1

Bit number:      7  6  5  4    3  2  1  0
Decimal value: 128 64 32 16    8  4  2  1
```

We can use function `testBit` to check if the bit at the given position is set or not:

```repl
Tutorial.Prim> testBit (the Bits8 23) 0
True
Tutorial.Prim> testBit (the Bits8 23) 1
True
Tutorial.Prim> testBit (the Bits8 23) 3
False
```

Likewise, we can use functions `setBit` and `clearBit` to set or unset a bit at a certain position:

```repl
Tutorial.Prim> setBit (the Bits8 23) 3
31
Tutorial.Prim> clearBit (the Bits8 23) 2
19
```

There are also operators `(.&.)` (bitwise *and*) and `(.|.)` (bitwise *or*) as well as function `xor` (bitwise *exclusive or*) for performing boolean operations on integral values. For instance `x .&. y` has exactly those bits set, which both `x` and `y` have set, while `x .|. y` has all bits set that are either set in `x` or `y` (or both), and `` x `xor` y `` has those bits set that are set in exactly one of the two values:

```repl
23 in binary:          0  0  0  1    0  1  1  1
11 in binary:          0  0  0  0    1  0  1  1

23 .&. 11 in binary:   0  0  0  0    0  0  1  1
23 .|. 11 in binary:   0  0  0  1    1  1  1  1
23 `xor` 11 in binary: 0  0  0  1    1  1  0  0
```

And here are the examples at the REPL:

```repl
Tutorial.Prim> the Bits8 23 .&. 11
3
Tutorial.Prim> the Bits8 23 .|. 11
31
Tutorial.Prim> the Bits8 23 `xor` 11
28
```

Finally, it is possible to shift all bits to the right or left by a certain number of steps by using functions `shiftR` and `shiftL`, respectively (overflowing bits will just be dropped). A left shift can therefore be viewed as a multiplication by a power of two, while a right shift can be seen as a division by a power of two:

```repl
22 in binary:            0  0  0  1    0  1  1  0

22 `shiftL` 2 in binary: 0  1  0  1    1  0  0  0
22 `shiftR` 1 in binary: 0  0  0  0    1  0  1  1
```

And at the REPL:

```repl
Tutorial.Prim> the Bits8 22 `shiftL` 2
88
Tutorial.Prim> the Bits8 22 `shiftR` 1
11
```

Bitwise operations are often used in specialized code or certain high-performance applications. As programmers, we have to know they exist and how they work.

## Integer Literals

So far, we always required an implementation of `Num` in order to be able to use integer literals for a given type. However, it is actually only necessary to implement a function `fromInteger` converting an `Integer` to the type in question. As we will see in the last section, such a function can even restrict the values allowed as valid literals.

For instance, assume we'd like to define a data type for representing the charge of a chemical molecule. Such a value can be positive or negative and (theoretically) of almost arbitrary magnitude:

```idris
record Charge where
  constructor MkCharge
  value : Integer
```

It makes sense to be able to sum up charges, but not to multiply them. They should therefore have an implementation of `Monoid` but not of `Num`. Still, we'd like to have the convenience of integer literals when using constant charges at compile time. Here's how to do this:

```idris
fromInteger : Integer -> Charge
fromInteger = MkCharge

Semigroup Charge where
  x <+> y = MkCharge $ x.value + y.value

Monoid Charge where
  neutral = 0
```

### Alternative Bases

In addition to the well known decimal literals, it is also possible to use integer literals in binary, octal, or hexadecimal representation. These have to be prefixed with a zero following by a `b`, `o`, or `x` for binary, octal, and hexadecimal, respectively:

```repl
Tutorial.Prim> 0b1101
13
Tutorial.Prim> 0o773
507
Tutorial.Prim> 0xffa2
65442
```

<!-- vi: filetype=idris2:syntax=markdown
-->
