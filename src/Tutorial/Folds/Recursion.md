# Recursion

```idris
module Tutorial.Folds.Recursion

import Data.List1
import Data.Maybe
import Data.Vect
import Debug.Trace

%default total
```

In this section, we are going to have a closer look at recursion in general and at tail recursion in particular.

Recursive functions are functions, which call themselves to repeat a task or calculation until a certain aborting condition (called the *base case*) holds. Please note, that it is recursive functions, which make it hard to verify totality: Non-recursive functions, which are *covering* (they cover all possible cases in their pattern matches) are automatically total if they only invoke other total functions.

Here is an example of a recursive function: It generates a list of the given length filling it with identical values:

```idris
replicateList : Nat -> a -> List a
replicateList 0     _ = []
replicateList (S k) x = x :: replicateList k x
```

As you can see (this module has the `%default total` pragma at the top), this function is provably total. Idris verifies, that the `Nat` argument gets *strictly smaller* in each recursive call, and that therefore, the function *must* eventually come to an end. Of course, we can do the same thing for `Vect`, where we can even show that the length of the resulting vector matches the given natural number:

```idris
replicateVect : (n : Nat) -> a -> Vect n a
replicateVect 0     _ = []
replicateVect (S k) x = x :: replicateVect k x
```

While we often use recursion to *create* values of data types like `List` or `Vect`, we also use recursion, when we *consume* such values. For instance, here is a function for calculating the length of a list:

```idris
len : List a -> Nat
len []        = 0
len (_ :: xs) = 1 + len xs
```

Again, Idris can verify that `len` is total, as the list we pass in the recursive case is strictly smaller than the original list argument.

But when is a recursive function non-total? Here is an example: The following function creates a sequence of values until the given generation function (`gen`) returns a `Nothing`. Note, how we use a *state* value (of generic type `s`) and use `gen` to calculate a value together with the next state:

```idris
covering
unfold : (gen : s -> Maybe (s,a)) -> s -> List a
unfold gen vs = case gen vs of
  Just (vs',va) => va :: unfold gen vs'
  Nothing       => []
```

With `unfold`, Idris can't verify that any of its arguments is converging towards the base case. It therefore rightfully refuses to accept that `unfold` is total. And indeed, the following function produces an infinite list (so please, don't try to inspect this at the REPL, as doing so will consume all your computer's memory):

```idris
fiboHelper : (Nat,Nat) -> ((Nat,Nat),Nat)
fiboHelper (f0,f1) = ((f1, f0 + f1), f0)

covering
fibonacci : List Nat
fibonacci = unfold (Just . fiboHelper) (1,1)
```

In order to safely create a (finite) sequence of Fibonacci numbers, we need to make sure the function generating the sequence will stop after a finite number of steps, for instance by limiting the length of the list:

```idris
unfoldTot : Nat -> (gen : s -> Maybe (s,a)) -> s -> List a
unfoldTot 0     _   _  = []
unfoldTot (S k) gen vs = case gen vs of
  Just (vs',va) => va :: unfoldTot k gen vs'
  Nothing       => []

fibonacciN : Nat -> List Nat
fibonacciN n = unfoldTot n (Just . fiboHelper) (1,1)
```

## The Call Stack

In order to demonstrate what tail recursion is about, we require the following `main` function:

```idris
main : IO ()
main = printLn . len $ replicateList 10000 10
```

