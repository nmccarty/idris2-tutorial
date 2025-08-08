# Reading CSV Tables

```idris
module Tutorial.Traverse.CSV

import Data.HList
import Data.IORef
import Data.List1
import Data.String
import Data.Validated
import Data.Vect
import Text.CSV

%default total
```

We stopped developing our CSV reader with function `hdecode`, which allows us to read a single line in a CSV file and decode it to a heterogeneous list. As a reminder, here is how to use `hdecode` at the REPL:

```repl
Tutorial.Traverse> hdecode [Bool,String,Bits8] 1 "f,foo,12"
Valid [False, "foo", 12]
```

The next step will be to parse a whole CSV table, represented as a list of strings, where each string corresponds to one of the table's rows. We will go about this stepwise as there are several aspects about doing this properly. What we are looking for - eventually - is a function of the following type (we are going to implement several versions of this function, hence the numbering):

```idris
hreadTable1 :  (0 ts : List Type)
            -> CSVLine (HList ts)
            => List String
            -> Validated CSVError (List $ HList ts)
```

In our first implementation, we are not going to care about line numbers:

```idris
hreadTable1 _  []        = pure []
hreadTable1 ts (s :: ss) = [| hdecode ts 0 s :: hreadTable1 ts ss |]
```

Note, how we can just use applicative syntax in the implementation of `hreadTable1`. To make this clearer, I used `pure []` on the first line instead of the more specific `Valid []`. In fact, if we used `Either` or `Maybe` instead of `Validated` for error handling, the implementation of `hreadTable1` would look exactly the same.

The question is: Can we extract a pattern to abstract over from this observation? What we do in `hreadTable1` is running an effectful computation of type `String -> Validated CSVError (HList ts)` over a list of strings, so that the result is a list of `HList ts` wrapped in a `Validated CSVError`. The first step of abstraction should be to use type parameters for the input and output: Run a computation of type `a -> Validated CSVError b` over a list `List a`:

```idris
traverseValidatedList :  (a -> Validated CSVError b)
                      -> List a
                      -> Validated CSVError (List b)
traverseValidatedList _ []        = pure []
traverseValidatedList f (x :: xs) = [| f x :: traverseValidatedList f xs |]

hreadTable2 :  (0 ts : List Type)
            -> CSVLine (HList ts)
            => List String
            -> Validated CSVError (List $ HList ts)
hreadTable2 ts = traverseValidatedList (hdecode ts 0)
```

But our observation was, that the implementation of `hreadTable1` would be exactly the same if we used `Either CSVError` or `Maybe` as our effect types instead of `Validated CSVError`. So, the next step should be to abstract over the *effect type*. We note, that we used applicative syntax (idiom brackets and `pure`) in our implementation, so we will need to write a function with an `Applicative` constraint on the effect type:

```idris
traverseList :  Applicative f => (a -> f b) -> List a -> f (List b)
traverseList _ []        = pure []
traverseList f (x :: xs) = [| f x :: traverseList f xs |]

hreadTable3 :  (0 ts : List Type)
            -> CSVLine (HList ts)
            => List String
            -> Validated CSVError (List $ HList ts)
hreadTable3 ts = traverseList (hdecode ts 0)
```

Note, how the implementation of `traverseList` is exactly the same as the one of `traverseValidatedList`, but the types are more general and therefore, `traverseList` is much more powerful.

Let's give this a go at the REPL:

```repl
Tutorial.Traverse> hreadTable3 [Bool,Bits8] ["f,12","t,0"]
Valid [[False, 12], [True, 0]]
Tutorial.Traverse> hreadTable3 [Bool,Bits8] ["f,12","t,1000"]
Invalid (FieldError 0 2 "1000")
Tutorial.Traverse> hreadTable3 [Bool,Bits8] ["1,12","t,1000"]
Invalid (Append (FieldError 0 1 "1") (FieldError 0 2 "1000"))
```

