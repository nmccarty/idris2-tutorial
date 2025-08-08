## Conclusion

- Interfaces allow us to implement the same function with different behavior for different types.
- Functions taking one or more interface implementations as arguments are called *constrained functions*.
- Interfaces can be organized hierarchically by *extending* other interfaces.
- Interfaces implementations can themselves be *constrained* requiring other implementations to be available.
- Interface functions can be given a *default implementation*, which can be overridden by implementers, for instance for reasons of efficiency.
- Certain interfaces allow us to use literal values such as string or integer literals for our own data types.

Note, that I did not yet tell the whole story about literal values in this section. More details for using literals with types that accept only a restricted set of values can be found in the chapter about [primitives](Prim.md).

### What's next

In the [next chapter](Functions2.md), we have a closer look at functions and their types. We will learn about named arguments, implicit arguments, and erased arguments as well as some constructors for implementing more complex functions.
