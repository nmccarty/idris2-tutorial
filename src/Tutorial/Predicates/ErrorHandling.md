# Use Case: Flexible Error Handling

```idris
module Tutorial.Predicates.ErrorHandling

import Tutorial.Predicates.Contracts

import Data.Either
import Data.List1
import Data.String
import Data.Vect
import Data.HList
import Decidable.Equality

import Text.CSV
import System.File

%default total
```

A recurring pattern when writing larger applications is the combination of different parts of a program each with their own failure types in a larger effectful computation. We saw this, for instance, when implementing a command-line tool for handling CSV files. There, we read and wrote data from and to files, we parsed column types and schemata, we parsed row and column indices and command-line commands. All these operations came with the potential of failure and might be implemented in different parts of our application. In order to unify these different failure types, we wrote a custom sum type encapsulating each of them, and wrote a single handler for this sum type. This approach was alright then, but it does not scale well and is lacking in terms of flexibility. We are therefore trying a different approach here. Before we continue, we quickly implement a couple of functions with the potential of failure plus some custom error types:

```idris
public export
record NoNat where
  constructor MkNoNat
  str : String

readNat' : String -> Either NoNat Nat
readNat' s = maybeToEither (MkNoNat s) $ parsePositive s

public export
record NoColType where
  constructor MkNoColType
  str : String

readColType' : String -> Either NoColType ColType
readColType' "I64"     = Right I64
readColType' "Str"     = Right Str
readColType' "Boolean" = Right Boolean
readColType' "Float"   = Right Float
readColType' s         = Left $ MkNoColType s
```

However, if we wanted to parse a `Fin n`, there'd be already two ways how this could fail: The string in question could not represent a natural number (leading to a `NoNat` error), or it could be out of bounds (leading to an `OutOfBounds` error). We have to somehow encode these two possibilities in the return type, for instance, by using an `Either` as the error type:

```idris
public export
record OutOfBounds where
  constructor MkOutOfBounds
  size  : Nat
  index : Nat

readFin' : {n : _} -> String -> Either (Either NoNat OutOfBounds) (Fin n)
readFin' s = do
  ix <- mapFst Left (readNat' s)
  maybeToEither (Right $ MkOutOfBounds n ix) $ natToFin ix n
```

This is incredibly ugly. A custom sum type might have been slightly better, but we still would have to use `mapFst` when invoking `readNat'`, and writing custom sum types for every possible combination of errors will get cumbersome very quickly as well. What we are looking for, is a generalized sum type: A type indexed by a list of types (the possible choices) holding a single value of exactly one of the types in question. Here is a first naive try:

```idris
data Sum : List Type -> Type where
  MkSum : (val : t) -> Sum ts
```

However, there is a crucial piece of information missing: We have not verified that `t` is an element of `ts`, nor *which* type it actually is. In fact, this is another case of an erased existential, and we will have no way to at runtime learn something about `t`. What we need to do is to pair the value with a proof, that its type `t` is an element of `ts`. We could use `Elem` again for this, but for some use cases we will require access to the number of types in the list. We will therefore use a vector instead of a list as our index. Here is a predicate similar to `Elem` but for vectors:

```idris
public export
data Has :  (v : a) -> (vs  : Vect n a) -> Type where
  Z : Has v (v :: vs)
  S : Has v vs -> Has v (w :: vs)

export
Uninhabited (Has v []) where
  uninhabited Z impossible
  uninhabited (S _) impossible
```

A value of type `Has v vs` is a witness that `v` is an element of `vs`. With this, we can now implement an indexed sum type (also called an *open union*):

```idris
public export
data Union : Vect n Type -> Type where
  U : (ix : Has t ts) -> (val : t) -> Union ts

export
Uninhabited (Union []) where
  uninhabited (U ix _) = absurd ix
```

Note the difference between `HList` and `Union`. `HList` is a *generalized product type*: It holds a value for each type in its index. `Union` is a *generalized sum type*: It holds only a single value, which must be of a type listed in the index. With this we can now define a much more flexible error type:

```idris
public export
0 Err : Vect n Type -> Type -> Type
Err ts t = Either (Union ts) t
```

A function returning an `Err ts a` describes a computation, which can fail with one of the errors listed in `ts`. We first need some utility functions.

```idris
inject : (prf : Has t ts) => (v : t) -> Union ts
inject v = U prf v

export
fail : Has t ts => (err : t) -> Err ts a
fail err = Left $ inject err

failMaybe : Has t ts => (err : Lazy t) -> Maybe a -> Err ts a
failMaybe err = maybeToEither (inject err)
```

Next, we can write more flexible versions of the parsers we wrote above:

```idris
readNat : Has NoNat ts => String -> Err ts Nat
readNat s = failMaybe (MkNoNat s) $ parsePositive s

readColType : Has NoColType ts => String -> Err ts ColType
readColType "I64"     = Right I64
readColType "Str"     = Right Str
readColType "Boolean" = Right Boolean
readColType "Float"   = Right Float
readColType s         = fail $ MkNoColType s
```

Before we implement `readFin`, we introduce a short cut for specifying that several error types must be present:

```idris
public export
0 Errs : List Type -> Vect n Type -> Type
Errs []        _  = ()
Errs (x :: xs) ts = (Has x ts, Errs xs ts)
```

Function `Errs` returns a tuple of constraints. This can be used as a witness that all listed types are present in the vector of types: Idris will automatically extract the proofs from the tuple as needed.

