# Recursion and Folds

In this chapter, we are going to have a closer look at the computations we typically perform with *container types*: Parameterized data types like `List`, `Maybe`, or `Identity`, holding zero or more values of the parameter's type. Many of these functions are recursive in nature, so we start with a discourse about recursion in general, and tail recursion as an important optimization technique in particular. Most recursive functions in this part will describe pure iterations over lists.

It is recursive functions, for which totality is hard to determine, so we will next have a quick look at the totality checker and learn, when it will refuse to accept a function as being total and what to do about this.

Finally, we will start looking for common patterns in the recursive functions from the first part and will eventually introduce a new interface for consuming container types: Interface `Foldable`.

```idris hide
module Tutorial.Folds

import Data.List1
import Data.Maybe
import Data.Vect
import Debug.Trace

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->
