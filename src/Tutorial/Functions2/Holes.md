# Programming with Holes

```idris
module Tutorial.Functions2.Holes

%default total
```

Solved all the exercises so far? Got angry at the type checker for always complaining and never being really helpful? It's time to change that. Idris comes with several highly useful interactive editing features. Sometimes, the compiler is able to implement complete functions for us (if the types are specific enough). Even if that's not possible, there's an incredibly useful and important feature, which can help us when the types are getting too complicated: Holes. Holes are variables, the names of which are prefixed with a question mark. We can use them as placeholders whenever we plan to implement a piece of functionality at a later time. In addition, their types and the types and quantities of all other variables in scope can be inspected at the REPL (or in your editor, if you setup the necessary plugin). Let's see them holes in action.

Remember the `traverseList` example from an Exercise earlier in this section? If this was your first encounter with applicative list traversals, this might have been a nasty bit of work. Well, let's just make it a wee bit harder still. We'd like to implement the same piece of functionality for functions returning `Either e`, where `e` is a type with a `Semigroup` implementation, and we'd like to accumulate the values in all `Left`s we meet along the way.

Here's the type of the function:

```idris
traverseEither :  Semigroup e
               => (a -> Either e b)
               -> List a
               -> Either e (List b)
```

As an optional exercise, you may wish to attempt this yourself first. You've seen everything you need. Consider:

- semigroups have an append operation `<+> : e -> e -> e` that combines two values into one
- the empty list will succeed vacuously
- if any of the function applications fail, you'll return a consolidation of all of the errors `e`
- if all of the function applications succeed, you'll return a list with all of the results `b`
- if you get it to compile, there are some test functions and variables at the bottom of this section for you to confirm that it's working as intended

Now, in order to follow along, you might want to start your own Idris source file, load it into a REPL session and adjust the code as described here. The first thing we'll do, is write a skeleton implementation with a hole on the right hand side:

```repl
traverseEither fun as = ?impl
```

When you now go to the REPL and reload the file using command `:r`, you can enter `:m` to list all the *metavariables*:

```repl
Tutorial.Functions2> :m
1 hole:
  Tutorial.Functions2.impl : Either e (List b)
```

Next, we'd like to display the hole's type (including all variables in the surrounding context plus their types):

```repl
Tutorial.Functions2> :t impl
 0 b : Type
 0 a : Type
 0 e : Type
   as : List a
   fun : a -> Either e b
------------------------------
impl : Either e (List b)
```

So, we have some erased type parameters (`a`, `b`, and `e`), a value of type `List a` called `as`, and a function from `a` to `Either e b` called `fun`. Our goal is to come up with a value of type `Either a (List b)`.

We *could* just return a `Right []`, but that only make sense if our input list is indeed the empty list. We therefore should start with a pattern match on the list:

```repl
traverseEither fun []        = ?impl_0
traverseEither fun (x :: xs) = ?impl_1
```

The result is two holes, which must be given distinct names. When inspecting `impl_0`, we get the following result:

```repl
Tutorial.Functions2> :t impl_0
 0 b : Type
 0 a : Type
 0 e : Type
   fun : a -> Either e b
------------------------------
impl_0 : Either e (List b)
```

Now, this is an interesting situation. We are supposed to come up with a value of type `Either e (List b)` with nothing to work with. We know nothing about `a`, so we can't provide an argument with which to invoke `fun`. Likewise, we know nothing about `e` or `b` either, so we can't produce any values of these either. The *only* option we have is to replace `impl_0` with an empty list wrapped in a `Right`:

```idris
traverseEither fun []        = Right []
```

The non-empty case is of course slightly more involved. Here's the context of `?impl_1`:

```repl
Tutorial.Functions2> :t impl_1
 0 b : Type
 0 a : Type
 0 e : Type
   x : a
   xs : List a
   fun : a -> Either e b
------------------------------
impl_1 : Either e (List b)
```

