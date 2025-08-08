# Sigma Types

So far in our examples of dependently typed programming, type indices such as the length of vectors were known at compile time or could be calculated from values known at compile time. In real applications, however, such information is often not available until runtime, where values depend on the decisions made by users or the state of the surrounding world. For instance, if we store a file's content as a vector of lines of text, the length of this vector is in general unknown until the file has been loaded into memory. As a consequence, the types of values we work with depend on other values only known at runtime, and we can often only figure out these types by pattern matching on the values they depend on. To express these dependencies, we need so called [*sigma types*](https://en.wikipedia.org/wiki/Dependent_type#%CE%A3_type): Dependent pairs and their generalization, dependent records.

```idris hide
module Tutorial.DPair

import Control.Monad.State

import Data.DPair
import Data.Either
import Data.HList
import Data.List
import Data.List1
import Data.Singleton
import Data.String
import Data.Vect

import Text.CSV

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->
