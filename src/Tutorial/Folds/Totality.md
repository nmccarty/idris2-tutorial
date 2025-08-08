# Notes on Totality Checking

```idris
module Tutorial.Folds.Totality

%default total
```

The totality checker in Idris verifies, that at least one (possibly erased!) argument in a recursive call converges towards a base case. For instance, with natural numbers, if the base case is zero (corresponding to data constructor `Z`), and we continue with `k` after pattern matching on `S k`, Idris can derive from `Nat`'s constructors, that `k` is strictly smaller than `S k` and therefore the recursive call must converge towards a base case. Exactly the same reasoning is used when pattern matching on a list and continuing only with its tail in the recursive call.

While this works in many cases, it doesn't always go as expected. Below, I'll show you a couple of examples where totality checking fails, although *we* know, that the functions in question are definitely total.

## Case 1: Recursion over a Primitive

Idris doesn't know anything about the internal structure of primitive data types. So the following function, although being obviously total, will not be accepted by the totality checker:

```idris
covering
replicatePrim : Bits32 -> a -> List a
replicatePrim 0 v = []
replicatePrim x v = v :: replicatePrim (x - 1) v
```

Unlike with natural numbers (`Nat`), which are defined as an inductive data type and are only converted to integer primitives during compilation, Idris can't tell that `x - 1` is strictly smaller than `x`, and so it fails to verify that this must converge towards the base case. (The reason is, that `x - 1` is implemented in terms of primitive function `prim__sub_Bits32`, which is built into the compiler and must be implemented by each backend individually. The totality checker knows about data types, constructors, and functions defined in Idris, but not about (primitive) functions and foreign functions implemented at the backends. While it is theoretically possible to also define and use laws for primitive and foreign functions, this hasn't yet been done for most of them.)

Since non-totality is highly contagious (all functions invoking a partial function are themselves considered to be partial by the totality checker), there is utility function `assert_smaller`, which we can use to convince the totality checker and still annotate our functions with the `total` keyword:

```idris
replicatePrim' : Bits32 -> a -> List a
replicatePrim' 0 v = []
replicatePrim' x v = v :: replicatePrim' (assert_smaller x $ x - 1) v
```

Please note, though, that whenever you use `assert_smaller` to silence the totality checker, the burden of proving totality rests on your shoulders. Failing to do so can lead to arbitrary and unpredictable program behavior (which is the default with most other programming languages).

### Ex Falso Quodlibet

Below - as a demonstration - is a simple proof of `Void`. `Void` is an *uninhabited type*: a type with no values. *Proofing `Void`* means, that we implement a function accepted by the totality checker, which returns a value of type `Void`, although this is supposed to be impossible as there is no such value. Doing so allows us to completely disable the type system together with all the guarantees it provides. Here's the code and its dire consequences:

```idris
-- In order to proof `Void`, we just loop forever, using
-- `assert_smaller` to silence the totality checker.
proofOfVoid : Bits8 -> Void
proofOfVoid n = proofOfVoid (assert_smaller n n)

-- From a value of type `Void`, anything follows!
-- This function is safe and total, as there is no
-- value of type `Void`!
exFalsoQuodlibet : Void -> a
exFalsoQuodlibet _ impossible

-- By passing our proof of void to `exFalsoQuodlibet`
-- (exported by the *Prelude* by the name of `void`), we
-- can coerce any value to a value of any other type.
-- This renders type checking completely useless, as
-- we can freely convert between values of different
-- types.
coerce : a -> b
coerce _ = exFalsoQuodlibet (proofOfVoid 0)

-- Finally, we invoke `putStrLn` with a number instead
-- of a string. `coerce` allows us to do just that.
pain : IO ()
pain = putStrLn $ coerce 0
```

Please take a moment to marvel at provably total function `coerce`: It claims to convert *any* value to a value of *any* other type. And it is completely safe, as it only uses total functions in its implementation. The problem is - of course - that `proofOfVoid` should never ever have been a total function.

In `pain` we use `coerce` to conjure a string from an integer. In the end, we get what we deserve: The program crashes with an error. While things could have been much worse, it can still be quite time consuming and annoying to localize the source of such an error.

```sh
$ idris2 --cg node --exec pain --find-ipkg src/Tutorial/Folds.md
ERROR: No clauses
```

So, with a single thoughtless placement of `assert_smaller` we wrought havoc within our pure and total codebase sacrificing totality and type safety in one fell swoop. Therefore: Use at your own risk!

Note: I do not expect you to understand all the dark magic at work in the code above. I'll explain the details in due time in another chapter.

Second note: *Ex falso quodlibet*, also called [the principle of explosion](https://en.wikipedia.org/wiki/Principle_of_explosion) is a law in logic: From a contradiction, any statement can be proven. In our case, the contradiction was our proof of `Void`: The claim that we wrote a total function producing such a value, although `Void` is an uninhabited type. You can verify this by inspecting `Void` at the REPL with `:doc Void`: It has no data constructors.

## Case 2: Recursion via Function Calls

Below is an implementation of a [*rose tree*](https://en.wikipedia.org/wiki/Rose_tree). Rose trees can represent search paths in computer algorithms, for instance in graph theory.

```idris
record Tree a where
  constructor Node
  value  : a
  forest : List (Tree a)

Forest : Type -> Type
Forest = List . Tree
```

We could try and compute the size of such a tree as follows:

```idris
covering
size : Tree a -> Nat
size (Node _ forest) = S . sum $ map size forest
```

In the code above, the recursive call happens within `map`. *We* know that we are using only subtrees in the recursive calls (since we know how `map` is implemented for `List`), but Idris can't know this (teaching a totality checker how to figure this out on its own seems to be an open research question). So it will refuse to accept the function as being total.

There are two ways to handle the case above. If we don't mind writing a bit of otherwise unneeded boilerplate code, we can use explicit recursion. In fact, since we often also work with search *forests*, this is the preferable way here.

```idris
mutual
  treeSize : Tree a -> Nat
  treeSize (Node _ forest) = S $ forestSize forest

  forestSize : Forest a -> Nat
  forestSize []        = 0
  forestSize (x :: xs) = treeSize x + forestSize xs
```

In the case above, Idris can verify that we don't blow up our trees behind its back as we are explicit about what happens in each recursive step. This is the safe, preferable way of going about this, especially if you are new to the language and totality checking in general.

However, sometimes the solution presented above is just too cumbersome to write. For instance, here is an implementation of `Show` for rose trees:

```idris
Show a => Show (Tree a) where
  showPrec p (Node v ts) =
    assert_total $ showCon p "Node" (showArg v ++ showArg ts)
```

In this case, we'd have to manually reimplement `Show` for lists of trees: A tedious task - and error-prone on its own. Instead, we resort to using the mighty sledgehammer of totality checking: `assert_total`. Needless to say that this comes with the same risks as `assert_smaller`, so be very careful.

<!-- vi: filetype=idris2:syntax=markdown
-->
