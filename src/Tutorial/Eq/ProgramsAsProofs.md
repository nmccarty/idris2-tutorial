# Programs as Proofs

```idris
module Tutorial.Eq.ProgramsAsProofs

import Tutorial.Eq.Eq

import Data.Either
import Data.HList
import Data.Vect
import Data.String

%default total
```

A famous observation by mathematician *Haskell Curry* and logician *William Alvin Howard* leads to the conclusion, that we can view a *type* in a programming language with a sufficiently rich type system as a mathematical proposition and a total program calculating a *value* of this type as a proof that the proposition holds. This is also known as the [Curry-Howard isomorphism](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence).

For instance, here is a simple proof that one plus one equals two:

```idris
onePlusOne : the Nat 1 + 1 = 2
onePlusOne = Refl
```

The above proof is trivial, as Idris solves this by unification. But we already stated some more interesting things in the exercises. For instance, the symmetry and transitivity of `SameColType`:

```idris
sctSymmetric : SameColType c1 c2 -> SameColType c2 c1
sctSymmetric SameCT = SameCT

sctTransitive : SameColType c1 c2 -> SameColType c2 c3 -> SameColType c1 c3
sctTransitive SameCT SameCT = SameCT
```

Note, that a type alone is not a proof. For instance, we are free to state that one plus one equals three:

```idris
onePlusOneWrong : the Nat 1 + 1 = 3
```

We will, however, have a hard time implementing this in a provably total way. We say: "The type `the Nat 1 + 1 = 3` is *uninhabited*", meaning, that there is no value of this type.

## When Proofs replace Tests

We will see several different use cases for compile time proofs, a very straight forward one being to show that our functions behave as they should by proofing some properties about them. For instance, here is a proposition that `map` on list does not change the number of elements in the list:

```idris
mapListLength : (f : a -> b) -> (as : List a) -> length as = length (map f as)
```

Read this as a universally quantified statement: For all functions `f` from `a` to `b` and for all lists `as` holding values of type `a`, the length of `map f as` is the same the as the length of the original list.

We can implement `mapListLength` by pattern matching on `as`. The `Nil` case will be trivial: Idris solves this by unification. It knows the value of the input list (`Nil`), and since `map` is implemented by pattern matching on the input as well, it follows immediately that the result will be `Nil` as well:

```idris
mapListLength f []        = Refl
```

The `cons` case is more involved, and we will do this stepwise. First, note that we can proof that the length of a map over the tail will stay the same by means of recursion:

```repl
mapListLength f (x :: xs) = case mapListLength f xs of
  prf => ?mll1
```

Let's inspect the types and context we have here:

```repl
 0 b : Type
 0 a : Type
   xs : List a
   f : a -> b
   x : a
   prf : length xs = length (map f xs)
------------------------------
mll1 : S (length xs) = S (length (map f xs))
```

So, we have a proof of type `length xs = length (map f xs)`, and from the implementation of `map` Idris concludes that what we are actually looking for is a result of type `S (length xs) = S (length (map f xs))`. This is exactly what function `cong` from the *Prelude* is for ("cong" is an abbreviation for *congruence*). We can thus implement the *cons* case concisely like so:

```idris
mapListLength f (x :: xs) = cong S $ mapListLength f xs
```

Please take a moment to appreciate what we achieved here: A *proof* in the mathematical sense that our function will not affect the length of our list. We no longer need a unit test or similar program to verify this.

Before we continue, please note an important thing: In our case expression, we used a *variable* for the result from the recursive call:

```repl
mapListLength f (x :: xs) = case mapListLength f xs of
  prf => cong S prf
```

Here, we did not want the two lengths to unify, because we needed the distinction in our call to `cong`. Therefore: If you need a proof of type `x = y` in order for two variables to unify, use the `Refl` data constructor in the pattern match. If, on the other hand, you need to run further computations on such a proof, use a variable and the left and right-hand sides will remain distinct.

Here is another example from the last chapter: We want to show that parsing and printing column types behaves correctly. Writing proofs about parsers can be very hard in general, but here it can be done with a mere pattern match:

```idris
showColType : ColType -> String
showColType I64      = "i64"
showColType Str      = "str"
showColType Boolean  = "boolean"
showColType Float    = "float"

readColType : String -> Maybe ColType
readColType "i64"      = Just I64
readColType "str"      = Just Str
readColType "boolean"  = Just Boolean
readColType "float"    = Just Float
readColType s          = Nothing

showReadColType : (c : ColType) -> readColType (showColType c) = Just c
showReadColType I64     = Refl
showReadColType Str     = Refl
showReadColType Boolean = Refl
showReadColType Float   = Refl
```

Such simple proofs give us quick but strong guarantees that we did not make any stupid mistakes.

The examples we saw so far were very easy to implement. In general, this is not the case, and we will have to learn about several additional techniques in order to proof interesting things about our programs. However, when we use Idris as a general purpose programming language and not as a proof assistant, we are free to choose whether some aspect of our code needs such strong guarantees or not.

## A Note of Caution: Lowercase Identifiers in Function Types

When writing down the types of proofs as we did above, one has to be very careful not to fall into the following trap: In general, Idris will treat lowercase identifiers in function types as type parameters (erased implicit arguments). For instance, here is a try at proofing the identity functor law for `Maybe`:

```idris
mapMaybeId1 : (ma : Maybe a) -> map id ma = ma
mapMaybeId1 Nothing  = Refl
mapMaybeId1 (Just x) = ?mapMaybeId1_rhs
```

You will not be able to implement the `Just` case, because Idris treats `id` as an implicit argument as can easily be seen when inspecting the context of `mapMaybeId1_rhs`:

```repl
Tutorial.Relations> :t mapMaybeId1_rhs
 0 a : Type
 0 id : a -> a
   x : a
------------------------------
mapMaybeId1_rhs : Just (id x) = Just x
```

As you can see, `id` is an erased argument of type `a -> a`. And in fact, when type-checking this module, Idris will issue a warning that parameter `id` is shadowing an existing function:

```repl
Warning: We are about to implicitly bind the following lowercase names.
You may be unintentionally shadowing the associated global definitions:
  id is shadowing Prelude.Basics.id
```

The same is not true for `map`: Since we explicitly pass arguments to `map`, Idris treats this as a function name and not as an implicit argument.

You have several options here. For instance, you could use an uppercase identifier, as these will never be treated as implicit arguments:

```idris
Id : a -> a
Id = id

mapMaybeId2 : (ma : Maybe a) -> map Id ma = ma
mapMaybeId2 Nothing  = Refl
mapMaybeId2 (Just x) = Refl
```

As an alternative - and this is the preferred way to handle this case - you can prefix `id` with part of its namespace, which will immediately resolve the issue:

```idris
mapMaybeId : (ma : Maybe a) -> map Prelude.id ma = ma
mapMaybeId Nothing  = Refl
mapMaybeId (Just x) = Refl
```

Note: If you have semantic highlighting turned on in your editor (for instance, by using the [idris2-lsp plugin](https://github.com/idris-community/idris2-lsp)), you will note that `map` and `id` in `mapMaybeId1` get highlighted differently: `map` as a function name, `id` as a bound variable.

<!-- vi: filetype=idris2:syntax=markdown
-->