Since `x` is of type `a`, we can either use it as an argument to `fun` or drop and ignore it. `xs`, on the other hand, is the remainder of the list of type `List a`. We could again drop it or process it further by invoking `traverseEither` recursively. Since the goal is to try and convert *all* values, we should drop neither. Since in case of two `Left`s we are supposed to accumulate the values, we eventually need to run both computations anyway (invoking `fun`, and recursively calling `traverseEither`). We therefore can do both at the same time and analyze the results in a single pattern match by wrapping both in a `Pair`:

```repl
traverseEither fun (x :: xs) =
  case (fun x, traverseEither fun xs) of
   p => ?impl_2
```

Once again, we inspect the context:

```repl
Tutorial.Functions2> :t impl_2
 0 b : Type
 0 a : Type
 0 e : Type
   xs : List a
   fun : a -> Either e b
   x : a
   p : (Either e b, Either e (List b))
------------------------------
impl_2 : Either e (List b)
```

We'll definitely need to pattern match on pair `p` next to figure out, which of the two computations succeeded:

```repl
traverseEither fun (x :: xs) =
  case (fun x, traverseEither fun xs) of
    (Left y, Left z)   => ?impl_6
    (Left y, Right _)  => ?impl_7
    (Right _, Left z)  => ?impl_8
    (Right y, Right z) => ?impl_9
```

At this point we might have forgotten what we actually wanted to do (at least to me, this happens annoyingly often), so we'll just quickly check what our goal is:

```repl
Tutorial.Functions2> :t impl_6
 0 b : Type
 0 a : Type
 0 e : Type
   xs : List a
   fun : a -> Either e b
   x : a
   y : e
   z : e
------------------------------
impl_6 : Either e (List b)
```

So, we are still looking for a value of type `Either e (List b)`, and we have two values of type `e` in scope. According to the spec we want to accumulate these using `e`s `Semigroup` implementation. We can proceed for the other cases in a similar manner, remembering that we should return a `Right`, if and only if all conversions where successful:

```idris
traverseEither fun (x :: xs) =
  case (fun x, traverseEither fun xs) of
    (Left y, Left z)   => Left (y <+> z)
    (Left y, Right _)  => Left y
    (Right _, Left z)  => Left z
    (Right y, Right z) => Right (y :: z)
```

To reap the fruits of our labour, let's show off with a small example:

```idris
data Nucleobase = Adenine | Cytosine | Guanine | Thymine

readNucleobase : Char -> Either (List String) Nucleobase
readNucleobase 'A' = Right Adenine
readNucleobase 'C' = Right Cytosine
readNucleobase 'G' = Right Guanine
readNucleobase 'T' = Right Thymine
readNucleobase c   = Left ["Unknown nucleobase: " ++ show c]

DNA : Type
DNA = List Nucleobase

readDNA : String -> Either (List String) DNA
readDNA = traverseEither readNucleobase . unpack
```

Let's try this at the REPL:

```repl
Tutorial.Functions2> readDNA "CGTTA"
Right [Cytosine, Guanine, Thymine, Thymine, Adenine]
Tutorial.Functions2> readDNA "CGFTAQ"
Left ["Unknown nucleobase: 'F'", "Unknown nucleobase: 'Q'"]
```

## Interactive Editing

There are plugins available for several editors and programming environments, which facilitate interacting with the Idris compiler when implementing your functions. One editor, which is well supported in the Idris community, is Neovim. Since I am a Neovim user myself, I added some examples of what's possible to the [appendix](../Appendices/Neovim.md). Now would be a good time to start using the utilities discussed there.

If you use a different editor, probably with less support for the Idris programming language, you should at the very least have a REPL session open all the time, where the source file you are currently working on is loaded. This allows you to introduce new metavariables and inspect their types and context as you develop your code.

<!-- vi: filetype=idris2:syntax=markdown
-->
