# Generic Data Types

```idris
module Tutorial.DataTypes.GenericDataTypes

import Tutorial.DataTypes.Enumerations
```

Sometimes, a concept is general enough that we'd like to apply it not just to one type, but to all kinds of types. For instance, it would be highly inconvenient if we had to define a notion of a list over and over again for every type we might want to put in a list, a list of integers and a list of strings may have differently typed contents, but they share the same structure, and repeating that structure would lead to lots of code duplication. Instead we'd like to have a single generic list type *parameterized* by the type of value it stores.

In this section, we will explore the definition and use of generic types.

## Maybe

Suppose we want to parse a value of the `Weekday` type, described in the section on enumerations, from user input. Such a parsing function should return `Saturday` if the user provided string was `"Saturday"`, but what should it return if the input were, say, `"sdfkl332"`? We have another of options here, for instance, we could return another "default" value, such as `Sunday`, but we must consider what behavior programmers using our library might expect. However, silently continuing with such a default value in the face of invalid user input is very rarely the best option, and can lead to a lot of confusion.

If we were working in a traditional imperative language, our parsing function would probably throw an exception upon encountering such invalid input. Idris has the option to throw an exception too, through the [`idris_crash`](https://www.idris-lang.org/Idris2/prelude/docs/Builtin.html#Builtin.idris_crash) function in the *Prelude*, but we need to abandon totality to do this, our function would no longer return a value for every possible input. This is a high price to pay for something as commonplace as a parsing error.

In a language like Java, C#, or C++, our function *might* also return some sort of `null` value (leading to the dreaded `NullPointerException` if not handled properly in the consuming code). Our solution will be conceptually similar, but instead of silently returning a `null`, we will make the possibility of failure visible in the type. We'll define a custom data type, which encapsulates the possibility of failure.

Defining new data types in Idris is very cheap, in terms of the amount of code needed, so this pattern is very often seen as a way of increasing type safety. Here's what such a bespoke type might look like for our use-case, along with the associated parsing function:

```idris
data MaybeWeekday = WD Weekday | NoWeekday

total
readWeekday : String -> MaybeWeekday
readWeekday "Monday"    = WD Monday
readWeekday "Tuesday"   = WD Tuesday
readWeekday "Wednesday" = WD Wednesday
readWeekday "Thursday"  = WD Thursday
readWeekday "Friday"    = WD Friday
readWeekday "Saturday"  = WD Saturday
readWeekday "Sunday"    = WD Sunday
readWeekday _           = NoWeekday
```

But what if we'd like also like to read a `Bool` from user input? We'd have to write another custom data type, `MaybeBool`, and so on for all the types we'd like to be able to parse from a `String`.

Idris, like many other programming languages, allows us to generalize this behavior by using *generic data types*. Here's what the *generic* version of our `MaybeWeekday` might look like:

> [!NOTE]
> While the prelude calls this type `Maybe`, we are calling it `Option` to avoid conflict. You may recognize the name `Option` from other programming languages, for instance, Rust uses the name `Option` to refer to this concept.

```idris
data Option a = Some a | None

total
readBool : String -> Option Bool
readBool "True"    = Some True
readBool "False"   = Some False
readBool _         = None
```

Let's go to the REPL and take a look at the types to get a feel for what we are working with here:

```repl
Tutorial.DataTypes.GenericDataTypes> :t Some
Tutorial.DataTypes.GenericDataTypes.Some : a -> Option a
Tutorial.DataTypes.GenericDataTypes> :t None
Tutorial.DataTypes.GenericDataTypes.None : Option a
Tutorial.DataTypes.GenericDataTypes> :t Option
Tutorial.DataTypes.GenericDataTypes.Option : Type -> Type
```

> [!NOTE]
> `Option` is what we call a *type constructor*, it is not yet a saturated type. It is, instead, a *function* from `Type` to `Type`. Only when we provide it a `Type` argument does it actually become a *type*.
>
> We say that `Option` is a type constructor *parameterized* over a *parameter* of type `Type`. While `Option` may not be a type, `Option Bool` is a type, and so is `Option Weekday`. Even `Option (Option Bool)` is a valid type.
>
> `Some` and `None` are `Option`'s *data constructors*, they are functions used to create values of type `Option a` for a given type `a`

Let's see some other use cases for `Option`. Below is a safe division operation:

```idris
total
safeDiv : Integer -> Integer -> Option Integer
safeDiv n 0 = None
safeDiv n k = Some (n `div` k)
```

The possibility of returning some kind of *null* value in the face of invalid input is so common, that there is a data type like `Option` already in the *Prelude*: `Maybe`, with data constructors `Just` and `Nothing`.

It is important to understand the difference between returning `Maybe Integer` in a function, which might fail, and returning `null` in languages like Java: In the former case, the possibility of failure is visible in the types. The type checker will force us to treat `Maybe Integer` differently than `Integer`: Idris will *not* allow us to forget to eventually handle the failure case. Not so, if `null` is silently returned without adjusting the types. Programmers may (and often *will*) forget to handle the `null` case, leading to unexpected and sometimes hard to debug runtime exceptions.

## Either

While `Maybe` is very useful to quickly provide a default value to signal some kind of failure, this value (`Nothing`) is not very informative. It will not tell us *what exactly* went wrong. For instance, in case of our `Weekday` reading function, it might be interesting later on to know the value of the invalid input string. And just like with `Maybe` and `Option` above, this concept is general enough that we might encounter other types of invalid values. Here's a data type to encapsulate this:

```idris
data Validated e a = Invalid e | Valid a
```

`Validated` is a type constructor parameterized over two type parameters `e` and `a`. It's data constructors are `Invalid` and `Valid`, the former holding a value describing some error condition, the latter the result in case of a successful computation. Let's see this in action:

```idris
total
readWeekdayV : String -> Validated String Weekday
readWeekdayV "Monday"    = Valid Monday
readWeekdayV "Tuesday"   = Valid Tuesday
readWeekdayV "Wednesday" = Valid Wednesday
readWeekdayV "Thursday"  = Valid Thursday
readWeekdayV "Friday"    = Valid Friday
readWeekdayV "Saturday"  = Valid Saturday
readWeekdayV "Sunday"    = Valid Sunday
readWeekdayV s           = Invalid ("Not a weekday: " ++ s)
```

Again, this is such a general concept that a data type similar to `Validated` is already available from the *Prelude*: `Either` with data constructors `Left` and `Right`. It is very common for functions to encapsulate the possibility of failure by returning an `Either err val`, where `err` is the error type and `val` is the desired return type. This is the type safe (and total!) alternative to throwing a catchable exception in an imperative language.

Note, however, that the semantics of `Either` are not always "`Left` is an error and `Right` a success". A function returning an `Either` just means that it can have to different types of results, each of which are *tagged* with the corresponding data constructor.

## List

One of the most important data structures in pure functional programming is the singly linked list. Here is its definition (called `Seq` in order for it not to collide with `List`, which is of course already available from the Prelude):

```idris
data Seq a = Nil | (::) a (Seq a)
```

This calls for some explanations. `Seq` consists of two *data constructors*: `Nil` (representing an empty sequence of values) and `(::)` (also called the *cons operator*), which prepends a new value of type `a` to an already existing list of values of the same type. As you can see, we can also use operators as data constructors, but please do not overuse this. Use clear names for your functions and data constructors and only introduce new operators when it truly helps readability!

Here is an example of how to use the `List` constructors (I use `List` here, as this is what you should use in your own code):

```idris
total
ints : List Int64
ints = 1 :: 2 :: -3 :: Nil
```

However, there is a more concise way of writing the above. Idris accepts special syntax for constructing data types consisting exactly of the two constructors `Nil` and `(::)`:

```idris
total
ints2 : List Int64
ints2 = [1, 2, -3]

total
ints3 : List Int64
ints3 = []
```

The two definitions `ints` and `ints2` are treated identically by the compiler. Note, that list syntax can also be used in pattern matches.

There is another thing that's special about `Seq` and `List`: Each of them is defined in terms of itself (the cons operator accepts a value and another `Seq` as arguments). We call such data types *recursive* data types, and their recursive nature means, that in order to decompose or consume them, we typically require recursive functions. In an imperative language, we might use a for loop or similar construct to iterate over the values of a `List` or a `Seq`, but these things do not exist in a language without in-place mutation. Here's how to sum a list of integers:

```idris
total
intSum : List Integer -> Integer
intSum Nil       = 0
intSum (n :: ns) = n + intSum ns
```

Recursive functions can be hard to grasp at first, so I'll break this down a bit. If we invoke `intSum` with the empty list, the first pattern matches and the function returns zero immediately. If, however, we invoke `intSum` with a non-empty list - `[7,5,9]` for instance - the following happens:

1. The second pattern matches and splits the list into two parts: Its head (`7`) is bound to variable `n` and its tail (`[5,9]`) is bound to `ns`:

   ```repl
   7 + intSum [5,9]
   ```

2. In a second invocation, `intSum` is called with a new list: `[5,9]`. The second pattern matches and `n` is bound to `5` and `ns` is bound to `[9]`:

   ```repl
   7 + (5 + intSum [9])
   ```

3. In a third invocation `intSum` is called with list `[9]`. The second pattern matches and `n` is bound to `9` and `ns` is bound to `[]`:

   ```repl
   7 + (5 + (9 + intSum [])
   ```

4. In a fourth invocation, `intSum` is called with list `[]` and returns `0` immediately:

   ```repl
   7 + (5 + (9 + 0)
   ```

5. In the third invocation, `9` and `0` are added and `9` is returned:

   ```repl
   7 + (5 + 9)
   ```

6. In the second invocation, `5` and `9` are added and `14` is returned:

   ```repl
   7 + 14
   ```

7. Finally, our initial invocation of `intSum` adds `7` and `14` and returns `21`.

Thus, the recursive implementation of `intSum` leads to a sequence of nested calls to `intSum`, which terminates once the argument is the empty list.

## Generic Functions

In order to fully appreciate the versatility that comes with generic data types, we also need to talk about generic functions. Like generic types, these are parameterized over one or more type parameters.

Consider for instance the case of breaking out of the `Option` data type. In case of a `Some`, we'd like to return the stored value, while for the `None` case we provide a default value. Here's how to do this, specialized to `Integer`s:

```idris
total
integerFromOption : Integer -> Option Integer -> Integer
integerFromOption _ (Some y) = y
integerFromOption x None     = x
```

It's pretty obvious that this, again, is not general enough. Surely, we'd also like to break out of `Option Bool` or `Option String` in a similar fashion. That's exactly what the generic function `fromOption` does:

```idris
total
fromOption : a -> Option a -> a
fromOption _ (Some y) = y
fromOption x None     = x
```

The lower-case `a` is again a *type parameter*. You can read the type signature as follows: "For any type `a`, given a *value* of type `a`, and an `Option a`, we can return a value of type `a`." Note, that `fromOption` knows nothing else about `a`, other than it being a type. It is therefore not possible, to conjure a value of type `a` out of thin air. We *must* have a value available to deal with the `None` case.

The pendant to `fromOption` for `Maybe` is called `fromMaybe` and is available from module `Data.Maybe` from the *base* library.

Sometimes, `fromOption` is not general enough. Assume we'd like to print the value of a freshly parsed `Bool`, giving some generic error message in case of a `None`. We can't use `fromOption` for this, as we have an `Option Bool` and we'd like to return a `String`. Here's how to do this:

```idris
total
option : b -> (a -> b) -> Option a -> b
option _ f (Some y) = f y
option x _ None     = x

total
handleBool : Option Bool -> String
handleBool = option "Not a boolean value." show
```

Function `option` is parameterized over *two* type parameters: `a` represents the type of values stored in the `Option`, while `b` is the return type. In case of a `Just`, we need a way to convert the stored `a` to a `b`, an that's done using the function argument of type `a -> b`.

In Idris, lower-case identifiers in function types are treated as *type parameters*, while upper-case identifiers are treated as types or type constructors that must be in scope.

<!-- vi: filetype=idris2:syntax=markdown
-->
