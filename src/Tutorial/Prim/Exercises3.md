# Exercises part 3

In this massive set of exercises, you are going to build a small library for working with predicates on primitives. We want to keep the following goals in mind:

- We want to use the usual operations of propositional logic to combine predicates: Negation, conjuction (logical *and*), and disjunction (logical *or*).
- All predicates should be erased at runtime. If we proof something about a primitive number, we want to make sure not to carry around a huge proof of validity.
- Calculations on predicates should make no appearance at runtime (with the exception of `decide`; see below).
- Recursive calculations on predicates should be tail recursive if they are used in implementations of `decide`. This might be tough to achieve. If you can't find a tail recursive solution for a given problem, use what feels most natural instead.

A note on efficiency: In order to be able to run computations on our predicates, we try to convert primitive values to algebraic data types as often and as soon as possible: Unsigned integers will be converted to `Nat` using `cast`, and strings will be converted to `List Char` using `unpack`. This allows us to work with proofs on `Nat` and `List` most of the time, and such proofs can be implemented without resorting to `believe_me` or other cheats. However, the one advantage of primitive types over algebraic data types is that they often perform much better. This is especially critical when comparing integral types with `Nat`: Operations on natural numbers often run with `O(n)` time complexity, where `n` is the size of one of the natural numbers involved, while with `Bits64`, for instance, many operations run in fast constant time (`O(1)`). Luckily, the Idris compiler optimizes many functions on natural number to use the corresponding `Integer` operations at runtime. This has the advantage that we can still use proper induction to proof stuff about natural numbers at compile time, while getting the benefit of fast integer operations at runtime. However, operations on `Nat` do run with `O(n)` time complexity and *compile time*. Proofs working on large natural number will therefore drastically slow down the compiler. A way out of this is discussed at the end of this section of exercises.

Enough talk, let's begin! To start with, you are given the following utilities:

```idris
-- Like `Dec` but with erased proofs. Constructors `Yes0`
-- and `No0` will be converted to constants `0` and `1` by
-- the compiler!
data Dec0 : (prop : Type) -> Type where
  Yes0 : (0 prf : prop) -> Dec0 prop
  No0  : (0 contra : prop -> Void) -> Dec0 prop

-- For interfaces with more than one parameter (`a` and `p`
-- in this example) sometimes one parameter can be determined
-- by knowing the other. For instance, if we know what `p` is,
-- we will most certainly also know what `a` is. We therefore
-- specify that proof search on `Decidable` should only be
-- based on `p` by listing `p` after a vertical bar: `| p`.
-- This is like specifing the search parameter(s) of
-- a data type with `[search p]` as was shown in the chapter
-- about predicates.
-- Specifying a single search parameter as shown here can
-- drastically help with type inference.
interface Decidable (0 a : Type) (0 p : a -> Type) | p where
  decide : (v : a) -> Dec0 (p v)

-- We often have to pass `p` explicitly in order to help Idris with
-- type inference. In such cases, it is more convenient to use
-- `decideOn pred` instead of `decide {p = pred}`.
decideOn : (0 p : a -> Type) -> Decidable a p => (v : a) -> Dec0 (p v)
decideOn _ = decide

-- Some primitive predicates can only be reasonably implemented
-- using boolean functions. This utility helps with decidability
-- on such proofs.
test0 : (b : Bool) -> Dec0 (b === True)
test0 True  = Yes0 Refl
test0 False = No0 absurd
```

We also want to run decidable computations at compile time. This is often much more efficient than running a direct proof search on an inductive type. We therefore come up with a predicate witnessing that a `Dec0` value is actually a `Yes0` together with two utility functions:

```idris
data IsYes0 : (d : Dec0 prop) -> Type where
  ItIsYes0 : {0 prf : _} -> IsYes0 (Yes0 prf)

0 fromYes0 : (d : Dec0 prop) -> (0 prf : IsYes0 d) => prop
fromYes0 (Yes0 x) = x
fromYes0 (No0 contra) impossible

0 safeDecideOn :  (0 p : a -> Type)
               -> Decidable a p
               => (v : a)
               -> (0 prf : IsYes0 (decideOn p v))
               => p v
safeDecideOn p v = fromYes0 $ decideOn p v
```

