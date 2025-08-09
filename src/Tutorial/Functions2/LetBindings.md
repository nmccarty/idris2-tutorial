# Let Bindings and Local Definitions

```idris
module Tutorial.Functions2.LetBindings

%default total
```

The functions we looked at so far were simple enough to be implemented directly via pattern matching without the need of additional auxiliary functions or variables. This is not always the case, and there are two important language constructs for introducing and reusing new local variables and functions. We'll look at these in two case studies.

## Use Case 1: Arithmetic Mean and Standard Deviation

In this example, we'd like to calculate the arithmetic mean and the standard deviation of a list of floating point values. There are several things we need to consider.

First, we need a function for calculating the sum of a list of numeric values. The *Prelude* exports function `sum` for this:

```repl
Main> :t sum
Prelude.sum : Num a => Foldable t => t a -> a
```

This is - of course - similar to `sumList` from Exercise 10 of the last section, but generalized to all container types with a `Foldable` implementation. We will learn about interface `Foldable` in a later section.

In order to also calculate the variance, we need to convert every value in the list to a new value, as we have to subtract the mean from every value in the list and square the result. In the previous section's exercises, we defined function `mapList` for this. The *Prelude* - of course - already exports a similar function called `map`, which is again more general and works also like our `mapMaybe` for `Maybe` and `mapEither` for `Either e`. Here's its type:

```repl
Main> :t map
Prelude.map : Functor f => (a -> b) -> f a -> f b
```

Interface `Functor` is another one we'll talk about in a later section.

Finally, we need a way to calculate the length of a list of values. We use function `length` for this:

```repl
Main> :t List.length
Prelude.List.length : List a -> Nat
```

Here, `Nat` is the type of natural numbers (unbounded, unsigned integers). `Nat` is actually not a primitive data type but a sum type defined in the *Prelude* with data constructors `Z : Nat` (for zero) and `S : Nat -> Nat` (for successor). It might seem highly inefficient to define natural numbers this way, but the Idris compiler treats these and several other *number-like* types specially, and replaces them with primitive integers during code generation.

We are now ready to give the implementation of `mean` a go. Since this is Idris, and we care about clear semantics, we will quickly define a custom record type instead of just returning a tuple of `Double`s. This makes it clearer, which floating point number corresponds to which statistic entity:

```idris
square : Double -> Double
square n = n * n

record Stats where
  constructor MkStats
  mean      : Double
  variance  : Double
  deviation : Double

stats : List Double -> Stats
stats xs =
  let len      := cast (length xs)
      mean     := sum xs / len
      variance := sum (map (\x => square (x - mean)) xs) / len
   in MkStats mean variance (sqrt variance)
```

As usual, we first try this at the REPL:

```repl
Tutorial.Functions2> stats [2,4,4,4,5,5,7,9]
MkStats 5.0 4.0 2.0
```

Seems to work, so let's digest this step by step. We introduce several new local variables (`len`, `mean`, and `variance`), which all will be used more than once in the remainder of the implementation. To do so, we use a `let` binding. This consists of the `let` keyword, followed by one or more variable assignments, followed by the final expression, which has to be prefixed by `in`. Note, that whitespace is significant again: We need to properly align the three variable names. Go ahead, and try out what happens if you remove a space in front of `mean` or `variance`. Note also, that the alignment of assignment operators `:=` is optional. I do this, since I thinks it helps readability.

Let's also quickly look at the different variables and their types. `len` is the length of the list cast to a `Double`, since this is what's needed later on, where we divide other values of type `Double` by the length. Idris is very strict about this: We are not allowed to mix up numeric types without explicit casts. Please note, that in this case Idris is able to *infer* the type of `len` from the surrounding context. `mean` is straight forward: We `sum` up the values stored in the list and divide by the list's length. `variance` is the most involved of the three: We map each item in the list to a new value using an anonymous function to subtract the mean and square the result. We then sum up the new terms and divide again by the number of values.

## Use Case 2: Simulating a Simple Web Server

In the second use case, we are going to write a slightly larger application. This should give you an idea about how to design data types and functions around some business logic you'd like to implement.

Assume we run a music streaming web server, where users can buy whole albums and listen to them online. We'd like to simulate a user connecting to the server and getting access to one of the albums they bought.

We first define a bunch of record types:

```idris
record Artist where
  constructor MkArtist
  name : String

record Album where
  constructor MkAlbum
  name   : String
  artist : Artist

record Email where
  constructor MkEmail
  value : String

record Password where
  constructor MkPassword
  value : String

record User where
  constructor MkUser
  name     : String
  email    : Email
  password : Password
  albums   : List Album
```

