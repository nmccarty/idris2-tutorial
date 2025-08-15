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

This looks almost like the enumeration types from the previous section, except that there is a new *thing*, called a *data constructor*, which accepts a `String` argument (actually, the values in an enumeration are also called (nullary) data constructors). If we inspect the types at the REPL, we learn the following:

```repl
Tutorial.DataTypes> :t Mr
Tutorial.DataTypes.Mr : Title
Tutorial.DataTypes> :t Other
Tutorial.DataTypes.Other : String -> Title
```

So, `Other` is a *function* from `String` to `Title`. This means, that we can pass `Other` a `String` argument and get a `Title` as the result:

```idris
public export
total
dr : Title
dr = Other "Dr."
```

Again, a value of type `Title` can only consist of one of the three choices listed above, and again, we can use pattern matching to implement functions on the `Title` data type in a provably total way:

```idris
export
total
showTitle : Title -> String
showTitle Mr        = "Mr."
showTitle Mrs       = "Mrs."
showTitle (Other x) = x
```

Note, how in the last pattern match, the string value stored in the `Other` data constructor is *bound* to local variable `x`. Also, the `Other x` pattern has to be wrapped in parentheses, as otherwise Idris would think `Other` and `x` were to distinct function arguments.

This is a very common way to extract the values from data constructors. We can use `showTitle` to implement a function for creating a courteous greeting:

```idris
export
total
greet : Title -> String -> String
greet t name = "Hello, " ++ showTitle t ++ " " ++ name ++ "!"
```

In the implementation of `greet`, we use string literals and the string concatenation operator `(++)` to assemble the greeting from its parts.

At the REPL:

```repl
Tutorial.DataTypes> greet dr "Höck"
"Hello, Dr. Höck!"
Tutorial.DataTypes> greet Mrs "Smith"
"Hello, Mrs. Smith!"
```

Data types like `Title` are called *sum types* as they consist of the sum of their different parts: A value of type `Title` is either a `Mr`, a `Mrs`, or a `String` wrapped up in `Other`.

Here's another (drastically simplified) example of a sum type. Assume we allow two forms of authentication in our web application: Either by entering a username plus a password (for which we'll use an unsigned 64 bit integer here), or by providing username plus a (very complex) secret key. Here's a data type to encapsulate this use case:

```idris
data Credentials = Password String Bits64 | Key String String
```

As an example of a very primitive login function, we can hard-code some known credentials:

```idris
total
login : Credentials -> String
login (Password "Anderson" 6665443) = greet Mr "Anderson"
login (Key "Y" "xyz")               = greet (Other "Agent") "Y"
login _                             = "Access denied!"
```

As can be seen in the example above, we can also pattern match against primitive values by using integer and string literals. Give `login` a go at the REPL:

```repl
Tutorial.DataTypes> login (Password "Anderson" 6665443)
"Hello, Mr. Anderson!"
Tutorial.DataTypes> login (Key "Y" "xyz")
"Hello, Agent Y!"
Tutorial.DataTypes> login (Key "Y" "foo")
"Access denied!"
```

<!-- vi: filetype=idris2:syntax=markdown
-->
