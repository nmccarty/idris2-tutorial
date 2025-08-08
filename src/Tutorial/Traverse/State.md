# Programming with State

```idris
module Tutorial.Traverse.State

import Data.HList
import Data.IORef
import Data.List1
import Data.String
import Data.Validated
import Data.Vect
import Text.CSV

%default total
```

Let's go back to our CSV reader. In order to get reasonable error messages, we'd like to tag each line with its index:

```idris
zipWithIndex : List a -> List (Nat, a)
```

It is, of course, very easy to come up with an ad hoc implementation for this:

```idris
zipWithIndex = go 1
  where go : Nat -> List a -> List (Nat,a)
        go _ []        = []
        go n (x :: xs) = (n,x) :: go (S n) xs
```

While this is perfectly fine, we should still note that we might want to do the same thing with the elements of trees, vectors, non-empty lists and so on. And again, we are interested in whether there is some form of abstraction we can use to describe such computations.

## Mutable References in Idris

Let us for a moment think about how we'd do such a thing in an imperative language. There, we'd probably define a local (mutable) variable to keep track of the current index, which would then be increased while iterating over the list in a `for`- or `while`-loop.

In Idris, there is no such thing as mutable state. Or is there? Remember, how we used a mutable reference to simulate a data base connection in an earlier exercise. There, we actually used some truly mutable state. However, since accessing or modifying a mutable variable is not a referential transparent operation, such actions have to be performed within `IO`. Other than that, nothing keeps us from using mutable variables in our code. The necessary functionality is available from module `Data.IORef` from the *base* library.

As a quick exercise, try to implement a function, which - given an `IORef Nat` - pairs a value with the current index and increases the index afterwards.

Here's how I would do this:

```idris
pairWithIndexIO : IORef Nat -> a -> IO (Nat,a)
pairWithIndexIO ref va = do
  ix <- readIORef ref
  writeIORef ref (S ix)
  pure (ix,va)
```

Note, that every time we *run* `pairWithIndexIO ref`, the natural number stored in `ref` is incremented by one. Also, look at the type of `pairWithIndexIO ref`: `a -> IO (Nat,a)`. We want to apply this effectful computation to each element in a list, which should lead to a new list wrapped in `IO`, since all of this describes a single computation with side effects. But this is *exactly* what function `traverse` does: Our input type is `a`, our output type is `(Nat,a)`, our container type is `List`, and the effect type is `IO`!

```idris
zipListWithIndexIO : IORef Nat -> List a -> IO (List (Nat,a))
zipListWithIndexIO ref = traverse (pairWithIndexIO ref)
```

Now *this* is really powerful: We could apply the same function to *any* traversable data structure. It therefore makes absolutely no sense to specialize `zipListWithIndexIO` to lists only:

```idris
zipWithIndexIO : Traversable t => IORef Nat -> t a -> IO (t (Nat,a))
zipWithIndexIO ref = traverse (pairWithIndexIO ref)
```

To please our intellectual minds even more, here is the same function in point-free style:

```idris
zipWithIndexIO' : Traversable t => IORef Nat -> t a -> IO (t (Nat,a))
zipWithIndexIO' = traverse . pairWithIndexIO
```

All that's left to do now is to initialize a new mutable variable before passing it to `zipWithIndexIO`:

```idris
zipFromZeroIO : Traversable t => t a -> IO (t (Nat,a))
zipFromZeroIO ta = newIORef 0 >>= (`zipWithIndexIO` ta)
```

Quickly, let's give this a go at the REPL:

```repl
> :exec zipFromZeroIO {t = List} ["hello", "world"] >>= printLn
[(0, "hello"), (1, "world")]
> :exec zipFromZeroIO (Just 12) >>= printLn
Just (0, 12)
> :exec zipFromZeroIO {t = Vect 2} ["hello", "world"] >>= printLn
[(0, "hello"), (1, "world")]
```

Thus, we solved the problem of tagging each element with its index once and for all for all traversable container types.

## The State Monad

