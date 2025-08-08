# Into the Void

```idris
module Tutorial.Eq.Void

import Tutorial.Eq.Eq

import Data.Either
import Data.HList
import Data.Vect
import Data.String

%default total
```

Remember function `onePlusOneWrong` from above? This was definitely a wrong statement: One plus one does not equal three. Sometimes, we want to express exactly this: That a certain statement is false and does not hold. Consider for a moment what it means to proof a statement in Idris: Such a statement (or proposition) is a type, and a proof of the statement is a value or expression of this type: The type is said to be *inhabited*. If a statement is not true, there can be no value of the given type. We say, the given type is *uninhabited*. If we still manage to get our hands on a value of an uninhabited type, that is a logical contradiction and from this, anything follows (remember [ex falso quodlibet](https://en.wikipedia.org/wiki/Principle_of_explosion)).

So this is how to express that a proposition does not hold: We state that if it *would* hold, this would lead to a contradiction. The most natural way to express a contradiction in Idris is to return a value of type `Void`:

```idris
onePlusOneWrongProvably : the Nat 1 + 1 = 3 -> Void
onePlusOneWrongProvably Refl impossible
```

See how this is a provably total implementation of the given type: A function from `1 + 1 = 3` to `Void`. We implement this by pattern matching, and there is only one constructor to match on, which leads to an impossible case.

We can also use contradictory statements to proof other such statements. For instance, here is a proof that if the lengths of two lists are not the same, then the two list can't be the same either:

```idris
notSameLength1 : (List.length as = length bs -> Void) -> as = bs -> Void
notSameLength1 f prf = f (cong length prf)
```

This is cumbersome to write and pretty hard to read, so there is function `Not` in the prelude to express the same thing more naturally:

```idris
notSameLength : Not (List.length as = length bs) -> Not (as = bs)
notSameLength f prf = f (cong length prf)
```

Actually, this is just a specialized version of the contraposition of `cong`: If from `a = b` follows `f a = f b`, then from `not (f a = f b)` follows `not (a = b)`:

```idris
contraCong : {0 f : _} -> Not (f a = f b) -> Not (a = b)
contraCong fun x = fun $ cong f x
```

## Interface `Uninhabited`

There is an interface in the *Prelude* for uninhabited types: `Uninhabited` with its sole function `uninhabited`. Have a look at its documentation at the REPL. You will see, that there is already an impressive number of implementations available, many of which involve data type `Equal`.

We can use `Uninhabited`, to for instance express that the empty schema is not equal to a non-empty schema:

```idris
Uninhabited (SameSchema [] (h :: t)) where
  uninhabited Same impossible

Uninhabited (SameSchema (h :: t) []) where
  uninhabited Same impossible
```

There is a related function you need to know about: `absurd`, which combines `uninhabited` with `void`:

```repl
Tutorial.Eq> :printdef absurd
Prelude.absurd : Uninhabited t => t -> a
absurd h = void (uninhabited h)
```

## Decidable Equality

When we implemented `sameColType`, we got a proof that two column types are indeed the same, from which we could figure out, whether two schemata are identical. The types guarantee we do not generate any false positives: If we generate a value of type `SameSchema s1 s2`, we have a proof that `s1` and `s2` are indeed identical. However, `sameColType` and thus `sameSchema` could theoretically still produce false negatives by returning `Nothing` although the two values are identical. For instance, we could implement `sameColType` in such a way that it always returns `Nothing`. This would be in agreement with the types, but definitely not what we want. So, here is what we'd like to do in order to get yet stronger guarantees: We'd either want to return a proof that the two schemata are the same, or return a proof that the two schemata are not the same. (Remember that `Not a` is an alias for `a -> Void`).

We call a property, which either holds or leads to a contradiction a *decidable property*, and the *Prelude* exports data type `Dec prop`, which encapsulates this distinction.

Here is a way to encode this for `ColType`:

```idris
decSameColType :  (c1,c2 : ColType) -> Dec (SameColType c1 c2)
decSameColType I64 I64         = Yes SameCT
decSameColType I64 Str         = No $ \case SameCT impossible
decSameColType I64 Boolean     = No $ \case SameCT impossible
decSameColType I64 Float       = No $ \case SameCT impossible

decSameColType Str I64         = No $ \case SameCT impossible
decSameColType Str Str         = Yes SameCT
decSameColType Str Boolean     = No $ \case SameCT impossible
decSameColType Str Float       = No $ \case SameCT impossible

decSameColType Boolean I64     = No $ \case SameCT impossible
decSameColType Boolean Str     = No $ \case SameCT impossible
decSameColType Boolean Boolean = Yes SameCT
decSameColType Boolean Float   = No $ \case SameCT impossible

decSameColType Float I64       = No $ \case SameCT impossible
decSameColType Float Str       = No $ \case SameCT impossible
decSameColType Float Boolean   = No $ \case SameCT impossible
decSameColType Float Float     = Yes SameCT
```

First, note how we could use a pattern match in a single argument lambda directly. This is sometimes called the *lambda case* style, named after an extension of the Haskell programming language. If we use the `SameCT` constructor in the pattern match, Idris is forced to try and unify for instance `Float` with `I64`. This is not possible, so the case as a whole is impossible.

Yet, this was pretty cumbersome to implement. In order to convince Idris we did not miss a case, there is no way around treating every possible pairing of constructors explicitly. However, we get *much* stronger guarantees out of this: We can no longer create false positives *or* false negatives, and therefore, `decSameColType` is provably correct.

Doing the same thing for schemata requires some utility functions, the types of which we can figure out by placing some holes:

```idris
decSameSchema' :  (s1, s2 : Schema) -> Dec (SameSchema s1 s2)
decSameSchema' []        []        = Yes Same
decSameSchema' []        (y :: ys) = No ?decss1
decSameSchema' (x :: xs) []        = No ?decss2
decSameSchema' (x :: xs) (y :: ys) = case decSameColType x y of
  Yes SameCT => case decSameSchema' xs ys of
    Yes Same => Yes Same
    No  contra => No $ \prf => ?decss3
  No  contra => No $ \prf => ?decss4
```

The first two cases are not too hard. The type of `decss1` is `SameSchema [] (y :: ys) -> Void`, which you can easily verify at the REPL. But that's just `uninhabited`, specialized to `SameSchema [] (y :: ys)`, and this we already implemented further above. The same goes for `decss2`.

The other two cases are harder, so I already filled in as much stuff as possible. We know that we want to return a `No`, if either the heads or tails are provably distinct. The `No` holds a function, so I already added a lambda, leaving a hole only for the return value. Here are the type and - more important - context of `decss3`:

```repl
Tutorial.Relations> :t decss3
   y : ColType
   xs : List ColType
   ys : List ColType
   x : ColType
   contra : SameSchema xs ys -> Void
   prf : SameSchema (y :: xs) (y :: ys)
------------------------------
decss3 : Void
```

The types of `contra` and `prf` are what we need here: If `xs` and `ys` are distinct, then `y :: xs` and `y :: ys` must be distinct as well. This is the contraposition of the following statement: If `x :: xs` is the same as `y :: ys`, then `xs` and `ys` are the same as well. We must therefore implement a lemma, which proves that the *cons* constructor is [*injective*](https://en.wikipedia.org/wiki/Injective_function):

```idris
consInjective :  SameSchema (c1 :: cs1) (c2 :: cs2)
              -> (SameColType c1 c2, SameSchema cs1 cs2)
consInjective Same = (SameCT, Same)
```

We can now pass `prf` to `consInjective` to extract a value of type `SameSchema xs ys`, which we then pass to `contra` in order to get the desired value of type `Void`. With these observations and utilities, we can now implement `decSameSchema`:

```idris
decSameSchema :  (s1, s2 : Schema) -> Dec (SameSchema s1 s2)
decSameSchema []        []        = Yes Same
decSameSchema []        (y :: ys) = No absurd
decSameSchema (x :: xs) []        = No absurd
decSameSchema (x :: xs) (y :: ys) = case decSameColType x y of
  Yes SameCT => case decSameSchema xs ys of
    Yes Same   => Yes Same
    No  contra => No $ contra . snd . consInjective
  No  contra => No $ contra . fst . consInjective
```

There is an interface called `DecEq` exported by module `Decidable.Equality` for types for which we can implement a decision procedure for propositional equality. We can implement this to figure out if two values are equal or not.

<!-- vi: filetype=idris2:syntax=markdown
-->