```idris
export
readFin : {n : _} -> Errs [NoNat, OutOfBounds] ts => String -> Err ts (Fin n)
readFin s = do
  S ix <- readNat s | Z => fail (MkOutOfBounds n Z)
  failMaybe (MkOutOfBounds n (S ix)) $ natToFin ix n
```

As a last example, here are parsers for schemata and CSV rows:

```idris
fromCSV : String -> List String
fromCSV = forget . split (',' ==)

public export
record InvalidColumn where
  constructor MkInvalidColumn
  str : String

readColumn : Errs [InvalidColumn, NoColType] ts => String -> Err ts Column
readColumn s = case forget $ split (':' ==) s of
  [n,ct] => MkColumn n <$> readColType ct
  _      => fail $ MkInvalidColumn s

export
readSchema : Errs [InvalidColumn, NoColType] ts => String -> Err ts Schema
readSchema = traverse readColumn . fromCSV

public export
data RowError : Type where
  InvalidField  : (row, col : Nat) -> (ct : ColType) -> String -> RowError
  UnexpectedEOI : (row, col : Nat) -> RowError
  ExpectedEOI   : (row, col : Nat) -> RowError

decodeField :  Has RowError ts
            => (row,col : Nat)
            -> (c : ColType)
            -> String
            -> Err ts (IdrisType c)
decodeField row col c s =
  let err = InvalidField row col c s
   in case c of
        I64     => failMaybe err $ read s
        Str     => failMaybe err $ read s
        Boolean => failMaybe err $ read s
        Float   => failMaybe err $ read s

export
decodeRow :  Has RowError ts
          => {s : _}
          -> (row : Nat)
          -> (str : String)
          -> Err ts (Row s)
decodeRow row = go 1 s . fromCSV
  where go : Nat -> (cs : Schema) -> List String -> Err ts (Row cs)
        go k []       []                    = Right []
        go k []       (_ :: _)              = fail $ ExpectedEOI row k
        go k (_ :: _) []                    = fail $ UnexpectedEOI row k
        go k (MkColumn n c :: cs) (s :: ss) =
          [| decodeField row k c s :: go (S k) cs ss |]
```

Here is an example REPL session, where I test `readSchema`. I defined variable `ts` using the `:let` command to make this more convenient. Note, how the order of error types is of no importance, as long as types `InvalidColumn` and `NoColType` are present in the list of errors:

```repl
Tutorial.Predicates> :let ts = the (Vect 3 _) [NoColType,NoNat,InvalidColumn]
Tutorial.Predicates> readSchema {ts} "foo:bar"
Left (U Z (MkNoColType "bar"))
Tutorial.Predicates> readSchema {ts} "foo:Float"
Right [MkColumn "foo" Float]
Tutorial.Predicates> readSchema {ts} "foo Float"
Left (U (S (S Z)) (MkInvalidColumn "foo Float"))
```

## Error Handling

There are several techniques for handling errors, all of which are useful at times. For instance, we might want to handle some errors early on and individually, while dealing with others much later in our application. Or we might want to handle them all in one fell swoop. We look at both approaches here.

First, in order to handle a single error individually, we need to *split* a union into one of two possibilities: A value of the error type in question or a new union, holding one of the other error types. We need a new predicate for this, which not only encodes the presence of a value in a vector but also the result of removing that value:

```idris
data Rem : (v : a) -> (vs : Vect (S n) a) -> (rem : Vect n a) -> Type where
  [search v vs]
  RZ : Rem v (v :: rem) rem
  RS : Rem v vs rem -> Rem v (w :: vs) (w :: rem)
```

Once again, we want to use one of the indices (`rem`) in our functions' return types, so we only use the other indices during proof search. Here is a function for splitting off a value from an open union:

```idris
split : (prf : Rem t ts rem) => Union ts -> Either t (Union rem)
split {prf = RZ}   (U Z     val) = Left val
split {prf = RZ}   (U (S x) val) = Right (U x val)
split {prf = RS p} (U Z     val) = Right (U Z val)
split {prf = RS p} (U (S x) val) = case split {prf = p} (U x val) of
  Left vt        => Left vt
  Right (U ix y) => Right $ U (S ix) y
```

This tries to extract a value of type `t` from a union. If it works, the result is wrapped in a `Left`, otherwise a new union is returned in a `Right`, but this one has `t` removed from its list of possible types.

With this, we can implement a handler for single errors. Error handling often happens in an effectful context (we might want to print a message to the console or write the error to a log file), so we use an applicative effect type to handle errors in.

```idris
handle :  Applicative f
       => Rem t ts rem
       => (h : t -> f a)
       -> Err ts a
       -> f (Err rem a)
handle h (Left x)  = case split x of
  Left v    => Right <$> h v
  Right err => pure $ Left err
handle _ (Right x) = pure $ Right x
```

For handling all errors at once, we can use a handler type indexed by the vector of errors, and parameterized by the output type:

```idris
namespace Handler
  public export
  data Handler : (ts : Vect n Type) -> (a : Type) -> Type where
    Nil  : Handler [] a
    (::) : (t -> a) -> Handler ts a -> Handler (t :: ts) a

extract : Handler ts a -> Has t ts -> t -> a
extract (f :: _)  Z     val = f val
extract (_ :: fs) (S y) val = extract fs y val
extract []        ix    _   = absurd ix

handleAll : Applicative f => Handler ts (f a) -> Err ts a -> f a
handleAll _ (Right v)       = pure v
handleAll h (Left $ U ix v) = extract h ix v
```

Below, we will see an additional way of handling all errors at once by defining a custom interface for error handling.

<!-- vi: filetype=idris2:syntax=markdown
-->