This works very well already, but note how our error messages do not yet print the correct line numbers. That's not surprising, as we are using a dummy constant in our call to `hdecode`. We will look at how we can come up with the line numbers on the fly when we talk about stateful computations later in this chapter. For now, we could just manually annotate the lines with their numbers and pass a list of pairs to `hreadTable`:

```idris
hreadTable4 :  (0 ts : List Type)
            -> CSVLine (HList ts)
            => List (Nat, String)
            -> Validated CSVError (List $ HList ts)
hreadTable4 ts = traverseList (uncurry $ hdecode ts)
```

If this is the first time you came across function `uncurry`, make sure you have a look at its type and try to figure out why it is used here. There are several utility functions like this in the *Prelude*, such as `curry`, `uncurry`, `flip`, or even `id`, all of which can be very useful when working with higher-order functions.

While not perfect, this version at least allows us to verify at the REPL that the line numbers are passed to the error messages correctly:

```repl
Tutorial.Traverse> hreadTable4 [Bool,Bits8] [(1,"t,1000"),(2,"1,100")]
Invalid (Append (FieldError 1 2 "1000") (FieldError 2 1 "1"))
```

## Interface Traversable

Now, here is an interesting observation: We can implement a function like `traverseList` for other container types as well. You might think that's obvious, given that we can convert container types to lists via function `toList` from interface `Foldable`. However, while going via `List` might be feasible in some occasions, it is undesirable in general, as we loose typing information. For instance, here is such a function for `Vect`:

```idris
traverseVect' : Applicative f => (a -> f b) -> Vect n a -> f (List b)
traverseVect' fun = traverseList fun . toList
```

Note how we lost all information about the structure of the original container type. What we are looking for is a function like `traverseVect'`, which keeps this type level information: The result should be a vector of the same length as the input.

```idris
traverseVect : Applicative f => (a -> f b) -> Vect n a -> f (Vect n b)
traverseVect _   []        = pure []
traverseVect fun (x :: xs) = [| fun x :: traverseVect fun xs |]
```

That's much better! And as I wrote above, we can easily get the same for other container types like `List1`, `SnocList`, `Maybe`, and so on. As usual, some derived functions will follow immediately from `traverseXY`. For instance:

```idris
sequenceList : Applicative f => List (f a) -> f (List a)
sequenceList = traverseList id
```

All of this calls for a new interface, which is called `Traversable` and is exported from the *Prelude*. Here is its definition (with primes for disambiguation):

```idris
interface Functor t => Foldable t => Traversable' t where
  traverse' : Applicative f => (a -> f b) -> t a -> f (t b)
```

Function `traverse` is one of the most abstract and versatile functions available from the *Prelude*. Just how powerful it is will only become clear once you start using it over and over again in your code. However, it will be the goal of the remainder of this chapter to show you several diverse and interesting use cases.

For now, we will quickly focus on the degree of abstraction. Function `traverse` is parameterized over no less than four parameters: The container type `t` (`List`, `Vect n`, `Maybe`, to just name a few), the effect type (`Validated e`, `IO`, `Maybe`, and so on), the input element type `a`, and the output element type `b`. Considering that the libraries bundled with the Idris project export more than 30 data types with an implementation of `Applicative` and more than ten traversable container types, there are literally hundreds of combinations for traversing a container with an effectful computation. This number gets even larger once we realize that traversable containers - like applicative functors - are closed under composition (see the exercises and the final section in this chapter).

## Traversable Laws

There are two laws function `traverse` must obey:

- `traverse (Id . f) = Id . map f`: Traversing over the `Identity` monad is just functor `map`.
- `traverse (MkComp . map f . g) = MkComp . map (traverse f) . traverse g`: Traversing with a composition of effects must be the same when being done in a single traversal (left hand side) or a sequence of two traversals (right hand side).

Since `map id = id` (functor's identity law), we can derive from the first law that `traverse Id = Id`. This means, that `traverse` must not change the size or shape of the container type, nor is it allowed to change the order of elements.

<!-- vi: filetype=idris2:syntax=markdown
-->
