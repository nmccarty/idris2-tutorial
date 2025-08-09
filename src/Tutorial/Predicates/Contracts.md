# Contracts between Values

```idris
module Tutorial.Predicates.Contracts

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

The predicates we saw so far restricted the values of a single type, but it is also possible to define predicates describing contracts between several values of possibly distinct types.

## The `Elem` Predicate

Assume we'd like to extract a value of a given type from a heterogeneous list:

```idris
get' : (0 t : Type) -> HList ts -> t
```

This can't work in general: If we could implement this we would immediately have a proof of void:

```idris
voidAgain : Void
voidAgain = get' Void []
```

The problem is obvious: The type of which we'd like to extract a value must be an element of the index of the heterogeneous list. Here is a predicate, with which we can express this:

```idris
public export
data Elem : (elem : a) -> (as : List a) -> Type where
  Here  : Elem x (x :: xs)
  There : Elem x xs -> Elem x (y :: xs)
```

This is a predicate describing a contract between two values: A value of type `a` and a list of `a`s. Values of this predicate are witnesses that the value is an element of the list. Note, how this is defined recursively: The case where the value we look for is at the head of the list is handled by the `Here` constructor, where the same variable (`x`) is used for the element and the head of the list. The case where the value is deeper within the list is handled by the `There` constructor. This can be read as follows: If `x` is an element of `xs`, then `x` is also an element of `y :: xs` for any value `y`. Let's write down some examples to get a feel for these:

```idris
MyList : List Nat
MyList = [1,3,7,8,4,12]

oneElemMyList : Elem 1 MyList
oneElemMyList = Here

sevenElemMyList : Elem 7 MyList
sevenElemMyList = There $ There Here
```

Now, `Elem` is just another way of indexing into a list of values. Instead of using a `Fin` index, which is limited by the list's length, we use a proof that a value can be found at a certain position.

We can use the `Elem` predicate to extract a value from the desired type of a heterogeneous list:

```idris
get : (0 t : Type) -> HList ts -> (prf : Elem t ts) => t
```

It is important to note that the auto implicit must not be erased in this case. This is no longer a single value data type, and we must be able to pattern match on this value in order to figure out, how far within the heterogeneous list our value is stored:

```idris
get t (v :: vs) {prf = Here}    = v
get t (v :: vs) {prf = There p} = get t vs
get _ [] impossible
```

It can be instructive to implement `get` yourself, using holes on the right hand side to see the context and types of values Idris infers based on the value of the `Elem` predicate.

Let's give this a spin at the REPL:

```repl
Tutorial.Predicates> get Nat ["foo", Just "bar", S Z]
1
Tutorial.Predicates> get Nat ["foo", Just "bar"]
Error: Can't find an implementation for Elem Nat [String, Maybe String].

(Interactive):1:1--1:28
 1 | get Nat ["foo", Just "bar"]
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

With this example we start to appreciate what *proof search* actually means: Given a value `v` and a list of values `vs`, Idris tries to find a proof that `v` is an element of `vs`. Now, before we continue, please note that proof search is not a silver bullet. The search algorithm has a reasonably limited *search depth*, and will fail with the search if this limit is exceeded. For instance:

```idris
Tps : List Type
Tps = List.replicate 50 Nat ++ [Maybe String]

hlist : HList Tps
hlist = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        , Nothing ]
```

And at the REPL:

```repl
Tutorial.Predicates> get (Maybe String) hlist
Error: Can't find an implementation for Elem (Maybe String) [Nat,...
```

As you can see, Idris fails to find a proof that `Maybe String` is an element of `Tps`. The search depth can be increased with the `%auto_implicit_depth` directive, which will hold for the rest of the source file or until set to a different value. The default value is set at 25. In general, it is not advisable to set this to a too large value as this can drastically increase compile times.

```idris
%auto_implicit_depth 100
aMaybe : Maybe String
aMaybe = get _ hlist

%auto_implicit_depth 25
```

## Use Case: A nicer Schema

In the chapter about sigma types, we introduced a schema for CSV files. This was not very nice to use, because we had to use natural numbers to access a certain column. Even worse, users of our small library had to do the same. There was no way to define a name for each column and access columns by name. We are going to change this. Here is an encoding for this use case:

```idris
public export
data ColType = I64 | Str | Boolean | Float

public export
IdrisType : ColType -> Type
IdrisType I64     = Int64
IdrisType Str     = String
IdrisType Boolean = Bool
IdrisType Float   = Double

public export
record Column where
  constructor MkColumn
  name : String
  type : ColType

infixr 8 :>

public export
(:>) : String -> ColType -> Column
(:>) = MkColumn

public export
Schema : Type
Schema = List Column

export
Show ColType where
  show I64     = "I64"
  show Str     = "Str"
  show Boolean = "Boolean"
  show Float   = "Float"

Show Column where
  show (MkColumn n ct) = "\{n}:\{show ct}"

export
showSchema : Schema -> String
showSchema = concat . intersperse "," . map show
```