Finally, as we are planning to refine mostly primitives, we will at times require some sledge hammer to convince Idris that we know what we are doing:

```idris
-- only use this if you are sure that `decideOn p v`
-- will return a `Yes0`!
0 unsafeDecideOn : (0 p : a -> Type) -> Decidable a p => (v : a) -> p v
unsafeDecideOn p v = case decideOn p v of
  Yes0 prf => prf
  No0  _   =>
    assert_total $ idris_crash "Unexpected refinement failure in `unsafeRefineOn`"
```

01. We start with equality proofs. Implement `Decidable` for `Equal v`.

    Hint: Use `DecEq` from module `Decidable.Equality` as a constraint and make sure that `v` is available at runtime.

02. We want to be able to negate a predicate:

    ```idris
    data Neg : (p : a -> Type) -> a -> Type where
      IsNot : {0 p : a -> Type} -> (contra : p v -> Void) -> Neg p v
    ```

    Implement `Decidable` for `Neg p` using a suitable constraint.

03. We want to describe the conjunction of two predicates:

    ```idris
    data (&&) : (p,q : a -> Type) -> a -> Type where
      Both : {0 p,q : a -> Type} -> (prf1 : p v) -> (prf2 : q v) -> (&&) p q v
    ```

    Implement `Decidable` for `(p && q)` using suitable constraints.

04. Come up with a data type called `(||)` for the disjunction (logical *or*) of two predicates and implement `Decidable` using suitable constraints.