Alas, while the solution presented above is elegant and performs very well, it still carries its `IO` stain, which is fine if we are already in `IO` land, but unacceptable otherwise. We do not want to make our otherwise pure functions much harder to test and reason about just for a simple case of stateful element tagging.

Luckily, there is an alternative to using a mutable reference, which allows us to keep our computations pure and untainted. However, it is not easy to come upon this alternative on one's own, and it can be hard to figure out what's going on here, so I'll try to introduce this slowly. We first need to ask ourselves what the essence of a "stateful" but otherwise pure computation is. There are two essential ingredients:

1. Access to the *current* state. In case of a pure function, this means that the function should take the current state as one of its arguments.
2. Ability to communicate the updated state to later stateful computations. In case of a pure function this means, that the function will return a pair of values: The computation's result plus the updated state.

These two prerequisites lead to the following generic type for a pure, stateful computation operating on state type `st` and producing values of type `a`:

```idris
Stateful : (st : Type) -> (a : Type) -> Type
Stateful st a = st -> (st, a)
```

Our use case is pairing elements with indices, which can be implemented as a pure, stateful computation like so:

```idris
pairWithIndex' : a -> Stateful Nat (Nat,a)
pairWithIndex' v index = (S index, (index,v))
```

Note, how we at the same time increment the index, returning the incremented value as the new state, while pairing the first argument with the original index.

Now, here is an important thing to note: While `Stateful` is a useful type alias, Idris in general does *not* resolve interface implementations for function types. If we want to write a small library of utility functions around such a type, it is therefore best to wrap it in a single-constructor data type and use this as our building block for writing more complex computations. We therefore introduce record `State` as a wrapper for pure, stateful computations:

```idris
public export
record State st a where
  constructor ST
  runST : st -> (st,a)
```

We can now implement `pairWithIndex` in terms of `State` like so:

```idris
export
pairWithIndex : a -> State Nat (Nat,a)
pairWithIndex v = ST $ \index => (S index, (index, v))
```

In addition, we can define some more utility functions. Here's one for getting the current state without modifying it (this corresponds to `readIORef`):

```idris
get : State st st
get = ST $ \s => (s,s)
```

Here are two others, for overwriting the current state. These corresponds to `writeIORef` and `modifyIORef`:

```idris
put : st -> State st ()
put v = ST $ \_ => (v,())

modify : (st -> st) -> State st ()
modify f = ST $ \v => (f v,())
```

Finally, we can define three functions in addition to `runST` for running stateful computations

```idris
runState : st -> State st a -> (st, a)
runState = flip runST

export
evalState : st -> State st a -> a
evalState s = snd . runState s

execState : st -> State st a -> st
execState s = fst . runState s
```

All of these are useful on their own, but the real power of `State s` comes from the observation that it is a monad. Before you go on, please spend some time and try implementing `Functor`, `Applicative`, and `Monad` for `State s` yourself. Even if you don't succeed, you will have an easier time understanding how the implementations below work.

```idris
export
Functor (State st) where
  map f (ST run) = ST $ \s => let (s2,va) = run s in (s2, f va)

export
Applicative (State st) where
  pure v = ST $ \s => (s,v)

  ST fun <*> ST val = ST $ \s =>
    let (s2, f)  = fun s
        (s3, va) = val s2
     in (s3, f va)

export
Monad (State st) where
  ST val >>= f = ST $ \s =>
    let (s2, va) = val s
     in runST (f va) s2
```

This may take some time to digest, so we come back to it in a slightly advanced exercise. The most important thing to note is, that we use every state value only ever once. We *must* make sure that the updated state is passed to later computations, otherwise the information about state updates is being lost. This can best be seen in the implementation of `Applicative`: The initial state, `s`, is used in the computation of the function value, which will also return an updated state, `s2`, which is then used in the computation of the function argument. This will again return an updated state, `s3`, which is passed on to later stateful computations together with the result of applying `f` to `va`.

<!-- vi: filetype=idris2:syntax=markdown
-->
