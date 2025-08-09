# Predicates and Proof Search

In the [last chapter](Eq.md) we learned about propositional equality, which allowed us to proof that two values are equal. Equality is a relation between values, and we used an indexed data type to encode this relation by limiting the degrees of freedom of the indices in the sole data constructor. There are other relations and contracts we can encode this way. This will allow us to restrict the values we accept as a function's arguments or the values returned by functions.

```idris hide
module Tutorial.Predicates

import Data.Either
import Data.List1
import Data.String
import Data.Vect
import Data.HList
import Decidable.Equality

import Text.CSV
import System.File

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->
