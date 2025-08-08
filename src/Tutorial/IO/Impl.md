# How `IO` is Implemented

In this final section of an already lengthy chapter, we will risk a glance at how `IO` is implemented in Idris. It is interesting to note, that `IO` is not a built-in type but a regular data type with only one minor speciality. Let's learn about it at the REPL:

```repl
Tutorial.IO> :doc IO
data PrimIO.IO : Type -> Type
  Totality: total
  Constructor: MkIO : (1 _ : PrimIO a) -> IO a
  Hints:
    Applicative IO
    Functor IO
    HasLinearIO IO
    Monad IO
```

Here, we learn that `IO` has a single data constructor called `MkIO`, which takes a single argument of type `PrimIO a` with quantity *1*. We are not going to talk about the quantities here, as in fact they are not important to understand how `IO` works.

Now, `PrimIO a` is a type alias for the following function:

```repl
Tutorial.IO> :printdef PrimIO
PrimIO.PrimIO : Type -> Type
PrimIO a = (1 _ : %World) -> IORes a
```

Again, don't mind the quantities. There is only one piece of the puzzle missing: `IORes a`, which is a publicly exported record type:

```repl
Solutions.IO> :doc IORes
data PrimIO.IORes : Type -> Type
  Totality: total
  Constructor: MkIORes : a -> (1 _ : %World) -> IORes a
```

So, to put this all together, `IO` is a wrapper around something similar to the following function type:

```repl
%World -> (a, %World)
```

You can think of type `%World` as a placeholder for the state of the outside world of a program (file system, memory, network connections, and so on). Conceptually, to execute an `IO a` action, we pass it the current state of the world, and in return get an updated world state plus a result of type `a`. The world state being updated represents all the side effects describable in a computer program.

Now, it is important to understand that there is no such thing as the *state of the world*. The `%World` type is just a placeholder, which is converted to some kind of constant that's passed around and never inspected at runtime. So, if we had a value of type `%World`, we could pass it to an `IO a` action and execute it, and this is exactly what happens at runtime: A single value of type `%World` (an uninteresting placeholder like `null`, `0`, or - in case of the JavaScript backends - `undefined`) is passed to the `main` function, thus setting the whole program in motion. However, it is impossible to programmatically create a value of type `%World` (it is an abstract, primitive type), and therefore we cannot ever extract a value of type `a` from an `IO a` action (modulo `unsafePerformIO`).

Once we will talk about monad transformers and the state monad, you will see that `IO` is nothing else but a state monad in disguise but with an abstract state type, which makes it impossible for us to run the stateful computation.

<!-- vi: filetype=idris2:syntax=markdown
-->
