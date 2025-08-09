# Preconditions

```idris
module Tutorial.Predicates.Preconditions

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

Often, when we implement functions operating on values of a given type, not all values are considered to be valid arguments for the function in question. For instance, we typically do not allow division by zero, as the result is undefined in the general case. This concept of putting a *precondition* on a function argument comes up pretty often, and there are several ways to go about this.

A very common operation when working with lists or other container types is to extract the first value in the sequence. This function, however, cannot work in the general case, because in order to extract a value from a list, the list must not be empty. Here are a couple of ways to encode and implement this, each with its own advantages and disadvantages:

- Wrap the result in a failure type, such as a `Maybe` or `Either e` with some custom error type `e`. This makes it immediately clear that the function might not be able to return a result. It is a natural way to deal with unvalidated input from unknown sources. The drawback of this approach is that results will carry the `Maybe` stain, even in situations when we *know* that the *nil* case is impossible, for instance because we know the value of the list argument at compile-time, or because we already *refined* the input value in such a way that we can be sure it is not empty (due to an earlier pattern match, for instance).

- Define a new data type for non-empty lists and use this as the function's argument. This is the approach taken in module `Data.List1`. It allows us to return a pure value (meaning "not wrapped in a failure type" here), because the function cannot possibly fail, but it comes with the burden of reimplementing many of the utility functions and interfaces we already implemented for `List`. For a very common data structure this can be a valid option, but for rare use cases it is often too cumbersome.

- Use an index to keep track of the property we are interested in. This was the approach we took with type family `List01`, which we saw in several examples and exercises in this guide so far. This is also the approach taken with vectors, where we use the exact length as our index, which is even more expressive. While this allows us to implement many functions only once and with greater precision at the type level, it also comes with the burden of keeping track of changes in the types, making for more complex function types and forcing us to at times return existentially quantified wrappers (for instance, dependent pairs), because the outcome of a computation is not known until runtime.

- Fail with a runtime exception. This is a popular solution in many programming languages (even Haskell), but in Idris we try to avoid this, because it breaks totality in a way, which also affects client code. Luckily, we can make use of our powerful type system to avoid this situation in general.

- Take an additional (possibly erased) argument of a type we can use as a witness that the input value is of the correct kind or shape. This is the solution we will discuss in this chapter in great detail. It is an incredibly powerful way to talk about restrictions on values without having to replicate a lot of already existing functionality.

There is a time and place for most if not all of the solutions listed above in Idris, but we will often turn to the last one and refine function arguments with predicates (so called *preconditions*), because it makes our functions nice to use at runtime *and* compile time.

## Example: Non-empty Lists

Remember how we implemented an indexed data type for propositional equality: We restricted the valid values of the indices in the constructors. We can do the same thing for a predicate for non-empty lists:

```idris
data NotNil : (as : List a) -> Type where
  IsNotNil : NotNil (h :: t)
```

This is a single-value data type, so we can always use it as an erased function argument and still pattern match on it. We can now use this to implement a safe and pure `head` function:

```idris
head1 : (as : List a) -> (0 _ : NotNil as) -> a
head1 (h :: _) _ = h
head1 [] IsNotNil impossible
```

Note, how value `IsNotNil` is a *witness* that its index, which corresponds to our list argument, is indeed non-empty, because this is what we specified in its type. The impossible case in the implementation of `head1` is not strictly necessary here. It was given above for completeness.

We call `NotNil` a *predicate* on lists, as it restricts the values allowed in the index. We can express a function's preconditions by adding additional (possibly erased) predicates to the function's list of arguments.

The first really cool thing is how we can safely use `head1`, if we can at compile-time show that our list argument is indeed non-empty:

```idris
headEx1 : Nat
headEx1 = head1 [1,2,3] IsNotNil
```

It is a bit cumbersome that we have to pass the `IsNotNil` proof manually. Before we scratch that itch, we will first discuss what to do with lists, the values of which are not known until runtime. For these cases, we have to try and produce a value of the predicate programmatically by inspecting the runtime list value. In the most simple case, we can wrap the proof in a `Maybe`, but if we can show that our predicate is *decidable*, we can get even stronger guarantees by returning a `Dec`:

```idris
Uninhabited (NotNil []) where
  uninhabited IsNotNil impossible

