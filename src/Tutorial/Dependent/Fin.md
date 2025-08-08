# `Fin`: Safe Indexing into Vectors

```idris
module Tutorial.Dependent.Fin

import Tutorial.Dependent.LengthIndexedLists

%default total
```

Consider function `index`, which tries to extract a value from a `List` at the given position:

```idris
indexList : (pos : Nat) -> List a -> Maybe a
indexList _     []        = Nothing
indexList 0     (x :: _)  = Just x
indexList (S k) (_ :: xs) = indexList k xs
```

Now, here is a thing to consider when writing functions like `indexList`: Do we want to express the possibility of failure in the output type, or do we want to restrict the accepted arguments, so the function can no longer fail? These are important design decisions, especially in larger applications. Returning a `Maybe` or `Either` from a function forces client code to eventually deal with the `Nothing` or `Left` case, and until this happens, all intermediary results will carry the `Maybe` or `Either` stain, which will make it more cumbersome to run calculations with these intermediary results. On the other hand, restricting the values accepted as input will complicate the argument types and will put the burden of input validation on our functions' callers, (although, at compile time we can get help from Idris, as we will see when we talk about auto implicits) while keeping the output pure and clean.

Languages without dependent types (like Haskell), can often only take the route described above: To wrap the result in a `Maybe` or `Either`. However, in Idris we can often *refine* the input types to restrict the set of accepted values, thus ruling out the possibility of failure.

Assume, as an example, we'd like to extract a value from a `Vect n a` at (zero-based) index `k`. Surely, this can succeed if and only if `k` is a natural number strictly smaller than the length `n` of the vector. Luckily, we can express this precondition in an indexed type:

```idris
data Fin : (n : Nat) -> Type where
  FZ : {0 n : Nat} -> Fin (S n)
  FS : (k : Fin n) -> Fin (S n)
```

`Fin n` is the type of natural numbers strictly smaller than `n`. It is defined inductively: `FZ` corresponds to natural number *zero*, which, as can be seen in its type, is strictly smaller than `S n` for any natural number `n`. `FS` is the inductive case: If `k` is strictly smaller than `n` (`k` being of type `Fin n`), then `FS k` is strictly smaller than `S n`.

Let's come up with some values of type `Fin`:

```idris
fin0_5 : Fin 5
fin0_5 = FZ

fin0_7 : Fin 7
fin0_7 = FZ

fin1_3 : Fin 3
fin1_3 = FS FZ

fin4_5 : Fin 5
fin4_5 = FS (FS (FS (FS FZ)))
```

Note, that there is no value of type `Fin 0`. We will learn in a later session, how to express "there is no value of type `x`" in a type.

Let us now check, whether we can use `Fin` to safely index into a `Vect`:

```idris
index : Fin n -> Vect n a -> a
```

Before you continue, try to implement `index` yourself, making use of holes if you get stuck.

```idris
index FZ     (x :: _) = x
index (FS k) (_ :: xs) = index k xs
```

Note, how there is no `Nil` case and the totality checker is still happy. That's because `Nil` is of type `Vect 0 a`, but there is no value of type `Fin 0`! We can verify this by adding the missing impossible clauses:

```idris
index FZ     Nil impossible
index (FS _) Nil impossible
```

<!-- vi: filetype=idris2:syntax=markdown
-->