As you can see, in a schema we now pair a column's type with its name. Here is an example schema for a CSV file holding information about employees in a company:

```idris
EmployeeSchema : Schema
EmployeeSchema = [ "firstName"  :> Str
                 , "lastName"   :> Str
                 , "email"      :> Str
                 , "age"        :> I64
                 , "salary"     :> Float
                 , "management" :> Boolean
                 ]
```

Such a schema could of course again be read from user input, but we will wait with implementing a parser until later in this chapter. Using this new schema with an `HList` directly led to issues with type inference, therefore I quickly wrote a custom row type: A heterogeneous list indexed over a schema.

```idris
public export
data Row : Schema -> Type where
  Nil  : Row []

  (::) :  {0 name : String}
       -> {0 type : ColType}
       -> (v : IdrisType type)
       -> Row ss
       -> Row (name :> type :: ss)
```

In the signature of *cons*, I list the erased implicit arguments explicitly. This is good practice, as otherwise Idris will often issue shadowing warnings when using such data constructors in client code.

We can now define a type alias for CSV rows representing employees:

```idris
0 Employee : Type
Employee = Row EmployeeSchema

hock : Employee
hock = [ "Stefan", "Höck", "hock@foo.com", 46, 5443.2, False ]
```

Note, how I gave `Employee` a zero quantity. This means, we are only ever allowed to use this function at compile time but never at runtime. This is a safe way to make sure our type-level functions and aliases do not leak into the executable when we build our application. We are allowed to use zero-quantity functions and values in type signatures and when computing other erased values, but not for runtime-relevant computations.

We would now like to access a value in a row based on the name given. For this, we write a custom predicate, which serves as a witness that a column with the given name is part of the schema. Now, here is an important thing to note: In this predicate we include an index for the *type* of the column with the given name. We need this, because when we access a column by name, we need a way to figure out the return type. But during proof search, this type will have to be derived by Idris based on the column name and schema in question (otherwise, the proof search will fail unless the return type is known in advance). We therefore *must* tell Idris, that it can't include this type in the list of search criteria, otherwise it will try and infer the column type from the context (using type inference) before running the proof search. This can be done by listing the indices to be used in the search like so: `[search name schema]`.

```idris
public export
data InSchema :  (name    : String)
              -> (schema  : Schema)
              -> (colType : ColType)
              -> Type where
  [search name schema]
  IsHere  : InSchema n (n :> t :: ss) t
  IsThere : InSchema n ss t -> InSchema n (fld :: ss) t

export
Uninhabited (InSchema n [] c) where
  uninhabited IsHere impossible
  uninhabited (IsThere _) impossible
```

With this, we are now ready to access the value at a given column based on the column's name:

```idris
export
getAt :  {0 ss : Schema}
      -> (name : String)
      -> (row  : Row ss)
      -> (prf  : InSchema name ss c)
      => IdrisType c
getAt name (v :: vs) {prf = IsHere}    = v
getAt name (_ :: vs) {prf = IsThere p} = getAt name vs
```

Below is an example how to use this at compile time. Note the amount of work Idris performs for us: It first comes up with proofs that `firstName`, `lastName`, and `age` are indeed valid names in the `Employee` schema. From these proofs it automatically figures out the return types of the calls to `getAt` and extracts the corresponding values from the row. All of this happens in a provably total and type safe way.

```idris
shoeck : String
shoeck =  getAt "firstName" hock
       ++ " "
       ++ getAt "lastName" hock
       ++ ": "
       ++ show (getAt "age" hock)
       ++ " years old."
```

In order to at runtime specify a column name, we need a way for computing values of type `InSchema` by comparing the column names with the schema in question. Since we have to compare two string values for being propositionally equal, we use the `DecEq` implementation for `String` here (Idris provides `DecEq` implementations for all primitives). We extract the column type at the same time and pair this (as a dependent pair) with the `InSchema` proof:

```idris
export
inSchema : (ss : Schema) -> (n : String) -> Maybe (c ** InSchema n ss c)
inSchema []                    _ = Nothing
inSchema (MkColumn cn t :: xs) n = case decEq cn n of
  Yes Refl   => Just (t ** IsHere)
  No  contra => case inSchema xs n of
    Just (t ** prf) => Just $ (t ** IsThere prf)
    Nothing         => Nothing
```

At the end of this chapter we will use `InSchema` in our CSV command-line application to list all values in a column.

<!-- vi: filetype=idris2:syntax=markdown
-->
