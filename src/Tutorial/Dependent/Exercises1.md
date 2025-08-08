## Exercises part 1

01. Implement a function `len : List a -> Nat` for calculating the length of a `List`. For example, `len [1, 1, 1]` produces `3`.

02. Implement function `head` for non-empty vectors:

    ```idris
    head : Vect (S n) a -> a
    ```

    Note, how we can describe non-emptiness by using a *pattern* in the length of `Vect`. This rules out the `Nil` case, and we can return a value of type `a`, without having to wrap it in a `Maybe`! Make sure to add an `impossible` clause for the `Nil` case (although this is not strictly necessary here).

03. Using `head` as a reference, declare and implement function `tail` for non-empty vectors. The types should reflect that the output is exactly one element shorter than the input.

04. Implement `zipWith3`. If possible, try to doing so without looking at the implementation of `zipWith`:

    ```idris
    zipWith3 : (a -> b -> c -> d) -> Vect n a -> Vect n b -> Vect n c -> Vect n d
    ```

05. Declare and implement a function `foldSemi` for accumulating the values stored in a `List` through `Semigroup`s append operator (`(<+>)`). (Make sure to only use a `Semigroup` constraint, as opposed to a `Monoid` constraint.)

06. Do the same as in Exercise 4, but for non-empty vectors. How does a vector's non-emptiness affect the output type?

07. Given an initial value of type `a` and a function `a -> a`, we'd like to generate `Vect`s of `a`s, the first value of which is `a`, the second value being `f a`, the third being `f (f a)` and so on.

    For instance, if `a` is 1 and `f` is `(* 2)`, we'd like to get results similar to the following: `[1,2,4,8,16,...]`.

    Declare and implement function `iterate`, which should encapsulate this behavior. Get some inspiration from `replicate` if you don't know where to start.

08. Given an initial value of a state type `s` and a function `fun : s -> (s,a)`, we'd like to generate `Vect`s of `a`s. Declare and implement function `generate`, which should encapsulate this behavior. Make sure to use the updated state in every new invocation of `fun`.

    Here's an example how this can be used to generate the first `n` Fibonacci numbers:

    ```repl
    generate 10 (\(x,y) => let z = x + y in ((y,z),z)) (0,1)
    [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
    ```

09. Implement function `fromList`, which converts a list of values to a `Vect` of the same length. Use holes if you get stuck:

    ```idris
    fromList : (as : List a) -> Vect (length as) a
    ```

    Note how, in the type of `fromList`, we can *calculate* the length of the resulting vector by passing the list argument to function *length*.

10. Consider the following declarations:

```idris
maybeSize : Maybe a -> Nat

fromMaybe : (m : Maybe a) -> Vect (maybeSize m) a
```

Choose a reasonable implementation for `maybeSize` and implement `fromMaybe` afterwards.
