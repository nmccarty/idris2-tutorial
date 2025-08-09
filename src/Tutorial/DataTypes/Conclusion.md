# Conclusion

We covered a lot of ground in this chapter, so I'll summarize the most important points below:

- Enumerations are data types consisting of a finite number of possible *values*.

- Sum types are data types with more than one data constructor, where each constructor describes a *choice* that can be made.

- Product types are data types with a single constructor used to group several values of possibly different types.

- We use pattern matching to deconstruct immutable values in Idris. The possible patterns correspond to a data type's data constructors.

- We can *bind* variables to values in a pattern or use an underscore as a placeholder for a value that's not needed on the right hand side of an implementation.

- We can pattern match on an intermediary result by introducing a *case block*.

- The preferred way to define new product types is to define them as *records*, since these come with additional syntactic conveniences for setting and modifying individual *record fields*.

- Generic types and functions allow us generalize certain concepts and make them available for many types by using *type parameters* instead of concrete types in function and type signatures.

- Common concepts like *nullary values* (`Maybe`), computations that might fail with some error condition (`Either`), and handling collections of values of the same type at once (`List`) are example use cases of generic types and functions already provided by the *Prelude*.

## What's next

In the next section, we will introduce *interfaces*, another approach to *function overloading*.