Most of these should be self-explanatory. Note, however, that in several cases (`Email`, `Artist`, `Password`) we wrap a single value in a new record type. Of course, we *could* have used the unwrapped `String` type instead, but we'd have ended up with many `String` fields, which can be hard to disambiguate. In order not to confuse an email string with a password string, it can therefore be helpful to wrap both of them in a new record type to drastically increase type safety at the cost of having to reimplement some interfaces. Utility function `on` from the *Prelude* is very useful for this. Don't forget to inspect its type at the REPL, and try to understand what's going on here.

```idris
Eq Artist where (==) = (==) `on` name

Eq Email where (==) = (==) `on` value

Eq Password where (==) = (==) `on` value

Eq Album where (==) = (==) `on` \a => (a.name, a.artist)
```

In case of `Album`, we wrap the two fields of the record in a `Pair`, which already comes with an implementation of `Eq`. This allows us to again use function `on`, which is very convenient.

Next, we have to define the data types representing server requests and responses:

```idris
record Credentials where
  constructor MkCredentials
  email    : Email
  password : Password

record Request where
  constructor MkRequest
  credentials : Credentials
  album       : Album

data Response : Type where
  UnknownUser     : Email -> Response
  InvalidPassword : Response
  AccessDenied    : Email -> Album -> Response
  Success         : Album -> Response
```

For server responses, we use a custom sum type encoding the possible outcomes of a client request. In practice, the `Success` case would return some kind of connection to start the actual album stream, but we just wrap up the album we found to simulate this behavior.

We can now go ahead and simulate the handling of a request at the server. To emulate our user data base, a simple list of users will do. Here's the type of the function we'd like to implement:

```idris
DB : Type
DB = List User

handleRequest : DB -> Request -> Response
```

Note, how we defined a short alias for `List User` called `DB`. This is often useful to make lengthy type signatures more readable and communicate the meaning of a type in the given context. However, this will *not* introduce a new type, nor will it increase type safety: `DB` is *identical* to `List User`, and as such, a value of type `DB` can be used wherever a `List User` is expected and vice versa. In more complex programs it is therefore usually preferable to define new types by wrapping values in single-field records.

The implementation will proceed as follows: It will first try and lookup a `User` by is email address in the data base. If this is successful, it will compare the provided password with the user's actual password. If the two match, it will lookup the requested album in the user's list of albums. If all of these steps succeed, the result will be an `Album` wrapped in a `Success`. If any of the steps fails, the result will describe exactly what went wrong.

Here's a possible implementation:

```idris
handleRequest db (MkRequest (MkCredentials email pw) album) =
  case lookupUser db of
    Just (MkUser _ _ password albums)  =>
      if password == pw then lookupAlbum albums else InvalidPassword

    Nothing => UnknownUser email

  where lookupUser : List User -> Maybe User
        lookupUser []        = Nothing
        lookupUser (x :: xs) =
          if x.email == email then Just x else lookupUser xs

        lookupAlbum : List Album -> Response
        lookupAlbum []        = AccessDenied email album
        lookupAlbum (x :: xs) =
          if x == album then Success album else lookupAlbum xs
```

I'd like to point out several things in this example. First, note how we can extract values from nested records in a single pattern match. Second, we defined two *local* functions in a `where` block: `lookupUser`, and `lookupAlbum`. Both of these have access to all variables in the surrounding scope. For instance, `lookupUser` uses the `email` variable from the pattern match in the implementation's first line. Likewise, `lookupAlbum` makes use of the `album` variable.

A `where` block introduces new local definitions, accessible only from the surrounding scope and from other functions defined later in the same `where` block. These need to be explicitly typed and indented by the same amount of whitespace.

Local definitions can also be introduced *before* a function's implementation by using the `let` keyword. This usage of `let` is not to be confused with *let bindings* described above, which are used to bind and reuse the results of intermediate computations. Below is how we could have implemented `handleRequest` with local definitions introduced by the `let` keyword. Again, all definitions have to be properly typed and indented:

```idris
handleRequest' : DB -> Request -> Response
handleRequest' db (MkRequest (MkCredentials email pw) album) =
  let lookupUser : List User -> Maybe User
      lookupUser []        = Nothing
      lookupUser (x :: xs) =
        if x.email == email then Just x else lookupUser xs

      lookupAlbum : List Album -> Response
      lookupAlbum []        = AccessDenied email album
      lookupAlbum (x :: xs) =
        if x == album then Success album else lookupAlbum xs

   in case lookupUser db of
        Just (MkUser _ _ password albums)  =>
          if password == pw then lookupAlbum albums else InvalidPassword

        Nothing => UnknownUser email
```

<!-- vi: filetype=idris2:syntax=markdown
-->
