# Do Blocks, Desugared

```idris
module Tutorial.IO.DoUnsugared

import Data.List1
import Data.String
import Data.Vect

import Tutorial.IO.PureSideEffects

%default total
```

Here's an important piece of information: There is nothing special about *do blocks*. They are just syntactic sugar, which is converted to a sequence of operator applications. With [syntactic sugar](https://en.wikipedia.org/wiki/Syntactic_sugar), we mean syntax in a programming language that makes it easier to express certain things in that language without making the language itself any more powerful or expressive. Here, it means you could write all the `IO` programs without using `do` notation, but the code you'll write will sometimes be harder to read, so *do blocks* provide nicer syntax for these occasions.

Consider the following example program:

```idris
sugared1 : IO ()
sugared1 = do
  str1 <- getLine
  str2 <- getLine
  str3 <- getLine
  putStrLn (str1 ++ str2 ++ str3)
```

The compiler will convert this to the following program *before disambiguating function names and type checking*:

```idris
desugared1 : IO ()
desugared1 =
  getLine >>= (\str1 =>
    getLine >>= (\str2 =>
      getLine >>= (\str3 =>
        putStrLn (str1 ++ str2 ++ str3)
      )
    )
  )
```

There is a new operator (`(>>=)`) called *bind* in the implementation of `desugared1`. If you look at its type at the REPL, you'll see the following:

```repl
Main> :t (>>=)
Prelude.>>= : Monad m => m a -> (a -> m b) -> m b
```

This is a constrained function requiring an interface called `Monad`. We will talk about `Monad` and some of its friends in the next chapter. Specialized to `IO`, *bind* has the following type:

```repl
Main> :t (>>=) {m = IO}
>>= : IO a -> (a -> IO b) -> IO b
```

This describes a sequencing of `IO` actions. Upon execution, the first `IO` action is being run and its result is being passed as an argument to the function generating the second `IO` action, which is then also being executed.

You might remember, that you already implemented something similar in an earlier exercise: In Algebraic Data Types, you implemented *bind* for `Maybe` and `Either e`. We will learn in the next chapter, that `Maybe` and `Either e` too come with an implementation of `Monad`. For now, suffice to say that `Monad` allows us to run computations with some kind of effect in sequence by passing the *result* of the first computation to the function returning the second computation. In `desugared1` you can see, how we first perform an `IO` action and use its result to compute the next `IO` action and so on. The code is somewhat hard to read, since we use several layers of nested anonymous function, that's why in such cases, *do blocks* are a nice alternative to express the same functionality.

Since *do block* are always desugared to sequences of applied *bind* operators, we can use them to chain any monadic computation. For instance, we can rewrite function `eval` by using a *do block* like so:

```idris
evalDo : String -> Either Error Integer
evalDo s = case forget $ split isSpace s of
  [x,y,z] => do
    v1 <- readInteger x
    op <- readOperator y
    v2 <- readInteger z
    Right $ op v1 v2
  _       => Left (ParseError s)
```

Don't worry, if this doesn't make too much sense yet. We will see many more examples, and you'll get the hang of this soon enough. The important thing to remember is how *do blocks* are always converted to sequences of *bind* operators as shown in `desugared1`.

## Binding Unit

Remember our implementation of `friendlyReadHello`? Here it is again:

```idris
friendlyReadHello' : IO ()
friendlyReadHello' = do
  _ <- putStrLn "Please enter your name."
  readHello
```

The underscore in there is a bit ugly and unnecessary. In fact, a common use case is to just chain effectful computations with result type `Unit` (`()`), merely for the side effects they perform. For instance, we could repeat `friendlyReadHello` three times, like so:

```idris
friendly3 : IO ()
friendly3 = do
  _ <- friendlyReadHello
  _ <- friendlyReadHello
  friendlyReadHello
```

This is such a common thing to do, that Idris allows us to drop the bound underscores altogether:

```idris
friendly4 : IO ()
friendly4 = do
  friendlyReadHello
  friendlyReadHello
  friendlyReadHello
  friendlyReadHello
```

Note, however, that the above gets desugared slightly differently:

```idris
friendly4Desugared : IO ()
friendly4Desugared =
  friendlyReadHello >>
  friendlyReadHello >>
  friendlyReadHello >>
  friendlyReadHello
```

Operator `(>>)` has the following type:

```repl
Main> :t (>>)
Prelude.>> : Monad m => m () -> Lazy (m b) -> m b
```

Note the `Lazy` keyword in the type signature. This means, that the wrapped argument will be *lazily evaluated*. This makes sense in many occasions. For instance, if the `Monad` in question is `Maybe` the result will be `Nothing` if the first argument is `Nothing`, in which case there is no need to even evaluate the second argument.

## Do, Overloaded

Because Idris supports function and operator overloading, we can write custom *bind* operators, which allows us to use *do notation* for types without an implementation of `Monad`. For instance, here is a custom implementation of `(>>=)` for sequencing computations returning vectors. Every value in the first vector (of length `m`) will be converted to a vector of length `n`, and the results will be concatenated leading to a vector of length `m * n`:

