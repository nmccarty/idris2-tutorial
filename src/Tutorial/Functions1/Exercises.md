# Exercises

```idris
module Tutorial.Functions1.Exercises
```

1. Reimplement functions `testSquare` and `twice` by using the dot operator and
   dropping the second arguments (have a look at the implementation of
   `squareTimes2` to get an idea where this should lead you). This highly
   concise way of writing function implementations is sometimes called
   *point-free style* and is often the preferred way of writing small utility
   functions.

2. Declare and implement function `isOdd` by combining functions `isEven` from
   above and `not` (from the Idris *Prelude*). Use point-free style.

3. Declare and implement function `isSquareOf`, which checks whether its first
   `Integer` argument is the square of the second argument.

4. Declare and implement function `isSmall`, which checks whether its `Integer`
   argument is less than or equal to 100. Use one of the comparison operators
   `<=` or `>=` in your implementation.

5. Declare and implement function `absIsSmall`, which checks whether the
   absolute value of its `Integer` argument is less than or equal to 100.  Use
   functions `isSmall` and `abs` (from the Idris *Prelude*) in your
   implementation, which should be in point-free style.

6. In this slightly extended exercise we are going to implement some utilities
   for working with `Integer` predicates (functions from `Integer` to `Bool`).
   Implement the following higher-order functions (use boolean operators `&&`,
   `||`, and function `not` in your implementations):

   ```idris
   -- return true, if and only if both predicates hold
   and : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool

   -- return true, if and only if at least one predicate holds
   or : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool

   -- return true, if the predicate does not hold
   negate : (Integer -> Bool) -> Integer -> Bool
   ```

   After solving this exercise, give it a go in the REPL. In the example below,
   we use binary function `and` in infix notation by wrapping it in backticks.
   This is just a syntactic convenience to make certain function applications
   more readable:

   ```repl
   Tutorial.Functions1> negate (isSmall `and` isOdd) 73
   False
   ```

7. As explained above, Idris allows us to define our own infix operators.  Even
   better, Idris supports *overloading* of function names, that is, two
   functions or operators can have the same name, but different types and
   implementations.  Idris will make use of the types to distinguish between
   equally named operators and functions.

   This allows us, to reimplement functions `and`, `or`, and `negate` from
   Exercise 6 by using the existing operator and function names from boolean
   algebra:

   ```idris
   -- return true, if and only if both predicates hold
   (&&) : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool
   x && y = and x y

   -- return true, if and only if at least one predicate holds
   (||) : (Integer -> Bool) -> (Integer -> Bool) -> Integer -> Bool

   -- return true, if the predicate does not hold
   not : (Integer -> Bool) -> Integer -> Bool
   ```

   Implement the other two functions and test them at the REPL:

   ```repl
   Tutorial.Functions1> not (isSmall && isOdd) 73
   False
   ```

<!-- vi: filetype=idris2:syntax=markdown
-->
