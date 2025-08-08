# Applicative

```idris
module Tutorial.Functor.Applicative

import Tutorial.Functor.Functor

import Data.List1
import Data.String
import Data.Vect

%default total
```

While `Functor` allows us to map a pure, unary function over a value in a context, it doesn't allow us to combine n such values under an n-ary function.

For instance, consider the following functions:

```idris
liftMaybe2 : (a -> b -> c) -> Maybe a -> Maybe b -> Maybe c
liftMaybe2 f (Just va) (Just vb) = Just $ f va vb
liftMaybe2 _ _         _         = Nothing

liftVect2 : (a -> b -> c) -> Vect n a -> Vect n b -> Vect n c
liftVect2 _ []        []        = []
liftVect2 f (x :: xs) (y :: ys) = f x y :: liftVect2 f xs ys

liftIO2 : (a -> b -> c) -> IO a -> IO b -> IO c
liftIO2 f ioa iob = fromPrim $ go (toPrim ioa) (toPrim iob)
  where go : PrimIO a -> PrimIO b -> PrimIO c
        go pa pb w =
          let MkIORes va w2 = pa w
              MkIORes vb w3 = pb w2
           in MkIORes (f va vb) w3
```

This behavior is not covered by `Functor`, yet it is a very common thing to do. For instance, we might want to read two numbers from standard input (both operations might fail), calculating the product of the two. Here's the code:

```idris
multNumbers : Num a => Neg a => IO (Maybe a)
multNumbers = do
  s1 <- getLine
  s2 <- getLine
  pure $ liftMaybe2 (*) (parseInteger s1) (parseInteger s2)
```

And it won't stop here. We might just as well want to have `liftMaybe3` for ternary functions and three `Maybe` arguments and so on, for arbitrary numbers of arguments.

But there is more: We'd also like to lift pure values into the context in question. With this, we could do the following:

```idris
liftMaybe3 : (a -> b -> c -> d) -> Maybe a -> Maybe b -> Maybe c -> Maybe d
liftMaybe3 f (Just va) (Just vb) (Just vc) = Just $ f va vb vc
liftMaybe3 _ _         _         _         = Nothing

pureMaybe : a -> Maybe a
pureMaybe = Just

multAdd100 : Num a => Neg a => String -> String -> Maybe a
multAdd100 s t = liftMaybe3 calc (parseInteger s) (parseInteger t) (pure 100)
  where calc : a -> a -> a -> a
        calc x y z = x * y + z
```

As you'll of course already know, I am now going to present a new interface to encapsulate this behavior. It's called `Applicative`. Here is its definition and an example implementation:

```idris
public export
interface Functor' f => Applicative' f where
  app   : f (a -> b) -> f a -> f b
  pure' : a -> f a

export
implementation Applicative' Maybe where
  app (Just fun) (Just val) = Just $ fun val
  app _          _          = Nothing

  pure' = Just
```

Interface `Applicative` is of course already exported by the *Prelude*. There, function `app` is an operator sometimes called *app* or *apply*: `(<*>)`.

You may wonder, how functions like `liftMaybe2` or `liftIO3` are related to operator *apply*. Let me demonstrate this:

```idris
liftA2 : Applicative f => (a -> b -> c) -> f a -> f b -> f c
liftA2 fun fa fb = pure fun <*> fa <*> fb

liftA3 : Applicative f => (a -> b -> c -> d) -> f a -> f b -> f c -> f d
liftA3 fun fa fb fc = pure fun <*> fa <*> fb <*> fc
```

It is really important for you to understand what's going on here, so let's break these down. If we specialize `liftA2` to use `Maybe` for `f`, `pure fun` is of type `Maybe (a -> b -> c)`. Likewise, `pure fun <*> fa` is of type `Maybe (b -> c)`, as `(<*>)` will apply the value stored in `fa` to the function stored in `pure fun` (currying!).

You'll often see such chains of applications of *apply*, the number of *applies* corresponding to the arity of the function we lift. You'll sometimes also see the following, which allows us to drop the initial call to `pure`, and use the operator version of `map` instead:

