# Functions Part 1

Idris is a *functional* programming language. This means,
that functions are its main form of abstraction (unlike for
instance in an object oriented language like Java, where
*objects* and *classes* are the main form of abstraction). It also
means that we expect Idris to make it very easy for
us to compose and combine functions to create new
functions. In fact, in Idris functions are *first class*:
Functions can take other functions as arguments and
can return functions as their results.

We already learned about the basic shape of top level
function declarations in Idris in the [introduction](Intro.md),
so we will continue from what we learned there.

```idris hide
module Tutorial.Functions1
```


<!-- vi: filetype=idris2:syntax=markdown
-->
