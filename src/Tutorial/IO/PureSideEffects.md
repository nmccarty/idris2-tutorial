# Pure Side Effects?

```idris
module Tutorial.IO.PureSideEffects

import Data.List1
import Data.String
import Data.Vect

%default total
```

If we once again look at the *hello world* example from the introduction, it had the following type and implementation:

```idris
hello : IO ()
hello = putStrLn "Hello World!"
```

If you load this module in a REPL session and evaluate `hello`, you'll get the following:

```repl
Tutorial.IO> hello
MkIO (prim__putStr "Hello World!")
```

This might not be what you expected, given that we'd actually wanted the program to just print "Hello World!". In order to explain what's going on here, we need to quickly look at how evaluation at the REPL works.

When we evaluate some expression at the REPL, Idris tries to reduce it to a value until it gets stuck somewhere. In the above case, Idris gets stuck at function `prim__putStr`. This is a *foreign function* defined in the *Prelude*, which has to be implemented by each backend in order to be available there. At compile time (and at the REPL), Idris knows nothing about the implementations of foreign functions and therefore can't reduce foreign function calls, unless they are built into the compiler itself. But even then, values of type `IO a` (`a` being a type parameter) are typically not reduced.

It is important to understand that values of type `IO a` *describe* a program, which, when being *executed*, will return a value of type `a`, after performing arbitrary side effects along the way. For instance, `putStrLn` has type `String -> IO ()`. Read this as: "`putStrLn` is a function, which, when given a `String` argument, will return a description of an effectful program with an output type of `()`". (`()` is syntactic sugar for type `Unit`, the empty tuple defined at the *Prelude*, which has only one value called `MkUnit`, for which we can also use `()` in our code.)

Since values of type `IO a` are mere descriptions of effectful computations, functions returning such values or taking such values as arguments are still *pure* and thus referentially transparent. It is, however, not possible to extract a value of type `a` from a value of type `IO a`, that is, there is no generic function `IO a -> a`, as such a function would inadvertently execute the side effects when extracting the result from its argument, thus breaking referential transparency. (Actually, there *is* such a function called `unsafePerformIO`. Do not ever use it in your code unless you know what you are doing.)

## Do Blocks

If you are new to pure functional programming, you might now - rightfully - mumble something about how useless it is to have descriptions of effectful programs without being able to run them. So please, hear me out. While we are not able to run values of type `IO a` when writing programs, that is, there is no function of type `IO a -> a`, we are able to chain such computations and describe more complex programs. Idris provides special syntax for this: *Do blocks*. Here's an example:

```idris
export
readHello : IO ()
readHello = do
  name <- getLine
  putStrLn $ "Hello " ++ name ++ "!"
```

Before we talk about what's going on here, let's give this a go at the REPL:

```repl
Tutorial.IO> :exec readHello
Stefan
Hello Stefan!
```

This is an interactive program, which will read a line from standard input (`getLine`), assign the result to variable `name`, and then use `name` to create a friendly greeting and write it to standard output.

Note the `do` keyword at the beginning of the implementation of `readHello`: It starts a *do block*, where we can chain `IO` computations and bind intermediary results to variables using arrows pointing to the left (`<-`), which can then be used in later `IO` actions. This concept is powerful enough to let us encapsulate arbitrary programs with side effects in a single value of type `IO`. Such a description can then be returned by function `main`, the main entry point to an Idris program, which is being executed when we run a compiled Idris binary.

## The Difference between Program Description and Execution

In order to better understand the difference between *describing* an effectful computation and *executing* or *running* it, here is a small program:

```idris
launchMissiles : IO ()
launchMissiles = putStrLn "Boom! You're dead."

export
friendlyReadHello : IO ()
friendlyReadHello = do
  _ <- putStrLn "Please enter your name."
  readHello

actions : Vect 3 (IO ())
actions = [launchMissiles, friendlyReadHello, friendlyReadHello]

runActions : Vect (S n) (IO ()) -> IO ()
runActions (_ :: xs) = go xs
  where go : Vect k (IO ()) -> IO ()
        go []        = pure ()
        go (y :: ys) = do
          _ <- y
          go ys

readHellos : IO ()
readHellos = runActions actions
```

Before I explain what the code above does, please note function `pure` used in the implementation of `runActions`. It is a constrained function, about which we will learn in the next chapter. Specialized to `IO`, it has generic type `a -> IO a`: It allows us to wrap a value in an `IO` action. The resulting `IO` program will just return the wrapped value without performing any side effects. We can now look at the big picture of what's going on in `readHellos`.

First, we define a friendlier version of `readHello`: When executed, this will ask about our name explicitly. Since we will not use the result of `putStrLn` any further, we can use an underscore as a catch-all pattern here. Afterwards, `readHello` is invoked. We also define `launchMissiles`, which, when being executed, will lead to the destruction of planet earth.

Now, `runActions` is the function we use to demonstrate that *describing* an `IO` action is not the same as *running* it. It will drop the first action from the non-empty vector it takes as its argument and return a new `IO` action, which describes the execution of the remaining `IO` actions in sequence. If this behaves as expected, the first `IO` action passed to `runActions` should be silently dropped together with all its potential side effects.