```idris
liftA2' : Applicative f => (a -> b -> c) -> f a -> f b -> f c
liftA2' fun fa fb = fun <$> fa <*> fb

liftA3' : Applicative f => (a -> b -> c -> d) -> f a -> f b -> f c -> f d
liftA3' fun fa fb fc = fun <$> fa <*> fb <*> fc
```

So, interface `Applicative` allows us to lift values (and functions!) into computational contexts and apply them to values in the same contexts. Before we will see an extended example why this is useful, I'll quickly introduce some syntactic sugar for working with applicative functors.

## Idiom Brackets

The programming style used for implementing `liftA2'` and `liftA3'` is also referred to as *applicative style* and is used a lot in Haskell for combining several effectful computations with a single pure function.

In Idris, there is an alternative to using such chains of operator applications: Idiom brackets. Here's another reimplementation of `liftA2` and `liftA3`:

```idris
liftA2'' : Applicative f => (a -> b -> c) -> f a -> f b -> f c
liftA2'' fun fa fb = [| fun fa fb |]

liftA3'' : Applicative f => (a -> b -> c -> d) -> f a -> f b -> f c -> f d
liftA3'' fun fa fb fc = [| fun fa fb fc |]
```

The above implementations will be desugared to the one given for `liftA2` and `liftA3`, again *before disambiguating, type checking, and filling in of implicit values*. Like with the *bind* operator, we can therefore write custom implementations for `pure` and `(<*>)`, and Idris will use these if it can disambiguate between the overloaded function names.

## Use Case: CSV Reader

In order to understand the power and versatility that comes with applicative functors, we will look at a slightly extended example. We are going to write some utilities for parsing and decoding content from CSV files. These are files where each line holds a list of values separated by commas (or some other delimiter). Typically, they are used to store tabular data, for instance from spread sheet applications. What we would like to do is convert lines in a CSV file and store the result in custom records, where each record field corresponds to a column in the table.

For instance, here is a simple example file, containing tabular user information from a web store: First name, last name, age (optional), email address, gender, and password.

```repl
Jon,Doe,42,jon@doe.ch,m,weijr332sdk
Jane,Doe,,jane@doe.ch,f,aa433sd112
Stefan,Hoeck,,nope@goaway.ch,m,password123
```

And here are the Idris data types necessary to hold this information at runtime. We use again custom string wrappers for increased type safety and because it will allow us to define for each data type what we consider to be valid input:

```idris
data Gender = Male | Female | Other

public export
record Name where
  constructor MkName
  value : String

record Email where
  constructor MkEmail
  value : String

record Password where
  constructor MkPassword
  value : String

record User where
  constructor MkUser
  firstName : Name
  lastName  : Name
  age       : Maybe Nat
  email     : Email
  gender    : Gender
  password  : Password
```

We start by defining an interface for reading fields in a CSV file and writing implementations for the data types we'd like to read:

```idris
public export
interface CSVField a where
  read : String -> Maybe a
```

Below are implementations for `Gender` and `Bool`. I decided to in these cases encode each value with a single lower case character:

```idris
export
CSVField Gender where
  read "m" = Just Male
  read "f" = Just Female
  read "o" = Just Other
  read _   = Nothing

export
CSVField Bool where
  read "t" = Just True
  read "f" = Just False
  read _   = Nothing
```

For numeric types, we can use the parsing functions from `Data.String`:

```idris
export
CSVField Nat where
  read = parsePositive

export
CSVField Integer where
  read = parseInteger

export
CSVField Double where
  read = parseDouble
```

For optional values, the stored type must itself come with an instance of `CSVField`. We can then treat the empty string `""` as `Nothing`, while a non-empty string will be passed to the encapsulated type's field reader. (Remember that `(<$>)` is an alias for `map`.)

```idris
export
CSVField a => CSVField (Maybe a) where
  read "" = Just Nothing
  read s  = Just <$> read s
```

Finally, for our string wrappers, we need to decide what we consider to be valid values. For simplicity, I decided to limit the length of allowed strings and the set of valid characters.

