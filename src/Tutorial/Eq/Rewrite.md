# Rewrite Rules

```idris
module Tutorial.Eq.Rewrite

import Data.Either
import Data.HList
import Data.Vect
import Data.String

%default total
```

One of the most important use cases of propositional equality is to replace or *rewrite* existing types, which Idris can't unify automatically otherwise. For instance, the following is no problem: Idris know that `0 + n` equals `n`, because `plus` on natural numbers is implemented by pattern matching on the first argument. The two vector lengths therefore unify just fine.

```idris
leftZero :  List (Vect n Nat)
         -> List (Vect (0 + n) Nat)
         -> List (Vect n Nat)
leftZero = (++)
```

However, the example below can't be implemented as easily (try it!), because Idris can't figure out on its own that the two lengths unify.

```idris
rightZero' :  List (Vect n Nat)
           -> List (Vect (n + 0) Nat)
           -> List (Vect n Nat)
```

Probably for the first time we realize, just how little Idris knows about the laws of arithmetics. Idris is able to unify values when

- all values in a computation are known at compile time
- one expression follows directly from the other due to the pattern matches used in a function's implementation.

In expression `n + 0`, not all values are known (`n` is a variable), and `(+)` is implemented by pattern matching on the first argument, about which we know nothing here.

However, we can teach Idris. If we can proof that the two expressions are equivalent, we can replace one expression for the other, so that the two unify again. Here is a lemma and its proof, that `n + 0` equals `n`, for all natural numbers `n`.

```idris
addZeroRight : (n : Nat) -> n + 0 = n
addZeroRight 0     = Refl
addZeroRight (S k) = cong S $ addZeroRight k
```

Note, how the base case is trivial: Since there are no variables left, Idris can immediately figure out that `0 + 0 = 0`. In the recursive case, it can be instructive to replace `cong S` with a hole and look at its type and context to figure out how to proceed.

The *Prelude* exports function `replace` for substituting one variable in a term by another, based on a proof of equality. Make sure to inspect its type first before looking at the example below:

```idris
replaceVect : Vect (n + 0) a -> Vect n a
replaceVect as = replace {p = \k => Vect k a} (addZeroRight n) as
```

As you can see, we *replace* a value of type `p x` with a value of type `p y` based on a proof that `x = y`, where `p` is a function from some type `t` to `Type`, and `x` and `y` are values of type `t`. In our `replaceVect` example, `t` equals `Nat`, `x` equals `n + 0`, `y` equals `n`, and `p` equals `\k => Vect k a`.

Using `replace` directly is not very convenient, because Idris can often not infer the value of `p` on its own. Indeed, we had to give its type explicitly in `replaceVect`. Idris therefore provides special syntax for such *rewrite rules*, which will get desugared to calls to `replace` with all the details filled in for us. Here is an implementation of `replaceVect` with a rewrite rule:

```idris
rewriteVect : Vect (n + 0) a -> Vect n a
rewriteVect as = rewrite sym (addZeroRight n) in as
```

One source of confusion is that *rewrite* uses proofs of equality the other way round: Given an `y = x` it replaces `p x` with `p y`. Hence the need to call `sym` in our implementation above.

## Use Case: Reversing Vectors

Rewrite rules are often required when we perform interesting type-level computations. For instance, we have already seen many interesting examples of functions operating on `Vect`, which allowed us to keep track of the exact lengths of the vectors involved, but one key functionality has been missing from our discussions so far, and for good reasons: Function `reverse`. Here is a possible implementation, which is how `reverse` is implemented for lists:

```repl
revOnto' : Vect m a -> Vect n a -> Vect (m + n) a
revOnto' xs []        = xs
revOnto' xs (x :: ys) = revOnto' (x :: xs) ys


reverseVect' : Vect n a -> Vect n a
reverseVect' = revOnto' []
```

As you might have guessed, this will not compile as the length indices in the two clauses of `revOnto'` do not unify.

The *nil* case is a case we've already seen above: Here `n` is zero, because the second vector is empty, so we have to convince Idris once again that `m + 0 = m`:

```idris
revOnto : Vect m a -> Vect n a -> Vect (m + n) a
revOnto xs [] = rewrite addZeroRight m in xs
```

The second case is more complex. Here, Idris fails to unify `S (m + len)` with `m + S len`, where `len` is the length of `ys`, the tail of the second vector. Module `Data.Nat` provides many proofs about arithmetic operations on natural numbers, one of which is `plusSuccRightSucc`. Here's its type:

```repl
Tutorial.Eq> :t plusSuccRightSucc
Data.Nat.plusSuccRightSucc :  (left : Nat)
                           -> (right : Nat)
                           -> S (left + right) = left + S right
```

In our case, we want to replace `S (m + len)` with `m + S len`, so we will need the version with arguments flipped. However, there is one more obstacle: We need to invoke `plusSuccRightSucc` with the length of `ys`, which is not given as an implicit function argument of `revOnto`. We therefore need to pattern match on `n` (the length of the second vector), in order to bind the length of the tail to a variable. Remember, that we are allowed to pattern match on an erased argument only if the constructor used follows from a match on another, unerased, argument (`ys` in this case). Here's the implementation of the second case:

```idris
revOnto {n = S len} xs (x :: ys) =
  rewrite sym (plusSuccRightSucc m len) in revOnto (x :: xs) ys
```

I know from my own experience that this can be highly confusing at first. If you use Idris as a general purpose programming language and not as a proof assistant, you probably will not have to use rewrite rules too often. Still, it is important to know that they exist, as they allow us to teach complex equivalences to Idris.

## A Note on Erasure

Single value data types like `Unit`, `Equal`, or `SameSchema` have not runtime relevance, as values of these types are always identical. We can therefore always use them as erased function arguments while still being able to pattern match on these values. For instance, when you look at the type of `replace`, you will see that the equality proof is an erased argument. This allows us to run arbitrarily complex computations to produce such values without fear of these computations slowing down the compiled Idris program.

<!-- vi: filetype=idris2:syntax=markdown
-->
