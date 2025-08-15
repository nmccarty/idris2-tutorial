# Records

```idris
module Tutorial.DataTypes.Records

import Tutorial.DataTypes.Enumerations
import Tutorial.DataTypes.SumTypes
```

It is often useful to group together several related values into a single logical unit. For instance, in our web application, we might want to group several pieces of information about a user into a single data type. Such data types are often called *product types*. The most common and convenient way to define such types is the `record` keyword:

```idris
record User where
  constructor MkUser
  name  : String
  title : Title
  age   : Bits8
```

The declaration above creates a new *type*, called `User`, and a new *data constructor* called `MkUser`. As usual, let's have a look at their types in the REPL:

```repl
Tutorial.DataTypes.Records> :t User
Tutorial.DataTypes.Records.User : Type
Tutorial.DataTypes.Records> :t MkUser
Tutorial.DataTypes.Records.MkUser : String -> Title -> Bits8 -> User
```

We can use `MkUser`, which is a function from `String` to `Title` to `Bits8` to `User`, to create values of type `User`:

```idris
total
agentY : User
agentY = MkUser "Y" (Other "Agent") 51

total
drNo : User
drNo = MkUser "No" dr 73
```

We can also use pattern matching to extract the fields from a value of the `User` type, binding them to local variables, just as we previously explored in the context of sum types:

```idris
total
greetUser : User -> String
greetUser (MkUser n t _) = greet t n
```

In our `greetUser` function, the `name` and `title` field are bound to two new local variables (`n` and `t` respectively), which can then be used on the right hand side of its implementation. For the `age` field, which is not used on the right hand side, we can use an underscore as a catch-all pattern, signifying our intent to ignore it's value.

In this instance, Idris will prevent us from making a common mistake, if we confuse the order of arguments, the implementation will no longer type check.

We can verify this by putting the erroneous code in a `failing` block:

> [!NOTE]
> The `failing` keyword marks an indented code block which is intended to fail to type check. Idris will attempt to compile the code inside the `failing` block, and give us an error if the included code actually does type check.
>
> Additionally, a string can optionally be specified as an argument to the `failing` keyword. If such a string is given, Idris will verify that the resulting compilation error contains the provided string, and provide a compilation error otherwise.
>
> `failing` blocks serve as a useful tool to show that type saftey works in two directions, allowing us to show not only that valid code type checks, but also that invalid code does not type check.

```idris
failing "Mismatch between: String and Title"
  greetUser' : User -> String
  greetUser' (MkUser n t _) = greet n t
```

Alternatively, we can prevent such errors more generally by exploiting the fact that the arguments of a record constructor are, in fact, *named arguments*:

```idris
total
greetUser' : User -> String
greetUser' (MkUser {name = n, title = t, age = _}) = greet t n
```

We'll explore this syntax in full detail in the chapter on advanced function topics, but for now, take note that using the named argument syntax frees us from having to care about the order of the augments:

```idris
total
greetUser'' : User -> String
greetUser'' (MkUser {age = _, title = t, name = n}) = greet t n
```

For every record field, Idris creates an accessor function of the same name. This can either be used as a regular function, or it can be used in postfix notation by appending it to a variable of the associated record type separated by a dot:

```idris
getAgeFunction : User -> Bits8
getAgeFunction u = age u

getAgePostfix : User -> Bits8
getAgePostfix u = u.age
```

## Syntactic Sugar for Records

As we discussed in the introduction, Idris is a *pure* functional programming language. In pure functions, we are not allowed to modify global mutable state, as such, if we want to modify a record value, we must create a *new* value, leaving the original value remaining unchanged. Records, like other values in Idris, are *immutable*. While this *can* have an impact on performance, it comes with the benefit that we can freely pass a record value to different functions, without needing to consider the possibility of the functions modifying the value through in-place mutation. These are, again, very strong guarantees, making it drastically easier to reason about our code.

There are several ways to modify a record, the most general being to pattern match on the record and adjust each field as desired. If, for instance, we'd like to increase the age of a `User` by one, we could do the following:

```idris
total
incAge : User -> User
incAge (MkUser name title age) = MkUser name title (age + 1)
```

That's a lot of code for such a simple thing, so Idris offers several syntactic conveniences for "modifying" values in records. For instance, using *record* syntax, we can directly access and update the `age` field of a value:

> [!NOTE]
> In record syntax, `:=` updates the named field to a provided *value*, while `$=` updates the named field by applying a provided *function* to its current value.

```idris
total
incAge2 : User -> User
incAge2 u = { age := u.age + 1 } u
```

Here, the assignment operator `:=` assigns a new value to the `age` field in the record stored in `u`. Remember, this will create a new `User` value, the original value in `u` remains unaffected by this.

We can access a record field, either by using the field name as a projection function (`age u`; also have a look at `:t age` in the REPL), or by using dot syntax: `u.age`. This is its own special syntax and is *not* related to the dot operator for function composition (`(.)`).

Modifying a record field is such a common use case that Idris provides special syntax for it as well:

```idris
total
incAge3 : User -> User
incAge3 u = { age $= (+ 1) } u
```

In this example, we use an *operator section* (`(+ 1)`) to define a function that accepts a numeric value and adds one to to it, here inferred to have type `Bits8 -> Bits8` due to the type of the `age` field, in a concise manner. As a more general alternative, we could have used an anonymous function instead:

```idris
total
incAge4 : User -> User
incAge4 u = { age $= \x => x + 1 } u
```

Since our function's argument `u` is only used once at the very end, we can drop it altogether, to get the following, highly concise version. You may recognize this as an example of [tacit programming](https://en.wikipedia.org/wiki/Tacit_programming), sometimes also called "point-free" style:

```idris
total
incAge5 : User -> User
incAge5 = { age $= (+ 1) }
```

As usual, we should give this a try at the REPL:

```repl
Tutorial.DataTypes.Records> incAge5 drNo
MkUser "No" (Other "Dr.") 74
```

> [!NOTE]
> Record syntax can also be used to set and/or update multiple record fields at once

```idris
total
drNoJunior : User
drNoJunior = { name $= (++ " Jr."), title := Mr, age := 17 } drNo
```

## Tuples

Previously, we refereed to records as *product types*. Much like how *sum types* are named by analogy to addition, product types are named by analogy to multiplication. Before we dig into this, lets define an example record to discuss in concrete terms:

```idris
record Foo where
  constructor MkFoo
  wd   : Weekday
  bool : Bool
```

Consider how many possible values there are of type `Foo`. There are 7 possible values for the `wd` field, since it is of type `Weekday`, and 2 possible values for the `bool` field. Since `Foo` can contain any possible combination of valid values of these two types, we need to multiply, or take the *product*, the numbers of possible values for each of the two types, getting `7 * 2 = 14`.

The most basic product type is the `Pair`, a type that stores two values, each of different types. Idris provides `Pair` in the *Prelude*:

```idris
total
weekdayAndBool : Weekday -> Bool -> Pair Weekday Bool
weekdayAndBool wd b = MkPair wd b
```

Since it is quite common to return several values from a function wrapped in a `Pair`, or a larger tuple, Idris provides some syntactic sugar for working with tuples. Instead of `Pair Weekday Bool`, we can write `(Weekday, Bool)`. Likewise, instead of `MkPair wd b`, we can write `(wd, b)` (the space is optional):

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

> [!NOTE]
> Tuples of more than two elements, such as in the `triple2` example, are converted into nested tuples, as in the `triple` example, by the Idris compiler.
>
> `(a, b, c)` becomes `(a, (b, c))`, also written `Pair a (Pair b c)`, `(a, b, c, d)` becomes `(a, (b, (c, d)))`, and so on.

Tuple syntax can also be used in pattern matching:

```idris
total
bar : Bool
bar = case triple of
  (b,wd,_) => b && isWeekend wd
```

## As Patterns

Sometimes, we'd like to take apart a value by pattern matching on it, but still retain the original value as a whole for using it in further computations:

```idris
total
baz : (Bool,Weekday,String) -> (Nat,Bool,Weekday,String)
baz t@(_,_,s) = (length s, t)
```

In our `baz` function, the variable `t` is *bound* to the triple as a whole, which is then reused to construct the resulting quadruple. Remember, that `(Nat,Bool,Weekday,String)` is just sugar for `Pair Nat (Bool,Weekday,String)`, and `(length s, t)` is just sugar for `MkPair (length s) t`. Hence, the implementation above is correct as is confirmed by the type checker.

<!-- vi: filetype=idris2:syntax=markdown
-->