```idris
readIf : (String -> Bool) -> (String -> a) -> String -> Maybe a
readIf p mk s = if p s then Just (mk s) else Nothing

isValidName : String -> Bool
isValidName s =
  let len = length s
   in 0 < len && len <= 100 && all isAlpha (unpack s)

export
CSVField Name where
  read = readIf isValidName MkName

isEmailChar : Char -> Bool
isEmailChar '.' = True
isEmailChar '@' = True
isEmailChar c   = isAlphaNum c

isValidEmail : String -> Bool
isValidEmail s =
  let len = length s
   in 0 < len && len <= 100 && all isEmailChar (unpack s)

CSVField Email where
  read = readIf isValidEmail MkEmail

isPasswordChar : Char -> Bool
isPasswordChar ' ' = True
-- please note that isSpace holds as well for other characaters than ' '
-- e.g. for non-breaking space: isSpace '\160' = True
-- but only ' ' shall be llowed in passwords
isPasswordChar c   = not (isControl c) && not (isSpace c)

isValidPassword : String -> Bool
isValidPassword s =
  let len = length s
   in 8 < len && len <= 100 && all isPasswordChar (unpack s)

CSVField Password where
  read = readIf isValidPassword MkPassword
```

In a later chapter, we will learn about refinement types and how to store an erased proof of validity together with a validated value.

We can now start to decode whole lines in a CSV file. In order to do so, we first introduce a custom error type encapsulating how things can go wrong:

```idris
public export
data CSVError : Type where
  FieldError           : (line, column : Nat) -> (str : String) -> CSVError
  UnexpectedEndOfInput : (line, column : Nat) -> CSVError
  ExpectedEndOfInput   : (line, column : Nat) -> CSVError
```

We can now use `CSVField` to read a single field at a given line and position in a CSV file, and return a `FieldError` in case of a failure.

```idris
export
readField : CSVField a => (line, column : Nat) -> String -> Either CSVError a
readField line col str =
  maybe (Left $ FieldError line col str) Right (read str)
```

If we know in advance the number of fields we need to read, we can try and convert a list of strings to a `Vect` of the given length. This facilitates reading record values of a known number of fields, as we get the correct number of string variables when pattern matching on the vector:

```idris
toVect : (n : Nat) -> (line, col : Nat) -> List a -> Either CSVError (Vect n a)
toVect 0     line _   []        = Right []
toVect 0     line col _         = Left (ExpectedEndOfInput line col)
toVect (S k) line col []        = Left (UnexpectedEndOfInput line col)
toVect (S k) line col (x :: xs) = (x ::) <$> toVect k line (S col) xs
```

Finally, we can implement function `readUser` to try and convert a single line in a CSV-file to a value of type `User`:

```idris
readUser' : (line : Nat) -> List String -> Either CSVError User
readUser' line ss = do
  [fn,ln,a,em,g,pw] <- toVect 6 line 0 ss
  [| MkUser (readField line 1 fn)
            (readField line 2 ln)
            (readField line 3 a)
            (readField line 4 em)
            (readField line 5 g)
            (readField line 6 pw) |]

readUser : (line : Nat) -> String -> Either CSVError User
readUser line = readUser' line . forget . split (',' ==)
```

Let's give this a go at the REPL:

```repl
Tutorial.Functor> readUser 1 "Joe,Foo,46,j@f.ch,m,pw1234567"
Right (MkUser (MkName "Joe") (MkName "Foo")
  (Just 46) (MkEmail "j@f.ch") Male (MkPassword "pw1234567"))
Tutorial.Functor> readUser 7 "Joe,Foo,46,j@f.ch,m,shortPW"
Left (FieldError 7 6 "shortPW")
```

Note, how in the implementation of `readUser'` we used an idiom bracket to map a function of six arguments (`MkUser`) over six values of type `Either CSVError`. This will automatically succeed, if and only if all of the parsings have succeeded. It would have been notoriously cumbersome resulting in much less readable code to implement `readUser'` with a succession of six nested pattern matches.

However, the idiom bracket above looks still quite repetitive. Surely, we can do better?

### A Case for Heterogeneous Lists

It is time to learn about a family of types, which can be used as a generic representation for record types, and which will allow us to represent and read rows in heterogeneous tables with a minimal amount of code: Heterogeneous lists.

```idris
namespace HList
  public export
  data HList : (ts : List Type) -> Type where
    Nil  : HList Nil
    (::) : (v : t) -> (vs : HList ts) -> HList (t :: ts)
```

