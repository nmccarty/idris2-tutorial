# The Truth about Interfaces

```idris
module Tutorial.Predicates.Truth

import Tutorial.Predicates.Contracts
import Tutorial.Predicates.ErrorHandling

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

Well, here it finally is: The truth about interfaces. Internally, an interface is just a record data type, with its fields corresponding to the members of the interface. An interface implementation is a *value* of such a record, annotated with a `%hint` pragma (see below) to make the value available during proof search. Finally, a constrained function is just a function with one or more auto implicit arguments. For instance, here is the same function for looking up an element in a list, once with the known syntax for constrained functions, and once with an auto implicit argument. The code produced by Idris is the same in both cases:

```idris
isElem1 : Eq a => a -> List a -> Bool
isElem1 v []        = False
isElem1 v (x :: xs) = x == v || isElem1 v xs

isElem2 : {auto _ : Eq a} -> a -> List a -> Bool
isElem2 v []        = False
isElem2 v (x :: xs) = x == v || isElem2 v xs
```

Being mere records, we can also take interfaces as regular function arguments and dissect them with a pattern match:

```idris
eq : Eq a -> a -> a -> Bool
eq (MkEq feq fneq) = feq
```

## A manual Interface Definition

I'll now demonstrate how we can achieve the same behavior with proof search as with a regular interface definition plus implementations. Since I want to finish the CSV example with our new error handling tools, we are going to implement some error handlers. First, an interface is just a record:

```idris
record Print a where
  constructor MkPrint
  print' : a -> String
```

In order to access the record in a constrained function, we use the `%search` keyword, which will try to conjure a value of the desired type (`Print a` in this case) by means of a proof search:

```idris
print : Print a => a -> String
print = print' %search
```

As an alternative, we could use a named constraint, and access it directly via its name:

```idris
print2 : (impl : Print a) => a -> String
print2 = print' impl
```

As yet another alternative, we could use the syntax for auto implicit arguments:

```idris
print3 : {auto impl : Print a} -> a -> String
print3 = print' impl
```

All three versions of `print` behave exactly the same at runtime. So, whenever we write `{auto x : Foo} ->` we can just as well write `(x : Foo) =>` and vice versa.

Interface implementations are just values of the given record type, but in order to be available during proof search, these need to be annotated with a `%hint` pragma:

```idris
%hint
noNatPrint : Print NoNat
noNatPrint = MkPrint $ \e => "Not a natural number: \{e.str}"

%hint
noColTypePrint : Print NoColType
noColTypePrint = MkPrint $ \e => "Not a column type: \{e.str}"

%hint
outOfBoundsPrint : Print OutOfBounds
outOfBoundsPrint = MkPrint $ \e => "Index is out of bounds: \{show e.index}"

%hint
rowErrorPrint : Print RowError
rowErrorPrint = MkPrint $
  \case InvalidField r c ct s =>
          "Not a \{show ct} in row \{show r}, column \{show c}. \{s}"
        UnexpectedEOI r c =>
          "Unexpected end of input in row \{show r}, column \{show c}."
        ExpectedEOI r c =>
          "Expected end of input in row \{show r}, column \{show c}."
```

We can also write an implementation of `Print` for a union or errors. For this, we first come up with a proof that all types in the union's index come with an implementation of `Print`:

```idris
0 All : (f : a -> Type) -> Vect n a -> Type
All f []        = ()
All f (x :: xs) = (f x, All f xs)

unionPrintImpl : All Print ts => Union ts -> String
unionPrintImpl (U Z val)     = print val
unionPrintImpl (U (S x) val) = unionPrintImpl $ U x val

%hint
unionPrint : All Print ts => Print (Union ts)
unionPrint = MkPrint unionPrintImpl
```

Defining interfaces this way can be an advantage, as there is much less magic going on, and we have more fine grained control over the types and values of our fields. Note also, that all of the magic comes from the search hints, with which our "interface implementations" were annotated. These made the corresponding values and functions available during proof search.

### Parsing CSV Commands

To conclude this chapter, we reimplement our CSV command parser, using the flexible error handling approach from the last section. While not necessarily less verbose than the original parser, this approach decouples the handling of errors and printing of error messages from the rest of the application: Functions with a possibility of failure are reusable in different contexts, as are the pretty printers we use for the error messages.

First, we repeat some stuff from earlier chapters. I sneaked in a new command for printing all values in a column:

```idris
record Table where
  constructor MkTable
  schema : Schema
  size   : Nat
  rows   : Vect size (Row schema)

data Command : (t : Table) -> Type where
  PrintSchema :  Command t
  PrintSize   :  Command t
  New         :  (newSchema : Schema) -> Command t
  Prepend     :  Row (schema t) -> Command t
  Get         :  Fin (size t) -> Command t
  Delete      :  Fin (size t) -> Command t
  Col         :  (name : String)
              -> (tpe  : ColType)
              -> (prf  : InSchema name t.schema tpe)
              -> Command t
  Quit        : Command t

