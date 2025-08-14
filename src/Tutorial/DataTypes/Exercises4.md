# Generic Data Type Exercises

```idris
module Tutorial.DataTypes.Exercises4

import Tutorial.DataTypes.SumTypes
```

```idris hide
-- Define this so we can syntax highlight the examples using it, but don't show it
data Element = C | H | O
```

The solutions to these exercises can be found in [`src/Solutions/DataTypes.idr`](../../Solutions/DataTypes.md).

If this is your first time programming in a pure functional language, these exercises are *very* important. Do not skip any of them! Take your time and work through them all. In most cases, the types should be enough to explain what's going on, even though they might appear cryptic in the beginning. Otherwise, have a look at the comments (if any) of each exercise.

Remember, that lower-case identifiers in a function signature are treated as type parameters.

## Exercise 1

Implement the following generic functions for `Maybe`:

```idris
-- make sure to map a `Just` to a `Just`.
total
mapMaybe : (a -> b) -> Maybe a -> Maybe b

-- Example: `appMaybe (Just (+2)) (Just 20) = Just 22`
total
appMaybe : Maybe (a -> b) -> Maybe a -> Maybe b

-- Example: `bindMaybe (Just 12) Just = Just 12`
total
bindMaybe : Maybe a -> (a -> Maybe b) -> Maybe b

-- keep the value in a `Just` only if the given predicate holds
total
filterMaybe : (a -> Bool) -> Maybe a -> Maybe a

-- keep the first value that is not a `Nothing` (if any)
total
first : Maybe a -> Maybe a -> Maybe a

-- keep the last value that is not a `Nothing` (if any)
total
last : Maybe a -> Maybe a -> Maybe a

-- this is another general way to extract a value from a `Maybe`.
-- Make sure the following holds:
-- `foldMaybe (+) 5 Nothing = 5`
-- `foldMaybe (+) 5 (Just 12) = 17`
total
foldMaybe : (acc -> el -> acc) -> acc -> Maybe el -> acc
```

## Exercise 2

Implement the following generic functions for `Either`:

```idris
total
mapEither : (a -> b) -> Either e a -> Either e b

-- In case of both `Either`s being `Left`s, keep the
-- value stored in the first `Left`.
total
appEither : Either e (a -> b) -> Either e a -> Either e b

total
bindEither : Either e a -> (a -> Either e b) -> Either e b

-- Keep the first value that is not a `Left`
-- If both `Either`s are `Left`s, use the given accumulator
-- for the error values
total
firstEither : (e -> e -> e) -> Either e a -> Either e a -> Either e a

-- Keep the last value that is not a `Left`
-- If both `Either`s are `Left`s, use the given accumulator
-- for the error values
total
lastEither : (e -> e -> e) -> Either e a -> Either e a -> Either e a

total
fromEither : (e -> c) -> (a -> c) -> Either e a -> c
```

## Exercise 3

Implement the following generic functions for `List`:

```idris
total
mapList : (a -> b) -> List a -> List b

total
filterList : (a -> Bool) -> List a -> List a

-- re-implement list concatenation (++) such that e.g. (++) [1, 2] [3, 4] = [1, 2, 3, 4]
-- note that because this function conflicts with the standard
-- Prelude.List.(++), if you use it then you will need to prefix it with
-- the name of your module, like DataTypes.(++) or Ch3.(++). alternatively
-- you could simply call the function something unique like myListConcat or concat'
total
(++) : List a -> List a -> List a

-- return the first value of a list, if it is non-empty
total
headMaybe : List a -> Maybe a

-- return everything but the first value of a list, if it is non-empty
total
tailMaybe : List a -> Maybe (List a)

-- return the last value of a list, if it is non-empty
total
lastMaybe : List a -> Maybe a

-- return everything but the last value of a list,
-- if it is non-empty
total
initMaybe : List a -> Maybe (List a)

-- accumulate the values in a list using the given
-- accumulator function and initial value
--
-- Examples:
-- `foldList (+) 10 [1,2,7] = 20`
-- `foldList String.(++) "" ["Hello","World"] = "HelloWorld"`
-- `foldList last Nothing (mapList Just [1,2,3]) = Just 3`
total
foldList : (acc -> el -> acc) -> acc -> List el -> acc
```

## Exercise 4

Assume we store user data for our web application in the following record:

```idris
record Client where
  constructor MkClient
  name          : String
  title         : Title
  age           : Bits8
  passwordOrKey : Either Bits64 String
```

Using `LoginError` from an earlier exercise, implement function `login`, which, given a list of `Client`s plus a value of type `Credentials` will return either a `LoginError` in case no valid credentials where provided, or the first `Client` for whom the credentials match.

## Exercise 5

Using your data type for chemical elements from an earlier exercise, implement a function for calculating the molar mass of a molecular formula.

Use a list of elements each paired with its count (a natural number) for representing formulae. For instance:

```idris
ethanol : List (Element,Nat)
ethanol = [(C,2),(H,6),(O,1)]
```

Hint: You can use function `cast` to convert a natural number to a `Double`.

<!-- vi: filetype=idris2:syntax=markdown
-->
