# Use Case: CSV Files with a Schema

```idris
module Tutorial.DPair.CSV

import Control.Monad.State

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

In this section, we are going to look at an extended example based on our previous work on CSV parsers. We'd like to write a small command-line program, where users can specify a schema for the CSV tables they'd like to parse and load into memory. Before we begin, here is a REPL session running the final program, which you will complete in the exercises:

```repl
Solutions.DPair> :exec main
Enter a command: load resources/example
Table loaded. Schema: str,str,fin2023,str?,boolean?
Enter a command: get 3
Row 3:

str   | str    | fin2023 | str? | boolean?
------------------------------------------
Floor | Jansen | 1981    |      | t

Enter a command: add Mikael,Stanne,1974,,
Row prepended:

str    | str    | fin2023 | str? | boolean?
-------------------------------------------
Mikael | Stanne | 1974    |      |

Enter a command: get 1
Row 1:

str    | str    | fin2023 | str? | boolean?
-------------------------------------------
Mikael | Stanne | 1974    |      |

Enter a command: delete 1
Deleted row: 1.
Enter a command: get 1
Row 1:

str | str     | fin2023 | str? | boolean?
-----------------------------------------
Rob | Halford | 1951    |      |

Enter a command: quit
Goodbye.
```

This example was inspired by a similar program used as an example in the [Type-Driven Development with Idris](https://www.manning.com/books/type-driven-development-with-idris) book.

We'd like to focus on several things here:

- Purity: With the exception of the main program loop, all functions used in the implementation should be pure, which in this context means "not running in any monad with side effects such as `IO`".
- Fail early: With the exception of the command parser, all functions updating the table and handling queries should be typed and implemented in such a way that they cannot fail.

We are often well advised to adhere to these two guidelines, as they can make the majority of our functions easier to implement and test.

Since we allow users of our library to specify a schema (order and types of columns) for the table they work with, this information is not known until runtime. The same goes for the current size of the table. We will therefore store both values as fields in a dependent record.

## Encoding the Schema

We need to inspect the table schema at runtime. Although theoretically possible, it is not advisable to operate on Idris types directly here. We'd rather use a closed custom data type describing the types of columns we understand. In a first try, we only support some Idris primitives:

```idris
data ColType = I64 | Str | Boolean | Float

Schema : Type
Schema = List ColType
```

Next, we need a way to convert a `Schema` to a list of Idris types, which we will then use as the index of a heterogeneous list representing the rows in our table:

```idris
IdrisType : ColType -> Type
IdrisType I64     = Int64
IdrisType Str     = String
IdrisType Boolean = Bool
IdrisType Float   = Double

Row : Schema -> Type
Row = HList . map IdrisType
```

We can now describe a table as a dependent record storing the table's content as a vector of rows. In order to safely index rows of the table and parse new rows to be added, the current schema and size of the table must be known at runtime:

```idris
record Table where
  constructor MkTable
  schema : Schema
  size   : Nat
  rows   : Vect size (Row schema)
```

Finally, we define an indexed data type describing commands operating on the current table. Using the current table as the command's index allows us to make sure that indices for accessing and deleting rows are within bounds and that new rows agree with the current schema. This is necessary to uphold our second design principle: All functions operating on tables must do so without the possibility of failure.

```idris
data Command : (t : Table) -> Type where
  PrintSchema : Command t
  PrintSize   : Command t
  New         : (newSchema : Schema) -> Command t
  Prepend     : Row (schema t) -> Command t
  Get         : Fin (size t) -> Command t
  Delete      : Fin (size t) -> Command t
  Quit        : Command t
```

We can now implement the main application logic: How user entered commands affect the application's current state. As promised, this comes without the risk of failure, so we don't have to wrap the return type in an `Either`:

```idris
applyCommand : (t : Table) -> Command t -> Table
applyCommand t                 PrintSchema = t
applyCommand t                 PrintSize   = t
applyCommand _                 (New ts)    = MkTable ts _ []
applyCommand (MkTable ts n rs) (Prepend r) = MkTable ts _ $ r :: rs
applyCommand t                 (Get x)     = t
applyCommand t                 Quit        = t
applyCommand (MkTable ts n rs) (Delete x)  = case n of
  S k => MkTable ts k (deleteAt x rs)
  Z   => absurd x
