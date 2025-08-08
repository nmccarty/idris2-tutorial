# Dependent Pairs

```idris
module Tutorial.DPair.DPair

import Data.DPair
import Data.Either
import Data.HList
import Data.List
import Data.List1
import Data.Singleton
import Data.String
import Data.Vect

import Text.CSV

%default total
```

We've already seen several examples of how useful the length index of a vector is to describe more precisely in the types what a function can and can't do. For instance, `map` or `traverse` operating on a vector will return a vector of exactly the same length. The types guarantee that this is true, therefore the following function is perfectly safe and provably total:

```idris
parseAndDrop : Vect (3 + n) String -> Maybe (Vect n Nat)
parseAndDrop = map (drop 3) . traverse parsePositive
```

Since the argument of `traverse parsePositive` is of type `Vect (3 + n) String`, its result will be of type `Maybe (Vect (3 + n) Nat)`. It is therefore safe to use this in a call to `drop 3`. Note, how all of this is known at compile time: We encoded the prerequisite that the first argument is a vector of at least three elements in the length index and could derive the length of the result from this.

## Vectors of Unknown Length

However, this is not always possible. Consider the following function, defined on `List` and exported by `Data.List`:

```repl
Tutorial.Relations> :t takeWhile
Data.List.takeWhile : (a -> Bool) -> List a -> List a
```

This will take the longest prefix of the list argument, for which the given predicate returns `True`. In this case, it depends on the list elements and the predicate, how long this prefix will be. Can we write such a function for vectors? Let's give it a try:

```idris
takeWhile' : (a -> Bool) -> Vect n a -> Vect m a
```

Go ahead, and try to implement this. Don't try too long, as you will not be able to do so in a provably total way. The question is: What is the problem here? In order to understand this, we have to realize what the type of `takeWhile'` promises: "For all predicates operating on values on type `a`, and for all vectors holding values of this type, and for all lengths `m`, I give you a vector of length `m` holding values of type `a`". All three arguments are said to be [*universally quantified*](https://en.wikipedia.org/wiki/Universal_quantification): The caller of our function is free to choose the predicate, the input vector, the type of values the vector holds, and *the length of the output vector*. Don't believe me? See here:

```idris
-- This looks like trouble: We got a non-empty vector of `Void`...
voids : Vect 7 Void
voids = takeWhile' (const True) []

-- ...from which immediately follows a proof of `Void`
proofOfVoid : Void
proofOfVoid = head voids
```

See how I could freely decide on the value of `m` when invoking `takeWhile'`? Although I passed `takeWhile'` an empty vector (the only existing vector holding values of type `Void`), the function's type promises me to return a possibly non-empty vector holding values of the same type, from which I freely extracted the first one.

Luckily, Idris doesn't allow this: We won't be able to implement `takeWhile'` without cheating (for instance, by turning totality checking off and looping forever). So, the question remains, how to express the result of `takeWhile'` in a type. The answer to this is: "Use a *dependent pair*", a vector paired with a value corresponding to its length.

```idris
record AnyVect a where
  constructor MkAnyVect
  length : Nat
  vect   : Vect length a
```

This corresponds to [*existential quantification*](https://en.wikipedia.org/wiki/Existential_quantification) in predicate logic: There is a natural number, which corresponds to the length of the vector I have here. Note, how from the outside of `AnyVect a`, the length of the wrapped vector is no longer visible at the type level but we can still inspect it and learn something about it at runtime, since it is wrapped up together with the actual vector. We can implement `takeWhile` in such a way that it returns a value of type `AnyVect a`:

```idris
takeWhile : (a -> Bool) -> Vect n a -> AnyVect a
takeWhile f []        = MkAnyVect 0 []
takeWhile f (x :: xs) = case f x of
  False => MkAnyVect 0 []
  True  => let MkAnyVect n ys = takeWhile f xs in MkAnyVect (S n) (x :: ys)
```

This works in a provably total way, because callers of this function can no longer choose the length of the resulting vector themselves. Our function, `takeWhile`, decides on this length and returns it together with the vector, and the type checker verifies that we make no mistakes when pairing the two values. In fact, the length can be inferred automatically by Idris, so we can replace it with underscores, if we so desire:

```idris
takeWhile2 : (a -> Bool) -> Vect n a -> AnyVect a
takeWhile2 f []        = MkAnyVect _ []
takeWhile2 f (x :: xs) = case f x of
  False => MkAnyVect 0 []
  True  => let MkAnyVect _ ys = takeWhile2 f xs in MkAnyVect _ (x :: ys)
```

To summarize: Parameters in generic function types are universally quantified, and their values can be decided on at the call site of such functions. Dependent record types allow us to describe existentially quantified values. Callers cannot choose such values freely: They are returned as part of a function's result.

Note, that Idris allows us to be explicit about universal quantification. The type of `takeWhile'` can also be written like so:

```idris
takeWhile'' : forall a, n, m . (a -> Bool) -> Vect n a -> Vect m a
```

Universally quantified arguments are desugared to implicit erased arguments by Idris. The above is a less verbose version of the following function type, the likes of which we have seen before:

```idris
takeWhile''' :  {0 a : _}
             -> {0 n : _}
             -> {0 m : _}
             -> (a -> Bool)
             -> Vect n a
             -> Vect m a
```

