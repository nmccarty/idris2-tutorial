# Conclusion

We again covered a lot of ground in this section. I can't stress enough that you should get yourselves accustomed to programming with holes and let the type checker help you figure out what to do next.

- When in need of local utility functions, consider defining them as local definitions in a *where block*.

- Use *let expressions* to define and reuse local variables.

- Function arguments can be given a name, which can serve as documentation, can be used to pass arguments in any order, and is used to refer to them in dependent types.

- Implicit arguments are wrapped in curly braces. The compiler is supposed to infer them from the context. If that's not possible, they can be passed explicitly as other named arguments.

- Whenever possible, Idris adds implicit erased arguments for all type parameters automatically.

- Quantities allow us to track how often a function argument is used. Quantity 0 means, the argument is erased at runtime.

- Use *holes* as placeholders for pieces of code you plan to fill in at a later time. Use the REPL (or your editor) to inspect the types of holes together with the names, types, and quantities of all variables in their context.

## What's next

In the next chapter we'll start using dependent types to help us write provably correct code. Having a good understanding of how to read Idris' type signatures will be of paramount importance there. Whenever you feel lost, add one or more holes and inspect their context to decide what to do next.