nonEmpty : (as : List a) -> Dec (NotNil as)
nonEmpty (x :: xs) = Yes IsNotNil
nonEmpty []        = No uninhabited
```

With this, we can implement function `headMaybe`, which is to be used with lists of unknown origin:

```idris
headMaybe1 : List a -> Maybe a
headMaybe1 as = case nonEmpty as of
  Yes prf => Just $ head1 as prf
  No  _   => Nothing
```

Of course, for trivial functions like `headMaybe` it makes more sense to implement them directly by pattern matching on the list argument, but we will soon see examples of predicates the values of which are more cumbersome to create.

## Auto Implicits

Having to manually pass a proof of being non-empty to `head1` makes this function unnecessarily verbose to use at compile time. Idris allows us to define implicit function arguments, the values of which it tries to assemble on its own by means of a technique called *proof search*. This is not to be confused with type inference, which means inferring values or types from the surrounding context. It's best to look at some examples to explain the difference.

Let us first have a look at the following implementation of `replicate` for vectors:

```idris
replicate' : {n : _} -> a -> Vect n a
replicate' {n = 0}   _ = []
replicate' {n = S _} v = v :: replicate' v
```

Function `replicate'` takes an unerased implicit argument. The *value* of this argument must be derivable from the surrounding context. For instance, in the following example it is immediately clear that `n` equals three, because that is the length of the vector we want:

```idris
replicateEx1 : Vect 3 Nat
replicateEx1 = replicate' 12
```

In the next example, the value of `n` is not known at compile time, but it is available as an unerased implicit, so this can again be passed as is to `replicate'`:

```idris
replicateEx2 : {n : _} -> Vect n Nat
replicateEx2 = replicate' 12
```

However, in the following example, the value of `n` can't be inferred, as the intermediary vector is immediately converted to a list of unknown length. Although Idris could try and insert any value for `n` here, it won't do so, because it can't be sure that this is the length we want. We therefore have to pass the length explicitly:

```idris
replicateEx3 : List Nat
replicateEx3 = toList $ replicate' {n = 17} 12
```

Note, how the *value* of `n` had to be inferable in these examples, which means it had to make an appearance in the surrounding context. With auto implicit arguments, this works differently. Here is the `head` example, this time with an auto implicit:

```idris
head : (as : List a) -> {auto 0 prf : NotNil as} -> a
head (x :: _) = x
head [] impossible
```

Note the `auto` keyword before the quantity of implicit argument `prf`. This means, we want Idris to construct this value on its own, without it being visible in the surrounding context. In order to do so, Idris will have to at compile time know the structure of the list argument `as`. It will then try and build such a value from the data type's constructors. If it succeeds, this value will then be automatically filled in as the desired argument, otherwise, Idris will fail with a type error.

Let's see this in action:

```idris
headEx3 : Nat
headEx3 = Preconditions.head [1,2,3]
```

The following example fails with an error:

```idris
failing "Can't find an implementation\nfor NotNil []."
  errHead : Nat
  errHead = Preconditions.head []
```

Wait! "Can't find an implementation for..."? Is this not the error message we get for missing interface implementations? That's correct, and I'll show you that interface resolution is just proof search at the end of this chapter. What I can show you already, is that writing the lengthy `{auto prf : t} ->` all the times can be cumbersome. Idris therefore allows us to use the same syntax as for constrained functions instead: `(prf : t) =>`, or even `t =>`, if we don't need to name the constraint. As usual, we can then access a constraint in the function body by its name (if any). Here is another implementation of `head`:

```idris
head' : (as : List a) -> (0 _ : NotNil as) => a
head' (x :: _) = x
head' [] impossible
```

During proof search, Idris will also look for values of the required type in the current function context. This allows us to implement `headMaybe` without having to pass on the `NotNil` proof manually:

```idris
headMaybe : List a -> Maybe a
headMaybe as = case nonEmpty as of
  -- `prf` is available during proof seach
  Yes prf => Just $ Preconditions.head as
  No  _   => Nothing
```

To conclude: Predicates allow us to restrict the values a function accepts as arguments. At runtime, we need to build such *witnesses* by pattern matching on the function arguments. These operations can typically fail. At compile time, we can let Idris try and build these values for us using a technique called *proof search*. This allows us to make functions safe and convenient to use at the same time.

<!-- vi: filetype=idris2:syntax=markdown
-->