In Idris, we are free to choose whether we want to be explicit about universal quantification. Sometimes it can help understanding what's going on at the type level. Other languages - for instance [PureScript](https://www.purescript.org/) - are more strict about this: There, explicit annotations on universally quantified parameters are [mandatory](https://github.com/purescript/documentation/blob/master/language/Differences-from-Haskell.md#explicit-forall).

## The Essence of Dependent Pairs

It can take some time and experience to understand what's going on here. At least in my case, it took many sessions programming in Idris, before I figured out what dependent pairs are about: They pair a *value* of some type with a second value of a type calculated from the first value. For instance, a natural number `n` (the value) paired with a vector of length `n` (the second value, the type of which *depends* on the first value). This is such a fundamental concept of programming with dependent types, that a general dependent pair type is provided by the *Prelude*. Here is its implementation (primed for disambiguation):

```idris
record DPair' (a : Type) (p : a -> Type) where
  constructor MkDPair'
  fst : a
  snd : p fst
```

It is essential to understand what's going on here. There are two parameters: A type `a`, and a function `p`, calculating a *type* from a *value* of type `a`. Such a value (`fst`) is then used to calculate the *type* of the second value (`snd`). For instance, here is `AnyVect a` represented as a `DPair`:

```idris
AnyVect' : (a : Type) -> Type
AnyVect' a = DPair Nat (\n => Vect n a)
```

Note, how `\n => Vect n a` is a function from `Nat` to `Type`. Idris provides special syntax for describing dependent pairs, as they are important building blocks for programming in languages with first class types:

```idris
AnyVect'' : (a : Type) -> Type
AnyVect'' a = (n : Nat ** Vect n a)
```

We can inspect at the REPL, that the right hand side of `AnyVect''` get's desugared to the right hand side of `AnyVect'`:

```repl
Tutorial.Relations> (n : Nat ** Vect n Int)
DPair Nat (\n => Vect n Int)
```

Idris can infer, that `n` must be of type `Nat`, so we can drop this information. (We still need to put the whole expression in parentheses.)

```idris
AnyVect3 : (a : Type) -> Type
AnyVect3 a = (n ** Vect n a)
```

This allows us to pair a natural number `n` with a vector of length `n`, which is exactly what we did with `AnyVect`. We can therefore rewrite `takeWhile` to return a `DPair` instead of our custom type `AnyVect`. Note, that like with regular pairs, we can use the same syntax `(x ** y)` for creating and pattern matching on dependent pairs:

```idris
takeWhile3 : (a -> Bool) -> Vect m a -> (n ** Vect n a)
takeWhile3 f []        = (_ ** [])
takeWhile3 f (x :: xs) = case f x of
  False => (_ ** [])
  True  => let (_  ** ys) = takeWhile3 f xs in (_ ** x :: ys)
```

Just like with regular pairs, we can use the dependent pair syntax to define dependent triples and larger tuples:

```idris
AnyMatrix : (a : Type) -> Type
AnyMatrix a = (m ** n ** Vect m (Vect n a))
```

## Erased Existentials

Sometimes, it is possible to determine the value of an index by pattern matching on a value of the indexed type. For instance, by pattern matching on a vector, we can learn about its length index. In these cases, it is not strictly necessary to carry around the index at runtime, and we can write a special version of a dependent pair where the first argument has quantity zero. Module `Data.DPair` from *base* exports data type `Exists` for this use case.

As an example, here is a version of `takeWhile` returning a value of type `Exists`:

```idris
takeWhileExists : (a -> Bool) -> Vect m a -> Exists (\n => Vect n a)
takeWhileExists f []        = Evidence _ []
takeWhileExists f (x :: xs) = case f x of
  True  => let Evidence _ ys = takeWhileExists f xs
            in Evidence _ (x :: ys)
  False => takeWhileExists f xs
```

In order to restore an erased value, data type `Singleton` from *base* module `Data.Singleton` can be useful: It is parameterized by the *value* it stores:

```idris
true : Singleton True
true = Val True
```

This is called a *singleton* type: A type corresponding to exactly one value. It is a type error to return any other value for constant `true`, and Idris knows this:

```idris
true' : Singleton True
true' = Val _
```

We can use this to conjure the (erased!) length of a vector out of thin air:

```idris
vectLength : Vect n a -> Singleton n
vectLength []        = Val 0
vectLength (x :: xs) = let Val k = vectLength xs in Val (S k)
```

This function comes with much stronger guarantees than `Data.Vect.length`: The latter claims to just return *any* natural number, while `vectLength` *must* return exactly `n` in order to type check. As a demonstration, here is a well-typed bogus implementation of `length`:

```idris
bogusLength : Vect n a -> Nat
bogusLength = const 0
```

This would not be accepted as a valid implementation of `vectLength`, as you may quickly verify yourself.

With the help of `vectLength` (but not with `Data.Vect.length`) we can convert an erased existential to a proper dependent pair:

```idris
toDPair : Exists (\n => Vect n a) -> (m ** Vect m a)
toDPair (Evidence _ as) = let Val m = vectLength as in (m ** as)
```

Again, as a quick exercise, try implementing `toDPair` in terms of `length`, and note how Idris will fail to unify the result of `length` with the actual length of the vector.

<!-- vi: filetype=idris2:syntax=markdown
-->
