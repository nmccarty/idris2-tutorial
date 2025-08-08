# Exercises part 2

1. Reimplement the following *do blocks*, once by using *bang notation*, and once by writing them in their desugared form with nested *bind*s:

   ```idris
   ex1a : IO String
   ex1a = do
     s1 <- getLine
     s2 <- getLine
     s3 <- getLine
     pure $ s1 ++ reverse s2 ++ s3

   ex1b : Maybe Integer
   ex1b = do
     n1 <- parseInteger "12"
     n2 <- parseInteger "300"
     Just $ n1 + n2 * 100
   ```

2. Below is the definition of an indexed family of types, the index of which keeps track of whether the value in question is possibly empty or provably non-empty:

   ```idris
   data List01 : (nonEmpty : Bool) -> Type -> Type where
     Nil  : List01 False a
     (::) : a -> List01 False a -> List01 ne a
   ```

   Please note, that the `Nil` case *must* have the `nonEmpty` tag set to `False`, while with the *cons* case, this is optional. So, a `List01 False a` can be empty or non-empty, and we'll only find out, which is the case, by pattern matching on it. A `List01 True a` on the other hand *must* be a *cons*, as for the `Nil` case the `nonEmpty` tag is always set to `False`.

   1. Declare and implement function `head` for non-empty lists:

      ```idris
      head : List01 True a -> a
      ```

   2. Declare and implement function `weaken` for converting any `List01 ne a` to a `List01 False a` of the same length and order of values.

   3. Declare and implement function `tail` for extracting the possibly empty tail from a non-empty list.

   4. Implement function `(++)` for concatenating two values of type `List01`. Note, how we use a type-level computation to make sure the result is non-empty if and only if at least one of the two arguments is non-empty:

      ```idris
      (++) : List01 b1 a -> List01 b2 a -> List01 (b1 || b2) a
      ```

   5. Implement utility function `concat'` and use it in the implementation of `concat`. Note, that in `concat` the two boolean tags are passed as unrestricted implicits, since you will need to pattern match on these to determine whether the result is provably non-empty or not:

      ```idris
      concat' : List01 ne1 (List01 ne2 a) -> List01 False a

      concat :  {ne1, ne2 : _}
             -> List01 ne1 (List01 ne2 a)
             -> List01 (ne1 && ne2) a
      ```

   6. Implement `map01`:

      ```idris
      map01 : (a -> b) -> List01 ne a -> List01 ne b
      ```

   7. Implement a custom *bind* operator in namespace `List01` for sequencing computations returning `List01`s.

      Hint: Use `map01` and `concat` in your implementation and make sure to use unrestricted implicits where necessary.

      You can use the following examples to test your custom *bind* operator:

      ```idris
      -- this and lf are necessary to make sure, which tag to use
      -- when using list literals
      lt : List01 True a -> List01 True a
      lt = id

      lf : List01 False a -> List01 False a
      lf = id

      test : List01 True Integer
      test = List01.do
        x  <- lt [1,2,3]
        y  <- lt [4,5,6,7]
        op <- lt [(*), (+), (-)]
        [op x y]

      test2 : List01 False Integer
      test2 = List01.do
        x  <- lt [1,2,3]
        y  <- Nil {a = Integer}
        op <- lt [(*), (+), (-)]
        lt [op x y]
      ```

Some notes on Exercise 2: Here, we combined the capabilities of `List` and `Data.List1` in a single indexed type family. This allowed us to treat list concatenation correctly: If at least one of the arguments is provably non-empty, the result is also non-empty. To tackle this correctly with `List` and `List1`, a total of four concatenation functions would have to be written. So, while it is often possible to define distinct data types instead of indexed families, the latter allow us to perform type-level computations to be more precise about the pre- and postconditions of the functions we write, at the cost of more-complex type signatures. In addition, sometimes it's not possible to derive the values of the indices from pattern matching on the data values alone, so they have to be passed as unerased (possibly implicit) arguments.

Please remember, that *do blocks* are first desugared, before type-checking, disambiguating which *bind* operator to use, and filling in implicit arguments. It is therefore perfectly fine to define *bind* operators with arbitrary constraints or implicit arguments as was shown above. Idris will handle all the details, *after* desugaring the *do blocks*.
