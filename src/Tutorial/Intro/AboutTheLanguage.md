# About the Idris Programming Language

Idris is a *pure*, *dependently typed*, *total* *functional* programming language. I'll quickly explain each of these adjectives in this section.

## Functional Programming

In functional programming languages, functions are first-class constructs, meaning that they can be assigned to variables, passed as arguments to other functions, and returned as results from functions. Unlike for instance in object-oriented programming languages, in functional programming, functions are the main form of abstraction. This means that whenever we find a common pattern or (almost) identical code in several parts of a project, we try to abstract over this in order to have to write the corresponding code only once. We do this by introducing one or more new functions implementing this behavior. Doing so, we often try to be as general as possible to make our functions as versatile to use as possible.

Functional programming languages are concerned with the evaluation of functions, unlike classical imperative languages, which are concerned with the execution of statements.

## Pure Functional Programming

Pure functional programming languages come with an additional important guarantee: Functions don't have side effects like writing to a file or mutating global state. They can only compute a result from their arguments possibly by invoking other pure functions, *and nothing else*. As a consequence, given the same input, they will *always* generate the same output. This property is known as [referential transparency](https://en.wikipedia.org/wiki/Referential_transparency).

Pure functions have several advantages:

- They can easily be tested by specifying (possibly randomly generated) sets of input arguments together with the expected results.

- They are thread-safe, since they don't mutate global state, and as such can be freely used in several computations running in parallel.

There are, of course, also some disadvantages:

- Some algorithms are hard to implement efficiently using only pure functions.

- Writing programs that actually *do* something (have some observable effect) is a bit trickier but certainly possible.

## Dependent Types

Idris is a strongly, statically typed programming language. This means that every Idris expression is given a *type* (for instance: integer, list of strings, boolean, function from integer to boolean, etc.) and types are verified at compile time to rule out certain common programming errors.

For instance, if a function expects an argument of type `String` (a sequence of unicode characters, such as `"Hello123"`), it is a *type error* to invoke this function with an argument of type `Integer`, and the Idris compiler will refuse to generate an executable from such an ill-typed program.

Being *statically typed* means that the Idris compiler will catch type errors at *compile time*, that is, before it generates an executable program that can be run. The opposite to this are *dynamically typed* languages such as Python, which check for type errors at *runtime*, that is, when a program is being executed. It is the philosophy of statically typed languages to catch as many type errors as possible before there even is a program that can be run.

Even more, Idris is *dependently typed*, which is one of its most characteristic properties in the landscape of programming languages. In Idris, types are *first class*: Types can be passed as arguments to functions, and functions can return types as their results. Even more, types can *depend* on other *values*. What this means, and why this is incredibly useful, we'll explore in due time.

## Total Functions

A *total* function is a pure function, that is guaranteed to return a value of the expected return type for every possible input in a finite number of computational steps. A total function will never fail with an exception or loop infinitely, although it can still take arbitrarily long to compute its result

Idris comes with a totality checker built-in, which enables us to verify the functions we write to be provably total. Totality in Idris is opt-in, as in general, checking the totality of an arbitrary computer program is undecidable (see also the [halting problem](https://en.wikipedia.org/wiki/Halting_problem)). However, if we annotate a function with the `total` keyword, Idris will fail with a type error, if its totality checker cannot verify that the function in question is indeed total.

<!-- vi: filetype=idris2:syntax=markdown
-->
