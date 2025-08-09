# Monad

```idris
module Tutorial.Functor.Monad

import Tutorial.Functor.Functor
import Tutorial.Functor.Applicative

import Data.List1
import Data.String
import Data.Vect

%default total
```

Finally, `Monad`. A lot of ink has been spilled about this one. However, after what we already saw in the chapter about `IO`, there is not much left to discuss here. `Monad` extends `Applicative` and adds two new related functions: The *bind* operator (`(>>=)`) and function `join`. Here is its definition:

```idris
interface Applicative' m => Monad' m where
  bind  : m a -> (a -> m b) -> m b
  join' : m (m a) -> m a
```

Implementers of `Monad` are free to choose to either implement `(>>=)` or `join` or both. You will show in an exercise, how `join` can be implemented in terms of *bind* and vice versa.

The big difference between `Monad` and `Applicative` is, that the former allows a computation to depend on the result of an earlier computation. For instance, we could decide based on a string read from standard input whether to delete a file or play a song. The result of the first `IO` action (reading some user input) will affect, which `IO` action to run next. This is not possible with the *apply* operator:

```repl
(<*>) : IO (a -> b) -> IO a -> IO b
```

The two `IO` actions have already been decided on when they are being passed as arguments to `(<*>)`. The result of the first cannot - in the general case - affect which computation to run in the second. (Actually, with `IO` this would theoretically be possible via side effects: The first action could write some command to a file or overwrite some mutable state, and the second action could read from that file or state, thus deciding on the next thing to do. But this is a speciality of `IO`, not of applicative functors in general. If the functor in question was `Maybe`, `List`, or `Vector`, no such thing would be possible.)

Let's demonstrate the difference with an example. Assume we'd like to enhance our CSV-reader with the ability to decode a line of tokens to a sum type. For instance, we'd like to decode CRUD requests from the lines of a CSV-file:

```idris
data Crud : (i : Type) -> (a : Type) -> Type where
  Create : (value : a) -> Crud i a
  Update : (id : i) -> (value : a) -> Crud i a
  Read   : (id : i) -> Crud i a
  Delete : (id : i) -> Crud i a
```

We need a way to on each line decide, which data constructor to choose for our decoding. One way to do this is to put the name of the data constructor (or some other tag of identification) in the first column of the CSV-file:

```idris
hlift : (a -> b) -> HList [a] -> b
hlift f [x] = f x

hlift2 : (a -> b -> c) -> HList [a,b] -> c
hlift2 f [x,y] = f x y

decodeCRUD :  CSVField i
           => CSVField a
           => (line : Nat)
           -> (s    : String)
           -> Either CSVError (Crud i a)
decodeCRUD l s =
  let h ::: t = split (',' ==) s
   in do
     MkName n <- readField l 1 h
     case n of
       "Create" => hlift  Create  <$> decodeAt l 2 t
       "Update" => hlift2 Update  <$> decodeAt l 2 t
       "Read"   => hlift  Read    <$> decodeAt l 2 t
       "Delete" => hlift  Delete  <$> decodeAt l 2 t
       _        => Left (FieldError l 1 n)
```

I added two utility function for helping with type inference and to get slightly nicer syntax. The important thing to note is, how we pattern match on the result of the first parsing function to decide on the data constructor and thus the next parsing function to use.

Here's how this works at the REPL:

```repl
Tutorial.Functor> decodeCRUD {i = Nat} {a = Email} 1 "Create,jon@doe.ch"
Right (Create (MkEmail "jon@doe.ch"))
Tutorial.Functor> decodeCRUD {i = Nat} {a = Email} 1 "Update,12,jane@doe.ch"
Right (Update 12 (MkEmail "jane@doe.ch"))
Tutorial.Functor> decodeCRUD {i = Nat} {a = Email} 1 "Delete,jon@doe.ch"
Left (FieldError 1 2 "jon@doe.ch")
```

To conclude, `Monad`, unlike `Applicative`, allows us to chain computations sequentially, where intermediary results can affect the behavior of later computations. So, if you have n unrelated effectful computations and want to combine them under a pure, n-ary function, `Applicative` will be sufficient. If, however, you want to decide based on the result of an effectful computation what computation to run next, you need a `Monad`.

Note, however, that `Monad` has one important drawback compared to `Applicative`: In general, monads don't compose. For instance, there is no `Monad` instance for `Either e . IO`. We will later learn about monad transformers, which can be composed with other monads.

## Monad Laws

Without further ado, here are the laws for `Monad`:

- `ma >>= pure = ma` and `pure v >>= f = f v`. These are monad's identity laws. Here they are as concrete examples:

  ```idris
  id1L : Maybe a -> Maybe a
  id1L ma = ma >>= pure

  id2L : a -> (a -> Maybe b) -> Maybe b
  id2L v f = pure v >>= f

  id2R : a -> (a -> Maybe b) -> Maybe b
  id2R v f = f v
  ```

  These two laws state that `pure` should behave neutrally w.r.t. *bind*.

- `(m >>= f) >>= g = m >>= (f >=> g)`. This is the law of associativity for monad. You might not have seen the second operator `(>=>)`. It can be used to sequence effectful computations and has the following type:

  ```repl
  Tutorial.Functor> :t (>=>)
  Prelude.>=> : Monad m => (a -> m b) -> (b -> m c) -> a -> m c
  ```

The above are the *official* monad laws. However, we need to consider a third one, given that in Idris (and Haskell) `Monad` extends `Applicative`: As `(<*>)` can be implemented in terms of `(>>=)`, the actual implementation of `(<*>)` must behave the same as the implementation in terms of `(>>=)`:

- `mf <*> ma = mf >>= (\fun => map (fun $) ma)`.

<!-- vi: filetype=idris2:syntax=markdown
-->