```

Please understand, that the constructors of `Command t` are typed in such a way that indices are always within bounds (constructors `Get` and `Delete`), and new rows adhere to the table's current schema (constructor `Prepend`).

One thing you might not have seen so far is the call to `absurd` on the last line. This is a derived function of the `Uninhabited` interface, which is used to describe types such as `Void` or - in the case above - `Fin 0`, of which there can be no value. Function `absurd` is then just another manifestation of the principle of explosion. If this doesn't make too much sense yet, don't worry. We will look at `Void` and its uses in the next chapter.

## Parsing Commands

User input validation is an important topic when writing applications. If it happens early, you can keep larger parts of your application pure (which - in this context - means: "without the possibility of failure") and provably total. If done properly, this step encodes and handles most if not all ways in which things can go wrong in your program, allowing you to come up with clear error messages telling users exactly what caused an issue. As you surely have experienced yourself, there are few things more frustrating than a non-trivial computer program terminating with an unhelpful "There was an error" message.

So, in order to treat this important topic with all due respect, we are first going to implement a custom error type. This is not *strictly* necessary for small programs, but once your software gets more complex, it can be tremendously helpful for keeping track of what can go wrong where. In order to figure out what can possibly go wrong, we first need to decide on how the commands should be entered. Here, we use a single keyword for each command, together with an optional number of arguments separated from the keyword by a single space character. For instance: `"new i64,boolean,str,str"`, for initializing an empty table with a new schema. With this settled, here is a list of things that can go wrong, and the messages we'd like to print:

- A bogus command is entered. We repeat the input with a message that we don't know the command plus a list of commands we know about.
- An invalid schema was entered. In this case, we list the position of the first unknown type, the string we found there, and a list of types we know about.
- An invalid CSV encoding of a row was entered. We list the erroneous position, the string encountered there, plus the expected type. In case of a too small or too large number of fields, we also print a corresponding error message.
- An index was out of bounds. This can happen, when users try to access or delete specific rows. We print the current number of rows plus the value entered.
- A value not representing a natural number was entered as an index. We print an according error message.

That's a lot of stuff to keep track of, so let's encode this in a sum type:

```idris
data Error : Type where
  UnknownCommand : String -> Error
  UnknownType    : (pos : Nat) -> String -> Error
  InvalidField   : (pos : Nat) -> ColType -> String -> Error
  ExpectedEOI    : (pos : Nat) -> String -> Error
  UnexpectedEOI  : (pos : Nat) -> String -> Error
  OutOfBounds    : (size : Nat) -> (index : Nat) -> Error
  NoNat          : String -> Error
```

In order to conveniently construct our error messages, it is best to use Idris' string interpolation facilities: We can enclose arbitrary string expressions in a string literal by enclosing them in curly braces, the first of which must be escaped with a backslash. Like so: `"foo \{myExpr a b c}"`. We can pair this with multiline string literals to get nicely formatted error messages.

```idris
showColType : ColType -> String
showColType I64      = "i64"
showColType Str      = "str"
showColType Boolean  = "boolean"
showColType Float    = "float"

showSchema : Schema -> String
showSchema = concat . intersperse "," . map showColType

allTypes : String
allTypes = concat
         . List.intersperse ", "
         . map showColType
         $ [I64,Str,Boolean,Float]

showError : Error -> String
showError (UnknownCommand x) = """
  Unknown command: \{x}.
  Known commands are: clear, schema, size, new, add, get, delete, quit.
  """

showError (UnknownType pos x) = """
  Unknown type at position \{show pos}: \{x}.
  Known types are: \{allTypes}.
  """

showError (InvalidField pos tpe x) = """
  Invalid value at position \{show pos}.
  Expected type: \{showColType tpe}.
  Value found: \{x}.
  """

showError (ExpectedEOI k x) = """
  Expected end of input.
  Position: \{show k}
  Input: \{x}
  """

showError (UnexpectedEOI k x) = """
  Unxpected end of input.
  Position: \{show k}
  Input: \{x}
  """

showError (OutOfBounds size index) = """
  Index out of bounds.
  Size of table: \{show size}
  Index: \{show index}
  Note: Indices start at 1.
  """

showError (NoNat x) = "Not a natural number: \{x}"
```

We can now write parsers for the different commands. We need facilities to parse vector indices, schemata, and CSV rows. Since we are using a CSV format for encoding and decoding rows, it makes sense to also encode the schema as a comma-separated list of values:

```idris
zipWithIndex : Traversable t => t a -> t (Nat, a)
zipWithIndex = evalState 1 . traverse pairWithIndex
  where pairWithIndex : a -> State Nat (Nat,a)
        pairWithIndex v = (,v) <$> get <* modify S

fromCSV : String -> List String
fromCSV = forget . split (',' ==)

readColType : Nat -> String -> Either Error ColType
readColType _ "i64"      = Right I64
readColType _ "str"      = Right Str
readColType _ "boolean"  = Right Boolean
readColType _ "float"    = Right Float
readColType n s          = Left $ UnknownType n s

