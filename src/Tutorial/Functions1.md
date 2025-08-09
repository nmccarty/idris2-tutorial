# Introduction To Functions

Idris is a *functional* programming language, functions are its main form of abstraction (unlike for instance in an object oriented language like Java, where *objects* and *classes* are the main form of abstraction). Thus, we expect Idris to make it very easy for us to compose and combine functions to create new functions. In fact, in Idris functions are *first class*, functions can take other functions as arguments and can return functions as their results.

This chapter will explore some of the basic tools Idris provides for combining and producing functions .

```idris hide
module Tutorial.Functions1
```

<!-- vi: filetype=idris2:syntax=markdown
-->