05. Proof [De Morgan's laws](https://en.wikipedia.org/wiki/De_Morgan%27s_laws) by implementing the following propositions:

    ```idris
    negOr : Neg (p || q) v -> (Neg p && Neg q) v

    andNeg : (Neg p && Neg q) v -> Neg (p || q) v

    orNeg : (Neg p || Neg q) v -> Neg (p && q) v
    ```

    The last of De Morgan's implications is harder to type and proof as we need a way to come up with values of type `p v` and `q v` and show that not both can exist. Here is a way to encode this (annotated with quantity 0 as we will need to access an erased contraposition):

    ```idris
    0 negAnd :  Decidable a p
             => Decidable a q
             => Neg (p && q) v
             -> (Neg p || Neg q) v
    ```

    When you implement `negAnd`, remember that you can freely access erased (implicit) arguments, because `negAnd` itself can only be used in an erased context.

    So far, we implemented the tools to algebraically describe and combine several predicate. It is now time to come up with some examples. As a first use case, we will focus on limiting the valid range of natural numbers. For this, we use the following data type:

    ```idris
    -- Proof that m <= n
    data (<=) : (m,n : Nat) -> Type where
      ZLTE : 0 <= n
      SLTE : m <= n -> S m <= S n
    ```

    This is similar to `Data.Nat.LTE` but I find operator notation often to be clearer. We also can define and use the following aliases:

    ```repl
    (>=) : (m,n : Nat) -> Type
    m >= n = n <= m

    (<) : (m,n : Nat) -> Type
    m < n = S m <= n

    (>) : (m,n : Nat) -> Type
    m > n = n < m

    LessThan : (m,n : Nat) -> Type
    LessThan m = (< m)

    To : (m,n : Nat) -> Type
    To m = (<= m)

    GreaterThan : (m,n : Nat) -> Type
    GreaterThan m = (> m)

    From : (m,n : Nat) -> Type
    From m = (>= m)

    FromTo : (lower,upper : Nat) -> Nat -> Type
    FromTo l u = From l && To u

    Between : (lower,upper : Nat) -> Nat -> Type
    Between l u = GreaterThan l && LessThan u
    ```

06. Coming up with a value of type `m <= n` by pattern matching on `m` and `n` is highly inefficient for large values of `m`, as it will require `m` iterations to do so. However, while in an erased context, we don't need to hold a value of type `m <= n`. We only need to show, that such a value follows from a more efficient computation. Such a computation is `compare` for natural numbers: Although this is implemented in the *Prelude* with a pattern match on its arguments, it is optimized by the compiler to a comparison of integers which runs in constant time even for very large numbers. Since `Prelude.(<=)` for natural numbers is implemented in terms of `compare`, it runs just as efficiently.

    We therefore need to proof the following two lemmas (make sure to not confuse `Prelude.(<=)` with `Prim.(<=)` in these declarations):

    ```idris
    0 fromLTE : (n1,n2 : Nat) -> (n1 <= n2) === True -> n1 <= n2

    0 toLTE : (n1,n2 : Nat) -> n1 <= n2 -> (n1 <= n2) === True
    ```

    They come with a quantity of 0, because they are just as inefficient as the other computations we discussed above. We therefore want to make absolutely sure that they will never be used at runtime!

    Now, implement `Decidable Nat (<= n)`, making use of `test0`, `fromLTE`, and `toLTE`. Likewise, implement `Decidable Nat (m <=)`, because we require both kinds of predicates.

    Note: You should by now figure out yourself that `n` must be available at runtime and how to make sure that this is the case.

07. Proof that `(<=)` is reflexive and transitive by declaring and implementing corresponding propositions. As we might require the proof of transitivity to chain several values of type `(<=)`, it makes sense to also define a short operator alias for this.

08. Proof that from `n > 0` follows `IsSucc n` and vise versa.

09. Declare and implement safe division and modulo functions for `Bits64`, by requesting an erased proof that the denominator is strictly positive when cast to a natural number. In case of the modulo function, return a refined value carrying an erased proof that the result is strictly smaller than the modulus:

    ```idris
    safeMod :  (x,y : Bits64)
            -> (0 prf : cast y > 0)
            => Subset Bits64 (\v => cast v < cast y)
    ```

10. We will use the predicates and utilities we defined so far to convert a value of type `Bits64` to a string of digits in base `b` with `2 <= b && b <= 16`. To do so, implement the following skeleton definitions:

    ```idris
    -- this will require some help from `assert_total`
    -- and `idris_crash`.
    digit : (v : Bits64) -> (0 prf : cast v < 16) => Char

    record Base where
      constructor MkBase
      value : Bits64
      0 prf : FromTo 2 16 (cast value)

    base : Bits64 -> Maybe Base

    namespace Base
      public export
      fromInteger : (v : Integer) -> {auto 0 _ : IsJust (base $ cast v)} -> Base
    ```

    Finally, implement `digits`, using `safeDiv` and `safeMod` in your implementation. This might be challenging, as you will have to manually transform some proofs to satisfy the type checker. You might also require `assert_smaller` in the recursive step.

    ```idris
    digits : Bits64 -> Base -> String
    ```

    We will now turn our focus on strings. Two of the most obvious ways in which we can restrict the strings we accept are by limiting the set of characters and limiting their lengths. More advanced refinements might require strings to match a certain pattern or regular expression. In such cases, we might either go for a boolean check or use a custom data type representing the different parts of the pattern, but we will not cover these topics here.

11. Implement the following aliases for useful predicates on characters.

    Hint: Use `cast` to convert characters to natural numbers, use `(<=)` and `InRange` to specify regions of characters, and use `(||)` to combine regions of characters.

    ```idris
    -- Characters <= 127
    IsAscii : Char -> Type

    -- Characters <= 255
    IsLatin : Char -> Type

    -- Characters in the interval ['A','Z']
    IsUpper : Char -> Type

    -- Characters in the interval ['a','z']
    IsLower : Char -> Type

    -- Lower or upper case characters
    IsAlpha : Char -> Type

    -- Characters in the range ['0','9']
    IsDigit : Char -> Type

    -- Digits or characters from the alphabet
    IsAlphaNum : Char -> Type

    -- Characters in the ranges [0,31] or [127,159]
    IsControl : Char -> Type

    -- An ASCII character that is not a control character
    IsPlainAscii : Char -> Type

    -- A latin character that is not a control character
    IsPlainLatin : Char -> Type
    ```

12. The advantage of this more modular approach to predicates on primitives is that we can safely run calculations on our predicates and get the strong guarantees from the existing proofs on inductive types like `Nat` and `List`. Here are some examples of such calculations and conversions, all of which can be implemented without cheating:

    ```idris
    0 plainToAscii : IsPlainAscii c -> IsAscii c

    0 digitToAlphaNum : IsDigit c -> IsAlphaNum c

    0 alphaToAlphaNum : IsAlpha c -> IsAlphaNum c

    0 lowerToAlpha : IsLower c -> IsAlpha c

    0 upperToAlpha : IsUpper c -> IsAlpha c

    0 lowerToAlphaNum : IsLower c -> IsAlphaNum c

    0 upperToAlphaNum : IsUpper c -> IsAlphaNum c
    ```

    The following (`asciiToLatin`) is trickier. Remember that `(<=)` is transitive. However, in your invocation of the proof of transitivity, you will not be able to apply direct proof search using `%search` because the search depth is too small. You could increase the search depth, but it is much more efficient to use `safeDecideOn` instead.

    ```idris
    0 asciiToLatin : IsAscii c -> IsLatin c

    0 plainAsciiToPlainLatin : IsPlainAscii c -> IsPlainLatin c
    ```

    Before we turn our full attention to predicates on strings, we have to cover lists first, because we will often treat strings as lists of characters.

13. Implement `Decidable` for `Head`:

    ```idris
    data Head : (p : a -> Type) -> List a -> Type where
      AtHead : {0 p : a -> Type} -> (0 prf : p v) -> Head p (v :: vs)
    ```

14. Implement `Decidable` for `Length`:

    ```idris
    data Length : (p : Nat -> Type) -> List a -> Type where
      HasLength :  {0 p : Nat -> Type}
                -> (0 prf : p (List.length vs))
                -> Length p vs
    ```

15. The following predicate is a proof that all values in a list of values fulfill the given predicate. We will use this to limit the valid set of characters in a string.

    ```idris
    data All : (p : a -> Type) -> (as : List a) -> Type where
      Nil  : All p []
      (::) :  {0 p : a -> Type}
           -> (0 h : p v)
           -> (0 t : All p vs)
           -> All p (v :: vs)
    ```

    Implement `Decidable` for `All`.

    For a real challenge, try to make your implementation of `decide` tail recursive. This will be important for real world applications on the JavaScript backends, where we might want to refine strings of thousands of characters without overflowing the stack at runtime. In order to come up with a tail recursive implementation, you will need an additional data type `AllSnoc` witnessing that a predicate holds for all elements in a `SnocList`.

16. It's time to come to an end here. An identifier in Idris is a sequence of alphanumeric characters, possibly separated by underscore characters (`_`). In addition, all identifiers must start with a letter. Given this specification, implement predicate `IdentChar`, from which we can define a new wrapper type for identifiers:

    ```idris
    0 IdentChars : List Char -> Type

    record Identifier where
      constructor MkIdentifier
      value : String
      0 prf : IdentChars (unpack value)
    ```

    Implement a factory method `identifier` for converting strings of unknown source at runtime:

    ```idris
    identifier : String -> Maybe Identifier
    ```

    In addition, implement `fromString` for `Identifier` and verify, that the following is a valid identifier:

    ```idris
    testIdent : Identifier
    testIdent = "fooBar_123"
    ```

Final remarks: Proofing stuff about the primitives can be challenging, both when deciding on what axioms to use and when trying to make things perform well at runtime and compile time. I'm experimenting with a library, which deals with these issues. It is not yet finished, but you can have a look at it [here](https://github.com/stefan-hoeck/idris2-prim).