readSchema : String -> Either Error Schema
readSchema = traverse (uncurry readColType) . zipWithIndex . fromCSV
```

We also need to decode CSV content based on the current schema. Note, how we can do so in a type safe manner by pattern matching on the schema, which will not be known until runtime. Unfortunately, we need to reimplement CSV-parsing, because we want to add the expected type to the error messages (a thing that would be much harder to do with interface `CSVLine` and error type `CSVError`).

```idris
decodeField : Nat -> (c : ColType) -> String -> Either Error (IdrisType c)
decodeField k c s =
  let err = InvalidField k c s
   in case c of
        I64     => maybeToEither err $ read s
        Str     => maybeToEither err $ read s
        Boolean => maybeToEither err $ read s
        Float   => maybeToEither err $ read s

decodeRow : {ts : _} -> String -> Either Error (Row ts)
decodeRow s = go 1 ts $ fromCSV s
  where go : Nat -> (cs : Schema) -> List String -> Either Error (Row cs)
        go k []       []         = Right []
        go k []       (_ :: _)   = Left $ ExpectedEOI k s
        go k (_ :: _) []         = Left $ UnexpectedEOI k s
        go k (c :: cs) (s :: ss) = [| decodeField k c s :: go (S k) cs ss |]
```

There is no hard and fast rule about whether to pass an index as an implicit argument or not. Some considerations:

- Pattern matching on explicit arguments comes with less syntactic overhead.
- If an argument can be inferred from the context most of the time, consider passing it as an implicit to make your function nicer to use in client code.
- Use explicit (possibly erased) arguments for values that can't be inferred by Idris most of the time.

All that is missing now is a way to parse indices for accessing the current table's rows. We use the conversion for indices to start at one instead of zero, which feels more natural for most non-programmers.

```idris
readFin : {n : _} -> String -> Either Error (Fin n)
readFin s = do
  S k <- maybeToEither (NoNat s) $ parsePositive {a = Nat} s
    | Z => Left $ OutOfBounds n Z
  maybeToEither (OutOfBounds n $ S k) $ natToFin k n
```

We are finally able to implement a parser for user commands. Function `Data.String.words` is used for splitting a string at space characters. In most cases, we expect the name of the command plus a single argument without additional spaces. CSV rows can have additional space characters, however, so we use `Data.String.unwords` on the split string.

```idris
readCommand :  (t : Table) -> String -> Either Error (Command t)
readCommand _                "schema"  = Right PrintSchema
readCommand _                "size"    = Right PrintSize
readCommand _                "quit"    = Right Quit
readCommand (MkTable ts n _) s         = case words s of
  ["new",    str] => New     <$> readSchema str
  "add" ::   ss   => Prepend <$> decodeRow (unwords ss)
  ["get",    str] => Get     <$> readFin str
  ["delete", str] => Delete  <$> readFin str
  _               => Left $ UnknownCommand s
```

## Running the Application

All that's left to do is to write functions for printing the results of commands to users and run the application in a loop until command `"quit"` is entered.

```idris
encodeField : (t : ColType) -> IdrisType t -> String
encodeField I64     x     = show x
encodeField Str     x     = show x
encodeField Boolean True  = "t"
encodeField Boolean False = "f"
encodeField Float   x     = show x

encodeRow : (ts : List ColType) -> Row ts -> String
encodeRow ts = concat . intersperse "," . go ts
  where go : (cs : List ColType) -> Row cs -> Vect (length cs) String
        go []        []        = []
        go (c :: cs) (v :: vs) = encodeField c v :: go cs vs

result :  (t : Table) -> Command t -> String
result t PrintSchema = "Current schema: \{showSchema t.schema}"
result t PrintSize   = "Current size: \{show t.size}"
result _ (New ts)    = "Created table. Schema: \{showSchema ts}"
result t (Prepend r) = "Row prepended: \{encodeRow t.schema r}"
result _ (Delete x)  = "Deleted row: \{show $ FS x}."
result _ Quit        = "Goodbye."
result t (Get x)     =
  "Row \{show $ FS x}: \{encodeRow t.schema (index x t.rows)}"

covering
runProg : Table -> IO ()
runProg t = do
  putStr "Enter a command: "
  str <- getLine
  case readCommand t str of
    Left err   => putStrLn (showError err) >> runProg t
    Right Quit => putStrLn (result t Quit)
    Right cmd  => putStrLn (result t cmd) >>
                  runProg (applyCommand t cmd)

covering
main : IO ()
main = runProg $ MkTable [] _ []
```

<!-- vi: filetype=idris2:syntax=markdown
-->