A heterogeneous list is a list type indexed over a *list of types*. This allows us to at each position store a value of the type at the same position in the list index. For instance, here is a variant, which stores three values of types `Bool`, `Nat`, and `Maybe String` (in that order):

```idris
hlist1 : HList [Bool, Nat, Maybe String]
hlist1 = [True, 12, Nothing]
```

You could argue that heterogeneous lists are just tuples storing values of the given types. That's right, of course, however, as you'll learn the hard way in the exercises, we can use the list index to perform compile-time computations on `HList`, for instance when concatenating two such lists to keep track of the types stored in the result at the same time.

But first, we'll make use of `HList` as a means to concisely parse CSV-lines. In order to do that, we need to introduce a new interface for types corresponding to whole lines in a CSV-file:

```idris
public export
interface CSVLine a where
  decodeAt : (line, col : Nat) -> List String -> Either CSVError a
```

We'll now write two implementations of `CSVLine` for `HList`: One for the `Nil` case, which will succeed if and only if the current list of strings is empty. The other for the *cons* case, which will try and read a single field from the head of the list and the remainder from its tail. We use again an idiom bracket to concatenate the results:

```idris
export
CSVLine (HList []) where
  decodeAt _ _ [] = Right Nil
  decodeAt l c _  = Left (ExpectedEndOfInput l c)

export
CSVField t => CSVLine (HList ts) => CSVLine (HList (t :: ts)) where
  decodeAt l c []        = Left (UnexpectedEndOfInput l c)
  decodeAt l c (s :: ss) = [| readField l c s :: decodeAt l (S c) ss |]
```

And that's it! All we need to add is two utility function for decoding whole lines before they have been split into tokens, one of which is specialized to `HList` and takes an erased list of types as argument to make it more convenient to use at the REPL:

```idris
decode : CSVLine a => (line : Nat) -> String -> Either CSVError a
decode line = decodeAt line 1 . forget . split (',' ==)

hdecode :  (0 ts : List Type)
        -> CSVLine (HList ts)
        => (line : Nat)
        -> String
        -> Either CSVError (HList ts)
hdecode _ = decode
```

It's time to reap the fruits of our labour and give this a go at the REPL:

```repl
Tutorial.Functor> hdecode [Bool,Nat,Double] 1 "f,100,12.123"
Right [False, 100, 12.123]
Tutorial.Functor> hdecode [Name,Name,Gender] 3 "Idris,,f"
Left (FieldError 3 2 "")
```

## Applicative Laws

Again, `Applicative` implementations must follow certain laws. Here they are:

- `pure id <*> fa = fa`: Lifting and applying the identity function has no visible effect.

- `[| f . g |] <*> v = f <*> (g <*> v)`: I must not matter, whether we compose our functions first and then apply them, or whether we apply our functions first and then compose them.

  The above might be hard to understand, so here they are again with explicit types and implementations:

  ```idris
  compL : Maybe (b -> c) -> Maybe (a -> b) -> Maybe a -> Maybe c
  compL f g v = [| f . g |] <*> v

  compR : Maybe (b -> c) -> Maybe (a -> b) -> Maybe a -> Maybe c
  compR f g v = f <*> (g <*> v)
  ```

  The second applicative law states, that the two implementations `compL` and `compR` should behave identically.

- `pure f <*> pure x = pure (f x)`. This is also called the *homomorphism* law. It should be pretty self-explaining.

- `f <*> pure v = pure ($ v) <*> f`. This is called the law of *interchange*.

  This should again be explained with a concrete example:

  ```idris
  interL : Maybe (a -> b) -> a -> Maybe b
  interL f v = f <*> pure v

  interR : Maybe (a -> b) -> a -> Maybe b
  interR f v = pure ($ v) <*> f
  ```

  Note, that `($ v)` has type `(a -> b) -> b`, so this is a function type being applied to `f`, which has a function of type `a -> b` wrapped in a `Maybe` context.

  The law of interchange states that it must not matter whether we apply a pure value from the left or right of the *apply* operator.

<!-- vi: filetype=idris2:syntax=markdown
-->
