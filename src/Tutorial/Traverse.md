# Effectful Traversals

In this chapter, we are going to bring our treatment of the higher-kinded interfaces in the *Prelude* to an end. In order to do so, we will continue developing the CSV reader we started implementing in chapter Functor and Friends. I moved some of the data types and interfaces from that chapter to their own modules, so we can import them here without the need to start from scratch.

Note that unlike in our original CSV reader, we will use `Validated` instead of `Either` for handling exceptions, since this will allow us to accumulate all errors when reading a CSV file.

```idris hide
module Tutorial.Traverse

import Data.HList
import Data.IORef
import Data.List1
import Data.String
import Data.Validated
import Data.Vect
import Text.CSV

%default total
```

<!-- vi: filetype=idris2:syntax=markdown
-->
