# Interface Foldable

```idris
module Tutorial.Folds.Foldable

import Debug.Trace

%default total
```

When looking back at all the exercises we solved in the section about recursion, most tail recursive functions on lists were of the following pattern: Iterate over all list elements from head to tail while passing along some state for accumulating intermediate results. At the end of the list, return the final state or convert it with an additional function call.

## Left Folds

This is functional programming, and we'd like to abstract over such reoccurring patterns. In order to tail recursively iterate over a list, all we need is an accumulator function and some initial state. But what should be the type of the accumulator? Well, it combines the current state with the list's next element and returns an updated state: `state -> elem -> state`. Surely, we can come up with a higher-order function to encapsulate this behavior:

```idris
leftFold : (acc : state -> el -> state) -> (st : state) -> List el -> state
leftFold _   st []        = st
leftFold acc st (x :: xs) = leftFold acc (acc st x) xs
```

We call this function a *left fold*, as it iterates over the list from left to right (head to tail), collapsing (or *folding*) the list until just a single value remains. This new value might still be a list or other container type, but the original list has been consumed from head to tail. Note how `leftFold` is tail recursive, and therefore all functions implemented in terms of `leftFold` are tail recursive (and thus, stack safe!) as well.

Here are a few examples:

```idris
sumLF : Num a => List a -> a
sumLF = leftFold (+) 0

reverseLF : List a -> List a
reverseLF = leftFold (flip (::)) Nil

-- this is more natural than `reverseLF`!
toSnocListLF : List a -> SnocList a
toSnocListLF = leftFold (:<) Lin
```

## Right Folds

The example functions we implemented in terms of `leftFold` had to always completely traverse the whole list, as every single element was required to compute the result. This is not always necessary, however. For instance, if you look at `findList` from the exercises, we could abort iterating over the list as soon as our search was successful. It is *not* possible to implement this more efficient behavior in terms of `leftFold`: There, the result will only be returned when our pattern match reaches the `Nil` case.

Interestingly, there is another, non-tail recursive fold, which reflects the list structure more naturally, we can use for breaking out early from an iteration. We call this a *right fold*. Here is its implementation:

```idris
rightFold : (acc : el -> state -> state) -> state -> List el -> state
rightFold acc st []        = st
rightFold acc st (x :: xs) = acc x (rightFold acc st xs)
```

Now, it might not immediately be obvious how this differs from `leftFold`. In order to see this, we will have to talk about lazy evaluation first.

### Lazy Evaluation in Idris

For some computations, it is not necessary to evaluate all function arguments in order to return a result. For instance, consider boolean operator `(&&)`: If the first argument evaluates to `False`, we already know that the result is `False` without even looking at the second argument. In such a case, we don't want to unnecessarily evaluate the second argument, as this might include a lengthy computation.

Consider the following REPL session:

```repl
Tutorial.Folds> False && (length [1..10000000000] > 100)
False
```

If the second argument were evaluated, this computation would most certainly blow up your computer's memory, or at least take a very long time to run to completion. However, in this case, the result `False` is printed immediately. If you look at the type of `(&&)`, you'll see the following:

```repl
Tutorial.Folds> :t (&&)
Prelude.&& : Bool -> Lazy Bool -> Bool
```

As you can see, the second argument is wrapped in a `Lazy` type constructor. This is a built-in type, and the details are handled by Idris automatically most of the time. For instance, when passing arguments to `(&&)`, we don't have to manually wrap the values in some data constructor. A lazy function argument will only be evaluated at the moment it is *required* in the function's implementation, for instance, because it is being pattern matched on, or it is being passed as a strict argument to another function. In the implementation of `(&&)`, the pattern match happens on the first argument, so the second will only be evaluated if the first argument is `True` and the second is returned as the function's (strict) result.

There are two utility functions for working with lazy evaluation: Function `delay` wraps a value in the `Lazy` data type. Note, that the argument of `delay` is strict, so the following might take several seconds to print its result:

```repl
Tutorial.Folds> False && (delay $ length [1..10000] > 100)
False
```

In addition, there is function `force`, which forces evaluation of a `Lazy` value.

### Lazy Evaluation and Right Folds

We will now learn how to make use of `rightFold` and lazy evaluation to implement folds, which can break out from iteration early. Note, that in the implementation of `rightFold` the result of folding over the remainder of the list is passed as an argument to the accumulator (instead of the result of invoking the accumulator being used in the recursive call):

```repl
rightFold acc st (x :: xs) = acc x (rightFold acc st xs)
```

If the second argument of `acc` were lazily evaluated, it would be possible to abort the computation of `acc`'s result without having to iterate till the end of the list:

```idris
foldHead : List a -> Maybe a
foldHead = force . rightFold first Nothing
  where first : a -> Lazy (Maybe a) -> Lazy (Maybe a)
        first v _ = Just v
```

Note, how Idris takes care of the bookkeeping of laziness most of the time. (It doesn't handle the curried invocation of `rightFold` correctly, though, so we either must pass on the list argument of `foldHead` explicitly, or compose the curried function with `force` to get the types right.)

In order to verify that this works correctly, we need a debugging utility called `trace` from module `Debug.Trace`. This "function" allows us to print debugging messages to the console at certain points in our pure code. Please note, that this is for debugging purposes only and should never be left lying around in production code, as, strictly speaking, printing stuff to the console breaks referential transparency.

Here is an adjusted version of `foldHead`, which prints "folded" to standard output every time utility function `first` is being invoked:

```idris
foldHeadTraced : List a -> Maybe a
foldHeadTraced = force . rightFold first Nothing
  where first : a -> Lazy (Maybe a) -> Lazy (Maybe a)
        first v _ = trace "folded" (Just v)
```

In order to test this at the REPL, we need to know that `trace` uses `unsafePerformIO` internally and therefore will not reduce during evaluation. We have to resort to the `:exec` command to see this in action at the REPL:

```repl
Tutorial.Folds> :exec printLn $ foldHeadTraced [1..10]
folded
Just 1
```

As you can see, although the list holds ten elements, `first` is only called once resulting in a considerable increase of efficiency.

Let's see what happens, if we change the implementation of `first` to use strict evaluation:

```idris
foldHeadTracedStrict : List a -> Maybe a
foldHeadTracedStrict = rightFold first Nothing
  where first : a -> Maybe a -> Maybe a
        first v _ = trace "folded" (Just v)
```

Although we don't use the second argument in the implementation of `first`, it is still being evaluated before evaluating the body of `first`, because Idris - unlike Haskell! - defaults to use strict semantics. Here's how this behaves at the REPL:

```repl
Tutorial.Folds> :exec printLn $ foldHeadTracedStrict [1..10]
folded
folded
folded
folded
folded
folded
folded
folded
folded
folded
Just 1
```

While this technique can sometimes lead to very elegant code, always remember that `rightFold` is not stack safe in the general case. So, unless your accumulator is guaranteed to return a result after not too many iterations, consider implementing your function tail recursively with an explicit pattern match. Your code will be slightly more verbose, but with the guaranteed benefit of stack safety.

## Folds and Monoids

Left and right folds share a common pattern: In both cases, we start with an initial *state* value and use an accumulator function for combining the current state with the current element. This principle of *combining values* after starting from an *initial value* lies at the heart of an interface we've already learned about: `Monoid`. It therefore makes sense to fold a list over a monoid:

```idris
foldMapList : Monoid m => (a -> m) -> List a -> m
foldMapList f = leftFold (\vm,va => vm <+> f va) neutral
```

Note how, with `foldMapList`, we no longer need to pass an accumulator function. All we need is a conversion from the element type to a type with an implementation of `Monoid`. As we have already seen in the chapter about [interfaces](Interfaces.md), there are *many* monoids in functional programming, and therefore, `foldMapList` is an incredibly useful function.

We could make this even shorter: If the elements in our list already are of a type with a monoid implementation, we don't even need a conversion function to collapse the list:

```idris
concatList : Monoid m => List m -> m
concatList = foldMapList id
```

## Stop Using `List` for Everything

And here we are, finally, looking at a large pile of utility functions all dealing in some way with the concept of collapsing (or folding) a list of values into a single result. But all of these folding functions are just as useful when working with vectors, with non-empty lists, with rose trees, even with single-value containers like `Maybe`, `Either e`, or `Identity`. Heck, for the sake of completeness, they are even useful when working with zero-value containers like `Control.Applicative.Const e`! And since there are so many of these functions, we'd better look out for an essential set of them in terms of which we can implement all the others, and wrap up the whole bunch in an interface. This interface is called `Foldable`, and is available from the `Prelude`. When you look at its definition in the REPL (`:doc Foldable`), you'll see that it consists of six essential functions:

- `foldr`, for folds from the right
- `foldl`, for folds from the left
- `null`, for testing if the container is empty or not
- `foldlM`, for effectful folds in a monad
- `toList`, for converting the container to a list of values
- `foldMap`, for folding over a monoid

For a minimal implementation of `Foldable`, it is sufficient to only implement `foldr`. However, consider implementing all six functions manually, because folds over container types are often performance critical operations, and each of them should be optimized accordingly. For instance, implementing `toList` in terms of `foldr` for `List` just makes no sense, as this is a non-tail recursive function running in linear time complexity, while a hand-written implementation can just return its argument without any modifications.

<!-- vi: filetype=idris2:syntax=markdown
-->
