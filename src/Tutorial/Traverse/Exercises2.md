# Exercises part 2

This sections consists of two extended exercise, the aim of which is to increase your understanding of the state monad. In the first exercise, we will look at random value generation, a classical application of stateful computations. In the second exercise, we will look at an indexed version of a state monad, which allows us to not only change the state's value but also its *type* during computations.

1. Below is the implementation of a simple pseudo-random number generator. We call this a *pseudo-random* number generator, because the numbers look pretty random but are generated predictably. If we initialize a series of such computations with a truly random seed, most users of our library will not be able to predict the outcome of our computations.

   ```idris
   rnd : Bits64 -> Bits64
   rnd seed = fromInteger
            $ (437799614237992725 * cast seed) `mod` 2305843009213693951
   ```

   The idea here is that the next pseudo-random number gets calculated from the previous one. But once we think about how we can use these numbers as seeds for computing random values of other types, we realize that these are just stateful computations. We can therefore write down an alias for random value generators as stateful computations:

   ```idris
   Gen : Type -> Type
   Gen = State Bits64
   ```

   Before we begin, please note that `rnd` is not a very strong pseudo-random number generator. It will not generate values in the full 64bit range, nor is it safe to use in cryptographic applications. It is sufficient for our purposes in this chapter, however. Note also, that we could replace `rnd` with a stronger generator without any changes to the functions you will implement as part of this exercise.

   01. Implement `bits64` in terms of `rnd`. This should return the current state, updating it afterwards by invoking function `rnd`. Make sure the state is properly updated, otherwise this won't behave as expected.

       ```idris
       bits64 : Gen Bits64
       ```

       This will be our *only* primitive generator, from which we will derived all the others. Therefore, before you continue, quickly test your implementation of `bits64` at the REPL:

       ```repl
       Solutions.Traverse> runState 100 bits64
       (2274787257952781382, 100)
       ```

   02. Implement `range64` for generating random values in the range `[0,upper]`. Hint: Use `bits64` and `mod` in your implementation but make sure to deal with the fact that `mod x upper` produces values in the range `[0,upper)`.

       ```idris
       range64 : (upper : Bits64) -> Gen Bits64
       ```

       Likewise, implement `interval64` for generating values in the range `[min a b, max a b]`:

       ```idris
       interval64 : (a,b : Bits64) -> Gen Bits64
       ```

       Finally, implement `interval` for arbitrary integral types.

       ```idris
       interval : Num n => Cast n Bits64 => (a,b : n) -> Gen n
       ```

       Note, that `interval` will not generate all possible values in the given interval but only such values with a `Bits64` representation in the the range `[0,2305843009213693950]`.

   03. Implement a generator for random boolean values.

   04. Implement a generator for `Fin n`. You'll have to think carefully about getting this one to typecheck and be accepted by the totality checker without cheating. Note: Have a look at function `Data.Fin.natToFin`.

   05. Implement a generator for selecting a random element from a vector of values. Use the generator from exercise 4 in your implementation.

   06. Implement `vect` and `list`. In case of `list`, the first argument should be used to randomly determine the length of the list.

       ```idris
       vect : {n : _} -> Gen a -> Gen (Vect n a)

       list : Gen Nat -> Gen a -> Gen (List a)
       ```

       Use `vect` to implement utility function `testGen` for testing your generators at the REPL:

       ```idris
       testGen : Bits64 -> Gen a -> Vect 10 a
       ```

   07. Implement `choice`.

       ```idris
       choice : {n : _} -> Vect (S n) (Gen a) -> Gen a
       ```

   08. Implement `either`.

       ```idris
       either : Gen a -> Gen b -> Gen (Either a b)
       ```

   09. Implement a generator for printable ASCII characters. These are characters with ASCII codes in the interval `[32,126]`. Hint: Function `chr` from the *Prelude* will be useful here.

   10. Implement a generator for strings. Hint: Function `pack` from the *Prelude* might be useful for this.

       ```idris
       string : Gen Nat -> Gen Char -> Gen String
       ```

   11. We shouldn't forget about our ability to encode interesting things in the types in Idris, so, for a challenge and without further ado, implement `hlist` (note the distinction between `HListF` and `HList`). If you are rather new to dependent types, this might take a moment to digest, so don't forget to use holes.

       ```idris
       data HListF : (f : Type -> Type) -> (ts : List Type) -> Type where
         Nil  : HListF f []
         (::) : (x : f t) -> (xs : HLift f ts) -> HListF f (t :: ts)

       hlist : HListF Gen ts -> Gen (HList ts)
       ```

   12. Generalize `hlist` to work with any applicative functor, not just `Gen`.

   If you arrived here, please realize how we can now generate pseudo-random values for most primitives, as well as regular sum- and product types. Here is an example REPL session:

   ```repl
   > testGen 100 $ hlist [bool, printableAscii, interval 0 127]
   [[True, ';', 5],
    [True, '^', 39],
    [False, 'o', 106],
    [True, 'k', 127],
    [False, ' ', 11],
    [False, '~', 76],
    [True, 'M', 11],
    [False, 'P', 107],
    [True, '5', 67],
    [False, '8', 9]]
   ```

   Final remarks: Pseudo-random value generators play an important role in property based testing libraries like [QuickCheck](https://hackage.haskell.org/package/QuickCheck) or [Hedgehog](https://github.com/stefan-hoeck/idris2-hedgehog). The idea of property based testing is to test predefined *properties* of pure functions against a large number of randomly generated arguments, to get strong guarantees about these properties to hold for *all* possible arguments. One example would be a test for verifying that the result of reversing a list twice equals the original list. While it is possible to proof many of the simpler properties in Idris directly without the need for tests, this is no longer possible as soon as functions are involved, which don't reduce during unification such as foreign function calls or functions not publicly exported from other modules.

2. While `State s a` gives us a convenient way to talk about stateful computations, it only allows us to mutate the state's *value* but not its *type*. For instance, the following function cannot be encapsulated in `State` because the type of the state changes:

   ```idris
   uncons : Vect (S n) a -> (Vect n a, a)
   uncons (x :: xs) = (xs, x)
   ```

   Your task is to come up with a new state type allowing for such changes (sometimes referred to as an *indexed* state data type). The goal of this exercise is to also sharpen your skills in expressing things at the type level including derived function types and interfaces. Therefore, I will give only little guidance on how to go about this. If you get stuck, feel free to peek at the solutions but make sure to only look at the types at first.

   1. Come up with a parameterized data type for encapsulating stateful computations where the input and output state type can differ. It must be possible to wrap `uncons` in a value of this type.

   2. Implement `Functor` for your indexed state type.

   3. It is not possible to implement `Applicative` for this *indexed* state type (but see also exercise 2.vii). Still, implement the necessary functions to use it with idom brackets.

   4. It is not possible to implement `Monad` for this indexed state type. Still, implement the necessary functions to use it in do blocks.

   5. Generalize the functions from exercises 3 and 4 with two new interfaces `IxApplicative` and `IxMonad` and provide implementations of these for your indexed state data type.

   6. Implement functions `get`, `put`, `modify`, `runState`, `evalState`, and `execState` for the indexed state data type. Make sure to adjust the type parameters where necessary.

   7. Show that your indexed state type is strictly more powerful than `State` by implementing `Applicative` and `Monad` for it.

      Hint: Keep the input and output state identical. Note also, that you might need to implement `join` manually if Idris has trouble inferring the types correctly.

   Indexed state types can be useful when we want to make sure that stateful computations are combined in the correct sequence, or that scarce resources get cleaned up properly. We might get back to such use cases in later examples.
