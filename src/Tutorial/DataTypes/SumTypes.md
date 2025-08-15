# Sum Types

```idris
module Tutorial.DataTypes.SumTypes 
```

The simple enumerations we covered in the previous chapter are only the most basic form of the more general *sum types*. A lot of traditional imperative programming languages, if they have enumerations at all, only have the basic form we've already explored, where the only data stored in a value of the enumeration type is the information on which variant the particular value is. Like other functional programming languages and many contemporary imperative languages, Idris goes a step further, allowing you to store additional data of your choosing in each of the variants of your type.

To provide an example, lets assume we'd like to write some web form, where users of our web application can tell us how they would like to be addressed. We'll give them a choice between two common predefined forms of address (Mr and Mrs), but also allow them to input a completely custom, freeform value. We can encode these choices in an Idris data type like so:

```idris
public export
data Title = Mr | Mrs | Other String
```

This looks almost like the enumeration types from the previous section, except that there is a new *thing* in the `Other` "slot", called a *data constructor*, which accepts a `String` argument.

> [!TIP]
> The values in a simple enumeration are also called (nullary) data constructors

If we inspect the types at the REPL, we learn the following:

```repl
Tutorial.DataTypes.SumTypes> :t Mr
Tutorial.DataTypes.SumTypes.Mr : Title
Tutorial.DataTypes.SumTypes> :t Other
Tutorial.DataTypes.SumTypes.Other : String -> Title
```

As the REPL has informed us,`Other` is actually a *function* from a `String` to a `Title`. This means that we can pass `Other` a `String` argument and get a `Title` as the result:

```idris
public export
total
dr : Title
dr = Other "Dr."
```

Just as with simple enumerations, a value of type `Title` can only consist of one of the three choices listed above, and we can again use pattern matching to implement functions on the `Title` data type in a provably total way:

```idris
export
total
showTitle : Title -> String
showTitle Mr        = "Mr."
showTitle Mrs       = "Mrs."
showTitle (Other x) = x
```

> [!NOTE]
> In the last pattern match, the string value stored in the `Other` data constructor is *bound* to the local variable `x`. Additionally, the `Other x` pattern has to be wrapped in parentheses, as otherwise Idris would think that `Other` and `x` were two distinct function arguments.
>
> Pattern matching as such is a very common way to extract the values from data constructors.

We can build upon `showTitle` to implement a function for creating a courteous greeting from a `Title` and a name, passed in as a `String`. We'll use string literals and the string concatenation operator `(++)` to assemble the greeting from its parts:

```idris
export
total
greet : Title -> String -> String
greet t name = "Hello, " ++ showTitle t ++ " " ++ name ++ "!"
```

At the REPL:

```repl
Tutorial.DataTypes.SumTypes> greet dr "Höck"
"Hello, Dr. Höck!"
Tutorial.DataTypes.SumTypes> greet Mrs "Smith"
"Hello, Mrs. Smith!"
```

Data types such as `Title` are called *sum types*, as they consist of the sum of their different parts: A value of type `Title` is either a `Mr`, a `Mrs`, or a `String` wrapped up in `Other`.

To provide another (drastically simplified) example of a sum type, let's assume that we want to allow two forms of authentication in our web application, either by entering a username plus a password (which we will represent with an unsigned 64 bit integer here), or by providing username plus a very complex secret key (which we will represent with a string). We can encode these two options as a sum type as follows:

```idris
data Credentials = Password String Bits64 | Key String String
```

We can then use this type to implement a very primitive login function by hard-coding some known credentials:

```idris
total
login : Credentials -> String
login (Password "Anderson" 6665443) = greet Mr "Anderson"
login (Key "Y" "xyz")               = greet (Other "Agent") "Y"
login _                             = "Access denied!"
```

> [!NOTE]
> As our `login` function demonstrates, we can also pattern match against primitive values by using integer and string literals.

Let's go ahead and try out `login` at the REPL:

```repl
Tutorial.DataTypes.SumTypes> login (Password "Anderson" 6665443)
"Hello, Mr. Anderson!"
Tutorial.DataTypes.SumTypes> login (Key "Y" "xyz")
"Hello, Agent Y!"
Tutorial.DataTypes.SumTypes> login (Key "Y" "foo")
"Access denied!"
```

<!-- vi: filetype=idris2:syntax=markdown
-->
