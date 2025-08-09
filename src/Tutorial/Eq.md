# Propositional Equality

In the last chapter we learned, how dependent pairs and records can be used to calculate *types* from values only known at runtime by pattern matching on these values. We will now look at how we can describe relations - or *contracts* - between values as types, and how we can use values of these types as proofs that the contracts hold.

```idris hide
module Tutorial.Eq

import Data.Either
import Data.HList
import Data.Vect
import Data.String

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->
