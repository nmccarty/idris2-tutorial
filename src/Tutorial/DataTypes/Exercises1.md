# Enumeration Exercises

```idris
module Tutorial.DataTypes.Exercises1
```

The solutions to these exercises can be found in [`src/Solutions/DataTypes.idr`](../../Solutions/DataTypes.md).

## Exercise 1

Use pattern matching to implement your own versions of boolean operators `(&&)` and `(||)`, calling them `and` and `or` respectively.

> [!TIP]
> One way to go about this is to enumerate all four possible combinations of two boolean values and give the result for each. However, there is a shorter, more clever way, requiring only two pattern matches for each of the two functions.

## Exercise 2

Define your own data type representing different units of time (seconds, minutes, hours, days, weeks), and implement the following functions for converting between time spans with different units.

> [!TIP]
> Use integer division (`div`) when going from seconds to some larger unit like hours).

```idris
data UnitOfTime = Second -- add additional values

-- calculate the number of seconds from a
-- number of steps in the given unit of time
total
toSeconds : UnitOfTime -> Integer -> Integer

-- Given a number of seconds, calculate the
-- number of steps in the given unit of time
total
fromSeconds : UnitOfTime -> Integer -> Integer

-- convert the number of steps in a given unit of time
-- to the number of steps in another unit of time.
-- use `fromSeconds` and `toSeconds` in your implementation
total
convert : UnitOfTime -> Integer -> UnitOfTime -> Integer
```

## Exercise 3

Define a data type for representing a subset of the chemical elements: Hydrogen (H), Carbon (C), Nitrogen (N), Oxygen (O), and Fluorine (F).

Declare and implement function `atomicMass`, which for each element returns its atomic mass in dalton:

```repl
Hydrogen : 1.008
Carbon : 12.011
Nitrogen : 14.007
Oxygen : 15.999
Fluorine : 18.9984
```

<!-- vi: filetype=idris2:syntax=markdown
-->
