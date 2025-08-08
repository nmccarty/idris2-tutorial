# Records

```idris
module Tutorial.DataTypes.Records

import Tutorial.DataTypes.Enumerations
import Tutorial.DataTypes.SumTypes
```

It is often useful to group together several values as a logical unit. For instance, in our web application we might want to group information about a user in a single data type. Such data types are often called *product types* (see below for an explanation). The most common and convenient way to define them is the `record` construct:

```idris
record User where
  constructor MkUser
  name  : String
  title : Title
  age   : Bits8
```

The declaration above creates a new *type* called `User`, and a new *data constructor* called `MkUser`. As usual, have a look at their types in the REPL:

```repl
Tutorial.DataTypes> :t User
Tutorial.DataTypes.User : Type
Tutorial.DataTypes> :t MkUser
Tutorial.DataTypes.MkUser : String -> Title -> Bits8 -> User
```

We can use `MkUser` (which is a function from `String` to `Title` to `Bits8` to `User`) to create values of type `User`:

```idris
total
agentY : User
agentY = MkUser "Y" (Other "Agent") 51

total
drNo : User
drNo = MkUser "No" dr 73
```

We can also use pattern matching to extract the fields from a `User` value (they can again be bound to local variables):

```idris
total
greetUser : User -> String
greetUser (MkUser n t _) = greet t n
```

In the example above, the `name` and `title` field are bound to two new local variables (`n` and `t` respectively), which can then be used on the right hand side of `greetUser`'s implementation. For the `age` field, which is not used on the right hand side, we can use an underscore as a catch-all pattern.

Note, how Idris will prevent us from making a common mistake: If we confuse the order of arguments, the implementation will no longer type check. We can verify this by putting the erroneous code in a `failing` block: This is an indented code block, which will lead to an error during elaboration (type checking). We can give part of the expected error message as an optional string argument to a failing block. If this does not match part of the error message (or the whole code block does not fail to type check) the `failing` block itself fails to type check. This is a useful tool to demonstrate that type safety works in two directions: We can show that valid code type checks but also that invalid code is rejected by the Idris elaborator:

```idris
failing "Mismatch between: String and Title"
  greetUser' : User -> String
  greetUser' (MkUser n t _) = greet n t
```

In addition, for every record field, Idris creates an extractor function of the same name. This can either be used as a regular function, or it can be used in postfix notation by appending it to a variable of the record type separated by a dot. Here are two examples for extracting the age from a user:

```idris
getAgeFunction : User -> Bits8
getAgeFunction u = age u

getAgePostfix : User -> Bits8
getAgePostfix u = u.age
```

## Syntactic Sugar for Records

As was already mentioned in the [intro](Intro.md), Idris is a *pure* functional programming language. In pure functions, we are not allowed to modify global mutable state. As such, if we want to modify a record value, we will always create a *new* value with the original value remaining unchanged: Records and other Idris values are *immutable*. While this *can* have a slight impact on performance, it has the benefit that we can freely pass a record value to different functions, without fear of the functions modifying the value by in-place mutation. These are, again, very strong guarantees, which makes it drastically easier to reason about our code.

There are several ways to modify a record, the most general being to pattern match on the record and adjust each field as desired. If, for instance, we'd like to increase the age of a `User` by one, we could do the following:

```idris
total
incAge : User -> User
incAge (MkUser name title age) = MkUser name title (age + 1)
```

That's a lot of code for such a simple thing, so Idris offers several syntactic conveniences for this. For instance, using *record* syntax, we can just access and update the `age` field of a value:

```idris
total
incAge2 : User -> User
incAge2 u = { age := u.age + 1 } u
```

Assignment operator `:=` assigns a new value to the `age` field in `u`. Remember, that this will create a new `User` value. The original value `u` remains unaffected by this.

We can access a record field, either by using the field name as a projection function (`age u`; also have a look at `:t age` in the REPL), or by using dot syntax: `u.age`. This is special syntax and *not* related to the dot operator for function composition (`(.)`).

The use case of modifying a record field is so common that Idris provides special syntax for this as well:

```idris
total
incAge3 : User -> User
incAge3 u = { age $= (+ 1) } u
```

Here, I used an *operator section* (`(+ 1)`) to make the code more concise. As an alternative to an operator section, we could have used an anonymous function like so:

```idris
total
incAge4 : User -> User
incAge4 u = { age $= \x => x + 1 } u
```

Finally, since our function's argument `u` is only used once at the very end, we can drop it altogether, to get the following, highly concise version:

```idris
total
incAge5 : User -> User
incAge5 = { age $= (+ 1) }
```

As usual, we should have a look at the result at the REPL:

```repl
Tutorial.DataTypes> incAge5 drNo
MkUser "No" (Other "Dr.") 74
```

It is possible to use this syntax to set and/or update several record fields at once:

```idris
total
drNoJunior : User
drNoJunior = { name $= (++ " Jr."), title := Mr, age := 17 } drNo
```

## Tuples

I wrote above that a record is also called a *product type*. This is quite obvious when we consider the number of possible values inhabiting a given type. For instance, consider the following custom record:

```idris
record Foo where
  constructor MkFoo
  wd   : Weekday
  bool : Bool
```

How many possible values of type `Foo` are there? The answer is `7 * 2 = 14`, as we can pair every possible `Weekday` (seven in total) with every possible `Bool` (two in total). So, the number of possible values of a record type is the *product* of the number of possible values for each field.

The canonical product type is the `Pair`, which is available from the *Prelude*:

```idris
total
weekdayAndBool : Weekday -> Bool -> Pair Weekday Bool
weekdayAndBool wd b = MkPair wd b
```

Since it is quite common to return several values from a function wrapped in a `Pair` or larger tuple, Idris provides some syntactic sugar for working with these. Instead of `Pair Weekday Bool`, we can just write `(Weekday, Bool)`. Likewise, instead of `MkPair wd b`, we can just write `(wd, b)` (the space is optional):

```idris
total
weekdayAndBool2 : Weekday -> Bool -> (Weekday, Bool)
weekdayAndBool2 wd b = (wd, b)
```

This works also for nested tuples:

```idris
total
triple : Pair Bool (Pair Weekday String)
triple = MkPair False (Friday, "foo")

total
triple2 : (Bool, Weekday, String)
triple2 = (False, Friday, "foo")
```

In the example above, `triple2` is converted to the form used in `triple` by the Idris compiler.

We can even use tuple syntax in pattern matches:

```idris
total
bar : Bool
bar = case triple of
  (b,wd,_) => b && isWeekend wd
```

## As Patterns

Sometimes, we'd like to take apart a value by pattern matching on it but still retain the value as a whole for using it in further computations:

```idris
total
baz : (Bool,Weekday,String) -> (Nat,Bool,Weekday,String)
baz t@(_,_,s) = (length s, t)
```

In `baz`, variable `t` is *bound* to the triple as a whole, which is then reused to construct the resulting quadruple. Remember, that `(Nat,Bool,Weekday,String)` is just sugar for `Pair Nat (Bool,Weekday,String)`, and `(length s, t)` is just sugar for `MkPair (length s) t`. Hence, the implementation above is correct as is confirmed by the type checker.

<!-- vi: filetype=idris2:syntax=markdown
-->
