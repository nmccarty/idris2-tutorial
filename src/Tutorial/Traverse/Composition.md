# The Power of Composition

```idris
module Tutorial.Traverse.Composition

import Tutorial.Traverse.State

import Data.HList
import Data.IORef
import Data.List1
import Data.String
import Data.Validated
import Data.Vect
import Text.CSV

%default total
```

After our excursion into the realms of stateful computations, we will go back and combine mutable state with error accumulation to tag and read CSV lines in a single traversal. We already defined `pairWithIndex` for tagging lines with their indices. We also have `uncurry $ hdecode ts` for decoding single tagged lines. We can now combine the two effects in a single computation:

```idris
tagAndDecode :  (0 ts : List Type)
             -> CSVLine (HList ts)
             => String
             -> State Nat (Validated CSVError (HList ts))
tagAndDecode ts s = uncurry (hdecode ts) <$> pairWithIndex s
```

Now, as we learned before, applicative functors are closed under composition, and the result of `tagAndDecode` is a nesting of two applicatives: `State Nat` and `Validated CSVError`. The *Prelude* exports a corresponding named interface implementation (`Prelude.Applicative.Compose`), which we can use for traversing a list of strings with `tagAndDecode`. Remember, that we have to provide named implementations explicitly. Since `traverse` has the applicative functor as its second constraint, we also need to provide the first constraint (`Traversable`) explicitly. But this is going to be the unnamed default implementation! To get our hands on such a value, we can use the `%search` pragma:

```idris
readTable :  (0 ts : List Type)
          -> CSVLine (HList ts)
          => List String
          -> Validated CSVError (List $ HList ts)
readTable ts = evalState 1 . traverse @{%search} @{Compose} (tagAndDecode ts)
```

This tells Idris to use the default implementation for the `Traversable` constraint, and `Prelude.Applicatie.Compose` for the `Applicative` constraint. While this syntax is not very nice, it doesn't come up too often, and if it does, we can improve things by providing custom functions for better readability:

```idris
traverseComp : Traversable t
             => Applicative f
             => Applicative g
             => (a -> f (g b))
             -> t a
             -> f (g (t b))
traverseComp = traverse @{%search} @{Compose}

readTable' :  (0 ts : List Type)
           -> CSVLine (HList ts)
           => List String
           -> Validated CSVError (List $ HList ts)
readTable' ts = evalState 1 . traverseComp (tagAndDecode ts)
```

Note, how this allows us to combine two computational effects (mutable state and error accumulation) in a single list traversal.

But I am not yet done demonstrating the power of composition. As you showed in one of the exercises, `Traversable` is also closed under composition, so a nesting of traversables is again a traversable. Consider the following use case: When reading a CSV file, we'd like to allow lines to be annotated with additional information. Such annotations could be mere comments but also some formatting instructions or other custom data tags might be feasible. Annotations are supposed to be separated from the rest of the content by a single hash character (`#`). We want to keep track of these optional annotations so we come up with a custom data type encapsulating this distinction:

```idris
data Line : Type -> Type where
  Annotated : String -> a -> Line a
  Clean     : a -> Line a
```

This is just another container type and we can easily implement `Traversable` for `Line` (do this yourself as a quick exercise):

```idris
Functor Line where
  map f (Annotated s x) = Annotated s $ f x
  map f (Clean x)       = Clean $ f x

Foldable Line where
  foldr f acc (Annotated _ x) = f x acc
  foldr f acc (Clean x)       = f x acc

Traversable Line where
  traverse f (Annotated s x) = Annotated s <$> f x
  traverse f (Clean x)       = Clean <$> f x
```

Below is a function for parsing a line and putting it in its correct category. For simplicity, we just split the line on hashes: If the result consists of exactly two strings, we treat the second part as an annotation, otherwise we treat the whole line as untagged CSV content.

```idris
readLine : String -> Line String
readLine s = case split ('#' ==) s of
  h ::: [t] => Annotated t h
  _         => Clean s
```

We are now going to implement a function for reading whole CSV tables, keeping track of line annotations:

```idris
readCSV :  (0 ts : List Type)
        -> CSVLine (HList ts)
        => String
        -> Validated CSVError (List $ Line $ HList ts)
readCSV ts = evalState 1
           . traverse @{Compose} @{Compose} (tagAndDecode ts)
           . map readLine
           . lines
```

Let's digest this monstrosity. This is written in point-free style, so we have to read it from end to beginning. First, we split the whole string at line breaks, getting a list of strings (function `Data.String.lines`). Next, we analyze each line, keeping track of optional annotations (`map readLine`). This gives us a value of type `List (Line String)`. Since this is a nesting of traversables, we invoke `traverse` with a named instance from the *Prelude*: `Prelude.Traversable.Compose`. Idris can disambiguate this based on the types, so we can drop the namespace prefix. But the effectful computation we run over the list of lines results in a composition of applicative functors, so we also need the named implementation for compositions of applicatives in the second constraint (again without need of an explicit prefix, which would be `Prelude.Applicative` here). Finally, we evaluate the stateful computation with `evalState 1`.

Honestly, I wrote all of this without verifying if it works, so let's give it a go at the REPL. I'll provide two example strings for this, a valid one without errors, and an invalid one. I use *multiline string literals* here, about which I'll talk in more detail in a later chapter. For the moment, note that these allow us to conveniently enter string literals with line breaks:

```idris
validInput : String
validInput = """
  f,12,-13.01#this is a comment
  t,100,0.0017
  t,1,100.8#color: red
  f,255,0.0
  f,24,1.12e17
  """

invalidInput : String
invalidInput = """
  o,12,-13.01#another comment
  t,100,0.0017
  t,1,abc
  f,256,0.0
  f,24,1.12e17
  """
```

And here's how it goes at the REPL:

```repl
Tutorial.Traverse> readCSV [Bool,Bits8,Double] validInput
Valid [Annotated "this is a comment" [False, 12, -13.01],
       Clean [True, 100, 0.0017],
       Annotated "color: red" [True, 1, 100.8],
       Clean [False, 255, 0.0],
       Clean [False, 24, 1.12e17]]

Tutorial.Traverse> readCSV [Bool,Bits8,Double] invalidInput
Invalid (Append (FieldError 1 1 "o")
  (Append (FieldError 3 3 "abc") (FieldError 4 2 "256")))
```

It is pretty amazing how we wrote dozens of lines of code, always being guided by the type- and totality checkers, arriving eventually at a function for parsing properly typed CSV tables with automatic line numbering and error accumulation, all of which just worked on first try.

<!-- vi: filetype=idris2:syntax=markdown
-->