```idris
flatten : Vect m (Vect n a) -> Vect (m * n) a
flatten []        = []
flatten (x :: xs) = x ++ flatten xs

(>>=) : Vect m a -> (a -> Vect n b) -> Vect (m * n) b
as >>= f = flatten (map f as)
```

It is not possible to write an implementation of `Monad`, which encapsulates this behavior, as the types wouldn't match: Monadic *bind* specialized to `Vect` has type `Vect k a -> (a -> Vect k b) -> Vect k b`. As you see, the sizes of all three occurrences of `Vect` have to be the same, which is not what we expressed in our custom version of *bind*. Here is an example to see this in action:

```idris
modString : String -> Vect 4 String
modString s = [s, reverse s, toUpper s, toLower s]

testDo : Vect 24 String
testDo = DoUnsugared.do
  s1 <- ["Hello", "World"]
  s2 <- [1, 2, 3]
  modString (s1 ++ show s2)
```

Try to figure out how `testDo` works by desugaring it manually and then comparing its result with what you expected at the REPL. Note, how we helped Idris disambiguate, which version of the *bind* operator to use by prefixing the `do` keyword with part of the operator's namespace. In this case, this wasn't strictly necessary, although `Vect k` does have an implementation of `Monad`, but it is still good to know that it is possible to help the compiler with disambiguating do blocks.

Of course, we can (and should!) overload `(>>)` in the same manner as `(>>=)`, if we want to overload the behavior of *do blocks*.

### Modules and Namespaces

Every data type, function, or operator can be unambiguously identified by prefixing it with its *namespace*. A function's namespace typically is the same as the module where it was defined. For instance, the fully qualified name of function `eval` would be `Tutorial.IO.eval`. Function and operator names must be unique in their namespace.

As we already learned, Idris can often disambiguate between functions with the same name but defined in different namespaces based on the types involved. If this is not possible, we can help the compiler by *prefixing* the function or operator name with a *suffix* of the full namespace. Let's demonstrate this at the REPL:

```repl
Tutorial.IO> :t (>>=)
Prelude.>>= : Monad m => m a -> (a -> m b) -> m b
Tutorial.IO.>>= : Vect m a -> (a -> Vect n b) -> Vect (m * n) b
```

As you can see, if we load this module in a REPL session and inspect the type of `(>>=)`, we get two results as two operators with this name are in scope. If we only want the REPL to print the type of our custom *bind* operator, is is sufficient to prefix it with `IO`, although we could also prefix it with its full namespace:

```repl
Tutorial.IO> :t IO.(>>=)
Tutorial.IO.>>= : Vect m a -> (a -> Vect n b) -> Vect (m * n) b
Tutorial.IO> :t Tutorial.IO.(>>=)
Tutorial.IO.>>= : Vect m a -> (a -> Vect n b) -> Vect (m * n) b
```

Since function names must be unique in their namespace and we still may want to define two overloaded versions of a function in an Idris module, Idris makes it possible to add additional namespaces to modules. For instance, in order to define another function called `eval`, we need to add it to its own namespace (note, that all definitions in a namespace must be indented by the same amount of whitespace):

```idris
namespace Foo
  export
  eval : Nat -> Nat -> Nat
  eval = (*)

-- prefixing `eval` with its namespace is not strictly necessary here
testFooEval : Nat
testFooEval = Foo.eval 12 100
```

Now, here is an important thing: For functions and data types to be accessible from outside their namespace or module, they need to be *exported* by annotating them with the `export` or `public export` keywords.

The difference between `export` and `public export` is the following: A function annotated with `export` exports its type and can be called from other namespaces. A data type annotated with `export` exports its type constructor but not its data constructors. A function annotated with `public export` also exports its implementation. This is necessary to use the function in compile-time computations. A data type annotated with `public export` exports its data constructors as well.

In general, consider annotating data types with `public export`, since otherwise you will not be able to create values of these types or deconstruct them in pattern matches. Likewise, unless you plan to use your functions in compile-time computations, annotate them with `export`.

## Bind, with a Bang

Sometimes, even *do blocks* are too noisy to express a combination of effectful computations. In this case, we can prefix the effectful parts with an exclamation mark (wrapping them in parentheses if they contain additional whitespace), while leaving pure expressions unmodified:

```idris
getHello : IO ()
getHello = putStrLn $ "Hello " ++ !getLine ++ "!"
```

The above gets desugared to the following *do block*:

```idris
getHello' : IO ()
getHello' = do
  s <- getLine
  putStrLn $ "Hello " ++ s ++ "!"
```

Here is another example:

```idris
bangExpr : String -> String -> String -> Maybe Integer
bangExpr s1 s2 s3 =
  Just $ !(parseInteger s1) + !(parseInteger s2) * !(parseInteger s3)
```

And here is the desugared *do block*:

```idris
bangExpr' : String -> String -> String -> Maybe Integer
bangExpr' s1 s2 s3 = do
  x1 <- parseInteger s1
  x2 <- parseInteger s2
  x3 <- parseInteger s3
  Just $ x1 + x2 * x3
```

Please remember the following: Syntactic sugar has been introduced to make code more readable or more convenient to write. If it is abused just to show how clever you are, you make things harder for other people (including your future self!) reading and trying to understand your code.

<!-- vi: filetype=idris2:syntax=markdown
-->