applyCommand : (t : Table) -> Command t -> Table
applyCommand t                 PrintSchema = t
applyCommand t                 PrintSize   = t
applyCommand _                 (New ts)    = MkTable ts _ []
applyCommand (MkTable ts n rs) (Prepend r) = MkTable ts _ $ r :: rs
applyCommand t                 (Get x)     = t
applyCommand t                 Quit        = t
applyCommand t                 (Col _ _ _) = t
applyCommand (MkTable ts n rs) (Delete x)  = case n of
  S k => MkTable ts k (deleteAt x rs)
  Z   => absurd x
```

Next, below is the command parser reimplemented. In total, it can fail in seven different was, at least some of which might also be possible in other parts of a larger application.

```idris
record UnknownCommand where
  constructor MkUnknownCommand
  str : String

%hint
unknownCommandPrint : Print UnknownCommand
unknownCommandPrint = MkPrint $ \v => "Unknown command: \{v.str}"

record NoColName where
  constructor MkNoColName
  str : String

%hint
noColNamePrint : Print NoColName
noColNamePrint = MkPrint $ \v => "Unknown column: \{v.str}"

0 CmdErrs : Vect 7 Type
CmdErrs = [ InvalidColumn
          , NoColName
          , NoColType
          , NoNat
          , OutOfBounds
          , RowError
          , UnknownCommand ]

readCommand : (t : Table) -> String -> Err CmdErrs (Command t)
readCommand _                "schema"  = Right PrintSchema
readCommand _                "size"    = Right PrintSize
readCommand _                "quit"    = Right Quit
readCommand (MkTable ts n _) s         = case words s of
  ["new",    str] => New     <$> readSchema str
  "add" ::   ss   => Prepend <$> decodeRow 1 (unwords ss)
  ["get",    str] => Get     <$> readFin str
  ["delete", str] => Delete  <$> readFin str
  ["column", str] => case inSchema ts str of
    Just (ct ** prf) => Right $ Col str ct prf
    Nothing          => fail $ MkNoColName str
  _               => fail $ MkUnknownCommand s
```

Note, how we could invoke functions like `readFin` or `readSchema` directly, because the necessary error types are part of our list of possible errors.

To conclude this sections, here is the functionality for printing the result of a command plus the application's main loop. Most of this is repeated from earlier chapters, but note how we can handle all errors at once with a single call to `print`:

```idris
encodeField : (t : ColType) -> IdrisType t -> String
encodeField I64     x     = show x
encodeField Str     x     = show x
encodeField Boolean True  = "t"
encodeField Boolean False = "f"
encodeField Float   x     = show x

encodeRow : (s : Schema) -> Row s -> String
encodeRow s = concat . intersperse "," . go s
  where go : (s' : Schema) -> Row s' -> Vect (length s') String
        go []        []        = []
        go (MkColumn _ c :: cs) (v :: vs) = encodeField c v :: go cs vs

encodeCol :  (name : String)
          -> (c    : ColType)
          -> InSchema name s c
          => Vect n (Row s)
          -> String
encodeCol name c = unlines . toList . map (\r => encodeField c $ getAt name r)

result :  (t : Table) -> Command t -> String
result t PrintSchema   = "Current schema: \{showSchema t.schema}"
result t PrintSize     = "Current size: \{show t.size}"
result _ (New ts)      = "Created table. Schema: \{showSchema ts}"
result t (Prepend r)   = "Row prepended: \{encodeRow t.schema r}"
result _ (Delete x)    = "Deleted row: \{show $ FS x}."
result _ Quit          = "Goodbye."
result t (Col n c prf) = "Column \{n}:\n\{encodeCol n c t.rows}"
result t (Get x)       =
  "Row \{show $ FS x}: \{encodeRow t.schema (index x t.rows)}"

covering
runProg : Table -> IO ()
runProg t = do
  putStr "Enter a command: "
  str <- getLine
  case readCommand t str of
    Left err   => putStrLn (print err) >> runProg t
    Right Quit => putStrLn (result t Quit)
    Right cmd  => putStrLn (result t cmd) >>
                  runProg (applyCommand t cmd)

covering
main : IO ()
main = runProg $ MkTable [] _ []
```

Here is an example REPL session:

```repl
Tutorial.Predicates> :exec main
Enter a command: new name:Str,age:Int64,salary:Float
Not a column type: Int64
Enter a command: new name:Str,age:I64,salary:Float
Created table. Schema: name:Str,age:I64,salary:Float
Enter a command: add John Doe,44,3500
Row prepended: "John Doe",44,3500.0
Enter a command: add Jane Doe,50,4000
Row prepended: "Jane Doe",50,4000.0
Enter a command: get 1
Row 1: "Jane Doe",50,4000.0
Enter a command: column salary
Column salary:
4000.0
3500.0

Enter a command: quit
Goodbye.
```

<!-- vi: filetype=idris2:syntax=markdown
-->