If you have [Node.js](https://nodejs.org/en/) installed on your system, you might try the following experiment. Compile and run this module using the *Node.js* backend of Idris instead of the default *Chez Scheme* backend and run the resulting JavaScript source file with the Node.js binary:

```sh
idris2 --cg node -o test.js --find-ipkg src/Tutorial/Folds.md
node build/exec/test.js
```

Node.js will fail with the following error message and a lengthy stack trace: `RangeError: Maximum call stack size exceeded`. What's going on here? How can it be that `main` fails with an exception although it is provably total?

First, remember that a function being total means that it will eventually produce a value of the given type in a finite amount of time, *given enough resources like computer memory*. Here, `main` hasn't been given enough resources as Node.js has a very small size limit on its call stack. The *call stack* can be thought of as a stack data structure (first in, last out), where nested function calls are put. In case of recursive functions, the stack size increases by one with every recursive function call. In case of our `main` function, we create and consume a list of length 10'000, so the call stack will hold at least 10'000 function calls before they are being invoked and the stack's size is reduced again. This exceeds Node.js's stack size limit by far, hence the overflow error.

Now, before we look at a solution how to circumvent this issue, please note that this is a very serious and limiting source of bugs when using the JavaScript backends of Idris. In Idris, having no access to control structures like `for` or `while` loops, we *always* have to resort to recursion in order to describe iterative computations. Luckily (or should I say "unfortunately", since otherwise this issue would already have been addressed with all seriousness), the Scheme backends don't have this issue, as their stack size limit is much larger and they perform all kinds of optimizations internally to prevent the call stack from overflowing.

## Tail Recursion

A recursive function is said to be *tail recursive*, if all recursive calls occur at *tail position*: The last function call in a (sub)expression. For instance, the following version of `len` is tail recursive:

```idris
lenOnto : Nat -> List a -> Nat
lenOnto k []        = k
lenOnto k (_ :: xs) = lenOnto (k + 1) xs
```

Compare this to `len` as defined above: There, the last function call is an invocation of operator `(+)`, and the recursive call happens in one of its arguments:

```repl
len (_ :: xs) = 1 + len xs
```

We can use `lenOnto` as a utility to implement a tail recursive version of `len` without the additional `Nat` argument:

```idris
lenTR : List a -> Nat
lenTR = lenOnto 0
```

This is a common pattern when writing tail recursive functions: We typically add an additional function argument for accumulating intermediary results, which is then passed on explicitly at each recursive call. For instance, here is a tail recursive version of `replicateList`:

```idris
replicateListTR : Nat -> a -> List a
replicateListTR n v = go Nil n
  where go : List a -> Nat -> List a
        go xs 0     = xs
        go xs (S k) = go (v :: xs) k
```

The big advantage of tail recursive functions is, that they can be easily converted to efficient, imperative loops by the Idris compiler, and are thus *stack safe*: Recursive function calls are *not* added to the call stack, thus avoiding the dreaded stack overflow errors.

```idris
main1 : IO ()
main1 = printLn . lenTR $ replicateListTR 10000 10
```

We can again run `main1` using the *Node.js* backend. This time, we use slightly different syntax to execute a function other than `main` (Remember: The dollar prefix is only there to distinghish a terminal command from its output. It is not part of the command you enter in a terminal sesssion.):

```sh
$ idris2 --cg node --exec main1 --find-ipkg src/Tutorial/Folds.md
10000
```

As you can see, this time the computation finished without overflowing the call stack.

Tail recursive functions are allowed to consist of (possibly nested) pattern matches, with recursive calls at tail position in several of the branches. Here is an example:

```idris
countTR : (a -> Bool) -> List a -> Nat
countTR p = go 0
  where go : Nat -> List a -> Nat
        go k []        = k
        go k (x :: xs) = case p x of
          True  => go (S k) xs
          False => go k xs
```

Note, how each invocation of `go` is in tail position in its branch of the case expression.

## Mutual Recursion

It is sometimes convenient to implement several related functions, which call each other recursively. In Idris, unlike in many other programming languages, a function must be declared in a source file *before* it can be called by other functions, as in general a function's implementation must be available during type checking (because Idris has dependent types). There are two ways around this, which actually result in the same internal representation in the compiler. Our first option is to write down the functions' declarations first with the implementations following after. Here's a silly example:

```idris
even : Nat -> Bool

odd : Nat -> Bool

even 0     = True
even (S k) = odd k

odd 0     = False
odd (S k) = even k
```

As you can see, function `even` is allowed to call function `odd` in its implementation, since `odd` has already been declared (but not yet implemented).

If you're like me and want to keep declarations and implementations next to each other, you can introduce a `mutual` block, which has the same effect. Like with other code blocks, functions in a `mutual` block must all be indented by the same amount of whitespace:

```idris
mutual
  even' : Nat -> Bool
  even' 0     = True
  even' (S k) = odd' k

  odd' : Nat -> Bool
  odd' 0     = False
  odd' (S k) = even' k
```

Just like with single recursive functions, mutually recursive functions can be optimized to imperative loops if all recursive calls occur at tail position. This is the case with functions `even` and `odd`, as can again be verified at the *Node.js* backend:

```idris
main2 : IO ()
main2 =  printLn (even 100000)
      >> printLn (odd 100000)
```

```sh
$ idris2 --cg node --exec main2 --find-ipkg src/Tutorial/Folds.md
True
False
```

## Final Remarks

In this section, we learned about several important aspects of recursion and totality checking, which are summarized here:

- In pure functional programming, recursion is the way to implement iterative procedures.

- Recursive functions pass the totality checker, if it can verify that one of the arguments is getting strictly smaller in every recursive function call.

- Arbitrary recursion can lead to stack overflow exceptions on backends with small stack size limits.

- The JavaScript backends of Idris perform mutual tail call optimization: Tail recursive functions are converted to stack safe, imperative loops.

Note, that not all Idris backends you will come across in the wild will perform tail call optimization. Please check the corresponding documentation.

Note also, that most recursive functions in the core libraries (*prelude* and *base*) do not yet make use of tail recursion. There is an important reason for this: In many cases, non-tail recursive functions are easier to use in compile-time proofs, as they unify more naturally than their tail recursive counterparts. Compile-time proofs are an important aspect of programming in Idris (as we will see in later chapters), so there is a compromise to be made between what performs well at runtime and what works well at compile time. Eventually, the way to go might be to provide two implementations for most recursive functions with a *transform rule* telling the compiler to use the optimized version at runtime whenever programmers use the non-optimized version in their code. Such transform rules have - for instance - already been written for functions `pack` and `unpack` (which use `fastPack` and `fastUnpack` at runtime; see the corresponding rules in [the following source file](https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/Types.idr)).

<!-- vi: filetype=idris2:syntax=markdown
-->