When we execute `readHellos` at the REPL, we will be asked for our name twice, although `actions` also contains `launchMissiles` at the beginning. Luckily, although we described how to destroy the planet, the action was not executed, and we are (probably) still here.

From this example we learn several things:

- Values of type `IO a` are *pure descriptions* of programs, which, when being *executed*, perform arbitrary side effects before returning a value of type `a`.

- Values of type `IO a` can be safely returned from functions and passed around as arguments or in data structures, without the risk of them being executed.

- Values of type `IO a` can be safely combined in *do blocks* to *describe* new `IO` actions.

- An `IO` action will only ever get executed when it's passed to `:exec` at the REPL, or when it is the `main` function of a compiled Idris program that is being executed.

- It is not possible to ever break out of the `IO` context: There is no function of type `IO a -> a`, as such a function would need to execute its argument in order to extract the final result, and this would break referential transparency.

## Combining Pure Code with `IO` Actions

The title of this subsection is somewhat misleading. `IO` actions *are* pure values, but what is typically meant here, is that we combine non-`IO` functions with effectful computations.

As a demonstration, in this section we are going to write a small program for evaluating arithmetic expressions. We are going to keep things simple and allow only expressions with a single operator and two arguments, both of which must be integers, for instance `12 + 13`.

We are going to use function `split` from `Data.String` in *base* to tokenize arithmetic expressions. We are then trying to parse the two integer values and the operator. These operations might fail, since user input can be invalid, so we also need an error type. We could actually just use `String`, but I consider it to be good practice to use custom sum types for erroneous conditions.

```idris
public export
data Error : Type where
  NotAnInteger    : (value : String) -> Error
  UnknownOperator : (value : String) -> Error
  ParseError      : (input : String) -> Error

dispError : Error -> String
dispError (NotAnInteger v)    = "Not an integer: " ++ v ++ "."
dispError (UnknownOperator v) = "Unknown operator: " ++ v ++ "."
dispError (ParseError v)      = "Invalid expression: " ++ v ++ "."
```

In order to parse integer literals, we use function `parseInteger` from `Data.String`:

```idris
export
readInteger : String -> Either Error Integer
readInteger s = maybe (Left $ NotAnInteger s) Right $ parseInteger s
```

Likewise, we declare and implement a function for parsing arithmetic operators:

```idris
export
readOperator : String -> Either Error (Integer -> Integer -> Integer)
readOperator "+" = Right (+)
readOperator "*" = Right (*)
readOperator s   = Left (UnknownOperator s)
```

We are now ready to parse and evaluate simple arithmetic expressions. This consists of several steps (splitting the input string, parsing each literal), each of which can fail. Later, when we learn about monads, we will see that do blocks can be used in such occasions just as well. However, in this case we can use an alternative syntactic convenience: Pattern matching in let bindings. Here is the code:

```idris
eval : String -> Either Error Integer
eval s =
  let [x,y,z]  := forget $ split isSpace s | _ => Left (ParseError s)
      Right v1 := readInteger x  | Left e => Left e
      Right op := readOperator y | Left e => Left e
      Right v2 := readInteger z  | Left e => Left e
   in Right $ op v1 v2
```

Let's break this down a bit. On the first line, we split the input string at all whitespace occurrences. Since `split` returns a `List1` (a type for non-empty lists exported from `Data.List1` in *base*) but pattern matching on `List` is more convenient, we convert the result using `Data.List1.forget`. Note, how we use a pattern match on the left hand side of the assignment operator `:=`. This is a partial pattern match (*partial* meaning, that it doesn't cover all possible cases), therefore we have to deal with the other possibilities as well, which is done after the vertical line. This can be read as follows: "If the pattern match on the left hand side is successful, and we get a list of exactly three tokens, continue with the `let` expression, otherwise return a `ParseError` in a `Left` immediately".

The other three lines behave exactly the same: Each has a partial pattern match on the left hand side with instructions what to return in case of invalid input after the vertical bar. We will later see, that this syntax is also available in *do blocks*.

Note, how all of the functionality implemented so far is *pure*, that is, it does not describe computations with side effects. (One could argue that already the possibility of failure is an observable *effect*, but even then, the code above is still referentially transparent, can be easily tested at the REPL, and evaluated at compile time, which is the important thing here.)

Finally, we can wrap this functionality in an `IO` action, which reads a string from standard input and tries to evaluate the arithmetic expression:

```idris
exprProg : IO ()
exprProg = do
  s <- getLine
  case eval s of
    Left err  => do
      putStrLn "An error occured:"
      putStrLn (dispError err)
    Right res => putStrLn (s ++ " = " ++ show res)
```

Note, how in `exprProg` we were forced to deal with the possibility of failure and handle both constructors of `Either` differently in order to print a result. Note also, that *do blocks* are ordinary expressions, and we can, for instance, start a new *do block* on the right hand side of a case expression.

<!-- vi: filetype=idris2:syntax=markdown
-->
